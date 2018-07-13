CREATE OR REPLACE PACKAGE BODY sa."B2B_PKG" AS
 /*******************************************************************************************************
  --$RCSfile: B2B_PKb.sql,v $
  --$Revision: 1.9 $
  --$Author: skambhammettu $
  --$Date: 2018/03/07 22:27:16 $
  --$ $Log: B2B_PKb.sql,v $
  --$ Revision 1.9  2018/03/07 22:27:16  skambhammettu
  --$ CR55236--change in get_esn_web_user
  --$
  --$ Revision 1.8  2014/09/04 21:34:14  hcampano
  --$ Added CUST_ID to isb2b check.
  --$
  --$ Revision 1.7  2014/06/18 16:11:35  cpannala
  --$ CR29410
  --$
  --$ Revision 1.6  2014/06/18 16:10:46  cpannala
  --$ get esn web user has chanegs for CR29410
  --$
  --$ Revision 1.1  2014/02/20 19:22:36  cpannala
  --$ CR22623 - B2B Initiative
  --$ Description: This procedure generates B2B esn for given part number.
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/
  ----
procedure is_b2b_prc(ip_type          VARCHAR2,
                                   ip_value         VARCHAR2,
                                   IP_BRAND         varchar2,--Only needed if ip_type = email
                                   OP_RESULT    out number,
                                   OP_ERR_NUM   out number,
                                   OP_ERR_MSG   out varchar2) is
begin
    op_result := is_b2b(ip_type,
                        ip_value,
                        IP_BRAND,--Only needed if ip_type = email
                        OP_ERR_NUM,
                        OP_ERR_MSG);
end is_b2b_prc;
----
PROCEDURE    POPULATE_FF_MAPPING_PRC
(
  IN_SRC_PART_NUM IN VARCHAR2
, IN_T_PART_NUM1  IN VARCHAR2
, IN_T_PART_NUM2  IN VARCHAR2
, IN_PP_NAME      IN VARCHAR2
, IN_ff_type      IN VARCHAR2
, OUT_ERR_MSG OUT VARCHAR2
, OUT_ERR_NUM OUT NUMBER
)
AS

BEGIN
OUT_ERR_MSG := 'Success';
OUT_ERR_NUM := 0 ;

 IF ((IN_SRC_PART_NUM IS NULL) OR (IN_T_PART_NUM1 IS NULL) OR (IN_T_PART_NUM2 IS NULL) OR (IN_PP_name IS NULL) OR (IN_FF_TYPE IS NULL)) THEN
   OUT_ERR_MSG := 'Need Required Inputs';
   OUT_ERR_NUM := -1;
   Return;
 END IF;

   INSERT INTO X_FF_PART_NUM_MAPPING(OBJID,
                             X_SOURCE_PART_NUM,
                             X_TARGET_PART_NUM1 ,
                             X_TARGET_PART_NUM2,
                             X_START_DATE,
                             X_END_DATE ,
                             X_FF_OBJID,
                             X_FF_TYPE )
           VALUES (SEQU_FF_PART_NUM_MAPPING.NEXTVAL,
                   IN_SRC_PART_NUM,
                   IN_T_PART_NUM1,
                   IN_T_PART_NUM2,
                   SYSDATE,
                   SYSDATE+30,
                   (SELECT OBJID FROM X_PROGRAM_PARAMETERS WHERE X_PROGRAM_NAME = IN_PP_name),
                   IN_ff_type
                   );

  Out_Err_Num := 0;
  OUT_ERR_MSG := 'Success';
 --
  Commit;
  ---
EXCEPTION
WHEN OTHERS THEN
  --
  out_err_num := SQLCODE;
  OUT_ERR_MSG := SUBSTR(sqlerrm, 1, 300);
  TOSS_UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => TO_CHAR(OUT_ERR_NUM),
                                      IP_KEY => IN_SRC_PART_NUM,
                                      IP_PROGRAM_NAME => 'POPULATE_FF_MAPPING_PRC',
                                      ip_error_text => out_err_msg);

END POPULATE_FF_MAPPING_PRC;
----
PROCEDURE    set_address(
    in_address IN address_type_rec,
    out_addr_objid OUT table_address.objid%TYPE)
IS
  --
  v_addr_objid table_address.objid%TYPE;
  v_country_objid table_country.objid%TYPE;
  V_STATE_OBJID TABLE_STATE_PROV.OBJID%TYPE;
  Address_Type Address_Type_Rec := Address_Type_Rec(NULL,NULL,NULL,NULL,NULL,NULL);
  --
FUNCTION get_country_objid(
    in_country table_country.s_name%TYPE)
  RETURN table_country.objid%TYPE
IS -- USA OR US, ITALY OR IT
  CURSOR country_cur
  IS
    SELECT objid
    FROM table_country
    WHERE(s_name                            = UPPER(in_country)
    OR x_postal_code                        = UPPER(in_country));
  v_country_objid table_country.objid%TYPE := NULL;
BEGIN
  --
  OPEN country_cur;
  FETCH country_cur INTO v_country_objid;
  CLOSE country_cur;
  --
  RETURN v_country_objid;
  --
END get_country_objid;
--
FUNCTION get_state_objid(
    in_state_code    IN table_state_prov.s_name%TYPE,
    in_country_objid IN table_country.objid%TYPE)
  RETURN table_state_prov.objid%TYPE
IS -- USA OR US, ITALY OR IT
  --
  CURSOR state_cur
  IS
    SELECT objid
    FROM table_state_prov
    WHERE s_name                             = UPPER(in_state_code)
    AND state_prov2country                   = in_country_objid;
  v_state_objid table_state_prov.objid%TYPE := NULL;
BEGIN
  --
  OPEN state_cur;
  FETCH state_cur INTO v_state_objid;
  CLOSE state_cur;
  --
  RETURN v_state_objid;
  --
END get_state_objid;
--
BEGIN
  Address_Type := in_address ;
  sp_seq('address', out_addr_objid);
  v_country_objid := get_country_objid(Address_Type.country);
  v_state_objid   := get_state_objid(Address_Type.state, v_country_objid);
  --
  INSERT
  INTO table_address
    (
      objid ,
      address ,
      s_address ,
      city ,
      s_city ,
      state ,
      s_state ,
      zipcode ,
      address_2 ,
      dev ,
      address2time_zone ,
      address2country ,
      address2state_prov ,
      update_stamp
    )
    VALUES
    (
      out_addr_objid ,
      Address_Type.address_1 ,
      UPPER(Address_Type.address_1) ,
      Address_Type.city ,
      UPPER(Address_Type.city) ,
      Address_Type.state ,
      UPPER(Address_Type.state) ,
      Address_Type.zipcode ,
      Address_Type.address_2 ,
      NULL ,
      NULL ,
      v_country_objid ,
      v_state_objid ,
      SYSDATE
    );
  --
EXCEPTION
WHEN OTHERS THEN
  OUT_ADDR_OBJID := NULL;
END set_address;
---
FUNCTION       B2B_MERCHANT_REF_NUMBER(in_channel varchar2)
  /*******************************************************************************************************
  * --$RCSfile: B2B_PKb.sql,v $
  --$Revision: 1.9 $
  --$Author: skambhammettu $
  --$Date: 2018/03/07 22:27:16 $
  --$ $Log: B2B_PKb.sql,v $
  --$ Revision 1.9  2018/03/07 22:27:16  skambhammettu
  --$ CR55236--change in get_esn_web_user
  --$
  --$ Revision 1.8  2014/09/04 21:34:14  hcampano
  --$ Added CUST_ID to isb2b check.
  --$
  --$ Revision 1.7  2014/06/18 16:11:35  cpannala
  --$ CR29410
  --$
  --$ Revision 1.6  2014/06/18 16:10:46  cpannala
  --$ get esn web user has chanegs for CR29410
  --$
  --$ Revision 1.1  2014/02/07 16:22:36 RUrimi
  --$ CR22623 - B2B Initiative
  --$
  * Description:To generate B2B merchant ref numbers
  *  * -----------------------------------------------------------------------------------------------------*/
   RETURN VARCHAR2
