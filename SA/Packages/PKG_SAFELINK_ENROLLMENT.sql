CREATE OR REPLACE PACKAGE sa.pkg_safelink_enrollment
IS
/***************************************************************************************************************
**********************
  * $Revision: 1.5 $
  * $Author: mshah $
  * $Date: 2017/03/17 19:03:51 $
  * $Log: pkg_safelink_enrollment.sql,v $
  * Revision 1.5  2017/03/17 19:03:51  mshah
  * CR43944 - Optimize Safelink Inbound - Special characters handled
  *
  * Revision 1.4  2017/03/16 21:23:29  mshah
  * CR43944 - Optimize Safelink Inbound - Special characters handled
  *
  * Revision 1.3  2017/03/02 20:14:30  mshah
  * CR43944 - Optimize Safelink Inbound
  *
  * Revision 1.2  2017/02/22 21:24:57  mshah
  * CR43944 - Optimize Safelink Inbound
  *
  * Revision 1.1  2017/02/13 20:35:34  mshah
  * CR43944 - Optimize Safelink Inbound
  *
  *
  *************************************************************************************************************************************/
 CURSOR vmbc_record_c(p_lid VARCHAR2, p_job_data_id VARCHAR2)
 IS
  SELECT  requestType,
          enrollRequest,
          state,
          TRIM(REGEXP_REPLACE(name,'[^a-zA-Z ''-]')) AS name,
          TO_DATE('1970-01-01', 'yyyy-mm-dd') AS dob,
          lid,
          SUBSTR(zip,1,5) ZIP,
          city,
          --REGEXP_REPLACE(REPLACE(address, SUBSTR(address,DECODE(INSTR(UPPER(address), 'BOX'),0,1000, INSTR(UPPER(address), 'BOX')),3),'B0X'), '[^a-zA-Z0-9 ''#-]') address, -- BOX is replace by B0X (zero) as this was present in old logic
          REGEXP_REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(address,'BOX','B0X'),'BOx','B0X'),'BoX','B0X'),'Box','B0X'),'bOX','B0X'),'bOx','B0X'),'boX','B0X'),'box','B0X'), '[^a-zA-Z0-9 ''#-]') as address, -- BOX is replace by B0X (zero) as this was present in old logic
          REGEXP_REPLACE(address2, '[^a-zA-Z0-9 ''#-]') address2,
          country,
          homeNumber,
          channelType,
          (
           CASE
           WHEN qualifyStatus = 'L'
           THEN 'D20'
           ELSE NULL
           END
          ) AS deenrollReason,
          '00000000' AS ssn,
          email,
          allowPrerecorded,
          emailPref,
          'Lifeline - '|| state || ' - '|| plan AS plan,
          DECODE(UPPER(enrollrequest),'E', esn, NULL) esn,
          'VMBC' AS src_origin,
          external_account,
          REGEXP_REPLACE(ref_fname,'[^a-zA-Z ''-]') as ref_fname,
          REGEXP_REPLACE(ref_lname,'[^a-zA-Z ''-]') as ref_lname,
          ref_lid,
          ref_min,
          ref_status,
          x_campaign,
          x_promotion,
          x_promocode,
          REGEXP_REPLACE(x_shp_address, '[^a-zA-Z0-9 ''#-]') as x_shp_address,
          REGEXP_REPLACE(x_shp_address2, '[^a-zA-Z0-9 ''#-]') as x_shp_address2,
          x_shp_city,
          x_shp_state,
          SUBSTR(x_shp_zip,1,5) x_shp_zip,
          addressIsCommercial,
          addressIsDuplicated,
          addressIsInvalid,
          addressIsTemporary,
          stateIdName,
          stateIdValue,
          adl,
          usacForm,
          cellTelephone,
          eligibleFirstName,
          eligibleLastName,
          eligibleMiddleNameInitial,
          hasPromotionalPlan,
          hmoDisclaimer,
          ipAddress,
          personId,
          personIsInvalid,
          shippingAddressHash,
          stateAgencyQualification,
          transferFlag,
          old_lid,
          status,
          lastModified,
          dobIsInvalid,
          ssnIsInvalid,
          disableManualVerification,
          qualifyType,
          qualifyPrograms,
          registrationLanguage,
          TO_DATE(qualifyDate,'YYYY-MM-DD HH24:MI:SS') AS qualifyDate,
          device_type,
          byop_device_state,
          byop_carrier,
          byop_sim,
          byop_esn,
          byop_act_zip,
          data_source,
          job_data_id
  FROM   sa.xsu_vmbc_request
  WHERE  lid          = p_lid
  AND    job_data_id  = p_job_data_id
  AND    ROWNUM       < 2;

 v_vmbc_record    vmbc_record_c%ROWTYPE;


 PROCEDURE p_process_enroll_job
 (
   p_lid                IN  VARCHAR,
   p_job_data_id        IN  VARCHAR,
   p_email_id           IN  table_web_user.login_name%TYPE,
   p_password           IN  table_web_user.password%TYPE,
   o_brand_name         OUT table_bus_org.org_id%TYPE,
   o_enroll_flag        OUT VARCHAR2,
   o_contact_objid      OUT NUMBER,
   o_web_user_objid     OUT NUMBER,
   o_id_number          OUT VARCHAR2,
   o_error_num          OUT NUMBER,
   o_error_string       OUT VARCHAR2
 );

 PROCEDURE p_pre_enroll_validation
 (
  o_brand_name         OUT table_bus_org.org_id%TYPE,
  o_return_flag        OUT NUMBER,
  o_error_num          OUT NUMBER,
  o_error_string       OUT VARCHAR2
 );

 PROCEDURE p_ins_sl_subs
 (
  o_enroll_flag        OUT VARCHAR2,
  o_enrolled_count     OUT NUMBER,
  o_error_num          OUT NUMBER,
  o_error_string       OUT VARCHAR2
 );

 PROCEDURE p_create_account
 (
  p_email_id           IN  table_web_user.login_name%TYPE,
  p_password           IN  table_web_user.password%TYPE,
  p_brand_name         IN table_bus_org.org_id%TYPE,
  o_contact_objid      OUT NUMBER,
  o_web_user_objid     OUT NUMBER,
  o_error_num          OUT NUMBER,
  o_error_string       OUT VARCHAR2
 );

 PROCEDURE p_create_case
 (
  p_email_id           IN  table_web_user.login_name%TYPE,
  p_brand_name         IN  table_bus_org.org_id%TYPE,
  p_contact_objid      IN NUMBER,
  p_web_user_objid     IN NUMBER,
  o_id_number          OUT VARCHAR2,
  o_error_num          OUT NUMBER,
  o_error_string       OUT VARCHAR2
 );

 PROCEDURE p_ins_sl_hist
 (
  p_current_esn        IN  sa.x_sl_currentvals.x_current_esn%TYPE,
  p_table_source       IN  sa.x_sl_hist.x_src_table%TYPE,
  p_event_value        IN  sa.x_sl_hist.x_event_value%TYPE,
  p_event_code         IN  sa.x_sl_hist.x_event_code%TYPE,
  p_event_data         IN  sa.x_sl_hist.x_event_data%TYPE,
  o_error_num          OUT NUMBER,
  o_error_string       OUT VARCHAR2
 );

 PROCEDURE p_ins_job_err
 (
  p_req_type    IN     VARCHAR2,
  p_err_msg     IN     VARCHAR2
 );

END pkg_safelink_enrollment;
/