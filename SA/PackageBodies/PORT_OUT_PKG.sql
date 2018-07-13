CREATE OR REPLACE PACKAGE BODY sa.port_out_pkg AS
--
--
PROCEDURE log_request (i_min                          IN VARCHAR2,
                       i_request_no                   IN VARCHAR2,
                       i_request_type                 IN VARCHAR2,
                       i_short_parent_name            IN VARCHAR2,
                       i_case_id_number               IN VARCHAR2,
                       i_desired_due_date             IN DATE,
                       i_nnsp                         IN VARCHAR2,
                       i_directional_indicator        IN VARCHAR2,
                       i_osp_account_no               IN VARCHAR2,
                       i_response                     IN VARCHAR2,
                       i_esn                          IN VARCHAR2 DEFAULT NULL,
                       i_brand_shared_group_flag      IN VARCHAR2 DEFAULT NULL,
                       i_request_xml                  IN XMLTYPE  DEFAULT NULL,
                       i_error_code                   IN VARCHAR2 DEFAULT NULL,
                       i_error_message                IN VARCHAR2 DEFAULT NULL,
                       i_site_part_objid              IN NUMBER   DEFAULT NULL,
                       i_service_end_date             IN DATE     DEFAULT NULL,
                       i_expiration_date              IN DATE     DEFAULT NULL,
                       i_deactivation_reason          IN VARCHAR2 DEFAULT NULL,
                       i_notify_carrier               IN NUMBER   DEFAULT NULL,
                       i_site_part_status             IN VARCHAR2 DEFAULT NULL,
                       i_service_plan_objid           IN NUMBER   DEFAULT NULL,
                       i_ild_transaction_status       IN VARCHAR2 DEFAULT NULL,
                       i_esn_part_inst_objid          IN NUMBER   DEFAULT NULL,
                       i_esn_part_inst_status         IN VARCHAR2 DEFAULT NULL,
                       i_esn_part_inst_code           IN NUMBER   DEFAULT NULL,
                       i_reactivation_flag            IN NUMBER   DEFAULT NULL,
                       i_contact_objid                IN NUMBER   DEFAULT NULL,
                       i_esn_new_personality_objid    IN NUMBER   DEFAULT NULL,
                       i_pgm_enroll_objid             IN NUMBER   DEFAULT NULL,
                       i_pgm_enrollment_status        IN VARCHAR2 DEFAULT NULL,
                       i_pgm_enroll_exp_date          IN DATE     DEFAULT NULL,
                       i_pgm_enroll_cooling_exp_date  IN DATE     DEFAULT NULL,
                       i_pgm_enroll_next_dlvry_date   IN DATE     DEFAULT NULL,
                       i_pgm_enroll_next_charge_date  IN DATE     DEFAULT NULL,
                       i_pgm_enroll_grace_period      IN NUMBER   DEFAULT NULL,
                       i_pgm_enroll_cooling_period    IN NUMBER   DEFAULT NULL,
                       i_pgm_enroll_service_days      IN NUMBER   DEFAULT NULL,
                       i_pgm_enroll_wait_exp_date     IN DATE     DEFAULT NULL,
                       i_pgm_enroll_charge_type       IN VARCHAR2 DEFAULT NULL,
                       i_pgm_enrol_tot_grace_prd_gn   IN NUMBER   DEFAULT NULL,
                       i_account_group_objid          IN NUMBER   DEFAULT NULL,
                       i_member_objid                 IN NUMBER   DEFAULT NULL,
                       i_member_status                IN VARCHAR2 DEFAULT NULL,
                       i_member_start_date            IN DATE     DEFAULT NULL,
                       i_member_end_date              IN DATE     DEFAULT NULL,
                       i_member_master_flag           IN VARCHAR2 DEFAULT NULL,
                       i_service_order_stage_objid    IN NUMBER   DEFAULT NULL,
                       i_service_order_stage_status   IN VARCHAR2 DEFAULT NULL,
                       i_min_part_inst_objid          IN NUMBER   DEFAULT NULL,
                       i_min_part_inst_status         IN VARCHAR2 DEFAULT NULL,
                       i_min_part_inst_code           IN NUMBER   DEFAULT NULL,
                       i_min_cool_end_date            IN DATE     DEFAULT NULL,
                       i_min_warr_end_date            IN DATE     DEFAULT NULL,
                       i_repair_date                  IN DATE     DEFAULT NULL,
                       i_min_personality_objid        IN NUMBER   DEFAULT NULL,
                       i_min_new_personality_objid    IN NUMBER   DEFAULT NULL,
                       i_min_to_esn_part_inst_objid   IN NUMBER   DEFAULT NULL,
                       i_last_cycle_date              IN DATE     DEFAULT NULL,
                       i_port_in                      IN NUMBER   DEFAULT NULL,
                       i_psms_outbox_objid            IN NUMBER   DEFAULT NULL,
                       i_psms_outbox_status           IN VARCHAR2 DEFAULT NULL,
                       i_ota_feat_objid               IN NUMBER   DEFAULT NULL,
                       i_ota_feat_ild_account         IN VARCHAR2 DEFAULT NULL,
                       i_ota_feat_ild_carr_status     IN VARCHAR2 DEFAULT NULL,
                       i_ota_feat_ild_prog_status     IN VARCHAR2 DEFAULT NULL,
                       i_click_plan_hist_objid        IN NUMBER   DEFAULT NULL,
                       i_click_plan_hist_end_date     IN DATE     DEFAULT NULL,
                       i_fvm_status                   IN NUMBER   DEFAULT NULL,
                       i_fvm_number                   IN VARCHAR2 DEFAULT NULL,
                       i_ota_transaction_objid        IN NUMBER   DEFAULT NULL,
                       i_ota_transaction_status       IN VARCHAR2 DEFAULT NULL,
                       i_ota_transaction_reason       IN VARCHAR2 DEFAULT NULL,
                       i_x_client_id                  IN VARCHAR2 DEFAULT NULL,   -- CR51128
                       i_account_no                   IN VARCHAR2 DEFAULT NULL,   -- CR56056
                       i_carrier                      IN VARCHAR2 DEFAULT NULL,
                       i_password_pin                 IN VARCHAR2 DEFAULT NULL,
                       i_v_key                        IN VARCHAR2 DEFAULT NULL,
                       i_full_name                    IN VARCHAR2 DEFAULT NULL,
                       i_billing_address              IN VARCHAR2 DEFAULT NULL,
                       i_last_4_ssn                   IN VARCHAR2 DEFAULT NULL,
                       i_account_alpha                IN VARCHAR2 DEFAULT NULL,
                       i_pin_alpha                    IN VARCHAR2 DEFAULT NULL,
                       i_zip_code                     IN VARCHAR2 DEFAULT NULL) AS -- CR56056

  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  INSERT INTO sa.x_port_out_request_log (min,
                                         request_no,
                                         request_date,
                                         request_type,
                                         short_parent_name,
                                         case_id_number,
                                         desired_due_date,
                                         nnsp,
                                         directional_indicator,
                                         osp_account_no,
                                         status,
                                         esn,
                                         brand_shared_group_flag,
                                         error_code,
                                         error_message,
                                         site_part_objid,
                                         service_end_date,
                                         expiration_date,
                                         deactivation_reason,
                                         notify_carrier,
                                         site_part_status,
                                         service_plan_objid,
                                         ild_transaction_status,
                                         esn_part_inst_objid,
                                         esn_part_inst_status,
                                         esn_part_inst_code,
                                         reactivation_flag,
                                         contact_objid,
                                         esn_new_personality_objid,
                                         pgm_enroll_objid,
                                         pgm_enrollment_status,
                                         pgm_enroll_exp_date,
                                         pgm_enroll_cooling_exp_date,
                                         pgm_enroll_next_delivery_date,
                                         pgm_enroll_next_charge_date,
                                         pgm_enroll_grace_period,
                                         pgm_enroll_cooling_period,
                                         pgm_enroll_service_days,
                                         pgm_enroll_wait_exp_date,
                                         pgm_enroll_charge_type,
                                         pgm_enrol_tot_grace_period_gn,
                                         account_group_objid,
                                         member_objid,
                                         member_status,
                                         member_start_date,
                                         member_end_date,
                                         member_master_flag,
                                         service_order_stage_objid,
                                         service_order_stage_status,
                                         min_part_inst_objid,
                                         min_part_inst_status,
                                         min_part_inst_code,
                                         min_cool_end_date,
                                         min_warr_end_date,
                                         repair_date,
                                         min_personality_objid,
                                         min_new_personality_objid,
                                         min_to_esn_part_inst_objid,
                                         last_cycle_date,
                                         port_in,
                                         psms_outbox_objid,
                                         psms_outbox_status,
                                         ota_feat_objid,
                                         ota_feat_ild_account,
                                         ota_feat_ild_carr_status,
                                         ota_feat_ild_prog_status,
                                         click_plan_hist_objid,
                                         click_plan_hist_end_date,
                                         fvm_status,
                                         fvm_number,
                                         ota_transaction_objid,
                                         ota_transaction_status,
                                         ota_transaction_reason,
                                         request_xml,
                                         x_carrier,    -- CR51128 client id for TMO values will be 6 / 36 /91
                                         account_no,   -- CR56056
                                         carrier,
                                         password_pin,
                                         v_key,
                                         full_name,
                                         billing_address,
                                         last_4_ssn,
                                         account_alpha,
                                         pin_alpha,
                                         zip_code)     --CR56056
                                 VALUES (i_min,
                                         i_request_no,
                                         sysdate,
                                         i_request_type,
                                         i_short_parent_name,
                                         i_case_id_number,
                                         i_desired_due_date,
                                         i_nnsp,
                                         i_directional_indicator,
                                         i_osp_account_no,
                                         i_response,
                                         i_esn,
                                         i_brand_shared_group_flag,
                                         i_error_code,
                                         i_error_message,
                                         i_site_part_objid,
                                         i_service_end_date,
                                         i_expiration_date,
                                         i_deactivation_reason,
                                         i_notify_carrier,
                                         i_site_part_status,
                                         i_service_plan_objid,
                                         i_ild_transaction_status,
                                         i_esn_part_inst_objid,
                                         i_esn_part_inst_status,
                                         i_esn_part_inst_code,
                                         i_reactivation_flag,
                                         i_contact_objid,
                                         i_esn_new_personality_objid,
                                         i_pgm_enroll_objid,
                                         i_pgm_enrollment_status,
                                         i_pgm_enroll_exp_date,
                                         i_pgm_enroll_cooling_exp_date,
                                         i_pgm_enroll_next_dlvry_date,
                                         i_pgm_enroll_next_charge_date,
                                         i_pgm_enroll_grace_period,
                                         i_pgm_enroll_cooling_period,
                                         i_pgm_enroll_service_days,
                                         i_pgm_enroll_wait_exp_date,
                                         i_pgm_enroll_charge_type,
                                         i_pgm_enrol_tot_grace_prd_gn,
                                         i_account_group_objid,
                                         i_member_objid,
                                         i_member_status,
                                         i_member_start_date,
                                         i_member_end_date,
                                         i_member_master_flag,
                                         i_service_order_stage_objid,
                                         i_service_order_stage_status,
                                         i_min_part_inst_objid,
                                         i_min_part_inst_status,
                                         i_min_part_inst_code,
                                         i_min_cool_end_date,
                                         i_min_warr_end_date,
                                         i_repair_date,
                                         i_min_personality_objid,
                                         i_min_new_personality_objid,
                                         i_min_to_esn_part_inst_objid,
                                         i_last_cycle_date,
                                         i_port_in,
                                         i_psms_outbox_objid,
                                         i_psms_outbox_status,
                                         i_ota_feat_objid,
                                         i_ota_feat_ild_account,
                                         i_ota_feat_ild_carr_status,
                                         i_ota_feat_ild_prog_status,
                                         i_click_plan_hist_objid,
                                         i_click_plan_hist_end_date,
                                         i_fvm_status,
                                         i_fvm_number,
                                         i_ota_transaction_objid,
                                         i_ota_transaction_status,
                                         i_ota_transaction_reason,
                                         i_request_xml,
                                         i_x_client_id,    --CR51128
                                         i_account_no,     --CR56056
                                         i_carrier,
                                         i_password_pin,
                                         i_v_key,
                                         i_full_name,
                                         i_billing_address,
                                         i_last_4_ssn,
                                         i_account_alpha,
                                         i_pin_alpha,
                                         i_zip_code);      --CR56056

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('log_request SQL error msg :'||sqlerrm);
END log_request;
--
--
PROCEDURE validate_carrier_attributes (i_carrier           IN  VARCHAR2,
                                       i_request_no        IN  VARCHAR2,
                                       i_min               IN  VARCHAR2,
                                       i_current_esn       IN  VARCHAR2,
                                       i_account_no        IN  VARCHAR2,
                                       i_password_pin      IN  VARCHAR2,
                                       i_v_key             IN  VARCHAR2,
                                       i_full_name         IN  VARCHAR2,
                                       i_billing_address   IN  VARCHAR2,
                                       i_last_4_ssn        IN  VARCHAR2,
                                       i_is_account_alpha  IN  VARCHAR2,
                                       i_is_pin_alpha      IN  VARCHAR2,
                                       i_zip               IN  VARCHAR2,
                                       i_portout_carrier   IN  VARCHAR2,
                                       i_request_xml       IN  XMLTYPE,
                                       o_err_num           OUT NUMBER,
                                       o_err_code          OUT VARCHAR2,
                                       o_err_msg           OUT VARCHAR2)
AS

  portout_tab            port_out_attribute_tab;
  c                      customer_type := customer_type (i_esn => NULL, i_min => i_min);

  l_request_status       VARCHAR2(240);
  l_err_code             VARCHAR2(240);
  l_request_date         DATE;
  l_request_count        NUMBER := 0;
  n_carrier_config_count NUMBER;
  n_min_exists           NUMBER := 0;
  n_template_exists      NUMBER := 0;

BEGIN

  -- CR56056 - Validating Inputs
  IF (TRIM(i_carrier) IS NULL) THEN
    o_err_num  := 10;
    o_err_code := 'CARRIER_INPUT_VALUE_MISSING';
    o_err_msg  := 'INPUT VALIDATION FAILED: CARRIER IS MANDATORY - NULL FOUND';
    RETURN;
  ELSIF (TRIM(i_min) IS NULL) THEN
    o_err_num  := 20;
    o_err_code := 'MDN_NOT_FOUND';
    o_err_msg  := 'INPUT VALIDATION FAILED: MIN IS MANDATORY - NULL FOUND';
    RETURN;
  ELSIF (TRIM(i_request_no) IS NULL) THEN
    o_err_num  := 30;
    o_err_code := 'REQUEST_ID_INPUT_VALUE_MISSING';
    o_err_msg  := 'INPUT VALIDATION FAILED: REQUEST_NO IS MANDATORY - NULL FOUND';
    RETURN;
  END IF;

  -- CR51128 - Validate if a request was already created
  -- CR56056 - Table sa.x_port_out_request_log has unique index on min, request_no and request_type
  BEGIN
    SELECT COUNT(1),
           MAX(request_date),
           MAX(status)
      INTO l_request_count,
           l_request_date,
           l_request_status
      FROM sa.x_port_out_request_log
     WHERE min = i_min
       AND request_no = i_request_no
       AND request_type = 'R';
  EXCEPTION
    WHEN OTHERS THEN
      l_request_count  := 0;
      l_request_date   := NULL;
      l_request_status := NULL;
  END;
  --
  dbms_output.put_line('l_request_count count :'||l_request_count);
  --
  IF (l_request_count > 0) THEN

   IF l_request_status = 'SUCCESS' THEN
     o_err_num  := 40;
     o_err_code := l_request_status;
     o_err_msg  := NULL;
     RETURN;
   ELSE
     o_err_num  := 50;
     o_err_code := 'DUPLICATE_REQUEST_NUMBER';
     o_err_msg  := 'Request number already exists with date :'||TO_CHAR(l_request_date,'DD-MON-YYYY HH24:MI:SS');
     RETURN;
   END IF;

  END IF;
  --
  -- validate carrier configuration
  SELECT COUNT(1)
    INTO n_carrier_config_count
    FROM sa.x_port_carriers
   WHERE port_type    = 'PORT OUT'
     AND phone_type   = 'Port Out'
     AND carrier_name = TRIM(i_carrier);

  IF n_carrier_config_count = 0 THEN
    o_err_num  := 60;
    o_err_code := 'MISSING_CARRIER_CONFIGURATION_IN_X_PORT_CARRIERS_TABLE';
    o_err_msg  := o_err_code||' - '||TRIM(i_carrier);
    RETURN;
  ELSIF n_carrier_config_count > 1 THEN
    o_err_num  := 70;
    o_err_code := 'MULTIPLE_CONFIGURATION_ENTRIES_IN_X_PORT_CARRIERS_TABLE';
    o_err_msg  := o_err_code||' - '||TRIM(i_carrier);
    RETURN;
  END IF;

  -- CR56056 - validate if MIN exists in Clarify
  SELECT COUNT(1)
    INTO n_min_exists
    FROM sa.table_part_inst
   WHERE x_domain = 'LINES'
     AND part_serial_no = TRIM(i_min);
  --
  IF n_min_exists = 0 THEN
    o_err_num  := 80;
    o_err_code := 'MDN_NOT_FOUND';
    o_err_msg  := 'MIN NOT FOUND IN PART INST TABLE: '||TRIM(i_min);
    RETURN;
  END IF;

  -- CR56056 - Check if input templte is not null and valid
  SELECT COUNT(1)
    INTO n_template_exists
    FROM sa.table_x_trans_profile
   WHERE x_template = i_portout_carrier;
  --
  IF n_template_exists = 0 THEN
    o_err_num  := 90;
    o_err_code := 'TEMPLATE_INPUT_VALUE_MISSING';
    o_err_msg  := 'INPUT VALIDATION FAILED: TEMPLATE IS MANDATORY: '||TRIM(i_portout_carrier);
    RETURN;
  END IF;

  --
  -- CR56056 - Query to map input parameters, with config table x_port_carriers flags
  -- CR56056 - It returns parameter values for the attributes set to Y in x_port_carriers
  -- CR56056 - It assigns null_input_flag and validation_message when input parameter is NULL
  WITH p
  AS
  ( SELECT x.flags flags,
           x.flag_value flag_value,
           CASE WHEN  x.flags = 'MIN_TO_TRANSFER'  THEN TRIM(i_min)
                WHEN  x.flags = 'CURRENT_ESN'      THEN TRIM(i_current_esn)
                WHEN  x.flags = 'ACCOUNT_NO'       THEN TRIM(i_account_no)
                WHEN  x.flags = 'PASSWORD_PIN'     THEN TRIM(i_password_pin)
                WHEN  x.flags = 'V_KEY'            THEN TRIM(i_v_key)
                WHEN  x.flags = 'FULL_NAME'        THEN TRIM(i_full_name)
                WHEN  x.flags = 'BILLING_ADDRESS'  THEN TRIM(i_billing_address)
                WHEN  x.flags = 'LAST_4_SSN'       THEN TRIM(i_last_4_ssn)
                WHEN  x.flags = 'IS_ACCOUNT_ALPHA' THEN TRIM(i_is_account_alpha)
                WHEN  x.flags = 'IS_PIN_ALPHA'     THEN TRIM(i_is_pin_alpha)
                WHEN  x.flags = 'ZIP_CODE_FLAG'    THEN TRIM(i_zip)
                WHEN  x.flags = 'ESN_ACCOUNT_FLAG' THEN TRIM(i_account_no)
                ELSE NULL
           END param_value
      FROM sa.x_port_carriers
           UNPIVOT (flag_value FOR flags IN ( min_to_transfer,
                                              current_esn,
                                              account_no,
                                              password_pin,
                                              v_key,
                                              full_name,
                                              billing_address,
                                              last_4_ssn,
                                              is_account_alpha,
                                              is_pin_alpha,
                                              zip_code_flag,
                                              esn_account_flag )
                   ) x
     WHERE flag_value       = 'Y'
       AND port_type        = 'PORT OUT'
       AND phone_type       = 'Port Out'
       AND carrier_name     = TRIM(i_carrier) )
  SELECT port_out_attribute_type (flags,                                 -- key_column with column name
                                  flag_value,                            -- key_value is the value in the column matched to carrier
                                  param_value,                           -- param_value is the value input as parameter
                                  NVL2(param_value, 'N', 'Y'),           -- null_input_flag to assign Y if input parameter is null
                                  'Y',                                   -- valid_input_flag to be set to default Y
                                  NVL(param_value, flags || '_IS_NULL')) -- validation_message set validation message to indicate input is NULL
  BULK   COLLECT
  INTO   portout_tab
  FROM   p;

  SELECT LISTAGG(key_column||' INPUT VALUE MISSING', ' ; ') WITHIN GROUP (ORDER BY key_column),
         MIN(validation_message)
  INTO   o_err_msg,
         l_err_code
  FROM   TABLE(portout_tab)
  WHERE  null_input_flag = 'Y';

  IF o_err_msg IS NOT NULL THEN

    IF l_err_code    = 'PASSWORD_PIN_IS_NULL' THEN
      o_err_code    := 'PASS_PIN_REQ_OR_INCORRECT';
    ELSIF l_err_code = 'ACCOUNT_NO_IS_NULL' THEN
      o_err_code    := 'ACCOUNT_NUM_REQ_OR_INCORRECT';
    ELSIF l_err_code = 'ESN_ACCOUNT_FLAG_IS_NULL' THEN
      o_err_code    := 'ACCOUNT_NUM_REQ_OR_INCORRECT';
    ELSIF l_err_code = 'ZIP_CODE_FLAG_IS_NULL' THEN
      o_err_code    := 'ZIP_CODE_REQ_OR_INCORRECT';
    ELSE
      o_err_code    := 'INPUT_VALIDATION_ERROR';   --Default value
    END IF;

    o_err_num  := 100;
    o_err_msg  := o_err_msg ||' - Carrier: '||TRIM(i_carrier);
    RETURN;

  END IF;

  -- get ESN attributes based on MIN
  c := c.get_web_user_attributes;

  dbms_output.put_line('c.esn :'                  || c.esn);
  dbms_output.put_line('c.iccid :'                || c.iccid);
  dbms_output.put_line('c.security_pin :'         || c.security_pin);
  dbms_output.put_line('c.contact_security_pin :' || c.contact_security_pin);
  dbms_output.put_line('c.zipcode :'              || c.zipcode);

  -- CR56056 - compare the values against clarify
  FOR i in 1 .. portout_tab.COUNT LOOP
    --
    dbms_output.put_line('key_column :'      ||portout_tab(i).key_column);
    dbms_output.put_line('param_value :'     ||portout_tab(i).param_value);
    dbms_output.put_line('null_input_flag :' ||portout_tab(i).null_input_flag);

    IF portout_tab(i).null_input_flag = 'N' THEN

      -- CR56056 - Check if ESN or SIM are either valid input values
      IF portout_tab(i).key_column = 'ACCOUNT_NO' AND
         portout_tab(i).param_value != NVL(c.esn,  '-1') AND
         portout_tab(i).param_value != NVL(c.iccid,'-1') THEN

        portout_tab(i).valid_input_flag   := 'N';
        portout_tab(i).validation_message := 'ACCOUNT_NUM_REQ_OR_INCORRECT';

      END IF;

      -- CR56056 - Check if contact security PIN or account security PIN are either valid input values
      IF portout_tab(i).key_column = 'PASSWORD_PIN' AND
         portout_tab(i).param_value != NVL(c.contact_security_pin, '-1') AND
         portout_tab(i).param_value != NVL(c.security_pin, '-1') THEN

        portout_tab(i).valid_input_flag   := 'N';
        portout_tab(i).validation_message := 'PASS_PIN_REQ_OR_INCORRECT';

      END IF;

      -- CR56056 - Check if ZIP code is a valid input
      IF portout_tab(i).key_column = 'ZIP_CODE_FLAG' AND
         portout_tab(i).param_value != NVL(c.zipcode, '-1') THEN

        portout_tab(i).valid_input_flag   := 'N';
        portout_tab(i).validation_message := 'ZIP_CODE_REQ_OR_INCORRECT';

      END IF;

      -- CR56056 - Check if ESN only is valid input
      IF portout_tab(i).key_column = 'ESN_ACCOUNT_FLAG' AND
         portout_tab(i).param_value != NVL(c.esn,  '-1') THEN

        portout_tab(i).valid_input_flag   := 'N';
        portout_tab(i).validation_message := 'ACCOUNT_NUM_REQ_OR_INCORRECT';

      END IF;

    END IF;
    --
  END LOOP;

  SELECT LISTAGG('INPUT VALIDATION ERROR ('||key_column||')', ' ; ') WITHIN GROUP (ORDER BY key_column),
         MIN(validation_message)
  INTO   o_err_msg,
         o_err_code
  FROM   TABLE(portout_tab)
  WHERE  valid_input_flag = 'N';

  IF o_err_msg IS NOT NULL  THEN
    o_err_num  := 110;
    o_err_msg  := o_err_msg ||' - Carrier: '||TRIM(i_carrier);
    RETURN;
  END IF;

  o_err_num  := 0;
  o_err_code := 'SUCCESS';
  o_err_msg  := o_err_code;

