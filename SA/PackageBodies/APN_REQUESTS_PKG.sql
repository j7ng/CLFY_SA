CREATE OR REPLACE PACKAGE BODY sa.apn_requests_pkg AS

-- Added on 02/16/2015 by Juda Pena to determine the template and other information based on the provided min
PROCEDURE get_min_data ( i_min                   IN  VARCHAR2,
                         o_template              OUT VARCHAR2,
                         o_esn                   OUT VARCHAR2,
                         o_line_part_inst_status OUT VARCHAR2,
                         o_zip_code              OUT VARCHAR2,
                         o_phone_manufacturer    OUT VARCHAR2,
                         o_min_found_flag        OUT VARCHAR2,
                         o_rate_plan             OUT VARCHAR2,
                         o_bus_org_id            OUT VARCHAR2,
                         o_contact_objid         OUT NUMBER,
                         i_debug_flag            IN  BOOLEAN DEFAULT FALSE) AS

  -- Retrieve all the variables (using the min only) to be used to determine the template
  CURSOR c_get_min_data IS
    SELECT pi.part_serial_no esn,
           pi.x_part_inst2contact contact_objid,
           bo.objid bus_org_objid,
           bo.org_id bus_org_id,
           pn.x_technology technology,
           pn.x_manufacturer phone_manufacturer,
           sp.x_zipcode zip_code,
           pi_min.part_inst2carrier_mkt carrier_objid,
           pa.x_parent_name parent_name,
           pa.x_parent_id parent_id,
           pi_min.x_part_inst_status line_part_inst_status,
           pa.x_next_available next_available,
           NVL(
               ( SELECT 1
                 FROM   sa.x_next_avail_carrier nac
                 WHERE  nac.x_carrier_id = ca.x_carrier_id
                 AND    ROWNUM = 1
               ),0) next_avail_carrier,
           NULL template,
           NULL rate_plan,
           NVL( ( SELECT to_number(v.x_param_value)
                  FROM   table_x_part_class_values v,
                         table_x_part_class_params n
                  WHERE  1 = 1
                  AND    v.value2part_class  = pn.part_num2part_class
                  AND    v.value2class_param = n.objid
                  AND    n.x_param_name = 'DATA_SPEED'
                  AND rownum = 1
                ), NVL( x_data_capable,0)) data_speed,
           'Y' min_found_flag,
           'N' create_mform_ig_flag
    FROM   table_site_part sp,
           table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           table_part_inst pi_min,
           table_x_carrier ca,
           table_x_carrier_group cg,
           table_x_parent pa,
           table_bus_org bo
    WHERe  sp.x_min = i_min
    AND    sp.objid = pi.x_part_inst2site_part
    AND    pi.x_domain = 'PHONES'
    AND    ml.objid = pi.n_part_inst2part_mod
    AND    pn.objid = ml.part_info2part_num
    AND    pi_min.part_serial_no = sp.x_min
    AND    pi_min.x_domain = 'LINES'
    AND    ca.objid = pi_min.part_inst2carrier_mkt
    AND    cg.objid = ca.carrier2carrier_group
    AND    pa.objid = cg.x_carrier_group2x_parent
    AND    pn.part_num2bus_org = bo.objid
    ORDER BY ( CASE pn.x_manufacturer         WHEN 'BYOP' THEN 1 ELSE 2 END ) ASC,
             ( CASE pi_min.x_part_inst_status WHEN '13'   THEN 1 ELSE 2 END ) ASC, -- Line Status
             ( CASE pi.x_part_inst_status     WHEN '52'   THEN 1 ELSE 2 END ) ASC; -- Phone Status

  min_data_rec c_get_min_data%ROWTYPE;

BEGIN

  -- Retrieve all the variables (using the min only) to be used to determine the template
  OPEN  c_get_min_data;
  FETCH c_get_min_data into min_data_rec;
  IF c_get_min_data%NOTFOUND THEN
    --
    CLOSE c_get_min_data;
    -- Set flag to No since line was not found in the system
    o_min_found_flag := 'N';
    -- Exit the current routine
    RETURN;
  END IF;
  CLOSE c_get_min_data;

  -- Get the template from profile table (joined with the 'Activation' order type)
  BEGIN
    SELECT DISTINCT
           CASE min_data_rec.technology
             WHEN 'GSM' THEN x_gsm_trans_template
             WHEN 'CDMA' THEN x_d_trans_template
             ELSE x_transmit_template
           END template
    INTO   min_data_rec.template
    FROM   table_x_order_type ot,
           table_x_trans_profile tp
    WHERE  1 = 1
    AND    ot.x_order_type = 'Activation'
    AND    ot.x_order_type2x_carrier = min_data_rec.carrier_objid
    AND    ot.x_npa IS NULL -- default npa
    AND    ot.x_nxx IS NULL -- default nxx
    AND    tp.objid = ot.x_order_type2x_trans_profile;
   EXCEPTION
     WHEN no_data_found THEN
       -- Handle exception when no rows were returned to avoid failures
       min_data_rec.template := NULL;
     WHEN too_many_rows THEN
       -- Handle exception to avoid failures
       min_data_rec.template := NULL;
  END;

  -- Get the rate plan based on the esn
  min_data_rec.rate_plan := service_plan.f_get_esn_rate_plan ( p_esn => min_data_rec.esn);

  -- Determine if the rate plan is allowed to create apn requests
  BEGIN
    SELECT DISTINCT NVL(create_mform_ig_flag,'N')
    INTO   min_data_rec.create_mform_ig_flag
    FROM   table_x_carrier_features
    WHERE  x_rate_plan = min_data_rec.rate_plan
    AND    NVL(create_mform_ig_flag,'N') = 'Y'
    AND    ROWNUM = 1;
   EXCEPTION
     WHEN no_data_found THEN
       -- Blank out the rate plan when it's not allowed to create apn requests
       min_data_rec.rate_plan := NULL;
     WHEN too_many_rows THEN
       -- Allow too many rows to continue the process
       NULL;
     WHEN others THEN
       -- Handle others exception when the flag was not determined
       min_data_rec.rate_plan := NULL;
  END;

  -- If the technology is GSM and parent id in () (copied logic from igate)
  IF min_data_rec.technology = 'GSM' AND
     min_data_rec.parent_id IN ('6' ,'71' ,'76','1000000266') AND
     NVL(min_data_rec.next_available,0) = 1 AND
     min_data_rec.next_avail_carrier = 1
  THEN
    -- Overwrite to get the template from the cingular info table
    SELECT template
    INTO   min_data_rec.template
    FROM   sa.x_cingular_mrkt_info
    WHERE  zip = min_data_rec.zip_code
    AND    ROWNUM = 1; -- used to avoid too_many_rows
  END IF;

  -- Overwrite with TRACFONE Surepay (copied logic from igate)
  IF min_data_rec.bus_org_id = 'TRACFONE' THEN
    IF sa.device_util_pkg.get_smartphone_fun(min_data_rec.esn) = 0 AND
	   min_data_rec.template = 'RSS'
    THEN
      min_data_rec.template := 'SUREPAY';
    END IF;
  END IF;

  --
  --

  -- Set output variables
  o_template              := min_data_rec.template;
  o_esn                   := min_data_rec.esn;
  o_line_part_inst_status := min_data_rec.line_part_inst_status;
  o_zip_code              := min_data_rec.zip_code;
  o_phone_manufacturer    := min_data_rec.phone_manufacturer;
  o_min_found_flag        := NVL(min_data_rec.min_found_flag,'N');
  o_rate_plan             := min_data_rec.rate_plan;
  o_bus_org_id            := min_data_rec.bus_org_id;
  o_contact_objid         := min_data_rec.contact_objid;

 EXCEPTION
   WHEN others THEN
     -- Log error message
     util_pkg.insert_error_tab ( i_action       => 'exception when others clause for i_min = ' || i_min,
                                 i_key          => i_min,
								 i_program_name => 'mformation.get_min_data',
                                 i_error_text   => 'SQLERRM: ' || SQLERRM );
     RAISE;
