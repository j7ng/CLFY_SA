CREATE OR REPLACE PROCEDURE sa."DEACTIVATE_NONUSAGE_PRC"
   AS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: DEACTIVATE_NONUSAGE_PRC.sql,v $
  --$Revision: 1.2 $
  --$Author: kacosta $
  --$Date: 2011/12/07 20:12:21 $
  --$ $Log: DEACTIVATE_NONUSAGE_PRC.sql,v $
  --$ Revision 1.2  2011/12/07 20:12:21  kacosta
  --$ CR19138 Long running sqls #3 thats facing ORA 1555
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
/******************************************************************************/
/* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved
/*
/* Name         :   DEACTIVATE_NONUSAGE_PRC
/* Purpose      :   Deactivates the esns provided by the BI with NONUSAGE reason
/* Parameters   :   NONE
/* Platforms    :   Oracle 10.2.0.1.0
/* Author       :   Sushanth Kuthadi
/* Date         :   08/15/2009
/* Revisions    :
/*
/* Version   Date         Who             Purpose
/* -------   --------    -------      --------------------------------------
/* 1.0- 1.6  08/25/09    SK        Initial revision
/* 1.7       09/22/09    IC        Brand Separation
/******************************************************************************/

      v_user TABLE_USER.objid%TYPE;
      v_returnflag VARCHAR2 (20);
      v_returnmsg VARCHAR2 (200);
      v_deact_reason VARCHAR2(20); --CR7233
      dpp_regflag PLS_INTEGER;
      intcalltranobj NUMBER := 0;
      blnotapending BOOLEAN := FALSE;

      -- BRAND_SEP added org_id to below cursor to send to service_deactivation_code.create_call_trans

      --CR19138 Start 12/7/2011
      -- Query modified by Curt Lindner
      --CURSOR c1
      --IS
      --SELECT sp.objid site_part_objid, sp.x_service_id x_service_id, sp.x_min x_min,
      -- ca.objid carrier_objid, ir.inv_role2site site_objid,
      -- sp.serial_no x_esn, ca.x_carrier_id x_carrier_id,
      -- sp.site_objid cust_site_objid, pi.objid esnobjid, sp.x_msid,
      -- pi.part_serial_no part_serial_no, pi.x_iccid, pn.x_ota_allowed,
      -- org.org_id
      --FROM (SELECT sp.objid, sp.x_service_id, sp.x_min, sp.x_msid, sp.site_objid,
      --         sp.serial_no
      --    FROM sa.table_site_part sp,sa.x_nonusage_esns nu
      --   WHERE 1 = 1
      --     AND sp.x_service_id = nu.x_esn            -- To get ESNS which qualify for deactivation
      --     AND nu.x_deact_flag = 1
      --     AND NVL (sp.part_status, 'Obsolete') = 'Active'
      --     AND NVL (sp.x_expire_dt,
      --              TO_DATE ('1753-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss')
      --             ) >
      --                TO_DATE ('1753-02-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss')) sp,
      -- sa.table_part_inst pi2,
      -- sa.table_x_carrier ca,
      -- sa.table_part_inst pi,
      -- sa.table_inv_bin ib,
      -- sa.table_inv_role ir,
      -- sa.table_mod_level ml,
      -- sa.table_part_num pn,
      -- sa.table_bus_org org
  --WHERE 1 = 1
  -- AND pi2.x_domain = 'LINES'
  -- AND pi2.part_serial_no = NVL (sp.x_min, 'NONE')
  -- AND ca.objid = pi2.part_inst2carrier_mkt
  -- AND ca.x_carrier_id || '' NOT IN (SELECT e.x_carrier_id
  --                                     FROM sa.x_excluded_pastduedeact e)
  -- AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
  -- AND ib.objid = pi.part_inst2inv_bin
  -- AND ml.part_info2part_num = pn.objid
  -- AND pi.n_part_inst2part_mod = ml.objid
  -- AND pn.part_num2bus_org= org.objid
  -- AND pi.x_domain = 'PHONES'
  -- AND pi.part_serial_no = NVL (sp.x_service_id, 'NONE');
      --AND ROWNUM < 2501;
      --CR8422-7233 Cursors for checking deact reason
      --CR8442-7233 ADDED DATE Check and part_status active check
      --CR8442-CR11177  Removed date check
      CURSOR c1 IS
        SELECT /*+ ORDERED use_nl(sp) use_nl(pi2) use_nl(ca)*/
         sp.objid          site_part_objid
        ,sp.x_service_id   x_service_id
        ,sp.x_min          x_min
        ,ca.objid          carrier_objid
        ,ir.inv_role2site  site_objid
        ,sp.serial_no      x_esn
        ,ca.x_carrier_id   x_carrier_id
        ,sp.site_objid     cust_site_objid
        ,pi.objid          esnobjid
        ,sp.x_msid
        ,pi.part_serial_no part_serial_no
        ,pi.x_iccid
        ,pn.x_ota_allowed
        ,org.org_id
          FROM sa.x_nonusage_esns nu
              ,sa.table_site_part sp
              ,sa.table_part_inst pi2
              ,sa.table_x_carrier ca
              ,sa.table_part_inst pi
              ,sa.table_inv_bin   ib
              ,sa.table_inv_role  ir
              ,sa.table_mod_level ml
              ,sa.table_part_num  pn
              ,sa.table_bus_org   org
         WHERE 1 = 1
           AND nu.x_deact_flag = 1
           AND sp.x_service_id = nu.x_esn
           AND sp.part_status || '' = 'Active'
           AND NVL(sp.x_expire_dt
                  ,TO_DATE('1753-01-01 00:00:00'
                          ,'yyyy-mm-dd hh24:mi:ss')) > TO_DATE('1753-02-01 00:00:00'
                                                              ,'yyyy-mm-dd hh24:mi:ss')
           AND pi2.x_domain || '' = 'LINES'
           AND pi2.part_serial_no = NVL(sp.x_min
                                       ,'NONE')
           AND ca.objid = pi2.part_inst2carrier_mkt
           AND ca.x_carrier_id || '' NOT IN (SELECT e.x_carrier_id
                                               FROM sa.x_excluded_pastduedeact e)
           AND pi.part_serial_no = NVL(sp.x_service_id
                                      ,'NONE')
           AND pi.x_domain = 'PHONES'
           AND ib.objid = pi.part_inst2inv_bin
           AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
           AND ml.objid = pi.n_part_inst2part_mod
           AND pn.objid = ml.part_info2part_num
           AND org.objid = pn.part_num2bus_org;
      --CR19138 End 12/7/2011

      CURSOR check_nonusage_reason( p_esn VARCHAR2 )
      IS
      SELECT nu.x_deact_flag,
         nu.x_esn
      FROM sa.x_nonusage_esns nu, sa.table_site_part sp
      WHERE nu.x_esn = p_esn
      AND sp.x_service_id = nu.X_ESN
      AND sp.part_status = 'Active'  ---- CR8442 look only for Active ESNS
    --AND sp.x_actual_expire_dt <= nu.X_TOSS_DEACT_DATE  -- CR8442-CR11177  Removed date check
      AND nu.x_deact_flag = 1;
      check_nonusage_reason_rec check_nonusage_reason%ROWTYPE;
    BEGIN
      DBMS_OUTPUT.put_line('step 1');
      SELECT objid
      INTO v_user
      FROM sa.TABLE_USER
      WHERE s_login_name = 'SA';
      FOR c1_rec IN c1
      LOOP
         DBMS_OUTPUT.put_line('step 2');
        IF (c1_rec.x_service_id
         IS
         NULL)
         THEN
            UPDATE sa.TABLE_SITE_PART SET x_service_id = NVL (c1_rec.x_esn, c1_rec.part_serial_no
            )
            WHERE objid = c1_rec.site_part_objid;
            commit;
        END IF;
         ----CR8442-7233----check_deact_reason----------
         OPEN check_nonusage_reason(c1_rec.x_esn);
         FETCH check_nonusage_reason
         INTO check_nonusage_reason_rec;
         IF check_nonusage_reason%FOUND
         THEN
            v_deact_reason := 'NONUSAGE';
         END IF;
         CLOSE check_nonusage_reason;

           --- check for esns are in deactivation protection plan
         sa.service_deactivation_code.check_dpp_registered_prc (c1_rec.x_service_id, dpp_regflag);
         IF dpp_regflag = 1
         THEN
          dbms_output.put_line ('Entering create call trans');
            --Insert into x_call_trans
            --CR7233 Instead of passing deact reason 'PASTDUE', deact reason is passed from variable v_deact_reason.
            -- BRAND_SEP added org_id to send to service_deactivation_code.create_call_trans
            sa.service_deactivation_code.create_call_trans (c1_rec.site_part_objid, 84, c1_rec.carrier_objid
            , c1_rec.site_objid, v_user, c1_rec.x_min, c1_rec.x_service_id,
            'PROTECTION PLAN BATCH', SYSDATE, NULL, 'Monthly Payments',
            v_deact_reason, 'Pending', c1_rec.x_iccid, c1_rec.org_id, intcalltranobj );

         ELSE

            --CR#4479 - Billing Platform change request  ----start
            ------------------------------------------------------------------------------------------------
            -- Comment: added for Billing Platform.
            --          This flow is reached when the customer is not enrolled into any deact protect
            --          programs. Check here is the customer is enrolled into existing autopay programs
            --          and provide benefits accordingly.
            --          Modification START
            --------------------------------------------------------------------------------------------------
            IF ( Billing_Deactprotect (c1_rec.x_service_id) = 1 )
            THEN
                 dbms_output.put_line ('Inside Billing Deactprotect');
               -- Deactivation protection enabled. No need to deactivate the ESN.
               NULL;
            ELSE

                 dbms_output.put_line ('Calling deactservice');
