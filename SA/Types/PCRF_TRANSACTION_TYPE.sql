CREATE OR REPLACE TYPE sa.pcrf_transaction_type AS OBJECT
(
  pcrf_transaction_id          NUMBER(22)             ,
  min                          VARCHAR2(30)           ,
  mdn                          VARCHAR2(30)           ,
  esn                          VARCHAR2(30)           ,
  subscriber_id                VARCHAR2(50)           ,
  group_id                     VARCHAR2(50)           ,
  order_type                   VARCHAR2(30)           ,
  phone_manufacturer           VARCHAR2(30)           ,
  action_type                  VARCHAR2(1)            ,
  sim                          VARCHAR2(30)           ,
  zipcode                      VARCHAR2(10)           ,
  service_plan_id              NUMBER(22)             ,
  case_id                      NUMBER(22)             ,
  pcrf_status_code             VARCHAR2(2)            ,
  status_message               VARCHAR2(1000)         ,
  web_objid                    NUMBER(22)             ,
  bus_org_id                   VARCHAR2(40)           ,
  sourcesystem                 VARCHAR2(30)           ,
  template                     VARCHAR2(30)           ,
  rate_plan                    VARCHAR2(60)           ,
  blackout_wait_date           DATE                   ,
  retry_count                  NUMBER(10)             ,
  data_usage                   NUMBER(20,2)           ,
  total_addon_data_usage       NUMBER(20,2)           ,
  total_data_usage             NUMBER(20,2)           ,
  hi_speed_data_usage          NUMBER(20,2)           ,
  addon_data_balance           NUMBER(20,2)           ,
  hi_speed_total_data_balance  NUMBER(20,2)           ,
  hi_speed_data_balance        NUMBER(20,2)           ,
  conversion_factor            VARCHAR2(50)           ,
  dealer_id                    VARCHAR2(80)           ,
  denomination                 VARCHAR2(50)           ,
  pcrf_parent_name             VARCHAR2(40)           ,
  propagate_flag               NUMBER(4)              ,
  service_plan_type            VARCHAR2(50)           ,
  part_inst_status             VARCHAR2(30)           ,
  phone_model                  VARCHAR2(50)           ,
  content_delivery_format      VARCHAR2(50)           ,
  language                     VARCHAR2(30)           ,
  wf_mac_id                    VARCHAR2(50)           ,
  pcrf_cos                     VARCHAR2(30)           ,
  ttl                          DATE                   ,
  future_ttl                   DATE                   ,
  redemption_date              DATE                   ,
  contact_objid                NUMBER(22)             ,
  insert_timestamp             DATE                   ,
  update_timestamp             DATE                   ,
  status                       VARCHAR2(1000)         ,
  low_priority_flag            VARCHAR2(1)            ,
  addons                       pcrf_transaction_detail_tab,
--CR43143, 42103 adding new fields
  imsi                        VARCHAR2(30)            ,
  lifeline_id                 NUMBER(22)              ,
  install_date                DATE                    ,
  program_parameter_id        VARCHAR2(50)            ,
  vmbc_certification_flag     VARCHAR2(1)             ,
  char_field_1                VARCHAR2(100)           ,
  char_field_2                VARCHAR2(100)           ,
  char_field_3                VARCHAR2(100)           ,
  date_field_1                DATE                    ,
  addons_flag                 VARCHAR2(1)             ,
  rcs_enable_flag             VARCHAR2(1)             ,
--END CR43143, 42103

  CONSTRUCTOR FUNCTION pcrf_transaction_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION pcrf_transaction_type ( i_esn              IN VARCHAR2,
                                               i_min              IN VARCHAR2,
                                               i_order_type       IN VARCHAR2,
                                               i_zipcode          IN VARCHAR2,
                                               i_sourcesystem     IN VARCHAR2,
                                               i_pcrf_status_code IN VARCHAR2) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION pcrf_transaction_type ( i_pcrf_transaction_id IN NUMBER   ,
                                               i_pcrf_status_code    IN VARCHAR2 ,
                                               i_status_message      IN VARCHAR2 DEFAULT NULL,
                                               i_data_usage          IN NUMBER   DEFAULT NULL,
                                               i_retry_count         IN NUMBER   DEFAULT NULL) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION pcrf_transaction_type ( i_pcrf_transaction_id IN NUMBER ) RETURN SELF AS RESULT,
  -- perform validations and insert new records into pcrf transaction
  MEMBER FUNCTION ins RETURN pcrf_transaction_type,
  -- determine if a record exists in the pcrf transaction table
  MEMBER FUNCTION exist RETURN BOOLEAN,
  -- determine if a record exists in the pcrf transaction table
  MEMBER FUNCTION exist ( i_pcrf_transaction_id IN NUMBER ) RETURN BOOLEAN,
  -- delete a row from pcrf transaction
  MEMBER FUNCTION del ( i_pcrf_transaction_id IN NUMBER ) RETURN BOOLEAN,
  -- get the low priority flag from x_cos (table)
  MEMBER FUNCTION get_low_priority_flag ( i_cos IN VARCHAR2 ) RETURN VARCHAR2,
  -- perform update on pcrf transaction (table)
  MEMBER FUNCTION upd RETURN pcrf_transaction_type,
  -- performs a raw insert into pcrf transaction (table)
  MEMBER FUNCTION save ( i_pt IN OUT pcrf_transaction_type ) RETURN VARCHAR2,
  -- performs a raw insert into pcrf transaction table (uses SELF values)
  MEMBER FUNCTION save RETURN pcrf_transaction_type
);
/
CREATE OR REPLACE TYPE BODY sa.pcrf_transaction_type IS
CONSTRUCTOR FUNCTION pcrf_transaction_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;
CONSTRUCTOR FUNCTION pcrf_transaction_type ( i_esn              IN VARCHAR2,
                                             i_min              IN VARCHAR2,
                                             i_order_type       IN VARCHAR2,
                                             i_zipcode          IN VARCHAR2,
                                             i_sourcesystem     IN VARCHAR2,
                                             i_pcrf_status_code IN VARCHAR2 ) RETURN SELF AS RESULT is
