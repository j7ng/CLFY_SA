CREATE OR REPLACE PACKAGE BODY sa.hotline_request_pkg AS

-- Request for single ESN
PROCEDURE  create_hotline_esn_request ( in_esn       IN  VARCHAR2,
                                        in_rqsttype  IN  VARCHAR2,
                                        in_user      IN  VARCHAR2,
                                        out_err_num  OUT NUMBER,
                                        out_err_msg  OUT VARCHAR2 ) IS

  -- customer type
  rs  sa.customer_type;
  s   sa.customer_type;

  -- call trans type
  ct  sa.call_trans_type := call_trans_type ();
  c   sa.call_trans_type := call_trans_type ();

  -- task type
  tt  sa.task_type := task_type ();
  t   sa.task_type := task_type ();

  -- ig transaction type
  it sa.ig_transaction_type := ig_transaction_type ();
  i  sa.ig_transaction_type := ig_transaction_type ();

BEGIN

  -- Make sure the request type is passed
  IF in_rqsttype IS NULL THEN
     out_err_num := 1;
     out_err_msg := 'RqstType cannot be NULL';
     RETURN;
  END IF;

  -- Make sure the ESN is passed
  IF in_esn IS NULL THEN
      out_err_num := 1;
      out_err_msg :=  'ESN/RqstType cannot be NULL';
      RETURN;
  END IF;

  -- instantiate the customer_type with the esn
  rs := customer_type ( i_esn => in_esn);

  -- calling the customer type retrieve method
  s := rs.retrieve;

  IF s.response NOT LIKE '%SUCCESS%' THEN
    out_err_num  := 1;
    out_err_msg  := s.response;
    sa.util_pkg.insert_error_tab ( i_action         => 'GETTING ESN',
                                   i_key            =>  in_esn,
                                   i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_ESN_REQUEST' ,
                                   i_error_text     =>  out_err_msg );
    RETURN;
  END IF;

  -- Make sure the ESN is active
  IF s.esn_part_inst_status <> '52' THEN
    out_err_num  := 1;
    out_err_msg  := 'ESN IS NOT IN ACTIVE';
    sa.util_pkg.insert_error_tab ( i_action         => 'CHECKING ESN STATUS',
                                   i_key            =>  in_esn,
                                   i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_ESN_REQUEST' ,
                                   i_error_text     =>  out_err_msg );
    RETURN;

  END IF;

  -- Make sure the ESN is active
  IF s.site_part_status <> 'Active' THEN
    out_err_num  := 1;
    out_err_msg  := 'SITE PART IS NOT ACTIVE';
    sa.util_pkg.insert_error_tab ( i_action         => 'CHECKING SITE PART STATUS',
                                   i_key            =>  in_esn,
                                   i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_ESN_REQUEST' ,
                                   i_error_text     =>  out_err_msg );
    RETURN;

  END IF;

  -- START CREATE CALL TRANS

  -- Get the correct action type
  c.action_type := ct.get_action_type ( i_code_type => 'AT' ,
                                        i_code_name => in_rqsttype );
  -- Get the user objid based on the login name
  BEGIN
    SELECT objid
    INTO   c.user_objid
    FROM   table_user
    WHERE  s_login_name = in_user
	AND    ROWNUM = 1;
  EXCEPTION
      WHEN OTHERS THEN
        out_err_num  := 1;
        out_err_msg  := 'LOGIN USER NOT FOUND IN TABLE USER';
        sa.util_pkg.insert_error_tab ( i_action         => 'CHECKING ACCESS FOR APEX USER',
                                       i_key            =>  in_esn,
                                       i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_ESN_REQUEST' ,
                                       i_error_text     =>  out_err_msg );
    RETURN;
  END;
  --

  -- instantiate call trans values
  ct  := sa.call_trans_type ( i_esn               => in_esn            ,
                              i_action_type       => c.action_type     ,
                              i_sourcesystem      => 'TAS'             ,
                              i_sub_sourcesystem  => s.bus_org_id      ,
                              i_reason            => 'SOC'             ,
                              i_result            => 'Completed'       ,
                              i_ota_req_type      => NULL              ,
                              i_ota_type          => NULL              ,
                              i_total_units       => NULL              ,
                              i_total_days        => NULL              ,
                              i_total_sms_units   => NULL              ,
                              i_total_data_units  => NULL              ,
                              i_user_objid        => c.user_objid      ,
                              i_action_text       => in_rqsttype       ,
                              i_new_due_date      => NULL              ,
                              i_call_trans_objid  => NULL              );

  -- call the call trans insert method
  c := ct.ins;

  DBMS_OUTPUT.PUT_lINE('C.RESPONSE : ' || c.response);

  -- if call_trans was not created successfully
  IF c.response NOT LIKE '%SUCCESS%' THEN

    out_err_num := 4;
    out_err_msg := 'Error while insert call_trans: ' || c.response;
    sa.util_pkg.insert_error_tab ( i_action         => 'CALL_TRANS INSERT FAILED',
                                   i_key            =>  in_esn,
                                   i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_ESN_REQUEST' ,
                                   i_error_text     =>  Out_Err_Msg );
    RETURN;
  END IF;

  -- END CREATE CALL TRANS


  -- START CREATE TASK

  -- Make sure the contact is available
  IF s.contact_objid IS NULL THEN
    out_err_num   := 4;
    out_err_msg   := 'CONTACT INFO NOT FOUND';
    sa.util_pkg.insert_error_tab ( i_action         => 'CONTACT INFO NOT FOUND',
                                   i_key            =>  in_esn,
                                   i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_ESN_REQUEST' ,
                                   i_error_text     =>  out_err_msg );
    RETURN;
  END IF;

  -- Get order type
  t.order_type := it.get_ig_order_type ( i_actual_order_type => in_rqsttype );

  -- Make sure the order type is valid
  IF t.order_type IS NULL THEN
    out_err_num   := 4;
    out_err_msg   := 'ORDER TYPE NOT CONFIGURED';
    sa.util_pkg.insert_error_tab ( i_action         => 'ORDER TYPE NOT CONFIGURED',
                                   i_key            =>  in_esn,
                                   i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_ESN_REQUEST' ,
                                   i_error_text     =>  out_err_msg );
    RETURN;
  END IF;

  -- instantiate task attributes
  tt := task_type ( i_call_trans_objid  => c.call_trans_objid ,
                    i_contact_objid     => s.contact_objid    ,
                    i_order_type        => t.order_type       ,
                    i_bypass_order_type => 0                  ,
                    i_case_code         => 0                  );

  -- call the insert method
  t := tt.ins;

  IF t.response <> 'SUCCESS' OR t.task_objid IS NULL OR t.task_id IS NULL THEN
    out_err_num := 5;
    out_err_msg := 'ERROR INSERTING TABLE_TASK: ' || t.response;
    sa.util_pkg.insert_error_tab ( i_action         => 'ERROR INSERTING TABLE_TASK',
                                   i_key            =>  in_esn,
                                   i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_ESN_REQUEST' ,
                                   i_error_text     =>  out_err_msg );
    RETURN;
  END IF;

  -- END CREATE TASK


  -- START CREATE IG TRANSACTION

  -- Set the account number when carrier parent is Verizon
  IF    s.short_parent_name = 'VZW' THEN
        i.account_num := '1161';
		--
  ELSIF s.short_parent_name = 'ATT' THEN
    -- getting account number for att
	  BEGIN
	    SELECT account_num
	    INTO   i.account_num
      FROM   sa.x_cingular_mrkt_info
	    WHERE  zip = s.zipcode
	    AND    rownum = 1;
	  EXCEPTION
	    WHEN OTHERS THEN
	  	  i.account_num := NULL;
	  END;
    --
  ELSE
     i.account_num := NULL; -- need to check
  END IF;

  -- Get the template value
  i.template := it.get_template ( i_technology          => t.technology,
                                  i_trans_profile_objid => t.trans_profile_objid );

  -- Validate template is valid
  IF i.template IS NULL THEN
    out_err_num := 5;
    out_err_msg := 'TEMPLATE NOT FOUND';
    sa.util_pkg.insert_error_tab ( i_action         => 'ERROR TEMPLATE NOT FOUND',
                                   i_key            =>  in_esn,
                                   i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_ESN_REQUEST' ,
                                   i_error_text     =>  out_err_msg );
    RETURN;
  END IF;

  -- Set the network login and password
  IF i.template IN ('TMOBILE', 'TMOSM', 'TMOUN') THEN
    i.network_login    := 'tracfone';
    i.network_password := 'Tr@cfon3';
  ELSE
    i.network_login    :=  NULL;
    i.network_password :=  NULL;
  END IF;

  -- set ig order type the same value as the task order type
  i.order_type := t.order_type;

  -- instantiate ig attributes
  it := ig_transaction_type ( i_esn                 =>  in_esn                     ,
                              i_action_item_id      =>  t.task_id                  ,
                              i_msid                =>  s.min                      ,
                              i_min                 =>  s.min                      ,
                              i_technology_flag     =>  SUBSTR(s.technology,1,1)   ,
                              i_order_type          =>  i.order_type               ,
                              i_template            =>  i.template                 ,
                              i_rate_plan           =>  s.rate_plan                ,
                              i_zip_code            =>  s.zipcode                  ,
                              i_transaction_id      =>  gw1.trans_id_seq.NEXTVAL + ( POWER(2,28)),
                              i_phone_manf          =>  s.phone_manufacturer       ,
                              i_carrier_id          =>  s.carrier_objid            ,
                              i_iccid	            =>  s.iccid                    ,
                              i_network_login       =>  i.network_login            ,
                              i_network_password    =>  i.network_password         ,
                              i_account_num	        =>  i.account_num              ,
                              i_transmission_method =>  'AOL'                      ,
                              i_status              =>  'Q'                        ,
                              i_application_system  =>  'IG'                       ,
                              i_skip_ig_validation  =>  'Y'                        );

  -- insert ig row
  i := it.ins;

  IF i.response <> 'SUCCESS' THEN
    out_err_num  := 7;
    out_err_msg  := 'ERROR INSERTING IG_TRANSACTION: ' || i.response;
    sa.util_pkg.insert_error_tab ( i_action         => 'FAILED INSERT IG_TRANSACTION',
                                   i_key            =>  in_esn,
                                   i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_ESN_REQUEST' ,
                                   i_error_text     =>  Out_Err_Msg );
    RETURN;
  END IF;

  -- END CREATE IG TRANSACTION

  out_err_num  := 0;
  out_err_msg  := 'success';

