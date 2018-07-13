CREATE TABLE sa.x_daily_card_status_log (
  x_smp VARCHAR2(30 BYTE),
  x_run_date DATE,
  x_error VARCHAR2(2000 BYTE)
);
ALTER TABLE sa.x_daily_card_status_log ADD SUPPLEMENTAL LOG GROUP dmtsora1878529034_0 (x_error, x_run_date, x_smp) ALWAYS;