CREATE OR REPLACE TYPE sa.IG_TRANSACTION_TYPE AS OBJECT (
  action_item_id             VARCHAR2(30)  ,
  carrier_id                 VARCHAR2(30)  ,
  order_type                 VARCHAR2(30)  ,
  min                        VARCHAR2(30)  ,
  esn                        VARCHAR2(30)  ,
  esn_hex                    VARCHAR2(30)  ,
  old_esn                    VARCHAR2(30)  ,
  old_esn_hex                VARCHAR2(30)  ,
  pin                        VARCHAR2(30)  ,
  phone_manf                 VARCHAR2(30)  ,
  end_user                   VARCHAR2(40)  ,
  account_num                VARCHAR2(30)  ,
  market_code                VARCHAR2(30)  ,
  rate_plan                  VARCHAR2(60)  ,
  ld_provider                VARCHAR2(30)  ,
  sequence_num               VARCHAR2(30)  ,
  dealer_code                VARCHAR2(30)  ,
  transmission_method        VARCHAR2(30)  ,
  fax_num                    VARCHAR2(40)  ,
  online_num                 VARCHAR2(40)  ,
  email                      VARCHAR2(45)  ,
  network_login              VARCHAR2(30)  ,
  network_password           VARCHAR2(30)  ,
  system_login               VARCHAR2(30)  ,
  system_password            VARCHAR2(30)  ,
  template                   VARCHAR2(30)  ,
  exe_name                   VARCHAR2(160) ,
  com_port                   VARCHAR2(40)  ,
  status                     VARCHAR2(30)  ,
  status_message             VARCHAR2(256) ,
  fax_batch_size             VARCHAR2(30)  ,
  fax_batch_q_time           VARCHAR2(30)  ,
  expidite                   VARCHAR2(30)  ,
  trans_prof_key             VARCHAR2(30)  ,
  q_transaction              VARCHAR2(30)  ,
  online_num2                VARCHAR2(49)  ,
  fax_num2                   VARCHAR2(40)  ,
  creation_date              DATE          ,
  update_date                DATE          ,
  blackout_wait              DATE          ,
  tux_iti_server             VARCHAR2(20)  ,
  transaction_id             NUMBER(10)    ,
  technology_flag            VARCHAR2(30)  ,
  voice_mail                 VARCHAR2(30)  ,
  voice_mail_package         VARCHAR2(30)  ,
  caller_id                  VARCHAR2(30)  ,
  caller_id_package          VARCHAR2(30)  ,
  call_waiting               VARCHAR2(30)  ,
  call_waiting_package       VARCHAR2(30)  ,
  rtp_server                 VARCHAR2(30)  ,
  digital_feature_code       VARCHAR2(30)  ,
  state_field                VARCHAR2(30)  ,
  zip_code                   VARCHAR2(30)  ,
  msid                       VARCHAR2(30)  ,
  new_msid_flag              VARCHAR2(10)  ,
  sms                        VARCHAR2(30)  ,
  sms_package                VARCHAR2(30)  ,
  iccid                      VARCHAR2(30)  ,
  old_min                    VARCHAR2(30)  ,
  digital_feature            VARCHAR2(30)  ,
  ota_type                   VARCHAR2(10)  ,
  rate_center_no             VARCHAR2(30)  ,
  application_system         VARCHAR2(30)  ,
  subscriber_update          VARCHAR2(1)   ,
  download_date              DATE          ,
  prl_number                 VARCHAR2(80)  ,
  amount                     NUMBER(6,2)   ,
  balance                    NUMBER(12,2)  ,
  language                   VARCHAR2(12)  ,
  exp_date                   DATE          ,
  x_mpn                      VARCHAR2(75)  ,
  x_mpn_code                 VARCHAR2(100) ,
  x_pool_name                VARCHAR2(60)  ,
  imsi                       VARCHAR2(40)  ,
  new_imsi_flag              VARCHAR2(10)  ,
  response                   VARCHAR2(1000),
  numeric_value              NUMBER        ,
  varchar2_value             VARCHAR2(1000),
  skip_ig_validation_flag    VARCHAR2(1)   ,
  task_objid                 NUMBER        ,
  call_trans_objid           NUMBER        ,
  cf_extension_count         NUMBER(3)     ,
  data_saver                 VARCHAR2(5)   ,
  data_saver_code            VARCHAR2(70)  ,
  carrier_feature_objid      NUMBER        , --CR48373
  cf_profile_id              NUMBER        , --CR49490
  rp_ext_objid               NUMBER        , --CR48260
  CONSTRUCTOR FUNCTION ig_transaction_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION ig_transaction_type ( i_transaction_id IN NUMBER) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION ig_transaction_type ( i_esn                IN VARCHAR2 ,
                                             i_action_item_id     IN VARCHAR2 ,
                                             i_msid               IN VARCHAR2 ,
                                             i_min                IN VARCHAR2 ,
                                             i_technology_flag    IN VARCHAR2 ,
                                             i_order_type         IN VARCHAR2 ,
                                             i_template           IN VARCHAR2 ,
                                             i_rate_plan          IN VARCHAR2 ,
                                             i_zip_code           IN VARCHAR2 ,
                                             i_transaction_id     IN NUMBER   DEFAULT NULL,
                                             i_phone_manf         IN VARCHAR2 DEFAULT NULL,
                                             i_carrier_id         IN VARCHAR2 DEFAULT NULL,
                                             i_network_login      IN VARCHAR2 DEFAULT NULL,
                                             i_network_password   IN VARCHAR2 DEFAULT NULL,
                                             i_status             IN VARCHAR2 DEFAULT NULL,
                                             i_status_message     IN VARCHAR2 DEFAULT NULL,
                                             i_application_system IN VARCHAR2 DEFAULT NULL) RETURN SELF AS RESULT,

  CONSTRUCTOR FUNCTION ig_transaction_type ( i_esn                 IN VARCHAR2 ,
                                             i_action_item_id      IN VARCHAR2 ,
                                             i_msid                IN VARCHAR2 ,
                                             i_min                 IN VARCHAR2 ,
                                             i_technology_flag     IN VARCHAR2 ,
                                             i_order_type          IN VARCHAR2 ,
                                             i_template            IN VARCHAR2 ,
                                             i_rate_plan           IN VARCHAR2 ,
                                             i_zip_code            IN VARCHAR2 ,
                                             i_transaction_id      IN NUMBER   ,
                                             i_phone_manf          IN VARCHAR2 DEFAULT NULL,
                                             i_carrier_id          IN VARCHAR2 DEFAULT NULL,
                                             i_iccid               IN VARCHAR2 DEFAULT NULL,
                                             i_network_login       IN VARCHAR2 DEFAULT NULL,
                                             i_network_password    IN VARCHAR2 DEFAULT NULL,
                                             i_account_num         IN VARCHAR2 ,
                                             i_transmission_method IN VARCHAR2 ,
                                             i_status              IN VARCHAR2 DEFAULT NULL,
                                             i_status_message      IN VARCHAR2 DEFAULT NULL,
                                             i_application_system  IN VARCHAR2 DEFAULT NULL,
                                             i_skip_ig_validation  IN VARCHAR2 DEFAULT NULL,
                                             i_old_esn             IN VARCHAR2 DEFAULT NULL, -- added for CR47153
                                             i_pin                 IN VARCHAR2 DEFAULT NULL) RETURN SELF AS RESULT,

  CONSTRUCTOR FUNCTION ig_transaction_type ( i_action_item_id          IN VARCHAR2 ,
                                             i_carrier_id              IN VARCHAR2 ,
                                             i_order_type              IN VARCHAR2 ,
                                             i_min                     IN VARCHAR2 ,
                                             i_esn                     IN VARCHAR2 ,
                                             i_esn_hex                 IN VARCHAR2 ,
                                             i_old_esn                 IN VARCHAR2 ,
                                             i_old_esn_hex             IN VARCHAR2 ,
                                             i_pin                     IN VARCHAR2 ,
                                             i_phone_manf              IN VARCHAR2 ,
                                             i_end_user                IN VARCHAR2 ,
                                             i_account_num             IN VARCHAR2 ,
                                             i_market_code             IN VARCHAR2 ,
                                             i_rate_plan               IN VARCHAR2 ,
                                             i_ld_provider             IN VARCHAR2 ,
                                             i_sequence_num            IN VARCHAR2 ,
                                             i_dealer_code             IN VARCHAR2 ,
                                             i_transmission_method     IN VARCHAR2 ,
                                             i_fax_num                 IN VARCHAR2 ,
                                             i_online_num              IN VARCHAR2 ,
                                             i_email                   IN VARCHAR2 ,
                                             i_network_login           IN VARCHAR2 ,
                                             i_network_password        IN VARCHAR2 ,
                                             i_system_login            IN VARCHAR2 ,
                                             i_system_password         IN VARCHAR2 ,
                                             i_template                IN VARCHAR2 ,
                                             i_exe_name                IN VARCHAR2 ,
                                             i_com_port                IN VARCHAR2 ,
                                             i_status                  IN VARCHAR2 ,
                                             i_status_message          IN VARCHAR2 ,
                                             i_fax_batch_size          IN VARCHAR2 ,
                                             i_fax_batch_q_time        IN VARCHAR2 ,
                                             i_expidite                IN VARCHAR2 ,
                                             i_trans_prof_key          IN VARCHAR2 ,
                                             i_q_transaction           IN VARCHAR2 ,
                                             i_online_num2             IN VARCHAR2 ,
                                             i_fax_num2                IN VARCHAR2 ,
                                             i_creation_date           IN DATE     ,
                                             i_update_date             IN DATE     ,
                                             i_blackout_wait           IN DATE     ,
                                             i_tux_iti_server          IN VARCHAR2 ,
                                             i_transaction_id          IN NUMBER   ,
                                             i_technology_flag         IN VARCHAR2 ,
                                             i_voice_mail              IN VARCHAR2 ,
                                             i_voice_mail_package      IN VARCHAR2 ,
                                             i_caller_id               IN VARCHAR2 ,
                                             i_caller_id_package       IN VARCHAR2 ,
                                             i_call_waiting            IN VARCHAR2 ,
                                             i_call_waiting_package    IN VARCHAR2 ,
                                             i_rtp_server              IN VARCHAR2 ,
                                             i_digital_feature_code    IN VARCHAR2 ,
                                             i_state_field             IN VARCHAR2 ,
                                             i_zip_code                IN VARCHAR2 ,
                                             i_msid                    IN VARCHAR2 ,
                                             i_new_msid_flag           IN VARCHAR2 ,
                                             i_sms                     IN VARCHAR2 ,
                                             i_sms_package             IN VARCHAR2 ,
                                             i_iccid                   IN VARCHAR2 ,
                                             i_old_min                 IN VARCHAR2 ,
                                             i_digital_feature         IN VARCHAR2 ,
                                             i_ota_type                IN VARCHAR2 ,
                                             i_rate_center_no          IN VARCHAR2 ,
                                             i_application_system      IN VARCHAR2 ,
                                             i_subscriber_update       IN VARCHAR2 ,
                                             i_download_date           IN DATE     ,
                                             i_prl_number              IN VARCHAR2 ,
                                             i_amount                  IN NUMBER   ,
                                             i_balance                 IN NUMBER   ,
                                             i_language                IN VARCHAR2 ,
                                             i_exp_date                IN DATE     ,
                                             i_x_mpn                   IN VARCHAR2 ,
                                             i_x_mpn_code              IN VARCHAR2 ,
                                             i_x_pool_name             IN VARCHAR2 ,
                                             i_imsi                    IN VARCHAR2 ,
                                             i_new_imsi_flag           IN VARCHAR2 ,
                                             i_data_saver              IN VARCHAR2 DEFAULT NULL,
                                             i_data_saver_code         IN VARCHAR2 DEFAULT NULL,
                                             i_carrier_feature_objid   IN NUMBER DEFAULT NULL  --CR48373
                                             ) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION exist ( i_transaction_id IN NUMBER) RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_ig IN ig_transaction_type ) RETURN ig_transaction_type,
  MEMBER FUNCTION ins RETURN ig_transaction_type,
  MEMBER FUNCTION upd ( i_transaction_id IN NUMBER) RETURN BOOLEAN,
  MEMBER FUNCTION upd RETURN ig_transaction_type,
  MEMBER FUNCTION del ( i_transaction_id IN  NUMBER) RETURN BOOLEAN,
  MEMBER FUNCTION del RETURN BOOLEAN,
  MEMBER FUNCTION get_template ( i_technology          IN VARCHAR2,
                                 i_trans_profile_objid IN NUMBER ) RETURN VARCHAR2,
  MEMBER FUNCTION get_ig_order_type ( i_actual_order_type IN VARCHAR2 ) RETURN VARCHAR2,
  MEMBER FUNCTION get_ig_transaction_id ( i_call_trans_ojid IN NUMBER ) RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY sa.IG_TRANSACTION_TYPE IS
