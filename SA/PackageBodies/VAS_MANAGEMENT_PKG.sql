CREATE OR REPLACE PACKAGE BODY sa."VAS_MANAGEMENT_PKG" as

/*****************************************************************************************/
--$RCSfile: VAS_MANAGEMENT_PKB.sql,v $
--$Revision: 1.112 $
--$Author: sinturi $
--$Date: 2018/02/01 16:06:09 $
--$ $Log: VAS_MANAGEMENT_PKB.sql,v $
--$ Revision 1.112  2018/02/01 16:06:09  sinturi
--$ Modicfied code to update MIN
--$
--$ Revision 1.110  2018/01/10 22:47:04  sinturi
--$ modified channel to ecommerce
--$
--$ Revision 1.107  2017/12/19 15:49:02  abustos
--$ CR48517 Fix for NT Web Common when passing brand
--$
--$ Revision 1.106  2017/12/13 20:49:40  sinturi
--$ Min condition added in update_vas_min proc
--$
--$ Revision 1.105  2017/12/12 17:24:29  abustos
--$ CR48517 - Merge with EME CR55486
--$
--$ Revision 1.103  2017/12/11 18:37:18  abustos
--$ CR48517 merge with production
--$
--$ Revision 1.102  2017/12/07 14:32:35  skambhammettu
--$ CR53217
--$
--$ Revision 1.99  2017/12/05 17:25:58  skota
--$ Modified for Sagar
--$
--$ Revision 1.98  2017/12/02 02:58:37  sinturi
--$ Updated
--$
--$ Revision 1.96  2017/12/02 01:26:44  sinturi
--$ Updated
--$
--$ Revision 1.93  2017/12/01 17:37:25  sinturi
--$ added condition for defect
--$
--$ Revision 1.90  2017/12/01 03:44:49  sinturi
--$ script id changes added
--$
--$ Revision 1.89  2017/12/01 00:40:48  sinturi
--$ updated
--$
--$ Revision 1.88  2017/11/30 20:44:37  sinturi
--$ Added condition for transfer flag
--$
--$ Revision 1.86  2017/11/27 22:17:41  sinturi
--$ Added condition for Is transferable flag
--$
--$ Revision 1.85  2017/11/27 19:05:04  sinturi
--$ Refund flag condition added
--$
--$ Revision 1.84  2017/11/24 19:55:23  sinturi
--$ Added few conditions
--$
--$ Revision 1.83  2017/11/20 17:22:30  sinturi
--$ Added order type param to update vas min proc
--$
--$ Revision 1.81  2017/11/14 22:46:32  smeganathan
--$ added new attributes in get eligible and enrolled vas services
--$
--$ Revision 1.80  2017/11/13 19:31:13  sinturi
--$ Added condition
--$
--$ Revision 1.78  2017/11/07 20:44:28  smeganathan
--$ fixes for is due flag
--$
--$ Revision 1.77  2017/11/07 20:41:06  smeganathan
--$ fixes for is due flag
--$
--$ Revision 1.76  2017/11/06 23:17:09  smeganathan
--$ changes to include suspend to get transfer eligible flags
--$
--$ Revision 1.75  2017/11/06 18:56:59  smeganathan
--$ fixes to include carrier pending for transfer vas
--$
--$ Revision 1.74  2017/11/06 17:32:07  smeganathan
--$ fixes to include carrier pending for transfer vas
--$
--$ Revision 1.72  2017/11/03 22:31:44  smeganathan
--$ changes in transfer vas
--$
--$ Revision 1.71  2017/11/03 19:09:14  smeganathan
--$ added program enrolled id attribute
--$
--$ Revision 1.70  2017/11/02 21:30:10  smeganathan
--$ changes in deenroll vas to return payment source id
--$
--$ Revision 1.69  2017/11/01 20:54:29  smeganathan
--$ changes in claim device check
--$
--$ Revision 1.68  2017/10/31 16:41:51  smeganathan
--$ update error code update vas enrollment procedure
--$
--$ Revision 1.67  2017/10/30 22:02:50  smeganathan
--$ changes in update vas and subscribe vas
--$
--$ Revision 1.66  2017/10/30 14:07:37  smeganathan
--$ added statuses in get enrolled services
--$
--$ Revision 1.65  2017/10/27 21:03:26  smeganathan
--$ overloaded check claim device procedure
--$
--$ Revision 1.64  2017/10/26 22:20:12  smeganathan
--$ overloaded check claim device procedure
--$
--$ Revision 1.63  2017/10/25 23:23:04  smacha
--$ Modified FindMIN_excep cursor regarding CR53086
--$
--$ Revision 1.61  2017/10/24 20:57:53  smeganathan
--$ changes in call to vas proration service
--$
--$ Revision 1.60  2017/10/23 18:47:29  smeganathan
--$ added new procedure to update min and changes in subscribe vas
--$
--$ Revision 1.56  2017/10/20 14:28:16  smeganathan
--$ added new procedures for asurion
--$
--$ Revision 1.53  2017/10/11 17:33:48  smeganathan
--$ added new procedure transfer vas
--$
--$ Revision 1.52  2017/10/06 18:48:18  smeganathan
--$ added vas_subscription_id
--$
--$ Revision 1.51  2017/10/04 21:27:59  smeganathan
--$ added refund code
--$
--$ Revision 1.50  2017/10/03 15:08:18  smeganathan
--$ added vas_final_cancellation and overloaded deenroll_vas_program
--$
--$ Revision 1.44  2017/09/28 21:48:51  smeganathan
--$ new procedures for VAS proration
--$
--$ Revision 1.43  2017/09/25 16:25:38  smeganathan
--$ Changes in eligible vas services
--$
--$ Revision 1.42  2017/09/22 22:39:52  smeganathan
--$ initialized type
--$
--$ Revision 1.39  2017/08/28 17:26:09  smeganathan
--$ Added new procedures for Asurion HPP
--$
--$ Revision 1.38 2017/07/31 22:54:16 aganesan
--$ Refcursor clear condition removed
--$
--$ Revision 1.33 2017/01/04 19:48:09 rpednekar
--$ CR47191
--$
--$ Revision 1.32 2017/01/04 17:17:31 rpednekar
--$ CR47191
--$
--$ Revision 1.31 2017/01/03 15:35:18 rpednekar
--$ CR47191
--$
--$ Revision 1.30 2016/12/30 16:43:36 rpednekar
--$ CR47191
--$
--$ Revision 1.29 2016/06/08 17:08:16 skota
--$ Modified GETSERVICEFORPIN for SAFELINK
--$
--$ Revision 1.28 2016/06/06 18:51:37 skota
--$ Megred the changes
--$
--$ Revision 1.27 2016/06/03 16:40:14 tbaney
--$ CR39723
--$
--$ Revision 1.25 2016/01/13 23:19:59 rpednekar
--$ CR40404 - Modified one of query condition
--$
--$ Revision 1.24 2015/01/27 18:28:46 arijal
--$ Prod Fix 1-27 issue
--$
--$ Revision 1.23 2015/01/15 00:30:00 arijal
--$ CR31545 SL CA HOME PHONE VAS BODY
--$
--$ Revision 1.22 2014/12/24 14:16:12 arijal
--$ CR31545 SL CA HOME PHONE VAS BODY
--$
--$ Revision 1.21 2014/12/23 23:15:02 arijal
--$ CR31545 SL CA HOME PHONE VAS BODY
--$
--$ Revision 1.20 2014/12/16 17:00:05 arijal
--$ CR31545 SL CA HOME PHONE VAS BODY
--$
--$ Revision 1.19 2014/11/13 23:24:40 arijal
--$ CR29866-CR30295 SafeLink California Pkg Body VAS_Mangmt
--$
--$ Revision 1.18 2014/08/23 14:32:43 vkashmire
--$ CR29489
--$
--$ Revision 1.17 2014/08/22 20:57:13 vkashmire
--$ CR22313 HPP Phase 2
--$ CR29489 HPP BYOP
--$ CR27087
--$ CR29638
--$
--$ Revision 1.16 2013/08/22 16:36:36 akuthadi
--$ 2 new functions get_vas_service_id_by_pin, get_vas_service_param_val
--$
--$ Revision 1.15 2013/07/24 15:57:14 akuthadi
--$ Moved the code to close the cursor find_min.
--$
--$ Revision 1.14 2013/07/13 16:02:12 ymillan
--$ CR24196
--$
--$ Revision 1.13 2013/05/06 11:28:09 icanavan
--$ fix the myaccount slow cursors
--$
--$ Revision 1.11 2013/04/30 22:24:19 icanavan
--$ rid local variables
--$
--$ Revision 1.9 2013/04/24 20:37:55 icanavan
--$ NEW PACKAGE BODY
--$
--$ Revision 1.8 2013/04/24 15:51:40 icanavan
--$
/******************************************************************************************/
/*======================================================================================*/
/* PURPOSE : Package has been developed to manage VALUE ADDED SERVICES */
/* */
/* REVISION DATE WHO PURPOSE */
/* ------------------------------------------------------------------------------------ */
/* 1.0-8 04/24/2013 ICanavan CR21443 Initial Revision */
/* 1.0-9-10 04/29/2013 ICanavan CR21443 Fine tuning */
/* 1.11 04/30/2013 ICanavan CR22634 simple mobile */
/* 1.12-13 05/06/2013 ICanavan CR22634 fix slow cursor */
/*======================================================================================*/

/* HPP BYOP 20-Aug-2014 VKashmire CR29489
 1) Replaced "select * from x_vas_subscriptions" with "select <column-name> from x_vas_subscriptions"
 2) Added a where clause to filter records - "AND VAS_NAME <> 'HPP BYOP'"
*/

IP_FIELD VARCHAR2(80) ;
LV_COUNTER NUMBER ;

cursor EVENT_COUNTER_CURSOR (IP_VALUE VARCHAR2, IP_EVENT VARCHAR2) IS
select *
 from X_VAS_EVENT_COUNTER
 where VAS_OBJECTVALUE = ip_value
 and VAS_EVENT = ip_event ;

Event_Counter_Row Event_Counter_Cursor%rowtype ;

cursor FindESN (IP_ESN VARCHAR2) IS
select pc.objid pc_objid, pn.x_technology, pn.x_dll, pi.part_serial_no,
 pi.x_part_inst_status, pi.x_iccid, bo.org_id
from table_part_num pn, table_part_class pc, table_mod_level ml,
 table_part_inst pi, table_bus_org bo
where pn.part_num2bus_org = bo.objid
 and pn.part_num2part_class=pc.objid
 and ml.part_info2part_num=pn.objid
 and pi.n_part_inst2part_mod=ml.objid
 and pi.part_serial_no = ip_ESN ;

FindESN_r FindESN%rowtype;

cursor FindMIN (IP_MIN VARCHAR2) IS
select pc.objid pc_objid, pn.x_technology, pn.x_dll, bo.org_id, sp.objid sp_objid,
 sp.part_status, sp.service_end_dt, sp.x_service_id, sp.x_min,
 sp.x_expire_dt, sp.x_zipcode, sp.site_part2part_info,sp.x_refurb_flag
from table_part_num pn, table_part_class pc, table_mod_level ml,
 table_bus_org bo, table_site_part sp
where pn.part_num2bus_org = bo.objid
 and pn.part_num2part_class=pc.objid
 and ml.part_info2part_num=pn.objid
 and sp.site_part2part_info=ml.objid
 and sp.part_status='Active'
 and rownum < 2
 and sp.x_min = IP_MIN ;

FindMIN_r FindMIN%rowtype;

--CR 53086
cursor FindMIN_excep (IP_MIN VARCHAR2) IS
SELECT pc.objid pc_objid,
       pn.x_technology,
       pn.x_dll,
       bo.org_id,
       sp.objid sp_objid,
       sp.part_status,
       sp.service_end_dt,
       sp.x_service_id,
       sp.x_min,
       sp.x_expire_dt,
       sp.x_zipcode,
       sp.site_part2part_info,
       sp.x_refurb_flag,
       sp.install_date
 FROM  table_part_num pn,
       table_part_class pc,
       table_mod_level ml,
       table_bus_org bo,
       table_site_part sp
WHERE 1= 1
  AND pn.part_num2bus_org     = bo.objid
  AND pn.part_num2part_class=pc.objid
  AND ml.part_info2part_num =pn.objid
  AND sp.site_part2part_info=ml.objid
  AND sp.x_min        = IP_MIN
  AND sp.install_date = (SELECT MAX(install_date)
                          FROM table_site_part sp2
                         WHERE sp2.x_service_id = sp.x_service_id
                        );

FindMIN_excep_rc FindMIN_excep%rowtype;  --CR 53086

cursor FindSIM (IP_SIM VARCHAR2) IS
select pc.objid pc_objid, pn.x_technology, pn.x_dll, pi.part_serial_no,
 pi.x_part_inst_status, pi.x_iccid, bo.org_id
from table_part_num pn, table_part_class pc, table_mod_level ml,
 table_part_inst pi, table_bus_org bo
where pn.part_num2bus_org = bo.objid
 and pn.part_num2part_class=pc.objid
 and ml.part_info2part_num=pn.objid
 and pi.n_part_inst2part_mod=ml.objid
 and rownum < 2
 and pi.x_iccid = ip_SIM ;

FindSIM_r FindSIM%rowtype;

--cursor FindACCOUNT (IP_ACCOUNT VARCHAR2) IS
--select pc.objid pc_objid, pn.x_technology, pn.x_dll, pi.part_serial_no,
 --pi.x_part_inst_status, pi.x_iccid, bo.org_id,
 --WU.OBJID WU_OBJID, WU.S_LOGIN_name
--from table_part_num pn, table_part_class pc, table_mod_level ml, table_part_inst pi,
 -- table_bus_org bo, x_program_enrolled pe, table_web_user wu
--where pn.part_num2bus_org = bo.objid
-- and pn.part_num2part_class=pc.objid
-- and ml.part_info2part_num=pn.objid
-- and pi.n_part_inst2part_mod=ml.objid
-- and pe.pgm_enroll2part_inst=pi.objid
-- and pe.pgm_enroll2web_user=wu.objid
-- and rownum < 2
-- and wu.s_login_name= ip_ACCOUNT ;

cursor FindACCOUNT (IP_ACCOUNT VARCHAR2) IS
select pc.objid pc_objid, pn.x_technology, pn.x_dll, pi.part_serial_no,
pi.x_part_inst_status, pi.x_iccid, bo.org_id,
WU.OBJID WU_OBJID, WU.S_LOGIN_name
from table_part_num pn, table_part_class pc, table_mod_level ml, table_part_inst pi,
 table_bus_org bo, table_contact tc, table_web_user wu
where pn.part_num2bus_org = bo.objid
 and pn.part_num2part_class=pc.objid
 and ml.part_info2part_num=pn.objid
 and pi.n_part_inst2part_mod=ml.objid
 and pi.x_part_inst2contact=tc.objid
 and wu.web_user2contact=tc.objid
 and rownum < 2
 and wu.s_login_name = ip_ACCOUNT ; -- 'A3CE1F13C018050B15DBAACE65EE384C@SAFELINK3.COM' ;

FindACCOUNT_r FindACCOUNT%rowtype;

cursor FindACCOUNTbyESN (IP_ESN VARCHAR2) IS
select pi.part_serial_no, pi.x_part_inst2contact,
 tc.e_mail,login_name, wu.s_login_name, wu.web_user2contact
from table_part_inst pi,
 table_contact tc,
 table_web_user wu
where pi.x_part_inst2contact=tc.objid
 and wu.web_user2contact=tc.objid
 and rownum < 2
 and pi.part_serial_no = ip_esn ; --'011426000565675' ;

FindACCOUNTbyESN_r FindACCOUNTbyESN%rowtype;

cursor FindMINbyESN (IP_ESN VARCHAR2) IS
select sp.objid sp_objid,sp.part_status,sp.service_end_dt, sp.x_service_id, sp.x_min,
 sp.x_expire_dt, sp.x_zipcode, sp.site_part2part_info,sp.x_refurb_flag
from table_site_part sp
where sp.part_status='Active'
 and rownum < 2
 and sp.x_service_id = ip_esn ;

FindMINbyESN_r FindMINbyESN%rowtype;

cursor FindService (IP_SERVICE NUMBER) IS
select *
 from VAS_PROGRAMS_VIEW
 where VAS_SERVICE_ID = IP_SERVICE ;

FindService_r FindService%rowtype ;

cursor FindEligible(l_org_id VARCHAR2, ip_service_id VARCHAR2) IS
select *
 from VAS_PROGRAMS_VIEW
 where vas_bus_org=l_org_id
 and vas_is_active= 'T'
 and vas_service_id = ip_service_id ;

FindEligible_R FindEligible%rowtype ;

cursor FindServiceforPhone (IP_PC_OBJID number, IP_ORG_ID varchar2 ) IS
select *
 from VAS_PROGRAMS_VIEW
 where NOT EXISTS
 (select vas_service_id
 from mtm_vas_handset_EXCLUSION MTM, vas_programs_view vpv, table_part_class pc
 where mtm.vas_programs_objid = vpv.vas_service_id
 and mtm.part_class_objid=pc.objid
 and pc.objid = IP_PC_OBJID )
 AND vas_category  = 'ILD_REUP'  -- CR49058
 and vas_bus_org = IP_ORG_ID ;

FindServiceforPhone_r FindServiceforPhone%rowtype ;

cursor FindServiceforPin (IP_Pin varchar2) IS
select vas_service_id, vas_bus_org, vas_type --CR40708 added vas_type
 from table_part_inst pi, table_mod_level ml, table_part_num pn, table_part_class pc, vas_programs_view vi
 where pi.n_part_inst2part_mod=ml.objid
 and ml.part_info2part_num=pn.objid
 and pn.part_num2part_class=pc.objid
 and vi.vas_card_class=pc.name
 --and pn.part_number=vi.vas_app_card -- CR31545 SL CA HOME PHONE AR -- 1/27 prod fix commented
 and pi.x_red_code = ip_PIN ; -- '999999936979268'

FindServiceforPIN_r FindServiceforPIN%rowtype ;
--
--CR47191
FUNCTION GET_ILD_PURCHASE_COUNT( ip_esn		VARCHAR2
				,ip_min		VARCHAR2
				,ip_days_period NUMBER DEFAULT 30
				)
RETURN NUMBER
IS

lv_ild_purch_count NUMBER := 0;
c_esn table_x_ild_transaction.x_esn%type;
BEGIN

 --CR53217
IF ip_esn IS NULL and ip_min is not null THEN
c_esn:=customer_info.get_esn (  ip_min );
else
c_esn:=ip_esn;
end if;
SELECT count(DISTINCT CT.objid) --CR53217
--COUNT(rc.objid) /*This gives muliple records for enrollment*/
		INTO lv_ild_purch_count
		FROM table_x_call_trans ct,
		table_x_red_card rc,
		sa.table_part_inst pi,
		table_part_num pn,
		table_mod_level ml,
		table_x_ild_transaction it
		WHERE 1 			= 	1
		AND ml.objid 			= 	rc.x_red_card2part_mod
		AND rc.red_card2call_trans 	= 	ct.objid
		AND ct.x_service_id 		= 	pi.part_serial_no
		AND pn.objid 			= 	ml.part_info2part_num
		AND pi.part_serial_no 		= 	c_esn
		AND pn.part_number 		IN	(SELECT DISTINCT VAS_APP_CARD FROM VAS_PROGRAMS_VIEW )
		AND it.X_ILD_TRANS2CALL_TRANS	=	ct.objid
		AND it.X_ESN 		= 	pi.part_serial_no
		AND it.x_transact_date 		> 	TRUNC(SYSDATE) - ip_days_period
		;

	RETURN lv_ild_purch_count;

EXCEPTION WHEN OTHERS
THEN

	lv_ild_purch_count	:=	0;

	RETURN lv_ild_purch_count;

END GET_ILD_PURCHASE_COUNT;
--CR47191

PROCEDURE RecordSubscription (
-- *********************************************************
-- This service is called from SOA services to record the VAS transaction
-- *********************************************************
 ip_type IN VARCHAR2,
 ip_value IN VARCHAR2,
 ip_service_id IN VARCHAR2,
 op_result OUT NUMBER,
 op_msg OUT VARCHAR2 )

as

 l_pc_objid number := 0;
 l_org_id varchar2(30) := null ;
 l_min varchar2(30) := null ;  --CR53086
 l_esn varchar2(30) := null ;
 l_sim varchar2(30) := null ;
 l_account varchar2(50) := null ;

begin

 op_result := '0';
 op_msg := 'Success';

 if ip_type is null or ip_value is null or ip_service_id is null
 then
 op_result := '604';
 op_msg := get_code_fun('SA.VAS_MANAGEMENT_PKG','604','ENGLISH');
 sa.ota_util_pkg.err_log
 (p_action => get_code_fun('SA.VAS_MANAGEMENT_PKG','604','ENGLISH')
 ,p_error_date => SYSDATE,p_key => IP_TYPE
 ,p_program_name => 'SA.VAS_MANAGEMENT_PKG.RecordSubscription'
 ,p_error_text => op_msg);
 return ;
 end if ;
 if ip_type not in ('ESN','MIN','SIM','ACCOUNT')
 then
 op_result := '601';
 op_msg := get_code_fun('VAS_MANAGEMENT_PKG','601','ENGLISH');
 sa.ota_util_pkg.err_log
 (p_action => get_code_fun('VAS_MANAGEMENT_PKG','601','ENGLISH')
 ,p_error_date => SYSDATE,p_key => IP_TYPE
 ,p_program_name => 'VAS_MANAGEMENT_PKG.RecordSubscription'
 ,p_error_text => op_msg);
 return ;
 end if ;
 if ip_type = 'MIN'
 then
 open FindMIN(ip_value) ;
     fetch FindMIN into FindMIN_r;
     if FindMIN%found then
          l_pc_objid:=FindMIN_r.pc_objid;
          l_org_id:=FindMIN_r.org_id;
          l_min := FindMIN_r.x_min;
          l_esn := FindMIN_r.x_service_id;
     end if;


  --CR 53086,If FindMIN%not found the return the values based on FindMIN_excep cursor.
  if FindMIN%notfound then
     dbms_output.put_line( 'no data found for FindMIN cursor');
     open FindMIN_excep(ip_value) ;
     fetch FindMIN_excep into FindMIN_excep_rc;

        if FindMIN_excep%found then

          dbms_output.put_line( 'Record found for FindMIN_excep cursor');
          l_pc_objid:= FindMIN_excep_rc.pc_objid;
          l_org_id:= FindMIN_excep_rc.org_id;
          l_min := FindMIN_excep_rc.x_min;
          l_esn := FindMIN_excep_rc.x_service_id;
	  dbms_output.put_line( 'l_pc_objid_cur:'||l_pc_objid);
        end if;


      CLOSE FindMIN_excep;
  end if; --if FindMIN%notfound then


  CLOSE FindMIN ;
  end if; -- if ip_type = 'MIN'




  open FindESN(l_esn) ;
          fetch FindESN into FindESN_r;
          if FindESN%found then
              l_sim := FindESN_r.x_iccid ;
          end if ;
          CLOSE FindESN ;

  open FindACCOUNTbyESN(l_esn) ;
          fetch FindACCOUNTbyESN into FindACCOUNTbyESN_r;
          if FindACCOUNTbyESN%found then
              l_ACCOUNT := FindACCOUNTbyESN_r.S_LOGIN_name ;
          end if ;
          CLOSE FindACCOUNTbyESN ;




    if ip_type = 'ESN'
    then
        open FindESN(ip_value) ;
       fetch FindESN into FindESN_r;
          if FindESN%found then
              l_pc_objid:=FindESN_r.pc_objid;
              l_org_id:=FindESN_r.org_id;
              l_esn := FindESN_r.part_serial_no ;
              l_sim := FindESN_r.x_iccid ;

            open FindMINbyESN(FindESN_R.part_serial_no) ;
            fetch FindMINbyESN into FindMINbyESN_r;
            if FindMINbyESN%found then
              l_MIN := FindMINbyESN_r.x_min ;
            end if ;
            CLOSE FindMINbyESN ;

          open FindACCOUNTbyESN(FindESN_R.part_serial_no) ;
          fetch FindACCOUNTbyESN into FindACCOUNTbyESN_r;
          if FindACCOUNTbyESN%found then
              l_ACCOUNT := FindACCOUNTbyESN_r.S_LOGIN_name ;
          end if ;
          CLOSE FindACCOUNTbyESN ;

         end if;
    end if ;
    if ip_type = 'SIM'
    then
        open FindSIM(ip_value) ;
       fetch FindSIM into FindSIM_r;
          if FindSIM%found then
              l_pc_objid:=FindSIM_r.pc_objid;
              l_org_id:=FindSIM_r.org_id;

            open FindMINbyESN(FindSIM_R.part_serial_no) ;
            fetch FindMINbyESN into FindMINbyESN_r;
            if FindMINbyESN%found then
              l_MIN := FindMINbyESN_r.x_min ;
            end if ;
            CLOSE FindMINbyESN ;

              l_esn := FindSIM_r.part_serial_no ;
              l_sim := FindSIM_r.x_iccid ;

          open FindACCOUNTbyESN(FindSIM_r.part_serial_no) ;
          fetch FindACCOUNTbyESN into FindACCOUNTbyESN_r;
          if FindACCOUNTbyESN%found then
              l_ACCOUNT := FindACCOUNTbyESN_r.S_LOGIN_name ;
          end if ;
          CLOSE FindACCOUNTbyESN ;

         end if;
    end if ;
    if ip_type = 'ACCOUNT'
    then
        open FindACCOUNT(ip_value) ;
       fetch FindACCOUNT into FindACCOUNT_r;
          if FindACCOUNT%found then
              l_pc_objid:=FindACCOUNT_r.pc_objid;
              l_org_id:=FindACCOUNT_r.org_id;


            open FindMINbyESN(findACCOUNT_r.part_serial_no ) ;
            fetch FindMINbyESN into FindMINbyESN_r;
            if FindMINbyESN%found then
              l_MIN := FindMINbyESN_r.x_min ;
            end if ;
            CLOSE FindMINbyESN ;

              l_esn := FindACCOUNT_r.part_serial_no ;
              l_sim := FindACCOUNT_r.x_iccid ;
              l_account := ip_value ;

          end if;
    end if ;

    dbms_output.put_line( 'l_pc_objid:'||l_pc_objid);

  if l_pc_objid > 0 then
   Insert into x_vas_subscriptions
    (OBJID,VAS_ESN,VAS_MIN,VAS_SIM,VAS_ACCOUNT,VAS_NAME,VAS_ID,VAS_X_IG_ORDER_TYPE,
     VAS_SUBSCRIPTION_DATE,VAS_IS_ACTIVE,PROGRAM_PARAMETERS_OBJID,PART_INST_OBJID,
     WEB_USER_OBJID,PROMOTION_OBJID,PROGRAM_PURCH_HDR_OBJID,X_PURCH_HDR_OBJID, ADDL_INFO )
    Values
    (SEQ_X_VAS_SUBSCRIPTIONS.NEXTVAL,
     DECODE(ip_type,'ESN',ip_value,l_esn),
     DECODE(ip_type,'MIN',ip_value,l_min),
     DECODE(ip_type,'SIM',ip_value,l_sim),
     DECODE(ip_type,'ACCOUNT',ip_value,l_account),
     (SELECT VAS_NAME FROM X_VAS_PROGRAMS WHERE OBJID = ip_service_id),
     ip_service_id,'A',SYSDATE,'T',null,null,null,null,null,null,'VAS RECORDED' ) ;
    commit ;
    else
      op_result := '604';
      op_msg := get_code_fun('VAS_MANAGEMENT_PKG','604','ENGLISH');
      sa.ota_util_pkg.err_log
      (p_action => get_code_fun('VAS_MANAGEMENT_PKG','604','ENGLISH')
      ,p_error_date   => SYSDATE,p_key => IP_TYPE
      ,p_program_name => 'VAS_MANAGEMENT_PKG.RecordSubscription'
      ,p_error_text   => op_msg);
    end if ;

   if FindESN%isopen
   then
   close FindESN ;
   end if  ;
   if FindMIN%isopen
   then
   close FindMIN ;
   end if  ;
   if FindSIM%isopen
   then
   close FindSIM ;
   end if  ;
   if FindACCOUNT%isopen
   then
   close FindACCOUNT ;
   end if  ;
    if FindMINbyESN%isopen
   then
   close FindMINbyESN ;
   end if  ;
   if FindACCOUNTbyESN%isopen
   then
   close FindACCOUNTbyESN ;
   end if  ;
   if FindMIN_excep%isopen
   then
   close FindMIN_excep ; --CR 53086
   end if  ;

   EXCEPTION
      WHEN OTHERS
      THEN
   if FindESN%isopen
   then
   close FindESN ;
   end if  ;
   if FindMIN%isopen
   then
   close FindMIN ;
   end if  ;
   if FindSIM%isopen
   then
   close FindSIM ;
   end if  ;
   if FindACCOUNT%isopen
   then
   close FindACCOUNT ;
   end if  ;
    if FindMINbyESN%isopen
   then
   close FindMINbyESN ;
   end if  ;
   if FindACCOUNTbyESN%isopen
   then
   close FindACCOUNTbyESN ;
   end if  ;
   if FindMIN_excep%isopen
   then
   close FindMIN_excep ;--CR 53086
   end if  ;

      op_result := SQLCODE;
      op_msg :=  'Error recording subscription' || SUBSTR (SQLERRM, 1, 100);