BEGIN
  SELF.esn := i_esn;
  SELF.min := i_min;
  SELF.order_type := i_order_type;
  SELF.zipcode := i_zipcode;
  SELF.sourcesystem := i_sourcesystem;
  SELF.pcrf_status_code := i_pcrf_status_code;
  SELF.status := 'SUCCESS';
  RETURN;
END;

CONSTRUCTOR FUNCTION pcrf_transaction_type ( i_pcrf_transaction_id IN NUMBER                ,
                                             i_pcrf_status_code    IN VARCHAR2              ,
                                             i_status_message      IN VARCHAR2 DEFAULT NULL ,
                                             i_data_usage          IN NUMBER   DEFAULT NULL ,
                                             i_retry_count         IN NUMBER   DEFAULT NULL ) RETURN SELF AS RESULT IS
BEGIN

  SELF.pcrf_transaction_id := i_pcrf_transaction_id;
  SELF.pcrf_status_code    := i_pcrf_status_code   ;
  SELF.status_message      := i_status_message     ;
  SELF.data_usage          := i_data_usage         ;
  SELF.retry_count         := i_retry_count        ;

  RETURN;

END pcrf_transaction_type;

CONSTRUCTOR FUNCTION pcrf_transaction_type ( i_pcrf_transaction_id IN NUMBER ) RETURN SELF AS RESULT AS

  pd    policy_mapping_config_type := policy_mapping_config_type();
  pdao  policy_mapping_config_type := policy_mapping_config_type();
  pdt   policy_mapping_config_type := policy_mapping_config_type();

