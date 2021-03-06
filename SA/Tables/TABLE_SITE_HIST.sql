CREATE TABLE sa.table_site_hist (
  "SID" NUMBER,
  "ACTION" VARCHAR2(10 BYTE),
  username VARCHAR2(30 BYTE),
  osuser VARCHAR2(100 BYTE),
  "PROCESS" VARCHAR2(100 BYTE),
  machine VARCHAR2(100 BYTE),
  terminal VARCHAR2(100 BYTE),
  "PROGRAM" VARCHAR2(100 BYTE),
  logon_time DATE,
  dt DATE,
  old_objid NUMBER,
  old_site_id VARCHAR2(80 BYTE),
  old_name VARCHAR2(80 BYTE),
  old_s_name VARCHAR2(80 BYTE),
  old_external_id VARCHAR2(80 BYTE),
  old_type NUMBER,
  old_logistics_type NUMBER,
  old_is_support NUMBER,
  old_region VARCHAR2(80 BYTE),
  old_s_region VARCHAR2(80 BYTE),
  old_district VARCHAR2(80 BYTE),
  old_s_district VARCHAR2(80 BYTE),
  old_depot VARCHAR2(80 BYTE),
  old_contr_login VARCHAR2(80 BYTE),
  old_contr_passwd VARCHAR2(80 BYTE),
  old_is_default NUMBER,
  old_notes VARCHAR2(255 BYTE),
  old_spec_consid NUMBER,
  old_mdbk VARCHAR2(80 BYTE),
  old_state_code NUMBER,
  old_state_value VARCHAR2(20 BYTE),
  old_industry_type VARCHAR2(30 BYTE),
  old_appl_type VARCHAR2(30 BYTE),
  old_cut_date DATE,
  old_site_type VARCHAR2(4 BYTE),
  old_status NUMBER,
  old_arch_ind NUMBER,
  old_alert_ind NUMBER,
  old_phone VARCHAR2(20 BYTE),
  old_fax VARCHAR2(20 BYTE),
  old_dev NUMBER,
  old_child_site2site NUMBER(38),
  old_support_office2site NUMBER(38),
  old_cust_primaddr2address NUMBER(38),
  old_cust_billaddr2address NUMBER(38),
  old_cust_shipaddr2address NUMBER(38),
  old_site_support2employee NUMBER(38),
  old_site_altsupp2employee NUMBER(38),
  old_report_site2bug NUMBER(38),
  old_primary2bus_org NUMBER(38),
  old_site2exch_protocol NUMBER(38),
  old_dealer2x_promotion NUMBER,
  old_x_smp_optional NUMBER,
  old_update_stamp DATE,
  old_x_fin_cust_id VARCHAR2(40 BYTE),
  old_ship_via VARCHAR2(80 BYTE),
  old_x_commerce_id VARCHAR2(150 BYTE),
  old_x_ship_loc_id NUMBER,
  old_x_referral_id VARCHAR2(20 BYTE),
  new_objid NUMBER,
  new_site_id VARCHAR2(80 BYTE),
  new_name VARCHAR2(80 BYTE),
  new_s_name VARCHAR2(80 BYTE),
  new_external_id VARCHAR2(80 BYTE),
  new_type NUMBER,
  new_logistics_type NUMBER,
  new_is_support NUMBER,
  new_region VARCHAR2(80 BYTE),
  new_s_region VARCHAR2(80 BYTE),
  new_district VARCHAR2(80 BYTE),
  new_s_district VARCHAR2(80 BYTE),
  new_depot VARCHAR2(80 BYTE),
  new_contr_login VARCHAR2(80 BYTE),
  new_contr_passwd VARCHAR2(80 BYTE),
  new_is_default NUMBER,
  new_notes VARCHAR2(255 BYTE),
  new_spec_consid NUMBER,
  new_mdbk VARCHAR2(80 BYTE),
  new_state_code NUMBER,
  new_state_value VARCHAR2(20 BYTE),
  new_industry_type VARCHAR2(30 BYTE),
  new_appl_type VARCHAR2(30 BYTE),
  new_cut_date DATE,
  new_site_type VARCHAR2(4 BYTE),
  new_status NUMBER,
  new_arch_ind NUMBER,
  new_alert_ind NUMBER,
  new_phone VARCHAR2(20 BYTE),
  new_fax VARCHAR2(20 BYTE),
  new_dev NUMBER,
  new_child_site2site NUMBER(38),
  new_support_office2site NUMBER(38),
  new_cust_primaddr2address NUMBER(38),
  new_cust_billaddr2address NUMBER(38),
  new_cust_shipaddr2address NUMBER(38),
  new_site_support2employee NUMBER(38),
  new_site_altsupp2employee NUMBER(38),
  new_report_site2bug NUMBER(38),
  new_primary2bus_org NUMBER(38),
  new_site2exch_protocol NUMBER(38),
  new_dealer2x_promotion NUMBER,
  new_x_smp_optional NUMBER,
  new_update_stamp DATE,
  new_x_fin_cust_id VARCHAR2(40 BYTE),
  new_ship_via VARCHAR2(80 BYTE),
  new_x_commerce_id VARCHAR2(150 BYTE),
  new_x_ship_loc_id NUMBER,
  new_x_referral_id VARCHAR2(20 BYTE)
);