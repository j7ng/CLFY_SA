CREATE OR REPLACE PACKAGE BODY sa."SP_CHECK_EXCHANGES" AS
/******************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         SP_CHECK_EXCHANGES (BODY)                                    */
/* PURPOSE:                                                                   */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/*                                                                            */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO          PURPOSE                                  */
/* -------  ---------- -----  ---------------------------------------------   */
/*  1.0                       Initial  Revision                               */
/*                                                                            */
/*  1.2     07/05/2002  SL    Add X_SUB_SOURCESYSTEM field for call trans     */
/*                            insert statement                                */
/*  1.3     04/10/03    SL    Clarify Upgrade - sequence                      */
/*  1.4     10/20/2005  GP    CR4579 Added carrierRules by technology         */
/*  1.5     05/15/2007  AB    CR6254 Added length for MEID numbers            */
/******************************************************************************/
PROCEDURE deactivate_service
 (ip_objid IN NUMBER,
  ip_reason IN NUMBER,
  ip_deactdate IN DATE,
  ip_esn IN VARCHAR2,
  ip_min IN VARCHAR2,
  ip_result IN OUT BOOLEAN) IS
 e_areacodechange   EXCEPTION;
 v_phone_status TABLE_PART_INST.x_part_inst_status%TYPE;
 v_min_new_status TABLE_PART_INST.x_part_inst_status%TYPE;
 v_first_act TABLE_SITE_PART.install_date%TYPE;
 v_min_ac_change TABLE_PART_INST.part_serial_no%TYPE;
 v_min_ac_change_new_status TABLE_PART_INST.x_part_inst_status%TYPE;
 v_reactivation_flag TABLE_PART_INST.x_reactivation_flag%TYPE;
 v_min_pers TABLE_PART_INST.part_inst2x_pers%TYPE;
 v_deact_reason TABLE_SITE_PART.x_deact_reason%TYPE;
 v_cooling_period DATE;
 v_status_objid NUMBER;
 v_act_diff NUMBER;
 v_ac_change NUMBER;  --0 false, 1 true
 v_notify_carrier NUMBER; --set to 1 if we are going to return the line
 v_ac_change_min_objid NUMBER; --objid of the ac reserved min
 v_min_objid NUMBER;
 CURSOR cur_ph IS
   SELECT c.x_technology,a.*  --CR4579 Added technology field
     FROM TABLE_PART_INST a, table_mod_level b, table_part_num c
    WHERE a.x_part_inst_status = '52'
      AND a.part_serial_no     = ip_esn
      AND a.x_domain           = 'PHONES'
      and a.n_part_inst2part_mod = b.objid
      and b.part_info2part_num = c.objid;

 CURSOR cur_min (v_cur_min IN VARCHAR2) IS
  SELECT * FROM TABLE_PART_INST
  WHERE part_serial_no  = v_cur_min
    AND x_domain        = 'LINES';


 CURSOR cur_info(c_tech in varchar2) IS
  SELECT cr.x_line_return_days, cr.x_cooling_period,
         pi.x_insert_date, pi.x_part_inst_status,
         pi.part_inst2x_new_pers,pi.part_inst2x_pers
  FROM   TABLE_X_CARRIER_RULES cr,
         TABLE_X_CARRIER ca,
         TABLE_PART_INST pi
  WHERE  cr.objid = DECODE(c_tech,'GSM',ca.carrier2rules_GSM,  -- CR4579 Added CarrierRule by technology
                                  'TDMA',ca.carrier2rules_TDMA,
                                  'CDMA',ca.carrier2rules_CDMA,
                                   ca.carrier2rules)
    AND  ca.objid           = pi.part_inst2carrier_mkt
    AND  x_domain           = 'LINES'
    AND  pi.part_serial_no  = ip_min;


 CURSOR cur_new_ac_min (ph_objid IN NUMBER) IS
   SELECT part_serial_no
     FROM TABLE_PART_INST
     WHERE x_part_inst_status = '38'
       AND part_to_esn2part_inst = ph_objid;
 rec_info cur_info%ROWTYPE;
 rec_ph   cur_ph%ROWTYPE;
 rec_min  cur_min%ROWTYPE;
