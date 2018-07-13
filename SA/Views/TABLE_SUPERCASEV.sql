CREATE OR REPLACE FORCE VIEW sa.table_supercasev (objid,contact_objid,clarify_state,id_number,title,s_title,age,"CONDITION",s_condition,status,s_status,last_name,s_last_name,first_name,s_first_name,creation_time,location_objid,is_supercase) AS
select table_case.objid, table_contact.objid,
 table_condition.condition, table_case.id_number,
 table_case.title, table_case.S_title, table_condition.wipbin_time,
 table_condition.title, table_condition.S_title, table_gbst_elm.title, table_gbst_elm.S_title,
 table_contact.last_name, table_contact.S_last_name, table_contact.first_name, table_contact.S_first_name,
 table_case.creation_time, table_case.case_reporter2site,
 table_case.is_supercase
 from table_case, table_contact, table_condition,
  table_gbst_elm
 where table_condition.objid = table_case.case_state2condition
 AND table_contact.objid = table_case.case_reporter2contact
 AND table_gbst_elm.objid = table_case.casests2gbst_elm
 AND table_case.case_reporter2site IS NOT NULL
 ;
COMMENT ON TABLE sa.table_supercasev IS 'Used for the super cases selection. Used by Case Window (420, 776), Previous Cases (421), Edit Case Site/Contact Info (765), New Case (411,775), Select Parent Case (424)';
COMMENT ON COLUMN sa.table_supercasev.objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_supercasev.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_supercasev.clarify_state IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_supercasev.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_supercasev.title IS 'Case or service call title; summary of case details';
COMMENT ON COLUMN sa.table_supercasev.age IS 'Date and time task was accepted into WIPbin';
COMMENT ON COLUMN sa.table_supercasev."CONDITION" IS 'Title of condition';
COMMENT ON COLUMN sa.table_supercasev.status IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_supercasev.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_supercasev.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_supercasev.creation_time IS 'The date and time the case was created';
COMMENT ON COLUMN sa.table_supercasev.location_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_supercasev.is_supercase IS 'Flag if the case is a super case';