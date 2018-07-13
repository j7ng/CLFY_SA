CREATE OR REPLACE PACKAGE sa.ADFCRM_SUI_VO
AS
  --********************************************************************************************************************
  TYPE GET_CLARIFY_REC
  IS RECORD (
             ATTRIBUTE_OBJID VARCHAR2(50),
             ATTRIBUTE_VALUE VARCHAR2(4000)
             );

  TYPE GET_CLARIFY_TAB
  IS
  TABLE OF GET_CLARIFY_REC;
  ------------------------------------------------------------------------------
  type validate_features_rec
  is record (
             fea_value varchar2(4000),
             is_valid varchar2(50)
             );

  type validate_features_tab is table of validate_features_rec;
  ------------------------------------------------------------------------------
  FUNCTION ENABLE_ACTION_BUTTON (
                                  ip_rule_objid NUMBER,
                                  ip_action_objid NUMBER,
                                  ip_esn varchar2,
                                  ip_transaction_id number default null
                                  )
  RETURN VARCHAR2;
  ------------------------------------------------------------------------------
  function get_carrier_feature_objid(ip_transaction_id varchar2)
  return varchar2;
  ------------------------------------------------------------------------------
  function get_validate_features(ip_transaction_id in varchar2,ip_carrier_feature_objid in varchar2 default null)
  return validate_features_tab pipelined;
  ------------------------------------------------------------------------------
  type sui_inquiry_rec
  is record (
             ATTR_OBJID         sa.ADFCRM_SUI_ATTRIBUTES.ATTR_OBJID%type,
             ATTR_NAME          sa.ADFCRM_SUI_ATTRIBUTES.ATTR_NAME%type,
             DISPLAY_LABEL      sa.ADFCRM_SUI_ATTRIBUTES.DISPLAY_LABEL%type,
             CLARIFY_VALUE      varchar2(4000),
             PARENT_ATTR_ID     sa.ADFCRM_SUI_ATTRIBUTES.PARENT_ATTR_ID%type,
             DISPLAY_SEQUENCE   sa.ADFCRM_SUI_ATTR_MTM.DISPLAY_SEQUENCE%type,
             WINNER             sa.ADFCRM_SUI_ATTR_MTM.WINNER%type,
             CARRIER_VALUE      varchar2(4000),
             CARRIER_VALUE_ADDL varchar2(4000),
             CHILD_COUNT        varchar2(30),
             CHECK_DIFFERENCES  varchar2(30)
             );

  type sui_inquiry_tab is table of sui_inquiry_rec;
  ------------------------------------------------------------------------------
  function get_sui_inquiry(ip_esn varchar2, ip_rule_objid varchar2, ip_transaction_id varchar2)
  return sui_inquiry_tab pipelined;
  ------------------------------------------------------------------------------
  function ret_sui_status_msg(ip_transaction_id varchar2)
  return varchar2;
  ------------------------------------------------------------------------------
  FUNCTION GET_PC_SCRIPT_TECH(IP_ESN IN VARCHAR2)
    RETURN GET_CLARIFY_TAB PIPELINED;
  --********************************************************************************************************************
  FUNCTION GET_CLARIFY_PROFILE(
      IP_PART_SERIAL_NO IN VARCHAR2,
      IP_RULE_OBJID     IN VARCHAR2,
      ip_transaction_id in varchar2)
    RETURN GET_CLARIFY_TAB PIPELINED;
  --********************************************************************************************************************
  PROCEDURE GET_CARRIER_INFO(
      IP_PART_SERIAL_NO IN VARCHAR2,
      IP_MIN            IN VARCHAR2,
      IP_CASE_ID        IN VARCHAR2,
      ESN OUT VARCHAR2,
      CARRIER_NAME OUT VARCHAR2,
      CARRIER_MARKET_NAME OUT VARCHAR2,
      CARRIER_ID OUT VARCHAR2,-- NEW OUT PARAM
      RULE_OBJID OUT VARCHAR2,
      ERR_NUM OUT VARCHAR2,
      ERR_MESSAGE OUT VARCHAR2);

  --********************************************************************************************************************
--    I DON'T SEE THIS FUNCTION CALLED ANYWHERE IN TAS
--    FUNCTION GET_CARRIER_PROFILE(
--      IP_TRANSACTION_ID IN VARCHAR2)
--    RETURN GET_CLARIFY_TAB PIPELINED;

--    I DON'T SEE THIS FUNCTION CALLED ANYWHERE IN TAS
--    PROCEDURE VERIFY_SUI_TRANSACTION(
--      IP_TRANSACTION_ID IN VARCHAR2,
--      OP_TRANSACTION_ID OUT VARCHAR2,
--      ERR_NUM OUT VARCHAR2,
--      ERR_MESSAGE OUT VARCHAR2);

END ADFCRM_SUI_VO;
/