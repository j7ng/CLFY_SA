CREATE TABLE sa.x_e911_esn (
  x_esn VARCHAR2(30 BYTE) NOT NULL,
  esn2e911address NUMBER,
  CONSTRAINT pk_e911_esn PRIMARY KEY (x_esn)
);
COMMENT ON TABLE sa.x_e911_esn IS 'Look up E911 addreess associated to the ESN';
COMMENT ON COLUMN sa.x_e911_esn.x_esn IS 'Electronic Serial Number for the E911';
COMMENT ON COLUMN sa.x_e911_esn.esn2e911address IS 'Reference to the E911 address';