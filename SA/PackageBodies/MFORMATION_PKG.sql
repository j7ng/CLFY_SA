CREATE OR REPLACE PACKAGE BODY sa.mformation_pkg AS

 --------------------------------------------------------------------------------------------
 --$RCSfile: mformation_pkg.sql,v $
  --$Revision: 1.48 $
  --$Author: jcheruvathoor $
  --$Date: 2018/03/13 16:11:15 $
  --$ $Log: mformation_pkg.sql,v $
  --$ Revision 1.48  2018/03/13 16:11:15  jcheruvathoor
  --$ CR56772	CRM  Sending wrong MSID values on APN order type for CDMA phones
  --$
  --$ Revision 1.47  2017/06/09 22:22:23  smacha
  --$ Updated logic not to create APN request for EPIR, PIR,IPI.
  --$
  --$ Revision 1.45  2015/10/14 20:02:48  jpena
  --$ latest changes for TFDM.
  --$
  --$ Revision 1.43  2015/08/28 23:30:13  kparkhi
  --$ CR35211
  --$
  --$ Revision 1.36  2015/07/06 20:16:59  pvenkata
  --$ 1.35
  --$
  --$ Revision 1.34  2015/06/30 21:29:36  pvenkata
  --$ cr
  --$
  --$ Revision 1.33  2015/06/29 20:19:59  pvenkata
  --$ cr
  --$
  --$ Revision 1.32  2015/06/29 18:30:07  pvenkata
  --$ CR
  --$
  --$ Revision 1.31  2015/06/29 17:24:07  pvenkata
  --$ contact
  --$
  --$ Revision 1.30  2015/06/22 20:05:55  pvenkata
  --$ CR33582
  --$
  --$ Revision 1.29  2015/06/10 18:19:55  pvenkata
  --$ CR3
  --$
  --$ Revision 1.28  2015/06/09 18:18:25  pvenkata
  --$ cr33
  --$
  --$ Revision 1.27  2015/06/09 16:21:02  pvenkata
  --$ CR
  --$
  --$ Revision 1.22  2015/06/06 15:51:52  pvenkata
  --$ Order by CF
  --$
  --$ Revision 1.21  2015/05/21 17:58:32  jpena
  --$ Restrict Reactivations to create APN requests.
  --$
  --$ Revision 1.20  2015/05/11 18:01:47  pvenkata
  --$ For ATT devices.
  --$
  --$ Revision 1.19  2015/03/25 15:42:05  jpena
  --$ cr30440
  --$
  --$ Revision 1.18  2015/03/20 19:57:19  jpena
  --$ mformation
  --$
  --$ Revision 1.60  2015/02/09 22:33:53  jpena
  --$ CR32596 - Mformation Changes
  --$
  --------------------------------------------------------------------------------------------

-- Added on 02/16/2015 by Juda Pena to display debugging messages
PROCEDURE debug_message ( i_debug_flag IN  BOOLEAN,
                          i_output_msg IN  VARCHAR2 ) IS
BEGIN
  IF i_debug_flag THEN
    DBMS_OUTPUT.PUT_LINE(i_output_msg);
  END IF;
END;

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
                         o_contact_objid         OUT  NUMBER,
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
  debug_message ( i_debug_flag, 'template              => ' || min_data_rec.template );
  debug_message ( i_debug_flag, 'esn                   => ' || min_data_rec.esn );
  debug_message ( i_debug_flag, 'zip_code              => ' || min_data_rec.zip_code );
  debug_message ( i_debug_flag, 'line_part_inst_status => ' || min_data_rec.line_part_inst_status );
  debug_message ( i_debug_flag, 'phone_manufacturer    => ' || min_data_rec.phone_manufacturer );
  debug_message ( i_debug_flag, 'rate_plan             => ' || min_data_rec.rate_plan );
  debug_message ( i_debug_flag, 'technology            => ' || min_data_rec.technology );
  debug_message ( i_debug_flag, 'bus_org_id            => ' || min_data_rec.bus_org_id );
  debug_message ( i_debug_flag, 'carrier_objid         => ' || min_data_rec.carrier_objid );
  debug_message ( i_debug_flag, 'parent_id             => ' || min_data_rec.parent_id );
  debug_message ( i_debug_flag, 'parent_name           => ' || min_data_rec.parent_name );
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
     debug_message ( i_debug_flag, 'Cannot determine the template for min '|| i_min ||' (mformation_pkg.get_min_data)' );
	   -- Log error message
     log_error( i_error_text   => 'SQLERRM: ' || SQLERRM,
                i_error_date   => SYSDATE,
                i_action       => 'exception when others clause for i_min = ' || i_min,
                i_key          => i_min,
                i_program_name => 'mformation.get_min_data');
     RAISE;
END get_min_data;

FUNCTION get_task_id (i_task_objid IN NUMBER) RETURN NUMBER IS
 l_task_id   VARCHAR2(30);
BEGIN
  --
  SELECT task_id
  INTO   l_task_id
  FROM   table_task
  WHERE  objid = i_task_objid;

  RETURN(l_task_id);

 EXCEPTION
   WHEN others THEN
     -- Handle exception when no rows were returned to avoid failures
     RETURN(NULL);
END get_task_id;

-- Added on 02/16/2015 by Juda Pena to create an ig transaction record for a request from w3ci (mformation)
-- Procedure changed on 8/27/2015 by Juda Pena as part of CR35211
PROCEDURE create_w3ci_apn_ig ( i_min                IN  VARCHAR2 ,  -- VARCHAR2(30)
                               i_rate_plan          IN  VARCHAR2 DEFAULT NULL,  -- OPTIONAL
                               i_carrier_name       IN  VARCHAR2 DEFAULT NULL,  -- OPTIONAL
                               o_err_code           OUT NUMBER   ,
                               o_err_msg            OUT VARCHAR2 ,
                               i_debug_flag         IN  BOOLEAN DEFAULT FALSE)
as

  l_apn_source_type    VARCHAR2(25) := NULL;
  l_create_ig_apn_flag VARCHAR2(1);
  l_esn                VARCHAR2(30);

BEGIN

  DBMS_OUTPUT.PUT_LINE('start of create_w3ci_apn_ig logic');

  IF i_min IS NULL THEN
    --
    o_err_msg  := 'MISSING MIN PARAMETER';
    --
    RETURN;
  END IF;

  -- get the ESN
  BEGIN
    SELECT pi_esn.part_serial_no
    INTO   l_esn
    FROM   table_part_inst pi_min,
           table_part_inst pi_esn
    WHERE  pi_min.part_serial_no = i_min
    AND    pi_min.x_domain = 'LINES'
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst;
   EXCEPTION
     WHEN others THEN
       o_err_msg := 'MIN NOT FOUND';
       RETURN;
  END;

  DBMS_OUTPUT.PUT_LINE('validating apn source type');

  -- Validate if the device mapping configuration applies to create the APN request
  BEGIN
    SELECT vw.apn_source_type
    INTO   l_apn_source_type
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           table_part_class pc,
           sa.pcpv vw
    WHERE  pi.part_serial_no = l_esn
    AND    pi.n_part_inst2part_mod = ml.objid
    AND    ml.part_info2part_num = pn.objid
    AND    pn.part_num2part_class = pc.objid
    AND    pc.name = vw.part_class;
  EXCEPTION
     WHEN OTHERS THEN
       -- Continue the process to create the APN
       NULL;
  END;

  -- create mformation apn request
  IF l_apn_source_type IS NULL THEN

    DBMS_OUTPUT.PUT_LINE('if apn_source_type is null');

    -- call the old mformation w3ci procedure logic
    sa.apn_requests_pkg.create_w3ci_apn ( 	  i_min           => i_min    ,
											  i_rate_plan     => i_rate_plan,
	                                          o_response_code => o_err_code,
                                              o_response      => o_err_msg );
	RETURN;
  END IF;

  -- create tf dm apn request (supports all other apn requests)
  IF l_apn_source_type IS NOT NULL THEN

    DBMS_OUTPUT.PUT_LINE('if apn_source_type is not null');

    -- call the new tfdm procedure logic
    sa.apn_requests_pkg.create_ig_min (     i_min             => i_min    ,
                                            i_apn_source_type => l_apn_source_type,
											o_response_code   => o_err_code,
                                            o_response        => o_err_msg );
    RETURN;
  END IF;

  o_err_code := 0;
  o_err_msg := 'SUCCESS';

  DBMS_OUTPUT.PUT_LINE('SUCCESS on CREATE_W3CI_APN_IG');

