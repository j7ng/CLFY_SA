CREATE OR REPLACE FORCE VIEW sa.table_case_attch (objid,attchid,title,"PATH") AS
select table_doc_inst.doc_inst2case, table_doc_inst.objid,
 table_doc_inst.title, table_doc_path.path
 from table_doc_inst, table_doc_path
 where table_doc_inst.doc_inst2case IS NOT NULL
 AND table_doc_path.objid = table_doc_inst.attach_info2doc_path
 ;
COMMENT ON TABLE sa.table_case_attch IS 'Field in the view that identifies the parent';
COMMENT ON COLUMN sa.table_case_attch.objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_case_attch.attchid IS 'Doc_inst internal record number';
COMMENT ON COLUMN sa.table_case_attch.title IS 'Document title';
COMMENT ON COLUMN sa.table_case_attch."PATH" IS 'Path and file name of the attachment';