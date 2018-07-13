CREATE OR REPLACE TYPE sa.alert_type AS OBJECT (
  esn                             VARCHAR2(30)   ,
  min                             VARCHAR2(30)   ,
  alert_objid                     NUMBER         ,
  type                            VARCHAR2(80)   ,
  alert_text                      VARCHAR2(4000) ,
  start_date                      DATE           ,
  end_date                        DATE           ,
  active                          NUMBER         ,
  title                           VARCHAR2(80)   ,
  hotline                         NUMBER         ,
  dev                             NUMBER         ,
  user_objid                      NUMBER(38)     ,
  contact_objid                   NUMBER(38)     ,
  site_objid                      NUMBER(38)     ,
  esn_part_inst_objid             NUMBER(38)     ,
  min_part_inst_objid             NUMBER(38)     ,
  site_part_objid                 NUMBER(38)     ,
  bus_org_id                      VARCHAR2(40)   ,
  bus_org_objid                   NUMBER(38)     ,
  alert2lead                      NUMBER         ,
  alert2opportunity               NUMBER         ,
  modify_stmp                     DATE           ,
  ivr_script_id                   VARCHAR2(10)   ,
  web_text_english                VARCHAR2(2000) ,
  web_text_spanish                VARCHAR2(2000) ,
  cancel_sql                      VARCHAR2(255)  ,
  tts_english                     VARCHAR2(2000) ,
  tts_spanish                     VARCHAR2(2000) ,
  eval_sql                        NUMBER(1)      ,
  condition_sql                   VARCHAR2(2000) ,
  step                            NUMBER         ,
  web_user_objid                  NUMBER(38),
  web_contact_objid               NUMBER(38),
  web_login_name                  VARCHAR2(50),
  response                        VARCHAR2(1000),
  numeric_value                   NUMBER,
  varchar2_value                  VARCHAR2(2000),
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION alert_type RETURN SELF AS RESULT,
  -- Constructor used to initialize the ESN and or MIN
  CONSTRUCTOR FUNCTION alert_type ( i_esn IN VARCHAR2 ) RETURN SELF AS RESULT,
  -- Constructor used to initialize the ESN and TITLE
  CONSTRUCTOR FUNCTION alert_type ( i_esn_part_inst_objid IN VARCHAR2 ,
                                    i_title               IN VARCHAR2 ) RETURN SELF AS RESULT,
  -- Constructor used to initialize the ESN and or MIN
  CONSTRUCTOR FUNCTION alert_type ( i_esn                 IN VARCHAR2  ,
                                    i_type                IN VARCHAR2  ,
                                    i_alert_text          IN VARCHAR2  ,
                                    i_start_date          IN DATE      ,
                                    i_end_date            IN DATE      ,
                                    i_active              IN NUMBER    ,
                                    i_title               IN VARCHAR2  ,
                                    i_hotline             IN NUMBER    ,
                                    i_dev                 IN NUMBER    DEFAULT NULL,
                                    i_user_objid          IN NUMBER    ,
                                    i_contact_objid       IN NUMBER    DEFAULT NULL,
                                    i_site_objid          IN NUMBER    DEFAULT NULL,
                                    i_esn_part_inst_objid IN NUMBER    ,
                                    i_bus_org_objid       IN NUMBER    DEFAULT NULL,
                                    i_alert2lead          IN NUMBER    DEFAULT NULL,
                                    i_alert2opportunity   IN NUMBER    DEFAULT NULL,
                                    i_modify_stmp         IN DATE      ,
                                    i_ivr_script_id       IN VARCHAR2  ,
                                    i_web_text_english    IN VARCHAR2  ,
                                    i_web_text_spanish    IN VARCHAR2  ,
                                    i_cancel_sql          IN VARCHAR2  ,
                                    i_tts_english         IN VARCHAR2  DEFAULT NULL,
                                    i_tts_spanish         IN VARCHAR2  DEFAULT NULL,
                                    i_eval_sql            IN NUMBER    DEFAULT NULL,
                                    i_condition_sql       IN VARCHAR2  DEFAULT NULL,
                                    i_step                IN NUMBER    DEFAULT NULL) RETURN SELF AS RESULT,
  -- Function used to get all the attributes for a particular alert
  MEMBER FUNCTION retrieve RETURN alert_type,
  -- Function used to get all the attributes for a particular alert
  MEMBER FUNCTION retrieve ( i_esn IN VARCHAR2 ) RETURN alert_type,
  -- Function used to insert a new alert (flash)
  MEMBER FUNCTION ins RETURN alert_type,
  -- Function used to delete an alert record
  MEMBER FUNCTION del RETURN alert_type
);
/
CREATE OR REPLACE TYPE BODY sa.alert_type IS
-- Constructor used to initialize the entire type
CONSTRUCTOR FUNCTION alert_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

