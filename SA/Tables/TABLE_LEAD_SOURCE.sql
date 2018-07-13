CREATE TABLE sa.table_lead_source (
  objid NUMBER,
  "TYPE" VARCHAR2(25 BYTE),
  status VARCHAR2(30 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  start_date DATE,
  end_date DATE,
  expense NUMBER(19,4),
  comments VARCHAR2(255 BYTE),
  "LOCATION" VARCHAR2(50 BYTE),
  s_location VARCHAR2(50 BYTE),
  "ID" VARCHAR2(32 BYTE),
  s_id VARCHAR2(32 BYTE),
  phone VARCHAR2(20 BYTE),
  is_default NUMBER,
  dev NUMBER,
  source2campaign NUMBER
);
ALTER TABLE sa.table_lead_source ADD SUPPLEMENTAL LOG GROUP dmtsora1424982529_0 (comments, description, dev, end_date, expense, "ID", is_default, "LOCATION", "NAME", objid, phone, source2campaign, start_date, status, s_id, s_location, s_name, "TYPE") ALWAYS;
COMMENT ON TABLE sa.table_lead_source IS 'A specific component of a campaign that is associated with incoming leads and other new sales opportunities';
COMMENT ON COLUMN sa.table_lead_source.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_lead_source."TYPE" IS 'Type of source; e.g., seminar, trade show, etc. This is a user-defined pop up with default name Lead Source Type';
COMMENT ON COLUMN sa.table_lead_source.status IS 'Status of the lead source. This is a user-defined pop up with default name Lead Source Status';
COMMENT ON COLUMN sa.table_lead_source."NAME" IS 'Name of the lead source';
COMMENT ON COLUMN sa.table_lead_source.description IS 'Description of the lead source';
COMMENT ON COLUMN sa.table_lead_source.start_date IS 'The date the lead source became active';
COMMENT ON COLUMN sa.table_lead_source.end_date IS 'The date the lead source ends';
COMMENT ON COLUMN sa.table_lead_source.expense IS 'Lead source cost';
COMMENT ON COLUMN sa.table_lead_source.comments IS 'Comments about the lead source';
COMMENT ON COLUMN sa.table_lead_source."LOCATION" IS 'Location of the lead source';
COMMENT ON COLUMN sa.table_lead_source."ID" IS 'Unique identifier of the lead source';
COMMENT ON COLUMN sa.table_lead_source.phone IS 'Phone number of the lead source';
COMMENT ON COLUMN sa.table_lead_source.is_default IS 'Indicates whether the object is the default lead source; i.e., 0=no, 1=yes. Used for auto-generated opportunities, which must be related to a lead_source';
COMMENT ON COLUMN sa.table_lead_source.dev IS 'Row version number for mobile distribution purposes';