EXCEPTION
   WHEN OTHERS THEN
     debug_message( i_debug_flag, 'create_wci_apn_ig => ' || SQLERRM);
	   -- Log error message
     log_error( i_error_text   => 'SQLERRM: ' || SQLERRM,
                i_error_date   => SYSDATE,
                i_action       => 'exception when others clause for i_min = ' || i_min || ', i_rate_plan = ' || i_rate_plan,
                i_key          => i_min,
                i_program_name => 'mformation.create_w3ci_apn_ig');
     o_err_code := 100;
     o_err_msg  := 'UNHANDLED EXCEPTION : ' || SQLERRM;
     RAISE;
END create_w3ci_apn_ig;

-- Added on 02/16/2015 by Juda Pena to wrap the functionality to duplicate an ig transaction record for a request from w3ci (mformation) for CR30440
PROCEDURE clone_ig_trans_wrapper ( i_transaction_id IN NUMBER ) AS
  l_err_code  NUMBER;
  l_err_msg   VARCHAR2(200);
BEGIN

  -- Call program to clone the ig transaction id for MFORMATION
  mformation_pkg.clone_ig_trans ( i_transaction_id => i_transaction_id,
                                  o_err_code       => l_err_code,
                                  o_err_msg        => l_err_msg,
                                  i_debug_flag     => TRUE );

  EXCEPTION
   WHEN OTHERS THEN
     debug_message(TRUE, 'clone_ig_trans_wrapper => ' || SQLERRM);
	   -- Log error message
     log_error( i_error_text   => 'SQLERRM: ' || SQLERRM,
                i_error_date   => SYSDATE,
                i_action       => 'exception when others clause for i_transaction_id = ' || i_transaction_id,
                i_key          => i_transaction_id,
                i_program_name => 'mformation.clone_ig_trans_wrapper');
     --RAISE;
END clone_ig_trans_wrapper;

-- Added on 02/16/2015 by Juda Pena to wrap the functionality to duplicate an ig transaction record for a request from w3ci (mformation) for CR30440
PROCEDURE clone_port_ig_trans_wrapper ( i_esn IN VARCHAR2 ) AS
  l_err_code  NUMBER;
  l_err_msg   VARCHAR2(200);
BEGIN
  --log_error( i_error_text   => 'start',
  --           i_error_date   => SYSDATE,
  --           i_action       => 'i_esn = ' || i_esn,
  --           i_key          => i_esn,
  --           i_program_name => 'mformation.clone_port_ig_trans');

  -- Call program to clone the ig transaction id for MFORMATION
  mformation_pkg.clone_port_ig_trans ( i_esn            => i_esn,
                                       o_err_code       => l_err_code,
                                       o_err_msg        => l_err_msg,
                                       i_debug_flag     => TRUE );

  --log_error( i_error_text   => 'end',
  --           i_error_date   => SYSDATE,
  --           i_action       => 'i_esn = ' || i_esn || ' code = ' || l_err_code || ' msg = ' || l_err_msg,
  --           i_key          => i_esn,
  --           i_program_name => 'mformation.clone_port_ig_trans');

EXCEPTION
   WHEN OTHERS THEN
     debug_message(TRUE, 'clone_port_ig_trans_wrapper => ' || SQLERRM);
	   -- Log error message
     log_error( i_error_text   => 'SQLERRM: ' || SQLERRM,
                i_error_date   => SYSDATE,
                i_action       => 'exception when others clause for i_esn = ' || i_esn,
                i_key          => i_esn,
                i_program_name => 'mformation.clone_port_ig_trans_wrapper');
     --RAISE;
END clone_port_ig_trans_wrapper;

-- Added on 02/16/2015 by Juda Pena to duplicate an ig transaction record for a request from w3ci (mformation) for CR30440
PROCEDURE clone_ig_trans ( i_transaction_id IN  NUMBER   ,
                           o_err_code       OUT NUMBER ,
                           o_err_msg        OUT VARCHAR2 ,
                           i_debug_flag     IN  BOOLEAN DEFAULT FALSE) AS

  -- Declare a record type to hold all the call trans related attributes
  TYPE call_trans_typ IS RECORD ( action_type       VARCHAR2(30),
                                  sourcesystem      VARCHAR2(30),
                                  bus_org_id        VARCHAR2(30),
                                  reason            table_x_call_trans.x_reason%TYPE,
                                  result            table_x_call_trans.x_result%TYPE,
                                  ota_req_type      table_x_call_trans.x_ota_req_type%TYPE,
                                  ota_type          table_x_call_trans.x_ota_type%TYPE,
                                  total_units       table_x_call_trans.x_total_units%TYPE ,
                                  call_trans_objid  table_x_call_trans.objid%TYPE,
                                  err_code          VARCHAR2(100),
                                  err_msg           VARCHAR2(1000) );

  ct_rec call_trans_typ;

  -- Declare a record type to hold all the call trans related attributes
  TYPE task_typ IS RECORD ( contact_objid     NUMBER,
                            order_type        VARCHAR2(30),
                            bypass_order_type NUMBER,
                            case_code         NUMBER,
                            status_code       NUMBER,
                            task_objid        table_task.objid%TYPE,
                            dummy_value       NUMBER);

  t_rec task_typ;


  -- Get the ig row based on the transaction_id (pk)
  CURSOR c_get_ig IS
    SELECT *
    FROM   ig_transaction ig
    WHERE  transaction_id = i_transaction_id
    AND    NOT EXISTS ( SELECT 1
                        FROM   table_task tt,
                               table_x_call_trans ct
                        WHERE  tt.task_id = ig.action_item_id
                        AND    tt.x_task2x_call_trans = ct.objid
                        AND    ct.x_action_type IN ('6','3','2') -- to restrict REDEMPTIONs, REACTIVATIONs, DEACTIVATIONs
                      );

  -- Record type to hold the ig transaction values to be inserted
  ig_rec  gw1.ig_transaction%ROWTYPE := NULL;

  -- Find a similar existing ig row for the same esn, min, order type and creation date
  CURSOR c_get_dup_ig ( p_esn VARCHAR2,
                        p_min VARCHAR2 ) IS
    SELECT /*+ use_invisible_indexes */ transaction_id
    FROM   ig_transaction ig
    WHERE  esn = p_esn
    AND    min = p_min
    AND    order_type||'' = 'APN'
    AND    TRUNC(creation_date) = TRUNC(SYSDATE);

 /*  AND    NOT EXISTS ( SELECT 1
                      FROM   table_task
               WHERE  task_id = ig.action_item_id
                );
                 */

  -- Record type to hold the ig transaction values to be inserted
  dup_ig_rec  c_get_dup_ig%ROWTYPE;

  CURSOR c_get_cf ( p_rate_plan VARCHAR2,
                    p_carrier_id NUMBER ) IS
    SELECT DISTINCT NVL(cf.create_mform_ig_flag,'N') create_mform_ig_flag
    FROM   table_x_carrier_features cf,
           table_x_carrier ca
    WHERE  1 = 1
    AND    cf.x_rate_plan = p_rate_plan
    AND    cf.x_feature2x_carrier = ca.objid
    AND    ca.x_carrier_id = p_carrier_id
	 order by create_mform_ig_flag desc;

  -- Record type to hold the ig transaction values to be inserted
  cf_rec c_get_cf%ROWTYPE := NULL;

  --
  CURSOR c_get_ig_order_type ( p_ig_order_type VARCHAR2) IS
    SELECT NVL(create_mform_ig_flag,'N') create_mform_ig_flag
    FROM   x_ig_order_type
    WHERE  x_ig_order_type = p_ig_order_type
	AND    x_programme_name = 'SP_INSERT_IG_TRANSACTION';

  -- Record type to hold the ig order type values to be inserted
  ig_order_type_rec c_get_ig_order_type%ROWTYPE := NULL;

  l_line_part_inst_status  VARCHAR2(20);
  l_min_found_flag         VARCHAR2(1);
  l_rate_plan_found_flag   VARCHAR2(1);
  rate_plan_rec            x_rate_plan%ROWTYPE;
  l_phone_manufacturer     VARCHAR2(100);

