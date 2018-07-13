CREATE OR REPLACE PACKAGE BODY sa."DUMMY_LINE_INSERT_PKG" AS
/************************************************************/
 PROCEDURE DUMMY_LINE (ip_account IN VARCHAR2,
 ip_carrier_id IN NUMBER,
 ip_user IN VARCHAR2,
 ip_esn IN VARCHAR2,
 ip_zip in varchar2,
 op_min OUT VARCHAR2,
 op_result OUT NUMBER,
 op_msg OUT VARCHAR2)
IS
/********************************************************************************/
/* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved */
/* */
/* Name : SA.dummy_line_insert_pkg */
/* Purpose : Insert a dummy line for no inventory carriers */
/* Parameters : */
/* Platforms : Oracle 8.0.6 AND newer versions */
/* Author : Natalio Guada */
/* Date : 07/27/2004 */
/* Revisions : */
/* */
/* Version Date Who Purpose */
/* ------- -------- ------- -------------------------------------- */
/* 1.0	 07/27/2004 Natalio		New package created to insert dummy lines     */
/*  1.1     10/12/2005  Gerald 		CR4579 - Added CarrierRules by Technology     */
/*  1.2     08/13/2007  nguada 		CR6453 - Update ESN Pers Relations      */
/********************************************************************************/
/********************************************************************************/
   /* NEW PVCS STRUCTURE /NEW_PLSQL/CODE
   /* 1.0   09/05/08        VAdapa    Prod Version as of 09/05/08
   /* 1.1   09/05/08        VAdapa    CDMA NA
   /* 1.2   09/10/08        CLindner  Latest fix (commented the insert to account_hist)
   /* 1.3   04/24/09        CLindner  CR8663 WALMART Includes new Verizon carrier
   /* 1.4   04/27/09        ICanavan  CR8663 added /
/********************************************************************************/
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: DUMMY_LINE_INSERT_PKG.sql,v $
  --$Revision: 1.3 $
  --$Author: sraman $
  --$Date: 2016/10/28 16:42:46 $
  --$ $Log: DUMMY_LINE_INSERT_PKG.sql,v $
  --$ Revision 1.3  2016/10/28 16:42:46  sraman
  --$ CR46073 :- Modified DUMMY_LINE procedure to assign the correct Tmin Area code for Verizon carriers
  --$
  --$ Revision 1.2  2012/08/21 13:27:57  kacosta
  --$ CR21643 Verizon NET10- T-Number
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
v_step VARCHAR2(100);
e_dummy_exceptions  EXCEPTION;
v_carrier_objid    NUMBER;
v_pers_objid       NUMBER;
v_line_objid       NUMBER;
v_account_objid    NUMBER;
v_code_objid       NUMBER;
v_mod_objid        NUMBER;
v_expire_days      NUMBER;
v_cooling_days     NUMBER;
v_user_objid       NUMBER;
v_exception_id     NUMBER;
v_expire_date      DATE;
v_cooling_end_date DATE;
v_code_name        VARCHAR2(25);
v_code_number      VARCHAR2(20);
v_status_id        VARCHAR2(20);
v_description      VARCHAR2(100);
v_npa              VARCHAR2(3);
v_nxx              VARCHAR2(3);
v_ext              VARCHAR2(20);
v_esn_objid        number;
v_min_objid        number;
v_tech             VARCHAR2(10);
--
cursor verizon_curs is
  select * from x_verizon_zip_npanxx
   where zip = ip_zip
     and template = 'RSS';
