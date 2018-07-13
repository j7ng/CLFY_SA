CREATE OR REPLACE PROCEDURE sa."CREATE_TMO_PORT_OUT" (
   i_min               VARCHAR2,
   OP_ERROR_CODE   OUT VARCHAR2,
   OP_ERROR_MSG    OUT VARCHAR2,
   o_response      OUT VARCHAR2)
AS
   -- customer type
   cst                     sa.customer_type := customer_type ();
   s                       sa.customer_type := customer_type ();
   l                       sa.customer_type := customer_type ();

   -- call trans type
   ct                      sa.call_trans_type := call_trans_type ();
   c                       sa.call_trans_type;

   -- task type
   tt                      sa.task_type := task_type ();
   t                       sa.task_type;

   --
   igt                     sa.ig_transaction_type := ig_transaction_type ();
   ig                      sa.ig_transaction_type;

   l_case_objid            NUMBER;
   l_user_objid            NUMBER;
   l_case_status           VARCHAR2 (100);
   l_case_msg              VARCHAR2 (100);
   l_case_id               table_case.id_number%TYPE;
   l_return                VARCHAR2 (100);
   l_returnmsg             VARCHAR2 (255);
   l_request_exist_count   NUMBER;
   l_task_id               NUMBER;

BEGIN
   IF i_min IS NULL
   THEN
      o_response := 'MIN NOT PASSED';
      RETURN;
   END IF;

   s := cst.retrieve_min (i_min => i_min);

   IF s.response NOT LIKE '%SUCCESS%'
   THEN
      -- Use the response from the customer type retrieve method
      o_response := s.response;
      -- exit
      RETURN;
   END IF;


   --Check MIN validation for TMO carrier CR 45350.
   IF s.parent_name NOT LIKE 'T%MO%'
   THEN
      o_response := 'MIN not belongs to TMO Carrier';
      -- exit
      RETURN;
   END IF;


   -- Get the user objid
   BEGIN
      SELECT objid
        INTO l_user_objid
        FROM table_user
       WHERE s_login_name = (SELECT UPPER (USER) FROM DUAL);
   EXCEPTION
      WHEN OTHERS
      THEN
         -- default to SA objid
         l_user_objid := 268435556;
         RETURN;
   END;

   -- Call the deactservice stored procedure (call trans and a task)
   sa.service_deactivation_code.deactservice (ip_sourcesystem      => 'TAS',
                                              ip_userobjid         => l_user_objid,
                                              ip_esn               => s.esn,
                                              ip_min               => i_min,
                                              ip_deactreason       => 'PORT OUT',
                                              intbypassordertype   => 0,
                                              ip_newesn            => NULL,
                                              ip_samemin           => 'true',
                                              op_return            => l_return,
                                              op_returnmsg         => l_returnmsg);

   DBMS_OUTPUT.put_line ('deact return' || l_return);
   DBMS_OUTPUT.put_line ('deact returnmsg' || l_returnmsg);

   IF (TRIM (l_returnmsg) <> '0')
   THEN                                        -- juda: find out return output
      o_response := 'ERROR IN DEACTIVATION : ' || l_returnmsg;

      RETURN;
   END IF;

   BEGIN
      SELECT call_trans_objid
        INTO ct.call_trans_objid                          --l_call_trans_objid
        FROM (  SELECT objid call_trans_objid
                  FROM table_x_call_trans
                 WHERE x_min = i_min
                   AND x_service_id = s.esn
                   AND x_action_type = '2'
                   AND x_result = 'Completed'
                   AND x_action_text || '' = 'DEACTIVATION'
                   AND x_reason || '' = 'PORT OUT'
                   AND x_call_trans2user = l_user_objid
              ORDER BY update_stamp DESC)
       WHERE ROWNUM = 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         o_response := 'CALL TRANS NOT FOUND';
         RETURN;
   END;

   DBMS_OUTPUT.
    put_line ('call trans objid             => ' || ct.call_trans_objid);

   -- set the values for the task to be created
   tt :=
      task_type (i_call_trans_objid    => ct.call_trans_objid,
                 i_contact_objid       => s.contact_objid,
                 i_order_type          => 'Update PortOut', -- New order type updated
                 i_bypass_order_type   => 0,
                 i_case_code           => 0);

   -- call the insert method to create a new task
   t := tt.ins;

   DBMS_OUTPUT.put_line ('t.response              => ' || t.response);

   -- if call_trans was not created successfully
   IF t.response NOT LIKE '%SUCCESS%'
   THEN
      o_response := t.response;
      -- exit the program and transfer control to the calling process
      ROLLBACK;
      RETURN;
   END IF;

   DBMS_OUTPUT.put_line ('t.task_objid            => ' || t.task_objid);

   -- create a case
   igate.sp_create_case (p_call_trans_objid   => ct.call_trans_objid,
                         p_task_objid         => t.task_objid,
                         p_queue_name         => 'Line Deactivation',
                         p_type               => 'Port Out', --CR 45350
                         p_title              => 'Auto Port Out', --CR 45350
                         p_case_objid         => l_case_objid);

   DBMS_OUTPUT.put_line ('case_objid => ' || l_case_objid);

   -- Validate the case was created successfully
   IF l_case_objid IS NULL
   THEN
      o_response := 'CASE CREATION FAILED';
      ROLLBACK;
      RETURN;
   END IF;

   UPDATE table_case
      SET case_type_lvl2 = s.bus_org_id
    WHERE objid = l_case_objid;

   --CR47153 changes

   -- Get the case id (id_number)
   BEGIN
      SELECT id_number
        INTO l_case_id
        FROM table_case
       WHERE objid = l_case_objid;
   EXCEPTION
      WHEN OTHERS
      THEN
         o_response := 'CASE ID NOT FOUND';
         ROLLBACK;
         RETURN;
   END;

   -- Close the case
   igate.sp_close_case (p_case_id           => l_case_id,
                        p_user_login_name   => 'sa',
                        p_source            => 'PORT_OUT_PROCESS',
                        p_resolution_code   => 'Resolution Given',
                        p_status            => l_case_status,
                        p_msg               => l_case_msg);

   DBMS_OUTPUT.put_line ('case status ' || l_case_status);

   -- When the case was not properly closed
   IF (l_case_msg = 'F')
   THEN
      o_response := 'PORT OUT CASE CLOSURE FAILED';
      ROLLBACK;
      RETURN;
   END IF;

   o_response := 'SUCCESS';
   -- Get the template value
   ig := ig_transaction_type ();
   ig.template :=
      igt.
       get_template (i_technology            => t.technology,
                     i_trans_profile_objid   => t.trans_profile_objid);
   igt :=
      ig_transaction_type (
         i_esn                   => s.esn,
         i_action_item_id        => t.task_id,
         i_msid                  => i_min,
         i_min                   => i_min,
         i_technology_flag       => 'C',
         i_order_type            => 'UPO',   -- New order type update port out
         i_template              => ig.template,
         i_rate_plan             => NULL,
         i_zip_code              => NULL,
         i_transaction_id        => NULL,
         i_phone_manf            => NULL,
         i_carrier_id            => NULL,
         i_iccid                 => NULL,
         i_network_login         => NULL,
         i_network_password      => NULL,
         i_account_num           => '1161',
         i_transmission_method   => 'AOL',
         i_status                => 'W',
         i_status_message        => o_response, --|| ' - ' || i_request_no,
         i_application_system    => NULL,
         i_skip_ig_validation    => 'Y');


   -- call the insert method
   ig := igt.ins;

   DBMS_OUTPUT.put_line ('ig status ;' || ig.status);
   DBMS_OUTPUT.put_line ('ig response ;' || ig.response);
   COMMIT;
END CREATE_TMO_PORT_OUT;
/