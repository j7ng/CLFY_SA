CREATE OR REPLACE FORCE VIEW sa.table_sim_rtrp (objid,x_sim_serial_no,x_sim_inv_status,x_sim_mnc,x_inv_insert_date,x_last_ship_date,x_sim_po_number,x_sim_order_number,x_last_update_date,x_sim_inv2part_mod,x_created_by2user,x_sim_status2x_code_table,x_sim_inv2inv_bin,x_pin1,x_pin2,x_puk1,x_puk2,x_qty,x_sim_imsi,ig_imsi,expiration_date) AS
select "OBJID","X_SIM_SERIAL_NO","X_SIM_INV_STATUS","X_SIM_MNC","X_INV_INSERT_DATE","X_LAST_SHIP_DATE","X_SIM_PO_NUMBER","X_SIM_ORDER_NUMBER","X_LAST_UPDATE_DATE","X_SIM_INV2PART_MOD","X_CREATED_BY2USER","X_SIM_STATUS2X_CODE_TABLE","X_SIM_INV2INV_BIN","X_PIN1","X_PIN2","X_PUK1","X_PUK2","X_QTY","X_SIM_IMSI","IG_IMSI","EXPIRATION_DATE" from sa.table_x_sim_inv@read_rtrp
where X_SIM_INV_STATUS='253'
and length(x_sim_serial_no) = 19
AND x_sim_serial_no LIKE '890126%'
and X_CREATED_BY2USER<>0;