END get_min_data;

--

PROCEDURE create_ig_apn_requests ( i_transaction_id IN  NUMBER   ,
                                   o_response       OUT VARCHAR2 ) AS

  -- call trans type
  ct  sa.call_trans_type := call_trans_type ();
  c   sa.call_trans_type;

  -- task type
  tt  sa.task_type := task_type ();
  t   sa.task_type;

  -- customer type
  rs  sa.customer_type;
  s   sa.customer_type;

  -- ig transaction type
  it sa.ig_transaction_type := ig_transaction_type ();
  i  sa.ig_transaction_type;

  l_apn_source_type     VARCHAR2(25) := NULL;
  l_create_ig_apn_flag  VARCHAR2(1);

  -- Record type to hold the ig transaction values to be inserted
  ig  gw1.ig_transaction%ROWTYPE := NULL;

  l_rate_plan_flag 		 VARCHAR2(1);
  l_mform_apn_rest_flag  VARCHAR2(1);
  l_apn_flag VARCHAR2(1) := 'N';

  CURSOR c_get_cf ( p_rate_plan VARCHAR2,
                    p_carrier_id NUMBER ) IS
    SELECT DISTINCT NVL(cf.create_mform_ig_flag,'N') create_mform_ig_flag
    FROM   table_x_carrier_features cf,
           table_x_carrier ca
    WHERE  1 = 1
    AND    cf.x_rate_plan = p_rate_plan
    AND    cf.x_feature2x_carrier = ca.objid
    AND    ca.x_carrier_id = p_carrier_id
    ORDER BY create_mform_ig_flag DESC;