BEGIN
--  dbms_output.put_line('got here 1');
  ip_result := FALSE;
  OPEN cur_ph;
  FETCH cur_ph INTO rec_ph;
  CLOSE cur_ph;

  OPEN cur_info(rec_ph.x_technology); --CR4579 Added technology parameter
  FETCH cur_info INTO rec_info;
  CLOSE cur_info;

  --Update min part_inst
  --Find out if we should return the line to the carrier or reuse it
  --Clear out the personality change if there was one pending
 -- dbms_output.put_line('line deactivated ' || ip_min);
  IF rec_info.part_inst2x_new_pers IS NULL THEN
--   dbms_output.put_line('x_new_pers = null ' || to_char(rec_info.part_inst2x_new_pers) );
   v_min_pers := rec_info.part_inst2x_pers;
  ELSE
--   dbms_output.put_line('x_new_pers <> null ' || to_char(rec_info.part_inst2x_new_pers) );
   v_min_pers := rec_info.part_inst2x_new_pers;
  END IF;
  --Get the first activation date after the last insert
  SELECT MIN(install_date)
  INTO v_first_act
  FROM TABLE_SITE_PART
  WHERE x_min        = ip_min
    AND part_status   <> 'Obsolete'
    AND install_date > rec_info.x_insert_date;
--  dbms_output.put_line('got here 2');
  --Check date calculation to see if we have to return the line
  SELECT SYSDATE - v_first_act
  INTO   v_act_diff
  FROM   dual;
  -- set ac change flag
  IF rec_info.x_part_inst_status = 34 THEN
   v_ac_change := 1;
  ELSE
   v_ac_change := 0;
  END IF;
  v_notify_carrier := 0;
  --Set the cooling period
  IF (rec_info.x_cooling_period = 0) OR (rec_info.x_cooling_period IS NULL) THEN
   v_cooling_period := TO_DATE('01-JAN-1753','dd-mon-yyyy');
  ELSE
   v_cooling_period := (rec_info.x_cooling_period + SYSDATE);
  END IF;
--  dbms_output.put_line('got here 3');
 --Check to see if we should reuse the line or not
 --IF x_line_return_days = 0 then always reuse
 --IF x_line_return_days = 1 then always return
 --Else do date test
  IF ((rec_info.x_line_return_days <> 1) AND (v_act_diff < rec_info.x_line_return_days)) OR
      (rec_info.x_line_return_days = 0) THEN
   IF v_ac_change = 1 THEN
      v_min_new_status := '35';
   ELSE
      v_min_new_status := '12';    --used
   END IF;
  ELSE
   v_min_new_status := '17';    --returned
   v_notify_carrier := 1;
  END IF;
  --determine if the line had a pending ac change
    IF v_ac_change = 1 THEN
--cwl2.put_line('adam','got here 1' || to_char(rec_ph.objid));
    OPEN cur_new_ac_min(rec_ph.objid);
    FETCH cur_new_ac_min INTO v_min_ac_change;
    IF cur_new_ac_min%notfound THEN
     CLOSE cur_new_ac_min;
     RAISE e_areacodechange;
    END IF;
    CLOSE cur_new_ac_min;
     IF (v_min_new_status = '35') THEN
--cwl2.put_line('adam','got here 2');
     SELECT objid
     INTO v_status_objid
     FROM TABLE_X_CODE_TABLE
     WHERE x_code_number = '12';
--cwl2.put_line('adam','got here 3');
     UPDATE TABLE_PART_INST
     SET x_part_inst_status      = '12',
         part_to_esn2part_inst   = NULL,
         x_cool_end_date         = v_cooling_period,
         last_trans_time         = SYSDATE, -- added by JR 1/12/01
         status2x_code_table     = v_status_objid
     WHERE x_part_inst_status    = '38'
       AND part_to_esn2part_inst = rec_ph.objid;
     v_min_ac_change_new_status := 12;
     ELSIF (v_ac_change = 1) AND (v_min_new_status = '17') THEN
