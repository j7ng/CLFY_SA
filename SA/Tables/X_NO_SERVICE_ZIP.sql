CREATE TABLE sa.x_no_service_zip (
  "STATE" VARCHAR2(20 BYTE),
  city VARCHAR2(100 BYTE),
  zip VARCHAR2(5 BYTE)
);
ALTER TABLE sa.x_no_service_zip ADD SUPPLEMENTAL LOG GROUP dmtsora1362478569_0 (city, "STATE", zip) ALWAYS;
COMMENT ON TABLE sa.x_no_service_zip IS 'This table holds the zip codes that do not offer service.';
COMMENT ON COLUMN sa.x_no_service_zip."STATE" IS 'State Code';
COMMENT ON COLUMN sa.x_no_service_zip.city IS 'Name of City';
COMMENT ON COLUMN sa.x_no_service_zip.zip IS 'Zip Code';