BEGIN
  DBMS_OUTPUT.PUT_LINE('start of logic');

  -- This will make sure IG Transaction record is not for REDEMPTIONs, REACTIVATIONs, DEACTIVATIONs and
  -- and flag in x_ig_order_type is set to 'Y' for matching x_ig_order_type
  BEGIN
    SELECT *
    INTO   ig
    FROM   ig_transaction i
    WHERE  transaction_id = i_transaction_id
    AND    NOT EXISTS ( SELECT 1
                        FROM   table_task tt,
                               table_x_call_trans ct
                        WHERE  tt.task_id = i.action_item_id
                        AND    tt.x_task2x_call_trans = ct.objid
                        AND    ct.x_action_type IN ('6','3','2') -- to restrict REDEMPTIONs, REACTIVATIONs, DEACTIVATIONs
                      )
    AND    EXISTS ( SELECT 1
                    FROM   x_ig_order_type
                    WHERE  x_ig_order_type = i.order_type
                    AND    x_programme_name = 'SP_INSERT_IG_TRANSACTION'
                    AND    create_ig_apn_flag = 'Y'
                  );

   EXCEPTION
     WHEN OTHERS THEN
       o_response := 'APN CREATION NOT APPLICABLE';
       RETURN;
  END;

  --CR 47142, If order_type 'CR' and action_type 111 then create APN Request.
  IF ig.order_type = 'CR' THEN

  BEGIN
  SELECT 'Y'
   INTO l_apn_flag
   FROM table_task tt,
        table_x_call_trans ct
  WHERE tt.task_id = ig.action_item_id
    AND tt.x_task2x_call_trans = ct.objid
	AND ct.x_service_id = ig.esn
    AND ct.x_action_type = '111'
    AND ROWNUM = 1;

  IF l_apn_flag <> 'Y' THEN

     o_response := 'APN CREATION NOT APPLICABLE for order type CR';

     RETURN;

  END IF;


  EXCEPTION
  WHEN OTHERS THEN
    l_apn_flag := 'N';
    o_response := 'APN CREATION NOT APPLICABLE for order type CR';
    RETURN;
  END;
  END IF;  --CR 47142

  DBMS_OUTPUT.PUT_LINE('validating apn source type');

  -- Validate if the device mapping configuration applies to create the APN request
  BEGIN
    SELECT vw.apn_source_type
    INTO   l_apn_source_type
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           table_part_class pc,
           sa.pcpv_mv vw   --CR52840 pcpv replaced by pcpv_mv
    WHERE  pi.part_serial_no = ig.esn
    AND    pi.n_part_inst2part_mod= ml.objid
    AND    ml.part_info2part_num = pn.objid
    AND    pn.part_num2part_class = pc.objid
    AND    pc.name = vw.part_class;
  EXCEPTION
     WHEN OTHERS THEN
       -- Continue the process to create the APN
       NULL;
  END;

  --
  IF l_apn_source_type IS NULL THEN

    DBMS_OUTPUT.PUT_LINE('calling mformation package');

    -- Call the mformation wrapper
    mformation_pkg.clone_ig_trans_wrapper(i_transaction_id);

  ELSE -- l_apn_source_type IS NOT NULL ...

    DBMS_OUTPUT.PUT_LINE('calling apn_source_type is not null');

    -- get the template and order type
    BEGIN
      SELECT apn_order_type, validate_rate_plan_flag
             --template
      INTO   ig.order_type, l_rate_plan_flag
	         --ig.template
      FROM   sa.x_apn_source_type
      WHERE  apn_source_type = l_apn_source_type;
     EXCEPTION
       WHEN OTHERS THEN
         o_response := 'APN SOURCE TYPE NOT FOUND (' || l_apn_source_type || ')';
         RETURN;
    END;

	IF l_rate_plan_flag = 'Y' THEN
	    BEGIN
        SELECT   allow_mform_apn_rqst_flag
          INTO   l_mform_apn_rest_flag
          FROM   x_rate_plan
         WHERE   x_rate_plan = ig.rate_plan;

        EXCEPTION
         WHEN OTHERS THEN
          o_response := 'RATE PLAN NOT FOUND FOR APN REQUEST (' || ig.rate_plan || ')';
         RETURN;
      END;

		 IF nvl(l_mform_apn_rest_flag,'N') = 'N' then
			o_response := 'RATE PLAN NOT APPLICABLE FOR APN REQUEST (' || ig.rate_plan || ')';
         RETURN;
		END IF;
	END IF;



    dbms_output.put_line('esn = ' || ig.esn);
    dbms_output.put_line('min = ' || ig.min);

    ct.numeric_value := 0;

    -- avoid duplicate ig transactions
    BEGIN
      SELECT /*+ use_invisible_indexes */ COUNT(1)
      INTO   ct.numeric_value
      FROM   ig_transaction
      WHERE  esn = ig.esn
      AND    min = ig.min
      AND    order_type||'' = ig.order_type
      AND    TRUNC(creation_date) = TRUNC(SYSDATE);
     EXCEPTION
       WHEN no_data_found THEN
         ct.numeric_value := 0;
       WHEN others THEN
         ct.numeric_value := 0;
    END;

    -- make sure we do not create duplicate requests
    IF ct.numeric_value > 0 THEN
      o_response := 'DUPLICATE REQUESTS ( ' || ct.numeric_value || ') CREATED TODAY FOR ORDER TYPE (' || ig.order_type ||')';
      RETURN;
    END IF;

    -- START CREATE CALL TRANS

    -- instantiate the customer_type with the esn from ig
    rs := customer_type ( i_esn => ig.esn);

    -- calling the retrieve method
    s := rs.retrieve;


    -- instantiate call trans values
    ct  := call_trans_type ( i_esn              => ig.esn        ,
                             i_action_type      => '277'         , -- Using "ACTIVATION" action type temporarily but most likely we'll need a new action type for APN requests
                             i_sourcesystem     => 'API'         ,
                             i_sub_sourcesystem => s.bus_org_id  ,
                             i_reason           => 'APN REQUEST' ,
                             i_result           => 'Completed'   ,
                             i_ota_req_type     => NULL          , -- MO:Mobile Originating, MT:Mobile Terminating
                             i_ota_type         => '276'         , -- Using "OTA COMMAND" temporarily
                             i_total_units      => NULL          ,
                             i_total_days       => NULL          ,
                             i_total_sms_units  => NULL          ,
                             i_total_data_units => NULL          );

    -- call the insert method
    c := ct.ins;

    -- if call_trans was not created successfully
    IF c.response <> 'SUCCESS' THEN

      o_response := c.response;

      -- exit the program and transfer control to the calling process
      RETURN;

    END IF;

    -- END CREATE CALL TRANS

    -- START TASK LOGIC

    IF s.contact_objid IS NULL THEN
      o_response := 'CONTACT NOT FOUND';
      RETURN;
    END IF;

    -- START CREATE TASK

    tt := task_type ( i_call_trans_objid  => c.call_trans_objid ,
                      i_contact_objid     => s.contact_objid    ,
                      i_order_type        => ig.order_type      , --'APN'
                      i_bypass_order_type => 0                  ,
                      i_case_code         => 0                  );

    -- call the insert method
    t := tt.ins;

    -- if call_trans was not created successfully
    IF t.response <> 'SUCCESS' THEN

      o_response := t.response;

      -- exit the program and transfer control to the calling process
      RETURN;

    ELSIF t.task_objid IS NULL THEN
      o_response := 'TASK OBJID IS NULL';

      -- exit the program and transfer control to the calling process
      RETURN;

    END IF;

    -- if call_trans was not created successfully
    IF t.task_id IS NULL THEN

      o_response := 'TASK ID WAS NOT CREATED';

      -- exit the program and transfer control to the calling process
      RETURN;

    END IF;

    -- END CREATE TASK

    -- START IG
    -- initialize values

    -- To get Carrier_id from carrier_objid and pass it to IG_TRANSACTION
    IF s.carrier_objid IS NOT NULL THEN
      BEGIN
        select x_carrier_id
        into   ig.carrier_id
        from   table_x_carrier
        where objid = s.carrier_objid;
       exception
         when others then
           null;
      END;
    END IF;

    -- Set attributes
    ig.status_message    := NULL;
    ig.creation_date     := SYSDATE;
    ig.update_date       := SYSDATE;
    ig.blackout_wait     := SYSDATE;
    ig.min               := CASE WHEN substr(s.technology,1,1) = 'C' THEN ig.min ELSE ig.msid END; -- CR56772
    ig.new_msid_flag     := NULL;
    ig.action_item_id    := t.task_id;
    ig.order_type        := 'APN';
    ig.network_login     := CASE WHEN ig.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'tracfone' ELSE NULL END;
    ig.network_password  := CASE WHEN ig.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'Tr@cfon3' ELSE NULL END;
    ig.status            := 'Q';
    ig.transaction_id    := gw1.trans_id_seq.NEXTVAL + ( POWER(2,28));
    ig.technology_flag   := substr(s.technology,1,1);
	ig.phone_manf        := s.phone_manufacturer;

	it := ig_transaction_type ( i_action_item_id          => ig.action_item_id     ,
                                i_carrier_id              => ig.carrier_id         ,
                                i_order_type              => ig.order_type         ,
                                i_min                     => ig.min                ,
                                i_esn                     => ig.esn                ,
                                i_esn_hex                 => ig.esn_hex            ,
                                i_old_esn                 => ig.old_esn            ,
                                i_old_esn_hex             => ig.old_esn_hex        ,
                                i_pin                     => ig.pin                ,
                                i_phone_manf              => ig.phone_manf         ,
                                i_end_user                => ig.end_user           ,
                                i_account_num             => ig.account_num        ,
                                i_market_code             => ig.market_code        ,
                                i_rate_plan               => ig.rate_plan          ,
                                i_ld_provider             => ig.ld_provider        ,
                                i_sequence_num            => ig.sequence_num       ,
                                i_dealer_code             => ig.dealer_code        ,
                                i_transmission_method     => ig.transmission_method,
                                i_fax_num                 => ig.fax_num            ,
                                i_online_num              => ig.online_num         ,
                                i_email                   => ig.email              ,
                                i_network_login           => ig.network_login      ,
                                i_network_password        => ig.network_password   ,
                                i_system_login            => ig.system_login       ,
                                i_system_password         => ig.system_password    ,
                                i_template                => ig.template           ,
                                i_exe_name                => ig.exe_name           ,
                                i_com_port                => ig.com_port           ,
                                i_status                  => ig.status             ,
                                i_status_message          => ig.status_message        ,
                                i_fax_batch_size          => ig.fax_batch_size        ,
                                i_fax_batch_q_time        => ig.fax_batch_q_time      ,
                                i_expidite                => ig.expidite              ,
                                i_trans_prof_key          => ig.trans_prof_key        ,
                                i_q_transaction           => ig.q_transaction         ,
                                i_online_num2             => ig.online_num2           ,
                                i_fax_num2                => ig.fax_num2              ,
                                i_creation_date           => ig.creation_date         ,
                                i_update_date             => ig.update_date           ,
                                i_blackout_wait           => ig.blackout_wait         ,
                                i_tux_iti_server          => ig.tux_iti_server        ,
                                i_transaction_id          => ig.transaction_id        ,
                                i_technology_flag         => ig.technology_flag       ,
                                i_voice_mail              => ig.voice_mail            ,
                                i_voice_mail_package      => ig.voice_mail_package    ,
                                i_caller_id               => ig.caller_id             ,
                                i_caller_id_package       => ig.caller_id_package     ,
                                i_call_waiting            => ig.call_waiting          ,
                                i_call_waiting_package    => ig.call_waiting_package  ,
                                i_rtp_server              => ig.rtp_server            ,
                                i_digital_feature_code    => ig.digital_feature_code  ,
                                i_state_field             => ig.state_field           ,
                                i_zip_code                => ig.zip_code              ,
                                i_msid                    => ig.msid                  ,
                                i_new_msid_flag           => ig.new_msid_flag         ,
                                i_sms                     => ig.sms                   ,
                                i_sms_package             => ig.sms_package           ,
                                i_iccid                   => ig.iccid                 ,
                                i_old_min                 => ig.old_min               ,
                                i_digital_feature         => ig.digital_feature       ,
                                i_ota_type                => ig.ota_type              ,
                                i_rate_center_no          => ig.rate_center_no        ,
                                i_application_system      => ig.application_system    ,
                                i_subscriber_update       => ig.subscriber_update     ,
                                i_download_date           => ig.download_date         ,
                                i_prl_number              => ig.prl_number            ,
                                i_amount                  => ig.amount                ,
                                i_balance                 => ig.balance               ,
                                i_language                => ig.language              ,
                                i_exp_date                => ig.exp_date              ,
                                i_x_mpn                   => ig.x_mpn                 ,
                                i_x_mpn_code              => ig.x_mpn_code            ,
                                i_x_pool_name             => ig.x_pool_name           ,
                                i_imsi                    => ig.imsi                  ,
                                i_new_imsi_flag           => ig.new_imsi_flag         );
	/*
    it := ig_transaction_type ( i_esn                => ig.esn,
                                i_action_item_id     => t.task_id ,
                                i_msid               => ig.msid,
                                i_min                => ig.msid,
                                i_technology_flag    => substr(s.technology,1,1),
                                i_order_type         => ig.order_type,
                                i_template           => ig.template,
                                i_rate_plan          => ig.rate_plan,
                                i_zip_code           => ig.zip_code,
                                i_transaction_id     => gw1.trans_id_seq.NEXTVAL + ( POWER(2,28)) ,
                                i_phone_manf         => s.phone_manufacturer,
                                i_carrier_id         => ig.carrier_id,
                                i_network_login      => NULL, -- CASE WHEN ig.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'tracfone' ELSE NULL END;
                                i_network_password   => NULL, -- CASE WHEN ig.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'Tr@cfon3' ELSE NULL END;
                                i_status             => 'Q',
                                i_status_message     => NULL,
                                i_application_system => 'IG' );
    */
    -- insert ig row
    i := it.ins;

    -- if ig was not created successfully
    IF i.response <> 'SUCCESS' THEN
      --
      o_response := i.response;
      -- exit the program and transfer control to the calling process
      RETURN;
    END IF;

    o_response := 'SUCCESS';

  END IF;

 EXCEPTION
   WHEN others THEN
     o_response  := 'UNHANDLED EXCEPTION: ' || SQLERRM;
     sa.util_pkg.insert_error_tab ( i_action         => 'CREATING NEW APN REQUEST',
                                    i_key            => i_transaction_id,
                                    i_program_name   => 'APN_REQUESTS_PKG.CREATE_IG' ,
                                    i_error_text     => 'ERROR MESSAGE => ' ||SQLERRM );
