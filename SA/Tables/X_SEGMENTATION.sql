CREATE TABLE sa.x_segmentation (
  segmentation_id NUMBER,
  segmentation_name VARCHAR2(20 BYTE),
  action_type VARCHAR2(30 BYTE),
  action_date DATE,
  esn VARCHAR2(30 BYTE),
  toss_part_num VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_segmentation ADD SUPPLEMENTAL LOG GROUP dmtsora1182884690_0 (action_date, action_type, esn, segmentation_id, segmentation_name, toss_part_num) ALWAYS;