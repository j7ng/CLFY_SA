CREATE OR REPLACE FORCE VIEW sa.view_inv_bin (objid,bin_name,location_name,"ACTIVE",gl_acct_no,inv_class,prior_active,dev,inv_bin2inv_locatn) AS
SELECT "OBJID","BIN_NAME","LOCATION_NAME","ACTIVE","GL_ACCT_NO","INV_CLASS","PRIOR_ACTIVE","DEV","INV_BIN2INV_LOCATN" FROM TABLE_INV_BIN
 ;