END create_ig_apn_requests;

--

FUNCTION determine_template ( i_min        IN VARCHAR2 ,
                              i_esn        IN VARCHAR2 ,
                              i_bus_org_id IN VARCHAR2 ,
                              i_technology IN VARCHAR2 ,
                              i_zipcode    IN VARCHAR2 ) RETURN VARCHAR2 IS

  l_template           VARCHAR2(100);
  l_carrier_objid      NUMBER;
  l_parent_id          VARCHAR2(30);
  l_next_available     NUMBER;
  l_next_avail_carrier NUMBER;

BEGIN

  IF i_min IS NULL THEN
    RETURN NULL;
  END IF;

  BEGIN
    SELECT part_inst2carrier_mkt carrier_objid,
           pa.x_parent_id parent_id,
           pa.x_next_available next_available,
           NVL(
               ( SELECT 1
                 FROM   sa.x_next_avail_carrier nac
                 WHERE  nac.x_carrier_id = ca.x_carrier_id
                 AND    ROWNUM = 1
               ),0) next_avail_carrier
    INTO   l_carrier_objid,
           l_parent_id,
           l_next_available,
           l_next_avail_carrier
    FROM   table_part_inst pi_min,
           table_x_carrier ca,
           table_x_carrier_group cg,
           table_x_parent pa
    WHERE  pi_min.part_serial_no = i_min
    AND    pi_min.x_domain = 'LINES'
    AND    pi_min.part_inst2carrier_mkt = ca.objid
    AND    ca.carrier2carrier_group = cg.objid
    AND    cg.x_carrier_group2x_parent = pa.objid;
   EXCEPTION
     WHEN others THEN
       RETURN 0;
  END;

  -- Get the template from profile table (joined with the 'Activation' order type)
  BEGIN
    SELECT DISTINCT
           CASE i_technology
             WHEN 'GSM' THEN x_gsm_trans_template
             WHEN 'CDMA' THEN x_d_trans_template
             ELSE x_transmit_template
           END template
    INTO   l_template
    FROM   table_x_order_type ot,
           table_x_trans_profile tp
    WHERE  1 = 1
    AND    ot.x_order_type = 'Activation'
    AND    ot.x_order_type2x_carrier = l_carrier_objid
    AND    ot.x_npa IS NULL -- default npa
    AND    ot.x_nxx IS NULL -- default nxx
    AND    tp.objid = ot.x_order_type2x_trans_profile;
   EXCEPTION
     WHEN others THEN
       -- Handle exception to avoid failures
       l_template := NULL;
  END;

  -- If the technology is GSM and parent id in () (copied logic from igate)
  IF i_technology = 'GSM' AND
     l_parent_id IN ('6' ,'71' ,'76','1000000266') AND
     NVL(l_next_available,0) = 1 AND
     l_next_avail_carrier = 1
  THEN
    -- Overwrite to get the template from the cingular info table
    BEGIN
      SELECT template
      INTO   l_template
      FROM   sa.x_cingular_mrkt_info
      WHERE  zip = i_zipcode
      AND    ROWNUM = 1; -- used to avoid too_many_rows
     EXCEPTION
       WHEN others THEN
         -- Handle exception to avoid failures
         l_template := NULL;
    END;
  END IF;

  -- Overwrite with TRACFONE Surepay (copied logic from igate)
  IF i_bus_org_id = 'TRACFONE' THEN
    IF sa.device_util_pkg.get_smartphone_fun(i_esn) = 0 AND
       l_template = 'RSS'
    THEN
      l_template := 'SUREPAY';
    END IF;
  END IF;

  RETURN l_template;

 EXCEPTION
   WHEN others THEN
     RETURN '0';