BEGIN
  -- display debug messages
  debug_message(i_debug_flag, 'entered replicate_ig_transaction logic');

  -- exit when the transaction id was not passed correctly
  IF i_transaction_id IS NULL THEN
    -- display debug messages
    debug_message(i_debug_flag, 'transaction_id parameter is empty');
    debug_message(i_debug_flag, 'transaction will not be cloned');
    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';
    -- exit process
    RETURN;
  END IF;

  -- get the ig row based on the transaction id (primary key)
  OPEN c_get_ig;
  FETCH c_get_ig INTO ig_rec;
  IF c_get_ig%NOTFOUND THEN
    CLOSE c_get_ig;

    debug_message(i_debug_flag, 'ig row was not found');
    debug_message(i_debug_flag, 'transaction will not be cloned');

    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';

    -- exit when the IG was not found in the database
    RETURN;
  END IF;
  CLOSE c_get_ig;


  -- avoid duplicate ig for the same min, esn, order type and transaction date
  OPEN c_get_dup_ig ( ig_rec.esn,
                      ig_rec.min );
  FETCH c_get_dup_ig INTO dup_ig_rec;
  IF c_get_dup_ig%FOUND THEN
    --
    CLOSE c_get_dup_ig;

    -- display debug messages
    debug_message(i_debug_flag, 'there is another apn request (ig) created today (' || dup_ig_rec.transaction_id || ')');
    debug_message(i_debug_flag, 'transaction will not be cloned');

    --
    RETURN;
  END IF;
  --
  CLOSE c_get_dup_ig;

  -- skip insert when status is 'W'
  IF ig_rec.status != 'S' THEN
    debug_message(i_debug_flag, 'ig has a "' || ig_rec.status || '" status (and not "W")');
    debug_message(i_debug_flag, 'ig transaction status does not apply to be cloned');

    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';
    -- exit process
    RETURN;
  END IF;

  -- only replicate for the following templates (as specified in the requirements document)
  IF ig_rec.template NOT IN ('TMOUN','TMOBILE','TMOSM','CSI_TLG') THEN

    -- display debug messages
    debug_message(i_debug_flag, 'template is ' || ig_rec.template || ' and not (TMOUN,TMOBILE,TMOSM,CSI_TLG)');
    debug_message(i_debug_flag, 'transaction does not apply to be cloned');
    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';
    -- exit process
    RETURN;
  END IF;

  --
  OPEN c_get_ig_order_type(ig_rec.order_type);
  FETCH c_get_ig_order_type INTO ig_order_type_rec;
  IF c_get_ig_order_type%NOTFOUND THEN
    CLOSE c_get_ig_order_type;
    -- display debug messages
    debug_message(i_debug_flag, 'ig_order_type is not found (' || ig_rec.order_type || ')');
    debug_message(i_debug_flag, 'transaction does not apply to be cloned');
    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';
    -- exit process
    RETURN;
  END IF;
  CLOSE c_get_ig_order_type;

  -- only replicate "A" and "AP" ig order types
  IF NVL(ig_order_type_rec.create_mform_ig_flag,'N') = 'N' THEN

    -- display debug messages
    debug_message(i_debug_flag, 'ig_order_type is not "A" or "AP"');
    debug_message(i_debug_flag, 'transaction does not apply to be cloned');

    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';
    -- exit process
    RETURN;
  END IF;

  -- get the carrier features flag
  OPEN c_get_cf(ig_rec.rate_plan, ig_rec.carrier_id);
  FETCH c_get_cf INTO cf_rec;
  IF c_get_cf%NOTFOUND THEN
    CLOSE c_get_cf;

    -- display debug messages
    debug_message(i_debug_flag, 'carrier features is not found');
    debug_message(i_debug_flag, 'transaction does not apply to be cloned');

    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';
    -- exit when the carrier features was not found in the database
    RETURN;
  END IF;
  CLOSE c_get_cf;

  -- if the carrier features are not configured to replicate the IG then exit the process
  IF NVL(cf_rec.create_mform_ig_flag,'N') = 'N' THEN
    -- display debug messages
    debug_message(i_debug_flag, 'carrier features does not apply to clone the ig');
    debug_message(i_debug_flag, 'transaction does not apply to be cloned');

    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';
    RETURN;
  END IF;

  -- Validate if the device mapping configuration applies to create the APN request
  begin
    select vw.manufacturer
    into   l_phone_manufacturer
    from   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           table_part_class pc,
           sa.pcpv vw
    where  pi.part_serial_no = ig_rec.esn
    and    pi.n_part_inst2part_mod= ml.objid
    and    ml.part_info2part_num = pn.objid
    and    pn.part_num2part_class = pc.objid
    and    pc.name = vw.part_class
    and    ( ( exists ( select 1
                        from   sa.x_apn_config_mapping acm -- new mapping configuration table
                        where  ( ( acm.phone_manufacturer = vw.manufacturer or phone_manufacturer is null)
                                 and
                                 ( acm.part_num_sourcesystem = pn.x_sourcesystem or acm.part_num_sourcesystem is null )
                                 and
                                 ( acm.device_type = vw.device_type or acm.device_type is null)
                                 and
                                 ( acm.bus_org = vw.bus_org or acm.bus_org is null)
                               )
                        and    acm.clone_ig_flag = 'Y' -- allow clone ig transaction
                        and    acm.inactive_flag = 'N' -- mapping row is active
                      )
              )
              OR
              ( vw.apn_request = 'Y' )
            );

   exception
     when no_data_found then
       debug_message(i_debug_flag, 'Cancel the APN request since the transaction does not apply');
       --
       o_err_code := 1;
       o_err_msg  := 'SUCCESS';
       -- Transaction does not apply to create the APN request
       RETURN;
     when too_many_rows then
       -- Continue the process to create the APN
       null;
     when others then
       -- Continue the process to create the APN
       null;
  end;

  -- TABLE_X_CALL_TRANS LOGIC

  -- assign call trans input values
  ct_rec.action_type       := '277';         -- Using "ACTIVATION" action type temporarily but most likely we'll need a new action type for APN requests
  ct_rec.sourcesystem      := 'API';         -- Using this value temporarily
  ct_rec.reason            := 'APN REQUEST'; -- Using this value temporarily
  ct_rec.result            := 'Completed';     -- Using this value temporarily
  ct_rec.ota_req_type      := NULL;          -- MO:Mobile Originating, MT:Mobile Terminating
  ct_rec.ota_type          := '276';         -- Using "OTA COMMAND" temporarily
  ct_rec.total_units       := NULL;          -- Units expressed in minutes (for call trans)

  -- create a call_trans record
  convert_bo_to_sql_pkg.sp_create_call_trans ( ip_esn          => ig_rec.esn              ,
                                               ip_action_type  => ct_rec.action_type      , -- Ask Oyonys if we need to create a new action type in table_x_code_table (AT)
                                               ip_sourcesystem => ct_rec.sourcesystem     ,
                                               ip_brand_name   => ct_rec.bus_org_id       ,
                                               ip_reason       => ct_rec.reason           ,
                                               ip_result       => ct_rec.result           ,
                                               ip_ota_req_type => ct_rec.ota_req_type     ,
                                               ip_ota_type     => ct_rec.ota_type         , -- Ask Oyonys if we need to create a new ota type in table_x_code_table (OTA)
                                               ip_total_units  => ct_rec.total_units      ,
                                               op_calltranobj  => ct_rec.call_trans_objid , -- output
                                               op_err_code     => ct_rec.err_code         , -- output
                                               op_err_msg      => ct_rec.err_msg         ); -- output

  -- if call_trans row was not created successfully
  IF NVL(ct_rec.err_code,'0') <> '0' THEN

    -- Log error code, message and passed parameters
    log_error ( i_error_text   => 'Error in convert_bo_to_sql_pkg.sp_create_call_trans : error code: ' || ct_rec.err_code || ' - ' || ct_rec.err_msg,
                i_error_date   => SYSDATE,
                i_action       => 'sp_create_call_trans(' || ig_rec.esn || ',' || ct_rec.action_type  || ',' || ct_rec.sourcesystem || ',' || ct_rec.bus_org_id   || ',' || ct_rec.reason || ',' || ct_rec.result || ',' || ct_rec.ota_req_type || ',' || ct_rec.ota_type     || ',' || ct_rec.total_units || ')',
                i_key          => ig_rec.esn,
                i_program_name => 'mformation_pkg.create_w3ci_apn_ig');

    --
    o_err_code := 7;
    o_err_msg  := 'MISSING CALL TRANS ( ' || ct_rec.err_code || ' - ' || ct_rec.err_msg || ' )';

    debug_message(i_debug_flag, 'error creating call trans ( ' || ct_rec.err_code || ' - ' || ct_rec.err_msg || ' )');

    -- exit the program and transfer control to the calling process
    RETURN;

  END IF;

  debug_message(i_debug_flag, 'created call trans ( ' || ct_rec.call_trans_objid || ' )');

  -- if call trans objid is not found
  IF ct_rec.call_trans_objid IS NULL THEN
    --
    o_err_code := 1;
    o_err_msg  := 'MISSING REQUIRED PARAMETER [CALL TRANS]';

    -- debugging
    debug_message(i_debug_flag, 'error creating call trans, missing call trans objid');

    -- exit the program
    RETURN;

  END IF;
  -- END TABLE_X_CALL_TRANS LOGIC


  -- ACTION ITEM (TASK) LOGIC
  BEGIN

    SELECT pi.X_PART_INST2CONTACT
    INTO   t_rec.contact_objid
    FROM    table_part_inst pi
    WHERE   pi.part_serial_no=ig_rec.ESN;

   EXCEPTION
     WHEN others THEN
       debug_message(i_debug_flag, 'contact objid was not found');
       --
       o_err_code := 1;
       o_err_msg  := 'MISSING REQUIRED PARAMETER [CONTACT]';
       --
       RETURN;
  END;

  -- assign task input values

  t_rec.order_type        := 'APN';
  t_rec.bypass_order_type := 0;
  t_rec.case_code         := 0;

  BEGIN
    SELECT /*+ index ( ot IND_ORDER_TYPE3 ) */ 1
    INTO  t_rec.dummy_value
    FROM  table_x_order_type ot ,
          table_x_carrier c,
          table_x_call_trans ct
    WHERE ot.x_order_type2x_carrier = c.objid
    AND   NVL(ot.x_npa ,-1) = -1
    AND   NVL(ot.x_nxx ,-1) = -1
    AND   ot.x_order_type = t_rec.order_type
    AND   c.objid  = ct.x_call_trans2carrier
    AND   ct.objid = ct_rec.call_trans_objid;
   EXCEPTION
     WHEN too_many_rows THEN
       NULL;
       debug_message(i_debug_flag, 'order type was found, continue process');
     WHEN others THEN
       debug_message(i_debug_flag, 'order type was not found');
       --
       o_err_code := 1;
       o_err_msg  := 'MISSING REQUIRED PARAMETER [ORDER TYPE]';
       --
       RETURN;
  END;

  -- create a task record
  igate.sp_create_action_item ( p_contact_objid     => t_rec.contact_objid     ,
                                p_call_trans_objid  => ct_rec.call_trans_objid ,
                                p_order_type        => t_rec.order_type        ,
                                p_bypass_order_type => t_rec.bypass_order_type ,
                                p_case_code         => t_rec.case_code         ,
                                p_status_code       => t_rec.status_code       , -- output (3 = trapped errors, 1 = success, 2 = bypass order type validations )
                                p_action_item_objid => t_rec.task_objid       ); -- output

  -- If the task creation failed
  IF NVL(t_rec.status_code,0) = 3 THEN

      -- Log the returned error
      log_error ( i_error_text   => 'Error in igate.sp_create_action_item : error code: (' || t_rec.status_code || ') ',
                  i_error_date   => SYSDATE,
                  i_action       => 'sp_create_action_item(' || t_rec.contact_objid || ',' || ct_rec.call_trans_objid || ',' || t_rec.order_type || ',' || t_rec.bypass_order_type || ',' || t_rec.case_code || ')',
                  i_key          => t_rec.contact_objid,
                  i_program_name => 'mformation_pkg.create_w3ci_apn_ig');

      debug_message(i_debug_flag, 'error creating task ' || t_rec.status_code);
      --
      o_err_code := 1;
      o_err_msg  := 'MISSING REQUIRED PARAMETER [TASK]';
      -- exit the process
      RETURN;

  END IF;

  -- if task objid is not found
  IF t_rec.task_objid IS NULL THEN
    --
    o_err_code := 1;
    o_err_msg  := 'MISSING REQUIRED PARAMETER [TASK]';

    -- debugging
    debug_message(i_debug_flag, 'missing task objid');

    -- exit the program
    RETURN;

  END IF;

  -- END ACTION ITEM (TASK) LOGIC



  -- Set the hard-coded values
  ig_rec.min              := CASE WHEN ig_rec.technology_flag = 'C' THEN ig_rec.min ELSE ig_rec.msid END; -- CR56772
  ig_rec.new_msid_flag    := NULL;
  --ig_rec.action_item_id   := sa.sequ_action_item_id.NEXTVAL; -- assign a new sequence dummy value (with no real task)
  ig_rec.action_item_id   := get_task_id ( i_task_objid => t_rec.task_objid);
  ig_rec.order_type       := 'APN';
  ig_rec.network_login    := CASE WHEN ig_rec.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'tracfone' ELSE NULL END;
  ig_rec.network_password := CASE WHEN ig_rec.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'Tr@cfon3' ELSE NULL END;
  ig_rec.status           := 'Q';
  ig_rec.transaction_id   := gw1.trans_id_seq.NEXTVAL + ( POWER(2,28));
  ig_rec.creation_date    := SYSDATE;
  ig_rec.update_date      := SYSDATE;
  ig_rec.blackout_wait    := SYSDATE;

  debug_message(i_debug_flag, 'after set hardcoded values' );
  debug_message(i_debug_flag, 'before creating ig row' );

  -- Raw insert and pre-validations
  mformation_pkg.create_ig_transaction ( i_ig_rec           => ig_rec,
                                         o_err_code         => o_err_code,  -- output
                                         o_err_msg          => o_err_msg);  -- output

  debug_message(i_debug_flag, 'ended call to create_ig_transaction = "' || o_err_msg || '"');

  -- Exit the routine
  IF o_err_code <> 0 THEN
    RETURN;
  END IF;

  -- Return successful response to the caller
  o_err_code := 0;
  o_err_msg  := 'SUCCESS';

  debug_message(i_debug_flag, 'ended clone_ig_trans sp successfully');

 EXCEPTION
   WHEN OTHERS THEN
     debug_message(i_debug_flag, 'clone_ig_trans => ' || SQLERRM);
     -- Log error message
     log_error( i_error_text   => 'SQLERRM: ' || SQLERRM,
                i_error_date   => SYSDATE,
                i_action       => 'exception when others clause for i_transaction_id = ' || i_transaction_id,
                i_key          => i_transaction_id,
                i_program_name => 'mformation.clone_ig_trans');
     o_err_code := 100;
     o_err_msg  := 'Unhandled exception : ' || SQLERRM;
     RAISE;
