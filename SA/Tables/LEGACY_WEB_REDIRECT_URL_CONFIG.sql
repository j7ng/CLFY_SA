CREATE TABLE sa.legacy_web_redirect_url_config (
  objid VARCHAR2(6 BYTE) NOT NULL,
  brand VARCHAR2(20 BYTE) NOT NULL,
  from_url VARCHAR2(250 BYTE) NOT NULL,
  to_url VARCHAR2(250 BYTE) NOT NULL,
  from_url_type VARCHAR2(50 BYTE),
  to_url_type VARCHAR2(50 BYTE),
  updated_date DATE,
  CONSTRAINT leg_wb_redr_urlcon_pk PRIMARY KEY (objid) USING INDEX sa.ux1_leg_wb_redr_urlcon
);
COMMENT ON TABLE sa.legacy_web_redirect_url_config IS 'Redirect legacy page URL table';
COMMENT ON COLUMN sa.legacy_web_redirect_url_config.objid IS 'Unique id';
COMMENT ON COLUMN sa.legacy_web_redirect_url_config.brand IS 'Brand';
COMMENT ON COLUMN sa.legacy_web_redirect_url_config.from_url IS 'From Legacy URL';
COMMENT ON COLUMN sa.legacy_web_redirect_url_config.to_url IS 'Redirect to URL';
COMMENT ON COLUMN sa.legacy_web_redirect_url_config.from_url_type IS 'From Relative / absolute type of URL';
COMMENT ON COLUMN sa.legacy_web_redirect_url_config.to_url_type IS 'To Relative / absolute type of URL';