CREATE OR REPLACE PROCEDURE sa."SP_VOID_CARD_WAGNER"
/************************************************************************/
/* Name   		: sp_void_card_wagner                               	        */
/* Author		: Gerald Pintado				                        */
/* Modified by Cosmin Ioan on 6/6/07 to void wagner cards*/
/* Date	 		: 01/25/2000					                        */
/* Input Paramaters 	: ip_card, ip_reason                            */
/************************************************************************/
 (
 IP_CARD   IN VARCHAR2, -- Input Param card number
 IP_REASON IN VARCHAR2, -- Reason for voiding
 OP_MSG    OUT VARCHAR2
 )
IS
CURSOR C1 IS
 SELECT * FROM TABLE_PART_INST
  WHERE PART_SERIAL_NO = IP_CARD
   AND X_DOMAIN = 'REDEMPTION CARDS'
   AND X_PART_INST_STATUS ='280';  --

CURSOR c_user_objid IS
 SELECT objid
  FROM table_user
   WHERE S_login_name = 'TOSSUTILITY';

v_user_objid    NUMBER;
r_user_objid    c_user_objid%ROWTYPE;
REC_CARD    C1%ROWTYPE;
BEGIN

open c_user_objid;
fetch c_user_objid into r_user_objid;
if c_user_objid%found then
    close c_user_objid;
    v_user_objid := r_user_objid.objid;
else
    close c_user_objid;
    v_user_objid := null;
end if;

  OPEN C1;
  FETCH C1 INTO REC_CARD;
  IF C1%NOTFOUND THEN
     OP_MSG := 'No Record Found or Card is Redeemed';
  ELSIF C1%FOUND THEN
     UPDATE TABLE_PART_INST SET
       X_PART_INST_STATUS = '281',
       STATUS2X_CODE_TABLE = (select objid from table_x_code_table where x_code_name='WAGNER EXPIRED')
     WHERE OBJID = REC_CARD.OBJID;
 --Write to pi_hist table
     INSERT INTO table_x_pi_hist ( OBJID,
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
                                   SEQ('x_pi_hist'),
                                   REC_CARD.status2x_code_table,
                                   sysdate,
                                   IP_REASON,
                                   REC_CARD.x_cool_end_date,
                                   REC_CARD.x_creation_date,
                                   REC_CARD.x_deactivation_flag,
                                   REC_CARD.x_domain,
                                   REC_CARD.x_ext,
                                   REC_CARD.x_insert_date,
                                   REC_CARD.x_npa,
                                   REC_CARD.x_nxx,
                                   null,
                                   null,
                                   null,
                                   REC_CARD.part_bin,
                                        '281',
                                   REC_CARD.part_mod,
                                   REC_CARD.part_serial_no,
                                   REC_CARD.part_status,
                                   REC_CARD.part_inst2carrier_mkt,
                                   REC_CARD.part_inst2inv_bin,
                                   REC_CARD.objid,
                                   REC_CARD.n_part_inst2part_mod,
                                   DECODE(v_user_objid,NULL,REC_CARD.created_by2user,v_user_objid),
                                   REC_CARD.part_inst2x_new_pers,
                                   REC_CARD.part_inst2x_pers,
                                   REC_CARD.x_po_num,
                                   REC_CARD.x_reactivation_flag,
                                   REC_CARD.x_red_code,
                                   REC_CARD.x_sequence,
                                   REC_CARD.warr_end_date,
                                   REC_CARD.dev,
                                   REC_CARD.fulfill2demand_dtl,
                                   REC_CARD.part_to_esn2part_inst,
                                   REC_CARD.bad_res_qty,
                                   REC_CARD.date_in_serv,
                                   REC_CARD.good_res_qty,
                                   REC_CARD.last_cycle_ct,
                                   REC_CARD.last_mod_time,
                                   REC_CARD.last_pi_date,
                                   REC_CARD.last_trans_time,
                                   REC_CARD.next_cycle_ct,
                                   REC_CARD.x_order_number,
                                   REC_CARD.part_bad_qty,
                                   REC_CARD.part_good_qty,
                                   REC_CARD.pi_tag_no,
                                   REC_CARD.pick_request,
                                   REC_CARD.repair_date,
                                   REC_CARD.transaction_id);
   COMMIT;
   OP_MSG := 'Void Completed';
   END IF;
CLOSE C1;
END sp_void_card_wagner;
/