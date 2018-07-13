CREATE OR REPLACE PACKAGE sa.AGENT_MGT AS

PROCEDURE authenticate_agent
            (ip_login_id IN VARCHAR2,
             ip_password IN VARCHAR2,
             op_role OUT VARCHAR2);

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
             op_typ_varchar2_array  out   sa.TYP_VARCHAR2_ARRAY);


PROCEDURE change_password
           (ip_login_id IN VARCHAR2,
            ip_password IN VARCHAR2,
            op_is_successful OUT number);

PROCEDURE initiate_password_reset
           (ip_login_id IN VARCHAR2,
            ip_hash IN VARCHAR2,
            op_is_successful OUT number);

PROCEDURE confirm_password_reset
           (ip_secret_code IN VARCHAR2,
            ip_login_id IN OUT VARCHAR2,
            op_is_valid OUT NUMBER);

PROCEDURE get_spiff_details
           (ip_login_id IN VARCHAR2,
             op_spiff_code out varchar2,
             op_spiff_date out date,
             op_epay_id  out varchar2,
             op_epay_status out varchar2,
             op_epay_last_update_date out date);

PROCEDURE update_call_trans
          (ip_call_trans_objid in number,
           ip_login_name in varchar2 ,
           op_error_code out number,
           op_error_msg out varchar2);

procedure validate_password_reset
          (ip_login_id   in varchar2,
           ip_spiff_info in varchar2,
           ip_epay_id  in varchar2,
           op_is_successful out number );

PROCEDURE DEALER_TRANSACTION_CODE_VALID
(IN_SPIFF_CODE VARCHAR2, V_STATUS OUT INTEGER, V_STATUS_MSG OUT VARCHAR2, V_DEALER_OBJID OUT INTEGER);

  PROCEDURE SP_INSERT_USER_BRAND_ENABLE
    (
      IP_USER_OBJID                   IN    sa.X_UDP_USER_BRAND_ENABLE.X_USER_OBJID%TYPE
      , IP_BUS_ORG_OBJID              IN    sa.X_UDP_USER_BRAND_ENABLE.X_BUS_ORG_OBJID%TYPE
      , IP_FLAG_ENABLE                IN    sa.X_UDP_USER_BRAND_ENABLE.X_FLAG_ENABLE%TYPE
      , IP_IDN_USER_CREATED           IN    sa.X_UDP_USER_BRAND_ENABLE.X_IDN_USER_CREATED%TYPE
      , OP_OBJID                      OUT   sa.X_UDP_USER_BRAND_ENABLE.OBJID%TYPE
      , OP_STATUS_NUM                 OUT NUMBER
      , OP_STATUS_MESSAGE             OUT VARCHAR2
    );
  PROCEDURE SP_UPDATE_USER_BRAND_ENABLE
    ( IP_OBJID                      IN    sa.X_UDP_USER_BRAND_ENABLE.OBJID%TYPE
      , IP_USER_OBJID               IN    sa.X_UDP_USER_BRAND_ENABLE.X_USER_OBJID%TYPE
      , IP_BUS_ORG_OBJID            IN    sa.X_UDP_USER_BRAND_ENABLE.X_BUS_ORG_OBJID%TYPE
      , IP_FLAG_ENABLE              IN    sa.X_UDP_USER_BRAND_ENABLE.X_FLAG_ENABLE%TYPE
      , IP_IDN_USER_CHANGE_LAST     IN    sa.X_UDP_USER_BRAND_ENABLE.X_IDN_USER_CHANGE_LAST%TYPE
      , OP_STATUS_NUM               OUT   NUMBER
      , OP_STATUS_MESSAGE           OUT   VARCHAR2
    );
  PROCEDURE SP_MODIFY_BRAND_VISIBLE_2_USER
    (
      IP_S_LOGIN_NAME               IN    sa.TABLE_USER.S_LOGIN_NAME%TYPE
      , IP_S_ORG_ID                 IN    sa.TABLE_BUS_ORG.S_ORG_ID%TYPE
      , IP_FLAG_ENABLE              IN    sa.X_UDP_USER_BRAND_ENABLE.X_FLAG_ENABLE%TYPE
      , IP_IDN_USER_CHANGE_LAST     IN    sa.X_UDP_USER_BRAND_ENABLE.X_IDN_USER_CHANGE_LAST%TYPE
      , OP_OBJID                    OUT   sa.X_UDP_USER_BRAND_ENABLE.OBJID%TYPE
      , OP_STATUS_NUM               OUT NUMBER
      , OP_STATUS_MESSAGE           OUT VARCHAR2
    ) ;
END AGENT_MGT;
/