--cwl2.put_line('adam','got here 4');
     SELECT objid
     INTO v_status_objid
     FROM TABLE_X_CODE_TABLE
     WHERE x_code_number = '36';
--cwl2.put_line('adam','got here 5');
     SELECT objid
     INTO v_ac_change_min_objid
     FROM TABLE_PART_INST
     WHERE x_part_inst_status = '38'
       AND part_to_esn2part_inst = rec_ph.objid
       AND x_domain = 'LINES';
     UPDATE TABLE_PART_INST
     SET x_part_inst_status   = '36',
          status2x_code_table = v_status_objid,
          last_trans_time         = SYSDATE -- added by JR 1/12/01
     WHERE x_part_inst_status = '38'
       AND part_to_esn2part_inst = rec_ph.objid;
     --Close out the account history record for this line that was created
     UPDATE TABLE_X_ACCOUNT_HIST
     SET x_end_date = SYSDATE
     WHERE account_hist2part_inst = v_ac_change_min_objid;
     v_min_ac_change_new_status := 36;
     END IF;
     OPEN cur_min(v_min_ac_change);
     FETCH cur_min INTO rec_min;
     CLOSE cur_min;
--cwl2.put_line('adam','got here 6');
     INSERT INTO TABLE_X_PI_HIST (	OBJID,
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
					X_TRANSACTION_ID)
				VALUES (
					-- 04/10/03 SEQ_X_PI_HIST.NEXTVAL + power(2,28),
					Seq('x_pi_hist'),
					rec_min.status2x_code_table,
					SYSDATE,
					'DEACTIVATE',
					rec_min.x_cool_end_date,
					rec_min.x_creation_date,
					rec_min.x_deactivation_flag,
					rec_min.x_domain,
					rec_min.x_ext,
					rec_min.x_insert_date,
					rec_min.x_npa,
					rec_min.x_nxx,
					SUBSTR(ip_min,7,4),
					SUBSTR(ip_min,1,3),
					SUBSTR(ip_min,4,3),
					rec_min.part_bin,
                                        v_min_ac_change_new_status,
					rec_min.part_mod,
					rec_min.part_serial_no,
					rec_min.part_status,
					rec_min.part_inst2carrier_mkt,
					rec_min.part_inst2inv_bin,
					rec_min.objid,
					rec_min.n_part_inst2part_mod,
					rec_min.created_by2user,
					rec_min.part_inst2x_new_pers,
					rec_min.part_inst2x_pers,
					rec_min.x_po_num,
					rec_min.x_reactivation_flag,
					rec_min.x_red_code,
					rec_min.x_sequence,
					rec_min.warr_end_date,
					rec_min.dev,
					rec_min.fulfill2demand_dtl,
					rec_min.part_to_esn2part_inst,
					rec_min.bad_res_qty,
					rec_min.date_in_serv,
					rec_min.good_res_qty,
					rec_min.last_cycle_ct,
					rec_min.last_mod_time,
					rec_min.last_pi_date,
					rec_min.last_trans_time,
					rec_min.next_cycle_ct,
					rec_min.x_order_number,
					rec_min.part_bad_qty,
					rec_min.part_good_qty,
					rec_min.pi_tag_no,
					rec_min.pick_request,
					rec_min.repair_date,
					rec_min.transaction_id);
  END IF;
  --update the account history table with an end since we will return the line
  IF v_min_new_status = '17' THEN    --returned
   SELECT objid INTO v_min_objid
   FROM TABLE_PART_INST
   WHERE part_serial_no = ip_min
     AND x_domain       = 'LINES';
   UPDATE TABLE_X_ACCOUNT_HIST
   SET x_end_date = SYSDATE
   WHERE account_hist2part_inst = v_min_objid;
  END IF;
--cwl2.put_line('adam','got here 7');
  SELECT objid
  INTO v_status_objid
  FROM TABLE_X_CODE_TABLE
  WHERE x_code_number = v_min_new_status;
