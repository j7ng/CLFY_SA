CREATE TABLE sa.table_x_tracking_element (
  objid NUMBER,
  x_element_id VARCHAR2(20 BYTE),
  x_element_desc VARCHAR2(100 BYTE),
  x_element_style VARCHAR2(50 BYTE)
);
ALTER TABLE sa.table_x_tracking_element ADD SUPPLEMENTAL LOG GROUP dmtsora711618473_0 (objid, x_element_desc, x_element_id, x_element_style) ALWAYS;
COMMENT ON TABLE sa.table_x_tracking_element IS 'Contains the element records for online tracking';
COMMENT ON COLUMN sa.table_x_tracking_element.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_tracking_element.x_element_id IS 'Element ID';
COMMENT ON COLUMN sa.table_x_tracking_element.x_element_desc IS 'Element Description';
COMMENT ON COLUMN sa.table_x_tracking_element.x_element_style IS 'Element Style';