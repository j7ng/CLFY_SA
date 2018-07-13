CREATE TABLE sa.table_escalation (
  objid NUMBER,
  creation_time DATE,
  notes LONG,
  dev NUMBER,
  case_escalate2case NUMBER(*,0),
  subc_escalate2subcase NUMBER(*,0),
  escalate2user NUMBER(*,0),
  bug_escalate2bug NUMBER(*,0)
);
ALTER TABLE sa.table_escalation ADD SUPPLEMENTAL LOG GROUP dmtsora1222007379_0 (bug_escalate2bug, case_escalate2case, creation_time, dev, escalate2user, objid, subc_escalate2subcase) ALWAYS;
COMMENT ON TABLE sa.table_escalation IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_escalation.objid IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_escalation.creation_time IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_escalation.notes IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_escalation.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_escalation.case_escalate2case IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_escalation.subc_escalate2subcase IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_escalation.escalate2user IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_escalation.bug_escalate2bug IS 'Reserved; not used';