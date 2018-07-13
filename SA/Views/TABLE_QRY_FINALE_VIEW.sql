CREATE OR REPLACE FORCE VIEW sa.table_qry_finale_view (objid,title,s_title,clarify_state,"CONDITION",s_condition,"OWNER",s_owner,"CREATION",id_number,rating,hits) AS
select table_probdesc.objid, table_probdesc.title, table_probdesc.S_title,
 table_condition.condition, table_condition.title, table_condition.S_title,
 table_user.login_name, table_user.S_login_name, table_probdesc.creation_time,
 table_probdesc.id_number, table_probdesc.rating,
 table_probdesc.hits
 from table_probdesc, table_condition, table_user
 where table_user.objid = table_probdesc.probdesc_owner2user
 AND table_condition.objid = table_probdesc.probdesc2condition
 ;
COMMENT ON TABLE sa.table_qry_finale_view IS 'Used by form Solutions from Query (813)';
COMMENT ON COLUMN sa.table_qry_finale_view.objid IS 'Probdesc internal record number';
COMMENT ON COLUMN sa.table_qry_finale_view.title IS 'Solution title -describes main details of the solution';
COMMENT ON COLUMN sa.table_qry_finale_view.clarify_state IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_qry_finale_view."CONDITION" IS 'Title of condition';
COMMENT ON COLUMN sa.table_qry_finale_view."OWNER" IS 'User login name';
COMMENT ON COLUMN sa.table_qry_finale_view."CREATION" IS 'Date and time the solution was created';
COMMENT ON COLUMN sa.table_qry_finale_view.id_number IS 'Unique ID number for the solution; assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_qry_finale_view.rating IS 'Solution rating';
COMMENT ON COLUMN sa.table_qry_finale_view.hits IS 'Number of times the solution has been linked to a case';