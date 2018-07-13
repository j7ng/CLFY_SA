CREATE OR REPLACE PROCEDURE sa."SP_INBOUND_FINCUSTOMER_PRC" IS
/********************************************************************************/
/* Copyright ? 2001 Tracfone Wireless Inc. All rights reserved */
/* */
/* Name : sp_inbound_customer_prc.sql */
/* Purpose : To populate the new Retailer ID and Name from Oracle */
/* Financial and it will insert/update Clarify/TOSS system */
/* Parameters : NONE */
/* Platforms : Oracle 8.0.6 AND newer versions */
/* Author : Ravi Kant Choudhary */
/* Tracfone */
/* Date : JULY 19,2001 */
/* Revisions : Version Date Who Purpose */
/* ------- -------- ------- ------------------------------ */
/* 1.0 07/19/03 Ravi Initial Version */
/* 1.1 04/10/03 SL Clarify Upgrade - sequence */
/* 1.2 06/04/03 SL Bug fix -- open cursor and */
/* ora-164 */
/* */
/* New CVS Versions */
/* Version Date Who Purpose */
/* ------- ---------- ------- ------------------------------------------------------------*/
/* 1.2 03/18/2011 KACOSTA CR12341 POSA Flag for Straight Talk Activation */
/* Added code to insert into X_POSA_FLAG_DEALER */
/* 1.3 03/21/2011 KACOSTA CR12341 POSA Flag for Straight Talk Activation */
/* Modified procedure to handle 2 POSA flags from OFS */
/* 1.4 03/21/2011 KACOSTA CR12341 POSA Flag for Straight Talk Activation */
/* Modified procedure to not update existing customer */
/* if the flags are null */
/* 1.5 03/29/2011 KACOSTA CR12341 POSA Flag for Straight Talk Activation */
/* Modified procedure to handle 1 POSA flags from OFS */
/* 1.6 08/10/2011 KACOSTA CR12341 POSA Flag for Straight Talk Activation */
/* OFS changed the column name from POSA_FLAG to POSA_DEALER */
/* 1.7 08/10/2011 KACOSTA CR12341 POSA Flag for Straight Talk Activation */
/* OFS changed the column name from POSA_DEALER to DEALER_TYPE */
/*********************************************************************************************/
logfile_handle UTL_FILE.FILE_TYPE;
var_in_site NUMBER :=0;
var_up_site NUMBER :=0;
--Start CR12341 KACOSTA 03/21/2011
--CURSOR cur_intf_cust IS SELECT CUSTOMER_ID CUST_ID,
-- CUSTOMER_NAME CUST_NAME,
-- 'RSEL' CUST_TYPE
-- FROM APPS.AR_CUSTOMERS@ofsprd
-- WHERE STATUS = 'A'
-- UNION
-- SELECT vendor_id CUST_ID,
-- vendor_name CUST_NAME,
-- DECODE(vendor_type_lookup_code,'FF','DIST','MANUFACTURER','MANF') CUST_TYPE
-- FROM APPS.po_vendors@ofsprd
-- WHERE vendor_type_lookup_code IN ('FF','MANUFACTURER');
 CURSOR cur_intf_cust IS
 SELECT   customer_id cust_id
         ,customer_name cust_name
         ,customer_number acct_number
         ,CASE
         WHEN (customer_class_code = 'FF') THEN
         'DIST'
         WHEN (customer_class_code = 'MANUFACTURER') THEN
         'MANF'
         ELSE
         'RSEL'
         END cust_type
         ,NVL(dealer_type,'N') posa_dealer
         ,customer_class_code CLASS_CODE --CR29223
         ,ship_to_id
 FROM   tf.tf_customers_v@ofsprd
 WHERE  NVL(customer_class_code,'RSEL') IN ( 'RSEL'
                                           ,'FF'
                                           ,'MANUFACTURER'
                                           ,'TRADE'
                                           ,'CARRIER'
                                           ,'CUNA'
                                           ,'SM_MA' -- added for SM
                                           ,'B2B','B2C'
                                           ,'BAR' -- CR24029 Added TracFone brand retailers
										   ,'HMO'    -- Changes starts as part of CR49886
										   ,'LIFELINE'
										   ,'NE_BAR'
										   ,'SAFELINK'
										   ,'TER'
										   ,'GRASSROOTS'
										   ,'TV CHANNEL' -- Changes ends as part of CR49886
										   );
 --End CR12341 KACOSTA 03/21/2011
