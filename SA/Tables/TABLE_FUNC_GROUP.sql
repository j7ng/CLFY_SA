CREATE TABLE sa.table_func_group (
  objid NUMBER,
  dev NUMBER,
  "ID" VARCHAR2(80 BYTE),
  "TYPE" NUMBER,
  iter NUMBER,
  iter_path VARCHAR2(255 BYTE),
  iter_focus NUMBER,
  iter_order VARCHAR2(255 BYTE),
  cond_path VARCHAR2(255 BYTE),
  cond_focus NUMBER,
  iter_rev_path VARCHAR2(255 BYTE),
  iter_target_name VARCHAR2(64 BYTE),
  iter_target_id NUMBER,
  cond_rev_path VARCHAR2(255 BYTE),
  cond_target_name VARCHAR2(64 BYTE),
  cond_target_id NUMBER,
  cond_attrib_name VARCHAR2(64 BYTE),
  cond_filter_list VARCHAR2(255 BYTE),
  iter_filter_list VARCHAR2(255 BYTE),
  iter_sqlfrom VARCHAR2(255 BYTE),
  iter_sqlwhere VARCHAR2(255 BYTE),
  cond_sqlfrom VARCHAR2(255 BYTE),
  cond_sqlwhere VARCHAR2(255 BYTE),
  cond_attrib_type NUMBER,
  cond_is_flexible NUMBER,
  iter_expected NUMBER,
  is_milestone NUMBER,
  func_group2process NUMBER
);
ALTER TABLE sa.table_func_group ADD SUPPLEMENTAL LOG GROUP dmtsora1672251201_0 (cond_attrib_name, cond_attrib_type, cond_filter_list, cond_focus, cond_is_flexible, cond_path, cond_rev_path, cond_sqlfrom, cond_sqlwhere, cond_target_id, cond_target_name, dev, func_group2process, "ID", is_milestone, iter, iter_expected, iter_filter_list, iter_focus, iter_order, iter_path, iter_rev_path, iter_sqlfrom, iter_sqlwhere, iter_target_id, iter_target_name, objid, "TYPE") ALWAYS;
COMMENT ON TABLE sa.table_func_group IS 'Contains one instance for each group of functions within a process. The function group gives the process its structure';
COMMENT ON COLUMN sa.table_func_group.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_func_group.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_func_group."ID" IS 'Function Group ID';
COMMENT ON COLUMN sa.table_func_group."TYPE" IS 'Type of Group 1=Serial, 2=Parallel, 3=Conditional';
COMMENT ON COLUMN sa.table_func_group.iter IS 'Type of iteration 0=Not iterative, 1=iterative, 2=iterative sequential';
COMMENT ON COLUMN sa.table_func_group.iter_path IS 'Iteration path';
COMMENT ON COLUMN sa.table_func_group.iter_focus IS '0 = Current focus object, 1 = current group_inst';
COMMENT ON COLUMN sa.table_func_group.iter_order IS 'Colon separated list of fields to order the iteration for sequential processing';
COMMENT ON COLUMN sa.table_func_group.cond_path IS 'Conditional expression';
COMMENT ON COLUMN sa.table_func_group.cond_focus IS '0 = Current focus object, 1 = current group_inst';
COMMENT ON COLUMN sa.table_func_group.iter_rev_path IS 'Iteration reverse path';
COMMENT ON COLUMN sa.table_func_group.iter_target_name IS 'Iteration path target object name';
COMMENT ON COLUMN sa.table_func_group.iter_target_id IS 'Iteration path target type ID';
COMMENT ON COLUMN sa.table_func_group.cond_rev_path IS 'Condition reverse path';
COMMENT ON COLUMN sa.table_func_group.cond_target_name IS 'Condition path target object name';
COMMENT ON COLUMN sa.table_func_group.cond_target_id IS 'Condition path target type ID';
COMMENT ON COLUMN sa.table_func_group.cond_attrib_name IS 'Condition path target attribute name';
COMMENT ON COLUMN sa.table_func_group.cond_filter_list IS 'Condition reverse path filter list';
COMMENT ON COLUMN sa.table_func_group.iter_filter_list IS 'Iteration reverse path filter list';
COMMENT ON COLUMN sa.table_func_group.iter_sqlfrom IS 'FROM clause for iterative path SQL statement';
COMMENT ON COLUMN sa.table_func_group.iter_sqlwhere IS 'WHERE clause for iterative path SQL statement';
COMMENT ON COLUMN sa.table_func_group.cond_sqlfrom IS 'FROM clause for conditional value SQL statement';
COMMENT ON COLUMN sa.table_func_group.cond_sqlwhere IS 'WHERE clause for conditional value SQL statement';
COMMENT ON COLUMN sa.table_func_group.cond_attrib_type IS 'Attribute type, one of  String, Number, Date';
COMMENT ON COLUMN sa.table_func_group.cond_is_flexible IS '0 = attribute is fixed, 1 = attribute is flexible';
COMMENT ON COLUMN sa.table_func_group.iter_expected IS 'Expected iteration count for forecasting sequential iteration';
COMMENT ON COLUMN sa.table_func_group.is_milestone IS '0 = No, 1 = Completion of this group is a milestone in the process';
COMMENT ON COLUMN sa.table_func_group.func_group2process IS 'Only the top level function group in a process will have this relation set';