BEGIN
  --
  IF i_pcrf_transaction_id IS NULL THEN
    --
    SELF.status := 'PCRF TRANSACTION ID IS NULL';
    RETURN;
  END IF;

  --
  SELECT pcrf_transaction_type ( objid                      ,
                                 min                        ,
                                 mdn                        ,
                                 esn                        ,
                                 subscriber_id              ,
                                 group_id                   ,
                                 order_type                 ,
                                 phone_manufacturer         ,
                                 action_type                ,
                                 sim                        ,
                                 zipcode                    ,
                                 service_plan_id            ,
                                 case_id                    ,
                                 pcrf_status_code           ,
                                 status_message             ,
                                 web_objid                  ,
                                 bus_org_id                 ,
                                 sourcesystem               ,
                                 template                   ,
                                 rate_plan                  ,
                                 blackout_wait_date         ,
                                 retry_count                ,
                                 data_usage                 ,
                                 NULL                       , -- total_addon_data_usage
                                 NULL                       , -- total_data_usage
                                 NULL                       , -- hi_speed_data_usage
                                 NULL                       , -- addon_data_balance
                                 NULL                       , -- hi_speed_total_data_balance
                                 NULL                       , -- hi_speed_data_balance
                                 conversion_factor          ,
                                 dealer_id                  ,
                                 denomination               ,
                                 pcrf_parent_name           ,
                                 propagate_flag             ,
                                 service_plan_type          ,
                                 part_inst_status           ,
                                 phone_model                ,
                                 content_delivery_format    ,
                                 language                   ,
                                 wf_mac_id                  ,
                                 pcrf_cos                   ,
                                 ttl                        ,
                                 future_ttl                 ,
                                 redemption_date            ,
                                 contact_objid              ,
                                 insert_timestamp           ,
                                 update_timestamp           ,
                                 NULL                       , -- status
                                 NULL                       , -- low_priority_flag
                                 NULL                       ,  -- addons
                                 imsi                       ,
                                 lifeline_id                ,
                                 install_date               ,
                                 program_parameter_id       ,
                                 vmbc_certification_flag    ,
                                 char_field_1               ,
                                 char_field_2               ,
                                 char_field_3               ,
                                 date_field_1               ,
								 addons_flag                ,
                                 rcs_enable_flag
                               )
  INTO   SELF
  FROM   x_pcrf_transaction
  WHERE  objid = i_pcrf_transaction_id;

  -- Get the add ons
  SELECT pcrf_transaction_detail_type ( objid               ,
                                        pcrf_transaction_id ,
                                        offer_id            ,
                                        ttl                 ,
                                        future_ttl          ,
                                        redemption_date     ,
                                        offer_name          ,
                                        data_usage          ,
                                        NULL                )
  BULK COLLECT
  INTO   SELF.addons
  FROM   x_pcrf_transaction_detail
  WHERE  pcrf_transaction_id = SELF.pcrf_transaction_id;

  -- if there are add ons
  IF SELF.addons.COUNT > 0 THEN
    FOR i IN 1 .. SELF.addons.COUNT LOOP
      -- Get the policy mapping configuration for the add on
      pdao := policy_mapping_config_type ( i_cos           => SELF.addons(i).offer_id,
                                           i_parent_name   => SELF.pcrf_parent_name,
                                           i_usage_tier_id => 2,                    -- CR37756 05/25/2016 PMistry Modify the tier value from 1 to 2
                                           i_entitlement   => 'DEFAULT' );
      -- add up the add ons thresholds
      pdt.threshold := NVL(pdt.threshold,0) + NVL(pdao.threshold,0);
    END LOOP;
  END IF;

  -- Add the addons table data usage
  SELECT NVL(SUM(data_usage),0)
  INTO   SELF.total_addon_data_usage
  FROM   TABLE(CAST(SELF.addons AS pcrf_transaction_detail_tab));

  -- if there is a threshold for the add ons
  IF pdt.threshold > 0 THEN
    -- calculate the addon data balance
    SELF.addon_data_balance := (pdt.threshold * 1024 * 1024)- NVL(SELF.total_addon_data_usage,0);
  END IF;

  -- Get the policy mapping configuration of the base COS
  pd := policy_mapping_config_type ( i_cos           => SELF.pcrf_cos,
                                     i_parent_name   => SELF.pcrf_parent_name,
                                     i_usage_tier_id => 2,                        -- CR37756 05/25/2016 PMistry Modify the tier value from 1 to 2
                                     i_entitlement   => 'DEFAULT' );
  IF pd.status NOT LIKE '%SUCCESS%'
  THEN
    pd := policy_mapping_config_type ( i_cos           => SELF.pcrf_cos,
                                       i_parent_name   => SELF.pcrf_parent_name,
                                       i_usage_tier_id => 2,
                                       i_entitlement   => NULL );
  END IF;


  -- If the threshold from the mapping table is greater than 0 (zero)
  IF pd.threshold > 0 THEN
    -- Calculate hi-speed data balance
    SELF.hi_speed_data_usage := (pd.threshold * 1024 * 1024) - NVL(SELF.data_usage,0);      -- CR37756 PMistry 05/23/2016 converted data into byte
    SELF.hi_speed_data_balance := (pd.threshold * 1024 * 1024)- NVL(SELF.data_usage,0);
  END IF;

  -- Summarize the total data usage
  SELF.total_data_usage := SELF.data_usage + SELF.total_addon_data_usage;

  -- Summarize the hi_speed_total_data_balance data usage
  SELF.hi_speed_total_data_balance := NVL(SELF.addon_data_balance,0) + NVL(SELF.hi_speed_data_balance,0);

  -- set the low priority flag
  SELF.low_priority_flag := SELF.get_low_priority_flag ( i_cos => SELF.pcrf_cos );

  DBMS_OUTPUT.PUT_LINE('SELF.low_priority_flag: ' || SELF.low_priority_flag);

  --
  SELF.status := 'SUCCESS';

  --
  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     SELF.status := 'PCRF TRANSACTION NOT FOUND';
     SELF.pcrf_transaction_id := i_pcrf_transaction_id;
     SELF.addons := pcrf_transaction_detail_tab();
     RETURN;
END pcrf_transaction_type;

--
MEMBER FUNCTION ins RETURN pcrf_transaction_type IS

  pcrf  pcrf_transaction_type := SELF;
  p     pcrf_transaction_type := pcrf_transaction_type ();

  ptlp  pcrf_trans_low_prty_type := pcrf_trans_low_prty_type();
  plpi  pcrf_trans_low_prty_type := pcrf_trans_low_prty_type();

  sub   subscriber_type := subscriber_type ( i_esn => pcrf.esn );

  --CR 44729 GO SMART
  ct    customer_type := customer_type ( i_esn => pcrf.esn );

