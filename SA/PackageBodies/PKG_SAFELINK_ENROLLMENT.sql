CREATE OR REPLACE PACKAGE BODY sa.pkg_safelink_enrollment
IS
/***************************************************************************************************************
**********************
  * $Revision: 1.10 $
  * $Author: mshah $
  * $Date: 2017/11/09 20:44:49 $
  * $Log: pkg_safelink_enrollment.sql,v $
  * Revision 1.10  2017/11/09 20:44:49  mshah
  * CR52506 - Safelink Field Activation Changes
  *
  * Revision 1.9  2017/10/16 16:02:38  mshah
  * CR52506 - Safelink Field Activation Changes
  *
  * Revision 1.8  2017/06/12 21:22:55  mshah
  * CR51323 - SL address line 2 dropped
  *
  * Revision 1.7  2017/04/25 18:33:05  mshah
  * CR49533 - Fix SL Inbound Job OR to AND
  *
  * Revision 1.6  2017/03/20 18:46:23  mshah
  * CR43944 - Optimize Safelink Inbound - optimize query
  *
  * Revision 1.5  2017/03/14 21:46:18  mshah
  * CR43944 - Optimize Safelink Inbound - Error message modified
  *
  * Revision 1.4  2017/03/02 20:16:37  mshah
  * CR43944 - Optimize Safelink Inbound
  *
  * Revision 1.3  2017/02/22 21:25:08  mshah
  * CR43944 - Optimize Safelink Inbound
  *
  * Revision 1.2  2017/02/14 16:39:34  mshah
  * CR43944 - Optimize Safelink Inbound
  *
  * Revision 1.1  2017/02/13 20:36:04  mshah
  * CR43944 - Optimize Safelink Inbound
  *
  *
  *************************************************************************************************************************************/