cur_intf_cust_rec cur_intf_cust%ROWTYPE;
 --Start CR12341 KACOSTA 03/21/2011
 CURSOR get_x_posa_flag_dealer_cur(cur_customer_id x_posa_flag_dealer.customer_id%TYPE) IS
 SELECT 1
 FROM x_posa_flag_dealer
 WHERE customer_id = cur_customer_id;
 get_x_posa_flag_dealer_rec get_x_posa_flag_dealer_cur%ROWTYPE;
 --End CR12341 KACOSTA 03/21/2011
-- Select Name from Table Site based on Customer ID
CURSOR cur_site (c_customer_id IN VARCHAR2) IS
SELECT a.ROWID, a.*
FROM TABLE_SITE a
WHERE a.x_fin_cust_id = c_customer_id
and a.type = 3;
cur_site_rec cur_site%ROWTYPE;
-- Create site objid sequence
/* 06/04/03 CURSOR cur_site_seq IS
-- 04/10/03 SELECT seq_site.NEXTVAL +(POWER(2,28)) seq FROM dual;
select sa.seq('site') seq from dual;
cur_site_seq_rec cur_site_seq%ROWTYPE; */
v_site_seq number; -- 06/04/03
-- cursor used to generate objid for table_inv_locatn records
/* 06/04/03 CURSOR get_inv_locatn_seq IS
-- 04/10/03 SELECT seq_inv_locatn.NEXTVAL+(POWER(2,28)) val FROM dual;
select sa.seq('inv_locatn') val from dual;
seq_inv_locatn_rec get_inv_locatn_seq%ROWTYPE; */
v_inv_locatn_seq number; --06/04/03
-- cursor used to generate objid for table_inv_role records
/* 06/04/03 CURSOR get_inv_role_seq IS
-- 04/10/03 SELECT seq_inv_role.NEXTVAL+(POWER(2,28)) val FROM dual;
select sa.seq('inv_role') val from dual;
seq_inv_role_rec get_inv_role_seq%ROWTYPE; */
v_inv_role_seq number; --06/04/03
-- cursor used to generate objid for table_inv_bin records
/* 06/04/03 CURSOR get_inv_bin_seq IS
-- 04/10/03 SELECT seq_inv_bin.NEXTVAL+(POWER(2,28)) val FROM dual;
select sa.seq('inv_bin') val from dual;
seq_inv_bin_rec get_inv_bin_seq%ROWTYPE; */
v_inv_bin_seq number; --06/04/03
seq_site_id_value NUMBER;
v_error_text VARCHAR2(1000);
sql_code NUMBER;
sql_err VARCHAR2(30);
side_id_count NUMBER;
BEGIN
FOR cur_intf_cust_rec IN cur_intf_cust LOOP
OPEN cur_site(cur_intf_cust_rec.cust_id);
FETCH cur_site INTO cur_site_rec;
BEGIN
IF cur_site%FOUND THEN
IF cur_site_rec.name != cur_intf_cust_rec.cust_name
OR cur_site_rec.site_type != cur_intf_cust_rec.cust_type THEN
/* -- Commented as per request from Muhammad Nazir
UPDATE TABLE_SITE
SET name = cur_intf_cust_rec.cust_name,
s_name = UPPER(cur_intf_cust_rec.cust_name),
type in (3,5),
site_type = cur_intf_cust_rec.cust_type
WHERE ROWID = cur_site_rec.ROWID;
var_up_site := var_up_site + 1;
*/
var_up_site := var_up_site + 1;
NULL;
ELSE
NULL;
END IF;
 -- CR12341 Start KACOSTA 03/21/2011
 IF (cur_intf_cust_rec.posa_dealer = 'Y') THEN
 --
 IF get_x_posa_flag_dealer_cur%ISOPEN THEN
 --
 CLOSE get_x_posa_flag_dealer_cur;
 --
 END IF;
 --
 OPEN get_x_posa_flag_dealer_cur(cur_customer_id => cur_intf_cust_rec.cust_id);
 FETCH get_x_posa_flag_dealer_cur
 INTO get_x_posa_flag_dealer_rec;
 --
 IF get_x_posa_flag_dealer_cur%NOTFOUND THEN
 --
 INSERT INTO x_posa_flag_dealer
 (retailer
 ,acct#
 ,customer_id
 ,site_id
 ,posa_airtime
 ,posa_phone)
 VALUES
 (cur_intf_cust_rec.cust_name
 ,cur_intf_cust_rec.acct_number
 ,cur_intf_cust_rec.cust_id
 ,cur_site_rec.site_id
 ,'N'
 ,'N');
 --
 END IF;
 --
 CLOSE get_x_posa_flag_dealer_cur;
 --
 END IF;
 -- CR12341 End KACOSTA 03/21/2011
