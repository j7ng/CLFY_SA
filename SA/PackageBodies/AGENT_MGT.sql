CREATE OR REPLACE PACKAGE BODY sa.AGENT_MGT AS
--------------------------------------------------------------------------------------------
--$RCSfile: AGENT_MGT_PKB.sql,v $
--$Revision: 1.34 $
--$Author: jarza $
--$Date: 2015/02/17 22:29:13 $
--$ $Log: AGENT_MGT_PKB.sql,v $
--$ Revision 1.34  2015/02/17 22:29:13  jarza
--$ CR32464 :
--$
--$ Added 3 new procedures
--$ 1.	SP_INSERT_USER_BRAND_ENABLE
--$ 2.	SP_UPDATE_USER_BRAND_ENABLE
--$ 3.	SP_MODIFY_BRAND_VISIBLE_2_USER
--$ Added one new parameter (op_typ_varchar2_array) to procedure: authenticate_agent
--$
--$ Revision 1.33  2014/09/29 16:46:58  rramachandran
--$ CR28333 - Dealer Transaction Code - Universal Dealer Portal (FastAct) and Master Agent API
--$
--$ Revision 1.32  2014/09/29 16:32:37  rramachandran
--$ CR28333 - Dealer Transaction Code - Universal Dealer Portal (FastAct) and Master Agent API
--$
--$ Revision 1.31  2014/09/29 16:19:34  rramachandran
--$ CR28333 - Dealer Transaction Code - Universal Dealer Portal (FastAct) and Master Agent API
--$
--$ Revision 1.30  2014/09/29 15:43:37  rramachandran
--$ CR28333 - Dealer Transaction Code - Universal Dealer Portal (FastAct) and Master Agent API
--$
--$ Revision 1.29  2014/09/29 15:03:13  rramachandran
--$ CR28333 - Dealer Transaction Code - Universal Dealer Portal (FastAct) and Master Agent API
--$
--$ Revision 1.28  2014/09/29 14:49:36  rramachandran
--$ CR28333 - Dealer Transaction Code - Universal Dealer Portal (FastAct) and Master Agent API
--$
--$ Revision 1.27  2014/09/29 14:08:14  rramachandran
--$ CR28333 - Dealer Transaction Code - Universal Dealer Portal (FastAct) and Master Agent API
--$
--$ Revision 1.26  2014/09/24 20:22:37  rramachandran
--$ CR28333 - Dealer Transaction Code - Universal Dealer Portal (FastAct) and Master Agent API
--$
--$ Revision 1.25  2014/09/24 20:06:00  rramachandran
--$ CR28333 - Dealer Transaction Code - Universal Dealer Portal (FastAct) and Master Agent API
--$
--$ Revision 1.24  2014/09/24 18:53:31  rramachandran
--$ CR28333 - Dealer Transaction Code - Universal Dealer Portal (FastAct) and Master Agent API
--$
--$ Revision 1.23  2014/09/22 14:50:42  rramachandran
--$ CR28333 - Dealer Transaction Code - Universal Dealer Portal (FastAct) and Master Agent API
--$
--$ Revision 1.22  2014/09/21 14:30:18  rramachandran
--$ CR28333 - Dealer Transaction Code - Universal Dealer Portal (FastAct) and Master Agent API
--$
--$ Revision 1.21  2014/09/19 17:15:59  rramachandran
--$ CR28333 - Dealer Transaction Code - Universal Dealer Portal (FastAct) and Master Agent API
--$
--$ Revision 1.20  2014/09/19 14:43:53  rramachandran
--$ CR28333 - Dealer Transaction Code - Universal Dealer Portal (FastAct) and Master Agent API
--$
--$ Revision 1.19  2014/07/17 13:27:05  rramachandran
--$ CR29250 - FastAct Retail - Retailer Flag
--$
--$ Revision 1.18  2014/07/16 21:21:10  rramachandran
--$ CR29250 - FastAct Retail - Retailer Flag
--$
--$ Revision 1.17  2014/07/01 19:14:41  rramachandran
--$ CR29250 - FastAct Retail - Retailer Flag
--$
--$ Revision 1.16  2014/03/20 21:32:01  akhan
--$ removed the status and dev update on pwd reset
--$
--$ Revision 1.15  2014/02/11 17:15:14  akhan
--$ commented out code ot auto lock users
--$
--$ Revision 1.14  2014/02/11 17:09:40  akhan
--$ Modified authentication to enable locking of the users
--$
--$ Revision 1.13  2013/09/06 20:39:12  akhan
--$ added code for passing back spiff details
--$
--$ Revision 1.12  2013/08/26 15:51:29  akhan
--$ added routines for returning spiff info and validate the spiff for password reset
--$
--$ Revision 1.11  2013/07/10 15:38:24  clinder
--$ EME24842
--$
--$ Revision 1.10  2013/07/10 15:31:44  clinder
--$ EME 24842
--$
--$ Revision 1.9  2013/04/29 15:28:53  akhan
--$ latest
--$
--$ Revision 1.8  2013/04/22 23:02:33  akhan
--$ fixed problem with update of call trans rec
--$
--$ Revision 1.7  2013/04/22 14:52:46  akhan
--$ added commits
--$
--$ Revision 1.6  2013/04/20 20:29:50  akhan
--$ resolved defect with inititate_password_reset
--$
--$ Revision 1.5  2013/04/19 13:53:36  akhan
--$ Update hash value on subsequent call to initiate password reset
--$
--$
--------------------------------------------------------------------------------------------