EXCEPTION
  WHEN OTHERS THEN
    o_err_code := 120;
    o_err_code := 'CARRIER_ATTRIBUTES_VALIDATION_ERROR';
    o_err_msg  := 'ERROR IN PORT_OUT_PKG.VALIDATE_CARRIER_ATTRIBUTES: '||SQLERRM;
END validate_carrier_attributes;
--
--
PROCEDURE pageplus_port_out_case (i_esn           IN  VARCHAR2,
                                  i_min           IN  VARCHAR2,
                                  i_iccid         IN  VARCHAR2,
                                  i_nnsp          IN  VARCHAR2,
                                  i_rate_plan     IN  VARCHAR2,
                                  o_error_code    OUT NUMBER,
                                  o_error_message OUT VARCHAR2)
IS
  --
  l_new_case_objid         NUMBER := 0;
  l_new_condition_objid    NUMBER := 0;
  l_new_act_entry_objid    NUMBER := 0;
  l_new_case_id            NUMBER := NULL;
  l_new_case_id_format     VARCHAR2(20) := NULL;
  l_carrier                VARCHAR2(200);
  --
BEGIN
  --
  IF i_esn IS NULL AND i_min IS NULL THEN
    o_error_code    := 1;
    o_error_message := 'ESN AND MIN ARE MANDATORY: '||i_esn||' - '||i_min;
    RETURN;
  END IF;

  -- case id sequence
  sa.next_id('Case ID', l_new_case_id, l_new_case_id_format);

  l_new_case_objid         := seq('case');
  l_new_condition_objid    := seq('condition');
  l_new_act_entry_objid    := seq('act_entry');

  -- table_case
  INSERT INTO table_case (objid,
                          title,
                          s_title,
                          id_number,
                          x_case_type,
                          casests2gbst_elm,
                          case_type_lvl2,
                          case_type_lvl3,
                          customer_code,
                          creation_time,
                          case_owner2user,
                          case_originator2user,
                          x_esn,
                          x_min,
                          x_msid,
                          x_iccid,
                          x_carrier_name,
                          case_state2condition,
                          oper_system)
                  VALUES (l_new_case_objid,        --objid,
                          'Auto Port Out',         --title,
                          'AUTO PORT OUT',         --s_title,
                          l_new_case_id,           --id_number,
                          'Port Out',              --x_case_type,
                          268435578,               --casests2gbst_elm,
                          'PAGEPLUS',              --case_type_lvl2,
                          'Port Successful',       --case_type_lvl3,
                          'PAGE_BATCH',            --customer_code,
                          SYSDATE,                 --creation_time,
                          268435556,               --case_owner2user,
                          268435556,               --case_originator2user,
                          i_esn,                   --x_esn,
                          i_min,                   --x_min,
                          i_min,                   --x_msid,
                          NVL(i_iccid, null),      --x_iccid,
                          'VERIZON PAGE',          --x_carrier_name,
                          l_new_condition_objid,   --case_state2condition,
                          'Port Successful');      --oper_system

  -- table_x_case_detail for port out carrier
  BEGIN
    SELECT description
    INTO   l_carrier
    FROM   sa.x_nnsp_mapping
    WHERE  id = i_nnsp
    AND    ROWNUM = 1;
  EXCEPTION
    WHEN OTHERS THEN
      l_carrier := 'OTHER';
  END;

  -- case details
  INSERT INTO sa.table_x_case_detail (objid,
                                      x_name,
                                      x_value,
                                      detail2case)
                              VALUES (sa.seq('x_case_detail'),
                                      'NEW_SERVICE_PROVIDER',
                                      l_carrier,
                                      l_new_case_objid);

  -- case details rate plan
  INSERT INTO sa.table_x_case_detail (objid,
                                      x_name,
                                      x_value,
                                      detail2case)
                              VALUES (sa.seq('x_case_detail'),
                                      'RATE_PLAN',
                                      i_rate_plan,
                                      l_new_case_objid);

  -- table_condition
  INSERT INTO sa.table_condition (objid,
                                  condition,
                                  title,
                                  s_title,
                                  wipbin_time,
                                  sequence_num)
                          VALUES (l_new_condition_objid,
                                  4,
                                  'Closed',
                                  'CLOSED',
                                  SYSDATE,
                                  0);

  -- table_act_entry
  INSERT INTO sa.table_act_entry (objid,
                                  act_code,
                                  entry_time,
                                  addnl_info,
                                  act_entry2case,
                                  act_entry2user,
                                  entry_name2gbst_elm)
                          VALUES (l_new_act_entry_objid,
                                  200,
                                  SYSDATE,
                                  'Status = Closed, Resolution Code =Not Available, State = Open.',
                                  l_new_case_objid,
                                  268435556,
                                  268435623);

  o_error_code    := 0;
  o_error_message := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    o_error_code    := 1;
    o_error_message := SQLERRM;
END pageplus_port_out_case;
--
--
--CR51293 - overriden procedure created
PROCEDURE winback_offer_accepted (i_min               IN  VARCHAR2,
                                  i_case_id_number    IN  VARCHAR2,
                                  o_work_force_pin_pn OUT VARCHAR2,
                                  o_response          OUT VARCHAR2) AS

 CURSOR c_getwinback (l_winback_case_id_number IN NUMBER) IS
 SELECT *
 FROM   sa.x_portout_winback_log
 WHERE  winback_case_id_number = l_winback_case_id_number
 AND    ROWNUM = 1;

 r_getwinback c_getwinback%ROWTYPE;
 --
 igt          sa.ig_transaction_type := ig_transaction_type();
 ig           sa.ig_transaction_type;
 l_task_id    NUMBER;
 l_cos        VARCHAR2(30);
 l_promo_type VARCHAR2(30);
 l_sp_objid   NUMBER;

BEGIN

 --Proceed with Creating IG order type UPO
 IF NVL(i_case_id_number,0) = '0' OR i_min IS NULL THEN
   o_response := 'CASE ID OR MIN NUMBER IS NOT PASSED';
   RETURN;
 END IF;

 OPEN c_getwinback (i_case_id_number);
 FETCH c_getwinback INTO r_getwinback;

 IF c_getwinback%FOUND THEN
   -- Set the values for IG
   o_response := 'ACCOUNT INCORRECT';

   sp_seq('task', l_task_id);

   igt := ig_transaction_type (i_esn                 => r_getwinback.esn,
                               i_action_item_id      => l_task_id,
                               i_msid                => i_min,
                               i_min                 => i_min,
                               i_technology_flag     => 'C',
                               i_order_type          => 'UPO', -- New order type update port out
                               i_template            => 'RSS',
                               i_rate_plan           => NULL,
                               i_zip_code            => NULL,
                               i_transaction_id      => NULL,
                               i_phone_manf          => NULL,
                               i_carrier_id          => NULL,
                               i_iccid               => NULL,
                               i_network_login       => NULL,
                               i_network_password    => NULL,
                               i_account_num         => '1161',
                               i_transmission_method => 'AOL',
                               i_status              => 'Q',
                               i_status_message      => o_response||' - '||r_getwinback.request_no,
                               i_application_system  => NULL,
                               i_skip_ig_validation  => 'Y',
                               i_old_esn             => r_getwinback.osp_account_no);

   -- call the insert method
   ig := igt.ins;

   -- log
   log_request (i_min                     => i_min,
                i_request_no              => r_getwinback.request_no,
                i_request_type            => 'R',
                i_short_parent_name       => r_getwinback.short_parent_name,
                i_case_id_number          => NULL,
                i_desired_due_date        => r_getwinback.desired_due_date,
                i_nnsp                    => r_getwinback.nnsp,
                i_directional_indicator   => r_getwinback.directional_indicator,
                i_osp_account_no          => r_getwinback.osp_account_no,
                i_response                => o_response,
                i_esn                     => r_getwinback.esn,
                i_brand_shared_group_flag => NULL,
                i_request_xml             => r_getwinback.request_xml);

   l_sp_objid := sa.customer_info.get_service_plan_objid(i_esn => r_getwinback.esn);

   --Get the new COS from the Offer Table

   BEGIN

     SELECT cos,
            part_number,
            promo_type
     INTO   l_cos,
            o_work_force_pin_pn,
            l_promo_type
     FROM   sa.x_offer_info a
     WHERE  a.name = 'WINBACK'
     AND    SYSDATE BETWEEN start_date and end_date
     AND    a.sp_objid = l_sp_objid
     AND    ROWNUM = 1; --One record
   EXCEPTION
     WHEN OTHERS THEN
       l_cos := NULL;
       o_work_force_pin_pn := NULL;
   END;

   IF l_cos IS NULL THEN
     o_response := 'NO PROMOTION FOR THIS SERVICE PLAN :'||l_sp_objid;
     dbms_output.put_line('o_response: '||o_response);
     RETURN;
   END IF;

   --Update WINBACK LOG with the SP and promo_type.
   sa.PORT_OUT_PKG.ins_upd_port_out_request (i_min                    => i_min,
                                             i_winback_case_id_number => i_case_id_number,
                                             i_sp_objid               => l_sp_objid,
                                             i_promo_type             => l_promo_type,
                                             i_request_xml            => NULL,
                                             o_response               => o_response);

   DBMS_OUTPUT.PUT_LINE('Updating Status Response: '||o_response);

   -- Insert Record into  x_policy_rule_subscriber
   MERGE INTO sa.x_policy_rule_subscriber t
   USING (SELECT i_min as min,
                 r_getwinback.esn as esn,
                 l_cos as cos
            FROM dual) s
   ON (t.esn = s.esn)
   WHEN MATCHED THEN
     UPDATE
     SET t.cos = s.cos,
         t.update_timestamp = sysdate
   WHEN NOT MATCHED THEN
     INSERT (objid,
             min,
             esn,
             cos,
             start_date,
             end_date,
             insert_timestamp,
             update_timestamp,
             inactive_flag)
     VALUES (sequ_policy_rule_subscriber.NEXTVAL,
             s.min,
             s.esn,
             s.cos,
             sysdate,
             TO_DATE('12/31/2055', 'MM/DD/YYYY'),
             sysdate,
             sysdate,
             'Y');

   o_response := 'SUCCESS';

 ELSE
   o_response := 'CASE IS NOT FOUND IN X_PORTOUT_WINBACK_LOG';
 END IF;

 CLOSE c_getwinback;

EXCEPTION
  WHEN OTHERS THEN
    -- Return response to caller
    o_response := 'ERROR CREATING UPO IG: ' || SQLERRM;
    ROLLBACK;
END winback_offer_accepted;
--
--
PROCEDURE create_request (i_min             IN  VARCHAR2,
                          i_case_id_number  IN  VARCHAR2,
                          o_response        OUT VARCHAR2) AS

 CURSOR c_getwinback (l_winback_case_id_number IN NUMBER) IS
 SELECT *
   FROM sa.x_portout_winback_log
  WHERE winback_case_id_number = l_winback_case_id_number
    AND ROWNUM = 1;

 r_getwinback       c_getwinback%ROWTYPE;
 v_sms_send_flag    VARCHAR2(10);
 v_case_id_number   VARCHAR2(255);
 v_portout_carrier  VARCHAR2(50);
 v_response_message VARCHAR2(2400);

BEGIN

 v_case_id_number := i_case_id_number;

 --Proceed with PORT OUT CASE
 IF NVL(i_case_id_number,'0') = '0' OR i_min IS NULL THEN
   o_response := 'CASE ID OR MIN NUMBER IS NOT PASSED: '||i_case_id_number||' - '||i_min;
   RETURN;
 END IF;

 OPEN c_getwinback (i_case_id_number);
 FETCH c_getwinback INTO r_getwinback;

 IF c_getwinback%FOUND THEN
   --
   create_request (i_min                    => i_min,
                   i_request_no             => r_getwinback.request_no,
                   i_short_parent_name      => r_getwinback.short_parent_name,
                   i_desired_due_date       => r_getwinback.desired_due_date,
                   i_nnsp                   => r_getwinback.nnsp,
                   i_directional_indicator  => r_getwinback.directional_indicator,
                   i_osp_account_no         => r_getwinback.osp_account_no,
                   i_request_xml            => r_getwinback.request_xml,
                   i_portout_carrier        => r_getwinback.portout_carrier,
                   o_response               => o_response,
                   o_case_id_number         => v_case_id_number,
                   o_sms_send_flag          => v_sms_send_flag,
                   o_response_message       => v_response_message);
   --
   --update x_policy_rule_subscriber to inactivate previous offer if any
   UPDATE sa.x_policy_rule_subscriber
      SET inactive_flag = 'Y',
          update_timestamp = SYSDATE
    WHERE min = i_min
      AND esn = r_getwinback.esn
      AND inactive_flag = 'N';
   --
   o_response := 'SUCCESS';
   --
 ELSE
   --
   o_response := 'CASE IS NOT FOUND IN X_PORTOUT_WINBACK_LOG';
   --
 END IF;

 CLOSE c_getwinback;

EXCEPTION
  WHEN OTHERS THEN
    -- Return response to caller
    o_response := 'ERROR CREATING PORT OUT REQUEST: ' || SUBSTR(SQLERRM,1,200);
    ROLLBACK;
END create_request;
--
--
PROCEDURE create_request (i_min                    IN  VARCHAR2,
                          i_request_no             IN  VARCHAR2,
                          i_short_parent_name      IN  VARCHAR2,
                          i_desired_due_date       IN  DATE,
                          i_nnsp                   IN  VARCHAR2,
                          i_directional_indicator  IN  VARCHAR2,
                          i_osp_account_no         IN  VARCHAR2,
                          i_request_xml            IN  XMLTYPE,
                          o_response               OUT VARCHAR2) AS

 v_case_id_number   VARCHAR2(255);
 v_sms_send_flag    VARCHAR2(10);
 v_portout_carrier  VARCHAR2(50);
 v_response_message VARCHAR2(2400);

BEGIN
  --
  create_request (i_min                    => i_min,
                  i_request_no             => i_request_no,
                  i_short_parent_name      => i_short_parent_name,
                  i_desired_due_date       => i_desired_due_date,
                  i_nnsp                   => i_nnsp,
                  i_directional_indicator  => i_directional_indicator,
                  i_osp_account_no         => i_osp_account_no,
                  i_request_xml            => i_request_xml,
                  i_portout_carrier        => v_portout_carrier,
                  o_response               => o_response,
                  o_case_id_number         => v_case_id_number,
                  o_sms_send_flag          => v_sms_send_flag,
                  o_response_message       => v_response_message);
  --
EXCEPTION
  WHEN OTHERS THEN
    -- Return response to caller
    o_response := 'ERROR CREATING PORT OUT REQUEST: ' || SUBSTR(SQLERRM,1,200);
    ROLLBACK;
