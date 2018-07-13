CREATE TABLE sa.x_device_recovery_code (
  objid NUMBER NOT NULL,
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  security_code VARCHAR2(30 BYTE) NOT NULL,
  creation_time DATE NOT NULL,
  last_validation_time DATE,
  failed_attempts NUMBER,
  communication_channel VARCHAR2(20 BYTE) NOT NULL,
  used_status VARCHAR2(1 BYTE),
  PRIMARY KEY (objid)
);
COMMENT ON COLUMN sa.x_device_recovery_code.used_status IS 'Y = Used, N = Un-used, E = Expired';