BEGIN

  -- validate the spr record exists
  IF sub.status NOT LIKE '%SUCCESS' THEN
    pcrf.status := sub.status;
    RETURN pcrf;
  END IF;

  IF sub.pcrf_esn IS NOT NULL AND pcrf.esn IS NULL THEN
    pcrf.esn := sub.pcrf_esn;
  END IF;
  IF sub.pcrf_min IS NOT NULL AND pcrf.min IS NULL THEN
    pcrf.min := sub.pcrf_min;
  END IF;

  IF pcrf.esn IS NULL AND pcrf.min IS NULL THEN
    pcrf.status := 'ESN or MIN IS A REQUIRED INPUT PARAMETER';
    RETURN pcrf;
  ELSIF pcrf.esn IS NULL THEN
    pcrf.esn := util_pkg.get_esn_by_min(pcrf.min);
    IF pcrf.esn IS NULL THEN
       pcrf.status := 'ESN or MIN IS INVALID';
       RETURN pcrf;
    END IF;
  ELSIF pcrf.min IS NULL THEN
    pcrf.min := util_pkg.get_min_by_esn(pcrf.esn);
    IF pcrf.min IS NULL THEN
       pcrf.status := 'ESN or MIN IS INVALID';
       RETURN pcrf;
    END IF;
  END IF;

  IF pcrf.order_type IS NULL THEN
    pcrf.status:= 'ORDER TYPE IS A REQUIRED PARAMETER';
    RETURN pcrf;
  ELSE
    BEGIN
       SELECT x_ig_order_type
       into   pcrf.order_type
       from   x_ig_order_type
       where  x_ig_order_type = pcrf.order_type
       and    x_programme_name = 'ADD_PCRF_TRANSACTION';
    EXCEPTION
       WHEN OTHERS THEN
         pcrf.status := 'ORDER TYPE NOT FOUND';
         RETURN pcrf;
    END;
  END IF;

  -- Validate the subscriber
  IF sub.get_subscriber_id IS NULL THEN
    pcrf.status:= 'SUBSCRIBER NOT FOUND';
    RETURN pcrf;
  END IF;

  BEGIN
    SELECT pcrf_status_code
    INTO   pcrf.pcrf_status_code
    FROM   x_pcrf_status
    WHERE  pcrf_status_code = pcrf.pcrf_status_code;
   EXCEPTION
     WHEN OTHERS THEN
       pcrf.status:= 'INVALID STATUS (' || pcrf.pcrf_status_code ||')';
       RETURN pcrf;
  END;

  -- Assign input values
  pcrf.subscriber_id               := sub.get_subscriber_id         ;
  pcrf.group_id                    := sub.pcrf_group_id             ;
  pcrf.phone_manufacturer          := sub.phone_manufacturer        ;
  pcrf.service_plan_id             := sub.service_plan_id           ;
  pcrf.web_objid                   := sub.web_user_objid            ;
  pcrf.rate_plan                   := sub.rate_plan                 ;
  pcrf.blackout_wait_date          := SYSDATE                       ;
  pcrf.template                    := 'PCRF'                        ;
  pcrf.conversion_factor           := sub.conversion_factor         ;
  pcrf.dealer_id                   := sub.dealer_id                 ;
  pcrf.denomination                := sub.denomination              ;
  pcrf.pcrf_parent_name            := sub.pcrf_parent_name          ;
  pcrf.service_plan_type           := sub.service_plan_type         ;
  pcrf.part_inst_status            := sub.part_inst_status          ;
  pcrf.phone_model                 := sub.phone_model               ;
  pcrf.content_delivery_format     := sub.content_delivery_format   ;
  pcrf.language                    := sub.language                  ;
  pcrf.wf_mac_id                   := sub.wf_mac_id                 ;
  pcrf.ttl                         := sub.pcrf_base_ttl             ;
  pcrf.future_ttl                  := sub.future_ttl                ;
  pcrf.redemption_date             := sub.pcrf_last_redemption_date ;
  pcrf.mdn                         := pcrf.min                      ;
  pcrf.contact_objid               := sub.contact_objid             ;
  pcrf.pcrf_cos                    := sub.pcrf_cos                  ;
  pcrf.zipcode                     := sub.zipcode                   ;
  pcrf.imsi                        := sub.imsi                      ;
  pcrf.lifeline_id                 := sub.lifeline_id               ;
  pcrf.install_date                := sub.install_date              ;
  pcrf.program_parameter_id        := sub.program_parameter_id      ;
  pcrf.vmbc_certification_flag     := sub.vmbc_certification_flag   ;
  pcrf.char_field_1                := sub.char_field_1              ;
  pcrf.char_field_2                := sub.char_field_2              ;
  pcrf.char_field_3                := sub.char_field_3              ;
  pcrf.date_field_1                := sub.date_field_1              ;
  pcrf.rcs_enable_flag             := sub.rcs_enable_flag           ;
  -- Override propagate flag to mask the value
  BEGIN
    SELECT CASE sub.propagate_flag
             WHEN -1 THEN 0
             WHEN 0  THEN 0
             WHEN 1  THEN 1
             WHEN 2  THEN 2
             WHEN 3  THEN 0
             WHEN 4  THEN 2
             WHEN 5  THEN 0
           ELSE sub.propagate_flag
           END
    INTO   pcrf.propagate_flag
    FROM   DUAL;
   EXCEPTION
     WHEN others THEN
       pcrf.propagate_flag := sub.propagate_flag;
  END;
  --

  -- Override BRAND to mask the value
  -- CR44729 GO SMART
  -- CHANGING THE HARDCODED LOGIC TO A LOOK UP ON TABLE_BUS_ORG