END clone_ig_trans;

-- Added on 02/16/2015 by Juda Pena to duplicate an ig transaction record for a request from w3ci (mformation) for CR30440
PROCEDURE clone_port_ig_trans ( i_esn            IN  VARCHAR2   ,
                                o_err_code       OUT NUMBER ,
                                o_err_msg        OUT VARCHAR2 ,
                                i_debug_flag     IN  BOOLEAN DEFAULT FALSE) AS

  -- Declare a record type to hold all the call trans related attributes
  TYPE call_trans_typ IS RECORD ( action_type       VARCHAR2(30),
                                  sourcesystem      VARCHAR2(30),
                                  bus_org_id        VARCHAR2(30),
                                  reason            table_x_call_trans.x_reason%TYPE,
                                  result            table_x_call_trans.x_result%TYPE,
                                  ota_req_type      table_x_call_trans.x_ota_req_type%TYPE,
                                  ota_type          table_x_call_trans.x_ota_type%TYPE,
                                  total_units       table_x_call_trans.x_total_units%TYPE ,
                                  call_trans_objid  table_x_call_trans.objid%TYPE,
                                  err_code          VARCHAR2(100),
                                  err_msg           VARCHAR2(1000) );

  ct_rec call_trans_typ;

  -- Declare a record type to hold all the call trans related attributes
  TYPE task_typ IS RECORD ( contact_objid     NUMBER,
                            order_type        VARCHAR2(30),
                            bypass_order_type NUMBER,
                            case_code         NUMBER,
                            status_code       NUMBER,
                            task_objid        table_task.objid%TYPE,
                            dummy_value       NUMBER);

  t_rec task_typ;

  -- Get the ig row based on the transaction_id (pk)
  CURSOR c_get_ig IS
    SELECT /*+ use_invisible_indexes */ *
    FROM   ig_transaction ig
    WHERE  esn = i_esn
    AND    order_type IN ('IPI','PIR','EPIR')
    AND    action_item_id = ( SELECT /*+ use_invisible_indexes */ MAX(action_item_id)
                              FROM   ig_transaction
                              WHERE  esn = ig.esn
                              AND    order_type IN ('IPI','PIR','EPIR')
                            );

  -- Record type to hold the ig transaction values to be inserted
  ig_rec  gw1.ig_transaction%ROWTYPE := NULL;

  -- Find a similar existing ig row for the same esn, min, order type and creation date
  CURSOR c_get_dup_ig ( p_esn VARCHAR2,
                        p_min VARCHAR2 ) IS
    SELECT /*+ use_invisible_indexes */ transaction_id
    FROM   ig_transaction ig
    WHERE  esn = p_esn
    AND    min = p_min
    AND    order_type||'' = 'APN'
    AND    TRUNC(creation_date) = TRUNC(SYSDATE);
   /* AND    NOT EXISTS ( SELECT 1
                        FROM   table_task
                        WHERE  task_id = ig.action_item_id
                      );
*/
  -- Record type to hold the ig transaction values to be inserted
  dup_ig_rec  c_get_dup_ig%ROWTYPE;

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

  -- Record type to hold the ig transaction values to be inserted
  cf_rec c_get_cf%ROWTYPE := NULL;

  --
  CURSOR c_get_ig_order_type ( p_ig_order_type VARCHAR2) IS
    SELECT NVL(create_mform_port_flag,'N') create_mform_port_flag
    FROM   x_ig_order_type
    WHERE  x_ig_order_type = p_ig_order_type
	AND    x_programme_name = 'SP_INSERT_IG_TRANSACTION';

  -- Record type to hold the ig order type values to be inserted
  ig_order_type_rec c_get_ig_order_type%ROWTYPE := NULL;

  l_line_part_inst_status  VARCHAR2(20);
  l_min_found_flag         VARCHAR2(1);
  l_rate_plan_found_flag   VARCHAR2(1);
  rate_plan_rec            x_rate_plan%ROWTYPE;
  l_phone_manufacturer                   VARCHAR2(100);
