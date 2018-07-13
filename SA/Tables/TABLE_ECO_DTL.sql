CREATE TABLE sa.table_eco_dtl (
  objid NUMBER,
  detail_type VARCHAR2(30 BYTE),
  "REQUIRED" NUMBER,
  status VARCHAR2(30 BYTE),
  labor_type VARCHAR2(30 BYTE),
  "TIME" NUMBER,
  "LOCATION" VARCHAR2(30 BYTE),
  description LONG,
  dev NUMBER,
  eco_details2eco_hdr NUMBER(*,0),
  eco_dtl2mod_level NUMBER(*,0)
);
ALTER TABLE sa.table_eco_dtl ADD SUPPLEMENTAL LOG GROUP dmtsora881564118_0 (detail_type, dev, eco_details2eco_hdr, eco_dtl2mod_level, labor_type, "LOCATION", objid, "REQUIRED", status, "TIME") ALWAYS;
COMMENT ON TABLE sa.table_eco_dtl IS 'A set of either labor or part detail information about an ECO.';
COMMENT ON COLUMN sa.table_eco_dtl.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_eco_dtl.detail_type IS 'Type of ECO, labor or part:  This is a clarify-defined pop up';
COMMENT ON COLUMN sa.table_eco_dtl."REQUIRED" IS 'Indicates whether the change is mandatory or optional; i.e., 0=optional, 1=mandatory';
COMMENT ON COLUMN sa.table_eco_dtl.status IS 'Status of the ECO detail. This is a user-defined popup';
COMMENT ON COLUMN sa.table_eco_dtl.labor_type IS 'Type of Labor. This is a user-defined popup';
COMMENT ON COLUMN sa.table_eco_dtl."TIME" IS 'Total elapsed time spent accomplishing task in seconds';
COMMENT ON COLUMN sa.table_eco_dtl."LOCATION" IS 'Ref Designator associated with ECO detail.';
COMMENT ON COLUMN sa.table_eco_dtl.description IS 'Text of the ECO Detail';
COMMENT ON COLUMN sa.table_eco_dtl.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_eco_dtl.eco_details2eco_hdr IS 'ECO header';
COMMENT ON COLUMN sa.table_eco_dtl.eco_dtl2mod_level IS 'Describes all part revisions associated with this ECO';