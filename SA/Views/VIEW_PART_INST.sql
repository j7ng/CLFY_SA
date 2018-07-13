CREATE OR REPLACE FORCE VIEW sa.view_part_inst (part_inst_objid,part_good_qty,part_bad_qty,part_serial_no,part_mod,part_bin,last_pi_date,pi_tag_no,last_cycle_ct,next_cycle_ct,last_mod_time,last_trans_time,transaction_id,date_in_serv,warr_end_date,repair_date,part_status,pick_request,good_res_qty,bad_res_qty,dev,x_insert_date,x_sequence,x_creation_date,x_po_num,x_red_code,x_domain,x_deactivation_flag,x_reactivation_flag,x_cool_end_date,x_part_inst_status,x_npa,x_nxx,x_ext,x_order_number,part_inst2inv_bin,n_part_inst2part_mod,fulfill2demand_dtl,part_inst2x_pers,part_inst2x_new_pers,part_inst2carrier_mkt,created_by2user,status2x_code_table,part_to_esn2part_inst,x_part_inst2site_part) AS
SELECT "OBJID" as PART_INST_OBJID, "PART_GOOD_QTY","PART_BAD_QTY","PART_SERIAL_NO","PART_MOD","PART_BIN","LAST_PI_DATE","PI_TAG_NO","LAST_CYCLE_CT","NEXT_CYCLE_CT","LAST_MOD_TIME","LAST_TRANS_TIME","TRANSACTION_ID","DATE_IN_SERV","WARR_END_DATE","REPAIR_DATE","PART_STATUS","PICK_REQUEST","GOOD_RES_QTY","BAD_RES_QTY","DEV","X_INSERT_DATE","X_SEQUENCE","X_CREATION_DATE","X_PO_NUM","X_RED_CODE","X_DOMAIN","X_DEACTIVATION_FLAG","X_REACTIVATION_FLAG","X_COOL_END_DATE","X_PART_INST_STATUS","X_NPA","X_NXX","X_EXT","X_ORDER_NUMBER","PART_INST2INV_BIN","N_PART_INST2PART_MOD","FULFILL2DEMAND_DTL","PART_INST2X_PERS","PART_INST2X_NEW_PERS","PART_INST2CARRIER_MKT","CREATED_BY2USER","STATUS2X_CODE_TABLE","PART_TO_ESN2PART_INST","X_PART_INST2SITE_PART"
FROM
       TABLE_PART_INST
;