-- Constructor used to initialize the ESN and or MIN
CONSTRUCTOR FUNCTION alert_type ( i_esn IN VARCHAR2 ) RETURN SELF AS RESULT IS
BEGIN

  -- Make sure we pass at least one parameters
  IF i_esn IS NULL THEN
    SELF.response := 'NO INPUT PARAMETERS PASSED';
    RETURN;
  END IF;

  SELF.esn := i_esn;

  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'UNABLE TO INSTANTIATE ALERT: ' || SUBSTR(SQLERRM,1,100);
     SELF.esn := i_esn;
     RETURN;
END;

-- Constructor used to initialize the ESN and TITLE
CONSTRUCTOR FUNCTION alert_type ( i_esn_part_inst_objid IN VARCHAR2 ,
                                  i_title               IN VARCHAR2 ) RETURN SELF AS RESULT IS

BEGIN

  -- Make sure the ESN objid is passed
  IF i_esn_part_inst_objid IS NULL THEN
    SELF.response := 'ESN PARAMETER NOT PASSED';
    RETURN;
  END IF;

  -- Set values
  SELF.esn_part_inst_objid := i_esn_part_inst_objid;
  SELF.title := i_title;

  -- Return successful response
  SELF.response := 'SUCCESS';

  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'UNABLE TO INSTANTIATE ALERT: ' || SUBSTR(SQLERRM,1,100);
     SELF.esn_part_inst_objid := i_esn_part_inst_objid;
     SELF.title := i_title;
     RETURN;
END;

-- Constructor used to initialize the ESN and or MIN
CONSTRUCTOR FUNCTION alert_type ( i_esn                 IN VARCHAR2  ,
                                  i_type                IN VARCHAR2  ,
                                  i_alert_text          IN VARCHAR2  ,
                                  i_start_date          IN DATE      ,
                                  i_end_date            IN DATE      ,
                                  i_active              IN NUMBER    ,
                                  i_title               IN VARCHAR2  ,
                                  i_hotline             IN NUMBER    ,
                                  i_dev                 IN NUMBER    DEFAULT NULL,
                                  i_user_objid          IN NUMBER    ,
                                  i_contact_objid       IN NUMBER    DEFAULT NULL,
                                  i_site_objid          IN NUMBER    DEFAULT NULL,
                                  i_esn_part_inst_objid IN NUMBER    ,
                                  i_bus_org_objid       IN NUMBER    DEFAULT NULL,
                                  i_alert2lead          IN NUMBER    DEFAULT NULL,
                                  i_alert2opportunity   IN NUMBER    DEFAULT NULL,
                                  i_modify_stmp         IN DATE      ,
                                  i_ivr_script_id       IN VARCHAR2  ,
                                  i_web_text_english    IN VARCHAR2  ,
                                  i_web_text_spanish    IN VARCHAR2  ,
                                  i_cancel_sql          IN VARCHAR2  ,
                                  i_tts_english         IN VARCHAR2  DEFAULT NULL,
                                  i_tts_spanish         IN VARCHAR2  DEFAULT NULL,
                                  i_eval_sql            IN NUMBER    DEFAULT NULL,
                                  i_condition_sql       IN VARCHAR2  DEFAULT NULL,
                                  i_step                IN NUMBER    DEFAULT NULL    ) RETURN SELF AS RESULT IS
