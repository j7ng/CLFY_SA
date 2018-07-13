CREATE OR REPLACE FORCE VIEW sa.table_sfa_attch_v (objid,title,deleted,description,keywords,path_objid,"PATH") AS
select table_doc_inst.objid, table_doc_inst.title,
 table_doc_inst.deleted, table_doc_inst.description,
 table_doc_inst.keywords, table_doc_path.objid,
 table_doc_path.path
 from table_doc_inst, table_doc_path
 where table_doc_path.objid = table_doc_inst.attach_info2doc_path
 ;
COMMENT ON TABLE sa.table_sfa_attch_v IS 'Displays an instance of an attachment and its file path. Used by forms Account Mgr (11650) and Lead (11610)';
COMMENT ON COLUMN sa.table_sfa_attch_v.objid IS 'Doc_inst internal record number';
COMMENT ON COLUMN sa.table_sfa_attch_v.title IS 'Document title';
COMMENT ON COLUMN sa.table_sfa_attch_v.deleted IS 'Indicates if document has been deleted. Reserved; future';
COMMENT ON COLUMN sa.table_sfa_attch_v.description IS 'The description of the document';
COMMENT ON COLUMN sa.table_sfa_attch_v.keywords IS 'Keywords for the document; used with FTS';
COMMENT ON COLUMN sa.table_sfa_attch_v.path_objid IS 'Doc_path internal record number';
COMMENT ON COLUMN sa.table_sfa_attch_v."PATH" IS 'Path and file name of the attachment';