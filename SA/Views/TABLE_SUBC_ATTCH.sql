CREATE OR REPLACE FORCE VIEW sa.table_subc_attch (objid,attchid,title,"PATH") AS
select table_doc_inst.doc_inst2subcase, table_doc_inst.objid,
 table_doc_inst.title, table_doc_path.path
 from table_doc_inst, table_doc_path
 where table_doc_path.objid = table_doc_inst.attach_info2doc_path
 AND table_doc_inst.doc_inst2subcase IS NOT NULL
 ;
COMMENT ON TABLE sa.table_subc_attch IS 'Joins attachment to its doc_path';
COMMENT ON COLUMN sa.table_subc_attch.objid IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_subc_attch.attchid IS 'Doc_inst internal record number';
COMMENT ON COLUMN sa.table_subc_attch.title IS 'Document title';
COMMENT ON COLUMN sa.table_subc_attch."PATH" IS 'Path and file name of the attachment';