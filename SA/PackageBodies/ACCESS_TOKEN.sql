CREATE OR REPLACE PACKAGE BODY sa."ACCESS_TOKEN"
AS
 /****************************************************************************************************/
 --$RCSfile: ACCESS_TOKEN_PKB.sql,v $
  --$Revision: 1.28 $
  --$Author: sraman $
  --$Date: 2017/04/14 22:04:08 $
  --$ $Log: ACCESS_TOKEN_PKB.sql,v $
  --$ Revision 1.28  2017/04/14 22:04:08  sraman
  --$ CR49087 - commented table_x_parameters use in this query
  --$
  --$ Revision 1.27  2015/06/17 15:55:20  jarza
  --$ CR32782 changes - Added a new procedure(EXPIRE_USER_TOKEN_IMMEDIATE) to expire user token immediately.
  --$ When SOA calls this procedure all the tokens linked to this user will expire.
  --$
  --$ Revision 1.26  2015/02/02 14:17:36  ahabeeb
  --$ Added new proc - getAccountFromToken
  --$
  --$ Revision 1.25  2014/02/26 21:05:33  mvadlapally
  --$ CR25065 - Safelink friends
  --$
  --$ Revision 1.23  2014/01/28 20:31:08  mvadlapally
  --$ CR25065  SL friends
  --$
  --$ Revision 1.15  2012/08/23 19:46:10  icanavan
  --$ TELCEL merge with 21540
  --$
  --$ Revision 1.14  2012/08/13 21:19:35  mmunoz
  --$ CR21540 : Added procedure CreateOrUpdatePartner (master CR15547)
  --$
  --$ Revision 1.12  2012/07/23 20:46:54  mmunoz
  --$ CR15547 : PROCEDURE UpdateRequestToken updated and ValidateTokensGetAccInfo, CreatePartner added
  --$
  --$ Revision 1.11  2011/11/07 19:16:56  mmunoz
  --$ Added op_email in check_myaccount
  --$
  --$ Revision 1.10  2011/10/27 21:50:08  mmunoz
  --$ Removed COMMIT
  --$
  --$ Revision 1.9  2011/10/27 19:50:58  mmunoz
  --$ Added sqlerr message
  --$
  --$ Revision 1.5  2011/10/19 15:05:50  akhan
  --$ Adding CVS header
  --$
  /***************************************************************************************************/
  /*===============================================================================================*/
  /*                                                                                               */
  /* PURPOSE  : Package has been developed to manage token information related with                */
  /*            interfacing between Antenna and Tracfone for Savings Club                          */
  /*                                                                                               */
  /* REVISIONS  DATE       WHO            PURPOSE                                                  */
  /* --------------------------------------------------------------------------------------------- */
  /*            10/17/11   mmunoz     CR15547: Mobile Marketing - Savings Club. Initial  Revision  */
  /*            08/23/12   icanavan   CR20451 | CR20854: Add TELCEL Brand                          */
  /*===============================================================================================*/
  CURSOR Get_ESN ( ip_esn IN VARCHAR2 )
  IS
    SELECT pi.objid ,
      pi.part_serial_no ,
      pi.n_part_inst2part_mod ,
      pi.x_part_inst_status
    FROM table_part_inst pi
    WHERE pi.x_domain     = 'PHONES'
    AND pi.part_serial_no = ip_esn;
  CURSOR MyAccount ( ip_objid_esn IN NUMBER )
  IS
    SELECT web.objid ,
      web.login_name ,
      web.password ,
      NVL(web.x_validated,0) x_validated ,
      web.x_validated_counter ,
      web.web_user2contact
    FROM table_x_contact_part_inst conpi ,
      table_web_user web
    WHERE conpi.x_contact_part_inst2part_inst = ip_objid_esn
    AND web.web_user2contact                  = conpi.x_contact_part_inst2contact;

  --CR49087 - commented table_x_parameters use in this query
  CURSOR Get_Brand_Model ( ip_n_part_inst2part_mod IN NUMBER )
  IS
    SELECT bo.s_org_id brand_name ,
      bo.web_site url ,
      ml.mod_level ,
      pn.part_number ,
      pn.x_manufacturer ,
      pn.x_technology ,
      pn.x_product_code
    FROM table_mod_level ml ,
      table_part_num pn ,
      table_bus_org bo --,
      --table_x_parameters pm
    WHERE ml.objid                     = ip_n_part_inst2part_mod
    AND pn.objid                       = ml.part_info2part_num
    AND bo.objid                       = pn.part_num2bus_org

    ;
  --  SELECT   bo.s_org_id brand_name
  --          ,bo.web_site url
  --          ,ml.mod_level
  --          ,pn.part_number
  --          ,pn.x_manufacturer
  --          ,pn.x_technology
  --          ,pn.x_product_code
  --  FROM    table_mod_level ml
  --          ,table_part_num  pn
  --          ,table_bus_org   bo
  --     ,table_x_parameters pm
  --  WHERE   ml.objid  = ip_n_part_inst2part_mod
  --  AND     pn.objid  = ml.part_info2part_num
  --  AND     bo.objid  = pn.part_num2bus_org
  --  AND     pm.X_PARAM_NAME = 'ACTIVE_BRAND'
  --  AND     INSTR(X_PARAM_VALUE,BO.ORG_ID) > 0;
  CURSOR Get_Account_inf ( ip_objid_web IN NUMBER )
  IS
    SELECT
      /*+ ORDERED */
      web.objid ,
      web.login_name ,
      web.password ,
      NVL(web.x_validated,0) x_validated ,
      web.x_validated_counter ,
      web.web_user2contact ,
      pi.part_serial_no ,
      pi.x_part_inst_status ,
      bo.s_org_id brand_name ,
      bo.web_site url ,
      ml.mod_level ,
      pn.part_number ,
      pn.x_manufacturer ,
      pn.x_technology ,
      pn.x_product_code
    FROM table_web_user web ,
      table_x_contact_part_inst conpi ,
      table_part_inst pi ,
      table_mod_level ml ,
      table_part_num pn ,
      table_bus_org bo
    WHERE web.objid                       = ip_objid_web
    AND conpi.x_contact_part_inst2contact = web.web_user2contact
    AND conpi.x_is_default                = 1 --The record belongs to the primary esn of the account: 0=No, 1=Yes
    AND pi.objid                          = conpi.x_contact_part_inst2part_inst
    AND ml.objid                          = pi.n_part_inst2part_mod
    AND pn.objid                          = ml.part_info2part_num
    AND bo.objid                          = pn.part_num2bus_org;
  CURSOR Get_user_token_info ( ip_user_token IN VARCHAR2 )
  IS
    SELECT xat.objid ,
      xat.x_user_token ,
      xat.x_user_token_expires ,
      xat.x_login_level ,
      xat.acc_token2web_user
    FROM x_access_token xat
    WHERE xat.x_user_token = ip_user_token;
  CURSOR Get_Request_Token_info ( ip_tp_request_token IN VARCHAR2 )
  IS
    SELECT xtptu.objid ,
      xtptu.x_request_token ,
      xtptu.x_request_token_expires
    FROM x_thirdparty_token xtptu
    WHERE xtptu.x_request_token = ip_tp_request_token;
