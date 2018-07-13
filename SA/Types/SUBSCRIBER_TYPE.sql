CREATE OR REPLACE TYPE sa.subscriber_type FORCE  AS OBJECT (
  pcrf_min                   VARCHAR2(30),
  pcrf_mdn                   VARCHAR2(30),
  pcrf_esn                   VARCHAR2(30),
  pcrf_subscriber_id         VARCHAR2(50),
  pcrf_group_id              VARCHAR2(50),
  pcrf_parent_name           VARCHAR2(40),
  pcrf_cos                   VARCHAR2(30),
  pcrf_base_ttl              DATE,
  pcrf_last_redemption_date  DATE,
  future_ttl                 DATE,
  brand                      VARCHAR2(40),
  phone_manufacturer         VARCHAR2(30),
  phone_model                VARCHAR2(50),
  content_delivery_format    VARCHAR2(50),
  denomination               VARCHAR2(50),
  conversion_factor          VARCHAR2(50),
  dealer_id                  VARCHAR2(80),
  rate_plan                  VARCHAR2(60),
  propagate_flag             NUMBER(4),
  pcrf_transaction_id        NUMBER(22),
  service_plan_type          VARCHAR2(50),
  service_plan_id            NUMBER(22),
  queued_days                NUMBER(3),
  language                   VARCHAR2(30),
  part_inst_status           VARCHAR2(30),
  bus_org_objid              NUMBER(22),
  contact_objid              NUMBER(22),
  web_user_objid             NUMBER(22),
  subscriber_spr_objid       NUMBER(22),
  wf_mac_id                  VARCHAR2(50),
  expired_usage_date         DATE,
  subscriber_status          VARCHAR2(50),
  curr_throttle_policy_id    NUMBER,
  curr_throttle_eff_date     DATE,
  zipcode                    VARCHAR2(10),
  status                     VARCHAR2(1000),
  addons                     subscriber_detail_tab,
  carrier_objid              NUMBER(22),
  technology                 VARCHAR2(50),
  enrolled_autorefill_flag   VARCHAR2(1),
  part_class_name            VARCHAR2(50),
  device_type                VARCHAR2(50),
  meter_source_voice         NUMBER(22),
  meter_source_sms           NUMBER(22),
  meter_source_data          NUMBER(22),
  meter_source_ild           NUMBER(22),
  iccid                      VARCHAR2(30),
  imsi                       VARCHAR2(30),
  -- CR43143 Add New fields in SPR table
  lifeline_id               VARCHAR2(50),
  install_date              DATE,
  program_parameter_id      VARCHAR2(50),
  vmbc_certification_flag   VARCHAR2(1),
  char_field_1              VARCHAR2(100),
  char_field_2              VARCHAR2(100),
  char_field_3              VARCHAR2(100),
  date_field_1              DATE,
  insert_timestamp          DATE,
  update_timestamp          DATE,
  rcs_enable_flag           VARCHAR2(1),
  CONSTRUCTOR FUNCTION subscriber_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION subscriber_type ( i_esn           IN VARCHAR2,
                                         i_min           IN VARCHAR2 DEFAULT NULL,
                                         i_msid          IN VARCHAR2 DEFAULT NULL,
                                         i_subscriber_id IN VARCHAR2 DEFAULT NULL,
                                         i_wf_mac_id     IN VARCHAR2 DEFAULT NULL ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION subscriber_type ( i_subscriber_spr_objid IN NUMBER,
                                         i_esn                  IN VARCHAR2 ) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION exist ( i_esn IN VARCHAR2) RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_esn IN VARCHAR2) RETURN subscriber_type,
  MEMBER FUNCTION ins RETURN subscriber_type,
  MEMBER FUNCTION upd ( i_esn IN VARCHAR2) RETURN BOOLEAN,
  MEMBER FUNCTION upd RETURN subscriber_type,
  ---
  -- CR36349_PAGE_PLUS_Page_Provisioning_via_TF_account/Enable_Sure_Carrier_for_Page VLAAD 07/14/2016 Added new oveloaded UPD function
  ---
  --MEMBER FUNCTION upd (sub IN OUT subscriber_type) RETURN subscriber_type,
  MEMBER FUNCTION del ( i_esn IN  VARCHAR2) RETURN BOOLEAN,
  MEMBER FUNCTION del RETURN BOOLEAN,
  ---
  -- CR36349_PAGE_PLUS_Page_Provisioning_via_TF_account/Enable_Sure_Carrier_for_Page VLAAD 07/14/2016 Added new oveloaded DEL function
  ---
  MEMBER FUNCTION del (sub IN OUT subscriber_type) RETURN subscriber_type,

  MEMBER FUNCTION get RETURN subscriber_type,
  MEMBER FUNCTION get ( i_esn            IN  VARCHAR2 ,
                        i_min            IN  VARCHAR2 ,
                        i_msid           IN  VARCHAR2 ,
                        i_subscriber_id  IN  VARCHAR2 ,
                        i_wf_mac_id      IN  VARCHAR2 ,
                        o_err_code       OUT NUMBER   ,
                        o_err_msg        OUT VARCHAR2 ) RETURN subscriber_type,
  MEMBER FUNCTION get_subscriber_uid ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,
  MEMBER FUNCTION get_subscriber_id RETURN VARCHAR2,
  MEMBER FUNCTION delAddOn( ao_offer_id IN VARCHAR2, o_result OUT VARCHAR2 ) RETURN BOOLEAN,
  MEMBER FUNCTION expireAddOns(ao_offer_id in VARCHAR2 default 'ALL', o_result out VARCHAR2) return BOOLEAN,
  MEMBER FUNCTION get_status RETURN VARCHAR2,
  MEMBER FUNCTION save ( sub subscriber_type ) RETURN VARCHAR2,
  MEMBER FUNCTION process_upgrade ( i_old_esn              IN VARCHAR2,
                                    i_new_esn              IN VARCHAR2,
                                    i_last_redemption_date IN DATE DEFAULT NULL,
                                    i_sourcesystem         IN VARCHAR2 DEFAULT NULL ,
                                    i_order_type           IN VARCHAR2 DEFAULT NULL ,
                                    i_pcrf_subscriber_id   IN VARCHAR2 DEFAULT NULL ,
                                    i_pcrf_group_id        IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2,
  MEMBER FUNCTION retrieve (i_ignore_tw_logic_flag         IN VARCHAR2 DEFAULT 'N') RETURN subscriber_type,
  MEMBER FUNCTION refresh_dates ( i_esn IN VARCHAR2) RETURN subscriber_type,
---
-- CR36349_PAGE_PLUS_Page_Provisioning_via_TF_account/Enable_Sure_Carrier_for_Page VLAAD 07/18/2016 Added new function UPDATE_DATES
---
  MEMBER FUNCTION update_dates (sub IN OUT subscriber_type) RETURN subscriber_type,

  MEMBER FUNCTION get_meter_sources ( i_device_type         IN VARCHAR2,
                                      i_source_system       IN VARCHAR2 DEFAULT NULL, -- CR46475
                                      i_brand               IN VARCHAR2,
                                      i_parent_name         IN VARCHAR2,
                                      i_service_plan_group  IN VARCHAR2 DEFAULT NULL ) RETURN subscriber_type,
  MEMBER FUNCTION get_cos_attributes RETURN subscriber_type,
  MEMBER FUNCTION remove RETURN subscriber_type,

--CR43143
  MEMBER FUNCTION get_vmbc_certification_flag (i_esn in varchar2) return varchar2,
--CR47564 start
  MEMBER FUNCTION update_program_param_id (i_min in varchar2,
                                           i_program_param_id in number) return varchar2,
  MEMBER FUNCTION get_esn_pin_redeem_days ( i_esn IN VARCHAR2 ) RETURN NUMBER,
--CR47564 end
  MEMBER FUNCTION upd_spr_throttle_status ( i_esn IN VARCHAR2,
                                            i_min IN VARCHAR2  ) RETURN varchar2,
  --51255
  MEMBER FUNCTION expire_pp_addons(ao_offer_id in   VARCHAR2 default 'ALL',
                                 o_result    out  VARCHAR2) return boolean
);
/
CREATE OR REPLACE TYPE BODY sa.SUBSCRIBER_TYPE   IS
CONSTRUCTOR FUNCTION subscriber_type RETURN SELF AS RESULT IS
BEGIN
  SELF.addons := subscriber_detail_tab();
  RETURN;
END;

CONSTRUCTOR FUNCTION subscriber_type ( i_esn           IN VARCHAR2,
                                       i_min           IN VARCHAR2 DEFAULT NULL,
                                       i_msid          IN VARCHAR2 DEFAULT NULL,
                                       i_subscriber_id IN VARCHAR2 DEFAULT NULL,
                                       i_wf_mac_id     IN VARCHAR2 DEFAULT NULL ) RETURN SELF AS RESULT IS
  n_number_of_lines NUMBER;
  c_sql             VARCHAR2(4000);
  c_where           VARCHAR2(4000);
BEGIN

-- Make sure we pass at least one parameters
IF ( i_esn IS NULL AND
     i_min IS NULL AND
     i_msid IS NULL AND
     i_subscriber_id IS NULL AND
     i_wf_mac_id IS NULL )
THEN
  self.status := 'NO INPUT PARAMETERS PASSED';
  RETURN;
END IF;

  -- Query the table
  c_sql := 'SELECT subscriber_type ( pcrf_min        ,
                           pcrf_mdn                  ,
                           pcrf_esn                  ,
                           pcrf_subscriber_id        ,
                           pcrf_group_id             ,
                           pcrf_parent_name          ,
                           pcrf_cos                  ,
                           pcrf_base_ttl             ,
                           pcrf_last_redemption_date ,
                           future_ttl                ,
                           brand                     ,
                           phone_manufacturer        ,
                           phone_model               ,
                           content_delivery_format   ,
                           denomination              ,
                           conversion_factor         ,
                           dealer_id                 ,
                           rate_plan                 ,
                           NVL(propagate_flag,2)     , --CR52372 setting default value to 2
                           pcrf_transaction_id       ,
                           service_plan_type         ,
                           service_plan_id           ,
                           NVL(queued_days,0)        ,
                           language                  ,
                           part_inst_status          ,
                           bus_org_objid             ,
                           contact_objid             ,
                           web_user_objid            ,
                           objid                     , -- subscriber objid
                           wf_mac_id                 ,
                           expired_usage_date        ,
                           INITCAP(ss.description)   , -- subscriber_status
                           curr_throttle_policy_id   ,
                           curr_throttle_eff_date    ,
                           zipcode                   ,
                           NULL                      , -- status
                           NULL                      , -- addons tab
                           NULL                      , -- carrier_objid
                           NULL                      , -- technology
                           NULL                      , -- enrolled_autorefill_flag
                           NULL                      ,  -- part_class_name
                           NULL                      , -- device_type
                           meter_source_voice        , -- meter_source_voice
                           meter_source_sms          , -- meter_source_sms
                           meter_source_data         , -- meter_source_data
                           meter_source_ild          , -- meter_source_ild
                           null                      , -- iccid
                           imsi                      , -- imsi
                           -- CR43143 Add New Fields to SPR
                           lifeline_id               ,
                           install_date              ,
                           program_parameter_id      ,
                           vmbc_certification_flag   ,
                           char_field_1              ,
                           char_field_2              ,
                           char_field_3              ,
                           date_field_1              ,
                           s.insert_timestamp        ,  --insert_timestamp
                           s.update_timestamp        ,  --update_timestamp,
                           rcs_enable_flag
                         )subs
  FROM   x_subscriber_spr s,
         x_subscriber_status ss
  WHERE  ss.subscriber_status_code = s.subscriber_status_code ';

  --
  IF ( i_esn IS NOT NULL
      and i_min is null
      and i_msid is null
      and i_subscriber_id is null
      and i_wf_mac_id is null)
  THEN
    c_sql := c_sql ||' and pcrf_esn = :esn ';
    execute immediate c_sql into self using i_esn;
  elsif (i_esn is  null
      and i_min is null
      and i_msid is null
      and i_subscriber_id is not null
      and i_wf_mac_id is null)
  then
    c_sql := c_sql ||' and pcrf_subscriber_id = :subid ';
    execute immediate c_sql into self using i_subscriber_id;
  elsif (i_esn is  null
      and i_min is not null
      and i_msid is null
      and i_subscriber_id is null
      and i_wf_mac_id is null)
  then
    c_sql := c_sql ||' and pcrf_min = :min ';
    EXECUTE IMMEDIATE c_sql INTO SELF USING i_min;
  elsif (i_esn is  null
      and i_min is null
      and i_msid is not null
      and i_subscriber_id is null
      and i_wf_mac_id is null)
  THEN
    c_sql := c_sql || ' and pcrf_mdn = :mdn ';
    EXECUTE IMMEDIATE c_sql INTO SELF USING i_msid;
  ELSE
    SELECT NVL2(i_esn, ' and pcrf_esn = '''||i_esn||'''',null) ||
           NVL2(i_min, ' and pcrf_min = '''||i_min||'''',null) ||
           NVL2(i_msid,' and pcrf_mdn = '''||i_msid||'''',null)||
           NVL2(i_subscriber_id,' and pcrf_subscriber_id = '''|| i_subscriber_id||'''',null)||
           NVL2(i_wf_mac_id,' and wf_mac_id = '''||i_wf_mac_id||'''',null)
    INTO   c_where
    FROM   dual;
    c_sql := c_sql || c_where;
    EXECUTE IMMEDIATE c_sql INTO SELF;
  END IF;
  --

  SELECT subscriber_detail_type ( subscriber_spr_objid   ,
                                  add_on_offer_id        ,
                                  add_on_ttl             ,
                                  add_on_redemption_date ,
                                  expired_usage_date     ,
                                  NULL                   ,                                  -- status
                                  acct_grp_benefit_objid
                                )
  BULK COLLECT
  INTO   SELF.addons
  FROM   x_subscriber_spr_detail
  WHERE  subscriber_spr_objid = SELF.subscriber_spr_objid;

  -- If account group objid is not blank
  IF SELF.service_plan_id IS NOT NULL THEN
    -- Send the GROUP_ID if the service plan id is capable of having more than one member even if currently the customer is enrolled into one.
    BEGIN
      SELECT TO_NUMBER(NVL(number_of_lines,0))
      INTO   n_number_of_lines
      FROM   sa.service_plan_feat_pivot_mv
      WHERE  service_plan_objid = SELF.service_plan_id;
     EXCEPTION
       WHEN others THEN
         n_number_of_lines := 0;
    END;

    -- Blank out group attributes when there is only 1 active member of the group
    IF NVL(n_number_of_lines,0) <= 1 THEN
      SELF.pcrf_group_id := NULL;
    END IF;
  END IF;

  --
  SELF.status := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.status := 'SUBSCRIBER NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     SELF.pcrf_esn := i_esn;
     SELF.pcrf_min := i_min;
     SELF.pcrf_mdn := i_msid;
     SELF.pcrf_subscriber_id := i_subscriber_id;
     SELF.wf_mac_id := i_wf_mac_id;

     -- Initialize the subscriber detail tab collection when the subscriber was not found
     SELF.addons := subscriber_detail_tab();
     RETURN;
END;


CONSTRUCTOR FUNCTION subscriber_type ( i_subscriber_spr_objid IN NUMBER,
                                       i_esn                  IN VARCHAR2 ) RETURN SELF AS RESULT IS

BEGIN
  --
  SELF.subscriber_spr_objid := i_subscriber_spr_objid;
  SELF.pcrf_esn := i_esn;

  --
  SELF.status := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     self.status   := 'ERROR INITIALIZING SUBSCRIBER: ' || SUBSTR(SQLERRM,1,100);
     SELF.subscriber_spr_objid := i_subscriber_spr_objid;
     SELF.pcrf_esn := i_esn;
     -- Initialize the subscriber detail tab collection when the subscriber was not found
     self.addons := subscriber_detail_tab();
     RETURN;
END subscriber_type;

MEMBER FUNCTION get_status RETURN VARCHAR2 IS
BEGIN
   RETURN SELF.status;
END;

MEMBER FUNCTION get RETURN subscriber_type is
 sub subscriber_type := subscriber_type(self.pcrf_esn);
 s   subscriber_type;
BEGIN

  IF ( sub.status <> 'SUCCESS' ) THEN
    -- Try to insert the subscriber when it doesn't exist
    s := sub.ins;
    -- When subscriber was created successfully
    IF INSTR(s.status,'SUCCESS') > 0 THEN
      -- Return the newly created subscriber
      sub := s;
    END IF;
  END IF;

  --
  RETURN sub;
END;

MEMBER FUNCTION get ( i_esn              IN  VARCHAR2,
                      i_min              IN  VARCHAR2,
                      i_msid             IN  VARCHAR2,
                      i_subscriber_id    IN  VARCHAR2,
                      i_wf_mac_id        IN  VARCHAR2,
                      o_err_code         OUT NUMBER  ,
                      o_err_msg          OUT VARCHAR2 ) RETURN subscriber_type IS

  sub  subscriber_type := SELF;
  s    subscriber_type;
  n_number_of_lines  NUMBER;
BEGIN

  -- At least one optional parameter should be passed
  IF ( i_esn           IS NULL AND
       i_min           IS NULL AND
       i_msid          IS NULL AND
       i_subscriber_id IS NULL AND
       i_wf_mac_id     IS NULL)
  THEN
    o_err_code := 10;
    o_err_msg  := 'NO INPUT PASSED';
    sub.status := 'NO INPUT PASSED';
  RETURN sub;
  END IF;

  -- Call constructor to get the subscriber spr data
  sub := subscriber_type ( i_esn            => i_esn,
                           i_min            => i_min,
                           i_msid           => i_msid,
                           i_subscriber_id  => i_subscriber_id,
                           i_wf_mac_id      => i_wf_mac_id );

  IF ( sub.status = 'SUCCESS' ) THEN
     -- if the TTL is less than sysdate or blank then synchronize the SPR row once again
     IF sub.pcrf_base_ttl <= SYSDATE  OR sub.pcrf_base_ttl IS NULL THEN
       s := sub.ins;
       sub := s;
     END IF;

     o_err_code  := 0;
  ELSE

    IF sub.pcrf_esn IS NULL THEN

      -- Determine the ESN based on other passed optional parameters
      sub.pcrf_esn := sa.util_pkg.get_esn ( i_min           => i_min           ,
                                            i_msid          => i_msid          ,
                                            i_subscriber_id => i_subscriber_id ,
                                            i_wf_mac_id     => i_wf_mac_id     );
    END IF;

    -- Try to insert the subscriber when it doesn't exist
    s := sub.ins;

    -- When subscriber was created successfully
    IF INSTR(s.status,'SUCCESS') > 0 THEN
      -- Return the newly created subscriber
      sub := s;
      o_err_code := 0;
    ELSE
      o_err_code  := 99;
    END IF;
  END IF;

  IF sub.service_plan_id IS NOT NULL THEN
    BEGIN
      SELECT TO_NUMBER(NVL(number_of_lines,0))
      INTO   n_number_of_lines
      FROM   sa.service_plan_feat_pivot_mv
      WHERE  service_plan_objid = sub.service_plan_id;
     EXCEPTION
       WHEN others THEN
         n_number_of_lines := 0;
    END;
    IF NVL(n_number_of_lines,0) <= 1 THEN
      sub.pcrf_group_id := NULL;
    END IF;
  END IF;
  o_err_msg := sub.status;

  --
  RETURN sub;
END get;

MEMBER FUNCTION ins RETURN subscriber_type IS
  sub     subscriber_type := SELF;
  s       subscriber_type;
begin
  s := sub.ins ( SELF.pcrf_esn );
  RETURN s;
END ins;

-- Procedure to add the SUBSCRIBER row based on ESN or MIN with all the proper validations.
MEMBER FUNCTION ins ( i_esn IN VARCHAR2) RETURN subscriber_type IS

  sub          subscriber_type := subscriber_type (i_esn => i_esn);
  s            subscriber_type := SELF;
  detail       subscriber_detail_type := subscriber_detail_type();

BEGIN

  --
  IF sub.pcrf_esn IS NULL THEN
    sub.status := 'NO ESN or MIN PASSED';
    RETURN sub;
  END IF;

  -- Retrieve the subscriber data
  s := sub.retrieve;

  -- Save transaction only when retrieve came back successfull
  IF s.status LIKE '%SUCCESS%' THEN

    -- Raw insert into X_SUBSCRIBER_SPR table
    s.status := s.status || '|' || save(s);

    -- insert addons/offers
    IF NOT detail.ins ( i_esn => sub.pcrf_esn, o_result => detail.status ) THEN
      s.status := s.status || '|ERROR INSERTING ADD ONS: ' || detail.status;
    END IF;

    -- re-insert queued cards
    -- IF qc.del ( i_esn => sub.pcrf_esn, o_response => qc.response ) THEN
      -- IF NOT qc.ins ( i_esn => sub.pcrf_esn, o_response => qc.response ) THEN
        -- s.status := s.status || '|ERROR INSERTING QUEUED CARDS: ' || qc.response;
      -- END IF;
    -- END IF;

    -- Set successful response
    s.status := s.status || '|' || CASE WHEN s.status IS NULL THEN 'SUCCESS' ELSE '|SUCCESS' END;

  ELSE
    -- Return error message in the s response
    NULL;
  END IF;


  RETURN s;

 EXCEPTION WHEN OTHERS THEN
   s.status := s.status || '|ERROR INSERTING SUBSCRIBER RECORD: ' || SUBSTR(SQLERRM,1,100);
   --
   RETURN s;
END ins;

MEMBER FUNCTION exist RETURN BOOLEAN IS

 sub  subscriber_type := subscriber_type(i_esn => SELF.pcrf_esn);

BEGIN
 IF sub.pcrf_subscriber_id IS NOT NULL THEN
    RETURN TRUE;
 ELSE
    RETURN FALSE;
 END IF;
END;

-- Validate if a subscriber exists in the subscriber table
MEMBER FUNCTION exist ( i_esn IN VARCHAR2)  RETURN BOOLEAN IS

  sub subscriber_type := subscriber_type ( i_esn => i_esn );

BEGIN
  IF sub.pcrf_subscriber_id IS NOT NULL THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;

-- Function to expire a subscriber
MEMBER FUNCTION upd ( i_esn IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
  RETURN TRUE;
END upd;

-- Function to update a subscriber
MEMBER FUNCTION upd RETURN subscriber_type IS

  sub  subscriber_type := SELF;
  spr_detail  subscriber_detail_type := subscriber_detail_type(); -- CR50892

BEGIN
  IF sub.subscriber_spr_objid IS NOT NULL AND sub.pcrf_esn IS NOT NULL THEN
    sub.queued_days := sub.get_esn_pin_redeem_days(i_esn => sub.pcrf_esn ); -- CR50892

    UPDATE x_subscriber_spr
    SET    pcrf_esn = NVL(sub.pcrf_esn, pcrf_esn),
           future_ttl = nvl((sub.pcrf_base_ttl + NVL(sub.queued_days,0)),sub.future_ttl) , -- CR50892
           update_timestamp = SYSDATE
    WHERE  objid = sub.subscriber_spr_objid;
  END IF;

  sub.status := 'SUCCESS';

  -- insert addons/offers  CR50892
  IF NOT spr_detail.ins ( i_esn => sub.pcrf_esn, o_result => spr_detail.status ) THEN
     sub.status := sub.status || '|ERROR INSERTING ADD ONS: ' || spr_detail.status;
  END IF;

  RETURN sub;

END upd;

MEMBER FUNCTION del RETURN BOOLEAN IS

  sub subscriber_type := subscriber_type( SELF.pcrf_esn );

BEGIN
   RETURN sub.del(SELF.pcrf_esn);
END;

MEMBER FUNCTION del ( i_esn IN VARCHAR2) RETURN BOOLEAN IS

  sub subscriber_type := SELF;

BEGIN

  --
  UPDATE x_subscriber_spr s
  SET    pcrf_base_ttl          = NVL(sa.util_pkg.get_expire_dt(pcrf_esn),SYSDATE),
         future_ttl             = NVL(sa.util_pkg.get_expire_dt(pcrf_esn),SYSDATE),
         update_timestamp       = SYSDATE,
         subscriber_status_code = 'EXP',
         part_inst_status       = ( CASE
                                     WHEN ( SELECT part_status
                                            FROM   ( SELECT part_status
                                                     FROM   table_site_part
                                                     WHERE  x_service_id = i_esn
                                                     ORDER BY update_stamp DESC
                                                   )
                                            WHERE  ROWNUM = 1
                                          ) = 'Active' THEN 'Active'
                                     ELSE 'Inactive'
                                   END )
  WHERE  pcrf_esn = i_esn;

  sub.status := 'SUCCESS';
  RETURN TRUE;
 EXCEPTION
   WHEN others THEN
     sub.status := 'ERROR DELETING SUBSCRIBER: ' || SUBSTR(SQLERRM,1,100);
     RETURN FALSE;
END del;

---
-- CR36349_PAGE_PLUS_Page_Provisioning_via_TF_account/Enable_Sure_Carrier_for_Page VLAAD 07/14/2016 Added new oveloaded DEL function
---
MEMBER FUNCTION del (sub IN OUT subscriber_type) RETURN subscriber_type AS
BEGIN
 IF sub.pcrf_esn IS NOT NULL THEN
  UPDATE x_subscriber_spr spr
  SET    pcrf_base_ttl          = NVL(sub.pcrf_base_ttl,SYSDATE),
         future_ttl             = NVL(sub.future_ttl,SYSDATE),
         update_timestamp       = SYSDATE,
         subscriber_status_code = 'EXP'
  WHERE  spr.pcrf_esn = sub.pcrf_esn;

  IF SQL%ROWCOUNT = 0 THEN
    sub.status := 'ESN-'||sub.pcrf_esn||' NOT FOUND. RECORD NOT DELETED';
  ELSE
    sub.status := 'SUCCESS';
  END IF;
 ELSE
    sub.status := 'ESN NOT PASSED. SUBSCRIBER TABLE NOT UPDATED';
 END IF;

  RETURN sub;
END del;

MEMBER FUNCTION get_subscriber_id RETURN VARCHAR2 AS
begin
  return pcrf_subscriber_id;
end;

MEMBER FUNCTION get_subscriber_uid ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 AS

  sub  subscriber_type := SELF;
  s    subscriber_type;

BEGIN
  IF i_esn IS NULL THEN
    sub.status := 'ESN IS A REQUIRED INPUT PARAM';
    RETURN(0);
  END IF;

  BEGIN
    SELECT pcrf_subscriber_id
    INTO   sub.pcrf_subscriber_id
    FROM   x_subscriber_spr
    WHERE  pcrf_esn = i_esn;

    RETURN ( sub.pcrf_subscriber_id);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       sub.status := 'ESN NOT FOUND IN SUBSCRIBER TABLE';
       RETURN(0);
  END;

  begin
    select part_serial_no
    into   sub.pcrf_esn
    from   table_part_inst
    where  part_serial_no = i_esn;
  exception
   when others then
     sub.status := 'ESN NOT FOUND IN PART INST';
     RETURN(0);
  end;

  -- Call add subscriber object-oriented member procedure
  s := sub.ins ( i_esn => i_esn);
  IF s.pcrf_subscriber_id IS NULL THEN
    RETURN(0);
  ELSE
    RETURN s.pcrf_subscriber_id;
  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     s.status := 'ERROR GETTING SUBSCRIBER '||SUBSTR(SQLERRM,1,100);
     RETURN(0);
END get_subscriber_uid;

MEMBER FUNCTION process_upgrade ( i_old_esn              IN VARCHAR2 ,
                                  i_new_esn              IN VARCHAR2 ,
                                  i_last_redemption_date IN DATE DEFAULT NULL,
                                  i_sourcesystem         IN VARCHAR2 DEFAULT NULL,
                                  i_order_type           IN VARCHAR2 DEFAULT NULL,
                                  i_pcrf_subscriber_id   IN VARCHAR2 DEFAULT NULL,
                                  i_pcrf_group_id        IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 IS

  old_esn_spr subscriber_type;
  new_esn_spr subscriber_type;
  new_sub     subscriber_type;
  detail      subscriber_detail_type := subscriber_detail_type();

--
FUNCTION esn_exists ( i_esn IN VARCHAR2 ) RETURN BOOLEAN IS
  n_esn_count NUMBER;
BEGIN
  SELECT COUNT(1)
  INTO   n_esn_count
  FROM   table_part_inst
  WHERE  part_serial_no = i_esn;
  IF n_esn_count > 0 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;

BEGIN
  --
  IF NOT esn_exists(i_old_esn) OR NOT esn_exists(i_new_esn) THEN
    RETURN 'ESN NOT FOUND';
  END IF;

  -- get the spr row for the old esn
  old_esn_spr := subscriber_type ( i_esn => i_old_esn );

  -- get the spr row for the new esn
  new_esn_spr := subscriber_type ( i_esn => i_new_esn );

  -- If the NEW upgraded ESN already exists in SPR
  IF new_esn_spr.exist THEN
    -- Delete the spr
    DELETE x_subscriber_spr_detail
    WHERE  subscriber_spr_objid IN ( SELECT objid
                                     FROM   x_subscriber_spr
                                     WHERE  pcrf_esn = new_esn_spr.pcrf_esn );
    -- delete spr row by esn
    DELETE x_subscriber_spr WHERE pcrf_esn = new_esn_spr.pcrf_esn;

  END IF;

  --if old esn not exists in SPR, insert SPR with new esn
  IF NOT old_esn_spr.exist THEN
     --
     new_sub := new_esn_spr.ins;
     RETURN ('SUCCESS');

  END IF;

  --
  new_sub := new_esn_spr.retrieve ( i_ignore_tw_logic_flag => 'Y' );

  -- Replace the OLD ESN with the NEW upgraded ESN in SPR
  UPDATE x_subscriber_spr
  SET    pcrf_esn                  = new_esn_spr.pcrf_esn,
         pcrf_subscriber_id        = NVL(i_pcrf_subscriber_id, pcrf_subscriber_id),
         pcrf_group_id             = NVL(i_pcrf_group_id, pcrf_group_id),
         pcrf_parent_name          = new_sub.pcrf_parent_name,
         pcrf_cos                  = new_sub.pcrf_cos,
         pcrf_base_ttl             = NVL(sa.util_pkg.get_expire_dt ( i_esn => new_esn_spr.pcrf_esn ), pcrf_base_ttl ),
         pcrf_last_redemption_date = NVL(i_last_redemption_date, sa.util_pkg.get_last_base_red_date ( i_esn => new_esn_spr.pcrf_esn)),
         brand                     = new_sub.brand,
         phone_manufacturer        = new_sub.phone_manufacturer,
         phone_model               = new_sub.phone_model,
         dealer_id                 = new_sub.dealer_id,
         rate_plan                 = new_sub.rate_plan,
         future_ttl                = new_sub.future_ttl,
         meter_source_voice        = new_sub.meter_source_voice,
         meter_source_sms          = new_sub.meter_source_sms,
         meter_source_data         = new_sub.meter_source_data,
         meter_source_ild          = new_sub.meter_source_ild,
	       service_plan_type         = new_sub.service_plan_type,
         service_plan_id           = new_sub.service_plan_id,
         content_delivery_format   = new_sub.content_delivery_format,  --CR 47880
         update_timestamp          = SYSDATE,
         rcs_enable_flag           = new_sub.rcs_enable_flag,
         part_inst_status          = ( CASE
                                         WHEN ( SELECT part_status
                                                FROM   ( SELECT part_status
                                                         FROM   table_site_part
                                                         WHERE  x_service_id = new_esn_spr.pcrf_esn
                                                         ORDER BY update_stamp DESC
                                                       )
                                                WHERE  ROWNUM = 1
                                              ) = 'Active' THEN 'Active'
                                         ELSE 'Inactive'
                                       END )
  WHERE  pcrf_esn = old_esn_spr.pcrf_esn;

  -- spr detail
  IF NOT detail.ins ( i_esn => new_esn_spr.pcrf_esn, o_result => detail.status ) THEN
     new_esn_spr.status :=  'ERROR INSERTING ADD ONS: ' || detail.status;
  END IF;

  --
  RETURN ('SUCCESS');

 EXCEPTION
   WHEN others THEN
     RETURN(SUBSTR(SQLERRM,1,100));
END process_upgrade;


MEMBER FUNCTION delAddOn( ao_offer_id IN VARCHAR2, o_result OUT VARCHAR2 ) RETURN BOOLEAN IS
 res boolean;
begin
    o_result := 'OFFER ID NOT FOUND';
    for cnt in 1..self.addOns.count
    loop
       null;
       if ( self.addOns(cnt).getOfferId  = ao_offer_id) then
            res := self.addOns(cnt).del;
            o_result := self.addOns(cnt).getStatus;
       end if;
    end loop;
return res;
end delAddOn;

-- to expire addons
MEMBER FUNCTION expireAddOns(ao_offer_id in   VARCHAR2 default 'ALL',
                             o_result    out  VARCHAR2) return boolean IS
  res boolean;
 BEGIN
   --
   o_result := 'OFFER ID NOT FOUND';
   --
   FOR cnt in 1..self.addOns.count loop
     --
     IF ( ao_offer_id = 'ALL' or self.addOns(cnt).getOfferId  = ao_offer_id )
     THEN
        -- to get the active addons from group benefit
        FOR i in ( select agb.objid,rc.x_red_date
                   FROM   x_account_group_member agm,
                          x_account_group_benefit agb,
                          table_x_red_card rc,
                          sa.service_plan_feat_pivot_mv spp
                   WHERE  agm.esn       = self.pcrf_esn
                   AND    rc.x_red_date = self.addons(cnt).add_on_redemption_date
                   AND    agm.account_group_id = agb.account_group_id
                   AND    agb.call_trans_id    = rc.red_card2call_trans
                   AND    agb.service_plan_id  = spp.service_plan_objid
                   AND    spp.cos  = self.addons(cnt).add_on_offer_id
                   AND    (agb.end_date > sysdate OR (nvl(spp.IGNORE_IG_FLAG,'N') = 'Y' and agb.end_date >= trunc (self.pcrf_base_ttl)) -- CR48780
				           OR  (agb.status = 'EXPIRED'
							AND  EXISTS (SELECT 1      --group plans changes starts as part of CR48816
							               FROM sa.x_subscriber_spr_detail
										  WHERE add_on_redemption_date = self.addons(cnt).add_on_redemption_date
										    AND subscriber_spr_objid   = self.addons(cnt).subscriber_spr_objid
											AND add_on_offer_id        = self.addons(cnt).add_on_offer_id
										)
								) --changes ends as part of CR48816
						  )
                   AND    EXISTS ( SELECT 1
                                   FROM   table_x_call_trans
                                   WHERE  objid = agb.call_trans_id)

                 )
        LOOP
            -- expiring the addons in group benefit
            update x_account_group_benefit
            set    status = 'EXPIRED',
                   reason = 'EXPIRED FROM Throttling Event',
                   end_date = sysdate
            where  objid = i.objid
            and    status = 'ACTIVE';

            -- delete the addon detail in spr detail
            res      := self.addOns(cnt).del;
            --
            o_result := self.addOns(cnt).getStatus;

        END LOOP;
     END IF;
   END LOOP;
  RETURN res;
END expireAddOns;

MEMBER FUNCTION save ( sub subscriber_type ) RETURN VARCHAR2 IS

BEGIN

  IF sub.pcrf_esn IS NULL THEN
    RETURN 'ESN IS EMPTY - NOT SAVING THE RECORD';
  END IF;

  IF sub.pcrf_min IS NULL THEN
    RETURN 'MIN IS EMPTY - NOT SAVING THE RECORD';
  END IF;

  IF sub.pcrf_mdn IS NULL THEN
    RETURN 'MDN IS EMPTY - NOT SAVING THE RECORD';
  END IF;

  IF sub.pcrf_subscriber_id IS NULL THEN
    RETURN 'SUBSCRIBER ID IS EMPTY - NOT SAVING THE RECORD';
  END IF;

  BEGIN
    MERGE
    INTO   sa.x_subscriber_spr s
    USING  dual
    ON     ( s.pcrf_esn = sub.pcrf_esn)
    WHEN MATCHED THEN
      UPDATE
      SET    s.pcrf_min                   = sub.pcrf_min                   ,
             s.pcrf_mdn                   = sub.pcrf_mdn                   ,
             s.pcrf_subscriber_id         = sub.pcrf_subscriber_id         ,
             s.pcrf_group_id              = sub.pcrf_group_id              ,
             s.pcrf_parent_name           = sub.pcrf_parent_name           ,
             s.service_plan_id            = sub.service_plan_id            ,
             s.pcrf_cos                   = sub.pcrf_cos                   ,
             s.pcrf_base_ttl              = sub.pcrf_base_ttl              ,
             s.future_ttl                 = sub.future_ttl                 ,
             s.pcrf_last_redemption_date  = sub.pcrf_last_redemption_date  ,
             s.brand                      = sub.brand                      ,
             s.phone_manufacturer         = sub.phone_manufacturer         ,
             s.phone_model                = sub.phone_model                ,
             s.content_delivery_format    = sub.content_delivery_format    ,
             s.denomination               = sub.denomination               ,
             s.conversion_factor          = sub.conversion_factor          ,
             s.dealer_id                  = sub.dealer_id                  ,
             s.rate_plan                  = sub.rate_plan                  ,
             s.propagate_flag             = sub.propagate_flag             ,
             s.pcrf_transaction_id        = sub.pcrf_transaction_id        ,
             s.service_plan_type          = sub.service_plan_type          ,
             s.queued_days                = sub.queued_days                ,
             s.language                   = sub.language                   ,
             s.contact_objid              = sub.contact_objid              ,
             s.bus_org_objid              = sub.bus_org_objid              ,
             s.web_user_objid             = sub.web_user_objid             ,
             s.part_inst_status           = sub.part_inst_status           ,
             s.wf_mac_id                  = sub.wf_mac_id                  ,
             s.expired_usage_date         = sub.expired_usage_date         ,
             s.zipcode                    = sub.zipcode                    ,
             s.curr_throttle_policy_id    = sub.curr_throttle_policy_id    ,
             s.curr_throttle_eff_date     = sub.curr_throttle_eff_date     ,
             s.subscriber_status_code     = sub.subscriber_status          ,
             s.meter_source_voice         = sub.meter_source_voice         ,
             s.meter_source_sms           = sub.meter_source_sms           ,
             s.meter_source_data          = sub.meter_source_data          ,
             s.meter_source_ild           = sub.meter_source_ild           ,
             s.imsi                       = sub.imsi                       ,
             -- CR43143 Add New Fields to SPR
             s.lifeline_id                = sub.lifeline_id                ,
             s.install_date               = sub.install_date               ,
             s.program_parameter_id       = sub.program_parameter_id       ,
             s.vmbc_certification_flag    = sub.vmbc_certification_flag    ,
             s.char_field_1               = sub.char_field_1               ,
             s.char_field_2               = sub.char_field_2               ,
             s.char_field_3               = sub.char_field_3               ,
             s.date_field_1               = sub.date_field_1               ,
             s.rcs_enable_flag            = sub.rcs_enable_flag
   WHEN NOT MATCHED THEN
      INSERT ( objid                      ,
               pcrf_min                   ,
               pcrf_mdn                   ,
               pcrf_esn                   ,
               pcrf_subscriber_id         ,
               pcrf_group_id              ,
               pcrf_parent_name           ,
               service_plan_id            ,
               pcrf_cos                   ,
               pcrf_base_ttl              ,
               future_ttl                 ,
               pcrf_last_redemption_date  ,
               brand                      ,
               phone_manufacturer         ,
               phone_model                ,
               content_delivery_format    ,
               denomination               ,
               conversion_factor          ,
               dealer_id                  ,
               rate_plan                  ,
               propagate_flag             ,
               pcrf_transaction_id        ,
               service_plan_type          ,
               queued_days                ,
               language                   ,
               bus_org_objid              ,
               contact_objid              ,
               web_user_objid             ,
               part_inst_status           ,
               wf_mac_id                  ,
               expired_usage_date         ,
               subscriber_status_code     ,
               zipcode                    ,
               curr_throttle_policy_id    ,
               curr_throttle_eff_date     ,
               insert_timestamp           ,
               update_timestamp           ,
               meter_source_voice         ,
               meter_source_sms           ,
               meter_source_data          ,
               meter_source_ild           ,
               imsi                       ,
               -- CR43143 Add New Fields to SPR
               lifeline_id                ,
               install_date               ,
               program_parameter_id       ,
               vmbc_certification_flag    ,
               char_field_1               ,
               char_field_2               ,
               char_field_3               ,
               date_field_1               ,
               rcs_enable_flag
              )
        VALUES
        ( sequ_subscriber_spr.NEXTVAL    ,
          sub.pcrf_min                   ,
          sub.pcrf_mdn                   ,
          sub.pcrf_esn                   ,
          sub.pcrf_subscriber_id         ,
          sub.pcrf_group_id              ,
          sub.pcrf_parent_name           ,
          sub.service_plan_id            ,
          sub.pcrf_cos                   ,
          sub.pcrf_base_ttl              ,
          sub.future_ttl                 ,
          sub.pcrf_last_redemption_date  ,
          sub.brand                      ,
          sub.phone_manufacturer         ,
          sub.phone_model                ,
          sub.content_delivery_format    ,
          sub.denomination               ,
          sub.conversion_factor          ,
          sub.dealer_id                  ,
          sub.rate_plan                  ,
          sub.propagate_flag             ,
          sub.pcrf_transaction_id        ,
          sub.service_plan_type          ,
          sub.queued_days                ,
          sub.language                   ,
          sub.bus_org_objid              ,
          sub.contact_objid              ,
          sub.web_user_objid             ,
          sub.part_inst_status           ,
          sub.wf_mac_id                  ,
          sub.expired_usage_date         ,
          sub.subscriber_status          , -- subscriber_status_code set to ACTIVE
          sub.zipcode                    ,
          sub.curr_throttle_policy_id    ,
          sub.curr_throttle_eff_date     ,
          SYSDATE                        ,
          SYSDATE                        ,
          sub.meter_source_voice         ,
          sub.meter_source_sms           ,
          sub.meter_source_data          ,
          sub.meter_source_ild           ,
          sub.imsi                       ,
          -- CR43143 Add New Fields to SPR
          sub.lifeline_id                ,
          sub.install_date               ,
          sub.program_parameter_id       ,
          sub.vmbc_certification_flag    ,
          sub.char_field_1               ,
          sub.char_field_2               ,
          sub.char_field_3               ,
          sub.date_field_1               ,
          sub.rcs_enable_flag
        );
   EXCEPTION
     WHEN dup_val_on_index THEN
      MERGE
      INTO   sa.x_subscriber_spr s
      USING  dual
      ON     ( s.pcrf_min = sub.pcrf_min)
      WHEN MATCHED THEN
        UPDATE
        SET    s.pcrf_esn                   = sub.pcrf_esn                   ,
               s.pcrf_subscriber_id         = sub.pcrf_subscriber_id         ,
               s.pcrf_group_id              = sub.pcrf_group_id              ,
               s.pcrf_parent_name           = sub.pcrf_parent_name           ,
               s.service_plan_id            = sub.service_plan_id            ,
               s.pcrf_cos                   = sub.pcrf_cos                   ,
               s.pcrf_base_ttl              = sub.pcrf_base_ttl              ,
               s.future_ttl                 = sub.future_ttl                 ,
               s.pcrf_last_redemption_date  = sub.pcrf_last_redemption_date  ,
               s.brand                      = sub.brand                      ,
               s.phone_manufacturer         = sub.phone_manufacturer         ,
               s.phone_model                = sub.phone_model                ,
               s.content_delivery_format    = sub.content_delivery_format    ,
               s.denomination               = sub.denomination               ,
               s.conversion_factor          = sub.conversion_factor          ,
               s.dealer_id                  = sub.dealer_id                  ,
               s.rate_plan                  = sub.rate_plan                  ,
               s.propagate_flag             = sub.propagate_flag             ,
               s.pcrf_transaction_id        = sub.pcrf_transaction_id        ,
               s.service_plan_type          = sub.service_plan_type          ,
               s.queued_days                = sub.queued_days                ,
               s.language                   = sub.language                   ,
               s.contact_objid              = sub.contact_objid              ,
               s.bus_org_objid              = sub.bus_org_objid              ,
               s.web_user_objid             = sub.web_user_objid             ,
               s.part_inst_status           = sub.part_inst_status           ,
               s.wf_mac_id                  = sub.wf_mac_id                  ,
               s.expired_usage_date         = sub.expired_usage_date         ,
               s.zipcode                    = sub.zipcode                    ,
               s.curr_throttle_policy_id    = sub.curr_throttle_policy_id    ,
               s.curr_throttle_eff_date     = sub.curr_throttle_eff_date     ,
               s.subscriber_status_code     = sub.subscriber_status          ,
               s.meter_source_voice         = sub.meter_source_voice         ,
               s.meter_source_sms           = sub.meter_source_sms           ,
               s.meter_source_data          = sub.meter_source_data          ,
               s.meter_source_ild           = sub.meter_source_ild           ,
               s.imsi                       = sub.imsi                       ,
               -- CR43143 Add New Fields to SPR
               s.lifeline_id                = sub.lifeline_id                ,
               s.install_date               = sub.install_date               ,
               s.program_parameter_id       = sub.program_parameter_id       ,
               s.vmbc_certification_flag    = sub.vmbc_certification_flag    ,
               s.char_field_1               = sub.char_field_1               ,
               s.char_field_2               = sub.char_field_2               ,
               s.char_field_3               = sub.char_field_3               ,
               s.date_field_1               = sub.date_field_1               ,
               s.rcs_enable_flag            = sub.rcs_enable_flag
      WHEN NOT MATCHED THEN
        INSERT ( objid                      ,
                 pcrf_min                   ,
                 pcrf_mdn                   ,
                 pcrf_esn                   ,
                 pcrf_subscriber_id         ,
                 pcrf_group_id              ,
                 pcrf_parent_name           ,
                 service_plan_id            ,
                 pcrf_cos                   ,
                 pcrf_base_ttl              ,
                 future_ttl                 ,
                 pcrf_last_redemption_date  ,
                 brand                      ,
                 phone_manufacturer         ,
                 phone_model                ,
                 content_delivery_format    ,
                 denomination               ,
                 conversion_factor          ,
                 dealer_id                  ,
                 rate_plan                  ,
                 propagate_flag             ,
                 pcrf_transaction_id        ,
                 service_plan_type          ,
                 queued_days                ,
                 language                   ,
                 bus_org_objid              ,
                 contact_objid              ,
                 web_user_objid             ,
                 part_inst_status           ,
                 wf_mac_id                  ,
                 expired_usage_date         ,
                 subscriber_status_code     ,
                 zipcode                    ,
                 curr_throttle_policy_id    ,
                 curr_throttle_eff_date     ,
                 insert_timestamp           ,
                 update_timestamp           ,
                 meter_source_voice         ,
                 meter_source_sms           ,
                 meter_source_data          ,
                 meter_source_ild           ,
                 imsi                       ,
                 -- CR43143 Add New Fields to SPR
                 lifeline_id                ,
                 install_date               ,
                 program_parameter_id       ,
                 vmbc_certification_flag    ,
                 char_field_1               ,
                 char_field_2               ,
                 char_field_3               ,
                 date_field_1               ,
                 rcs_enable_flag
                )
          VALUES
          ( sequ_subscriber_spr.NEXTVAL    ,
            sub.pcrf_min                   ,
            sub.pcrf_mdn                   ,
            sub.pcrf_esn                   ,
            sub.pcrf_subscriber_id         ,
            sub.pcrf_group_id              ,
            sub.pcrf_parent_name           ,
            sub.service_plan_id            ,
            sub.pcrf_cos                   ,
            sub.pcrf_base_ttl              ,
            sub.future_ttl                 ,
            sub.pcrf_last_redemption_date  ,
            sub.brand                      ,
            sub.phone_manufacturer         ,
            sub.phone_model                ,
            sub.content_delivery_format    ,
            sub.denomination               ,
            sub.conversion_factor          ,
            sub.dealer_id                  ,
            sub.rate_plan                  ,
            sub.propagate_flag             ,
            sub.pcrf_transaction_id        ,
            sub.service_plan_type          ,
            sub.queued_days                ,
            sub.language                   ,
            sub.bus_org_objid              ,
            sub.contact_objid              ,
            sub.web_user_objid             ,
            sub.part_inst_status           ,
            sub.wf_mac_id                  ,
            sub.expired_usage_date         ,
            sub.subscriber_status          , -- subscriber_status_code set to ACTIVE
            sub.zipcode                    ,
            sub.curr_throttle_policy_id    ,
            sub.curr_throttle_eff_date     ,
            SYSDATE                        ,
            SYSDATE                        ,
            sub.meter_source_voice         ,
            sub.meter_source_sms           ,
            sub.meter_source_data          ,
            sub.meter_source_ild           ,
            sub.imsi                       ,
            -- CR43143 Add New Fields to SPR
            sub.lifeline_id                ,
            sub.install_date               ,
            sub.program_parameter_id       ,
            sub.vmbc_certification_flag    ,
            sub.char_field_1               ,
            sub.char_field_2               ,
            sub.char_field_3               ,
            sub.date_field_1               ,
            sub.rcs_enable_flag
          );

  END;

  RETURN('SUCCESS');

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 'ERROR SAVING SUBSCRIBER RECORD: ' || SQLERRM;
     --
END save;

MEMBER FUNCTION retrieve (i_ignore_tw_logic_flag IN VARCHAR2 DEFAULT 'N') RETURN subscriber_type IS

  sub                          subscriber_type := SELF;
  s                            subscriber_type := SELF;
  m                            subscriber_type := SELF;
  detail                       subscriber_detail_type := subscriber_detail_type();
  n_pi_esn_objid               NUMBER;
  n_site_part_objid            NUMBER;
  n_err_code                   NUMBER;
  c_err_msg                    VARCHAR2(1000);
  n_account_group_objid        NUMBER;
  n_account_group_member_objid NUMBER;
  n_denomination               NUMBER;
  c_service_plan_group         VARCHAR2(100);

BEGIN
  -- Reset sub with an empty object
  sub := subscriber_type ();

  sub.pcrf_esn := s.pcrf_esn;

  --
  IF sub.pcrf_esn IS NULL THEN
    sub.status := 'NO ESN PASSED';
    RETURN sub;
  END IF;

  sub.subscriber_status := 'ACT';

  -- get the rate plan
  sub.rate_plan      := sa.util_pkg.get_esn_rate_plan ( i_esn => sub.pcrf_esn);

  -- function to get the propagate_flag
  sub.propagate_flag := sa.util_pkg.get_propagate_flag ( ip_esn       => sub.pcrf_esn,
                                                         ip_rate_plan => sub.rate_plan);

  -- Display a message when the ESN is non-data capable
  IF sub.propagate_flag < 0 THEN
    sub.status := 'ESN DOES NOT HAVE DATA CAPABILITY';
  END IF;

  -- Assign the base ttl from table_site_part
  sub.pcrf_base_ttl := sa.util_pkg.get_expire_dt ( i_esn => sub.pcrf_esn);

  -- Assign the future ttl the same value of the base ttl (until the queued days are calculated further with the queued days when applicable)
  sub.future_ttl := sub.pcrf_base_ttl;

  -- get the last redemption date
  sub.pcrf_last_redemption_date := sa.util_pkg.get_last_base_red_date ( i_esn => sub.pcrf_esn );


   -- Get the dealer, brand and other features
  BEGIN
    SELECT bin_name dealer_id,
           pcpv.bus_org bus_org_id,
           pcpv.firmware content_delivery_format,
           pcpv.motricity_denomination denomination,
           pn.x_manufacturer phone_manufacturer,
           pcpv.part_class phone_model,
           pn.part_num2bus_org bus_org_objid,
           pcpv.technology,
           pcpv.part_class part_class_name,
           pcpv.device_type
    INTO   sub.dealer_id,
           sub.brand,
           sub.content_delivery_format,
           sub.denomination,
           sub.phone_manufacturer,
           sub.phone_model,
           sub.bus_org_objid,
           sub.technology,
           sub.part_class_name,
           sub.device_type
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           table_inv_bin inv,
           pcpv_mv pcpv
    WHERE  1 = 1
    AND    pi.part_serial_no = sub.pcrf_esn
    AND    pi.x_domain = 'PHONES'
    and    pi.part_inst2inv_bin = inv.objid
    AND    pi.n_part_inst2part_mod = ml.objid
    AND    ml.part_info2part_num = pn.objid
    AND    pn.domain = 'PHONES'
    AND    pn.part_num2part_class = pcpv.pc_objid;
   EXCEPTION
    WHEN others THEN
      sub.status := sub.status || '|DEALER NOT FOUND';
      BEGIN
        SELECT bo.org_id bus_org_id,
               pn.x_manufacturer phone_manufacturer,
               pn.part_num2bus_org bus_org_objid
        INTO   sub.brand,
               sub.phone_manufacturer,
               sub.bus_org_objid
        FROM   table_part_inst pi,
               table_mod_level ml,
               table_part_num pn,
               table_bus_org bo
        WHERE  1 = 1
        AND    pi.part_serial_no = sub.pcrf_esn
        AND    pi.x_domain = 'PHONES'
        AND    pi.n_part_inst2part_mod = ml.objid
        AND    ml.part_info2part_num = pn.objid
        AND    pn.domain = 'PHONES'
        AND    pn.part_num2bus_org = bo.objid;
       EXCEPTION
         WHEN others THEN
           sub.status := sub.status || '|BRAND NOT FOUND';
      END;
  END;

  --CR44881 added to default dealer id to "0" if dealer id is alphanumeric
  if regexp_like(sub.dealer_id,'[^0-9]+')  then
   sub.dealer_id := '0';
  end if;

  -- Get the min, carrier parent and wf_mac_id
  BEGIN
    SELECT pi_min.part_serial_no min,
           pi_min.part_serial_no mdn,
           pi_esn.objid pi_esn_objid,
           p.x_parent_name parent_name,
           pi_esn.x_wf_mac_id wf_mac_id,
           c.objid carrier_objid
    INTO   sub.pcrf_min,
           sub.pcrf_mdn,
           n_pi_esn_objid,
           sub.pcrf_parent_name,
           sub.wf_mac_id,
           sub.carrier_objid
    FROM   table_part_inst pi_esn,
           table_part_inst pi_min,
           table_x_parent p,
           table_x_carrier_group cg,
           table_x_carrier c
    WHERE  pi_esn.part_serial_no = sub.pcrf_esn
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_min.part_to_esn2part_inst = pi_esn.objid
    AND    pi_min.x_domain = 'LINES'
    AND    pi_min.part_inst2carrier_mkt = c.objid
    AND    c.carrier2carrier_group = cg.objid
    AND    cg.x_carrier_group2x_parent = p.objid;
   EXCEPTION
     WHEN too_many_rows THEN
       sub.status := sub.status || '|DUPLICATE ESN FOUND';
       RETURN sub;
     WHEN others THEN
       sub.status := sub.status || '|ESN NOT FOUND';
      dbms_output.put_line(SQLERRM);
       RETURN sub;
  END;



  IF sub.pcrf_min IS NULL THEN
    sub.status := 'MIN NOT FOUND';
    RETURN sub;
  END IF;

  -- Get the web user and contact (Active site part status)
  BEGIN
    SELECT sp.x_zipcode zipcode,
           sp.objid site_part_objid,
           sp.part_status,
           sp.x_iccid
    INTO   sub.zipcode,
           n_site_part_objid,
           sub.part_inst_status,
           sub.iccid
    FROM   table_part_inst pi,
           table_site_part sp
    WHERE  1 = 1
    AND    pi.part_serial_no = sub.pcrf_esn
    AND    pi.x_domain = 'PHONES'
    AND    pi.part_serial_no = sp.x_service_id
    AND    sp.part_status = 'Active';
   EXCEPTION
     WHEN no_data_found THEN
       -- Consider the customer as active when the TTL is in the future
       BEGIN
         SELECT sp.x_zipcode zipcode,
                sp.objid site_part_objid,
                'Active' part_status,
                sp.x_iccid
         INTO   sub.zipcode,
                n_site_part_objid,
                sub.part_inst_status,
                sub.iccid
         FROM   table_part_inst pi,
                table_site_part sp
         WHERE  1 = 1
         AND    pi.part_serial_no = sub.pcrf_esn
         AND    pi.x_domain = 'PHONES'
         AND    pi.part_serial_no = sp.x_service_id
         AND    sp.part_status = 'CarrierPending'
         AND    sp.x_expire_dt > TRUNC(SYSDATE);
        EXCEPTION
          WHEN others THEN
            sub.status := sub.status || '|STATUS, ZIPCODE NOT FOUND';
            RETURN sub;
       END;
     WHEN too_many_rows THEN
       BEGIN
         SELECT sp.x_zipcode zipcode,
                sp.objid site_part_objid,
                sp.part_status,
                sp.x_iccid
         INTO   sub.zipcode,
                n_site_part_objid,
                sub.part_inst_status,
                sub.iccid
         FROM   table_part_inst pi,
                table_site_part sp
         WHERE  1 = 1
         AND    pi.part_serial_no = sub.pcrf_esn
         AND    pi.x_domain = 'PHONES'
         AND    pi.part_serial_no = sp.x_service_id
         AND    sp.part_status = 'Active'
         AND    sp.objid = ( SELECT MAX(objid)
                             FROM   table_site_part
                             WHERE  x_service_id = sp.x_service_id
                             AND    part_status = 'Active'
                           );
        EXCEPTION
          WHEN no_data_found THEN
            sub.status := sub.status || '|STATUS, ZIPCODE NOT FOUND';
            RETURN sub;
          WHEN others THEN
            sub.status := sub.status || '|STATUS, ZIPCODE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
            RETURN sub;
       END;
     WHEN others THEN
       sub.status := sub.status || '|STATUS, ZIPCODE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN sub;
  END;

  -- Get the web user and contact
  BEGIN
    SELECT wu.objid web_user_objid,
           wu.web_user2contact contact_objid
    INTO   sub.web_user_objid,
           sub.contact_objid
    FROM   table_x_contact_part_inst cpi,
           table_web_user wu
    WHERE  1 = 1
    AND    cpi.x_contact_part_inst2part_inst = n_pi_esn_objid
    AND    wu.web_user2contact = cpi.x_contact_part_inst2contact;
   EXCEPTION
     WHEN no_data_found THEN
       sub.status := sub.status || '|WEB USER NOT FOUND';
       BEGIN
         SELECT x_part_inst2contact
         INTO   sub.contact_objid
         from   table_part_inst
         where  part_serial_no = sub.pcrf_esn;
        EXCEPTION
          WHEN others THEN
            sub.status := sub.status || '|CONTACT NOT FOUND';
       END;
     WHEN too_many_rows THEN
       sub.status := sub.status || '|DUPLICATE WEB USER';
       BEGIN
         SELECT x_part_inst2contact
         INTO   sub.contact_objid
         from   table_part_inst
         where  part_serial_no = sub.pcrf_esn;
        EXCEPTION
          WHEN others THEN
            sub.status := sub.status || '|CONTACT NOT FOUND';
       END;
     WHEN OTHERS THEN
       sub.status := sub.status || '|WEB USER NOT FOUND: '|| SUBSTR(SQLERRM,1,100);
       BEGIN
         SELECT x_part_inst2contact
         INTO   sub.contact_objid
         from   table_part_inst
         where  part_serial_no = sub.pcrf_esn;
        EXCEPTION
          WHEN others THEN
            sub.status := sub.status || '|CONTACT NOT FOUND';
       END;
  END;

  --
  IF n_site_part_objid IS NOT NULL THEN
    -- Get the service plan and cos
    BEGIN
      SELECT spsp.x_service_plan_id,
             fea.mkt_name service_plan_type,
             fea.service_plan_group
      INTO   sub.service_plan_id,
             sub.service_plan_type,
             c_service_plan_group
      FROM   x_service_plan_site_part spsp,
             sa.service_plan_feat_pivot_mv fea
      WHERE  spsp.table_site_part_id = n_site_part_objid
      AND    spsp.x_service_plan_id = fea.service_plan_objid;
     EXCEPTION
      WHEN too_many_rows THEN
        sub.status := sub.status || '|DUPLICATE SERVICE PLAN, COS';
      WHEN OTHERS THEN
        sub.status := sub.status || '|SERVICE PLAN, COS NOT FOUND';
    END;

    -- Get the cos value from the rule engine
    sub.pcrf_cos := get_cos ( i_esn => sub.pcrf_esn );

  ELSE
    sub.status := sub.status || '|SERVICE PLAN, COS NOT FOUND';
  END IF;

  -- CR47564 WFM Commented out below code and replace with member function call
  sub.queued_days := sub.get_esn_pin_redeem_days(i_esn => sub.pcrf_esn );

--  BEGIN
--    SELECT NVL(SUM( NVL(x_redeem_days,0) ),0) queued_days
--    INTO   sub.queued_days
--    FROM   table_part_inst cards,
--           table_mod_level ml,
--           table_part_num  pn
--    WHERE  cards.part_to_esn2part_inst = n_pi_esn_objid
--    AND    cards.x_part_inst_status = '400'
--    AND    cards.x_domain = 'REDEMPTION CARDS'
--    AND    cards.n_part_inst2part_mod = ml.objid
--    AND    ml.part_info2part_num = pn.objid;
--   EXCEPTION
--    WHEN OTHERS THEN
--      sub.queued_days := 0;
--  END;

  sub.future_ttl := sub.pcrf_base_ttl + NVL(sub.queued_days,0);

  IF sub.service_plan_id IS NULL AND sub.brand IN ('TRACFONE','NET10') THEN
    sub.service_plan_id := 0;
    sub.service_plan_type := 'NA';
    sub.pcrf_cos := 'DEFAULT';
  END IF;

  -- get denomination
  IF n_pi_esn_objid IS NOT NULL THEN
    BEGIN
      SELECT x_motricity_deno,
             x_current_conv_rate
      INTO   n_denomination,
             sub.conversion_factor
      FROM   sa.table_x_ota_features
      WHERE  x_ota_features2part_inst = n_pi_esn_objid;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
  END IF;

  -- Reassign denomination same as the original inquiry
  IF n_denomination IS NOT NULL THEN
    sub.denomination := TO_CHAR(n_denomination);
  END IF;

  -- Assign variables
  sub.conversion_factor := sa.util_pkg.get_ota_current_conv_rate ( i_part_inst_objid => n_pi_esn_objid )        ;
  sub.language          := 'ENGLISH';

  -- Determine if the customer is throttled and retrieve the throttling policy information
  BEGIN
    SELECT x_policy_id,
           x_creation_date
    INTO   sub.curr_throttle_policy_id,
           sub.curr_throttle_eff_date
    FROM   w3ci.table_x_throttling_cache
    WHERE  x_esn = sub.pcrf_esn
    AND    x_min = sub.pcrf_min
    AND    x_status IN ('A','P')
    AND    ROWNUM = 1; -- There are some throttled subscribers with more than one entry in the cache
   EXCEPTION
    WHEN others THEN
      -- Continue the process when this value was not found
      NULL;
  END;

  -- Get enrollment details for an ESN
  BEGIN
    SELECT enrolled_autorefill_flag
    INTO   sub.enrolled_autorefill_flag
    FROM   ( SELECT 1 enrolled_autorefill_flag
             FROM   x_program_enrolled enr
             WHERE  enr.x_esn = sub.pcrf_esn
             AND    x_enrollment_status IN ('ENROLLED','ENROLLMENTPENDING')
             AND    x_next_charge_date > SYSDATE
             UNION ALL
             SELECT 1 enrolled_autorefill_flag
             FROM   x_program_enrolled enr,
                    x_program_parameters pp
             WHERE  enr.x_esn = sub.pcrf_esn
             AND    x_enrollment_status = 'ENROLLED_NO_ACCOUNT'
             AND    x_next_charge_date > SYSDATE
             AND    enr.pgm_enroll2pgm_parameter = pp.objid
             AND    pp.x_prog_class||'' = 'WARRANTY'
           )
    WHERE  ROWNUM = 1;
   EXCEPTION
     WHEN OTHERS THEN
       sub.enrolled_autorefill_flag := 0;
  END;

  -- call new create member function
 n_account_group_member_objid := create_member (  i_esn                => sub.pcrf_esn           ,
                                                  i_web_user_objid     => sub.web_user_objid     ,
                                                  i_service_plan_id    => sub.service_plan_id    ,
                                                  i_bus_org_objid      => sub.bus_org_objid      ,
                                                  i_group_status       => 'ACTIVE'               ,
                                                  i_member_status      => 'ACTIVE'               ,
                                                  i_force_create_flag  => 'N'                    ,
                                                  i_retrieve_only_flag => i_ignore_tw_logic_flag ,
                                                  o_account_group_uid  => sub.pcrf_group_id      ,
                                                  o_account_group_id   => n_account_group_objid  ,
                                                  o_subscriber_uid     => sub.pcrf_subscriber_id ,
                                                  o_err_code           => n_err_code             ,
                                                  o_err_msg            => c_err_msg              );

  -- Getting imsi from last IG
  BEGIN
    SELECT /*+ use_invisible_indexes */ imsi
    INTO  sub.imsi
    FROM  gw1.ig_transaction
    WHERE esn = sub.pcrf_esn
    AND   status = 'S'
    AND   transaction_id = ( SELECT /*+ use_invisible_indexes */ MAX(transaction_id)
                             FROM   gw1.ig_transaction
                             WHERE  esn = sub.pcrf_esn
                             AND    status = 'S');
   EXCEPTION
    WHEN OTHERS THEN
      sub.imsi := NULL;
  END;

  -- Getting imsi from inventory
  IF sub.imsi IS NULL THEN
    BEGIN
      SELECT s.x_sim_imsi
      INTO   sub.imsi
      FROM   sa.table_part_inst m ,
             sa.table_part_inst e ,
             sa.table_x_sim_inv s
      WHERE  e.part_serial_no = sub.pcrf_esn
      AND    e.objid = m.part_to_esn2part_inst
      AND    s.x_sim_serial_no = e.x_iccid
      AND    e.x_part_inst_status = '52'
      AND    m.x_part_inst_status = '13'
      AND    e.x_iccid is NOT NULL
      AND    ROWNUM  = 1;
     EXCEPTION
       WHEN OTHERS THEN
         sub.imsi := NULL;
    END;
  END IF;

  --
  -- CR40903_My_Account_App_Data_Balance_Inquiry_Update Tim 7/5/2016 added service plan group
  --

  -- get metering sources
  --CR44107 - use the function transform_device_type as below
  m := get_meter_sources ( i_device_type        => sa.Transform_device_type(sub.device_type,sub.pcrf_esn),
                           i_brand              => sub.brand,
                           i_parent_name        => sub.pcrf_parent_name,
                           i_service_plan_group => c_service_plan_group);

  sub.meter_source_voice := m.meter_source_voice ;
  sub.meter_source_sms   := m.meter_source_sms   ;
  sub.meter_source_data  := m.meter_source_data  ;
  sub.meter_source_ild   := m.meter_source_ild   ;

---
-- CR43143 New SPR fields Code changes to include lifeline_id  VL 08/02/2016
---
  sub.vmbc_certification_flag := sub.get_vmbc_certification_flag(i_esn => sub.pcrf_esn);
  -- Get LIFELINE ID
  begin
    select slcur.lid
    into   sub.lifeline_id
    from   sa.x_program_enrolled pe,
           sa.x_program_parameters pgm,
           sa.x_sl_currentvals slcur
    where  pe.x_esn                =  sub.pcrf_esn
    and    pgm.objid               =  pe.pgm_enroll2pgm_parameter
    and    pgm.x_prog_class        =  'LIFELINE'
    and    pe.x_enrollment_status  =  'ENROLLED'
    and    slcur.x_current_esn     =  pe.x_esn
    and    rownum = 1;

   exception
     when others then
      sub.lifeline_id        :=  null;
  end;

    -- Get program parameter for enrolled customers
  begin
   select program_parameter_objid
   into   sub.program_parameter_id
   from (
          select enr.pgm_enroll2pgm_parameter program_parameter_objid
          from   x_program_enrolled enr
          where  enr.x_esn = sub.pcrf_esn
          and    x_enrollment_status in ('ENROLLED','ENROLLMENTSCHEDULED')
          and    x_next_charge_date > sysdate
          union all
          select enr.pgm_enroll2pgm_parameter program_parameter_objid
          from   x_program_enrolled enr,
                 x_program_parameters pp
          where  enr.x_esn = sub.pcrf_esn
          and    x_enrollment_status = 'ENROLLED_NO_ACCOUNT'
          and    x_next_charge_date > sysdate
          and    enr.pgm_enroll2pgm_parameter = pp.objid
          and    pp.x_prog_class||'' = 'WARRANTY'
          union all
          select enr.pgm_enroll2pgm_parameter program_parameter_objid
          from   x_program_enrolled enr
          where  enr.x_esn = sub.pcrf_esn
          and    sub.lifeline_id is not null
          and    x_enrollment_status in ('ENROLLED','ENROLLMENTSCHEDULED')
          and    x_next_delivery_date > sysdate
         )
   where  rownum = 1;
   exception
     when others then
      sub.program_parameter_id         :=  NULL;
  end;

  -- Get install date
  begin
   select min(install_date)
   into   sub.install_date
   from   table_site_part
   where  x_service_id = sub.pcrf_esn
   and    x_min        = sub.pcrf_min;
  exception
   when others then
     sub.install_date := null;
  end;

  begin
    -- Tim 12/13/17 CR53920_RCS_Flag_clfy_DDL
    -- Possible values Y, N, Null  Max for Y then X then Null.
    SELECT MAX(rcs_flag)
      INTO sub.rcs_enable_flag
      FROM (
            select rcs_flag
              from   sa.x_policy_mapping_config
             where  cos = sub.pcrf_cos
               and    usage_tier_id = 2
               and    rownum < 2
             UNION
            SELECT pn.rcs_capable
              FROM table_part_num pn,
                   table_mod_level ml,
                   table_part_inst pi
             WHERE pn.objid = ml.part_info2part_num
               AND ml.objid = pi.n_part_inst2part_mod
               AND pi.part_serial_no = sub.pcrf_esn
               AND    rownum < 2
            )   ;

  exception
    when others then
     sub.rcs_enable_flag := 'N';
  end;

  -- Set successful response
  sub.status := sub.status || '|' || CASE WHEN sub.status IS NULL THEN 'SUCCESS' ELSE '|SUCCESS' END;

  RETURN sub;

 EXCEPTION
   WHEN OTHERS THEN
     sub.status := 'ERROR RETRIEVING SUBSCRIBER RECORD: ' || sqlerrm;
     RETURN sub;
     --
END retrieve;

MEMBER FUNCTION refresh_dates ( i_esn IN VARCHAR2) RETURN subscriber_type IS

  sub  subscriber_type := SELF;
  s    subscriber_type;
  s1   subscriber_type := subscriber_type();
BEGIN

  IF sub.pcrf_esn IS NULL THEN
    sub.pcrf_esn := i_esn;
  END IF;

  IF NOT sub.exist THEN
    s := sub.ins;
    IF s.status LIKE '%SUCCESS%' THEN
      sub.status := 'SUCCESS';
      RETURN sub;
    ELSE
      RETURN s;
    END IF;
  END IF;

  s1.pcrf_last_redemption_date := sa.util_pkg.get_last_base_red_date ( i_esn => sub.pcrf_esn );
  s1.queued_days := NVL(sa.util_pkg.get_queued_days ( sub.pcrf_esn ),0);
  --CR43143
  s1.vmbc_certification_flag := nvl(s1.get_vmbc_certification_flag(i_esn => sub.pcrf_esn),'N');

  -- If the passing values are not instantiated read the new values from the util package
  UPDATE x_subscriber_spr
  SET    pcrf_base_ttl             = NVL(sub.pcrf_base_ttl, sa.util_pkg.get_expire_dt ( sub.pcrf_esn)),
         future_ttl                = NVL(sub.future_ttl, (sa.util_pkg.get_expire_dt ( sub.pcrf_esn) + s1.queued_days)),
         queued_days               = NVL(sub.queued_days, s1.queued_days),
         pcrf_last_redemption_date = NVL(sub.pcrf_last_redemption_date, s1.pcrf_last_redemption_date),
         --CR43143
         vmbc_certification_flag   = s1.vmbc_certification_flag,
         update_timestamp          = SYSDATE
  WHERE  pcrf_esn = sub.pcrf_esn
    RETURNING pcrf_min,
            zipcode
  INTO      sub.pcrf_min,
            sub.zipcode;

  --
  sub.status := 'SUCCESS';

  RETURN sub;

 EXCEPTION
   WHEN OTHERS THEN
     sub.status := 'ERROR UPDATING SUBSCRIBER TTL, FUTURE TTL AND REDEMPTION DATE: ' || SQLERRM;
     RETURN sub;
     --
END refresh_dates;

---
-- CR36349_PAGE_PLUS_Page_Provisioning_via_TF_account/Enable_Sure_Carrier_for_Page VLAAD 07/14/2016 Added new function UPDATE_DATES
---
MEMBER FUNCTION update_dates (sub IN OUT subscriber_type) RETURN subscriber_type AS
BEGIN
   UPDATE x_subscriber_spr spr
  SET    pcrf_base_ttl             = NVL(sub.pcrf_base_ttl, spr.pcrf_base_ttl),
         future_ttl                = NVL(sub.future_ttl, spr.future_ttl),
         queued_days               = NVL(sub.queued_days, spr.queued_days),
         pcrf_last_redemption_date = NVL(sub.pcrf_last_redemption_date, spr.pcrf_last_redemption_date),
         update_timestamp          = SYSDATE
  WHERE  pcrf_esn = sub.pcrf_esn;
  IF SQL%ROWCOUNT = 0 THEN
    sub.status := 'ESN-'||sub.pcrf_esn||' NOT FOUND. SPR TABLE NOT UPDATED';
  ELSE
    sub.status := 'SUCCESS';
  END IF;

  RETURN sub;
END update_dates;


MEMBER FUNCTION get_meter_sources ( i_device_type         IN VARCHAR2,
                                    i_source_system       IN VARCHAR2 DEFAULT NULL, -- CR46475
                                    i_brand               IN VARCHAR2,
                                    i_parent_name         IN VARCHAR2,
                                    i_service_plan_group  IN VARCHAR2 DEFAULT NULL) RETURN subscriber_type  IS

 s subscriber_type := subscriber_type();

 --
BEGIN
  IF i_device_type IS NULL OR i_brand IS NULL OR i_parent_name IS NULL THEN
    s.status := 'METERING PARAMETERS NOT PASSED';
    RETURN s;
  END IF;

  s.device_type := CASE
                     WHEN i_device_type ='BYOP' THEN 'SMARTPHONE'
                     ELSE i_device_type
                   END;

  BEGIN
    SELECT (SELECT  CARRIER_MTG_ID  FROM X_USAGE_HOST WHERE SHORT_NAME=voice_mtg_source) VOICE_MTG_SOURCE,
           (SELECT  CARRIER_MTG_ID  FROM X_USAGE_HOST WHERE SHORT_NAME=sms_mtg_source) VOICE_SMS_SOURCE,
           (SELECT  CARRIER_MTG_ID  FROM X_USAGE_HOST WHERE SHORT_NAME=data_mtg_source) VOICE_DATA_SOURCE,
           (SELECT  CARRIER_MTG_ID  FROM X_USAGE_HOST WHERE SHORT_NAME=ild_mtg_source) VOICE_ILD_SOURCE
    INTO   s.meter_source_voice,
           s.meter_source_sms,
           s.meter_source_data,
           s.meter_source_ild
       FROM (
             SELECT VOICE_MTG_SOURCE
                   ,SMS_MTG_SOURCE
                   ,DATA_MTG_SOURCE
                   ,ILD_MTG_SOURCE
                   ,SERVICE_PLAN_GROUP
              FROM   x_product_config
              WHERE  1= 1
              AND  brand_name = i_brand
              AND  device_type = s.device_type
              AND  parent_name = i_parent_name
              AND  NVL(source_system,'X')  = NVL(i_source_system,'X') -- CR46475
              AND  NVL(service_plan_group,'X') = CASE WHEN service_plan_group IS NOT NULL
                                                             AND
                                                             service_plan_group = i_service_plan_group
                                                        THEN service_plan_group
                                                        ELSE 'X'
                                                         END
               ORDER BY  CASE WHEN service_plan_group = i_service_plan_group
                              THEN 1
                              ELSE 2
                                END)
              WHERE ROWNUM = 1;
   EXCEPTION
     WHEN others THEN
       s.meter_source_voice := NULL;
       s.meter_source_sms   := NULL;
       s.meter_source_data  := NULL;
       s.meter_source_ild   := NULL;
  END;

  RETURN s;

 EXCEPTION
   WHEN OTHERS THEN
     s.status := 'ERROR GETTING METER SOURCES: ' || SQLERRM;
     RETURN s;
     --
END get_meter_sources;

-- Method used to get the necessary attributes for the cos rule engine
MEMBER FUNCTION get_cos_attributes RETURN subscriber_type IS

  sub                subscriber_type := SELF;
  s                  subscriber_type := SELF;
  n_site_part_objid  NUMBER;
BEGIN

  -- Reset sub with an empty object
  sub := subscriber_type ();

  sub.pcrf_esn := s.pcrf_esn;

  --
  IF sub.pcrf_esn IS NULL THEN
    sub.status := 'NO ESN PASSED';
    RETURN sub;
  END IF;

  -- Get min, carrier parent_name
  BEGIN
    SELECT pi_min.part_serial_no min,
           p.x_parent_name parent_name
    INTO   sub.pcrf_min,
           sub.pcrf_parent_name
    FROM   table_part_inst pi_esn,
           table_part_inst pi_min,
           table_x_parent p,
           table_x_carrier_group cg,
           table_x_carrier c
    WHERE  pi_esn.part_serial_no = sub.pcrf_esn
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_min.part_to_esn2part_inst = pi_esn.objid
    AND    pi_min.x_domain = 'LINES'
    AND    pi_min.part_inst2carrier_mkt = c.objid
    AND    c.carrier2carrier_group = cg.objid
    AND    cg.x_carrier_group2x_parent = p.objid;
   EXCEPTION
     WHEN too_many_rows THEN
       sub.status := sub.status || 'DUPLICATE ESN FOUND';
     WHEN others THEN
       sub.status := sub.status || 'ESN NOT FOUND';

       RETURN sub;
  END;

   -- Get the dealer, brand, part_class_name
  BEGIN
    SELECT bin_name dealer_id,
           pcpv.bus_org bus_org_id,
           pcpv.part_class part_class_name
    INTO   sub.dealer_id,
           sub.brand,
           sub.part_class_name
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           table_inv_bin inv,
           pcpv_mv pcpv
    WHERE  1 = 1
    AND    pi.part_serial_no = sub.pcrf_esn
    AND    pi.x_domain = 'PHONES'
    and    pi.part_inst2inv_bin = inv.objid
    AND    pi.n_part_inst2part_mod = ml.objid
    AND    ml.part_info2part_num = pn.objid
    AND    pn.domain = 'PHONES'
    AND    pn.part_num2part_class = pcpv.pc_objid;
   EXCEPTION
    WHEN others THEN
      sub.status := sub.status || '|DEALER NOT FOUND';
  END;

  -- Get enrollment details for an ESN
  BEGIN
    SELECT enrolled_autorefill_flag
    INTO   sub.enrolled_autorefill_flag
    FROM   ( SELECT 1 enrolled_autorefill_flag
             FROM   x_program_enrolled enr
             WHERE  enr.x_esn = sub.pcrf_esn
             AND    x_enrollment_status IN ('ENROLLED','ENROLLMENTPENDING')
             AND    x_next_charge_date > SYSDATE
             UNION ALL
             SELECT 1 enrolled_autorefill_flag
             FROM   x_program_enrolled enr,
                    x_program_parameters pp
             WHERE  enr.x_esn = sub.pcrf_esn
             AND    x_enrollment_status = 'ENROLLED_NO_ACCOUNT'
             AND    x_next_charge_date > SYSDATE
             AND    enr.pgm_enroll2pgm_parameter = pp.objid
             AND    pp.x_prog_class||'' = 'WARRANTY'
           )
    WHERE  ROWNUM = 1;
   EXCEPTION
     WHEN OTHERS THEN
       sub.enrolled_autorefill_flag := 0;
  END;

  -- Get the web user and contact (Active site part status)
  BEGIN
    SELECT sp.objid site_part_objid
    INTO   n_site_part_objid
    FROM   table_part_inst pi,
           table_site_part sp
    WHERE  1 = 1
    AND    pi.part_serial_no = sub.pcrf_esn
    AND    pi.x_domain = 'PHONES'
    AND    pi.part_serial_no = sp.x_service_id
    AND    sp.part_status = 'Active';
   EXCEPTION
     WHEN no_data_found THEN
       sub.status := sub.status || '|STATUS, ZIPCODE NOT FOUND';
  END;

  IF n_site_part_objid IS NOT NULL THEN
    -- Get the service plan
    BEGIN
      SELECT spsp.x_service_plan_id
      INTO   sub.service_plan_id
      FROM   x_service_plan_site_part spsp
      WHERE  spsp.table_site_part_id = n_site_part_objid;
     EXCEPTION
      WHEN too_many_rows THEN
     sub.status := sub.status || '|DUPLICATE SERVICE PLAN';
      WHEN OTHERS THEN
     sub.status := sub.status || '|SERVICE PLAN NOT FOUND';
    END;
  END IF;

  IF sub.service_plan_id IS NOT NULL THEN
    BEGIN
      SELECT cos pcrf_cos
      INTO   sub.pcrf_cos
      FROM   sa.service_plan_feat_pivot_mv
      WHERE  service_plan_objid = sub.service_plan_id;
     EXCEPTION
       WHEN OTHERS THEN
         sub.status := sub.status || '|COS NOT FOUND';
    END;
  END IF;

  -- Set successful response
  sub.status := CASE WHEN sub.status IS NULL THEN 'SUCCESS' ELSE (sub.status || '|SUCCESS') END;

  RETURN sub;

 EXCEPTION
   WHEN OTHERS THEN
     sub.status := 'ERROR RETRIEVING COS ATTRIBUTES: ' || SQLERRM;
     RETURN sub;
     --
END get_cos_attributes;

MEMBER FUNCTION remove RETURN subscriber_type IS

  s  subscriber_type := SELF;

BEGIN

  -- Make sure at least the ESN or MIN are passed
  IF s.pcrf_esn IS NULL AND s.pcrf_min IS NULL THEN
    --
    s.status := 'ESN AND MIN CANNOT BE BLANK';
    RETURN s;

  END IF;

  IF s.pcrf_esn IS NOT NULL THEN
    -- delete add ons from detail
    DELETE x_subscriber_spr_detail
    WHERE  subscriber_spr_objid IN ( SELECT objid
                                     FROM   x_subscriber_spr
                                     WHERE  pcrf_esn = s.pcrf_esn );
    -- delete spr row by esn
    DELETE x_subscriber_spr WHERE pcrf_esn = s.pcrf_esn;
  END IF;

  IF s.pcrf_min IS NOT NULL THEN
    -- delete add ons from detail
    DELETE x_subscriber_spr_detail
    WHERE  subscriber_spr_objid IN ( SELECT objid
                                     FROM   x_subscriber_spr
                                     WHERE  pcrf_min = s.pcrf_min );
    -- Delete by MIN from the SPR
    DELETE x_subscriber_spr WHERE pcrf_min = s.pcrf_min;
  END IF;

  -- Set successful response
  s.status := 'SUCCESS';

  RETURN s;

 EXCEPTION
   WHEN OTHERS THEN
     s.status := 'ERROR DELETING SUBSCRIBER: ' || SQLERRM;
     RETURN s;
     --
END remove;

--CR43143 Starts
 MEMBER FUNCTION get_vmbc_certification_flag (i_esn in varchar2) return varchar2
  is
   d_last_av_date date;
  begin
   select to_date(max(sls.x_last_av_date),'YYYY-MM-DD')
   into d_last_av_date
   from x_sl_subs sls, x_sl_currentvals cv
   where cv.x_current_esn = i_esn
   and cv.lid             = sls.lid;
   if d_last_av_date >= trunc(sysdate,'YYYY') then
     return 'Y';
   else
     return 'N';
   end if;
  exception
   when others then
    return 'N';
 end get_vmbc_certification_flag;
--CR47564 Start
MEMBER FUNCTION UPDATE_PROGRAM_PARAM_ID (i_min in varchar2,
                                         i_program_param_id in number) return varchar2
IS
BEGIN
   UPDATE x_subscriber_spr
   	SET program_parameter_id = i_program_param_id
    WHERE pcrf_min = i_min;

  IF SQL%ROWCOUNT = 0 THEN
    RETURN 'Invalid MIN. 0 rows updated.';
  ELSE
    RETURN 'SUCCESS';
  END IF;

EXCEPTION
   WHEN OTHERS
   THEN
		return SUBSTR(SQLERRM, 1, 1000);
END UPDATE_PROGRAM_PARAM_ID;
--CR47564 end
MEMBER FUNCTION get_esn_pin_redeem_days(i_esn IN VARCHAR2 )RETURN NUMBER IS
  s subscriber_type := subscriber_type();
  CURSOR brm_notification_flag_curs (i_esn IN VARCHAR2)
  IS
    SELECT bo.brm_notification_flag
    FROM table_part_inst pi,
      table_mod_level ml,
      table_part_num pn,
      table_bus_org bo
    WHERE 1                     = 1
    AND pi.part_serial_no       = i_esn
    AND pi.x_domain             = 'PHONES'
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid
    AND pn.domain               = 'PHONES'
    AND pn.part_num2bus_org     = bo.objid;

  brm_notification_flag_rec brm_notification_flag_curs%ROWTYPE;

BEGIN

  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  OPEN brm_notification_flag_curs (i_esn);
  FETCH brm_notification_flag_curs INTO brm_notification_flag_rec;

  IF brm_notification_flag_curs%NOTFOUND THEN
    CLOSE brm_notification_flag_curs;
    RETURN NULL;
  END IF;

  IF (brm_notification_flag_rec.brm_notification_flag= 'Y') THEN
    SELECT NVL(SUM(NVL(piext.brm_service_days,0)),0)
    INTO s.queued_days
    FROM table_part_inst pi,
      x_part_inst_ext piext,
      table_part_inst pi_esn
    WHERE 1                     = 1
    AND pi.objid                = piext.part_inst_objid
    AND pi_esn.part_serial_no   =i_esn
    AND pi.part_to_esn2part_inst=pi_esn.objid;
  ELSE
    SELECT NVL(SUM(NVL(pn.x_redeem_days,0)),0)
    INTO s.queued_days
    FROM table_part_inst pi_esn,
      table_part_inst pi_card,
      table_mod_level ml,
      table_part_num pn
    WHERE 1                           = 1
    AND pi_esn.part_serial_no         =i_esn
    AND pi_esn.x_domain               = 'PHONES'
    AND pi_card.part_to_esn2part_inst = pi_esn.objid
    AND pi_card.x_part_inst_status
      ||'' = '400'
    AND pi_card.x_domain
      ||''                           = 'REDEMPTION CARDS'
    AND pi_card.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num        = pn.objid;
  END IF;

  CLOSE brm_notification_flag_curs;
  RETURN nvl(s.queued_days,0);

EXCEPTION
WHEN OTHERS THEN
  RETURN s.queued_days;
END get_esn_pin_redeem_days;


MEMBER FUNCTION upd_spr_throttle_status (i_esn in varchar2,
                                         i_min in varchar2 ) return varchar2
IS
 s subscriber_type := subscriber_type();
BEGIN

   BEGIN
    SELECT x_policy_id,
           x_creation_date
    INTO   s.curr_throttle_policy_id,
           s.curr_throttle_eff_date
    FROM   w3ci.table_x_throttling_cache
    WHERE  x_esn = i_esn
    AND    x_min = i_min
    AND    x_status IN ('A','P')
    AND    ROWNUM = 1; -- There are some throttled subscribers with more than one entry in the cache


   EXCEPTION
    WHEN OTHERS THEN
       NULL; -- Continue the process when this value was not found
   END;

   update sa.x_subscriber_spr
      set curr_throttle_policy_id =  s.curr_throttle_policy_id,
          curr_throttle_eff_date  =  s.curr_throttle_eff_date
    where pcrf_esn = i_esn
      and pcrf_min = i_min;

  RETURN 'SUCCESS';

EXCEPTION
   WHEN OTHERS THEN
		RETURN SUBSTR(SQLERRM, 1, 400);
END upd_spr_throttle_status;

-- to expire pageplus addons
MEMBER FUNCTION expire_pp_addons(ao_offer_id in   VARCHAR2 default 'ALL',
                                 o_result    out  VARCHAR2) return boolean IS
  res boolean;
 BEGIN
   --
   o_result := 'OFFER ID NOT FOUND';
   --
   FOR cnt in 1..self.addOns.count loop
     --
     IF ( ao_offer_id = 'ALL' or self.addOns(cnt).getOfferId  = ao_offer_id )
     THEN
        --
        FOR i in ( select pab.objid
                   FROM   sa.x_pageplus_addon_benefit pab
                   WHERE  pab.pcrf_esn       = self.pcrf_esn
                   AND    pab.pcrf_min       = self.pcrf_min
                   AND    (pab.end_date >= SYSDATE
				           OR     (pab.status = 'EXPIRED'
							             AND  EXISTS (SELECT 1
							                          FROM   sa.x_subscriber_spr_detail
										                    WHERE  add_on_redemption_date = self.addons(cnt).add_on_redemption_date
										                    AND    subscriber_spr_objid   = self.addons(cnt).subscriber_spr_objid
											                  AND    add_on_offer_id        = self.addons(cnt).add_on_offer_id ) )
						              )
                  )

        LOOP
            --
            update x_pageplus_addon_benefit
            set    status = 'EXPIRED',
                   reason = 'EXPIRED FROM Throttling Event',
                   end_date = sysdate
            where  objid = i.objid
            and    status = 'ACTIVE';

            -- delete the addon detail in spr detail
            res      := self.addOns(cnt).del;
            --
            o_result := self.addOns(cnt).getStatus;

        END LOOP;
     END IF;
   END LOOP;
  RETURN res;
END expire_pp_addons;
END;

-- ANTHILL_TEST PLSQL/SA/Schema/subscriber_type.sql 	CR54619: 1.132
/