CREATE OR REPLACE FORCE VIEW sa.table_x_sim_load_view (x_description,s_x_description,x_part_number,s_x_part_number,x_site_id,x_name,s_x_name,x_login_name,s_x_login_name,x_x_code_number,x_x_code_name,x_objid,x_x_sim_serial_no,x_x_sim_inv_status,x_x_sim_mnc,x_x_inv_insert_date,x_x_last_ship_date,x_x_sim_po_number,x_x_sim_order_number,x_x_last_update_date,x_x_qty,x_x_pin1,x_x_puk1,x_x_pin2,x_x_puk2) AS
select table_part_num.description, table_part_num.S_description, table_part_num.part_number, table_part_num.S_part_number,
 table_site.site_id, table_site.name, table_site.S_name,
 table_user.login_name, table_user.S_login_name, table_x_code_table.x_code_number,
 table_x_code_table.x_code_name, table_x_sim_inv.objid,
 table_x_sim_inv.x_sim_serial_no, table_x_sim_inv.x_sim_inv_status,
 table_x_sim_inv.x_sim_mnc, table_x_sim_inv.x_inv_insert_date,
 table_x_sim_inv.x_last_ship_date, table_x_sim_inv.x_sim_po_number,
 table_x_sim_inv.x_sim_order_number, table_x_sim_inv.x_last_update_date,
 table_x_sim_inv.x_qty, table_x_sim_inv.x_pin1,
 table_x_sim_inv.x_puk1, table_x_sim_inv.x_pin2,
 table_x_sim_inv.x_puk2
 from table_part_num, table_site, table_user,
  table_x_code_table, table_x_sim_inv, table_inv_bin,
  table_inv_locatn, table_mod_level
 where table_inv_bin.objid = table_x_sim_inv.x_sim_inv2inv_bin
 AND table_site.objid = table_inv_locatn.inv_locatn2site
 AND table_user.objid = table_x_sim_inv.x_created_by2user
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_inv_locatn.objid = table_inv_bin.inv_bin2inv_locatn
 AND table_x_code_table.objid = table_x_sim_inv.x_sim_status2x_code_table
 AND table_mod_level.objid = table_x_sim_inv.x_sim_inv2part_mod
 ;
COMMENT ON TABLE sa.table_x_sim_load_view IS 'SIM Load View';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_description IS 'Description of the product';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_site_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_name IS 'Name of the site';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_login_name IS 'User login name';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_code_number IS 'Code Number';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_code_name IS 'Code Name';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_sim_serial_no IS 'For parts tracked by serial number, the SIM serial number';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_sim_inv_status IS 'Status of the SIM inventory part';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_sim_mnc IS 'SIM MNC';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_inv_insert_date IS 'The Date on which the SIM was received from manufacturer';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_last_ship_date IS 'The Date on which the SIM was shipped to retailer';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_sim_po_number IS 'The Purchase Order Number for the Part';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_sim_order_number IS 'Order Number (Oracle Financials interface)';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_last_update_date IS 'Last update date';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_qty IS 'Quantity';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_pin1 IS 'Pin 1';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_puk1 IS 'Puk 1';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_pin2 IS 'Pin 2';
COMMENT ON COLUMN sa.table_x_sim_load_view.x_x_puk2 IS 'Puk 2';