IS
   v_seq_name          VARCHAR2 (100) := trim ('SEQU_B2B_MERCHANT_REF_NUMBER');
   v_next_value        NUMBER;
   v_error             VARCHAR2 (1000);

BEGIN
  select SEQU_B2B_MERCHANT_REF_NUMBER.nextval
    into v_next_value
    from dual;
  RETURN    in_channel|| trunc(TO_CHAR (sysdate, 'YYYYMMDD'))||  ''|| v_next_value;

  EXCEPTION
      WHEN OTHERS
      THEN
         INSERT INTO error_table
                     (error_text,
                      error_date, action,
                      key, program_name)
              VALUES (   'Error occured when updating sequence '
                      || v_seq_name
                      || ' - '
                      || v_error,
                      trunc(sysdate),    'Updating sequence '
                               || v_seq_name,
                      v_seq_name, v_seq_name);

      COMMIT;
         raise_application_error (
            -20004,
               'Error occured when updating sequence '
            || v_seq_name
            || v_error
         );
END b2b_merchant_ref_number;
--
function is_b2b(
    ip_type          VARCHAR2,
    ip_value         VARCHAR2,
    IP_BRAND         varchar2,--Only needed if ip_type = email
    OP_ERR_NUM   out number,
    OP_ERR_MSG   out varchar2
    )