END determine_template;

PROCEDURE create_ig_min ( i_min             IN  VARCHAR2 ,
                          i_apn_source_type IN  VARCHAR2,
                          o_response_code   OUT NUMBER,
                          o_response        OUT VARCHAR2 ) AS

  -- Record type to hold the ig transaction values to be inserted
  ig                       gw1.ig_transaction%ROWTYPE := NULL;
  l_line_part_inst_status  VARCHAR2(20);
  l_min_found_flag         VARCHAR2(1);
  l_rate_plan_found_flag   VARCHAR2(1);
  rate_plan_rec            x_rate_plan%ROWTYPE;
  l_dummy_value            NUMBER;
  l_phone_manufacturer     VARCHAR2(100);

  -- subscriber type
  rs  sa.customer_type;
  s   sa.customer_type;

  -- call trans type
  ct  sa.call_trans_type := call_trans_type ();
  c   sa.call_trans_type;

  -- task type
  tt  sa.task_type := task_type ();
  t   sa.task_type;

  -- ig transaction type
  it  sa.ig_transaction_type := ig_transaction_type ();
  i   sa.ig_transaction_type;

  l_rate_plan_flag 		 VARCHAR2(1);
  l_mform_apn_rest_flag  VARCHAR2(1);

BEGIN

  -- Make sure the min is a mandatory input parameter
  IF i_min IS NULL THEN
    --
    o_response_code := 1;
    o_response := 'MISSING REQUIRED PARAMETER [MIN]';
    --
    RETURN;
  END IF;

  -- Make sure the min is a mandatory input parameter
  IF i_apn_source_type IS NULL THEN
    --
    o_response_code := 1;
    o_response := 'MISSING REQUIRED PARAMETER [APN SOURCE TYPE]';
    --
    RETURN;
  END IF;

  --
  BEGIN
    SELECT pi_esn.part_serial_no
    INTO   ig.esn
    FROM   table_part_inst pi_min,
           table_part_inst pi_esn
    WHERE  pi_min.part_serial_no = i_min
    AND    pi_min.x_domain = 'LINES'
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst;
   EXCEPTION
     WHEN others THEN
       o_response_code := 1;
       o_response := 'MIN NOT FOUND';
       RETURN;
  END;

      -- get the template and order type
    BEGIN
      SELECT apn_order_type, validate_rate_plan_flag
             --template
      INTO   ig.order_type, l_rate_plan_flag
	         --ig.template
      FROM   sa.x_apn_source_type
      WHERE  apn_source_type = i_apn_source_type;
     EXCEPTION
       WHEN OTHERS THEN
	     o_response_code := 1;
         o_response := 'APN SOURCE TYPE NOT FOUND (' || i_apn_source_type || ')';
         RETURN;
    END;
	 -- instantiate the customer_type with the esn from ig
	  rs := customer_type ( i_esn => ig.esn);  --CR40763

	  -- calling the retrieve method
	  s := rs.retrieve;

	IF l_rate_plan_flag = 'Y' THEN
    BEGIN
        SELECT   allow_mform_apn_rqst_flag
          INTO   l_mform_apn_rest_flag
          FROM   x_rate_plan
          WHERE  x_rate_plan = s.rate_plan;    --CR40763
        EXCEPTION
         WHEN OTHERS THEN
          o_response := 'RATE PLAN NOT FOUND FOR APN REQUEST (' || s.rate_plan || ')';
         RETURN;
		END;

		 IF nvl(l_mform_apn_rest_flag,'N') = 'N' then
			o_response := 'RATE PLAN NOT APPLICABLE FOR APN REQUEST (' || s.rate_plan || ')';
         RETURN;

		END IF;
	END IF;



  IF s.response NOT LIKE '%SUCCESS%' THEN
    o_response_code := 5;
    o_response := 'LINE IS NOT FOUND IN THE SYSTEM';
    RETURN;
  END IF;

  IF s.bus_org_id IS NULL THEN
    o_response_code := 1;
    o_response := 'BRAND NOT FOUND';
    RETURN;
  END IF;

  IF s.contact_objid IS NULL THEN
    o_response_code := 1;
    o_response := 'CONTACT NOT FOUND';
    RETURN;
  END IF;

