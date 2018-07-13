CREATE TABLE sa.table_sec_threshold_types (
  objid NUMBER,
  thresh_level VARCHAR2(5 BYTE) CHECK (upper(thresh_level) in ('ESN','AGENT')) CHECK (upper(thresh_level) in ('ESN','AGENT')),
  thresh_comp_type VARCHAR2(5 BYTE) CHECK (upper(thresh_comp_type) in ('COMP','REPL')) CHECK (upper(thresh_comp_type) in ('COMP','REPL')),
  thresh_unit_type VARCHAR2(25 BYTE) CHECK (upper(thresh_unit_type) in ('VOICE','DATA','SMS','DAYS')) CHECK (upper(thresh_unit_type) in ('VOICE','DATA','SMS','DAYS')),
  CONSTRAINT uniq_cons UNIQUE (thresh_level,thresh_comp_type,thresh_unit_type)
);