CREATE TABLE sa.udp_password_reset (
  objid NUMBER NOT NULL,
  s_login_name VARCHAR2(30 BYTE),
  generation_time DATE,
  generated_hash VARCHAR2(150 BYTE),
  PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.udp_password_reset IS 'TABLE USED TO STORE "SYSTEM GENERATED HASH" FOR ADDITIONAL LAYER OF AUTHENTICATION FOR UNIVERSAL DEALER PORTAL(UDP PROJECT)';
COMMENT ON COLUMN sa.udp_password_reset.objid IS 'UNIQUE IDENTIFIER USES SEQUENCE';
COMMENT ON COLUMN sa.udp_password_reset.s_login_name IS 'LOGIN NAME';
COMMENT ON COLUMN sa.udp_password_reset.generation_time IS 'TIME HASH WAS INSERTED';
COMMENT ON COLUMN sa.udp_password_reset.generated_hash IS 'SYSTEM GENERATED HASH';