return number        -- 1-b2b  0-not b2b
is
 ---------------------------------------------------------------------------------------------
  --$RCSfile: B2B_PKb.sql,v $
  --$Revision: 1.9 $
  --$Author: skambhammettu $
  --$Date: 2018/03/07 22:27:16 $
  --$ $Log: B2B_PKb.sql,v $
  --$ Revision 1.9  2018/03/07 22:27:16  skambhammettu
  --$ CR55236--change in get_esn_web_user
  --$
  --$ Revision 1.8  2014/09/04 21:34:14  hcampano
  --$ Added CUST_ID to isb2b check.
  --$
  --$ Revision 1.7  2014/06/18 16:11:35  cpannala
  --$ CR29410
  --$
  --$ Revision 1.6  2014/06/18 16:10:46  cpannala
  --$ get esn web user has chanegs for CR29410
  --$
  --$ Revision 1.9  2014/02/08 01:32:33  akhan
  --$ correcting logic
  --$
  --$ Revision 1.8  2014/02/08 01:30:44  akhan
  --$ adjusted logic to work for  new esns(no lines attached yet)
  --$
  --$ Revision 1.7  2014/02/07 18:36:03  cpannala
  --$ CR25490
  --$
  --$ Revision 1.6  2014/02/03 15:14:51  cpannala
  --$ CR25490
  --$
  --$ Revision 1.5  2014/01/29 22:58:51  akhan
  --$ commented out redundant join
  --$
  --$ Revision 1.4  2014/01/29 22:08:20  akhan
  --$ adding sucess message
  --$
  --$ Revision 1.3  2014/01/29 21:56:49  akhan
  --$ add the needed out parameters
  --$
  --$ Revision 1.2  2014/01/27 20:05:35  csenkesen
  --$ Corrected TYPE
  --$
  --$ Revision 1.1  2014/01/27 20:02:43  csenkesen
  --$ Initial B2B Project
  --$
  --$Description: To Identify B2B ESN/MIN/Email
  --$
  --$
  ---------------------------------------------------------------------------------------------
  is_b2b_count number := 0;
  esn_serial_no table_part_inst.part_serial_no%type;
BEGIN

--Assume it is success. Will be replaced with error if any error;
op_err_num := 0;
op_err_msg := 'Success';
IF upper(ip_type) =  'EMAIL'  THEN

   select  count(*)
   into is_b2b_count
   from TABLE_WEB_USER WU,
        table_bus_org bo,
        X_SITE_WEB_ACCOUNTS SWA
   where wu.objid = swa.site_web_acct2web_user
   and bo.objid = wu.web_user2bus_org
   and bo.s_org_id = upper(ip_brand)
   and wu.s_login_name = upper(ip_value);

else
  BEGIN
    if ( upper(IP_TYPE) = 'MIN' ) then
        select esn.part_serial_no
        into esn_serial_no
        from table_part_inst esn,
             table_part_inst line
        where LINE.PART_TO_ESN2PART_INST = ESN.OBJID
        and ESN.X_DOMAIN = 'PHONES'
        and LINE.X_DOMAIN = 'LINES'
        and line.part_serial_no not like 'T%'
        and (esn.part_serial_no = ip_value
             or LINE.PART_SERIAL_NO = IP_VALUE);
    elsif upper(IP_TYPE) = 'CUST_ID' then
      begin
        select part_serial_no
        into esn_serial_no
        from table_part_inst pi, table_contact c
        where pi.X_PART_INST2CONTACT = c.objid
        and X_DOMAIN = 'PHONES'
        and c.x_cust_id = ip_value;
      exception
        when no_data_found then
             select pi.part_serial_no
             into esn_serial_no
             from table_x_contact_part_inst cpi,
                  table_web_user wu,
                  table_contact c,
                  table_part_inst pi
             where WEB_USER2CONTACT = cpi.X_CONTACT_PART_INST2CONTACT
             and cpi.X_CONTACT_PART_INST2CONTACT = c.objid
             and cpi.X_CONTACT_PART_INST2PART_INST = pi.objid
             and c.x_cust_id = IP_VALUE
             and rownum < 2;
      end;
    else
      select ESN.PART_SERIAL_NO
      into ESN_SERIAL_NO
      from TABLE_PART_INST ESN
      where ESN.X_DOMAIN = 'PHONES'
      and ESN.PART_SERIAL_NO = IP_VALUE;
    end if;

    select  count(*)
    into is_b2b_count
    from TABLE_WEB_USER WU,
         TABLE_X_CONTACT_PART_INST CPI,
         TABLE_PART_INST PI,
         X_SITE_WEB_ACCOUNTS SWA
    where WU.WEB_USER2CONTACT = CPI.X_CONTACT_PART_INST2CONTACT
    and CPI.X_CONTACT_PART_INST2PART_INST = PI.OBJID
   -- AND CPI.X_CONTACT_PART_INST2CONTACT = PI.X_PART_INST2CONTACT
    and SWA.SITE_WEB_ACCT2WEB_USER = WU.OBJID
    and  PI.PART_SERIAL_NO = esn_serial_no;
  EXCEPTION
   when others then
     is_b2b_count := 0;
    -- op_err_num := sqlcode;
    -- op_err_msg := sqlerrm;
  END;