--cwl2.put_line('adam','got here 8');
  UPDATE TABLE_PART_INST
  SET  x_part_inst_status       = v_min_new_status,
       status2x_code_table      = v_status_objid,
       x_cool_end_date          = v_cooling_period,
       last_trans_time         = SYSDATE, -- added by JR 1/12/01
       part_inst2x_pers         = v_min_pers
  WHERE part_serial_no          = ip_min
    AND x_domain = 'LINES';
--cwl2.put_line('adam','got here 9');
  OPEN cur_min(ip_min);
  FETCH cur_min INTO rec_min;
  CLOSE cur_min;
  INSERT INTO TABLE_X_PI_HIST (		OBJID,
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
					X_TRANSACTION_ID)
				VALUES (
					-- 04/10/03 SEQ_X_PI_HIST.NEXTVAL + power(2,28),
					Seq('x_pi_hist'),
					rec_min.status2x_code_table,
					SYSDATE,
					'DEACTIVATE',
					rec_min.x_cool_end_date,
					rec_min.x_creation_date,
					rec_min.x_deactivation_flag,
					rec_min.x_domain,
					rec_min.x_ext,
					rec_min.x_insert_date,
					rec_min.x_npa,
					rec_min.x_nxx,
					NULL,
					NULL,
					NULL,
					rec_min.part_bin,
					v_min_new_status,
					rec_min.part_mod,
					rec_min.part_serial_no,
					rec_min.part_status,
					rec_min.part_inst2carrier_mkt,
					rec_min.part_inst2inv_bin,
					rec_min.objid,
					rec_min.n_part_inst2part_mod,
					rec_min.created_by2user,
					rec_min.part_inst2x_new_pers,
					rec_min.part_inst2x_pers,
					rec_min.x_po_num,
					rec_min.x_reactivation_flag,
					rec_min.x_red_code,
					rec_min.x_sequence,
					rec_min.warr_end_date,
					rec_min.dev,
					rec_min.fulfill2demand_dtl,
					rec_min.part_to_esn2part_inst,
					rec_min.bad_res_qty,
					rec_min.date_in_serv,
					rec_min.good_res_qty,
					rec_min.last_cycle_ct,
					rec_min.last_mod_time,
					rec_min.last_pi_date,
					rec_min.last_trans_time,
					rec_min.next_cycle_ct,
					rec_min.x_order_number,
					rec_min.part_bad_qty,
					rec_min.part_good_qty,
					rec_min.pi_tag_no,
					rec_min.pick_request,
					rec_min.repair_date,
					rec_min.transaction_id);
  --update the site part
  SELECT x_code_name
  INTO v_deact_reason
  FROM TABLE_X_CODE_TABLE
  WHERE x_code_number = ip_reason;