--cwl CR6362 8/12/08
               --               IF NOT blnotapending THEN
               --CR3153 T-Mobile changes
               --CR7233 Instead of passing deact reason 'PASTDUE', deact reason is passed from variable v_deact_reason.
               sa.service_deactivation_code.deactservice ('NONUSAGE_BATCH', v_user, c1_rec.x_service_id,
               c1_rec.x_min, v_deact_reason, 0, NULL, 'true', v_returnflag,v_returnmsg );
               -- CR6697 09/27/07 - NEG - Close Open Warehouse Cases for Passdue Phones
               DECLARE
                  CURSOR open_cases_cur
                  IS
                  SELECT TABLE_CASE.objid
                  FROM sa.TABLE_CASE, sa.TABLE_CONDITION
                  WHERE case_state2condition = TABLE_CONDITION.objid
                  AND TABLE_CASE.x_esn = c1_rec.x_service_id
                  AND TABLE_CONDITION.condition <> 4
                  AND TABLE_CASE.objid IN (
                  SELECT request2case
                  FROM sa.TABLE_X_PART_REQUEST
                  WHERE request2case = TABLE_CASE.objid);
                  error_num VARCHAR2 (200);
                  error_str VARCHAR2 (200);
               BEGIN
                  FOR open_cases_rec IN open_cases_cur
                  LOOP
                     sa.Clarify_Case_Pkg.close_case (open_cases_rec.objid,
                     268435556, NULL, 'Closed', 'Closed', error_num, error_str
                     );
                  END LOOP;
                  EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;

            --CR6697 END
            --cwl 8/12/08
            --               END IF;
            END IF;
-- End Billing_deactprotect
         --------------------------------------------------------------------------------------------------
         --    Billing Platform Modification END
         ---------------------------------------------------------------------------------------------------
         END IF;
         -- DISABLE promotion group from group2esn
         -- CR4102 , CR3922
         FOR c2_rec IN (
         SELECT ROWID
         FROM sa.TABLE_X_GROUP2ESN
         WHERE groupesn2part_inst = c1_rec.esnobjid
         AND groupesn2x_promo_group IN (
         SELECT objid
         FROM sa.TABLE_X_PROMOTION_GROUP
         WHERE group_name IN ('90_DAY_SERVICE', '52020_GRP')))
         LOOP
            UPDATE sa.TABLE_X_GROUP2ESN u SET x_end_date = SYSDATE
            WHERE u.ROWID = c2_rec.ROWID;
            commit;
         END LOOP;
         commit;
      END LOOP;
    END deactivate_nonusage_prc;
/