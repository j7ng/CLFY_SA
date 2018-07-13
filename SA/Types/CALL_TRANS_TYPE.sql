CREATE OR REPLACE TYPE sa.call_trans_type AS OBJECT(
  min                        VARCHAR2(30)  ,
  esn                        VARCHAR2(30)  ,
  bus_org_id                 VARCHAR2(50)  ,
  call_trans_objid           NUMBER        ,
  call_trans2site_part       NUMBER        ,
  action_type                VARCHAR2(20)  ,
  call_trans2carrier         NUMBER        ,
  call_trans2dealer          NUMBER        ,
  call_trans2user            NUMBER        ,
  line_status                VARCHAR2(20)  ,
  sourcesystem               VARCHAR2(30)  ,
  transact_date              DATE          ,
  total_units                NUMBER        ,
  action_text                VARCHAR2(20)  ,
  reason                     VARCHAR2(500) ,
  result                     VARCHAR2(20)  ,
  sub_sourcesystem           VARCHAR2(30)  ,
  iccid                      VARCHAR2(30)  ,
  ota_req_type               VARCHAR2(30)  ,
  ota_type                   VARCHAR2(30)  ,
  call_trans2x_ota_code_hist NUMBER        ,
  new_due_date               DATE          ,
  call_trans_ext_objid       NUMBER        ,
  total_days                 NUMBER        ,
  total_sms_units            NUMBER        ,
  total_data_units           NUMBER        ,
  update_stamp               DATE          ,
  account_group_id           NUMBER(22)    ,
  master_flag                VARCHAR2(1)   ,
  service_plan_id            NUMBER(22)    ,
  part_inst2site_part        NUMBER(38)    ,
  user_objid                 NUMBER(38)    ,
  response                   VARCHAR2(1000),
  numeric_value              NUMBER        ,
  varchar2_value             VARCHAR2(2000),
  CONSTRUCTOR FUNCTION call_trans_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION call_trans_type ( i_call_trans_objid 	IN NUMBER ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION call_trans_type ( i_esn              	IN VARCHAR2 ,
                                         i_action_type      	IN VARCHAR2 DEFAULT NULL,
                                         i_sourcesystem     	IN VARCHAR2 DEFAULT NULL,
                                         i_sub_sourcesystem 	IN VARCHAR2 DEFAULT NULL,
                                         i_reason           	IN VARCHAR2 DEFAULT NULL,
                                         i_result           	IN VARCHAR2 DEFAULT NULL,
                                         i_ota_req_type     	IN VARCHAR2 DEFAULT NULL,
                                         i_ota_type         	IN VARCHAR2 DEFAULT NULL,
                                         i_total_units      	IN NUMBER   DEFAULT NULL,
                                         i_total_days       	IN NUMBER   DEFAULT NULL,
                                         i_total_sms_units  	IN NUMBER   DEFAULT NULL,
                                         i_total_data_units 	IN NUMBER   DEFAULT NULL,
										 i_user_objid       	IN NUMBER   DEFAULT NULL,
										 i_action_text      	IN VARCHAR2 DEFAULT NULL,
                                         i_new_due_date     	IN DATE     DEFAULT NULL,
                                         i_call_trans_objid 	IN NUMBER   DEFAULT NULL,
										 i_calltrans2carrier 	IN NUMBER   DEFAULT NULL
										 ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION call_trans_type ( i_call_trans2site_part       IN  NUMBER    ,
                                         i_action_type                IN  VARCHAR2  ,
                                         i_call_trans2carrier         IN  NUMBER    ,
                                         i_call_trans2dealer          IN  NUMBER    ,
                                         i_call_trans2user            IN  NUMBER    ,
                                         i_line_status                IN  VARCHAR2  ,
                                         i_min                        IN  VARCHAR2  ,
                                         i_esn                        IN  VARCHAR2  ,
                                         i_sourcesystem               IN  VARCHAR2  ,
                                         i_transact_date              IN  DATE      ,
                                         i_total_units                IN  NUMBER    ,
                                         i_action_text                IN  VARCHAR2  ,
                                         i_reason                     IN  VARCHAR2  ,
                                         i_result                     IN  VARCHAR2  ,
                                         i_sub_sourcesystem           IN  VARCHAR2  ,
                                         i_iccid                      IN  VARCHAR2  ,
                                         i_ota_req_type               IN  VARCHAR2  ,
                                         i_ota_type                   IN  VARCHAR2  ,
                                         i_call_trans2x_ota_code_hist IN  NUMBER    ,
                                         i_new_due_date               IN  DATE      ) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION exist ( i_call_trans_objid IN NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION ins RETURN call_trans_type,
  MEMBER FUNCTION upd ( i_call_trans_objid IN NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION upd RETURN call_trans_type,
  MEMBER FUNCTION del ( i_call_trans_objid IN  NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION del RETURN BOOLEAN,
  MEMBER FUNCTION get RETURN call_trans_type,
  MEMBER FUNCTION get ( i_call_trans_objid IN NUMBER ) RETURN call_trans_type,
  MEMBER FUNCTION get_action_type ( i_code_type IN VARCHAR2 ,
                                    i_code_name IN VARCHAR2 ) RETURN VARCHAR2,
  MEMBER FUNCTION retrieve RETURN call_trans_type,
  MEMBER FUNCTION save ( i_ct IN OUT call_trans_type ) RETURN VARCHAR2,
  MEMBER FUNCTION save RETURN call_trans_type
);
/
CREATE OR REPLACE TYPE BODY sa.call_trans_type IS
CONSTRUCTOR FUNCTION call_trans_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

CONSTRUCTOR FUNCTION call_trans_type ( i_call_trans_objid IN NUMBER ) RETURN SELF AS RESULT IS

BEGIN
  --
  IF i_call_trans_objid IS NULL THEN
    SELF.response := 'CALL TRANS ID NOT PASSED';
    RETURN;
  END IF;

  -- Query the table
  SELECT call_trans_type ( ct.x_min                     , -- MIN
                           ct.x_service_id              , -- ESN
                           NULL                         , -- BUS_ORG_ID
                           ct.objid                     , -- CALL_TRANS_OBJID
                           call_trans2site_part         , -- CALL_TRANS2SITE_PART
                           x_action_type                , -- ACTION_TYPE
                           x_call_trans2carrier         , -- CALL_TRANS2CARRIER
                           x_call_trans2dealer          , -- CALL_TRANS2DEALER
                           x_call_trans2user            , -- CALL_TRANS2USER
                           x_line_status                , -- LINE_STATUS
                           x_sourcesystem               , -- SOURCESYSTEM
                           x_transact_date              , -- TRANSACT_DATE
                           x_total_units                , -- TOTAL_UNITS
                           x_action_text                , -- ACTION_TEXT
                           x_reason                     , -- REASON
                           x_result                     , -- RESULT
                           x_sub_sourcesystem           , -- SUB_SOURCESYSTEM
                           x_iccid                      , -- ICCID
                           x_ota_req_type               , -- OTA_REQ_TYPE
                           x_ota_type                   , -- OTA_TYPE
                           x_call_trans2x_ota_code_hist , -- CALL_TRANS2X_OTA_CODE_HIST
                           x_new_due_date               , -- NEW_DUE_DATE
                           ext.objid                    , -- CALL_TRANS_EXT_OBJID
                           ext.x_total_days             , -- TOTAL_DAYS
                           ext.x_total_sms_units        , -- TOTAL_SMS_UNITS
                           ext.x_total_data_units       , -- TOTAL_DATA_UNITS
                           ct.update_stamp              , -- UPDATE_STAMP
                           ext.account_group_id         , -- ACCOUNT_GROUP_ID
                           ext.master_flag              , -- MASTER_FLAG
                           ext.service_plan_id          , -- SERVICE_PLAN_ID
                           NULL                         , -- PART_INST2SITE_PART
                           NULL                         , -- USER_OBJID
                           NULL                         , -- RESPONSE
                           NULL                         , -- NUMERIC_VALUE
                           NULL                           -- VARCHAR2_VALUE
                         )
  INTO   SELF
  FROM   table_x_call_trans ct,
         table_x_call_trans_ext ext
  WHERE  ct.objid = i_call_trans_objid
  AND    ct.objid = ext.call_trans_ext2call_trans(+);

  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'CALL TRANS NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     SELF.call_trans_objid := i_call_trans_objid;
     --
     RETURN;
END;

CONSTRUCTOR FUNCTION call_trans_type ( i_esn               IN VARCHAR2,
                                       i_action_type       IN VARCHAR2 DEFAULT NULL ,
                                       i_sourcesystem      IN VARCHAR2 DEFAULT NULL ,
                                       i_sub_sourcesystem  IN VARCHAR2 DEFAULT NULL ,
                                       i_reason            IN VARCHAR2 DEFAULT NULL ,
                                       i_result            IN VARCHAR2 DEFAULT NULL ,
                                       i_ota_req_type      IN VARCHAR2 DEFAULT NULL ,
                                       i_ota_type          IN VARCHAR2 DEFAULT NULL ,
                                       i_total_units       IN NUMBER   DEFAULT NULL ,
                                       i_total_days        IN NUMBER   DEFAULT NULL ,
                                       i_total_sms_units   IN NUMBER   DEFAULT NULL ,
                                       i_total_data_units  IN NUMBER   DEFAULT NULL ,
                                       i_user_objid        IN NUMBER   DEFAULT NULL ,
                                       i_action_text       IN VARCHAR2 DEFAULT NULL ,
                                       i_new_due_date      IN DATE     DEFAULT NULL ,
                                       i_call_trans_objid  IN NUMBER   DEFAULT NULL ,
                                       i_calltrans2carrier IN NUMBER   DEFAULT NULL ) RETURN SELF AS RESULT IS

BEGIN

  --
  SELF.esn              	:= i_esn              	;
  SELF.action_type      	:= i_action_type      	;
  SELF.sourcesystem     	:= i_sourcesystem     	;
  SELF.sub_sourcesystem 	:= i_sub_sourcesystem 	;
  SELF.reason           	:= i_reason           	;
  SELF.result           	:= i_result           	;
  SELF.ota_req_type     	:= i_ota_req_type     	;
  SELF.ota_type         	:= i_ota_type         	;
  SELF.total_units      	:= i_total_units      	;
  SELF.total_days       	:= i_total_days       	;
  SELF.total_sms_units  	:= i_total_sms_units  	;
  SELF.total_data_units 	:= i_total_data_units 	;
  SELF.user_objid       	:= i_user_objid       	;
  SELF.action_text      	:= i_action_text      	;
  SELF.new_due_date     	:= i_new_due_date     	;
  SELF.call_trans_objid 	:= i_call_trans_objid 	;
  SELF.call_trans2carrier	:= i_calltrans2carrier  ;
  --

  SELF.response := 'SUCCESS';

  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     SELF.response     			:= 'ERROR INITIALIZING CALL TRANS: ' || SUBSTR(SQLERRM,1,100);
     SELF.esn              		:= i_esn              	;
     SELF.action_type      		:= i_action_type      	;
     SELF.sourcesystem     		:= i_sourcesystem     	;
     SELF.sub_sourcesystem 		:= i_sub_sourcesystem 	;
     SELF.reason           		:= i_reason           	;
     SELF.result           		:= i_result           	;
     SELF.ota_req_type     		:= i_ota_req_type     	;
     SELF.ota_type         		:= i_ota_type         	;
     SELF.total_units      		:= i_total_units      	;
     SELF.total_days       		:= i_total_days       	;
     SELF.total_sms_units  		:= i_total_sms_units  	;
     SELF.total_data_units 		:= i_total_data_units 	;
     SELF.user_objid       		:= i_user_objid       	;
     SELF.action_text      		:= i_action_text      	;
     SELF.new_due_date     		:= i_new_due_date     	;
     SELF.call_trans_objid 		:= i_call_trans_objid 	;
     SELF.call_trans2carrier	:= i_calltrans2carrier	;
     --
     RETURN;
END;

CONSTRUCTOR FUNCTION call_trans_type ( i_call_trans2site_part       IN  NUMBER    ,
                                       i_action_type                IN  VARCHAR2  ,
                                       i_call_trans2carrier         IN  NUMBER    ,
                                       i_call_trans2dealer          IN  NUMBER    ,
                                       i_call_trans2user            IN  NUMBER    ,
                                       i_line_status                IN  VARCHAR2  ,
                                       i_min                        IN  VARCHAR2  ,
                                       i_esn                        IN  VARCHAR2  ,
                                       i_sourcesystem               IN  VARCHAR2  ,
                                       i_transact_date              IN  DATE      ,
                                       i_total_units                IN  NUMBER    ,
                                       i_action_text                IN  VARCHAR2  ,
                                       i_reason                     IN  VARCHAR2  ,
                                       i_result                     IN  VARCHAR2  ,
                                       i_sub_sourcesystem           IN  VARCHAR2  ,
                                       i_iccid                      IN  VARCHAR2  ,
                                       i_ota_req_type               IN  VARCHAR2  ,
                                       i_ota_type                   IN  VARCHAR2  ,
                                       i_call_trans2x_ota_code_hist IN  NUMBER    ,
                                       i_new_due_date               IN  DATE      ) RETURN SELF AS RESULT IS

BEGIN

  --
  SELF.call_trans2site_part       := i_call_trans2site_part       ;
  SELF.action_type                := i_action_type                ;
  SELF.call_trans2carrier         := i_call_trans2carrier         ;
  SELF.call_trans2dealer          := i_call_trans2dealer          ;
  SELF.call_trans2user            := i_call_trans2user            ;
  SELF.line_status                := i_line_status                ;
  SELF.min                        := i_min                        ;
  SELF.esn                        := i_esn                        ;
  SELF.sourcesystem               := i_sourcesystem               ;
  SELF.transact_date              := i_transact_date              ;
  SELF.total_units                := i_total_units                ;
  SELF.action_text                := i_action_text                ;
  SELF.reason                     := i_reason                     ;
  SELF.result                     := i_result                     ;
  SELF.sub_sourcesystem           := i_sub_sourcesystem           ;
  SELF.iccid                      := i_iccid                      ;
  SELF.ota_req_type               := i_ota_req_type               ;
  SELF.ota_type                   := i_ota_type                   ;
  SELF.call_trans2x_ota_code_hist := i_call_trans2x_ota_code_hist ;
  SELF.new_due_date               := i_new_due_date               ;

  SELF.response := 'SUCCESS';

  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     SELF.response     			     := 'ERROR INITIALIZING CALL TRANS: ' || SUBSTR(SQLERRM,1,100);
     SELF.call_trans2site_part       := i_call_trans2site_part       ;
     SELF.action_type                := i_action_type                ;
     SELF.call_trans2carrier         := i_call_trans2carrier         ;
     SELF.call_trans2dealer          := i_call_trans2dealer          ;
     SELF.call_trans2user            := i_call_trans2user            ;
     SELF.line_status                := i_line_status                ;
     SELF.min                        := i_min                        ;
     SELF.esn                        := i_esn                        ;
     SELF.sourcesystem               := i_sourcesystem               ;
     SELF.transact_date              := i_transact_date              ;
     SELF.total_units                := i_total_units                ;
     SELF.action_text                := i_action_text                ;
     SELF.reason                     := i_reason                     ;
     SELF.result                     := i_result                     ;
     SELF.sub_sourcesystem           := i_sub_sourcesystem           ;
     SELF.iccid                      := i_iccid                      ;
     SELF.ota_req_type               := i_ota_req_type               ;
     SELF.ota_type                   := i_ota_type                   ;
     SELF.call_trans2x_ota_code_hist := i_call_trans2x_ota_code_hist ;
     SELF.new_due_date               := i_new_due_date               ;
     --
     RETURN;
END;

MEMBER FUNCTION exist RETURN BOOLEAN IS

 ct  call_trans_type := call_trans_type ( i_call_trans_objid => SELF.call_trans_objid );

BEGIN
  IF ct.esn IS NOT NULL THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END exist;

MEMBER FUNCTION exist ( i_call_trans_objid IN NUMBER) RETURN BOOLEAN IS

 ct  call_trans_type := call_trans_type ( i_call_trans_objid => i_call_trans_objid );

BEGIN
  IF ct.call_trans_objid IS NOT NULL THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END exist;

-- Procedure to add the
MEMBER FUNCTION ins RETURN call_trans_type IS

  ct  call_trans_type := SELF;
  c   call_trans_type := SELF;

  ex  call_trans_ext_type;
  ce  call_trans_ext_type;

BEGIN
  --
  IF ct.esn IS NULL THEN
    ct.response := 'NO ESN ATTRIBUTE PASSED';
    RETURN ct;
  END IF;

  --
  IF ct.action_type IS NULL THEN
    ct.response := 'NO ACTION ITEM ATTRIBUTE PASSED';
    RETURN ct;
  END IF;

  --
  IF ct.sourcesystem IS NULL THEN
    ct.response := 'NO SOURCESYSTEM ATTRIBUTE PASSED';
    RETURN ct;
  END IF;

  --
  IF ct.reason IS NULL THEN
    ct.response := 'NO REASON ATTRIBUTE PASSED';
    RETURN ct;
  END IF;

  --
  IF ct.result IS NULL THEN
    ct.response := 'NO RESULT ATTRIBUTE PASSED';
    RETURN ct;
  END IF;

  -- Retrieve the call trans data
  c := ct.retrieve;

  -- Save transaction only when retrieve came back successful
  IF c.response LIKE '%SUCCESS%' THEN
    -- Raw insert into X_SUBSCRIBER_SPR table
    c.response := c.response || '|' || save(c) ;
    --
    c.response := CASE c.response WHEN 'SUCCESS|SUCCESS' THEN 'SUCCESS' ELSE c.response END;

    -- Instantiate attributes for the CALL TRANS EXT row
    ex := call_trans_ext_type ( i_call_trans_objid => c.call_trans_objid  ,
                                i_total_days       => c.total_days        ,
                                i_total_sms_units  => c.total_sms_units   ,
                                i_total_data_units => c.total_data_units  );

    -- Insert the CALL TRANS EXT record
    ce := ex.ins;

   	-- Assign CALL TRANS EXT attributes
    IF ce.response LIKE '%SUCCESS%' THEN
      c.call_trans_ext_objid := ce.call_trans_ext_objid;
      c.account_group_id     := ce.account_group_id;
      c.master_flag          := ce.master_flag;
      c.service_plan_id      := ce.service_plan_id;
    END IF;

  ELSE
    -- Return the error message in the c.response column
    c.response := c.response || '|ROW WAS NOT CREATED';
  END IF;


  RETURN c;

 EXCEPTION
   WHEN others THEN
     ct.response  := 'ERROR INSERTING CALL TRANS RECORD: ' || SUBSTR(SQLERRM,1,100);
     --
     RETURN ct;
END ins;

-- Function to expire a subscriber
MEMBER FUNCTION upd ( i_call_trans_objid IN NUMBER) RETURN BOOLEAN IS
BEGIN
  RETURN TRUE;
END upd;

-- Function to update a subscriber
MEMBER FUNCTION upd RETURN call_trans_type IS

  ct  call_trans_type := SELF;
  c   call_trans_type := call_trans_type ();
BEGIN
  --
  IF ct.call_trans_objid IS NULL THEN
    ct.response := 'CALL TRANS OBJID CANNOT BE EMPTY';
    RETURN ct;
  END IF;

  IF ( ct.result IS NOT NULL OR
       ct.reason IS NOT NULL OR
       ct.new_due_date IS NOT NULL OR
       ct.total_units IS NOT NULL
     )
  THEN
    --
    UPDATE table_x_call_trans
    SET    x_result       = NVL( ct.result, x_result ),
           x_reason       = NVL( ct.reason, x_reason ),
           x_new_due_date = NVL( ct.new_due_date, x_new_due_date),
           x_total_units  = NVL( ct.total_units, x_total_units),
           update_stamp   = SYSDATE
    WHERE  objid = ct.call_trans_objid;
  END IF;

  c := call_trans_type ( ct.call_trans_objid );

  ct.response := 'SUCCESS';
  RETURN c;

 EXCEPTION
   WHEN others THEN
    ct.response := 'ERROR UPDATING CALL TRANS: ' || SUBSTR(SQLERRM,1,100);
    c.response := 'ERROR UPDATING CALL TRANS: ' || SUBSTR(SQLERRM,1,100);
    RETURN c;
END upd;

MEMBER FUNCTION del RETURN BOOLEAN IS

  ct call_trans_type := call_trans_type ( SELF.call_trans_objid );

begin
   RETURN ct.del ( SELF.call_trans_objid);
end;

MEMBER FUNCTION del ( i_call_trans_objid  IN NUMBER) RETURN BOOLEAN IS

  -- Find the call trans row
  ct call_trans_type := call_trans_type ( i_call_trans_objid => i_call_trans_objid);

  ce call_trans_ext_type := call_trans_ext_type();

BEGIN
  --DBMS_OUTPUT.PUT_LINE('START DELETING');

  -- If the CALL TRANS row was not found successfully
  IF ct.response != 'SUCCESS' THEN
    --DBMS_OUTPUT.PUT_LINE('ct.response => ' || ct.response);
    ct.response := 'UNABLE TO FIND CALL TRANS: ' || ct.response;
    RETURN FALSE;
  END IF;

  -- Delete the CALL TRANS EXT row
  IF NOT ce.del ( i_call_trans_objid => i_call_trans_objid) THEN
    --DBMS_OUTPUT.PUT_LINE('ce.response => ' || ce.response);
    ce.response := 'ERROR DELETING CALL TRANS EXT TABLE: ' || SUBSTR(SQLERRM,1,100);
    RETURN FALSE;
  END IF;

  -- Delete CALL TRANS
  DELETE table_x_call_trans
  WHERE  objid = i_call_trans_objid;

  ct.response := 'SUCCESS';

  --DBMS_OUTPUT.PUT_LINE('END DELETING');

  RETURN TRUE;
 EXCEPTION
   WHEN others THEN
     ct.response := 'ERROR DELETING CALL TRANS: ' || SUBSTR(SQLERRM,1,100);
     RETURN FALSE;
END del;

MEMBER FUNCTION get RETURN call_trans_type is

  ct call_trans_type := call_trans_type( SELF.call_trans_objid );

BEGIN
  RETURN ct;
END;

MEMBER FUNCTION get ( i_call_trans_objid IN NUMBER ) RETURN call_trans_type IS

  ct  call_trans_type := SELF;
  c   call_trans_type;

BEGIN
  RETURN ct;
END get;

MEMBER FUNCTION get_action_type ( i_code_type IN VARCHAR2 ,
                                  i_code_name IN VARCHAR2 ) RETURN VARCHAR2 IS
  ct  call_trans_type := SELF;
BEGIN
  --
  SELECT x_code_number
  INTO   ct.action_type
  FROM   sa.table_x_code_table
  WHERE  x_code_name = i_code_name
  AND    x_code_type = i_code_type;
  --
  RETURN ct.action_type;
 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_action_type;

-- Procedure to add the
MEMBER FUNCTION retrieve RETURN call_trans_type IS

  ct  call_trans_type := SELF;

BEGIN
  -- Reset response column to blank
  ct.response := NULL;

  -- Trim unnecessary empty space characters
  ct.esn := TRIM(ct.esn);
  ct.action_type := TRIM(ct.action_type);

  -- ESN is a mandatory attribute in the retrieve
  IF ct.esn IS NULL THEN
    ct.response := 'NO ESN PASSED';
    RETURN ct;
  END IF;

  -- ACTION_TYPE is a mandatory attribute in the retrieve
  IF ct.action_type IS NULL THEN
    ct.response := 'NO ACTION TYPE PASSED';
    RETURN ct;
  END IF;

  -- Verify inputs

  -- Get the site part objid
  BEGIN
    SELECT x_part_inst2site_part
    INTO   ct.call_trans2site_part
    FROM   table_part_inst
    WHERE  part_serial_no = ct.esn
    AND    x_domain       = 'PHONES'; -- Fix for redemption card matching min/esn
   EXCEPTION
     WHEN no_data_found THEN
       ct.response  := 'INVALID INPUT: ESN NOT FOUND IN PART INST';
       RETURN ct;
     WHEN others THEN
       ct.response  := 'ERROR SEARCHING FOR ESN IN PART INST: ' || SUBSTR(SQLERRM,1,100);
       RETURN ct;
  END;

  dbms_output.put_line('CALL TRANS 2 SITE PART: ' || ct.call_trans2site_part);

  -- If the passed action text is not empty
  IF ct.action_text IS NULL THEN
    -- Get the action text
    BEGIN
      SELECT x_code_name
      INTO   ct.action_text
      FROM   table_x_code_table
      WHERE  x_code_number = ct.action_type;
     EXCEPTION
       WHEN others THEN
         ct.response := 'INVALID INPUT: ACTION TYPE NOT FOUND IN CODE TABLE';
         RETURN ct;
    END;
  END IF;

  -- c_sp
  BEGIN
    SELECT x_min,
           x_iccid
    INTO   ct.min,
           ct.iccid
    FROM   table_site_part
    WHERE  objid = ct.call_trans2site_part;
   EXCEPTION
     WHEN others THEN
       ct.response  := 'INVALID ESN IN SITE PART: ' || SUBSTR(SQLERRM,1,100);
       RETURN ct;
  END;

  -- c_pi
  IF ct.call_trans2carrier IS NULL THEN
  BEGIN
    SELECT part_inst2carrier_mkt
    INTO   ct.call_trans2carrier
    FROM   table_part_inst
    WHERE  part_serial_no = ct.min
    AND    x_domain       = 'LINES'; -- Fix for redemption card matching min/esn
   EXCEPTION
     WHEN no_data_found THEN
       ct.response  := 'MIN NOT FOUND IN PART INST.';
       RETURN ct;
     WHEN others THEN
       ct.response  := 'INVALID MIN IN PART INST: ' || SUBSTR(SQLERRM,1,100);
       RETURN ct;
  END;
  END IF;

  -- Get the user objid
  IF ct.user_objid IS NULL THEN
    -- Get the user objid based on the login name
    BEGIN
      SELECT objid
      INTO   ct.call_trans2user
      FROM   table_user
      WHERE  s_login_name = USER;
     EXCEPTION
       WHEN no_data_found THEN
         ct.response  := 'USER LOGIN NOT FOUND IN TABLE USER.';
       WHEN others THEN
         ct.response  := 'INVALID USER LOGIN IN TABLE USER: ' || SUBSTR(SQLERRM,1,100);
    END;
    --
  ELSE
    -- Get user objid
    BEGIN
      SELECT objid
      INTO   ct.call_trans2user
      FROM   table_user
      WHERE  objid = ct.user_objid;
     EXCEPTION
       WHEN no_data_found THEN
         ct.response  := 'USER OBJID NOT FOUND IN TABLE USER.';
       WHEN others THEN
         ct.response  := 'INVALID USER OBJID IN TABLE USER: ' || SUBSTR(SQLERRM,1,100);
    END;
    --

  END IF;

  -- Get the dealer from table_site
  BEGIN
    SELECT s.objid
    INTO   ct.call_trans2dealer
    FROM   table_part_inst pi,
           table_inv_bin   ib,
           table_site      s
    WHERE  1 = 1
    AND    pi.part_serial_no    = ct.esn
    AND    pi.part_inst2inv_bin = ib.objid
    AND    ib.bin_name          = s.site_id
    AND    pi.x_domain          = 'PHONES'; -- Fix for redemption card matching min/esn
   EXCEPTION
     WHEN no_data_found THEN
       ct.response  := ct.response || '|MIN NOT FOUND IN PART INST.';
     WHEN others THEN
       ct.response  := ct.response || '|INVALID MIN IN PART INST: ' || SUBSTR(SQLERRM,1,100);
  END;

  -- Validate sourcesystem channel
  IF ct.sourcesystem IS NOT NULL THEN
    BEGIN
      SELECT 1
      INTO   ct.numeric_value
      FROM   table_channel
      WHERE  title = ct.sourcesystem;
     EXCEPTION
       WHEN no_data_found THEN
         ct.response  := ct.response || '|SOURCESYSTEM NOT FOUND IN CHANNEL.';
         RETURN ct;
       WHEN others THEN
         ct.response  := ct.response || '|INVALID SOURCESYSTEM IN CHANNEL: ' || SUBSTR(SQLERRM,1,100);
    END;
  END IF;

  -- Determine sub sourcesystem
  ct.sub_sourcesystem := CASE UPPER(ct.sub_sourcesystem)
                           WHEN 'ENGLISH' THEN '200'
                           WHEN 'SPANISH' THEN '201'
                           ELSE ct.sub_sourcesystem
                         END;

  -- Assign next sequence value to the objid
  --sp_seq ( 'x_call_trans', ct.call_trans_objid );

  -- Set transaction date
  --CR47538 IF transact date is already passed, do not change it
  ct.transact_date := NVL(ct.transact_date,SYSDATE);

  -- Set successful response
  ct.response  := CASE WHEN ct.response IS NULL THEN 'SUCCESS' ELSE ct.response || '|SUCCESS' END;

  RETURN ct;

 EXCEPTION
    WHEN others THEN
      ct.response  := ct.response || '|ERROR RETRIEVING CALL TRANS RECORD: ' || SUBSTR(SQLERRM,1,100);
      --
      RETURN ct;
END retrieve;

MEMBER FUNCTION save ( i_ct IN OUT call_trans_type ) RETURN VARCHAR2 IS


BEGIN
  -- Validate empty attribute
  IF i_ct.call_trans2site_part IS NULL THEN
    RETURN 'SITE PART OBJID ATTRIBUTE CANNOT BE EMPTY';
  END IF;

  -- Validate empty attribute
  IF i_ct.esn IS NULL THEN
    RETURN 'ESN ATTRIBUTE CANNOT BE EMPTY';
  END IF;

  -- Validate empty attribute
  IF i_ct.action_type IS NULL THEN
    RETURN 'ACTION TYPE ATTRIBUTE CANNOT BE EMPTY';
  END IF;

  -- Validate empty attribute
  IF i_ct.sourcesystem IS NULL THEN
    RETURN 'SOURCESYSTEM ATTRIBUTE CANNOT BE EMPTY';
  END IF;

  -- Validate empty attribute
  IF i_ct.sourcesystem IS NULL THEN
    RETURN 'SUB SOURCESYSTEM ATTRIBUTE CANNOT BE EMPTY';
  END IF;

  -- Validate empty attribute
  IF i_ct.transact_date IS NULL THEN
    RETURN 'TRANSACTION DATE ATTRIBUTE CANNOT BE EMPTY';
  END IF;

  -- Assign timestamp attributes
  i_ct.update_stamp := SYSDATE;

  --
  BEGIN
    INSERT
    INTO table_x_call_trans
    ( objid                 ,
      call_trans2site_part  ,
      x_action_type         ,
      x_call_trans2carrier  ,
      x_call_trans2dealer   ,
      x_call_trans2user     ,
      x_min                 ,
      x_service_id          ,
      x_sourcesystem        ,
      x_transact_date       ,
      x_total_units         ,
      x_action_text         ,
      x_reason              ,
      x_result              ,
      x_sub_sourcesystem    ,
      x_iccid               ,
      x_ota_req_type        ,
      x_ota_type            ,
      update_stamp
    )
    VALUES
    ( sa.sequ_x_call_trans.NEXTVAL         ,
      i_ct.call_trans2site_part            ,
      i_ct.action_type                     ,
      i_ct.call_trans2carrier              ,
      i_ct.call_trans2dealer               ,
      i_ct.call_trans2user                 ,
      i_ct.min                             ,
      i_ct.esn                             ,
      i_ct.sourcesystem                    ,
      i_ct.transact_date                   ,
      i_ct.total_units                     ,
      i_ct.action_text                     ,
      i_ct.reason                          ,
      i_ct.result                          ,
      i_ct.sub_sourcesystem                ,
      i_ct.iccid                           ,
      i_ct.ota_req_type                    ,
      i_ct.ota_type                        ,
      i_ct.update_stamp
    )
    RETURNING objid INTO i_ct.call_trans_objid;

   EXCEPTION
    WHEN dup_val_on_index then
      RETURN('DUPLICATE VALUE INSERTING INTO CALL TRANS');

  END;

  dbms_output.put_line(NVL(SQL%ROWCOUNT,0) || ' row created in CT (' || i_ct.call_trans_objid || ')');

  RETURN('SUCCESS');

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 'ERROR SAVING CALL TRANS RECORD: ' || SQLERRM;
     --
END save;

MEMBER FUNCTION save RETURN call_trans_type IS

  ct  call_trans_type := SELF;

BEGIN
  -- Validate empty attribute
  IF ct.esn IS NULL THEN
    ct.response := 'ESN ATTRIBUTE CANNOT BE EMPTY';
	RETURN ct;
  END IF;

    -- Validate empty attribute
  IF ct.call_trans2site_part IS NULL THEN
    ct.response := 'SITE PART OBJID ATTRIBUTE CANNOT BE EMPTY';
    RETURN ct;
  END IF;

  -- Validate empty attribute
  IF ct.action_type IS NULL THEN
    ct.response := 'ACTION TYPE ATTRIBUTE CANNOT BE EMPTY';
	RETURN ct;
  END IF;

  -- Validate empty attribute
  IF ct.sourcesystem IS NULL THEN
    ct.response := 'SOURCESYSTEM ATTRIBUTE CANNOT BE EMPTY';
	RETURN ct;
  END IF;

  -- Validate empty attribute
  IF ct.sub_sourcesystem IS NULL THEN
    ct.response := 'SUB SOURCESYSTEM ATTRIBUTE CANNOT BE EMPTY';
	RETURN ct;
  END IF;

  -- Validate empty attribute
  IF ct.transact_date IS NULL THEN
    ct.response := 'TRANSACTION DATE ATTRIBUTE CANNOT BE EMPTY';
	RETURN ct;
  END IF;

  -- Assign timestamp attributes
  ct.update_stamp := SYSDATE;

  --
  BEGIN
    INSERT
    INTO table_x_call_trans
    ( objid                 ,
      call_trans2site_part  ,
      x_action_type         ,
      x_call_trans2carrier  ,
      x_call_trans2dealer   ,
      x_call_trans2user     ,
      x_min                 ,
      x_service_id          ,
      x_sourcesystem        ,
      x_transact_date       ,
      x_total_units         ,
      x_action_text         ,
      x_reason              ,
      x_result              ,
      x_sub_sourcesystem    ,
      x_iccid               ,
      x_ota_req_type        ,
      x_ota_type            ,
      update_stamp
    )
    VALUES
    ( sa.sequ_x_call_trans.NEXTVAL ,
      ct.call_trans2site_part      ,
      ct.action_type               ,
      ct.call_trans2carrier        ,
      ct.call_trans2dealer         ,
      ct.call_trans2user           ,
      ct.min                       ,
      ct.esn                       ,
      ct.sourcesystem              ,
      ct.transact_date             ,
      ct.total_units               ,
      ct.action_text               ,
      ct.reason                    ,
      ct.result                    ,
      ct.sub_sourcesystem          ,
      ct.iccid                     ,
      ct.ota_req_type              ,
      ct.ota_type                  ,
      ct.update_stamp
    )
    RETURNING objid
    INTO      ct.call_trans_objid;

   EXCEPTION
    WHEN dup_val_on_index THEN

      ct.response  := 'DUPLICATE VALUE INSERTING INTO CALL TRANS';
      --
      RETURN ct;
    WHEN others THEN

      ct.response  := 'ERROR INSERTING CALL TRANS: ' || SQLERRM;
      --
      RETURN ct;

  END;

  dbms_output.put_line(NVL(SQL%ROWCOUNT,0) || ' row created in CT (' || ct.call_trans_objid || ')');

  -- Set successful response
  ct.response  := CASE WHEN ct.response IS NULL THEN 'SUCCESS' ELSE ct.response || '|SUCCESS' END;

  RETURN ct;

 EXCEPTION
   WHEN OTHERS THEN
     ct.response := 'ERROR SAVING CALL TRANS RECORD: ' || SQLERRM;
     RETURN ct;
     --
END save;

END;
/