end if;
if is_b2b_count > 0 then
    return 1;
else
    return 0;
END IF;
END is_b2b;
----
PROCEDURE          get_esn_web_user(
    in_login_name IN table_web_user.login_name%TYPE ,
    IN_BUS_ORG    IN VARCHAR2,
    in_esn        IN table_part_inst.part_serial_no%type DEFAULT NULL,
    in_min        in table_site_part.x_min%type default null,
    out_wu_objid OUT NUMBER,
    out_esn_wuobjid out number,
    out_bo_objid out number,
    out_err_num OUT NUMBER,
    out_Err_msg OUT VARCHAR2)
is
 /*******************************************************************************************************
  * --$RCSfile: B2B_PKb.sql,v $
  --$Revision: 1.9 $
  --$Author: skambhammettu $
  --$Date: 2018/03/07 22:27:16 $
  --$ $Log: B2B_PKb.sql,v $
  --$ Revision 1.9  2018/03/07 22:27:16  skambhammettu
  --$ CR55236--change in get_esn_web_user
  --$
  --$ Revision 1.8  2014/09/04 21:34:14  hcampano
  --$ Added CUST_ID to isb2b check.
  --$
  --$ Revision 1.7  2014/06/18 16:11:35  cpannala
  --$ CR29410
  --$
  --$ Revision 1.6  2014/06/18 16:10:46  cpannala
  --$ get esn web user has chanegs for CR29410
  --$
  --$ Revision 1.1  2013/12/05 16:22:36 cpannala
  --$ CR22623 - B2B Initiative
  --$
  * Description: This is internal procedure to get web user objid.
  *
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/
 -- bo_objid NUMBER;
  boobjid  NUMBER;
  Brand    VARCHAR2(40);
BEGIN
  IF In_Bus_Org IS NOT NULL THEN
    BEGIN
      select objid
      into out_bo_objid
      from table_bus_org
      WHERE Org_Id = In_Bus_Org;
    EXCEPTION
    WHEN OTHERS THEN
      out_err_num := -1;
      out_Err_msg := 'Selecting bus_org '||SUBSTR(sqlerrm, 1, 300);
      RETURN;
    END;
   END IF;
    --
 if  in_login_name is not null  THEN
    BEGIN
      SELECT objid
      INTO out_wu_objid
      FROM Table_Web_User Wu
      where wu.s_login_name     = upper(in_login_name)
      AND Wu.Web_User2bus_Org = out_Bo_Objid;
    EXCEPTION
    WHEN OTHERS THEN
      out_err_num := -1;
      out_Err_msg := 'Selecting web user for login name'||SUBSTR(sqlerrm, 1, 300);
      return;
    END;
 END IF;
 IF in_esn IS NOT NULL THEN

    BEGIN
      SELECT bo.objid ,
        bo.Org_Id
      INTO boobjid,
        Brand
      FROM table_part_num pn,
        table_mod_level ml,
        table_part_inst pi,
        table_bus_org bo
      WHERE 1                     = 1
      AND ml.part_info2part_num   = pn.objid
      AND Pi.N_Part_Inst2part_Mod = Ml.Objid
      AND Pi.Part_Serial_No       = IN_ESN
      AND Pn.Part_Num2bus_Org     = Bo.Objid;
    EXCEPTION
    WHEN OTHERS THEN
      out_err_num := -1;
      out_Err_msg := 'Selecting bus_org of given ESN'||SUBSTR(sqlerrm, 1, 300);
      RETURN;
    END;
  END IF;
IF boobjid = out_bo_objid THEN
    BEGIN
      SELECT distinct wu.objid --Added for CR55236 TW web common standards
      INTO out_esn_wuobjid
      FROM TABLE_X_CONTACT_PART_INST CPI,
        TABLE_CONTACT C,
        TABLE_PART_INST PI,
        TABLE_WEB_USER WU
      WHERE cpi.x_contact_part_inst2part_inst = pi.objid
      AND CPI.X_CONTACT_PART_INST2CONTACT     = C.OBJID
      AND Wu.Web_User2contact                 = C.Objid
      AND PI.PART_SERIAL_NO                   = in_ESN;
    EXCEPTION
    WHEN OTHERS THEN
      out_err_num := -1;
      out_Err_msg := 'Selecting web user for ESN'||SUBSTR(sqlerrm, 1, 300);
      RETURN;
    END;
  END IF;
  IF (in_esn       IS NOT NULL) AND (in_login_name IS NOT NULL) AND (in_bus_org IS NOT NULL) THEN
    IF out_Wu_Objid = out_Esn_WuObjid THEN
      NULL;
    ELSE
      out_err_num := -1;
      out_Err_msg := 'web user for ESN is different'||SUBSTR(sqlerrm, 1, 300);
      RETURN;
    END IF;
  END IF;
  out_err_num := 0;
  OUT_ERR_MSG := 'success';
EXCEPTION
WHEN OTHERS THEN
  --
  out_err_num := SQLCODE;
  OUT_ERR_MSG := SUBSTR(SQLERRM, 1, 300);
  OTA_UTIL_PKG.ERR_LOG(P_ACTION => 'B2B generate web user',
                       P_ERROR_DATE => SYSDATE,
                       p_key => in_esn || in_login_name,
                       p_program_name => 'get_esn_web_user',
                       P_ERROR_TEXT => OUT_ERR_MSG);

END get_esn_web_user;
---
PROCEDURE b2b_err_log_proc(in_rec err_rec,
                          out_code  out number,
                          out_msg   out varchar2)
AS
l_objid number;
 l_clob  clob;
BEGIN
 l_objid := sequ_b2b_err_log.nextval;

insert into x_b2b_services_err_log(objid ,
            x_client_TransactionID ,
            x_clientID    ,
            x_error_Code,
            x_error_Message ,
            x_server_TransactionID ,
            x_code ,
            x_subCode ,
            x_isRetriable  ,
            x_summary,
            x_MESSAGE ,
            x_payload ,
            x_core_Fault ,
            x_causedBy  ,
            x_brand_Name ,
            x_source_System ,
            x_instanceID  ,
            x_instance_Name ,
            x_conversationID  ,
            x_failure_TimeStamp ,
            x_failure_Source  ,
            x_failure_Target ,
            x_operation_Name  ,
            x_process_Name ,
            x_error_Type ,
            x_comments ,
            x_segment1 ,
            x_segment2,
            x_segment3,
            x_segment4)
    values( l_objid  ,
           in_rec.x_client_TransactionID ,
           in_rec.x_clientID    ,
           in_rec.x_error_Code,
           in_rec.x_error_Message ,
           in_rec.x_server_TransactionID ,
           in_rec.x_code ,
           in_rec.x_subCode ,
           in_rec.x_isRetriable  ,
           in_rec.x_summary,
           in_rec.x_MESSAGE ,
           empty_clob(), --in_rec.x_payload ,
           in_rec.x_core_Fault ,
           in_rec.x_causedBy  ,
           in_rec.x_brand_Name ,
           in_rec.x_source_System ,
           in_rec.x_instanceID  ,
           in_rec.x_instance_Name ,
           in_rec.x_conversationID  ,
           in_rec.x_failure_TimeStamp ,
           in_rec.x_failure_Source  ,
           in_rec.x_failure_Target ,
           in_rec.x_operation_Name  ,
           in_rec.x_process_Name ,
           in_rec.x_error_Type ,
           in_rec.x_comments ,
           in_rec.x_segment1 ,
           in_rec.x_segment2,
           in_rec.x_segment3,
           in_rec.x_segment4); --returning in_rec.x_payload into l_clob;

    begin
    UPDATE x_b2b_services_err_log
       SET x_payload  = in_rec.x_payload --l_clob
       WHERE objid    = l_objid ;
     exception
    when others then
      out_code := -1;
      out_msg := 'X_payload value Not Populated';
      return;
    end;

  out_code := 0;
  out_msg := 'Success';
exception
when others then
  out_code := -1;
  out_msg := 'Insert Not Done';
  rollback;
 TOSS_UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => 'SOA_ERR_LOG',
                                     IP_KEY =>in_rec.x_error_Message,
                                     IP_PROGRAM_NAME => 'b2b_err_log_proc',
                                     iP_ERROR_TEXT => out_msg);
END b2b_err_log_proc;
END B2B_PKG;
/