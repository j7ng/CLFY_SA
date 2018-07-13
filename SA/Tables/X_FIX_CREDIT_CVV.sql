CREATE TABLE sa.x_fix_credit_cvv (
  objid NUMBER,
  status VARCHAR2(10 BYTE)
);
ALTER TABLE sa.x_fix_credit_cvv ADD SUPPLEMENTAL LOG GROUP dmtsora1723777583_0 (objid, status) ALWAYS;