verizon_rec verizon_curs%rowtype;
--
CURSOR c_carrier_check(c_tech in varchar2) IS
 SELECT
   b.objid,
   b.carrier2personality,
   b.x_mkt_submkt_name,
   c.x_line_expire_days,
   c.x_cooling_after_insert,
   p.x_parent_name
  FROM
   table_x_parent p,
   table_x_carrier_group cg,
   table_x_carrier b,
   table_x_carrier_rules c
  --CR4579 Commented Out: WHERE  b.carrier2rules = c.objid
  WHERE 1=1
   and p.objid = cg.X_CARRIER_GROUP2X_PARENT
   and cg.objid = b.CARRIER2CARRIER_GROUP
   and DECODE(c_tech,'GSM',b.carrier2rules_GSM,
                       'TDMA',b.carrier2rules_TDMA,
                       'CDMA',b.carrier2rules_CDMA,
                              b.carrier2rules) = c.objid
   and b.x_carrier_id = ip_carrier_id;
--
CURSOR c_user_objid IS
 SELECT objid
  FROM table_user
 WHERE login_name = ip_user;
--
CURSOR c_get_mod_level is
 SELECT objid
  FROM table_mod_level
   WHERE part_info2part_num in (SELECT objid
                                FROM table_part_num
                                WHERE part_number = 'Lines');
--
CURSOR c_verizon_account_check(c_account in varchar2) IS
 SELECT *
  FROM table_x_account
  where 1=1
    AND x_acct_num = c_ACCOUNT
    AND x_status = 'Active';
--
CURSOR c_account_check(c_account in varchar2) IS
 SELECT *
  FROM table_x_account
   WHERE account2x_carrier = v_carrier_objid
    AND x_acct_num = c_ACCOUNT
    AND x_status = 'Active';
--
CURSOR c_status_objid (c_status_id in varchar2) IS
 SELECT OBJID,X_CODE_NUMBER
  FROM table_x_code_table
   WHERE X_CODE_NUMBER = c_status_id;
--
CURSOR c_esn_objid (c_esn in varchar2) IS
SELECT a.OBJID,c.x_technology
  FROM table_part_inst a, table_mod_level b, table_part_num c
   WHERE a.part_serial_no = c_esn
   and a.n_part_inst2part_mod = b.objid
   and b.part_info2part_num = c.objid;
--
r_carrier_check c_carrier_check%ROWTYPE;
r_account_check c_account_check%ROWTYPE;
r_status_objid  c_status_objid%ROWTYPE;
r_user_objid    c_user_objid%ROWTYPE;
r_esn_objid    c_esn_objid%ROWTYPE;
--
BEGIN
  op_result := 1;
  op_msg    := op_min ||': successfully completed';
  v_status_id := '37';
--
  select sa.seq('part_inst') into v_min_objid from dual;
--
  op_min := 'T' || v_min_objid;
  v_npa := SUBSTR(op_min,1,3);
  v_nxx := SUBSTR(op_min,4,3);
  v_ext := SUBSTR(op_min,7,4);
  v_tech := '';
------------------------------------------------------------------
v_step := 'Get ESN objid';
------------------------------------------------------------------
  OPEN c_esn_objid (ip_esn);
    FETCH c_esn_objid INTO r_esn_objid;
    v_esn_objid  := r_esn_objid.objid;
    v_tech       := r_esn_objid.x_technology;
  CLOSE c_esn_objid;
-----------------------------------------------------------------------------
v_step := 'Getting carrier, personality, expiration, cooling, and mod info';
-----------------------------------------------------------------------------
  OPEN c_carrier_check(v_tech);
    FETCH c_carrier_check INTO r_carrier_check;
dbms_output.put_line('r_carrier_check.x_parent_name :'||r_carrier_check.x_parent_name );
dbms_output.put_line('r_esn_objid.x_technology :'||r_esn_objid.x_technology );
    IF c_carrier_check%FOUND THEN
dbms_output.put_line('c_carrier_check%FOUND');
      CLOSE c_carrier_check;
      --CR21643 Start kacosta 08/21/2012
      --if r_carrier_check.x_parent_name in ('VERIZON PREPAY PLATFORM', 'VERIZON WIRELESS')