end  RecordSubscription;

PROCEDURE UpdateSubscriptionforMINC
-- *********************************************************
-- This service is called from IGATE_IN3 during a MINC transaction. Looks for
-- the min and deactivate the existing VAS and activate again for the new min
-- *********************************************************
  ( ip_oldmin in varchar2,
    ip_newmin in varchar2,
    op_result out number,
    op_msg out varchar2 )
as

cursor findMINC_c (IP_OLDMIN IN VARCHAR2) IS
  /* select *             cr29489 - removed "select *"   */
  select  objid,
          vas_esn,
          vas_min,
          vas_sim,
          vas_account,
          vas_name,
          vas_id,
          vas_x_ig_order_type,
          vas_subscription_date,
          vas_is_active,
          program_parameters_objid,
          part_inst_objid,
          web_user_objid,
          promotion_objid,
          program_purch_hdr_objid,
          x_purch_hdr_objid,
          addl_info,
          x_email,
          x_manufacturer,
          x_model_number,
          x_real_esn,
          vas_subscription_id,
          program_enrolled_id,
          status,
          vas_expiry_date,
          device_price_tier,
          ecommerce_order_id,
          vendor_contract_id
    from x_vas_subscriptions
   where vas_min = IP_OLDMIN -- '5703013742' --
     and vas_is_active = 'T'
     and vas_x_ig_order_type = 'A'
     and vas_name <> 'HPP BYOP'  /*  CR29489  condition added - AND VAS_NAME <> 'HPP BYOP'  */
     ;

findMINC_r findMINC_c%rowtype ;
BEGIN
  --
  op_result := 0 ;
  op_msg := 'Success' ;
  --
  FOR findMINC_r IN findMINC_c(IP_OLDMIN)
  LOOP
    --
    UPDATE  x_vas_subscriptions
    SET     VAS_X_IG_ORDER_TYPE = 'MINC',
            VAS_IS_ACTIVE       = 'F',
            ADDL_INFO           = 'OLD MIN: '||IP_OLDMIN||' NEW MIN: '||IP_NEWMIN,
            update_date         = SYSDATE
    WHERE   objid = FindMINC_r.objid ;
    COMMIT ;
    --
    -- CR49058 added new columns
    INSERT INTO x_vas_subscriptions
        ( objid,
          vas_esn,
          vas_min,
          vas_sim,
          vas_account,
          vas_name,
          vas_id,
          vas_x_ig_order_type,
          vas_subscription_date,
          vas_is_active,
          program_parameters_objid,
          part_inst_objid,
          web_user_objid,
          promotion_objid,
          program_purch_hdr_objid,
          x_purch_hdr_objid,
          addl_info,
          x_email,
          x_manufacturer,
          x_model_number,
          x_real_esn,
          vas_subscription_id,
          program_enrolled_id,
          status,
          vas_expiry_date,
          device_price_tier,
          ecommerce_order_id,
          vendor_contract_id)
    VALUES
        ( seq_x_vas_subscriptions.NEXTVAL,
          findminc_r.vas_esn,
          ip_newmin,
          findminc_r.vas_sim,
          findminc_r.vas_account,
          findminc_r.vas_name,
          findminc_r.vas_id,
          findminc_r.vas_x_ig_order_type,
          findminc_r.vas_subscription_date,
          'T',
          findminc_r.program_parameters_objid,
          findminc_r.part_inst_objid,
          findminc_r.web_user_objid,
          findminc_r.promotion_objid,
          findminc_r.program_purch_hdr_objid,
          findminc_r.x_purch_hdr_objid,
          findminc_r.addl_info,
          findminc_r.x_email,
          findminc_r.x_manufacturer,
          findminc_r.x_model_number,
          findminc_r.x_real_esn,
          findminc_r.vas_subscription_id,
          findminc_r.program_enrolled_id,
          findminc_r.status,
          findminc_r.vas_expiry_date,
          findminc_r.device_price_tier,
          findminc_r.ecommerce_order_id,
          findminc_r.vendor_contract_id) ;
    COMMIT ;
  END LOOP;
  --
  IF FindMINC_c%isopen
  THEN
    CLOSE FindMINC_c ;
  END IF ;
  --
EXCEPTION
  WHEN OTHERS
  THEN
  op_result := SQLCODE ;
  op_msg := 'Error recording subscription' || SUBSTR (SQLERRM, 1, 100);
END UpdateSubscriptionforMINC;
--
PROCEDURE   iseligibleForService (
-- *********************************************************
-- A service that returns "true" or "false" indicating whether or not a phone
-- is eligible for the specified VAS service.
-- Output:  is_eligible - boolean
-- *********************************************************
    ip_type          IN  VARCHAR2,
    ip_value         IN  VARCHAR2,
    ip_service_id    IN  VARCHAR2,
    op_is_eligible   OUT VARCHAR2, -- BOOLEAN,
    op_result        OUT NUMBER,
    op_msg           OUT VARCHAR2 )
as

  l_pc_objid number := 0;
  l_org_id varchar2(30) := null ;

begin

  op_is_eligible := 'F' ; -- ALSE ;
  op_result  := '0';
  op_msg  := 'Success';

-----------------------
  if ip_type is null or ip_value is null or ip_service_id is null
  then
     op_result := '604';
     op_msg := get_code_fun('VAS_MANAGEMENT_PKG','604','ENGLISH');
     sa.ota_util_pkg.err_log
     (p_action => get_code_fun('VAS_MANAGEMENT_PKG','604','ENGLISH')
     ,p_error_date   => SYSDATE,p_key => IP_TYPE
     ,p_program_name => 'VAS_MANAGEMENT_PKG.iseligibleForService'
     ,p_error_text   => op_msg);
     return ;
  end if ;
  if ip_type not in ('ESN','MIN','SIM','ACCOUNT')
  then
     op_result := '601';
     op_msg := get_code_fun('VAS_MANAGEMENT_PKG','601','ENGLISH');
     sa.ota_util_pkg.err_log
     (p_action => get_code_fun('VAS_MANAGEMENT_PKG','601','ENGLISH')
     ,p_error_date   => SYSDATE,p_key => IP_TYPE
     ,p_program_name => 'VAS_MANAGEMENT_PKG.iseligibleForService'
     ,p_error_text   => op_msg);
     return ;
  end if ;

  if ip_type = 'MIN'
  then
      open FindMIN(ip_value) ;
     fetch FindMIN into FindMIN_r;

        if FindMIN%found then
          l_pc_objid:=FindMIN_r.pc_objid;
          l_org_id:=FindMIN_r.org_id;
     close FindMIN ; -- CR24196
        else
          op_is_eligible := 'F' ; -- ALSE ;
        end if;
    end if ;
    if ip_type = 'ESN'
    then
        open FindESN(ip_value) ;
       fetch FindESN into FindESN_r;
          if FindESN%found then
              l_pc_objid:=FindESN_r.pc_objid;
              l_org_id:=FindESN_r.org_id;
          else
            op_is_eligible := 'F' ; -- ALSE ;
          end if;
    end if ;
    if ip_type = 'SIM'
    then
        open FindSIM(ip_value) ;
       fetch FindSIM into FindSIM_r;
          if FindSIM%found then
              l_pc_objid:=FindSIM_r.pc_objid;
              l_org_id:=FindSIM_r.org_id;
          else
            op_is_eligible := 'F' ; -- ALSE ;
          end if;
    end if ;
    if ip_type = 'ACCOUNT'
    then
        open FindACCOUNT(ip_value) ;
       fetch FindACCOUNT into FindACCOUNT_r;
          if FindACCOUNT%found then
              l_pc_objid:=FindACCOUNT_r.pc_objid;
              l_org_id:=FindACCOUNT_r.org_id;
          else
            op_is_eligible := 'F' ; -- ALSE ;
          end if;
    end if ;

    if l_pc_objid > 0 and l_org_id is not null
    then
        open FindEligible(l_org_id,ip_service_id ) ;
        fetch FindEligible into FindEligible_r;
        if FindEligible%found
        then
          op_is_eligible := 'T' ; --RUE ;
          close FindEligible ;
        else
            op_is_eligible := 'F' ; -- ALSE ;
        end if ;
    end if ;

   if FindESN%isopen
   then
   close FindESN ;
   end if  ;
   if FindMIN%isopen
   then
   close FindMIN ;
   end if  ;
   if FindSIM%isopen
   then
   close FindSIM ;
   end if  ;
   if FindACCOUNT%isopen
   then
   close FindACCOUNT ;
   end if  ;
   if FindEligible%isopen
   then
   close FindEligible;
   end if ;

EXCEPTION
   WHEN OTHERS
   THEN
  op_result  := '0';
  op_msg  := 'Error';

end iseligibleForService ;

PROCEDURE   getTransactionHistoryForPhone (
-- *********************************************************
-- This service returns the VAS transation history of a handset
-- Output:  view
-- *********************************************************
ip_type                     in varchar2, -- valid objects are ESN, MIN, SIM, ACCOUNT
ip_value                    in varchar2, -- this is the object
TransactionHistoryForPhone  out sys_refcursor,
op_result                   out number,
op_msg                      out varchar2 )
IS
begin
  op_result := '0';
  op_msg := 'Success';

  if ip_type not in ('ESN','MIN','SIM','ACCOUNT')
  then
     op_result := '601';
     op_msg := get_code_fun('VAS_MANAGEMENT_PKG','601','ENGLISH');
     sa.ota_util_pkg.err_log
     (p_action => get_code_fun('VAS_MANAGEMENT_PKG','601','ENGLISH')
     ,p_error_date   => SYSDATE,p_key => IP_TYPE
     ,p_program_name => 'VAS_MANAGEMENT_PKG.getTransactionHistoryForPhone'
     ,p_error_text   => op_msg);
     return ;
  end if ;
  if ip_type is null or ip_value is null
  then
     op_result := '604';
     op_msg := get_code_fun('VAS_MANAGEMENT_PKG','604','ENGLISH');
     sa.ota_util_pkg.err_log
     (p_action => get_code_fun('VAS_MANAGEMENT_PKG','604','ENGLISH')
     ,p_error_date   => SYSDATE,p_key => IP_TYPE
     ,p_program_name => 'VAS_MANAGEMENT_PKG.getTransactionHistoryForPhone'
     ,p_error_text   => op_msg);
     return ;
  end if ;
  if ip_type ='ESN'
  then
    open TransactionHistoryForPhone
    FOR
  /* select *             cr29489 - removed "select *"   */
      select OBJID    ,
              VAS_ESN    ,
              VAS_MIN    ,
              VAS_SIM    ,
              VAS_ACCOUNT    ,
              VAS_NAME    ,
              VAS_ID    ,
              VAS_X_IG_ORDER_TYPE    ,
              VAS_SUBSCRIPTION_DATE    ,
              VAS_IS_ACTIVE    ,
              PROGRAM_PARAMETERS_OBJID    ,
              PART_INST_OBJID    ,
              WEB_USER_OBJID    ,
              PROMOTION_OBJID    ,
              PROGRAM_PURCH_HDR_OBJID    ,
              X_PURCH_HDR_OBJID    ,
              ADDL_INFO
    from x_vas_subscriptions
    where vas_esn = ip_value
    AND   vas_id   IN ( SELECT  vas_service_id    -- CR49058 added this condition to include only ILD
                        FROM    vas_programs_view
                        WHERE   vas_category    = 'ILD_REUP')
    and vas_name <> 'HPP BYOP'  /*  CR29489  condition added - AND VAS_NAME <> 'HPP BYOP'  */
    ;
    if TransactionHistoryForPhone%NOTFOUND
    then
      op_result := '600';
      op_msg := get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH');
      sa.ota_util_pkg.err_log(p_action        => get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH')
                            ,p_error_date   => SYSDATE
                            ,p_key          =>  IP_VALUE
                            ,p_program_name => 'VAS_MANAGEMENT_PKG.TransactionHistoryForPhone'
                            ,p_error_text   => op_msg);
      close TransactionHistoryForPhone ;
      return ;
    end if ;
    --close TransactionHistoryForPhone ; do not close cursor
  end if ;
  if ip_type ='MIN'
  then
    open TransactionHistoryForPhone
    FOR
  /* select *             cr29489 - removed "select *"   */
      select OBJID    ,
              VAS_ESN    ,
              VAS_MIN    ,
              VAS_SIM    ,
              VAS_ACCOUNT    ,
              VAS_NAME    ,
              VAS_ID    ,
              VAS_X_IG_ORDER_TYPE    ,
              VAS_SUBSCRIPTION_DATE    ,
              VAS_IS_ACTIVE    ,
              PROGRAM_PARAMETERS_OBJID    ,
              PART_INST_OBJID    ,
              WEB_USER_OBJID    ,
              PROMOTION_OBJID    ,
              PROGRAM_PURCH_HDR_OBJID    ,
              X_PURCH_HDR_OBJID    ,
              ADDL_INFO
    from x_vas_subscriptions
    where vas_min = ip_value
    AND   vas_id   IN ( SELECT  vas_service_id    -- CR49058 added this condition to include only ILD
                        FROM    vas_programs_view
                        WHERE   vas_category    = 'ILD_REUP')
    and vas_name <> 'HPP BYOP'  /*  CR29489  condition added - AND VAS_NAME <> 'HPP BYOP'  */
    ;
    if TransactionHistoryForPhone%NOTFOUND
    then
      op_result := '600';
      op_msg := get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH');
      sa.ota_util_pkg.err_log(p_action        => get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH')
                            ,p_error_date   => SYSDATE
                            ,p_key          =>  IP_VALUE
                            ,p_program_name => 'VAS_MANAGEMENT_PKG.getTransactionHistoryForPhone'
                            ,p_error_text   => op_msg);
      close TransactionHistoryForPhone ;
      return ;
    end if ;
  --close TransactionHistoryForPhone ; do not close cursor
  end if ;
  if ip_type ='SIM'
  then
    open TransactionHistoryForPhone
    FOR
  /* select *             cr29489 - removed "select *"   */
      select OBJID    ,
              VAS_ESN    ,
              VAS_MIN    ,
              VAS_SIM    ,
              VAS_ACCOUNT    ,
              VAS_NAME    ,
              VAS_ID    ,
              VAS_X_IG_ORDER_TYPE    ,
              VAS_SUBSCRIPTION_DATE    ,
              VAS_IS_ACTIVE    ,
              PROGRAM_PARAMETERS_OBJID    ,
              PART_INST_OBJID    ,
              WEB_USER_OBJID    ,
              PROMOTION_OBJID    ,
              PROGRAM_PURCH_HDR_OBJID    ,
              X_PURCH_HDR_OBJID    ,
              ADDL_INFO
    from x_vas_subscriptions
    where vas_sim = ip_value
    AND   vas_id   IN ( SELECT  vas_service_id    -- CR49058 added this condition to include only ILD
                        FROM    vas_programs_view
                        WHERE   vas_category    = 'ILD_REUP')
    and vas_name <> 'HPP BYOP'  /*  CR29489  condition added - AND VAS_NAME <> 'HPP BYOP'  */
    ;
    if TransactionHistoryForPhone%NOTFOUND
    then
      op_result := '600';
      op_msg := get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH');
      sa.ota_util_pkg.err_log(p_action        => get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH')
                            ,p_error_date   => SYSDATE
                            ,p_key          =>  IP_VALUE
                            ,p_program_name => 'VAS_MANAGEMENT_PKG.TransactionHistoryForPhone'
                            ,p_error_text   => op_msg);
      close TransactionHistoryForPhone ;
      return ;
    end if ;
    --close TransactionHistoryForPhone ; do not close cursor
  end if ;
  if ip_type ='ACCOUNT'
  then
    open TransactionHistoryForPhone
    FOR
  /* select *             cr29489 - removed "select *"   */
      select OBJID    ,
              VAS_ESN    ,
              VAS_MIN    ,
              VAS_SIM    ,
              VAS_ACCOUNT    ,
              VAS_NAME    ,
              VAS_ID    ,
              VAS_X_IG_ORDER_TYPE    ,
              VAS_SUBSCRIPTION_DATE    ,
              VAS_IS_ACTIVE    ,
              PROGRAM_PARAMETERS_OBJID    ,
              PART_INST_OBJID    ,
              WEB_USER_OBJID    ,
              PROMOTION_OBJID    ,
              PROGRAM_PURCH_HDR_OBJID    ,
              X_PURCH_HDR_OBJID    ,
              ADDL_INFO
    from x_vas_subscriptions
    where vas_account = ip_value
    AND   vas_id   IN ( SELECT  vas_service_id    -- CR49058 added this condition to include only ILD
                        FROM    vas_programs_view
                        WHERE   vas_category    = 'ILD_REUP')
    and vas_name <> 'HPP BYOP'  /*  CR29489  condition added - AND VAS_NAME <> 'HPP BYOP'  */
    ;
    if TransactionHistoryForPhone%NOTFOUND
    then
      op_result := '600';
      op_msg := get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH');
      sa.ota_util_pkg.err_log(p_action        => get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH')
                            ,p_error_date   => SYSDATE
                            ,p_key          =>  IP_VALUE
                            ,p_program_name => 'VAS_MANAGEMENT_PKG.getTransactionHistoryForPhone'
                            ,p_error_text   => op_msg);
      close TransactionHistoryForPhone ;
      return ;
    end if ;
  --close TransactionHistoryForPhone ; do not close cursor
  end if ;
  close TransactionHistoryForPhone ;
end getTransactionHistoryForPhone ;

PROCEDURE   getEnrolledServicesForPhone (
-- *********************************************************
-- This service returns all active VAS services a phone is currently enrolled in.
-- Output:  From X_VAS_SUBSCRIPTIONS table
-- *********************************************************
ip_type                   in varchar2, -- valid objects are ESN, MIN, SIM, ACCOUNT
ip_value                  in varchar2, -- this is the object
EnrolledServicesForPhone  out sys_refcursor,
op_result                 out number,
op_msg                    out varchar2 )
IS
begin
  op_result := '0';
  op_msg := 'Success' ;

  if ip_type not in ('ESN','MIN','SIM','ACCOUNT')
  then
     op_result := '601';
     op_msg := get_code_fun('VAS_MANAGEMENT_PKG','601','ENGLISH');
     sa.ota_util_pkg.err_log
     (p_action => get_code_fun('VAS_MANAGEMENT_PKG','601','ENGLISH')
     ,p_error_date   => SYSDATE,p_key => IP_TYPE
     ,p_program_name => 'VAS_MANAGEMENT_PKG.getEnrolledServicesForPhone'
     ,p_error_text   => op_msg);
     return ;
  end if ;
  if ip_type ='ESN'
  then
    open EnrolledServicesForPhone
    FOR
  /* select *             cr29489 - removed "select *"   */
      select OBJID    ,
              VAS_ESN    ,
              VAS_MIN    ,
              VAS_SIM    ,
              VAS_ACCOUNT    ,
              VAS_NAME    ,
              VAS_ID    ,
              VAS_X_IG_ORDER_TYPE    ,
              VAS_SUBSCRIPTION_DATE    ,
              VAS_IS_ACTIVE    ,
              PROGRAM_PARAMETERS_OBJID    ,
              PART_INST_OBJID    ,
              WEB_USER_OBJID    ,
              PROMOTION_OBJID    ,
              PROGRAM_PURCH_HDR_OBJID    ,
              X_PURCH_HDR_OBJID    ,
              ADDL_INFO
    from x_vas_subscriptions
    where vas_esn = ip_value
    AND   vas_id   IN ( SELECT  vas_service_id    -- CR49058 added this condition to include only ILD
                        FROM    vas_programs_view
                        WHERE   vas_category    = 'ILD_REUP')
    and vas_name <> 'HPP BYOP'  /*  CR29489  condition added - AND VAS_NAME <> 'HPP BYOP'  */
    ;
    if EnrolledServicesForPhone%NOTFOUND
    then
      op_result := '600';
      op_msg := get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH');
      sa.ota_util_pkg.err_log(p_action        => get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH')
                            ,p_error_date   => SYSDATE
                            ,p_key          =>  IP_VALUE
                            ,p_program_name => 'VAS_MANAGEMENT_PKG.getEnrolledServicesForPhone'
                            ,p_error_text   => op_msg);
      close EnrolledServicesForPhone ;
      return ;
    end if ;
    --close EnrolledServicesForPhone ; do not close cursor
  end if ;
  if ip_type ='MIN'
  then
    open EnrolledServicesForPhone
    FOR
  /* select *             cr29489 - removed "select *"   */
      select OBJID    ,
              VAS_ESN    ,
              VAS_MIN    ,
              VAS_SIM    ,
              VAS_ACCOUNT    ,
              VAS_NAME    ,
              VAS_ID    ,
              VAS_X_IG_ORDER_TYPE    ,
              VAS_SUBSCRIPTION_DATE    ,
              VAS_IS_ACTIVE    ,
              PROGRAM_PARAMETERS_OBJID    ,
              PART_INST_OBJID    ,
              WEB_USER_OBJID    ,
              PROMOTION_OBJID    ,
              PROGRAM_PURCH_HDR_OBJID    ,
              X_PURCH_HDR_OBJID    ,
              ADDL_INFO
    from x_vas_subscriptions
    where vas_min = ip_value
    AND   vas_id   IN ( SELECT  vas_service_id    -- CR49058 added this condition to include only ILD
                        FROM    vas_programs_view
                        WHERE   vas_category    = 'ILD_REUP')
    and vas_name <> 'HPP BYOP'  /*  CR29489  condition added - AND VAS_NAME <> 'HPP BYOP'  */
    ;
    if EnrolledServicesForPhone%NOTFOUND
    then
      op_result := '600';
      op_msg := get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH');
      sa.ota_util_pkg.err_log(p_action        => get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH')
                            ,p_error_date   => SYSDATE
                            ,p_key          =>  IP_VALUE
                            ,p_program_name => 'VAS_MANAGEMENT_PKG.getEnrolledServicesForPhone'
                            ,p_error_text   => op_msg);
      close EnrolledServicesForPhone ;
      return ;
    end if ;
  --close EnrolledServicesForPhone ; do not close cursor
  end if ;
  if ip_type ='SIM'
  then
    open EnrolledServicesForPhone
    FOR
  /* select *             cr29489 - removed "select *"   */
      select OBJID    ,
              VAS_ESN    ,
              VAS_MIN    ,
              VAS_SIM    ,
              VAS_ACCOUNT    ,
              VAS_NAME    ,
              VAS_ID    ,
              VAS_X_IG_ORDER_TYPE    ,
              VAS_SUBSCRIPTION_DATE    ,
              VAS_IS_ACTIVE    ,
              PROGRAM_PARAMETERS_OBJID    ,
              PART_INST_OBJID    ,
              WEB_USER_OBJID    ,
              PROMOTION_OBJID    ,
              PROGRAM_PURCH_HDR_OBJID    ,
              X_PURCH_HDR_OBJID    ,
              ADDL_INFO
    from x_vas_subscriptions
    where vas_sim = ip_value
    AND   vas_id   IN ( SELECT  vas_service_id    -- CR49058 added this condition to include only ILD
                        FROM    vas_programs_view
                        WHERE   vas_category    = 'ILD_REUP')
    and vas_name <> 'HPP BYOP'  /*  CR29489  condition added - AND VAS_NAME <> 'HPP BYOP'  */
    ;
    if EnrolledServicesForPhone%NOTFOUND
    then
      op_result := '600';
      op_msg := get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH');
      sa.ota_util_pkg.err_log(p_action        => get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH')
                            ,p_error_date   => SYSDATE
                            ,p_key          =>  IP_VALUE
                            ,p_program_name => 'VAS_MANAGEMENT_PKG.getEnrolledServicesForPhone'
                            ,p_error_text   => op_msg);
      close EnrolledServicesForPhone ;
      return ;
    end if ;
    --close EnrolledServicesForPhone ; do not close cursor
  end if ;
  if ip_type ='ACCOUNT'
  then
    open EnrolledServicesForPhone
    FOR
  /* select *             cr29489 - removed "select *"   */
      select OBJID    ,
              VAS_ESN    ,
              VAS_MIN    ,
              VAS_SIM    ,
              VAS_ACCOUNT    ,
              VAS_NAME    ,
              VAS_ID    ,
              VAS_X_IG_ORDER_TYPE    ,
              VAS_SUBSCRIPTION_DATE    ,
              VAS_IS_ACTIVE    ,
              PROGRAM_PARAMETERS_OBJID    ,
              PART_INST_OBJID    ,
              WEB_USER_OBJID    ,
              PROMOTION_OBJID    ,
              PROGRAM_PURCH_HDR_OBJID    ,
              X_PURCH_HDR_OBJID    ,
              ADDL_INFO
    from x_vas_subscriptions
    where vas_account = ip_value
    AND   vas_id   IN ( SELECT  vas_service_id    -- CR49058 added this condition to include only ILD
                        FROM    vas_programs_view
                        WHERE   vas_category    = 'ILD_REUP')
    and vas_name <> 'HPP BYOP'  /*  CR29489  condition added - AND VAS_NAME <> 'HPP BYOP'  */
    ;
    if EnrolledServicesForPhone%NOTFOUND
    then
      op_result := '600';
      op_msg := get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH');
      sa.ota_util_pkg.err_log(p_action        => get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH')
                            ,p_error_date   => SYSDATE
                            ,p_key          =>  IP_VALUE
                            ,p_program_name => 'VAS_MANAGEMENT_PKG.getEnrolledServicesForPhone'
                            ,p_error_text   => op_msg);
      close EnrolledServicesForPhone ;
      return ;
    end if ;
  --close EnrolledServicesForPhone ; do not close cursor
  end if ;
  if FindESN%isopen
  then
     close FindESN ;
  end if  ;
  if FindMIN%isopen
  then
    close FindMIN ;
  end if  ;
  if FindSIM%isopen
  then
    close FindSIM ;
  end if  ;
  if FindACCOUNT%isopen
  then
    close FindACCOUNT ;
  end if  ;

