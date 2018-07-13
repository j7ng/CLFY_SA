CREATE TABLE sa.table_x_model_features (
  objid NUMBER,
  dev NUMBER,
  x_feat_name VARCHAR2(80 BYTE),
  x_feat_value VARCHAR2(80 BYTE),
  feature2part_class NUMBER
);
ALTER TABLE sa.table_x_model_features ADD SUPPLEMENTAL LOG GROUP dmtsora403305279_0 (dev, feature2part_class, objid, x_feat_name, x_feat_value) ALWAYS;