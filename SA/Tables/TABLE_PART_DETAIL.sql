CREATE TABLE sa.table_part_detail (
  objid NUMBER,
  part_type NUMBER,
  machine_id VARCHAR2(80 BYTE),
  long1 NUMBER,
  long2 NUMBER,
  long3 NUMBER,
  long4 NUMBER,
  long5 NUMBER,
  long6 NUMBER,
  long7 NUMBER,
  long8 NUMBER,
  text1 VARCHAR2(255 BYTE),
  text2 VARCHAR2(255 BYTE),
  text3 VARCHAR2(255 BYTE),
  text4 VARCHAR2(255 BYTE),
  text5 VARCHAR2(255 BYTE),
  text6 VARCHAR2(255 BYTE),
  text7 VARCHAR2(255 BYTE),
  text8 VARCHAR2(255 BYTE),
  text9 VARCHAR2(255 BYTE),
  date1 DATE,
  date2 DATE,
  dev NUMBER,
  detail_key2site_part NUMBER(*,0)
);
ALTER TABLE sa.table_part_detail ADD SUPPLEMENTAL LOG GROUP dmtsora652583197_0 (date1, date2, detail_key2site_part, dev, long1, long2, long3, long4, long5, long6, long7, long8, machine_id, objid, part_type, text1, text2, text3, text4, text5, text6, text7, text8, text9) ALWAYS;
COMMENT ON TABLE sa.table_part_detail IS 'Contains record types with part data for systems management';
COMMENT ON COLUMN sa.table_part_detail.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_part_detail.part_type IS 'Record type; i.e., 1=AuditedSoftware, 2=Disk, 3=Environment, 4=Identification, 5=NetworkCard, 6=Network, 7=OperatingSystem, 8=Processor, 9=Video, 10=WorkstationStatus, 11=Memory';
COMMENT ON COLUMN sa.table_part_detail.machine_id IS 'Parent site_part machine ID. Used for SMS compare';
COMMENT ON COLUMN sa.table_part_detail.long1 IS 'Integer value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.long2 IS 'Integer value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.long3 IS 'Integer value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.long4 IS 'Integer value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.long5 IS 'Integer value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.long6 IS 'Integer value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.long7 IS 'Integer value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.long8 IS 'Integer value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.text1 IS 'Character value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.text2 IS 'Character value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.text3 IS 'Character value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.text4 IS 'Character value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.text5 IS 'Character value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.text6 IS 'Character value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.text7 IS 'Character value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.text8 IS 'Character value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.text9 IS 'Character value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.date1 IS 'Date value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.date2 IS 'Date value; meaning depends on part type';
COMMENT ON COLUMN sa.table_part_detail.dev IS 'Row version number for mobile distribution purposes';