--
--
CONSTRUCTOR FUNCTION ig_transaction_type
RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;
--
--
CONSTRUCTOR FUNCTION IG_TRANSACTION_TYPE ( i_transaction_id IN NUMBER )
RETURN SELF AS RESULT IS
BEGIN

  -- get the ig transaction attributes
  SELECT ig_transaction_type ( action_item_id         ,
                               carrier_id             ,
                               order_type             ,
                               min                    ,
                               esn                    ,
                               esn_hex                ,
                               old_esn                ,
                               old_esn_hex            ,
                               pin                    ,
                               phone_manf             ,
                               end_user               ,
                               account_num            ,
                               market_code            ,
                               rate_plan              ,
                               ld_provider            ,
                               sequence_num           ,
                               dealer_code            ,
                               transmission_method    ,
                               fax_num                ,
                               online_num             ,
                               email                  ,
                               network_login          ,
                               network_password       ,
                               system_login           ,
                               system_password        ,
                               template               ,
                               exe_name               ,
                               com_port               ,
                               status                 ,
                               status_message         ,
                               fax_batch_size         ,
                               fax_batch_q_time       ,
                               expidite               ,
                               trans_prof_key         ,
                               q_transaction          ,
                               online_num2            ,
                               fax_num2               ,
                               creation_date          ,
                               update_date            ,
                               blackout_wait          ,
                               tux_iti_server         ,
                               transaction_id         ,
                               technology_flag        ,
                               voice_mail             ,
                               voice_mail_package     ,
                               caller_id              ,
                               caller_id_package      ,
                               call_waiting           ,
                               call_waiting_package   ,
                               rtp_server             ,
                               digital_feature_code   ,
                               state_field            ,
                               zip_code               ,
                               msid                   ,
                               new_msid_flag          ,
                               sms                    ,
                               sms_package            ,
                               iccid                  ,
                               old_min                ,
                               digital_feature        ,
                               ota_type               ,
                               rate_center_no         ,
                               application_system     ,
                               subscriber_update      ,
                               download_date          ,
                               prl_number             ,
                               amount                 ,
                               balance                ,
                               language               ,
                               exp_date               ,
                               x_mpn                  ,
                               x_mpn_code             ,
                               x_pool_name            ,
                               imsi                   ,
                               new_imsi_flag          ,
                               NULL                   , -- response
                               NULL                   , -- numeric_value
                               NULL                   , -- varchar2_value
                               skip_ig_validation_flag,
                               NULL                   , -- task objid
                               NULL                   , -- call trans objid
                               cf_extension_count     ,
                               data_saver             ,
                               data_saver_code        ,
                               carrier_feature_objid  ,-- CR48373
                               cf_profile_id          ,-- CR49490
                               rp_ext_objid )          --CR48260
  INTO   SELF
  FROM   gw1.ig_transaction
  WHERE  transaction_id = i_transaction_id;

  -- get the task objid and call trans objid
  BEGIN
    SELECT tt.objid,
           tt.x_task2x_call_trans
    INTO   SELF.task_objid,
           SELF.call_trans_objid
    FROM   gw1.ig_transaction ig,
           table_task tt
    WHERE  ig.transaction_id = i_transaction_id
    AND    ig.action_item_id = tt.task_id;
  EXCEPTION
   WHEN OTHERS THEN
     NULL;
  END;

  --
  SELF.response := 'SUCCESS';

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    SELF.response := 'TRANSACTION NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
    SELF.transaction_id := i_transaction_id;
    RETURN;
