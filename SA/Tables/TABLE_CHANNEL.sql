CREATE TABLE sa.table_channel (
  objid NUMBER,
  dev NUMBER,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  s_description VARCHAR2(255 BYTE),
  designation VARCHAR2(80 BYTE),
  "LOCATION" VARCHAR2(255 BYTE),
  s_location VARCHAR2(255 BYTE),
  "ACTIVE" NUMBER,
  inbound_ind NUMBER,
  outbound_ind NUMBER,
  channel2medium NUMBER,
  brm_channel_id NUMBER(22),
  suppress_tax_usf_flag VARCHAR2(1 BYTE),
  suppress_tax_rcrf_flag VARCHAR2(1 BYTE)
);
ALTER TABLE sa.table_channel ADD SUPPLEMENTAL LOG GROUP dmtsora278870749_0 ("ACTIVE", channel2medium, description, designation, dev, inbound_ind, "LOCATION", objid, outbound_ind, s_description, s_location, s_title, title) ALWAYS;
COMMENT ON TABLE sa.table_channel IS 'Communication channel used for customer interactions. This is a grouping within a medium, for a business purpose: e.g., Sales Department email';
COMMENT ON COLUMN sa.table_channel.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_channel.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_channel.title IS 'Common name of the channel';
COMMENT ON COLUMN sa.table_channel.description IS 'Description of the channel';
COMMENT ON COLUMN sa.table_channel.designation IS 'Unique (within medium) designator of the channel';
COMMENT ON COLUMN sa.table_channel."LOCATION" IS 'Free-form description of the channel s location';
COMMENT ON COLUMN sa.table_channel."ACTIVE" IS 'Indicates whether the channel is active; i.e., 0=no, 1=yes, default=1';
COMMENT ON COLUMN sa.table_channel.inbound_ind IS 'Indicates whether the channel allows inbound communication; i.e., 0=no, 1=yes, default=1';
COMMENT ON COLUMN sa.table_channel.outbound_ind IS 'Indicates whether the channel allows outbound communication; i.e., 0=no, 1=yes, default=1';
COMMENT ON COLUMN sa.table_channel.brm_channel_id IS 'BRM specific channel ID';
COMMENT ON COLUMN sa.table_channel.suppress_tax_usf_flag IS 'Determine Apply USF_Tax or Not , Y-> Apply STax ,N-> Dont Apply STax';
COMMENT ON COLUMN sa.table_channel.suppress_tax_rcrf_flag IS 'Determine Apply RCRF_Tax or Not , Y-> Apply STax ,N-> Dont Apply STax';