BEGIN
  -- display debug messages
  debug_message(i_debug_flag, 'entered logic');

  -- exit when the transaction id was not passed correctly
  IF i_esn IS NULL THEN
    -- display debug messages
    debug_message(i_debug_flag, 'esn parameter is empty');
    debug_message(i_debug_flag, 'transaction will not be cloned');
    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';
    -- exit process
    RETURN;
  END IF;

  -- get the ig row based on the transaction id (primary key)
  OPEN c_get_ig;
  FETCH c_get_ig INTO ig_rec;

  --CR 47142,Transaction does not apply to create the APN request for order type IPI,PIR,EPIR.
  IF ig_rec.order_type IN ('IPI','PIR','EPIR') THEN


     debug_message(i_debug_flag, 'Transaction does not apply to create the APN request for order type IPI,PIR,EPIR');
     DBMS_OUTPUT.PUT_LINE('Transaction does not apply to create the APN request for order type IPI,PIR,EPIR');

     o_err_code := 1;
     o_err_msg  := 'SUCCESS';

     -- exit when order_type IN ('IPI','PIR','EPIR')
     RETURN;

  END IF; --CR 47142

  IF c_get_ig%NOTFOUND THEN
    CLOSE c_get_ig;

    debug_message(i_debug_flag, 'ig row was not found');
    debug_message(i_debug_flag, 'transaction will not be cloned');

    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';

    -- exit when the IG was not found in the database
    RETURN;
  END IF;
  CLOSE c_get_ig;

  -- avoid duplicate ig for the same min, esn, order type and transaction date
  OPEN c_get_dup_ig ( ig_rec.esn,
                      ig_rec.min );
  FETCH c_get_dup_ig INTO dup_ig_rec;
  IF c_get_dup_ig%FOUND THEN
    --
    CLOSE c_get_dup_ig;

    -- display debug messages
    debug_message(i_debug_flag, 'there is another apn request (ig) created today (' || dup_ig_rec.transaction_id || ')');
    debug_message(i_debug_flag, 'transaction will not be cloned');

    --
    RETURN;
  END IF;
  --
  CLOSE c_get_dup_ig;

  -- skip insert when status is 'W'
  /*IF ig_rec.status != 'W' THEN
    debug_message(i_debug_flag, 'ig has a "' || ig_rec.status || '" status (and not "W")');
    debug_message(i_debug_flag, 'ig transaction status does not apply to be cloned');

    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';
    -- exit process
    RETURN;
  END IF; */

  -- only replicate for the following templates (as specified in the requirements document)
  IF ig_rec.template NOT IN ('TMOUN','TMOBILE','TMOSM','CSI_TLG') THEN

    -- display debug messages
    debug_message(i_debug_flag, 'template is ' || ig_rec.template || ' and not (TMOUN,TMOBILE,TMOSM,CSI_TLG)');
    debug_message(i_debug_flag, 'transaction does not apply to be cloned');
    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';
    -- exit process
    RETURN;
  END IF;

  --
  OPEN c_get_ig_order_type(ig_rec.order_type);
  FETCH c_get_ig_order_type INTO ig_order_type_rec;
  IF c_get_ig_order_type%NOTFOUND THEN
    CLOSE c_get_ig_order_type;
    -- display debug messages
    debug_message(i_debug_flag, 'ig_order_type is not found (' || ig_rec.order_type || ')');
    debug_message(i_debug_flag, 'transaction does not apply to be cloned');
    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';
    -- exit process
    RETURN;
  END IF;
  CLOSE c_get_ig_order_type;

  -- only replicate "A" and "AP" ig order types
  IF NVL(ig_order_type_rec.create_mform_port_flag,'N') = 'N' THEN

    -- display debug messages
    debug_message(i_debug_flag, 'ig_order_type is not "PIR" or "EPIR"');
    debug_message(i_debug_flag, 'transaction does not apply to be cloned');

    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';
    -- exit process
    RETURN;
  END IF;

  -- get the carrier features flag
  OPEN c_get_cf(ig_rec.rate_plan, ig_rec.carrier_id);
  FETCH c_get_cf INTO cf_rec;
  IF c_get_cf%NOTFOUND THEN
    CLOSE c_get_cf;

    -- display debug messages
    debug_message(i_debug_flag, 'carrier features is not found');
    debug_message(i_debug_flag, 'transaction does not apply to be cloned');

    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';
    -- exit when the carrier features was not found in the database
    RETURN;
  END IF;
  CLOSE c_get_cf;

  -- if the carrier features are not configured to replicate the IG then exit the process
  IF NVL(cf_rec.create_mform_ig_flag,'N') = 'N' THEN
    -- display debug messages
    debug_message(i_debug_flag, 'carrier features does not apply to clone the ig');
    debug_message(i_debug_flag, 'transaction does not apply to be cloned');

    --
    o_err_code := 1;
    o_err_msg  := 'SUCCESS';
    RETURN;
  END IF;

  -- Validate if the device mapping configuration applies to create the APN request
  BEGIN
    SELECT vw.manufacturer
    INTO   l_phone_manufacturer
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           table_part_class pc,
           sa.pcpv vw
    WHERE  pi.part_serial_no = ig_rec.esn
    AND    pi.n_part_inst2part_mod= ml.objid
    AND    ml.part_info2part_num = pn.objid
    AND    pn.part_num2part_class = pc.objid
    AND    pc.name = vw.part_class
    AND    ( ( exists ( select 1
                        from   sa.x_apn_config_mapping acm -- new mapping configuration table
                        where  ( ( acm.phone_manufacturer = vw.manufacturer or phone_manufacturer is null)
                                 and
                                 ( acm.part_num_sourcesystem = pn.x_sourcesystem or acm.part_num_sourcesystem is null )
                                 and
                                 ( acm.device_type = vw.device_type or acm.device_type is null)
                                 and
                                 ( acm.bus_org = vw.bus_org or acm.bus_org is null)
                               )
                        and    acm.clone_ig_flag = 'Y' -- allow clone ig transaction
                        and    acm.inactive_flag = 'N' -- mapping row is active
                      )
              )
              OR
              ( vw.apn_request = 'Y' )
            );
   exception
     when no_data_found then
       debug_message(i_debug_flag, 'Cancel the APN request since the transaction does not apply');
       --
       o_err_code := 7;
       o_err_msg  := 'DEVICE DOES NOT APPLY TO CREATE APN REQUEST';
       -- Transaction does not apply to create the APN request
       RETURN;
     when too_many_rows then
       -- Continue the process to create the APN
       null;
     when others then
       -- Continue the process to create the APN
       null;
  end;

  -- TABLE_X_CALL_TRANS LOGIC

  -- assign call trans input values
  ct_rec.action_type       := '277';         -- Using "ACTIVATION" action type temporarily but most likely we'll need a new action type for APN requests
  ct_rec.sourcesystem      := 'API';         -- Using this value temporarily
  ct_rec.reason            := 'APN REQUEST'; -- Using this value temporarily
  ct_rec.result            := 'Completed';     -- Using this value temporarily
  ct_rec.ota_req_type      := NULL;          -- MO:Mobile Originating, MT:Mobile Terminating
  ct_rec.ota_type          := '276';         -- Using "OTA COMMAND" temporarily
  ct_rec.total_units       := NULL;          -- Units expressed in minutes (for call trans)

  -- create a call_trans record
  convert_bo_to_sql_pkg.sp_create_call_trans ( ip_esn          => ig_rec.esn              ,
                                               ip_action_type  => ct_rec.action_type      , -- Ask Oyonys if we need to create a new action type in table_x_code_table (AT)
                                               ip_sourcesystem => ct_rec.sourcesystem     ,
                                               ip_brand_name   => ct_rec.bus_org_id       ,
                                               ip_reason       => ct_rec.reason           ,
                                               ip_result       => ct_rec.result           ,
                                               ip_ota_req_type => ct_rec.ota_req_type     ,
                                               ip_ota_type     => ct_rec.ota_type         , -- Ask Oyonys if we need to create a new ota type in table_x_code_table (OTA)
                                               ip_total_units  => ct_rec.total_units      ,
                                               op_calltranobj  => ct_rec.call_trans_objid , -- output
                                               op_err_code     => ct_rec.err_code         , -- output
                                               op_err_msg      => ct_rec.err_msg         ); -- output

  -- if call_trans row was not created successfully
  IF NVL(ct_rec.err_code,'0') <> '0' THEN

    -- Log error code, message and passed parameters
    log_error ( i_error_text   => 'Error in convert_bo_to_sql_pkg.sp_create_call_trans : error code: ' || ct_rec.err_code || ' - ' || ct_rec.err_msg,
                i_error_date   => SYSDATE,
                i_action       => 'sp_create_call_trans(' || ig_rec.esn || ',' || ct_rec.action_type  || ',' || ct_rec.sourcesystem || ',' || ct_rec.bus_org_id   || ',' || ct_rec.reason || ',' || ct_rec.result || ',' || ct_rec.ota_req_type || ',' || ct_rec.ota_type     || ',' || ct_rec.total_units || ')',
                i_key          => ig_rec.esn,
                i_program_name => 'mformation_pkg.create_w3ci_apn_ig');

    --
    o_err_code := 7;
    o_err_msg  := 'MISSING CALL TRANS ( ' || ct_rec.err_code || ' - ' || ct_rec.err_msg || ' )';

    debug_message(i_debug_flag, 'error creating call trans ( ' || ct_rec.err_code || ' - ' || ct_rec.err_msg || ' )');

    -- exit the program and transfer control to the calling process
    RETURN;

  END IF;

  debug_message(i_debug_flag, 'created call trans ( ' || ct_rec.call_trans_objid || ' )');

  -- if call trans objid is not found
  IF ct_rec.call_trans_objid IS NULL THEN
    --
    o_err_code := 1;
    o_err_msg  := 'MISSING REQUIRED PARAMETER [CALL TRANS]';

    -- debugging
    debug_message(i_debug_flag, 'error creating call trans, missing call trans objid');

    -- exit the program
    RETURN;

  END IF;
  -- END TABLE_X_CALL_TRANS LOGIC


  -- ACTION ITEM (TASK) LOGIC
  BEGIN

 SELECT pi.X_PART_INST2CONTACT
    INTO   t_rec.contact_objid
    FROM    table_part_inst pi
    WHERE   pi.part_serial_no=ig_rec.ESN;

   EXCEPTION
     WHEN others THEN
       debug_message(i_debug_flag, 'contact objid was not found');
       --
       o_err_code := 1;
       o_err_msg  := 'MISSING REQUIRED PARAMETER [CONTACT]';
       --
       RETURN;
  END;

  -- assign task input values

  t_rec.order_type        := 'APN';
  t_rec.bypass_order_type := 0;
  t_rec.case_code         := 0;

  BEGIN
    SELECT /*+ index ( ot IND_ORDER_TYPE3 ) */ 1
    INTO  t_rec.dummy_value
    FROM  table_x_order_type ot ,
          table_x_carrier c,
          table_x_call_trans ct
    WHERE ot.x_order_type2x_carrier = c.objid
    AND   NVL(ot.x_npa ,-1) = -1
    AND   NVL(ot.x_nxx ,-1) = -1
    AND   ot.x_order_type = t_rec.order_type
    AND   c.objid  = ct.x_call_trans2carrier
    AND   ct.objid = ct_rec.call_trans_objid;
   EXCEPTION
     WHEN too_many_rows THEN
       NULL;
       debug_message(i_debug_flag, 'order type was found, continue process');
     WHEN others THEN
       debug_message(i_debug_flag, 'order type was not found');
       --
       o_err_code := 1;
       o_err_msg  := 'MISSING REQUIRED PARAMETER [ORDER TYPE]';
       --
       RETURN;
  END;

  -- create a task record
  igate.sp_create_action_item ( p_contact_objid     => t_rec.contact_objid     ,
                                p_call_trans_objid  => ct_rec.call_trans_objid ,
                                p_order_type        => t_rec.order_type        ,
                                p_bypass_order_type => t_rec.bypass_order_type ,
                                p_case_code         => t_rec.case_code         ,
                                p_status_code       => t_rec.status_code       , -- output (3 = trapped errors, 1 = success, 2 = bypass order type validations )
                                p_action_item_objid => t_rec.task_objid       ); -- output

  -- If the task creation failed
  IF NVL(t_rec.status_code,0) = 3 THEN

      -- Log the returned error
      log_error ( i_error_text   => 'Error in igate.sp_create_action_item : error code: (' || t_rec.status_code || ') ',
                  i_error_date   => SYSDATE,
                  i_action       => 'sp_create_action_item(' || t_rec.contact_objid || ',' || ct_rec.call_trans_objid || ',' || t_rec.order_type || ',' || t_rec.bypass_order_type || ',' || t_rec.case_code || ')',
                  i_key          => t_rec.contact_objid,
                  i_program_name => 'mformation_pkg.create_w3ci_apn_ig');

      debug_message(i_debug_flag, 'error creating task ' || t_rec.status_code);
      --
      o_err_code := 1;
      o_err_msg  := 'MISSING REQUIRED PARAMETER [TASK]';
      -- exit the process
      RETURN;

  END IF;

  -- if task objid is not found
  IF t_rec.task_objid IS NULL THEN
    --
    o_err_code := 1;
    o_err_msg  := 'MISSING REQUIRED PARAMETER [TASK]';

    -- debugging
    debug_message(i_debug_flag, 'missing task objid');

    -- exit the program
    RETURN;

  END IF;

  -- END ACTION ITEM (TASK) LOGIC

  -- Set the hardcoded values
  ig_rec.min              := ig_rec.msid;
  ig_rec.new_msid_flag    := NULL;
  ig_rec.action_item_id   := get_task_id ( i_task_objid => t_rec.task_objid);
  ig_rec.order_type       := 'APN';
  ig_rec.network_login    := CASE WHEN ig_rec.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'tracfone' ELSE NULL END;
  ig_rec.network_password := CASE WHEN ig_rec.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'Tr@cfon3' ELSE NULL END;
  ig_rec.status           := 'Q';
  ig_rec.transaction_id   := gw1.trans_id_seq.NEXTVAL + ( POWER(2,28));
  ig_rec.creation_date    := SYSDATE;
  ig_rec.update_date      := SYSDATE;
  ig_rec.blackout_wait    := SYSDATE;

  debug_message(i_debug_flag, 'after set hardcoded values' );
  debug_message(i_debug_flag, 'before creating ig row' );

  -- Raw insert and pre-validations
  mformation_pkg.create_ig_transaction ( i_ig_rec           => ig_rec,
                                         o_err_code         => o_err_code,  -- output
                                         o_err_msg          => o_err_msg);  -- output

  debug_message(i_debug_flag, 'ended call to create_ig_transaction = "' || o_err_msg || '"');

  -- Exit the routine
  IF o_err_code <> 0 THEN
    RETURN;
  END IF;

  -- Return successful response to the caller
  o_err_code := 0;
  o_err_msg  := 'SUCCESS';

  debug_message(i_debug_flag, 'ended clone_ig_trans sp successfully');

  COMMIT;

