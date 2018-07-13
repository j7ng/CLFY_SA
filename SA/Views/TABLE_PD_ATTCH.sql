CREATE OR REPLACE FORCE VIEW sa.table_pd_attch (objid,attchid,title,"PATH") AS
select table_workaround.workaround2probdesc, table_doc_inst.objid,
 table_doc_inst.title, table_doc_path.path
 from table_workaround, table_doc_inst, table_doc_path
 where table_workaround.workaround2probdesc IS NOT NULL
 AND table_workaround.objid = table_doc_inst.attachment2workaround
 AND table_doc_path.objid = table_doc_inst.attach_info2doc_path
 ;
COMMENT ON TABLE sa.table_pd_attch IS 'Joins attachment of Resolution (Workaround) of a solution (PD) to its doc_path';
COMMENT ON COLUMN sa.table_pd_attch.objid IS 'Probdesc internal record number';
COMMENT ON COLUMN sa.table_pd_attch.attchid IS 'Doc_inst internal record number';
COMMENT ON COLUMN sa.table_pd_attch.title IS 'Document title';
COMMENT ON COLUMN sa.table_pd_attch."PATH" IS 'Path and file name of the attachment';