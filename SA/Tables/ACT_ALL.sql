CREATE TABLE sa.act_all (
  action_type CHAR(10 BYTE),
  ct_x_service_id VARCHAR2(30 BYTE),
  esnpi_x_po_num VARCHAR2(30 BYTE),
  ct_x_min VARCHAR2(30 BYTE),
  ac_x_acct_num VARCHAR2(32 BYTE),
  cellpi_x_insert_date DATE,
  ct_x_transact_date DATE,
  sp_x_zipcode VARCHAR2(20 BYTE),
  deactivation_date DATE,
  deactivation_reason DATE,
  ct_objid NUMBER,
  ct_x_sourcesystem VARCHAR2(30 BYTE),
  ca_objid NUMBER,
  ca_x_carrier_id NUMBER,
  ca_x_mkt_submkt_name VARCHAR2(30 BYTE),
  ca_x_carrier2address NUMBER,
  cmadd_address VARCHAR2(200 BYTE),
  cmadd_address_2 VARCHAR2(200 BYTE),
  cmadd_city VARCHAR2(30 BYTE),
  cmadd_state VARCHAR2(40 BYTE),
  cmadd_zipcode VARCHAR2(20 BYTE),
  cg_objid NUMBER,
  cg_x_carrier_group_id NUMBER,
  cg_x_carrier_name VARCHAR2(30 BYTE),
  cg_x_group2address NUMBER,
  cgadd_address VARCHAR2(200 BYTE),
  cgadd_address_2 VARCHAR2(200 BYTE),
  cgadd_city VARCHAR2(30 BYTE),
  cgadd_state VARCHAR2(40 BYTE),
  cgadd_zipcode VARCHAR2(20 BYTE),
  ct_x_call_trans2user NUMBER,
  us_login_name VARCHAR2(30 BYTE),
  em_first_name VARCHAR2(30 BYTE),
  em_last_name VARCHAR2(30 BYTE),
  cn_first_name VARCHAR2(30 BYTE),
  cn_last_name VARCHAR2(30 BYTE),
  custadd_address VARCHAR2(200 BYTE),
  custadd_address_2 VARCHAR2(200 BYTE),
  custadd_city VARCHAR2(30 BYTE),
  custadd_state VARCHAR2(40 BYTE),
  custadd_zipcode VARCHAR2(20 BYTE),
  cn_phone VARCHAR2(20 BYTE),
  esnst_objid NUMBER,
  esnst_site_id VARCHAR2(80 BYTE),
  esnst_name VARCHAR2(80 BYTE),
  esnpn_objid NUMBER,
  esnpn_part_number VARCHAR2(30 BYTE),
  esnpn_description VARCHAR2(255 BYTE),
  sp_site_part2x_plan NUMBER,
  cellpi_part_inst2x_pers NUMBER,
  esnpn_x_technology VARCHAR2(20 BYTE),
  act_tech VARCHAR2(20 BYTE),
  ca_x_act_technology VARCHAR2(20 BYTE),
  ca_x_act_analog NUMBER,
  ca_x_react_technology VARCHAR2(20 BYTE),
  ca_x_react_analog NUMBER,
  cd_x_code_name VARCHAR2(20 BYTE),
  cn_x_cust_id VARCHAR2(80 BYTE),
  jt DATE DEFAULT sysdate
);
ALTER TABLE sa.act_all ADD SUPPLEMENTAL LOG GROUP dmtsora39039045_0 (action_type, ac_x_acct_num, ca_objid, ca_x_carrier2address, ca_x_carrier_id, ca_x_mkt_submkt_name, cellpi_x_insert_date, cgadd_address, cgadd_address_2, cgadd_city, cgadd_state, cgadd_zipcode, cg_objid, cg_x_carrier_group_id, cg_x_carrier_name, cg_x_group2address, cmadd_address, cmadd_address_2, cmadd_city, cmadd_state, cmadd_zipcode, ct_objid, ct_x_call_trans2user, ct_x_min, ct_x_service_id, ct_x_sourcesystem, ct_x_transact_date, deactivation_date, deactivation_reason, em_first_name, esnpi_x_po_num, sp_x_zipcode, us_login_name) ALWAYS;
ALTER TABLE sa.act_all ADD SUPPLEMENTAL LOG GROUP dmtsora39039045_1 (act_tech, ca_x_act_analog, ca_x_act_technology, ca_x_react_analog, ca_x_react_technology, cd_x_code_name, cellpi_part_inst2x_pers, cn_first_name, cn_last_name, cn_phone, cn_x_cust_id, custadd_address, custadd_address_2, custadd_city, custadd_state, custadd_zipcode, em_last_name, esnpn_description, esnpn_objid, esnpn_part_number, esnpn_x_technology, esnst_name, esnst_objid, esnst_site_id, sp_site_part2x_plan) ALWAYS;