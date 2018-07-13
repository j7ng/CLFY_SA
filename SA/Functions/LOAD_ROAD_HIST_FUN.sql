CREATE OR REPLACE FUNCTION sa.LOAD_ROAD_HIST_FUN(c_ip_domain     IN  VARCHAR2,
                                                   c_ip_ser_no     IN  VARCHAR2,
                                                   c_ip_status     IN  VARCHAR2,
                                                   c_ip_code_objid IN  NUMBER,
                                                   c_ip_bin_objid  IN  NUMBER,
                                                   c_ip_part       IN  NUMBER,
                                                   c_ip_load_type  IN  VARCHAR2,
                                                   c_op_out_msg    OUT VARCHAR2,
                                                   c_op_out_err    OUT VARCHAR2)
RETURN BOOLEAN AS

/******************************************************************************/
/* Copyright (R) 2002 Tracfone Wireless Inc. All rights reserved              */
/*                                                                            */
/* Name         :   load_road_hist_fun.sql                                    */
/* Purpose      :   To invalidate ('44') or revalidate ('42' or '45') the     */
/*                  unredeemed cards and load into pi_hist table              */
/* Parameters   :   NONE                                                      */
/* Platforms    :   Oracle 8.0.6 AND newer versions                           */
/* Author		:   Miguel Leon                                               */
/* Date         :   11/26/01                                                  */
/* Revisions	:   Version  Date      Who       Purpose                      */
/*                  -------  --------  -------   ---------------------------- */
/*                  1.0      11/26/01  Mleon    Initial revision              */
/*                  1.1      04/01/03  SL       Clarify Upgrade-sequence      */
/*                  1.2      08/12/03  MNAZIR   Get Sequence from proc        */
/******************************************************************************/


    CURSOR c_part_exists IS
        SELECT *
        FROM TABLE_X_ROAD_INST
        WHERE part_serial_no = c_ip_ser_no;

    r_part_exists   c_part_exists%ROWTYPE;

    v_action        VARCHAR2(4000);
    v_err_text      VARCHAR2(4000);
    v_change_reason VARCHAR2(80);
	v_seq           NUMBER ; -- 08/12/03 MNAZIR

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

    UPDATE  table_x_road_inst
    SET     x_part_inst_status  = c_ip_status,
            rd_status2x_code_table = c_ip_code_objid,
            road_inst2inv_bin   = c_ip_bin_objid,
            n_road_inst2part_mod = c_ip_part,
			x_hist_update  = 1 --meaning do not fire the trigger
    WHERE   objid               = r_parT_exists.objid
    AND     x_part_inst_status  <> '41';

    IF SQL%ROWCOUNT = 1 THEN

    v_action := 'Cycle Cnt : Insert road_hist';
	sp_seq('x_pi_hist',v_seq); -- 08/12/03 MNAZIR
            INSERT INTO table_x_road_hist(
                    OBJID,
                    ROAD_HIST2X_CODE_TABLE,
                    X_CHANGE_DATE,
                    X_CHANGE_REASON,
                    X_CREATION_DATE,
                    X_DOMAIN,
                    X_INSERT_DATE,
                    X_PART_BIN,
                    X_PART_INST_STATUS,
                    X_PART_MOD,
                    X_PART_SERIAL_NO,
                    X_PART_STATUS,
                    X_ROAD_HIST2INV_BIN,
                    X_ROAD_HIST2ROAD_INST,
                    X_ROAD_HIST2PART_MOD,
                    X_ROAD_HIST2USER,
                    X_PO_NUM,
                    X_WARR_END_DATE,
--                     X_LAST_TRANS_TIME,
                    X_ORDER_NUMBER,
--                     X_PICK_REQUEST,
                    X_REPAIR_DATE,
                    X_TRANSACTION_ID)
            VALUES (
                    -- 04/01/03 SEQ_X_PI_HIST.NEXTVAL + power(2,28),
                    -- seq('x_pi_hist'),
			v_seq, -- 08/12/03 MNAZIR
                    c_ip_code_objid,
                    sysdate,
                    v_change_reason,
                    r_part_exists.x_creation_date,
                    r_part_exists.x_domain,
                    r_part_exists.x_insert_date,
                    r_part_exists.part_bin,
                    c_ip_status,
                    r_part_exists.part_mod,
                    r_part_exists.part_serial_no,
                    r_part_exists.part_status,
                    c_ip_bin_objid,
                    r_part_exists.objid,
                    c_ip_part,
                    r_part_exists.rd_create2user,
                    r_part_exists.x_po_num,
                    r_part_exists.warr_end_date,
--                     r_part_exists.last_trans_time,NOT In table_x_road_inst
                    r_part_exists.x_order_number,
--                     r_part_exists.pick_request, NOT in table_x_road_inst
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

END LOAD_ROAD_HIST_FUN;
/