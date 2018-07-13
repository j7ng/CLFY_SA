CREATE OR REPLACE FUNCTION sa."SP_LOAD_PART_HIST_FUN" (c_ip_domain     IN  VARCHAR2,
                                                    c_ip_ser_no     IN  VARCHAR2,
                                                    c_ip_status     IN  VARCHAR2,
                                                    c_ip_code_objid IN  NUMBER,
                                                    c_ip_bin_objid  IN  NUMBER,
                                                    c_ip_part       IN  NUMBER,
                                                    c_ip_load_type  IN  VARCHAR2,
                                                    c_op_out_msg    OUT VARCHAR2,
                                                    c_op_out_err    OUT VARCHAR2)
RETURN BOOLEAN AS

/********************************************************************************/
/* Copyright ) 2001 Tracfone Wireless Inc. All rights reserved                  */
/*                                                                              */
/* Name         :   sp_load_part_hist_fun.sql                                   */
/* Purpose      :   To invalidate ('44') or revalidate ('42' or '45') the       */
/*                  unredeemed cards and load into pi_hist table                */
/* Parameters   :   NONE                                                        */
/* Platforms    :   Oracle 8.0.6 AND newer versions                             */
/* Author		:   Vanisri Adapa                                               */
/* Date         :   11/26/01                                                    */
/* Revisions	:   Version  Date      Who       Purpose                        */
/*                  -------  --------  -------   ------------------------------ */
/*                  1.0      11/26/01  VAdapa    Initial revision               */
/*                  1.1      11/28/01  VAdapa    Added a new parameter C_IP_PART*/
/*                                               to update the part number info */
/*                                               for the given SMP              */
/*                  1.2      04/01/03  SL       Clarify Upgrade-sequence        */
/*                  1.3      06/16/03  SL       Bug fix ora164                  */
/********************************************************************************/


    CURSOR c_part_exists IS
        SELECT *
        FROM TABLE_PART_INST
        WHERE part_serial_no = c_ip_ser_no;

    r_part_exists   c_part_exists%ROWTYPE;

    v_action        VARCHAR2(4000);
    v_err_text      VARCHAR2(4000);
    v_change_reason VARCHAR2(80);
    v_seq           NUMBER ; -- 06/16/03

BEGIN

    IF c_ip_load_type = 'INVALIDATE' THEN
        v_change_reason := 'DESTROYED';
    ELSIF c_ip_load_type = 'REVALIDATE' THEN
        v_change_reason := 'INVENTORY ADJUSTMENT';
    END IF;

    OPEN c_parT_exists;
    FETCH c_part_exists INTO r_part_exists;

    v_action := 'Cycle Cnt : Update Part_Inst';

--Do not update the status if the card is REDEEMED

    UPDATE  table_part_inst
    SET     x_part_inst_status  = c_ip_status,
            status2x_code_table = c_ip_code_objid,
            part_inst2inv_bin   = c_ip_bin_objid,
            n_part_inst2part_mod = c_ip_part
    WHERE   objid               = r_parT_exists.objid
    AND     x_part_inst_status  <> '41';

    IF SQL%ROWCOUNT = 1 THEN

    v_action := 'Cycle Cnt : Insert Pi_Hist';
    sp_seq('x_pi_hist',v_seq); --06/16/03
            INSERT INTO table_x_pi_hist(
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
                    -- 04/01/03 SEQ_X_PI_HIST.NEXTVAL + power(2,28),
                    -- 06/16/03 seq('x_pi_hist'),
                    v_seq,
                    c_ip_code_objid,
                    sysdate,
                    v_change_reason,
                    r_part_exists.x_cool_end_date,
                    r_part_exists.x_creation_date,
                    r_part_exists.x_deactivation_flag,
                    r_part_exists.x_domain,
                    r_part_exists.x_ext,
                    r_part_exists.x_insert_date,
                    r_part_exists.x_npa,
                    r_part_exists.x_nxx,
                    null,
                    null,
                    null,
                    r_part_exists.part_bin,
                    c_ip_status,
                    r_part_exists.part_mod,
                    r_part_exists.part_serial_no,
                    r_part_exists.part_status,
                    r_part_exists.part_inst2carrier_mkt,
                    c_ip_bin_objid,
                    r_part_exists.objid,
                    c_ip_part,
                    r_part_exists.created_by2user,
                    r_part_exists.part_inst2x_new_pers,
                    r_part_exists.part_inst2x_pers,
                    r_part_exists.x_po_num,
                    r_part_exists.x_reactivation_flag,
                    r_part_exists.x_red_code,
                    r_part_exists.x_sequence,
                    r_part_exists.warr_end_date,
                    r_part_exists.dev,
                    r_part_exists.fulfill2demand_dtl,
                    r_part_exists.part_to_esn2part_inst,
                    r_part_exists.bad_res_qty,
                    r_part_exists.date_in_serv,
                    r_part_exists.good_res_qty,
                    r_part_exists.last_cycle_ct,
                    r_part_exists.last_mod_time,
                    r_part_exists.last_pi_date,
                    r_part_exists.last_trans_time,
                    r_part_exists.next_cycle_ct,
                    r_part_exists.x_order_number,
                    r_part_exists.part_bad_qty,
                    r_part_exists.part_good_qty,
                    r_part_exists.pi_tag_no,
                    r_part_exists.pick_request,
                    r_part_exists.repair_date,
                    r_part_exists.transaction_id);

                END IF; --end of sql%rowcount check

    CLOSE c_part_exists;

    RETURN TRUE;

EXCEPTION

    WHEN others THEN
        c_op_out_msg := v_action;
        c_op_out_err := 'Cycle Count Err : '||sqlerrm;
        RETURN FALSE;

END SP_LOAD_PART_HIST_FUN;
/