END create_request;
--
--
PROCEDURE create_request (i_min                    IN  VARCHAR2,
                          i_request_no             IN  VARCHAR2,
                          i_short_parent_name      IN  VARCHAR2  DEFAULT NULL,  -- CR56056
                          i_desired_due_date       IN  DATE      DEFAULT NULL,  -- CR56056
                          i_nnsp                   IN  VARCHAR2  DEFAULT NULL,  -- CR56056
                          i_directional_indicator  IN  VARCHAR2  DEFAULT NULL,  -- CR56056
                          i_osp_account_no         IN  VARCHAR2,
                          i_request_xml            IN  XMLTYPE,
                          i_portout_carrier        IN  VARCHAR2,
                          o_response               OUT VARCHAR2,
                          o_case_id_number         IN  OUT VARCHAR2,
                          o_sms_send_flag          OUT VARCHAR2,
                          i_x_client_id            IN  VARCHAR2  DEFAULT NULL,  -- CR51128
                          i_carrier                IN  VARCHAR2  DEFAULT NULL,  -- CR56462 Starts
                          i_current_esn            IN  VARCHAR2  DEFAULT NULL,
                          i_account_no             IN  VARCHAR2  DEFAULT NULL,
                          i_password_pin           IN  VARCHAR2  DEFAULT NULL,
                          i_v_key                  IN  VARCHAR2  DEFAULT NULL,
                          i_full_name              IN  VARCHAR2  DEFAULT NULL,
                          i_billing_address        IN  VARCHAR2  DEFAULT NULL,
                          i_last_4_ssn             IN  VARCHAR2  DEFAULT NULL,
                          i_is_account_alpha       IN  VARCHAR2  DEFAULT NULL,
                          i_is_pin_alpha           IN  VARCHAR2  DEFAULT NULL,
                          i_zip                    IN  VARCHAR2  DEFAULT NULL,  -- CR56462 ends
                          o_response_message       OUT VARCHAR2) AS

 -- customer type
 cst sa.customer_type   := customer_type();
 s   sa.customer_type   := customer_type();
 sub sa.subscriber_type := sa.subscriber_type (i_esn => NULL, i_min => i_min);

 -- call trans type
 ct sa.call_trans_type  := call_trans_type();
 c  sa.call_trans_type;

 -- task type
 tt sa.task_type        := task_type();
 t  sa.task_type;

 --
 igt sa.ig_transaction_type := ig_transaction_type();
 ig  sa.ig_transaction_type;

 l_case_objid     NUMBER;
 l_user_objid     NUMBER;
 l_db_user        VARCHAR2(30);
 l_case_status    VARCHAR2(240);
 l_case_msg       VARCHAR2(240);
 l_case_id        table_case.id_number%TYPE;
 l_return         VARCHAR2(240);
 l_returnmsg      VARCHAR2(2400);
 l_task_id        NUMBER;
 l_carrier_desc   x_nnsp_mapping.description%TYPE := NULL; --CR 48685
 l_sms_send_flag  VARCHAR2(200);
 l_proceed_flag   VARCHAR2(200);
 l_errnum         NUMBER;
 l_errcode        VARCHAR2(240);
 l_errmsg         VARCHAR2(2400);
 l_x_carrier      VARCHAR2(30);  -- CR51128 Starts
 l_nw_login       VARCHAR2(30);
 l_nw_pwd         VARCHAR2(240);
 l_tech_flag      VARCHAR2(240);
 l_app_sys        VARCHAR2(240);
 l_acc_num        VARCHAR2(240);
 l_carr_name      VARCHAR2(240); -- CR51128 Ends
 l_min_portred    VARCHAR2(1);   -- CR55926 starts
 v_ctobjid        NUMBER;
 v_esn            VARCHAR2(240);
 v_ctcarobjid     NUMBER;        -- CR55926 Ends
 --