FUNCTION token_expire
  RETURN DATE
IS
  token_timeout DATE;
BEGIN
  SELECT sysdate + to_number(x_param_value) token_timeout
  INTO token_timeout
  FROM table_x_parameters txp
  WHERE txp.x_param_name = 'TOKEN_TIMEOUT';
  RETURN token_timeout;
END token_expire;
PROCEDURE EXPIRE_USER_TOKEN_IMMEDIATE(
      ip_accountid  IN NUMBER ,
      op_err_num OUT NUMBER ,
      op_err_string OUT VARCHAR2 ) as
BEGIN
  op_err_num := 0;
  op_err_string := 'Success';
  UPDATE sa.x_access_token
  SET x_user_token_expires = sysdate
  WHERE acc_token2web_user = ip_accountid;

  IF SQL%ROWCOUNT = 0 THEN
    op_err_num := 1;
    op_err_string := 'No record found for given Account id: '||ip_accountid;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    op_err_num := 2;
    op_err_string := 'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
    ROLLBACK;
    RAISE;
END EXPIRE_USER_TOKEN_IMMEDIATE;
PROCEDURE Check_MyAccount(
    ip_esn IN VARCHAR2 ,
    op_email OUT VARCHAR2 ,
    op_accountid OUT NUMBER ,
    op_contactObjid OUT NUMBER ,
    op_user_token OUT VARCHAR2 ,
    op_brand OUT VARCHAR2 ,
    op_model OUT VARCHAR2 ,
    op_url OUT VARCHAR2 ,
    op_loginlevel OUT NUMBER ,
    op_isEmailValidated OUT NUMBER ,
    op_err_num OUT NUMBER ,
    op_err_string OUT VARCHAR2 )
