CREATE TABLE sa.table_query (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  obj_type NUMBER,
  view_type NUMBER,
  default_val NUMBER,
  stored_prc_name VARCHAR2(40 BYTE),
  sql_statement LONG,
  keyword_mode VARCHAR2(10 BYTE),
  order_val NUMBER,
  shared_pers NUMBER,
  shared_pers_st VARCHAR2(20 BYTE),
  prompt_ind NUMBER,
  prompt_ind_st VARCHAR2(20 BYTE),
  description VARCHAR2(255 BYTE),
  dev NUMBER,
  query2user NUMBER(*,0),
  x_apex_sql_statement VARCHAR2(4000 BYTE)
);
ALTER TABLE sa.table_query ADD SUPPLEMENTAL LOG GROUP dmtsora1457626558_0 (default_val, description, dev, keyword_mode, objid, obj_type, order_val, prompt_ind, prompt_ind_st, query2user, shared_pers, shared_pers_st, stored_prc_name, title, view_type) ALWAYS;
COMMENT ON TABLE sa.table_query IS 'EIS  object which stores the definition of a query as defined by a user';
COMMENT ON COLUMN sa.table_query.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_query.title IS 'Name of the query';
COMMENT ON COLUMN sa.table_query.obj_type IS 'Object type ID the query is for; e.g., case=0, solution=1, subcase=24, change request=192';
COMMENT ON COLUMN sa.table_query.view_type IS 'Schema view being used for query; differs based on object type';
COMMENT ON COLUMN sa.table_query.default_val IS 'Indicates whether the query invokes properties, keyphrases, or both';
COMMENT ON COLUMN sa.table_query.stored_prc_name IS 'Reserved for the name of the stored procedure for the query';
COMMENT ON COLUMN sa.table_query.sql_statement IS 'SQL code created based on parameters entered by user for the query';
COMMENT ON COLUMN sa.table_query.keyword_mode IS 'If using keywords, match All or Any';
COMMENT ON COLUMN sa.table_query.order_val IS 'Ascending or descending sort criteria';
COMMENT ON COLUMN sa.table_query.shared_pers IS 'Indicates whether the query is shareable with users other than the originator; i.e., 0=private, 1=shareable, default=0';
COMMENT ON COLUMN sa.table_query.shared_pers_st IS 'Translates shared_pers';
COMMENT ON COLUMN sa.table_query.prompt_ind IS 'Indicates whether the query uses a run-time prompt; i.e., 0=no prompt, 1=prompt, default=0';
COMMENT ON COLUMN sa.table_query.prompt_ind_st IS 'Translates prompt_ind';
COMMENT ON COLUMN sa.table_query.description IS 'Description of the query. Used only by Billing Manager';
COMMENT ON COLUMN sa.table_query.dev IS 'Row version number for mobile distribution purposes';