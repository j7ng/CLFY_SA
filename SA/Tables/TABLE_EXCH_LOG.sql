CREATE TABLE sa.table_exch_log (
  objid NUMBER,
  exch_code NUMBER,
  reason_code VARCHAR2(80 BYTE),
  entry_time DATE,
  comments LONG,
  dev NUMBER,
  exch_log2exchange NUMBER(*,0),
  exch_log2contact_role NUMBER(*,0),
  exch_log2user NUMBER(*,0),
  event_time DATE,
  exch_log2close_exch NUMBER,
  repair_code NUMBER
);
ALTER TABLE sa.table_exch_log ADD SUPPLEMENTAL LOG GROUP dmtsora1572368289_0 (dev, entry_time, event_time, exch_code, exch_log2close_exch, exch_log2contact_role, exch_log2exchange, exch_log2user, objid, reason_code, repair_code) ALWAYS;
COMMENT ON TABLE sa.table_exch_log IS 'Records exchange events';
COMMENT ON COLUMN sa.table_exch_log.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_exch_log.exch_code IS 'Event code for the exchange log entry; internally assigned with a unique code for each type of event';
COMMENT ON COLUMN sa.table_exch_log.reason_code IS 'Reason for the event from user-defined popup lists which are context dependent';
COMMENT ON COLUMN sa.table_exch_log.entry_time IS 'Date and time of entry into exchange log';
COMMENT ON COLUMN sa.table_exch_log.comments IS 'Notes about the event';
COMMENT ON COLUMN sa.table_exch_log.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_exch_log.exch_log2exchange IS 'The releated exchange object';
COMMENT ON COLUMN sa.table_exch_log.exch_log2contact_role IS 'Contact role who performed the activity';
COMMENT ON COLUMN sa.table_exch_log.exch_log2user IS 'User who created the entry';
COMMENT ON COLUMN sa.table_exch_log.event_time IS 'Date and time the event took place';
COMMENT ON COLUMN sa.table_exch_log.exch_log2close_exch IS 'Related close_exch';
COMMENT ON COLUMN sa.table_exch_log.repair_code IS 'Identifies the X790 Repair Activity performed';