IS
  CURSOR Get_User_Token_by_acc ( ip_objid_web IN NUMBER )
  IS
    SELECT xat.objid ,
      xat.x_user_token ,
      xat.x_user_token_expires ,
      xat.x_login_level
    FROM x_access_token xat
    WHERE xat.acc_token2web_user = ip_objid_web;
  Get_ESN_rec Get_ESN%rowtype;
  MyAccount_rec MyAccount%rowtype;
  Get_Brand_Model_rec Get_Brand_Model%rowtype;
  Get_User_Token_by_acc_rec Get_User_Token_by_acc%rowtype;
BEGIN
  op_err_num                   := 0;
  IF INSTR(NVL(ip_esn,' '),' ') > 0 --ESN is null
    THEN
    op_err_num := 520;
  ELSE
    OPEN Get_ESN(ip_esn);
    FETCH Get_ESN INTO Get_ESN_rec;
    IF Get_ESN%NOTFOUND THEN
      op_err_num := 2; --521;  --Invalid ESN
    ELSE
      --              IF Get_ESN_rec.x_part_inst_status <> '52'
      --              THEN
      --                  op_err_num     := 522;  --ESN Not Active
      --              ELSE
      OPEN MyAccount(Get_ESN_rec.objid);
      FETCH MyAccount INTO MyAccount_rec;
      IF MyAccount%NOTFOUND THEN
        op_err_num := 1; --523;  --ESN does not have an Account
      ELSE
        OPEN Get_Brand_Model(Get_ESN_rec.n_part_inst2part_mod);
        FETCH Get_Brand_Model INTO Get_Brand_Model_rec;
        -- CR20451 | CR20854: Add TELCEL Brand
        -- IF Get_Brand_Model_rec.brand_name NOT IN ('TRACFONE', 'NET10', 'STRAIGHT_TALK')
        IF Get_Brand_Model%NOTFOUND THEN
          op_err_num := 2; --528;  --ESN does not belong to TRACFONE, NET10 or STRAIGHT TALK
        ELSE
          OPEN Get_User_Token_by_acc(MyAccount_rec.objid);
          FETCH Get_User_Token_by_acc INTO Get_User_Token_by_acc_rec;
          op_email            := MyAccount_rec.login_name;
          op_accountid        := MyAccount_rec.objid;
          op_contactObjid     := MyAccount_rec.web_user2contact;
          op_user_token       := Get_User_Token_by_acc_rec.x_user_token;
          op_brand            := Get_Brand_Model_rec.brand_name;
          op_model            := Get_Brand_Model_rec.part_number;
          op_url              := Get_Brand_Model_rec.url;
          op_loginlevel       := Get_User_Token_by_acc_rec.x_login_level;
          op_isEmailValidated := MyAccount_rec.x_validated;
          CLOSE Get_User_Token_by_acc;
        END IF;
        CLOSE Get_Brand_Model;
      END IF;
      CLOSE MyAccount;
      --              END IF;
    END IF;
    CLOSE Get_ESN;
  END IF;
  IF op_err_num    = 0 THEN
    op_err_string := 'Success';
  ELSE
    op_err_string :=
    CASE op_err_num
    WHEN 1 THEN
      'Error ESN does not have account '
    WHEN 2 THEN
      'Invalid ESN [NO TRACFONE/NET10/STRAIGHT_TALK/TELCEL]'
    ELSE
      sa.get_code_fun('ACCESS_TOKEN', op_err_num, 'ENGLISH')
    END;
  END IF;
END Check_MyAccount;
PROCEDURE ValidateUserToken(
    ip_user_token IN VARCHAR2 ,
    op_user_token_info OUT Get_user_token_info%rowtype ,
    op_err_num OUT NUMBER ,
    op_err_string OUT VARCHAR2 )
IS
  Get_user_token_info_rec Get_user_token_info%rowtype;