BEGIN
 --
 -- CR56056 - Commits from the process were removed because the calling processes (intergate) will auto-commit (Venu).
 --
 o_response_message := NULL;
 o_sms_send_flag    := 'N';
 l_min_portred      := 'N';  -- CR55926
 --
 -- CR56056 - calling the customer_type retrieve method plus port out attrs func.
 s := cst.get_port_out_attributes (i_min => i_min);
 --
 -- CR56056 - Must use carrier value from intergate to obtain short parent name
 s.short_parent_name := s.get_short_parent_name (i_parent_name => i_carrier);
 --
 dbms_output.put_line('s.short_parent_name :'||s.short_parent_name);
 dbms_output.put_line('s.esn :'||s.esn);
 dbms_output.put_line('s.response :'||s.response);
 --
 -- CR51128 - CR56056 - short_parent_name value
 IF i_x_client_id IN('6','36','91') AND NVL(s.short_parent_name,'XXX') = 'TMO' THEN
   l_nw_login    := 'tracfone';
   l_nw_pwd      := 'Tr@cfon3';
   l_tech_flag   := 'G';
   l_app_sys     := 'IG';
 END IF;

 SELECT DECODE(s.short_parent_name, 'TMO', NULL, '1161')
   INTO l_acc_num
   FROM dual;
 -- CR51128
 --
 -- CR56056 - Call to new validation procedure
 -- CR56056 - Cannot use i_account_no for Verizon and TMO
 validate_carrier_attributes (s.short_parent_name,
                              i_request_no,
                              i_min,
                              i_current_esn,
                              i_osp_account_no,
                              i_password_pin,
                              i_v_key,
                              i_full_name,
                              i_billing_address,
                              i_last_4_ssn,
                              i_is_account_alpha,
                              i_is_pin_alpha,
                              i_zip,
                              i_portout_carrier,
                              i_request_xml,
                              l_errnum,
                              l_errcode,
                              l_errmsg);

 dbms_output.put_line('validate_carrier_attributes l_errnum  :'||l_errnum);
 dbms_output.put_line('validate_carrier_attributes l_errcode :'||l_errcode);
 dbms_output.put_line('validate_carrier_attributes l_errmsg  :'||l_errmsg);

 IF NVL(l_errnum, -1) != 0 THEN

   -- Set the values for IG
   o_response := l_errcode;
   o_response_message := l_errmsg;

   sp_seq('task', l_task_id);

   igt := ig_transaction_type (i_esn                  => s.esn,
                               i_action_item_id       => l_task_id,
                               i_msid                 => i_min,
                               i_min                  => i_min,
                               i_technology_flag      => NVL(l_tech_flag,'C'), --CR51128
                               i_order_type           => 'UPO', -- New order type update port out
                               i_template             => i_portout_carrier,
                               i_rate_plan            => NULL,
                               i_zip_code             => i_zip,
                               i_transaction_id       => NULL,
                               i_phone_manf           => NULL,
                               i_carrier_id           => NULL,
                               i_iccid                => NULL,
                               i_network_login        => NVL(l_nw_login,NULL), --CR51128
                               i_network_password     => NVL(l_nw_pwd,NULL),   --CR51128
                               i_account_num          => l_acc_num,            --CR51128
                               i_transmission_method  => 'AOL',
                               i_status               => 'Q',
                               i_status_message       => o_response||' - '||i_request_no,
                               i_application_system   => NVL(l_app_sys,NULL),  --CR51128
                               i_skip_ig_validation   => 'Y',
                               i_old_esn              => i_osp_account_no,
                               i_pin                  => i_password_pin);

   -- call the insert method
   ig  := igt.ins;

   dbms_output.put_line('ig status :'  ||ig.status);
   dbms_output.put_line('ig response :'||ig.response);

   log_request (i_min                     => i_min,
                i_request_no              => i_request_no,
                i_request_type            => 'R',
                i_short_parent_name       => s.short_parent_name,
                i_case_id_number          => NULL,
                i_desired_due_date        => i_desired_due_date,
                i_nnsp                    => i_nnsp,
                i_directional_indicator   => i_directional_indicator,
                i_osp_account_no          => i_osp_account_no,
                i_response                => o_response,
                i_error_message           => o_response_message,
                i_esn                     => s.esn,
                i_brand_shared_group_flag => NULL,
                i_request_xml             => i_request_xml,
                i_x_client_id             => i_x_client_id,
                i_account_no              => i_account_no,
                i_carrier                 => i_carrier,
                i_password_pin            => i_password_pin,
                i_v_key                   => i_v_key,
                i_full_name               => i_full_name,
                i_billing_address         => i_billing_address,
                i_last_4_ssn              => i_last_4_ssn,
                i_account_alpha           => i_is_account_alpha,
                i_pin_alpha               => i_is_pin_alpha,
                i_zip_code                => i_zip);

   IF (sub.status LIKE '%SUCCESS%') AND (sub.brand = 'PAGEPLUS') THEN
     --
     pageplus_port_out_case (i_esn           => sub.pcrf_esn,
                             i_min           => sub.pcrf_min,
                             i_iccid         => sub.iccid,
                             i_nnsp          => i_nnsp,
                             i_rate_plan     => sub.rate_plan,
                             o_error_code    => l_errnum,
                             o_error_message => l_errmsg);
     --
     IF l_errnum <> 0 THEN
       log_request (i_min                      =>  i_min,
                    i_request_no               =>  i_request_no,
                    i_request_type             =>  'R',
                    i_short_parent_name        =>  s.short_parent_name,
                    i_case_id_number           =>  NULL,
                    i_desired_due_date         =>  i_desired_due_date,
                    i_nnsp                     =>  i_nnsp,
                    i_directional_indicator    =>  i_directional_indicator,
                    i_osp_account_no           =>  i_osp_account_no,
                    i_response                 =>  'PAGEPLUS',
                    i_error_message            =>  'Pageplus - ' || SUBSTR(l_errmsg,1, 200),
                    i_esn                      =>  NULL,
                    i_brand_shared_group_flag  =>  NULL,
                    i_request_xml              =>  i_request_xml);
     END IF;
     --
   END IF;
   --
   dbms_output.put_line('o_response :' ||o_response);
   --
   RETURN;
   --
 END IF;
 --
 -- Validate if new TMO process is being called with another Carrier
 -- Commented code as part if CR55926
 -- CR56056 - s.short_parent_name is mapped to input carrier while s.parent_name to ESN attr.
 IF NVL(s.short_parent_name,'XXX') = 'TMO' THEN

   dbms_output.put_line('MIN carrier s.parent_name :'||NVL(s.parent_name,'Not Found'));

   IF NVL(s.parent_name,'XXX') NOT LIKE 'T%MO%' THEN

     l_min_portred := 'Y';   -- CR55926

     BEGIN
       SELECT call_trans_obj,
              esn,
              x_call_trans2carrier
         INTO v_ctobjid,
              v_esn,
              v_ctcarobjid
         FROM (SELECT ct.x_action_text,
                      ct.objid call_trans_obj,
                      ct.call_trans2site_part,
                      ct.x_call_trans2carrier,
                      (SELECT tc.x_carrier_id||' - '||tc.x_mkt_submkt_name
                         FROM sa.table_x_carrier tc
                        WHERE tc.objid = ct.x_call_trans2carrier) x_carrier_id,
                      ct.x_transact_date call_trans_date,
                      ct.x_new_due_date due_date,
                      ct.x_service_id esn,
                      ct.x_min,
                      ct.x_iccid,
                      ct.x_action_type,
                      ct.x_reason,
                      ct.x_sourcesystem
                 FROM sa.table_x_call_trans ct
                WHERE 1 = 1
                  AND EXISTS (SELECT 1
                                FROM sa.table_x_carrier_group cg,
                                     sa.table_x_carrier tc
                               WHERE cg.x_carrier_name LIKE 'T%MOBILE%'
                                 AND cg.objid = tc.carrier2carrier_group
                                 AND tc.objid = ct.x_call_trans2carrier)
                  AND EXISTS (SELECT 1
                                FROM sa.table_site_part sp
                               WHERE sp.x_min = i_min
                                 AND sp.x_service_id = ct.x_service_id)
               ORDER BY ct.x_transact_date DESC)
        WHERE ROWNUM = 1;
     EXCEPTION
       WHEN OTHERS THEN
         o_response := 'INPUT_VALIDATION_ERROR';
         o_response_message := o_response||' - Could not find any ESN linked to TMO';
         log_request (i_min                      =>  i_min,
                      i_request_no               =>  i_request_no,
                      i_request_type             =>  'R',
                      i_short_parent_name        =>  s.short_parent_name,
                      i_case_id_number           =>  NULL,
                      i_desired_due_date         =>  i_desired_due_date,
                      i_nnsp                     =>  i_nnsp,
                      i_directional_indicator    =>  i_directional_indicator,
                      i_osp_account_no           =>  i_osp_account_no,
                      i_response                 =>  o_response,
                      i_error_message            =>  o_response_message,
                      i_esn                      =>  s.esn,
                      i_brand_shared_group_flag  =>  NULL,
                      i_request_xml              =>  i_request_xml,
                      i_x_client_id              =>  i_x_client_id,
                      i_account_no               =>  i_account_no,
                      i_carrier                  =>  i_carrier,
                      i_password_pin             =>  i_password_pin,
                      i_v_key                    =>  i_v_key,
                      i_full_name                =>  i_full_name,
                      i_billing_address          =>  i_billing_address,
                      i_last_4_ssn               =>  i_last_4_ssn,
                      i_account_alpha            =>  i_is_account_alpha,
                      i_pin_alpha                =>  i_is_pin_alpha,
                      i_zip_code                 =>  i_zip );
         --
         RETURN;
         --
     END;

     dbms_output.put_line('l_min_portred ESN :'                   || v_esn);
     dbms_output.put_line('l_min_portred call trans carrier id :' || v_ctcarobjid);
     dbms_output.put_line('l_min_portred call trans objid :'      || v_ctobjid);

   END IF;

 END IF;-- CR51128

 dbms_output.put_line('l_min_portred :' || l_min_portred);
 --
 -- CR55926 - calling the customer_type to retrieve method for v_esn if l_min_portred = 'Y'
 -- CR55926 - ensure the s.short_parent_name is mapped to the input carrier and not the ESN attrb.
 IF l_min_portred = 'Y' THEN

   s := customer_type ();
   s := sa.customer_type (i_esn => TRIM(v_esn));
   s := s.retrieve;
   s.short_parent_name := s.get_short_parent_name (i_parent_name => i_carrier);

   dbms_output.put_line('l_min_portred contact_objid :'         || s.contact_objid);
   dbms_output.put_line('l_min_portred brand_shared_grp_flag :' || s.brand_shared_group_flag);
   dbms_output.put_line('l_min_portred short_parent_name :'     || s.short_parent_name);

 END IF;

 dbms_output.put_line('s.response :'||s.response);

 -- Program will return and exit when the ESN is not found
 IF s.response NOT LIKE '%SUCCESS%' THEN
   --
   -- Use the response from the customer type retrieve method
   o_response := 'INPUT_VALIDATION_ERROR';
   o_response_message := 'Response: '||s.response;
   --
   log_request (i_min                      => i_min,
                i_request_no               => i_request_no,
                i_request_type             => 'R',
                i_short_parent_name        => s.short_parent_name,
                i_case_id_number           => NULL,
                i_desired_due_date         => i_desired_due_date,
                i_nnsp                     => i_nnsp,
                i_directional_indicator    => i_directional_indicator,
                i_osp_account_no           => i_osp_account_no,
                i_response                 => o_response,
                i_error_message            => o_response_message,
                i_esn                      => s.esn,
                i_brand_shared_group_flag  => s.brand_shared_group_flag,
                i_request_xml              => i_request_xml,
                i_x_client_id              => i_x_client_id,
                i_account_no               => i_account_no,
                i_carrier                  => i_carrier,
                i_password_pin             => i_password_pin,
                i_v_key                    => i_v_key,
                i_full_name                => i_full_name,
                i_billing_address          => i_billing_address,
                i_last_4_ssn               => i_last_4_ssn,
                i_account_alpha            => i_is_account_alpha,
                i_pin_alpha                => i_is_pin_alpha,
                i_zip_code                 => i_zip);
   -- exit
   RETURN;
   --
 END IF;

 dbms_output.put_line('s.min_part_inst_status :'||s.min_part_inst_status);
 --
 -- CR56056 - If the MIN line is not active then stop the process.
 IF (s.min_part_inst_status NOT IN('13') OR s.min_part_inst_status IS NULL) AND (l_min_portred = 'N') THEN
   --
   -- Set the values for IG
   o_response := 'MDN_NOT_ACTIVE';
   o_response_message := o_response||' - min_part_inst_status: '||s.min_part_inst_status;
   --
   sp_seq('task', l_task_id);
   --
   igt := ig_transaction_type (i_esn                  => s.esn,
                               i_action_item_id       => l_task_id,
                               i_msid                 => i_min,
                               i_min                  => i_min,
                               i_technology_flag      => NVL(l_tech_flag,'C'),    --CR51128
                               i_order_type           => 'UPO', -- New order type update port out
                               i_template             => i_portout_carrier,
                               i_rate_plan            => NULL,
                               i_zip_code             => i_zip,
                               i_transaction_id       => NULL,
                               i_phone_manf           => NULL,
                               i_carrier_id           => NULL,
                               i_iccid                => NULL,
                               i_network_login        => NVL(l_nw_login,NULL),    --CR51128
                               i_network_password     => NVL(l_nw_pwd,NULL),      --CR51128
                               i_account_num          => l_acc_num,               --CR51128
                               i_transmission_method  => 'AOL',
                               i_status               => 'Q',
                               i_status_message       => o_response||' - '||i_request_no,
                               i_application_system   => NVL(l_app_sys,NULL),     --CR51128
                               i_skip_ig_validation   => 'Y',
                               i_old_esn              => i_osp_account_no,
                               i_pin                  => i_password_pin);

   -- call the insert method
   ig  := igt.ins;
   --
   -- log
   log_request (i_min                      => i_min,
                i_request_no               => i_request_no,
                i_request_type             => 'R',
                i_short_parent_name        => s.short_parent_name,
                i_case_id_number           => NULL,
                i_desired_due_date         => i_desired_due_date,
                i_nnsp                     => i_nnsp,
                i_directional_indicator    => i_directional_indicator,
                i_osp_account_no           => i_osp_account_no,
                i_response                 => o_response,
                i_error_message            => o_response_message,
                i_esn                      => s.esn,
                i_brand_shared_group_flag  => s.brand_shared_group_flag,
                i_request_xml              => i_request_xml,
                i_x_client_id              => i_x_client_id,
                i_account_no               => i_account_no,
                i_carrier                  => i_carrier,
                i_password_pin             => i_password_pin,
                i_v_key                    => i_v_key,
                i_full_name                => i_full_name,
                i_billing_address          => i_billing_address,
                i_last_4_ssn               => i_last_4_ssn,
                i_account_alpha            => i_is_account_alpha,
                i_pin_alpha                => i_is_pin_alpha,
                i_zip_code                 => i_zip);
   -- exit
   RETURN;
   --
 END IF;

 dbms_output.put_line('o_case_id_number :'||NVL(o_case_id_number,'0'));
 --
 --Calling CREATE_WINBACK_CASE to create Winback case if Carrier is configured for Winback
 IF NVL(o_case_id_number,'0') = '0' AND l_min_portred = 'N' THEN
   --
   sa.PORT_OUT_PKG.create_winback_case (i_min                    => i_min,
                                        i_request_no             => i_request_no,
                                        i_short_parent_name      => s.short_parent_name,
                                        i_desired_due_date       => i_desired_due_date,
                                        i_nnsp                   => i_nnsp,
                                        i_directional_indicator  => i_directional_indicator,
                                        i_osp_account_no         => i_osp_account_no,
                                        i_portout_carrier        => i_portout_carrier,
                                        i_request_xml            => i_request_xml,
                                        o_case_id_number         => o_case_id_number,
                                        o_sms_send_flag          => l_sms_send_flag,
                                        o_proceed_flag           => l_proceed_flag,
                                        o_errcode                => l_errnum,
                                        o_errmsg                 => l_errmsg);
   --
   dbms_output.put_line('l_errnum :'||l_errnum);
   dbms_output.put_line('l_proceed_flag :'||l_proceed_flag);
   --
   IF l_errnum = 0 AND l_proceed_flag = 'WINBACK' THEN
     o_sms_send_flag  :=  l_sms_send_flag;
     o_response       :=  'SUCCESS';
     dbms_output.put_line('Created Winback Case - l_sms_send_flag :'||l_sms_send_flag);
     RETURN;
   END IF;
   --
 END IF;

 -- Get the valid db user objid
 BEGIN
   SELECT objid
     INTO l_user_objid
     FROM sa.table_user
    WHERE s_login_name = (SELECT UPPER(user) FROM DUAL);
 EXCEPTION
   WHEN OTHERS THEN
     -- Get unregistered user for error log and return
     BEGIN
       SELECT UPPER(user),
              NULL
         INTO l_db_user,
              l_user_objid
         FROM DUAL;
     EXCEPTION
       WHEN OTHERS THEN
         l_user_objid := NULL;
         l_db_user    := NULL;
     END;
 END;

 dbms_output.put_line('l_user_objid :'||l_user_objid);

 IF l_user_objid IS NULL THEN
   --
   -- Use the response from the customer type retrieve method
   o_response := 'INVALID_USER_ID';
   o_response_message := 'DB User is not registered in sa.table_user :'||l_db_user;
   --
   log_request (i_min                      => i_min,
                i_request_no               => i_request_no,
                i_request_type             => 'R',
                i_short_parent_name        => s.short_parent_name,
                i_case_id_number           => NULL,
                i_desired_due_date         => i_desired_due_date,
                i_nnsp                     => i_nnsp,
                i_directional_indicator    => i_directional_indicator,
                i_osp_account_no           => i_osp_account_no,
                i_response                 => o_response,
                i_error_message            => o_response_message,
                i_esn                      => s.esn,
                i_brand_shared_group_flag  => s.brand_shared_group_flag,
                i_request_xml              => i_request_xml,
                i_x_client_id              => i_x_client_id,
                i_account_no               => i_account_no,
                i_carrier                  => i_carrier,
                i_password_pin             => i_password_pin,
                i_v_key                    => i_v_key,
                i_full_name                => i_full_name,
                i_billing_address          => i_billing_address,
                i_last_4_ssn               => i_last_4_ssn,
                i_account_alpha            => i_is_account_alpha,
                i_pin_alpha                => i_is_pin_alpha,
                i_zip_code                 => i_zip);
   -- exit
   RETURN;
   --
 END IF;

 dbms_output.put_line('case status :'||l_case_status);
 dbms_output.put_line('case msg :'||l_case_msg);

 -- CR56056 - Call the deactivation process only for non-ported mins ('N').
 IF l_min_portred = 'N' THEN

   dbms_output.put_line('s.response :'||s.response);
   dbms_output.put_line('s.esn:'||s.esn);
   dbms_output.put_line('s.pgm_enroll_objid :'||s.pgm_enroll_objid);

   -- Call the deactservice stored procedure (call trans and a task)
   sa.SERVICE_DEACTIVATION_CODE.deactservice (ip_sourcesystem    => 'TAS',
                                              ip_userobjid       => l_user_objid,
                                              ip_esn             => s.esn,
                                              ip_min             => i_min,
                                              ip_deactreason     => 'PORT OUT',
                                              intbypassordertype => 0,
                                              ip_newesn          => NULL,
                                              ip_samemin         => 'true',
                                              op_return          => l_return,
                                              op_returnmsg       => l_returnmsg );

   dbms_output.put_line('deactservice return :'||l_return);
   dbms_output.put_line('deactservice returnmsg :'||l_returnmsg);

   -- CR56056 - Corrected call to error message from deactservice
   IF (NVL(TRIM(l_return),'XXX') <> 'true') THEN
     --
     o_response := 'ERROR_IN_DEACTIVATION';
     o_response_message := o_response||': '||l_returnmsg;

     -- log request
     log_request (i_min                          =>  i_min,
                  i_request_no                   =>  i_request_no,
                  i_request_type                 =>  'R' ,
                  i_short_parent_name            =>  s.short_parent_name,
                  i_case_id_number               =>  l_case_id,
                  i_desired_due_date             =>  i_desired_due_date,
                  i_nnsp                         =>  i_nnsp,
                  i_directional_indicator        =>  i_directional_indicator,
                  i_osp_account_no               =>  i_osp_account_no,
                  i_response                     =>  o_response,
                  i_error_message                =>  o_response_message,
                  i_esn                          =>  s.esn,
                  i_brand_shared_group_flag      =>  s.brand_shared_group_flag,
                  i_request_xml                  =>  i_request_xml,
                  i_site_part_objid              =>  s.site_part_objid,
                  i_service_end_date             =>  s.service_end_date,
                  i_expiration_date              =>  s.expiration_date,
                  i_deactivation_reason          =>  s.deactivation_reason,
                  i_notify_carrier               =>  s.notify_carrier,
                  i_site_part_status             =>  s.site_part_status,
                  i_service_plan_objid           =>  s.service_plan_objid,
                  i_ild_transaction_status       =>  s.ild_transaction_status,
                  i_esn_part_inst_objid          =>  s.esn_part_inst_objid,
                  i_esn_part_inst_status         =>  s.esn_part_inst_status,
                  i_esn_part_inst_code           =>  s.esn_part_inst_code,
                  i_reactivation_flag            =>  s.reactivation_flag,
                  i_contact_objid                =>  s.contact_objid,
                  i_esn_new_personality_objid    =>  s.esn_new_personality_objid,
                  i_pgm_enroll_objid             =>  s.pgm_enroll_objid,
                  i_pgm_enrollment_status        =>  s.pgm_enrollment_status,
                  i_pgm_enroll_exp_date          =>  s.pgm_enroll_exp_date,
                  i_pgm_enroll_cooling_exp_date  =>  s.pgm_enroll_cooling_exp_date,
                  i_pgm_enroll_next_dlvry_date   =>  s.pgm_enroll_next_delivery_date,
                  i_pgm_enroll_next_charge_date  =>  s.pgm_enroll_next_charge_date,
                  i_pgm_enroll_grace_period      =>  s.pgm_enroll_grace_period,
                  i_pgm_enroll_cooling_period    =>  s.pgm_enroll_cooling_period,
                  i_pgm_enroll_service_days      =>  s.pgm_enroll_service_days,
                  i_pgm_enroll_wait_exp_date     =>  s.pgm_enroll_wait_exp_date,
                  i_pgm_enroll_charge_type       =>  s.pgm_enroll_charge_type,
                  i_pgm_enrol_tot_grace_prd_gn   =>  s.pgm_enrol_tot_grace_period_gn,
                  i_account_group_objid          =>  s.account_group_objid,
                  i_member_objid                 =>  s.member_objid,
                  i_member_status                =>  s.member_status,
                  i_member_start_date            =>  s.member_start_date,
                  i_member_end_date              =>  s.member_end_date,
                  i_member_master_flag           =>  s.member_master_flag,
                  i_service_order_stage_objid    =>  s.service_order_stage_objid,
                  i_service_order_stage_status   =>  s.service_order_stage_status,
                  i_min_part_inst_objid          =>  s.min_part_inst_objid,
                  i_min_part_inst_status         =>  s.min_part_inst_status,
                  i_min_part_inst_code           =>  s.min_part_inst_code,
                  i_min_cool_end_date            =>  s.min_cool_end_date,
                  i_min_warr_end_date            =>  s.min_warr_end_date,
                  i_repair_date                  =>  s.repair_date,
                  i_min_personality_objid        =>  s.min_personality_objid,
                  i_min_new_personality_objid    =>  s.min_new_personality_objid,
                  i_min_to_esn_part_inst_objid   =>  s.min_to_esn_part_inst_objid,
                  i_last_cycle_date              =>  s.last_cycle_date,
                  i_port_in                      =>  s.port_in,
                  i_psms_outbox_objid            =>  s.psms_outbox_objid,
                  i_psms_outbox_status           =>  s.psms_outbox_status,
                  i_ota_feat_objid               =>  s.ota_feat_objid,
                  i_ota_feat_ild_account         =>  s.ota_feat_ild_account,
                  i_ota_feat_ild_carr_status     =>  s.ota_feat_ild_carr_status,
                  i_ota_feat_ild_prog_status     =>  s.ota_feat_ild_prog_status,
                  i_click_plan_hist_objid        =>  s.click_plan_hist_objid,
                  i_click_plan_hist_end_date     =>  s.click_plan_hist_end_date,
                  i_fvm_status                   =>  s.fvm_status,
                  i_fvm_number                   =>  s.fvm_number,
                  i_ota_transaction_objid        =>  s.ota_transaction_objid,
                  i_ota_transaction_status       =>  s.ota_transaction_status,
                  i_ota_transaction_reason       =>  s.ota_transaction_reason,
                  i_x_client_id                  =>  i_x_client_id,
                  i_account_no                   =>  i_account_no,
                  i_carrier                      =>  i_carrier,
                  i_password_pin                 =>  i_password_pin,
                  i_v_key                        =>  i_v_key,
                  i_full_name                    =>  i_full_name,
                  i_billing_address              =>  i_billing_address,
                  i_last_4_ssn                   =>  i_last_4_ssn,
                  i_account_alpha                =>  i_is_account_alpha,
                  i_pin_alpha                    =>  i_is_pin_alpha,
                  i_zip_code                     =>  i_zip);
     --
     RETURN;
     --
   END IF;
   --
   BEGIN
     SELECT call_trans_objid
       INTO ct.call_trans_objid
       FROM (SELECT objid call_trans_objid
               FROM sa.table_x_call_trans
              WHERE x_min = i_min
                AND x_service_id = s.esn
                AND x_action_type = '2'
                AND x_result = 'Completed'
                AND x_action_text||'' = 'DEACTIVATION'
                AND x_reason||'' = 'PORT OUT'
                AND x_call_trans2user = l_user_objid
             ORDER BY update_stamp desc)
      WHERE ROWNUM = 1;
   EXCEPTION
     WHEN OTHERS THEN
       o_response := 'CALL_TRANS_NOT_FOUND';
       o_response_message := SUBSTR(SQLERRM,1,200);
       --
       log_request ( i_min                          =>  i_min,
                     i_request_no                   =>  i_request_no,
                     i_request_type                 =>  'R',
                     i_short_parent_name            =>  s.short_parent_name,
                     i_case_id_number               =>  NULL,
                     i_desired_due_date             =>  i_desired_due_date,
                     i_nnsp                         =>  i_nnsp,
                     i_directional_indicator        =>  i_directional_indicator,
                     i_osp_account_no               =>  i_osp_account_no,
                     i_response                     =>  o_response,
                     i_error_message                =>  o_response_message,
                     i_esn                          =>  s.esn,
                     i_brand_shared_group_flag      =>  s.brand_shared_group_flag,
                     i_request_xml                  =>  i_request_xml,
                     i_site_part_objid              =>  s.site_part_objid,
                     i_service_end_date             =>  s.service_end_date,
                     i_expiration_date              =>  s.expiration_date,
                     i_deactivation_reason          =>  s.deactivation_reason,
                     i_notify_carrier               =>  s.notify_carrier,
                     i_site_part_status             =>  s.site_part_status,
                     i_service_plan_objid           =>  s.service_plan_objid,
                     i_ild_transaction_status       =>  s.ild_transaction_status,
                     i_esn_part_inst_objid          =>  s.esn_part_inst_objid,
                     i_esn_part_inst_status         =>  s.esn_part_inst_status,
                     i_esn_part_inst_code           =>  s.esn_part_inst_code,
                     i_reactivation_flag            =>  s.reactivation_flag,
                     i_contact_objid                =>  s.contact_objid,
                     i_esn_new_personality_objid    =>  s.esn_new_personality_objid,
                     i_pgm_enroll_objid             =>  s.pgm_enroll_objid,
                     i_pgm_enrollment_status        =>  s.pgm_enrollment_status,
                     i_pgm_enroll_exp_date          =>  s.pgm_enroll_exp_date,
                     i_pgm_enroll_cooling_exp_date  =>  s.pgm_enroll_cooling_exp_date,
                     i_pgm_enroll_next_dlvry_date   =>  s.pgm_enroll_next_delivery_date,
                     i_pgm_enroll_next_charge_date  =>  s.pgm_enroll_next_charge_date,
                     i_pgm_enroll_grace_period      =>  s.pgm_enroll_grace_period,
                     i_pgm_enroll_cooling_period    =>  s.pgm_enroll_cooling_period,
                     i_pgm_enroll_service_days      =>  s.pgm_enroll_service_days,
                     i_pgm_enroll_wait_exp_date     =>  s.pgm_enroll_wait_exp_date,
                     i_pgm_enroll_charge_type       =>  s.pgm_enroll_charge_type,
                     i_pgm_enrol_tot_grace_prd_gn   =>  s.pgm_enrol_tot_grace_period_gn,
                     i_account_group_objid          =>  s.account_group_objid,
                     i_member_objid                 =>  s.member_objid,
                     i_member_status                =>  s.member_status,
                     i_member_start_date            =>  s.member_start_date,
                     i_member_end_date              =>  s.member_end_date,
                     i_member_master_flag           =>  s.member_master_flag,
                     i_service_order_stage_objid    =>  s.service_order_stage_objid,
                     i_service_order_stage_status   =>  s.service_order_stage_status,
                     i_min_part_inst_objid          =>  s.min_part_inst_objid,
                     i_min_part_inst_status         =>  s.min_part_inst_status,
                     i_min_part_inst_code           =>  s.min_part_inst_code,
                     i_min_cool_end_date            =>  s.min_cool_end_date,
                     i_min_warr_end_date            =>  s.min_warr_end_date,
                     i_repair_date                  =>  s.repair_date,
                     i_min_personality_objid        =>  s.min_personality_objid,
                     i_min_new_personality_objid    =>  s.min_new_personality_objid,
                     i_min_to_esn_part_inst_objid   =>  s.min_to_esn_part_inst_objid,
                     i_last_cycle_date              =>  s.last_cycle_date,
                     i_port_in                      =>  s.port_in,
                     i_psms_outbox_objid            =>  s.psms_outbox_objid,
                     i_psms_outbox_status           =>  s.psms_outbox_status,
                     i_ota_feat_objid               =>  s.ota_feat_objid,
                     i_ota_feat_ild_account         =>  s.ota_feat_ild_account,
                     i_ota_feat_ild_carr_status     =>  s.ota_feat_ild_carr_status,
                     i_ota_feat_ild_prog_status     =>  s.ota_feat_ild_prog_status,
                     i_click_plan_hist_objid        =>  s.click_plan_hist_objid,
                     i_click_plan_hist_end_date     =>  s.click_plan_hist_end_date,
                     i_fvm_status                   =>  s.fvm_status,
                     i_fvm_number                   =>  s.fvm_number,
                     i_ota_transaction_objid        =>  s.ota_transaction_objid,
                     i_ota_transaction_status       =>  s.ota_transaction_status,
                     i_ota_transaction_reason       =>  s.ota_transaction_reason,
                     i_x_client_id                  =>  i_x_client_id,
                     i_account_no                   =>  i_account_no,
                     i_carrier                      =>  i_carrier,
                     i_password_pin                 =>  i_password_pin,
                     i_v_key                        =>  i_v_key,
                     i_full_name                    =>  i_full_name,
                     i_billing_address              =>  i_billing_address,
                     i_last_4_ssn                   =>  i_last_4_ssn,
                     i_account_alpha                =>  i_is_account_alpha,
                     i_pin_alpha                    =>  i_is_pin_alpha,
                     i_zip_code                     =>  i_zip);
       --
       RETURN;
       --
   END;
   --
 ELSIF l_min_portred = 'Y' THEN
   --
   ct.call_trans_objid := v_ctobjid;
   --
 END IF;

 dbms_output.put_line('ct.call_trans_objid :'||ct.call_trans_objid);

 -- Set the values for the task to be created
 -- New order type updated - Update PortOut
 tt := task_type (i_call_trans_objid  => ct.call_trans_objid,
                  i_contact_objid     => s.contact_objid,
                  i_order_type        => 'Update PortOut',
                  i_bypass_order_type => 0,
                  i_case_code         => 0);

 -- call the insert method to create a new task
 t := tt.ins;

 dbms_output.put_line('t.response :'||t.response);

 -- if call_trans was not created successfully
 IF t.response NOT LIKE '%SUCCESS%' THEN
   --
   o_response := 'CALL_TRANS_TASK_ERROR';
   o_response_message := t.response;
   --
   log_request ( i_min                          =>  i_min,
                 i_request_no                   =>  i_request_no,
                 i_request_type                 =>  'R',
                 i_short_parent_name            =>  s.short_parent_name,
                 i_case_id_number               =>  l_case_id,
                 i_desired_due_date             =>  i_desired_due_date,
                 i_nnsp                         =>  i_nnsp,
                 i_directional_indicator        =>  i_directional_indicator,
                 i_osp_account_no               =>  i_osp_account_no,
                 i_response                     =>  o_response,
                 i_error_message                =>  o_response_message,
                 i_esn                          =>  s.esn,
                 i_brand_shared_group_flag      =>  s.brand_shared_group_flag,
                 i_request_xml                  =>  i_request_xml,
                 i_site_part_objid              =>  s.site_part_objid,
                 i_service_end_date             =>  s.service_end_date,
                 i_expiration_date              =>  s.expiration_date,
                 i_deactivation_reason          =>  s.deactivation_reason,
                 i_notify_carrier               =>  s.notify_carrier,
                 i_site_part_status             =>  s.site_part_status,
                 i_service_plan_objid           =>  s.service_plan_objid,
                 i_ild_transaction_status       =>  s.ild_transaction_status,
                 i_esn_part_inst_objid          =>  s.esn_part_inst_objid,
                 i_esn_part_inst_status         =>  s.esn_part_inst_status,
                 i_esn_part_inst_code           =>  s.esn_part_inst_code,
                 i_reactivation_flag            =>  s.reactivation_flag,
                 i_contact_objid                =>  s.contact_objid,
                 i_esn_new_personality_objid    =>  s.esn_new_personality_objid,
                 i_pgm_enroll_objid             =>  s.pgm_enroll_objid,
                 i_pgm_enrollment_status        =>  s.pgm_enrollment_status,
                 i_pgm_enroll_exp_date          =>  s.pgm_enroll_exp_date,
                 i_pgm_enroll_cooling_exp_date  =>  s.pgm_enroll_cooling_exp_date,
                 i_pgm_enroll_next_dlvry_date   =>  s.pgm_enroll_next_delivery_date,
                 i_pgm_enroll_next_charge_date  =>  s.pgm_enroll_next_charge_date,
                 i_pgm_enroll_grace_period      =>  s.pgm_enroll_grace_period,
                 i_pgm_enroll_cooling_period    =>  s.pgm_enroll_cooling_period,
                 i_pgm_enroll_service_days      =>  s.pgm_enroll_service_days,
                 i_pgm_enroll_wait_exp_date     =>  s.pgm_enroll_wait_exp_date,
                 i_pgm_enroll_charge_type       =>  s.pgm_enroll_charge_type,
                 i_pgm_enrol_tot_grace_prd_gn   =>  s.pgm_enrol_tot_grace_period_gn,
                 i_account_group_objid          =>  s.account_group_objid,
                 i_member_objid                 =>  s.member_objid,
                 i_member_status                =>  s.member_status,
                 i_member_start_date            =>  s.member_start_date,
                 i_member_end_date              =>  s.member_end_date,
                 i_member_master_flag           =>  s.member_master_flag,
                 i_service_order_stage_objid    =>  s.service_order_stage_objid,
                 i_service_order_stage_status   =>  s.service_order_stage_status,
                 i_min_part_inst_objid          =>  s.min_part_inst_objid,
                 i_min_part_inst_status         =>  s.min_part_inst_status,
                 i_min_part_inst_code           =>  s.min_part_inst_code,
                 i_min_cool_end_date            =>  s.min_cool_end_date,
                 i_min_warr_end_date            =>  s.min_warr_end_date,
                 i_repair_date                  =>  s.repair_date,
                 i_min_personality_objid        =>  s.min_personality_objid,
                 i_min_new_personality_objid    =>  s.min_new_personality_objid,
                 i_min_to_esn_part_inst_objid   =>  s.min_to_esn_part_inst_objid,
                 i_last_cycle_date              =>  s.last_cycle_date,
                 i_port_in                      =>  s.port_in,
                 i_psms_outbox_objid            =>  s.psms_outbox_objid,
                 i_psms_outbox_status           =>  s.psms_outbox_status,
                 i_ota_feat_objid               =>  s.ota_feat_objid,
                 i_ota_feat_ild_account         =>  s.ota_feat_ild_account,
                 i_ota_feat_ild_carr_status     =>  s.ota_feat_ild_carr_status,
                 i_ota_feat_ild_prog_status     =>  s.ota_feat_ild_prog_status,
                 i_click_plan_hist_objid        =>  s.click_plan_hist_objid,
                 i_click_plan_hist_end_date     =>  s.click_plan_hist_end_date,
                 i_fvm_status                   =>  s.fvm_status,
                 i_fvm_number                   =>  s.fvm_number,
                 i_ota_transaction_objid        =>  s.ota_transaction_objid,
                 i_ota_transaction_status       =>  s.ota_transaction_status,
                 i_ota_transaction_reason       =>  s.ota_transaction_reason,
                 i_x_client_id                  =>  i_x_client_id,
                 i_account_no                   =>  i_account_no,
                 i_carrier                      =>  i_carrier,
                 i_password_pin                 =>  i_password_pin,
                 i_v_key                        =>  i_v_key,
                 i_full_name                    =>  i_full_name,
                 i_billing_address              =>  i_billing_address,
                 i_last_4_ssn                   =>  i_last_4_ssn,
                 i_account_alpha                =>  i_is_account_alpha,
                 i_pin_alpha                    =>  i_is_pin_alpha,
                 i_zip_code                     =>  i_zip);
   --
   ROLLBACK;
   --
   RETURN;
   --
 END IF;

 dbms_output.put_line('t.task_objid :'||t.task_objid);

 -- CR48685 - create a SP case
 sa.IGATE.sp_create_case (p_call_trans_objid => ct.call_trans_objid,
                          p_task_objid       => t.task_objid,
                          p_queue_name       => 'Line Deactivation',
                          p_type             => 'Port Out',       --CR 48685
                          p_title            => 'Auto Port Out',  --CR 48685
                          p_case_objid       => l_case_objid);

 dbms_output.put_line('sp_create_case case_objid :'||l_case_objid);

 -- CR48685 - Validate if the case was created successfully or if NULL
 IF l_case_objid IS NOT NULL THEN

   dbms_output.put_line('i_nnsp :'||i_nnsp);

   BEGIN
     SELECT description
       INTO l_carrier_desc
       FROM sa.x_nnsp_mapping
      WHERE id = i_nnsp
        AND ROWNUM = 1;
   EXCEPTION
     WHEN OTHERS THEN
       l_carrier_desc := 'OTHER';
   END;

   INSERT INTO sa.table_x_case_detail (objid,
                                       x_name,
                                       x_value,
                                       detail2case)
                               VALUES (seq('x_case_detail'),
                                       'NEW_SERVICE_PROVIDER',
                                       l_carrier_desc,
                                       l_case_objid);

 ELSIF l_case_objid IS NULL THEN
   --
   o_response := 'CASE_CREATION_FAILED';
   o_response_message := o_response ||' for '||ct.call_trans_objid||' - '||t.task_objid;
   --
   log_request ( i_min                          =>  i_min,
                 i_request_no                   =>  i_request_no,
                 i_request_type                 =>  'R',
                 i_short_parent_name            =>  s.short_parent_name,
                 i_case_id_number               =>  NULL,
                 i_desired_due_date             =>  i_desired_due_date,
                 i_nnsp                         =>  i_nnsp,
                 i_directional_indicator        =>  i_directional_indicator,
                 i_osp_account_no               =>  i_osp_account_no,
                 i_response                     =>  o_response,
                 i_error_message                =>  o_response_message,
                 i_esn                          =>  s.esn,
                 i_brand_shared_group_flag      =>  s.brand_shared_group_flag,
                 i_request_xml                  =>  i_request_xml,
                 i_site_part_objid              =>  s.site_part_objid,
                 i_service_end_date             =>  s.service_end_date,
                 i_expiration_date              =>  s.expiration_date,
                 i_deactivation_reason          =>  s.deactivation_reason,
                 i_notify_carrier               =>  s.notify_carrier,
                 i_site_part_status             =>  s.site_part_status,
                 i_service_plan_objid           =>  s.service_plan_objid,
                 i_ild_transaction_status       =>  s.ild_transaction_status,
                 i_esn_part_inst_objid          =>  s.esn_part_inst_objid,
                 i_esn_part_inst_status         =>  s.esn_part_inst_status,
                 i_esn_part_inst_code           =>  s.esn_part_inst_code,
                 i_reactivation_flag            =>  s.reactivation_flag,
                 i_contact_objid                =>  s.contact_objid,
                 i_esn_new_personality_objid    =>  s.esn_new_personality_objid,
                 i_pgm_enroll_objid             =>  s.pgm_enroll_objid,
                 i_pgm_enroll_charge_type       =>  s.pgm_enroll_charge_type,
                 i_pgm_enroll_next_charge_date  =>  s.pgm_enroll_next_charge_date,
                 i_account_group_objid          =>  s.account_group_objid,
                 i_member_objid                 =>  s.member_objid,
                 i_member_status                =>  s.member_status,
                 i_member_start_date            =>  s.member_start_date,
                 i_member_end_date              =>  s.member_end_date,
                 i_member_master_flag           =>  s.member_master_flag,
                 i_service_order_stage_objid    =>  s.service_order_stage_objid,
                 i_service_order_stage_status   =>  s.service_order_stage_status,
                 i_min_part_inst_objid          =>  s.min_part_inst_objid,
                 i_min_part_inst_status         =>  s.min_part_inst_status,
                 i_min_part_inst_code           =>  s.min_part_inst_code,
                 i_min_cool_end_date            =>  s.min_cool_end_date,
                 i_min_warr_end_date            =>  s.min_warr_end_date,
                 i_repair_date                  =>  s.repair_date,
                 i_min_personality_objid        =>  s.min_personality_objid,
                 i_min_new_personality_objid    =>  s.min_new_personality_objid,
                 i_min_to_esn_part_inst_objid   =>  s.min_to_esn_part_inst_objid,
                 i_last_cycle_date              =>  s.last_cycle_date,
                 i_port_in                      =>  s.port_in,
                 i_psms_outbox_objid            =>  s.psms_outbox_objid,
                 i_psms_outbox_status           =>  s.psms_outbox_status,
                 i_ota_feat_objid               =>  s.ota_feat_objid,
                 i_ota_feat_ild_account         =>  s.ota_feat_ild_account,
                 i_ota_feat_ild_carr_status     =>  s.ota_feat_ild_carr_status,
                 i_ota_feat_ild_prog_status     =>  s.ota_feat_ild_prog_status,
                 i_click_plan_hist_objid        =>  s.click_plan_hist_objid,
                 i_click_plan_hist_end_date     =>  s.click_plan_hist_end_date,
                 i_fvm_status                   =>  s.fvm_status,
                 i_fvm_number                   =>  s.fvm_number,
                 i_ota_transaction_objid        =>  s.ota_transaction_objid,
                 i_ota_transaction_status       =>  s.ota_transaction_status,
                 i_ota_transaction_reason       =>  s.ota_transaction_reason,
                 i_x_client_id                  =>  i_x_client_id,
                 i_account_no                   =>  i_account_no,
                 i_carrier                      =>  i_carrier,
                 i_password_pin                 =>  i_password_pin,
                 i_v_key                        =>  i_v_key,
                 i_full_name                    =>  i_full_name,
                 i_billing_address              =>  i_billing_address,
                 i_last_4_ssn                   =>  i_last_4_ssn,
                 i_account_alpha                =>  i_is_account_alpha,
                 i_pin_alpha                    =>  i_is_pin_alpha,
                 i_zip_code                     =>  i_zip);
   --
   ROLLBACK;
   --
   RETURN;
   --
 END IF;

 -- CR47153 - Update and Get the case id (id_number)
 BEGIN
   --
   UPDATE sa.table_case
      SET case_type_lvl2 = s.bus_org_id
    WHERE objid = l_case_objid;
   --
   SELECT id_number
     INTO l_case_id
     FROM sa.table_case
    WHERE objid = l_case_objid;
   --
 EXCEPTION
   WHEN OTHERS THEN
     o_response := 'CASE_ID_NOT_FOUND';
     o_response_message := 'ERROR for '||l_case_objid||': '||SUBSTR(SQLERRM,1,200);
     --
     log_request ( i_min                          =>  i_min,
                   i_request_no                   =>  i_request_no,
                   i_request_type                 =>  'R',
                   i_short_parent_name            =>  s.short_parent_name,
                   i_case_id_number               =>  NULL,
                   i_desired_due_date             =>  i_desired_due_date,
                   i_nnsp                         =>  i_nnsp,
                   i_directional_indicator        =>  i_directional_indicator,
                   i_osp_account_no               =>  i_osp_account_no,
                   i_response                     =>  o_response,
                   i_error_message                =>  o_response_message,
                   i_esn                          =>  s.esn,
                   i_brand_shared_group_flag      =>  s.brand_shared_group_flag,
                   i_request_xml                  =>  i_request_xml,
                   i_site_part_objid              =>  s.site_part_objid,
                   i_service_end_date             =>  s.service_end_date,
                   i_expiration_date              =>  s.expiration_date,
                   i_deactivation_reason          =>  s.deactivation_reason,
                   i_notify_carrier               =>  s.notify_carrier,
                   i_site_part_status             =>  s.site_part_status,
                   i_service_plan_objid           =>  s.service_plan_objid,
                   i_ild_transaction_status       =>  s.ild_transaction_status,
                   i_esn_part_inst_objid          =>  s.esn_part_inst_objid,
                   i_esn_part_inst_status         =>  s.esn_part_inst_status,
                   i_esn_part_inst_code           =>  s.esn_part_inst_code,
                   i_reactivation_flag            =>  s.reactivation_flag,
                   i_contact_objid                =>  s.contact_objid,
                   i_esn_new_personality_objid    =>  s.esn_new_personality_objid,
                   i_pgm_enroll_objid             =>  s.pgm_enroll_objid,
                   i_pgm_enroll_charge_type       =>  s.pgm_enroll_charge_type,
                   i_pgm_enroll_next_charge_date  =>  s.pgm_enroll_next_charge_date,
                   i_account_group_objid          =>  s.account_group_objid,
                   i_member_objid                 =>  s.member_objid,
                   i_member_status                =>  s.member_status,
                   i_member_start_date            =>  s.member_start_date,
                   i_member_end_date              =>  s.member_end_date,
                   i_member_master_flag           =>  s.member_master_flag,
                   i_service_order_stage_objid    =>  s.service_order_stage_objid,
                   i_service_order_stage_status   =>  s.service_order_stage_status,
                   i_min_part_inst_objid          =>  s.min_part_inst_objid,
                   i_min_part_inst_status         =>  s.min_part_inst_status,
                   i_min_part_inst_code           =>  s.min_part_inst_code,
                   i_min_cool_end_date            =>  s.min_cool_end_date,
                   i_min_warr_end_date            =>  s.min_warr_end_date,
                   i_repair_date                  =>  s.repair_date,
                   i_min_personality_objid        =>  s.min_personality_objid,
                   i_min_new_personality_objid    =>  s.min_new_personality_objid,
                   i_min_to_esn_part_inst_objid   =>  s.min_to_esn_part_inst_objid,
                   i_last_cycle_date              =>  s.last_cycle_date,
                   i_port_in                      =>  s.port_in,
                   i_psms_outbox_objid            =>  s.psms_outbox_objid,
                   i_psms_outbox_status           =>  s.psms_outbox_status,
                   i_ota_feat_objid               =>  s.ota_feat_objid,
                   i_ota_feat_ild_account         =>  s.ota_feat_ild_account,
                   i_ota_feat_ild_carr_status     =>  s.ota_feat_ild_carr_status,
                   i_ota_feat_ild_prog_status     =>  s.ota_feat_ild_prog_status,
                   i_click_plan_hist_objid        =>  s.click_plan_hist_objid,
                   i_click_plan_hist_end_date     =>  s.click_plan_hist_end_date,
                   i_fvm_status                   =>  s.fvm_status,
                   i_fvm_number                   =>  s.fvm_number,
                   i_ota_transaction_objid        =>  s.ota_transaction_objid,
                   i_ota_transaction_status       =>  s.ota_transaction_status,
                   i_ota_transaction_reason       =>  s.ota_transaction_reason,
                   i_x_client_id                  =>  i_x_client_id,
                   i_account_no                   =>  i_account_no,
                   i_carrier                      =>  i_carrier,
                   i_password_pin                 =>  i_password_pin,
                   i_v_key                        =>  i_v_key,
                   i_full_name                    =>  i_full_name,
                   i_billing_address              =>  i_billing_address,
                   i_last_4_ssn                   =>  i_last_4_ssn,
                   i_account_alpha                =>  i_is_account_alpha,
                   i_pin_alpha                    =>  i_is_pin_alpha,
                   i_zip_code                     =>  i_zip);
     --
     ROLLBACK;
     --
     RETURN;
 END;

 dbms_output.put_line('sa.table_case l_case_id :'||l_case_id);

 -- Close the case
 sa.IGATE.sp_close_case (p_case_id          => l_case_id,
                         p_user_login_name  => 'sa',
                         p_source           => 'PORT_OUT_PROCESS',
                         p_resolution_code  => 'Resolution Given',
                         p_status           => l_case_status,
                         p_msg              => l_case_msg);

 dbms_output.put_line('sp_close_case case l_case_msg :'||l_case_msg);
 dbms_output.put_line('sp_close_case case status :'||l_case_status);

 -- CR56056 - When the case was not properly closed
 IF (l_case_status = 'F') THEN
   --
   o_response := 'PORT_OUT_CASE_CLOSURE_FAILED';
   o_response_message := o_response ||' - '||l_case_msg;
   --
   log_request ( i_min                          =>  i_min,
                 i_request_no                   =>  i_request_no,
                 i_request_type                 =>  'R',
                 i_short_parent_name            =>  s.short_parent_name,
                 i_case_id_number               =>  NULL,
                 i_desired_due_date             =>  i_desired_due_date,
                 i_nnsp                         =>  i_nnsp,
                 i_directional_indicator        =>  i_directional_indicator,
                 i_osp_account_no               =>  i_osp_account_no,
                 i_response                     =>  o_response,
                 i_error_message                =>  o_response_message,
                 i_esn                          =>  s.esn,
                 i_brand_shared_group_flag      =>  s.brand_shared_group_flag,
                 i_request_xml                  =>  i_request_xml,
                 i_site_part_objid              =>  s.site_part_objid,
                 i_service_end_date             =>  s.service_end_date,
                 i_expiration_date              =>  s.expiration_date,
                 i_deactivation_reason          =>  s.deactivation_reason,
                 i_notify_carrier               =>  s.notify_carrier,
                 i_site_part_status             =>  s.site_part_status,
                 i_service_plan_objid           =>  s.service_plan_objid,
                 i_ild_transaction_status       =>  s.ild_transaction_status,
                 i_esn_part_inst_objid          =>  s.esn_part_inst_objid,
                 i_esn_part_inst_status         =>  s.esn_part_inst_status,
                 i_esn_part_inst_code           =>  s.esn_part_inst_code,
                 i_reactivation_flag            =>  s.reactivation_flag,
                 i_contact_objid                =>  s.contact_objid,
                 i_esn_new_personality_objid    =>  s.esn_new_personality_objid,
                 i_pgm_enroll_objid             =>  s.pgm_enroll_objid,
                 i_pgm_enroll_charge_type       =>  s.pgm_enroll_charge_type,
                 i_pgm_enroll_next_charge_date  =>  s.pgm_enroll_next_charge_date,
                 i_account_group_objid          =>  s.account_group_objid,
                 i_member_objid                 =>  s.member_objid,
                 i_member_status                =>  s.member_status,
                 i_member_start_date            =>  s.member_start_date,
                 i_member_end_date              =>  s.member_end_date,
                 i_member_master_flag           =>  s.member_master_flag,
                 i_service_order_stage_objid    =>  s.service_order_stage_objid,
                 i_service_order_stage_status   =>  s.service_order_stage_status,
                 i_min_part_inst_objid          =>  s.min_part_inst_objid,
                 i_min_part_inst_status         =>  s.min_part_inst_status,
                 i_min_part_inst_code           =>  s.min_part_inst_code,
                 i_min_cool_end_date            =>  s.min_cool_end_date,
                 i_min_warr_end_date            =>  s.min_warr_end_date,
                 i_repair_date                  =>  s.repair_date,
                 i_min_personality_objid        =>  s.min_personality_objid,
                 i_min_new_personality_objid    =>  s.min_new_personality_objid,
                 i_min_to_esn_part_inst_objid   =>  s.min_to_esn_part_inst_objid,
                 i_last_cycle_date              =>  s.last_cycle_date,
                 i_port_in                      =>  s.port_in,
                 i_psms_outbox_objid            =>  s.psms_outbox_objid,
                 i_psms_outbox_status           =>  s.psms_outbox_status,
                 i_ota_feat_objid               =>  s.ota_feat_objid,
                 i_ota_feat_ild_account         =>  s.ota_feat_ild_account,
                 i_ota_feat_ild_carr_status     =>  s.ota_feat_ild_carr_status,
                 i_ota_feat_ild_prog_status     =>  s.ota_feat_ild_prog_status,
                 i_click_plan_hist_objid        =>  s.click_plan_hist_objid,
                 i_click_plan_hist_end_date     =>  s.click_plan_hist_end_date,
                 i_fvm_status                   =>  s.fvm_status,
                 i_fvm_number                   =>  s.fvm_number,
                 i_ota_transaction_objid        =>  s.ota_transaction_objid,
                 i_ota_transaction_status       =>  s.ota_transaction_status,
                 i_ota_transaction_reason       =>  s.ota_transaction_reason,
                 i_x_client_id                  =>  i_x_client_id,
                 i_account_no                   =>  i_account_no,
                 i_carrier                      =>  i_carrier,
                 i_password_pin                 =>  i_password_pin,
                 i_v_key                        =>  i_v_key,
                 i_full_name                    =>  i_full_name,
                 i_billing_address              =>  i_billing_address,
                 i_last_4_ssn                   =>  i_last_4_ssn,
                 i_account_alpha                =>  i_is_account_alpha,
                 i_pin_alpha                    =>  i_is_pin_alpha,
                 i_zip_code                     =>  i_zip);
   --
   ROLLBACK;
   --
   RETURN;
   --
 END IF;

 o_case_id_number := l_case_id;
 o_response := 'SUCCESS';
 o_response_message := NULL;

 dbms_output.put_line('t.technology :'||t.technology);
 dbms_output.put_line('t.trans_profile_objid :'||t.trans_profile_objid);

 -- Get the template value
 ig := ig_transaction_type();
 ig.template := igt.get_template (i_technology          => t.technology,
                                  i_trans_profile_objid => t.trans_profile_objid);
 --
 igt := ig_transaction_type (i_esn                  => s.esn,
                             i_action_item_id       => t.task_id,
                             i_msid                 => i_min,
                             i_min                  => i_min,
                             i_technology_flag      => NVL(l_tech_flag,'C'),  --CR51128
                             i_order_type           => 'UPO', -- New order type update port out
                             i_template             => ig.template,
                             i_rate_plan            => NULL,
                             i_zip_code             => i_zip,
                             i_transaction_id       => NULL,
                             i_phone_manf           => NULL,
                             i_carrier_id           => NULL,
                             i_iccid                => NULL,
                             i_network_login        => NVL(l_nw_login,NULL),  --CR51128
                             i_network_password     => NVL(l_nw_pwd,NULL),    --CR51128
                             i_account_num          => l_acc_num,             --CR51128
                             i_transmission_method  => 'AOL',
                             i_status               => 'Q',
                             i_status_message       => o_response||' - '||i_request_no,
                             i_application_system   => NVL(l_app_sys,NULL),   --CR51128
                             i_skip_ig_validation   => 'Y',
                             i_old_esn              => i_osp_account_no,
                             i_pin                  => i_password_pin);

 -- call the insert method
 ig  := igt.ins;

 dbms_output.put_line('ig status :'||ig.status);
 dbms_output.put_line('ig response :'||ig.response);

 log_request ( i_min                          =>  i_min,
               i_request_no                   =>  i_request_no,
               i_request_type                 =>  'R',
               i_short_parent_name            =>  s.short_parent_name,
               i_case_id_number               =>  l_case_id,
               i_desired_due_date             =>  i_desired_due_date,
               i_nnsp                         =>  i_nnsp,
               i_directional_indicator        =>  i_directional_indicator,
               i_osp_account_no               =>  i_osp_account_no,
               i_response                     =>  o_response,
               i_error_message                =>  o_response_message,
               i_esn                          =>  s.esn,
               i_brand_shared_group_flag      =>  s.brand_shared_group_flag,
               i_request_xml                  =>  i_request_xml,
               i_site_part_objid              =>  s.site_part_objid,
               i_service_end_date             =>  s.service_end_date,
               i_expiration_date              =>  s.expiration_date,
               i_deactivation_reason          =>  s.deactivation_reason,
               i_notify_carrier               =>  s.notify_carrier,
               i_site_part_status             =>  s.site_part_status,
               i_service_plan_objid           =>  s.service_plan_objid,
               i_ild_transaction_status       =>  s.ild_transaction_status,
               i_esn_part_inst_objid          =>  s.esn_part_inst_objid,
               i_esn_part_inst_status         =>  s.esn_part_inst_status,
               i_esn_part_inst_code           =>  s.esn_part_inst_code,
               i_reactivation_flag            =>  s.reactivation_flag,
               i_contact_objid                =>  s.contact_objid,
               i_esn_new_personality_objid    =>  s.esn_new_personality_objid,
               i_pgm_enroll_objid             =>  s.pgm_enroll_objid,
               i_pgm_enroll_charge_type       =>  s.pgm_enroll_charge_type,
               i_pgm_enroll_next_charge_date  =>  s.pgm_enroll_next_charge_date,
               i_account_group_objid          =>  s.account_group_objid,
               i_member_objid                 =>  s.member_objid,
               i_member_status                =>  s.member_status,
               i_member_start_date            =>  s.member_start_date,
               i_member_end_date              =>  s.member_end_date,
               i_member_master_flag           =>  s.member_master_flag,
               i_service_order_stage_objid    =>  s.service_order_stage_objid,
               i_service_order_stage_status   =>  s.service_order_stage_status,
               i_min_part_inst_objid          =>  s.min_part_inst_objid,
               i_min_part_inst_status         =>  s.min_part_inst_status,
               i_min_part_inst_code           =>  s.min_part_inst_code,
               i_min_cool_end_date            =>  s.min_cool_end_date,
               i_min_warr_end_date            =>  s.min_warr_end_date,
               i_repair_date                  =>  s.repair_date,
               i_min_personality_objid        =>  s.min_personality_objid,
               i_min_new_personality_objid    =>  s.min_new_personality_objid,
               i_min_to_esn_part_inst_objid   =>  s.min_to_esn_part_inst_objid,
               i_last_cycle_date              =>  s.last_cycle_date,
               i_port_in                      =>  s.port_in,
               i_psms_outbox_objid            =>  s.psms_outbox_objid,
               i_psms_outbox_status           =>  s.psms_outbox_status,
               i_ota_feat_objid               =>  s.ota_feat_objid,
               i_ota_feat_ild_account         =>  s.ota_feat_ild_account,
               i_ota_feat_ild_carr_status     =>  s.ota_feat_ild_carr_status,
               i_ota_feat_ild_prog_status     =>  s.ota_feat_ild_prog_status,
               i_click_plan_hist_objid        =>  s.click_plan_hist_objid,
               i_click_plan_hist_end_date     =>  s.click_plan_hist_end_date,
               i_fvm_status                   =>  s.fvm_status,
               i_fvm_number                   =>  s.fvm_number,
               i_ota_transaction_objid        =>  s.ota_transaction_objid,
               i_ota_transaction_status       =>  s.ota_transaction_status,
               i_ota_transaction_reason       =>  s.ota_transaction_reason,
               i_x_client_id                  =>  i_x_client_id,
               i_account_no                   =>  i_account_no,
               i_carrier                      =>  i_carrier,
               i_password_pin                 =>  i_password_pin,
               i_v_key                        =>  i_v_key,
               i_full_name                    =>  i_full_name,
               i_billing_address              =>  i_billing_address,
               i_last_4_ssn                   =>  i_last_4_ssn,
               i_account_alpha                =>  i_is_account_alpha,
               i_pin_alpha                    =>  i_is_pin_alpha,
               i_zip_code                     =>  i_zip);
 --
 dbms_output.put_line('o_response :'||o_response);
 dbms_output.put_line('*** End of Port-Out process ***');
 --