--------------------------------------------------------------------------------
/*
Functionality:   SafeLink Inbound Job
Called by:       CBO
Description:     p_process_enroll_job is the main procedure. Any subsequent calls are made from this procedure.
o_error_num:     If fails for any LID, o_error_num <> 0 else o_error_num = 0
o_error_string:  If fails for any LID, o_error_string <>  'Success' else o_error_string = 'Success'
x_job_errors:    In case of failure, errors are logged in x_job_errors table for each JOB_ID and LID.
*/
--------------------------------------------------------------------------------

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
 )
 IS
 l_brand_name           table_bus_org.org_id%TYPE;
 l_enrolled_count       NUMBER;
 l_return_flag          NUMBER := 0;
 BEGIN --{ procedure begin
 DBMS_OUTPUT.PUT_LINE('----------------------------START------------------------------');
 o_error_num          := 0;
 o_error_string       := 'Success';

 DBMS_OUTPUT.PUT_LINE('Step 1 - Populate global array for an LID and close the cursor.');

 /*First step is to populate the vmbc_record_c array with the cursor for the LID passed.
 This array will be used throughout the enrollment process for LID*/
  BEGIN --{

   OPEN  vmbc_record_c(p_lid, p_job_data_id); --{ open cursor

   FETCH vmbc_record_c
   INTO  v_vmbc_record;

   IF vmbc_record_c%NOTFOUND
   THEN --{
    o_error_num    := 100;
    o_error_string := 'Record is not eligible to process for lid ' || p_lid;

    p_ins_job_err
              (
               'SLENROLL',
               o_error_string
              );
    CLOSE vmbc_record_c;
    RETURN;
   END IF; --}

   CLOSE vmbc_record_c; --} close cursor.

  EXCEPTION
   WHEN OTHERS THEN
    o_error_num    := 105;
    o_error_string := 'Error in cursor vmbc_record_c for p_lid '||p_lid||' '||SUBSTR(SQLERRM, 1, 100);
    p_ins_job_err
              (
               'SLENROLL',
               o_error_string
              );
    RETURN;
  END; --}

  DBMS_OUTPUT.PUT_LINE('Step 2 - Perform basic validations.');

  BEGIN --{
   p_pre_enroll_validation
                         (
                          o_brand_name,
                          l_return_flag,
                          o_error_num,
                          o_error_string
                         );
   EXCEPTION
   WHEN OTHERS THEN
    o_error_num    := 110;
    o_error_string := 'Error in p_pre_enroll_validation for p_lid '||p_lid||' '||SUBSTR(SQLERRM, 1, 100);
    p_ins_job_err
              (
               'SLENROLL',
               o_error_string
              );
    RETURN;
   END; --}

   --Return if pre enrollment validation fails
   IF l_return_flag > 0
   THEN --{
    RETURN;
   END IF; --}

  DBMS_OUTPUT.PUT_LINE('Step 3 - Insert into SL SUBS.');

  BEGIN --{
   p_ins_sl_subs
                   (
                    o_enroll_flag,
                    l_enrolled_count,
                    o_error_num,
                    o_error_string
                   );
  EXCEPTION
  WHEN OTHERS THEN
   o_error_num    := 115;
   o_error_string := 'Error in call p_ins_sl_subs for p_lid '||p_lid||' '||SUBSTR(SQLERRM, 1, 100);
   p_ins_job_err
             (
              'SLENROLL',
              o_error_string
             );
   RETURN;
  END; --}

  --Return if already enrolled
  IF l_enrolled_count > 0 OR o_error_num > 0
  THEN --{
   RETURN;
  END IF; --}

  DBMS_OUTPUT.PUT_LINE('Step 4 - Create Contact and User.');

  BEGIN --{
   p_create_account
                  (
                   p_email_id,
                   p_password,
                   o_brand_name,
                   o_contact_objid,
                   o_web_user_objid,
                   o_error_num,
                   o_error_string
                  );

   --Return if fails
   IF o_error_num > 0
   THEN --{
    RETURN;
   END IF; --}

  IF o_contact_objid IS NULL OR o_web_user_objid IS NULL
  THEN --{
   o_error_num    := 116;
   o_error_string := 'Contact or User not present';
   p_ins_job_err
             (
              'SLENROLL',
              o_error_string
             );
   RETURN;
  ELSE --}{
   UPDATE x_sl_subs
   SET    sl_subs2table_contact = o_contact_objid,
          sl_subs2web_user      = o_web_user_objid
   WHERE  lid                   = v_vmbc_record.lid;
  END IF; --}

  EXCEPTION
  WHEN OTHERS THEN
   o_error_num    := 120;
   o_error_string := 'Error in call p_create_account for p_lid '||p_lid||' '||SUBSTR(SQLERRM, 1, 100);
   p_ins_job_err
             (
              'SLENROLL',
              o_error_string
             );
   RETURN;
  END; --}

  DBMS_OUTPUT.PUT_LINE('Step 5 - Create Case.');

  BEGIN --{
   p_create_case
                (
                 p_email_id,
                 l_brand_name,
                 o_contact_objid,
                 o_web_user_objid,
                 o_id_number,
                 o_error_num,
                 o_error_string
                );
  EXCEPTION
  WHEN OTHERS THEN
   o_error_num    := 125;
   o_error_string := 'Error in call p_create_case for p_lid '||p_lid||' '||SUBSTR(SQLERRM, 1, 100);
   p_ins_job_err
             (
              'SLENROLL',
              o_error_string
             );

   RETURN;
  END; --}

 v_vmbc_record := NULL; --clear
 DBMS_OUTPUT.PUT_LINE('----------------------------END------------------------------');
 END p_process_enroll_job; --}

 PROCEDURE p_pre_enroll_validation
 (
  o_brand_name         OUT table_bus_org.org_id%TYPE,
  o_return_flag        OUT NUMBER,
  o_error_num          OUT NUMBER,
  o_error_string       OUT VARCHAR2
 )
 IS
 l_brand_name           table_bus_org.org_id%TYPE;
 l_zip_state_count      NUMBER;
 l_param_value          table_x_parameters.x_param_value%TYPE;
 l_restrict_addr_cnt    NUMBER := 0;
 BEGIN --{
 o_return_flag        := 0;
 o_error_num          := 0;
 o_error_string       := 'Success';

-- Validation 1
  BEGIN --{
   SELECT tbo.org_id
   INTO   l_brand_name
   FROM   sa.x_program_parameters pp,
          sa.table_bus_org tbo
   WHERE  1=1
   AND    pp.prog_param2bus_org = tbo.objid
   AND    pp.x_program_name     = v_vmbc_record.plan;
  EXCEPTION
  WHEN OTHERS THEN
   o_error_num    := 165;
   o_error_string := 'Brand name or Program Name not found based on program name for p_lid '||v_vmbc_record.lid;

   p_ins_job_err
             (
              'SLENROLL',
              o_error_string
             );
   o_return_flag := 1;
   RETURN;
  END; --}

  o_brand_name := l_brand_name;

-- Validation 2
  BEGIN --{
   SELECT count(1)
   INTO   l_zip_state_count
   FROM   table_x_zip_code
   WHERE  x_state = v_vmbc_record.state
   AND    x_zip   = v_vmbc_record.zip;
  EXCEPTION
  WHEN OTHERS THEN
   l_zip_state_count := 0;
  END; --}

  IF l_zip_state_count = 0
  THEN --{

   o_error_num       := 170;
   o_error_string    := 'State and ZIP Code did not match.';
   p_ins_job_err
             (
              'SLENROLL',
              o_error_string
             );
   o_return_flag := 1;
   RETURN;
  END IF; --}

-- Validation 3
 BEGIN --{
  SELECT  x_param_value
  INTO    l_param_value
  FROM    table_x_parameters
  WHERE   x_param_name      = 'SL_SHIP_ADDRESS_CHECK'
  AND     ROWNUM = 1;

 EXCEPTION
  WHEN OTHERS THEN
   l_param_value := NULL;
 END; --}

 IF l_param_value = 'ZIP_ONLY' AND UPPER(v_vmbc_record.enrollrequest)    = 'S'
 THEN --{
  SELECT COUNT(1)
  INTO   l_restrict_addr_cnt
  FROM   SL_RESTRICT_SHIP_ADDRESS
  WHERE  zip = NVL(v_vmbc_record.x_shp_zip, v_vmbc_record.zip);

   IF l_restrict_addr_cnt <> 0
   THEN --{

   /*p_ins_job_err
             (
              'SLENROLL',
              o_error_string
             );     */

    INSERT INTO xsu_vmbc_response
                                (
                                responseto,
                                requestid,
                                lid,
                                enrollrequest,
                                errorcode,
                                errormsg,
                                activatedate,
                                phoneesn,
                                phonenumber,
                                trackingnumber,
                                ticketnumber,
                                batchdate,
                                data_source
                                )
                         VALUES (
                                 'Deenroll',
                                 NULL,
                                 v_vmbc_record.lid,
                                 v_vmbc_record.enrollrequest,
                                 '0',
                                 'Zip code rejected',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 SYSDATE,
                                 v_vmbc_record.data_source
                                 );
    o_return_flag := 1;
    RETURN;
   END IF; --}

 END IF; --}


 EXCEPTION
 WHEN OTHERS THEN
  o_error_num       := 175;
  o_error_string    := 'In main exception of p_pre_enroll_validation '||SUBSTR(SQLERRM, 1, 100);
  p_ins_job_err
            (
             'SLENROLL',
             o_error_string
            );
 o_return_flag := 1;
 RETURN;
 END p_pre_enroll_validation; --}

 PROCEDURE p_ins_sl_subs
 (
  o_enroll_flag        OUT VARCHAR2,
  o_enrolled_count     OUT NUMBER,
  o_error_num          OUT NUMBER,
  o_error_string       OUT VARCHAR2
 )
 IS
 l_insert_into_subdtl       VARCHAR2(10);
 l_enrolled_count           NUMBER := 0;
 l_current_esn              sa.x_sl_currentvals.x_current_esn%TYPE;
 l_requested_plan           sa.x_sl_subs.x_requested_plan%TYPE;
 l_pgm_objid                sa.x_program_enrolled.objid%TYPE;

 BEGIN --{ procedure begin
 o_error_num          := 0;
 o_error_string       := 'Success';
 l_insert_into_subdtl := 'FALSE';

    BEGIN --{

    INSERT INTO sa.x_sl_subs
                           (
                           objid,
                           lid,
                           full_name,
                           address_1,
                           address_2,
                           city,
                           state,
                           zip,
                           zip2,
                           country,
                           e_mail,
                           x_homenumber,
                           x_allow_prerecorded,
                           x_email_pref,
                           x_external_account,
                           x_requested_plan,
                           X_REFERRER,
                           x_campaign,
                           x_promotion,
                           x_promocode,
                           x_shp_address,
                           x_shp_address2,
                           x_shp_city,
                           x_shp_state,
                           x_shp_zip,
                           x_qualify_date,
                           x_device_type,
                           x_data_source
                           )
                           VALUES
                           (
                           sa.seq_x_sl_subs.NEXTVAL,
                           v_vmbc_record.lid,
                           v_vmbc_record.name,
                           v_vmbc_record.address,
                           v_vmbc_record.address2,
                           v_vmbc_record.city,
                           v_vmbc_record.state,
                           v_vmbc_record.zip,
                           NULL,
                           v_vmbc_record.country,
                           v_vmbc_record.email,
                           v_vmbc_record.homeNumber,
                           v_vmbc_record.allowPrerecorded,
                           v_vmbc_record.emailPref,
                           v_vmbc_record.external_account,
                           v_vmbc_record.plan,
                           v_vmbc_record.ref_lid,
                           v_vmbc_record.x_campaign,
                           v_vmbc_record.x_promotion,
                           v_vmbc_record.x_promocode,
                           v_vmbc_record.x_shp_address,
                           v_vmbc_record.x_shp_address2,
                           v_vmbc_record.x_shp_city,
                           v_vmbc_record.x_shp_state,
                           v_vmbc_record.x_shp_zip,
                           v_vmbc_record.qualifyDate,
                           v_vmbc_record.device_type,
                           v_vmbc_record.data_source
                           );

    l_insert_into_subdtl := 'TRUE';

    IF UPPER(v_vmbc_record.enrollrequest)    = 'S'
    THEN --{
     o_enroll_flag := 'FALSE';
    ELSIF UPPER(v_vmbc_record.enrollrequest) = 'E'
    THEN
     o_enroll_flag := 'TRUE';
    END IF; --}

   EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
    SELECT CASE WHEN COUNT(0) = 0
           THEN 'TRUE'
           ELSE 'FALSE'
           END
    INTO   l_insert_into_subdtl
    FROM   sa.x_sl_subs_dtl a
    WHERE  1     = 1
    AND    a.lid = v_vmbc_record.lid;

    SELECT COUNT(1)
    INTO   l_enrolled_count
    FROM   sa.x_sl_subs a,
           sa.x_sl_currentvals b
    WHERE  1 = 1
    AND    b.lid              = v_vmbc_record.lid
    AND    a.lid              = b.lid
    AND    a.x_data_source = 'VMBC'
    AND    (
            b.x_current_esn IS NOT NULL
            AND
            b.x_current_esn <> '-1'
            AND
            b.x_current_esn <> '0' --CR49533
            );

    IF l_enrolled_count > 0
    THEN --{
     o_enroll_flag := 'FALSE';
 /*
     SELECT b.x_current_esn,
            a.x_requested_plan,
            c.objid
     INTO   l_current_esn,
            l_requested_plan,
            l_pgm_objid
     FROM   sa.x_sl_subs a,
            sa.x_sl_currentvals b,
            sa.x_program_enrolled c
     WHERE  1                  = 1
     AND    b.lid              = v_vmbc_record.lid
     AND    a.lid              = b.lid
     AND    b.x_current_esn    = c.x_esn(+)
     AND    x_current_enrolled = 'Y';

     p_ins_sl_hist
      (
       l_current_esn,
       NULL,
       l_requested_plan, --p_event_value
       619, --p_event_code
       l_pgm_objid, --p_event_data
       o_error_num,
       o_error_string
      );

      UPDATE sa.x_sl_subs
      SET    x_requested_plan = l_requested_plan ----
      WHERE  1   = 1
      AND    lid = v_vmbc_record.lid;
   */
    ELSE -- }{

      IF UPPER(v_vmbc_record.enrollrequest)    = 'S'
      THEN --{
       o_enroll_flag := 'FALSE';
      ELSIF UPPER(v_vmbc_record.enrollrequest) = 'E'
      THEN
       o_enroll_flag := 'TRUE';
      END IF; --}

    END IF; --}

    o_enrolled_count := l_enrolled_count;

   WHEN OTHERS THEN
   o_error_num    := 155;
   o_error_string := 'Exception occured while inserting into x_sl_subs '||SUBSTR(SQLERRM, 1, 100);
   p_ins_job_err
             (
              'SLENROLL',
              o_error_string
             );
   RETURN;
   END; --}

   IF l_insert_into_subdtl = 'TRUE'
   THEN --{

   BEGIN --{
    INSERT INTO sa.x_sl_subs_dtl
                               (
                                lid,
                                x_addressiscommercial,
                                x_addressisduplicated,
                                x_addressisinvalid,
                                x_addressistemporary,
                                x_stateidname,
                                x_stateidvalue,
                                x_adl,
                                x_usacform,
                                x_celltelephone,
                                x_eligiblefirstname,
                                x_eligiblelastname,
                                x_eligiblemiddlenameinitial,
                                x_haspromotionalplan,
                                x_hmodisclaimer,
                                x_ipaddress,
                                x_personid,
                                x_personisinvalid,
                                x_shippingaddresshash,
                                x_stateagencyqualification,
                                x_transferflag,
                                x_old_lid,
                                x_status,
                                x_lastmodified,
                                x_dobisinvalid,
                                x_ssnisinvalid,
                                x_disablemanualverification,
                                x_qualify_type,
                                x_qualify_programs,
                                x_channel_type,
                                x_language,
                                x_byop_device_state,
                                x_byop_carrier,
                                x_byop_sim,
                                x_byop_esn,
                                x_byop_act_zip
                                )
                                VALUES
                                (
                                v_vmbc_record.lid,
                                v_vmbc_record.addressiscommercial,
                                v_vmbc_record.addressisduplicated,
                                v_vmbc_record.addressisinvalid,
                                v_vmbc_record.addressistemporary,
                                v_vmbc_record.stateidname,
                                v_vmbc_record.stateidvalue,
                                v_vmbc_record.adl,
                                v_vmbc_record.usacform,
                                v_vmbc_record.celltelephone,
                                v_vmbc_record.eligiblefirstname,
                                v_vmbc_record.eligiblelastname,
                                v_vmbc_record.eligiblemiddlenameinitial,
                                v_vmbc_record.haspromotionalplan,
                                v_vmbc_record.hmodisclaimer,
                                v_vmbc_record.ipaddress,
                                v_vmbc_record.personid,
                                v_vmbc_record.personisinvalid,
                                v_vmbc_record.shippingaddresshash,
                                v_vmbc_record.stateagencyqualification,
                                v_vmbc_record.transferflag,
                                v_vmbc_record.old_lid,
                                v_vmbc_record.status,
                                v_vmbc_record.lastmodified,
                                v_vmbc_record.dobisinvalid,
                                v_vmbc_record.ssnisinvalid,
                                v_vmbc_record.disablemanualverification,
                                v_vmbc_record.qualifytype,
                                v_vmbc_record.qualifyprograms,
                                v_vmbc_record.channeltype,
                                v_vmbc_record.registrationlanguage,
                                v_vmbc_record.byop_device_state,
                                v_vmbc_record.byop_carrier,
                                v_vmbc_record.byop_sim,
                                v_vmbc_record.byop_esn,
                                v_vmbc_record.byop_act_zip
                                );
  EXCEPTION
  WHEN OTHERS THEN
   o_error_num    := 156;
   o_error_string := 'Exception occured while inserting into x_sl_subs_dtl '||SUBSTR(SQLERRM, 1, 100);
   p_ins_job_err
             (
              'SLENROLL',
              o_error_string
             );
   RETURN;
  END; --}
  END IF; --}


 EXCEPTION
 WHEN OTHERS THEN
  o_error_num     := 160;
  o_error_string  := 'In main exception of p_ins_sl_subs '||SUBSTR(SQLERRM, 1, 100);
  p_ins_job_err
            (
             'SLENROLL',
             o_error_string
            );
 RETURN;
 END p_ins_sl_subs; --}

 PROCEDURE p_create_account
 (
  p_email_id           IN  table_web_user.login_name%TYPE,
  p_password           IN  table_web_user.password%TYPE,
  p_brand_name         IN  table_bus_org.org_id%TYPE,
  o_contact_objid      OUT NUMBER,
  o_web_user_objid     OUT NUMBER,
  o_error_num          OUT NUMBER,
  o_error_string       OUT VARCHAR2
 )
 IS

 l_name_space_index         NUMBER;
 l_first_name               VARCHAR2(50);
 l_last_name                VARCHAR2(50);
 l_city                     table_x_zip_code.x_city%TYPE;
 l_state                    table_x_zip_code.x_state%TYPE;
 l_create_contact_error_num VARCHAR2(50);
 l_create_contact_error_str VARCHAR2(200);
 l_check_web_user_cnt       NUMBER := 0;
 l_web_user_objid           NUMBER;
 l_contact_objid            NUMBER := 0;
 l_account_flag             NUMBER := 0;
 l_ship_add_flag            VARCHAR2(5)              := 'FALSE';
 l_ship_add1                VARCHAR2 (100);
 l_ship_add2                VARCHAR2 (100);
 l_ship_city                VARCHAR2 (100);
 l_ship_state               VARCHAR2 (100);
 l_ship_zip                 VARCHAR2 (100);

 l_timezone_objid           table_time_zone.objid%TYPE;
 l_country_objid            table_country.objid%TYPE;
 l_regular_add_objid        table_address.objid%TYPE := sa.seq('address');
 l_table_site_objid         table_site.objid%TYPE;

 BEGIN --{
 o_error_num          := 0;
 o_error_string       := 'Success';

  SELECT COUNT(1)
  INTO   l_check_web_user_cnt
  FROM   table_web_user web_user_h,
         table_bus_org  bus_org_i
  WHERE  web_user_h.web_user2bus_org = bus_org_i.objid
  AND    s_org_id                    = p_brand_name
  AND    s_login_name                = UPPER(p_email_id);

------------------------------------------------------
-- Check If Account For ESN present
------------------------------------------------------
 SELECT    COUNT(1)
 INTO      l_account_flag
 FROM      table_contact tc,
           table_x_contact_part_inst txcpi,
           table_part_inst tpi,
           table_web_user twu
 WHERE     txcpi.x_contact_part_inst2part_inst = tpi.objid
 AND       txcpi.x_contact_part_inst2contact   = tc.objid
 AND       twu.web_user2contact                = tc.objid
 AND       tpi.part_serial_no                  = v_vmbc_record.esn
 AND       v_vmbc_record.esn                   IS NOT NULL;



 --To-DO: Future business validation, for enroll E record.

  IF l_check_web_user_cnt = 0 AND l_account_flag = 0
  THEN --{
  --Check space from back
   SELECT INSTR(v_vmbc_record.name,' ', 1, 1)
   INTO   l_name_space_index
   FROM   dual;

   IF l_name_space_index > 0
   THEN --{

    /*SELECT SUBSTR(v_vmbc_record.name, 0, l_name_space_index-1),
           TRIM(SUBSTR(v_vmbc_record.name, l_name_space_index))
    INTO   l_first_name,
           l_last_name
    FROM   dual;*/

   SELECT SUBSTR(v_vmbc_record.name, 1, INSTR(v_vmbc_record.name, ' ', -1)-1),
          SUBSTR(v_vmbc_record.name, INSTR(v_vmbc_record.name, ' ', -1)+1)
   INTO   l_first_name,
          l_last_name
   FROM   dual;

   ELSE --}{
    l_first_name := v_vmbc_record.name;
   END IF; --}

    IF v_vmbc_record.x_shp_address IS NULL
    THEN --{
     l_ship_add_flag := 'FALSE';
    ELSE --}{
     l_ship_add_flag := 'TRUE';
    END IF; --}

    SELECT DECODE(l_ship_add_flag, 'TRUE', v_vmbc_record.x_shp_address, v_vmbc_record.address),
           DECODE(l_ship_add_flag, 'TRUE', v_vmbc_record.x_shp_address2, v_vmbc_record.address2),
           DECODE(l_ship_add_flag, 'TRUE', v_vmbc_record.x_shp_city, v_vmbc_record.city),
           DECODE(l_ship_add_flag, 'TRUE', v_vmbc_record.x_shp_state, v_vmbc_record.state),
           DECODE(l_ship_add_flag, 'TRUE', v_vmbc_record.x_shp_zip, v_vmbc_record.zip)
    INTO   l_ship_add1,
           l_ship_add2,
           l_ship_city,
           l_ship_state,
           l_ship_zip
    FROM  dual;

 --Insert Addresses start
 BEGIN --{
  SELECT objid
  INTO   l_timezone_objid
  FROM   table_time_zone
  WHERE  name   = 'EST'
  AND    ROWNUM < 2;
 EXCEPTION
 WHEN OTHERS THEN
  l_timezone_objid := NULL;
 END; --}

 BEGIN --{
  SELECT objid
  INTO   l_country_objid
  FROM   table_country
  WHERE  name   = 'USA'
  AND    ROWNUM < 2;
 EXCEPTION
 WHEN OTHERS THEN
  l_country_objid := NULL;
 END; --}

 --Create Contact start
  BEGIN --{
     SELECT tc.objid
     INTO   l_contact_objid
     FROM   table_contact   tc,
            table_part_inst tpi
     WHERE  tc.objid           = tpi.x_part_inst2contact
     AND    tpi.part_serial_no = v_vmbc_record.esn
     AND    v_vmbc_record.esn IS NOT NULL;
  EXCEPTION
  WHEN OTHERS THEN
   l_contact_objid := 0;
  END; --}

  IF l_contact_objid = 0
  THEN --{

 -- Regular Address
   BEGIN --{
    INSERT INTO table_address
                            (
                             objid,
                             address,
                             s_address,
                             city,
                             s_city,
                             state,
                             s_state,
                             zipcode,
                             address_2,
                             dev,
                             address2time_zone,
                             address2country,
                             address2state_prov,
                             update_stamp
                            )
                          VALUES
                            (
                             l_regular_add_objid,
                             v_vmbc_record.address,
                             UPPER(v_vmbc_record.address),
                             v_vmbc_record.city,
                             UPPER(v_vmbc_record.city),
                             v_vmbc_record.state,
                             UPPER(v_vmbc_record.state),
                             v_vmbc_record.zip,
                             v_vmbc_record.address2,
                             NULL,
                             l_timezone_objid,
                             l_country_objid,
                             (SELECT objid FROM table_state_prov WHERE s_name = UPPER(v_vmbc_record.state) AND state_prov2country = l_country_objid AND ROWNUM < 2),
                             SYSDATE
                            );
   EXCEPTION
   WHEN OTHERS THEN
    o_error_num     := 185;
    o_error_string  := 'Error while inserting regular address '||SUBSTR(SQLERRM, 1, 100);
    p_ins_job_err
              (
               'SLENROLL',
               o_error_string
              );
    RETURN;
   END; --}

 BEGIN --{
   sa.contact_pkg.createcontact_prc
                                  (
                                  in_esn               => v_vmbc_record.esn,
                                  in_first_name        => l_first_name,
                                  in_last_name         => l_last_name,
                                  in_middle_name       => null,
                                  in_phone             => v_vmbc_record.cellTelephone,
                                  in_shp_add1          => l_ship_add1,
                                  in_shp_add2          => l_ship_add2,
                                  in_shp_fax           => null,
                                  in_shp_city          => l_ship_city,
                                  in_shp_st            => l_ship_state,
                                  in_shp_zip           => l_ship_zip,
                                  in_bil_add1          => l_ship_add1,
                                  in_bil_add2          => l_ship_add2,
                                  in_bil_fax           => null,
                                  in_bil_city          => l_ship_city,
                                  in_bil_st            => l_ship_state,
                                  in_bil_zip           => l_ship_zip,
                                  in_email             => p_email_id,
                                  in_email_status      => null,
                                  in_roadside_status   => null,
                                  in_no_name_flag      => 0,
                                  in_no_phone_flag     => 0,
                                  in_no_address_flag   => 0,
                                  in_sourcesystem      => 'WEB',
                                  in_brand_name        => p_brand_name,
                                  in_do_not_email      => null,
                                  in_do_not_phone      => null,
                                  in_do_not_mail       => null,
                                  in_do_not_sms        => null,
                                  in_ssn               => null,
                                  in_dob               => null,
                                  in_do_not_mobile_ads => null,
                                  out_contact_objid    => l_contact_objid,
                                  out_err_code         => l_create_contact_error_num,
                                  out_err_msg          => l_create_contact_error_str
                                  );

   EXCEPTION
   WHEN OTHERS THEN
    o_error_num    := 135;
    o_error_string := 'Error after sa.contact_pkg.createcontact_prc for p_lid '||v_vmbc_record.lid||' '||SUBSTR(SQLERRM, 1, 100);
    p_ins_job_err
              (
               'SLENROLL',
               o_error_string
              );
    RETURN;
   END; --}

  BEGIN --{
   SELECT ts.objid
   INTO   l_table_site_objid
   FROM   table_contact tc,
          table_contact_role tcr,
          table_site ts
   WHERE  tc.objid              = tcr.contact_role2contact
   AND    tcr.contact_role2site = ts.objid
   AND    tcr.s_role_name||''   = 'DEFAULT'
   AND    tc.objid = l_contact_objid
   AND    ROWNUM < 2;
  EXCEPTION
  WHEN OTHERS THEN
   l_table_site_objid := NULL;
   o_error_num    := 210;
   o_error_string := 'Error while fetching table site '||SUBSTR(SQLERRM, 1, 100);
   p_ins_job_err
             (
              'SLENROLL',
              o_error_string
             );
   RETURN;
  END; --}

   UPDATE  table_site
   SET     cust_primaddr2address = l_regular_add_objid
   WHERE   objid                 = l_table_site_objid;
 END IF; --}

   BEGIN  --{
    l_web_user_objid := sa.seq('web_user');

    INSERT INTO table_web_user
                             (
                             objid,
                             login_name,
                             s_login_name,
                             password,
                             status,
                             x_secret_questn,
                             x_secret_ans,
                             s_x_secret_questn,
                             s_x_secret_ans,
                             web_user2contact,
                             web_user2bus_org
                             )
                             VALUES
                             (
                             l_web_user_objid,
                             p_email_id,
                             UPPER(p_email_id),
                             p_password,
                             '1',
                             'Please enter the word lifeline as the answer',
                             'lifeline',
                             'PLEASE ENTER THE WORD LIFELINE AS THE ANSWER',
                             'LIFELINE',
                             l_contact_objid,
                             (SELECT objid FROM table_bus_org WHERE s_org_id = p_brand_name)
                             );
    EXCEPTION
     WHEN OTHERS THEN
     o_error_num     := 140;
     o_error_string  := 'Insertion failed in TABLE_WEB_USER for p_lid '||v_vmbc_record.lid||' '||SUBSTR(SQLERRM, 1, 100);
     p_ins_job_err
               (
                'SLENROLL',
                o_error_string
               );
    RETURN;
    END; --}

  ELSE --}{

   BEGIN --{

    BEGIN --{
     SELECT web_user_h.objid, web_user2contact
     INTO   l_web_user_objid, l_contact_objid
     FROM   table_web_user web_user_h,
            table_bus_org  bus_org_i
     WHERE  web_user_h.web_user2bus_org = bus_org_i.objid
     AND    s_org_id                    = p_brand_name
     AND    s_login_name                = UPPER(p_email_id);
    EXCEPTION
    WHEN OTHERS THEN
     l_web_user_objid := NULL;
     l_contact_objid := NULL;
    END; --}

    IF l_web_user_objid IS NULL OR l_contact_objid IS NULL
    THEN --{

     BEGIN --{
      SELECT twu.objid, twu.web_user2contact
      INTO   l_web_user_objid, l_contact_objid
      FROM   table_contact   tc,
             table_x_contact_part_inst txcpi,
             table_part_inst tpi,
             table_web_user  twu
      WHERE  txcpi.x_contact_part_inst2part_inst = tpi.objid
      AND    txcpi.x_contact_part_inst2contact   = tc.objid
      AND    twu.web_user2contact                = tc.objid
      AND    tpi.part_serial_no                  = v_vmbc_record.esn
      AND    ROWNUM < 2;
     EXCEPTION
     WHEN OTHERS THEN
      l_web_user_objid := NULL;
      l_contact_objid  := NULL;
     END; --}
    END IF; --}

   EXCEPTION
    WHEN OTHERS THEN
    o_error_num     := 145;
    o_error_string  := 'Web user/contact failed for p_lid '||v_vmbc_record.lid||' '||SUBSTR(SQLERRM, 1, 100);
    p_ins_job_err
              (
               'SLENROLL',
               o_error_string
              );
    RETURN;
   END; --}

  END IF; --}

  o_contact_objid   := l_contact_objid;
  o_web_user_objid  := l_web_user_objid;

 EXCEPTION
 WHEN OTHERS THEN
  o_error_num    := 150;
  o_error_string := 'In main exception of p_create_account for p_lid '||v_vmbc_record.lid||' '||SUBSTR(SQLERRM, 1, 100);
  p_ins_job_err
            (
             'SLENROLL',
             o_error_string
            );
  RETURN;
 END p_create_account; --}

 PROCEDURE p_create_case
 (
  p_email_id           IN  table_web_user.login_name%TYPE,
  p_brand_name         IN  table_bus_org.org_id%TYPE,
  p_contact_objid      IN NUMBER,
  p_web_user_objid     IN NUMBER,
  o_id_number          OUT VARCHAR2,
  o_error_num          OUT NUMBER,
  o_error_string       OUT VARCHAR2
 )
 IS
 l_case_count         NUMBER := 0;
 l_ship_add_flag      VARCHAR2(5)              := 'FALSE';
 l_name_space_index   NUMBER;
 l_first_name         VARCHAR2(50);
 l_last_name          VARCHAR2(50);
 l_city               table_x_zip_code.x_city%TYPE;
 l_state              table_x_zip_code.x_state%TYPE;
 l_contact_objid      NUMBER := 0;