END;
--
--
CONSTRUCTOR FUNCTION ig_transaction_type ( i_esn                IN VARCHAR2 ,
                                           i_action_item_id     IN VARCHAR2 ,
                                           i_msid               IN VARCHAR2 ,
                                           i_min                IN VARCHAR2 ,
                                           i_technology_flag    IN VARCHAR2 ,
                                           i_order_type         IN VARCHAR2 ,
                                           i_template           IN VARCHAR2 ,
                                           i_rate_plan          IN VARCHAR2 ,
                                           i_zip_code           IN VARCHAR2 ,
                                           i_transaction_id     IN NUMBER   DEFAULT NULL,
                                           i_phone_manf         IN VARCHAR2 DEFAULT NULL,
                                           i_carrier_id         IN VARCHAR2 DEFAULT NULL,
                                           i_network_login      IN VARCHAR2 DEFAULT NULL,
                                           i_network_password   IN VARCHAR2 DEFAULT NULL,
                                           i_status             IN VARCHAR2 DEFAULT NULL,
                                           i_status_message     IN VARCHAR2 DEFAULT NULL,
                                           i_application_system IN VARCHAR2 DEFAULT NULL )
RETURN SELF AS RESULT AS

BEGIN

  SELF.esn                := i_esn                ;
  SELF.action_item_id     := i_action_item_id     ;
  SELF.msid               := i_msid               ;
  SELF.min                := i_min                ;
  SELF.technology_flag    := i_technology_flag    ;
  SELF.order_type         := i_order_type         ;
  SELF.template           := i_template           ;
  SELF.rate_plan          := i_rate_plan          ;
  SELF.zip_code           := i_zip_code           ;
  SELF.transaction_id     := i_transaction_id     ;
  SELF.phone_manf         := i_phone_manf         ;
  SELF.carrier_id         := i_carrier_id         ;
  SELF.network_login      := i_network_login      ;
  SELF.network_password   := i_network_password   ;
  SELF.status             := i_status             ;
  SELF.status_message     := i_status_message     ;
  SELF.application_system := i_application_system ;

  --
  SELF.response := 'SUCCESS';

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    SELF.response := 'ERROR INITIALIZING IG : ' || SUBSTR(SQLERRM,1,100);
    SELF.esn                := i_esn                ;
    SELF.action_item_id     := i_action_item_id     ;
    SELF.msid               := i_msid               ;
    SELF.min                := i_min                ;
    SELF.technology_flag    := i_technology_flag    ;
    SELF.order_type         := i_order_type         ;
    SELF.template           := i_template           ;
    SELF.rate_plan          := i_rate_plan          ;
    SELF.zip_code           := i_zip_code           ;
    SELF.transaction_id     := i_transaction_id     ;
    SELF.phone_manf         := i_phone_manf         ;
    SELF.carrier_id         := i_carrier_id         ;
    SELF.network_login      := i_network_login      ;
    SELF.network_password   := i_network_password   ;
    SELF.status             := i_status             ;
    SELF.status_message     := i_status_message     ;
    SELF.application_system := i_application_system ;
    RETURN;
