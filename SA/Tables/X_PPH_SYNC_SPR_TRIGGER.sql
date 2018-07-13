CREATE TABLE sa.x_pph_sync_spr_trigger (
  pph_objid NUMBER(38) NOT NULL,
  sourcesystem VARCHAR2(30 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  CONSTRAINT pk_pph_sync_spr_trigger PRIMARY KEY (pph_objid)
);
COMMENT ON COLUMN sa.x_pph_sync_spr_trigger.insert_timestamp IS 'Insert time stamp for the transaction';