BEGIN
  op_err_num                          := 0;
  IF INSTR(NVL(ip_user_token,' '),' ') > 0 --TOKEN is null
    THEN
    op_err_num := 524;
  ELSE
    OPEN Get_user_token_info(ip_user_token);
    FETCH Get_user_token_info INTO Get_user_token_info_rec;
    IF Get_user_token_info%NOTFOUND THEN
      op_err_num := 1; --525;  --Invalid TOKEN
    ELSE
      IF Get_user_token_info_rec.x_user_token_expires < SYSDATE THEN
        op_err_num                                   := 2; --526;  --Token has been expired
      END IF;
    END IF;
    op_user_token_info := Get_user_token_info_rec;
    CLOSE Get_user_token_info;
  END IF;
  IF op_err_num    = 0 THEN
    op_err_string := 'Success';
  ELSE
    op_err_string :=
    CASE op_err_num
    WHEN 1 THEN
      'Error User Token does not exist'
    WHEN 2 THEN
      'Error User Token expired'
    ELSE
      sa.get_code_fun('ACCESS_TOKEN', op_err_num, 'ENGLISH')
    END;
  END IF;
END ValidateUserToken;
PROCEDURE ValidateUserToken(
    ip_user_token IN VARCHAR2 ,
    op_err_num OUT NUMBER ,
    op_err_string OUT VARCHAR2 )
IS
  op_user_token_info Get_user_token_info%rowtype;
BEGIN
  ValidateUserToken ( ip_user_token ,op_user_token_info ,op_err_num ,op_err_string);
END;
PROCEDURE GetUserTokenAccountInfo(
    ip_user_token IN VARCHAR2 ,
    op_accountid OUT VARCHAR2 ,
    op_contactObjid OUT NUMBER ,
    op_brand OUT VARCHAR2 ,
    op_model OUT VARCHAR2 ,
    op_loginlevel OUT VARCHAR2 ,
    op_isEmailValidated OUT NUMBER ,
    op_err_num OUT NUMBER ,
    op_err_string OUT VARCHAR2 )
IS
  Get_user_token_info_rec Get_user_token_info%rowtype;
  Get_Account_inf_rec Get_Account_inf%rowtype;
  CURSOR c_user_referrer ( in_web_user IN NUMBER ) -- added for CR25065 - SL friends
  IS
    SELECT refr.x_referrer_id,
      refr.x_validated
    FROM x_user_referrers refr
    WHERE x_user_ref2webuser = in_web_user;
  r_user_referrer c_user_referrer%ROWTYPE;
BEGIN
  ValidateUserToken ( ip_user_token ,Get_user_token_info_rec ,op_err_num ,op_err_string);
  OPEN c_user_referrer(Get_user_token_info_rec.acc_token2web_user);
  FETCH c_user_referrer INTO r_user_referrer;
  IF (c_user_referrer%FOUND AND op_err_num       = 0) THEN
    op_accountid                                := r_user_referrer.x_referrer_id;
    op_contactObjid                             := 0; -- Not used for SLFriends
    op_brand                                    := NULL ;
    op_model                                    := 0 ; -- No model for SLFriends
    op_loginlevel                               := Get_user_token_info_rec.x_login_level;
    op_isEmailValidated                         := r_user_referrer.x_validated;
  ELSIF (c_user_referrer%NOTFOUND AND op_err_num = 0) THEN
    OPEN Get_Account_inf(Get_user_token_info_rec.acc_token2web_user);
    FETCH Get_Account_inf INTO Get_Account_inf_rec;
    IF Get_Account_inf%NOTFOUND THEN
      op_err_num := 527;
    ELSE
      op_accountid        := Get_Account_inf_rec.objid;
      op_contactObjid     := Get_Account_inf_rec.web_user2contact;
      op_brand            := Get_Account_inf_rec.brand_name;
      op_model            := Get_Account_inf_rec.part_number;
      op_loginlevel       := Get_user_token_info_rec.x_login_level;
      op_isEmailValidated := Get_Account_inf_rec.x_validated;
    END IF;
    CLOSE Get_Account_inf;
  END IF;
  CLOSE c_user_referrer;
  IF op_err_num    > 500 THEN
    op_err_string := sa.get_code_fun('ACCESS_TOKEN', op_err_num, 'ENGLISH');
  END IF;
END GetUserTokenAccountInfo;
PROCEDURE ValidateRequestToken(
    ip_request_token IN VARCHAR2 ,
    op_err_num OUT NUMBER ,
    op_err_string OUT VARCHAR2 )