EXCEPTION
   WHEN OTHERS THEN
     out_Err_Num  := 1;
     out_Err_Msg  := 'UNHANDLED EXCEPTION: ' || SQLERRM;
     sa.util_pkg.insert_error_tab ( i_action         => 'CREATING HOTLINE REQUEST',
                                    i_key            =>  NULL,
                                    i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_ESN_REQUEST' ,
                                    i_error_text     =>  Out_Err_Msg );
END create_hotline_esn_request;


--for set of esn transactions
PROCEDURE create_hotline_set_request ( in_set_esn  IN  esn_tbl  ,
                                       in_rqsttype IN  VARCHAR2 ,
                                       out_err_num OUT NUMBER   ,
                                       out_err_msg OUT VARCHAR2 ) IS

  -- esn type
  esn_list sa.esn_tbl := in_set_esn;

  -- call trans type
  ct  sa.call_trans_type := call_trans_type ();
  c   sa.call_trans_type;

  -- task type
  tt  sa.task_type := task_type ();
  t   sa.task_type := task_type ();

  -- customer type
  rs  sa.customer_type;
  s   sa.customer_type;

  -- ig transaction type
  it sa.ig_transaction_type := ig_transaction_type ();
  i  sa.ig_transaction_type := ig_transaction_type ();