EXCEPTION
   WHEN OTHERS THEN
     debug_message(i_debug_flag, 'clone_port_ig_trans => ' || SQLERRM);
	   -- Log error message
     log_error( i_error_text   => 'SQLERRM: ' || SQLERRM,
                i_error_date   => SYSDATE,
                i_action       => 'exception when others clause for i_esn = ' || i_esn,
                i_key          => i_esn,
                i_program_name => 'mformation.clone_port_ig_trans');
     o_err_code := 100;
     o_err_msg  := 'Unhandled exception : ' || SQLERRM;
     RAISE;
END clone_port_ig_trans;

-- Added on 02/16/2015 by Juda Pena to create an ig transaction record
PROCEDURE create_ig_transaction ( i_ig_rec     IN  ig_transaction%ROWTYPE,
                                  o_err_code   OUT NUMBER   ,
                                  o_err_msg    OUT VARCHAR2 ,
                                  i_debug_flag IN BOOLEAN DEFAULT FALSE) AS

  -- Record type to hold the ig transaction values to be inserted
  --l_igt_rec  gw1.ig_transaction%ROWTYPE := NULL;
BEGIN

  -- Make sure the min is a mandatory input parameter
  IF i_ig_rec.min IS NULL THEN
    --
    o_err_code := 1;
    o_err_msg  := 'MISSING MIN PARAMETER';
    --
    RETURN;
  END IF;

  -- Make sure the rate plan is valid
  IF i_ig_rec.rate_plan IS NULL THEN
    --
    o_err_code := 2;
    o_err_msg  := 'MISSING RATE PLAN PARAMETER';
    --
    RETURN;
  END IF;

  -- Make sure the template is valid
  IF i_ig_rec.template IS NULL THEN
    --
    o_err_code := 3;
    o_err_msg  := 'MISSING TEMPLATE PARAMETER';
    --
    RETURN;
  END IF;

  -- Make sure the technology flag is valid
  IF i_ig_rec.technology_flag IS NULL THEN
    --
    o_err_code := 4;
    o_err_msg  := 'MISSING TECHNOLOGY FLAG PARAMETER';
    --
    RETURN;
  END IF;

  -- Make sure the zip code is valid
  IF i_ig_rec.zip_code IS NULL THEN
    --
    o_err_code := 5;
    o_err_msg  := 'MISSING ZIP CODE PARAMETER';
    --
    RETURN;
  END IF;

  -- Inserting into ig_transaction
  INSERT
  INTO   ig_transaction
         ( action_item_id,
           carrier_id,
           order_type,
           min,
           esn,
           esn_hex,
           old_esn,
           old_esn_hex,
           pin,
           phone_manf,
           end_user,
           account_num,
           market_code,
           rate_plan,
           ld_provider,
           sequence_num,
           dealer_code,
           transmission_method,
           fax_num,
           online_num,
           email,
           network_login,
           network_password,
           system_login,
           system_password,
           template,
           exe_name,
           com_port,
           status,
           status_message,
           fax_batch_size,
           fax_batch_q_time,
           expidite,
           trans_prof_key,
           q_transaction,
           online_num2,
           fax_num2,
           creation_date,
           update_date,
           blackout_wait,
           tux_iti_server,
           transaction_id,
           technology_flag,
           voice_mail,
           voice_mail_package,
           caller_id,
           caller_id_package,
           call_waiting,
           call_waiting_package,
           rtp_server,
           digital_feature_code,
           state_field,
           zip_code,
           msid,
           new_msid_flag,
           sms,
           sms_package,
           iccid,
           old_min,
           digital_feature,
           ota_type,
           rate_center_no,
           application_system,
           subscriber_update,
           download_date,
           prl_number,
           amount,
           balance,
           language,
           exp_date,
           x_mpn,
           x_mpn_code,
           x_pool_name
         )
  VALUES
  ( i_ig_rec.action_item_id,
    i_ig_rec.carrier_id,
    i_ig_rec.order_type,
    i_ig_rec.min,
    i_ig_rec.esn,
    i_ig_rec.esn_hex,
    i_ig_rec.old_esn,
    i_ig_rec.old_esn_hex,
    i_ig_rec.pin,
    i_ig_rec.phone_manf,
    i_ig_rec.end_user,
    i_ig_rec.account_num,
    i_ig_rec.market_code,
    i_ig_rec.rate_plan,
    i_ig_rec.ld_provider,
    i_ig_rec.sequence_num,
    i_ig_rec.dealer_code,
    i_ig_rec.transmission_method,
    i_ig_rec.fax_num,
    i_ig_rec.online_num,
    i_ig_rec.email,
    i_ig_rec.network_login,
    i_ig_rec.network_password,
    i_ig_rec.system_login,
    i_ig_rec.system_password,
    i_ig_rec.template,
    i_ig_rec.exe_name,
    i_ig_rec.com_port,
    i_ig_rec.status,
    i_ig_rec.status_message,
    i_ig_rec.fax_batch_size,
    i_ig_rec.fax_batch_q_time,
    i_ig_rec.expidite,
    i_ig_rec.trans_prof_key,
    i_ig_rec.q_transaction,
    i_ig_rec.online_num2,
    i_ig_rec.fax_num2,
    i_ig_rec.creation_date,
    i_ig_rec.update_date,
    i_ig_rec.blackout_wait,
    i_ig_rec.tux_iti_server,
    i_ig_rec.transaction_id,
    i_ig_rec.technology_flag,
    i_ig_rec.voice_mail,
    i_ig_rec.voice_mail_package,
    i_ig_rec.caller_id,
    i_ig_rec.caller_id_package,
    i_ig_rec.call_waiting,
    i_ig_rec.call_waiting_package,
    i_ig_rec.rtp_server,
    i_ig_rec.digital_feature_code,
    i_ig_rec.state_field,
    i_ig_rec.zip_code,
    i_ig_rec.msid,
    i_ig_rec.new_msid_flag,
    i_ig_rec.sms,
    i_ig_rec.sms_package,
    i_ig_rec.iccid,
    i_ig_rec.old_min,
    i_ig_rec.digital_feature,
    i_ig_rec.ota_type,
    i_ig_rec.rate_center_no,
    i_ig_rec.application_system,
    i_ig_rec.subscriber_update,
    i_ig_rec.download_date,
    i_ig_rec.prl_number,
    i_ig_rec.amount,
    i_ig_rec.balance,
    i_ig_rec.language,
    i_ig_rec.exp_date,
    i_ig_rec.x_mpn,
    i_ig_rec.x_mpn_code,
    i_ig_rec.x_pool_name
  );

  IF SQL%ROWCOUNT > 0 THEN
    debug_message(i_debug_flag, 'IG was created');
  ELSE
    debug_message(i_debug_flag, 'IG was NOT created');
  END IF;

  -- Return successful response to the caller
  o_err_code := 0;
  o_err_msg  := 'SUCCESS';

