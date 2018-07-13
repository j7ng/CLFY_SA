CREATE TABLE sa.x_udp_user_brand_enable (
  objid NUMBER NOT NULL,
  x_user_objid NUMBER NOT NULL,
  x_bus_org_objid NUMBER NOT NULL,
  x_flag_enable VARCHAR2(1 BYTE) NOT NULL,
  x_idn_user_created VARCHAR2(50 BYTE),
  x_dte_created DATE,
  x_idn_user_change_last VARCHAR2(50 BYTE),
  x_dte_change_last DATE,
  CONSTRAINT udp_user_brand_unique UNIQUE (x_user_objid,x_bus_org_objid)
);
COMMENT ON TABLE sa.x_udp_user_brand_enable IS 'This table will determine list of brands, a user will be able view after logging into UDP. Users who are not present in this table will view all brands after log-in. Business will provide users and list of brands (that user can view) to support team; who there by insert/update records in this table';
COMMENT ON COLUMN sa.x_udp_user_brand_enable.objid IS 'Primary key column of X_UDP_USER_BRAND_ENABLE table';
COMMENT ON COLUMN sa.x_udp_user_brand_enable.x_user_objid IS 'Link user Objid of table_user';
COMMENT ON COLUMN sa.x_udp_user_brand_enable.x_bus_org_objid IS 'Link Organization Objid of table_bus_org';
COMMENT ON COLUMN sa.x_udp_user_brand_enable.x_flag_enable IS 'Enable flag. With valid values are Y or N ';
COMMENT ON COLUMN sa.x_udp_user_brand_enable.x_idn_user_created IS 'User who created this record ';
COMMENT ON COLUMN sa.x_udp_user_brand_enable.x_dte_created IS 'Date when this record is created ';
COMMENT ON COLUMN sa.x_udp_user_brand_enable.x_idn_user_change_last IS 'User who updated this record ';
COMMENT ON COLUMN sa.x_udp_user_brand_enable.x_dte_change_last IS 'Date when this record is updated ';