CREATE OR REPLACE PROCEDURE sa."SP_ISSUE_COMPDAYS_DML"
/******************************************************************************/
/* Name      :   SP_ISSUE_COMPDAYS_DML
/* Type      :   Procedure
/* Purpose   :   To issue compensation days as pending redemptions
/* Author    :   Ingrid Canavan
/* Date      :   06/26/2009
/* Revisions :   Version  Date      Who         Purpose
/*               -------  --------  -------     -----------------------
/*               1.0-1.1  07/02/09  ICanavan    Initial revision
/*                                              Follow-up to the days being offered
/*               1.3                            fix mod problem when dividing
/******************************************************************************/
   ( ip_objid IN NUMBER,
     ip_days IN NUMBER,
     ip_idnumber IN VARCHAR2,
     op_return OUT VARCHAR2,
     op_returnMsg OUT VARCHAR2,
     ip_ChgReason IN VARCHAR2 DEFAULT NULL)
AS
   CURSOR c_getComp
   IS
   SELECT * FROM sa.table_x_promotion
   WHERE x_revenue_type = 'REPL' AND x_access_days > 0
   ORDER BY x_access_days DESC;

   CURSOR part_inst_c(p_objid NUMBER)
   IS
   SELECT *
   FROM sa.table_part_inst
   WHERE objid=p_objid;
   rec_part_inst_c part_inst_c%ROWTYPE;

   CURSOR site_part_c(p_esn VARCHAR2)
   IS
   SELECT *
   FROM sa.table_site_part
   WHERE part_status = 'Active' AND x_service_id = p_esn;
   rec_site_part_c site_part_c%ROWTYPE;

   TYPE OBJID_TAB
   IS
   TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE TYPE_TAB
   IS
   TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;

   PromoObjid OBJID_TAB;
   PromoType TYPE_TAB;
   PromoIDX NUMBER := 0;
   v_daysLeft NUMBER := 0;
   v_factor NUMBER := 0;
   strErr VARCHAR2(200);
   sp_objid VARCHAR2(20);
   carrierobjid VARCHAR2(20);
   dealerobjid VARCHAR2(20);
   sp_min VARCHAR2(20);
   cnt NUMBER := 0;
   strCTobjid NUMBER := 0;
   pi_objid NUMBER(20);
   v_ChgReason VARCHAR2(20);

BEGIN

   op_return := 'TRUE';
   v_daysLeft := ip_days;
   v_ChgReason := NVL(ip_ChgReason,'Repl:Exch/DefPhone') ;
-- needed to change this for days of 365
   IF MOD(ip_days, 5) = 0
   THEN
      FOR c1_rec IN c_getComp
      LOOP
         v_factor := FLOOR( v_daysLeft / c1_rec.x_access_days);
         IF v_factor < 0
         THEN
            NULL;
         ELSE
            FOR i IN 1..v_factor
            LOOP
               PromoObjid(PromoIDX) := c1_rec.objid;
               PromoType(PromoIDX) := c1_rec.x_revenue_type;
               PromoIDX := PromoIDX + 1;
               v_daysLeft := v_daysLeft - c1_rec.x_access_days;
            END LOOP;
         END IF;
      END LOOP;
      --get part Inst record
      OPEN part_inst_c(IP_OBJID);
      FETCH part_inst_c
      INTO rec_part_inst_c;
      CLOSE part_inst_c;

      pi_objid := rec_part_inst_c.objid;
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
      IF rec_site_part_c.x_service_id IS NULL
      THEN
         SELECT objid INTO sp_objid FROM sa.table_site_part
         WHERE x_service_id = rec_part_inst_c.part_serial_no
         AND ROWNUM < 2
         ORDER BY install_date DESC ;
      END IF;

      UPDATE sa.table_part_inst SET x_part_inst2site_part = sp_objid
      WHERE part_serial_no = rec_part_inst_c.part_serial_no;

      -- To get Carrier Info
      SELECT COUNT(*) INTO cnt
      FROM sa.table_x_carrier b, sa.table_part_inst a
      WHERE a.part_inst2carrier_mkt = b.objid
      AND a.part_serial_no = rec_part_inst_c.part_serial_no;
      IF cnt > 0
      THEN
         SELECT b.objid INTO carrierobjid
         FROM sa.table_x_carrier b, sa.table_part_inst a
         WHERE a.part_inst2carrier_mkt = b.objid
         AND a.part_serial_no = rec_part_inst_c.part_serial_no;
         cnt := 0;
      END IF;

      -- To get Dealer Info
      SELECT COUNT(*)  INTO cnt
      FROM sa.table_site g,
           sa.table_inv_role h,
           sa.table_inv_locatn e,
           sa.table_inv_bin d,
           sa.table_part_inst f
      WHERE g.objid = e.inv_locatn2site
      AND e.objid = h.inv_role2inv_locatn
      AND e.objid = d.inv_bin2inv_locatn
      AND d.objid = f.part_inst2inv_bin
      AND f.part_serial_no = rec_part_inst_c.part_serial_no;
      IF cnt > 0
      THEN
         SELECT g.objid INTO dealerobjid
         FROM sa.table_site g,
              sa.table_inv_role h,
              sa.table_inv_locatn e,
              sa.table_inv_bin d,
              sa.table_part_inst f
         WHERE g.objid = e.inv_locatn2site
         AND e.objid = h.inv_role2inv_locatn
         AND e.objid = d.inv_bin2inv_locatn
         AND d.objid = f.part_inst2inv_bin
         AND f.part_serial_no = rec_part_inst_c.part_serial_no;
      END IF;

      --To get the call trans Objid of the esn
      SELECT max(objid) INTO strCTobjid
      FROM sa.table_x_call_trans
      WHERE x_reason = v_ChgReason
      AND x_service_id = rec_part_inst_c.part_serial_no
      ORDER BY objid DESC;

      FOR k IN 0..PromoObjid.COUNT - 1
      LOOP
         INSERT
         INTO table_x_pending_redemption(
            objid,
            pend_red2x_promotion,
            pend_redemption2esn,
            x_pend_type,
            x_case_id,
            x_granted_from2x_call_trans
         ) VALUES(
            sa.Seq('x_pending_redemption'),
            PromoObjid(k),
            pi_objid,
            PromoType(k),
            ip_idnumber,
            strCTobjid
         );
      END LOOP;
      COMMIT;
   END IF;
   EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
      strErr := SUBSTR(SQLERRM, 1, 200);
      op_return := 'FALSE';
      op_returnMsg := strErr;
END;
/