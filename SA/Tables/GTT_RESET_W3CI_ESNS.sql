CREATE GLOBAL TEMPORARY TABLE sa.gtt_reset_w3ci_esns (
  esn VARCHAR2(30 BYTE) NOT NULL,
  "MIN" VARCHAR2(30 BYTE),
  account_group_id NUMBER(22) NOT NULL,
  master_flag VARCHAR2(1 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE,
  CONSTRAINT pk_gtt_reset_w3ci_esns PRIMARY KEY (esn)
)
ON COMMIT PRESERVE ROWS;
COMMENT ON TABLE sa.gtt_reset_w3ci_esns IS 'Global Temp table to hold member transaction to process in STMT level trigger';