BEGIN

  -- Make sure we pass at least one parameters
  IF i_esn IS NULL THEN
    SELF.response := 'NO INPUT PARAMETERS PASSED';
    RETURN;
  END IF;

  SELF.esn                 := i_esn                 ;
  SELF.type                := i_type                ;
  SELF.alert_text          := i_alert_text          ;
  SELF.start_date          := i_start_date          ;
  SELF.end_date            := i_end_date            ;
  SELF.active              := i_active              ;
  SELF.title               := i_title               ;
  SELF.hotline             := i_hotline             ;
  SELF.dev                 := i_dev                 ;
  SELF.user_objid          := i_user_objid          ;
  SELF.contact_objid       := i_contact_objid       ;
  SELF.site_objid          := i_site_objid          ;
  SELF.esn_part_inst_objid := i_esn_part_inst_objid ;
  SELF.bus_org_objid       := i_bus_org_objid       ;
  SELF.alert2lead          := i_alert2lead          ;
  SELF.alert2opportunity   := i_alert2opportunity   ;
  SELF.modify_stmp         := i_modify_stmp         ;
  SELF.ivr_script_id       := i_ivr_script_id       ;
  SELF.web_text_english    := i_web_text_english    ;
  SELF.web_text_spanish    := i_web_text_spanish    ;
  SELF.cancel_sql          := i_cancel_sql          ;
  SELF.tts_english         := i_tts_english         ;
  SELF.tts_spanish         := i_tts_spanish         ;
  SELF.eval_sql            := i_eval_sql            ;
  SELF.condition_sql       := i_condition_sql       ;
  SELF.step                := i_step                ;

  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'UNABLE TO INSTANTIATE ALERT: ' || SUBSTR(SQLERRM,1,100);
     SELF.esn := i_esn;
     RETURN;
END;

-- Function used to get all the attributes for a particular alert
MEMBER FUNCTION retrieve RETURN alert_type IS

  cst  alert_type := SELF;
  c    alert_type := SELF;