/*    CR46073 - Replace below If with get_short_parent_name function call
      IF r_carrier_check.x_parent_name IN ('VERIZON PREPAY PLATFORM'
                                          ,'VERIZON WIRELESS'
                                          ,'VERIZON WIRELESS_NET10') */
      IF sa.util_pkg.get_short_parent_name(I_PARENT_NAME => r_carrier_check.x_parent_name) = 'VZW'
      --CR21643 End kacosta 08/21/2012
          and r_esn_objid.x_technology = 'CDMA' then
        open verizon_curs;
          fetch verizon_curs into verizon_rec;
dbms_output.put_line('VERIZON WIRELESS');
          op_min := 'T' ||verizon_rec.npanxx||v_min_objid;
          v_npa := verizon_rec.npa;
          v_nxx := verizon_rec.nxx;
          v_ext := v_min_objid;
        close verizon_curs;
      end if;
dbms_output.put_line('zero');
      v_carrier_objid := r_carrier_check.objid;
      v_pers_objid    := r_carrier_check.carrier2personality;
      v_expire_days   := r_carrier_check.x_line_expire_days;
      v_cooling_days  := r_carrier_check.x_cooling_after_insert;
dbms_output.put_line('one');
      FOR r_get_mod_level IN c_get_mod_level LOOP
        v_mod_objid := r_get_mod_level.objid;
      END LOOP;
dbms_output.put_line('two');
      SELECT DECODE(v_expire_days,NULL,
                                   TO_DATE('01/01/1753','MM/DD/YYYY'),0,
                                   TO_DATE('01/01/1753','MM/DD/YYYY'),
                                   SYSDATE + v_expire_days) INTO v_expire_date
                                   FROM DUAL;
dbms_output.put_line('three');
      SELECT DECODE(v_cooling_days,NULL,
                                   TO_DATE('01/01/1753','MM/DD/YYYY'),0,
                                   TO_DATE('01/01/1753','MM/DD/YYYY'),
                                   SYSDATE + v_cooling_days * 1/86400) INTO v_cooling_end_date
                                   FROM DUAL;
dbms_output.put_line('four');
dbms_output.put_line('v_mod_objid:'||v_mod_objid);
dbms_output.put_line('v_pers_objid:'||v_pers_objid);
      IF v_mod_objid IS NULL THEN
        v_exception_id := 103;
        RAISE e_dummy_exceptions;
      END IF;
      IF v_pers_objid IS NULL THEN
        v_exception_id := 104;
        RAISE e_dummy_exceptions;
      END IF;
    ELSE
      CLOSE c_carrier_check;
      v_exception_id := 105;
      RAISE e_dummy_exceptions;
    END IF;
-----------------------------------
v_step := 'Getting account objid';
-----------------------------------
/* as per rick ramon this is no longer needed
  if r_carrier_check.x_parent_name = 'VERIZON WIRELESS' and r_esn_objid.x_technology = 'CDMA' then
    OPEN c_verizon_account_check(verizon_rec.account_num);
      FETCH c_verizon_account_check INTO r_account_check;
      dbms_output.put_line('verizon_rec.account_num:'||verizon_rec.account_num);
      IF c_verizon_account_check%FOUND THEN
        v_account_objid := r_account_check.objid;
      else
        close c_verizon_account_check;
        v_exception_id := 107;
        RAISE e_dummy_exceptions;
      end if;
    close c_verizon_account_check;
  else
    OPEN c_account_check(ip_account);
      FETCH c_account_check INTO r_account_check;
      IF c_account_check%FOUND THEN
        CLOSE c_account_check;
        dbms_output.put_line('r_account_check.x_status:'|| r_account_check.x_status );
        v_account_objid := r_account_check.objid;
      ELSE
        CLOSE c_account_check;
        v_exception_id := 107;
        RAISE e_dummy_exceptions;
      END IF;
    CLOSE c_account_check;
  end if;
*/
--------------------------------------------
v_step := 'Getting (LINE_BATCH) user info';
--------------------------------------------
  OPEN c_user_objid;
    FETCH c_user_objid INTO r_user_objid;
    IF c_user_objid%FOUND THEN
      CLOSE c_user_objid;
      v_user_objid := r_user_objid.objid;
    ELSE
      CLOSE c_user_objid;
      v_exception_id := 109;
      RAISE e_dummy_exceptions;
    END IF;
