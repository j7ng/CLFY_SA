CREATE TABLE sa.table_com_tmplte (
  objid NUMBER,
  title VARCHAR2(40 BYTE),
  time_til_esc NUMBER,
  flags NUMBER,
  "CONDITION" VARCHAR2(255 BYTE),
  "ACTION" LONG,
  rule_set VARCHAR2(20 BYTE),
  description VARCHAR2(255 BYTE),
  "TYPE" NUMBER,
  time_type NUMBER,
  time_units NUMBER,
  repeat_num NUMBER,
  repeat_period NUMBER,
  urgency NUMBER,
  dev NUMBER,
  escal_act2com_tmplte NUMBER(*,0),
  commit_time2trnd NUMBER(*,0)
);
ALTER TABLE sa.table_com_tmplte ADD SUPPLEMENTAL LOG GROUP dmtsora1544818098_0 (commit_time2trnd, "CONDITION", description, dev, escal_act2com_tmplte, flags, objid, repeat_num, repeat_period, rule_set, time_til_esc, time_type, time_units, title, "TYPE", urgency) ALWAYS;
COMMENT ON TABLE sa.table_com_tmplte IS 'Object used to define business rules and customer commitments';
COMMENT ON COLUMN sa.table_com_tmplte.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_com_tmplte.title IS 'The title used for identifying the template';
COMMENT ON COLUMN sa.table_com_tmplte.time_til_esc IS 'Elapsed time until time bomb will fire <from creation> in seconds';
COMMENT ON COLUMN sa.table_com_tmplte.flags IS 'Flags controlling associated time bomb behavior';
COMMENT ON COLUMN sa.table_com_tmplte."CONDITION" IS 'Condition that must be true for time bomb to fire';
COMMENT ON COLUMN sa.table_com_tmplte."ACTION" IS 'Action that occurs when time bomb fires. For notifications, this is the message';
COMMENT ON COLUMN sa.table_com_tmplte.rule_set IS 'Designates an administrative group to which a business rule is assigned; e.g., case/Subcase Only, Change Request, Change Status';
COMMENT ON COLUMN sa.table_com_tmplte.description IS 'Description of what the template is used for';
COMMENT ON COLUMN sa.table_com_tmplte."TYPE" IS 'Type for the object';
COMMENT ON COLUMN sa.table_com_tmplte.time_type IS 'Describes the elapsed time relative to the focus object in seconds';
COMMENT ON COLUMN sa.table_com_tmplte.time_units IS 'Describes what type of unit the elapsed time is in';
COMMENT ON COLUMN sa.table_com_tmplte.repeat_num IS 'Describes the number of times to repeat the template';
COMMENT ON COLUMN sa.table_com_tmplte.repeat_period IS 'Amount of elapsed time between repeats';
COMMENT ON COLUMN sa.table_com_tmplte.urgency IS 'The urgency of the associated time bombs';
COMMENT ON COLUMN sa.table_com_tmplte.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_com_tmplte.escal_act2com_tmplte IS 'Escalation rule for the rule';
COMMENT ON COLUMN sa.table_com_tmplte.commit_time2trnd IS 'Commitment object that fires a trend';