BEGIN

  -- Initialize entire cst type with an empty object
  cst := alert_type ();

  cst.esn := c.esn;

  cst.min := NULL;

  -- Exit when the ESN is not passed
  IF cst.esn IS NULL THEN
    cst.response := 'ESN NOT PASSED';
    RETURN cst;
  END IF;

  -- Get the min, carrier parent and wf_mac_id
  BEGIN
    SELECT pi_min.part_serial_no min,
           pi_esn.objid esn_part_inst_objid,
           pi_min.objid min_part_inst_objid,
           pi_esn.x_part_inst2contact
    INTO   cst.min,
           cst.esn_part_inst_objid,
           cst.min_part_inst_objid,
		   cst.contact_objid
    FROM   table_part_inst pi_esn,
           table_part_inst pi_min
    WHERE  pi_esn.part_serial_no = cst.esn
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_min.part_to_esn2part_inst = pi_esn.objid
    AND    pi_min.x_domain = 'LINES';
   EXCEPTION
     WHEN too_many_rows THEN
       cst.response := cst.response || 'DUPLICATE ESN FOUND';
     WHEN no_data_found THEN
       BEGIN
         SELECT pi_esn.objid esn_part_inst_objid
         INTO   cst.esn_part_inst_objid
         FROM   table_part_inst pi_esn
         WHERE  pi_esn.part_serial_no = cst.esn
         AND    pi_esn.x_domain = 'PHONES';
         EXCEPTION
           WHEN others THEN
             cst.response := cst.response || 'ESN NOT FOUND';
             RETURN cst;
       END;
     WHEN others THEN
       cst.response := cst.response || 'UNHANDLED ERROR: ' || SQLERRM;
       RETURN cst;
  END;


  -- Get the web user and contact (Active site part status)
  BEGIN
    SELECT sp.objid site_part_objid,
           NVL2(cst.min, cst.min, sp.x_min) min
    INTO   cst.site_part_objid,
           cst.min
    FROM   table_site_part sp
    WHERE  1 = 1
    AND    sp.x_service_id = cst.esn
    AND    sp.part_status = 'Active';
   EXCEPTION
     WHEN no_data_found THEN
       -- get the zipcode, iccid and site part status for the last updated row in site part
       BEGIN
         SELECT sp.objid site_part_objid,
                NVL2(cst.min, cst.min, sp.x_min) min
         INTO   cst.site_part_objid,
                cst.min
         FROM   table_site_part sp
         WHERE  1 = 1
         AND    sp.x_service_id = cst.esn
         AND    sp.update_stamp = ( SELECT MAX(update_stamp)
                                    FROM   table_site_part
                                    WHERE  x_service_id = sp.x_service_id
                                    AND    x_min = sp.x_min
                                  );
        EXCEPTION
          WHEN others THEN
            cst.response := cst.response || '|SITE PART STATUS, ZIPCODE NOT FOUND';
       END;
     WHEN too_many_rows THEN
       -- Get the max objid when there is more than one active site part
       BEGIN
         SELECT sp.objid site_part_objid,
                NVL2(cst.min, cst.min, sp.x_min) min
         INTO   cst.site_part_objid,
                cst.min
         FROM   table_site_part sp
         WHERE  1 = 1
         AND    sp.x_service_id = cst.esn
         AND    sp.part_status = 'Active'
         AND    sp.objid = ( SELECT MAX(objid)
                             FROM   table_site_part
                             WHERE  x_service_id = sp.x_service_id
                             AND    part_status = 'Active'
                           );
        EXCEPTION
          WHEN no_data_found THEN
            cst.response := cst.response || '|SITE PART NOT FOUND';
          WHEN others THEN
            cst.response := cst.response || '|SITE PART NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       END;
     WHEN others THEN
       cst.response := cst.response || '|SITE PART NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN cst;
  END;

  -- Get the activation site id
  BEGIN
    SELECT s.objid
    INTO   cst.site_objid
    FROM   table_x_call_trans ct,
           table_site s
    WHERE  ct.x_service_id = cst.esn
    AND    ct.x_action_type = '1'
    AND    ct.x_call_trans2dealer = s.objid
    AND    ct.objid = ( SELECT MAX(objid)
                        FROM   table_x_call_trans
                        WHERE  x_service_id = ct.x_service_id
                        AND    x_action_type = ct.x_action_type
                      );
   EXCEPTION
       WHEN others THEN
         NULL;
  END;

  -- Get the web user and contact
  BEGIN
    SELECT wu.objid web_user_objid,
           wu.login_name web_login_name,
           wu.web_user2contact
    INTO   cst.web_user_objid,
           cst.web_login_name,
           cst.web_contact_objid
    FROM   table_x_contact_part_inst cpi,
           table_web_user wu
    WHERE  1 = 1
    AND    cpi.x_contact_part_inst2part_inst = cst.esn_part_inst_objid
    AND    wu.web_user2contact = cpi.x_contact_part_inst2contact;
   EXCEPTION
     WHEN no_data_found THEN
       cst.response := cst.response || '|WEB USER NOT FOUND';
     WHEN too_many_rows THEN
       --
       BEGIN
         SELECT wu.objid web_user_objid,
                wu.login_name web_login_name,
                wu.web_user2contact
         INTO   cst.web_user_objid,
                cst.web_login_name,
                cst.web_contact_objid
         FROM   table_x_contact_part_inst cpi,
                table_web_user wu
         WHERE  1 = 1
         AND    cpi.x_contact_part_inst2part_inst = cst.esn_part_inst_objid
         AND    wu.web_user2contact = cpi.x_contact_part_inst2contact
         AND    web_user2bus_org = cst.bus_org_objid;
        EXCEPTION
          WHEN others THEN
            cst.response := cst.response || '|DUPLICATE WEB USER';
            cst.response := cst.response || '|WEB USER PER BRAND NOT FOUND';
       END;
     WHEN OTHERS THEN
       cst.response := cst.response || '|WEB USER NOT FOUND: '|| SUBSTR(SQLERRM,1,100);
  END;

  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  -- Return the type
  RETURN cst;

 EXCEPTION
   WHEN OTHERS THEN
     cst.response := 'ERROR RETRIEVING CUSTOMER: ' || SQLERRM;
     RETURN cst;
     --
END retrieve;