EXCEPTION
  WHEN OTHERS THEN
    -- Return response to caller
    o_response := 'ERROR_CREATING_PORT_OUT_REQUEST';
    o_response_message := SUBSTR(SQLERRM,1,200);
    --
    ROLLBACK;
    --
    log_request (i_min                          =>  i_min,
                 i_request_no                   =>  i_request_no,
                 i_request_type                 =>  'R',
                 i_short_parent_name            =>  s.short_parent_name,
                 i_case_id_number               =>  l_case_id,
                 i_desired_due_date             =>  i_desired_due_date,
                 i_nnsp                         =>  i_nnsp,
                 i_directional_indicator        =>  i_directional_indicator,
                 i_osp_account_no               =>  i_osp_account_no,
                 i_response                     =>  o_response,
                 i_error_message                =>  o_response_message,
                 i_esn                          =>  s.esn,
                 i_brand_shared_group_flag      =>  s.brand_shared_group_flag,
                 i_request_xml                  =>  i_request_xml,
                 i_site_part_objid              =>  s.site_part_objid,
                 i_service_end_date             =>  s.service_end_date,
                 i_expiration_date              =>  s.expiration_date,
                 i_deactivation_reason          =>  s.deactivation_reason,
                 i_notify_carrier               =>  s.notify_carrier,
                 i_site_part_status             =>  s.site_part_status,
                 i_service_plan_objid           =>  s.service_plan_objid,
                 i_ild_transaction_status       =>  s.ild_transaction_status,
                 i_esn_part_inst_objid          =>  s.esn_part_inst_objid,
                 i_esn_part_inst_status         =>  s.esn_part_inst_status,
                 i_esn_part_inst_code           =>  s.esn_part_inst_code,
                 i_reactivation_flag            =>  s.reactivation_flag,
                 i_contact_objid                =>  s.contact_objid,
                 i_esn_new_personality_objid    =>  s.esn_new_personality_objid,
                 i_pgm_enroll_objid             =>  s.pgm_enroll_objid,
                 i_pgm_enroll_charge_type       =>  s.pgm_enroll_charge_type,
                 i_pgm_enroll_next_charge_date  =>  s.pgm_enroll_next_charge_date,
                 i_account_group_objid          =>  s.account_group_objid,
                 i_member_objid                 =>  s.member_objid,
                 i_member_status                =>  s.member_status,
                 i_member_start_date            =>  s.member_start_date,
                 i_member_end_date              =>  s.member_end_date,
                 i_member_master_flag           =>  s.member_master_flag,
                 i_service_order_stage_objid    =>  s.service_order_stage_objid,
                 i_service_order_stage_status   =>  s.service_order_stage_status,
                 i_min_part_inst_objid          =>  s.min_part_inst_objid,
                 i_min_part_inst_status         =>  s.min_part_inst_status,
                 i_min_part_inst_code           =>  s.min_part_inst_code,
                 i_min_cool_end_date            =>  s.min_cool_end_date,
                 i_min_warr_end_date            =>  s.min_warr_end_date,
                 i_repair_date                  =>  s.repair_date,
                 i_min_personality_objid        =>  s.min_personality_objid,
                 i_min_new_personality_objid    =>  s.min_new_personality_objid,
                 i_min_to_esn_part_inst_objid   =>  s.min_to_esn_part_inst_objid,
                 i_last_cycle_date              =>  s.last_cycle_date,
                 i_port_in                      =>  s.port_in,
                 i_psms_outbox_objid            =>  s.psms_outbox_objid,
                 i_psms_outbox_status           =>  s.psms_outbox_status,
                 i_ota_feat_objid               =>  s.ota_feat_objid,
                 i_ota_feat_ild_account         =>  s.ota_feat_ild_account,
                 i_ota_feat_ild_carr_status     =>  s.ota_feat_ild_carr_status,
                 i_ota_feat_ild_prog_status     =>  s.ota_feat_ild_prog_status,
                 i_click_plan_hist_objid        =>  s.click_plan_hist_objid,
                 i_click_plan_hist_end_date     =>  s.click_plan_hist_end_date,
                 i_fvm_status                   =>  s.fvm_status,
                 i_fvm_number                   =>  s.fvm_number,
                 i_ota_transaction_objid        =>  s.ota_transaction_objid,
                 i_ota_transaction_status       =>  s.ota_transaction_status,
                 i_ota_transaction_reason       =>  s.ota_transaction_reason,
                 i_x_client_id                  =>  i_x_client_id,
                 i_account_no                   =>  i_account_no,
                 i_carrier                      =>  i_carrier,
                 i_password_pin                 =>  i_password_pin,
                 i_v_key                        =>  i_v_key,
                 i_full_name                    =>  i_full_name,
                 i_billing_address              =>  i_billing_address,
                 i_last_4_ssn                   =>  i_last_4_ssn,
                 i_account_alpha                =>  i_is_account_alpha,
                 i_pin_alpha                    =>  i_is_pin_alpha,
                 i_zip_code                     =>  i_zip);
    --
