CREATE TABLE sa.x_cos (
  "COS" VARCHAR2(15 BYTE) NOT NULL,
  pcrf_low_priority_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  queue_priority NUMBER(2) DEFAULT 1,
  CONSTRAINT pk_cos PRIMARY KEY ("COS")
);
COMMENT ON TABLE sa.x_cos IS 'table to configure class of service values';
COMMENT ON COLUMN sa.x_cos."COS" IS 'COS value';
COMMENT ON COLUMN sa.x_cos.pcrf_low_priority_flag IS 'Flag to indicate when records will be moved the low priority table';