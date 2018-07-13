CREATE TABLE sa.x_cost_center (
  x_cost_center_no NUMBER,
  x_cost_center_name VARCHAR2(200 BYTE)
);
ALTER TABLE sa.x_cost_center ADD SUPPLEMENTAL LOG GROUP dmtsora1463157909_0 (x_cost_center_name, x_cost_center_no) ALWAYS;
COMMENT ON TABLE sa.x_cost_center IS 'Lookup used by Promo Engine to Identify the Cost Center that is generating a given promotions.';
COMMENT ON COLUMN sa.x_cost_center.x_cost_center_no IS 'Accounting ID for the Cost Center';
COMMENT ON COLUMN sa.x_cost_center.x_cost_center_name IS 'Name of the Cost Center According to Accounting Ledger.';