END create_request;
--
--
-- Procedure to cancel a verizon port out request
PROCEDURE cancel_request (i_min                  IN  VARCHAR2,
                          i_request_no           IN  VARCHAR2,
                          i_error_code           IN  VARCHAR2,
                          i_error_message        IN  VARCHAR2,
                          i_request_xml          IN xmltype,
                          o_response             OUT VARCHAR2) AS

  por_rec           x_port_out_request_log%rowtype;
  s                 sa.customer_type := customer_type();
  l_request_exist_count NUMBER;
  -- CR50499 starts
  l_min_active_count NUMBER := 0;
  n_user_objid       NUMBER;
  l_task_id          NUMBER;
  igt                sa.ig_transaction_type := ig_transaction_type();
  ig                 sa.ig_transaction_type;
  cst                sa.customer_type       := customer_type();
  ct                 sa.call_trans_type     := call_trans_type();
  -- CR50499 starts
BEGIN

  -- Validate min is passed correctly
  IF (i_min IS NULL) THEN
    o_response := 'MIN NOT PASSED';
    RETURN;
  END IF;

    -- Validate if a request was already created
  BEGIN
    SELECT COUNT(1)
    INTO   l_request_exist_count
    FROM   x_port_out_request_log
    WHERE  min = i_min
    AND    request_no = i_request_no
    AND    request_type IN ('C','N');
  EXCEPTION
    WHEN OTHERS THEN
      l_request_exist_count := 0;
  END;

  IF (l_request_exist_count > 0) THEN
    o_response := 'DUPLICATE REQUEST NUMBER';
    RETURN;
  END IF;

  -- validate if the MIN is in Clarify
  BEGIN
    SELECT COUNT(1)
    INTO   s.numeric_value
    FROM   sa.table_part_inst
    WHERE  part_serial_no = i_min
    AND    x_domain = 'LINES';
  EXCEPTION
    WHEN others THEN
      NULL;
  END;

  -- if the min is NOT in Clarify
  -- CR50499 starts
  IF s.numeric_value = 0 THEN

    o_response := 'MIN NOT FOUND';

    sp_seq('task', l_task_id);

    -- create Suspend ig record if MIN NOT FOUND (not in clarify)
    igt := ig_transaction_type (i_esn                 => NULL,
                                i_action_item_id      => l_task_id,
                                i_msid                => i_min,
                                i_min                 => i_min,
                                i_technology_flag     => NULL,
                                i_order_type          => 'S', -- Suspend
                                i_template            => NULL,
                                i_rate_plan           => NULL,
                                i_zip_code            => NULL,
                                i_transaction_id      => NULL,
                                i_phone_manf          => NULL,
                                i_carrier_id          => NULL,
                                i_iccid               => NULL,
                                i_network_login       => NULL,
                                i_network_password    => NULL,
                                i_account_num         => NULL,
                                i_transmission_method => NULL,
                                i_status              => 'Q',
                                i_status_message      => o_response||' - '||i_request_no,
                                i_application_system  => 'IG',
                                i_skip_ig_validation  => 'Y');

    -- call the insert method
    ig := igt.ins;

    COMMIT;

    -- CR50499 Ends
    log_request ( i_min                     =>  i_min,
                  i_request_no              =>  i_request_no,
                  i_request_type            =>  'N',
                  i_short_parent_name       =>  NULL,
                  i_case_id_number          =>  NULL,
                  i_desired_due_date        =>  NULL,
                  i_nnsp                    =>  NULL,
                  i_directional_indicator   =>  NULL,
                  i_osp_account_no          =>  NULL,
                  i_response                =>  o_response,
                  i_esn                     =>  NULL,
                  i_brand_shared_group_flag =>  NULL,
                  i_request_xml             =>  i_request_xml,
                  i_error_code              =>  i_error_code,
                  i_error_message           =>  i_error_message);

    RETURN;

  END IF;

  -- Get the port out request to be cancelled
  BEGIN
    SELECT *
    INTO   por_rec
    FROM   sa.x_port_out_request_log
    WHERE  min = i_min
    AND    request_type = 'R'
    AND    request_date = (SELECT MAX(request_date)
                             FROM x_port_out_request_log
                            WHERE min = i_min
                              AND request_type = 'R');
  EXCEPTION
    WHEN OTHERS THEN
      o_response := 'PORT OUT REQUEST NOT FOUND';
      log_request (i_min                     =>  i_min,
                   i_request_no              =>  i_request_no,
                   i_request_type            =>  'C',
                   i_short_parent_name       =>  NULL,
                   i_case_id_number          =>  NULL,
                   i_desired_due_date        =>  NULL,
                   i_nnsp                    =>  NULL,
                   i_directional_indicator   =>  NULL,
                   i_osp_account_no          =>  NULL,
                   i_response                =>  o_response,
                   i_esn                     =>  NULL,
                   i_brand_shared_group_flag =>  NULL,
                   i_request_xml             =>  i_request_xml,
                   i_error_code              =>  i_error_code,
                   i_error_message           =>  i_error_message);
  END;

  -- Validate status
  IF (por_rec.status IS NULL) THEN

    o_response := 'PORT OUT REQUEST STATUS NOT FOUND';

    log_request ( i_min                     =>  i_min,
                  i_request_no              =>  i_request_no,
                  i_request_type            =>  'C',
                  i_short_parent_name       =>  NULL,
                  i_case_id_number          =>  NULL,
                  i_desired_due_date        =>  NULL,
                  i_nnsp                    =>  NULL,
                  i_directional_indicator   =>  NULL,
                  i_osp_account_no          =>  NULL,
                  i_response                =>  o_response,
                  i_esn                     =>  por_rec.esn,
                  i_brand_shared_group_flag =>  NULL,
                  i_request_xml             =>  i_request_xml,
                  i_error_code              =>  i_error_code,
                  i_error_message           =>  i_error_message);
    --RETURN; --CR50499
  END IF;

  -- Make sure the port out request was successful
  dbms_output.put_line('Req status: '||por_rec.status);

  IF (por_rec.status NOT LIKE '%SUCCESS%') THEN

    o_response := 'PORT OUT REQUEST INVALID STATUS = '||por_rec.status;

    log_request ( i_min                     =>  i_min,
                  i_request_no              =>  i_request_no,
                  i_request_type            =>  'C',
                  i_short_parent_name       =>  NULL,
                  i_case_id_number          =>  NULL,
                  i_desired_due_date        =>  NULL,
                  i_nnsp                    =>  NULL,
                  i_directional_indicator   =>  NULL,
                  i_osp_account_no          =>  NULL,
                  i_response                =>  o_response,
                  i_esn                     =>  por_rec.esn,
                  i_brand_shared_group_flag =>  NULL,
                  i_request_xml             =>  i_request_xml,
                  i_error_code              =>  i_error_code,
                  i_error_message           =>  i_error_message);

    --RETURN; --CR50499

  ELSE

    o_response := 'CUSTOMER ALREADY PORTED OUT';

    log_request ( i_min                     =>  i_min,
                  i_request_no              =>  i_request_no,
                  i_request_type            =>  'C',
                  i_short_parent_name       =>  NULL,
                  i_case_id_number          =>  NULL,
                  i_desired_due_date        =>  NULL,
                  i_nnsp                    =>  NULL,
                  i_directional_indicator   =>  NULL,
                  i_osp_account_no          =>  NULL,
                  i_response                =>  o_response,
                  i_esn                     =>  por_rec.esn,
                  i_brand_shared_group_flag =>  NULL,
                  i_request_xml             =>  i_request_xml,
                  i_error_code              =>  i_error_code,
                  i_error_message           =>  i_error_message);

    --RETURN;  --CR50499

  END IF;
  --
  -- CR50499 starts  validate if the MIN is Active in Clarify
  BEGIN
    SELECT COUNT(1)
      INTO l_min_active_count
      FROM sa.table_part_inst
     WHERE part_serial_no = i_min
       AND x_domain = 'LINES'
       AND x_part_inst_status = '13';
   EXCEPTION
     WHEN OTHERS THEN
       l_min_active_count := 0;
  END;

  dbms_output.put_line('Min Active Count:'||l_min_active_count);

  IF l_min_active_count = 0 THEN
      -- Update line status to 39
    BEGIN
      UPDATE table_part_inst
         SET X_PART_INST_STATUS = '39'
       WHERE part_serial_no = por_rec.min
         AND x_domain = 'LINES';
      dbms_output.put_line('No of Records updated Line status to 39:'||SQL%ROWCOUNT);
    EXCEPTION
      WHEN OTHERS THEN
        o_response := 'Table Part inst Not Updated';
    END;

    -- Update existing Port Out Case
    dbms_output.put_line('Case Id  :'||por_rec.case_id_number);

    IF por_rec.case_id_number IS NOT NULL THEN
      BEGIN
        UPDATE sa.table_case
        SET    title = 'Cancel Port Out',s_title = 'CANCEL PORT OUT'  -- Need to confirm, if required or not
        WHERE  id_number = por_rec.case_id_number;
        dbms_output.put_line('No of Records updated Case Title  :'||SQL%ROWCOUNT);
      EXCEPTION
        WHEN OTHERS THEN
          o_response := 'Table Case Title Not Updated';
      END;
    ELSE
      dbms_output.put_line('No Case Found ');
      o_response := 'No Case Found';
      RETURN;
    END IF;

    -- Create Call Trans
    BEGIN
      SELECT objid
      INTO n_user_objid
      FROM table_user
      WHERE s_login_name = (SELECT UPPER(USER) FROM dual);
    EXCEPTION
      WHEN OTHERS THEN
       -- default to SA objid
       n_user_objid := 268435556;
    END;

    cst  := cst.retrieve_min ( i_min => i_min );

    dbms_output.put_line('cst  response ;'||cst.response);

    ct := call_trans_type();

    ct := call_trans_type (i_call_trans2site_part        => cst.site_part_objid,
                           i_action_type                 => '2',
                           i_call_trans2carrier          => cst.carrier_objid, -- Objid of T-MOBILE SIMPLE
                           i_call_trans2dealer           => cst.inv_bin_objid,
                           i_call_trans2user             => n_user_objid, -- 'sa'
                           i_line_status                 => NULL,
                           i_min                         => cst.min,
                           i_esn                         => cst.esn,
                           i_sourcesystem                => 'TAS',
                           i_transact_date               => SYSDATE,
                           i_total_units                 => 0,
                           i_action_text                 => 'DEACTIVATION',
                           i_reason                      => 'Port Out Cancel',
                           i_result                      => 'Completed',
                           i_sub_sourcesystem            => cst.bus_org_id,
                           i_iccid                       => cst.iccid,
                           i_ota_req_type                => NULL,
                           i_ota_type                    => NULL,
                           i_call_trans2x_ota_code_hist  => NULL,
                           i_new_due_date                => NULL);

    ct := ct.save;

    dbms_output.put_line('ct.response:'||ct.response);

    IF ct.response NOT LIKE '%SUCCESS%' THEN
      o_response := 'Error creating call trans for IG :'||ct.response;
      ROLLBACK;
      RETURN;
    END IF;

    sp_seq('task', l_task_id);

    -- create Suspend ig record if LINE is Inactive
    igt := ig_transaction_type (i_esn                 => cst.esn,
                                i_action_item_id      => l_task_id,
                                i_msid                => i_min,
                                i_min                 => i_min,
                                i_technology_flag     => 'C',
                                i_order_type          => 'S', -- Suspend
                                i_template            => 'RSS',
                                i_rate_plan           => NULL,
                                i_zip_code            => NULL,
                                i_transaction_id      => NULL,
                                i_phone_manf          => NULL,
                                i_carrier_id          => NULL,
                                i_iccid               => NULL,
                                i_network_login       => NULL,
                                i_network_password    => NULL,
                                i_account_num         => NULL,
                                i_transmission_method => NULL,
                                i_status              => 'Q',
                                i_status_message      => o_response||' - '||i_request_no,
                                i_application_system  => 'IG',
                                i_skip_ig_validation  => 'Y');

    -- call the insert method
    ig := igt.ins;

    COMMIT;

  END IF;
  -- CR50499 Ends

  dbms_output.put_line('site_part_objid               :'||por_rec.site_part_objid                   );
  dbms_output.put_line('service_end_date              :'||por_rec.service_end_date                  );
  dbms_output.put_line('expiration_date               :'||por_rec.expiration_date                   );
  dbms_output.put_line('deactivation_reason           :'||por_rec.deactivation_reason               );
  dbms_output.put_line('notify_carrier                :'||por_rec.notify_carrier                    );
  dbms_output.put_line('site_part_status              :'||por_rec.site_part_status                  );
  dbms_output.put_line('service_plan_objid            :'||por_rec.service_plan_objid                );
  dbms_output.put_line('ild_transaction_status        :'||por_rec.ild_transaction_status            );
  dbms_output.put_line('esn_part_inst_status          :'||por_rec.esn_part_inst_status              );
  dbms_output.put_line('esn_part_inst_code            :'||por_rec.esn_part_inst_code                );
  dbms_output.put_line('reactivation_flag             :'||por_rec.reactivation_flag                 );
  dbms_output.put_line('contact_objid                 :'||por_rec.contact_objid                     );
  dbms_output.put_line('esn_new_personality_objid     :'||por_rec.esn_new_personality_objid         );
  dbms_output.put_line('pgm_enroll_objid              :'||por_rec.pgm_enroll_objid                  );
  dbms_output.put_line('pgm_enroll_charge_type        :'||por_rec.pgm_enroll_charge_type            );
  dbms_output.put_line('pgm_enroll_next_charge_date   :'||por_rec.pgm_enroll_next_charge_date       );
  dbms_output.put_line('account_group_objid           :'||por_rec.account_group_objid               );
  dbms_output.put_line('member_objid                  :'||por_rec.member_objid                      );
  dbms_output.put_line('member_status                 :'||por_rec.member_status                     );
  dbms_output.put_line('member_start_date             :'||por_rec.member_start_date                 );
  dbms_output.put_line('member_end_date               :'||por_rec.member_end_date                   );
  dbms_output.put_line('member_master_flag            :'||por_rec.member_master_flag                );
  dbms_output.put_line('service_order_stage_objid     :'||por_rec.service_order_stage_objid         );
  dbms_output.put_line('service_order_stage_status    :'||por_rec.service_order_stage_status        );
  dbms_output.put_line('min_part_inst_status          :'||por_rec.min_part_inst_status              );
  dbms_output.put_line('min_part_inst_code            :'||por_rec.min_part_inst_code                );
  dbms_output.put_line('min_cool_end_date             :'||por_rec.min_cool_end_date                 );
  dbms_output.put_line('min_warr_end_date             :'||por_rec.min_warr_end_date                 );
  dbms_output.put_line('repair_date                   :'||por_rec.repair_date                       );
  dbms_output.put_line('min_personality_objid         :'||por_rec.min_personality_objid             );
  dbms_output.put_line('min_new_personality_objid     :'||por_rec.min_new_personality_objid         );
  dbms_output.put_line('min_to_esn_part_inst_objid    :'||por_rec.min_to_esn_part_inst_objid        );
  dbms_output.put_line('last_cycle_date               :'||por_rec.last_cycle_date                   );
  dbms_output.put_line('port_in                       :'||por_rec.port_in                           );