/*  BEGIN
    SELECT CASE sub.brand
             WHEN 'NET10'          THEN 'NT'
             WHEN 'TRACFONE'       THEN 'TF'
             WHEN 'STRAIGHT_TALK'  THEN 'ST'
             WHEN 'SIMPLE_MOBILE'  THEN 'SM'
             WHEN 'TELCEL'         THEN 'TC'
             WHEN 'TOTAL_WIRELESS' THEN 'TW'
             WHEN 'PAGEPLUS'       THEN 'PP'
             ELSE sub.brand
           END
    INTO   pcrf.bus_org_id
    FROM   DUAL;
   EXCEPTION
     WHEN others THEN
       pcrf.bus_org_id := sub.brand;
  END;*/

  BEGIN

    SELECT w3ci_acronym
    INTO   pcrf.bus_org_id
    FROM   table_bus_org
    WHERE  org_id = nvl(ct.get_sub_brand, sub.brand);

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
  END;
  -- set the low priority flag before masking the COS
  pcrf.low_priority_flag := pcrf.get_low_priority_flag ( i_cos => pcrf.pcrf_cos );

  -- Override COS to mask the value
  BEGIN
    SELECT CASE sub.pcrf_cos
             WHEN 'DEFAULT' THEN 'TFDEFAULT'
             ELSE sub.pcrf_cos
           END
    INTO   pcrf.pcrf_cos
    FROM   DUAL;
   EXCEPTION
     WHEN others THEN
       pcrf.pcrf_cos := sub.pcrf_cos;
  END;

  -- set required values for conversion factor, contact and web objid
  SELECT NVL2(sub.conversion_factor, sub.conversion_factor, '1'),
         NVL2(sub.contact_objid, sub.contact_objid, 0),
         NVL2(sub.web_user_objid, sub.web_user_objid, 0)
  INTO   pcrf.conversion_factor,
         pcrf.contact_objid,
         pcrf.web_objid
  FROM   dual;

  -- Assign SYSDATE when is a Delete
  IF pcrf.order_type = 'DL' AND pcrf.ttl IS NULL THEN
    pcrf.ttl        := SYSDATE;
    pcrf.future_ttl := SYSDATE;
  END IF;

  -- Control duplicate DL transactions
  IF pcrf.order_type = 'DL' THEN
    BEGIN
      SELECT objid
      INTO   pcrf.pcrf_transaction_id
      FROM   sa.x_pcrf_transaction p
      WHERE  esn = pcrf.esn
      AND    min = pcrf.min
      AND    order_type = 'DL'
      AND    objid = ( SELECT MAX(objid)
                       FROM   x_pcrf_transaction
                       WHERE  esn             = p.esn
                       AND    min             = p.min
                       AND    order_type      = p.order_type
                     );
      pcrf.status:= 'DUPLICATE DL PCRF TRANSACTION FOUND: ' || pcrf.pcrf_transaction_id;
      RETURN pcrf;
    EXCEPTION
       WHEN too_many_rows THEN
         pcrf.status := 'MULTIPLE DUPLICATE DL PCRF TRANSACTIONS FOUND';
         RETURN pcrf;
       WHEN no_data_found THEN
         NULL;
       WHEN OTHERS THEN
         NULL; -- do nothing
    END;
  ELSIF pcrf.order_type <> 'BI' THEN
    --Skipping duplicate check for the addons
    IF nvl(sub.addons.COUNT,0) = 0 THEN -- no addons
      BEGIN
        SELECT objid
        INTO   pcrf.pcrf_transaction_id
        FROM   sa.x_pcrf_transaction p
        WHERE  esn = pcrf.esn
        AND    min = pcrf.min
        AND    pcrf_cos = pcrf.pcrf_cos
        AND    ttl = pcrf.ttl
        AND    future_ttl = pcrf.future_ttl
        AND    redemption_date = pcrf.redemption_date
        AND    rate_plan = pcrf.rate_plan
        AND    objid = ( SELECT MAX(objid)
                         FROM   x_pcrf_transaction
                         WHERE  esn             = p.esn
                         AND    min             = p.min
                         AND    pcrf_cos        = p.pcrf_cos
                         AND    ttl             = p.ttl
                         AND    future_ttl      = p.future_ttl
                         AND    redemption_date = p.redemption_date
                         AND    rate_plan       = p.rate_plan
                         -- CR43498 added to skip the check for addons
                         AND    nvl(addons_flag,'N') = 'N'
                       );
        pcrf.status:= 'DUPLICATE PCRF TRANSACTION FOUND: ' || pcrf.pcrf_transaction_id;
        RETURN pcrf;
      EXCEPTION
         WHEN too_many_rows THEN
           pcrf.status := 'MULTIPLE DUPLICATE PCRF TRANSACTIONS FOUND';
           RETURN pcrf;
         WHEN no_data_found THEN
           NULL;
         WHEN OTHERS THEN
           NULL; -- do nothing
      END;
    END IF; --no addons
  END IF;

  -- exclude temporary mins
  IF pcrf.min LIKE 'T%' THEN
    pcrf.status := 'TEMPORARY TMIN: ' || pcrf.min;
    RETURN pcrf;
  END IF;

  -- Don't create a UP if Base TTL <=  SYSDATE
  IF TRUNC(pcrf.ttl) < TRUNC(SYSDATE) THEN
    pcrf.status := 'INVALID TTL DATE: ' || pcrf.ttl;
    RETURN pcrf;
  END IF;

  -- Move configured COS rows to low priority table
  IF pcrf.low_priority_flag = 'Y' THEN

    pcrf.addons := pcrf_transaction_detail_tab();

    -- set the addons if available
    IF sub.addons.COUNT > 0 THEN
      --
      BEGIN
        SELECT pcrf_transaction_detail_type ( seq_pcrf_trans_detail_low_prty.NEXTVAL ,
                                              pcrf.pcrf_transaction_id ,
                                              add_on_offer_id ,
                                              add_on_ttl ,
                                              add_on_ttl ,
                                              add_on_redemption_date,
                                              add_on_offer_id ,
                                              NULL ,
                                              NULL
                                            )
        BULK COLLECT
        INTO   pcrf.addons
        FROM   TABLE(CAST(sub.addons AS subscriber_detail_tab))
        WHERE  expired_usage_date IS NULL;
       EXCEPTION
         WHEN others THEN
           NULL;
      END;
    END IF;

    -- instantiate values into pcrf_trans_low_prty_type type
    ptlp := pcrf_trans_low_prty_type ( i_min                     => pcrf.min                      ,
                                       i_mdn                     => pcrf.mdn                      ,
                                       i_esn                     => pcrf.esn                      ,
                                       i_subscriber_id           => pcrf.subscriber_id            ,
                                       i_group_id                => pcrf.group_id                 ,
                                       i_order_type              => pcrf.order_type               ,
                                       i_phone_manufacturer      => pcrf.phone_manufacturer       ,
                                       i_action_type             => pcrf.action_type              ,
                                       i_sim                     => pcrf.sim                      ,
                                       i_zipcode                 => pcrf.zipcode                  ,
                                       i_service_plan_id         => pcrf.service_plan_id          ,
                                       i_case_id                 => pcrf.case_id                  ,
                                       i_pcrf_status_code        => pcrf.pcrf_status_code         ,
                                       i_status_message          => pcrf.status_message           ,
                                       i_web_objid               => pcrf.web_objid                ,
                                       i_bus_org_id              => pcrf.bus_org_id               ,
                                       i_sourcesystem            => pcrf.sourcesystem             ,
                                       i_template                => pcrf.template                 ,
                                       i_rate_plan               => pcrf.rate_plan                ,
                                       i_blackout_wait_date      => pcrf.blackout_wait_date       ,
                                       i_conversion_factor       => pcrf.conversion_factor        ,
                                       i_dealer_id               => pcrf.dealer_id                ,
                                       i_denomination            => pcrf.denomination             ,
                                       i_pcrf_parent_name        => pcrf.pcrf_parent_name         ,
                                       i_propagate_flag          => pcrf.propagate_flag           ,
                                       i_service_plan_type       => pcrf.service_plan_type        ,
                                       i_part_inst_status        => pcrf.part_inst_status         ,
                                       i_phone_model             => pcrf.phone_model              ,
                                       i_content_delivery_format => pcrf.content_delivery_format  ,
                                       i_language                => pcrf.language                 ,
                                       i_wf_mac_id               => pcrf.wf_mac_id                ,
                                       i_pcrf_cos                => pcrf.pcrf_cos                 ,
                                       i_ttl                     => pcrf.ttl                      ,
                                       i_future_ttl              => pcrf.future_ttl               ,
                                       i_redemption_date         => pcrf.redemption_date          ,
                                       i_contact_objid           => pcrf.contact_objid            ,
                                       i_addons                  => pcrf.addons                   ,
                                       i_imsi                    => pcrf.imsi                     ,
                                       i_lifeline_id             => pcrf.lifeline_id              ,
                                       i_install_date            => pcrf.install_date             ,
                                       i_program_parameter_id    => pcrf.program_parameter_id     ,
                                       i_vmbc_certification_flag => pcrf.vmbc_certification_flag  ,
                                       i_char_field_1            => pcrf.char_field_1             ,
                                       i_char_field_2            => pcrf.char_field_2             ,
                                       i_char_field_3            => pcrf.char_field_3             ,
                                       i_date_field_1            => pcrf.date_field_1             ,
                                       i_rcs_enable_flag         => pcrf.rcs_enable_flag
                                       );

    -- call the insert method
    plpi := ptlp.ins;

    -- set the pcrf transaction id from the low priority table
    pcrf.pcrf_transaction_id := plpi.pcrf_transaction_id;

    -- if there was an error inserting into the low priority table then ...
    IF plpi.status NOT LIKE '%SUCCESS%' THEN
      pcrf.status := 'ERROR INSERTING LOW PRIORITY PCRF TRANSACTION: ' ||plpi.status;
      RETURN pcrf;
    END IF;

  -- Otherwise use the original table
  ELSE

    -- call the save method to perform the insert
    p.status := p.save ( i_pt => pcrf );

    -- if there was an error saving the record
    IF p.status NOT LIKE '%SUCCESS%' THEN
      pcrf.status := 'ERROR INSERTING PCRF TRANSACTION: ' || p.status;
      RETURN pcrf;
    END IF;

    -- if there are addons
    IF sub.addons.COUNT > 0 THEN
      -- insert all addons
      INSERT
      INTO   x_pcrf_transaction_detail
             ( objid               ,
               pcrf_transaction_id ,
               offer_id            ,
               ttl                 ,
               redemption_date
             )
      SELECT sequ_pcrf_transaction_detail.NEXTVAL,
             pcrf.pcrf_transaction_id,
             add_on_offer_id,
             add_on_ttl,
             add_on_redemption_date
      FROM   TABLE(CAST(sub.addons AS subscriber_detail_tab))
      WHERE  expired_usage_date IS NULL;
      -- if add ons were created, set a flag in pcrf transaction
      IF SQL%ROWCOUNT > 0 THEN
        -- set flag as yes
        BEGIN
          UPDATE x_pcrf_transaction
          SET    addons_flag = 'Y'
          WHERE  objid = pcrf.pcrf_transaction_id;
         EXCEPTION
           WHEN others THEN
             NULL;
        END;
      END IF;

    END IF;

  END IF; -- IF pcrf.propagate_flag = 0 THEN

  --
  pcrf.status := 'SUCCESS';

  --
  RETURN pcrf;

 EXCEPTION
   WHEN OTHERS THEN
     --
     pcrf.status := 'UNHANDLED ERROR ADDING PCRF TRANSACTION : ' || SQLERRM;
     RETURN pcrf;
     --