END;
--
--
CONSTRUCTOR FUNCTION ig_transaction_type ( i_esn                 IN VARCHAR2 ,
                                           i_action_item_id      IN VARCHAR2 ,
                                           i_msid                IN VARCHAR2 ,
                                           i_min                 IN VARCHAR2 ,
                                           i_technology_flag     IN VARCHAR2 ,
                                           i_order_type          IN VARCHAR2 ,
                                           i_template            IN VARCHAR2 ,
                                           i_rate_plan           IN VARCHAR2 ,
                                           i_zip_code            IN VARCHAR2 ,
                                           i_transaction_id      IN NUMBER   ,
                                           i_phone_manf          IN VARCHAR2 DEFAULT NULL,
                                           i_carrier_id          IN VARCHAR2 DEFAULT NULL,
                                           i_iccid               IN VARCHAR2 DEFAULT NULL,
                                           i_network_login       IN VARCHAR2 DEFAULT NULL,
                                           i_network_password    IN VARCHAR2 DEFAULT NULL,
                                           i_account_num         IN VARCHAR2 ,
                                           i_transmission_method IN VARCHAR2 ,
                                           i_status              IN VARCHAR2 DEFAULT NULL,
                                           i_status_message      IN VARCHAR2 DEFAULT NULL,
                                           i_application_system  IN VARCHAR2 DEFAULT NULL,
                                           i_skip_ig_validation  IN VARCHAR2 DEFAULT NULL,
                                           i_old_esn             IN VARCHAR2 DEFAULT NULL,  --Added for CR47153
                                           i_pin                 IN VARCHAR2 DEFAULT NULL ) --Added for CR56056
RETURN SELF AS RESULT AS