end getEnrolledServicesForPhone ;
--CR47191

PROCEDURE   getAvailableServicesForPhone (
ip_type          IN   VARCHAR2,
ip_value         IN   VARCHAR2,
ServicesforPhone OUT SYS_REFCURSOR,
op_return_value  OUT NUMBER,
op_return_string OUT VARCHAR2
)
IS
BEGIN

	sa.vas_management_pkg.getavailableservicesforphone (ip_type,
							   ip_value,
							   ServicesforPhone,
							   op_return_value,
							   op_return_string,
							   NULL
						   );



END;

--CR47191

PROCEDURE   getAvailableServicesForPhone (
-- *********************************************************
-- Desc:  This service returns a list of VAS services available to a phone model.
--        Uses the X_MTM_PROGRAM_HANDSET_EXCLUSION table that links Programs to Models
-- Output: List of VAS Service Objects
-- *********************************************************
   ip_type          IN   VARCHAR2,
   ip_value         IN   VARCHAR2,
   ServicesforPhone OUT  SYS_REFCURSOR,
   op_return_value  OUT  NUMBER,
   op_return_string OUT  VARCHAR2,
   ip_sourcesystem  IN	 VARCHAR2
   ) IS

   l_pc_objid  number := 0;
   l_org_id    varchar2(30) := null ;
   l_vas_type  x_vas_values.vas_param_value%type := 'STANDALONE';  -- CR31545 SL CA HOME PHONE AR

   --CR52398 --Start
   n_bus_org_objid NUMBER;
   --CR52398 --End

  CURSOR esn_sp_cur(c_esn IN table_part_inst.part_serial_no%TYPE)
  IS
   SELECT sp.objid
    FROM x_service_plan_site_part spsp, x_service_plan sp, table_site_part tsp
    WHERE tsp.x_service_id = c_esn
    AND tsp.objid = DECODE((SELECT COUNT(1) FROM table_site_part WHERE x_service_id = c_esn AND part_status = 'Active'),
                            1,
                           (SELECT objid FROM table_site_part WHERE x_service_id = c_esn AND part_status    = 'Active'),
                           (SELECT MAX(objid) FROM table_site_part WHERE x_service_id = c_esn AND part_status   <> 'Obsolete') -- could be inactive too?
                          )
    AND sp.objid = spsp.x_service_plan_id
    AND spsp.table_site_part_id = tsp.objid;

  esn_sp_rec   esn_sp_cur%ROWTYPE;


  -- Cursor to check if Enrolled in SafeLink ESN -- CR31545 SL CA HOME PHONE AR
  -- cursor checksl (IP_ESN VARCHAR2) IS
  CURSOR checksl (in_key IN VARCHAR2, in_value IN VARCHAR2)
  IS
    SELECT slcur.lid
    FROM
      x_program_enrolled pe,
      x_program_parameters pgm,
      x_sl_currentvals slcur,
      x_sl_subs slsub,
      sa.mtm_program_safelink ps,
      table_site_part tsp
    WHERE 1 = 1
      AND pgm.objid = pe.pgm_enroll2pgm_parameter
      AND slcur.x_current_esn = pe.x_esn
      AND slcur.lid = slsub.lid
      AND ps.program_param_objid = pgm.objid
      AND sysdate BETWEEN ps.start_date AND ps.end_date
      AND pgm.x_prog_class = 'LIFELINE'
      AND pe.x_sourcesystem in ('VMBC', 'WEB')
      AND pgm.x_is_recurring = 1
    --  and pe.x_esn = IP_ESN
      AND pe.x_enrollment_status   = 'ENROLLED'
      AND tsp.x_service_id = pe.x_esn
      AND tsp.x_service_id = slcur.x_current_esn
      AND tsp.part_status || '' = 'Active'
      AND (
            (in_key = 'ESN' AND tsp.x_service_id  = in_value )
         OR (in_key = 'MIN' AND tsp.x_min         = in_value )
        );
  rec_checksl checksl%ROWTYPE;

  lv_part_serial_no		    table_site_part.x_service_id%TYPE;	--CR47191
  lv_min			            table_site_part.x_min%type;		      --CR47191
  lv_ild_purch_limit		  NUMBER;					                    --CR47191
  lv_ild_purch_exceed		  NUMBER :=	0;
  lv_ild_purch_limit_days	NUMBER;
  --CR48517 B2B ILD AddOn
  lv_b2b_err_num          NUMBER;
  lv_b2b_err_msg          VARCHAR2(30);

BEGIN
  op_return_value  := '0' ;
  op_return_string := 'Success' ;

  --CR47191 -- Initializing ref cursor
	OPEN ServicesforPhone
	FOR SELECT * FROM VAS_PROGRAMS_VIEW
	WHERE 1 = 2
	;
  --CR47191 -- Initializing ref cursor

  IF ip_type = 'MIN'
  THEN
    OPEN FindMIN(ip_value) ;
    FETCH FindMIN INTO FindMIN_r;

    IF FindMIN%FOUND
    THEN
      l_pc_objid        := findmin_r.pc_objid;
      l_org_id          := findmin_r.org_id;
      lv_part_serial_no	:=	findmin_r.x_service_id;		--CR47191
      OPEN esn_sp_cur(findmin_r.x_service_id);  -- get service plan by esn
      FETCH esn_sp_cur INTO esn_sp_rec;
      CLOSE esn_sp_cur;

      -- CR31545 SL CA HOME PHONE AR
      OPEN checksl (ip_type, ip_value);
      FETCH checksl INTO rec_checksl ;

      IF checksl%FOUND
      THEN
        l_vas_type := 'SAFELINK';
        CLOSE checksl;
      --CR48517 Check if the MIN is B2B and change the vas_type
      ELSIF (sa.b2b_pkg.is_b2b (ip_type, ip_value, NULL, lv_b2b_err_num, lv_b2b_err_msg) = 1)
      THEN
        l_vas_type := 'B2B';
      END IF;

    ELSE
          op_return_value := 0 ; --'NOT FOUND';
    END IF;
    close FindMIN ;
  END IF ;

  IF ip_type = 'ESN'
  THEN
    -- check sl esn
    -- open checksl(ip_value) ;
    -- fetch checksl into rec_checksl;

    -- if checksl%found then  -- if sl esn -->start
    -- open ServicesforPhone for select * from VAS_PROGRAMS_VIEW where 1 = 2;
    --
    -- else -- no sl esn found

    OPEN FindESN(ip_value) ;
    FETCH FindESN INTO FindESN_r;
    IF FindESN%FOUND
    THEN
      l_pc_objid        := FindESN_r.pc_objid;
      l_org_id          := findesn_r.org_id;
	    lv_part_serial_no	:=	findesn_r.part_serial_no;		--CR47191
      OPEN esn_sp_cur(findesn_r.part_serial_no);  -- get service plan by esn
      FETCH esn_sp_cur INTO esn_sp_rec;
      CLOSE esn_sp_cur;

      -- CR31545 SL CA HOME PHONE AR
      OPEN checksl (ip_type, ip_value);
      FETCH checksl INTO rec_checksl ;
      IF checksl%FOUND
      THEN
        l_vas_type := 'SAFELINK';
        CLOSE checksl;
      ELSIF (sa.b2b_pkg.is_b2b (ip_type, ip_value, NULL, lv_b2b_err_num, lv_b2b_err_msg) = 1)
      THEN
        l_vas_type := 'B2B';
      END IF;

    ELSE
      op_return_value := 0 ; --'NOT FOUND';
    END IF;

    -- end if; -- if sl esn -->end

  END IF;

  if ip_type = 'SIM'
  then
        open FindSIM(ip_value) ;
       fetch FindSIM into FindSIM_r;
          if FindSIM%found then
              l_pc_objid:=FindSIM_r.pc_objid;
              l_org_id:=findsim_r.org_id;
	      lv_part_serial_no	:=	FindSIM_r.part_serial_no;		--CR47191
              open esn_sp_cur(FindSIM_r.part_serial_no);  -- get service plan by esn
              fetch esn_sp_cur into esn_sp_rec;
              close esn_sp_cur;
          else
            op_return_value := 0 ; --'NOT FOUND';
          end if;
    end if ;
    if ip_type = 'ACCOUNT'
    then
        open FindACCOUNT(ip_value) ;
       fetch FindACCOUNT into FindACCOUNT_r;
          if FindACCOUNT%found then
              l_pc_objid:=FindACCOUNT_r.pc_objid;
              l_org_id:=findaccount_r.org_id;
	      lv_part_serial_no	:=	findaccount_r.part_serial_no;		--CR47191
              open esn_sp_cur(findaccount_r.part_serial_no);  -- get service plan by esn
              fetch esn_sp_cur into esn_sp_rec;
              close esn_sp_cur;
          else
            op_return_value := 0 ; --'NOT FOUND';
          end if;
  end if ;

  --CR47191
  IF 	NVL(ip_sourcesystem,'X')	<> 'TAS'
  THEN

    BEGIN
      SELECT  sp.x_min
      INTO lv_min
      FROM table_part_inst pi, table_site_part sp
      WHERE pi.part_serial_no 	=	lv_part_serial_no
      AND pi.x_domain			=	'PHONES'
      AND pi.x_part_inst2site_part 	= 	sp.objid
      AND sp.part_status		=	'Active'
      AND rownum = 1
      ;
    EXCEPTION WHEN OTHERS
    THEN
	    lv_min	:= NULL;
    END;

    BEGIN
      SELECT X_PARAM_VALUE
      INTO lv_ild_purch_limit
      FROM TABLE_X_PARAMETERS
      WHERE X_PARAM_NAME = 'ILD_CARD_PURCHASE_LIMIT'
      ;

      SELECT X_PARAM_VALUE
      INTO lv_ild_purch_limit_days
      FROM TABLE_X_PARAMETERS
      WHERE X_PARAM_NAME = 'ILD_CARD_PURCHASE_LIMIT_DAYS'
      ;

    EXCEPTION WHEN OTHERS
    THEN
	    lv_ild_purch_limit		:=	9;
	    lv_ild_purch_limit_days		:=	30;
    END;


    IF sa.VAS_MANAGEMENT_PKG.GET_ILD_PURCHASE_COUNT(lv_part_serial_no,lv_min,lv_ild_purch_limit_days) >= lv_ild_purch_limit
    THEN
		  lv_ild_purch_exceed	:=	1;
    ELSE
		  lv_ild_purch_exceed	:=	0;
    END IF;

  END IF;

  --CR47191
  IF lv_ild_purch_exceed	=	1  AND NVL(ip_sourcesystem,'X')	<> 'TAS'
  THEN

	  OPEN ServicesforPhone
	  FOR SELECT * FROM VAS_PROGRAMS_VIEW
	  WHERE 1 = 2
	  ;

	  op_return_value := 1 ;
    op_return_string := 'ILD Card Purchases Exceed Limit Of '||lv_ild_purch_limit||' Over Last 30 Days.' ;


  ELSIF l_pc_objid > 0
  then
    open FindServiceforPhone(l_pc_objid, l_org_ID) ;
    fetch FindServiceforPhone into FindServiceforPhone_r;
    if FindServiceforPhone%found
    then
      op_return_value:=l_pc_objid;
      dbms_output.put_line('1 op_return_value : ' || op_return_value) ;
      op_return_string := 'select * from VAS_PROGRAMS_HANDSETS_VIEW where part_class_objid = ' || op_return_value || ';' ;

      IF (esn_sp_rec.objid IS NULL) THEN  -- service plan is not available, check by part class
          open ServicesforPhone
          for select * from VAS_PROGRAMS_VIEW vpv_out where vas_service_id not in
            (select vas_service_id
             from mtm_vas_handset_EXCLUSION MTM, vas_programs_view vpv, table_part_class pc
            where mtm.vas_programs_objid = vpv.vas_service_id
              and mtm.part_class_objid=pc.objid
              and pc.objid = l_PC_OBJID )  -- 536942989 )
              AND vas_bus_org = l_ORG_ID
              AND vas_category  = 'ILD_REUP'  -- CR49058
              /* Commented and modified for CR40404
		AND vas_type = l_vas_type;   -- CR31545 SL CA HOME PHONE AR
		*/
              AND vas_type = l_vas_type; --DECODE(l_ORG_ID,'TRACFONE',vas_type,l_vas_type)   -- CR31545 SL CA HOME PHONE AR
		                  --CR40708 removed the hardcoded for TRACFONE in above decode
      ELSE
          open ServicesforPhone
          for select * from VAS_PROGRAMS_VIEW vpv_out where vas_service_id not in
            (select vas_service_id
             from mtm_vas_handset_EXCLUSION MTM, vas_programs_view vpv, x_service_plan sp
            where mtm.vas_programs_objid = vpv.vas_service_id
              and mtm.service_plan_objid=sp.objid
              and sp.objid = esn_sp_rec.objid)
              AND vas_bus_org = l_org_id
              AND vas_category  = 'ILD_REUP'  -- CR49058
              /* Commented and modified for CR40404
		AND vas_type = l_vas_type;   -- CR31545 SL CA HOME PHONE AR
		*/
              AND vas_type = l_vas_type;--DECODE(l_ORG_ID,'TRACFONE',vas_type,l_vas_type)   -- CR31545 SL CA HOME PHONE AR
		          --CR40708 removed the hardcoded  TRACFONE in above decode
      END IF;

      close FindServiceforPhone ;
    else
      op_return_value := 0 ; -- 'NOT FOUND';
      op_return_string :='NOT FOUND' ;
    end if ;
    end if ;

    --CR52398 Web common standard for Simple mobile --Start

    --Input validation
    IF ip_type IS NULL OR ip_value IS NULL THEN
       op_return_value  := -1;
       op_return_string := 'Input type or value cannot be null';
       RETURN;
    END IF;
    --
    IF ip_type = 'BRAND' THEN

       --Brand validation
       n_bus_org_objid := sa.customer_info.get_bus_org_objid(i_bus_org_id => ip_value);

       dbms_output.put_line('n_bus_org_objid: '||n_bus_org_objid);

       IF n_bus_org_objid IS NULL THEN
          op_return_value  := -1;
          op_return_string := 'Invalid Brand: '||ip_value;
          RETURN;
       END IF;

       OPEN ServicesforPhone
       FOR
       SELECT * FROM vas_programs_view
       WHERE vas_bus_org = ip_value
       AND   vas_category  = 'ILD_REUP'  -- CR49058
       AND   vas_type NOT IN ('SAFELINK','B2B'); -- CR53217: restrict Safeline VAS programs; -- CR48517 Restrict B2B NT WCS fix

    END IF;
    --CR52398 Web common standard for Simple mobile --End

    IF FindESN%ISOPEN THEN
      close FindESN ;
    END IF;
    IF FindMIN%ISOPEN THEN
      close FindMIN ;
    END IF;
   if FindSIM%isopen
   then
     close FindSIM ;
   end if  ;
   if FindACCOUNT%isopen
   then
     close FindACCOUNT ;
   end if  ;
   IF FindServiceforPhone%ISOPEN THEN
      close FindServiceforPhone;
   end if;
   IF esn_sp_cur%ISOPEN THEN
      close esn_sp_cur;
   end if;
   IF checksl%ISOPEN THEN
      CLOSE checksl;
   END IF;

EXCEPTION
WHEN OTHERS
THEN
  DBMS_OUTPUT.PUT_LINE('ERROR_MESSAGE: ' || SQLERRM);
  op_return_value  := 0;
  op_return_string := 'IS NULL' ;

END getAvailableServicesForPhone ;

PROCEDURE getServices (
-- *********************************************************
-- A basic service that returns available VAS services from VAS_PROGRAMS_VIEW
-- Output:  List of VAS Service Objects filtered by BUSINESS
-- *********************************************************
ip_bus_org  in varchar2, -- BRAND required
Services    out sys_refcursor,
op_result   out number,
op_msg      out varchar2 ) AS

begin
  op_result := '0';
  op_msg := 'Success' ;

  open Services
  for select * from vas_programs_view
  where vas_start_date < = sysdate
    and vas_end_date > = sysdate
    and vas_is_active='T'
    and VAS_BUS_ORG = ip_bus_org -- 'NET10' ; --
    AND vas_category  = 'ILD_REUP'  -- CR49058
    and vas_type NOT IN ('SAFELINK', 'B2B');  -- CR31545 SL CA HOME PHONE AR, CR48517 B2B ILD AddOn
  if Services%NOTFOUND
  then
    op_result := '600';
    op_msg := get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH');
    sa.ota_util_pkg.err_log(p_action      => get_code_fun('VAS_MANAGEMENT_PKG','600','ENGLISH')
                          ,p_error_date   => SYSDATE
                          ,p_key          =>  ip_bus_org
                          ,p_program_name => 'VAS_MANAGEMENT_PKG.GETSERVICES'
                          ,p_error_text   => op_msg);
      -- close Services ; we dont close the cursor JAVA team closes the cursor
      return ;
  end if ;
end getServices ; -- end getServices

PROCEDURE   getCounterByEvent (
-- *********************************************************
-- This service returns the curent count of a specific value and event
-- Output:  number
-- X_VAS_EVENT_COUNTER(OBJID,VAS_OBJECTVALUE,VAS_EVENT,OBJECTVALUE_EVENT_COUNTER)
-- *********************************************************

ip_value                    in varchar2, -- this is the object
ip_event                    in varchar2,
op_counter                  out number,
op_result                   out number,
op_msg                      out varchar2 ) as

begin
op_counter := 0 ;
op_result := '0';
op_msg := NULL;

if ip_value is null or ip_event is null
  then
     op_result := '601';
     op_msg := get_code_fun('VAS_MANAGEMENT_PKG','601','ENGLISH');
     sa.ota_util_pkg.err_log
     (p_action => get_code_fun('VAS_MANAGEMENT_PKG','601','ENGLISH')
     ,p_error_date   => SYSDATE,p_key => IP_VALUE
     ,p_program_name => 'VAS_MANAGEMENT_PKG.getCounterByEvent'
     ,p_error_text   => op_msg);
     return ;
  end if ;

open EVENT_COUNTER_CURSOR (IP_VALUE,IP_EVENT) ;
fetch EVENT_COUNTER_CURSOR into EVENT_COUNTER_row;
if event_counter_cursor%found then
  op_counter :=event_counter_row.objectvalue_event_counter;
else
  op_counter := 0 ; --'NOT FOUND';
end if;
close EVENT_COUNTER_CURSOR ;

end getCounterByEvent ;

PROCEDURE   IncrementCounterForEvent (
-- *********************************************************
-- This service increments the counter of a specific event and account identifier
-- Output:  op_counter after update
-- *********************************************************
ip_value                    in varchar2, -- this is the object
ip_event                    in varchar2,
ip_step                     in number,
op_counter                  out number,
op_result                   out varchar2,
op_msg                      out varchar2 ) as

increment_counter number := 0 ;

begin

  op_counter := 0 ;
  op_result :='0' ;
  op_msg :='Success' ;

  open EVENT_COUNTER_CURSOR (IP_VALUE,IP_EVENT) ;
  fetch EVENT_COUNTER_CURSOR into EVENT_COUNTER_row;
  if event_counter_cursor%found then
    increment_counter := EVENT_COUNTER_ROW.OBJECTVALUE_EVENT_COUNTER ;
    update X_VAS_EVENT_COUNTER
        set OBJECTVALUE_EVENT_COUNTER = OBJECTVALUE_EVENT_COUNTER + ip_step
      where VAS_OBJECTVALUE = ip_value and VAS_EVENT = ip_event ;
     commit ;
  else
    insert into sa.X_VAS_EVENT_COUNTER (
      OBJID, VAS_OBJECTVALUE, VAS_EVENT, OBJECTVALUE_EVENT_COUNTER)
    values
      (sequ_x_VAS_EVENT_COUNTER.NEXTVAL, ip_value, ip_event, ip_step) ;
    commit ;
  end if;
  increment_counter := increment_counter + ip_step ;
  op_counter := increment_counter ;
  close EVENT_COUNTER_CURSOR ;
end IncrementCounterForEvent ;

------------------------
PROCEDURE   getServiceforPIN (
-- *********************************************************
-- This service returns the service of the pin entered
-- Output:  service_id
-- *********************************************************

ip_PIN                      in varchar2, -- this is the pin
ip_esn                      in varchar2 default null,
op_service_id               out number,
op_result                   out varchar2,
op_msg                      out varchar2 ) as

l_sl_cnt       NUMBER := 0;
l_vas_type     VARCHAR2(30) := 'STANDALONE';
lv_b2b_err_num NUMBER;       --CR48517 B2B ILD AddOn
lv_b2b_err_msg VARCHAR2(30); --CR48517
begin

  op_result := '0' ;
  op_msg := 'Success' ;

  IF ip_pin IS NULL
  THEN
     op_result := '603';
     op_msg := get_code_fun('VAS_MANAGEMENT_PKG','603','ENGLISH');
     sa.ota_util_pkg.err_log
     (p_action       => get_code_fun('VAS_MANAGEMENT_PKG','603','ENGLISH')
     ,p_error_date   => SYSDATE
     ,p_key          => IP_PIN
     ,p_program_name => 'VAS_MANAGEMENT_PKG.getServiceforPIN'
     ,p_error_text   => op_msg);
    op_result := '603' ;
    op_msg := 'Pin is Invalid' ;
    RETURN ;
  END IF ;
  -- CR40708 BEGIN
  -- The TRACFONE ILD 10 has two ILD PRODUCTS, the below logic will return the right product id for safelink esn
  IF ip_esn IS NOT NULL THEN
    SELECT COUNT(1)
    INTO   l_sl_cnt
    FROM   x_program_enrolled pe,
           x_program_parameters pgm,
           x_sl_currentvals slcur,
           x_sl_subs slsub,
           sa.mtm_program_safelink ps,
           table_site_part tsp
     WHERE 1 = 1
       AND pgm.objid = pe.pgm_enroll2pgm_parameter
       AND slcur.x_current_esn = pe.x_esn
       AND slcur.lid = slsub.lid
       AND ps.program_param_objid = pgm.objid
       AND sysdate BETWEEN ps.start_date AND ps.end_date
       AND pgm.x_prog_class = 'LIFELINE'
       AND pe.x_sourcesystem in ('VMBC', 'WEB')
       AND pgm.x_is_recurring = 1
     --  and pe.x_esn = IP_ESN
       AND pe.x_enrollment_status   = 'ENROLLED'
       AND tsp.x_service_id = pe.x_esn
       AND tsp.x_service_id = slcur.x_current_esn
       AND tsp.part_status || '' = 'Active'
       AND tsp.x_service_id  = ip_esn;

    IF l_sl_cnt >= 1
    THEN
      l_vas_type := 'SAFELINK';
    ELSIF (sa.b2b_pkg.is_b2b (ip_esn, 'ESN', NULL, lv_b2b_err_num, lv_b2b_err_msg) = 1)
    THEN
      l_vas_type := 'B2B';
    END IF;

    END IF;

  FOR  findServiceforPIN_R in findServiceforPIN (IP_PIN)
  loop
     -- DBMS_OUTPUT.PUT_LINE('vas_bus_org :'||findServiceforPIN_R.vas_bus_org);
     -- DBMS_OUTPUT.PUT_LINE('vas_type :'||findServiceforPIN_R.vas_type);
      IF findServiceforPIN_R.vas_bus_org != 'TRACFONE' THEN
         op_service_id := findServiceforPIN_R.vas_service_id ;
      ELSE
          IF findServiceforPIN_R.vas_type = l_vas_type THEN
             op_service_id := findServiceforPIN_R.vas_service_id ;
          END IF;
      END IF;
  end loop;

  IF op_service_id IS NULL THEN
      op_result     := '603' ;
      op_msg        := 'service not found' ;
  END IF;
  --CR40708 END
	 --Commented as part of CR40708
	 /*
	open findServiceforPIN (IP_PIN) ;
	fetch findServiceforPIN into findServiceforPIN_R;
	if findServiceforPIN%found then
	  op_service_id := findServiceforPIN_R.vas_service_id ;
	else
	  op_service_id := null ; --'NOT FOUND';
	  op_result := '603' ;
	  op_msg := 'service not found' ;

	end if;
	close findServiceforPIN ;
	*/