--cwl2.put_line('adam','objid of table_site_part:'||to_char(ip_objid));
  UPDATE TABLE_SITE_PART
  SET service_end_dt       = ip_deactdate,
      x_deact_reason       = v_deact_reason,
      x_notify_carrier     = v_notify_carrier,
      part_status          = 'Inactive',
      site_part2x_new_plan = NULL
  WHERE objid = ip_objid;
  --Set the end date for the Click Plan
  UPDATE TABLE_X_CLICK_PLAN_HIST
  SET x_end_date = SYSDATE
  WHERE curr_hist2site_part = ip_objid
    AND (x_end_date IS NULL
         OR TRUNC(x_end_date) = TRUNC(TO_DATE('01-JAN-1753','dd-mon-yyyy')) );
  --update esn part_inst
  --find the new status for the phone
    IF ip_reason = 21 THEN
     v_phone_status := '53';
    ELSIF ip_reason = 22 THEN
     v_phone_status := '54';
    ELSIF ip_reason = 31 THEN
     v_phone_status := '55';
    ELSIF ip_reason = 32 THEN
     v_phone_status := '56';
    ELSIF ip_reason = 63 THEN
     v_phone_status := '58';
    ELSE
     v_phone_status := '51';
    END IF;
  -- if x_value from the x_code_table for the status = 2 (no redemption required for react) then set x_reactivation_flag = 1
  SELECT x_value
  INTO v_reactivation_flag
  FROM TABLE_X_CODE_TABLE
  WHERE x_code_number = ip_reason;
  IF v_reactivation_flag = 2 THEN
   v_reactivation_flag := 1;
  ELSE
   v_reactivation_flag := 0;
  END IF;
  SELECT objid
  INTO v_status_objid
  FROM TABLE_X_CODE_TABLE
  WHERE x_code_number = v_phone_status;
  UPDATE TABLE_PART_INST
  SET x_part_inst_status   = v_phone_status,
      status2x_code_table = v_status_objid,
      last_trans_time         = SYSDATE, -- added by JR 1/12/01
      x_reactivation_flag  = v_reactivation_flag
  WHERE x_part_inst_status = '52' --Phone is active
    AND part_serial_no =ip_esn
    AND x_domain = 'PHONES';
  --write to pi_hist table
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
					X_TRANSACTION_ID)
				VALUES (
					-- 04/10/03 SEQ_X_PI_HIST.NEXTVAL + power(2,28),
					Seq('x_pi_hist'),
					rec_ph.status2x_code_table,
					SYSDATE,
					'DEACTIVATE',
					rec_ph.x_cool_end_date,
					rec_ph.x_creation_date,
					rec_ph.x_deactivation_flag,
					rec_ph.x_domain,
					rec_ph.x_ext,
					rec_ph.x_insert_date,
					rec_ph.x_npa,
					rec_ph.x_nxx,
					NULL,
					NULL,
					NULL,
					rec_ph.part_bin,
					v_phone_status,
					rec_ph.part_mod,
					rec_ph.part_serial_no,
					rec_ph.part_status,
					rec_ph.part_inst2carrier_mkt,
					rec_ph.part_inst2inv_bin,
					rec_ph.objid,
					rec_ph.n_part_inst2part_mod,
					rec_ph.created_by2user,
					rec_ph.part_inst2x_new_pers,
					rec_ph.part_inst2x_pers,
					rec_ph.x_po_num,
					rec_ph.x_reactivation_flag,
					rec_ph.x_red_code,
					rec_ph.x_sequence,
					rec_ph.warr_end_date,
					rec_ph.dev,
					rec_ph.fulfill2demand_dtl,
					rec_ph.part_to_esn2part_inst,
					rec_ph.bad_res_qty,
					rec_ph.date_in_serv,
					rec_ph.good_res_qty,
					rec_ph.last_cycle_ct,
					rec_ph.last_mod_time,
					rec_ph.last_pi_date,
					rec_ph.last_trans_time,
					rec_ph.next_cycle_ct,
					rec_ph.x_order_number,
					rec_ph.part_bad_qty,
					rec_ph.part_good_qty,
					rec_ph.pi_tag_no,
					rec_ph.pick_request,
					rec_ph.repair_date,
					rec_ph.transaction_id);
EXCEPTION
 WHEN e_areacodechange THEN
   INSERT INTO PAST_DUE_ERROR
    VALUES (ip_esn, ip_min,SYSDATE, 'No New number found for area code change');
   ip_result := TRUE;
   COMMIT;
 END deactivate_service;
PROCEDURE create_call_trans
  (ip_site_part IN NUMBER,
   ip_action IN NUMBER,
   ip_carrier IN NUMBER,
   ip_dealer IN NUMBER,
   ip_user  IN NUMBER,
   ip_min  IN VARCHAR2,
   ip_phone IN VARCHAR2,
   ip_source IN VARCHAR2,
   ip_transdate IN DATE,
   ip_units IN NUMBER,
   ip_action_text IN VARCHAR2,
   ip_reason IN VARCHAR2,
   ip_result IN VARCHAR2) IS
   v_objid TABLE_X_CALL_TRANS.objid%TYPE;
   CURSOR call_trans_seq IS
    -- 04/10/03 select Seq_x_call_trans.nextval+POWER(2,28) val
      SELECT Seq('x_call_trans') val
      FROM dual;
   call_trans_seq_rec call_trans_seq%ROWTYPE;