END ins;

--
MEMBER FUNCTION exist RETURN BOOLEAN IS

 pcrf  pcrf_transaction_type    := pcrf_transaction_type ( i_pcrf_transaction_id => SELF.pcrf_transaction_id);
 lpcrf pcrf_trans_low_prty_type := pcrf_trans_low_prty_type ( SELF.pcrf_transaction_id );

BEGIN
  -- Use the low priority table when the COS derives the rule
  IF pcrf.low_priority_flag = 'Y' THEN
    IF lpcrf.pcrf_transaction_id IS NOT NULL THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  -- non-low priority go to pcrf transaction
  ELSE

    IF pcrf.pcrf_transaction_id IS NOT NULL THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END IF;
END exist;

MEMBER FUNCTION exist ( i_pcrf_transaction_id IN NUMBER ) RETURN BOOLEAN IS

 pcrf  pcrf_transaction_type := pcrf_transaction_type ( i_pcrf_transaction_id => i_pcrf_transaction_id);

BEGIN
 IF pcrf.pcrf_transaction_id IS NOT NULL THEN
    RETURN TRUE;
 ELSE
    RETURN FALSE;
 END IF;
END exist;

--
MEMBER FUNCTION del ( i_pcrf_transaction_id IN NUMBER) RETURN BOOLEAN IS
BEGIN
  RETURN TRUE;