PROCEDURE change_password
          (ip_login_id IN VARCHAR2,
           ip_password IN VARCHAR2,
           op_is_successful OUT NUMBER) AS
          /* Return 0=success 1=failure */

 pragma autonomous_transaction;
updated_rows NUMBER;

BEGIN

  op_is_successful:=0;
  UPDATE TABLE_USER
  SET WEB_PASSWORD = encryptPassword(ip_password),
      WEB_PASSWD_CHG=trunc(SYSDATE),
      web_last_login =sysdate-1/24,
      SUBMITTER_IND=0
  WHERE S_LOGIN_NAME = upper(ip_login_id);


  IF sql%rowcount > 0 THEN
    op_is_successful := 0;
  ELSE
    op_is_successful := 1;
  END IF;
  commit;

EXCEPTION
  WHEN OTHERS THEN
  op_is_successful:=1;

END change_password;

PROCEDURE authenticate_agent
            (ip_login_id IN VARCHAR2,
             ip_password IN VARCHAR2,
             op_role OUT VARCHAR2,
             op_spiff_code out varchar2,
             op_spiff_date out date,
             op_epay_id  out varchar2,
             op_epay_status out varchar2,
             op_epay_last_update_date out date,
             op_is_spiff_flag out integer, --CR28333 RRS 09/19/2014
             op_is_retailer_flag out varchar2,
             op_typ_varchar2_array  out   sa.TYP_VARCHAR2_ARRAY) as      --CR29250 RRS 07/01/2014
 pragma autonomous_transaction;
 found number := 0;
 v_last_login  date;
 v_start_date date;
 v_invalid_attempts number := 0;
