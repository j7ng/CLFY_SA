CREATE TABLE sa.table_part_delta (
  objid NUMBER,
  part_type NUMBER,
  machine_id VARCHAR2(80 BYTE),
  from_system VARCHAR2(20 BYTE),
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
  dev NUMBER
);
ALTER TABLE sa.table_part_delta ADD SUPPLEMENTAL LOG GROUP dmtsora435745764_0 (date1, date2, dev, from_system, long1, long2, long3, long4, long5, long6, long7, long8, machine_id, objid, part_type, text1, text2, text3, text4, text5, text6, text7, text8, text9) ALWAYS;