CREATE TABLE sa.x_serviceplanfeaturevalue_def (
  objid NUMBER,
  parent_objid NUMBER,
  value_name VARCHAR2(50 BYTE) NOT NULL,
  child_value_objid NUMBER,
  display_name VARCHAR2(50 BYTE),
  display_order NUMBER,
  optional NUMBER,
  table_type VARCHAR2(50 BYTE),
  leaf NUMBER,
  description VARCHAR2(250 BYTE)
);
ALTER TABLE sa.x_serviceplanfeaturevalue_def ADD SUPPLEMENTAL LOG GROUP dmtsora1693095727_0 (child_value_objid, description, display_name, display_order, leaf, objid, optional, parent_objid, table_type, value_name) ALWAYS;
COMMENT ON TABLE sa.x_serviceplanfeaturevalue_def IS 'This table defines a tree structure for all the service plan features and its potential values. it works in conjuction with x_service_plan_feature and x_serviceplanfeature_value';
COMMENT ON COLUMN sa.x_serviceplanfeaturevalue_def.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_serviceplanfeaturevalue_def.parent_objid IS 'Self Reference';
COMMENT ON COLUMN sa.x_serviceplanfeaturevalue_def.value_name IS 'Name Value for the Node';
COMMENT ON COLUMN sa.x_serviceplanfeaturevalue_def.child_value_objid IS 'Selft Reference to the Node that defines the possible values.';
COMMENT ON COLUMN sa.x_serviceplanfeaturevalue_def.display_name IS 'Display Description for Node';
COMMENT ON COLUMN sa.x_serviceplanfeaturevalue_def.display_order IS 'Display Order';
COMMENT ON COLUMN sa.x_serviceplanfeaturevalue_def.optional IS 'Optional Flag: 0,1';
COMMENT ON COLUMN sa.x_serviceplanfeaturevalue_def.table_type IS 'Name of the table that contain the options for the values: IT-SELF, TABLE_PART_CLASS';
COMMENT ON COLUMN sa.x_serviceplanfeaturevalue_def.leaf IS 'Is the node a leaf: 0,1';
COMMENT ON COLUMN sa.x_serviceplanfeaturevalue_def.description IS 'Description of the node.';