EXCEPTION
  WHEN others THEN
    -- Return response to caller
    o_response := 'ERROR CANCELLING PORT OUT REQUEST: ' || SQLERRM;
    log_request ( i_min                     =>  i_min,
                  i_request_no              =>  i_request_no,
                  i_request_type            =>  'C',
                  i_short_parent_name       =>  NULL,
                  i_case_id_number          =>  NULL,
                  i_desired_due_date        =>  NULL,
                  i_nnsp                    =>  NULL,
                  i_directional_indicator   =>  NULL,
                  i_osp_account_no          =>  NULL,
                  i_response                =>  o_response,
                  i_esn                     =>  por_rec.esn,
                  i_brand_shared_group_flag =>  NULL,
                  i_request_xml             =>  i_request_xml,
                  i_error_code              =>  i_error_code,
                  i_error_message           =>  i_error_message);
    RETURN;
END cancel_request;
--CR47275
--
--
PROCEDURE create_close_port_out_case (ip_esn                    IN   VARCHAR2,
                                      ip_create_task_flag       IN   VARCHAR2,
                                      ip_create_case_flag       IN   VARCHAR2,
                                      ip_close_case_flag        IN   VARCHAR2,
                                      ip_new_service_provider   IN   VARCHAR2 DEFAULT NULL,
                                      op_error_code             OUT  VARCHAR2,
                                      op_error_msg              OUT  VARCHAR2)
IS
  P_CASE_DETAIL       VARCHAR2(200);
  P_ID_NUMBER         VARCHAR2(200);
  P_CASE_OBJID        NUMBER;
  P_ERROR_NO          VARCHAR2(200) := '0';
  P_ERROR_STR         VARCHAR2(200);
  lv_user_objid       NUMBER;
  LV_CONTACT_OBJID    NUMBER;
  lV_call_trans_objid NUMBER;
  -- task type
  tt sa.task_type := task_type ();
  t sa.task_type;
BEGIN

  OP_ERROR_CODE   :=  '0';

  BEGIN
    SELECT objid
    INTO lv_user_objid
    FROM table_user
    WHERE s_login_name = (SELECT UPPER(user) FROM DUAL);
  EXCEPTION
    WHEN OTHERS THEN
      -- default to SA objid
      lv_user_objid := 268435556;
  END;

  BEGIN
    SELECT x_part_inst2contact
    INTO   lv_contact_objid
    FROM   table_part_inst
    WHERE  part_serial_no = ip_esn;
  EXCEPTION
    WHEN OTHERS THEN
      OP_ERROR_CODE   :=  '99';
      OP_ERROR_MSG    :=  SQLERRM;
      RETURN;
  END;

  BEGIN
    SELECT call_trans_objid
    INTO   lV_call_trans_objid
    FROM   (SELECT objid call_trans_objid
            FROM   sa.table_x_call_trans
            WHERE  1                 = 1
            AND    x_service_id      = ip_esn
            AND    x_action_type     = '2'
            AND    x_result          = 'Completed'
            AND    x_action_text     = 'DEACTIVATION'
            AND    x_reason          = 'PORT OUT'
            AND    x_call_trans2user = lv_user_objid
            ORDER BY update_stamp DESC)
    WHERE  ROWNUM = 1;
  EXCEPTION
    WHEN OTHERS THEN
      lV_call_trans_objid := NULL;
  END;

  IF IP_CREATE_TASK_FLAG = 'Y' THEN
    --
    tt := task_type ( i_call_trans_objid  => lV_call_trans_objid,
                      i_contact_objid     => LV_CONTACT_OBJID,
                      i_order_type        => 'Update PortOut', -- New order type updated
                      i_bypass_order_type => 0, i_case_code => 0 );

    -- call the insert method to create a new task
    t := tt.ins;
    --
  END IF;

  IF IP_CREATE_CASE_FLAG = 'Y' THEN

    IF IP_NEW_SERVICE_PROVIDER IS NOT NULL THEN
      P_CASE_DETAIL    := 'NEW_SERVICE_PROVIDER||'||IP_NEW_SERVICE_PROVIDER||'||';
    ELSE
      P_CASE_DETAIL    := NULL;
    END IF;

    sa.CLARIFY_CASE_PKG.create_case (p_title => 'Port Out',
                                     p_case_type => 'Port Out',
                                     p_status => 'Pending',
                                     p_priority => 'Low',
                                     p_issue => 'PORT OUT',
                                     p_source => '',
                                     p_point_contact => '',
                                     p_creation_time => sysdate,
                                     p_task_objid => t.task_objid,
                                     p_contact_objid => lv_contact_objid,
                                     p_user_objid => lv_user_objid,
                                     p_esn => ip_esn,
                                     p_phone_num => '',
                                     p_first_name => '',
                                     p_last_name => '',
                                     p_e_mail => '',
                                     p_delivery_type => '',
                                     p_address => '',
                                     p_city => '',
                                     p_state => '',
                                     p_zipcode => '',
                                     p_repl_units => '',
                                     p_fraud_objid => '',
                                     p_case_detail => p_case_detail,
                                     p_part_request => '',
                                     p_id_number => p_id_number,
                                     p_case_objid => p_case_objid,
                                     p_error_no => p_error_no,
                                     p_error_str => p_error_str);

    IF P_ERROR_NO <> '0' THEN
      OP_ERROR_CODE :=  '99';
      OP_ERROR_MSG  :=  P_ERROR_STR;
      RETURN;
    END IF;

  END IF;
  --
  IF IP_CLOSE_CASE_FLAG = 'Y' THEN

    sa.CLARIFY_CASE_PKG.CLOSE_CASE (P_CASE_OBJID => P_CASE_OBJID,
                                    P_USER_OBJID => lV_user_objid,
                                    P_SOURCE     => 'PORT_OUT_PROCESS',
                                    P_RESOLUTION => 'Resolution Given',
                                    P_STATUS     => '',
                                    P_ERROR_NO   => P_ERROR_NO,
                                    P_ERROR_STR  => P_ERROR_STR);

    IF P_ERROR_NO <> '0' THEN
      OP_ERROR_CODE :=  '99';
      OP_ERROR_MSG  :=  P_ERROR_STR;
      RETURN;
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    OP_ERROR_CODE   :=  '99';
    OP_ERROR_MSG    :=  SQLERRM;
    util_pkg.insert_error_tab ( i_action => 'CREATE_CLOSE_PORT_OUT_CASE Main exception'
                              , i_key => ip_esn
                              , i_program_name => 'port_out_pkg.create_close_port_out_case'
                              , i_error_text => trim(SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,500)));
END CREATE_CLOSE_PORT_OUT_CASE;
--CR47275
--
--
PROCEDURE create_winback_case (i_min                    IN  VARCHAR2,
                               i_request_no             IN  VARCHAR2,
                               i_short_parent_name      IN  VARCHAR2,
                               i_desired_due_date       IN  DATE,
                               i_nnsp                   IN  VARCHAR2,
                               i_directional_indicator  IN  VARCHAR2,
                               i_osp_account_no         IN  VARCHAR2,
                               i_portout_carrier        IN  VARCHAR2,
                               i_request_xml            IN  xmltype,
                               o_case_id_number         IN  OUT VARCHAR2,
                               o_sms_send_flag          OUT VARCHAR2,
                               o_proceed_flag           OUT VARCHAR2,
                               o_errcode                OUT NUMBER,
                               o_errmsg                 OUT VARCHAR2)
AS
 v_winback_carrier                VARCHAR2(5) := 'N';
 v_winback_brand                  VARCHAR2(5) := 'N';
 v_request_count                  NUMBER      := 0;
 v_response                       VARCHAR2(500);
 io_port_out_request_objid        NUMBER; --TEMP
 cst  sa.customer_type            := customer_type();
 s    sa.customer_type            := customer_type();
 v_user_objid                     NUMBER;
 v_case_objid                     NUMBER;
 v_portin_case_count              NUMBER      := 0;
BEGIN

 o_proceed_flag := 'PORT OUT';
 o_errcode      := 0;
 o_errmsg       := 'Success';

 BEGIN --{
   SELECT COUNT(1)
     INTO v_portin_case_count
     FROM sa.table_case          c,
          sa.table_x_case_detail cd,
          sa.table_condition     tc
    WHERE 1=1
      AND c.x_case_type  = 'Port In'
      AND cd.x_name      = 'CURRENT_MIN'
      AND cd.x_value     = i_min
      AND cd.detail2case = c.objid
      AND tc.objid       = c.case_state2condition
      AND tc.s_title NOT LIKE 'CLOSE%'
      AND ROWNUM         = 1;
 EXCEPTION
   WHEN OTHERS THEN
     v_portin_case_count := 0;
 END; --}

 IF v_portin_case_count = 1 THEN
   o_proceed_flag := 'PORT OUT';
   o_sms_send_flag:= 'N';
   DBMS_OUTPUT.PUT_LINE('Internal Port In Case exists');
   RETURN;
 END IF ;

 --Check if carrier is eligible for WINBACK case
 BEGIN --{

   WITH DATA AS (
                 SELECT x_param_value str
                 FROM   sa.table_x_parameters
                 WHERE  x_param_name = 'WINBACK_CARRIER'
                )
   SELECT 'Y'
   INTO   v_winback_carrier
   FROM
   (
   SELECT trim(regexp_substr(str, '[^,]+', 1, LEVEL)) str
   FROM DATA
   CONNECT BY regexp_substr(str, '[^,]+', 1, LEVEL) IS NOT NULL
   )
   WHERE str = i_portout_carrier
   AND ROWNUM = 1;

 EXCEPTION
   WHEN OTHERS THEN
    v_winback_carrier := 'N';
 END; --}

 --Check if brand is eligible for WINBACK case
 BEGIN --{

   WITH DATA AS (
                 SELECT x_param_value str
                 FROM   sa.table_x_parameters
                 WHERE  x_param_name = 'WINBACK_BRAND'
                )
   SELECT 'Y'
   INTO   v_winback_brand
   FROM
   (
   SELECT trim(regexp_substr(str, '[^,]+', 1, LEVEL)) str
   FROM DATA
   CONNECT BY regexp_substr(str, '[^,]+', 1, LEVEL) IS NOT NULL
   )
   WHERE str = sa.util_pkg.get_bus_org_id(sa.util_pkg.get_esn_by_min(i_min))
   AND ROWNUM = 1;

 EXCEPTION
   WHEN OTHERS THEN
    v_winback_brand := 'N';
 END; --}

 DBMS_OUTPUT.PUT_LINE('Carrier Eligible: '||i_portout_carrier||' '||v_winback_carrier);

 IF v_winback_carrier <> 'Y' AND v_winback_brand <> 'Y' AND NVL(o_case_id_number,'0') = '0' THEN  --Non-VZW

   o_proceed_flag := 'PORT OUT';
   o_sms_send_flag:= 'N';
   DBMS_OUTPUT.PUT_LINE('Carrier not eligible for Winback offer.');
   RETURN;

 ELSIF  NVL(o_case_id_number,'0') <> '0' THEN  --TAS scenario

   o_proceed_flag := 'PORT OUT';
   o_sms_send_flag:= 'N';
   DBMS_OUTPUT.PUT_LINE('Customer rejected the offer.');
   RETURN;

 ELSIF v_winback_carrier = 'Y' AND v_winback_brand = 'Y' THEN  --First Timer

   o_proceed_flag := 'WINBACK';
   DBMS_OUTPUT.PUT_LINE('First time PORT OUT request. Create Winback ticket.');

 END IF;

 DBMS_OUTPUT.PUT_LINE('Proceed Flag: '||o_proceed_flag);

 IF o_proceed_flag = 'WINBACK' THEN
   --Check if recorded
   BEGIN
     SELECT COUNT(1)
     INTO   v_request_count
     FROM   sa.x_portout_winback_log
     WHERE  min             =  i_min
     AND    port_out_status =  'CASE CREATED';
   EXCEPTION
     WHEN OTHERS THEN
       v_request_count := 0;
   END;

   DBMS_OUTPUT.PUT_LINE('Case Created Count:'||v_request_count);

   IF v_request_count = 0 THEN    --{

     s := cst.retrieve_min ( i_min => i_min );

     --Check if case is not close

     BEGIN --{
       SELECT objid
       INTO   v_user_objid
       FROM   sa.table_user
       WHERE  s_login_name = 'SA';
     EXCEPTION
       WHEN OTHERS THEN
         v_user_objid := '268435556'; --SA objid
     END; --}

     sa.CLARIFY_CASE_PKG.create_case (p_title           => 'Win Back Port Out Request',
                                      p_case_type       => 'Win Back Port Out',
                                      p_status          => 'Pending',
                                      p_priority        => 'Low',
                                      p_issue           => 'WIN BACK',
                                      p_source          => 'BATCH',
                                      p_point_contact   => null,
                                      p_creation_time   => sysdate,
                                      p_task_objid      => null,
                                      p_contact_objid   => s.contact_objid,
                                      p_user_objid      => v_user_objid,
                                      p_esn             => s.esn,
                                      p_phone_num       => i_min,
                                      p_first_name      => s.first_name,
                                      p_last_name       => s.last_name,
                                      p_e_mail          => s.web_login_name,
                                      p_delivery_type   => null,
                                      p_address         => null,
                                      p_city            => null,
                                      p_state           => null,
                                      p_zipcode         => s.zipcode,
                                      p_repl_units      => null,
                                      p_fraud_objid     => null,
                                      p_case_detail     => null,
                                      p_part_request    => null,
                                      p_id_number       => o_case_id_number,
                                      p_case_objid      => v_case_objid,
                                      p_error_no        => o_errcode,
                                      p_error_str       => o_errmsg);

     DBMS_OUTPUT.PUT_LINE('New Winback Case Info: Objid'||v_case_objid||' ID:'||o_case_id_number);

     IF  NVL(o_case_id_number,0) = 0 AND  NVL(v_case_objid,0) = 0 THEN

       o_proceed_flag := 'PORT OUT';
       DBMS_OUTPUT.PUT_LINE('Case creation failed - Error: '||o_errmsg);
       RETURN;

     ELSE

       --Dispatch case
       IF NVL(o_errcode,'0') = '0' THEN

         DBMS_OUTPUT.PUT_LINE('In dispatch case: '||o_errcode);

         sa.CLARIFY_CASE_PKG.dispatch_case (p_case_objid => v_case_objid,
                                            p_user_objid => v_user_objid,
                                            p_queue_name => null,
                                            p_error_no   => o_errcode,
                                            p_error_str  => o_errmsg);

         BEGIN --{
           SELECT x_param_value
           INTO   o_sms_send_flag
           FROM   sa.table_x_parameters
           WHERE  x_param_name = 'WINBACK_SMS_FLAG';
         EXCEPTION
           WHEN OTHERS THEN
             o_sms_send_flag := 'N';
         END; --}

       END IF;

     END IF;

     --execute winback
     ins_upd_port_out_request (i_min                     => i_min,
                               i_esn                     => s.esn,
                               i_request_no              => i_request_no,
                               i_short_parent_name       => i_short_parent_name,
                               i_desired_due_date        => i_desired_due_date,
                               i_nnsp                    => i_nnsp,
                               i_directional_indicator   => i_directional_indicator,
                               i_osp_account_no          => i_osp_account_no,
                               i_winback_case_objid      => v_case_objid,     --case objid number
                               i_winback_case_id_number  => o_case_id_number, --case id number
                               i_winback_offer_status    => NULL,
                               i_portout_carrier         => i_portout_carrier,
                               i_port_out_status         => CASE
                                                            WHEN NVL(o_case_id_number,0) <> 0
                                                             AND NVL(v_case_objid,0) <> 0
                                                             AND o_errcode = 0
                                                               THEN 'CASE CREATED'
                                                               ELSE 'FAILED'
                                                            END,
                               i_Status_Message          => o_errmsg,
                               i_request_xml             => i_request_xml,
                               o_response                => v_response);

     DBMS_OUTPUT.PUT_LINE('v_response '||v_response);

   END IF; --}

 ELSE --}{

   o_proceed_flag := 'PORT OUT';
   o_sms_send_flag:= 'N';
   DBMS_OUTPUT.PUT_LINE('Case aleardy created. Proceed Flag: '||o_proceed_flag);
   RETURN;

 END IF;  --}