IS
  Get_Request_Token_info_rec Get_Request_Token_info%rowtype;
BEGIN
  op_err_num                             := 0;
  IF INSTR(NVL(ip_request_token,' '),' ') > 0 THEN
    op_err_num                           := 1; --530;  --ThirdParty TOKEN is null
  ELSE
    OPEN Get_Request_Token_info(ip_request_token);
    FETCH Get_Request_Token_info INTO Get_Request_Token_info_rec;
    IF Get_Request_Token_info%NOTFOUND THEN
      op_err_num := 1; --531;  --ThirdParty Invalid TOKEN
    ELSE
      IF Get_Request_Token_info_rec.x_request_token_expires < SYSDATE THEN
        op_err_num                                         := 2; --532;  --Third Party Token has been expired
      END IF;
    END IF;
    CLOSE Get_Request_Token_info;
  END IF;
  IF op_err_num    = 0 THEN
    op_err_string := 'Success';
  ELSE
    op_err_string :=
    CASE op_err_num
    WHEN 1 THEN
      'Error Partner Token does not exist'
    WHEN 2 THEN
      'Error Partner Token expired'
    ELSE
      sa.get_code_fun('ACCESS_TOKEN', op_err_num, 'ENGLISH')
    END;
  END IF;
END ValidateRequestToken;
PROCEDURE getAccountFromToken(
    ip_request_token IN VARCHAR2 ,
    op_login_name OUT VARCHAR2 ,
    op_err_num OUT NUMBER ,
    op_err_string OUT VARCHAR2 )
IS
  CURSOR Get_user_token_info ( ip_user_token IN VARCHAR2 )
  IS
    SELECT xat.objid ,
      xat.x_user_token ,
      x_user_token_expires,
      xat.x_login_level ,
      xat.acc_token2web_user
    FROM x_access_token xat
    WHERE xat.x_user_token = ip_user_token;
  CURSOR Get_login_name ( ip_wu_objid IN NUMBER )
  IS
    SELECT login_name,
      s_login_name
    FROM sa.table_web_user
    WHERE objid = ip_wu_objid;
  Get_user_token_info_rec Get_user_token_info%rowtype;
  Get_login_name_Rec Get_login_name%rowtype;
  l_error_msg VARCHAR2(4000);
BEGIN
  op_err_num    := 0;
  op_err_string := 'Success';
  OPEN Get_user_token_info (ip_request_token);
  FETCH Get_user_token_info INTO Get_user_token_info_rec;
  IF Get_user_token_info%NOTFOUND THEN
    op_err_num    := 1;
    op_err_string := 'Error User Token does not exist';
    CLOSE Get_user_token_info;
    RETURN;
  ELSIF Get_user_token_info_rec.x_user_token_expires < SYSDATE THEN
    op_err_num                                      := 2;
    op_err_string                                   := 'Error user Token expired';
    CLOSE Get_user_token_info;
    RETURN;
  ELSE
    CLOSE Get_user_token_info;
  END IF;
  OPEN Get_login_name (Get_user_token_info_rec.acc_token2web_user);
  FETCH Get_login_name INTO Get_login_name_Rec;
  IF Get_login_name%NOTFOUND THEN
    op_err_num    := 3;
    op_err_string := 'Error login name not found for Token';
    CLOSE Get_login_name;
    RETURN;
  ELSE
    op_login_name := Get_login_name_rec.login_name;
    CLOSE Get_login_name;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  l_error_msg   := SQLCODE || ': ' || sqlerrm || '.';
  op_err_num    := -1;
  op_err_string := SUBSTR(l_error_msg, 1, 100);
  sa.ota_util_pkg.err_log (p_action => ip_request_token ,p_error_date => SYSDATE ,p_key => 'SA.ACCESS_TOKEN.getAccountFromToken' ,p_program_name => 'SA.ACCESS_TOKEN.getAccountFromToken' ,p_error_text => l_error_msg);
END;
PROCEDURE Validate_Login_ESN(
    ip_user_name IN VARCHAR2 ,
    ip_password  IN VARCHAR2 ,
    ip_esn       IN VARCHAR2 ,
    op_accountid OUT NUMBER ,
    op_user_token OUT VARCHAR2 ,
    op_brand_name OUT VARCHAR2 ,
    op_model_number OUT VARCHAR2 ,
    op_url OUT VARCHAR2 ,
    op_err_num OUT NUMBER ,
    op_err_string OUT VARCHAR2 )
