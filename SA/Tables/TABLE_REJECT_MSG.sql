CREATE TABLE sa.table_reject_msg (
  objid NUMBER,
  creation_time DATE,
  description LONG,
  reject_from VARCHAR2(80 BYTE),
  reject_to VARCHAR2(80 BYTE),
  dev NUMBER,
  reject_reason2case NUMBER(*,0),
  reject_reason2subcase NUMBER(*,0),
  reject_person2user NUMBER(*,0),
  rej_reason2probdesc NUMBER(*,0),
  reject_reason2bug NUMBER(*,0),
  reject_msg2demand_dtl NUMBER(*,0),
  reject_msg2opportunity NUMBER(*,0),
  reject_msg2contract NUMBER(*,0),
  reject_reason2job NUMBER(*,0),
  reject_msg2task NUMBER(*,0),
  reject_msg2dialogue NUMBER
);
ALTER TABLE sa.table_reject_msg ADD SUPPLEMENTAL LOG GROUP dmtsora371072078_0 (creation_time, dev, objid, reject_from, reject_msg2contract, reject_msg2demand_dtl, reject_msg2dialogue, reject_msg2opportunity, reject_msg2task, reject_person2user, reject_reason2bug, reject_reason2case, reject_reason2job, reject_reason2subcase, reject_to, rej_reason2probdesc) ALWAYS;
COMMENT ON TABLE sa.table_reject_msg IS 'Reason for rejecting dispatch of a case, subcase, solution or change request';
COMMENT ON COLUMN sa.table_reject_msg.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_reject_msg.creation_time IS 'Date and time the task was rejected';
COMMENT ON COLUMN sa.table_reject_msg.description IS 'Reason for rejection';
COMMENT ON COLUMN sa.table_reject_msg.reject_from IS 'Queue item was rejected from';
COMMENT ON COLUMN sa.table_reject_msg.reject_to IS 'Queue item was rejected to';
COMMENT ON COLUMN sa.table_reject_msg.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_reject_msg.reject_reason2case IS 'Case for the reject message';
COMMENT ON COLUMN sa.table_reject_msg.reject_reason2subcase IS 'Subcase for the reject message';
COMMENT ON COLUMN sa.table_reject_msg.reject_person2user IS 'User creating the reject message';
COMMENT ON COLUMN sa.table_reject_msg.rej_reason2probdesc IS 'Solution for the reject message';
COMMENT ON COLUMN sa.table_reject_msg.reject_reason2bug IS 'Change request for the reject message';
COMMENT ON COLUMN sa.table_reject_msg.reject_msg2demand_dtl IS 'Part request detail for the reject message';
COMMENT ON COLUMN sa.table_reject_msg.reject_msg2opportunity IS 'Opportunity for the reject message';
COMMENT ON COLUMN sa.table_reject_msg.reject_msg2contract IS 'Contract for the reject message';
COMMENT ON COLUMN sa.table_reject_msg.reject_reason2job IS 'Job for the reject message';
COMMENT ON COLUMN sa.table_reject_msg.reject_msg2task IS 'Task for the reject message';
COMMENT ON COLUMN sa.table_reject_msg.reject_msg2dialogue IS 'Dialogue for the reject message';