EXCEPTION
  WHEN OTHERS THEN
    o_proceed_flag := 'PORT OUT';
    o_sms_send_flag:= 'N';
    DBMS_OUTPUT.PUT_LINE('In main exception of create_winback_case');
END create_winback_case; --}
--
--
--CR51293 starts here
PROCEDURE ins_upd_port_out_request (i_min                       IN    VARCHAR2,
                                    i_esn                       IN    VARCHAR2             DEFAULT NULL,
                                    i_request_no                IN    VARCHAR2             DEFAULT NULL,
                                    i_short_parent_name         IN    VARCHAR2             DEFAULT NULL,
                                    i_desired_due_date          IN    DATE                 DEFAULT NULL,
                                    i_nnsp                      IN    VARCHAR2             DEFAULT NULL,
                                    i_directional_indicator     IN    VARCHAR2             DEFAULT NULL,
                                    i_osp_account_no            IN    VARCHAR2             DEFAULT NULL,
                                    i_winback_case_objid        IN    NUMBER               DEFAULT NULL,
                                    i_winback_case_id_number    IN    VARCHAR2             DEFAULT NULL,
                                    i_winback_offer_status      IN    VARCHAR2             DEFAULT NULL,
                                    i_port_out_status           IN    VARCHAR2             DEFAULT NULL,
                                    i_Status_Message            IN    VARCHAR2             DEFAULT NULL,
                                    i_portout_carrier           IN    VARCHAR2             DEFAULT NULL,
                                    i_SP_Objid                  IN    NUMBER               DEFAULT NULL,
                                    i_promo_type                IN    VARCHAR2             DEFAULT NULL,
                                    i_request_xml               IN    XMLTYPE,
                                    o_response                  OUT   VARCHAR2)
IS

PRAGMA AUTONOMOUS_TRANSACTION;
l_objid NUMBER;

BEGIN

  -- Get objid from winback case objid
  IF i_winback_case_objid IS NOT NULL OR i_winback_case_id_number IS NOT NULL THEN
    BEGIN
      SELECT objid INTO l_objid
        FROM sa.x_portout_winback_log
       WHERE (winback_case_objid = i_winback_case_objid OR winback_case_id_number = i_winback_case_id_number);
    EXCEPTION
      WHEN OTHERS THEN
       l_objid := NULL;
    END;
  END IF;

  IF l_objid IS NULL THEN
    SELECT sa.seq_portout_winback_log.NEXTVAL
    INTO   l_objid
    FROM   DUAL;
  END IF;

  -- Inserting or updating x_portout_winback_log table
  MERGE
  INTO   sa.x_portout_winback_log por
  USING  dual
  ON     (por.objid = l_objid)
  WHEN MATCHED THEN
       UPDATE
          SET min                     = NVL(i_min,  min                    ),
              esn                     = NVL(i_esn,  esn                    ),
              request_no              = NVL(i_request_no,  request_no             ),
              short_parent_name       = NVL(i_short_parent_name,  short_parent_name      ),
              desired_due_date        = NVL(i_desired_due_date,  desired_due_date       ),
              nnsp                    = NVL(i_nnsp,  nnsp                   ),
              directional_indicator   = NVL(i_directional_indicator,  directional_indicator  ),
              osp_account_no          = NVL(i_osp_account_no,  osp_account_no         ),
              winback_case_objid      = NVL(i_winback_case_objid,  winback_case_objid     ),
              winback_case_id_number  = NVL(i_winback_case_id_number,  winback_case_id_number ),
              winback_offer_status    = NVL(i_winback_offer_status,  winback_offer_status   ),
              port_out_status         = NVL(i_port_out_status,  port_out_status        ),
              Status_Message          = NVL(i_Status_Message,  Status_Message         ),
              portout_carrier         = NVL(i_portout_carrier,  portout_carrier        ),
              SP_Objid                = NVL(i_SP_Objid,  sp_objid               ),
              promo_type              = NVL(i_promo_type,  promo_type             ),
              request_xml             = NVL(i_request_xml,  request_xml            ),
              update_timestamp        = SYSDATE
  WHEN NOT MATCHED THEN
       INSERT (objid,
               min,
               esn,
               request_no,
               short_parent_name,
               desired_due_date,
               nnsp,
               directional_indicator,
               osp_account_no,
               winback_case_objid,
               winback_case_id_number,
               winback_offer_status,
               port_out_status,
               Status_Message,
               portout_carrier,
               request_xml,
               sp_Objid,
               promo_type,
               insert_timestamp,
               update_timestamp)
       VALUES (l_objid,
               i_min,
               i_esn,
               i_request_no,
               i_short_parent_name,
               i_desired_due_date,
               i_nnsp,
               i_directional_indicator,
               i_osp_account_no,
               i_winback_case_objid,
               i_winback_case_id_number,
               i_winback_offer_status,
               i_port_out_status,
               i_Status_Message,
               i_portout_carrier,
               i_request_xml,
               i_sp_objid,
               i_promo_type,
               SYSDATE,
               SYSDATE);

  COMMIT;

  o_response := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    o_response := 'ERROR INSERTING INTO x_portout_winback_log: '||SQLERRM;
    RETURN;
END ins_upd_port_out_request;
--
--
PROCEDURE process_winback_cases (o_errcode OUT NUMBER,
                                 o_errmsg  OUT VARCHAR2) AS

CURSOR   curr_winback_cases IS
SELECT   a.*
FROM     x_portout_winback_log a,
         table_x_parameters b
WHERE    port_out_status   = 'CASE CREATED'
AND      x_param_name      = 'WINBACK_REQUEST_TIMEOUT_INTERVAL'
AND      insert_timestamp  + (x_param_value / (24*60)) <SYSDATE;

v_winback_cases curr_winback_cases%ROWTYPE;
v_response   VARCHAR2(500) := '';
v_user_objid NUMBER;

BEGIN --{
 o_errcode := 0;
 o_errmsg  := '';

  BEGIN --{
   SELECT objid
   INTO   v_user_objid
   FROM   table_user
   WHERE  s_login_name = 'SA';
  EXCEPTION
  WHEN OTHERS THEN
   v_user_objid := '268435556'; --SA objid
  END; --}

 FOR i IN curr_winback_cases LOOP --{

   DBMS_OUTPUT.PUT_LINE('-------'||i.min||' '||i.esn||'-------');

   --Create PORT OUT tickets

   DBMS_OUTPUT.PUT_LINE('Creating PORT OUT Case');
   PORT_OUT_PKG.create_request ( i.min,
                                i.winback_case_id_number,
                                v_response);
   DBMS_OUTPUT.PUT_LINE('Creating PORT OUT Case Result: '||v_response);

   DBMS_OUTPUT.PUT_LINE('Closing Winback Case');
   sa.clarify_case_pkg.close_case( p_case_objid => i.winback_case_objid,
                                   p_user_objid => v_user_objid,
                                   p_source     => 'BATCH',
                                   p_resolution => 'Winback Case Closed By Job.',
                                   p_status     => 'Closed',
                                   p_error_no   => o_errcode,
                                   p_error_str  => o_errmsg);

   DBMS_OUTPUT.PUT_LINE('Closing Winback Case Result: '||o_errcode||' '||o_errmsg);

   DBMS_OUTPUT.PUT_LINE('Updating Status');

   PORT_OUT_PKG.ins_upd_port_out_request (i_min                     => i.min,
                                          i_esn                     => NULL,
                                          i_request_no              => NULL,
                                          i_short_parent_name       => NULL,
                                          i_desired_due_date        => NULL,
                                          i_nnsp                    => NULL,
                                          i_directional_indicator   => NULL,
                                          i_osp_account_no          => NULL,
                                          i_winback_case_objid      => i.winback_case_objid, --case objid number
                                          i_winback_case_id_number  => i.winback_case_id_number, --case id number
                                          i_winback_offer_status    => 'OFFER_EXPIRED',
                                          i_portout_carrier         => NULL,
                                          i_port_out_status         => 'COMPLETE',
                                          i_Status_Message          => 'SUCCESS',
                                          i_request_xml             => NULL,
                                          o_response                => v_response);

   DBMS_OUTPUT.PUT_LINE('Updating Status Response: '||v_response);
   DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------');

   COMMIT;

 END LOOP; --}

 o_errcode := 0;
 o_errmsg  := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    o_errcode := 1;
    o_errmsg  := 'Job Failed due to '||sqlerrm;
    DBMS_OUTPUT.PUT_LINE('In main exception due to '||sqlerrm);
END process_winback_cases; --}
--CR51293 Ends here
--
--
PROCEDURE get_winback_attributes (i_esn                    IN  VARCHAR2,
                                  i_sp_objid               IN  NUMBER,
                                  o_cos                    OUT VARCHAR2,
                                  o_work_force_pin_pn      OUT VARCHAR2,
                                  o_threshold              OUT NUMBER,
                                  o_addn_threshold         OUT NUMBER,
                                  o_errcode                OUT NUMBER,
                                  o_errmsg                 OUT VARCHAR2) AS

CURSOR   cur_winback_log (c_min IN VARCHAR2) IS
SELECT   a.*
FROM     x_portout_winback_log a
WHERE    a.min = c_min
AND      a.WINBACK_OFFER_STATUS IS NOT NULL
ORDER BY objid DESC; --Latest winback

v_winback_cases cur_winback_log%ROWTYPE;

CURSOR   cur_winback_attributes (c_sp_objid IN NUMBER) IS
SELECT   a.*
FROM     sa.x_offer_info a
WHERE    a.name         = 'WINBACK'
AND      SYSDATE BETWEEN start_date AND end_date
AND      a.sp_objid     = c_sp_objid
AND      ROWNUM         = 1; --One record

v_winback_attributes cur_winback_attributes%ROWTYPE;

pm sa.policy_mapping_config_type := sa.policy_mapping_config_type();

l_short_parent VARCHAR2(50);
l_min          VARCHAR2(30);

BEGIN

  --Validate Input
  IF i_esn IS NULL OR i_sp_objid IS NULL THEN
    o_errcode := 100;
    o_errmsg  := 'ESN OR SERVICE PLAN OBJID NOT PASSED';
    RETURN;
  END IF;

  l_min:= sa.customer_info.get_min ( i_esn => i_esn );

  --Check Winback case exists for this MIN
  OPEN cur_winback_log (l_min);
  FETCH cur_winback_log INTO v_winback_cases;

  IF cur_winback_log%NOTFOUND  THEN
    o_errcode := 101;
    o_errmsg  := 'NO WINBACK CASE FOR THE MIN';
    CLOSE cur_winback_log;
    RETURN;
  END IF;

  CLOSE cur_winback_log;

  IF NVL(v_winback_cases.winback_offer_status,'X') <> 'CUSTOMER_ACCEPTED' THEN
    o_errcode := 102;
    o_errmsg  := 'LAST WINBACK CASE IS NOT CUSTOMER_ACCEPTED';
    RETURN;
  END IF;

  --Check Winback offer exists for this Service Plan
  OPEN cur_winback_attributes (i_sp_objid);
  FETCH cur_winback_attributes INTO v_winback_attributes;

  IF cur_winback_attributes%NOTFOUND  THEN
    o_errcode := 103;
    o_errmsg  := 'NO WINBACK OFFER FOR THIS SERVICE PLAN';
    CLOSE cur_winback_attributes;
    RETURN;
  END IF;

  CLOSE cur_winback_attributes;

  IF NVL(v_winback_cases.promo_type,'X')  <> v_winback_attributes.promo_type THEN
    o_errcode := 104;
    o_errmsg  := 'WINBACK OFFER NOT ELIGIBLE FOR THIS SP AND ESN';
    RETURN;
  END IF;

  --Get the threshold value
  l_short_parent      := util_pkg.get_short_parent_name (util_pkg.get_parent_name ( i_esn => i_esn ) );
  pm                  := sa.policy_mapping_config_type  (i_cos           => v_winback_attributes.COS,
                                                         i_parent_name   => l_short_parent,
                                                         i_usage_tier_id => 2);    --100%

  --Assigning values to output parameters
  o_threshold         := pm.threshold;

  IF o_threshold IS NULL THEN --{
    BEGIN --{
     SELECT  threshold
     INTO    o_threshold
     FROM    sa.x_policy_mapping_config
     WHERE   cos = v_winback_attributes.COS
     AND     usage_tier_id = 2
     AND     rownum = 1;
    EXCEPTION
      WHEN OTHERS THEN
        o_threshold := '';
    END; --}
  END IF; --}

  o_cos               := v_winback_attributes.COS;
  o_work_force_pin_pn := v_winback_attributes.part_number;
  o_addn_threshold    := v_winback_attributes.unit_value; --Additional Data in MB

  o_errcode := 0;
  o_errmsg  := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    o_errcode := 1;
    o_errmsg  := 'Oracle Error: '||sqlerrm;
    DBMS_OUTPUT.PUT_LINE('In main exception due to '||sqlerrm);
END get_winback_attributes;
--
--
PROCEDURE set_portout_winback_promo (i_esn           IN  VARCHAR2,
                                     i_ig_order_type IN  VARCHAR2 DEFAULT NULL,
                                     o_errcode       OUT NUMBER,
                                     o_errmsg        OUT VARCHAR2)
AS

 v_min                VARCHAR2(50);
 v_work_force_pin_pn  VARCHAR2(30);
 v_cos                VARCHAR2(20);

 v_sp_objid           NUMBER;
 v_threshold          NUMBER;
 v_addn_threshold     NUMBER;

 CURSOR curr_winback_log(i_min VARCHAR2) IS
 SELECT *
 FROM   x_portout_winback_log
 WHERE  winback_offer_status = 'CUSTOMER_ACCEPTED'
 AND    min = i_min
 AND    ROWNUM = 1;

 rec_winback_log curr_winback_log%ROWTYPE;

BEGIN --{

  o_errcode := 0;
  o_errmsg  := '';

  IF i_esn IS NULL THEN --{
    o_errcode := -1;
    o_errmsg  := 'ESN not passed.';
    RETURN;
  END IF; --}

  v_min       := sa.customer_info.get_min(i_esn);
  v_sp_objid  := sa.customer_info.get_service_plan_objid(i_esn);

  IF v_min IS NULL OR NVL(v_sp_objid,0) = 0 THEN --{
    o_errcode := -2;
    o_errmsg  := 'MIN or Service Plan not found.';
    RETURN;
  END IF; --}

  OPEN  curr_winback_log(v_min);
  FETCH curr_winback_log INTO rec_winback_log;

  IF curr_winback_log%NOTFOUND THEN --{

    UPDATE sa.x_policy_rule_subscriber outt
    SET    inactive_flag    = 'Y',
           update_timestamp = SYSDATE
    WHERE  esn              = i_esn
    AND    EXISTS (SELECT 1
                   FROM   sa.x_offer_info inn
                   WHERE  inn.name  = 'WINBACK'
                   AND    inn.cos   = outt.cos);

    o_errcode := -3;
    o_errmsg  := 'ESN not eligible for Winback offer.';

    CLOSE curr_winback_log;

    RETURN;

  END IF; --}

  CLOSE curr_winback_log;

  BEGIN --{

    get_winback_attributes (i_esn               => i_esn,
                            i_sp_objid          => v_sp_objid,
                            o_cos               => v_cos,
                            o_work_force_pin_pn => v_work_force_pin_pn,
                            o_threshold         => v_threshold,
                            o_addn_threshold    => v_addn_threshold,
                            o_errcode           => o_errcode,
                            o_errmsg            => o_errmsg);

    DBMS_OUTPUT.PUT_LINE('ESN: '||i_esn||' o_cos:'||v_cos||' o_work_force_pin_pn:'||v_work_force_pin_pn||
                         ' o_threshold:'||v_threshold||' o_addn_threshold:'||v_addn_threshold||' o_errcode:'||o_errcode);

  EXCEPTION
    WHEN OTHERS THEN
      o_errcode := -4;
      o_errmsg  := 'Exception while calling get_winback_attributes '||sqlerrm;
      DBMS_OUTPUT.PUT_LINE('Failed in call get_winback_attributes '||sqlerrm);
      RETURN;
  END; --}

  IF NVL(v_cos, '0') = '0' OR i_ig_order_type = 'D' THEN --{

    DBMS_OUTPUT.PUT_LINE('COS not found'); --Update By ESN

    UPDATE sa.x_policy_rule_subscriber outt
    SET    inactive_flag    = 'Y',
           update_timestamp = SYSDATE
    WHERE  esn              = i_esn
    AND    EXISTS (SELECT 1
                   FROM   sa.x_offer_info inn
                   WHERE  inn.NAME  = 'WINBACK'
                   AND    inn.cos   = outt.cos);

    UPDATE x_portout_winback_log
    SET    winback_offer_status = 'OFFER_TERMINATED',
           status_message       = 'Customer is no more eligible for winback offer.',
           update_timestamp     = SYSDATE
    WHERE  objid                = rec_winback_log.objid
    AND    winback_offer_status = 'CUSTOMER_ACCEPTED';

  ELSE --}{

    DBMS_OUTPUT.PUT_LINE('COS found'||v_cos); --Update By MIN

    IF sa.customer_info.get_last_redemption_date (i_esn =>i_esn) > rec_winback_log.update_timestamp THEN --{

       UPDATE sa.x_policy_rule_subscriber outt
       SET    esn              = i_esn,
              cos              = v_cos,
              inactive_flag    = 'N',
              update_timestamp = SYSDATE
       WHERE  min              = v_min
       AND    EXISTS (SELECT 1
                      FROM   sa.x_offer_info inn
                      WHERE  inn.name  = 'WINBACK'
                      AND    inn.cos   = outt.cos);
    END IF; --}

  END IF; --}

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('In main set_portout_winback_promo exception.'||sqlerrm);
    o_errcode := -10;
    o_errmsg  := 'In set_portout_winback_promo main exception '||sqlerrm;
END set_portout_winback_promo; --}
--
--
END port_out_pkg;
/