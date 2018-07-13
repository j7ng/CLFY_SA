CREATE TABLE sa.x_pending_deact_bkup (
  objid NUMBER,
  x_expire_dt DATE
);
ALTER TABLE sa.x_pending_deact_bkup ADD SUPPLEMENTAL LOG GROUP dmtsora1077923696_0 (objid, x_expire_dt) ALWAYS;