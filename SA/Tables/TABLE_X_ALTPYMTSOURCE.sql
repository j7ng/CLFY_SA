CREATE TABLE sa.table_x_altpymtsource (
  objid NUMBER,
  x_alt_pymt_source VARCHAR2(20 BYTE),
  x_alt_pymt_source_type VARCHAR2(20 BYTE),
  x_application_key VARCHAR2(100 BYTE),
  x_status VARCHAR2(10 BYTE),
  x_customer_firstname VARCHAR2(20 BYTE),
  x_customer_lastname VARCHAR2(20 BYTE),
  x_customer_phone VARCHAR2(20 BYTE),
  x_customer_email VARCHAR2(50 BYTE),
  x_changedate DATE,
  x_original_insert_date DATE,
  x_changedby VARCHAR2(20 BYTE),
  x_comments LONG,
  x_moms_maiden VARCHAR2(20 BYTE),
  x_altpymtsource2contact NUMBER,
  x_altpymtsource2address NUMBER,
  x_altpymtsource2bus_org NUMBER
);
COMMENT ON TABLE sa.table_x_altpymtsource IS 'Table stores Alternative Payment source details.';
COMMENT ON COLUMN sa.table_x_altpymtsource.objid IS 'refers to the UniqueId to identify each alternative payment source added';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_alt_pymt_source IS 'refers Alternative Payment source';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_alt_pymt_source_type IS 'refers Type of the Alternative Payment Source';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_application_key IS 'refers Order key';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_status IS 'refers to status of the Payment source';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_customer_firstname IS 'refers to Customer Firstname';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_customer_lastname IS 'refers to Customer Lastname';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_customer_phone IS 'refers to Customer Phone';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_customer_email IS 'refers to Customer Email';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_changedate IS 'refers to Changedate';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_original_insert_date IS 'refers to Original Insert date';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_changedby IS 'refers to person who has changed this record';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_comments IS 'refers to Comments if any';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_moms_maiden IS 'refers to Mothers Maiden Name';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_altpymtsource2contact IS 'Foriegn key being referred from Contact table';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_altpymtsource2address IS 'Foriegn key being referred from Address table';
COMMENT ON COLUMN sa.table_x_altpymtsource.x_altpymtsource2bus_org IS 'Foriegn key being referred from BusOrg table';