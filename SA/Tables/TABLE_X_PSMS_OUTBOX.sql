CREATE TABLE sa.table_x_psms_outbox (
  objid NUMBER,
  dev NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_seq NUMBER,
  x_command VARCHAR2(10 BYTE),
  x_creation_date DATE,
  x_status VARCHAR2(10 BYTE),
  x_red_card VARCHAR2(30 BYTE),
  x_last_update DATE,
  x_ild_type NUMBER,
  outbox2call_trans NUMBER
);
ALTER TABLE sa.table_x_psms_outbox ADD SUPPLEMENTAL LOG GROUP dmtsora580621899_0 (dev, objid, outbox2call_trans, x_command, x_creation_date, x_esn, x_ild_type, x_last_update, x_red_card, x_seq, x_status) ALWAYS;
COMMENT ON TABLE sa.table_x_psms_outbox IS 'Pending PSMS messages to be generated';
COMMENT ON COLUMN sa.table_x_psms_outbox.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_psms_outbox.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_psms_outbox.x_esn IS 'TBD';
COMMENT ON COLUMN sa.table_x_psms_outbox.x_seq IS 'Sequence for message creation';
COMMENT ON COLUMN sa.table_x_psms_outbox.x_command IS 'Type of Command,  Represents a relation to x_psms_template';
COMMENT ON COLUMN sa.table_x_psms_outbox.x_creation_date IS 'Date - Time record was created';
COMMENT ON COLUMN sa.table_x_psms_outbox.x_status IS 'Status of the record Pending, Processed, Canceled';
COMMENT ON COLUMN sa.table_x_psms_outbox.x_red_card IS 'Future use to hold cards for redemption';
COMMENT ON COLUMN sa.table_x_psms_outbox.x_last_update IS 'Date-Time of last status update';
COMMENT ON COLUMN sa.table_x_psms_outbox.x_ild_type IS 'ild_type associated to part number and psms_template';
COMMENT ON COLUMN sa.table_x_psms_outbox.outbox2call_trans IS 'TBD';