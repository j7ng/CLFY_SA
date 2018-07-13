CREATE OR REPLACE PACKAGE BODY sa.web_account_pkg as
  function UpdateAccountProfile(
p_web_user_objid                      in number,
p_PASSWORD                            in    VARCHAR2,
p_X_SECRET_QUESTN                      in   VARCHAR2,
p_X_SECRET_ANS                         in   VARCHAR2,
p_FIRST_NAME                           in   VARCHAR2,
p_LAST_NAME                            in    VARCHAR2,
p_E_MAIL                                in   VARCHAR2 ,
p_PHONE                                 in   VARCHAR2  ,
p_X_DATEOFBIRTH                        in    DATE       ,
p_X_PIN                               in     VARCHAR2    ,
p_X_PRERECORDED_CONSENT               in     NUMBER      ,
p_X_DO_NOT_MOBILE_ADS                  in    NUMBER      ,
p_X_ESN_NICK_NAME                     in     VARCHAR2    ,
p_ADDRESS                             in     VARCHAR2    ,
p_ADDRESS_2                           in     VARCHAR2    ,
p_CITY                                 in    VARCHAR2    ,
p_STATE                               in     VARCHAR2    ,
p_ZIPCODE                             in     VARCHAR2    ,
p_SHIP_ADDRESS                      in     VARCHAR2    ,
p_SHIP_ADDRESS_2                      in     VARCHAR2    ,
p_SHIP_CITY                           in   VARCHAR2    ,
p_SHIP_STATE                         in    VARCHAR2    ,
p_SHIP_ZIPCODE                          in   VARCHAR2) return varchar2 is
   pragma autonomous_transaction;
   cursor contact_curs is
     select wu.web_user2contact objid
       from table_web_user wu
      where objid = p_web_user_objid;
   contact_rec contact_curs%rowtype;
 begin
   open contact_curs;
     fetch contact_curs into contact_rec;
     if contact_curs%notfound then
       close contact_curs;
       return 'failure';
     end if;
  close contact_curs;
  if p_PASSWORD is not null then
    update table_web_user wu
      set password = p_password
    where objid = p_web_user_objid;
  end if;
  if p_X_SECRET_QUESTN is not null then
    update table_web_user wu
      set X_SECRET_QUESTN = p_X_SECRET_QUESTN
    where objid = p_web_user_objid;
  end if;
  if p_X_SECRET_ANS is not null then
    update table_web_user wu
      set X_SECRET_ANS = p_X_SECRET_ANS
    where objid = p_web_user_objid;
  end if;
  if p_FIRST_NAME is not null then
    update table_contact c
      set FIRST_NAME = p_FIRST_NAME,
          S_FIRST_NAME = upper(p_FIRST_NAME)
    where objid = contact_rec.objid;
  end if;
  if p_LAST_NAME is not null then
    update table_contact c
      set LAST_NAME = p_LAST_NAME,
          S_LAST_NAME = upper(p_LAST_NAME)
    where objid = contact_rec.objid;
  end if;
  if p_E_MAIL  is not null then
    update table_web_user wu
      set login_name = p_e_mail,
          s_login_name = upper(p_e_mail)
    where objid = p_web_user_objid;
    update table_contact c
      set E_MAIL  = p_E_MAIL
    where objid = contact_rec.objid;
  end if;
  if p_PHONE is not null then
    update table_contact c
      set PHONE = p_PHONE
    where objid = contact_rec.objid;
  end if;
  if p_X_DATEOFBIRTH is not null then
    update Table_X_Contact_add_info ai
      set X_DATEOFBIRTH = p_X_DATEOFBIRTH
    where ai.add_info2contact = contact_rec.objid;
  end if;
  if p_X_PIN is not null then
    update Table_X_Contact_add_info ai
      set X_PIN = p_X_PIN
    where ai.add_info2contact = contact_rec.objid;
  end if;
  if p_X_PRERECORDED_CONSENT is not null then
    update Table_X_Contact_add_info ai
      set X_PRERECORDED_CONSENT = p_X_PRERECORDED_CONSENT
    where ai.add_info2contact = contact_rec.objid;
  end if;
  if p_X_DO_NOT_MOBILE_ADS is not null then
    update Table_X_Contact_add_info ai
      set X_DO_NOT_MOBILE_ADS = p_X_DO_NOT_MOBILE_ADS
    where ai.add_info2contact = contact_rec.objid;
  end if;
  if p_X_ESN_NICK_NAME is not null then
    update table_x_contact_part_inst cpi
      set X_ESN_NICK_NAME = p_X_ESN_NICK_NAME
    where cpi.x_contact_part_inst2contact = contact_rec.objid
      and cpi.x_is_default = 1;
  end if;
  if p_ADDRESS is not null then
    update table_address a
      set a.ADDRESS = p_ADDRESS,
          a.s_address = upper(p_address)
    where a.objid = (select s.CUST_PRIMADDR2ADDRESS
                     from table_contact_role cr
                         ,table_site s
                    where 1=1
                    and cr.contact_role2contact         = contact_rec.objid
                    and s.objid                         = cr.contact_role2site);
  end if;
  if p_ADDRESS_2 is not null then
    update table_address a
      set a.ADDRESS_2 = p_ADDRESS_2
    where a.objid = (select s.CUST_PRIMADDR2ADDRESS
                     from table_contact_role cr
                         ,table_site s
                    where 1=1
                    and cr.contact_role2contact         = contact_rec.objid
                    and s.objid                         = cr.contact_role2site);
  end if;
  if p_CITY is not null then
    update table_address a
      set a.CITY = p_CITY,
          a.s_CITY = upper(p_CITY)
    where a.objid = (select s.CUST_PRIMADDR2ADDRESS
                     from table_contact_role cr
                         ,table_site s
                    where 1=1
                    and cr.contact_role2contact         = contact_rec.objid
                    and s.objid                         = cr.contact_role2site);
  end if;
  if p_STATE is not null then
    update table_address a
      set a.STATE = p_STATE,
          a.s_STATE = upper(p_STATE)
    where a.objid = (select s.CUST_PRIMADDR2ADDRESS
                     from table_contact_role cr
                         ,table_site s
                    where 1=1
                    and cr.contact_role2contact         = contact_rec.objid
                    and s.objid                         = cr.contact_role2site);
  end if;
  if p_ZIPCODE is not null then
    update table_address a
      set a.ZIPCODE = p_ZIPCODE
    where a.objid = (select s.CUST_PRIMADDR2ADDRESS
                     from table_contact_role cr
                         ,table_site s
                    where 1=1
                    and cr.contact_role2contact         = contact_rec.objid
                    and s.objid                         = cr.contact_role2site);
 end if;
  if p_ship_ADDRESS is not null then
    update table_address a
      set a.ADDRESS = p_ship_ADDRESS,
          a.s_address = upper(p_ship_address)
    where a.objid = (select s.CUST_shipADDR2ADDRESS
                     from table_contact_role cr
                         ,table_site s
                    where 1=1
                    and cr.contact_role2contact         = contact_rec.objid
                    and s.objid                         = cr.contact_role2site);
  end if;
  if p_ship_ADDRESS_2 is not null then
    update table_address a
      set a.ADDRESS_2 = p_ship_ADDRESS_2
    where a.objid = (select s.CUST_shipADDR2ADDRESS
                     from table_contact_role cr
                         ,table_site s
                    where 1=1
                    and cr.contact_role2contact         = contact_rec.objid
                    and s.objid                         = cr.contact_role2site);
  end if;
  if p_ship_CITY is not null then
    update table_address a
      set a.CITY = p_ship_CITY,
          a.s_CITY = upper(p_ship_CITY)
    where a.objid = (select s.CUST_shipADDR2ADDRESS
                     from table_contact_role cr
                         ,table_site s
                    where 1=1
                    and cr.contact_role2contact         = contact_rec.objid
                    and s.objid                         = cr.contact_role2site);
  end if;
  if p_ship_STATE is not null then
    update table_address a
      set a.STATE = p_ship_STATE,
          a.s_STATE = upper(p_ship_STATE)
    where a.objid = (select s.CUST_shipADDR2ADDRESS
                     from table_contact_role cr
                         ,table_site s
                    where 1=1
                    and cr.contact_role2contact         = contact_rec.objid
                    and s.objid                         = cr.contact_role2site);
  end if;
  if p_ship_ZIPCODE is not null then
    update table_address a
      set a.ZIPCODE = p_ship_ZIPCODE
    where a.objid = (select s.CUST_shipADDR2ADDRESS
                     from table_contact_role cr
                         ,table_site s
                    where 1=1
                    and cr.contact_role2contact         = contact_rec.objid
                    and s.objid                         = cr.contact_role2site);
 end if;
 commit;
   return 'success';
  exception when others then
  rollback;
   return 'failure';
 end;
 function UpdateCreditCard(
p_web_user_OBJID                       in   NUMBER,
p_PAYMENT_SOURCE_OBJID                 in   NUMBER,
p_X_IS_DEFAULT                         in   NUMBER,
p_X_CUSTOMER_CC_EXPMO                  in   VARCHAR2,
p_X_CUSTOMER_CC_EXPYR                  in   VARCHAR2,
p_X_CUSTOMER_FIRSTNAME                 in   VARCHAR2,
p_X_CUSTOMER_LASTNAME                  in   VARCHAR2,
P_X_PYMT_SRC_NAME                     IN  sa.X_PAYMENT_SOURCE.X_PYMT_SRC_NAME%TYPE,
p_ADDRESS                            in   VARCHAR2,
p_ADDRESS_2                            in   VARCHAR2,
p_CITY                               in   VARCHAR2,
p_STATE                              in   VARCHAR2,
p_ZIPCODE                              in   VARCHAR2,
p_country                              in varchar2) return varchar2 is
   pragma autonomous_transaction;
   cursor cc_curs is
     select cc.X_CREDIT_CARD2ADDRESS,
            cc.objid
       from x_payment_source ps,
            table_x_credit_card cc
      where ps.objid = p_payment_source_objid
        and ps.PYMT_SRC2WEB_USER = p_web_user_objid
        and cc.objid = PYMT_SRC2X_CREDIT_CARD;
  cc_rec cc_curs%rowtype;
 begin
   open cc_curs;
     fetch cc_curs into cc_rec;
     if cc_curs%notfound then
       close cc_curs;
       return 'failure';
     end if;
   CLOSE cc_curs;
   if p_X_IS_DEFAULT is not null then
     update x_payment_source ps
       set X_IS_DEFAULT = p_X_IS_DEFAULT
      WHERE objid = p_payment_source_objid;
  -- CR35913 Added IF condition to the update statement below
  -- update default flag to 0 for other payment sources, only if the current payment source is the default one
     IF p_X_IS_DEFAULT  = 1 THEN
       update x_payment_source ps
         set X_IS_DEFAULT = 0
        where ps.objid != p_payment_source_objid
          AND ps.PYMT_SRC2WEB_USER = p_web_user_objid;
     END IF; -- CR35913 ends
   end if;
   IF P_X_PYMT_SRC_NAME IS NOT NULL THEN
      update x_payment_source ps
       set X_PYMT_SRC_NAME = P_X_PYMT_SRC_NAME
      where objid = p_payment_source_objid;
   END IF;
   if p_X_CUSTOMER_CC_EXPMO is not null then
     update table_x_credit_card cc
       set X_CUSTOMER_CC_EXPMO = p_X_CUSTOMER_CC_EXPMO
      where objid = cc_rec.objid;
   end if;
   if p_X_CUSTOMER_CC_EXPYR is not null then
     update table_x_credit_card cc
       set X_CUSTOMER_CC_EXPYR = p_X_CUSTOMER_CC_EXPYR
      where objid = cc_rec.objid;
   end if;
   if p_X_CUSTOMER_FIRSTNAME is not null then
     update table_x_credit_card cc
       set X_CUSTOMER_FIRSTNAME = p_X_CUSTOMER_FIRSTNAME
      where objid = cc_rec.objid;
   end if;
   if p_X_CUSTOMER_LASTNAME is not null then
     update table_x_credit_card cc
       set X_CUSTOMER_LASTNAME = p_X_CUSTOMER_LASTNAME
      where objid = cc_rec.objid;
   end if;
   if p_ADDRESS is not null then
    update table_address a
      set a.ADDRESS = p_ADDRESS,
          a.s_address = upper(p_address)
    where a.objid = cc_rec.X_CREDIT_CARD2ADDRESS;
  end if;
  if p_ADDRESS_2 is not null then
    update table_address a
      set a.ADDRESS_2 = p_ADDRESS_2
    where a.objid = cc_rec.X_CREDIT_CARD2ADDRESS;
  end if;
  if p_CITY is not null then
    update table_address a
      set a.CITY = p_CITY,
          a.s_CITY = upper(p_CITY)
    where a.objid = cc_rec.X_CREDIT_CARD2ADDRESS;
  end if;
  if p_STATE is not null then
    update table_address a
      set a.STATE = p_STATE,
          a.s_STATE = upper(p_STATE)
    where a.objid = cc_rec.X_CREDIT_CARD2ADDRESS;
  end if;
  if p_ZIPCODE is not null then
    update table_address a
      set a.ZIPCODE = p_ZIPCODE
    where a.objid = cc_rec.X_CREDIT_CARD2ADDRESS;
 end if;
  if p_country is not null then
    update table_address a
      set a.ADDRESS2COUNTRY = (select objid from table_country where s_name = upper(p_country)) --,a.ADDRESS2COUNTRY)
    where a.objid = cc_rec.X_CREDIT_CARD2ADDRESS;
 end if;
 commit;
   return 'success';
  exception when others then
  rollback;
    return 'failure';
 end;
END;
/