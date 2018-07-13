CREATE OR REPLACE FORCE VIEW sa.table_qry_owner (objid,title,owner_objid,owner_login,s_owner_login,obj_type,view_type,default_val,stored_prc_name,sql_statement,keyword_mode,order_val,shared_pers,shared_pers_st,prompt_ind,prompt_ind_st) AS
select table_query.objid, table_query.title,
 table_user.objid, table_user.login_name, table_user.S_login_name,
 table_query.obj_type, table_query.view_type,
 table_query.default_val, table_query.stored_prc_name,
 table_query.sql_statement, table_query.keyword_mode,
 table_query.order_val, table_query.shared_pers,
 table_query.shared_pers_st, table_query.prompt_ind,
 table_query.prompt_ind_st
 from table_query, table_user
 where table_user.objid = table_query.query2user
 ;
COMMENT ON TABLE sa.table_qry_owner IS 'View for query owner. Used by forms Query-Logistics (570), Query (804), Define Query Icon (809) and Query (9130)';
COMMENT ON COLUMN sa.table_qry_owner.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_qry_owner.title IS 'Name of the query';
COMMENT ON COLUMN sa.table_qry_owner.owner_objid IS 'Query owner s objid';
COMMENT ON COLUMN sa.table_qry_owner.owner_login IS 'Query owner s login';
COMMENT ON COLUMN sa.table_qry_owner.obj_type IS 'Object type ID the query is for; e.g., case=0, solution=1, subcase=24, change request=192';
COMMENT ON COLUMN sa.table_qry_owner.view_type IS 'Schema view being used for query; differs based on object type';
COMMENT ON COLUMN sa.table_qry_owner.default_val IS 'Indicates whether the query invokes properties, keyphrases, or both';
COMMENT ON COLUMN sa.table_qry_owner.stored_prc_name IS 'Reserved for the name of the stored procedure for this query';
COMMENT ON COLUMN sa.table_qry_owner.sql_statement IS 'SQL code created based on parameters entered by user for this query';
COMMENT ON COLUMN sa.table_qry_owner.keyword_mode IS 'If using keywords, match All or Any';
COMMENT ON COLUMN sa.table_qry_owner.order_val IS 'Ascending or descending sort criteria';
COMMENT ON COLUMN sa.table_qry_owner.shared_pers IS 'Indicates whether the query is shareable with users other than the originator; i.e., 0=private, 1=shareable, default=0';
COMMENT ON COLUMN sa.table_qry_owner.shared_pers_st IS 'Translates shared_pers';
COMMENT ON COLUMN sa.table_qry_owner.prompt_ind IS '0=no prompt, 1=prompt';
COMMENT ON COLUMN sa.table_qry_owner.prompt_ind_st IS 'Translates prompt_ind';