----------------------------------------
v_step := 'Getting status info';
----------------------------------------
  OPEN c_status_objid (v_status_id);
    FETCH c_status_objid INTO r_status_objid;
    v_code_number := r_status_objid.x_code_number;
    v_code_objid  := r_status_objid.objid;
  CLOSE c_status_objid;
------------------------------------------------------------------
v_step := 'Checking min status to determine an update or insert';
------------------------------------------------------------------
  IF NOT INSERT_LINE_REC (v_min_objid,
                         op_min,
                         v_npa,
                         v_nxx,
                         v_ext,
                         '',
                         v_expire_date,
                         v_cooling_end_date,
                         v_code_number,
                         v_mod_objid,
                         v_pers_objid,
                         v_carrier_objid,
                         v_code_objid,
                         v_user_objid,
                         v_esn_objid) THEN
         v_exception_id := 112;
    RAISE e_dummy_exceptions;
  END IF;
-------------------------------------------------------
v_step := 'Inserting account hist and pi_hist record';
-------------------------------------------------------
  IF v_line_objid IS NULL THEN
    SELECT objid INTO v_line_objid
      FROM table_part_inst
     WHERE x_domain = 'LINES'
       AND part_serial_no = op_min;
  END IF;
/*
  IF NOT INSERT_ACCOUNT_HIST (v_line_objid, v_account_objid) THEN
    v_exception_id := 113;
    RAISE e_dummy_exceptions;
  end if;
*/
  IF NOT WRITE_TO_PI_HIST (v_line_objid,'LINE_BATCH') THEN
    v_exception_id := 114;
    RAISE e_dummy_exceptions;
  END IF;
---------
EXCEPTION
  WHEN e_dummy_exceptions THEN
    op_result := v_exception_id;
    SELECT description INTO v_description
      FROM x_luts_exceptions
     WHERE exception_id = v_exception_id;
    IF v_exception_id in (110,117) THEN
      op_msg := op_min || ', ' || ip_account || ', : ' || v_description || ' ' || v_code_name;
    ELSE
      op_msg := op_min || ', ' || ip_account || ', : ' || v_description;
    END IF;
  WHEN OTHERS THEN
    ROLLBACK;
    op_result := 0;
    op_MSG :=  op_min || ', ' || ip_account || ', : Error occured while ' || v_step;
END DUMMY_LINE;
/*****************************************************************************************/
/********************************************************************************************/
FUNCTION INSERT_LINE_REC(ip_objid IN VARCHAR2,
                         ip_min IN VARCHAR2,
                         ip_npa IN VARCHAR2,
                         ip_nxx IN VARCHAR2,
                         ip_ext IN VARCHAR2,
                         ip_file_name    IN VARCHAR2,
                         ip_expire_date  IN DATE,
                         ip_cooling_end_date IN DATE,
                         ip_code_number   IN VARCHAR2,
                         ip_mod_objid     IN NUMBER,
                         ip_pers_objid    IN NUMBER,
                         ip_carrier_objid IN NUMBER,
                         ip_code_objid    IN NUMBER,
                         ip_user_objid    IN NUMBER,
                         ip_esn_objid     IN NUMBER) RETURN BOOLEAN