END del;

-- get the low priority flag from x_cos (table)
MEMBER FUNCTION get_low_priority_flag ( i_cos IN VARCHAR2) RETURN VARCHAR2 IS

  p pcrf_transaction_type := pcrf_transaction_type();

BEGIN

  -- exit when the cos is not passed
  IF i_cos IS NULL THEN
    RETURN('N');
  END IF;

  p.pcrf_cos := i_cos;

  IF i_cos = 'TFDEFAULT' THEN
    p.pcrf_cos := 'DEFAULT';
  END IF;

  -- get the low priority flag from the X_COS table
  BEGIN
    SELECT NVL(pcrf_low_priority_flag,'N')
    INTO   p.low_priority_flag
    FROM   x_cos
    WHERE  cos = p.pcrf_cos;
   EXCEPTION
     WHEN others THEN
       p.low_priority_flag := 'N';
  END;

  dbms_output.put_line(NVL(p.low_priority_flag,'N'));

  -- return value
  RETURN (NVL(p.low_priority_flag,'N'));

 EXCEPTION
   WHEN OTHERS THEN
     RETURN('N');
END get_low_priority_flag;

-- perform update on pcrf transaction (table)
MEMBER FUNCTION upd RETURN pcrf_transaction_type IS

  pcrf  pcrf_transaction_type := SELF;
  p     pcrf_transaction_type;

  lpcrf pcrf_trans_low_prty_type := pcrf_trans_low_prty_type ();
  lp    pcrf_trans_low_prty_type;