IS
  CURSOR Get_token_by_user ( ip_user_name IN VARCHAR2 ,ip_password IN VARCHAR2 )
  IS
    SELECT xat.objid ,
      xat.x_user_token ,
      xat.x_user_token_expires ,
      NVL(web.x_validated,0) x_validated ,
      web.web_user2contact ,
      xat.x_login_level
    FROM table_web_user web ,
      x_access_token xat
    WHERE web.login_name       = ip_user_name
    AND web.password           = ip_password
    AND xat.acc_token2web_user = web.objid;
  Get_ESN_rec Get_ESN%rowtype;
  MyAccount_rec MyAccount%rowtype;
  Get_Brand_Model_rec Get_Brand_Model%rowtype;
  Get_token_by_user_rec Get_token_by_user%rowtype;
BEGIN
  op_err_num := 0;
  OPEN Get_token_by_user(ip_user_name,ip_password);
  FETCH Get_token_by_user INTO Get_token_by_user_rec;
  IF Get_token_by_user%NOTFOUND THEN
    op_err_num                                    := 535; --Invalid login
  ELSIF Get_token_by_user_rec.x_user_token_expires < SYSDATE THEN
    op_err_num                                    := 526; --Token has been expired
  END IF;
  op_user_token := Get_token_by_user_rec.x_user_token;
  CLOSE Get_token_by_user;
  IF INSTR(NVL(ip_esn,' '),' ') = 0 AND op_err_num = 0 --ESN is NOT null
    THEN
    OPEN Get_ESN(ip_esn);
    FETCH Get_ESN INTO Get_ESN_rec;
    IF Get_ESN%NOTFOUND THEN
      op_err_num := 536; --Success Login but Fail ESN Attachment
    ELSE
      IF Get_ESN_rec.x_part_inst_status <> '52' THEN
        op_err_num                      := 522; --ESN Not Active
      ELSE
        OPEN MyAccount(Get_ESN_rec.objid);
        FETCH MyAccount INTO MyAccount_rec;
        IF MyAccount%NOTFOUND THEN
          op_err_num := 523; --ESN does not have an Account
        ELSE
          OPEN Get_Brand_Model(Get_ESN_rec.n_part_inst2part_mod);
          FETCH Get_Brand_Model INTO Get_Brand_Model_rec;
          -- CR20451 | CR20854: Add TELCEL Brand
          -- IF Get_Brand_Model_rec.brand_name NOT IN ('TRACFONE', 'NET10', 'STRAIGHT_TALK')
          IF Get_Brand_Model%NOTFOUND THEN
            op_err_num := 528; --ESN does not belong to TRACFONE, NET10 or STRAIGHT TALK
          ELSE
            IF MyAccount_rec.login_name <> ip_user_name OR MyAccount_rec.password <> ip_password THEN
              op_err_num                := 529; --The Optional ESN belongs to another Account
            END IF;
          END IF;
          op_accountid    := MyAccount_rec.objid;
          op_brand_name   := Get_Brand_Model_rec.brand_name;
          op_model_number := Get_Brand_Model_rec.part_number;
          op_url          := Get_Brand_Model_rec.url;
          CLOSE Get_Brand_Model;
        END IF;
        CLOSE MyAccount;
      END IF;
    END IF;
    CLOSE Get_ESN;
  END IF;
  IF op_err_num    = 0 THEN
    op_err_string := 'Success';
  ELSE
    op_err_string := sa.get_code_fun('ACCESS_TOKEN', op_err_num, 'ENGLISH');
  END IF;
END Validate_Login_ESN;
PROCEDURE CheckAccountLogin(
    ip_user_name IN VARCHAR2 ,
    ip_password  IN VARCHAR2 ,
    ip_brand     IN VARCHAR2 ,
    op_accountid OUT NUMBER ,
    op_contactObjid OUT NUMBER ,
    op_model OUT VARCHAR2 ,
    op_err_num OUT NUMBER ,
    op_err_string OUT VARCHAR2 )