BEGIN

  IF (in_rqsttype IS NULL) THEN
     Out_Err_Num := 1;
     Out_Err_Msg := 'RqstType cannot be NULL';
     RETURN;
  END IF;

  IF esn_list.COUNT > 0 THEN

    FOR idx IN 1 .. esn_list.COUNT LOOP

	  ct  := call_trans_type ();
      c   := call_trans_type ();

      tt  := task_type ();
      t   := task_type ();

      Out_Err_Num  := NULL;
      Out_Err_Msg  := NULL;

      DBMS_OUTPUT.PUT_LINE('Element: '|| idx || ' ESN value being processed: ' || esn_list(idx));
      DBMS_OUTPUT.PUT_LINE('In_RqstType ' || In_RqstType);

      IF esn_list(idx) IS NULL THEN
        Out_Err_Num := 1;
        Out_Err_Msg :=  'ESN cannot be NULL';
        RETURN;
      END IF;

      -- instantiate the customer_type with the esn from ig
      rs := customer_type ( i_esn => esn_list(idx) );

      -- calling the retrieve method
      s := rs.retrieve;

      IF s.response NOT LIKE '%SUCCESS%' THEN
        out_err_num  := 1;
        out_err_msg  := s.response;
        sa.util_pkg.insert_error_tab ( i_action         => 'GETTING ESN',
                                       i_key            =>  esn_list(idx),
                                       i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_SET_REQUEST' ,
                                       i_error_text     =>  out_err_msg );
        RETURN;
      END IF;

      -- Make sure the ESN is active
      IF s.esn_part_inst_status <> '52' THEN
        out_err_num  := 1;
        out_err_msg  := 'ESN is not Active';
        sa.util_pkg.insert_error_tab ( i_action         => 'CHECKING ESN STATUS',
                                       i_key            =>  esn_list(idx),
                                       i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_SET_REQUEST' ,
                                       i_error_text     =>  out_err_msg );
        RETURN;

      END IF;

      -- START CREATE CALL TRANS

      -- Get the correct action type
      c.action_type := ct.get_action_type ( i_code_type => 'AT' ,
                                            i_code_name => in_rqsttype );

      -- instantiate call trans values
      ct  := sa.call_trans_type (  i_esn               => esn_list(idx)     ,
                                   i_action_type       => c.action_type     ,
                                   i_sourcesystem      => 'TAS'             ,
                                   i_sub_sourcesystem  => s.bus_org_id      ,
                                   i_reason            => 'SOC'             ,
                                   i_result            => 'Completed'       ,
                                   i_ota_req_type      => NULL              ,
                                   i_ota_type          => NULL              ,
                                   i_total_units       => NULL              ,
                                   i_total_days        => NULL              ,
                                   i_total_sms_units   => NULL              ,
                                   i_total_data_units  => NULL              ,
                                   i_user_objid        => NULL              ,
                                   i_action_text       => in_rqsttype       ,
                                   i_new_due_date      => NULL              ,
                                   i_call_trans_objid  => NULL              );

      -- call the insert method
      c := ct.ins;

      -- if call_trans was not created successfully
      IF c.response <> 'SUCCESS' THEN
        --
        out_err_num := 1;
        out_err_msg := 'Error while insert call_trans';
        sa.util_pkg.insert_error_tab ( i_action         => 'CALL_TRANS INSERT FAILED',
                                       i_key            =>  esn_list(idx),
                                       i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_SET_REQUEST' ,
                                       i_error_text     =>  out_err_msg );
        CONTINUE;
      END IF;

      -- need to check for this condition
      IF s.contact_objid IS NULL THEN
        out_err_num := 1;
        out_err_msg := 'CONTACT INFO NOT FOUND';
        sa.util_pkg.insert_error_tab ( i_action         => 'CONTACT INFO NOT FOUND',
                                       i_key            =>  esn_list(idx),
                                       i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_SET_REQUEST' ,
                                       i_error_text     =>  out_err_msg );
        CONTINUE;
      END IF;

      -- Get order type
      t.order_type := it.get_ig_order_type ( i_actual_order_type => in_rqsttype );

      -- Make sure the order type is valid
      IF t.order_type IS NULL THEN
        out_err_num   := 4;
        out_err_msg   := 'ORDER TYPE NOT CONFIGURED';
        sa.util_pkg.insert_error_tab ( i_action         => 'ORDER TYPE NOT CONFIGURED',
                                       i_key            =>  esn_list(idx),
                                       i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_ESN_REQUEST' ,
                                       i_error_text     =>  out_err_msg );
        CONTINUE;
      END IF;

      tt := task_type ( i_call_trans_objid  => c.call_trans_objid ,
                        i_contact_objid     => s.contact_objid    ,
                        i_order_type        => t.order_type       ,
                        i_bypass_order_type => 0                  ,
                        i_case_code         => 0                  );

      -- call the insert method
      t := tt.ins;

      IF t.response <> 'SUCCESS' OR t.task_objid IS NULL  OR t.task_id IS NULL THEN

        out_err_num := 1;
        out_err_msg := 'ERROR WHILE INSERT TABLE_TASK';
        sa.util_pkg.insert_error_tab ( i_action         => 'FAILED INSERT TABLE_TASK',
                                       i_key            =>  esn_list(idx),
                                       i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_SET_REQUEST' ,
                                       i_error_text     =>  Out_Err_Msg );
        CONTINUE;
      END IF;

      DBMS_OUTPUT.PUT_LINE ('t.task_objid'||t.task_objid);
      DBMS_OUTPUT.PUT_LINE ('t.task_id '  ||t.task_id   );

      IF s.short_parent_name = 'VZW' THEN
         i.account_num  := '1161';
      ELSE
         i.account_num  := NULL;
      END IF;

      -- Get the template value
      i.template := it.get_template ( i_technology          => t.technology,
                                      i_trans_profile_objid => t.trans_profile_objid );

      -- Set the network login and password
      IF i.template IN ('TMOBILE', 'TMOSM', 'TMOUN') THEN
        i.network_login    := 'tracfone';
        i.network_password := 'Tr@cfon3';
      ELSE
        i.network_login    :=  NULL;
        i.network_password :=  NULL;
      END IF;

      -- set ig order type the same value as the task order type
      i.order_type := t.order_type;


      it := ig_transaction_type ( i_esn                 => esn_list(idx)              ,
                                  i_action_item_id      => t.task_id                  ,
                                  i_msid                => s.min                      ,
                                  i_min                 => s.min                      ,
                                  i_technology_flag     => SUBSTR(s.technology,1,1)   ,
                                  i_order_type          => i.order_type               ,
                                  i_template            => i.template                 ,
                                  i_rate_plan           => s.rate_plan                ,
                                  i_zip_code            => s.zipcode                  ,
                                  i_transaction_id      => gw1.trans_id_seq.NEXTVAL + ( POWER(2,28)),
                                  i_phone_manf          => s.phone_manufacturer       ,
                                  i_carrier_id          => s.carrier_objid            ,
                                  i_iccid               => s.iccid                    ,
                                  i_network_login       => i.network_login            ,
                                  i_network_password    => i.network_password         ,
                                  i_account_num         => i.account_num              ,
                                  i_transmission_method => 'AOL'                      ,
                                  i_status              => 'Q'                        ,
                                  i_application_system  => 'IG'                       ,
				  i_skip_ig_validation  => 'Y'                        );

      -- insert ig row
      i := it.ins;

      IF i.response <> 'SUCCESS' THEN
        out_err_num  := 1;
        out_err_msg  := 'ERROR WHILE INSERT IN IG_TRANS';
        sa.util_pkg.insert_error_tab ( i_action         => 'FAILED INSERT IG_TRANS',
                                       i_key            =>  esn_list(idx),
                                       i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_SET_REQUEST' ,
                                       i_error_text     =>  out_err_msg );
        CONTINUE;
      END IF;

    END LOOP; -- idx

  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     out_err_num := 1;
     out_err_msg := 'UNHANDLED EXCEPTION: ' || SQLERRM;
     sa.util_pkg.insert_error_tab ( i_action         => 'CREATING HOTLINE REQUEST',
                                    i_key            =>  NULL,
                                    i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_SET_REQUEST_REQUEST' ,
                                    i_error_text     =>  out_err_msg );