/*  --CR40763 Confirmation from Oyonys
  -- avoid duplicate ig transactions
  BEGIN
    SELECT COUNT(1)
    INTO   ct.numeric_value
    FROM   ig_transaction
    WHERE  esn = ig.esn
    AND    min = i_min
    AND    order_type||'' = ig.order_type
	AND    ig.order_type NOT IN ('APN') --CR40763
    AND    TRUNC(creation_date) = TRUNC(SYSDATE);
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- do not allow duplicate requests
  IF ct.numeric_value > 0 THEN
    o_response_code := 1;
    o_response := 'DUPLICATE REQUESTS CREATED TODAY';
    RETURN;
  END IF;
  */
  -- Make sure the line is active
  IF UPPER(s.site_part_status) != 'ACTIVE' THEN
    --
    o_response_code := 6;
    o_response  := 'LINE IS NOT ACTIVE (' || UPPER(s.site_part_status) || ')';
    --
    RETURN;

  END IF;

  -- If the rate plan was not found (based on the carrier_objid, technology, bus_org_objid, data_speed)
  IF s.rate_plan IS NULL THEN
    --
    o_response_code := 2;
    o_response  := 'MISSING REQUIRED PARAMETER [RATE PLAN]';
    --
    RETURN;
  END IF;

   -- determine the template							--CR40763
  ig.template := determine_template ( i_min        => i_min        ,
                                      i_esn        => ig.esn       ,
                                      i_bus_org_id => s.bus_org_id ,
                                      i_technology => s.technology ,
                                      i_zipcode    => s.zipcode    );

  -- Make sure the template is valid
  IF ig.template IS NULL THEN
    --
    o_response_code := 3;
    o_response  := 'MISSING REQUIRED PARAMETER [TEMPLATE]';
    --
    RETURN;
  END IF;

  -- Make sure the zip code is valid
  IF s.zipcode IS NULL THEN
    --
    o_response_code := 4;
    o_response  := 'MISSING REQUIRED PARAMETER [ZIP CODE]';
    --
    RETURN;
  END IF;

  -- Make sure the esn is valid
  IF ig.esn IS NULL THEN
    --
    o_response_code := 1;
    o_response  := 'MISSING REQUIRED PARAMETER [ESN]';
    --
    RETURN;
  END IF;

  -- START CREATE CALL TRANS
  --
  -- instantiate call trans values
  ct := call_trans_type ( i_esn              => ig.esn    ,
                          i_action_type      => '277'         , -- Using "ACTIVATION" action type temporarily but most likely we'll need a new action type for APN requests
                          i_sourcesystem     => 'SMS'         , --CR49653
                          i_sub_sourcesystem => s.bus_org_id       ,
                          i_reason           => 'APN REQUEST' ,
                          i_result           => 'Pending'     ,
                          i_ota_req_type     => NULL          , -- MO:Mobile Originating, MT:Mobile Terminating
                          i_ota_type         => '276'         , -- Using "OTA COMMAND" temporarily
                          i_total_units      => NULL          ,
                          i_total_days       => NULL          ,
                          i_total_sms_units  => NULL          ,
                          i_total_data_units => NULL          );

  -- call the insert method
  c := ct.ins;

  -- if call_trans was not created successfully
  IF c.response <> 'SUCCESS' THEN

   o_response_code := 1;
   o_response := c.response;

    -- exit the program and transfer control to the calling process
    RETURN;

  END IF;
  --
  -- END CREATE CALL TRANS


  -- START ACTION ITEM (TASK) LOGIC
  --
  tt := task_type ( i_call_trans_objid  => c.call_trans_objid ,
                    i_contact_objid     => s.contact_objid    ,
                    i_order_type        => ig.order_type      ,
                    i_bypass_order_type => 0                  ,
                    i_case_code         => 0                  );

  -- call the insert method
  t := tt.ins;

  -- if call_trans was not created successfully
  IF t.response <> 'SUCCESS' THEN
    --
    o_response_code := 1;
	o_response := t.response;
    -- exit the program and transfer control to the calling process
    RETURN;
  END IF;
  --
  -- END ACTION ITEM (TASK) LOGIC

  -- START IG
  --
  -- initialize values

  -- To get Carrier_id from carrier_objid and pass it to IG_TRANSACTION
  if s.carrier_objid is not null then
    begin
      select x_carrier_id
      into   ig.carrier_id
      from   TABLE_X_CARRIER
      where  objid = s.carrier_objid;
     exception
       when others then
         null;
    end;
  end if;

  it := ig_transaction_type ( i_esn                => ig.esn,
                              i_action_item_id     => t.task_id ,
                              i_msid               => i_min,
                              i_min                => i_min,
                              i_technology_flag    => substr(s.technology,1,1),
                              i_order_type         => ig.order_type,
                              i_template           => ig.template,
                              i_rate_plan          => s.rate_plan,
                              i_zip_code           => s.zipcode,
                              i_transaction_id     => gw1.trans_id_seq.NEXTVAL + ( POWER(2,28)) ,
                              i_phone_manf         => s.phone_manufacturer,
                              i_carrier_id         => ig.carrier_id,
                              i_network_login      => CASE WHEN ig.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'tracfone' ELSE NULL END,
                              i_network_password   => CASE WHEN ig.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'Tr@cfon3' ELSE NULL END,
                              i_status             => 'Q',
                              i_status_message     => NULL,
                              i_application_system => 'IG_3CI' );

  -- insert ig row
  i := it.ins;

  -- if ig was not created successfully
  IF i.response <> 'SUCCESS' THEN
    --
    o_response_code := 1;
    o_response := i.response;
    -- exit the program and transfer control to the calling process
    RETURN;
  END IF;
  --
  -- END IG


  -- instantiate values to mark call trans as completed
  ct := call_trans_type ( i_esn              => NULL,
                          i_result           => 'Completed' ,
                          i_call_trans_objid => c.call_trans_objid );

  -- mark call trans as completed
  c := ct.upd;

  IF c.response <> 'SUCCESS' THEN
    --
    o_response_code := 1;
    o_response := c.response;
    -- exit the program and transfer control to the calling process
    RETURN;

  END IF;

  -- return successful response to the caller
  o_response_code := 0;
  o_response  := 'SUCCESS';

