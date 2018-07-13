CREATE TABLE sa.table_function (
  objid NUMBER,
  dev NUMBER,
  seqno NUMBER,
  func_type NUMBER,
  "VALUE" VARCHAR2(255 BYTE),
  val_type NUMBER,
  val_focus NUMBER,
  cond_type NUMBER,
  cond_operator NUMBER,
  cond_expected NUMBER,
  val_rev_path VARCHAR2(255 BYTE),
  val_target_name VARCHAR2(64 BYTE),
  val_target_id NUMBER,
  val_attrib_name VARCHAR2(64 BYTE),
  val_filter_list VARCHAR2(255 BYTE),
  val_sqlfrom VARCHAR2(255 BYTE),
  val_sqlwhere VARCHAR2(255 BYTE),
  val_attrib_type NUMBER,
  val_is_flexible NUMBER,
  focus_object VARCHAR2(64 BYTE),
  flags NUMBER,
  reforecast NUMBER,
  belongs2func_group NUMBER,
  function2func_group NUMBER,
  function2svc_rqst NUMBER,
  function2process NUMBER
);
ALTER TABLE sa.table_function ADD SUPPLEMENTAL LOG GROUP dmtsora1017550526_0 (belongs2func_group, cond_expected, cond_operator, cond_type, dev, flags, focus_object, function2func_group, function2process, function2svc_rqst, func_type, objid, reforecast, seqno, "VALUE", val_attrib_name, val_attrib_type, val_filter_list, val_focus, val_is_flexible, val_rev_path, val_sqlfrom, val_sqlwhere, val_target_id, val_target_name, val_type) ALWAYS;
COMMENT ON TABLE sa.table_function IS 'Contains one instance for function contained in a function group. Creates the many to many relation between function groups and thier children either sub_groups or service requests';
COMMENT ON COLUMN sa.table_function.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_function.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_function.seqno IS 'Sequence number for serial functions';
COMMENT ON COLUMN sa.table_function.func_type IS 'Function type. 0 = normal, 1 = error, 2 = cancel';
COMMENT ON COLUMN sa.table_function."VALUE" IS 'The value to match for a conditional group';
COMMENT ON COLUMN sa.table_function.val_type IS '0 = Path, 1 = constant';
COMMENT ON COLUMN sa.table_function.val_focus IS 'If val_type is Path then 0 = focus object, 1 =group_inst';
COMMENT ON COLUMN sa.table_function.cond_type IS 'For condition groups, the function type. 0 = value, 1 = default, 2 = action';
COMMENT ON COLUMN sa.table_function.cond_operator IS 'For condition groups, the operator type. 0 = equal to, 1 = greater than, 2 = less than, 3 = greater than/equal to, 4 = less than/equal to';
COMMENT ON COLUMN sa.table_function.cond_expected IS '1 = The expected function in a conditional group';
COMMENT ON COLUMN sa.table_function.val_rev_path IS 'Where value is a path, this is the reverse path';
COMMENT ON COLUMN sa.table_function.val_target_name IS 'Value path target object name';
COMMENT ON COLUMN sa.table_function.val_target_id IS 'Value path target type ID';
COMMENT ON COLUMN sa.table_function.val_attrib_name IS 'Value path target attribute name';
COMMENT ON COLUMN sa.table_function.val_filter_list IS 'Value reverse path filter list';
COMMENT ON COLUMN sa.table_function.val_sqlfrom IS 'FROM clause for SQL statement';
COMMENT ON COLUMN sa.table_function.val_sqlwhere IS 'WHERE clause for SQL statement';
COMMENT ON COLUMN sa.table_function.val_attrib_type IS 'Attribute type: Same as N_Attribute.N_Type';
COMMENT ON COLUMN sa.table_function.val_is_flexible IS '0 = attribute is fixed, 1 = attribute is flexible';
COMMENT ON COLUMN sa.table_function.focus_object IS 'The focus object of the function (and its related group/rqst/sub-process)';
COMMENT ON COLUMN sa.table_function.flags IS 'Various flags that control the way a function is used';
COMMENT ON COLUMN sa.table_function.reforecast IS 'Reforecast at the completion of this function';
COMMENT ON COLUMN sa.table_function.function2func_group IS 'A group associated with this function (ie a sub_group)';
COMMENT ON COLUMN sa.table_function.function2svc_rqst IS 'A service request associated with this function';
COMMENT ON COLUMN sa.table_function.function2process IS 'A process associated with this function';