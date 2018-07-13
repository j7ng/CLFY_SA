CREATE OR REPLACE PACKAGE BODY sa.account_services_pkg IS
 /*******************************************************************************************************
 --$RCSfile: account_services_pkb.sql,v $
 --$Revision: 1.41 $
 --$Author: ddevaraj $
 --$Date: 2016/01/12 21:10:34 $
 --$ $Log: account_services_pkb.sql,v $
 --$ Revision 1.41  2016/01/12 21:10:34  ddevaraj
 --$ For CR39698
 --$
 --$ Revision 1.40  2015/08/18 14:57:56  pvenkata
 --$ CR34819: Changes for buyers count information added.
 --$
 --$ Revision 1.38 2015/03/16 19:58:59 oarbab
 --$ CR33401 commented out Rollbacks and COMMITs in getaccountsummary
 --$
 --$ Revision 1.37 2015/02/17 14:47:57 oarbab
 --$ CR31683 Fix ESN summary is counting many statuses per ESN
 --$
 --$ Revision 1.36 2015/02/16 14:53:30 oarbab
 --$ CR31683 fix to SOA time out issue.
 --$
 --$ Revision 1.34 2015/02/04 20:25:52 oarbab
 --$ added out_account_summary := l_tab_account_summary;
 --$
 --$ Revision 1.33 2015/02/04 19:31:31 oarbab
 --$ switched getaccountsummary parameter io_account_summary IN OUT typ_account_summary_tbl to out only. new name out_account_summary
 --$
 --$ Revision 1.32 2015/01/28 23:26:31 gsaragadam
 --$ CR31683 Added new i/p parameter Organizationid to getaccountsummary Procedure
 --$
 --$ Revision 1.31 2015/01/23 18:45:43 gsaragadam
 --$ CR31683 Updated Package Body
 --$
 --$ Revision 1.29 2014/08/20 15:31:48 cpannala
 --$ Cr30255 account validation
 --$
 --$ Revision 1.27 2014/07/17 22:42:21 icanavan
 --$ RR CR28212 MERGE WITH PROD B2B
 --$
 --$ Revision 1.26 2014/07/09 18:14:24 cpannala
 --$ Cr29468 changes to getEsnListBycriteria
 --$
 --$ Revision 1.24 2014/06/26 18:38:54 cpannala
 --$ CR29467 To fix TST trasaction issue
 --$
 --$ Revision 1.21 2014/06/06 20:20:46 cpannala
 --$ CR29196 changes made for defect 347
 --$
 --$ Revision 1.1 2013/12/03 cpannala
 --$ CR22623 - B2B Initiative
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/

 PROCEDURE esn_criteria
 (
 io_esn_info IN OUT typ_esn_info_tbl
 ,io_web_objid NUMBER
 ,in_esn VARCHAR2
 ,in_min VARCHAR2
 ,in_order_by_field IN VARCHAR2
 ,in_order_direction IN VARCHAR2 DEFAULT 'ASC'
 ,in_max_rec_number IN NUMBER DEFAULT 25
 ) IS
 v_typ_esn_info_tbl typ_esn_info_tbl := typ_esn_info_tbl();
 v_typ_esn_info_tbl2 typ_esn_info_tbl := typ_esn_info_tbl();
 BEGIN

 IF io_esn_info.count = 0 THEN
 io_esn_info.extend;
 io_esn_info(io_esn_info.last) := sa.typ_esn_info_rec(NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL);
 END IF;
 FOR i IN io_esn_info.first .. io_esn_info.last LOOP
 IF in_esn IS NOT NULL THEN
 io_esn_info(i).esn := in_esn;
 END IF;
 IF in_min IS NOT NULL THEN
 io_esn_info(i).min := in_min;
 END IF;
 SELECT typ_esn_info_rec(pi.part_serial_no
 ,NVL(tsp.x_min
 ,'')
 ,cpi.x_esn_nick_name
 ,(CASE
 WHEN pi.x_part_inst_status IN ('50') THEN
 'NEW'
 WHEN pi.x_part_inst_status IN ('52') THEN
 'ACTIVE'
 ELSE
 'INACTIVE'
 END)
 ,NVL(ct.x_result
 ,'')
 ,wu.login_name
 ,swa.x_account_type
 ,s.s_name
 ,sp.mkt_name
 ,sp.description
 ,pn.part_number) BULK COLLECT
 INTO v_typ_esn_info_tbl
 FROM table_web_user wu
 ,table_x_contact_part_inst cpi
 ,table_part_inst pi
 ,x_site_web_accounts swa
 ,table_site s
 ,table_inv_bin ib
 ,x_service_plan sp
 ,table_site_part tsp
 ,x_service_plan_site_part spsp
 ,table_x_call_trans ct
 ,table_part_num pn
 ,table_mod_level ml
 ,table_x_ota_transaction ota
 WHERE wu.web_user2contact = cpi.x_contact_part_inst2contact
 AND wu.objid = swa.site_web_acct2web_user
 AND swa.site_web_acct2site = s.objid
 AND s.site_id = ib.bin_name
 AND pi.x_part_inst2site_part = tsp.objid(+)
 AND cpi.x_contact_part_inst2part_inst = pi.objid
 AND tsp.objid = spsp.table_site_part_id(+)
 AND spsp.x_service_plan_id = sp.objid(+)
 AND tsp.objid = ct.call_trans2site_part(+)
 AND ct.objid = ota.x_ota_trans2x_call_trans(+)
 AND pi.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid
 AND wu.web_user2bus_org = pn.part_num2bus_org
 AND wu.objid = io_web_objid
 AND pi.x_domain = 'PHONES'
 AND 1 = CASE
 WHEN io_esn_info(i).esn IS NULL
 OR io_esn_info(i).esn = pi.part_serial_no THEN
 1
 ELSE
 0
 END
 AND 1 = CASE
 WHEN io_esn_info(i).min IS NULL
 OR io_esn_info(i).min = tsp.x_min THEN
 1
 ELSE
 0
 END
 AND 1 = CASE
 WHEN UPPER(io_esn_info(i).esn_status) IS NULL
 OR UPPER(io_esn_info(i).esn_status) = DECODE(pi.x_part_inst_status
 ,'50'
 ,'NEW'
 ,'52'
 ,'ACTIVE'
 ,'INACTIVE') THEN
 1
 ELSE
 0
 END
 AND 1 = CASE
 WHEN io_esn_info(i).nick_name IS NULL
 OR UPPER(io_esn_info(i).nick_name) = UPPER(cpi.x_esn_nick_name) THEN
 1
 ELSE
 0
 END
 AND 1 = CASE
 WHEN io_esn_info(i).org_name IS NULL
 OR UPPER(io_esn_info(i).org_name) = s.s_name THEN
 1
 ELSE
 0
 END
 AND 1 = CASE
 WHEN io_esn_info(i).plan_name IS NULL
 OR io_esn_info(i).plan_name = sp.mkt_name THEN
 1
 ELSE
 0
 END
 AND 1 = CASE
 WHEN io_esn_info(i).buyer_type IS NULL
 OR io_esn_info(i).buyer_type = swa.x_account_type THEN
 1
 ELSE
 0
 END
 AND 1 = CASE
 WHEN io_esn_info(i).buyer_id IS NULL
 OR io_esn_info(i).buyer_id = wu.login_name THEN
 1
 ELSE
 0
 END
 AND 1 = CASE
 WHEN io_esn_info(i).ota_flag IS NULL
 OR io_esn_info(i).ota_flag = ct.x_result THEN
 1
 ELSE
 0
 END
 AND 1 = CASE
 WHEN io_esn_info(i).plan_desc IS NULL
 OR io_esn_info(i).plan_desc = sp.description THEN
 1
 ELSE
 0
 END
 AND 1 = CASE
 WHEN io_esn_info(i).esn_part_number IS NULL
 OR io_esn_info(i).esn_part_number = pn.part_number THEN
 1
 ELSE
 0
 END
 AND ROWNUM <= NVL(in_max_rec_number
 ,25);

 v_typ_esn_info_tbl2 := v_typ_esn_info_tbl MULTISET UNION v_typ_esn_info_tbl2;
 END LOOP;
 EXECUTE IMMEDIATE 'select cast ( multiset( select distinct * from table( :v_typ_esn_info_tbl2 )t
 order by ' || NVL(in_order_by_field
 ,'ESN') || ' ' || in_order_direction || ') as typ_esn_info_tbl)
 from dual'
 INTO io_esn_info
 USING v_typ_esn_info_tbl2;

 END;

 PROCEDURE getesnlistbycriterias
 (
 in_login_name IN table_web_user.login_name%TYPE
 ,in_bus_org IN VARCHAR2
 ,in_esn IN table_part_inst.part_serial_no%TYPE DEFAULT NULL
 ,in_min IN table_site_part.x_min%TYPE DEFAULT NULL
 ,io_esn_info IN OUT typ_esn_info_tbl
 ,in_order_by_field IN VARCHAR2
 ,in_order_direction IN VARCHAR2 DEFAULT 'ASC'
 ,in_start_idx IN BINARY_INTEGER DEFAULT 0
 ,in_max_rec_number IN NUMBER DEFAULT 25
 ,out_err_num OUT NUMBER
 ,out_err_msg OUT VARCHAR2
 ) IS
 esn_wu_objid NUMBER;
 wu_objid NUMBER;
 bo_objid NUMBER;
 boobjid NUMBER;
 brand VARCHAR2(40);
 l_commerce_id VARCHAR2(50);

 CURSOR org_cur(commerce_id VARCHAR2) IS

 SELECT site_web_acct2web_user web_user
 FROM x_site_web_accounts
 WHERE site_web_acct2site IN (SELECT objid
 FROM table_site
 WHERE LEVEL >= 1
 START WITH x_commerce_id = commerce_id
 CONNECT BY NOCYCLE PRIOR objid = child_site2site);

 org_rec org_cur%ROWTYPE;
 l_typ_esn_info_tbl1 typ_esn_info_tbl := typ_esn_info_tbl();
 l_typ_esn_info_tbl2 typ_esn_info_tbl := typ_esn_info_tbl();
 BEGIN
 b2b_pkg.get_esn_web_user(in_login_name
 ,in_bus_org
 ,in_esn
 ,in_min
 ,wu_objid
 ,esn_wu_objid
 ,boobjid
 ,out_err_num
 ,out_err_msg);
 BEGIN
 SELECT ts.x_commerce_id
 INTO l_commerce_id
 FROM x_site_web_accounts swa
 ,table_site ts
 WHERE ts.objid = swa.site_web_acct2site
 AND x_account_type = 'BUYERADMIN'
 AND swa.site_web_acct2web_user = wu_objid; -- 580930491
 EXCEPTION
 WHEN no_data_found THEN
 esn_criteria(io_esn_info
 , --in out typ_esn_info_tbl,
 NVL(wu_objid
 ,esn_wu_objid)
 , --number,
 in_esn
 , --varchar2,
 in_min
 , --varchar2,
 in_order_by_field
 , -- In Varchar2,
 in_order_direction
 , --In Varchar2 Default 'ASC',
 in_max_rec_number); -- In Number Default 25)
 WHEN others THEN
 out_err_num := -1;
 out_err_msg := 'Error Occured In Org Selection';
 RETURN;
 END;
 IF l_commerce_id IS NOT NULL THEN

 FOR org_rec IN org_cur(l_commerce_id) LOOP

 l_typ_esn_info_tbl1 := io_esn_info;
 esn_criteria(l_typ_esn_info_tbl1
 , --in out typ_esn_info_tbl,
 io_web_objid => org_rec.web_user
 , --number,
 in_esn => in_esn
 , --varchar2,
 in_min => in_min
 , --varchar2,
 in_order_by_field => in_order_by_field
 , -- In Varchar2,
 in_order_direction => in_order_direction
 , --In Varchar2 Default 'ASC',
 in_max_rec_number => in_max_rec_number); -- In Number Default 25)

 l_typ_esn_info_tbl2 := l_typ_esn_info_tbl1 MULTISET UNION l_typ_esn_info_tbl2;
 END LOOP;
 io_esn_info := l_typ_esn_info_tbl2;
 END IF;

 IF out_err_num IS NULL THEN
 out_err_num := 0;
 out_err_msg := 'Success';
 END IF;
 --
 EXCEPTION
 WHEN others THEN
 --
 out_err_num := SQLCODE;
 out_err_msg := SUBSTR(SQLERRM
 ,1
 ,300);
 util_pkg.insert_error_tab_proc(ip_action => TO_CHAR(out_err_num)
 ,ip_key => in_login_name
 ,ip_program_name => 'SA.account_services_pkg.GetESNListByCriterias'
 ,ip_error_text => out_err_msg);
 --

 END getesnlistbycriterias;
 ----
 PROCEDURE addesntoaccount
 (
 in_esn IN table_part_inst.part_serial_no%TYPE
 ,in_login_name IN table_web_user.login_name%TYPE
 ,in_org_id IN VARCHAR2
 , --brand
 in_sourcesystem IN VARCHAR2
 ,out_err_num OUT VARCHAR2
 ,out_err_msg OUT VARCHAR2
 ) IS
 --V_Debug VARCHAR2(250);
 bo_objid NUMBER;
 pi_objid NUMBER;
 wu_objid NUMBER;
 wu_contact NUMBER;
 another_acct NUMBER := 0;
 esn_ib_objid NUMBER;
 ib_objid NUMBER;
 boobjid NUMBER;
 brand VARCHAR2(40);
 -------------------------------------------------------------------------
 PROCEDURE insert_contact_pi
 (
 p_contact_objid IN NUMBER
 ,p_esn_objid IN NUMBER
 ) IS
 -------------------------------------------------------------------------
 BEGIN
 -- REM INSERTING into TABLE_X_CONTACT_PART_INST
 INSERT INTO table_x_contact_part_inst
 (objid
 ,x_contact_part_inst2contact
 ,x_contact_part_inst2part_inst
 ,x_esn_nick_name
 ,x_is_default
 ,x_transfer_flag
 ,x_verified)
 VALUES
 ((sa.seq('x_contact_part_inst'))
 ,p_contact_objid
 ,p_esn_objid
 ,NULL
 ,1
 ,NULL
 ,NULL);
 END;
 -----
 BEGIN
 IF in_esn IS NULL
 OR in_org_id IS NULL
 OR in_login_name IS NULL THEN
 out_err_num := -1;
 out_err_msg := 'Required Input Parameters Missing';
 RETURN;
 END IF;
 BEGIN
 SELECT bo.objid
 ,bo.org_id
 INTO boobjid
 ,brand
 FROM table_part_num pn
 ,table_mod_level ml
 ,table_part_inst pi
 ,table_bus_org bo
 WHERE 1 = 1
 AND ml.part_info2part_num = pn.objid
 AND pi.n_part_inst2part_mod = ml.objid
 AND pi.part_serial_no = in_esn
 AND pn.part_num2bus_org = bo.objid;
 EXCEPTION
 WHEN others THEN
 out_err_num := -1;
 out_err_msg := 'Selecting Bus_Org Of Given ESN' || SUBSTR(SQLERRM
 ,1
 ,300);
 RETURN;
 END;
 BEGIN
 SELECT objid
 INTO bo_objid
 FROM table_bus_org
 WHERE org_id = in_org_id;
 EXCEPTION
 WHEN others THEN
 out_err_num := -1;
 out_err_msg := 'Selecting Bus_Org ' || SUBSTR(SQLERRM
 ,1
 ,300);
 RETURN;
 END;
 ----
 IF bo_objid = boobjid THEN
 NULL;
 ELSE
 out_err_num := -1;
 out_err_msg := 'Esn Brand Is Not NET10 ' || SUBSTR(SQLERRM
 ,1
 ,300);
 RETURN;
 END IF;
 -----
 BEGIN
 SELECT wu.objid
 ,wu.web_user2contact
 INTO wu_objid
 ,wu_contact
 FROM table_web_user wu
 WHERE wu.s_login_name = UPPER(in_login_name)
 AND wu.web_user2bus_org = bo_objid;
 EXCEPTION
 WHEN others THEN
 out_err_num := -1;
 out_err_msg := 'Selecting Myacct ' || SUBSTR(SQLERRM
 ,1
 ,300);
 RETURN;
 END;
 -----
 BEGIN
 SELECT objid
 ,part_inst2inv_bin
 INTO pi_objid
 ,esn_ib_objid
 FROM table_part_inst pi
 WHERE pi.part_serial_no = in_esn;
 EXCEPTION
 WHEN others THEN
 out_err_num := -1;
 out_err_msg := 'Selecting ESN' || SUBSTR(SQLERRM
 ,1
 ,300);
 RETURN;
 END;
 ---
 BEGIN
 SELECT wu.objid --inv_bin_objid
 INTO ib_objid
 FROM table_web_user wu
 ,table_x_contact_part_inst cpi
 ,x_site_web_accounts swa
 WHERE wu.web_user2contact = cpi.x_contact_part_inst2contact
 AND wu.objid = swa.site_web_acct2web_user
 AND wu.objid = wu_objid
 AND cpi.x_contact_part_inst2part_inst = pi_objid;
 IF ib_objid IS NOT NULL THEN
 out_err_num := -3;
 out_err_msg := 'ESN Already Attached To The Same Account';
 util_pkg.insert_error_tab_proc(ip_action => TO_CHAR(out_err_num)
 ,ip_key => in_login_name
 ,ip_program_name => 'SA.account_services_pkg.ADDESNTOACCOUNT'
 ,ip_error_text => out_err_msg);
 RETURN;
 END IF;
 EXCEPTION
 WHEN too_many_rows THEN
 out_err_num := -3;
 out_err_msg := 'ESN Attached To Another Account';
 util_pkg.insert_error_tab_proc(ip_action => TO_CHAR(out_err_num)
 ,ip_key => in_login_name
 ,ip_program_name => 'account_services_pkg.ADDESNTOACCOUNT'
 ,ip_error_text => out_err_msg);
 RETURN;
 WHEN no_data_found THEN
 BEGIN
 SELECT COUNT(*)
 INTO another_acct
 FROM table_web_user wu
 ,table_x_contact_part_inst cpi
 WHERE wu.web_user2contact = cpi.x_contact_part_inst2contact
 AND wu.objid = wu_objid
 AND cpi.x_contact_part_inst2part_inst = pi_objid;

 IF another_acct > 0 THEN
 out_err_num := -1;
 out_err_msg := 'ESN Associated To Another Account ' || SUBSTR(SQLERRM
 ,1
 ,300);
 util_pkg.insert_error_tab_proc(ip_action => TO_CHAR(out_err_num)
 ,ip_key => in_login_name
 ,ip_program_name => 'account_services_pkg.ADDESNTOACCOUNT'
 ,ip_error_text => out_err_msg);
 RETURN;
 ELSE
 insert_contact_pi(wu_contact
 ,pi_objid);
 END IF;
 END;
 END;
 IF out_err_num IS NULL THEN
 out_err_num := 0;
 out_err_msg := 'Success';
 END IF;
 ---
 EXCEPTION
 WHEN others THEN
 --
 out_err_num := SQLCODE;
 out_err_msg := SUBSTR(SQLERRM
 ,1
 ,300);
 util_pkg.insert_error_tab_proc(ip_action => TO_CHAR(out_err_num)
 ,ip_key => in_login_name
 ,ip_program_name => 'account_services_pkg.ADDESNTOACCOUNT'
 ,ip_error_text => out_err_msg);
 END addesntoaccount;
 PROCEDURE validate_plan
 (
 p_service_plan_id IN x_service_plan.objid%TYPE
 ,p_org_id IN table_bus_org.org_id%TYPE
 ,op_billing_plan_id OUT NUMBER
 ,op_is_unlimited OUT NUMBER
 , --- 1 or 0
 op_er_cd OUT NUMBER
 ,op_msg OUT VARCHAR2
 ) IS
 /*--------------------------------------------------------------------------*/
 /* */
 /* Name : VALIDATE_NT_PLAN_PRC */
 /* */
 /* Purpose : This procedures provides the corresponding Billing */
 /* plan from the service plan for NET10 */
 /* */
 /* Author : Adasgupta */
 /* */
 /* Date : 05-21-2014 */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------- ---------- ----- ------------------------------------ */
 /* 1.0 05-21-2014 Adasgupta Initial Version */
 /*--------------------------------------------------------------------------*/

 CURSOR plan_cur IS
 SELECT pp.objid
 ,DECODE(NVL(pn.x_redeem_units
 ,1)
 ,0
 ,1
 ,0) unl
 FROM mtm_sp_x_program_param mtm
 ,x_program_parameters pp
 ,x_service_plan sp
 ,table_part_num pn
 ,table_bus_org bo
 WHERE 1 = 1
 AND sp.objid = p_service_plan_id
 AND bo.org_id = p_org_id
 AND bo.objid = pp.prog_param2bus_org
 AND pp.x_is_recurring = 1
 AND mtm.x_sp2program_param = pp.objid
 AND mtm.program_para2x_sp = sp.objid
 AND pn.objid = pp.prog_param2prtnum_monfee
 AND (pp.x_prog_class IS NULL OR pp.x_prog_class = 'SWITCHBASE')
 AND x_program_name NOT LIKE '%B2B'
 AND pp.x_start_date <= SYSDATE -- CR28212 RRS 06/25/2014
 AND pp.x_end_date > SYSDATE;
 plan_rec plan_cur%ROWTYPE;

 BEGIN

 op_er_cd := 0;
 OPEN plan_cur;
 FETCH plan_cur
 INTO plan_rec;

 IF plan_cur%FOUND THEN
 op_is_unlimited := plan_rec.unl; --1 unlimited 0 or other value is limited plan
 op_billing_plan_id := plan_rec.objid;
 ELSE
 op_er_cd := -200;
 op_msg := 'No corresponding Billing Plan';
 op_is_unlimited := 0;
 op_billing_plan_id := NULL;
 END IF;
 CLOSE plan_cur;

 IF op_er_cd = 0 THEN
 op_msg := 'Success';
 ELSE
 op_msg := CASE op_er_cd
 WHEN -200 THEN
 'No corresponding Billing Plan'
 ELSE
 SUBSTR(SQLERRM
 ,1
 ,100)
 END;
 END IF;
 END validate_plan;

 ---added for CR39698
 PROCEDURE b2b_validate_plan
 (
 p_b2b_part_num in varchar2
 ,p_org_id IN table_bus_org.org_id%TYPE
 ,op_billing_plan_id OUT NUMBER
 ,op_is_unlimited OUT NUMBER
 , --- 1 or 0
 op_er_cd OUT NUMBER
 ,op_msg OUT VARCHAR2
 ) IS
