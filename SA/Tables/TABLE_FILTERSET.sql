CREATE TABLE sa.table_filterset (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  "TYPE" VARCHAR2(30 BYTE),
  id1 NUMBER,
  id2 VARCHAR2(30 BYTE),
  obj_type NUMBER,
  view_type NUMBER,
  stored_prc_name VARCHAR2(40 BYTE),
  sql_statement LONG,
  order_val NUMBER,
  is_default VARCHAR2(20 BYTE),
  dev NUMBER,
  filterset2user NUMBER(*,0),
  update_stamp DATE
);
ALTER TABLE sa.table_filterset ADD SUPPLEMENTAL LOG GROUP dmtsora502069533_0 (dev, filterset2user, id1, id2, is_default, objid, obj_type, order_val, stored_prc_name, title, "TYPE", update_stamp, view_type) ALWAYS;
COMMENT ON TABLE sa.table_filterset IS 'Object which stores the definition of a filter as defined by a user';
COMMENT ON COLUMN sa.table_filterset.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_filterset.title IS 'Name of the filterset';
COMMENT ON COLUMN sa.table_filterset."TYPE" IS 'Function that is using the filterset; e.g., CBX';
COMMENT ON COLUMN sa.table_filterset.id1 IS 'ID of the form to which the filterset belongs';
COMMENT ON COLUMN sa.table_filterset.id2 IS 'Identifies the functionality using the filterset';
COMMENT ON COLUMN sa.table_filterset.obj_type IS 'Object type ID base object the filterset is for; e.g., 0=case, 52=site';
COMMENT ON COLUMN sa.table_filterset.view_type IS 'Schema view being used for filterset; differs based on object type';
COMMENT ON COLUMN sa.table_filterset.stored_prc_name IS 'Reserved for the name of the stored procedure for the filterset';
COMMENT ON COLUMN sa.table_filterset.sql_statement IS 'SQL code created based on parameters entered by user for the filterset';
COMMENT ON COLUMN sa.table_filterset.order_val IS '0=Ascending , 1=descending sort criteria';
COMMENT ON COLUMN sa.table_filterset.is_default IS 'If the default filterset, set to string representing "default", else blank';
COMMENT ON COLUMN sa.table_filterset.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_filterset.update_stamp IS 'Date/time of last update to the filterset';