END create_hotline_set_request;

PROCEDURE create_hotline_sms ( in_min        IN  VARCHAR2  ,
                               in_rqsttype   IN  VARCHAR2  ,
                               in_short_code IN  VARCHAR2  ,
                               in_sms_msg    IN  VARCHAR2  ,
                               in_user       IN  VARCHAR2  ,
                               out_err_num   OUT NUMBER    ,
                               out_err_msg   OUT VARCHAR2  ) is

  -- call trans type
  ct  sa.call_trans_type := call_trans_type ();
  c   sa.call_trans_type;

  -- task type
  tt  sa.task_type := task_type ();
  t   sa.task_type;

  -- customer type
  rs  sa.customer_type := customer_type ();
  s   sa.customer_type := customer_type ();

  -- ig transaction type
  it  sa.ig_transaction_type := ig_transaction_type ();
  ig  sa.ig_transaction_type;

BEGIN


  -- Make sure the min is a mandatory input parameter
  IF in_min IS NULL THEN
    --
    Out_Err_Num := 1;
    Out_Err_Msg := 'MISSING REQUIRED PARAMETER [MIN]';
    --
    RETURN;
  END IF;

  -- Make sure the request_type is a mandatory input parameter
  IF In_RqstType IS NULL THEN
    --
    Out_Err_Num := 1;
    Out_Err_Msg := 'MISSING REQUIRED PARAMETER [REQUEST TYPE]';
    --
    RETURN;
  END IF;

 -- Make sure the request_type is a mandatory input parameter
  IF In_sms_msg IS NULL THEN
    --
    Out_Err_Num := 1;
    Out_Err_Msg := 'MISSING REQUIRED PARAMETER [SMS MESSAGE]';
    --
    RETURN;
  END IF;

  -- calling the retrieve method
  s := rs.retrieve_min ( i_min => in_min );

  IF s.response NOT LIKE '%SUCCESS%' THEN
    out_err_num := 5;
    out_err_msg := 'LINE IS NOT FOUND IN THE SYSTEM';
    RETURN;
  END IF;

  IF s.esn IS NULL THEN
    out_err_num  := 1;
    out_err_msg  := 'MIN NOT FOUND';
    sa.util_pkg.insert_error_tab ( i_action         => 'MIN NOT FOUND',
                                   i_key            =>  s.min,
                                   i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_SMS' ,
                                   i_error_text     =>  Out_Err_Msg );
    RETURN;
  END IF;

  IF s.bus_org_id IS NULL THEN
    out_err_num := 5;
    out_err_msg := 'BRAND NOT FOUND';
    RETURN;
  END IF;

  IF s.contact_objid IS NULL THEN
    out_err_num := 5;
    out_err_msg := 'CONTACT NOT FOUND';
    RETURN;
  END IF;

  -- Make sure the line is active
  IF UPPER(s.site_part_status) NOT IN  ( 'ACTIVE', 'CARRIERPENDING' ) THEN
    --
    out_err_num := 6;
    out_err_msg := 'LINE IS NOT ACTIVE (' || UPPER(s.site_part_status) || ')';
    --
    RETURN;

  END IF;

  -- Make sure the zip code is valid
  IF s.zipcode IS NULL THEN
    --
    out_err_num := 4;
    out_err_msg := 'MISSING REQUIRED PARAMETER [ZIP CODE]';
    --
    RETURN;
  END IF;

  -- Make sure the esn is valid
  IF s.esn IS NULL THEN
    --
    out_err_num := 7;
    out_err_msg := 'MISSING REQUIRED PARAMETER [ESN]';
    --
    RETURN;
  END IF;

  -- Get the correct action type
  c.action_type := ct.get_action_type ( i_code_type => 'AT' ,
                                        i_code_name => in_rqsttype );

  IF c.action_type IS NULL THEN
    --
    out_err_num := 8;
    out_err_msg := 'ACTION TYPE NOT FOUND';
    sa.util_pkg.insert_error_tab ( i_action         => 'ACTION TYPE NOT FOUND',
                                   i_key            =>  s.esn,
                                   i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_SMS' ,
                                   i_error_text     =>  Out_Err_Msg );
    --
    RETURN;
  END IF;

  -- Get the user objid based on the login name
  begin
    select objid
    into   c.user_objid
    from   table_user
    where  s_login_name = in_user;
  exception
      when others then
      out_err_num  := 1;
      out_err_msg  := 'user login not found in table user';
      sa.util_pkg.insert_error_tab ( i_action         => 'CHECKING ACCESS FOR APEX USER',
                                     i_key            =>  in_min,
                                     i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_ESN_REQUEST' ,
                                     i_error_text     =>  out_err_msg );
    RETURN;
  end;
  -- instantiate call trans values
  ct := sa.call_trans_type (  i_esn               => s.esn             ,
                              i_action_type       => c.action_type     ,
                              i_sourcesystem      => 'TAS'             ,
                              i_sub_sourcesystem  => s.bus_org_id      ,
                              i_reason            => 'SOC'             ,
                              i_result            => 'Completed'       ,
                              i_ota_req_type      => NULL              ,
                              i_ota_type          => NULL              ,
                              i_total_units       => NULL              ,
                              i_total_days        => NULL              ,
                              i_total_sms_units   => NULL              ,
                              i_total_data_units  => NULL              ,
                              i_user_objid        => c.user_objid      ,
                              i_action_text       => in_rqsttype       ,
                              i_new_due_date      => NULL              ,
                              i_call_trans_objid  => NULL              );

  -- call the insert method
  c := ct.ins;

  -- if call_trans was not created successfully
  IF c.response <> 'SUCCESS' THEN
    Out_Err_Num := 9;
    Out_Err_Msg := 'Error while insert call_trans';
    sa.util_pkg.insert_error_tab ( i_action         => 'CALL_TRANS INSERT FAILED',
                                   i_key            =>  s.esn,
                                   i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_SMS' ,
                                   i_error_text     =>  Out_Err_Msg );
    RETURN;
  END IF;

  -- END CREATE CALL TRANS


  -- START TASK LOGIC

  -- Get order type
  t.order_type := it.get_ig_order_type ( i_actual_order_type => in_rqsttype );

  -- Make sure the order type is valid
  IF t.order_type IS NULL THEN
    out_err_num   := 4;
    out_err_msg   := 'ORDER TYPE NOT CONFIGURED';
    sa.util_pkg.insert_error_tab ( i_action         => 'ORDER TYPE NOT CONFIGURED',
                                   i_key            =>  s.esn,
                                   i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_ESN_REQUEST' ,
                                   i_error_text     =>  out_err_msg );
    RETURN;
  END IF;

  --
  tt := task_type ( i_call_trans_objid  => c.call_trans_objid ,
                    i_contact_objid     => s.contact_objid    ,
                    i_order_type        => t.order_type       ,
                    i_bypass_order_type => 0                  ,
                    i_case_code         => 0                  );

  -- call the insert method
  t := tt.ins;

  IF t.response <> 'SUCCESS' OR t.task_objid IS NULL OR t.task_id IS NULL THEN

    Out_Err_Num   := 11;
    Out_Err_Msg   := 'ERROR INSERTING TABLE_TASK: ' || t.response;
    sa.util_pkg.insert_error_tab ( i_action         => 'FAILED INSERT TABLE_TASK',
                                   i_key            =>  s.esn,
                                   i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_SMS' ,
                                   i_error_text     =>  Out_Err_Msg );
    RETURN;
  END IF;

  -- END TASK LOGIC
  /*
  BEGIN
    SELECT
           action_item_id,
           transaction_id,
           ig.template
    INTO   ig.action_item_id,
           ig.transaction_id,
           ig.template
    FROM   gw1.ig_transaction igt
    WHERE  esn = s.esn
    AND    min = s.min
    AND    order_type IN ('FASL', 'FAFRD','FAMKT')
    AND    transaction_id = ( SELECT  MAX(transaction_id)
                              FROM   gw1.ig_transaction
                              WHERE  esn = igt.esn
                              AND    min = igt.min
                              AND    order_type IN ('FASL', 'FAFRD','FAMKT')
                            );

   EXCEPTION
    WHEN OTHERS THEN
      out_err_num := 12;
      out_err_msg := 'IG TRANSACTION NOT FOUND';
      sa.util_pkg.insert_error_tab ( i_action         => 'IG DATA NOT FOUND',
                                     i_key            =>  s.esn,
                                     i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_SMS' ,
                                     i_error_text     =>  out_err_msg );
  END;
  */
  BEGIN
    INSERT
    INTO sa.x_sms_hotline
         ( objid         ,
           action_item_id,
           transaction_id,
           min           ,
           text_messgae  ,
           short_code    ,
           status        ,
           status_message,
           template      ,
           creation_date ,
           update_date
         )
    VALUES (sa.seq_sms_hotline.nextval,
            NULL,
            NULL,
            in_min,
            in_sms_msg,
            in_short_code,
            'Q',
            NULL,
            NULL,
            SYSDATE,
            SYSDATE
            );

    COMMIT;

   EXCEPTION
    WHEN OTHERS THEN
      out_err_num := 13;
      out_err_msg := 'EEROR WHILE INSERT HOTLINE_SMS';
      sa.util_pkg.insert_error_tab ( i_action       => 'IG DATA NOT FOUND',
                                     i_key          =>  s.esn,
                                     i_program_name => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_SMS' ,
                                     i_error_text   =>  Out_Err_Msg );
     RETURN;
  END;

  -- return successful response to the caller
  out_err_num := 0;
  out_err_msg := 'SUCCESS';

 EXCEPTION
   WHEN OTHERS THEN
     out_err_num := 1;
     out_err_msg := 'UNHANDLED EXCEPTION: ' || SQLERRM;
     sa.util_pkg.insert_error_tab ( i_action         => 'CREATING HOTLINE REQUEST',
                                    i_key            =>  in_min,
                                    i_program_name   => 'HOTLINE_REQUEST_PKG.CREATE_HOTLINE_SMS' ,
                                    i_error_text     =>  out_err_msg );
END create_hotline_sms;

end hotline_request_pkg;
/