-------
 l_title           VARCHAR2 (100);
 l_case_type       VARCHAR2 (100);
 l_status          VARCHAR2 (100) := 'Pending';
 l_priority        VARCHAR2 (100) := 'Medium';
 l_issue           VARCHAR2 (100);
 l_source          VARCHAR2 (100);
 l_point_contact   VARCHAR2 (100) := 'W';
 l_creation_time   DATE;
 l_task_objid      NUMBER;
 l_user_objid      NUMBER;
 l_phone_num       VARCHAR2 (100);
 l_e_mail          VARCHAR2 (100);
 l_delivery_type   VARCHAR2 (100);
 l_address         VARCHAR2 (400);
 l_zipcode         VARCHAR2 (100);
 l_repl_units      NUMBER;
 l_fraud_objid     NUMBER;
 l_case_detail     VARCHAR2 (500);
 l_part_request    VARCHAR2 (100);
 l_id_number       VARCHAR2 (100);
 l_case_objid      NUMBER := 0;
 l_curval_cnt      NUMBER := 0;
 l_error_no        VARCHAR2 (1000);
 l_error_str       VARCHAR2 (3000);
 l_queue_name      VARCHAR2 (30) := 'Warehouse';

 l_ship_add1        VARCHAR2 (100);
 l_ship_add2        VARCHAR2 (100);
 l_ship_city        VARCHAR2 (100);
 l_ship_state       VARCHAR2 (100);
 l_ship_zip         VARCHAR2 (100);
 l_prefer_part      VARCHAR2 (100);

 BEGIN --{
  o_error_num          := 0;
  o_error_string       := 'Success';

   IF UPPER(v_vmbc_record.enrollrequest)    = 'S'
   THEN --{
    l_title            := 'Lifeline Shipment';
    l_case_type        := 'Warehouse';
   ELSIF UPPER(v_vmbc_record.enrollrequest)    = 'P'
   THEN --}{
      l_title            := 'SL_FIELD_ACTIVATION';
      l_case_type        := 'SAFELINK';
   ELSE --}{
    l_title            := '';
    l_case_type        := '';
   END IF; --}

   -- below query is to check if CASE is present for the passed LID.
   BEGIN --{
    SELECT tc.objid, tc.id_number
    INTO   l_case_objid, l_id_number
    FROM   table_case tc,
           table_x_case_detail cd
    WHERE  tc.objid      =  cd.detail2case
    AND    s_title       =  UPPER(l_title)
    AND    x_case_type   =  l_case_type
    AND    cd.x_name     =  'LIFELINEID'
    AND    cd.x_value    =  v_vmbc_record.lid
    AND    creation_time >  SYSDATE-30
    AND    ROWNUM < 2;
   EXCEPTION
   WHEN OTHERS THEN
    l_case_objid := 0;
    l_id_number  := '0';
   END; --}

   -- below query is to check if ESN is present for the passed LID.
   BEGIN --{
    SELECT COUNT(1)
    INTO   l_curval_cnt
    FROM   sa.x_sl_currentvals
    WHERE  1             = 1
    AND    lid           = v_vmbc_record.lid
    AND    (
                x_current_esn <> '0'
            AND x_current_esn <> '-1'      -- AND condition added as part of CR49533
            AND x_current_esn IS NOT NULL
           );
   EXCEPTION
   WHEN OTHERS THEN
    l_curval_cnt := 0;
   END; --}

  DBMS_OUTPUT.PUT_LINE('l_case_count = '||l_case_count);

  IF l_case_objid = 0 AND l_curval_cnt = 0
  THEN --{

  IF v_vmbc_record.x_shp_address IS NULL
  THEN --{
   l_ship_add_flag := 'FALSE';
  ELSE --}{
   l_ship_add_flag := 'TRUE';
  END IF; --}


  SELECT DECODE(l_ship_add_flag, 'TRUE', v_vmbc_record.x_shp_address, v_vmbc_record.address),
         DECODE(l_ship_add_flag, 'TRUE', v_vmbc_record.x_shp_address2, v_vmbc_record.address2),
         DECODE(l_ship_add_flag, 'TRUE', v_vmbc_record.x_shp_city, v_vmbc_record.city),
         DECODE(l_ship_add_flag, 'TRUE', v_vmbc_record.x_shp_state, v_vmbc_record.state),
         DECODE(l_ship_add_flag, 'TRUE', v_vmbc_record.x_shp_zip, v_vmbc_record.zip)
  INTO   l_ship_add1,
         l_ship_add2,
         l_ship_city,
         l_ship_state,
         l_ship_zip
  FROM  dual;

   SELECT INSTR(v_vmbc_record.name,' ', 1, 1)
   INTO   l_name_space_index
   FROM   dual;

   IF l_name_space_index > 0
   THEN --{

/*    SELECT SUBSTR(v_vmbc_record.name, 0, l_name_space_index-1),
           TRIM(SUBSTR(v_vmbc_record.name, l_name_space_index))
    INTO   l_first_name,
           l_last_name
    FROM   dual;*/

   SELECT SUBSTR(v_vmbc_record.name, 1, INSTR(v_vmbc_record.name, ' ', -1)-1),
          SUBSTR(v_vmbc_record.name, INSTR(v_vmbc_record.name, ' ', -1)+1)
   INTO   l_first_name,
          l_last_name
   FROM   dual;

   ELSE
    l_first_name := v_vmbc_record.name;
   END IF; --}

  -- Create Case start
  IF UPPER(v_vmbc_record.enrollrequest)    = 'S'
  THEN --{
   BEGIN --{
    sa.safelink_validations_pkg.p_get_part_num_by_zip_sl
                                                       (
                                                        ip_zip             => v_vmbc_record.zip,
                                                        ip_program_name    => v_vmbc_record.plan,
                                                        ip_device_type     => v_vmbc_record.device_type,
                                                        ip_simtype_carrier => v_vmbc_record.byop_carrier,
                                                        ip_sim_size        => v_vmbc_record.byop_sim,
                                                        op_part_number     => l_prefer_part ,
                                                        op_err_num         => o_error_num ,
                                                        op_err_string      => o_error_string
                                                       );
   EXCEPTION
    WHEN OTHERS THEN
     o_error_num    := 215;
     o_error_string := 'Error in call safelink_validations_pkg.p_get_part_num_by_zip_sl '||SUBSTR(SQLERRM, 1, 100);
     p_ins_job_err
               (
                'SLENROLL',
                o_error_string
               );
     ROLLBACK;
     RETURN;
   END; --}
  ELSE --}{
   l_prefer_part := NULL;
  END IF; --}

   BEGIN --{
    SELECT objid
    INTO   l_user_objid
    FROM   table_user
    WHERE  s_login_name = 'SA';
   EXCEPTION
   WHEN OTHERS THEN
    l_user_objid := '268435556'; --SA objid
   END; --}

   l_case_detail := 'ACTIVATION_ZIP||'||v_vmbc_record.zip||'||CONTACTID||'||p_contact_objid||'||BPWEBUSERID||'||p_web_user_objid||'||BPEMAIL||'||p_email_id||'||X_REQUESTED_PLAN||'||v_vmbc_record.plan||'||LIFELINEID||'||v_vmbc_record.lid||'||';

   BEGIN --{

    sa.clarify_case_pkg.create_case (
                                     p_title           => l_title,
                                     p_case_type       => l_case_type,
                                     p_status          => l_status,
                                     p_priority        => l_priority,
                                     p_issue           => l_issue,
                                     p_source          => l_source,
                                     p_point_contact   => l_point_contact,
                                     p_creation_time   => SYSDATE,
                                     p_task_objid      => NULL,
                                     p_contact_objid   => p_contact_objid,
                                     p_user_objid      => l_user_objid,
                                     p_esn             => v_vmbc_record.esn,
                                     p_phone_num       => v_vmbc_record.homeNumber,
                                     p_first_name      => l_first_name,
                                     p_last_name       => l_last_name,
                                     p_e_mail          => v_vmbc_record.email,
                                     p_delivery_type   => NULL,
                                     p_address         => l_ship_add1||(CASE WHEN l_ship_add2 IS NOT NULL THEN '||'|| l_ship_add2 ELSE NULL END),
                                     p_city            => l_ship_city,
                                     p_state           => l_ship_state,
                                     p_zipcode         => l_ship_zip,
                                     p_repl_units      => NULL,
                                     p_fraud_objid     => NULL,
                                     p_case_detail     => l_case_detail,
                                     p_part_request    => l_prefer_part,
                                     p_id_number       => l_id_number,
                                     p_case_objid      => l_case_objid,
                                     p_error_no        => l_error_no,
                                     p_error_str       => l_error_str
                                    );

   o_id_number := l_id_number;

   EXCEPTION
   WHEN OTHERS THEN
    o_error_num     := 220;
    o_error_string  := 'In exception after calling CREATE_CASE '||SUBSTR(SQLERRM, 1, 100);
    p_ins_job_err
              (
               'SLENROLL',
               o_error_string
              );
    RETURN;
   END; --}
   p_ins_sl_hist
               (
               '-1',
               'table_case',
               l_id_number, --p_event_value
               610, --p_event_code
               NULL, --p_event_data
               o_error_num,
               o_error_string
               );

   BEGIN --{
    sa.clarify_case_pkg.dispatch_case (
                                       p_case_objid   => l_case_objid,
                                       p_user_objid   => l_user_objid,
                                       p_queue_name   => l_queue_name,
                                       p_error_no     => l_error_no,
                                       p_error_str    => l_error_str
                                      );
   EXCEPTION
   WHEN OTHERS THEN
    o_error_num     := 225;
    o_error_string  := 'In exception after calling dispatch_case '||SUBSTR(SQLERRM, 1, 100);
    p_ins_job_err
              (
               'SLENROLL',
               o_error_string
              );
    RETURN;
   END; --}

/*
   BEGIN --{
    INSERT INTO x_autoclose_case
                                (
                                 x_esn,
                                 x_case_type,
                                 x_case_title,
                                 x_contact_first_name,
                                 x_contact_last_name,
                                 x_cust_id,
                                 x_activation_zip_code,
                                 x_carrier_id,
                                 x_carrier_name,
                                 x_phone_model,
                                 x_msid,
                                 x_activation_date,
                                 x_prl,
                                 x_soc,
                                 x_red_code,
                                 x_retailer,
                                 x_create_date,
                                 x_agent_name,
                                 x_flow_type,
                                 x_sourcesystem,
                                 x_sub_sourcesystem
                                )
                                 VALUES
                                (
                                 v_vmbc_record.esn,
                                 l_case_type,
                                 l_title,
                                 l_first_name,
                                 l_last_name,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 SYSDATE,
                                 'SA',
                                 NULL,
                                 'WEB',
                                 NULL
                                );

   EXCEPTION
   WHEN OTHERS THEN
    o_error_num     := 226;
    o_error_string  := 'In exception while inserting in x_autoclose_case '||SUBSTR(SQLERRM, 1, 100);
    p_ins_job_err
              (
               'SLENROLL',
               o_error_string
              );
   END; --}
*/

  ELSE --}{
   DBMS_OUTPUT.PUT_LINE('Do nothing.....');
   o_id_number := l_id_number;
  END IF; --}
  -- Create Case end

 EXCEPTION
 WHEN OTHERS THEN
  o_error_num     := 230;
  o_error_string  := 'In main exception of p_create_case '||SUBSTR(SQLERRM, 1, 100);
  p_ins_job_err
            (
             'SLENROLL',
             o_error_string
            );
  RETURN;
 END p_create_case; --}

 PROCEDURE p_ins_sl_hist
 (
  p_current_esn        IN  sa.x_sl_currentvals.x_current_esn%TYPE,
  p_table_source       IN  sa.x_sl_hist.x_src_table%TYPE,
  p_event_value        IN  sa.x_sl_hist.x_event_value%TYPE,
  p_event_code         IN  sa.x_sl_hist.x_event_code%TYPE,
  p_event_data         IN  sa.x_sl_hist.x_event_data%TYPE,
  o_error_num          OUT NUMBER,
  o_error_string       OUT VARCHAR2
 )
 IS
 BEGIN --{
  o_error_num          := 0;
  o_error_string       := 'Success';

  DBMS_OUTPUT.PUT_LINE('In p_ins_sl_hist');

     INSERT INTO x_sl_hist (
                            objid,
                            lid,
                            x_esn,
                            x_event_dt,
                            x_insert_dt,
                            x_event_value,
                            x_event_code,
                            x_event_data,
                            x_min,
                            username,
                            x_sourcesystem,
                            x_code_number,
                            x_src_table,
                            x_src_objid,
                            x_program_enrolled_id
                           )
                         VALUES
                          (
                           sa.seq_x_sl_hist.NEXTVAL,
                           v_vmbc_record.lid,
                           p_current_esn,
                           SYSDATE, ----
                           SYSDATE, ----
                           p_event_value,
                           p_event_code,
                           p_event_data,
                           null,
                           'SA',
                           'WEB',
                           '0',
                           p_table_source,
                           null,
                           null
                          );
 EXCEPTION
 WHEN OTHERS THEN
  o_error_num     := 180;
  o_error_string  := 'In main exception of p_ins_sl_hist '||SUBSTR(SQLERRM, 1, 100);
  p_ins_job_err
            (
             'SLENROLL',
             o_error_string
            );
  RETURN;
 END p_ins_sl_hist; --}

 PROCEDURE p_ins_job_err
                     (
                      p_req_type    IN     VARCHAR2,
                      p_err_msg     IN     VARCHAR2
                     )
 AS
 PRAGMA AUTONOMOUS_TRANSACTION;

 BEGIN --{
 INSERT INTO x_job_errors
                        (
                         objid,
                         x_source_job_id,
                         x_request_type,
                         x_request,
                         ordinal,
                         x_status_code,
                         x_reject,
                         x_insert_date,
                         x_update_date,
                         x_resent,
                         x_error_msg
                        )
                        VALUES
                       (
                        sa.seq_x_job_errors.NEXTVAL,
                        v_vmbc_record.job_data_id, --j.job_data_id,
                        DECODE(UPPER(v_vmbc_record.enrollrequest), 'S', p_req_type, 'P', 'SLENROLL_FA', p_req_type), --i.req_type,
                        v_vmbc_record.lid, --i.req,
                        0,
                        -99,
                        0,
                        SYSDATE,
                        SYSDATE,
                        0,
                        p_err_msg
                       );
   COMMIT;
 EXCEPTION
 WHEN OTHERS THEN
   ROLLBACK;
 END p_ins_job_err; --}

END pkg_safelink_enrollment;
/