end getServiceforPIN ;

FUNCTION get_vas_service_id_by_pin(in_pin  IN  table_part_inst.x_red_code%TYPE) RETURN x_vas_programs.objid%TYPE IS
 --
 CURSOR vas_pgm_view_cur IS
 SELECT vpv1.vas_service_id
  FROM vas_programs_view vpv1
 WHERE 1=1
 AND EXISTS (SELECT 1
              FROM vas_programs_view vpv2
             WHERE vpv2.vas_service_id = vpv1.vas_service_id
              AND vpv2.vas_card_class = bau_util_pkg.get_pin_part_class(in_pin)
            )
 AND SYSDATE BETWEEN vas_start_date AND vas_end_date;
 --AND vas_type <> 'SAFELINK';  -- CR31545 SL CA HOME PHONE AR
 --CR39723 commented the safelink because it should allow the redemption
 vas_service_id   x_vas_programs.objid%TYPE;
 --
BEGIN
  --
  IF (in_pin IS NOT NULL) THEN
    OPEN vas_pgm_view_cur;
    FETCH vas_pgm_view_cur INTO vas_service_id;
    CLOSE vas_pgm_view_cur;
  END IF;
  --
  RETURN vas_service_id;
  --
END get_vas_service_id_by_pin;

FUNCTION get_vas_service_param_val(in_vas_id    IN x_vas_programs.objid%TYPE,
                                   in_vas_param IN x_vas_params.vas_param_name%TYPE) RETURN x_vas_values.vas_param_value%TYPE IS
 --
 CURSOR vas_param_val_cur IS
 SELECT vas_param_value
  FROM vas_params_view
 WHERE vas_service_id = in_vas_id
  AND vas_param_name = in_vas_param;
 vas_param_val   x_vas_values.vas_param_value%TYPE;
 --
BEGIN
  --
  IF (in_vas_id IS NOT NULL) AND (in_vas_param IS NOT NULL) THEN
    OPEN vas_param_val_cur;
    FETCH vas_param_val_cur INTO vas_param_val;
    CLOSE vas_param_val_cur;
  END IF;
  --
  RETURN vas_param_val;
  --
END get_vas_service_param_val;
--
-- CR49058 changes starts..
PROCEDURE p_get_program_parameter_id  ( i_vas_service_id      IN    NUMBER,
                                        i_auto_pay_flag       IN    VARCHAR2,
                                        o_program_id          OUT   NUMBER,
                                        o_error_code          OUT   VARCHAR2,
                                        o_error_msg           OUT   VARCHAR2
                                      )
IS
BEGIN
--
  -- Input validation
  IF i_vas_service_id IS NULL OR i_auto_pay_flag IS NULL
  THEN
    o_error_code  :=  '800';
    o_error_msg   :=  'VAS Service ID / Auto Pay Flag cannot be null';
    RETURN;
  END IF;
  --
  BEGIN
    SELECT DECODE ( i_auto_pay_flag,  'Y',   auto_pay_program_objid, program_parameters_objid)
    INTO   o_program_id
    FROM   vas_programs_view
    WHERE  vas_service_id = i_vas_service_id;
  EXCEPTION
    WHEN OTHERS THEN
      o_program_id  :=  NULL;
  END;
  --
  o_error_code  :=  '0';
  o_error_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of vas_managmeent_pkg.p_get_program_parameter_id - ' || SUBSTR(SQLERRM,1,500);
END p_get_program_parameter_id;
--
-- New procedure to get proration applicable flag
PROCEDURE p_get_proration_flag  ( i_program_param_id            IN    VARCHAR2,
                                  o_proration_applicable_flag   OUT   VARCHAR2,
                                  o_error_code                  OUT   VARCHAR2,
                                  o_error_msg                   OUT   VARCHAR2)
IS
--
l_vas_programs_view    vas_programs_view%ROWTYPE;
--
BEGIN
  SELECT  *
  INTO    l_vas_programs_view
  FROM    vas_programs_view vpv
  WHERE   (NVL(vpv.program_parameters_objid, 1) = i_program_param_id OR
          NVL(vpv.auto_pay_program_objid, 1)   = i_program_param_id);
  --
  o_proration_applicable_flag :=  l_vas_programs_view.proration_flag;
  --
  o_error_code  :=  '0';
  o_error_msg   :=  'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
    o_proration_applicable_flag :=  'N';
    o_error_code                :=  '99';
    o_error_msg                 :=  'Failed in when others of vas_management_pkg.p_get_proration_flag ' || SUBSTR(SQLERRM,1,500);
END p_get_proration_flag;
-- New procedure to get collection of enrolled vas services and its details
PROCEDURE p_get_enrolled_vas_services ( i_esn                       IN  VARCHAR2,
                                        o_vas_program_details_tab   OUT vas_program_details_tab,
                                        o_error_code                OUT VARCHAR2,
                                        o_error_msg                 OUT VARCHAR2
                                      )
IS
--
  c                 customer_type   :=  customer_type();
  cst_add_info      customer_type   :=  customer_type();
--
BEGIN
--
  -- Intialize the output collection object
  o_vas_program_details_tab := vas_program_details_tab();
  -- Input Validation
  IF i_esn  IS NULL
  THEN
    o_error_code  :=  '100';
    o_error_msg   :=  'ESN cannot be NULL';
    RETURN;
  END IF;
  --
  c     :=  c.get_part_class_attributes (i_esn  =>  i_esn);
  --
  cst_add_info     :=  cst_add_info.get_contact_add_info( i_esn => i_esn);
  --
  SELECT vas_program_details_type(  prog_id                ,
                                    x_program_name         ,
                                    x_program_desc         ,
                                    x_retail_price         ,
                                    status                 ,
                                    part_number            ,
                                    part_class             ,
                                    auto_pay_enrolled      ,
                                    next_charge_date       ,
                                    x_charge_frq_code      ,
                                    auto_pay_available     ,
                                    enroll_expiry_date     ,
                                    is_due_flag            ,
                                    x_enrolled_date        ,
                                    x_purch_hdr_objid      ,
                                    program_purch_hdr_objid,
                                    deductible_amount      ,
                                    device_price_tier      ,
                                    mobile_name            ,
                                    mobile_description     ,
                                    mobile_more_info       ,
                                    terms_condition_link   ,
                                    vas_name               ,
                                    vas_category           ,
                                    vas_product_type       ,
                                    vas_description_english,
                                    vas_type               ,
                                    vas_vendor             ,
                                    vas_service_id         ,
                                    vas_subscription_id    ,
                                    vas_offer_expiry_date  ,
                                    transfer_eligible_flag ,
                                    refund_applicable_flag ,
                                    service_days           ,
                                    proration_applied_flag ,
                                    electronic_refund_days ,
                                    vendor_contract_id     ,
                                    reason                 ,
                                    esn_contact_objid      ,
                                    program_enrolled_id    ,
                                    refund_case_id         ,
                                    refund_amount          ,
                                    refund_type            ,
                                    payment_source_objid)
  BULK COLLECT
  INTO    o_vas_program_details_tab
  FROM    (
          SELECT  /*+ ORDERED */
                  pp.objid                              prog_id,
                  pp.x_program_name                     x_program_name,
                  pp.x_program_desc                     x_program_desc,
                  sa.sp_metadata.getprice (pn.part_number, 'BILLING') x_retail_price,
                  vs.status                             status, --pe.x_enrollment_status  status,
                  pn.part_number                        part_number,
                  pc.name                               part_class,
                  DECODE(pp.x_is_recurring, 1, 'Y','N') auto_pay_enrolled,
                  pe.x_next_charge_date                 next_charge_date,
                  pp.x_charge_frq_code                  x_charge_frq_code,
                  (CASE WHEN pp.x_is_recurring  = 1
                        THEN NULL
                        WHEN pp.x_is_recurring  =  0 AND vpv.auto_pay_program_objid IS NOT NULL
                        THEN 'Y'
                        ELSE NULL
                   END)                                 auto_pay_available,
                  vs.vas_expiry_date                    enroll_expiry_date , --pe.x_exp_date           enroll_expiry_date,
                  (CASE WHEN   DECODE(pp.x_is_recurring, 1, 'Y','N') = 'Y'  -- added condition for recurring payments
                        THEN   'N'
                        WHEN  vs.status   = 'SUSPENDED' AND
                              TRUNC(vs.vas_expiry_date) < TRUNC(SYSDATE) AND
                              vpv.show_due_before_days  > 0
                        THEN  'Y'
                        WHEN  vs.status   = 'ENROLLED' AND
                              (TRUNC(vs.vas_expiry_date) - TRUNC(SYSDATE)) <=  vpv.show_due_before_days
                        THEN  'Y'
                        ELSE  'N'
                  END)                                  is_due_flag,
                  vs.vas_subscription_date              x_enrolled_date,  --pe.x_enrolled_date        x_enrolled_date,
                  vs.x_purch_hdr_objid                  x_purch_hdr_objid,
                  vs.program_purch_hdr_objid            program_purch_hdr_objid,
                  tr.price_deductible                   deductible_amount,
                  tr.handset_msrp_tier                  device_price_tier,
                  mi.mobile_name_script_id              mobile_name,
                  mi.mobile_desc_script_id              mobile_description,
                  mi.mobile_info_script_id              mobile_more_info,
                  mi.mobile_terms_condition_link        terms_condition_link,
                  vpv.vas_name                          vas_name,
                  vpv.vas_category                      vas_category,
                  vpv.vas_product_type                  vas_product_type,
                  vpv.vas_description_english           vas_description_english,
                  vpv.vas_type                          vas_type,
                  vpv.vas_vendor                        vas_vendor,
                  vpv.vas_service_id                    vas_service_id,
                  vs.vas_subscription_id                vas_subscription_id,
                  NULL                                  vas_offer_expiry_date,
                  (CASE WHEN  vpv.auto_pay_program_objid IS NOT NULL   -- added condition for Monthly plans
                        THEN  'Y'
                        ELSE  'N'
                  END)                                   transfer_eligible_flag,
                  (CASE WHEN  vs.is_claimed='Y'
                        THEN  'N'
                        ELSE  vpv.refund_on_cancellation_flag
                  END)                                  refund_applicable_flag,
                  NULL                                  service_days,
                  'N'                                   proration_applied_flag,
                  vpv.electronic_refund_days            electronic_refund_days,
                  vs.vendor_contract_id                 vendor_contract_id,
                  (CASE WHEN vs.status  = 'SUSPENDED'
                        THEN pe.x_reason
                        ELSE NULL
                   END)                                 reason,
                  cst_add_info.contact_objid            esn_contact_objid,
                  vs.program_enrolled_id                program_enrolled_id,
                  vs.case_id_number                     refund_case_id,
                  vs.refund_amount                      refund_amount,
                  vs.refund_type                        refund_type,
                  pe.pgm_enroll2x_pymt_src              payment_source_objid
          FROM    x_program_enrolled        pe,
                  x_program_parameters      pp,
                  x_vas_subscriptions       vs,
                  table_part_num            pn,
                  table_handset_msrp_tiers  tr,
                  x_mtm_program_msrp        protr,
                  vas_programs_view         vpv,
                  table_x_mobile_info       mi,
                  table_part_class          pc
          WHERE   1 =1
          AND     tr.product_type               = DECODE(c.device_type, 'BYOP',  'BYOD',
                                                                        'BYOT',  'BYOD',
                                                                        tr.product_type)
          AND     tr.msrp_tiers2vas_programs    = vs.vas_id
          AND     tr.handset_msrp_tier          = vs.device_price_tier
          AND     tr.objid                      = protr.pgm_msrp2handset_msrp_tier
          AND     protr.pgm_msrp2pgm_parameter  = pp.objid
          AND     mi.pgm_enroll2mobile_info(+)  = pe.pgm_enroll2pgm_parameter
          AND     pn.part_num2part_class        = pc.objid
          AND     pn.objid                      = ( CASE  WHEN pp.x_is_recurring = 0
                                                          THEN pp.prog_param2prtnum_enrlfee
                                                          ELSE pp.prog_param2prtnum_monfee
                                                    END)
          AND     vs.vas_id                     = vpv.vas_service_id
          --AND     vs.status                     IN ('ENROLLED','SUSPENDED','DEENROLL_SCHEDULED','ENROLL_SCHEDULED')
          AND     vs.program_enrolled_id        = pe.objid
          AND     vs.vas_esn                    = pe.x_esn
          AND     vs.vas_is_active              = 'T'
          AND     pp.x_prog_class               = 'WARRANTY'
          AND     pp.objid                      = pe.pgm_enroll2pgm_parameter
         -- AND     pe.x_enrollment_status        NOT IN     ('DEENROLLED', 'ENROLLMENTFAILED', 'READYTOREENROLL')
          AND     pe.x_esn                      = i_esn
          UNION
          SELECT  /*+ ORDERED */
                  pp.objid                              prog_id,
                  pp.x_program_name                     x_program_name,
                  pp.x_program_desc                     x_program_desc,
                  sa.sp_metadata.getprice (pn.part_number, 'BILLING') x_retail_price,
                  vs.status                             status, --pe.x_enrollment_status  status,
                  pn.part_number                        part_number,
                  pc.name                               part_class,
                  DECODE(pp.x_is_recurring, 1, 'Y','N') auto_pay_enrolled,
                  pe.x_next_charge_date                 next_charge_date,
                  pp.x_charge_frq_code                  x_charge_frq_code,
                  (CASE WHEN pp.x_is_recurring  = 1
                        THEN NULL
                        WHEN pp.x_is_recurring  =  0 AND vpv.auto_pay_program_objid IS NOT NULL
                        THEN 'Y'
                        ELSE NULL
                   END)                                 auto_pay_available,
                  vs.vas_expiry_date                    enroll_expiry_date , --pe.x_exp_date           enroll_expiry_date,
                  (CASE WHEN   DECODE(pp.x_is_recurring, 1, 'Y','N') = 'Y'   -- added condition for recurring payments
                        THEN   'N'
                        WHEN  vs.status   = 'SUSPENDED' AND
                              TRUNC(vs.vas_expiry_date) < TRUNC(SYSDATE) AND
                              vpv.show_due_before_days  > 0
                        THEN  'Y'
                        WHEN  vs.status   = 'ENROLLED' AND
                              (TRUNC(vs.vas_expiry_date) - TRUNC(SYSDATE)) <=  vpv.show_due_before_days
                        THEN  'Y'
                        ELSE  'N'
                  END)  is_due_flag,
                  vs.vas_subscription_date              x_enrolled_date,  --pe.x_enrolled_date        x_enrolled_date,
                  vs.x_purch_hdr_objid                  x_purch_hdr_objid,
                  vs.program_purch_hdr_objid            program_purch_hdr_objid,
                  0                                     deductible_amount,--tr.price_deductible,
                  0                                     device_price_tier,--tr.handset_msrp_tier,
                  mi.mobile_name_script_id              mobile_name,
                  mi.mobile_desc_script_id              mobile_description,
                  mi.mobile_info_script_id              mobile_more_info,
                  mi.mobile_terms_condition_link        terms_condition_link,
                  vpv.vas_name                          vas_name,
                  vpv.vas_category                      vas_category,
                  vpv.vas_product_type                  vas_product_type,
                  vpv.vas_description_english           vas_description_english,
                  vpv.vas_type                          vas_type,
                  vpv.vas_vendor                        vas_vendor,
                  vpv.vas_service_id                    vas_service_id,
                  vs.vas_subscription_id                vas_subscription_id,
                  NULL                                  vas_offer_expiry_date,
                  (CASE WHEN  vpv.auto_pay_program_objid IS NOT NULL   -- added condition for Monthly plans
                        THEN  'Y'
                        ELSE  'N'
                  END)                                   transfer_eligible_flag,
                  (CASE WHEN  vs.is_claimed='Y'
                        THEN  'N'
                        ELSE  vpv.refund_on_cancellation_flag
                  END)                                  refund_applicable_flag,
                  NULL                                  service_days,
                  'N'                                   proration_applied_flag,
                  vpv.electronic_refund_days            electronic_refund_days,
                  vs.vendor_contract_id                 vendor_contract_id,
                  (CASE WHEN vs.status  = 'SUSPENDED'
                        THEN pe.x_reason
                        ELSE NULL
                   END)                                 reason,
                  cst_add_info.contact_objid            esn_contact_objid,
                  vs.program_enrolled_id                program_enrolled_id,
                  vs.case_id_number                     refund_case_id,
                  vs.refund_amount                      refund_amount,
                  vs.refund_type                        refund_type,
                  pe.pgm_enroll2x_pymt_src              payment_source_objid
          FROM    x_program_enrolled        pe,
                  x_program_parameters      pp,
                  x_vas_subscriptions       vs,
                  table_part_num            pn,
                  vas_programs_view         vpv,
                  table_x_mobile_info       mi,
                  table_part_class          pc
          WHERE   1 =1
          AND     mi.pgm_enroll2mobile_info(+)  = pe.pgm_enroll2pgm_parameter
          AND     pn.part_num2part_class        = pc.objid
          AND     pn.objid                      = ( CASE  WHEN pp.x_is_recurring = 0
                                                          THEN pp.prog_param2prtnum_enrlfee
                                                          ELSE pp.prog_param2prtnum_monfee
                                                    END)
          AND     vpv.program_parameters_objid  = pp.objid
          AND     vs.vas_id                     = vpv.vas_service_id
         -- AND     vs.status                     IN ('ENROLLED','SUSPENDED','DEENROLL_SCHEDULED','ENROLL_SCHEDULED')
          AND     vs.program_enrolled_id        = pe.objid
          AND     vs.vas_esn                    = pe.x_esn
          AND     vs.vas_is_active              = 'T'
          AND     pp.x_prog_class               = 'VAS'
          AND     pp.objid                      = pe.pgm_enroll2pgm_parameter
          --AND     pe.x_enrollment_status        NOT IN     ('DEENROLLED', 'ENROLLMENTFAILED', 'READYTOREENROLL')
          AND     pe.x_esn                      = i_esn)
  ORDER by x_enrolled_date;
  --
  o_error_code    :=  0;
  o_error_msg     :=  'SUCCESS';
--
EXCEPTION
WHEN OTHERS THEN
  o_error_code                :=  '99';
  o_error_msg                 :=  'Failed in when others of vas_management_pkg.p_get_enrolled_vas_services ' || SUBSTR(SQLERRM,1,500);
END p_get_enrolled_vas_services;
--
-- New Procedure to get list of eligbile as well as enrolled VAS services
PROCEDURE p_get_eligible_vas_services ( i_esn                     IN  VARCHAR2,
                                        i_min                     IN  VARCHAR2,
                                        i_bus_org                 IN  VARCHAR2,
                                        i_ecommerce_orderid       IN  VARCHAR2,
                                        i_phone_make              IN  VARCHAR2,
                                        i_phone_model             IN  VARCHAR2,
                                        i_phone_price             IN  NUMBER,
                                        i_activation_zipcode      IN  VARCHAR2,
                                        i_is_byod                 IN  VARCHAR2,
                                        i_enrolled_only           IN  VARCHAR2 DEFAULT 'N',
                                        i_to_esn                  IN  VARCHAR2,
                                        i_process_flow            IN  VARCHAR2 DEFAULT NULL,
                                        o_vas_program_details_tab OUT vas_program_details_tab,
                                        o_error_code              OUT VARCHAR2,
                                        o_error_msg               OUT VARCHAR2
                                      )
IS
--
  cwp_refcursor                   sys_refcursor;
  currentwtyprograms_rec          sa.value_addedprg.currentwtyprograms_record;
  l_vas_program_details_tab       vas_program_details_tab   :=  vas_program_details_tab();
  vas_program_details_result      vas_program_details_type  :=  vas_program_details_type();
  vp_enrolled                     vas_programs_type         :=  vas_programs_type();
  vs_reenroll                     vas_subscriptions_type    :=  vas_subscriptions_type();
  c                               customer_type             :=  customer_type();
  cst_add_info                    customer_type             :=  customer_type();
  l_bus_org_objid                 NUMBER;
  l_prorated_days                 NUMBER;
  l_prorated_amount               NUMBER;
  l_error_code                    NUMBER;
  l_error_msg                     VARCHAR2(1000);
  l_esn                           VARCHAR2(50);
  l_vas_enrolled_flag             VARCHAR2(1) :=  'Y';
  l_product_type_enrolled_flag    VARCHAR2(1) :=  'N';
  l_product_type_deenrolled_flag  VARCHAR2(1) :=  'N';
  l_prod_type_deenroll_sch_flag   VARCHAR2(1) :=  'N';
  l_claim_device_flag             VARCHAR2(1) :=  'N';
-- below variables for script
  v_script_id                      VARCHAR2(50);
  v_script_type                    VARCHAR2(50);
  v_script_source                  VARCHAR2(50):= 'WEB';
  v_script_language                VARCHAR2(50):= 'ENGLISH';
  v_op_objid 			   VARCHAR2(200);
  v_op_description                 VARCHAR2(200);
  v_op_script_text                 VARCHAR2(200);
  v_op_publish_by                  VARCHAR2(200);
  v_op_publish_date                DATE;
  v_op_sm_link                     VARCHAR2(200);
  v_is_claimed_flag                VARCHAR2(3);

  CURSOR get_site_part_local ( ip_objid IN NUMBER)
  IS
    --If for any reasons igate/ota is down the part_status is CarrierPending and Handset Protection Program should be offered
    SELECT sp.objid,
           sp.part_status,
           sp.x_service_id,
           --phone age is based on the initial activation date or the first activation after the phone was refurbished
           (SELECT  MIN (TRUNC(tsp.install_date))
            FROM    table_site_part tsp
            WHERE   tsp.x_service_id = sp.x_service_id
            AND     NVL (x_refurb_flag, 0) <> 1)      install_date,
           sp.x_zipcode
    FROM   table_site_part sp
    WHERE  sp.objid = ip_objid;
  --
  CURSOR get_part_inst_local (ip_esn              IN VARCHAR2,
                              ip_pricing_channel  IN VARCHAR2)
  IS
    SELECT  pi.objid,
            pi.part_serial_no,
            pi.x_part_inst_status,
            sa.sp_metadata.getprice (pn.part_number, ip_pricing_channel)  x_retail_price,
            pn.part_num2part_class,
            pi.x_part_inst2site_part,
            pn.part_num2bus_org
    FROM    sa.table_part_inst pi,
            sa.table_mod_level ml,
            sa.table_part_num pn
    WHERE   pi.part_serial_no = ip_esn
    AND     pi.x_domain       = 'PHONES'
    AND     ml.objid          = pi.n_part_inst2part_mod
    AND     pn.objid          = ml.part_info2part_num;
  --
  get_site_part_local_rec   get_site_part_local%ROWTYPE;
  get_part_inst_local_rec   get_part_inst_local%ROWTYPE;
  --
  c_pricing_channel        table_x_parameters.x_param_value%TYPE;