BEGIN
    select role,
           signup_confirm_code,
           terms_accept_date,
           provider_id,
           prov_cust_status,
           prov_cust_last_update,
           web_last_login,
           x_start_date,
           spiff_ma_flag, --CR28333 RRS 09/19/2014
           decode(s.name,'Topp Telecom','DEALER','MASTER DEALER') IS_RETAILER --CR29250 RRS 07/01/2014
    into op_role,
         op_spiff_code,
         op_spiff_date,
         op_epay_id,
         op_epay_status,
         op_epay_last_update_date,
         v_last_login,
         v_start_date,
         op_is_spiff_flag, --CR28333 RRS 09/19/2014
         op_is_retailer_flag
    from table_user u,
         table_employee e,
         x_dealer_commissions c,
         table_site s
    where s_login_name = upper(ip_login_id)
    and u.objid = e.employee2user
    and c.dealer_comms2employee = e.objid
    and e.supp_person_off2site = s.objid
    and web_password = encryptpassword(ip_password)
    and u.status = 1
    and u.dev = 1
    and sysdate between nvl(u.x_start_date,sysdate-1) and nvl(u.x_end_date,sysdate+1)
    and agent_id = 'SMOB';

    --Start of CR32464
    --DBMS_OUTPUT.PUT_LINE('Start of user brand relation');
    op_typ_varchar2_array := sa.typ_varchar2_array();

    BEGIN
      SELECT bo.s_org_id bulk collect
      INTO op_typ_varchar2_array
      FROM sa.table_user u ,
        sa.x_udp_user_brand_enable ub ,
        sa.table_bus_org bo
      WHERE u.s_login_name = upper(ip_login_id)
      AND ub.x_user_objid  = u.objid
      AND x_flag_enable    = 'Y'
      AND BO.OBJID         = UB.X_BUS_ORG_OBJID;
    EXCEPTION
      WHEN no_data_found THEN
        op_typ_varchar2_array := sa.typ_varchar2_array();
        --DBMS_OUTPUT.PUT_LINE('Step 1 - user brand relation - no data error');
    END;
    --DBMS_OUTPUT.PUT_LINE('Step 2 - user brand relation');
    IF op_typ_varchar2_array.COUNT = 0 THEN
      --DBMS_OUTPUT.PUT_LINE('Sending default values');
      op_typ_varchar2_array := sa.typ_varchar2_array();
      op_typ_varchar2_array.extend(5);
      op_typ_varchar2_array(1) := 'TRACFONE';
      op_typ_varchar2_array(2) := 'SIMPLE_MOBILE';
      op_typ_varchar2_array(3) := 'NET10';
      op_typ_varchar2_array(4) := 'TELCEL';
      op_typ_varchar2_array(5) := 'PAGEPLUS';
    END IF;
    --DBMS_OUTPUT.PUT_LINE('End of user brand relation');
    --End of CR32464

    update table_user
    set web_last_login = sysdate,
        SUBMITTER_IND  = 0
    where s_login_name = upper(ip_login_id);

    commit;

EXCEPTION
  WHEN OTHERS THEN
    update table_user
    set submitter_ind = submitter_ind+1
    where s_login_name = upper(ip_login_id)
    returning submitter_ind into v_invalid_attempts;

--    to be implemented later after frontend change to give out a proper message
--    if (v_invalid_attempts > 4 ) then
--        update table_user
--        set dev = 0
--        where s_login_name = upper(ip_login_id);
--    end if;
    commit;
    op_role:=null;
    op_is_retailer_flag:=null;     --CR29250 RRS 07/01/2014
END authenticate_agent;




PROCEDURE authenticate_agent
            (ip_login_id IN VARCHAR2,
             ip_password IN VARCHAR2,
             op_role OUT VARCHAR2) AS
    /* Return null=invalid user role_id=success */
 pragma autonomous_transaction;
 found number := 0;
 v_last_login  date;
 v_start_date date;
 v_invalid_attempts number := 0;
BEGIN
    select role,
           web_last_login,
           x_start_date
    into op_role,
         v_last_login,
         v_start_date
    from table_user u,
         table_employee e,
         x_dealer_commissions c
    where s_login_name = upper(ip_login_id)
    and u.objid = e.employee2user
    and c.dealer_comms2employee = e.objid
    and web_password = encryptpassword(ip_password)
    and status = 1
    and u.dev = 1
    and sysdate between nvl(x_start_date,sysdate-1) and nvl(x_end_date,sysdate+1)
    and agent_id = 'SMOB';


    update table_user
    set web_last_login = sysdate,
        submitter_ind  = 0
    where s_login_name = upper(ip_login_id);


    commit;

EXCEPTION
  WHEN OTHERS THEN
    update table_user
    set submitter_ind = submitter_ind+1
    where s_login_name = upper(ip_login_id)
    returning submitter_ind into v_invalid_attempts;

--    to be implemented later after frontend change to give out a proper message
--    if (v_invalid_attempts > 4 ) then
--        update table_user
--        set dev = 0
--        where s_login_name = upper(ip_login_id);
--    end if;
    commit;
    op_role:=null;
END authenticate_agent;

PROCEDURE get_spiff_details
           (ip_login_id IN VARCHAR2,
             op_spiff_code out varchar2,
             op_spiff_date out date,
             op_epay_id  out varchar2,
             op_epay_status out varchar2,
             op_epay_last_update_date out date) as
 pragma autonomous_transaction;

