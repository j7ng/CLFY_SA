CREATE OR REPLACE FORCE VIEW sa.table_victimcase (objid,contact_objid,clarify_state,id_number,title,s_title,age,"CONDITION",s_condition,status,s_status,last_name,s_last_name,first_name,s_first_name,creation_time,location_objid,is_supercase,supercase_objid) AS
select table_victimcase.objid, table_contact.objid,
 table_condition.condition, table_victimcase.id_number,
 table_victimcase.title, table_victimcase.S_title, table_condition.wipbin_time,
 table_condition.title, table_condition.S_title, table_gbst_elm.title, table_gbst_elm.S_title,
 table_contact.last_name, table_contact.S_last_name, table_contact.first_name, table_contact.S_first_name,
 table_victimcase.creation_time, table_victimcase.case_reporter2site,
 table_victimcase.is_supercase, table_victimcase.case_victim2case
 from table_case table_victimcase, table_contact, table_condition, table_gbst_elm
 where table_victimcase.case_reporter2site IS NOT NULL
 AND table_condition.objid = table_victimcase.case_state2condition
 AND table_contact.objid = table_victimcase.case_reporter2contact
 AND table_victimcase.case_victim2case IS NOT NULL
 AND table_gbst_elm.objid = table_victimcase.casests2gbst_elm
 ;
COMMENT ON TABLE sa.table_victimcase IS 'Used in the victim cases tab on the Case. Used by forms Case Window (420, 776), Edit Case Site/Contact Info (766) and Linked Child Cases (428)';
COMMENT ON COLUMN sa.table_victimcase.objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_victimcase.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_victimcase.clarify_state IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_victimcase.id_number IS 'Unique victimcase.number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_victimcase.title IS 'Case or service call title; summary of victimcase.details';
COMMENT ON COLUMN sa.table_victimcase.age IS 'Date and time task was accepted into WIPbin';
COMMENT ON COLUMN sa.table_victimcase."CONDITION" IS 'Title of condition';
COMMENT ON COLUMN sa.table_victimcase.status IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_victimcase.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_victimcase.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_victimcase.creation_time IS 'The date and time the victimcase.was created';
COMMENT ON COLUMN sa.table_victimcase.location_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_victimcase.is_supercase IS 'Flag if the case is a super case';
COMMENT ON COLUMN sa.table_victimcase.supercase_objid IS 'Parent super case internal record number';