BEGIN
  -- Initialization
  o_vas_program_details_tab   :=  vas_program_details_tab ();
  -- Input Validation
  IF i_esn  IS NULL AND i_min IS NULL AND i_ecommerce_orderid IS NULL
  THEN
    o_error_code  :=  200;
    o_error_msg   :=  'ESN or MIN or Order ID cannot be NULL';
    RETURN;
  END IF;
  --
  IF i_bus_org IS NULL
  THEN
    o_error_code  :=  201;
    o_error_msg   :=  'Brand cannot be NULL';
    RETURN;
  END IF;
  --
  IF i_esn IS NULL AND i_min IS NOT NULL
  THEN
    c.min :=  i_min;
    l_esn :=  c.get_esn ( i_min => c.min );
  ELSIF i_esn IS NOT NULL
  THEN
    l_esn :=  i_esn;
  END IF;
  -- Get Bus org OBJID
  c.bus_org_id    :=  i_bus_org;
  l_bus_org_objid :=  c.get_bus_org_objid();
  --
  -- get contact info for ESN
  cst_add_info     :=  cst_add_info.get_contact_add_info( i_esn => l_esn);
  --
  BEGIN
    SELECT x_param_value
	INTO   c_pricing_channel
	FROM   table_x_parameters
	WHERE  x_param_name = 'PHONE_PRICING_CHANNEL_FOR_HPP'
	AND    ROWNUM = 1;
  EXCEPTION
  WHEN OTHERS THEN
    c_pricing_channel := 'ECOMMERCE';
  END;

  IF l_esn IS NOT NULL
  THEN
    -- Get Part inst info
    OPEN get_part_inst_local (l_esn, c_pricing_channel);
    FETCH get_part_inst_local INTO get_part_inst_local_rec;
    --
    IF get_part_inst_local%NOTFOUND
    THEN
      --
      CLOSE get_part_inst_local;
      --
      o_error_code := '202';
      o_error_msg := 'ESN not found';
      RETURN;
    ELSE
      CLOSE get_part_inst_local;
      --
    END IF;
    -- Get site part Info
    OPEN get_site_part_local (get_part_inst_local_rec.x_part_inst2site_part);
    FETCH get_site_part_local INTO get_site_part_local_rec;
    --
    IF get_site_part_local%NOTFOUND AND get_part_inst_local_rec.x_part_inst_status <> '50' -- to get eligible services for NEW phone
    THEN
      CLOSE get_site_part_local;
      --
      o_error_code := '203';
      o_error_msg := 'MIN not found';
      RETURN;
    ELSE
      CLOSE get_site_part_local;
      --
    END IF;
    --
  END IF;
  --
  -- get all the Enrolled OLD Warranty Programs (LEGACY)
  value_addedprg.getCurrentWarrantyProgram ( ip_esn         =>  l_esn,
                                             op_result_set  =>  cwp_refcursor,
                                             op_error_code  =>  o_error_code,
                                             op_error_text  =>  o_error_msg);
  --
  LOOP
    FETCH cwp_refcursor INTO currentwtyprograms_rec;
    EXIT WHEN cwp_refcursor%NOTFOUND;
    --
    vas_program_details_result.prog_id                  :=  currentwtyprograms_rec.prog_id;
    vas_program_details_result.x_program_name           :=  currentwtyprograms_rec.x_program_name;
    vas_program_details_result.x_program_desc           :=  currentwtyprograms_rec.x_program_desc;
    vas_program_details_result.x_retail_price           :=  sa.sp_metadata.getprice (currentwtyprograms_rec.part_number, 'BILLING');
    vas_program_details_result.status                   :=  currentwtyprograms_rec.status;
    vas_program_details_result.part_number              :=  currentwtyprograms_rec.part_number;
    vas_program_details_result.next_charge_date         :=  currentwtyprograms_rec.expirationdate;
    vas_program_details_result.x_charge_frq_code        :=  currentwtyprograms_rec.x_charge_frq_code;
    vas_program_details_result.enroll_expiry_date       :=  currentwtyprograms_rec.x_exp_date;
    vas_program_details_result.x_enrolled_date          :=  currentwtyprograms_rec.x_enrolled_date;
    vas_program_details_result.deductible_amount        :=  currentwtyprograms_rec.x_retail_price;
    vas_program_details_result.mobile_name              :=  currentwtyprograms_rec.mobile_name;
    vas_program_details_result.mobile_description       :=  currentwtyprograms_rec.mobile_description;
    vas_program_details_result.mobile_more_info         :=  currentwtyprograms_rec.mobile_more_info;
    vas_program_details_result.terms_condition_link     :=  currentwtyprograms_rec.terms_condition_link;
    vas_program_details_result.vas_name                 :=  'LEGACY_WARRANTY_PROGRAM';
    vas_program_details_result.vas_category             :=  'AIG_HPP';
    --vas_program_details_result.vas_description_english  :=  'LEGACY_WARRANTY_PROGRAM';
    vas_program_details_result.vas_product_type         :=  'HANDSET PROTECTION';
    vas_program_details_result.vas_vendor               :=  'AIG';
    vas_program_details_result.vas_service_id           :=  '';
    vas_program_details_result.vas_subscription_id      :=  '';
    --
    --  pipe ROW (vas_program_details_result);
    o_vas_program_details_tab.extend;
    o_vas_program_details_tab(o_vas_program_details_tab.COUNT)  := vas_program_details_result;
    --
  END LOOP;
  --
  -- Get all the Enrolled VAS Services
  --
  p_get_enrolled_vas_services ( i_esn                       =>  l_esn,
                                o_vas_program_details_tab   =>  l_vas_program_details_tab,
                                o_error_code                =>  o_error_code,
                                o_error_msg                 =>  o_error_msg
                              );
  --
  IF l_vas_program_details_tab IS NOT NULL
  THEN
    IF l_vas_program_details_tab.COUNT > 0
    THEN
      -- Check for claim device
      IF  i_process_flow  = 'UPGRADE' AND
          i_to_esn        IS NOT NULL
      THEN
        -- Validate to ESN
        p_check_claim_device  ( i_old_esn           =>  l_esn,
                                i_new_esn           =>  i_to_esn,
                                o_claim_device_flag =>  l_claim_device_flag,
                                o_error_code        =>  l_error_code,
                                o_error_msg         =>  l_error_msg
                              );
      END IF;
      --
      FOR each IN 1 .. l_vas_program_details_tab.COUNT
      LOOP
        --
        -- Reinitialize
        l_prorated_days     :=  0;
        l_prorated_amount   :=  0;
        -- Get Vas program details of the ENROLLED service
        vp_enrolled         :=  vas_programs_type (i_vas_service_id => l_vas_program_details_tab(each).vas_service_id );
        --
        vas_program_details_result.prog_id                  :=  l_vas_program_details_tab(each).prog_id;
        -- vas_program_details_result.x_program_name           :=  l_vas_program_details_tab(each).x_program_name;
        -- vas_program_details_result.x_program_desc           :=  l_vas_program_details_tab(each).x_program_desc;
        vas_program_details_result.x_retail_price           :=  l_vas_program_details_tab(each).x_retail_price;
        vas_program_details_result.status                   :=  l_vas_program_details_tab(each).status;
        vas_program_details_result.part_number              :=  l_vas_program_details_tab(each).part_number;
        vas_program_details_result.part_class               :=  l_vas_program_details_tab(each).part_class;
        vas_program_details_result.auto_pay_enrolled        :=  l_vas_program_details_tab(each).auto_pay_enrolled;
        vas_program_details_result.next_charge_date         :=  l_vas_program_details_tab(each).next_charge_date;
        vas_program_details_result.x_charge_frq_code        :=  l_vas_program_details_tab(each).x_charge_frq_code;
        vas_program_details_result.auto_pay_available       :=  l_vas_program_details_tab(each).auto_pay_available;
        vas_program_details_result.enroll_expiry_date       :=  l_vas_program_details_tab(each).enroll_expiry_date;
        vas_program_details_result.is_due_flag              :=  l_vas_program_details_tab(each).is_due_flag;
        vas_program_details_result.x_enrolled_date          :=  l_vas_program_details_tab(each).x_enrolled_date;
        vas_program_details_result.x_purch_hdr_objid        :=  l_vas_program_details_tab(each).x_purch_hdr_objid;
        vas_program_details_result.program_purch_hdr_objid  :=  l_vas_program_details_tab(each).program_purch_hdr_objid;
        vas_program_details_result.deductible_amount        :=  l_vas_program_details_tab(each).deductible_amount;
        vas_program_details_result.device_price_tier        :=  l_vas_program_details_tab(each).device_price_tier;
        vas_program_details_result.mobile_name              :=  l_vas_program_details_tab(each).mobile_name;
        vas_program_details_result.mobile_description       :=  l_vas_program_details_tab(each).mobile_description;
        vas_program_details_result.mobile_more_info         :=  l_vas_program_details_tab(each).mobile_more_info;
        vas_program_details_result.terms_condition_link     :=  l_vas_program_details_tab(each).terms_condition_link;
        --vas_program_details_result.vas_name                 :=  l_vas_program_details_tab(each).vas_name;
        vas_program_details_result.vas_category             :=  l_vas_program_details_tab(each).vas_category;
        vas_program_details_result.vas_product_type         :=  l_vas_program_details_tab(each).vas_product_type;
        vas_program_details_result.vas_description_english  :=  l_vas_program_details_tab(each).vas_description_english;
        vas_program_details_result.vas_type                 :=  l_vas_program_details_tab(each).vas_type;
        vas_program_details_result.vas_vendor               :=  l_vas_program_details_tab(each).vas_vendor;
        vas_program_details_result.vas_service_id           :=  l_vas_program_details_tab(each).vas_service_id;
        vas_program_details_result.vas_subscription_id      :=  l_vas_program_details_tab(each).vas_subscription_id;
        vas_program_details_result.transfer_eligible_flag   :=  l_vas_program_details_tab(each).transfer_eligible_flag;
        vas_program_details_result.refund_applicable_flag   :=  l_vas_program_details_tab(each).refund_applicable_flag;
        vas_program_details_result.service_days             :=  vp_enrolled.service_days;
        vas_program_details_result.proration_applied_flag   :=  l_vas_program_details_tab(each).proration_applied_flag;
        vas_program_details_result.electronic_refund_days   :=  l_vas_program_details_tab(each).electronic_refund_days;
        vas_program_details_result.vendor_contract_id       :=  l_vas_program_details_tab(each).vendor_contract_id;
        vas_program_details_result.reason                   :=  l_vas_program_details_tab(each).reason;
        vas_program_details_result.esn_contact_objid        :=  l_vas_program_details_tab(each).esn_contact_objid;
        vas_program_details_result.program_enrolled_id      :=  l_vas_program_details_tab(each).program_enrolled_id;
        vas_program_details_result.refund_case_id           :=  l_vas_program_details_tab(each).refund_case_id;
        vas_program_details_result.refund_amount            :=  l_vas_program_details_tab(each).refund_amount;
        vas_program_details_result.refund_type              :=  l_vas_program_details_tab(each).refund_type;
        vas_program_details_result.payment_source_objid     :=  l_vas_program_details_tab(each).payment_source_objid;
        --
		BEGIN
		  SELECT NVL(is_claimed,'N')
		  INTO   v_is_claimed_flag
		  FROM   x_vas_subscriptions
		  WHERE  vas_esn = i_esn
		  AND    vas_subscription_id = l_vas_program_details_tab(each).vas_subscription_id;
		EXCEPTION
		 WHEN OTHERS
		 THEN
		   v_is_claimed_flag := 'N';
		END;
        -- Check for upgrade and refund flags
        IF  i_to_esn        IS NOT NULL     AND
            l_claim_device_flag = 'Y'       AND
            i_process_flow      = 'UPGRADE' AND
            vas_program_details_result.status IN ('ENROLLED','SUSPENDED') -- include suspended only for replacement flow
        THEN
          -- Replacement device upgrade (claimed device), set replacement flags
          vas_program_details_result.transfer_eligible_flag :=  vp_enrolled.transfer_on_replacement_flag;
          vas_program_details_result.refund_applicable_flag :=  vp_enrolled.refund_on_replacement_flag;
        ELSIF i_to_esn          IS NOT NULL   AND
              l_claim_device_flag = 'N'       AND
			  v_is_claimed_flag   = 'N'       AND
              i_process_flow      = 'UPGRADE' AND
              vas_program_details_result.status IN ('ENROLLED','SUSPENDED') -- include suspended for upgrade too as flow is suspending before upgrade
        THEN
          -- Regular upgrade,set upgrade flags
          vas_program_details_result.transfer_eligible_flag :=  vp_enrolled.transfer_on_upgrade_flag;
          vas_program_details_result.refund_applicable_flag :=  vp_enrolled.refund_on_upgrade_flag;
        END IF;
        --
        -- check for proration
        IF  vp_enrolled.proration_flag          = 'Y'  AND
            vas_program_details_result.status   = 'SUSPENDED'
        THEN
          --
          sp_metadata.p_vas_proration_service ( i_esn                   =>  l_esn,
                                                i_vas_service_id        =>  vas_program_details_result.vas_service_id,
                                                i_current_expiry_date   =>  vas_program_details_result.enroll_expiry_date,
                                                i_current_status        =>  vas_program_details_result.status,
                                                i_part_number           =>  vas_program_details_result.part_number,
                                                i_source                =>  'BILLING',
                                                o_prorated_service_days =>  l_prorated_days,
                                                o_prorated_amount       =>  l_prorated_amount,
                                                o_error_code            =>  o_error_code,
                                                o_error_msg             =>  o_error_msg
                                              );
          --
          IF  NVL(l_prorated_amount,0)  > 0  AND
              NVL(l_prorated_days,0)    > 0
          THEN
            vas_program_details_result.service_days             :=  l_prorated_days;
            vas_program_details_result.x_retail_price           :=  l_prorated_amount;
            vas_program_details_result.proration_applied_flag   :=  'Y';
          END IF;
          --
        END IF;
        --
        -- get the refund details
        IF vas_program_details_result.refund_amount IS NULL
        THEN
          -- get the refund details of old esn
          BEGIN
            SELECT  vs_rf.case_id_number, vs_rf.refund_amount, vs_rf.refund_type
            INTO    vas_program_details_result.refund_case_id,
                    vas_program_details_result.refund_amount,
                    vas_program_details_result.refund_type
            FROM    x_vas_subscriptions vs_rf
            WHERE   vs_rf.vas_subscription_id = vas_program_details_result.vas_subscription_id
            AND     vs_rf.objid               = ( SELECT MAX(objid)
                                                  FROM   x_vas_subscriptions v
                                                  WHERE  v.vas_subscription_id  =   vs_rf.vas_subscription_id
                                                  AND    v.vas_esn              <>  l_esn
                                                  AND    INSTR(v.addl_info, l_esn,1) > 0
                                                );
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        END IF;

        BEGIN

	      v_script_type := NULL;
		  v_script_id   := NULL;
          SELECT SUBSTR(xvv.vas_param_value,1,INSTR(xvv.vas_param_value,'_',1)-1),
                 SUBSTR(xvv.vas_param_value,INSTR(xvv.vas_param_value,'_',1)+1)
          INTO   v_script_type,
                 v_script_id
          FROM   x_vas_values xvv,
                 x_vas_params xvp,
                 x_vas_programs vprog
          WHERE  xvv.vas_params_objid = xvp.objid
          AND    xvv.vas_programs_objid = vprog.objid
          AND    xvp.vas_param_name = 'WEB_SCRIPT_ID'
          AND    vprog.objid = l_vas_program_details_tab(each).vas_service_id;

          sa.scripts_pkg.get_script_prc(
		                       ip_sourcesystem  => v_script_source,
		                       ip_brand_name    => c.bus_org_id,
		                       ip_script_type   => v_script_type,
		                       ip_script_id     => v_script_id,
		                       ip_language      => v_script_language,
		                       ip_carrier_id    => NULL,
		                       ip_part_class    => NULL,
		                       op_objid         => v_op_objid,
		                       op_description   => v_op_description,
		                       op_script_text   => v_op_script_text,
		                       op_publish_by    => v_op_publish_by,
		                       op_publish_date  => v_op_publish_date,
		                       op_sm_link       => v_op_sm_link
		                     );

          IF v_op_script_text LIKE '%MISSING%'
          THEN
            vas_program_details_result.vas_name :=  l_vas_program_details_tab(each).vas_name;
          ELSE
            vas_program_details_result.vas_name :=  v_op_script_text;
		  END IF;
        EXCEPTION
         WHEN OTHERS THEN
          vas_program_details_result.vas_name :=  l_vas_program_details_tab(each).vas_name;
        END;

        --
        --PIPE ROW (vas_program_details_result);
        o_vas_program_details_tab.extend;
        o_vas_program_details_tab(o_vas_program_details_tab.COUNT)  := vas_program_details_result;
        --
      END LOOP;
    END IF;
  END IF;
  --
  --  Get eligible vas services only if the enrolled only flag is N
  IF i_enrolled_only = 'N'
  THEN
    -- Get all the Eligible VAS services
    FOR PROG  IN ( SELECT /*+ ORDERED */
                          pn.part_number,
                          pc.name   part_class,
                          pp.objid,
                          pp.x_handset_value,
                          pp.x_program_name,
                          pp.x_program_desc,
                          pp.x_charge_frq_code,
                          sa.sp_metadata.getprice (pn.part_number, 'BILLING')  x_retail_price,
                          (CASE WHEN  vpv.auto_pay_program_objid IS NOT NULL
                                THEN  'Y'
                                ELSE  'N'
                           END) auto_pay_available,
                          msrp.price_deductible,
                          msrp.handset_msrp_tier,
                          vpv.offer_expiry,
                          vpv.vas_name,
                          vpv.vas_category,
                          vpv.vas_description_english,
                          vpv.vas_type,
                          vpv.vas_vendor,
                          vpv.vas_service_id,
                          vpv.vas_product_type,
                          mi.mobile_name_script_id        mobile_name,
                          mi.mobile_desc_script_id        mobile_description,
                          mi.mobile_info_script_id        mobile_more_info,
                          mi.mobile_terms_condition_link  terms_condition_link,
                          vpv.reenroll_allow_flag,
                          vpv.proration_flag,
                          vpv.service_days,
                          vpv.electronic_refund_days
                   FROM   sa.table_handset_msrp_tiers msrp,
                          sa.x_mtm_program_msrp       xpmsrp,
                          sa.x_program_parameters     pp,
                          sa.table_part_num           pn,
                          vas_programs_view           vpv,
                          table_x_mobile_info         mi,
                          table_part_class            pc
                   WHERE  (((get_part_inst_local_rec.x_retail_price BETWEEN msrp.tier_price_low AND msrp.tier_price_high) AND
                            i_is_byod     = 'N')
                          OR
                           ((NVL(i_phone_price,0) BETWEEN msrp.tier_price_low AND msrp.tier_price_high) AND
                            i_is_byod     = 'Y'))
                   AND    msrp.product_type                     =   DECODE (i_is_byod,  'Y',  'BYOD', 'PHONE')
                   AND    NVL(msrp.msrp_tiers2vas_programs,0)   =   vpv.vas_service_id
                   AND    msrp.objid                            =   xpmsrp.pgm_msrp2handset_msrp_tier
                   AND    xpmsrp.pgm_msrp2pgm_parameter         =   vpv.program_parameters_objid
                   AND    pp.objid                              =   xpmsrp.pgm_msrp2pgm_parameter
                   AND    pp.x_prog_class                       =   'WARRANTY'
                   AND    SYSDATE           BETWEEN pp.x_start_date AND pp.x_end_date
                   AND    pn.part_num2part_class                =   pc.objid
                   AND    pn.objid                              =   DECODE (pp.x_is_recurring,  0,  pp.prog_param2prtnum_enrlfee,
                                                                                                    pp.prog_param2prtnum_monfee)
                   AND    pp.prog_param2bus_org                 =   NVL(l_bus_org_objid, get_part_inst_local_rec.part_num2bus_org)
                   AND    mi.pgm_enroll2mobile_info(+)          =   pp.objid
                   UNION
                   SELECT /*+ ORDERED */
                          pn.part_number,
                          pc.name   part_class,
                          pp.objid,
                          pp.x_handset_value,
                          pp.x_program_name,
                          pp.x_program_desc,
                          pp.x_charge_FRQ_code,
                          sa.sp_metadata.getprice (pn.part_number, 'BILLING')  x_retail_price,
                          (CASE WHEN  vpv.auto_pay_program_objid IS NOT NULL
                                THEN  'Y'
                                ELSE  'N'
                           END) auto_pay_available,
                          0   price_deductible,
                          0   handset_msrp_tier,
                          vpv.offer_expiry,
                          vpv.vas_name,
                          vpv.vas_category,
                          vpv.vas_description_english,
                          vpv.vas_type,
                          vpv.vas_vendor,
                          vpv.vas_service_id,
                          vpv.vas_product_type,
                          mi.mobile_name_script_id        mobile_name,
                          mi.mobile_desc_script_id        mobile_description,
                          mi.mobile_info_script_id        mobile_more_info,
                          mi.mobile_terms_condition_link  terms_condition_link,
                          vpv.reenroll_allow_flag,
                          vpv.proration_flag,
                          vpv.service_days,
                          vpv.electronic_refund_days
                   FROM   sa.x_program_parameters     pp,
                          sa.table_part_num           pn,
                          vas_programs_view           vpv,
                          table_x_mobile_info         mi,
                          table_part_class            pc
                   WHERE  pp.objid                              =   vpv.program_parameters_objid
                   AND    pp.x_prog_class                       =   'VAS'  -- Vas services other than handset protection
                   AND    SYSDATE           BETWEEN pp.x_start_date AND pp.x_end_date
                   AND    pn.part_num2part_class                =   pc.objid
                   AND    pn.objid                              =   DECODE (pp.x_is_recurring,  0,  pp.prog_param2prtnum_enrlfee,
                                                                                                    pp.prog_param2prtnum_monfee)
                   AND    pp.prog_param2bus_org                 =   NVL(l_bus_org_objid, get_part_inst_local_rec.part_num2bus_org)
                   AND    mi.pgm_enroll2mobile_info(+)          =   pp.objid
                   )
    LOOP
      --
      dbms_output.put_line('inside Eligible Vas services logic');
      --
      -- *** Check whether this VAS service id is already enrolled  ***
      BEGIN
        SELECT DECODE(COUNT(*),0, 'N','Y')
        INTO   l_vas_enrolled_flag
        FROM   TABLE(CAST(o_vas_program_details_tab AS sa.vas_program_details_tab)) v
        WHERE  v.vas_service_id = prog.vas_service_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_vas_enrolled_flag :=  'N';
      END;
      --
      IF l_vas_enrolled_flag  = 'Y'
      THEN
        -- SKIP this VAS program as it is enrolled already and continue with rest
        CONTINUE;
      END IF;
      --
      -- *** Check whether same product type of VAS is already enrolled including Legacy Warranty program  ***
      BEGIN
        SELECT DECODE(COUNT(*),0, 'N','Y')
        INTO   l_product_type_enrolled_flag
        FROM   TABLE(CAST(o_vas_program_details_tab AS sa.vas_program_details_tab)) v
        WHERE  v.vas_product_type = prog.vas_product_type
        AND    v.status           <>  'ELIGIBLE';
      EXCEPTION
        WHEN OTHERS THEN
          l_product_type_enrolled_flag :=  'N';
      END;
      --
      IF  l_product_type_enrolled_flag  = 'Y'
      THEN
        -- SKIP this VAS program, as same vas product type is already enrolled
        CONTINUE;
      END IF;
      --
      -- *** Check whether this SPECIFIC VAS program was enrolled in the past and eligible for Reenroll ***
      vs_reenroll   :=  vas_subscriptions_type( i_esn             =>  l_esn,
                                                i_vas_service_id  =>  prog.vas_service_id);
      --
      IF  (vs_reenroll.status    = 'DEENROLLED'  AND
          NVL(prog.reenroll_allow_flag,'N') = 'N')  OR
          vs_reenroll.status    = 'DEENROLL_SCHEDULED'
      THEN
        CONTINUE; -- SKIP this VAS program as same vas was deenrolled and not eligible for Reenroll
        --
      END IF;
      --
      -- *** Check whether same VAS product type was deenrolled in the past and eligible for Reenroll ***
      BEGIN
        SELECT DECODE(COUNT(*),0, 'N','Y')
        INTO   l_product_type_deenrolled_flag
        FROM   x_vas_subscriptions  vs,
               vas_programs_view    vp
        WHERE  NVL(vp.reenroll_allow_flag,'N') = 'N'
        AND    vp.vas_product_type             = prog.vas_product_type
        AND    vs.vas_id                       = vp.vas_service_id
        AND    vs.vas_id                       <> prog.vas_service_id
        AND    vs.vas_esn                      = l_esn
        AND    vs.vas_is_active                = 'T'
        AND    vs.status                       IN  ('DEENROLLED');
      EXCEPTION
        WHEN OTHERS THEN
          l_product_type_deenrolled_flag :=  'N';
      END;
      --
      IF l_product_type_deenrolled_flag  = 'Y'
      THEN
        -- SKIP this VAS program, as same vas product type was deenrolled and not eligible for Reenroll
        CONTINUE;
      END IF;
      --
      -- *** Check whether same VAS product type is in deenroll_scheduled  ***
      BEGIN
        SELECT DECODE(COUNT(*),0, 'N','Y')
        INTO   l_prod_type_deenroll_sch_flag
        FROM   x_vas_subscriptions  vs,
               vas_programs_view    vp
        WHERE  vp.vas_product_type             = prog.vas_product_type
        AND    vs.vas_id                       = vp.vas_service_id
        AND    vs.vas_id                       <> prog.vas_service_id
        AND    vs.vas_esn                      = l_esn
        AND    vs.vas_is_active                = 'T'
        AND    vs.status                       IN  ('DEENROLL_SCHEDULED');
      EXCEPTION
        WHEN OTHERS THEN
          l_prod_type_deenroll_sch_flag :=  'N';
      END;
      --
      IF l_prod_type_deenroll_sch_flag  = 'Y'
      THEN
        -- SKIP this VAS program, as same vas product type is in deenroll_scheduled
        CONTINUE;
      END IF;
      --
      vas_program_details_result.status :=  CASE
                                            WHEN NOT (value_addedprg.is_valid_status (prog.objid, get_part_inst_local_rec.x_part_inst_status))
                                            THEN
                                              'NON_ELIGIBLE'
                                            WHEN value_addedprg.is_restricted_state (prog.objid,i_activation_zipcode)
                                            THEN
                                              'NON_ELIGIBLE'
                                            WHEN prog.x_handset_value = 'RESTRICTED'  AND
                                                 value_addedprg.is_restricted_handset (prog.objid, get_part_inst_local_rec.part_num2part_class)
                                            THEN
                                              'NON_ELIGIBLE'
                                            WHEN get_site_part_local_rec.install_date IS NOT NULL  AND
                                                 (TRUNC(SYSDATE) - get_site_part_local_rec.install_date) >= nvl(prog.offer_expiry,0) AND
                                                 i_ecommerce_orderid  IS NULL
                                            THEN
                                                'NON_ELIGIBLE'
                                            ELSE
                                              'ELIGIBLE'
                                            END;
      --
      dbms_output.put_line(' vas_program_details_result.STATUS'|| vas_program_details_result.STATUS);
      --
      -- vas_program_details_result.prog_id                  :=  prog.objid;
      -- vas_program_details_result.x_program_name           :=  prog.x_program_name;
      -- vas_program_details_result.x_program_desc           :=  prog.x_program_desc;
      vas_program_details_result.x_retail_price           :=  prog.x_retail_price;
      vas_program_details_result.part_number              :=  prog.part_number;
      vas_program_details_result.part_class               :=  prog.part_class;
      vas_program_details_result.x_charge_frq_code        :=  prog.x_charge_frq_code;
      vas_program_details_result.auto_pay_available       :=  prog.auto_pay_available;
      vas_program_details_result.deductible_amount        :=  prog.price_deductible;
      vas_program_details_result.device_price_tier        :=  prog.handset_msrp_tier;
      vas_program_details_result.mobile_name              :=  prog.mobile_name;
      vas_program_details_result.mobile_description       :=  prog.mobile_description;
      vas_program_details_result.mobile_more_info         :=  prog.mobile_more_info;
      vas_program_details_result.terms_condition_link     :=  prog.terms_condition_link;
      --vas_program_details_result.vas_name                 :=  prog.vas_name; -- name is fetching from script id
      vas_program_details_result.vas_category             :=  prog.vas_category;
      vas_program_details_result.vas_product_type         :=  prog.vas_product_type;
      vas_program_details_result.vas_description_english  :=  prog.vas_description_english;
      vas_program_details_result.vas_type                 :=  prog.vas_type;
      vas_program_details_result.vas_vendor               :=  prog.vas_vendor;
      vas_program_details_result.vas_service_id           :=  prog.vas_service_id;
      vas_program_details_result.vas_subscription_id      :=  ''; -- only for Enrolled services
      vas_program_details_result.service_days             :=  prog.service_days;
      vas_program_details_result.vas_offer_expiry_date    :=  get_site_part_local_rec.install_date  + nvl(prog.offer_expiry,0);
      vas_program_details_result.proration_applied_flag   :=  'N';
      vas_program_details_result.electronic_refund_days   :=  prog.electronic_refund_days;
      vas_program_details_result.esn_contact_objid        :=  cst_add_info.contact_objid;
      --

      BEGIN

	    v_script_type := NULL;
		v_script_id   := NULL;
        SELECT SUBSTR(xvv.vas_param_value,1,INSTR(xvv.vas_param_value,'_',1)-1),
               SUBSTR(xvv.vas_param_value,INSTR(xvv.vas_param_value,'_',1)+1)
        INTO   v_script_type,
               v_script_id
        FROM   x_vas_values xvv,
               x_vas_params xvp,
               x_vas_programs vprog
        WHERE  xvv.vas_params_objid = xvp.objid
        AND    xvv.vas_programs_objid = vprog.objid
        AND    xvp.vas_param_name = 'WEB_SCRIPT_ID'
        AND    vprog.objid = prog.vas_service_id;

        sa.scripts_pkg.get_script_prc(
		                       ip_sourcesystem  => v_script_source,
		                       ip_brand_name    => c.bus_org_id,
		                       ip_script_type   => v_script_type,
		                       ip_script_id     => v_script_id,
		                       ip_language      => v_script_language,
		                       ip_carrier_id    => NULL,
		                       ip_part_class    => NULL,
		                       op_objid         => v_op_objid,
		                       op_description   => v_op_description,
		                       op_script_text   => v_op_script_text,
		                       op_publish_by    => v_op_publish_by,
		                       op_publish_date  => v_op_publish_date,
		                       op_sm_link       => v_op_sm_link
		                     );

        IF v_op_script_text LIKE '%MISSING%'
        THEN
          vas_program_details_result.vas_name :=  prog.vas_name;
        ELSE
          vas_program_details_result.vas_name :=  v_op_script_text;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          vas_program_details_result.vas_name :=  prog.vas_name;
      END;

      IF  prog.proration_flag  = 'Y' AND
          get_part_inst_local_rec.x_part_inst_status <> '50'  -- skip proration for NEW Phones
      THEN
         -- Reinitialize
        l_prorated_days     :=  0;
        l_prorated_amount   :=  0;
        --
        sp_metadata.p_vas_proration_service ( i_esn                   =>  l_esn,
                                              i_vas_service_id        =>  vas_program_details_result.vas_service_id,
                                              i_current_expiry_date   =>  NULL,
                                              i_current_status        =>  'NOT_ENROLLED',
                                              i_part_number           =>  vas_program_details_result.part_number,
                                              i_source                =>  'BILLING',
                                              o_prorated_service_days =>  l_prorated_days,
                                              o_prorated_amount       =>  l_prorated_amount,
                                              o_error_code            =>  o_error_code,
                                              o_error_msg             =>  o_error_msg
                                            );
        --
        IF  NVL(l_prorated_amount,0)  > 0 AND
            NVL(l_prorated_days,0)    > 0
        THEN
          vas_program_details_result.service_days             :=  l_prorated_days;
          vas_program_details_result.x_retail_price           :=  l_prorated_amount;
          vas_program_details_result.proration_applied_flag   :=  'Y';
        END IF;
        --
      END IF;
      --
      IF vas_program_details_result.STATUS = 'ELIGIBLE'
      THEN
        --PIPE ROW (vas_program_details_result);
        o_vas_program_details_tab.extend;
        o_vas_program_details_tab(o_vas_program_details_tab.COUNT)  := vas_program_details_result;
      END IF;
    END LOOP;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others vas_management_pkg.p_get_eligible_vas_services ' || SUBSTR(SQLERRM,1,500);