ELSE
/* 06/04/03 OPEN cur_site_seq;
FETCH cur_site_seq INTO cur_site_seq_rec;
CLOSE cur_site_seq;
OPEN get_inv_locatn_seq;
FETCH get_inv_locatn_seq INTO seq_inv_locatn_rec;
CLOSE get_inv_locatn_seq;
OPEN get_inv_role_seq;
FETCH get_inv_role_seq INTO seq_inv_role_rec;
CLOSE get_inv_role_seq;
OPEN get_inv_bin_seq;
FETCH get_inv_bin_seq INTO seq_inv_bin_rec;
CLOSE get_inv_bin_seq; */
-- 06/04/03
sp_seq('site', v_site_seq);
sp_seq('inv_locatn', v_inv_locatn_seq);
sp_seq('inv_role',v_inv_role_seq);
sp_seq('inv_bin',v_inv_bin_seq);
-- Get the next site_id from sequence and also the check the uniqueness of site_id in table table_site.
LOOP
SELECT seq_site_id.NEXTVAL INTO seq_site_id_value FROM dual;
side_id_count := 0;
SELECT COUNT(*) INTO side_id_count
FROM sa.TABLE_SITE
WHERE site_id = TO_CHAR(seq_site_id_value);
IF side_id_count >= 1 THEN
-- dbms_output.put_line('Matched');
-- If value is more then one it means, this site_id is already exist. Generate the next site_id from sequence
-- and check the uniqueness of site_id in table table_site.
NULL;
ELSE
-- dbms_output.put_line('Un Matched');
EXIT; -- Exit from current loop
END IF;
END LOOP;
INSERT INTO TABLE_SITE (objid,
status,
site_id,
name,
s_name,
type,
site_type,
APPL_TYPE, -- CR29223
x_ship_loc_id, -- CR47779
x_fin_cust_id)
VALUES ( --06/04/03 cur_site_seq_rec.seq,
v_site_seq,
0,
seq_site_id_value,
cur_intf_cust_rec.cust_name,
UPPER(cur_intf_cust_rec.cust_name),
3,
cur_intf_cust_rec.cust_type,
DECODE (cur_intf_cust_rec.CLASS_CODE, 'CUNA','CUNA',NULL),--CR29223
cur_intf_cust_rec.ship_to_id, -- CR47779
cur_intf_cust_rec.cust_id);
INSERT INTO TABLE_INV_LOCATN( objid,
active,
location_type,
location_name,
inv_locatn2site)
VALUES( -- 06/04/03 seq_inv_locatn_rec.val,
v_inv_locatn_seq,
1,
'Inventory Location',
seq_site_id_value,
--cur_site_seq_rec.seq
v_site_seq);
INSERT INTO TABLE_INV_ROLE( objid,
active,
focus_type,
inv_role2site,
inv_role2inv_locatn,
role_name )
VALUES( --06/04/03 seq_inv_role_rec.val,
v_inv_role_seq,
1,
228,
-- 06/04/03 cur_site_seq_rec.seq,
v_site_seq,
-- 06/04/03 seq_inv_locatn_rec.val,
v_inv_locatn_seq,
'Located at');
INSERT INTO TABLE_INV_BIN( objid,
active,
bin_name,
location_name,
inv_bin2inv_locatn )
VALUES( -- 06/04/03seq_inv_bin_rec.val,
v_inv_bin_seq,
1,
seq_site_id_value,
seq_site_id_value,
-- 06/04/03 seq_inv_locatn_rec.val
v_inv_locatn_seq);
 -- CR12341 Start KACOSTA 03/21/2011
 IF (cur_intf_cust_rec.posa_dealer = 'Y') THEN
 --
 INSERT INTO x_posa_flag_dealer
 (retailer
 ,acct#
 ,customer_id
 ,site_id
 ,posa_airtime
 ,posa_phone)
 VALUES
 (cur_intf_cust_rec.cust_name
 ,cur_intf_cust_rec.acct_number
 ,cur_intf_cust_rec.cust_id
 ,seq_site_id_value
 ,'N'
 ,'N');
 --
 END IF;
 -- CR12341 End KACOSTA 03/21/2011
var_in_site := var_in_site + 1;
END IF;
CLOSE cur_site;
EXCEPTION
WHEN OTHERS THEN
--06/04/03
if cur_site%isopen then
close cur_site;
end if;
sql_code := SQLCODE;
sql_err := SQLERRM;
v_error_text := 'Error in Exception Part, SQL Error Code : '||TO_CHAR(sql_code)||' Error Message : '||sql_err;
INSERT INTO sa.ERROR_TABLE (ERROR_TEXT,
ERROR_DATE,
PROGRAM_NAME)
VALUES (v_error_text,
SYSDATE,
'SP_INBOUND_CUSTOMER_PROC');
END;
END LOOP;
COMMIT;
END sp_inbound_fincustomer_prc;
/