EXCEPTION
   WHEN OTHERS THEN
     debug_message(i_debug_flag, 'create_ig_transaction => ' || SQLERRM);
	   -- Log error message
     log_error( i_error_text   => 'SQLERRM: ' || SQLERRM,
                i_error_date   => SYSDATE,
                i_action       => 'exception when others clause for i_ig_rec.min = ' || i_ig_rec.min || ', i_ig_rec.rate_plan = ' || i_ig_rec.rate_plan || ', i_ig_rec.template = ' || i_ig_rec.template,
                i_key          => i_ig_rec.min,
                i_program_name => 'mformation.create_ig_transaction');
     o_err_code := 100;
     o_err_msg  := 'Unhandled exception : ' || SQLERRM;
     RAISE;
END create_ig_transaction;

-- Added on 02/16/2015 by Juda Pena to log procedure calls and parameters on ERROR_TABLE
PROCEDURE log_error ( i_error_text   IN VARCHAR2,
                      i_error_date   IN DATE,
                      i_action       IN VARCHAR2,
                      i_key          IN VARCHAR2,
                      i_program_name IN VARCHAR2) AS

  PRAGMA AUTONOMOUS_TRANSACTION; -- Declare block as an autonomous transaction

BEGIN
  -- Insert log message
  INSERT
  INTO error_table
       ( error_text,
         error_date,
         action,
         key,
         program_name
       )
  VALUES
  ( i_error_text,
    i_error_date,
    i_action ,
    i_key,
    i_program_name
  );

  -- Save changes
  COMMIT;

 EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END log_error;