begin
    select signup_confirm_code,
           terms_accept_date,
           provider_id,
           prov_cust_status,
           prov_cust_last_update
    into op_spiff_code,
         op_spiff_date,
         op_epay_id,
         op_epay_status,
         op_epay_last_update_date
    from table_user u,
         table_employee e,
         x_dealer_commissions c
    where s_login_name = upper(ip_login_id)
    and u.objid = e.employee2user
    and c.dealer_comms2employee = e.objid
    and agent_id = 'SMOB';


EXCEPTION
  WHEN OTHERS THEN
   null;
end;

procedure validate_password_reset
          (ip_login_id   in varchar2,
           ip_spiff_info in varchar2,
           ip_epay_id    in varchar2,
           op_is_successful out number ) as
  /* Return 0=success 1=failed */

  found number:= 0;
  pragma autonomous_transaction;
BEGIN

   op_is_successful := 1;  -- FAIL
   if (ip_spiff_info is null and ip_epay_id is null) then
       return;
   end if;

    select count(*)
    into found
    from table_user u,
         table_employee e,
         x_dealer_commissions c
    where s_login_name = upper(ip_login_id)
    and u.objid = e.employee2user
    and c.dealer_comms2employee = e.objid
    and c.signup_confirm_code = nvl(ip_spiff_info,c.signup_confirm_code)
    and c.provider_id   = nvl(ip_epay_id,c.provider_id)
    and agent_id = 'SMOB';

if found > 0 then
   op_is_successful := 0;
end if;


EXCEPTION
  WHEN OTHERS THEN
    op_is_successful := 1;
END;
PROCEDURE initiate_password_reset
           (ip_login_id IN VARCHAR2,
            ip_hash IN VARCHAR2,
            op_is_successful OUT NUMBER) AS
  /* Return 0=success 1=failed */

  found number:= 0;
  pragma autonomous_transaction;
BEGIN
    op_is_successful := 1;

    select count(*)
    into found
    from table_user
    where s_login_name = upper(ip_login_id)
    and agent_id = 'SMOB';

    if found > 0 then

      MERGE INTO UDP_PASSWORD_RESET
      using (select 1 from dual)
      on (s_login_name = upper(ip_login_id))
      when matched then
         UPDATE set generated_hash = ip_hash,
              generation_time = sysdate
      when not matched then
        INSERT(OBJID,
               S_LOGIN_NAME,
               GENERATION_TIME,
               GENERATED_HASH)
        VALUES(UDP_PASSWORD_RESET_SEQ.NEXTVAL,
               upper(ip_login_id),
               SYSDATE,
               ip_hash);

      commit;
      op_is_successful := 0;
    end if;

EXCEPTION
  WHEN OTHERS THEN
    op_is_successful := 1;
END initiate_password_reset;

PROCEDURE confirm_password_reset
          (ip_secret_code IN VARCHAR2,
           ip_login_id IN OUT VARCHAR2,
           op_is_valid OUT NUMBER) AS
/* Return 0=success 1=failed */
temp_login_id table_user.s_login_name%TYPE;
BEGIN
    op_is_valid := 1;

    select s_login_name
    into temp_login_id
    from udp_password_reset
    where generated_hash = ip_secret_code
    and s_login_name = upper(ip_login_id);


    op_is_valid := 0;
    ip_login_id := temp_login_id;

EXCEPTION
  WHEN OTHERS THEN
    op_is_valid := 1;
    ip_login_id := null;

END confirm_password_reset;
PROCEDURE update_call_trans(ip_call_trans_objid in number,
                            ip_login_name in varchar2 ,
                            op_error_code out number,
                            op_error_msg out varchar2) IS
 pragma autonomous_transaction;
 v_user_objid number;

BEGIN
  begin
    select u.objid
    into v_user_objid
    from table_user u
    where u.s_login_name = upper(ip_login_name);
  exception
    when no_data_found then
      op_error_code := 99;
      op_error_msg := 'User does not exist';
      return;
    when others then
      op_error_code := 99;
      op_error_msg := 'Selecting user -'||sqlerrm;
      return;
  end;
  update sa.table_x_call_trans ct
   set ct.x_call_trans2user = v_user_objid,
       ct.X_NEW_DUE_DATE = (select sp.X_EXPIRE_DT
                              from table_site_part sp
			     where sp.objid = ct.CALL_TRANS2SITE_PART) --EME 24842
  where ct.objid = ip_call_trans_objid;


  if sql%rowcount > 0 then
     op_error_code    := 0;
     op_error_msg := null;
  else
     op_error_code    := 99;
     op_error_msg := 'Problem locating Call Trans';
  end if;
  commit;