BEGIN

  SELF.esn                      := i_esn                 ;
  SELF.action_item_id           := i_action_item_id      ;
  SELF.msid                     := i_msid                ;
  SELF.min                      := i_min                 ;
  SELF.technology_flag          := i_technology_flag     ;
  SELF.order_type               := i_order_type          ;
  SELF.template                 := i_template            ;
  SELF.rate_plan                := i_rate_plan           ;
  SELF.zip_code                 := i_zip_code            ;
  SELF.transaction_id           := i_transaction_id      ;
  SELF.phone_manf               := i_phone_manf          ;
  SELF.carrier_id               := i_carrier_id          ;
  SELF.iccid                    := i_iccid               ;
  SELF.network_login            := i_network_login       ;
  SELF.network_password         := i_network_password    ;
  SELF.account_num              := i_account_num         ;
  SELF.transmission_method      := i_transmission_method ;
  SELF.status                   := i_status              ;
  SELF.status_message           := i_status_message      ;
  SELF.application_system       := i_application_system  ;
  SELF.skip_ig_validation_flag  := i_skip_ig_validation  ;
  SELF.old_esn                  := i_old_esn             ;  --Added for CR47153
  SELF.pin                      := i_pin                 ;  --Added for CR56056
  --
  SELF.response := 'SUCCESS';

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    SELF.response := 'ERROR INITIALIZING IG : ' || SUBSTR(SQLERRM,1,100);
    SELF.esn                 := i_esn                 ;
    SELF.action_item_id      := i_action_item_id      ;
    SELF.msid                := i_msid                ;
    SELF.min                 := i_min                 ;
    SELF.technology_flag     := i_technology_flag     ;
    SELF.order_type          := i_order_type          ;
    SELF.template            := i_template            ;
    SELF.rate_plan           := i_rate_plan           ;
    SELF.zip_code            := i_zip_code            ;
    SELF.transaction_id      := i_transaction_id      ;
    SELF.phone_manf          := i_phone_manf          ;
    SELF.carrier_id          := i_carrier_id          ;
    SELF.iccid               := i_iccid               ;
    SELF.network_login       := i_network_login       ;
    SELF.network_password    := i_network_password    ;
    SELF.account_num         := i_account_num         ;
    SELF.transmission_method := i_transmission_method ;
    SELF.status              := i_status              ;
    SELF.status_message      := i_status_message      ;
    SELF.application_system  := i_application_system  ;
    SELF.old_esn             := i_old_esn             ;      --Added for CR47153
    SELF.pin                 := i_pin                 ;      --Added for CR56056
    RETURN;
END;
--
--
CONSTRUCTOR FUNCTION ig_transaction_type ( i_action_item_id          IN VARCHAR2 ,
                                           i_carrier_id              IN VARCHAR2 ,
                                           i_order_type              IN VARCHAR2 ,
                                           i_min                     IN VARCHAR2 ,
                                           i_esn                     IN VARCHAR2 ,
                                           i_esn_hex                 IN VARCHAR2 ,
                                           i_old_esn                 IN VARCHAR2 ,
                                           i_old_esn_hex             IN VARCHAR2 ,
                                           i_pin                     IN VARCHAR2 ,
                                           i_phone_manf              IN VARCHAR2 ,
                                           i_end_user                IN VARCHAR2 ,
                                           i_account_num             IN VARCHAR2 ,
                                           i_market_code             IN VARCHAR2 ,
                                           i_rate_plan               IN VARCHAR2 ,
                                           i_ld_provider             IN VARCHAR2 ,
                                           i_sequence_num            IN VARCHAR2 ,
                                           i_dealer_code             IN VARCHAR2 ,
                                           i_transmission_method     IN VARCHAR2 ,
                                           i_fax_num                 IN VARCHAR2 ,
                                           i_online_num              IN VARCHAR2 ,
                                           i_email                   IN VARCHAR2 ,
                                           i_network_login           IN VARCHAR2 ,
                                           i_network_password        IN VARCHAR2 ,
                                           i_system_login            IN VARCHAR2 ,
                                           i_system_password         IN VARCHAR2 ,
                                           i_template                IN VARCHAR2 ,
                                           i_exe_name                IN VARCHAR2 ,
                                           i_com_port                IN VARCHAR2 ,
                                           i_status                  IN VARCHAR2 ,
                                           i_status_message          IN VARCHAR2 ,
                                           i_fax_batch_size          IN VARCHAR2 ,
                                           i_fax_batch_q_time        IN VARCHAR2 ,
                                           i_expidite                IN VARCHAR2 ,
                                           i_trans_prof_key          IN VARCHAR2 ,
                                           i_q_transaction           IN VARCHAR2 ,
                                           i_online_num2             IN VARCHAR2 ,
                                           i_fax_num2                IN VARCHAR2 ,
                                           i_creation_date           IN DATE     ,
                                           i_update_date             IN DATE     ,
                                           i_blackout_wait           IN DATE     ,
                                           i_tux_iti_server          IN VARCHAR2 ,
                                           i_transaction_id          IN NUMBER   ,
                                           i_technology_flag         IN VARCHAR2 ,
                                           i_voice_mail              IN VARCHAR2 ,
                                           i_voice_mail_package      IN VARCHAR2 ,
                                           i_caller_id               IN VARCHAR2 ,
                                           i_caller_id_package       IN VARCHAR2 ,
                                           i_call_waiting            IN VARCHAR2 ,
                                           i_call_waiting_package    IN VARCHAR2 ,
                                           i_rtp_server              IN VARCHAR2 ,
                                           i_digital_feature_code    IN VARCHAR2 ,
                                           i_state_field             IN VARCHAR2 ,
                                           i_zip_code                IN VARCHAR2 ,
                                           i_msid                    IN VARCHAR2 ,
                                           i_new_msid_flag           IN VARCHAR2 ,
                                           i_sms                     IN VARCHAR2 ,
                                           i_sms_package             IN VARCHAR2 ,
                                           i_iccid                   IN VARCHAR2 ,
                                           i_old_min                 IN VARCHAR2 ,
                                           i_digital_feature         IN VARCHAR2 ,
                                           i_ota_type                IN VARCHAR2 ,
                                           i_rate_center_no          IN VARCHAR2 ,
                                           i_application_system      IN VARCHAR2 ,
                                           i_subscriber_update       IN VARCHAR2 ,
                                           i_download_date           IN DATE     ,
                                           i_prl_number              IN VARCHAR2 ,
                                           i_amount                  IN NUMBER   ,
                                           i_balance                 IN NUMBER   ,
                                           i_language                IN VARCHAR2 ,
                                           i_exp_date                IN DATE     ,
                                           i_x_mpn                   IN VARCHAR2 ,
                                           i_x_mpn_code              IN VARCHAR2 ,
                                           i_x_pool_name             IN VARCHAR2 ,
                                           i_imsi                    IN VARCHAR2 ,
                                           i_new_imsi_flag           IN VARCHAR2 ,
                                           i_data_saver              IN VARCHAR2 DEFAULT NULL,
                                           i_data_saver_code         IN VARCHAR2 DEFAULT NULL,
                                           i_carrier_feature_objid   IN NUMBER DEFAULT NULL )  --CR48373