END p_get_eligible_vas_services;
--
PROCEDURE p_subscribe_vas  (  i_esn                 IN      VARCHAR2,
                              i_min                 IN      VARCHAR2,
                              i_order_id            IN      VARCHAR2,
                              i_phone_make          IN      VARCHAR2,
                              i_phone_model         IN      VARCHAR2,
                              i_phone_price         IN      NUMBER,
                              i_activation_zipcode  IN      VARCHAR2,
                              i_email_address       IN      VARCHAR2,
                              i_device_price_tier   IN      VARCHAR2,
                              io_programs           IN OUT  subscribe_vas_programs_tab,
                              o_error_code          OUT     VARCHAR2,
                              o_error_msg           OUT     VARCHAR2
                           )
IS
--
  cst                     customer_type           :=  customer_type();
  wu                      customer_type           :=  customer_type();
  c                       customer_type           :=  customer_type();
  vpt                     vas_programs_type       :=  vas_programs_type();
  vs                      vas_subscriptions_type  :=  vas_subscriptions_type();
--
BEGIN
--
  -- Input validation
  IF i_esn IS NULL AND i_order_id IS NULL
  THEN
    o_error_code  :=  '300';
    o_error_msg   :=  'ESN and ORDER ID cannot be NULL';
    RETURN;
  END IF;
  --
  IF io_programs IS NULL
  THEN
    o_error_code  :=  '301';
    o_error_msg   :=  'Enrollment program details cannot be null';
    RETURN;
  END IF;
  --
  IF i_esn IS NOT NULL
  THEN
    wu.esn   :=  i_esn;
    --
    cst   :=  wu.get_web_user_attributes;
    --
    c     :=  c.get_contact_add_info( i_esn => i_esn);
  END IF;
  --
  FOR each IN 1 .. io_programs.COUNT
  LOOP
    --
    IF  io_programs(each).vas_service_id  IS NULL  OR
        io_programs(each).program_id      IS NULL
    THEN
      o_error_code  :=  '302';
      o_error_msg   :=  'Vas service id or Program id cannot be null';
      RETURN;
    END IF;
    --
    IF io_programs(each).subscription_start_date  IS NULL  OR
       io_programs(each).subscription_end_date    IS NULL
    THEN
      o_error_code  :=  '303';
      o_error_msg   :=  'Subscription start date and end date cannot be null';
      RETURN;
    END IF;
    --
    IF  io_programs(each).vas_service_id IS NOT NULL
    THEN
      vpt    :=  vas_programs_type ( i_vas_service_id => io_programs(each).vas_service_id);
      --
    ELSIF io_programs(each).program_id IS NOT NULL
    THEN
      vpt    :=  vas_programs_type ( i_program_param_id => io_programs(each).program_id);
      --
    END IF;
    --
    IF  vpt.vas_product_type   = 'HANDSET PROTECTION'  AND
        i_device_price_tier   IS NULL
    THEN
      o_error_code  :=  '304';
      o_error_msg   :=  'Device Price tier cannot be null for Handset protection VAS';
      RETURN;
    END IF;
    --
    vs.addl_info                 :=	  'VAS RECORDED -INITIAL';
    vs.device_price_tier         :=	  i_device_price_tier;
    vs.ecommerce_order_id        :=	  i_order_id;
    vs.objid                     :=	  seq_x_vas_subscriptions.NEXTVAL;
    vs.part_inst_objid           :=	  cst.esn_part_inst_objid;
    vs.program_enrolled_id       :=	  io_programs(each).program_enrolled_id;
    vs.program_parameters_objid  :=	  io_programs(each).program_id;
    vs.program_purch_hdr_objid   :=	  io_programs(each).program_purch_hdr_objid;
    vs.status                    :=	  CASE WHEN cst.min IS NULL OR cst.min LIKE 'T%'
                                           THEN 'ENROLL_SCHEDULED'  -- will be updated later by igate_in3, when actual MIN is available
                                           ELSE 'ENROLLED'
                                      END;
    vs.vas_esn                   :=	  i_esn;
    vs.vas_expiry_date           :=	  io_programs(each).subscription_end_date;
    vs.vas_id                    :=	  vpt.vas_service_id;
    vs.vas_is_active             :=	  'T';
    vs.vas_min                   :=	  CASE WHEN cst.min IS NULL OR cst.min LIKE 'T%'
                                           THEN NULL  -- will be updated later with actual MIN by igate_in3
                                           ELSE cst.min
                                      END;
    vs.vas_name                  :=	  vpt.vas_name;
    vs.vas_subscription_date     :=	  io_programs(each).subscription_start_date;
    vs.vas_subscription_id       :=	  sa.seq_vas_subscription_id.nextval;
    vs.vas_x_ig_order_type       :=	  'A';
    vs.web_user_objid            :=	  cst.web_user_objid;
    vs.x_email                   :=	  NVL(i_email_address,  c.contact_email);
    vs.x_manufacturer            :=	  i_phone_make;
    vs.x_model_number            :=	  i_phone_model;
    vs.x_purch_hdr_objid         :=	  io_programs(each).x_purch_hdr_objid;
    --vs.vendor_contract_id        :=   ''; -- It will be updated later once the ID Is generated at Vendor
    --
    -- Insert a new record into vas subscriptions table
    vs        :=  vs.ins  ( i_vas_subscriptions_type  =>  vs);
    --
    IF  vs.response =  'SUCCESS'
    THEN
      io_programs(each).vas_subscription_id :=  vs.vas_subscription_id;
    ELSE
      io_programs(each).vas_subscription_id :=  NULL;
    END IF;
    --
  END LOOP;
  --
  o_error_code  :=  '0';
  o_error_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others vas_management_pkg.p_subscribe_vas ' || SUBSTR(SQLERRM,1,500);
END p_subscribe_vas;
--
PROCEDURE p_get_vas_subscription_info  (  i_esn                 IN    VARCHAR2,
                                          i_min                 IN    VARCHAR2,
                                          i_vendor_contract_id  IN    VARCHAR2,
                                          i_vas_subscription_id IN    VARCHAR2,
                                          o_vas_status          OUT   VARCHAR2,
                                          o_vas_start_date      OUT   DATE,
                                          o_vas_expiry_date     OUT   DATE,
                                          o_site_part_status    OUT   VARCHAR2,
                                          o_error_code          OUT   VARCHAR2,
                                          o_error_msg           OUT   VARCHAR2
                                        )
IS
--
  vs       vas_subscriptions_type;
  c        customer_type :=  customer_type();
  cst      customer_type :=  customer_type();
  l_esn    VARCHAR2(50);
--
BEGIN
--
  -- Input validation
  IF i_esn  IS NULL AND i_min IS NULL
  THEN
    o_error_code  :=  700;
    o_error_msg   :=  'ESN OR MIN CANNOT BE NULL';
    RETURN;
  END IF;
  --
  IF i_esn IS NULL AND i_min IS NOT NULL
  THEN
    c.min :=  i_min;
    l_esn :=  c.get_esn ( i_min => c.min );
  ELSIF i_esn IS NOT NULL
  THEN
    l_esn :=  i_esn;
  END IF;
  --
  cst.esn   :=  l_esn;
  cst       :=  cst.get_service_plan_attributes();
  --
  vs        :=   vas_subscriptions_type ( i_esn                 =>  l_esn,
                                          i_vendor_contract_id  =>  i_vendor_contract_id,
                                          i_vas_subscription_id =>  i_vas_subscription_id
                                        );
  --
  --
  IF vs.response NOT LIKE '%SUCCESS%'
  THEN
    o_error_code      :=  '701';
    o_error_msg       :=  'VAS SUBSCRIPTION CANNOT BE FOUND';
    RETURN;
  END IF;
  --
  o_vas_status          :=  vs.status;
  o_vas_start_date      :=  vs.vas_subscription_date;
  o_vas_expiry_date     :=  vs.vas_expiry_date;
  o_site_part_status    :=  UPPER (cst.site_part_status);
  --
  o_error_code      :=  '0';
  o_error_msg       :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of vas_management_pkg.p_get_vas_subscription_info - ' || SUBSTR(SQLERRM,1,500);
END p_get_vas_subscription_info;
--
-- This procedure is called from SPF Service to update the Program Enroll ID and vas subscription status
--
PROCEDURE p_update_vas_enrollment ( i_esn                   IN    VARCHAR2,
                                    i_min                   IN    VARCHAR2,
                                    i_vas_subscription_id   IN    VARCHAR2,
                                    i_program_enroll_id     IN    VARCHAR2,
                                    i_program_param_id      IN    VARCHAR2,
                                    i_status                IN    VARCHAR2,
                                    i_vas_expiry_date       IN    DATE,
                                    o_error_code            OUT   VARCHAR2,
                                    o_error_msg             OUT   VARCHAR2)
IS
--
  vs      vas_subscriptions_type  :=  vas_subscriptions_type();
  pe      program_enrolled_type   :=  program_enrolled_type();
  pt      program_trans_type      :=  program_trans_type ();
  c       customer_type           :=  customer_type();
  --
  l_program_parameters_rec    x_program_parameters%ROWTYPE;
--
BEGIN
--
  IF i_esn IS NULL OR i_vas_subscription_id IS NULL OR i_program_enroll_id IS NULL
  THEN
    o_error_code  :=  '1300';
    o_error_msg   :=  'INPUT VALUES CANNOT BE NULL';
    RETURN;
  END IF;
  --
  vs      :=  vas_subscriptions_type ( i_vas_subscription_id  =>  i_vas_subscription_id);
  --
  IF vs.vas_esn <>  i_esn
  THEN
    o_error_code  :=  '1301';
    o_error_msg   :=  'INVALID ESN FOR THE VAS SUBSCRIPTION ID';
    RETURN;
  END IF;
  --
  c     :=  c.get_contact_add_info( i_esn => vs.vas_esn);
  --
  IF i_status = 'ENROLLED'
  THEN
    --
    -- Scenario : VAS goes to Suspend mode due to base plan past due.
    --            When the reactivation is done, services will call this to update the VAS
    IF  vs.program_enrolled_id = NVL(i_program_enroll_id,0)  AND
        vs.status   = 'SUSPENDED'
    THEN
      -- Move the status from suspended to enrolled
      UPDATE x_program_enrolled
      SET    x_enrollment_status = i_status,
             x_update_stamp      = SYSDATE,
             x_reason            = 'ENROLLMENT IS ACTIVE NOW'
      WHERE  objid               = vs.program_enrolled_id
      AND    x_enrollment_status IN  ('SUSPENDED');
      --
      -------- Get the program name for logging ------------
      BEGIN
        SELECT  *
        INTO    l_program_parameters_rec
        FROM    x_program_parameters
        WHERE   objid = vs.program_parameters_objid;
      EXCEPTION
        WHEN OTHERS THEN
          l_program_parameters_rec  :=  NULL;
      END;
      --
      pe  :=  program_enrolled_type ( i_program_enrolled_objid => vs.program_enrolled_id);
      --
      /*  If the program enrolled update is successful then insert log */
      --
      IF SQL%ROWCOUNT > 0
      THEN
        -- Insert a log into the program history
        -- Insert record into program trans.
        pt.enrollment_status      := pe.enrollment_status;
        pt.enroll_status_reason   := pe.enrollment_status || ' BACK FROM SUSPENDED';
        pt.float_given            := NULL;
        pt.cooling_given          := NULL;
        pt.grace_period_given     := NULL;
        pt.trans_date             := SYSDATE;
        pt.action_text            := pe.enrollment_status;
        pt.action_type            := pe.enrollment_status;
        pt.reason                 := l_program_parameters_rec.x_program_name || '    ' || 'is ' || pe.enrollment_status;
        pt.sourcesystem           := pe.sourcesystem;
        pt.esn                    := pe.esn;
        pt.exp_date               := SYSDATE;
        pt.cooling_exp_date       := SYSDATE;
        pt.update_status          := 'I';
        pt.update_user            := 'System';
        pt.pgm_tran2pgm_entrolled := pe.program_enrolled_objid;
        pt.pgm_trans2web_user     := pe.pgm_enroll2web_user;
        pt.pgm_trans2site_part    := pe.pgm_enroll2site_part;
        --
        -- insert into x_program_trans
        pt := pt.ins;
        --
        ---------------- Insert a billing Log ------------------
        INSERT INTO x_billing_log
          (
          objid,
          x_log_category,
          x_log_title,
          x_log_date,
          x_details,
          x_program_name,
          x_nickname,
          x_esn,
          x_originator,
          x_contact_first_name,
          x_contact_last_name,
          x_agent_name,
          x_sourcesystem,
          billing_log2web_user
          )
        VALUES
          (
          billing_seq ('X_BILLING_LOG'),
          'Program',
          'Program '||pe.enrollment_status,
          SYSDATE,
          l_program_parameters_rec.x_program_name || ' '||pe.enrollment_status ||' BACK FROM SUSPENDED ',
          l_program_parameters_rec.x_program_name,
          billing_getnickname (vs.vas_esn),
          vs.vas_esn,
          'System',
          c.contact_first_name,
          c.contact_last_name,
          'System',
          pe.sourcesystem,
          pe.pgm_enroll2web_user
          );
      END IF;
    END IF;
    --
    -- update vas subscription status, vendor contract id and expiry date
    --
    UPDATE x_vas_subscriptions
    SET    vas_expiry_date            =   i_vas_expiry_date,
           program_enrolled_id        =   i_program_enroll_id,
           program_parameters_objid   =   NVL(i_program_param_id,program_parameters_objid),
           status                     =   i_status
    WHERE  NVL(vas_subscription_id,0) =  i_vas_subscription_id
    AND    vas_is_active     =   'T'
    AND    NVL(vas_esn,0)    =   i_esn;
    --
    IF SQL%ROWCOUNT = 0
    THEN
      o_error_code  :=  '1302';
      o_error_msg   :=  'NO DATA TO UPDATE';
      RETURN;
    END IF;
  ELSE
    o_error_code  :=  '1303';
    o_error_msg   :=  'INVALID STATUS CODE';
  END IF;
  --
  o_error_code  :=  '0';
  o_error_msg   :=  'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of vas_management_pkg.p_update_vas_enrollment - ' || SUBSTR(SQLERRM,1,500);
END p_update_vas_enrollment;
--
-- This procedure will be called from recurring payment job , billing payment recon and deenroll jonb
-- to keep the expiry date in sync with the next charge date in program enrolled
--
PROCEDURE p_update_vas_subscription  ( i_esn                IN    VARCHAR2,
                                       i_program_enroll_id  IN    VARCHAR2)

IS
--
  l_new_expiry_date     DATE;
  pe                    program_enrolled_type   :=  program_enrolled_type ();
  vpt                   vas_programs_type       :=  vas_programs_type(); -- CR49058
--
BEGIN
--
  pe      :=  program_enrolled_type ( i_program_enrolled_objid => i_program_enroll_id);
  vpt     :=  vas_programs_type ( i_program_param_id => pe.pgm_enroll2pgm_parameter);
  --
  IF  TRUNC(NVL(pe.next_charge_date, SYSDATE)) > TRUNC(SYSDATE) AND -- to check if the recurring payment is successful
      pe.enrollment_status    =   'ENROLLED'
  THEN
    UPDATE x_vas_subscriptions
    SET    vas_expiry_date      =   pe.next_charge_date,
           status               =   pe.enrollment_status,-- 'ENROLLED',
           update_date          =   SYSDATE
    WHERE  NVL(vas_esn,0)       =   i_esn
    AND    program_enrolled_id  =   i_program_enroll_id
    AND    status               NOT IN ( 'DEENROLLED' ,'DEENROLL_SCHEDULED')
    AND    vas_is_active        =   'T';
    --
  ELSIF pe.enrollment_status    =   'DEENROLLED'
  THEN
    UPDATE x_vas_subscriptions
    SET    status               =   (CASE WHEN TRUNC(vas_expiry_date)   <= TRUNC(SYSDATE)  AND
                                               status                   = 'ENROLLED'       AND -- update status to suspend only for enrolled
                                               NVL(vpt.grace_period, 0) <> 0               AND -- skip Warranty which goes deenrolled after expiry
                                               (TRUNC(SYSDATE) - TRUNC(vas_expiry_date))  < NVL(vpt.grace_period, 0)
                                          THEN  'SUSPENDED'
                                          ELSE  pe.enrollment_status
                                    END),
           update_date          =   SYSDATE
    WHERE  NVL(vas_esn,0)       =   i_esn
    AND    program_enrolled_id  =   i_program_enroll_id
    AND    status               IN  ('ENROLLED','SUSPENDED')
    AND    vas_is_active        =   'T';
    --
  END IF;
--
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END p_update_vas_subscription;
--
-- This procedure will be called from igate_in3 to update the actual MIN
/*  When customer tries to purchase VAS along with Activation, only TMIN will be available.
    Once the actual MIN is available, it will updated in x_vas_subscription table along with applicable vas status */
--
PROCEDURE p_update_vas_min      ( i_esn           IN    VARCHAR2,
                                  i_min           IN    VARCHAR2,
                                  i_order_type    IN    VARCHAR2 DEFAULT NULL,
                                  o_error_code    OUT   VARCHAR2,
                                  o_error_msg     OUT   VARCHAR2
                                )
IS
  c_min VARCHAR2(30);
BEGIN
--
  IF ( i_order_type IS NULL OR i_order_type IN ('A','AP','CR','R','EPIR','IPI','MINC','PIR','E') )
  THEN
    -- GET min
    c_min := CASE
               WHEN i_min LIKE 'T%' THEN sa.customer_info.get_min ( i_esn => i_esn )
               ELSE i_min
             END;
    IF c_min NOT LIKE 'T%'
    THEN
    UPDATE  x_vas_subscriptions
    SET     vas_min         =   c_min,
            status          =   'ENROLLED',
            addl_info       =   'REAL MIN IS UPDATED : STATUS MOVED TO ENROLLED',
            update_date     =   SYSDATE
    WHERE   vas_esn       = i_esn
      AND     ( vas_min LIKE 'T%' OR vas_min IS NULL)
    AND     status        = 'ENROLL_SCHEDULED'
    AND     vas_is_active = 'T';
    --
    o_error_code  :=  '0';
    o_error_msg   :=  'SUCCESS';
    END IF;
  END IF;
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of vas_management_pkg.p_update_vas_min - ' || SUBSTR(SQLERRM,1,500);
END p_update_vas_min;
--
-- Procedure called by ETL to update vendor contract id generated by third party
--
PROCEDURE p_update_vas_contract_id  ( i_esn                 IN    VARCHAR2,
                                      i_vas_subscription_id IN    VARCHAR2,
                                      i_contract_id         IN    VARCHAR2,
                                      o_error_code          OUT   VARCHAR2,
                                      o_error_msg           OUT   VARCHAR2)
IS
BEGIN
--
  IF i_esn  IS NULL OR i_vas_subscription_id IS NULL OR i_contract_id IS NULL
  THEN
    o_error_code  :=  '1400';
    o_error_msg   :=  'INPUT PARAMETERS CANNOT BE NULL';
    RETURN;
  END IF;
  --
  UPDATE  x_vas_subscriptions
  SET     vendor_contract_id    =   NVL(i_contract_id,vendor_contract_id),
          update_date           =   SYSDATE,
          is_claimed            =   'Y' -- Bug fix for 33886
  WHERE   vendor_contract_id  IS NULL
  AND     vas_esn             = i_esn
  AND     vas_subscription_id = i_vas_subscription_id
  AND     vas_is_active       = 'T';
  --
  COMMIT;
  --
  o_error_code  :=  '0';
  o_error_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of vas_management_pkg.p_update_vas_contract_id - ' || SUBSTR(SQLERRM,1,500);
END p_update_vas_contract_id;
--
-- New procedure to check the ESN / SIM (BYOP) is a claim device
-- procedure called from SERVICES to check for claim device and to get the OLD ESN and MIN
PROCEDURE p_check_claim_device  ( i_esn               IN    VARCHAR2,
                                  i_sim               IN    VARCHAR2,
                                  i_is_byod           IN    VARCHAR2 DEFAULT 'N',
                                  o_claim_device_flag OUT   VARCHAR2,
                                  o_old_esn           OUT   VARCHAR2,
                                  o_min               OUT   VARCHAR2,
                                  o_error_code        OUT   VARCHAR2,
                                  o_error_msg         OUT   VARCHAR2
                                )
IS
--
cst           customer_type     :=  customer_type ();
--
BEGIN
--
  o_error_code    :=  '0';
  o_error_msg     :=  'SUCCESS';
  --
  IF i_esn  IS NULL AND i_is_byod ='N'
  THEN
    o_error_code    :=  '90';
    o_error_msg     :=  'ESN CANNOT BE NULL FOR NON BYOD';
    RETURN;
  ELSIF i_sim  IS NULL AND i_is_byod ='Y'
  THEN
    o_error_code    :=  '91';
    o_error_msg     :=  'SIM CANNOT BE NULL FOR BYOD';
    RETURN;
  END IF;
  --
  IF i_is_byod  = 'N'    -- HANDSET
  THEN
    BEGIN
      SELECT old_esn      -- get old ESN using new ESN
      INTO   o_old_esn
      FROM  sa.asurion_outbound_positive a
      WHERE a.imei      =  i_esn
      AND   a.load_date = ( SELECT  MAX(b.load_date)
                            FROM    sa.asurion_outbound_positive b
                            WHERE   b.imei  = a.imei);
    EXCEPTION
      WHEN OTHERS THEN
        o_claim_device_flag :=  'N';
        RETURN;
    END;
    --
  ELSE    -- BYOP devices
    BEGIN
      SELECT old_esn      -- get old ESN using new SIM
      INTO   o_old_esn
      FROM  sa.asurion_outbound_positive a
      WHERE a.sim_id    =  i_sim
      AND   a.load_date = ( SELECT  MAX(b.load_date)
                            FROM    sa.asurion_outbound_positive b
                            WHERE   b.sim_id  = a.sim_id);
    EXCEPTION
      WHEN OTHERS THEN
        o_claim_device_flag :=  'N';
        RETURN;
    END;
  END IF;
  -- get the MIN using old ESN
  IF o_old_esn IS NOT NULL
  THEN
    o_min               :=  cst.get_min ( i_esn =>  o_old_esn);
    o_claim_device_flag :=  'Y';
    RETURN;
  END IF;
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code    :=  99;
    o_error_msg     :=  'Failed in when others of p_check_claim_device - '|| SUBSTR(SQLERRM,1,100);
