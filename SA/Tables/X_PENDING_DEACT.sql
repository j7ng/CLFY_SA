CREATE TABLE sa.x_pending_deact (
  objid NUMBER,
  x_expire_dt DATE
);
ALTER TABLE sa.x_pending_deact ADD SUPPLEMENTAL LOG GROUP dmtsora1855543200_0 (objid, x_expire_dt) ALWAYS;