RETURN SELF AS RESULT AS

BEGIN

  SELF.action_item_id       := i_action_item_id         ;
  SELF.carrier_id           := i_carrier_id             ;
  SELF.order_type           := i_order_type             ;
  SELF.min                  := i_min                    ;
  SELF.esn                  := i_esn                    ;
  SELF.esn_hex              := i_esn_hex                ;
  SELF.old_esn              := i_old_esn                ;
  SELF.old_esn_hex          := i_old_esn_hex            ;
  SELF.pin                  := i_pin                    ;
  SELF.phone_manf           := i_phone_manf             ;
  SELF.end_user             := i_end_user               ;
  SELF.account_num          := i_account_num            ;
  SELF.market_code          := i_market_code            ;
  SELF.rate_plan            := i_rate_plan              ;
  SELF.ld_provider          := i_ld_provider            ;
  SELF.sequence_num         := i_sequence_num           ;
  SELF.dealer_code          := i_dealer_code            ;
  SELF.transmission_method  := i_transmission_method    ;
  SELF.fax_num              := i_fax_num                ;
  SELF.online_num           := i_online_num             ;
  SELF.email                := i_email                  ;
  SELF.network_login        := i_network_login          ;
  SELF.network_password     := i_network_password       ;
  SELF.system_login         := i_system_login           ;
  SELF.system_password      := i_system_password        ;
  SELF.template             := i_template               ;
  SELF.exe_name             := i_exe_name               ;
  SELF.com_port             := i_com_port               ;
  SELF.status               := i_status                 ;
  SELF.status_message       := i_status_message         ;
  SELF.fax_batch_size       := i_fax_batch_size         ;
  SELF.fax_batch_q_time     := i_fax_batch_q_time       ;
  SELF.expidite             := i_expidite               ;
  SELF.trans_prof_key       := i_trans_prof_key         ;
  SELF.q_transaction        := i_q_transaction          ;
  SELF.online_num2          := i_online_num2            ;
  SELF.fax_num2             := i_fax_num2               ;
  SELF.creation_date        := i_creation_date          ;
  SELF.update_date          := i_update_date            ;
  SELF.blackout_wait        := i_blackout_wait          ;
  SELF.tux_iti_server       := i_tux_iti_server         ;
  SELF.transaction_id       := i_transaction_id         ;
  SELF.technology_flag      := i_technology_flag        ;
  SELF.voice_mail           := i_voice_mail             ;
  SELF.voice_mail_package   := i_voice_mail_package     ;
  SELF.caller_id            := i_caller_id              ;
  SELF.caller_id_package    := i_caller_id_package      ;
  SELF.call_waiting         := i_call_waiting           ;
  SELF.call_waiting_package := i_call_waiting_package   ;
  SELF.rtp_server           := i_rtp_server             ;
  SELF.digital_feature_code := i_digital_feature_code   ;
  SELF.state_field          := i_state_field            ;
  SELF.zip_code             := i_zip_code               ;
  SELF.msid                 := i_msid                   ;
  SELF.new_msid_flag        := i_new_msid_flag          ;
  SELF.sms                  := i_sms                    ;
  SELF.sms_package          := i_sms_package            ;
  SELF.iccid                := i_iccid                  ;
  SELF.old_min              := i_old_min                ;
  SELF.digital_feature      := i_digital_feature        ;
  SELF.ota_type             := i_ota_type               ;
  SELF.rate_center_no       := i_rate_center_no         ;
  SELF.application_system   := i_application_system     ;
  SELF.subscriber_update    := i_subscriber_update      ;
  SELF.download_date        := i_download_date          ;
  SELF.prl_number           := i_prl_number             ;
  SELF.amount               := i_amount                 ;
  SELF.balance              := i_balance                ;
  SELF.language             := i_language               ;
  SELF.exp_date             := i_exp_date               ;
  SELF.x_mpn                := i_x_mpn                  ;
  SELF.x_mpn_code           := i_x_mpn_code             ;
  SELF.x_pool_name          := i_x_pool_name            ;
  SELF.imsi                 := i_imsi                   ;
  SELF.new_imsi_flag        := i_new_imsi_flag          ;
  SELF.data_saver           := i_data_saver             ;
  SELF.data_saver_code      := i_data_saver_code        ;
  SELF.carrier_feature_objid := i_carrier_feature_objid ;--CR48373
  --
  SELF.response := 'SUCCESS';

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    SELF.response := 'ERROR INITIALIZING IG : ' || SUBSTR(SQLERRM,1,100);
    SELF.status_message       := i_status_message         ;
    SELF.fax_batch_size       := i_fax_batch_size         ;
    SELF.fax_batch_q_time     := i_fax_batch_q_time       ;
    SELF.expidite             := i_expidite               ;
    SELF.trans_prof_key       := i_trans_prof_key         ;
    SELF.q_transaction        := i_q_transaction          ;
    SELF.online_num2          := i_online_num2            ;
    SELF.fax_num2             := i_fax_num2               ;
    SELF.creation_date        := i_creation_date          ;
    SELF.update_date          := i_update_date            ;
    SELF.blackout_wait        := i_blackout_wait          ;
    SELF.tux_iti_server       := i_tux_iti_server         ;
    SELF.transaction_id       := i_transaction_id         ;
    SELF.technology_flag      := i_technology_flag        ;
    SELF.voice_mail           := i_voice_mail             ;
    SELF.voice_mail_package   := i_voice_mail_package     ;
    SELF.caller_id            := i_caller_id              ;
    SELF.caller_id_package    := i_caller_id_package      ;
    SELF.call_waiting         := i_call_waiting           ;
    SELF.call_waiting_package := i_call_waiting_package   ;
    SELF.rtp_server           := i_rtp_server             ;
    SELF.digital_feature_code := i_digital_feature_code   ;
    SELF.state_field          := i_state_field            ;
    SELF.zip_code             := i_zip_code               ;
    SELF.msid                 := i_msid                   ;
    SELF.new_msid_flag        := i_new_msid_flag          ;
    SELF.sms                  := i_sms                    ;
    SELF.sms_package          := i_sms_package            ;
    SELF.iccid                := i_iccid                  ;
    SELF.old_min              := i_old_min                ;
    SELF.digital_feature      := i_digital_feature        ;
    SELF.ota_type             := i_ota_type               ;
    SELF.rate_center_no       := i_rate_center_no         ;
    SELF.application_system   := i_application_system     ;
    SELF.subscriber_update    := i_subscriber_update      ;
    SELF.download_date        := i_download_date          ;
    SELF.prl_number           := i_prl_number             ;
    SELF.amount               := i_amount                 ;
    SELF.balance              := i_balance                ;
    SELF.language             := i_language               ;
    SELF.exp_date             := i_exp_date               ;
     SELF.x_mpn                := i_x_mpn                 ;
    SELF.x_mpn_code           := i_x_mpn_code             ;
    SELF.x_pool_name          := i_x_pool_name            ;
    SELF.imsi                 := i_imsi                   ;
    SELF.new_imsi_flag        := i_new_imsi_flag          ;
    RETURN;
