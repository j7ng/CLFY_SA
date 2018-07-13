CREATE OR REPLACE PROCEDURE sa."SP_ISSUE_COMPUNITS"
 /******************************************************************************/
 /* Name : SP_ISSUE_COMPUNITS
/* Type : Procedure
/* Purpose : To issue compensation units as pending redemptions
/* Author : Gerald Pintado
/* Date : 07/24/2004
/* Revisions : Version Date Who Purpose
/* ------- -------- ------- -----------------------
/* 1.0 07/26/2004 Gpintado Initial revision
/*		 1.1	 09//3/2004 Mchinta		added caseid in
/*						 x_pend_redemption table
/*						 for warehouse REPL Units
/*		 1.2	 09/21/2004 Mchinta		Insert record into
/*			 x_call-trans table for reporting
/*		 1.3	 05/02/2005 Mchinta		CR3972 insert new column into
/*			 x_pending_redemption table for reporting
/* 1.4 05/13/2005 Mchinta CR3540
/* 1.5 09/01/2005 NGuada CR4478 - Remove previously appended units to avoid duplications
/* 1.6 08/22/2006 NGuada CR5728 - Fix issue with c_getComp cursor causing division error
/* 1.7 new_plsql 1.3 07/02/2009 ICanavan CR8740 - modified for new DMFL options
/* NEW_PLSQL PVCS
/* 1.6 01/22/2010 Nguada BRAND_SEP_IV
/* CVS
/* 1.2 03/04/2011 Nguada CR15761
/******************************************************************************/
 ( ip_esnObjid IN NUMBER,
 ip_units IN NUMBER,
 ip_idnumber IN VARCHAR2,
 op_return OUT VARCHAR2,
 op_returnMsg OUT VARCHAR2,
 ip_ChgReason IN VARCHAR2 DEFAULT NULL)
AS
 CURSOR c_getComp
 IS
 SELECT *
 FROM sa.table_x_promotion
 WHERE x_revenue_type = 'REPL'
 AND x_units > 0 -- CR5728
 ORDER BY x_units DESC;
 --start CR3229
 --Get the new esn record
 CURSOR part_inst_c(
 p_objid VARCHAR2
 )
 Is
 Select pi.*,bo.org_id
 From sa.Table_Part_Inst Pi,sa.Table_Mod_Level Ml,sa.Table_Part_Num Pn,sa.Table_Bus_Org Bo
 Where Pi.Objid = P_Objid
 And Ml.Objid=Pi.N_Part_Inst2part_Mod
 And Pn.Objid = Ml.Part_Info2part_Num
 and bo.objid = pn.part_num2bus_org;
 Rec_Part_Inst_C Part_Inst_C%Rowtype;

 --get Site part record
 CURSOR site_part_c(
 p_esn VARCHAR2
 )
 IS
 SELECT *
 FROM sa.table_site_part
 WHERE part_status = 'Active'
 AND x_service_id = p_esn;
 rec_site_part_c site_part_c%ROWTYPE;
 --End CR3229
 TYPE OBJID_TAB
 IS
 TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE TYPE_TAB
 IS
 TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;
 PromoObjid OBJID_TAB;
 PromoType TYPE_TAB;
 PromoIDX NUMBER := 0;
 v_unitsLeft NUMBER := 0;
 v_factor NUMBER := 0;
 strErr VARCHAR2(200);
 --start CR3229
 sp_objid VARCHAR2(20);
 carrierobjid VARCHAR2(20);
 dealerobjid VARCHAR2(20);
 sp_min VARCHAR2(20);
 cnt NUMBER := 0;
 strCTobjid NUMBER := 0;
 v_ChgReason VARCHAR2(20) ;
--CR3972
--End CR3229
BEGIN

v_ChgReason := nvl(ip_chgReason,'Repl:Exch/DefPhone') ;