EXCEPTION
 when others then
   op_error_code := 99;
   op_error_msg  := SQLERRM;
END update_call_trans;
PROCEDURE DEALER_TRANSACTION_CODE_VALID
(IN_SPIFF_CODE VARCHAR2, V_STATUS OUT INTEGER, V_STATUS_MSG OUT VARCHAR2, V_DEALER_OBJID OUT INTEGER)
IS
 /* VALIDATE DEALER TRANSACTION CODE AS TO WHETHER IT IS VALID, FOR A DEALER IS ACTIVE */
 V_COUNT INTEGER;
 V_SPIFF_COUNT INTEGER;
 V_ROLE_VALID INTEGER;
 V_SPIFF_ACTIVE INTEGER;
 V_ROLE_MASTER_AGENT INTEGER;
 V_ERROR_FOUND BOOLEAN := TRUE;
BEGIN

 SELECT COUNT(*) INTO V_COUNT FROM SMOB_USERS_V WHERE SPIFF_CONFIRM_CODE = IN_SPIFF_CODE AND ROLE = 'DEALER' AND STATUS = 'ACTIVE';

 IF V_COUNT <> 0 THEN
    V_STATUS := 0;
    V_STATUS_MSG := 'SUCCESS';
    V_ERROR_FOUND := FALSE;
    SELECT OBJID INTO V_DEALER_OBJID FROM X_DEALER_COMMISSIONS WHERE SIGNUP_CONFIRM_CODE = IN_SPIFF_CODE AND ROLE = 'DEALER';
 END IF;

 IF V_ERROR_FOUND THEN
 SELECT COUNT(*) INTO V_SPIFF_COUNT FROM SMOB_USERS_V WHERE SPIFF_CONFIRM_CODE = IN_SPIFF_CODE;

 IF V_SPIFF_COUNT = 0 THEN
    V_STATUS := -1;
    V_STATUS_MSG := 'DEALER TRANSACTION CODE INVALID';
    V_ERROR_FOUND := TRUE;
 ELSE
    V_ERROR_FOUND := FALSE;
 END IF;

 SELECT COUNT(*) INTO V_ROLE_VALID FROM SMOB_USERS_V WHERE SPIFF_CONFIRM_CODE = IN_SPIFF_CODE AND ROLE = 'DEALER';

 IF NOT(V_ERROR_FOUND) THEN
 IF V_ROLE_VALID = 0 THEN
    V_STATUS := -2;
    V_STATUS_MSG := 'ROLE NOT DEALER';
    V_ERROR_FOUND := TRUE;
 ELSE
    V_ERROR_FOUND := FALSE;
 END IF;
 END IF;

 SELECT COUNT(*) INTO V_SPIFF_ACTIVE FROM SMOB_USERS_V WHERE SPIFF_CONFIRM_CODE = IN_SPIFF_CODE AND ROLE = 'DEALER' AND STATUS = 'ACTIVE';

 IF NOT(V_ERROR_FOUND) THEN
 IF V_SPIFF_ACTIVE = 0 THEN
    V_STATUS := -3;
    V_STATUS_MSG := 'DEALER FOR TRANSACTION CODE INACTIVE';
    V_ERROR_FOUND := TRUE;
 ELSE
    V_ERROR_FOUND := FALSE;
 END IF;
 END IF;

 SELECT COUNT(*) INTO V_ROLE_MASTER_AGENT FROM SMOB_USERS_V WHERE SPIFF_CONFIRM_CODE = IN_SPIFF_CODE AND ROLE = 'MASTER_AGENT';

 IF NOT(V_ERROR_FOUND) THEN
 IF V_ROLE_MASTER_AGENT = 0 THEN
    V_STATUS := -4;
    V_STATUS_MSG := 'ROLE NOT MASTER AGENT';
 END IF;
 END IF;

 END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('NOT A VALID DEALER');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERRORS');
