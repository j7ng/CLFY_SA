CREATE OR REPLACE TYPE sa.pcrf_trans_low_prty_type AS OBJECT
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
  addons                       pcrf_transaction_detail_tab ,
  --CR43143, 42103 adding new fields
  imsi                         VARCHAR2(30)           ,
  lifeline_id                  NUMBER(22)             ,
  install_date                 DATE                   ,
  program_parameter_id         VARCHAR2(50)           ,
  vmbc_certification_flag      VARCHAR2(1)            ,
  char_field_1                 VARCHAR2(100)          ,
  char_field_2                 VARCHAR2(100)          ,
  char_field_3                 VARCHAR2(100)          ,
  date_field_1                 DATE                   ,
  rcs_enable_flag              VARCHAR2(1)            ,
  --END CR43143, 42103

  CONSTRUCTOR FUNCTION pcrf_trans_low_prty_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION pcrf_trans_low_prty_type ( i_esn              IN VARCHAR2,
                                                  i_min              IN VARCHAR2,
                                                  i_order_type       IN VARCHAR2,
                                                  i_zipcode          IN VARCHAR2,
                                                  i_sourcesystem     IN VARCHAR2,
                                                  i_pcrf_status_code IN VARCHAR2) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION pcrf_trans_low_prty_type ( i_pcrf_transaction_id IN NUMBER   ,
                                                  i_pcrf_status_code    IN VARCHAR2 ,
                                                  i_status_message      IN VARCHAR2 DEFAULT NULL,
                                                  i_data_usage          IN NUMBER   DEFAULT NULL,
                                                  i_retry_count         IN NUMBER   DEFAULT NULL) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION pcrf_trans_low_prty_type ( i_pcrf_transaction_id IN NUMBER ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION pcrf_trans_low_prty_type ( i_pcrf_trans_low_prty_type IN OUT pcrf_trans_low_prty_type ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION pcrf_trans_low_prty_type ( i_min                     IN VARCHAR2   ,
                                                  i_mdn                     IN VARCHAR2   ,
                                                  i_esn                     IN VARCHAR2   ,
                                                  i_subscriber_id           IN VARCHAR2   ,
                                                  i_group_id                IN VARCHAR2   ,
                                                  i_order_type              IN VARCHAR2   ,
                                                  i_phone_manufacturer      IN VARCHAR2   ,
                                                  i_action_type             IN VARCHAR2   ,
                                                  i_sim                     IN VARCHAR2   ,
                                                  i_zipcode                 IN VARCHAR2   ,
                                                  i_service_plan_id         IN NUMBER     ,
                                                  i_case_id                 IN NUMBER     ,
                                                  i_pcrf_status_code        IN VARCHAR2   ,
                                                  i_status_message          IN VARCHAR2   ,
                                                  i_web_objid               IN NUMBER     ,
                                                  i_bus_org_id              IN VARCHAR2   ,
                                                  i_sourcesystem            IN VARCHAR2   ,
                                                  i_template                IN VARCHAR2   ,
                                                  i_rate_plan               IN VARCHAR2   ,
                                                  i_blackout_wait_date      IN VARCHAR2   ,
                                                  i_conversion_factor       IN VARCHAR2   ,
                                                  i_dealer_id               IN VARCHAR2   ,
                                                  i_denomination            IN VARCHAR2   ,
                                                  i_pcrf_parent_name        IN VARCHAR2   ,
                                                  i_propagate_flag          IN NUMBER     ,
                                                  i_service_plan_type       IN VARCHAR2   ,
                                                  i_part_inst_status        IN VARCHAR2   ,
                                                  i_phone_model             IN VARCHAR2   ,
                                                  i_content_delivery_format IN VARCHAR2   ,
                                                  i_language                IN VARCHAR2   ,
                                                  i_wf_mac_id               IN VARCHAR2   ,
                                                  i_pcrf_cos                IN VARCHAR2   ,
                                                  i_ttl                     IN DATE       ,
                                                  i_future_ttl              IN DATE       ,
                                                  i_redemption_date         IN DATE       ,
                                                  i_contact_objid           IN NUMBER     ,
                                                  i_addons                  IN pcrf_transaction_detail_tab,
                                                  --CR43143 42103
                                                  i_imsi                    IN VARCHAR2   DEFAULT NULL,
                                                  i_lifeline_id             IN NUMBER     DEFAULT NULL,
                                                  i_install_date            IN DATE       DEFAULT NULL,
                                                  i_program_parameter_id    IN VARCHAR2   DEFAULT NULL,
                                                  i_vmbc_certification_flag IN VARCHAR2   DEFAULT NULL,
                                                  i_char_field_1            IN VARCHAR2   DEFAULT NULL,
                                                  i_char_field_2            IN VARCHAR2   DEFAULT NULL,
                                                  i_char_field_3            IN VARCHAR2   DEFAULT NULL,
                                                  i_date_field_1            IN DATE       DEFAULT NULL,
                                                  i_rcs_enable_flag         IN VARCHAR2   DEFAULT NULL
                                                  ) RETURN SELF AS RESULT,
  MEMBER FUNCTION ins RETURN pcrf_trans_low_prty_type,
  MEMBER FUNCTION ins ( i_pt IN OUT pcrf_trans_low_prty_type ) RETURN pcrf_trans_low_prty_type,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION exist ( i_pcrf_transaction_id IN NUMBER) RETURN BOOLEAN,
  MEMBER FUNCTION del ( i_pcrf_transaction_id IN NUMBER) RETURN BOOLEAN,
  MEMBER FUNCTION upd RETURN pcrf_trans_low_prty_type,
  MEMBER FUNCTION save ( i_pt IN OUT pcrf_trans_low_prty_type ) RETURN VARCHAR2,
  MEMBER FUNCTION save RETURN pcrf_trans_low_prty_type

);
/
CREATE OR REPLACE TYPE BODY sa.pcrf_trans_low_prty_type IS
CONSTRUCTOR FUNCTION pcrf_trans_low_prty_type RETURN SELF AS RESULT IS
BEGIN
  SELF.addons := pcrf_transaction_detail_tab();
  RETURN;
END;
CONSTRUCTOR FUNCTION pcrf_trans_low_prty_type ( i_esn              IN VARCHAR2,
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

CONSTRUCTOR FUNCTION pcrf_trans_low_prty_type ( i_pcrf_transaction_id IN NUMBER                ,
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

END pcrf_trans_low_prty_type;

CONSTRUCTOR FUNCTION pcrf_trans_low_prty_type ( i_pcrf_transaction_id IN NUMBER ) RETURN SELF AS RESULT AS

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
  SELECT pcrf_trans_low_prty_type ( objid                      ,
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
                                    NULL                       , -- addons
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
  INTO   SELF
  FROM   x_pcrf_trans_low_prty
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
  FROM   x_pcrf_trans_detail_low_prty
  WHERE  pcrf_trans_low_prty_id = SELF.pcrf_transaction_id;

  -- if there are add ons
  IF SELF.addons.COUNT > 0 THEN
    FOR i IN 1 .. SELF.addons.COUNT LOOP
      -- Get the policy mapping configuration for the add on
      pdao := policy_mapping_config_type ( i_cos           => SELF.addons(i).offer_id,
                                           i_parent_name   => SELF.pcrf_parent_name,
                                           i_usage_tier_id => 1,
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
    SELF.addon_data_balance := pdt.threshold - NVL(SELF.total_addon_data_usage,0);
  END IF;

  -- Get the policy mapping configuration of the base COS
  pd := policy_mapping_config_type ( i_cos           => SELF.pcrf_cos,
                                     i_parent_name   => SELF.pcrf_parent_name,
                                     i_usage_tier_id => 2, --1, --CR44107 changed to 2
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
    SELF.hi_speed_data_usage := pd.threshold - NVL(SELF.data_usage,0);
    SELF.hi_speed_data_balance := pd.threshold - NVL(SELF.data_usage,0);
  END IF;

  -- Summarize the total data usage
  SELF.total_data_usage := SELF.data_usage + SELF.total_addon_data_usage;

  -- Summarize the hi_speed_total_data_balance data usage
  SELF.hi_speed_total_data_balance := NVL(SELF.addon_data_balance,0) + NVL(SELF.hi_speed_data_balance,0);

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
END pcrf_trans_low_prty_type;

CONSTRUCTOR FUNCTION pcrf_trans_low_prty_type ( i_pcrf_trans_low_prty_type IN OUT pcrf_trans_low_prty_type ) RETURN SELF AS RESULT IS

BEGIN
  SELF.min                     := i_pcrf_trans_low_prty_type.min                     ;
  SELF.mdn                     := i_pcrf_trans_low_prty_type.mdn                     ;
  SELF.esn                     := i_pcrf_trans_low_prty_type.esn                     ;
  SELF.subscriber_id           := i_pcrf_trans_low_prty_type.subscriber_id           ;
  SELF.group_id                := i_pcrf_trans_low_prty_type.group_id                ;
  SELF.order_type              := i_pcrf_trans_low_prty_type.order_type              ;
  SELF.phone_manufacturer      := i_pcrf_trans_low_prty_type.phone_manufacturer      ;
  SELF.action_type             := i_pcrf_trans_low_prty_type.action_type             ;
  SELF.sim                     := i_pcrf_trans_low_prty_type.sim                     ;
  SELF.zipcode                 := i_pcrf_trans_low_prty_type.zipcode                 ;
  SELF.service_plan_id         := i_pcrf_trans_low_prty_type.service_plan_id         ;
  SELF.case_id                 := i_pcrf_trans_low_prty_type.case_id                 ;
  SELF.pcrf_status_code        := i_pcrf_trans_low_prty_type.pcrf_status_code        ;
  SELF.status_message          := i_pcrf_trans_low_prty_type.status_message          ;
  SELF.web_objid               := i_pcrf_trans_low_prty_type.web_objid               ;
  SELF.bus_org_id              := i_pcrf_trans_low_prty_type.bus_org_id              ;
  SELF.sourcesystem            := i_pcrf_trans_low_prty_type.sourcesystem            ;
  SELF.template                := i_pcrf_trans_low_prty_type.template                ;
  SELF.rate_plan               := i_pcrf_trans_low_prty_type.rate_plan               ;
  SELF.blackout_wait_date      := i_pcrf_trans_low_prty_type.blackout_wait_date      ;
  SELF.conversion_factor       := i_pcrf_trans_low_prty_type.conversion_factor       ;
  SELF.dealer_id               := i_pcrf_trans_low_prty_type.dealer_id               ;
  SELF.denomination            := i_pcrf_trans_low_prty_type.denomination            ;
  SELF.pcrf_parent_name        := i_pcrf_trans_low_prty_type.pcrf_parent_name        ;
  SELF.propagate_flag          := i_pcrf_trans_low_prty_type.propagate_flag          ;
  SELF.service_plan_type       := i_pcrf_trans_low_prty_type.service_plan_type       ;
  SELF.part_inst_status        := i_pcrf_trans_low_prty_type.part_inst_status        ;
  SELF.phone_model             := i_pcrf_trans_low_prty_type.phone_model             ;
  SELF.content_delivery_format := i_pcrf_trans_low_prty_type.content_delivery_format ;
  SELF.language                := i_pcrf_trans_low_prty_type.language                ;
  SELF.wf_mac_id               := i_pcrf_trans_low_prty_type.wf_mac_id               ;
  SELF.pcrf_cos                := i_pcrf_trans_low_prty_type.pcrf_cos                ;
  SELF.ttl                     := i_pcrf_trans_low_prty_type.ttl                     ;
  SELF.future_ttl              := i_pcrf_trans_low_prty_type.future_ttl              ;
  SELF.redemption_date         := i_pcrf_trans_low_prty_type.redemption_date         ;
  SELF.contact_objid           := i_pcrf_trans_low_prty_type.contact_objid           ;
  SELF.addons                  := i_pcrf_trans_low_prty_type.addons           ;
  SELF.imsi                    := i_pcrf_trans_low_prty_type.imsi                    ;
  SELF.lifeline_id             := i_pcrf_trans_low_prty_type.lifeline_id             ;
  SELF.install_date            := i_pcrf_trans_low_prty_type.install_date            ;
  SELF.program_parameter_id    := i_pcrf_trans_low_prty_type.program_parameter_id    ;
  SELF.vmbc_certification_flag := i_pcrf_trans_low_prty_type.vmbc_certification_flag ;
  SELF.char_field_1            := i_pcrf_trans_low_prty_type.char_field_1            ;
  SELF.char_field_2            := i_pcrf_trans_low_prty_type.char_field_2            ;
  SELF.char_field_3            := i_pcrf_trans_low_prty_type.char_field_3            ;
  SELF.date_field_1            := i_pcrf_trans_low_prty_type.date_field_1            ;
  SELF.rcs_enable_flag         := i_pcrf_trans_low_prty_type.rcs_enable_flag         ;


  SELF.status := 'SUCCESS';

  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     SELF.status := 'ERROR INSTANTIATING PCRF LOW PRTY';
     SELF.addons := pcrf_transaction_detail_tab();
     RETURN;
END pcrf_trans_low_prty_type;

CONSTRUCTOR FUNCTION pcrf_trans_low_prty_type ( i_min                     IN VARCHAR2   ,
                                                i_mdn                     IN VARCHAR2   ,
                                                i_esn                     IN VARCHAR2   ,
                                                i_subscriber_id           IN VARCHAR2   ,
                                                i_group_id                IN VARCHAR2   ,
                                                i_order_type              IN VARCHAR2   ,
                                                i_phone_manufacturer      IN VARCHAR2   ,
                                                i_action_type             IN VARCHAR2   ,
                                                i_sim                     IN VARCHAR2   ,
                                                i_zipcode                 IN VARCHAR2   ,
                                                i_service_plan_id         IN NUMBER     ,
                                                i_case_id                 IN NUMBER     ,
                                                i_pcrf_status_code        IN VARCHAR2   ,
                                                i_status_message          IN VARCHAR2   ,
                                                i_web_objid               IN NUMBER     ,
                                                i_bus_org_id              IN VARCHAR2   ,
                                                i_sourcesystem            IN VARCHAR2   ,
                                                i_template                IN VARCHAR2   ,
                                                i_rate_plan               IN VARCHAR2   ,
                                                i_blackout_wait_date      IN VARCHAR2   ,
                                                i_conversion_factor       IN VARCHAR2   ,
                                                i_dealer_id               IN VARCHAR2   ,
                                                i_denomination            IN VARCHAR2   ,
                                                i_pcrf_parent_name        IN VARCHAR2   ,
                                                i_propagate_flag          IN NUMBER     ,
                                                i_service_plan_type       IN VARCHAR2   ,
                                                i_part_inst_status        IN VARCHAR2   ,
                                                i_phone_model             IN VARCHAR2   ,
                                                i_content_delivery_format IN VARCHAR2   ,
                                                i_language                IN VARCHAR2   ,
                                                i_wf_mac_id               IN VARCHAR2   ,
                                                i_pcrf_cos                IN VARCHAR2   ,
                                                i_ttl                     IN DATE       ,
                                                i_future_ttl              IN DATE       ,
                                                i_redemption_date         IN DATE       ,
                                                i_contact_objid           IN NUMBER     ,
                                                i_addons                  IN pcrf_transaction_detail_tab,

                                                i_imsi                    IN VARCHAR2   DEFAULT NULL,
                                                i_lifeline_id             IN NUMBER     DEFAULT NULL,
                                                i_install_date            IN DATE       DEFAULT NULL,
                                                i_program_parameter_id    IN VARCHAR2   DEFAULT NULL,
                                                i_vmbc_certification_flag IN VARCHAR2   DEFAULT NULL,
                                                i_char_field_1            IN VARCHAR2   DEFAULT NULL,
                                                i_char_field_2            IN VARCHAR2   DEFAULT NULL,
                                                i_char_field_3            IN VARCHAR2   DEFAULT NULL,
                                                i_date_field_1            IN DATE       DEFAULT NULL,
                                                i_rcs_enable_flag         IN VARCHAR2   DEFAULT NULL
                                                ) RETURN SELF AS RESULT IS

BEGIN


  SELF.min                     := i_min                     ;
  SELF.mdn                     := i_mdn                     ;
  SELF.esn                     := i_esn                     ;
  SELF.subscriber_id           := i_subscriber_id           ;
  SELF.group_id                := i_group_id                ;
  SELF.order_type              := i_order_type              ;
  SELF.phone_manufacturer      := i_phone_manufacturer      ;
  SELF.action_type             := i_action_type             ;
  SELF.sim                     := i_sim                     ;
  SELF.zipcode                 := i_zipcode                 ;
  SELF.service_plan_id         := i_service_plan_id         ;
  SELF.case_id                 := i_case_id                 ;
  SELF.pcrf_status_code        := i_pcrf_status_code        ;
  SELF.status_message          := i_status_message          ;
  SELF.web_objid               := i_web_objid               ;
  SELF.bus_org_id              := i_bus_org_id              ;
  SELF.sourcesystem            := i_sourcesystem            ;
  SELF.template                := i_template                ;
  SELF.rate_plan               := i_rate_plan               ;
  SELF.blackout_wait_date      := i_blackout_wait_date      ;
  SELF.conversion_factor       := i_conversion_factor       ;
  SELF.dealer_id               := i_dealer_id               ;
  SELF.denomination            := i_denomination            ;
  SELF.pcrf_parent_name        := i_pcrf_parent_name        ;
  SELF.propagate_flag          := i_propagate_flag          ;
  SELF.service_plan_type       := i_service_plan_type       ;
  SELF.part_inst_status        := i_part_inst_status        ;
  SELF.phone_model             := i_phone_model             ;
  SELF.content_delivery_format := i_content_delivery_format ;
  SELF.language                := i_language                ;
  SELF.wf_mac_id               := i_wf_mac_id               ;
  SELF.pcrf_cos                := i_pcrf_cos                ;
  SELF.ttl                     := i_ttl                     ;
  SELF.future_ttl              := i_future_ttl              ;
  SELF.redemption_date         := i_redemption_date         ;
  SELF.contact_objid           := i_contact_objid           ;
  SELF.addons                  := i_addons           ;
  SELF.imsi                    := i_imsi                    ;
  SELF.lifeline_id             := i_lifeline_id             ;
  SELF.install_date            := i_install_date            ;
  SELF.program_parameter_id    := i_program_parameter_id    ;
  SELF.vmbc_certification_flag := i_vmbc_certification_flag ;
  SELF.char_field_1            := i_char_field_1            ;
  SELF.char_field_2            := i_char_field_2            ;
  SELF.char_field_3            := i_char_field_3            ;
  SELF.date_field_1            := i_date_field_1            ;
  SELF.rcs_enable_flag         := i_rcs_enable_flag         ;

  SELF.status := 'SUCCESS';

  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     SELF.status := 'ERROR INSTANTIATING PCRF LOW PRTY';
     SELF.addons := pcrf_transaction_detail_tab();
     RETURN;
END pcrf_trans_low_prty_type;

--
MEMBER FUNCTION ins RETURN pcrf_trans_low_prty_type IS

  pcrf  pcrf_trans_low_prty_type := SELF;
  p     pcrf_trans_low_prty_type := pcrf_trans_low_prty_type ();

BEGIN

  -- Control duplicate DL transactions
  IF pcrf.order_type = 'DL' THEN
    BEGIN
      SELECT objid
      INTO   pcrf.pcrf_transaction_id
      FROM   sa.x_pcrf_trans_low_prty p
      WHERE  esn = pcrf.esn
      AND    min = pcrf.min
      AND    order_type = 'DL'
      AND    objid = ( SELECT MAX(objid)
                       FROM   x_pcrf_trans_low_prty
                       WHERE  esn             = p.esn
                       AND    min             = p.min
                       AND    order_type      = p.order_type
                     );
      pcrf.status:= 'DUPLICATE DELETE PCRF TRANSACTION LOW PRIORITY FOUND: ' || pcrf.pcrf_transaction_id;
      RETURN pcrf;
    EXCEPTION
       WHEN too_many_rows THEN
         pcrf.status := 'MULTIPLE DUPLICATE DELETE PCRF TRANSACTIONS LOW PRIORITY FOUND';
         RETURN pcrf;
       WHEN no_data_found THEN
         NULL;
       WHEN OTHERS THEN
         NULL; -- do nothing
    END;
  ELSIF pcrf.order_type <> 'BI' THEN
    BEGIN
      SELECT objid
      INTO   pcrf.pcrf_transaction_id
      FROM   sa.x_pcrf_trans_low_prty p
      WHERE  esn = pcrf.esn
      AND    min = pcrf.min
      AND    pcrf_cos = pcrf.pcrf_cos
      AND    ttl = pcrf.ttl
      AND    future_ttl = pcrf.future_ttl
      AND    redemption_date = pcrf.redemption_date
      AND    rate_plan = pcrf.rate_plan
      AND    objid = ( SELECT MAX(objid)
                       FROM   x_pcrf_trans_low_prty
                       WHERE  esn             = p.esn
                       AND    min             = p.min
                       AND    pcrf_cos        = p.pcrf_cos
                       AND    ttl             = p.ttl
                       AND    future_ttl      = p.future_ttl
                       AND    redemption_date = p.redemption_date
                       AND    rate_plan       = p.rate_plan
                     );

      pcrf.status:= 'DUPLICATE PCRF TRANSACTION LOW PRIORITY FOUND: ' || pcrf.pcrf_transaction_id;
      RETURN pcrf;

    EXCEPTION
       WHEN too_many_rows THEN
         pcrf.status := 'MULTIPLE DUPLICATE PCRF TRANSACTIONS LOW PRIORITY FOUND';
         RETURN pcrf;
       WHEN no_data_found THEN
         NULL;
       WHEN OTHERS THEN
         NULL; -- do nothing
    END;
  END IF;

  -- call the save method to perform the insert
  p.status := p.save ( i_pt => pcrf );

  IF pcrf.addons.COUNT > 0 THEN
    --
    INSERT
    INTO   x_pcrf_trans_detail_low_prty
           ( objid                  ,
             pcrf_trans_low_prty_id ,
             offer_id               ,
             ttl                    ,
             redemption_date
           )
    SELECT seq_pcrf_trans_detail_low_prty.NEXTVAL,
           pcrf.pcrf_transaction_id,
           offer_id,
           ttl,
           redemption_date
    FROM   TABLE(CAST(pcrf.addons AS pcrf_transaction_detail_tab));
    -- if add ons were created, set a flag in pcrf transaction
    IF SQL%ROWCOUNT > 0 THEN
      -- set flag as yes
      BEGIN
        UPDATE x_pcrf_trans_low_prty
        SET    addons_flag = 'Y'
        WHERE  objid = pcrf.pcrf_transaction_id;
       EXCEPTION
         WHEN others THEN
           NULL;
      END;
    END IF;
    --
  END IF;

  --
  pcrf.status := 'SUCCESS';

  RETURN pcrf;

 EXCEPTION
   WHEN OTHERS THEN
     --
     pcrf.status := 'UNHANDLED ERROR ADDING PCRF TRANSACTION LOW PRIORITY : ' || SQLERRM;
     RETURN pcrf;
     --
END ins;

MEMBER FUNCTION ins ( i_pt IN OUT pcrf_trans_low_prty_type ) RETURN pcrf_trans_low_prty_type IS

  pcrf pcrf_trans_low_prty_type := pcrf_trans_low_prty_type ();
  p    pcrf_trans_low_prty_type;

BEGIN

  -- instantiate values into pcrf_trans_low_prty_type type
  pcrf := pcrf_trans_low_prty_type ( i_min                     => i_pt.min                      ,
                                     i_mdn                     => i_pt.mdn                      ,
                                     i_esn                     => i_pt.esn                      ,
                                     i_subscriber_id           => i_pt.subscriber_id            ,
                                     i_group_id                => i_pt.group_id                 ,
                                     i_order_type              => i_pt.order_type               ,
                                     i_phone_manufacturer      => i_pt.phone_manufacturer       ,
                                     i_action_type             => i_pt.action_type              ,
                                     i_sim                     => i_pt.sim                      ,
                                     i_zipcode                 => i_pt.zipcode                  ,
                                     i_service_plan_id         => i_pt.service_plan_id          ,
                                     i_case_id                 => i_pt.case_id                  ,
                                     i_pcrf_status_code        => i_pt.pcrf_status_code         ,
                                     i_status_message          => i_pt.status_message           ,
                                     i_web_objid               => i_pt.web_objid                ,
                                     i_bus_org_id              => i_pt.bus_org_id               ,
                                     i_sourcesystem            => i_pt.sourcesystem             ,
                                     i_template                => i_pt.template                 ,
                                     i_rate_plan               => i_pt.rate_plan                ,
                                     i_blackout_wait_date      => i_pt.blackout_wait_date       ,
                                     i_conversion_factor       => i_pt.conversion_factor        ,
                                     i_dealer_id               => i_pt.dealer_id                ,
                                     i_denomination            => i_pt.denomination             ,
                                     i_pcrf_parent_name        => i_pt.pcrf_parent_name         ,
                                     i_propagate_flag          => i_pt.propagate_flag           ,
                                     i_service_plan_type       => i_pt.service_plan_type        ,
                                     i_part_inst_status        => i_pt.part_inst_status         ,
                                     i_phone_model             => i_pt.phone_model              ,
                                     i_content_delivery_format => i_pt.content_delivery_format  ,
                                     i_language                => i_pt.language                 ,
                                     i_wf_mac_id               => i_pt.wf_mac_id                ,
                                     i_pcrf_cos                => i_pt.pcrf_cos                 ,
                                     i_ttl                     => i_pt.ttl                      ,
                                     i_future_ttl              => i_pt.future_ttl               ,
                                     i_redemption_date         => i_pt.redemption_date          ,
                                     i_contact_objid           => i_pt.contact_objid            ,
                                     i_addons                  => i_pt.addons                   ,
                                     i_imsi                    => i_pt.imsi                     ,
                                     i_lifeline_id             => i_pt.lifeline_id              ,
                                     i_install_date            => i_pt.install_date             ,
                                     i_program_parameter_id    => i_pt.program_parameter_id     ,
                                     i_vmbc_certification_flag => i_pt.vmbc_certification_flag  ,
                                     i_char_field_1            => i_pt.char_field_1             ,
                                     i_char_field_2            => i_pt.char_field_2             ,
                                     i_char_field_3            => i_pt.char_field_3             ,
                                     i_date_field_1            => i_pt.date_field_1             ,
                                     i_rcs_enable_flag         => i_pt.rcs_enable_flag
                                     );

  -- call the insert method
  p := pcrf.ins;

  RETURN p;

 EXCEPTION
   WHEN OTHERS THEN
     --
     p.status := 'UNHANDLED ERROR INSERTING PCRF TRANSACTION LOW PRIORITY : ' || SQLERRM;
     RETURN p;
     --
END ins;

--
MEMBER FUNCTION exist RETURN BOOLEAN IS

 pcrf  pcrf_trans_low_prty_type := pcrf_trans_low_prty_type ( i_pcrf_transaction_id => SELF.pcrf_transaction_id);

BEGIN
 IF pcrf.pcrf_transaction_id IS NOT NULL THEN
    RETURN TRUE;
 ELSE
    RETURN FALSE;
 END IF;
END exist;

MEMBER FUNCTION exist ( i_pcrf_transaction_id IN NUMBER) RETURN BOOLEAN IS

 pcrf  pcrf_trans_low_prty_type := pcrf_trans_low_prty_type ( i_pcrf_transaction_id => i_pcrf_transaction_id);

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

--
MEMBER FUNCTION upd RETURN pcrf_trans_low_prty_type IS

  pcrf  pcrf_trans_low_prty_type := SELF;

BEGIN
  BEGIN
    --
    UPDATE x_pcrf_trans_low_prty
    SET    pcrf_status_code = NVL(pcrf.pcrf_status_code, pcrf_status_code),
           order_type       = NVL(pcrf.order_type      , order_type      ),
           data_usage       = NVL(pcrf.data_usage      , data_usage      ),
           status_message   = NVL(pcrf.status_message  , status_message  ),
           retry_count      = NVL(pcrf.retry_count     , retry_count     ),
           insert_timestamp = SYSDATE
    WHERE  objid = pcrf.pcrf_transaction_id;
   EXCEPTION
     WHEN others THEN
       --
       UPDATE x_pcrf_trans_low_prty
       SET    insert_timestamp = SYSDATE
       WHERE  objid = pcrf.pcrf_transaction_id;
       --
       UPDATE x_pcrf_trans_low_prty
       SET    pcrf_status_code = NVL(pcrf.pcrf_status_code, pcrf_status_code),
              order_type       = NVL(pcrf.order_type      , order_type      ),
              data_usage       = NVL(pcrf.data_usage      , data_usage      ),
              status_message   = NVL(pcrf.status_message  , status_message  ),
              retry_count      = NVL(pcrf.retry_count     , retry_count     )
       WHERE  objid = pcrf.pcrf_transaction_id;
  END;

  pcrf.status := 'SUCCESS';

  RETURN pcrf;

 EXCEPTION
   WHEN OTHERS THEN
     pcrf.status := 'ERROR UPDATING PCRF TRANSACTION: ' || SUBSTR(SQLERRM,1,100);
     RETURN pcrf;
END upd;

MEMBER FUNCTION save ( i_pt IN OUT pcrf_trans_low_prty_type ) RETURN VARCHAR2 IS

BEGIN

  --
  BEGIN
    INSERT
    INTO   x_pcrf_trans_low_prty
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
    ( seq_pcrf_trans_low_prty.NEXTVAL  ,
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
       i_pt.status := 'DUPLICATE KEY INSERTING INTO PCRF TRANSACTION LOW PRTY: ' ||SQLERRM;
       RETURN('DUPLICATE KEY INSERTING INTO PCRF TRANSACTION LOW PRTY: ' ||SQLERRM);
     WHEN OTHERS THEN
       i_pt.status := 'ERROR INSERTING INTO PCRF TRANSACTION LOW PRTY: ' ||SQLERRM;
       RETURN('ERROR INSERTING INTO PCRF TRANSACTION LOW PRTY: ' ||SQLERRM);
  END;

  RETURN('SUCCESS');

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 'ERROR SAVING PCRF TRANSACTION LOW PRTY RECORD: ' || SQLERRM;
     --
END save;

--
MEMBER FUNCTION save RETURN pcrf_trans_low_prty_type IS

  pcrf  pcrf_trans_low_prty_type := SELF;

BEGIN
  --
  pcrf.status := save ( i_pt => pcrf );
  --
  RETURN pcrf;

END save;

END;
/