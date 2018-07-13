CREATE TABLE sa.x_excluded_pastduedeact (
  x_carrier_id NUMBER
);
ALTER TABLE sa.x_excluded_pastduedeact ADD SUPPLEMENTAL LOG GROUP dmtsora262175001_0 (x_carrier_id) ALWAYS;
COMMENT ON TABLE sa.x_excluded_pastduedeact IS 'Deactivation support table, carrier ids listed here are prevented from deactivating because of past due.';
COMMENT ON COLUMN sa.x_excluded_pastduedeact.x_carrier_id IS 'Deactivation support table, carrier ids listed here are prevented from deactivating because of past due.';