END;
/***************************************************************************************************************
 Program Name			   :  	SP_INSERT_USER_BRAND_ENABLE
 Program Type      	 :  	Stored procedure
 Program Arguments 	 :  	IP_USER_OBJID - User Objid of table_user
                          ,IP_BUS_ORG_OBJID - Organization Objid of table_bus_org
                          ,IP_FLAG_ENABLE - Enable flag. With valid values are Y or N
                          ,IP_IDN_USER_CREATED - User who created this record
 Returns             :   	OP_OBJID - Objid of record inserted
                          , OP_ERR_NUM - Error number
                          , OP_ERR_STRING - Error message
 Program Called     	:  	None
 Description        		:  		This procedure inserts records into SA.X_UDP_USER_BRAND_ENABLE table
 Modified By	          Modification Date    		CR Number             Description
 =============          =================     =============         ============================
  Jai Arza		   		      02/17/2015						CR32464	                Initial Creation
***************************************************************************************************************/
  PROCEDURE SP_INSERT_USER_BRAND_ENABLE
    (
      IP_USER_OBJID                   IN    sa.X_UDP_USER_BRAND_ENABLE.X_USER_OBJID%TYPE
      , IP_BUS_ORG_OBJID              IN    sa.X_UDP_USER_BRAND_ENABLE.X_BUS_ORG_OBJID%TYPE
      , IP_FLAG_ENABLE                IN    sa.X_UDP_USER_BRAND_ENABLE.X_FLAG_ENABLE%TYPE
      , IP_IDN_USER_CREATED           IN    sa.X_UDP_USER_BRAND_ENABLE.X_IDN_USER_CREATED%TYPE
      , OP_OBJID                      OUT   sa.X_UDP_USER_BRAND_ENABLE.OBJID%TYPE
      , OP_STATUS_NUM                 OUT NUMBER
      , OP_STATUS_MESSAGE             OUT VARCHAR2
    ) IS
    LV_OBJID                          sa.X_UDP_USER_BRAND_ENABLE.OBJID%TYPE;
  BEGIN
    LV_OBJID := sa.SEQU_X_UDP_USER_BRAND_ENABLE.NEXTVAL;
    INSERT INTO sa.X_UDP_USER_BRAND_ENABLE
      (
        OBJID
      , X_USER_OBJID
      , X_BUS_ORG_OBJID
      , X_FLAG_ENABLE
      , X_IDN_USER_CREATED
      , X_DTE_CREATED
      , X_IDN_USER_CHANGE_LAST
      , X_DTE_CHANGE_LAST
      )
    VALUES
      (
      	LV_OBJID                 --OBJID
      ,	IP_USER_OBJID			      --X_USER_OBJID
      ,	IP_BUS_ORG_OBJID			  --X_BUS_ORG_OBJID
      ,	UPPER(IP_FLAG_ENABLE)			    --X_FLAG_ENABLE
      ,	IP_IDN_USER_CREATED			--X_IDN_USER_CREATED
      , SYSDATE				          --X_DTE_CREATED
      ,	IP_IDN_USER_CREATED			--X_IDN_USER_CHANGE_LAST
      , SYSDATE				          --X_DTE_CHANGE_LAST
      )
      ;
    OP_OBJID := LV_OBJID;
    OP_STATUS_NUM := '0';
    OP_STATUS_MESSAGE := 'Success';
  EXCEPTION
    WHEN OTHERS THEN
      OP_STATUS_NUM := '1';
      OP_STATUS_MESSAGE := 'Failure';
      ROLLBACK;
      RAISE;
  END SP_INSERT_USER_BRAND_ENABLE;
