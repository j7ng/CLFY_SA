CREATE OR REPLACE PACKAGE sa."ADFCRM_BOGO_PKG" AS

  type get_bogo_rec is record
      (x_BRAND X_BOGO_CONFIGURATION.brand%type,
    x_BOGO_PART_NUMBER X_BOGO_CONFIGURATION.brand%type,
    x_CARD_PIN_PART_CLASS X_BOGO_CONFIGURATION.brand%type,
    x_ESN_PART_CLASS X_BOGO_CONFIGURATION.brand%type,
    x_ESN_PART_NUMBER X_BOGO_CONFIGURATION.brand%type,
    x_ESN_DEALER_ID X_BOGO_CONFIGURATION.brand%type,
    x_ESN_DEALER_NAME X_BOGO_CONFIGURATION.brand%type,
    x_ELIGIBLE_SERVICE_PLAN varchar2(20000),
    x_CHANNEL X_BOGO_CONFIGURATION.brand%type,
    x_ACTION_TYPE X_BOGO_CONFIGURATION.brand%type,
    x_MSG_SCRIPT_ID X_BOGO_CONFIGURATION.brand%type,
    x_BOGO_START_DATE date,
    x_BOGO_END_DATE date,
    x_APPL_EXECUTION_ID varchar2(1000),
    x_BOGO_STATUS X_BOGO_CONFIGURATION.brand%type,
    x_CREATED_BY varchar2(100),
    x_CREATED_DATE date,
    x_UPDATED_BY varchar2(100),
    x_UPDATED_DATE date);

  type get_bogo_rec_tab is table of get_bogo_rec;

  function get_bogopromotions_func(
    ip_part_class in varchar2,
    ip_part_number in varchar2,
	ip_bogo_part_number in varchar2)
  return get_bogo_rec_tab pipelined;

END ADFCRM_BOGO_PKG;
/