BEGIN
   -- Get objid for the call trans
   OPEN call_trans_seq;
     FETCH call_trans_seq INTO call_trans_seq_rec;
   CLOSE call_trans_seq;
   INSERT INTO TABLE_X_CALL_TRANS (objid,
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
                                   x_result,
                                   x_sub_sourcesystem -- 07/05/2002
                                   )
                            VALUES (call_trans_seq_rec.val,
                                   ip_site_part,
                                   ip_action,
                                   ip_carrier,
                                   ip_dealer,
                                   ip_user,
                                   ip_min,
                                   ip_phone,
                                   ip_source,
                                   ip_transdate,
                                   ip_units,
                                   ip_action_text,
                                   ip_reason,
                                   ip_result,
--                                   'DBMS' -- 07/05/2002
                                    '202' --insert the code number for x_sub_sourcesystem
                                   );
END create_call_trans;
--added as part of real time activation project DSH
PROCEDURE write_to_monitor
   (site_part_objid IN NUMBER,
    cust_site_objid IN NUMBER,
    x_carrier_id IN NUMBER)
 IS
  --retrieve the deactivated site part
  CURSOR c1 IS
    SELECT *
      FROM TABLE_SITE_PART
     WHERE objid = site_part_objid;
  c1_rec c1%ROWTYPE;
  --retrieve the customer_id for the site part
  CURSOR c2 IS
    SELECT site_id
      FROM TABLE_SITE
      WHERE objid = cust_site_objid AND
            ROWNUM = 1;
  c2_rec c2%ROWTYPE;
  --retrieve the dealer_id for the site part
  CURSOR c3(sp_esn IN VARCHAR2) IS
    SELECT s.site_id site_id
      FROM TABLE_SITE s,
           TABLE_INV_ROLE ir,
           TABLE_INV_LOCATN il,
           TABLE_INV_BIN ib,
           TABLE_PART_INST pi
      WHERE s.objid = ir.inv_role2site AND
           ir.inv_role2inv_locatn = il.objid AND
           il.objid = ib.inv_bin2inv_locatn AND
           ib.objid = pi.part_inst2inv_bin AND
           pi.x_domain = 'PHONES' AND
           pi.part_serial_no = sp_esn AND
           ROWNUM = 1;
  c3_rec c3%ROWTYPE;
  CURSOR c4 (ml_objid IN NUMBER) IS
    SELECT pn.x_manufacturer x_manufacturer
      FROM TABLE_PART_NUM pn,
           TABLE_MOD_LEVEL ml
     WHERE pn.objid = ml.part_info2part_num
       AND ml.objid = ml_objid;
  c4_rec c4%ROWTYPE;
  CURSOR c5(site_objid IN NUMBER) IS
    SELECT c.last_name||', '||c.first_name name, c.x_cust_id
      FROM TABLE_CONTACT      c,
           TABLE_CONTACT_ROLE cr
     WHERE c.objid  = cr.contact_role2contact
       AND cr.contact_role2site = site_objid
       AND ROWNUM = 1;
  c5_rec c5%ROWTYPE;
BEGIN
     OPEN c1;
      FETCH c1 INTO c1_rec;
     CLOSE c1;
     OPEN c2;
      FETCH c2 INTO c2_rec;
     CLOSE c2;
     OPEN c3(c1_rec.serial_no);
      FETCH c3 INTO c3_rec;
     CLOSE c3;
     OPEN c4(c1_rec.site_part2part_info);
      FETCH c4 INTO c4_rec;
     CLOSE c4;
     OPEN c5(c1_rec.site_part2site);
      FETCH c5 INTO c5_rec;
     CLOSE c5;
