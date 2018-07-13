CREATE OR REPLACE FORCE VIEW sa.table_finale_lst (objid,title,s_title,"OWNER",s_owner,"CREATION",id_number) AS
select table_probdesc.objid, table_probdesc.title, table_probdesc.S_title,
 table_user.login_name, table_user.S_login_name, table_probdesc.creation_time,
 table_probdesc.id_number
 from table_probdesc, table_user
 where table_user.objid = table_probdesc.probdesc_owner2user
 ;
COMMENT ON TABLE sa.table_finale_lst IS 'List of solutions for Select solutions form. Used by form Select solutions (328)';
COMMENT ON COLUMN sa.table_finale_lst.objid IS 'Displays solution unique object ID number';
COMMENT ON COLUMN sa.table_finale_lst.title IS 'Displays solution title';
COMMENT ON COLUMN sa.table_finale_lst."OWNER" IS 'Displays solution owner';
COMMENT ON COLUMN sa.table_finale_lst."CREATION" IS 'Displays solution creation date and time';
COMMENT ON COLUMN sa.table_finale_lst.id_number IS 'Displays solution unique ID number';