/***************************************************************************************************************
 Program Name			   :  	SP_UPDATE_USER_BRAND_ENABLE
 Program Type      	 :  	Stored procedure
 Program Arguments 	 :  	IP_USER_OBJID - User Objid of table_user
                          ,IP_BUS_ORG_OBJID - Organization Objid of table_bus_org
                          ,IP_FLAG_ENABLE - Enable flag. With valid values are Y or N
                          ,IP_IDN_USER_CREATED - User who created this record
 Returns             :   	OP_OBJID - Objid of record updated
                          , OP_ERR_NUM - Error number
                          , OP_ERR_STRING - Error message
 Program Called     	:  	None
 Description        		:  		This procedure Updates records into SA.X_UDP_USER_BRAND_ENABLE table
 Modified By	          Modification Date    		CR Number             Description
 =============          =================     =============         ============================
  Jai Arza		   		      02/17/2015						CR32464	                Initial Creation
***************************************************************************************************************/
  PROCEDURE SP_UPDATE_USER_BRAND_ENABLE
    ( IP_OBJID                      IN    sa.X_UDP_USER_BRAND_ENABLE.OBJID%TYPE
      , IP_USER_OBJID               IN    sa.X_UDP_USER_BRAND_ENABLE.X_USER_OBJID%TYPE
      , IP_BUS_ORG_OBJID            IN    sa.X_UDP_USER_BRAND_ENABLE.X_BUS_ORG_OBJID%TYPE
      , IP_FLAG_ENABLE              IN    sa.X_UDP_USER_BRAND_ENABLE.X_FLAG_ENABLE%TYPE
      , IP_IDN_USER_CHANGE_LAST     IN    sa.X_UDP_USER_BRAND_ENABLE.X_IDN_USER_CHANGE_LAST%TYPE
      , OP_STATUS_NUM               OUT   NUMBER
      , OP_STATUS_MESSAGE           OUT   VARCHAR2
    )
    IS
    LV_OBJID                        sa.X_UDP_USER_BRAND_ENABLE.OBJID%TYPE;
    LV_COUNT                        PLS_INTEGER := 0;
  BEGIN
    UPDATE sa.X_UDP_USER_BRAND_ENABLE
    SET  X_FLAG_ENABLE = UPPER(IP_FLAG_ENABLE)
        , X_IDN_USER_CHANGE_LAST = IP_IDN_USER_CHANGE_LAST
        , X_DTE_CHANGE_LAST = SYSDATE
    WHERE OBJID =IP_OBJID
    ;
    LV_COUNT := SQL%ROWCOUNT;
    IF LV_COUNT > 0 THEN
      OP_STATUS_NUM := '0';
      OP_STATUS_MESSAGE := 'Success';
    ELSE
      OP_STATUS_NUM := '1';
      OP_STATUS_MESSAGE := 'Failure. Did not update records. Please check';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      OP_STATUS_NUM := '1';
      OP_STATUS_MESSAGE := 'Failure';
      ROLLBACK;
      RAISE;
  END SP_UPDATE_USER_BRAND_ENABLE;