procedure create_w3ci_apn_ig_soa ( i_min           IN  VARCHAR2 ,              -- VARCHAR2(30)
                                   i_rate_plan     IN  VARCHAR2 DEFAULT NULL,  -- OPTIONAL
                                   i_carrier_name  IN  VARCHAR2 DEFAULT NULL,  -- OPTIONAL
                                   o_err_code      OUT NUMBER   ,
                                   o_err_msg       OUT VARCHAR2) AS

  v_i_min           VARCHAR2(100);
  v_i_rate_plan     VARCHAR2(100);
  v_i_carrier_name  VARCHAR2(100);
  v_o_err_code      NUMBER;
  v_o_err_msg       VARCHAR2(1000);

begin

  v_i_min := i_min;
  v_i_rate_plan := i_rate_plan;
  v_i_carrier_name := i_carrier_name;

  mformation_pkg.create_w3ci_apn_ig ( i_min           => v_i_min          ,  -- VARCHAR2(30)
                                      i_rate_plan     => v_i_rate_plan    ,  -- OPTIONAL
                                      i_carrier_name  => v_i_carrier_name ,  -- OPTIONAL
                                      o_err_code      => v_o_err_code     ,
                                      o_err_msg       => v_o_err_msg      );

  o_err_code := v_o_err_code;
  o_err_msg := v_o_err_msg;

end create_w3ci_apn_ig_soa;

END mformation_pkg;
/