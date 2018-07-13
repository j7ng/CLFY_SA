CREATE TABLE sa.st_winback (
  objid NUMBER(22) NOT NULL,
  esn VARCHAR2(30 BYTE) NOT NULL,
  winback_flag VARCHAR2(1 BYTE) DEFAULT 'Y' NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  inactive_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  CONSTRAINT pk_st_winback PRIMARY KEY (objid)
);
COMMENT ON COLUMN sa.st_winback.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.st_winback.esn IS 'ESN information';
COMMENT ON COLUMN sa.st_winback.winback_flag IS 'Promo eligibility';
COMMENT ON COLUMN sa.st_winback.insert_timestamp IS 'Load date';
COMMENT ON COLUMN sa.st_winback.update_timestamp IS 'udpdated date';
COMMENT ON COLUMN sa.st_winback.inactive_flag IS 'Promo is active or not';