END;
--
--
MEMBER FUNCTION exist RETURN BOOLEAN IS

  ig  ig_transaction_type := ig_transaction_type ( i_transaction_id => SELF.transaction_id );

BEGIN
  IF ig.esn IS NOT NULL THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;
END;
--
--
-- Validate if a row exists in the table
MEMBER FUNCTION exist ( i_transaction_id IN NUMBER) RETURN BOOLEAN IS

  ig  ig_transaction_type := ig_transaction_type ( i_transaction_id => i_transaction_id );

BEGIN
  IF ig.esn IS NOT NULL THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
--
--
MEMBER FUNCTION ins RETURN ig_transaction_type IS
  ig     ig_transaction_type := SELF;
  i      ig_transaction_type;
BEGIN
  i := ig.ins ( i_ig => ig );
  RETURN i;
END ins;
--
--
-- Procedure to add the row based on ESN or MIN with all the proper validations.
MEMBER FUNCTION ins ( i_ig IN ig_transaction_type ) RETURN ig_transaction_type IS

  ig  ig_transaction_type := i_ig;

BEGIN

  -- Make sure the min is a mandatory input parameter
  IF ig.min IS NULL THEN
    --
    ig.response := 'MIN NOT FOUND';
    --
    RETURN ig;
  END IF;

  IF ig.transaction_id IS NULL THEN
    ig.transaction_id := gw1.trans_id_seq.NEXTVAL;
  END IF;

  IF ig.update_date IS NULL THEN
    ig.update_date := SYSDATE;
  END IF;

  -- skip ig validations
  IF  NVL(ig.skip_ig_validation_flag,'N') = 'N' THEN

  -- Make sure ESN is valid
  IF ig.esn IS NULL THEN
    ig.response := 'NO ESN PASSED';
    RETURN ig;
  END IF;

  -- Make sure the rate plan is valid
  IF ig.rate_plan IS NULL THEN
    --
    ig.response := 'RATE PLAN NOT FOUND';
    --
    RETURN ig;
  END IF;

  -- Make sure the template is valid
  IF ig.template IS NULL THEN
    --
    ig.response  := 'TEMPLATE NOT FOUND';
    --
    RETURN ig;
  END IF;

  -- Make sure the technology flag is valid
  IF ig.technology_flag IS NULL THEN
    --
    ig.response  := 'TECHNOLOGY FLAG NOT FOUND';
    --
    RETURN ig;
  END IF;

  -- Make sure the zip code is valid
  IF ig.zip_code IS NULL THEN
    --
    ig.response  := 'ZIP CODE NOT FOUND';
    --
    RETURN ig;
  END IF;

  END IF;

  -- Inserting into ig_transaction
  INSERT INTO gw1.ig_transaction (action_item_id,
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
                                  x_pool_name,
                                  imsi,
                                  new_imsi_flag,
                                  data_saver,
                                  data_saver_code,
                                  carrier_feature_objid)  --CR48373
                          VALUES (ig.action_item_id,
                                  ig.carrier_id,
                                  ig.order_type,
                                  ig.min,
                                  ig.esn,
                                  ig.esn_hex,
                                  ig.old_esn,
                                  ig.old_esn_hex,
                                  ig.pin,
                                  ig.phone_manf,
                                  ig.end_user,
                                  ig.account_num,
                                  ig.market_code,
                                  ig.rate_plan,
                                  ig.ld_provider,
                                  ig.sequence_num,
                                  ig.dealer_code,
                                  ig.transmission_method,
                                  ig.fax_num,
                                  ig.online_num,
                                  ig.email,
                                  ig.network_login,
                                  ig.network_password,
                                  ig.system_login,
                                  ig.system_password,
                                  ig.template,
                                  ig.exe_name,
                                  ig.com_port,
                                  ig.status,
                                  ig.status_message,
                                  ig.fax_batch_size,
                                  ig.fax_batch_q_time,
                                  ig.expidite,
                                  ig.trans_prof_key,
                                  ig.q_transaction,
                                  ig.online_num2,
                                  ig.fax_num2,
                                  ig.creation_date,
                                  ig.update_date,
                                  ig.blackout_wait,
                                  ig.tux_iti_server,
                                  ig.transaction_id,
                                  ig.technology_flag,
                                  ig.voice_mail,
                                  ig.voice_mail_package,
                                  ig.caller_id,
                                  ig.caller_id_package,
                                  ig.call_waiting,
                                  ig.call_waiting_package,
                                  ig.rtp_server,
                                  ig.digital_feature_code,
                                  ig.state_field,
                                  ig.zip_code,
                                  ig.msid,
                                  ig.new_msid_flag,
                                  ig.sms,
                                  ig.sms_package,
                                  ig.iccid,
                                  ig.old_min,
                                  ig.digital_feature,
                                  ig.ota_type,
                                  ig.rate_center_no,
                                  ig.application_system,
                                  ig.subscriber_update,
                                  ig.download_date,
                                  ig.prl_number,
                                  ig.amount,
                                  ig.balance,
                                  ig.language,
                                  ig.exp_date,
                                  ig.x_mpn,
                                  ig.x_mpn_code,
                                  ig.x_pool_name,
                                  ig.imsi,
                                  ig.new_imsi_flag,
                                  ig.data_saver,
                                  ig.data_saver_code,
                                  ig.carrier_feature_objid);  --CR48373

  dbms_output.put_line(NVL(SQL%ROWCOUNT,0) || ' row(s) created in IG (' || ig.transaction_id || ')');

  --
  RETURN ig;