dbms_output.put_line('SA.Sp_Issue_Compunits-start');
 --CR4478 NEG 09/01/2005 - Remove previouly granted units to avoid duplicates
 delete sa.table_x_pending_redemption
 where x_case_id = ip_idnumber
 and pend_redemption2esn = ip_esnObjid;
 commit;
 --END CR4478

 op_return := 'TRUE';
 v_unitsLeft := ip_units;
 /*IF MOD(ip_units, 10) = 0
 THEN cr36262*/
 FOR c1_rec IN c_getComp
 LOOP
 v_factor := FLOOR( v_unitsLeft / c1_rec.x_units); -- CR5728
 IF v_factor < 0
 THEN
 NULL;
 ELSE
 FOR i IN 1..v_factor
 LOOP
 PromoObjid(PromoIDX) := c1_rec.objid;
 PromoType(PromoIDX) := c1_rec.x_revenue_type;
 PromoIDX := PromoIDX + 1;
 v_unitsLeft := v_unitsLeft - c1_rec.x_units;
            END LOOP;
         END IF;
      END LOOP;
      --start CR3229  Insert record into call trans for reporting
      --check for site part record and if not present insert a new record and then create call trans record
      --get part Inst record
      OPEN part_inst_c(ip_esnObjid);
      FETCH part_inst_c
      INTO rec_part_inst_c;
      CLOSE part_inst_c;
      --get part Inst record
      OPEN site_part_c(rec_part_inst_c.part_serial_no);
      FETCH site_part_c
      INTO rec_site_part_c;
      IF site_part_c%NOTFOUND
      THEN
         INSERT
         INTO sa.table_site_part(
            objid,
            instance_name,
            serial_no,
            s_serial_no,
            install_date,
            part_status,
            service_end_dt,
            x_service_id,
            site_part2part_info
         ) VALUES(
            sa.Seq('site_part'),
            'Wireless',
            rec_part_inst_c.part_serial_no,
            rec_part_inst_c.part_serial_no,
            SYSDATE,
            'Obsolete',
            TO_DATE('01/01/1753', 'mm/dd/yyyy'),
            rec_part_inst_c.part_serial_no,
            rec_part_inst_c.n_part_inst2part_mod
         );
      END IF;
      COMMIT;
      sp_objid := rec_site_part_c.objid;
      sp_min := rec_site_part_c.x_min;
      CLOSE site_part_c;
      -- Sitepart record
      IF rec_site_part_c.x_service_id
      IS
      NULL
      THEN

         SELECT objid
         INTO sp_objid
         FROM sa.table_site_part
         WHERE x_service_id = rec_part_inst_c.part_serial_no
         AND ROWNUM < 2
         ORDER BY install_date DESC ;

      END IF;
      UPDATE sa.table_part_inst SET x_part_inst2site_part = sp_objid
      WHERE part_serial_no = rec_part_inst_c.part_serial_no;
      -- To get Carrier Info
      SELECT COUNT(*)
      INTO cnt
      FROM sa.table_x_carrier b, sa.table_part_inst a
      WHERE a.part_inst2carrier_mkt = b.objid
      AND a.part_serial_no = rec_part_inst_c.part_serial_no;
      IF cnt > 0
      THEN
         SELECT b.objid
         INTO carrierobjid
         FROM sa.table_x_carrier b, sa.table_part_inst a
         WHERE a.part_inst2carrier_mkt = b.objid
         AND a.part_serial_no = rec_part_inst_c.part_serial_no;
         cnt := 0;

      END IF;
      -- To get Dealer Info
      SELECT COUNT(*)
      INTO cnt
      FROM sa.table_site g, sa.table_inv_role h, sa.table_inv_locatn e, sa.table_inv_bin d,
      sa.table_part_inst f
      WHERE g.objid = e.inv_locatn2site
      AND e.objid = h.inv_role2inv_locatn
      AND e.objid = d.inv_bin2inv_locatn
      AND d.objid = f.part_inst2inv_bin
      AND f.part_serial_no = rec_part_inst_c.part_serial_no;
      IF cnt > 0
      THEN
         SELECT g.objid
         INTO dealerobjid
         FROM sa.table_site g, sa.table_inv_role h, sa.table_inv_locatn e, sa.table_inv_bin
         d, sa.table_part_inst f
         WHERE g.objid = e.inv_locatn2site
         AND e.objid = h.inv_role2inv_locatn
         AND e.objid = d.inv_bin2inv_locatn
         AND d.objid = f.part_inst2inv_bin
         AND f.part_serial_no = rec_part_inst_c.part_serial_no;
      END IF;
      -- insert into call Trans
      INSERT
      INTO sa.table_x_call_trans(
         objid,
         call_trans2site_part,
         x_action_type,
         x_call_trans2carrier,
         x_call_trans2dealer,
         x_call_trans2user,
         x_min,
         x_service_id,
         x_sourcesystem,
         x_transact_date,
         x_total_units,
         x_action_text,
         x_reason,
         X_Result,
         x_sub_sourcesystem

      ) 		 VALUES(
         sa.Seq('x_call_trans'),
         sp_objid,
         '8',
         carrierobjid,
         dealerobjid,
         '268435556',
         sp_min,
         rec_part_inst_c.part_serial_no,
         'WEBCSR',
         SYSDATE,
         ip_units,
         'CUST SERVICE',
          V_Chgreason,
         'Completed',
         rec_part_inst_c.org_id
      );
      -- end CR3229
      -- To get the call trans Objid of the esn  Start CR3972
      -- CR15761
      SELECT objid
      INTO strCTobjid
      FROM sa.table_x_call_trans
      WHERE x_reason = v_chgReason
      and x_service_id = rec_part_inst_c.part_serial_no
      and x_transact_date in (select max(x_transact_date) from sa.table_x_call_trans
                              where x_service_id = rec_part_inst_c.part_serial_no
                              and x_reason = v_chgreason)
      and rownum < 2;

      --END CR3972 CR15761
      FOR k IN 0..PromoObjid.COUNT - 1
      LOOP
         INSERT
         INTO sa.table_x_pending_redemption(
            objid,
            pend_red2x_promotion,
            pend_redemption2esn,
            x_pend_type,
            x_case_id,
            x_granted_from2x_call_trans --- CR3972
         ) VALUES(
            sa.Seq('x_pending_redemption'),
            PromoObjid(k),
            ip_esnObjid,
            PromoType(k),
            ip_idnumber,
            strCTobjid --CR3972
         );
      END LOOP;
      COMMIT;
 --  END IF; for cr36262
   dbms_output.put_line('Sp_Issue_Compunits-end');
   EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
      strErr := SUBSTR(SQLERRM, 1, 200);
      op_return := 'FALSE';
      op_returnMsg := strErr;
END;
/