IS
Begin
 INSERT INTO table_part_inst (
         objid,
         part_good_qty,
         part_bad_qty,
         part_serial_no,
         last_pi_date,
         last_cycle_ct,
         next_cycle_ct,
         last_mod_time,
         last_trans_time,
         date_in_serv,
         warr_end_date,
         repair_date,
         part_status,
         good_res_qty,
         bad_res_qty,
         x_insert_date,
         x_sequence,
         x_creation_date,
         x_domain,
         x_deactivation_flag,
         x_reactivation_flag,
         x_cool_end_date,
         x_part_inst_status,
         x_npa,
         x_nxx,
         x_ext,
         x_order_number,
         n_part_inst2part_mod,
         part_inst2x_pers,
         part_inst2carrier_mkt,
         created_by2user,
         status2x_code_table,
         part_to_esn2part_inst,
         hdr_ind,
         x_msid)
       VALUES (
         ip_objid,
         1,
         0,
         ip_min,
         TO_DATE('01/01/1753','MM/DD/YYYY'),
         TO_DATE('01/01/1753','MM/DD/YYYY'),
         TO_DATE('01/01/1753','MM/DD/YYYY'),
         TO_DATE('01/01/1753','MM/DD/YYYY'),
         TO_DATE('01/01/1753','MM/DD/YYYY'),
         TO_DATE('01/01/1753','MM/DD/YYYY'),
         ip_expire_date,
         TO_DATE('01/01/1753','MM/DD/YYYY'),
         'Active',
         0,
         0,
         SYSDATE,
         0,
         SYSDATE,
         'LINES',
         0,
         0,
         ip_cooling_end_date,
         ip_code_number,
         ip_npa,
         ip_nxx,
         ip_ext,
         ip_file_name,
         ip_mod_objid,
         ip_pers_objid,
         ip_carrier_objid,
         ip_user_objid,
         ip_code_objid,
         ip_esn_objid,
         0,
         ip_min);

         update table_part_inst
         set part_inst2x_pers = ip_pers_objid
         where objid = ip_esn_objid;

  IF SQL%RowCount = 1 THEN
    COMMIT;
    RETURN TRUE;
  ELSE
    ROLLBACK;
    RETURN FALSE;
  END IF;

EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  RETURN FALSE;
END INSERT_LINE_REC;

/*************************************************************************************/

FUNCTION INSERT_ACCOUNT_HIST (ip_line_objid IN NUMBER,
                              ip_account_objid IN NUMBER) RETURN BOOLEAN
IS

BEGIN

   INSERT INTO table_x_account_hist
    values(sa.seq('x_account_hist'),
           ip_line_objid,
           ip_account_objid,
           null,
           TO_DATE('01/01/1753','MM/DD/YYYY'),
           SYSDATE);
   IF SQL%RowCount = 1 THEN
      COMMIT;
      RETURN TRUE;
   ELSE
      ROLLBACK;
      RETURN FALSE;
   END IF;
EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  RETURN FALSE;
END INSERT_ACCOUNT_HIST;
/*************************************************************************************/
FUNCTION WRITE_TO_PI_HIST  (ip_line_objid IN NUMBER,
                            ip_reason     IN VARCHAR2) RETURN BOOLEAN
IS
 CURSOR c_part_inst IS
  SELECT *
   FROM table_part_inst
    WHERE objid = ip_line_objid;
r_part_inst  c_part_inst%ROWTYPE;