EXCEPTION
  WHEN OTHERS THEN
    ig.response := ig.response || '|ERROR INSERTING IG RECORD: ' || SUBSTR(SQLERRM,1,100);
    RETURN ig;
END ins;
--
--
-- Function to expire a row
MEMBER FUNCTION upd ( i_transaction_id IN NUMBER) RETURN BOOLEAN IS
BEGIN
  RETURN TRUE;
END upd;
--
--
-- Function to update a row
MEMBER FUNCTION upd RETURN ig_transaction_type IS
  ig  ig_transaction_type := SELF;
BEGIN
  ig.response := 'SUCCESS';
  RETURN ig_transaction_type;
END upd;
--
--
MEMBER FUNCTION del RETURN BOOLEAN IS
  ig ig_transaction_type := ig_transaction_type ( SELF.transaction_id );
BEGIN
   RETURN ig.del (SELF.transaction_id);
END;
--
--
MEMBER FUNCTION del ( i_transaction_id IN NUMBER) RETURN BOOLEAN IS
  ig ig_transaction_type := SELF;
BEGIN

  DELETE gw1.ig_transaction
  WHERE  transaction_id = i_transaction_id;

  ig.response := 'SUCCESS';

  RETURN TRUE;

EXCEPTION
  WHEN others THEN
    ig.response := 'ERROR DELETING IG TRANSACTION';
    RETURN FALSE;
END del;
--
--
MEMBER FUNCTION get_template ( i_technology          IN VARCHAR2 ,
                               i_trans_profile_objid IN NUMBER   ) RETURN VARCHAR2 IS

  ig  ig_transaction_type := SELF;

BEGIN

  BEGIN
    SELECT CASE i_technology
                 WHEN 'GSM'  THEN x_gsm_trans_template
                 WHEN 'CDMA' THEN x_d_trans_template
                         ELSE x_transmit_template
           END template
    INTO   ig.template
    FROM   table_x_trans_profile
    WHERE  objid = i_trans_profile_objid;
  EXCEPTION
    WHEN others THEN
      RETURN NULL;
  END;

  RETURN ig.template;

EXCEPTION
  WHEN others THEN
    RETURN NULL;
END get_template;
--
--
MEMBER FUNCTION get_ig_order_type ( i_actual_order_type IN VARCHAR2 ) RETURN VARCHAR2 IS

  ig  ig_transaction_type := SELF;

BEGIN

  BEGIN
    SELECT x_ig_order_type
    INTO   ig.order_type
    FROM   sa.x_ig_order_type
    WHERE  x_actual_order_type = i_actual_order_type;
   EXCEPTION
     WHEN others THEN
           RETURN NULL;
  END;

  RETURN ig.order_type;

EXCEPTION
  WHEN others THEN
    RETURN NULL;
END get_ig_order_type;
--
--
MEMBER FUNCTION get_ig_transaction_id ( i_call_trans_ojid IN NUMBER ) RETURN NUMBER IS

  ig  ig_transaction_type := SELF;

BEGIN

  BEGIN
     SELECT transaction_id
       INTO ig.transaction_id
       FROM gw1.ig_transaction ig,
            table_task tt
      WHERE 1 = 1
        AND ig.action_item_id = tt.task_id
        AND tt.x_task2x_call_trans = i_call_trans_ojid;
   EXCEPTION
     WHEN others THEN
           RETURN NULL;
  END;

  RETURN ig.transaction_id;

EXCEPTION
  WHEN others THEN
    RETURN NULL;
END get_ig_transaction_id;
--
--
END;
/