--cwl2.put_line('adam','site_part_objid:'||to_char(site_part_objid));
     INSERT INTO X_MONITOR
        (X_MONITOR_ID,
         X_DATE_MVT,
         X_PHONE,
         X_ESN,
         X_CUST_ID,
         X_CARRIER_ID,
         X_DEALER_ID,
         X_ACTION,
         X_REASON_CODE,
         X_LINE_WORKED,
         X_LINE_WORKED_BY,
         X_LINE_WORKED_DATE,
         X_ISLOCKED,
         X_LOCKED_BY,
         X_ACTION_TYPE_ID,
         X_IG_STATUS,
         X_IG_ERROR,
         X_PIN,
         X_MANUFACTURER,
         X_INITIAL_ACT_DATE,
         X_END_USER)
       VALUES
       ((seq_x_monitor_id.NEXTVAL + (POWER(2,28))),
         SYSDATE,
         c1_rec.x_min,
         c1_rec.serial_no,
         c3_rec.site_id,
         TO_CHAR(x_carrier_id),
         c3_rec.site_id,
         DECODE(c1_rec.x_notify_carrier,1,'D',0,'S'),
         c1_rec.x_deact_reason,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         DECODE(c1_rec.x_notify_carrier,1,0,0,1),
         NULL,
         NULL,
         c1_rec.x_pin,
         c4_rec.x_manufacturer,
         c1_rec.install_date,
         c5_rec.name);
END write_to_monitor;
PROCEDURE deactivate_overdue_exchange
 IS
  v_user TABLE_USER.objid%TYPE;
  v_service_return_code NUMBER(1);
  v_trans_return_code NUMBER(1);
  v_errorflag BOOLEAN;
  v_exchange_days TABLE_X_CODE_TABLE.x_value%TYPE;
  v_curr_status TABLE_PART_INST.x_part_inst_status%TYPE;
  CURSOR alt_esn (exchange_days IN NUMBER) IS
    SELECT *
      FROM TABLE_X_ALT_ESN
     WHERE ((SYSDATE - x_date) > exchange_days)
       AND x_type = 'EXCHANGE'
       AND x_status = 'PENDING';
  CURSOR sp_curs(esn IN VARCHAR2) IS
    SELECT sp.objid                    site_part_objid,
           sp.x_service_id             x_service_id,
           sp.x_min                    x_min,
           ca.objid                    carrier_objid,
           ir.inv_role2site            site_objid,
           sp.serial_no                x_esn,
           ca.x_carrier_id             x_carrier_id,
           sp.site_objid               cust_site_objid
     FROM
           TABLE_X_CARRIER  ca,
           TABLE_PART_INST  pi2,
           TABLE_INV_ROLE   ir,
           TABLE_INV_BIN    ib,
           TABLE_PART_INST  pi,
           TABLE_SITE_PART  sp
     WHERE ca.objid                 = pi2.part_inst2carrier_mkt
       AND INITCAP(pi2.x_domain)    = 'Lines'
       AND pi2.part_serial_no       = sp.x_min
       AND ir.inv_role2inv_locatn   = ib.inv_bin2inv_locatn
       AND ib.objid                 = pi.part_inst2inv_bin
       AND pi.x_part_inst2site_part = sp.objid
       AND (sp.part_status)         = 'Active'
       AND sp.x_service_id          = esn;
     sp_curs_rec sp_curs%ROWTYPE;
  CURSOR ph_curs(esn IN VARCHAR2) IS
    SELECT *
      FROM TABLE_PART_INST
     WHERE part_serial_no = esn;
   rec_ph ph_curs%ROWTYPE;
BEGIN
  dbms_transaction.use_rollback_segment('R07_BIG');
    SELECT objid INTO v_user
     FROM TABLE_USER
     WHERE login_name = 'sa';
    SELECT x_value INTO v_exchange_days
      FROM TABLE_X_CODE_TABLE
     WHERE x_code_name = 'EXCHANGE DAYS';
    FOR alt_esn_rec IN alt_esn(v_exchange_days) LOOP
     --Look for the status of the line

      IF (LENGTH(RTRIM(LTRIM(alt_esn_rec.x_replacement_esn))) = 11
-- CR6254 start  Addint MEID numbers to be allowed
        or  LENGTH(TRIM(alt_esn_rec.x_replacement_esn)) = 18)
