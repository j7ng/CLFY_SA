CREATE OR REPLACE FUNCTION sa."LRP_RATE_PLAN_RULES_F" (p_carrier IN VARCHAR2,rec LRP_template_final%ROWTYPE, debug BOOLEAN default false)
RETURN VARCHAR2 IS

  -- global vars
  G_safelink_click_plans VARCHAR2(250);

  -- Private proc
  PROCEDURE get_safelink_click_plans IS
  BEGIN

     FOR r IN (select objid
                 from table_x_click_plan
                where x_click_in_sms = 0 and x_click_out_sms = 0
                  and x_click_local  > 0
                  and x_status       > 0
                  and x_bus_org NOT IN ('STRAIGHT_TALK'))
     LOOP
        G_safelink_click_plans := G_safelink_click_plans || '|' || r.objid;
     END LOOP;

   END get_safelink_click_plans;

  -- get TW rate plan
   FUNCTION get_tw_service_plan (p_esn varchar2)
   RETURN VARCHAR2 IS
      c_return_value VARCHAR2(2000);
      cursor c is
          select (select objid||'|'||description||'|'||mkt_name
              from sa.x_service_plan sp3
             where sp3.mkt_name = 'TW 1 Line with Data') service_plan
      from sa.x_account_group_member agm,
           sa.x_account_group ag,
           sa.x_service_plan sp
     where agm.ESN  = p_esn
       and ag.objid = agm.ACCOUNT_GROUP_ID
       and sp.objid = ag.SERVICE_PLAN_ID
       and sp.mkt_name = 'TW Talk and Text Only'
       and exists ( select 1
                      from sa.x_account_group_benefit agb,
                           sa.x_service_plan sp2
                     where agb.ACCOUNT_GROUP_ID = ag.objid
                       and upper(agb.status) = 'ACTIVE'
                       and sp2.objid = agb.service_plan_id
                       and sp2.mkt_name = 'TW 1.5 GB Add-On Data');
   BEGIN
      OPEN c; FETCH c INTO c_return_value; CLOSE c;
      RETURN c_return_value;
   END get_tw_service_plan;

   FUNCTION get_exception_rate_plan(p_rec IN LRP_template_final%rowtype, p_data_speed IN VARCHAR2)
      RETURN VARCHAR2 IS

      return_value varchar2(60);
      -- get rate plan from carrier finance EXCEPTIONS TABLE
      CURSOR c1 is
      SELECT distinct cf.x_rate_plan
        FROM table_site_part             sp,
             sa.x_multi_rate_plan_esns   mtme,  -- Exceptions table
             sa.x_service_plan_site_part sp2sp,
             sa.mtm_sp_carrierfeatures   mtmc,
             table_x_carrier_features    cf
      WHERE 1=1
         AND cf.objid                 = mtmc.x_carrier_features_id
         AND mtmc.priority            = mtme.x_priority
         AND mtmc.x_service_plan_id   = mtme.x_service_plan_id
         AND sp2sp.x_service_plan_id  = mtme.x_service_plan_id
         AND sp2sp.table_site_part_id = sp.objid
         AND mtme.x_esn               = sp.x_service_id
         AND sp.objid                 = p_rec.sp_objid_src        --P_SP_OBJID
         AND sp.x_service_id          = p_rec.sp_x_service_id_src --P_ESN
         AND sp.x_min                 = p_rec.sp_x_min_src        --P_MIN
         AND cf.x_feature2x_carrier   = NVL(p_rec.pi_mdn_part_inst2carrier_mkt, p_rec.ct_x_call_trans2carrier_src) --P_CARRIER_OBJID
         AND sp.part_status          in ('Active','CarrierPending')
         --
         and cf.x_data                = NVL(p_data_speed, p_rec.pn_data_capable)
         and cf.x_technology          = p_rec.pn_x_technology
         and mtmc.priority            = mtme.x_priority
         ;
         -- AND ROWNUM < 2

      -- get rate plan from carrier finance EXCEPTIONS TABLE (alternate method)
      CURSOR c2 IS
      SELECT DISTINCT cf.x_rate_plan
        FROM table_site_part             sp,
             sa.x_multi_rate_plan_esns   mtme,
             sa.x_service_plan_site_part sp2sp,
             sa.mtm_sp_carrierfeatures   mtmc,
             table_x_carrier_features    cf
      WHERE 1=1
         AND cf.objid                 = mtmc.x_carrier_features_id
         AND mtmc.priority            = mtme.x_priority
         AND mtmc.x_service_plan_id   = mtme.x_service_plan_id
         AND sp2sp.x_service_plan_id  = mtme.x_service_plan_id
         AND sp2sp.table_site_part_id = sp.objid
         AND mtme.x_esn               = sp.x_service_id
         AND sp.x_service_id          = p_rec.sp_x_service_id_src -- P_ESN
         AND sp.x_min                 = p_rec.sp_x_min_src        -- P_MIN
         AND cf.x_feature2x_carrier   = NVL(p_rec.pi_mdn_part_inst2carrier_mkt, p_rec.ct_x_call_trans2carrier_src) -- P_CARRIER_OBJID
         AND sp.part_status          in ('Active','CarrierPending')
         --
         and cf.x_data                = NVL(p_data_speed, p_rec.pn_data_capable)
         and cf.x_technology          = p_rec.pn_x_technology
         and mtmc.priority            = mtme.x_priority;
         --
         -- AND ROWNUM < 2;
   BEGIN

      FOR r IN c1 LOOP
         return_value := r.x_rate_plan;
      END LOOP;

      IF return_value IS NULL THEN
         FOR r IN c2 LOOP
            return_value := r.x_rate_plan;
         END LOOP;
      END IF;

      RETURN return_value;

   END get_exception_rate_plan;

   -- vz
   FUNCTION get_real_rate_plan_vz(rec LRP_template_final%ROWTYPE)
   RETURN VARCHAR2
   IS
         real_rate_plan          VARCHAR2(60);
         c_data_speed            VARCHAR2(60);
         c_manufacturer          VARCHAR2(60);
         c_device_type           VARCHAR2(60);
         c_last_redemption_type  VARCHAR2(250);
         n_service_plan_id       NUMBER;
         c_service_plan_desc     VARCHAR2(250);
         c_service_plan          VARCHAR2(250);
         c_brand                 VARCHAR2(250);
         c_safelink              VARCHAR2(250);
         c_tw_service_plan       VARCHAR2(2000);
         c_spl_service_plan_desc VARCHAR2(2000);
   BEGIN


      c_spl_service_plan_desc := rec.spl_service_plan_desc;
      IF  c_brand = 'TOTAL_WIRELESS'
      AND rec.spl_service_plan_desc LIKE '%TW Talk and Text Only%'
      THEN
         c_tw_service_plan := get_tw_service_plan(rec.sp_x_service_id_src);
         if c_tw_service_plan is not null then
            c_spl_service_plan_desc := c_tw_service_plan;
         end if;
      END IF;

      c_data_speed:=        REGEXP_SUBSTR (rec.pc_non_ppe,                 '([^|]*)\||$', 1, 1, NULL, 1);
      c_device_type:=       REGEXP_SUBSTR (rec.pc_non_ppe,                 '([^|]*)\||$', 1, 3, NULL, 1);
      n_service_plan_id :=  REGEXP_SUBSTR (c_spl_service_plan_desc||'|',   '([^|]*)\||$', 1, 1, NULL, 1);
      c_service_plan_desc:= REGEXP_SUBSTR (c_spl_service_plan_desc||'|',   '([^|]*)\||$', 1, 2, NULL, 1);
      c_brand:=             REGEXP_SUBSTR (rec.brand||'|',                 '([^|]*)\||$', 1, 1, NULL, 1);
      c_safelink:=          REGEXP_SUBSTR (rec.brand||'|',                 '([^|]*)\||$', 1, 2, NULL, 1);

      if debug then
         -- dbms_output.put_line('rec.spl_service_plan_desc='||rec.spl_service_plan_desc);
         dbms_output.put_line('brand = '||c_brand);
         dbms_output.put_line('safelink = '||c_safelink);
         dbms_output.put_line('device type = '||c_device_type);
         dbms_output.put_line('part class model number = '||rec.pc_x_model_number);
         dbms_output.put_line('data speed = '||c_data_speed);
         dbms_output.put_line('service plan id = '||n_service_plan_id);
         dbms_output.put_line('service plan desc = '||c_service_plan_desc);
      end if;

      IF rec.exception_table_flag = 'Y' THEN
         real_rate_plan := get_exception_rate_plan(rec, c_data_speed);
         IF real_rate_plan IS NOT NULL THEN
            RETURN real_rate_plan;
         END IF;
      END IF;

      /* Note: Always put the actual rate plan value in UPPERCASE */

      IF  c_brand = 'TOTAL_WIRELESS'
      OR  rec.carrier_rate_plan LIKE 'TW%' THEN
          -- Skip TW rate plan conversions for now
          real_rate_plan             := 'unknown';

      -- TFREVBULKTIER_ROAM
      ELSIF rec.carrier_rate_plan       = 'TFREVBULKTIER_ROAM' THEN
         -- Skip rate plan conversions from "ROAM" rate plan
         real_rate_plan             := 'TFREVBULKTIER_ROAM';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (21,41,42,43,213,316,336)
      and c_data_speed = 3
      THEN real_rate_plan := 'TFREVBLKTRUC_E_WG';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (208,209,210,211,216,318,338)
      and c_data_speed = 5
      THEN real_rate_plan := 'TFREVBLKTRUC_E_WG';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (21,41,42,43,213,316,336)
      and c_data_speed = 6 THEN real_rate_plan := 'TFREVBLKTRUC_E_WG';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (21,41,42,43,213,316,336)
      and c_data_speed = 10
      THEN real_rate_plan := 'TFREVBLKTRUC_E_WG';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (21,41,42,43,213,316,336)
      and c_data_speed = 18
      THEN real_rate_plan := 'TFREVBLKTRUC_E_WG';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (21,41,42,43,213,316,336)
      and c_data_speed = 4
      THEN real_rate_plan := 'TFREVBLKTRUC_IPHN_WG';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (208,209,210,211,216,318,338)
      and c_data_speed = 8
      THEN real_rate_plan := 'TFREVBLKTRUC_IPHN_WG';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (21,41,42,43,213,316,336)
      and c_data_speed = 12
      THEN real_rate_plan := 'TFREVBLKTRUC_IPHN_WG';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (21,41,42,43,213,316,336)
      and c_data_speed = 20
      THEN real_rate_plan := 'TFREVBLKTRUC_IPHN_WG';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (21,41,42,43,213,316,336)
      and c_data_speed = 0
      THEN real_rate_plan := 'TFREVBULKTIERUC_FEAT';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (21,41,42,43,213,316,336)
      and c_data_speed = 1
      THEN real_rate_plan := 'TFREVBULKTIERUC_FEAT';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (218,219)
      and c_data_speed = 0
      THEN real_rate_plan := 'TFREVBULKTIERUC_HP';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (224,226,228,229,230,319,339)
      and c_data_speed = 3
      THEN real_rate_plan := 'TFREVBULKTIERUC_I';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (1,325)
      and c_data_speed = 0
      THEN real_rate_plan := 'TFREVBULKTIER_D';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (1,325)
      and c_data_speed = 1
      THEN real_rate_plan := 'TFREVBULKTIER_D';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (208,209,210,211,216,318,338)
      and c_data_speed = 17
      THEN real_rate_plan := 'TF_4G_2GDATA_UC_IPHN';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (21,41,42,43,213,316,336)
      and c_data_speed = 21
      THEN real_rate_plan := 'TF_4G_2GDATA_UC_IPHN';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (21,41,42,43,213,316,336)
      and c_data_speed = 11
      THEN real_rate_plan := 'TF_4G_2GDATA_UC_WG';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (21,41,42,43,213,316,336)
      and c_data_speed = 13
      THEN real_rate_plan := 'TF_4G_2GDATA_UC_WG';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (208,209,210,211,216,318,338)
      and c_data_speed = 16
      THEN real_rate_plan := 'TF_4G_2GDATA_UC_WG';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (21,41,42,43,213,316,336)
      and c_data_speed = 19
      THEN real_rate_plan := 'TF_4G_2GDATA_UC_WG';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (21,41,42,43,213,316,336)
      and c_data_speed = 15
      THEN real_rate_plan := 'TF_4G_2GDAT_UCIPHNWG';

     ELSIF c_brand = 'STRAIGHT_TALK'
     and nvl(n_service_plan_id,-1) IN (259)
     and c_data_speed = 14
     THEN real_rate_plan := 'TF_4G_FTE_4GMBB';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (255)
      and c_data_speed = 14
      THEN real_rate_plan := 'TF_4G_MBB_1GPOOL';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (256,257,258)
      and c_data_speed = 14
      THEN real_rate_plan := 'TF_4G_MBB_2GPOOL';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (255,256,257,258,259,288,290,291,292)
      and c_data_speed = 7
      THEN real_rate_plan := 'TRACFONE_MBB';

      ELSIF c_brand = 'STRAIGHT_TALK'
      and nvl(n_service_plan_id,-1) IN (277,278)
      and c_data_speed = 9
      THEN real_rate_plan := 'TRAC_BNDLFIXED_ALERT';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (220,221,253,254,263,327,330,331,334,393,394,400,405)
      and c_data_speed = 3
      THEN real_rate_plan := 'TFREVBLKTRUC_E_WG';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (222,223,261,262,264,321,328,332,333,335,401,402,406,407,411)
      and c_data_speed = 5
      THEN real_rate_plan := 'TFREVBLKTRUC_E_WG';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (220,221,253,254,263,320,327,330,331,334,393,394,400,405,410)
      and c_data_speed = 6
      THEN real_rate_plan := 'TFREVBLKTRUC_E_WG';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (220,221,253,254,263,320,327,330,331,334,393,394,400,405,410)
      and c_data_speed = 10
      THEN real_rate_plan := 'TFREVBLKTRUC_E_WG';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (222,223,261,262,264,321,328,332,333,335,401,402,406,407,411)
      and c_data_speed = 8
      THEN real_rate_plan := 'TFREVBLKTRUC_IPHN_WG';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (220,221,253,254,263,320,327,330,331,334,393,394,400,405,410)
      and c_data_speed = 1
      THEN real_rate_plan := 'TFREVBULKTIERUC_FEAT';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (244)
      and c_data_speed = 0
      THEN real_rate_plan := 'TFREVBULKTIERUC_HP';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (244)
      and c_data_speed = 1
      THEN real_rate_plan := 'TFREVBULKTIERUC_HP';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (231,232,320,329,403,404,408,409,410)
      and c_data_speed = 3
      THEN real_rate_plan := 'TFREVBULKTIERUC_I';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (222,223,321,328,401,402,406,407,411)
      and c_data_speed = 17
      THEN real_rate_plan := 'TF_4G_2GDATA_UC_IPHN';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (220,221,320,327,393,394,400,405,410)
      and c_data_speed = 13
      THEN real_rate_plan := 'TF_4G_2GDATA_UC_WG';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (222,223,321,328,401,402,406,407,411)
      and c_data_speed = 16
      THEN real_rate_plan := 'TF_4G_2GDATA_UC_WG';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (220,221,320,327,393,394,400,405,410)
      and c_data_speed = 15
      THEN real_rate_plan := 'TF_4G_2GDAT_UCIPHNWG';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (253,254,330,331)
      and c_data_speed = 15
      THEN real_rate_plan := 'TF_4G_500MB_UCIPHNWG';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (261,262,332,333)
      and c_data_speed = 17
      THEN real_rate_plan := 'TF_4G_500MB_UC_IPHN';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (253,254,330,331)
      and c_data_speed = 13
      THEN real_rate_plan := 'TF_4G_500MB_UC_WG';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (261,262,332,333)
      and c_data_speed = 16
      THEN real_rate_plan := 'TF_4G_500MB_UC_WG';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (263,334)
      and c_data_speed = 13
      THEN real_rate_plan := 'TF_4G_TNT_100MB';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (264,335)
      and c_data_speed = 16
      THEN real_rate_plan := 'TF_4G_TNT_100MB';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (263,334)
      and c_data_speed = 15
      THEN real_rate_plan := 'TF_4G_TNT_100MB_IPHN';

      ELSIF c_brand = 'TELCEL'
      and nvl(n_service_plan_id,-1) IN (264,335)
      and c_data_speed = 17
      THEN real_rate_plan := 'TF_4G_TNT_100MB_IPHN';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,350,351,352,367,368,369,377)
      and c_data_speed = 3
      THEN real_rate_plan := 'TFREVBLKTRUC_E_WG';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (207,217,266,268,270,272,296,297,298,299,300,301,323,341,343,344,347,355,356,370,371,372,378,398)
      and c_data_speed = 5
      THEN real_rate_plan := 'TFREVBLKTRUC_E_WG';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,350,351,352,367,368,369,377)
      and c_data_speed = 6
      THEN real_rate_plan := 'TFREVBLKTRUC_E_WG';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,350,351,352,367,368,369,377)
      and c_data_speed = 10
      THEN real_rate_plan := 'TFREVBLKTRUC_E_WG';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,350,351,352,367,368,369,377)
      and c_data_speed = 18
      THEN real_rate_plan := 'TFREVBLKTRUC_E_WG';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,350,351,352,367,368,369,377)
      and c_data_speed = 4
      THEN real_rate_plan := 'TFREVBLKTRUC_IPHN_WG';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (207,217,266,268,270,272,296,297,298,299,300,301,323,341,344,347,355,356,370,371,372,378,398)
      and c_data_speed = 8
      THEN real_rate_plan := 'TFREVBLKTRUC_IPHN_WG';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,350,351,352,367,368,369,377)
      and c_data_speed = 20
      THEN real_rate_plan := 'TFREVBLKTRUC_IPHN_WG';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (101,102,212,247,248,265,279,280,281,322,367,368,369,390,413)
      and c_data_speed = 0
      THEN real_rate_plan := 'TFREVBULKTIERUC_FEAT';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (101,102,212,247,248,265,267,269,271,279,280,281,282,283,284,322,340,343,346,350,351,352,367,368,369,377,390,413)
      and c_data_speed = 1
      THEN real_rate_plan := 'TFREVBULKTIERUC_FEAT';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (233,234,376,423,424)
      and c_data_speed = 0
      THEN real_rate_plan := 'TFREVBULKTIERUC_HP';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (233,234)
      and c_data_speed = 1
      THEN real_rate_plan := 'TFREVBULKTIERUC_HP';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (225,227,273,274,275,276,324,342,345,348,373,374,375)
      and c_data_speed = 3
      THEN real_rate_plan := 'TFREVBULKTIERUC_I';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (354)
      and c_data_speed = 5
      THEN real_rate_plan := 'TFREVBULKTIERUC_TNT';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (354)
      and c_data_speed = 8
      THEN real_rate_plan := 'TFREVBULKTIERUC_TNT';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (207,217,266,268,270,272,299,300,301,323,341,344,347,370,371,372,378,398)
      and c_data_speed = 17
      THEN real_rate_plan := 'TF_4G_2GDATA_UC_IPHN';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,350,351,352,367,368,369,377)
      and c_data_speed = 21
      THEN real_rate_plan := 'TF_4G_2GDATA_UC_IPHN';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,351,352,367,368,369,377)
      and c_data_speed = 13
      THEN real_rate_plan := 'TF_4G_2GDATA_UC_WG';


      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (207,217,266,268,270,272,299,300,301,323,341,344,347,370,371,372,378,398)
      and c_data_speed = 16
      THEN real_rate_plan := 'TF_4G_2GDATA_UC_WG';


      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,350,351,352,367,368,369,377)
      and c_data_speed = 19
      THEN real_rate_plan := 'TF_4G_2GDATA_UC_WG';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,367,368,369,377)
      and c_data_speed = 15
      THEN real_rate_plan := 'TF_4G_2GDAT_UCIPHNWG';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (350)
      and c_data_speed = 13
      THEN real_rate_plan := 'TF_4G_500MB_UC_WG';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (306)
      and c_data_speed = 14
      THEN real_rate_plan := 'TF_4G_FTE_4GMBB';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (303,304)
      and c_data_speed = 14
      THEN real_rate_plan := 'TF_4G_MBB_1GPOOL';

      ELSIF c_brand = 'NET10'
      and nvl(n_service_plan_id,-1) IN (305)
      and c_data_speed = 14
      THEN real_rate_plan := 'TF_4G_MBB_2GPOOL';

      ELSIF c_brand = 'TRACFONE'
      and nvl(n_service_plan_id,-1) IN (249,250,251,252,388,399)
      and c_data_speed = 3
      THEN real_rate_plan := 'TFREVBULKTIER_NONEXP';

      ELSIF c_brand = 'TRACFONE'
      and nvl(n_service_plan_id,-1) IN (249,250,251,252,388,399)
      and c_data_speed = 6
      THEN real_rate_plan := 'TFREVBULKTIER_NONEXP';

      ELSIF c_brand = 'TRACFONE'
      and nvl(n_service_plan_id,-1) IN (252)
      and c_data_speed = 18
      THEN real_rate_plan := 'TFREVBULKTIER_NONEXP';

      ELSIF c_brand = 'TRACFONE'
      and nvl(n_service_plan_id,-1) IN (249,250,251,252,388,399)
      and c_data_speed = 5
      THEN real_rate_plan := 'TFREVBULK_BYOP_ANDR';

      ELSIF c_brand = 'TRACFONE'
      and nvl(n_service_plan_id,-1) IN (249,250,251,252,388,399)
      and c_data_speed = 8
      THEN real_rate_plan := 'TFREVBULK_BYOP_IPHN';

      ELSIF c_brand = 'TRACFONE'
      and nvl(n_service_plan_id,-1) IN (252)
      and c_data_speed = 20
      THEN real_rate_plan := 'TFREVBULK_BYOP_IPHN';

      ELSIF c_brand = 'TRACFONE'
      and nvl(n_service_plan_id,-1) IN (249,250,251,252,388,399)
      and c_data_speed = 13
      THEN real_rate_plan := 'TF_4G_100MB';

      ELSIF c_brand = 'TRACFONE'
      and nvl(n_service_plan_id,-1) IN (249,250,251,252,388,399)
      and c_data_speed = 16
      THEN real_rate_plan := 'TF_4G_100MB';

      ELSIF c_brand = 'TRACFONE'
      and nvl(n_service_plan_id,-1) IN (249,250,251,252,388,399)
      and c_data_speed = 17
      THEN real_rate_plan := 'TF_4G_500MB_IPHN_PP';

      ELSIF c_brand = 'TRACFONE'
      and nvl(n_service_plan_id,-1) IN (252)
      and c_data_speed = 21
      THEN real_rate_plan := 'TF_4G_500MB_IPHN_PP';

      ELSIF c_brand = 'TRACFONE'
      and nvl(n_service_plan_id,-1) IN (252)
      and c_data_speed = 19
      THEN real_rate_plan := 'TF_4G_500MB_PP';

      END IF;

      RETURN NVL(real_rate_plan, 'unknown');

   END get_real_rate_plan_vz;

   -- att
   FUNCTION get_real_rate_plan_att(rec LRP_template_final%ROWTYPE)
   RETURN VARCHAR2
   IS
         real_rate_plan         VARCHAR2(60);
         c_data_speed           VARCHAR2(60);
         c_device_type          VARCHAR2(250);
         c_last_redemption_type VARCHAR2(250);
         n_service_plan_id      NUMBER;
         c_service_plan_desc    VARCHAR2(250);
         c_service_plan         VARCHAR2(250);
         c_brand                VARCHAR2(250);
         c_safelink             VARCHAR2(250);

   BEGIN

      c_data_speed:=        REGEXP_SUBSTR (rec.pc_non_ppe,                 '([^|]*)\||$', 1, 1, NULL, 1);
      c_device_type:=       REGEXP_SUBSTR (rec.pc_non_ppe,                 '([^|]*)\||$', 1, 3, NULL, 1);
      n_service_plan_id :=  REGEXP_SUBSTR (rec.spl_service_plan_desc||'|', '([^|]*)\||$', 1, 1, NULL, 1);
      c_service_plan_desc:= REGEXP_SUBSTR (rec.spl_service_plan_desc||'|', '([^|]*)\||$', 1, 2, NULL, 1);
      c_brand:=             REGEXP_SUBSTR (rec.brand||'|',                 '([^|]*)\||$', 1, 1, NULL, 1);
      c_safelink:=          REGEXP_SUBSTR (rec.brand||'|',                 '([^|]*)\||$', 1, 2, NULL, 1);

      if debug then
         -- dbms_output.put_line('rec.spl_service_plan_desc='||rec.spl_service_plan_desc);
         dbms_output.put_line('brand = '||c_brand);
         dbms_output.put_line('safelink = '||c_safelink);
         dbms_output.put_line('device type = '||c_device_type);
         dbms_output.put_line('part class model number = '||rec.pc_x_model_number);
         dbms_output.put_line('data speed = '||c_data_speed);
         dbms_output.put_line('service plan id = '||n_service_plan_id);
         dbms_output.put_line('service plan desc = '||c_service_plan_desc);
      end if;

      IF rec.exception_table_flag = 'Y' THEN
         real_rate_plan := get_exception_rate_plan(rec, c_data_speed);
         IF real_rate_plan IS NOT NULL THEN
            RETURN real_rate_plan;
         END IF;
      END IF;

      IF c_brand = 'STRAIGHT_TALK'
       and nvl(n_service_plan_id,-1) IN (81,82,83,84,85,214,317,326,337)
       and c_data_speed IN (4)
       THEN real_rate_plan := 'TFV2';

      ELSIF c_brand = 'STRAIGHT_TALK'
       and nvl(n_service_plan_id,-1) IN (82,83,84,85,214,317,337)
       and c_data_speed IN (7,12,18,19,20,21)
       THEN real_rate_plan := 'TFV2';

      ELSIF c_brand = 'STRAIGHT_TALK'
       and nvl(n_service_plan_id,-1) IN (208,209,210,211,216,318,338)
       and c_data_speed IN (6)
       THEN real_rate_plan := 'TFV2';

      ELSIF c_brand = 'STRAIGHT_TALK'
       and nvl(n_service_plan_id,-1) IN (288,289,290,291,292)
       and c_data_speed IN (10)
       THEN real_rate_plan := 'TFV2';

      ELSIF c_brand = 'STRAIGHT_TALK'
       and nvl(n_service_plan_id,-1) IN (361,362,363)
       and c_data_speed IN (11)
       THEN real_rate_plan := 'TFV2';

      ELSIF c_brand = 'STRAIGHT_TALK'
       and nvl(n_service_plan_id,-1) IN (81,82,83,84,85,214,317,326,337)
       and c_data_speed IN (1)
       THEN real_rate_plan := 'TFWAP3';

      ELSIF c_brand = 'STRAIGHT_TALK'
       and nvl(n_service_plan_id,-1) IN (81,82,83,84,85,214,326,337)
       and c_data_speed IN (6)
       THEN real_rate_plan := 'TFWAP3';

      ELSIF c_brand = 'STRAIGHT_TALK'
       and nvl(n_service_plan_id,-1) IN (81,82,83,84,85,214,317,326,337)
       and c_data_speed IN (3)
       THEN real_rate_plan := 'TFMVNO3';

      ELSIF c_brand = 'STRAIGHT_TALK'
       and nvl(n_service_plan_id,-1) IN (121,122,123,124,215,353,357)
       and c_data_speed IN (6)
       THEN real_rate_plan := 'TFMVNO3';

      ELSIF c_brand = 'STRAIGHT_TALK'
       and nvl(n_service_plan_id,-1) IN (124,215)
       and c_data_speed IN (1)
       THEN real_rate_plan := 'TFMVNO3';

      ELSIF c_brand = 'STRAIGHT_TALK'
       and nvl(n_service_plan_id,-1) IN (255,256,257,258,259)
       and c_data_speed IN (9)
       THEN real_rate_plan := 'TFVDONLY';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (101,102,212,247,248,265,267,269,271,322,340,343,346,350,351,352,367,368,369)
       and c_data_speed IN (4)
       THEN real_rate_plan := 'TFV1';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,322,340,343,346,350,351,352,367,368,369)
       and c_data_speed IN (7,12,18,19,20,21)
       THEN real_rate_plan := 'TFV1';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (207,217,266,268,270,272,323,341,344,347,351,352,355,356,370,371,372,398)
       and c_data_speed IN (3)
       THEN real_rate_plan := 'TFV1';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (271,340)
       and c_data_speed IN (5)
       THEN real_rate_plan := 'TFV1';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (281,282,283,284,377)
       and c_data_speed IN (4)
       THEN real_rate_plan := 'TFV2';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (282,283,284,377)
       and c_data_speed IN (7,18,19,20,21)
       THEN real_rate_plan := 'TFV2';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (298,299,300,301,378)
       and c_data_speed IN (3)
       THEN real_rate_plan := 'TFV2';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (318,385,386,387)
       and c_data_speed IN (11)
       THEN real_rate_plan := 'TFV2';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (279,280,390,413)
       and c_data_speed IN (4)
       THEN real_rate_plan := 'TFVP';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (296,297)
       and c_data_speed IN (3)
       THEN real_rate_plan := 'TFVP';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (101,102,212,247,248,265,267,269,271,279,280,281,282,283,284,322,340,343,346,350,351,352,367,368,369,377,390,413)
       and c_data_speed IN (6)
       THEN real_rate_plan := 'TFWAP3';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (101,102,212,247,248,265,267,269,271,279,280,281,282,283,284,322,340,343,346,367,368,369,377,390,413)
       and c_data_speed IN (1)
       THEN real_rate_plan := 'TFWAP3';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (101,102,212,247,248,265,279,280,281,322,367,369,390,413)
       and c_data_speed IN (0)
       THEN real_rate_plan := 'TFWAP3';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (101,102,212,247,248,265,267,269,271,279,280,281,282,283,284,322,340,343,346,350,367,368,369,377,390,413)
       and c_data_speed IN (3)
       THEN real_rate_plan := 'TFMVNO3';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (354)
       and c_data_speed IN (3)
       THEN real_rate_plan := 'TFTTONLY';

      ELSIF c_brand = 'NET10'
       and nvl(n_service_plan_id,-1) IN (303,304,305,306,395,396,397)
       and c_data_speed IN (9)
       THEN real_rate_plan := 'TFVDONLY';

      END IF;

      IF debug THEN
         dbms_output.put_line('rateplan = '||real_rate_plan||' '||rec.data_setting);
      END IF;

      RETURN NVL(real_rate_plan, 'unknown');

   END get_real_rate_plan_att;

   -- SPRINT
   FUNCTION get_real_rate_plan_sprint(rec LRP_template_final%ROWTYPE)
   RETURN VARCHAR2
   IS

         real_rate_plan         VARCHAR2(60);
         c_last_redemption_type VARCHAR2(250);
         n_service_plan_id      NUMBER;
         c_service_plan_desc    VARCHAR2(250);
         c_service_plan         VARCHAR2(250);
         c_brand                VARCHAR2(250);
         c_safelink             VARCHAR2(250);
         c_device_type          VARCHAR2(250);
         c_data_speed           VARCHAR2(60);

   BEGIN

      c_data_speed:=        REGEXP_SUBSTR (rec.pc_non_ppe,                 '([^|]*)\||$', 1, 1, NULL, 1);
      c_device_type:=       REGEXP_SUBSTR (rec.pc_non_ppe,                 '([^|]*)\||$', 1, 3, NULL, 1);
      n_service_plan_id :=  REGEXP_SUBSTR (rec.spl_service_plan_desc||'|', '([^|]*)\||$', 1, 1, NULL, 1);
      c_service_plan_desc:= REGEXP_SUBSTR (rec.spl_service_plan_desc||'|', '([^|]*)\||$', 1, 2, NULL, 1);
      c_brand:=             REGEXP_SUBSTR (rec.brand||'|',                 '([^|]*)\||$', 1, 1, NULL, 1);
      c_safelink:=          REGEXP_SUBSTR (rec.brand||'|',                 '([^|]*)\||$', 1, 2, NULL, 1);

      if debug then
         -- dbms_output.put_line('rec.spl_service_plan_desc='||rec.spl_service_plan_desc);
         dbms_output.put_line('brand = '||c_brand);
         dbms_output.put_line('safelink = '||c_safelink);
         dbms_output.put_line('device type = '||c_device_type);
         dbms_output.put_line('part class model number = '||rec.pc_x_model_number);
         dbms_output.put_line('data speed = '||c_data_speed);
         dbms_output.put_line('service plan id = '||n_service_plan_id);
         dbms_output.put_line('service plan desc = '||c_service_plan_desc);
      end if;

      IF rec.exception_table_flag = 'Y' THEN
         real_rate_plan := get_exception_rate_plan(rec, c_data_speed);
         IF real_rate_plan IS NOT NULL THEN
            RETURN real_rate_plan;
         END IF;
      END IF;

      IF  rec.carrier_status_alt = 'SUSPENDED'
      AND c_brand IN ('STRAIGHT_TALK', 'NET10')
      AND NVL(c_data_speed,'x') IN ('4', '6') THEN
            real_rate_plan := 'TRFPLAN13';

      -- Always put the actual rate plan value in upper case

      -- TRFPLAN4
      ELSIF rec.carrier_status_alt = 'SUSPENDED' THEN
            real_rate_plan := 'TRFPLAN4';

      -- TRFPLAN1
      ELSIF c_brand = 'NET10'
        and nvl(n_service_plan_id,-1) in (322,351,352,377,265,340,282,267,247,248
                                         ,101,283,367,343,269,212,284,368,346,271
                                         ,369)
        and c_data_speed = 1
        THEN
           real_rate_plan := 'TRFPLAN1';

      -- TRFPLAN1
      ELSIF c_brand = 'STRAIGHT_TALK'
        and nvl(n_service_plan_id,-1) in (316,357,121,215,353,122,123,124)
        and c_data_speed = 1
        THEN
           real_rate_plan := 'TRFPLAN1';

      -- TRFPLAN1
      ELSIF c_brand = 'TELCEL'
        and nvl(n_service_plan_id,-1) in (320,263,334,253,330,221,254,331,220,327)
        and c_data_speed = 1
        THEN
           real_rate_plan := 'TRFPLAN1';

      -- TRFPLAN11
      ELSIF c_brand = 'NET10'
        and nvl(n_service_plan_id,-1) in (350)
        and c_data_speed = 1
        THEN
           real_rate_plan := 'TRFPLAN11';

      -- TRFPLAN11
      ELSIF c_brand = 'NET10'
        and nvl(n_service_plan_id,-1) in (350)
        and c_data_speed = 4
        THEN
           real_rate_plan := 'TRFPLAN1';

      -- TRFPLAN6
      ELSIF c_brand = 'NET10'
        and nvl(n_service_plan_id,-1) in (322,351,352,377,265,340,282,267,247,248,101
                                         ,283,367,343,269,212,284,368,346,271,369)
        and c_data_speed = 4
        THEN
           real_rate_plan := 'TRFPLAN6';

      -- TRFPLAN6
      ELSIF c_brand = 'STRAIGHT_TALK'
        and nvl(n_service_plan_id,-1) in (316,357,121,215,353,122,123,124)
        and c_data_speed = 4
        THEN
           real_rate_plan := 'TRFPLAN6';

      -- TRFPLAN11
      ELSIF c_brand = 'NET10'
        and nvl(n_service_plan_id,-1) in (354)
        and c_data_speed = 5
        THEN
           real_rate_plan := 'TRFPLAN11';

      -- TRFPLAN1
      ELSIF c_brand = 'NET10'
        and nvl(n_service_plan_id,-1) in (323,355,356,378,266,341,299,268,207,300
                                         ,370,344,270,217,301,371,347,272,372)
        and c_data_speed = 5
        THEN
           real_rate_plan := 'TRFPLAN1';

      -- TRFPLAN1
      ELSIF c_brand = 'STRAIGHT_TALK'
        and nvl(n_service_plan_id,-1) in (318,208,216,338,209,210,211)
        and c_data_speed = 5
        THEN
           real_rate_plan := 'TRFPLAN1';

      -- TRFPLAN11
      ELSIF c_brand = 'NET10'
        and nvl(n_service_plan_id,-1) in (354)
        and c_data_speed = 6
        THEN
           real_rate_plan := 'TRFPLAN11';

      -- TRFPLAN6
      ELSIF c_brand = 'NET10'
        and nvl(n_service_plan_id,-1) in (323,355,356,378,266,341,299,268,207,300
                                         ,370,344,270,217,301,371,347,272,372)
        and c_data_speed = 6
        THEN
           real_rate_plan := 'TRFPLAN6';

      -- TRFPLAN6
      ELSIF c_brand = 'STRAIGHT_TALK'
        and nvl(n_service_plan_id,-1) in (318,208,216,338,209,210,211)
        and c_data_speed = 6
        THEN
           real_rate_plan := 'TRFPLAN6';

      END IF;

      RETURN NVL(real_rate_plan, 'unknown');

   END get_real_rate_plan_sprint;

   -- TMO
   FUNCTION get_real_rate_plan_tmo(rec LRP_template_final%ROWTYPE)
   RETURN VARCHAR2
   IS
         real_rate_plan         VARCHAR2(60);
         c_data_speed           VARCHAR2(60);
         c_device_type          VARCHAR2(60);
         c_last_redemption_type VARCHAR2(250);

         n_service_plan_id      NUMBER;
         c_service_plan_mkt     VARCHAR2(250);
         c_service_plan_desc    VARCHAR2(250);
         c_click_plan           VARCHAR2(60);
         c_new_click_plan       VARCHAR2(60);

         c_service_plan         VARCHAR2(250);
         c_brand                VARCHAR2(250);
         c_safelink             VARCHAR2(250);


   BEGIN

      c_data_speed:=        REGEXP_SUBSTR (rec.pc_non_ppe,                 '([^|]*)\||$', 1, 1, NULL, 1);
      c_device_type:=       REGEXP_SUBSTR (rec.pc_non_ppe,                 '([^|]*)\||$', 1, 3, NULL, 1);

      n_service_plan_id :=  REGEXP_SUBSTR (rec.spl_service_plan_desc||'|', '([^|]*)\||$', 1, 1, NULL, 1);
      c_service_plan_desc:= REGEXP_SUBSTR (rec.spl_service_plan_desc||'|', '([^|]*)\||$', 1, 2, NULL, 1);
      c_service_plan_mkt:=  REGEXP_SUBSTR (rec.spl_service_plan_desc||'|', '([^|]*)\||$', 1, 3, NULL, 1);
      c_click_plan:=        REGEXP_SUBSTR (rec.spl_service_plan_desc||'|', '([^|]*)\||$', 1, 4, NULL, 1);
      c_new_click_plan:=    REGEXP_SUBSTR (rec.spl_service_plan_desc||'|', '([^|]*)\||$', 1, 5, NULL, 1);

      c_brand:=             REGEXP_SUBSTR (rec.brand||'|',                 '([^|]*)\||$', 1, 1, NULL, 1);
      c_safelink:=          REGEXP_SUBSTR (rec.brand||'|',                 '([^|]*)\||$', 1, 2, NULL, 1);

      IF debug THEN
         dbms_output.put_line('brand = '||c_brand);
         dbms_output.put_line('safelink = '||c_safelink);
         dbms_output.put_line('device type = '||c_device_type);
         dbms_output.put_line('part class model number = '||rec.pc_x_model_number);
         dbms_output.put_line('data speed = '||c_data_speed);
         dbms_output.put_line('service plan id = '||n_service_plan_id);
         dbms_output.put_line('service plan desc = '||c_service_plan_desc);
         dbms_output.put_line('click plan = '||c_click_plan);
         dbms_output.put_line('new click plan = '||c_new_click_plan);
      END IF;

      IF rec.exception_table_flag = 'Y' THEN
         real_rate_plan := get_exception_rate_plan(rec, c_data_speed);
         IF real_rate_plan IS NOT NULL THEN
            RETURN real_rate_plan;
         END IF;
      END IF;


      IF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (236,237,285,286,287,313,314,315)
      and c_data_speed = 1
      THEN real_rate_plan := 'Simple Data Only LTE Package';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (302)
      and c_data_speed = 1
      THEN real_rate_plan := 'Simple LTE Package';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (302)
      and c_data_speed = 18
      THEN real_rate_plan := 'Simple LTE Package';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (302)
      and c_data_speed = 19
      THEN real_rate_plan := 'Simple LTE Package';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (302)
      and c_data_speed = 22
      THEN real_rate_plan := 'Simple LTE Package';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (349,364,365,366,389,391,412,414,416)
      and c_data_speed = 1
      THEN real_rate_plan := 'Simple LTE Roam Package';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (349,364,365,366,389,391,412,414,416)
      and c_data_speed = 18
      THEN real_rate_plan := 'Simple LTE Roam Package';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (349,364,365,366,389,391,412,414,416)
      and c_data_speed = 19
      THEN real_rate_plan := 'Simple LTE Roam Package';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (349,364,365,366,389,391,412,414,416)
      and c_data_speed = 22
      THEN real_rate_plan := 'Simple LTE Roam Package';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (235,392,415)
      and c_data_speed = 1
      THEN real_rate_plan := 'Simple TT RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (235,392,415)
      and c_data_speed = 18
      THEN real_rate_plan := 'Simple TT RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (235,392,415)
      and c_data_speed = 19
      THEN real_rate_plan := 'Simple TT RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (235,392,415)
      and c_data_speed = 22
      THEN real_rate_plan := 'Simple TT RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (238,239,307,310,358,359,360)
      and c_data_speed = 1
      THEN real_rate_plan := 'Simple TTW1 RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (238,239,307,310,358,359,360)
      and c_data_speed = 18
      THEN real_rate_plan := 'Simple TTW1 RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (238,239,307,310,358,359,360)
      and c_data_speed = 19
      THEN real_rate_plan := 'Simple TTW1 RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (238,239,307,310,358,359,360)
      and c_data_speed = 22
      THEN real_rate_plan := 'Simple TTW1 RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (240,241,242,308,311)
      and c_data_speed = 1
      THEN real_rate_plan := 'Simple TTW2 RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (240,241,242,308,311)
      and c_data_speed = 18
      THEN real_rate_plan := 'Simple TTW2 RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (240,241,242,308,311)
      and c_data_speed = 19
      THEN real_rate_plan := 'Simple TTW2 RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (240,241,242,308,311)
      and c_data_speed = 22
      THEN real_rate_plan := 'Simple TTW2 RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (243,245,246,309,312)
      and c_data_speed = 1
      THEN real_rate_plan := 'Simple TTW3 RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (243,245,246,309,312)
      and c_data_speed = 18
      THEN real_rate_plan := 'Simple TTW3 RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (243,245,246,309,312)
      and c_data_speed = 19
      THEN real_rate_plan := 'Simple TTW3 RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      and nvl(n_service_plan_id,-1) IN (243,245,246,309,312)
      and c_data_speed = 22
      THEN real_rate_plan := 'Simple TTW3 RSMRC';

      ELSIF c_brand = 'SIMPLE_MOBILE'
      THEN
           real_rate_plan := 'unknown';

      -- TracFone Subscriber Package
      ELSIF c_safelink         = 'SAFELINK'
      AND   c_device_type      = 'FEATURE_PHONE'
      AND   n_service_plan_id is null
      THEN

            -- Check safelink click plans
            IF    G_safelink_click_plans||'|' NOT LIKE '%|'||NVL(c_new_click_plan, c_click_plan)||'|%'
            AND   rec.carrier_rate_plan = 'TracFone Subscriber Limited SMS (PayGo)'
            THEN
                  -- Enrolled Safe link subsriber whose new click plan did not change yet
                  real_rate_plan := 'TracFone Subscriber Limited SMS (PayGo)';

            ELSIF G_safelink_click_plans||'|' LIKE '%|'||c_new_click_plan||'|%'
            AND   rec.carrier_rate_plan = 'TracFone Subscriber Limited SMS (PayGo)'
            THEN
                  -- Enrolled Safe link subsriber whose new click plan is pending
                  real_rate_plan := 'TracFone Subscriber Limited SMS (PayGo)';

            ELSIF G_safelink_click_plans||'|' LIKE '%|'||c_click_plan||'|%'
            THEN
                  -- Enrolled Safe link subsriber whose click plan changed
                  real_rate_plan := 'TracFone Subscriber Package';

            ELSE
                  -- Existing Safe link
                  real_rate_plan := 'TracFone Subscriber Package';

            END IF;

      -- TracFone Subscriber Limited SMS (PayGo)
      ELSIF NVL(c_safelink,'X') <> 'SAFELINK'
      AND   c_brand              = 'TRACFONE'
      AND   c_device_type        = 'FEATURE_PHONE' THEN
            -- Check safelink click plans
            IF  G_safelink_click_plans||'|' LIKE '%|'||c_click_plan||'|%'
            AND rec.carrier_rate_plan = 'TracFone Subscriber Package'
            THEN
                -- De-enrolled Safe link subsriber whose click plan did not change yet
                real_rate_plan := 'TracFone Subscriber Package';
            ELSE
                -- Paygo
                real_rate_plan := 'TracFone Subscriber Limited SMS (PayGo)';
            END IF;

        ELSIF c_brand = 'NET10' and nvl(n_service_plan_id,-1) IN (303,304,305,306) and c_data_speed = 9 THEN real_rate_plan := 'TracFone Data Only LTE Package';
        ELSIF c_brand = 'NET10' and nvl(n_service_plan_id,-1) IN (101,102,212,247,248,265,279,281,322,367,368,369,390,413) and c_data_speed = 0 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'NET10' and nvl(n_service_plan_id,-1) IN (101,102,212,247,248,265,267,269,271,279,280,281,282,283,284,322,340,343,346,367,368,369,377,390,413) and c_data_speed = 1 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'NET10' and nvl(n_service_plan_id,-1) IN (101,102,212,247,248,265,267,269,271,279,280,281,282,283,284,322,340,343,346,350,351,352,367,368,369,377,390,413) and c_data_speed = 3 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'NET10' and nvl(n_service_plan_id,-1) IN (101,102,212,247,248,265,267,269,271,279,280,281,282,283,284,322,340,343,346,350,351,352,367,368,369,377,390,413) and c_data_speed = 4 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'NET10' and nvl(n_service_plan_id,-1) IN (207,217,266,268,270,272,296,297,298,299,300,301,323,341,344,347,355,356,370,371,372,378,398) and c_data_speed = 5 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'NET10' and nvl(n_service_plan_id,-1) IN (101,102,212,247,248,265,267,269,271,279,280,281,282,283,284,322,340,343,346,350,351,352,367,368,369,377,390,413) and c_data_speed = 6 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'NET10' and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,350,351,352,367,368,369,377,417) and c_data_speed = 7 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'NET10' and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,350,351,352,367,368,369,377) and c_data_speed = 18 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'NET10' and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,350,351,352,367,368,369,377) and c_data_speed = 19 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'NET10' and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,350,351,352,367,368,369,377) and c_data_speed = 20 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'NET10' and nvl(n_service_plan_id,-1) IN (101,212,247,248,265,267,269,271,282,283,284,322,340,343,346,350,351,352,367,368,369,377) and c_data_speed = 21 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'NET10' and nvl(n_service_plan_id,-1) IN (101,102,212,247,248,265,267,269,271,279,280,281,282,283,284,322,340,343,346,350,351,352,367,368,369,377,390,413) and c_data_speed = 22 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'NET10' and nvl(n_service_plan_id,-1) IN (354) and c_data_speed = 5 THEN real_rate_plan := 'TracFone Talk and Text Package';

        ELSIF c_brand = 'STRAIGHT_TALK' and nvl(n_service_plan_id,-1) IN (255,256,257,258,259) and c_data_speed = 8 THEN real_rate_plan := 'TracFone Data Only LTE Package';
        ELSIF c_brand = 'STRAIGHT_TALK' and nvl(n_service_plan_id,-1) IN (255,256,257,258,259) and c_data_speed = 9 THEN real_rate_plan := 'TracFone Data Only LTE Package';
        ELSIF c_brand = 'STRAIGHT_TALK' and nvl(n_service_plan_id,-1) IN (288,289,290,291,292) and c_data_speed = 10 THEN real_rate_plan := 'TracFone Data Only LTE Package';
        ELSIF c_brand = 'STRAIGHT_TALK' and nvl(n_service_plan_id,-1) IN (81,82,83,84,85,208,209,210,211,214,216,317,318,326,337,338) and c_data_speed = 1 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'STRAIGHT_TALK' and nvl(n_service_plan_id,-1) IN (81,82,83,84,85,214,317,326,337) and c_data_speed = 3 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'STRAIGHT_TALK' and nvl(n_service_plan_id,-1) IN (81,82,83,84,85,214,317,326,337) and c_data_speed = 4 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'STRAIGHT_TALK' and nvl(n_service_plan_id,-1) IN (81,82,83,84,85,214,317,326,337) and c_data_speed = 6 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'STRAIGHT_TALK' and nvl(n_service_plan_id,-1) IN (82,83,84,85,214,317,337) and c_data_speed = 7 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'STRAIGHT_TALK' and nvl(n_service_plan_id,-1) IN (82,83,84,85,214,317,337) and c_data_speed = 18 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'STRAIGHT_TALK' and nvl(n_service_plan_id,-1) IN (82,83,84,85,214,317,337) and c_data_speed = 19 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'STRAIGHT_TALK' and nvl(n_service_plan_id,-1) IN (82,83,84,85,214,317,337) and c_data_speed = 20 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'STRAIGHT_TALK' and nvl(n_service_plan_id,-1) IN (82,83,84,85,214,317,337) and c_data_speed = 21 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'STRAIGHT_TALK' and nvl(n_service_plan_id,-1) IN (81,82,83,84,85,214,317,326,337) and c_data_speed = 22 THEN real_rate_plan := 'TracFone LTE Package';

        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (253,261,263,264,330,332,334,335) and c_data_speed = 1 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (253,263,330,334) and c_data_speed = 3 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (253,263,330,334) and c_data_speed = 4 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (253,263,330,334) and c_data_speed = 6 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (253,263,330,334) and c_data_speed = 7 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (253,263,330,334) and c_data_speed = 22 THEN real_rate_plan := 'TracFone LTE Package';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (221,222,254,262,331,333,393,400,401,402) and c_data_speed = 1 THEN real_rate_plan := 'TracFone TTW1 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (221,254,331,393,400) and c_data_speed = 3 THEN real_rate_plan := 'TracFone TTW1 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (221,254,331,393,400) and c_data_speed = 4 THEN real_rate_plan := 'TracFone TTW1 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (221,254,331,393,400) and c_data_speed = 6 THEN real_rate_plan := 'TracFone TTW1 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (221,254,331,393,400) and c_data_speed = 7 THEN real_rate_plan := 'TracFone TTW1 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (221,254,331,393,400) and c_data_speed = 22 THEN real_rate_plan := 'TracFone TTW1 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (220,223,327,328) and c_data_speed = 1 THEN real_rate_plan := 'TracFone TTW2 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (220,327) and c_data_speed = 3 THEN real_rate_plan := 'TracFone TTW2 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (220,327) and c_data_speed = 4 THEN real_rate_plan := 'TracFone TTW2 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (220,327) and c_data_speed = 6 THEN real_rate_plan := 'TracFone TTW2 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (220,327) and c_data_speed = 7 THEN real_rate_plan := 'TracFone TTW2 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (220,327) and c_data_speed = 22 THEN real_rate_plan := 'TracFone TTW2 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (394,405,406,407) and c_data_speed = 1 THEN real_rate_plan := 'TracFone TTW3 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (394,405) and c_data_speed = 3 THEN real_rate_plan := 'TracFone TTW3 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (394,405) and c_data_speed = 4 THEN real_rate_plan := 'TracFone TTW3 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (394,405) and c_data_speed = 6 THEN real_rate_plan := 'TracFone TTW3 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (394,405) and c_data_speed = 7 THEN real_rate_plan := 'TracFone TTW3 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (394,405) and c_data_speed = 22 THEN real_rate_plan := 'TracFone TTW3 RSMRC';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (320,321,410,411) and c_data_speed = 1 THEN real_rate_plan := 'Tracfone Mexico Roaming Package';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (320,410) and c_data_speed = 3 THEN real_rate_plan := 'Tracfone Mexico Roaming Package';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (320,410) and c_data_speed = 4 THEN real_rate_plan := 'Tracfone Mexico Roaming Package';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (320,410) and c_data_speed = 6 THEN real_rate_plan := 'Tracfone Mexico Roaming Package';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (320,410) and c_data_speed = 7 THEN real_rate_plan := 'Tracfone Mexico Roaming Package';
        ELSIF c_brand = 'TELCEL' and nvl(n_service_plan_id,-1) IN (320,410) and c_data_speed = 22 THEN real_rate_plan := 'Tracfone Mexico Roaming Package';


      END IF;

      RETURN NVL(real_rate_plan, 'unknown');

   END get_real_rate_plan_tmo;


BEGIN

       get_safelink_click_plans;

       IF p_carrier    = 'ATT' THEN
          RETURN get_real_rate_plan_att(rec);
       ELSIF p_carrier = 'VERIZON' THEN
          RETURN get_real_rate_plan_vz(rec);
       ELSIF p_carrier = 'SPRINT' THEN
          RETURN get_real_rate_plan_sprint(rec);
       ELSIF p_carrier = 'TMOBILE' THEN
          RETURN get_real_rate_plan_tmo(rec);
       ELSE
          RETURN 'unknown';
       END IF;

END LRP_rate_plan_rules_f;
/