BEGIN
 OPEN c_part_inst;
 FETCH c_part_inst INTO r_part_inst;
 IF c_part_inst%FOUND THEN
  CLOSE c_part_inst;
  INSERT INTO TABLE_X_PI_HIST (
                    OBJID,
                    STATUS_HIST2X_CODE_TABLE,
                    X_CHANGE_DATE,
                    X_CHANGE_REASON,
                    X_COOL_END_DATE,
                    X_CREATION_DATE,
                    X_DEACTIVATION_FLAG,
                    X_DOMAIN,
                    X_EXT,
                    X_INSERT_DATE,
                    X_NPA,
                    X_NXX,
                    X_OLD_EXT,
                    X_OLD_NPA,
                    X_OLD_NXX,
                    X_PART_BIN,
                    X_PART_INST_STATUS,
                    X_PART_MOD,
                    X_PART_SERIAL_NO,
                    X_PART_STATUS,
                    X_PI_HIST2CARRIER_MKT,
                    X_PI_HIST2INV_BIN,
                    X_PI_HIST2PART_INST,
                    X_PI_HIST2PART_MOD,
                    X_PI_HIST2USER,
                    X_PI_HIST2X_NEW_PERS,
                    X_PI_HIST2X_PERS,
                    X_PO_NUM,
                    X_REACTIVATION_FLAG,
                    X_RED_CODE,
                    X_SEQUENCE,
                    X_WARR_END_DATE,
                    DEV,
                    FULFILL_HIST2DEMAND_DTL,
                    PART_TO_ESN_HIST2PART_INST,
                    X_BAD_RES_QTY,
                    X_DATE_IN_SERV,
                    X_GOOD_RES_QTY,
                    X_LAST_CYCLE_CT,
                    X_LAST_MOD_TIME,
                    X_LAST_PI_DATE,
                    X_LAST_TRANS_TIME,
                    X_NEXT_CYCLE_CT,
                    X_ORDER_NUMBER,
                    X_PART_BAD_QTY,
                    X_PART_GOOD_QTY,
                    X_PI_TAG_NO,
                    X_PICK_REQUEST,
                    X_REPAIR_DATE,
                    X_TRANSACTION_ID,
                    X_MSID)
                VALUES (
                    sa.seq('x_pi_hist'),
                    r_part_inst.status2x_code_table,
                    sysdate,
                    ip_reason,
                    r_part_inst.x_cool_end_date,
                    r_part_inst.x_creation_date,
                    r_part_inst.x_deactivation_flag,
                    r_part_inst.x_domain,
                    r_part_inst.x_ext,
                    r_part_inst.x_insert_date,
                    r_part_inst.x_npa,
                    r_part_inst.x_nxx,
                    NULL,
                    NULL,
                    NULL,
                    r_part_inst.part_bin,
                    r_part_inst.x_part_inst_status,
                    r_part_inst.part_mod,
                    r_part_inst.part_serial_no,
                    r_part_inst.part_status,
                    r_part_inst.part_inst2carrier_mkt,
                    r_part_inst.part_inst2inv_bin,
                    r_part_inst.objid,
                    r_part_inst.n_part_inst2part_mod,
                    r_part_inst.created_by2user,
                    r_part_inst.part_inst2x_new_pers,
                    r_part_inst.part_inst2x_pers,
                    r_part_inst.x_po_num,
                    r_part_inst.x_reactivation_flag,
                    r_part_inst.x_red_code,
                    r_part_inst.x_sequence,
                    r_part_inst.warr_end_date,
                    r_part_inst.dev,
                    r_part_inst.fulfill2demand_dtl,
                    r_part_inst.part_to_esn2part_inst,
                    r_part_inst.bad_res_qty,
                    r_part_inst.date_in_serv,
                    r_part_inst.good_res_qty,
                    r_part_inst.last_cycle_ct,
                    r_part_inst.last_mod_time,
                    r_part_inst.last_pi_date,
                    r_part_inst.last_trans_time,
                    r_part_inst.next_cycle_ct,
                    r_part_inst.x_order_number,
                    r_part_inst.part_bad_qty,
                    r_part_inst.part_good_qty,
                    r_part_inst.pi_tag_no,
                    r_part_inst.pick_request,
                    r_part_inst.repair_date,
                    r_part_inst.transaction_id,
                    r_part_inst.x_msid);
 ELSE
  CLOSE c_part_inst;
  ROLLBACK;
  RETURN FALSE;
 END IF;
  IF SQL%RowCount = 1 THEN
   COMMIT;
   RETURN TRUE;
  ELSE
   ROLLBACK;
   RETURN FALSE;
  END IF;
EXCEPTION
 WHEN OTHERS THEN
 ROLLBACK;
 RETURN FALSE;
END WRITE_TO_PI_HIST;

END DUMMY_LINE_INSERT_PKG;
/