BEGIN

  -- call the constructor to determine the cos value from the pcrf transaction
  p := pcrf_transaction_type ( i_pcrf_transaction_id => pcrf.pcrf_transaction_id );

  --
  UPDATE x_pcrf_transaction
  SET    pcrf_status_code = NVL(pcrf.pcrf_status_code, pcrf_status_code),
         order_type       = NVL(pcrf.order_type      , order_type      ),
         data_usage       = NVL(pcrf.data_usage      , data_usage      ),
         status_message   = NVL(pcrf.status_message  , status_message  ),
         retry_count      = NVL(pcrf.retry_count     , retry_count     )
  WHERE  objid = pcrf.pcrf_transaction_id
  AND    pcrf_status_code||'' NOT IN ('F','S','W','C','SS','FF');

  pcrf.status := 'SUCCESS';

  RETURN pcrf;

 EXCEPTION
   WHEN OTHERS THEN
     pcrf.status := 'ERROR UPDATING PCRF TRANSACTION: ' || SUBSTR(SQLERRM,1,100);
     RETURN pcrf;
END upd;

-- performs a raw insert into pcrf transaction (table)
MEMBER FUNCTION save ( i_pt IN OUT pcrf_transaction_type ) RETURN VARCHAR2 IS

BEGIN

  --
  BEGIN
    INSERT
    INTO   x_pcrf_transaction
           ( objid                      ,
             min                        ,
             mdn                        ,
             esn                        ,
             subscriber_id              ,
             group_id                   ,
             order_type                 ,
             phone_manufacturer         ,
             action_type                ,
             sim                        ,
             zipcode                    ,
             service_plan_id            ,
             case_id                    ,
             pcrf_status_code           ,
             status_message             ,
             web_objid                  ,
             brand                      ,
             sourcesystem               ,
             template                   ,
             rate_plan                  ,
             blackout_wait_date         ,
             conversion_factor          ,
             dealer_id                  ,
             denomination               ,
             pcrf_parent_name           ,
             propagate_flag             ,
             service_plan_type          ,
             part_inst_status           ,
             phone_model                ,
             content_delivery_format    ,
             language                   ,
             wf_mac_id                  ,
             pcrf_cos                   ,
             ttl                        ,
             future_ttl                 ,
             redemption_date            ,
             contact_objid              ,
             imsi                       ,
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
    ( sequ_pcrf_transaction.NEXTVAL    ,
      i_pt.min                         ,
      i_pt.mdn                         ,
      i_pt.esn                         ,
      i_pt.subscriber_id               ,
      i_pt.group_id                    ,
      i_pt.order_type                  ,
      i_pt.phone_manufacturer          ,
      i_pt.action_type                 ,
      i_pt.sim                         ,
      i_pt.zipcode                     ,
      i_pt.service_plan_id             ,
      i_pt.case_id                     ,
      i_pt.pcrf_status_code            ,
      i_pt.status_message              ,
      i_pt.web_objid                   ,
      i_pt.bus_org_id                  ,
      i_pt.sourcesystem                ,
      i_pt.template                    ,
      i_pt.rate_plan                   ,
      i_pt.blackout_wait_date          ,
      i_pt.conversion_factor           ,
      i_pt.dealer_id                   ,
      i_pt.denomination                ,
      i_pt.pcrf_parent_name            ,
      i_pt.propagate_flag              ,
      i_pt.service_plan_type           ,
      i_pt.part_inst_status            ,
      i_pt.phone_model                 ,
      i_pt.content_delivery_format     ,
      i_pt.language                    ,
      i_pt.wf_mac_id                   ,
      i_pt.pcrf_cos                    ,
      i_pt.ttl                         ,
      i_pt.future_ttl                  ,
      i_pt.redemption_date             ,
      i_pt.contact_objid               ,
      i_pt.imsi                        ,
      i_pt.lifeline_id                 ,
      i_pt.install_date                ,
      i_pt.program_parameter_id        ,
      i_pt.vmbc_certification_flag     ,
      i_pt.char_field_1                ,
      i_pt.char_field_2                ,
      i_pt.char_field_3                ,
      i_pt.date_field_1                ,
      i_pt.rcs_enable_flag
    )
    RETURNING objid
    INTO      i_pt.pcrf_transaction_id;
   EXCEPTION
     WHEN dup_val_on_index THEN
       i_pt.status := 'DUPLICATE KEY INSERTING INTO PCRF TRANSACTION: ' ||SQLERRM;
       RETURN('DUPLICATE KEY INSERTING INTO PCRF TRANSACTION: ' ||SQLERRM);
     WHEN OTHERS THEN
       i_pt.status := 'ERROR INSERTING INTO PCRF TRANSACTION: ' ||SQLERRM;
       RETURN('ERROR INSERTING INTO PCRF TRANSACTION: ' ||SQLERRM);
  END;

  RETURN('SUCCESS');

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 'ERROR SAVING PCRF TRANSACTION RECORD: ' || SQLERRM;
     --
END save;

-- performs a raw insert into pcrf transaction table (uses SELF values)
MEMBER FUNCTION save RETURN pcrf_transaction_type IS

  pcrf  pcrf_transaction_type := SELF;

BEGIN
  --
  pcrf.status := save ( i_pt => pcrf );
  --
  RETURN pcrf;

END save;

END;
/