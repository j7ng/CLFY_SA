CREATE TABLE sa.table_close_exch (
  objid NUMBER,
  close_date DATE,
  "SUMMARY" VARCHAR2(255 BYTE),
  s_summary VARCHAR2(255 BYTE),
  dev NUMBER,
  close2exchange NUMBER
);
ALTER TABLE sa.table_close_exch ADD SUPPLEMENTAL LOG GROUP dmtsora367392351_0 (close2exchange, close_date, dev, objid, "SUMMARY", s_summary) ALWAYS;
COMMENT ON TABLE sa.table_close_exch IS 'Close exchange object which records contains the exchange metrics. Reserved; future';
COMMENT ON COLUMN sa.table_close_exch.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_close_exch.close_date IS 'Exchange close date and time';
COMMENT ON COLUMN sa.table_close_exch."SUMMARY" IS 'Close case summary';
COMMENT ON COLUMN sa.table_close_exch.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_close_exch.close2exchange IS 'The related exchange';