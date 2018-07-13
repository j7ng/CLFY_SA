CREATE TABLE sa.table_expense_log (
  objid NUMBER,
  expense_type VARCHAR2(20 BYTE),
  quantity NUMBER,
  rate NUMBER,
  total NUMBER,
  billable NUMBER,
  bill_to VARCHAR2(30 BYTE),
  removed NUMBER,
  dev NUMBER,
  expense2onsite_log NUMBER(*,0)
);
ALTER TABLE sa.table_expense_log ADD SUPPLEMENTAL LOG GROUP dmtsora1311091907_0 (billable, bill_to, dev, expense2onsite_log, expense_type, objid, quantity, rate, removed, total) ALWAYS;