IS
  CURSOR Get_web_user_info ( ip_user_name IN VARCHAR2 ,ip_password IN VARCHAR2 )
  IS
    SELECT web.objid ,
      web.web_user2contact
    FROM table_web_user web
    WHERE web.login_name = ip_user_name
    AND web.password     = ip_password ;
  Get_Account_inf_rec Get_Account_inf%rowtype;
  Get_web_user_info_rec Get_web_user_info%rowtype;
BEGIN
  op_err_num := 0;
  OPEN Get_web_user_info(ip_user_name,ip_password);
  FETCH Get_web_user_info INTO Get_web_user_info_rec;
  IF Get_web_user_info%NOTFOUND THEN
    op_err_num := 1; --535;     --Invalid login
  ELSE
    op_accountid    := Get_web_user_info_rec.objid;
    op_contactObjid := Get_web_user_info_rec.web_user2contact;
  END IF;
  CLOSE Get_web_user_info;
  OPEN Get_Account_inf(Get_web_user_info_rec.objid);
  FETCH Get_Account_inf INTO Get_Account_inf_rec;
  IF Get_Account_inf%NOTFOUND THEN
    op_err_num := 1;
  ELSE
    IF NVL(ip_brand,' ') != ' ' AND Get_Account_inf_rec.brand_name != ip_brand THEN
      op_err_num         := 1;
    END IF;
    op_model := Get_Account_inf_rec.part_number;
  END IF;
  CLOSE Get_Account_inf;
  IF op_err_num    = 0 THEN
    op_err_string := 'Success';
  ELSE
    op_err_string :=
    CASE op_err_num
    WHEN 1 THEN
      'Not Found'
    ELSE
      sa.get_code_fun('ACCESS_TOKEN', op_err_num, 'ENGLISH')
    END;
  END IF;
END CheckAccountLogin;
PROCEDURE ValidateB2BUser(
    ip_user_name IN VARCHAR2 ,
    ip_password  IN VARCHAR2 ,
    op_err_num OUT NUMBER ,
    op_err_string OUT VARCHAR2 )
IS
  CURSOR Get_TP_token_by_acc ( ip_user_name IN VARCHAR2 ,ip_password IN VARCHAR2 )
  IS
    SELECT xtptu.objid ,
      xtptu.x_request_token ,
      xtptu.x_request_token_expires
    FROM x_thirdparty_token xtptu
    WHERE xtptu.x_user_name = ip_user_name
    AND xtptu.x_password    = ip_password;
  Get_TP_token_by_acc_rec Get_TP_token_by_acc%rowtype;
BEGIN
  op_err_num := 0;
  OPEN Get_TP_token_by_acc(ip_user_name,ip_password);
  FETCH Get_TP_token_by_acc INTO Get_TP_token_by_acc_rec;
  IF Get_TP_token_by_acc%NOTFOUND THEN
    op_err_num := 1; --534;   --Invalid Third Party Login
    /*****
    ELSE
    IF Get_TP_token_by_acc_rec.x_request_token_expires < SYSDATE
    THEN
    op_err_num     := 532;  --Third Party Token has been expired
    END IF;
    op_token        := Get_TP_token_by_acc_rec.x_request_token;
    op_token_expire := Get_TP_token_by_acc_rec.x_request_token_expires;
    *****/
  END IF;
  CLOSE Get_TP_token_by_acc;
  IF op_err_num    = 0 THEN
    op_err_string := 'Success';
  ELSE
    op_err_string :=
    CASE op_err_num
    WHEN 1 THEN
      'Not Found'
    ELSE
      sa.get_code_fun('ACCESS_TOKEN', op_err_num, 'ENGLISH')
    END;
  END IF;
END ValidateB2BUser;
PROCEDURE UpdateUserToken(
    ip_accountid  IN NUMBER ,
    ip_token      IN VARCHAR2 ,
    ip_loginlevel IN NUMBER ,
    op_err_num OUT NUMBER ,
    op_err_string OUT VARCHAR2 )
IS
  timeout_date DATE;
