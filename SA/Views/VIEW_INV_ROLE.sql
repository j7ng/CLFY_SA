CREATE OR REPLACE FORCE VIEW sa.view_inv_role (objid,role_name,focus_type,"ACTIVE","RANK",dev,inv_role2inv_locatn,inv_role2site) AS
SELECT "OBJID","ROLE_NAME","FOCUS_TYPE","ACTIVE","RANK","DEV","INV_ROLE2INV_LOCATN","INV_ROLE2SITE" FROM TABLE_INV_ROLE
;