EXCEPTION
   WHEN OTHERS THEN
     -- Log error message
     o_response := 'UNHANDLED EXCEPTION : ' || SQLERRM;
END create_ig_min;

PROCEDURE create_w3ci_apn ( i_min           IN  VARCHAR2 ,
                            i_rate_plan     IN  VARCHAR2 DEFAULT NULL,
                            o_response_code OUT NUMBER,
                            o_response      OUT VARCHAR2 ) AS

  -- Record type to hold the ig transaction values to be inserted
  ig                          gw1.ig_transaction%ROWTYPE := NULL;
  l_phone_manufacturer        VARCHAR2(100);
  l_create_mform_ig_flag      VARCHAR2(1);
  l_allow_mform_apn_rqst_flag VARCHAR2(1);

  -- customer type
  rs  sa.customer_type;
  s   sa.customer_type;

  -- call trans type
  ct  sa.call_trans_type := call_trans_type ();
  c   sa.call_trans_type;

  -- task type
  tt  sa.task_type := task_type ();
  t   sa.task_type;

  -- ig transaction type
  it  sa.ig_transaction_type := ig_transaction_type ();
  i   sa.ig_transaction_type;

BEGIN

  -- Make sure the min is a mandatory input parameter
  IF i_min IS NULL THEN
    --
    o_response_code := 1;
    o_response := 'MISSING REQUIRED PARAMETER [MIN]';
    --
    RETURN;
  END IF;

  --
  BEGIN
    SELECT pi_esn.part_serial_no
    INTO   ig.esn
    FROM   table_part_inst pi_min,
           table_part_inst pi_esn
    WHERE  pi_min.part_serial_no = i_min
    AND    pi_min.x_domain = 'LINES'
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst;
   EXCEPTION
     WHEN others THEN
       o_response_code := 1;
       o_response := 'MIN NOT FOUND';
       RETURN;
  END;

  -- instantiate the subscriber_type with the esn from ig
  rs := customer_type ( i_esn => ig.esn );

  -- calling the retrieve method
  s := rs.retrieve;

  IF s.response NOT LIKE '%SUCCESS%' THEN
    o_response_code := 3;
    o_response := 'LINE IS NOT FOUND IN THE SYSTEM';
    RETURN;
  END IF;

  -- Make sure the line is active
  IF UPPER(s.site_part_status) != 'ACTIVE' THEN
    --
    o_response_code := 4;
    o_response  := 'LINE IS NOT ACTIVE (' || UPPER(s.site_part_status) || ')';
    --
    RETURN;

  END IF;

  --CR40763 confirmation from Oyonys
  -- avoid duplicate ig transactions
  /*
  BEGIN
    SELECT  COUNT(1)
    INTO   ct.numeric_value
    FROM   ig_transaction ig
    WHERE  esn = ig.esn
    AND    min = i_min
    AND    order_type||'' = 'APN'
    AND    TRUNC(creation_date) = TRUNC(SYSDATE);
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- do not allow duplicate requests
  IF ct.numeric_value > 0 THEN
    o_response := 'DUPLICATE REQUESTS CREATED TODAY';
    RETURN;
  END IF;
  */
  -- determine the template
  ig.template := determine_template ( i_min        => i_min        ,
                                      i_esn        => ig.esn       ,
                                      i_bus_org_id => s.bus_org_id ,
                                      i_technology => s.technology ,
                                      i_zipcode    => s.zipcode    );


  -- If the rate plan was not found (based on the carrier_objid, technology, bus_org_objid, data_speed)
  IF s.rate_plan IS NULL THEN
    IF i_rate_plan IS NOT NULL THEN
      s.rate_plan := i_rate_plan;
    ELSE
      --
      o_response_code := 1;
      o_response  := 'MISSING REQUIRED PARAMETER [RATE PLAN]';
      --
      RETURN;
    END IF;
  END IF;

  -- validate rate plan with mformation
  BEGIN
    SELECT create_mform_ig_flag
    INTO   l_create_mform_ig_flag
    FROM   table_x_carrier_features
    WHERE  x_rate_plan = s.rate_plan
    AND    create_mform_ig_flag||'' = 'Y'
    AND    ROWNUM = 1;
   EXCEPTION
     WHEN no_data_found THEN
       o_response_code := 2;
       o_response  := 'RATE PLAN DOES NOT ALLOW APN REQUESTS [' || s.rate_plan || ']';
       --
       RETURN;
     WHEN others THEN
       l_create_mform_ig_flag := 'N';
  END;

  IF NVL(l_create_mform_ig_flag,'N') = 'N' THEN
    o_response_code := 2;
    o_response := 'RATE PLAN DOES NOT ALLOW APN REQUESTS [' || s.rate_plan || ']';
    RETURN;
  END IF;

  -- Make sure the template is valid
  IF ig.template IS NULL THEN
    --
    o_response_code := 1;
    o_response  := 'MISSING REQUIRED PARAMETER [TEMPLATE]';
    --
    RETURN;
  END IF;

  -- Make sure the zip code is valid
  IF s.zipcode IS NULL THEN
    --
    o_response_code := 1;
    o_response  := 'MISSING REQUIRED PARAMETER [ZIP CODE]';
    --
    RETURN;
  END IF;

  -- Make sure the esn is valid
  IF ig.esn IS NULL THEN
    --
    o_response_code := 1;
    o_response  := 'MISSING REQUIRED PARAMETER [ESN]';
    --
    RETURN;
  END IF;

  -- find out if the rate plan allows apn requests
  BEGIN
    --
    SELECT allow_mform_apn_rqst_flag
    INTO   l_allow_mform_apn_rqst_flag
    FROM   x_rate_plan
    WHERE  x_rate_plan = s.rate_plan;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- Validate the rate plan allows apn requests
  IF NVL(l_allow_mform_apn_rqst_flag,'N') = 'N' THEN
    --
    o_response_code := 6;
    o_response  := 'LINE IS NOT PART OF CARRIER THAT SUPPORTS APN SERVICE';
    --
    RETURN;

  END IF;
  --

  -- Validate if the device mapping configuration applies to create the APN request
  BEGIN
    SELECT vw.manufacturer
    INTO   l_phone_manufacturer
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           table_part_class pc,
           sa.pcpv_mv vw    --CR52840 pcpv replaced by pcpv_mv
    WHERE  pi.part_serial_no = ig.esn
    AND    pi.n_part_inst2part_mod = ml.objid
    AND    ml.part_info2part_num = pn.objid
    AND    pn.part_num2part_class = pc.objid
    AND    pc.name = vw.part_class
    AND    ( ( EXISTS ( SELECT 1
                        FROM   sa.x_apn_config_mapping acm -- new mapping configuration table
                        WHERE  ( ( acm.phone_manufacturer = vw.manufacturer OR phone_manufacturer IS NULL )
                                 AND
                                 ( acm.part_num_sourcesystem = pn.x_sourcesystem OR acm.part_num_sourcesystem IS NULL )
                                 AND
                                 ( acm.device_type = vw.device_type OR acm.device_type IS NULL)
                                 AND
                                 ( acm.bus_org = vw.bus_org OR acm.bus_org IS NULL)
                               )
                        AND    acm.clone_ig_flag = 'Y' -- allow clone ig transaction
                        AND    acm.inactive_flag = 'N' -- mapping row is active
                      )
              )
              OR
              ( vw.apn_request = 'Y' )
            );
   EXCEPTION
     WHEN no_data_found THEN
       o_response := 'DEVICE DOES NOT APPLY TO CREATE APN REQUEST';
       -- Transaction does not apply to create the APN request
       RETURN;
     WHEN too_many_rows THEN
       -- Continue the process to create the APN
       null;
     WHEN OTHERS THEN
       -- Continue the process to create the APN
       NULL;
  END;


  -- START CREATE CALL TRANS
  --
  -- instantiate call trans values
  ct := call_trans_type ( i_esn              => ig.esn        ,
                          i_action_type      => '277'         , -- Using "ACTIVATION" action type temporarily but most likely we'll need a new action type for APN requests
                          i_sourcesystem     => 'SMS'         , --CR49653
                          i_sub_sourcesystem => s.bus_org_id  ,
                          i_reason           => 'APN REQUEST' ,
                          i_result           => 'Pending'     ,
                          i_ota_req_type     => NULL          , -- MO:Mobile Originating, MT:Mobile Terminating
                          i_ota_type         => '276'         , -- Using "OTA COMMAND" temporarily
                          i_total_units      => NULL          ,
                          i_total_days       => NULL          ,
                          i_total_sms_units  => NULL          ,
                          i_total_data_units => NULL          );

  -- call the insert method
  c := ct.ins;

  -- if call_trans was not created successfully
  IF c.response <> 'SUCCESS' THEN

    o_response_code := 7;
    o_response := c.response;

    -- exit the program and transfer control to the calling process
    RETURN;

  END IF;

  --
  -- END CREATE CALL TRANS


  -- START ACTION ITEM (TASK) LOGIC

  --
  tt := task_type ( i_call_trans_objid  => c.call_trans_objid ,
                    i_contact_objid     => s.contact_objid    ,
                    i_order_type        => 'APN'              ,
                    i_bypass_order_type => 0                  ,
                    i_case_code         => 0                  );

  -- call the insert method
  t := tt.ins;

  -- if call_trans was not created successfully
  IF t.response <> 'SUCCESS' THEN
    --
    o_response_code := 1;
    o_response := t.response;
    -- exit the program and transfer control to the calling process
    RETURN;
  END IF;

  --
  -- END ACTION ITEM (TASK) LOGIC

  -- START IG
  --
  -- initialize values
  it := ig_transaction_type ( i_esn                => ig.esn,
                              i_action_item_id     => t.task_id ,
                              i_msid               => i_min,
                              i_min                => i_min,
                              i_technology_flag    => 'G',
                              i_order_type         => 'APN',
                              i_template           => ig.template,
                              i_rate_plan          => s.rate_plan,
                              i_zip_code           => s.zipcode,
                              i_transaction_id     => gw1.trans_id_seq.NEXTVAL + ( POWER(2,28)) ,
                              i_phone_manf         => s.phone_manufacturer,
                              i_network_login      => CASE WHEN ig.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'tracfone' ELSE NULL END,
                              i_network_password   => CASE WHEN ig.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'Tr@cfon3' ELSE NULL END,
                              i_status             => 'Q',
                              i_application_system => 'IG_3CI' );
  -- insert ig row
  i := it.ins;

  -- if ig was not created successfully
  IF i.response <> 'SUCCESS' THEN
    --
    o_response_code := 1;
    o_response := i.response;
    -- exit the program and transfer control to the calling process
    RETURN;
  END IF;
  --
  -- END IG

  -- instantiate values to mark call trans as completed
  ct := call_trans_type ( i_esn              => NULL,
                          i_result           => 'Completed' ,
                          i_call_trans_objid => c.call_trans_objid );

  -- mark call trans as completed
  c := ct.upd;

  IF c.response <> 'SUCCESS' THEN
    --
    o_response_code := 1;
    o_response := c.response;
    -- exit the program and transfer control to the calling process
    RETURN;

  END IF;

  -- Return successful response to the caller
  o_response_code := 0;
  o_response := 'SUCCESS';

EXCEPTION
   WHEN OTHERS THEN
     -- Log error message
     util_pkg.insert_error_tab ( i_action       => 'exception when others clause for i_min = ' || i_min || ', i_rate_plan = ' || i_rate_plan,
                                 i_key          => i_min,
								 i_program_name => 'apn_requests_pkg.create_w3ci_apn',
                                 i_error_text   => 'SQLERRM: ' || SQLERRM );

     o_response_code := 100;
     o_response := 'UNHANDLED EXCEPTION : ' || SQLERRM;
END create_w3ci_apn;

END apn_requests_pkg;
/