/***************************************************************************************************************
 Program Name			   :  	SP_ADD_BRANDS_VISIBLE_TO_USER
 Program Type      	 :  	Stored procedure
 Program Arguments 	 :  	IP_USER_OBJID - User Objid of table_user
                          ,IP_BUS_ORG_OBJID - Organization Objid of table_bus_org
                          ,IP_FLAG_ENABLE - Enable flag. With valid values are Y or N
                          ,IP_IDN_USER_CREATED - User who created this record
 Returns            		:   	OP_OBJID - Objid of record inserted
 Program Called     	:  	None
 Description        		:  		This procedure will modify records into SA.X_UDP_USER_BRAND_ENABLE table
 Modified By	          Modification Date    		CR Number             Description
 =============          =================     =============         ============================
  Jai Arza		   		      02/17/2015						CR32464	                Initial Creation
***************************************************************************************************************/
  PROCEDURE SP_MODIFY_BRAND_VISIBLE_2_USER
    (
      IP_S_LOGIN_NAME               IN    sa.TABLE_USER.S_LOGIN_NAME%TYPE
      , IP_S_ORG_ID                 IN    sa.TABLE_BUS_ORG.S_ORG_ID%TYPE
      , IP_FLAG_ENABLE              IN    sa.X_UDP_USER_BRAND_ENABLE.X_FLAG_ENABLE%TYPE
      , IP_IDN_USER_CHANGE_LAST     IN    sa.X_UDP_USER_BRAND_ENABLE.X_IDN_USER_CHANGE_LAST%TYPE
      , OP_OBJID                    OUT   sa.X_UDP_USER_BRAND_ENABLE.OBJID%TYPE
      , OP_STATUS_NUM               OUT NUMBER
      , OP_STATUS_MESSAGE           OUT VARCHAR2
    )
    IS
    LV_USER_OBJID                   sa.X_UDP_USER_BRAND_ENABLE.X_USER_OBJID%TYPE;
    LV_BUS_ORG_OBJID                sa.X_UDP_USER_BRAND_ENABLE.X_BUS_ORG_OBJID%TYPE;
    LV_OBJID                        sa.X_UDP_USER_BRAND_ENABLE.OBJID%TYPE;
    LV_EXIST                        PLS_INTEGER := 0;
  BEGIN

      BEGIN
        SELECT  OBJID
        INTO    LV_USER_OBJID
        FROM    TABLE_USER U
        WHERE   S_LOGIN_NAME = UPPER(IP_S_LOGIN_NAME);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          OP_STATUS_NUM := '1';
          OP_STATUS_MESSAGE := 'Not a valid login name. please provide a valid login name';
          RAISE;
        WHEN OTHERS THEN
          RAISE;
      END;

      BEGIN
        SELECT  OBJID
        INTO    LV_BUS_ORG_OBJID
        FROM    TABLE_BUS_ORG
        WHERE   S_ORG_ID = UPPER(IP_S_ORG_ID);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          OP_STATUS_NUM := '1';
          OP_STATUS_MESSAGE := 'Not a valid Org ID. please provide a valid Org ID';
          RAISE;
        WHEN OTHERS THEN
          RAISE;
      END;

      BEGIN
        SELECT    OBJID
        INTO      LV_OBJID
        FROM      sa.X_UDP_USER_BRAND_ENABLE
        WHERE     X_USER_OBJID = LV_USER_OBJID
        AND       X_BUS_ORG_OBJID = LV_BUS_ORG_OBJID
        ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          LV_EXIST := 0;
          LV_OBJID := NULL;
        WHEN OTHERS THEN
          OP_STATUS_NUM := '1';
          OP_STATUS_MESSAGE := 'Failure';
          RAISE;
      END;

      IF LV_OBJID IS NULL THEN
        sa.AGENT_MGT.SP_INSERT_USER_BRAND_ENABLE
          (
            LV_USER_OBJID
            ,	LV_BUS_ORG_OBJID
            ,	IP_FLAG_ENABLE
            ,	IP_IDN_USER_CHANGE_LAST
            , LV_OBJID
            , OP_STATUS_NUM
            , OP_STATUS_MESSAGE
          );
          DBMS_OUTPUT.PUT_LINE('Inserted IP_S_LOGIN_NAME: '||IP_S_LOGIN_NAME|| ', IP_S_ORG_ID:'||IP_S_ORG_ID||', LV_OBJID:'||LV_OBJID||' with IP_FLAG_ENABLE:'||IP_FLAG_ENABLE);
      ELSIF LV_OBJID IS NOT NULL THEN
        sa.AGENT_MGT.SP_UPDATE_USER_BRAND_ENABLE
          (
            LV_OBJID
            , LV_USER_OBJID
            ,	LV_BUS_ORG_OBJID
            , IP_FLAG_ENABLE
            , IP_IDN_USER_CHANGE_LAST
            , OP_STATUS_NUM
            , OP_STATUS_MESSAGE
          );
        DBMS_OUTPUT.PUT_LINE('Updated IP_S_LOGIN_NAME: '||IP_S_LOGIN_NAME|| ', IP_S_ORG_ID:'||IP_S_ORG_ID||', LV_OBJID:'||LV_OBJID||' with IP_FLAG_ENABLE:'||IP_FLAG_ENABLE);
      END IF;

      IF LV_OBJID IS NOT NULL THEN
        OP_OBJID := LV_OBJID;
        OP_STATUS_NUM := '0';
        OP_STATUS_MESSAGE := 'Success';
      ELSE
        OP_STATUS_NUM := '1';
        OP_STATUS_MESSAGE := 'Failure. Did not insert or update, please check.';
      END IF;
  EXCEPTION
    WHEN OTHERS THEN
      OP_STATUS_NUM := '1';
      OP_STATUS_MESSAGE := 'Failure';
      ROLLBACK;
      RAISE;
  END SP_MODIFY_BRAND_VISIBLE_2_USER;

END AGENT_MGT;
/