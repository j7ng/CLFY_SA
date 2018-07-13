CREATE OR REPLACE PACKAGE sa."VALUE_ADDEDPRG"
AS
--------------------------------------------------------------------------------------------
--$RCSfile: VALUE_ADDEDPRG_PKG.sql,v $
--$Revision: 1.19 $
--$Author: smeganathan $
--$Date: 2015/08/26 20:35:44 $
--$ $Log: VALUE_ADDEDPRG_PKG.sql,v $
--$ Revision 1.19  2015/08/26 20:35:44  smeganathan
--$ Changes for 35913 a?? My accounts - changed the comments
--$
--$ Revision 1.18  2015/08/11 19:17:34  smeganathan
--$ Changes for 35913 My accounts
--$
--$ Revision 1.17  2015/07/29 20:35:49  aganesan
--$ CR35913 - My account changes.
--$
--$ Revision 1.17  2015/07/13 10:00:00  sethiraj
--$ CR35913 - New Function Geteligiblewtyprogramsv2
--$ Modified exisiting Procedure getCurrentWarrantyProgram
--$
--$ Revision 1.16  2014/10/02 19:26:30  vkashmire
--$ CR29079 case update byop proc separated from original case update
--$
--$ Revision 1.15  2014/09/17 19:27:26  vkashmire
--$ CR29489 - getCaseUpdates_hppbyop removed
--$
--$ Revision 1.14  2014/09/15 21:31:19  vkashmire
--$ CR29489 - case update BYOP changes
--$
--$ Revision 1.13  2014/08/28 18:56:17  vkashmire
--$ CR29489 - TAS requirements
--$
--$ Revision 1.12  2014/08/25 18:11:33  vkashmire
--$ CR29489
--$
--$ Revision 1.11  2014/08/22 21:08:01  vkashmire
--$ CR29489_CR22313
--$
--$ Revision 1.10  2014/08/22 15:47:56  oarbab
--$ CR27087 to create annual renewals file
--$ CR29638 to send recurring billing part numbers instead of first enrollment
--$
--$ Revision 1.9  2014/05/30 17:46:51  mvadlapally
--$ CR28538 - Car Connection Post Rollout - merged with Prod
--$
--$ Revision 1.8  2014/03/14 21:02:29  ymillan
--$ CR26941
--$
--$ Revision 1.3  2013/01/11 16:59:52  icanavan
--$ Added X_CHARGE_FRQ_CODE type
--$
--$ Revision 1.2  2012/12/07 19:42:34  mmunoz
--$ CR22380 : Handset Protection grant execute to DQIETL_ROLE
--$
--$ Revision 1.1  2012/10/26 21:25:52  mmunoz
--$ CR22380 Handset Protection Program
--$
--------------------------------------------------------------------------------------------
  type CurrentWtyPrograms_record is record
  (prog_id        sa.x_program_parameters.objid%type,
   x_program_name sa.x_program_parameters.x_program_name%type,
   x_program_desc sa.x_program_parameters.x_program_desc%type,
   X_RETAIL_PRICE sa.TABLE_X_PRICING.X_RETAIL_PRICE%type,
   STATUS         sa.X_PROGRAM_ENROLLED.X_ENROLLMENT_STATUS%type,
   part_number    sa.TABLE_PART_NUM.PART_NUMBER%type,
   expirationDate sa.x_program_enrolled.x_exp_date%type,
   x_charge_FRQ_code sa.x_program_parameters.x_charge_frq_code%type -- CR23058 MONTHLY or 365
   /* CR29489 changes starts */
   , x_exp_date sa.x_program_enrolled.x_exp_date%type,
   /* CR29489 changes ends */
    x_enrolled_date sa.x_program_enrolled.x_enrolled_date%TYPE,
    mobile_name  table_x_mobile_info.mobile_name_script_id%TYPE,
    mobile_description table_x_mobile_info.mobile_desc_script_id%TYPE,
    mobile_more_info  table_x_mobile_info.mobile_info_script_id%TYPE,
    terms_condition_link  table_x_mobile_info.mobile_terms_condition_link%TYPE
  );

  type EligibleWtyPrograms_rec is record
  (prog_id        sa.x_program_parameters.objid%type,
   x_program_name sa.x_program_parameters.x_program_name%type,
   x_program_desc sa.x_program_parameters.x_program_desc%type,
   x_retail_price sa.table_x_pricing.x_retail_price%type,
   status         sa.x_program_enrolled.x_enrollment_status%type,
   part_number    sa.TABLE_PART_NUM.PART_NUMBER%type
  );

  TYPE ELIGIBLEWTYPROGRAMS_TAB IS TABLE OF ELIGIBLEWTYPROGRAMS_REC;
  ELIGIBLEWTYPROGRAMS_RSLT ELIGIBLEWTYPROGRAMS_REC;

  TYPE eligiblewtyprogramsv2_rec IS record
  (prog_id        sa.x_program_parameters.objid%TYPE,
   x_program_name sa.x_program_parameters.x_program_name%TYPE,
   x_program_desc sa.x_program_parameters.x_program_desc%TYPE,
   x_retail_price sa.table_x_pricing.x_retail_price%TYPE,
   status         sa.x_program_enrolled.x_enrollment_status%TYPE,
   part_number    sa.table_part_num.part_number%TYPE,
   mobile_name  table_x_mobile_info.mobile_name_script_id%TYPE,
   mobile_description table_x_mobile_info.mobile_desc_script_id%TYPE,
   mobile_more_info  table_x_mobile_info.mobile_info_script_id%TYPE,
   terms_condition_link  table_x_mobile_info.mobile_terms_condition_link%TYPE
  );

  TYPE eligiblewtyprogramsv2_tab IS TABLE OF eligiblewtyprogramsv2_rec;
  eligiblewtyprogramsv2_rslt eligiblewtyprogramsv2_rec;

   FUNCTION geteligiblewtyprogramsv2(
    ip_esn IN VARCHAR2
    )
  RETURN eligiblewtyprogramsv2_tab pipelined;

  function getEligibleWtyPrograms(
    ip_esn in varchar2
    )
  RETURN ELIGIBLEWTYPROGRAMS_TAB pipelined;

  /*  CR29489 changes starts ; 28-Aug-2014 function getEligibleWtyPrgForActivation added to support TAS */
  function getEligibleWtyPrgForActivation(
    ip_esn in varchar2
    )
  RETURN ELIGIBLEWTYPROGRAMS_TAB pipelined;
  /* CR29489 changes ends  */

  FUNCTION SEQ(
    ip_TABLE in varchar2
    )
  RETURN NUMBER;

  TYPE account_file_rec IS RECORD (
    DP_STREAM_NO                     varchar2(200),
    RECORD_TYPE                      varchar2(200),
    CLIENT_BATCH_ID                  varchar2(200),
    CONSUMER_ID_NUMBER               sa.TABLE_SITE.SITE_ID%type,
    CONSUMER_TITLE                   sa.TABLE_CONTACT.TITLE%type,
    FIRST_NAME                       sa.TABLE_CONTACT.FIRST_NAME%type,
    last_name                        sa.TABLE_CONTACT.last_name%type,
    BUSINESS_INDICATOR               varchar2(200),
    BUSINESS_DBA_NAME                varchar2(200),
    SERVICE_ADDRESS1                 sa.TABLE_CONTACT.ADDRESS_1%type,
    SERVICE_ADDRESS2                 sa.TABLE_CONTACT.ADDRESS_2%type,
    SERVICE_CITY                     sa.TABLE_CONTACT.CITY%type,
    SERVICE_STATE                    sa.TABLE_CONTACT.STATE%type,
    SERVICE_ZIP                      sa.TABLE_CONTACT.ZIPCODE%type,
    SERVICE_ZIP4                     varchar2(200),
    SERVICE_COUNTRY_CODE             sa.table_country.S_NAME%type,
    PHONE_TYPE1                      varchar2(200),
    PHONE                            sa.TABLE_SITE_PART.X_MIN%type,
    PHONE1_USAGE_TYPE                varchar2(200),
    PHONE_TYPE2                      varchar2(200),
    phone_2                          varchar2(200),
    PHONE2_USAGE_TYPE                varchar2(200),
    E_MAIL_ADDRESS                   sa.TABLE_CONTACT.E_MAIL%type,
    LANGUAGE_CODE                    varchar2(200),
    MIDDLE_INITIAL                   sa.TABLE_CONTACT.X_MIDDLE_INITIAL%type,
    DEALERID                         varchar2(200),
    CONTRACT_NUMBER                  varchar2(200),
    CONTRACT_PURCHASE_DATE           sa.X_PROGRAM_ENROLLED.X_INSERT_DATE%type,
    EQUIPMENT_PURCHASE_DATE          sa.TABLE_SITE_PART.INSTALL_DATE%type,
    PACKAGE_SEQUENCE_NUMBER          number,
    line_item                        varchar2(200),
    reporting_tag_contract1          varchar2(200),
    REPORTING_TAG_CONTRACT2          varchar2(200),
    MODEL_NUMBER                     sa.TABLE_PART_CLASS.name%type,
    SERIAL_NUMBER                    sa.TABLE_PART_INST.PART_SERIAL_NO%type,
    QUANTITY_SOLD                    varchar2(200),
    LABOR_WARR                       varchar2(200),
    PARTS_WARR                       varchar2(200),
    PRODUCT_CODE                     varchar2(200),
    MANUF_CODE                       sa.TABLE_PART_NUM.X_MANUFACTURER%type,
    SKU_NUMBER                       sa.TABLE_PART_NUM.PART_NUMBER%type,
    CONTRACT_RETAIL                  sa.X_PROGRAM_ENROLLED.X_AMOUNT%type,
    equipment_retail                 sa.TABLE_X_PRICING.x_retail_price%type,
    CANCEL_REQUEST_DATE              varchar2(200),
    UPDATE_ACTION_CODE               varchar2(200)
   );

  type account_file_TAB is table of account_file_rec;
  type annualRenew_file_TAB is table of account_file_rec; -- CR27087

  function getSalesAccountUpdates (
  --Extract all pending Handset Protection customers sales for non annual programs re-enrolment.--CR27087
  --Extract Handset Protection customers that have changed their address, email, min, name or account status
    ip_date in date
    )
  return account_file_TAB pipelined;

  -- CR27087 Begin ---
    function getAnnualRenewals (
  --Extract all pending HPP annual programs re-enrolment.--CR27087
     ip_date in date
    )
	return annualRenew_file_TAB pipelined;
  -- CR27087 End ---

  type CASE_UPDATES_FILE_REC is RECORD (
    caseTYPE             sa.X_PROGRAM_CLAIMS.X_TYPE%type,
    caseDATE             sa.TABLE_X_PART_REQUEST.X_SHIP_DATE%type,
    ESN                  sa.table_case.x_esn%type,
    NEWESN               sa.table_x_part_request.x_part_serial_no%type,
    TRACKINGNUMBER       sa.table_x_part_request.x_tracking_no%type
   );

  TYPE case_updates_file_TAB is table of case_updates_file_rec;

  function getCaseUpdates (
    ip_date in date
    )
  return case_updates_file_TAB pipelined;

  function getCaseUpdates_byop (
    ip_date in date
    )
  return case_updates_file_TAB pipelined;


  PROCEDURE getCurrentWarrantyProgram(
    ip_esn         in  varchar2,
    op_result_set  out SYS_REFCURSOR,
    op_error_code  out varchar2,
    op_error_text  out varchar2
  );

  PROCEDURE Process_ACK(
  -- Process Sales ACK file, its data has been stored in x_contract_responses
    ip_date        in  date,
    op_error_code  out varchar2,
    op_error_text  out varchar2
  );

  PROCEDURE Claim_Creation (
  -- Process Claim file, its data has been stored in x_program_claims, for each new record create case related to Handset protection
    ip_date        in  date,
    op_error_code  out varchar2,
    op_error_text  out varchar2
  );
  --CR26941
  FUNCTION is_restricted_handset (
    PP_OBJID  IN NUMBER,
    pc_objid  in number
  ) return Boolean;

  FUNCTION is_restricted_state (
    pp_objid    in number,
    ip_zipcode  in varchar2
  ) return Boolean;

  FUNCTION is_valid_status (
    PP_OBJID  IN NUMBER,
    ip_status in varchar2
  ) return Boolean;
   --CR26941
   -- Process Claim file, its data has been stored in x_device_claims, for each new record case will be created
  PROCEDURE device_claim_creation (ip_date         IN     DATE,
                                   op_error_code      OUT VARCHAR2,
                                   op_error_text      OUT VARCHAR2);
END VALUE_ADDEDPRG;
-- ANTHILL_TEST PLSQL/SA/Packages/VALUE_ADDEDPRG_PKG.sql 	CR29079: 1.16
/