END p_check_claim_device;
--
-- New procedure to check the ESN / SIM (BYOP) is a claim device
-- procedure called from the get eligible vas services to determine the claim device
PROCEDURE p_check_claim_device  ( i_old_esn           IN    VARCHAR2,
                                  i_new_esn           IN    VARCHAR2,
                                  o_claim_device_flag OUT   VARCHAR2,
                                  o_error_code        OUT   VARCHAR2,
                                  o_error_msg         OUT   VARCHAR2
                                )
IS
--
cst           customer_type     :=  customer_type ();
pit           part_inst_type    :=  part_inst_type ();
--
BEGIN
--
  o_error_code    :=  '0';
  o_error_msg     :=  'SUCCESS';
  --
  IF i_old_esn  IS NULL OR i_new_esn IS NULL
  THEN
    o_error_code    :=  '90';
    o_error_msg     :=  'OLD AND NEW ESN CANNOT BE NULL';
    RETURN;
  END IF;
  --
  cst     :=  cst.get_part_class_attributes (i_esn  =>  i_new_esn);
  --
  pit     :=  part_inst_type ( i_esn =>   i_new_esn);
  --
  IF cst.device_type  IN ('BYOP','BYOT')    -- BYOP devices
  THEN
    --
    BEGIN
      SELECT DECODE(COUNT(*),0,'N','Y')
      INTO   o_claim_device_flag
      FROM  sa.asurion_outbound_positive a
      WHERE a.sim_id    =   pit.iccid
      AND   a.old_esn   =   i_old_esn;
    EXCEPTION
      WHEN OTHERS THEN
        o_claim_device_flag :=  'N';
        RETURN;
    END;
  ELSE    -- HANDSET
    BEGIN
      SELECT DECODE(COUNT(*),0,'N','Y')
      INTO   o_claim_device_flag
      FROM  sa.asurion_outbound_positive a
      WHERE a.imei      =  i_new_esn
      AND   a.old_esn   =  i_old_esn;
    EXCEPTION
      WHEN OTHERS THEN
        o_claim_device_flag :=  'N';
        RETURN;
    END;
  END IF;
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code    :=  99;
    o_error_msg     :=  'Failed in when others of p_check_claim_device - '|| SUBSTR(SQLERRM,1,100);
END p_check_claim_device;
--
--
PROCEDURE p_calculate_prorated_amount ( i_total_amount            IN    NUMBER,
                                        i_tax_amount              IN    NUMBER,
                                        i_e911_amount             IN    NUMBER,
                                        i_usf_taxamount           IN    NUMBER,
                                        i_rcrf_tax_amount         IN    NUMBER,
                                        i_actual_service_days     IN    NUMBER,
                                        i_remaining_service_days  IN    NUMBER,
                                        o_total_refund_amount     OUT   NUMBER,
                                        o_tax_refund_amount       OUT   NUMBER,
                                        o_e911_refund_amount      OUT   NUMBER,
                                        o_usf_refund_amount       OUT   NUMBER,
                                        o_rcrf_refund_amount      OUT   NUMBER,
                                        o_error_code              OUT   VARCHAR2,
                                        o_error_msg               OUT   VARCHAR2
                                      )
IS
--
  l_total_amount_per_day      NUMBER;
  l_tax_amount_per_day        NUMBER;
  l_e911_amount_per_day       NUMBER;
  l_usf_taxamount_per_day     NUMBER;
  l_rcrf_tax_amount_per_day   NUMBER;
  l_prorated_amount_per_day   NUMBER;
--
BEGIN
  --  Input Validation
  IF i_total_amount IS NULL  OR i_actual_service_days IS NULL OR i_remaining_service_days IS NULL
  THEN
    o_error_code  := '900';
    o_error_msg   := 'Input values cannot be null';
    RETURN;
  END IF;
  --
  IF  i_actual_service_days   <= 0 OR
      i_remaining_service_days <= 0
  THEN
    o_error_code  := '901';
    o_error_msg   := 'INPUT DAYS CANNOT BE 0';
    RETURN;
  END IF;
  --
  -- Calculate cost per day
  l_total_amount_per_day    :=  i_total_amount           / i_actual_service_days;
  l_tax_amount_per_day      :=  NVL(i_tax_amount,0)      / i_actual_service_days;
  l_e911_amount_per_day     :=  NVL(i_e911_amount,0)     / i_actual_service_days;
  l_usf_taxamount_per_day   :=  NVL(i_usf_taxamount,0)   / i_actual_service_days;
  l_rcrf_tax_amount_per_day :=  NVL(i_rcrf_tax_amount,0) / i_actual_service_days;
  --
  -- Calculate refund amount
  o_total_refund_amount     :=  l_total_amount_per_day    * i_remaining_service_days;
  o_tax_refund_amount       :=  l_tax_amount_per_day      * i_remaining_service_days;
  o_e911_refund_amount      :=  l_e911_amount_per_day     * i_remaining_service_days;
  o_usf_refund_amount       :=  l_usf_taxamount_per_day   * i_remaining_service_days;
  o_rcrf_refund_amount      :=  l_rcrf_tax_amount_per_day * i_remaining_service_days;
  --
  o_error_code      :=  '0';
  o_error_msg       :=  'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of vas_management_pkg.p_calculate_prorated_amount - ' || SUBSTR(SQLERRM,1,500);
END p_calculate_prorated_amount;
--
PROCEDURE p_calculate_vas_refund  ( i_esn                     IN      VARCHAR2,
                                    i_vas_service_id          IN      VARCHAR2,
                                    i_vas_subscription_id     IN      VARCHAR2,
                                    i_program_id              IN      VARCHAR2,
                                    i_cancel_effective_date   IN      DATE,
                                    o_total_refund_amount     OUT     NUMBER,
                                    o_tax_refund_amount       OUT     NUMBER,
                                    o_e911_refund_amount      OUT     NUMBER,
                                    o_usf_refund_amount       OUT     NUMBER,
                                    o_rcrf_refund_amount      OUT     NUMBER,
                                    o_error_code              OUT     VARCHAR2,
                                    o_error_msg               OUT     VARCHAR2
                                  )
IS
--
  vs     vas_subscriptions_type :=  vas_subscriptions_type();
  vpt    vas_programs_type      :=  vas_programs_type();
  l_total_amount            NUMBER;
  l_tax_amount              NUMBER;
  l_e911_amount             NUMBER;
  l_usf_amount              NUMBER;
  l_rcrf_amount             NUMBER;
  l_remaining_service_days  NUMBER;
--
BEGIN
  --
  --  Input Validation
  IF i_esn IS NULL  OR i_vas_service_id IS NULL OR I_program_id IS NULL OR i_cancel_effective_date IS NULL
  THEN
    o_error_code  := '1000';
    o_error_msg   := 'Input values cannot be null';
    RETURN;
  END IF;
  --
  vpt         :=  vas_programs_type (i_vas_service_id => i_vas_service_id );
  --
  IF vpt.response NOT LIKE '%SUCCESS%'
  THEN
    o_error_code      :=  '1001';
    o_error_msg       :=  'INVALID VAS SERVICE ID';
    RETURN;
  END IF;
  --
  vs          :=  vas_subscriptions_type ( i_esn             => i_esn,
                                           i_vas_service_id  => i_vas_service_id);
  --
  IF vs.response NOT LIKE '%SUCCESS%'
  THEN
    o_error_code      :=  '1002';
    o_error_msg       :=  'INVALID VAS SERVICE ID AND ESN';
    RETURN;
  END IF;
  --
  IF  vs.vas_subscription_id  <> i_vas_subscription_id
  THEN
    o_error_code      :=  '1003';
    o_error_msg       :=  'INVALID VAS SUBSCRIPTION ID';
    RETURN;
  END IF;
  --
  IF TRUNC(i_cancel_effective_date)  < TRUNC(SYSDATE)
  THEN
    o_error_code      :=  '1004';
    o_error_msg       :=  'CANCELATION EFFECTIVE DATE CANNOT BE IN THE PAST';
    RETURN;
  END IF;
  --
  SELECT  x_amount, x_tax_amount, X_E911_TAX_AMOUNT, x_usf_taxamount, x_rcrf_tax_amount
  INTO    l_total_amount, l_tax_amount, l_e911_amount, l_usf_amount,  l_rcrf_amount
  FROM    x_program_purch_hdr
  WHERE   objid   = vs.program_purch_hdr_objid;
  --
  IF TRUNC(vs.vas_expiry_date) > TRUNC(SYSDATE)
  THEN
    l_remaining_service_days  :=  TRUNC(vs.vas_expiry_date) - TRUNC(i_cancel_effective_date) ;
  ELSE
    l_remaining_service_days  :=  0;
  END IF;
  --
  IF l_remaining_service_days = 0
  THEN
    o_total_refund_amount     :=  0;
    o_tax_refund_amount       :=  0;
    o_e911_refund_amount      :=  0;
    o_usf_refund_amount       :=  0;
    o_rcrf_refund_amount      :=  0;
    --
    o_error_code              :=  '0';
    o_error_msg               :=  'SUCCESS';
    RETURN;
  END IF;
  --
  p_calculate_prorated_amount ( i_total_amount            =>  l_total_amount,
                                i_tax_amount              =>  l_tax_amount,
                                i_e911_amount             =>  l_e911_amount,
                                i_usf_taxamount           =>  l_usf_amount,
                                i_rcrf_tax_amount         =>  l_rcrf_amount,
                                i_actual_service_days     =>  vpt.service_days,
                                i_remaining_service_days  =>  l_remaining_service_days,
                                o_total_refund_amount     =>  o_total_refund_amount,
                                o_tax_refund_amount       =>  o_tax_refund_amount,
                                o_e911_refund_amount      =>  o_e911_refund_amount,
                                o_usf_refund_amount       =>  o_usf_refund_amount,
                                o_rcrf_refund_amount      =>  o_rcrf_refund_amount,
                                o_error_code              =>  o_error_code,
                                o_error_msg               =>  o_error_msg);
  --
  o_error_code      :=  '0';
  o_error_msg       :=  'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  := '99';
    o_error_msg   := 'Failed in when others of vas_management_pkg.p_calculate_vas_refund - ' || SUBSTR(SQLERRM,1,500);
END p_calculate_vas_refund;
--
PROCEDURE p_transfer_vas    ( i_from_esn              IN      VARCHAR2,
                              i_to_esn                IN      VARCHAR2,
                              io_subscription_id_tab  IN OUT  vas_subscriptions_id_tab,
                              o_error_code            OUT     VARCHAR2,
                              o_error_msg             OUT     VARCHAR2
                            )
IS
--
  CURSOR  c_program_details ( i_vas_subscription_id   IN NUMBER)
  IS
  SELECT  pe.objid,
          pe.pgm_enroll2web_user,
          pe.pgm_enroll2pgm_parameter,
          pp.x_prog_class,
          pe.x_esn,
          pp.x_program_name
  FROM    x_program_enrolled    pe,
          x_program_parameters  pp,
          x_vas_subscriptions   vs
  WHERE   1 =1
  AND     pp.x_prog_class               IN  ( SELECT x_param_value
                                              FROM sa.table_x_parameters
                                              WHERE x_param_name = 'NON_BASE_PROGRAM_CLASS'
                                            )
  AND     pe.pgm_enroll2pgm_parameter   =   pp.objid
  AND     (pe.x_enrollment_status        =   'ENROLLED' OR
           (pe.x_enrollment_status        =   'SUSPENDED' AND
            pe.x_reason                   =   'UPGRADE'))
  AND     pe.x_esn                      =   vs.vas_esn
  AND     vs.program_enrolled_id        =   pe.objid
  AND     vs.vas_is_active              =   'T'
  AND     vs.status                     IN  ('ENROLLED', 'SUSPENDED')
  AND     vs.vas_esn                    =   i_from_esn
  AND     vs.vas_subscription_id        =   i_vas_subscription_id;
  --
  cst_from_esn          customer_type           :=  customer_type ();
  cst_to_esn            customer_type           :=  customer_type ();
  wu                    customer_type           :=  customer_type ();
  pt                    program_trans_type      :=  program_trans_type ();
  pe                    program_enrolled_type   :=  program_enrolled_type ();
  pe_upd                program_enrolled_type   :=  program_enrolled_type ();
  vs                    vas_subscriptions_type  :=  vas_subscriptions_type();
  vs_new                vas_subscriptions_type  :=  vas_subscriptions_type();
  vp_enrolled           vas_programs_type       :=  vas_programs_type();
  n_pgm_upgrade_Objid   NUMBER;
  l_error_number        NUMBER;
  l_error_message       VARCHAR2(1000);
  l_first_name          table_contact.first_name%TYPE;
  l_last_name           table_contact.last_name%TYPE;
  l_claim_device_flag   VARCHAR2(1) :=  'N';
--
BEGIN
  --
  IF i_from_esn IS NULL OR i_to_esn IS NULL OR io_subscription_id_tab IS NULL
  THEN
    o_error_code  := '1101';
    o_error_msg   := 'INPUT PARAMETERS CANNOT BE NULL';
    RETURN;
  END IF;
  --
  wu.esn   :=  i_from_esn;
  --
  cst_from_esn   :=  wu.get_web_user_attributes;
  --
  IF cst_from_esn.response NOT LIKE '%SUCCESS%'
  THEN
    o_error_code  := '1102';
    o_error_msg   := 'FROM ESN NOT FOUND: ' || cst_from_esn.response;
    RETURN;
  END IF;
  --
  wu.esn   :=  i_to_esn;
  --
  cst_to_esn   :=  wu.get_web_user_attributes;
  --
  IF cst_to_esn.response NOT LIKE '%SUCCESS%'
  THEN
    o_error_code  := '1103';
    o_error_msg   := 'TO ESN NOT FOUND: ' || cst_to_esn.response;
    RETURN;
  END IF;
  --
  IF cst_from_esn.web_user_objid <>  cst_to_esn.web_user_objid
  THEN
    o_error_code  := '1104';
    o_error_msg   := 'TO-ESN DOESNT BELONGS TO FROM-ESN ACCOUNT';
    RETURN;
  END IF;
  --
  -- check for claim device
  p_check_claim_device  ( i_old_esn           =>  i_from_esn,
                          i_new_esn           =>  i_to_esn,
                          o_claim_device_flag =>  l_claim_device_flag,
                          o_error_code        =>  o_error_code,
                          o_error_msg         =>  o_error_msg
                        );
  --
  FOR each_rec  IN  1..io_subscription_id_tab.COUNT
  LOOP
    FOR each_pgm  IN  c_program_details ( i_vas_subscription_id => io_subscription_id_tab(each_rec).vas_subscriptions_id )
    LOOP
      --
      vs      :=  vas_subscriptions_type ( i_vas_subscription_id  =>  io_subscription_id_tab(each_rec).vas_subscriptions_id);
      --
      vp_enrolled         :=  vas_programs_type (i_vas_service_id => vs.vas_id );
      --
      -- check whether transfer is eligible for the vas program based on Regular Upgrade / Replacement Upgrade
      --
      IF  (l_claim_device_flag  = 'Y' AND vp_enrolled.transfer_on_replacement_flag  = 'Y') OR
          (l_claim_device_flag  = 'N' AND vp_enrolled.transfer_on_upgrade_flag      = 'Y')
      THEN
        --
        /* commenting this as this is not done through JOB
        --
        n_pgm_upgrade_Objid  :=  billing_seq ('X_PROGRAM_UPGRADE');
        --
        INSERT
        INTO x_program_upgrade
        (
          objid,
          x_esn,
          x_replacement_esn,
          x_type,
          x_date,
          x_status,
          pgm_upgrade2case,
          x_description
        )
        VALUES
        (
          n_pgm_upgrade_Objid,
          i_from_esn,
          i_to_esn,
          'VAS Transfer',
          SYSDATE,
          'INCOMPLETE',
          hpp_rec.objid,
          'Initiated the process : VAS Transfer from x_esn to x_replacement_esn'
        );
        */
        -- Checks: Check if the ESN is compatible with all the programs that have been enrolled into.
        billing_canenroll( each_pgm.pgm_enroll2web_user,
                           i_to_esn,
                           each_pgm.pgm_enroll2pgm_parameter,
                           l_error_number,
                           l_error_message);
        --
        pe  :=  program_enrolled_type ( i_program_enrolled_objid => each_pgm.objid);
        --
        BEGIN
          SELECT  first_name,
                  last_name
          INTO    l_first_name,
                  l_last_name
          FROM    table_contact
          WHERE   objid   = cst_from_esn.web_contact_objid;
        EXCEPTION
        WHEN OTHERS THEN
          l_first_name  :=  NULL;
          l_last_name   :=  NULL;
        END;
        --
        IF (l_error_number IN (1
                              ,2
                              ,3
                              ,4
                              ,8001
                              ,8007
                              ,7511
                              ,7508)  OR
             (l_error_number                      = 8009 AND
              cst_to_esn.esn_part_inst_status     = '52'  AND
              UPPER(cst_to_esn.site_part_status)  IN( 'CARRIERPENDING'))) -- carrierpending is allowed, since vas doesn't go to carrier
        THEN
          -- Insert record into program trans.
          pt.enrollment_status      := pe.enrollment_status;
          pt.enroll_status_reason   := 'ESN is being upgraded.';
          pt.float_given            := NULL;
          pt.cooling_given          := NULL;
          pt.grace_period_given     := NULL;
          pt.trans_date             := SYSDATE;
          pt.action_text            := 'Upgrading the ESN';
          pt.action_type            := 'TRANSFER';
          pt.reason                 := SUBSTR('Due to upgrade from ESN ' || i_from_esn || ' to ' || i_to_esn || ' - Program ' || each_pgm.x_program_name || ' is transferred successfully',1,255);
          pt.sourcesystem           := pe.sourcesystem;
          pt.esn                    := pe.esn;
          pt.exp_date               := pe.exp_date;
          pt.cooling_exp_date       := pe.cooling_exp_date;
          pt.update_status          := 'I';
          pt.update_user            := 'System';
          pt.pgm_tran2pgm_entrolled := pe.program_enrolled_objid;
          pt.pgm_trans2web_user     := pe.pgm_enroll2web_user;
          pt.pgm_trans2site_part    := pe.pgm_enroll2site_part;
          --
          -- insert into x_program_trans
          pt := pt.ins;
          --
          pe_upd.program_enrolled_objid   :=  each_pgm.objid;
          pe_upd.esn                      :=  i_to_esn;
          pe_upd.pgm_enroll2site_part     :=  cst_to_esn.site_part_objid;
          pe_upd.pgm_enroll2part_inst     :=  cst_to_esn.esn_part_inst_objid;
          pe_upd.wait_exp_date            :=  NULL;
          pe_upd.grace_period             :=  NULL;
          pe_upd.cooling_period           :=  NULL;
          pe_upd.enrollment_status        :=  'ENROLLED'; -- updating status for transfered new esn
          --
          -- Update x_program_enrolled
          pe_upd := pe_upd.upd ( i_program_enrolled_type => pe_upd );
          --
          -- Code to update vas subscription record with OLD ESN
          UPDATE  x_vas_subscriptions
          SET     vas_is_active   = 'F',
                  status          = 'DEENROLLED',
                  addl_info       = 'DEVICE REPLACEMENT - '|| 'NEW ESN: '||i_to_esn
          WHERE   vas_subscription_id = vs.vas_subscription_id;
          --
          -- copy the data to new instance of type
          vs_new    :=  vs;
          --
          -- update attributes for new ESN
          vs_new.objid              :=  NULL;
          vs_new.vas_esn            :=  i_to_esn;
          vs_new.ecommerce_order_id :=  NULL;
          vs_new.part_inst_objid    :=	cst_to_esn.esn_part_inst_objid;
          vs_new.vas_is_active      :=  'T';
          vs_new.status             :=  'ENROLLED';

		  IF l_claim_device_flag  = 'Y'
		  THEN
            vs_new.is_claimed       :=  'Y';
		  END IF;
          --
          -- Insert a new record into vas subscriptions table with NEW ESN
          vs_new        :=  vs_new.ins  ( i_vas_subscriptions_type  =>  vs_new);
          --
          ---------------- Insert the record into billing log --------------------
          -- Log for old esn
          INSERT INTO x_billing_log
            (objid
            ,x_log_category
            ,x_log_title
            ,x_log_date
            ,x_details
            ,x_program_name
            ,x_nickname
            ,x_esn
            ,x_originator
            ,x_contact_first_name
            ,x_contact_last_name
            ,x_agent_name
            ,x_sourcesystem
            ,billing_log2web_user)
          VALUES
            (billing_seq('X_BILLING_LOG')
            ,'Program'
            ,'Upgrade'
            ,SYSDATE
            ,SUBSTR('Upgrading ESN ' || i_from_esn || ' to ' || i_to_esn || ' - ' || each_pgm.x_program_name || ' transferred out successfully',1,1000)
            ,each_pgm.x_program_name
            ,billing_getnickname(i_from_esn)
            ,i_from_esn
            ,'System'
            ,l_first_name
            ,l_last_name
            ,'System'
            ,'WEBCSR'
            ,pe.pgm_enroll2web_user);
          --
          -- Log for the new esn
          INSERT INTO x_billing_log
            (objid
            ,x_log_category
            ,x_log_title
            ,x_log_date
            ,x_details
            ,x_program_name
            ,x_nickname
            ,x_esn
            ,x_originator
            ,x_contact_first_name
            ,x_contact_last_name
            ,x_agent_name
            ,x_sourcesystem
            ,billing_log2web_user)
          VALUES
            (billing_seq('X_BILLING_LOG')
            ,'Program'
            ,'Upgrade'
            ,SYSDATE
            ,SUBSTR('Upgrading ESN ' || i_from_esn || ' to ' || i_to_esn || ' - ' || each_pgm.x_program_name || ' transferred in successfully',1,1000)
            ,each_pgm.x_program_name
            ,billing_getnickname(i_to_esn)
            ,i_to_esn
            ,'System'
            ,l_first_name
            ,l_last_name
            ,'System'
            ,'WEBCSR'
            ,pe.pgm_enroll2web_user);
          ------------------------------------------------------------------------
          io_subscription_id_tab(each_rec).error_code := 0;
          io_subscription_id_tab(each_rec).error_msg  := io_subscription_id_tab(each_rec).error_msg || each_pgm.x_program_name || ' - TRANSFER SUCCESS ';
          --
        ELSE
          io_subscription_id_tab(each_rec).error_code := 8701;
          -- One or more programs could not be transferred.
          io_subscription_id_tab(each_rec).error_msg := io_subscription_id_tab(each_rec).error_msg || each_pgm.x_program_name || ' - TRANSFER FAILED ';
          --
          -- Update the Enrollment record.
          UPDATE  x_program_enrolled
          SET     x_wait_exp_date = SYSDATE + 10 -- Set wait period for incompatible programs.
          WHERE   objid   = each_pgm.objid;
          --
          -- Insert record into program trans.
          pt.enrollment_status      := pe.enrollment_status;
          pt.enroll_status_reason   := 'ESN upgrade failure -Error code ' || TO_CHAR(l_error_number);
          pt.float_given            := NULL;
          pt.cooling_given          := NULL;
          pt.grace_period_given     := NULL;
          pt.trans_date             := SYSDATE;
          pt.action_text            := 'Upgrading the ESN';
          pt.action_type            := 'TRANSFER';
          pt.reason                 := SUBSTR('Due to upgrade from ESN ' || i_from_esn || ' to ' || i_to_esn || ', upgrade attempt of ' ||
                                              each_pgm.x_program_name || ' failed. Wait period of 10 days applied. ' || TO_CHAR(l_error_number) || ' - ' || l_error_message,1,255);
          pt.sourcesystem           := pe.sourcesystem;
          pt.esn                    := pe.esn;
          pt.exp_date               := pe.exp_date;
          pt.cooling_exp_date       := pe.cooling_exp_date;
          pt.update_status          := 'I';
          pt.update_user            := 'System';
          pt.pgm_tran2pgm_entrolled := pe.program_enrolled_objid;
          pt.pgm_trans2web_user     := pe.pgm_enroll2web_user;
          pt.pgm_trans2site_part    := pe.pgm_enroll2site_part;
          --
          -- insert into x_program_trans
          pt := pt.ins;
          --
          INSERT INTO x_billing_log
            (objid
            ,x_log_category
            ,x_log_title
            ,x_log_date
            ,x_details
            ,x_program_name
            ,x_nickname
            ,x_esn
            ,x_originator
            ,x_contact_first_name
            ,x_contact_last_name
            ,x_agent_name
            ,x_sourcesystem
            ,billing_log2web_user)
          VALUES
            (billing_seq('X_BILLING_LOG')
            ,'Program'
            ,'Upgrade'
            ,SYSDATE
            ,SUBSTR('Due to upgrade from ' || i_from_esn || ' to ' || i_to_esn || ', transfer attempt of ' ||
                    each_pgm.x_program_name || ' failed. Wait period of 10 days applied. ' || TO_CHAR(l_error_number) || ' - ' || l_error_message,1,1000)
             --CR20740 End KACOSTA 05/31/2012
            ,each_pgm.x_program_name
            ,billing_getnickname(i_from_esn)
            ,i_from_esn
            ,'System'
            ,l_first_name
            ,l_last_name
            ,'System'
            ,'WEBCSR'
            ,pe.pgm_enroll2web_user);
        END IF;
        --
        pe  :=  program_enrolled_type ( i_program_enrolled_objid => each_pgm.objid);
        --
        --
        /*
        IF io_subscription_id_tab(each_rec).error_code = 0
        THEN
          -- Success transferring the programs.
          UPDATE x_program_upgrade
          SET   x_status      = 'SUCCESS',
                x_description = 'Successfully transferred programs (VAS) from ' || i_from_esn || ' to ' || i_to_esn
          WHERE objid         = n_pgm_upgrade_Objid;
          --
        ELSE
          -- Failed to transfer the programs.
          UPDATE x_program_upgrade
          SET   x_status      = 'FAILED',
                x_description = 'Failed to transfer the programs(VAS) to new ESN. Error_code=' ||io_subscription_id_tab(each_rec).error_code
                                || ', Error_Message=' ||io_subscription_id_tab(each_rec).error_msg ||'.'
          WHERE objid   = n_pgm_upgrade_Objid;
        END IF;
        */
      ELSE
         io_subscription_id_tab(each_rec).error_code :=  '1105';
         io_subscription_id_tab(each_rec).error_msg  :=  'NOT ELIGIBLE FOR TRANSFER';
      END IF;
    END LOOP;
    --
    IF io_subscription_id_tab(each_rec).error_code IS NULL
    THEN
      io_subscription_id_tab(each_rec).error_code :=  '1106';
      io_subscription_id_tab(each_rec).error_msg  :=  'UNABLE TO GET PROGRAMS FOR THIS ESN AND SUBSCRIPTION ID';
    END IF;
    --
  END LOOP;
  --
  o_error_code  := '0';
  o_error_msg   := 'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  := '99';
    o_error_msg   := 'Failed in when others of vas_management_pkg.p_transfer_vas - ' || SUBSTR(SQLERRM,1,500);
    --