cursor b2b_plan_cur is
SELECT * FROM X_FF_PART_NUM_MAPPING
where x_source_part_num= p_b2b_part_num;
b2b_plan_rec b2b_plan_cur%ROWTYPE;

 BEGIN

 op_er_cd := 0;
 OPEN b2b_plan_cur;
 FETCH b2b_plan_cur
 INTO b2b_plan_rec;

 IF b2b_plan_cur%FOUND THEN

begin
 select DECODE(NVL(x_redeem_units
 ,1)
 ,0
 ,1
 ,0) unl into op_is_unlimited
 from table_part_num
 where part_number=b2b_plan_rec.X_TARGET_PART_NUM1;
 exception
 when others then
 op_is_unlimited := 0;
 end;


 ---op_is_unlimited := plan_rec.unl; --1 unlimited 0 or other value is limited plan
 op_billing_plan_id := b2b_plan_rec.X_FF_OBJID;
 ELSE
 op_er_cd := -200;
 op_msg := 'No corresponding Billing Plan';
 op_is_unlimited := 0;
 op_billing_plan_id := NULL;
 END IF;
 CLOSE b2b_plan_cur;

 IF op_er_cd = 0 THEN
 op_msg := 'Success';
 ELSE
 op_msg := CASE op_er_cd
 WHEN -200 THEN
 'No corresponding Billing Plan'
 ELSE
 SUBSTR(SQLERRM
 ,1
 ,100)
 END;
 END IF;
 END b2b_validate_plan;
 --end addition CR39698
 --
 --CR31683 Start Kacosta 01/22/2015
 PROCEDURE getaccountsummary
 (
 organizationid IN VARCHAR2
 ,in_login_name IN table_web_user.login_name%TYPE
 ,in_bus_org IN table_bus_org.org_id%TYPE
 ,out_account_summary OUT typ_account_summary_tbl
 ,out_err_num OUT NUMBER
 ,out_err_msg OUT VARCHAR2
 ) IS
 --
 CURSOR cur_get_monthly_plan_charges(c_n_wu_objid sa.table_web_user.objid%TYPE) IS
 WITH ecommerce_org_hierarchy AS
 (SELECT LEVEL ecom_org_hierarchy_level
 ,CASE
 WHEN LEVEL = 1 THEN
 SUBSTR(SYS_CONNECT_BY_PATH(ecom_orgs.ecom_org_name
 ,'/')
 ,2)
 ELSE
 SUBSTR(SYS_CONNECT_BY_PATH(ecom_orgs.ecom_org_name
 ,'/')
 ,2
 ,INSTR(SYS_CONNECT_BY_PATH(ecom_orgs.ecom_org_name
 ,'/')
 ,'/'
 ,1
 ,2) - 2)
 END ecom_primary_org_name
 ,CASE
 WHEN LEVEL = 1 THEN
 NULL
 ELSE
 SUBSTR(SYS_CONNECT_BY_PATH(ecom_orgs.ecom_org_name
 ,'/')
 ,INSTR(SYS_CONNECT_BY_PATH(ecom_orgs.ecom_org_name
 ,'/')
 ,'/'
 ,1
 ,LEVEL - 1) + 1
 ,(INSTR(SYS_CONNECT_BY_PATH(ecom_orgs.ecom_org_name
 ,'/')
 ,'/'
 ,1
 ,LEVEL)) - (INSTR(SYS_CONNECT_BY_PATH(ecom_orgs.ecom_org_name
 ,'/')
 ,'/'
 ,1
 ,LEVEL - 1) + 1))
 END ecom_parent_org_name
 ,ecom_orgs.ecom_org_name
 ,ecom_orgs.ecom_org_id
 ,ecom_orgs.ecom_org_site_type
 ,ecom_orgs.ecom_org_site_id
 ,ecom_orgs.ecom_org_objid
 FROM (SELECT tbs.objid ecom_org_objid
 ,COALESCE(tbs.child_site2site
 ,tbs.objid) child_site2site
 ,tbs.x_commerce_id ecom_org_id
 ,tbs.name ecom_org_name
 ,tbs.site_type ecom_org_site_type
 ,tbs.site_id ecom_org_site_id
 FROM sa.table_site tbs
 WHERE tbs.x_commerce_id IS NOT NULL) ecom_orgs
 WHERE 1 = 1
 START WITH ecom_orgs.ecom_org_objid = ecom_orgs.child_site2site
 CONNECT BY NOCYCLE PRIOR ecom_orgs.ecom_org_objid = ecom_orgs.child_site2site)
 SELECT SUM(monthly_plan_charges) monthly_plan_charges
 FROM (SELECT NVL(xpe.x_amount
 ,0) monthly_plan_charges
 ,DENSE_RANK() over(PARTITION BY tpi_esn.part_serial_no ORDER BY DECODE(xpe.x_enrollment_status, 'ENROLLED', 1, 'ENROLLMENTPENDING', 2, 3), xpe.x_insert_date DESC, xpe.objid DESC) program_enrollment_status_rank
 FROM sa.table_web_user twu
 JOIN sa.x_site_web_accounts xsa
 ON twu.objid = xsa.site_web_acct2web_user
 JOIN ecommerce_org_hierarchy ecom_org_account
 ON xsa.site_web_acct2site = ecom_org_account.ecom_org_objid
 JOIN ecommerce_org_hierarchy ecom_orgs
 ON ecom_org_account.ecom_primary_org_name = ecom_orgs.ecom_primary_org_name
 JOIN sa.x_site_web_accounts xsa_org
 ON ecom_orgs.ecom_org_objid = xsa_org.site_web_acct2site
 JOIN sa.table_web_user twu_org
 ON xsa_org.site_web_acct2web_user = twu_org.objid
 JOIN sa.table_contact tbc_org
 ON twu_org.web_user2contact = tbc_org.objid
                JOIN table_x_contact_part_inst cpi_org
                  ON tbc_org.objid = cpi_org.x_contact_part_inst2contact
                JOIN sa.table_part_inst tpi_esn
                  ON cpi_org.x_contact_part_inst2part_inst = tpi_esn.objid
                JOIN sa.table_x_code_table xct
                  ON tpi_esn.x_part_inst_status = xct.x_code_number
                LEFT OUTER JOIN sa.x_program_enrolled xpe
                  ON tpi_esn.part_serial_no = xpe.x_esn
               WHERE 1 = 1
                 AND xsa.site_web_acct2web_user = c_n_wu_objid
                 AND ((xsa.x_account_type = 'BUYERADMIN' AND ecom_org_account.ecom_org_hierarchy_level <= ecom_orgs.ecom_org_hierarchy_level) OR (xsa.x_account_type = 'BUYER' AND ecom_org_account.ecom_org_name = ecom_orgs.ecom_org_name))
                 AND xct.x_code_name = 'ACTIVE'
                 AND xpe.x_enrollment_status IN ('ENROLLED'
                                                ,'ENROLLMENTPENDING'))
       WHERE program_enrollment_status_rank = 1;
    --
    CURSOR cur_get_esn_summary(c_n_wu_objid sa.table_web_user.objid%TYPE) IS
      WITH ecommerce_org_hierarchy AS
       (SELECT LEVEL ecom_org_hierarchy_level
              ,CASE
                 WHEN LEVEL = 1 THEN
                  SUBSTR(SYS_CONNECT_BY_PATH(ecom_orgs.ecom_org_name
                                            ,'/')
                        ,2)
                 ELSE
                  SUBSTR(SYS_CONNECT_BY_PATH(ecom_orgs.ecom_org_name
                                            ,'/')
                        ,2
                        ,INSTR(SYS_CONNECT_BY_PATH(ecom_orgs.ecom_org_name
                                                  ,'/')
                              ,'/'
                              ,1
                              ,2) - 2)
               END ecom_primary_org_name
              ,CASE
                 WHEN LEVEL = 1 THEN
                  NULL
                 ELSE
                  SUBSTR(SYS_CONNECT_BY_PATH(ecom_orgs.ecom_org_name
                                            ,'/')
                        ,INSTR(SYS_CONNECT_BY_PATH(ecom_orgs.ecom_org_name
                                                  ,'/')
                              ,'/'
                              ,1
                              ,LEVEL - 1) + 1
                        ,(INSTR(SYS_CONNECT_BY_PATH(ecom_orgs.ecom_org_name
                                                   ,'/')
                               ,'/'
                               ,1
                               ,LEVEL)) - (INSTR(SYS_CONNECT_BY_PATH(ecom_orgs.ecom_org_name
                                                                    ,'/')
                                                ,'/'
                                                ,1
                                                ,LEVEL - 1) + 1))
               END ecom_parent_org_name
              ,ecom_orgs.ecom_org_name
              ,ecom_orgs.ecom_org_id
              ,ecom_orgs.ecom_org_site_type
              ,ecom_orgs.ecom_org_site_id
              ,ecom_orgs.ecom_org_objid
          FROM (SELECT tbs.objid ecom_org_objid
                      ,COALESCE(tbs.child_site2site
                               ,tbs.objid) child_site2site
                      ,tbs.x_commerce_id ecom_org_id
                      ,tbs.name ecom_org_name
                      ,tbs.site_type ecom_org_site_type
                      ,tbs.site_id ecom_org_site_id
                  FROM sa.table_site tbs
                 WHERE tbs.x_commerce_id IS NOT NULL) ecom_orgs
         WHERE 1 = 1
         START WITH ecom_orgs.ecom_org_objid = ecom_orgs.child_site2site
        CONNECT BY NOCYCLE PRIOR ecom_orgs.ecom_org_objid = ecom_orgs.child_site2site)
      SELECT CASE
               WHEN esn_status = 'ACTIVE'
                    AND program_enrollment_status IN ('ENROLLED'
                                                     ,'ENROLLMENTPENDING') THEN
                'Active'
               WHEN esn_status = 'ACTIVE'
                    AND program_enrollment_status IN ('READYTOREENROLL'
                                                     ,'DEENROLLED') THEN
                'Expiring'
               WHEN esn_status IN ('NEW'
                                  ,'REFURBISHED') THEN
                'New'
               ELSE
                'Expired'
             END esn_summary_status
            ,COUNT(*) esn_summary_status_count
        FROM (SELECT tpi_esn.part_serial_no esn
                    ,xct.x_code_name esn_status
                    ,xpe.x_enrollment_status program_enrollment_status
                    ,DENSE_RANK() over(PARTITION BY tpi_esn.part_serial_no ORDER BY DECODE(xpe.x_enrollment_status, 'ENROLLED', 1, 'ENROLLMENTPENDING', 2, 3), xpe.x_insert_date DESC, xpe.objid DESC) program_enrollment_status_rank
                FROM sa.x_site_web_accounts xsa
                JOIN ecommerce_org_hierarchy ecom_org_account
                  ON xsa.site_web_acct2site = ecom_org_account.ecom_org_objid
                JOIN ecommerce_org_hierarchy ecom_orgs
                  ON ecom_org_account.ecom_primary_org_name = ecom_orgs.ecom_primary_org_name
                JOIN sa.x_site_web_accounts xsa_org
                  ON ecom_orgs.ecom_org_objid = xsa_org.site_web_acct2site
                JOIN sa.table_web_user twu_org
                  ON xsa_org.site_web_acct2web_user = twu_org.objid
                JOIN sa.table_contact tbc_org
                  ON twu_org.web_user2contact = tbc_org.objid
                JOIN table_x_contact_part_inst cpi_org
                  ON tbc_org.objid = cpi_org.x_contact_part_inst2contact
                JOIN sa.table_part_inst tpi_esn
                  ON cpi_org.x_contact_part_inst2part_inst = tpi_esn.objid
                JOIN sa.table_x_code_table xct
                  ON tpi_esn.x_part_inst_status = xct.x_code_number
                LEFT OUTER JOIN sa.x_program_enrolled xpe
                  ON tpi_esn.part_serial_no = xpe.x_esn
               WHERE 1 = 1
                 AND xsa.site_web_acct2web_user = c_n_wu_objid
                 AND ((xsa.x_account_type = 'BUYERADMIN' AND ecom_org_account.ecom_org_hierarchy_level <= ecom_orgs.ecom_org_hierarchy_level)
				       OR (xsa.x_account_type = 'BUYER' AND ecom_org_account.ecom_org_name = ecom_orgs.ecom_org_name
					      AND  CPI_ORG.X_CONTACT_PART_INST2PART_INST IN      --CR 34819 added a new block for giving the ESN for only buyers
										 (SELECT CPI.X_CONTACT_PART_INST2PART_INST
											FROM sa.TABLE_WEB_USER TWU
											JOIN sa.TABLE_CONTACT TC 				ON TWU.WEB_USER2CONTACT = TC.OBJID
											JOIN TABLE_X_CONTACT_PART_INST CPI	    ON TC.OBJID = CPI.X_CONTACT_PART_INST2CONTACT
										   WHERE TWU.OBJID = c_n_wu_objid) --
					   ))
               ORDER BY tpi_esn.part_serial_no)
       WHERE program_enrollment_status_rank = 1
       GROUP BY CASE
                  WHEN esn_status = 'ACTIVE'
                       AND program_enrollment_status IN ('ENROLLED'
                                                        ,'ENROLLMENTPENDING') THEN
                   'Active'
                  WHEN esn_status = 'ACTIVE'
                       AND program_enrollment_status IN ('READYTOREENROLL'
                                                        ,'DEENROLLED') THEN
                   'Expiring'
                  WHEN esn_status IN ('NEW'
                                     ,'REFURBISHED') THEN
                   'New'
                  ELSE
                   'Expired'
                END;
    --
    l_exc_business_error EXCEPTION;
    l_n_wu_objid                   NUMBER;
    l_n_esn_wuobjid                NUMBER;
    l_n_bo_objid                   NUMBER;
    l_n_err_num                    NUMBER := 0;
    l_rec_get_monthly_plan_charges cur_get_monthly_plan_charges%ROWTYPE;
    l_rec_get_esn_summary          cur_get_esn_summary%ROWTYPE;
    l_v_err_msg                    VARCHAR2(32767) := 'Success';
    l_tab_account_summary          typ_account_summary_tbl := typ_account_summary_tbl();
    --
  BEGIN
    --
    IF in_login_name IS NULL THEN
      --
      l_n_err_num := -1;
      l_v_err_msg := 'Login name parameter is null';
      --
      RAISE l_exc_business_error;
      --
    END IF;
    --
    IF in_bus_org IS NULL THEN
      --
      l_n_err_num := -1;
      l_v_err_msg := 'Bus org parameter is null';
      --
      RAISE l_exc_business_error;
      --
    END IF;
    --
    sa.b2b_pkg.get_esn_web_user(in_login_name   => in_login_name
                               ,in_bus_org      => in_bus_org
                               ,in_esn          => NULL
                               ,in_min          => NULL
                               ,out_wu_objid    => l_n_wu_objid
                               ,out_esn_wuobjid => l_n_esn_wuobjid
                               ,out_bo_objid    => l_n_bo_objid
                               ,out_err_num     => l_n_err_num
                               ,out_err_msg     => l_v_err_msg);
    --
    IF l_n_err_num <> 0 THEN
      --
      l_v_err_msg := 'Calling b2b_pkg.get_esn_web_user failed for login ' || in_login_name || ' and bus org ' || in_bus_org || ' with the following error: ' || l_v_err_msg;
      --
      RAISE l_exc_business_error;
      --
    END IF;
    --
    BEGIN
      --
      l_tab_account_summary.extend;
      l_tab_account_summary(1) := sa.typ_account_summary_rec(monthly_plan_charges => NULL
                                                            ,NEW                  => NULL
                                                            ,active               => NULL
                                                            ,expiring             => NULL
                                                            ,expired              => NULL);
      --
    EXCEPTION
      WHEN others THEN
        --
        l_n_err_num := SQLCODE;
        l_v_err_msg := 'Oracle error raised when initializing account summary table for login ' || in_login_name || ' and bus org ' || in_bus_org || ': ' || SQLERRM;
        --
        RAISE l_exc_business_error;
        --
    END;
    --
    BEGIN
      --
      l_tab_account_summary(1).monthly_plan_charges := 0;
      --
      IF cur_get_monthly_plan_charges%ISOPEN THEN
        --
        CLOSE cur_get_monthly_plan_charges;
        --
      END IF;
      --
      OPEN cur_get_monthly_plan_charges(c_n_wu_objid => l_n_wu_objid);
      FETCH cur_get_monthly_plan_charges
        INTO l_rec_get_monthly_plan_charges;
      --
      IF cur_get_monthly_plan_charges%FOUND THEN
        --
        l_tab_account_summary(1).monthly_plan_charges := COALESCE(l_rec_get_monthly_plan_charges.monthly_plan_charges
                                                                 ,0);
        --
      END IF;
      --
      CLOSE cur_get_monthly_plan_charges;
      --
    EXCEPTION
      WHEN others THEN
        --
        l_n_err_num := SQLCODE;
        l_v_err_msg := 'Oracle error raised when retrieving monthly plan charges for login ' || in_login_name || ' and bus org ' || in_bus_org || ': ' || SQLERRM;
        --
        RAISE l_exc_business_error;
        --
    END;
    --
    BEGIN
      --
      l_tab_account_summary(1).new := 0;
      l_tab_account_summary(1).active := 0;
      l_tab_account_summary(1).expiring := 0;
      l_tab_account_summary(1).expired := 0;
      --
      IF cur_get_esn_summary%ISOPEN THEN
        --
        CLOSE cur_get_esn_summary;
        --
      END IF;
      --
      OPEN cur_get_esn_summary(c_n_wu_objid => l_n_wu_objid);
      --
      LOOP
        --
        FETCH cur_get_esn_summary
          INTO l_rec_get_esn_summary;
        --
        EXIT WHEN cur_get_esn_summary%NOTFOUND;
        --
        CASE l_rec_get_esn_summary.esn_summary_status
          WHEN 'New' THEN
            --
            l_tab_account_summary(1).new := COALESCE(l_rec_get_esn_summary.esn_summary_status_count
                                                    ,0);
            --
          WHEN 'Active' THEN
            --
            l_tab_account_summary(1).active := COALESCE(l_rec_get_esn_summary.esn_summary_status_count
                                                       ,0);
            --
          WHEN 'Expiring' THEN
            --
            l_tab_account_summary(1).expiring := COALESCE(l_rec_get_esn_summary.esn_summary_status_count
                                                         ,0);
            --
          ELSE
            --
            l_tab_account_summary(1).expired := COALESCE(l_rec_get_esn_summary.esn_summary_status_count
                                                        ,0);
            --
        END CASE;
        --
      END LOOP;
      --
      CLOSE cur_get_esn_summary;

      out_account_summary := l_tab_account_summary;
      --
    EXCEPTION
      WHEN others THEN
        --
        l_n_err_num := SQLCODE;
        l_v_err_msg := 'Oracle error raised when retrieving ESN summary for login ' || in_login_name || ' and bus org ' || in_bus_org || ': ' || SQLERRM;
        --
        RAISE l_exc_business_error;
        --
    END;
    --
    out_err_num := l_n_err_num;
    out_err_msg := l_v_err_msg;
    --
  EXCEPTION
    WHEN l_exc_business_error THEN
      --
  -- CR33401     ROLLBACK;
      --
      out_err_num := l_n_err_num;
      out_err_msg := SUBSTR(l_v_err_msg
                           ,1
                           ,300);
      --
      util_pkg.insert_error_tab_proc(ip_action       => TO_CHAR(out_err_num)
                                    ,ip_key          => in_login_name
                                    ,ip_program_name => 'sa.account_services_pkg.getaccountsummary'
                                    ,ip_error_text   => out_err_msg);
      --
 -- CR33401     COMMIT;
      --
    WHEN others THEN
      --
  -- CR33401    ROLLBACK;
      --
      out_err_num := SQLCODE;
      out_err_msg := SUBSTR(SQLERRM
                           ,1
                           ,300);
      --
      util_pkg.insert_error_tab_proc(ip_action       => TO_CHAR(out_err_num)
                                    ,ip_key          => in_login_name
                                    ,ip_program_name => 'sa.account_services_pkg.getaccountsummary'
                                    ,ip_error_text   => out_err_msg);
      --
  -- CR33401    COMMIT;
      --
  END getaccountsummary;
  --CR31683 End Kacosta 01/22/2015
--
END account_services_pkg;
/