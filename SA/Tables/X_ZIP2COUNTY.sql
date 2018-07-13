CREATE TABLE sa.x_zip2county (
  zip VARCHAR2(10 BYTE),
  county VARCHAR2(50 BYTE),
  st VARCHAR2(10 BYTE)
);
ALTER TABLE sa.x_zip2county ADD SUPPLEMENTAL LOG GROUP dmtsora1078495462_0 (county, st, zip) ALWAYS;
COMMENT ON TABLE sa.x_zip2county IS 'Counties and States based on Zip Code';
COMMENT ON COLUMN sa.x_zip2county.zip IS 'Zip Code';
COMMENT ON COLUMN sa.x_zip2county.county IS 'County Name';
COMMENT ON COLUMN sa.x_zip2county.st IS 'State Code';