END p_transfer_vas;
--
-- core logic to deenroll vas program from program enrolled table and vas subscriptions table
-- It can be called directly from MANAGE ENROLLMENTS, when customer is requesting to DEENROLL VAS
--
PROCEDURE p_deenroll_vas_program  ( i_esn                     IN    VARCHAR2,
                                    i_program_id              IN    NUMBER,
                                    i_vas_service_id          IN    NUMBER,
                                    i_status                  IN    VARCHAR2,
                                    i_reason                  IN    VARCHAR2,
                                    i_refund_complete_flag    IN    VARCHAR2,
                                    o_error_code              OUT   VARCHAR2,
                                    o_error_msg               OUT   VARCHAR2
                                  )
IS
--
  c                           customer_type :=  customer_type();
  l_program_parameters_rec    x_program_parameters%ROWTYPE;
  vs                          vas_subscriptions_type  :=  vas_subscriptions_type();
  vpt                         vas_programs_type       :=  vas_programs_type();
  pt                          program_trans_type      :=  program_trans_type ();
  pe                          program_enrolled_type   :=  program_enrolled_type ();
--
BEGIN
--
  -- Input validation
  IF i_esn IS NULL
  THEN
    o_error_code  :=  '400';
    o_error_msg   :=  'ESN cannot be null';
    RETURN;
  END IF;
  --
  IF i_program_id IS NULL AND i_vas_service_id IS NULL
  THEN
    o_error_code  :=  '401';
    o_error_msg   :=  'Program ID and Vas service ID cannot be null';
    RETURN;
  END IF;
  --
  IF i_status IS NULL
  THEN
    o_error_code  :=  '402';
    o_error_msg   :=  'Status cannot be null';
    RETURN;
  END IF;
  --
  c     :=  c.get_contact_add_info( i_esn => i_esn);
  --
  -- get vas program details.
  vpt         :=  vas_programs_type (i_vas_service_id => i_vas_service_id );
  --
  IF vpt.response NOT LIKE '%SUCCESS%'
  THEN
    o_error_code      :=  '403';
    o_error_msg       :=  'INVALID VAS SERVICE ID';
    RETURN;
  END IF;
  --
  -- get vas subscription details
  vs          :=  vas_subscriptions_type (  i_esn              => i_esn,
                                            i_vas_service_id   => i_vas_service_id);
  --
  IF vs.response NOT LIKE '%SUCCESS%'
  THEN
    o_error_code      :=  '404';
    o_error_msg       :=  'INVALID VAS SERVICE ID AND ESN';
    RETURN;
  END IF;
  -------- Get the program name for logging ------------
  BEGIN
    SELECT  *
    INTO    l_program_parameters_rec
    FROM    x_program_parameters
    WHERE   objid = vs.program_parameters_objid;
  EXCEPTION
    WHEN OTHERS THEN
      l_program_parameters_rec  :=  NULL;
  END;
  --
  IF i_status IN ('DEENROLL','SUSPEND','DEENROLL_TRANSFER')
  THEN
    -- DEENROLL -- No Grace period, direct cancellation
    -- SUSPEND  -- SUSPEND, Deenroll after grace period as applicable
    UPDATE x_program_enrolled
    SET    x_enrollment_status = CASE WHEN  i_status = 'DEENROLL' AND  NVL(vpt.direct_cancel_flag,'X')  = 'Y'
                                      THEN  'DEENROLLED'
                                      WHEN  i_status = 'DEENROLL' AND  NVL(vpt.direct_cancel_flag,'X')  = 'N' AND i_refund_complete_flag = 'N'
                                      THEN  'DEENROLL_SCHEDULED'
                                      WHEN  i_status = 'DEENROLL' AND  NVL(vpt.direct_cancel_flag,'X')  = 'N' AND i_refund_complete_flag = 'Y'
                                      THEN  'DEENROLLED'
                                      WHEN  i_status = 'DEENROLL_TRANSFER'
                                      THEN  'DEENROLLED'
                                      WHEN  i_status = 'SUSPEND'
                                      THEN  'SUSPENDED'
                                      ELSE  x_enrollment_status
                                END,
           x_update_stamp      = SYSDATE,
           x_reason            = i_reason
    WHERE  objid               = vs.program_enrolled_id
    AND    x_esn               = i_esn
    AND    x_enrollment_status IN  ('ENROLLED','SUSPENDED');
    --
    --
    pe  :=  program_enrolled_type ( i_program_enrolled_objid => vs.program_enrolled_id);
    --
    /*  If the program enrolled update is successful then insert log,
        if already deenrolled, update the vas_subscriptions alone */
    --
    IF SQL%ROWCOUNT > 0
    THEN
      -- Insert a log into the program history
      -- Insert record into program trans.
      pt.enrollment_status      := pe.enrollment_status;
      pt.enroll_status_reason   := pe.enrollment_status||' FROM PROGRAM';
      pt.float_given            := NULL;
      pt.cooling_given          := NULL;
      pt.grace_period_given     := NULL;
      pt.trans_date             := SYSDATE;
      pt.action_text            := pe.enrollment_status;
      pt.action_type            := pe.enrollment_status;
      pt.reason                 := l_program_parameters_rec.x_program_name || '    ' || 'is ' || pe.enrollment_status;
      pt.sourcesystem           := pe.sourcesystem;
      pt.esn                    := pe.esn;
      pt.exp_date               := SYSDATE;
      pt.cooling_exp_date       := SYSDATE;
      pt.update_status          := 'I';
      pt.update_user            := 'System';
      pt.pgm_tran2pgm_entrolled := pe.program_enrolled_objid;
      pt.pgm_trans2web_user     := pe.pgm_enroll2web_user;
      pt.pgm_trans2site_part    := pe.pgm_enroll2site_part;
      --
      -- insert into x_program_trans
      pt := pt.ins;
      --
      ---------------- Insert a billing Log ------------------
      INSERT INTO x_billing_log
        (
        objid,
        x_log_category,
        x_log_title,
        x_log_date,
        x_details,
        x_program_name,
        x_nickname,
        x_esn,
        x_originator,
        x_contact_first_name,
        x_contact_last_name,
        x_agent_name,
        x_sourcesystem,
        billing_log2web_user
        )
      VALUES
        (
        billing_seq ('X_BILLING_LOG'),
        'Program',
        'Program '||pe.enrollment_status,
        SYSDATE,
        l_program_parameters_rec.x_program_name || ' '||pe.enrollment_status ||' due to '|| i_reason,
        l_program_parameters_rec.x_program_name,
        billing_getnickname (i_esn),
        i_esn,
        'System',
        c.contact_first_name,
        c.contact_last_name,
        'System',
        pe.sourcesystem,
        pe.pgm_enroll2web_user
        );
    END IF;
    -- Update vas_subscriptions..
    UPDATE  x_vas_subscriptions
    SET     status          =   CASE  WHEN  i_status = 'DEENROLL' AND  NVL(vpt.direct_cancel_flag,'X')  = 'Y'
                                      THEN  'DEENROLLED'
                                      WHEN  i_status = 'DEENROLL' AND  NVL(vpt.direct_cancel_flag,'X')  = 'N' AND i_refund_complete_flag = 'N'
                                      THEN  'DEENROLL_SCHEDULED'
                                      WHEN  i_status = 'DEENROLL' AND  NVL(vpt.direct_cancel_flag,'X')  = 'N' AND i_refund_complete_flag = 'Y'
                                      THEN  'DEENROLLED'
                                      WHEN  i_status = 'DEENROLL_TRANSFER'
                                      THEN  status
                                      WHEN  i_status = 'SUSPEND'
                                      THEN  'SUSPENDED'
                                      ELSE  status
                                END,
            vas_expiry_date = ( CASE  WHEN  i_status = 'DEENROLL' AND TRUNC(vas_expiry_date) < TRUNC(SYSDATE)
                                      THEN  vas_expiry_date
                                      WHEN  i_status = 'DEENROLL' AND TRUNC(vas_expiry_date) > TRUNC(SYSDATE)
                                      THEN  SYSDATE
                                      WHEN  i_status = 'DEENROLL_TRANSFER'
                                      THEN  vas_expiry_date
                                      WHEN  i_status = 'SUSPEND'
                                      THEN  vas_expiry_date
                                      ELSE  SYSDATE
                                END),
            update_date     = SYSDATE
    WHERE   vas_esn         = i_esn
    AND     vas_id          = i_vas_service_id
    AND     vas_is_active   = 'T'
    AND     status          IN  ('ENROLLED','SUSPENDED');
  --
  END IF;
  --
  o_error_code  :=  '0';
  o_error_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of vas_management_pkg.p_deenroll_vas_program1 - ' || SUBSTR(SQLERRM,1,500);
END p_deenroll_vas_program;
--
--  This procedure is called from service_deactivation_code to sync up the subscription status
--  to align with the base plan service status
PROCEDURE p_deenroll_vas_program (  i_esn                 IN    VARCHAR2,
                                    i_deenroll_reason     IN    VARCHAR2,
                                    o_error_code          OUT   VARCHAR2,
                                    o_error_msg           OUT   VARCHAR2
                                 )
IS
--
  CURSOR  c_program_enrolled
  IS
  SELECT  pe.pgm_enroll2pgm_parameter  program_id,
          vs.vas_id                    vas_service_id
  FROM    x_program_enrolled    pe,
          x_vas_subscriptions   vs,
          vas_programs_view     vpv
  WHERE   1 = 1
  AND     vs.vas_id                   =   vpv.vas_service_id
  AND     pe.x_enrollment_status      IN ('ENROLLED')
  AND     pe.x_esn                    =   vs.vas_esn
  AND     pe.objid                    =   vs.program_enrolled_id
  AND     vs.vas_is_active            =   'T'
  AND     vs.status                   IN ('ENROLLED')
  AND     vs.vas_esn                  =   i_esn;
  --
  cst           customer_type   :=  customer_type();
--
BEGIN
--
  -- Input validation
  IF i_esn  IS NULL
  THEN
    o_error_code  :=  '500';
    o_error_msg   :=  'ESN Cannot be NULL';
    RETURN;
  END IF;
  --
  cst.esn   :=  i_esn;
  cst       :=  cst.get_service_plan_attributes();
  --
  IF UPPER(cst.site_part_status)  <>  'ACTIVE'
  THEN
    FOR each_rec  in c_program_enrolled
    LOOP
      p_deenroll_vas_program  ( i_esn                   =>  i_esn,
                                i_program_id            =>  each_rec.program_id,
                                i_vas_service_id        =>  each_rec.vas_service_id,
                                i_status                =>  'SUSPEND',
                                                           /* ( CASE WHEN i_deenroll_reason  IN  ('PASTDUE')
                                                              THEN 'SUSPEND'
                                                              ELSE 'DEENROLL'
                                                              END),*/
                                i_reason                =>  i_deenroll_reason,
                                i_refund_complete_flag  =>  'N',
                                o_error_code            =>  o_error_code,
                                o_error_msg             =>  o_error_msg
                              );
    END LOOP;
  END IF;
  --
  o_error_code    :=  '0';
  o_error_msg     :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of p_deenroll_vas_program2 - ' || SUBSTR(SQLERRM,1,500);
END p_deenroll_vas_program;
--
-- procedure to deenroll from vas program, when customer switches from Monthly to auto pay and vice versa
--
PROCEDURE p_deenroll_vas_program  ( i_esn                     IN    VARCHAR2,
                                    i_program_id              IN    NUMBER,
                                    i_vas_subscription_id     IN    NUMBER,
                                    i_status                  IN    VARCHAR2,
                                    i_reason                  IN    VARCHAR2,
                                    o_expiry_date             OUT   DATE,
                                    o_contact_objid           OUT   NUMBER,
                                    o_web_user_objid          OUT   NUMBER,
                                    o_program_purch_hdr_objid OUT   NUMBER,
                                    o_payment_source_id       OUT   NUMBER,
                                    o_x_purch_hdr_objid       OUT   NUMBER,
                                    o_error_code              OUT   VARCHAR2,
                                    o_error_msg               OUT   VARCHAR2
                                  )
IS
--
  CURSOR  c_program_enrolled  (c_program_id   IN NUMBER)
  IS
  SELECT  pe.pgm_enroll2pgm_parameter  program_id,
          vs.vas_id                    vas_service_id,
          pe.pgm_enroll2contact,
          pe.pgm_enroll2web_user,
          vs.vas_expiry_date,
          pe.x_next_charge_date,
          pe.x_exp_date,
          pp.x_is_recurring,
          pe.pgm_enroll2x_pymt_src
  FROM    x_program_enrolled    pe,
          x_vas_subscriptions   vs,
          x_program_parameters  pp
  WHERE   1 = 1
  AND     pe.pgm_enroll2pgm_parameter =   c_program_id
  AND     pe.x_enrollment_status      IN ('ENROLLED', 'SUSPENDED')
  AND     pe.x_esn                    =   vs.vas_esn
  AND     pe.objid                    =   vs.program_enrolled_id
  AND     vs.vas_subscription_id      =   i_vas_subscription_id
  AND     vs.vas_is_active            =   'T'
  AND     vs.status                   IN ('ENROLLED', 'SUSPENDED')
  AND     vs.vas_esn                  =   i_esn;
  --
  vs       vas_subscriptions_type;
--
BEGIN
--
  -- Input validation
  IF i_esn IS NULL
  THEN
    o_error_code  :=  '600';
    o_error_msg   :=  'ESN cannot be null';
    RETURN;
  END IF;
  --
  IF i_program_id IS NULL AND i_vas_subscription_id IS NULL
  THEN
    o_error_code  :=  '601';
    o_error_msg   :=  'Program ID and Vas service ID cannot be null';
    RETURN;
  END IF;
  --
  IF i_status IS NULL
  THEN
    o_error_code  :=  '602';
    o_error_msg   :=  'Status cannot be null';
    RETURN;
  END IF;
  --
  FOR each_rec  IN c_program_enrolled  (c_program_id => i_program_id)
  LOOP
    --
    IF  (TRUNC(each_rec.vas_expiry_date) <>  TRUNC(each_rec.x_next_charge_date) AND
        each_rec.x_is_recurring         =  1) OR
        (TRUNC(each_rec.vas_expiry_date) <>  TRUNC(each_rec.x_exp_date) AND
        each_rec.x_is_recurring         =  0)
    THEN
      o_error_code    :=  '603';
      o_error_code    :=  'EXPIRY DATES ARE NOT ALIGNED';
      RETURN;
    END IF;
    --
    vs          :=  vas_subscriptions_type (  i_esn                   => i_esn,
                                              i_vas_subscription_id   => i_vas_subscription_id);
    --
    p_deenroll_vas_program  ( i_esn                   =>  i_esn,
                              i_program_id            =>  each_rec.program_id,
                              i_vas_service_id        =>  each_rec.vas_service_id,
                              i_status                =>  i_status, -- DEENROLL_TRANSFER
                              i_reason                =>  i_reason,
                              i_refund_complete_flag  =>  'N',
                              o_error_code            =>  o_error_code,
                              o_error_msg             =>  o_error_msg
                            );
    --
    IF NVL(o_error_code, 1) <>  '0'
    THEN
       o_error_code    :=  o_error_code;
       o_error_msg     :=  o_error_msg;
       RETURN;
    END IF;
    --
    o_expiry_date               :=  each_rec.vas_expiry_date;
    o_contact_objid             :=  each_rec.pgm_enroll2contact;
    o_web_user_objid            :=  each_rec.pgm_enroll2web_user;
    o_program_purch_hdr_objid   :=  vs.program_purch_hdr_objid;
    o_payment_source_id         :=  each_rec.pgm_enroll2x_pymt_src;
    o_x_purch_hdr_objid         :=  vs.x_purch_hdr_objid;
    --
  END LOOP;
  --
  o_error_code    :=  '0';
  o_error_msg     :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of vas_management_pkg.p_deenroll_vas_program - ' || SUBSTR(SQLERRM,1,500);
END p_deenroll_vas_program;
--
--  This procedure is called from job which updates REFUND details back to case
--  Procedure moves the VAS status from DEENROLL_SCHEDULED to DEENROLLED
--
PROCEDURE p_update_vas_subscription  (  i_vas_subscription_id   IN    NUMBER,
                                        o_error_code            OUT   VARCHAR2,
                                        o_error_msg             OUT   VARCHAR2)
IS
--
  l_program_parameters_rec    x_program_parameters%ROWTYPE;
  vs                          vas_subscriptions_type  :=  vas_subscriptions_type();
  pt                          program_trans_type      :=  program_trans_type ();
  pe                          program_enrolled_type   :=  program_enrolled_type ();
  c                           customer_type           :=  customer_type();
--
BEGIN
--
  -- Input Validation
  IF i_vas_subscription_id IS NULL
  THEN
    o_error_code  := '1200';
    o_error_msg   := 'SUBSCRIPTION ID CANNOT BE NULL';
    RETURN;
  END IF;
  --
  vs  :=  vas_subscriptions_type ( i_vas_subscription_id  =>  i_vas_subscription_id);
  --
  IF vs.response NOT LIKE '%SUCCESS%'
  THEN
    o_error_code      :=  '1201';
    o_error_msg       :=  'INVALID VAS SUBSCRIPTION ID';
    RETURN;
  END IF;
  --
  c     :=  c.get_contact_add_info( i_esn => vs.vas_esn);
  --
  -- Move the status from deenroll scheduled to deenrolled ( final cancellation)
  UPDATE x_program_enrolled
  SET    x_enrollment_status = 'DEENROLLED',
         x_update_stamp      = SYSDATE,
         x_reason            = x_reason
  WHERE  objid               = vs.program_enrolled_id
  AND    x_enrollment_status IN  ('DEENROLL_SCHEDULED');
  --
  -------- Get the program name for logging ------------
  BEGIN
    SELECT  *
    INTO    l_program_parameters_rec
    FROM    x_program_parameters
    WHERE   objid = vs.program_parameters_objid;
  EXCEPTION
    WHEN OTHERS THEN
      l_program_parameters_rec  :=  NULL;
  END;
  --
  pe  :=  program_enrolled_type ( i_program_enrolled_objid => vs.program_enrolled_id);
  --
  /*  If the program enrolled update is successful then insert log,
      if already deenrolled, update the vas_subscriptions alone */
  --
  IF SQL%ROWCOUNT > 0
  THEN
    -- Insert a log into the program history
    -- Insert record into program trans.
    pt.enrollment_status      := pe.enrollment_status;
    pt.enroll_status_reason   := pe.enrollment_status||' FROM PROGRAM';
    pt.float_given            := NULL;
    pt.cooling_given          := NULL;
    pt.grace_period_given     := NULL;
    pt.trans_date             := SYSDATE;
    pt.action_text            := pe.enrollment_status;
    pt.action_type            := pe.enrollment_status;
    pt.reason                 := l_program_parameters_rec.x_program_name || '    ' || 'is ' || pe.enrollment_status;
    pt.sourcesystem           := pe.sourcesystem;
    pt.esn                    := pe.esn;
    pt.exp_date               := SYSDATE;
    pt.cooling_exp_date       := SYSDATE;
    pt.update_status          := 'I';
    pt.update_user            := 'System';
    pt.pgm_tran2pgm_entrolled := pe.program_enrolled_objid;
    pt.pgm_trans2web_user     := pe.pgm_enroll2web_user;
    pt.pgm_trans2site_part    := pe.pgm_enroll2site_part;
    --
    -- insert into x_program_trans
    pt := pt.ins;
    --
    ---------------- Insert a billing Log ------------------
    INSERT INTO x_billing_log
      (
      objid,
      x_log_category,
      x_log_title,
      x_log_date,
      x_details,
      x_program_name,
      x_nickname,
      x_esn,
      x_originator,
      x_contact_first_name,
      x_contact_last_name,
      x_agent_name,
      x_sourcesystem,
      billing_log2web_user
      )
    VALUES
      (
      billing_seq ('X_BILLING_LOG'),
      'Program',
      'Program '||pe.enrollment_status,
      SYSDATE,
      l_program_parameters_rec.x_program_name || ' '||pe.enrollment_status ||' after sending REFUND CHECK ',
      l_program_parameters_rec.x_program_name,
      billing_getnickname (vs.vas_esn),
      vs.vas_esn,
      'System',
      c.contact_first_name,
      c.contact_last_name,
      'System',
      pe.sourcesystem,
      pe.pgm_enroll2web_user
      );
  END IF;
  -- Update vas_subscriptions..
  UPDATE  x_vas_subscriptions
  SET     status          =   'DEENROLLED',
          update_date     =   SYSDATE
  WHERE   vas_subscription_id   =  vs.vas_subscription_id
  AND     vas_is_active         = 'T'
  AND     status                IN  ('DEENROLL_SCHEDULED');
  --
  COMMIT;
  --
  o_error_code  :=  '0';
  o_error_msg   :=  'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  := SQLCODE;
    o_error_msg := 'FAILED in vas_management_pkg.p_update_vas_subscription 1 - ' || SUBSTR(sqlerrm,1,500);
END p_update_vas_subscription;
--
-- procedure called from job to update suspend status to Deenrolled, after the grace period
PROCEDURE p_vas_final_cancellation  ( i_run_date    IN  DATE DEFAULT SYSDATE,
                                      o_error_code  OUT VARCHAR2,
                                      o_error_msg   OUT VARCHAR2)
IS
--
  CURSOR  c_get_vas
  IS
  SELECT  vs.rowid vas_rowid, vs.*
  FROM    x_vas_subscriptions vs,
          vas_programs_view   vpv
  WHERE   vs.vas_id                 =  vpv.vas_service_id
  AND     vs.vas_expiry_date  IS NOT NULL
  AND     vs.status                 =   'SUSPENDED'
  AND     vs.vas_is_active          =   'T'
  AND     TRUNC(vs.vas_expiry_date) <   TRUNC(i_run_date)
  AND     NVL(vpv.grace_period, 0)  >=  (TRUNC(i_run_date) - TRUNC(vs.vas_expiry_date))
  UNION  -- ATTENtion check again
  SELECT  vs.rowid vas_rowid, vs.*
  FROM    x_vas_subscriptions vs,
          vas_programs_view   vpv
  WHERE   vs.vas_id                 =  vpv.vas_service_id
  AND     vs.vas_expiry_date  IS NOT NULL
  AND     vs.status                 =   'ENROLLED'
  AND     vs.vas_is_active          =   'T'
  AND     TRUNC(vs.vas_expiry_date) <   TRUNC(i_run_date)
  AND     NVL(vpv.grace_period, 0)  =   0
  AND     NVL(vpv.vas_category, 'X')  =  'DEVICE WARRANTY';
  --
  jt      job_type        :=  job_type();
  et      error_log_type  :=  error_log_type();
--
BEGIN
--
  jt.job_run_objid   :=  jt.create_job_instance(  i_job_name           => 'VAS_FINAL_CANCELLATION',
                                                  i_status             => 'RUNNING',
                                                  i_job_run_mode       => '0',
                                                  i_seq_name           => 'X_JOB_RUN_DETAILS',
                                                  i_owner_name         => 'BATCH_PROC',
                                                  i_reason             => 'Autosys',
                                                  i_status_code        => NULL,
                                                  i_sub_sourcesystem   => 'VAS' );
  --
  FOR each_rec IN c_get_vas
  LOOP
    UPDATE  x_vas_subscriptions
    SET     status      = 'DEENROLLED',
            update_date = SYSDATE,
            addl_info   = 'SUBSCRIPTION DEENROLLED : OLD STATUS : '||each_rec.status
    WHERE   rowid = each_rec.vas_rowid;
    --
    COMMIT;
  END LOOP;
  --
  jt.response        :=  jt.update_job_instance( i_job_run_objid    =>  jt.job_run_objid ,
                                                 i_owner_name       => 'BATCH_PROC',
                                                 i_reason           => 'Autosys',
                                                 i_status           => 'SUCCESS',
                                                 i_status_code      => '0',
                                                 i_sub_sourcesystem => 'VAS' );
 --
 o_error_code   :=  '0';
 o_error_msg    :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  := SQLCODE;
    o_error_msg := 'FAILED in vas_management_pkg.p_vas_final_cancellation - ' || SUBSTR(sqlerrm,1,500);
    et.response     :=  et.ins_job_err (  i_job_id          =>  jt.job_run_objid,
                                          i_request_type    =>  'VAS_FINAL_CANCELLATION',
                                          i_request         =>  'sqlcode: '||o_error_code,
                                          i_error_msg       =>  o_error_msg,
                                          i_ordinal         =>  0,
                                          i_status_code     =>  -200,
                                          i_reject          =>  0,
                                          i_resent          =>  0 );
    --
    jt.response        :=  jt.update_job_instance( i_job_run_objid    =>  jt.job_run_objid ,
                                                   i_owner_name       => 'BATCH_PROC',
                                                   i_reason           => 'Autosys',
                                                   i_status           => 'FAILED',
                                                   i_status_code      => '0',
                                                   i_sub_sourcesystem => 'VAS' );
--
END p_vas_final_cancellation;
--
-- CR49058 changes ends.
--
END VAS_MANAGEMENT_PKG;
/