-- CR6254 end

      THEN
       SELECT x_part_inst_status INTO v_curr_status
        FROM TABLE_PART_INST
       WHERE part_serial_no = alt_esn_rec.x_replacement_esn;
       --Look for active service.
       IF v_curr_status = '52' THEN
            OPEN sp_curs(alt_esn_rec.x_replacement_esn);
             FETCH sp_curs INTO sp_curs_rec;
              IF sp_curs%Found THEN
                   deactivate_service (sp_curs_rec.site_part_objid,63,SYSDATE,sp_curs_rec.x_service_id,sp_curs_rec.x_min,v_errorflag);
                     create_call_trans  (sp_curs_rec.site_part_objid,2,sp_curs_rec.carrier_objid,sp_curs_rec.site_objid,
                                      v_user,sp_curs_rec.x_min,sp_curs_rec.x_service_id,'OVERDUE_EXCHANGE_BATCH',SYSDATE,
                                      NULL,	NULL, 'OVERDUE EXCHANGE','Completed');
                     write_to_monitor (sp_curs_rec.site_part_objid,
                                       sp_curs_rec.cust_site_objid,
                                       sp_curs_rec.x_carrier_id);
              END IF;
            CLOSE sp_curs;
            COMMIT;
       ELSE
            OPEN ph_curs(alt_esn_rec.x_replacement_esn);
             FETCH ph_curs INTO rec_ph;
              IF ph_curs%Found THEN
                UPDATE TABLE_PART_INST
                   SET x_part_inst_status = '58',
                       status2x_code_table = (SELECT objid
                                                FROM TABLE_X_CODE_TABLE
                                               WHERE x_code_number = '58'
                                              )
                 WHERE objid = rec_ph.objid;
                 COMMIT;
              END IF;
             CLOSE ph_curs;
            OPEN ph_curs(alt_esn_rec.x_replacement_esn);
             FETCH ph_curs INTO rec_ph;
              IF ph_curs%Found THEN
                 --write to pi_hist table
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
			            		             X_TRANSACTION_ID)
			            	VALUES (
			            		             -- 04/10/03 SEQ_X_PI_HIST.NEXTVAL + power(2,28),
			            		             Seq('x_pi_hist'),
			            		             rec_ph.status2x_code_table,
			            		             SYSDATE,
			            		             'OVERDUE EXCHANGE',
			            		             rec_ph.x_cool_end_date,
			            		             rec_ph.x_creation_date,
			            		             rec_ph.x_deactivation_flag,
			            		             rec_ph.x_domain,
			            		             rec_ph.x_ext,
			            		             rec_ph.x_insert_date,
			            		             rec_ph.x_npa,
			            		             rec_ph.x_nxx,
			            		             NULL,
			            		             NULL,
			            		             NULL,
			            		             rec_ph.part_bin,
			            		             '58',
			            		             rec_ph.part_mod,
			            		             rec_ph.part_serial_no,
			            		             rec_ph.part_status,
			            		             rec_ph.part_inst2carrier_mkt,
			            		             rec_ph.part_inst2inv_bin,
			            		             rec_ph.objid,
			            		             rec_ph.n_part_inst2part_mod,
			            		             rec_ph.created_by2user,
			            		             rec_ph.part_inst2x_new_pers,
			            		             rec_ph.part_inst2x_pers,
			            		             rec_ph.x_po_num,
			            		             rec_ph.x_reactivation_flag,
			            		             rec_ph.x_red_code,
			            		             rec_ph.x_sequence,
			            		             rec_ph.warr_end_date,
			            		             rec_ph.dev,
			            		             rec_ph.fulfill2demand_dtl,
			            		             rec_ph.part_to_esn2part_inst,
			            		             rec_ph.bad_res_qty,
			            		             rec_ph.date_in_serv,
			            		             rec_ph.good_res_qty,
			            		             rec_ph.last_cycle_ct,
			            		             rec_ph.last_mod_time,
			            		             rec_ph.last_pi_date,
			            		             rec_ph.last_trans_time,
			            		             rec_ph.next_cycle_ct,
			            		             rec_ph.x_order_number,
			            		             rec_ph.part_bad_qty,
			            		             rec_ph.part_good_qty,
			            		             rec_ph.pi_tag_no,
			            		             rec_ph.pick_request,
			            		             rec_ph.repair_date,
			            		             rec_ph.transaction_id);
                            COMMIT;
             END IF;
             CLOSE ph_curs;
      END IF;
     END IF;
    END LOOP;
END deactivate_overdue_exchange;
END Sp_check_exchanges;
/