-- Function used to get all the attributes for a particular customer
MEMBER FUNCTION retrieve ( i_esn IN VARCHAR2 ) RETURN alert_type IS

  -- instantiate initial values
  rc     sa.alert_type  := alert_type ( i_esn => i_esn );

  -- type to hold retrieved attributes
  cst    sa.alert_type;

BEGIN

  -- call the retrieve method
  cst := rc.retrieve;

  RETURN cst;

END retrieve;

-- Get the brand objid
MEMBER FUNCTION ins RETURN alert_type IS

  a  alert_type := SELF;

BEGIN

  IF a.esn_part_inst_objid IS NULL THEN
    a.response := 'ESN OBJID CANNOT BE NULL';
    RETURN a;
  END IF;

  IF a.title IS NULL THEN
    a.response := 'ALERT TITLE CANNOT BE NULL';
    RETURN a;
  END IF;

  IF a.start_date IS NULL THEN
    a.response := 'START DATE CANNOT BE NULL';
    RETURN a;
  END IF;

  IF a.end_date IS NULL THEN
    a.response := 'END DATE CANNOT BE NULL';
    RETURN a;
  END IF;

  BEGIN
    INSERT
    INTO   sa.table_alert
           ( objid              ,
             type               ,
             alert_text         ,
             start_date         ,
             end_date           ,
             active             ,
             title              ,
             hot                ,
             dev                ,
             last_update2user   ,
             alert2contact      ,
             alert2site         ,
             alert2contract     ,
             alert2bus_org      ,
             alert2lead         ,
             alert2opportunity  ,
             modify_stmp        ,
             x_ivr_script_id    ,
             x_web_text_english ,
             x_web_text_spanish ,
             x_cancel_sql       ,
             x_tts_english      ,
             x_tts_spanish      ,
             x_eval_sql         ,
             x_condition_sql    ,
             x_step
           )
    VALUES
    ( sa.sequ_alert.NEXTVAL,
      a.type               ,
      a.alert_text         ,
      a.start_date         ,
      a.end_date           ,
      a.active             ,
      a.title              ,
      a.hotline            ,
      a.dev                ,
      a.user_objid         ,
      a.contact_objid      ,
      a.site_objid         ,
      a.esn_part_inst_objid,
      a.bus_org_objid      ,
      a.alert2lead         ,
      a.alert2opportunity  ,
      a.modify_stmp        ,
      a.ivr_script_id    ,
      a.web_text_english ,
      a.web_text_spanish ,
      a.cancel_sql       ,
      a.tts_english      ,
      a.tts_spanish      ,
      a.eval_sql         ,
      a.condition_sql    ,
      a.step
    )
    RETURNING objid INTO a.alert_objid;
   --
   EXCEPTION
     WHEN dup_val_on_index then
       a.response := 'DUPLICATE VALUE INSERTING INTO ALERT';
       RETURN a;
     WHEN others then
       a.response := 'ERROR INSERTING ALERT: ' ||SQLERRM;
       RETURN a;
  END;

  dbms_output.put_line(NVL(SQL%ROWCOUNT,0) || ' row(s) created in ALERT (' || a.alert_objid || ')');

  a.response := 'SUCCESS';
  --
  RETURN a;
  --
 EXCEPTION
   WHEN others THEN
     a.response := 'ERROR SAVING ALERT RECORD: ' || SQLERRM;
     RETURN a;
END ins;

-- Function used to delete an alert record
MEMBER FUNCTION del RETURN alert_type IS

  a  alert_type := SELF;

BEGIN
  --
  IF a.esn_part_inst_objid IS NULL THEN
    a.response := 'ESN NOT PASSED';
	RETURN a;
  END IF;

  IF a.title IS NULL THEN
    a.response := 'ALERT TITLE NOT PASSED';
	RETURN a;
  END IF;

  --
  DELETE
  FROM   sa.table_alert
  WHERE  alert2contract = a.esn_part_inst_objid
  AND    title = a.title;

  a.response := 'SUCCESS';
  --
  RETURN a;
  --
 EXCEPTION
   WHEN others THEN
     a.response := 'ERROR DELETING ALERT RECORD: ' || SQLERRM;
     RETURN a;
END del;

--
END;
/