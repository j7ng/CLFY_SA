CREATE OR REPLACE FORCE VIEW sa.table_qry_scasev (elm_objid,id_number,"OWNER",s_owner,status,s_status,title,s_title,site_name,s_site_name,first_name,s_first_name,last_name,s_last_name,is_supercase) AS
select table_case.objid, table_case.id_number,
 table_owner.login_name, table_owner.S_login_name, table_gse_status.title, table_gse_status.S_title,
 table_case.title, table_case.S_title, table_site.name, table_site.S_name,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
 table_case.is_supercase
 from table_gbst_elm table_gse_status, table_user table_owner, table_case, table_site, table_contact
 where table_owner.objid = table_case.case_owner2user
 AND table_gse_status.objid = table_case.casests2gbst_elm
 AND table_contact.objid = table_case.case_reporter2contact
 AND table_site.objid = table_case.case_reporter2site
 ;
COMMENT ON TABLE sa.table_qry_scasev IS 'Used by form Cases Window (420, 776) and New Case (421, 775)';
COMMENT ON COLUMN sa.table_qry_scasev.elm_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_qry_scasev.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_qry_scasev."OWNER" IS 'User login name';
COMMENT ON COLUMN sa.table_qry_scasev.status IS 'Status of the case';
COMMENT ON COLUMN sa.table_qry_scasev.title IS 'Case or service call title; summary of case details';
COMMENT ON COLUMN sa.table_qry_scasev.site_name IS 'Name of the reporting site';
COMMENT ON COLUMN sa.table_qry_scasev.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_qry_scasev.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_qry_scasev.is_supercase IS 'Flag if the case is a super case';