BEGIN
  IF ip_accountid IS NOT NULL THEN
    timeout_date  := token_expire;
    UPDATE x_access_token
    SET x_user_token         = ip_token ,
      x_user_token_expires   = timeout_date
    WHERE acc_token2web_user = ip_accountid;
    IF SQL%ROWCOUNT          = 0 THEN
      INSERT
      INTO x_access_token
        (
          OBJID,
          X_USER_TOKEN,
          X_USER_TOKEN_EXPIRES,
          ACC_TOKEN2WEB_USER,
          X_LOGIN_LEVEL
        )
        VALUES
        (
          sa.SEQ_X_ACCESS_TOKEN.NEXTVAL ,
          ip_token ,
          timeout_date ,
          ip_accountid ,
          NVL(ip_loginlevel,0)
        );
    END IF;
    op_err_num    := 0;
    op_err_string := 'Success';
  ELSE
    op_err_num    := 537;
    op_err_string := sa.get_code_fun('ACCESS_TOKEN', op_err_num, 'ENGLISH')||' Account Id is invalid';
  END IF;
EXCEPTION
WHEN OTHERS THEN
  op_err_num    := 537;
  op_err_string := SQLERRM||' '||'ip_accountid=>'||ip_accountid ||' '||'ip_token=>'||ip_token ||' '||'ip_loginlevel=>'||ip_loginlevel;
  --op_err_string  := SA.get_code_fun('ACCESS_TOKEN', op_err_num, 'ENGLISH');
END UpdateUserToken;
PROCEDURE UpdateRequestToken
  (
    ip_token     IN VARCHAR2 ,
    ip_user_name IN VARCHAR2 ,
    op_err_num OUT NUMBER ,
    op_err_string OUT VARCHAR2
  )
IS
  timeout_date DATE;
BEGIN
  timeout_date := token_expire;
  UPDATE x_thirdparty_token
  SET x_request_token       = ip_token ,
    x_request_token_expires = timeout_date
  WHERE x_user_name         = lower(trim(ip_user_name)) ;
  op_err_num               := 0;
  op_err_string            := 'Success  row(s) updated: '||sql%rowcount;
EXCEPTION
WHEN OTHERS THEN
  op_err_num    := 538;
  op_err_string := sa.get_code_fun('ACCESS_TOKEN', op_err_num, 'ENGLISH');
  op_err_string := SQLERRM||' '||'ip_token=>'||ip_token;
END UpdateRequestToken;
PROCEDURE ValidateTokensGetAccInfo(
    ip_user_token    IN VARCHAR2 ,
    ip_partner_token IN VARCHAR2 ,
    op_accountid OUT VARCHAR2 ,
    op_contactObjid OUT NUMBER ,
    op_brand OUT VARCHAR2 ,
    op_model OUT VARCHAR2 ,
    op_loginlevel OUT VARCHAR2 ,
    op_isEmailValidated OUT NUMBER ,
    op_err_num OUT NUMBER ,
    op_err_string OUT VARCHAR2 )
IS
BEGIN
  ValidateRequestToken ( ip_partner_token ,op_err_num ,op_err_string );
  IF op_err_num = 0 THEN
    GetUserTokenAccountInfo ( ip_user_token ,op_accountid ,op_contactObjid ,op_brand ,op_model ,op_loginlevel ,op_isEmailValidated ,op_err_num ,op_err_string);
  END IF;
END ValidateTokensGetAccInfo;
PROCEDURE CreateOrUpdatePartner(
    ip_user_name    IN VARCHAR2 ,
    ip_password     IN VARCHAR2 ,
    ip_company_name IN VARCHAR2 ,
    op_err_num OUT NUMBER ,
    op_err_string OUT VARCHAR2 )
IS
BEGIN
  MERGE INTO x_thirdparty_token xtt USING
  (SELECT 1 FROM dual
  ) a ON ( xtt.X_USER_NAME = ip_user_name )
WHEN MATCHED THEN
  UPDATE
  SET X_PASSWORD   = ip_password ,
    X_COMPANY_NAME = ip_company_name WHEN NOT MATCHED THEN
  INSERT
    (
      OBJID,
      X_USER_NAME,
      X_PASSWORD,
      X_COMPANY_NAME
    )
    VALUES
    (
      sa.SEQ_X_THIRDPARTY_TOKEN.NEXTVAL ,
      ip_user_name ,
      ip_password ,
      ip_company_name
    );
  op_err_num    := 0;
  op_err_string := 'Successfully create or updated partner';
EXCEPTION
WHEN OTHERS THEN
  op_err_num    := 1;
  op_err_string := 'Failure to create or update partner';
  dbms_output.put_line(SQLERRM);
END CreateOrUpdatePartner;
BEGIN
  NULL;
END ACCESS_TOKEN;
/
