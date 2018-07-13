CREATE TABLE sa.red22 (
  sp_objid NUMBER,
  sp_install_date DATE,
  sp_x_zipcode VARCHAR2(20 BYTE),
  sp_site_part2x_plan NUMBER,
  sp_site_part2site NUMBER,
  objid NUMBER,
  custsite_cust_primaddr2address NUMBER(*,0),
  custadd_address VARCHAR2(200 BYTE),
  custadd_address_2 VARCHAR2(200 BYTE),
  custadd_city VARCHAR2(30 BYTE),
  custadd_state VARCHAR2(40 BYTE),
  custadd_zipcode VARCHAR2(20 BYTE),
  cr_contact_role2contact NUMBER(*,0),
  cn_first_name VARCHAR2(30 BYTE),
  cn_last_name VARCHAR2(30 BYTE),
  cn_phone VARCHAR2(20 BYTE),
  cn_x_cust_id VARCHAR2(80 BYTE)
);
ALTER TABLE sa.red22 ADD SUPPLEMENTAL LOG GROUP dmtsora761940504_0 (cn_first_name, cn_last_name, cn_phone, cn_x_cust_id, cr_contact_role2contact, custadd_address, custadd_address_2, custadd_city, custadd_state, custadd_zipcode, custsite_cust_primaddr2address, objid, sp_install_date, sp_objid, sp_site_part2site, sp_site_part2x_plan, sp_x_zipcode) ALWAYS;