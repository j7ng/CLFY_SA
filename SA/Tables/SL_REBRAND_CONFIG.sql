CREATE TABLE sa.sl_rebrand_config (
  objid NUMBER NOT NULL,
  source_part VARCHAR2(30 BYTE),
  dest_tf_part VARCHAR2(30 BYTE),
  dest_nt_part VARCHAR2(30 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  CONSTRAINT pk_sl_rebrand_config PRIMARY KEY (objid)
);