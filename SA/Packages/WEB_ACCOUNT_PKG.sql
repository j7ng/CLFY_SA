CREATE OR REPLACE package sa.web_account_pkg as
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
p_SHIP_ZIPCODE                          in   VARCHAR2) return varchar2;
 function UpdateCreditCard(
p_web_user_OBJID                                in   NUMBER,
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
p_ZIPCODE                              in   VARCHAR2  ,
p_country                              in varchar2
) RETURN VARCHAR2;
end;
/