CREATE OR REPLACE TYPE sa."RED_CARD_TYPE" AS OBJECT (
  esn                             VARCHAR2(30),
  min                             VARCHAR2(30),
  account_group_objid             NUMBER(22),
  account_group_uid               VARCHAR2(50),
  account_group_name              VARCHAR2(50),
  application_req_num             VARCHAR2(100),
  brand_leasing_flag              VARCHAR2(1),
  brand_shared_group_flag         VARCHAR2(1),
  bus_org_id                      VARCHAR2(40),
  bus_org_objid                   NUMBER(22),
  bus_org_flow                    VARCHAR2(1),
  carrier_objid                   NUMBER(22),
  contact_objid                   NUMBER(22),
  conversion_rate                 VARCHAR2(50),
  cos                             VARCHAR2(30),
  data_speed                      VARCHAR2(50),
  deactivation_reason             VARCHAR2(30),
  dealer_id                       VARCHAR2(80),
  device_type                     VARCHAR2(50),
  do_not_email                    NUMBER(1),
  do_not_phone                    NUMBER(1),
  do_not_sms                      NUMBER(1),
  do_not_mail                     NUMBER(1),
  esn_new_personality_objid       NUMBER(22),
  esn_part_inst_code              NUMBER,
  esn_part_inst_objid             NUMBER,
  esn_part_inst_status            VARCHAR2(30),
  esn_part_number                 VARCHAR2(30),
  expiration_date                 DATE,
  firmware                        VARCHAR2(50),
  first_name                      VARCHAR2(30),
  last_name                       VARCHAR2(30),
  group_available_capacity        NUMBER(3),
  group_total_lines               NUMBER(3),
  group_allowed_lines             NUMBER(3),
  group_service_plan_objid        NUMBER(22),
  group_start_date                DATE,
  group_leased_flag               VARCHAR2(1),
  group_contact_objid             NUMBER,
  iccid                           VARCHAR2(30),
  ild_transaction_objid           NUMBER(22),
  ild_transaction_status          VARCHAR2(10),
  install_date                    DATE,
  inv_bin_objid                   NUMBER,
  is_swb_carrier                  NUMBER(1),
  last_cycle_date                 DATE,
  last_redemption_date            DATE,
  lease_status                    VARCHAR2(20),
  lease_blocked_slots             NUMBER(3),
  member_objid                    NUMBER(22),
  member_status                   VARCHAR2(30),
  member_start_date               DATE,
  member_end_date                 DATE,
  member_master_flag              VARCHAR2(1),
  meter_source_data               NUMBER(22),
  meter_source_ild                NUMBER(22),
  meter_source_sms                NUMBER(22),
  meter_source_voice              NUMBER(22),
  min_cool_end_date               DATE,
  min_warr_end_date               DATE,
  min_part_inst_code              NUMBER,
  min_part_inst_objid             NUMBER,
  min_part_inst_status            VARCHAR2(30),
  min_new_personality_objid       NUMBER(22),
  min_personality_objid           NUMBER(22),
  min_to_esn_part_inst_objid      NUMBER(22),
  model_type                      VARCHAR2(50),
  motricity_denomination          VARCHAR2(50),
  non_ppe_flag                    VARCHAR2(50),
  notify_carrier                  NUMBER,
  parent_name                     VARCHAR2(40),
  part_class_objid                NUMBER(22),
  part_class_name                 VARCHAR2(50),
  phone_generation                VARCHAR2(50),
  phone_manufacturer              VARCHAR2(30),
  pin                             VARCHAR2(30),
  pin_part_number                 VARCHAR2(30),
  pgm_enroll_charge_type          VARCHAR2(30),
  pgm_enroll_objid                NUMBER(22),
  pgm_enroll_next_charge_date     DATE,
  port_in                         NUMBER,
  program_parameter_objid         NUMBER(22),
  propagate_flag                  NUMBER(4),
  queued_days                     NUMBER(4),
  red_card_code                   VARCHAR2(30),
  rate_plan                       VARCHAR2(60),
  safelink_flag                   VARCHAR2(1),
  safelink_pgm_param_objid        NUMBER(22),
  security_pin                    VARCHAR2(6),
  service_end_date                DATE,
  service_order_stage_objid       NUMBER(22),
  service_order_stage_status      VARCHAR2(30),
  service_plan_objid              NUMBER(22),
  service_plan_data               NUMBER(12,2),
  service_plan_name               VARCHAR2(100),
  service_plan_part_number        VARCHAR2(30),
  service_plan_price              NUMBER,
  service_plan_group              VARCHAR2(50),
  service_plan_days               NUMBER,
  sim_part_number                 VARCHAR2(30),
  site_id                         VARCHAR2(80),
  site_part_objid                 NUMBER,
  site_part_status                VARCHAR2(50),
  short_parent_name               VARCHAR2(40),
  smp                             VARCHAR2(30),
  subscriber_uid                  VARCHAR2(50),
  subscriber_spr_objid            NUMBER(22),
  technology                      VARCHAR2(50),
  throttle_date                   DATE,
  throttle_policy_id              NUMBER(22),
  web_user_objid                  NUMBER(22),
  web_contact_objid               NUMBER(22),
  web_login_name                  VARCHAR2(50),
  wf_mac_id                       VARCHAR2(50),
  zipcode                         VARCHAR2(10),
  --
  posa_card_flag                  VARCHAR2(1),
  units                           NUMBER,
  redeem_units                    NUMBER,
  redeem_days                     NUMBER,
  card_brand                      VARCHAR2(50),
  card_part_number                VARCHAR2(30),
  card_part_inst_status           VARCHAR2(30),
  msgnum                          NUMBER(3),
  msgstr                          VARCHAR2(1000),
  error_pin                       VARCHAR2(1000),
  description                     VARCHAR2(255),
  part_number_description         VARCHAR2(255),
  part_number                     VARCHAR2(50),
  card_type                       VARCHAR2(20),
  part_type                       VARCHAR2(20),
  web_card_desc                   VARCHAR2(100),
  sp_web_card_desc                VARCHAR2(100),
  ild_type                        NUMBER,
  error_str                       VARCHAR2(1000),
  posa_airtime                    VARCHAR2(1),
  inactive_posa_flag              VARCHAR2(1),
  posa_result                     VARCHAR2(1000),
  card_units                      NUMBER,
  call_trans_objid                NUMBER,
  is_card_redeemed_flag           VARCHAR2(1),
  is_esn_enrolled_flag            NUMBER,
  promo_code                      VARCHAR2(10),
  promo_objid                     NUMBER,
  card_part_number_objid          NUMBER,
  dll                             VARCHAR2(50),
  card_esn_compatibility_flag     VARCHAR2(1),
  esn_grp_compatibility_flag      VARCHAR2(1),
  vas_part_class_name             VARCHAR2(100),
  sl_program_provision_flag       NUMBER(2),
  gtt_part_inst_objid             NUMBER,
  gtt_posa_card_objid             NUMBER,
  toss_att_customer               VARCHAR2(100),
  toss_att_location               VARCHAR2(100),
  toss_posa_code                  VARCHAR2(100),
  toss_posa_date                  DATE,
  tf_extract_flag                 VARCHAR2(1),
  tf_extract_date                 DATE,
  toss_site_id                    VARCHAR2(40),
  toss_posa_action                VARCHAR2(40),
  remote_trans_id                 VARCHAR2(20),
  sourcesystem                    VARCHAR2(30),
  toss_att_trans_date             DATE,
  balance_metering                VARCHAR(100),
  -- part inst attributes
  part_inst_objid                 NUMBER           ,
  part_good_qty                   NUMBER           ,
  part_bad_qty                    NUMBER           ,
  part_serial_no                  VARCHAR2(30)     ,
  part_mod                        VARCHAR2(10)     ,
  part_bin                        VARCHAR2(20)     ,
  last_pi_date                    DATE             ,
  pi_tag_no                       VARCHAR2(8)      ,
  last_cycle_ct                   DATE             ,
  next_cycle_ct                   DATE             ,
  last_mod_time                   DATE             ,
  last_trans_time                 DATE             ,
  transaction_id                  VARCHAR2(20)     ,
  date_in_serv                    DATE             ,
  warr_end_date                   DATE             ,
  repair_date                     DATE             ,
  part_status                     VARCHAR2(40)     ,
  pick_request                    VARCHAR2(255)    ,
  good_res_qty                    NUMBER           ,
  bad_res_qty                     NUMBER           ,
  dev                             NUMBER           ,
  insert_date                     DATE             ,
  sequence                        NUMBER           ,
  creation_date                   DATE             ,
  po_num                          VARCHAR2(30)     ,
  red_code                        VARCHAR2(30)     ,
  domain                          VARCHAR2(20)     ,
  deactivation_flag               NUMBER           ,
  reactivation_flag               NUMBER           ,
  cool_end_date                   DATE             ,
  part_inst_status                VARCHAR2(20)     ,
  npa                             VARCHAR2(10)     ,
  nxx                             VARCHAR2(10)     ,
  ext                             VARCHAR2(10)     ,
  order_number                    VARCHAR2(40)     ,
  part_inst2inv_bin               NUMBER           ,
  n_part_inst2part_mod            NUMBER           ,
  fulfill2demand_dtl              NUMBER           ,
  part_inst2x_pers                NUMBER           ,
  part_inst2x_new_pers            NUMBER           ,
  part_inst2carrier_mkt           NUMBER           ,
  created_by2user                 NUMBER           ,
  status2x_code_table             NUMBER           ,
  part_to_esn2part_inst           NUMBER           ,
  part_inst2site_part             NUMBER           ,
  ld_processed                    VARCHAR2(10)     ,
  dtl2part_inst                   NUMBER           ,
  eco_new2part_inst               NUMBER           ,
  hdr_ind                         NUMBER           ,
  msid                            VARCHAR2(30)     ,
  part_inst2contact               NUMBER           ,
  clear_tank                      NUMBER           ,
  hex_serial_no                   VARCHAR2(30)     ,
  parent_part_serial_no           VARCHAR2(30)     ,
  cpo_manufacturer                VARCHAR2(240)    ,
  expire_addon_buckets            addon_bucket_details_tab, -- CR49721
  --
  response                        VARCHAR2(1000),
  numeric_value                   NUMBER,
  varchar2_value                  VARCHAR2(2000),
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION red_card_type RETURN SELF AS RESULT,
  -- Constructor used to initialize the ESN and or MIN
  CONSTRUCTOR FUNCTION red_card_type ( i_esn  IN VARCHAR2,
                                       i_min  IN VARCHAR2 DEFAULT NULL ) RETURN SELF AS RESULT,
  -- Constructor used to initialize the GTT PART INST table
  CONSTRUCTOR FUNCTION red_card_type ( i_part_serial_no          IN VARCHAR2,
                                       i_domain                  IN VARCHAR2,
                                       i_red_code                IN VARCHAR2,
                                       i_part_inst_status        IN VARCHAR2,
                                       i_insert_date             IN DATE,
                                       i_creation_date           IN DATE,
                                       i_po_num                  IN VARCHAR2,
                                       i_order_number            IN VARCHAR2,
                                       i_created_by2user         IN NUMBER,
                                       i_status2x_code_table     IN NUMBER,
                                       i_n_part_inst2part_mod    IN NUMBER,
                                       i_part_inst2inv_bin       IN NUMBER,
                                       i_last_trans_time         IN DATE,
                                       i_parent_part_serial_no   IN VARCHAR2) RETURN SELF AS RESULT,
  -- Constructor used to initialize the gtt part inst
  CONSTRUCTOR FUNCTION red_card_type ( i_part_number         IN VARCHAR2,
                                       i_part_serial_no      IN VARCHAR2,
                                       i_toss_att_customer   IN VARCHAR2,
                                       i_toss_att_location   IN VARCHAR2,
                                       i_toss_posa_code      IN VARCHAR2,
                                       i_toss_posa_date      IN DATE,
                                       i_tf_extract_flag     IN VARCHAR2,
                                       i_tf_extract_date     IN DATE,
                                       i_toss_site_id        IN VARCHAR2,
                                       i_toss_posa_action    IN VARCHAR2,
                                       i_remote_trans_id     IN VARCHAR2,
                                       i_sourcesystem        IN VARCHAR2,
                                       i_toss_att_trans_date IN DATE ) RETURN SELF AS RESULT,
  -- Function used to convert a pin to an smp
  MEMBER FUNCTION convert_pin_to_smp ( i_red_card_code IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to convert an smp to an pin
  MEMBER FUNCTION convert_smp_to_pin ( i_smp IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get all the attributes for a particular customer
  MEMBER FUNCTION retrieve RETURN red_card_type,
  -- Function used to get all the attributes for a particular customer
  MEMBER FUNCTION retrieve ( i_esn IN VARCHAR2 ) RETURN red_card_type,
  -- Function used to get all the attributes for a particular group
  MEMBER FUNCTION retrieve_group ( i_account_group_objid IN NUMBER ) RETURN red_card_type,
  -- Function used to get all the attributes for a particular customer by login name
  MEMBER FUNCTION retrieve_login ( i_login_name IN VARCHAR2 ) RETURN red_card_type,
  -- Function used to get all the attributes for a particular customer by login name
  MEMBER FUNCTION retrieve_login ( i_login_name IN VARCHAR2 ,
                                   i_bus_org_id IN VARCHAR2 ) RETURN red_card_type,
  -- Function used to get all the attributes for a particular customer by min
  MEMBER FUNCTION retrieve_min ( i_min IN VARCHAR2 ) RETURN red_card_type,
  -- Function used to get all the attributes for a particular pin
  MEMBER FUNCTION retrieve_pin ( i_red_card_code IN VARCHAR2 ) RETURN red_card_type,
  -- Function used to determine when the brand allows leasing
  MEMBER FUNCTION get_leasing_flag ( i_bus_org_objid  IN NUMBER) RETURN VARCHAR2,
  -- Function used to get the brand
  MEMBER FUNCTION get_bus_org_id ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get the brand objid
  MEMBER FUNCTION get_bus_org_objid ( i_esn IN VARCHAR2 ) RETURN NUMBER,
  -- Function used to get the necessary attributes for the cos rule engine
  MEMBER FUNCTION get_cos ( i_esn                IN VARCHAR2,
                            i_min                IN VARCHAR2,
                            i_part_class_name    IN VARCHAR2,
                            i_bus_org_objid      IN NUMBER,
                            i_parent_name        IN VARCHAR2,
                            i_service_plan_objid IN NUMBER,
                            i_site_id            IN VARCHAR2,
                            i_as_of_date         IN DATE DEFAULT SYSDATE ) RETURN VARCHAR2,
  -- Overloaded method used to get the necessary attributes to calculate the cos from the rule engine
  MEMBER FUNCTION get_cos ( i_esn                IN VARCHAR2,
                            i_as_of_date         IN DATE DEFAULT SYSDATE ) RETURN VARCHAR2,
  -- Function used to get the cos value from a given MIN in Clarify
  MEMBER FUNCTION get_min_cos_value  ( i_min              IN VARCHAR2,
                                       i_as_of_date       IN DATE DEFAULT SYSDATE,
                                       i_bypass_date_flag IN VARCHAR2 DEFAULT 'N' ) RETURN VARCHAR2,
  -- Function used to get the necessary attributes for the cos rule engine
  MEMBER FUNCTION get_cos_attributes ( i_esn IN VARCHAR2 ) RETURN red_card_type,
  -- Function used get the expiration date from site part
  MEMBER FUNCTION get_expiration_date ( i_esn IN VARCHAR2 ) RETURN DATE,
  -- Function used get the last redemption date from site part
  MEMBER FUNCTION get_last_redemption_date ( i_esn IN VARCHAR2) RETURN DATE,
  -- Function used to get the ota conversion rate
  MEMBER FUNCTION get_ota_conversion_rate ( i_esn_part_inst_objid IN NUMBER ) RETURN VARCHAR2,
  -- Function used to get all the attributes related to part class
  MEMBER FUNCTION get_part_class_attributes ( i_esn IN VARCHAR2 ) RETURN red_card_type,
  -- Function used to get the attributes pertinent to a port out request
  MEMBER FUNCTION get_port_out_attributes ( i_min IN VARCHAR2 ) RETURN red_card_type,
  -- Function used to get the propagate flag from the rate plan table
  MEMBER FUNCTION get_propagate_flag ( i_rate_plan IN VARCHAR2 ) RETURN NUMBER,
  -- Function used to get the rate plan of an ESN
  MEMBER FUNCTION get_rate_plan ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get the attributes related to a service plan
  MEMBER FUNCTION get_service_plan_attributes RETURN red_card_type,
  -- Function used to determine when the brand allows shared groups
  MEMBER FUNCTION get_shared_group_flag ( i_bus_org_id IN VARCHAR2) RETURN VARCHAR2,
  -- Added on 11/26/2014 by Juda Pena to determine if the esn's brand allows shared groups
  MEMBER FUNCTION get_shared_group_flag ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get the short description of the parent name based on the logic from the previous get inquiry process
  MEMBER FUNCTION get_short_parent_name ( i_parent_name IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get the web user objid
  MEMBER FUNCTION get_web_user_attributes RETURN red_card_type,
  MEMBER FUNCTION retrieve_red_card ( i_red_card   IN VARCHAR2 ,
                                      i_smp_number IN VARCHAR2 ) RETURN red_card_type,
  MEMBER FUNCTION get_esn ( i_call_trans_objid IN NUMBER) RETURN red_card_type,
  MEMBER FUNCTION get_esn ( i_part_inst_objid IN NUMBER) RETURN red_card_type,
  MEMBER FUNCTION is_card_redeemed ( i_esn IN VARCHAR2,
                                     i_red_card IN VARCHAR2 ) RETURN red_card_type,
  MEMBER FUNCTION get_gtt_part_number_attributes ( i_red_card IN VARCHAR2 ) RETURN red_card_type,
  MEMBER FUNCTION get_gtt_esn_attributes ( i_esn IN VARCHAR2 ) RETURN red_card_type,
  MEMBER FUNCTION is_card_compatible_with_esn ( i_esn_part_class_objid  IN NUMBER ,
                                                i_card_part_class_objid IN NUMBER ) RETURN red_card_type,
  MEMBER FUNCTION get_vas_part_class_name ( i_part_class_objid IN NUMBER ) RETURN red_card_type,
  -- Function used to get the safelink attributes and flags
  MEMBER FUNCTION get_safelink_flag ( i_esn                   IN VARCHAR2 ,
                                      i_esn_part_number_objid IN NUMBER   ) RETURN red_card_type,
  -- Function used to delete the gtt_part_inst table
  MEMBER FUNCTION del_gtt_part_inst ( i_gtt_part_inst_objid IN NUMBER ) RETURN VARCHAR2,
  MEMBER FUNCTION save_gtt_part_inst ( io_gpi IN OUT red_card_type ) RETURN VARCHAR2,
  -- Function used to delete the gtt_posa_card table
  MEMBER FUNCTION del_gtt_posa_card ( i_gtt_posa_card_objid IN NUMBER ) RETURN VARCHAR2,
  MEMBER FUNCTION save_gtt_posa_card ( io_gpc IN OUT red_card_type ) RETURN VARCHAR2,
  MEMBER FUNCTION choose_random_esn ( i_red_card IN VARCHAR2 ) RETURN VARCHAR2,
  MEMBER FUNCTION is_esn_compatible_with_group ( i_account_group_objid IN NUMBER,
                                                 i_esn                 IN VARCHAR2 ) RETURN VARCHAR2,
  MEMBER FUNCTION retrieve_gtt_pin ( i_red_card IN VARCHAR2 ) RETURN red_card_type,
  MEMBER FUNCTION retrieve_pin ( i_red_card IN VARCHAR2 ) RETURN red_card_type,
  MEMBER FUNCTION get_smartphone ( i_esn IN VARCHAR2) RETURN NUMBER,
  MEMBER FUNCTION is_sl_red_card_compatible ( i_red_code IN VARCHAR2) RETURN BOOLEAN,
  -- CR43162  Added function for qpintoesn copy of standalone qpintoesn
  MEMBER FUNCTION qPinToEsn(  i_esn      IN   VARCHAR2,
                              i_pin      IN   VARCHAR2,
                              o_err_code OUT  VARCHAR2,
                              o_err_msg  OUT  VARCHAR2) RETURN NUMBER,
  -- function get brand using partnumber
  MEMBER FUNCTION get_brand_partnum ( i_partnumber IN VARCHAR2) RETURN VARCHAR2,
  -- function get brand using pin
  MEMBER FUNCTION get_brand_pin     ( i_pin        IN VARCHAR2) RETURN VARCHAR2,
  -- CR49721 new member function to expire add ons based on esn
  MEMBER FUNCTION expire_addons ( i_esn IN VARCHAR2) RETURN addon_bucket_details_tab
);
/
CREATE OR REPLACE TYPE BODY sa."RED_CARD_TYPE" IS
-- Constructor used to initialize the entire type
CONSTRUCTOR FUNCTION red_card_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

-- Constructor used to initialize the ESN and or MIN
CONSTRUCTOR FUNCTION red_card_type ( i_esn IN VARCHAR2,
                                     i_min IN VARCHAR2 DEFAULT NULL ) RETURN SELF AS RESULT IS
BEGIN

  -- Make sure we pass at least one parameters
  IF ( i_esn IS NULL AND
               i_min IS NULL )
  THEN
    SELF.response := 'NO INPUT PARAMETERS PASSED';
    RETURN;
  END IF;

  SELF.esn := i_esn;
  SELF.min := i_min;

  --
  SELF.response := 'SUCCESS';

  RETURN;
EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'UNABLE TO INSTANTIATE CUSTOMER: ' || SUBSTR(SQLERRM,1,100);
     SELF.esn := i_esn;
     SELF.min := i_min;

     RETURN;
END;

-- Constructor used to initialize the gtt part inst
CONSTRUCTOR FUNCTION red_card_type ( i_part_serial_no          IN VARCHAR2,
                                     i_domain                  IN VARCHAR2,
                                     i_red_code                IN VARCHAR2,
                                     i_part_inst_status        IN VARCHAR2,
                                     i_insert_date             IN DATE,
                                     i_creation_date           IN DATE,
                                     i_po_num                  IN VARCHAR2,
                                     i_order_number            IN VARCHAR2,
                                     i_created_by2user         IN NUMBER,
                                     i_status2x_code_table     IN NUMBER,
                                     i_n_part_inst2part_mod    IN NUMBER,
                                     i_part_inst2inv_bin       IN NUMBER,
                                     i_last_trans_time         IN DATE,
                                     i_parent_part_serial_no   IN VARCHAR2 ) RETURN SELF AS RESULT IS
BEGIN

  SELF.part_serial_no        := i_part_serial_no        ;
  SELF.domain                := i_domain                ;
  SELF.red_code              := i_red_code              ;
  SELF.part_inst_status      := i_part_inst_status      ;
  SELF.insert_date           := i_insert_date           ;
  SELF.creation_date         := i_creation_date         ;
  SELF.po_num                := i_po_num                ;
  SELF.order_number          := i_order_number          ;
  SELF.created_by2user       := i_created_by2user       ;
  SELF.status2x_code_table   := i_status2x_code_table   ;
  SELF.n_part_inst2part_mod  := i_n_part_inst2part_mod  ;
  SELF.part_inst2inv_bin     := i_part_inst2inv_bin     ;
  SELF.last_trans_time       := i_last_trans_time       ;
  SELF.parent_part_serial_no := i_parent_part_serial_no ;
  --
  SELF.response := 'SUCCESS';
  --
  RETURN;
  --
EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'UNABLE TO INSTANTIATE GTT PART INST: ' || SUBSTR(SQLERRM,1,100);
     SELF.part_serial_no        := i_part_serial_no        ;
     SELF.domain                := i_domain                ;
     SELF.red_code              := i_red_code              ;
     SELF.part_inst_status      := i_part_inst_status      ;
     SELF.insert_date           := i_insert_date           ;
     SELF.creation_date         := i_creation_date         ;
     SELF.po_num                := i_po_num                ;
     SELF.order_number          := i_order_number          ;
     SELF.created_by2user       := i_created_by2user       ;
     SELF.status2x_code_table   := i_status2x_code_table   ;
     SELF.n_part_inst2part_mod  := i_n_part_inst2part_mod  ;
     SELF.part_inst2inv_bin     := i_part_inst2inv_bin     ;
     SELF.last_trans_time       := i_last_trans_time       ;
     SELF.parent_part_serial_no := i_parent_part_serial_no ;
     --
     RETURN;
END;

-- Constructor used to initialize the gtt part inst
CONSTRUCTOR FUNCTION red_card_type ( i_part_number         IN VARCHAR2,
                                     i_part_serial_no      IN VARCHAR2,
                                     i_toss_att_customer   IN VARCHAR2,
                                     i_toss_att_location   IN VARCHAR2,
                                     i_toss_posa_code      IN VARCHAR2,
                                     i_toss_posa_date      IN DATE,
                                     i_tf_extract_flag     IN VARCHAR2,
                                     i_tf_extract_date     IN DATE,
                                     i_toss_site_id        IN VARCHAR2,
                                     i_toss_posa_action    IN VARCHAR2,
                                     i_remote_trans_id     IN VARCHAR2,
                                     i_sourcesystem        IN VARCHAR2,
                                     i_toss_att_trans_date IN DATE ) RETURN SELF AS RESULT IS
BEGIN
  SELF.part_number         := i_part_number          ;
  SELF.part_serial_no      := i_part_serial_no       ;
  SELF.toss_att_customer   := i_toss_att_customer    ;
  SELF.toss_att_location   := i_toss_att_location    ;
  SELF.toss_posa_code      := i_toss_posa_code       ;
  SELF.toss_posa_date      := i_toss_posa_date       ;
  SELF.tf_extract_flag     := i_tf_extract_flag      ;
  SELF.tf_extract_date     := i_tf_extract_date      ;
  SELF.toss_site_id        := i_toss_site_id         ;
  SELF.toss_posa_action    := i_toss_posa_action     ;
  SELF.remote_trans_id     := i_remote_trans_id      ;
  SELF.sourcesystem        := i_sourcesystem         ;
  SELF.toss_att_trans_date := i_toss_att_trans_date  ;
  --
  SELF.response := 'SUCCESS';
  --
  RETURN;
  --
EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'UNABLE TO INSTANTIATE GTT POSA CARD: ' || SUBSTR(SQLERRM,1,100);
     SELF.part_number         := i_part_number          ;
     SELF.part_serial_no      := i_part_serial_no       ;
     SELF.toss_att_customer   := i_toss_att_customer    ;
     SELF.toss_att_location   := i_toss_att_location    ;
     SELF.toss_posa_code      := i_toss_posa_code       ;
     SELF.toss_posa_date      := i_toss_posa_date       ;
     SELF.tf_extract_flag     := i_tf_extract_flag      ;
     SELF.tf_extract_date     := i_tf_extract_date      ;
     SELF.toss_site_id        := i_toss_site_id         ;
     SELF.toss_posa_action    := i_toss_posa_action     ;
     SELF.remote_trans_id     := i_remote_trans_id      ;
     SELF.sourcesystem        := i_sourcesystem         ;
     SELF.toss_att_trans_date := i_toss_att_trans_date  ;
     --
     RETURN;
END;

-- Function used to convert a pin to an smp
MEMBER FUNCTION convert_pin_to_smp ( i_red_card_code IN VARCHAR2 ) RETURN VARCHAR2 IS

  cst red_card_type := red_card_type();

BEGIN

  cst.pin := i_red_card_code;

  -- Exit when the ESN is not passed
  IF cst.pin IS NULL THEN
    cst.response := 'PIN NOT PASSED';
    RETURN NULL;
  END IF;

  BEGIN
    SELECT smp
            INTO   cst.smp
            FROM   ( -- Get the SMP from the part inst table (if it has NOT been burned)
             SELECT part_serial_no smp
             FROM   table_part_inst
             WHERE  1 = 1
             AND    x_red_code = cst.pin
             AND    x_domain = 'REDEMPTION CARDS'
             -- Get the SMP from the red card (if it has been burned)
             UNION
             SELECT x_smp smp
             FROM   table_x_red_card
             WHERE  x_red_code = cst.pin
           );
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  RETURN cst.smp;

EXCEPTION
   WHEN OTHERS THEN
     RETURN(NULL);
END convert_pin_to_smp;

-- Function used to convert an smp to an pin
MEMBER FUNCTION convert_smp_to_pin ( i_smp IN VARCHAR2 ) RETURN VARCHAR2 IS

  cst red_card_type := red_card_type();

BEGIN

  cst.smp := i_smp;

  ---- Exit when the SMP is not passed
  IF cst.smp IS NULL THEN
    cst.response := 'SMP NOT PASSED';
    RETURN NULL;
  END IF;

  BEGIN
    SELECT pin
            INTO   cst.pin
            FROM   ( -- Get the SMP from the part inst table (if it has NOT been burned)
             SELECT x_red_code pin
             FROM   table_part_inst
             WHERE  1 = 1
             AND    part_serial_no = cst.smp
             AND    x_domain = 'REDEMPTION CARDS'
             -- Get the SMP from the red card (if it has been burned)
             UNION
             SELECT x_red_code pin
             FROM   table_x_red_card
             WHERE  x_smp = cst.smp
           );
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  RETURN cst.pin;

EXCEPTION
   WHEN OTHERS THEN
     RETURN(NULL);

END convert_smp_to_pin;

-- Function used to get all the attributes for a particular customer
MEMBER FUNCTION retrieve RETURN red_card_type IS

  cst  red_card_type := SELF;
  c    red_card_type := SELF;

BEGIN

  -- Initialize entire cst type with an empty object
  cst := red_card_type ();

  cst.esn := c.esn;

  cst.min := NULL;

  -- Exit when the ESN is not passed
  IF cst.esn IS NULL THEN
    cst.response := 'ESN NOT PASSED';
    RETURN cst;
  END IF;

  -- Get the subscriber spr objid
  BEGIN
    SELECT objid
    INTO   cst.subscriber_spr_objid
    FROM   x_subscriber_spr
    WHERE  pcrf_esn = cst.esn;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- Get the min, carrier parent and wf_mac_id
  BEGIN
    SELECT pi_min.part_serial_no min,
           pi_min.x_msid msid,
           pi_esn.objid esn_part_inst_objid,
           pi_min.objid min_part_inst_objid,
           pi_esn.x_wf_mac_id wf_mac_id,
          pi_min.part_inst2carrier_mkt carrier_objid,
           pi_esn.x_part_inst_status esn_part_inst_status,
           pi_min.x_part_inst_status min_part_inst_status,
           pi_esn.x_part_inst2contact
    INTO   cst.min,
           cst.msid,
           cst.esn_part_inst_objid,
           cst.min_part_inst_objid,
           cst.wf_mac_id,
           cst.carrier_objid,
           cst.esn_part_inst_status,
           cst.min_part_inst_status,
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
         SELECT pi_esn.objid esn_part_inst_objid,
                pi_esn.x_wf_mac_id wf_mac_id,
                pi_esn.x_part_inst_status esn_part_inst_status
         INTO   cst.esn_part_inst_objid,
                cst.wf_mac_id,
                cst.esn_part_inst_status
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


  -- Get rate plan
  cst.rate_plan := c.get_rate_plan ( i_esn => cst.esn);

  -- Get propagate_flag
  cst.propagate_flag := c.get_propagate_flag ( i_rate_plan => cst.rate_plan);

  -- Assign the base ttl from table_site_part
  cst.expiration_date := c.get_expiration_date ( i_esn => cst.esn);

  -- Get the last redemption date
  cst.last_redemption_date := c.get_last_redemption_date ( i_esn => cst.esn );

  -- Get carrier parent name
  IF cst.carrier_objid IS NOT NULL THEN
    BEGIN
      SELECT p.x_parent_name parent_name
      INTO   cst.parent_name
      FROM   table_x_parent p,
             table_x_carrier_group cg,
             table_x_carrier c
      WHERE  c.objid = cst.carrier_objid
      AND    c.carrier2carrier_group = cg.objid
      AND    cg.x_carrier_group2x_parent = p.objid;
     EXCEPTION
       WHEN others THEN
         cst.response := cst.response || 'CARRIER PARENT NAME NOT FOUND';
    END;
    -- get short parent name
    IF cst.parent_name IS NOT NULL THEN
      cst.short_parent_name := c.get_short_parent_name ( i_parent_name => cst.parent_name );
    END IF;
  END IF;

  -- Get the web user and contact (Active site part status)
  BEGIN
    SELECT sp.x_zipcode zipcode,
           sp.objid site_part_objid,
           sp.part_status,
           sp.x_iccid,
           NVL2(cst.min, cst.min, sp.x_min) min,
           sp.install_date
    INTO   cst.zipcode,
           cst.site_part_objid,
           cst.site_part_status,
           cst.iccid,
           cst.min,
           cst.install_date
    FROM   table_site_part sp
    WHERE  1 = 1
    AND    sp.x_service_id = cst.esn
    AND    sp.part_status = 'Active';
   EXCEPTION
     WHEN no_data_found THEN
       -- get the zipcode, iccid and site part status for the last updated row in site part
       BEGIN
         SELECT sp.x_zipcode zipcode,
                sp.objid site_part_objid,
                sp.part_status,
                sp.x_iccid,
                NVL2(cst.min, cst.min, sp.x_min) min
         INTO   cst.zipcode,
                cst.site_part_objid,
                cst.site_part_status,
                cst.iccid,
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
         SELECT sp.x_zipcode zipcode,
                sp.objid site_part_objid,
                sp.part_status,
                sp.x_iccid,
                NVL2(cst.min, cst.min, sp.x_min) min,
                sp.install_date
         INTO   cst.zipcode,
                cst.site_part_objid,
                cst.site_part_status,
                cst.iccid,
                cst.min,
                cst.install_date
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
            cst.response := cst.response || '|STATUS, ZIPCODE NOT FOUND';
          WHEN others THEN
            cst.response := cst.response || '|STATUS, ZIPCODE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       END;
     WHEN others THEN
       cst.response := cst.response || '|STATUS, ZIPCODE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN cst;
  END;

  IF cst.iccid IS NOT NULL THEN
    -- Get the sim part number
    BEGIN
      SELECT pn.part_number
      INTO   cst.sim_part_number
      FROM   table_x_sim_inv sim,
             table_mod_level ml,
             table_part_num pn
      WHERE  1 = 1
      AND    sim.x_sim_serial_no = cst.iccid
      AND    sim.x_sim_inv2part_mod = ml.objid
      AND    ml.part_info2part_num = pn.objid;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
  END IF;

  -- Get the activation date
  IF cst.install_date IS NULL THEN
    BEGIN
      SELECT MAX(install_date)
      INTO   cst.install_date
      FROM   table_site_part
      WHERE  x_service_id = cst.esn
      AND    x_min = cst.min;
     EXCEPTION
       WHEN others THEN
         cst.response := cst.response || '|INSTALL DATE NOT FOUND';
    END;
  END IF;

  --
  IF cst.site_part_objid IS NOT NULL THEN
    -- Get the service plan and cos
    BEGIN
      SELECT spsp.x_service_plan_id,
             fea.mkt_name,
             NVL(fea.number_of_lines,1),
             fea.service_plan_group,
             CASE WHEN UPPER(fea.data) IN ('UNLIMITED','NA','DYNAMIC') THEN 0 ELSE TO_NUMBER(fea.data) END service_plan_data,
             fea.plan_purchase_part_number,
             TRIM(regexp_replace(NVL(fea.service_days,0),'[[:alpha:]]','') )
      INTO   cst.service_plan_objid,
             cst.service_plan_name,
             cst.group_allowed_lines,
             cst.service_plan_group,
             cst.service_plan_data,
             cst.service_plan_part_number,
             cst.service_plan_days
      FROM   x_service_plan_site_part spsp,
             sa.service_plan_feat_pivot_mv fea
      WHERE  spsp.table_site_part_id = cst.site_part_objid
      AND    spsp.x_service_plan_id = fea.service_plan_objid;
     EXCEPTION
      WHEN too_many_rows THEN
        cst.response := cst.response || '|DUPLICATE SERVICE PLAN, COS';
      WHEN OTHERS THEN
        cst.response := cst.response || '|SERVICE PLAN NOT FOUND';
    END;

  ELSE
    cst.response := cst.response || '|SERVICE PLAN NOT FOUND';
  END IF;

  SELECT SUM(QUEUED_DAYS)     -- [ CR47564 WFM change ] For WFM  brand the  brm_service_days is fetched from x_part_inst_ext and for
    INTO cst.queued_days       --  other brands x_redeem_days are fetched from table_part_num.
  FROM TABLE (sa.customer_info.get_esn_queued_cards (i_esn => cst.esn));


  -- Get the dealer, brand and other features
  BEGIN
    SELECT pcpv.bus_org bus_org_id,
           pcpv.firmware firmware,
           pcpv.motricity_denomination motricity_denomination,
           pn.x_manufacturer phone_manufacturer,
           pcpv.model_type model_type,
           pn.part_num2bus_org bus_org_objid,
           pcpv.technology,
           pcpv.part_class part_class_name,
           pcpv.device_type,
           pn.part_num2part_class part_class_objid,
           pn.part_number,
           pi.part_inst2inv_bin inv_bin_objid,
           pcpv.non_ppe non_ppe_flag,
           pcpv.phone_gen phone_generation,
           pcpv.data_speed
    INTO   cst.bus_org_id,
           cst.firmware,
           cst.motricity_denomination,
           cst.phone_manufacturer,
           cst.model_type,
           cst.bus_org_objid,
           cst.technology,
           cst.part_class_name,
           cst.device_type,
           cst.part_class_objid,
           cst.esn_part_number,
           cst.inv_bin_objid,
           cst.non_ppe_flag,
           cst.phone_generation,
           cst.data_speed
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           pcpv_mv pcpv
    WHERE  1 = 1
    AND    pi.part_serial_no = cst.esn
    AND    pi.x_domain = 'PHONES'
    AND    pi.n_part_inst2part_mod = ml.objid
    AND    ml.part_info2part_num = pn.objid
    AND    pn.domain = 'PHONES'
    AND    pn.part_num2part_class = pcpv.pc_objid;
   EXCEPTION
    WHEN others THEN
      cst.response := cst.response || '|PART NUMBER, PART CLASS NOT FOUND';
  END;

  -- Determine when the brand allows device leasing
  IF cst.bus_org_objid IS NOT NULL THEN
    cst.brand_leasing_flag := c.get_leasing_flag ( i_bus_org_objid => cst.bus_org_objid);
  END IF;

  -- Determine when the brand allows shared groups
  IF cst.bus_org_id IS NOT NULL THEN
    cst.brand_shared_group_flag := c.get_shared_group_flag ( i_bus_org_id => cst.bus_org_id);
  END IF;

  -- Get dealer id
  IF cst.inv_bin_objid IS NOT NULL THEN
    BEGIN
      SELECT bin_name
      INTO   cst.dealer_id
      FROM   table_inv_bin
      WHERE  objid = cst.inv_bin_objid;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
  END IF;

  -- Get the activation site id
  BEGIN
    SELECT s.site_id
    INTO   cst.site_id
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

  -- Get the cos (offer id) value from the rule engine logic
  cst.cos := cst.get_cos ( i_esn                => cst.esn ,
                           i_min                => cst.min ,
                           i_part_class_name    => cst.part_class_name ,
                           i_bus_org_objid      => cst.bus_org_objid,
                           i_parent_name        => cst.parent_name,
                           i_service_plan_objid => cst.service_plan_objid,
                           i_site_id            => cst.site_id );

  -- Get denomination and conversion rate
  IF cst.esn_part_inst_objid IS NOT NULL THEN
    BEGIN
      SELECT NVL2(cst.motricity_denomination, cst.motricity_denomination, TO_CHAR(x_motricity_deno)) ,
             x_current_conv_rate
      INTO   cst.motricity_denomination,
             cst.conversion_rate
      FROM   sa.table_x_ota_features
      WHERE  x_ota_features2part_inst = cst.esn_part_inst_objid;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
  END IF;

  -- Get conversion rate
  IF cst.conversion_rate IS NULL THEN
    cst.conversion_rate := c.get_ota_conversion_rate ( i_esn_part_inst_objid => cst.esn_part_inst_objid );
  END IF;

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
         SELECT DISTINCT web_user_objid,
                         web_login_name,
                         web_user2contact
         INTO   cst.web_user_objid,
                cst.web_login_name,
                cst.web_contact_objid
         FROM   ( SELECT wu.objid web_user_objid,
                         wu.login_name web_login_name,
                         wu.web_user2contact
                  FROM   table_x_contact_part_inst cpi,
                         table_web_user wu
                  WHERE  1 = 1
                  AND    cpi.x_contact_part_inst2part_inst = cst.esn_part_inst_objid
                  AND    wu.web_user2contact = cpi.x_contact_part_inst2contact
                  AND    web_user2bus_org = cst.bus_org_objid
                );
        EXCEPTION
          WHEN others THEN
            cst.response := cst.response || '|DUPLICATE WEB USER';
            cst.response := cst.response || '|WEB USER PER BRAND NOT FOUND';
       END;
     WHEN OTHERS THEN
       cst.response := cst.response || '|WEB USER NOT FOUND: '|| SUBSTR(SQLERRM,1,100);
  END;

  -- Determine if the customer is throttled and retrieve the throttling policy information
  BEGIN
    SELECT x_policy_id,
           x_creation_date
    INTO   cst.throttle_policy_id,
           cst.throttle_date
    FROM   ( SELECT x_policy_id,
                    x_creation_date
             FROM   w3ci.table_x_throttling_cache
             WHERE  x_esn = cst.esn
             AND    x_min = cst.min
             AND    x_status IN ('A','P')
             ORDER BY objid DESC
           )
    WHERE  ROWNUM = 1; -- Just in case there are throttled subscribers with more than one cache row
   EXCEPTION
    WHEN others THEN
      -- Continue the process when this value was not found
      NULL;
  END;

  -- Get the safelink program parameter
  BEGIN
    SELECT pgm.objid,
           'Y' safelink_flag
    INTO   cst.safelink_pgm_param_objid,
           cst.safelink_flag
    FROM   sa.x_program_enrolled pe,
           sa.x_program_parameters pgm,
           sa.x_sl_currentvals slcur
    WHERE  pe.x_esn = cst.esn
    AND    pgm.objid = pe.pgm_enroll2pgm_parameter
    AND    pgm.x_prog_class = 'LIFELINE'
    AND    pe.x_enrollment_status = 'ENROLLED'
    AND    slcur.x_current_esn = pe.x_esn;
   EXCEPTION
     WHEN others THEN
       cst.safelink_flag := 'N';
  END;

  -- Get program parameter for enrolled customers
  BEGIN
    SELECT program_parameter_objid
    INTO   cst.program_parameter_objid
    FROM   ( SELECT enr.pgm_enroll2pgm_parameter program_parameter_objid
             FROM   x_program_enrolled enr
             WHERE  enr.x_esn = cst.esn
             AND    x_enrollment_status IN ('ENROLLED','ENROLLMENTSCHEDULED')
             AND    x_next_charge_date > SYSDATE
             UNION ALL
             SELECT enr.pgm_enroll2pgm_parameter program_parameter_objid
             FROM   x_program_enrolled enr,
                    x_program_parameters pp
             WHERE  enr.x_esn = cst.esn
             AND    x_enrollment_status = 'ENROLLED_NO_ACCOUNT'
             AND    x_next_charge_date > SYSDATE
             AND    enr.pgm_enroll2pgm_parameter = pp.objid
             AND    pp.x_prog_class||'' = 'WARRANTY'
           )
    WHERE  ROWNUM = 1;
   EXCEPTION
     WHEN OTHERS THEN
       cst.program_parameter_objid := NULL;
  END;

  -- Get the account group data
  BEGIN
    SELECT account_group_uid,
           objid,
           service_plan_id,
           account_group_name
    INTO   cst.account_group_uid,
           cst.account_group_objid,
           cst.group_service_plan_objid,
           cst.account_group_name
    FROM   ( SELECT account_group_uid,
                    objid,
                    service_plan_id,
                    account_group_name
             FROM   sa.x_account_group
             WHERE  objid IN ( SELECT account_group_id
                               FROM   sa.x_account_group_member
                               WHERE  esn = cst.esn
                               AND    UPPER(status) <> 'EXPIRED'
                             )
             AND    UPPER(status) <> 'EXPIRED'
             ORDER BY objid DESC
           )
    WHERE  ROWNUM = 1;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;
  --


  IF cst.pin IS NOT NULL THEN
    BEGIN
      -- Get the part class of the pin
      SELECT part_number
      INTO   cst.pin_part_number
      FROM   ( SELECT pn.part_number
               FROM   table_part_inst pi,
                      table_mod_level ml,
                      table_part_num pn
               WHERE  1 = 1
               AND    pi.x_red_code = cst.pin
               AND    pi.x_domain = 'REDEMPTION CARDS'
               AND    pi.n_part_inst2part_mod = ml.objid
               AND    ml.part_info2part_num = pn.objid
               AND    pn.domain = 'REDEMPTION CARDS'
               UNION
               SELECT pn.part_number
               FROM   table_x_red_card rc,
                      table_mod_level ml,
                      table_part_num pn
               WHERE  rc.x_red_code = cst.pin
               AND    ml.objid = rc.x_red_card2part_mod
               AND    ml.part_info2part_num = pn.objid
               AND    pn.domain = 'REDEMPTION CARDS'
               UNION
               SELECT pn.part_number
               FROM   table_x_posa_card_inv pi,
                     table_mod_level ml,
                      table_part_num pn
               WHERE  1 = 1
               AND    pi.x_red_code = cst.pin
               AND    ml.objid = pi.x_posa_inv2part_mod
               AND    pn.objid = ml.part_info2part_num
               AND    pn.domain = 'REDEMPTION CARDS'
             );
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
  END IF;

  -- Get the account group member data
  BEGIN
    SELECT subscriber_uid,
           objid,
           status
    INTO   cst.subscriber_uid,
           cst.member_objid,
           cst.member_status
    FROM   ( SELECT subscriber_uid,
                    objid,
                    status
             FROM   sa.x_account_group_member
             WHERE  esn = cst.esn
             AND    UPPER(status) <> 'EXPIRED'
             ORDER BY objid DESC
           )
    WHERE  ROWNUM = 1;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;
  --

  --
  IF cst.contact_objid IS NOT NULL THEN
    BEGIN
      SELECT NVL(x_do_not_email,0),
             NVL(x_do_not_phone,0),
             NVL(x_do_not_sms,0),
             NVL(x_do_not_mail,0)
      INTO   cst.do_not_email,
             cst.do_not_phone,
             cst.do_not_sms,
             cst.do_not_mail
      FROM   sa.table_x_contact_add_info
      WHERE  add_info2contact = cst.contact_objid;
     EXCEPTION
       WHEN others THEN
         cst.do_not_email := 0;
         cst.do_not_phone := 0;
         cst.do_not_sms   := 0;
         cst.do_not_mail  := 0;
    END;
  END IF;

  --
  IF cst.web_contact_objid IS NOT NULL THEN
    BEGIN
      SELECT x_pin
      INTO   cst.security_pin
      FROM   sa.table_x_contact_add_info
      WHERE  add_info2contact = cst.web_contact_objid;
     EXCEPTION
       WHEN dup_val_on_index THEN
         BEGIN
           SELECT x_pin
           INTO   cst.security_pin
           FROM   sa.table_x_contact_add_info
           WHERE  add_info2contact = cst.web_contact_objid
           AND    add_info2bus_org = cst.bus_org_objid;
          EXCEPTION
            WHEN others THEN
              NULL;
         END;
       WHEN others THEN
         NULL;
    END;
    --
    BEGIN
      SELECT first_name,
             last_name
      INTO   cst.first_name,
             cst.last_name
      FROM   sa.table_contact
      WHERE  objid = cst.web_contact_objid;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
    --
  END IF;

  -- Get the switch based flag
  IF cst.carrier_objid IS NOT NULL AND
     cst.rate_plan IS NOT NULL
  THEN
    BEGIN
      SELECT x_is_swb_carrier
      INTO   cst.is_swb_carrier
      FROM   table_x_carrier_features
      WHERE  x_feature2x_carrier = cst.carrier_objid
      AND    x_rate_plan = cst.rate_plan
      AND    ( x_data = TO_NUMBER(cst.data_speed) OR cst.data_speed IS NULL)
      GROUP BY x_is_swb_carrier;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
  END IF;


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
MEMBER FUNCTION retrieve ( i_esn IN VARCHAR2 ) RETURN red_card_type IS

  -- instantiate initial values
  rc     sa.red_card_type  := red_card_type ( i_esn => i_esn );

  -- type to hold retrieved attributes
  cst    sa.red_card_type;

BEGIN

  -- call the retrieve method
  cst := rc.retrieve;

  RETURN cst;

END retrieve;

-- Function used to get all the attributes for a particular customer
MEMBER FUNCTION retrieve_group ( i_account_group_objid IN NUMBER ) RETURN red_card_type IS

  cst  red_card_type := SELF;
  c    red_card_type := SELF;

BEGIN

  -- Initialize entire cst type with an empty object
  cst := red_card_type ();

  cst.account_group_objid := i_account_group_objid;

  -- Exit when the ESN is not passed
  IF cst.account_group_objid IS NULL THEN
    cst.response := 'GROUP ID NOT PASSED';
    RETURN cst;
  END IF;

  -- Get the account group data
  BEGIN
    SELECT account_group_uid,
           account_group_name,
           service_plan_id,
           bus_org_objid,
           start_date
    INTO   cst.account_group_uid,
           cst.account_group_name,
           cst.group_service_plan_objid,
           cst.bus_org_objid,
           cst.group_start_date
    FROM   sa.x_account_group
    WHERE  objid = cst.account_group_objid;
   EXCEPTION
     WHEN others THEN
       cst.response := cst.response || '|GROUP NOT FOUND';
  END;
  --
  --
  -- Get Contact objid for the group
  BEGIN
    SELECT conpi.x_contact_part_inst2contact
    INTO   cst.group_contact_objid
    FROM   sa.table_x_contact_part_inst conpi,
           sa.table_part_inst           pi_esn,
           sa.x_account_group_member    agm,
           sa.x_account_group           ag
    WHERE  conpi.x_contact_part_inst2part_inst = pi_esn.objid
    AND    pi_esn.x_domain                     = 'PHONES'
    AND    pi_esn.part_serial_no               = agm.esn
    AND    UPPER(agm.status)                  != 'EXPIRED'
    AND    agm.account_group_id                = ag.objid
    AND    ag.objid                            = cst.account_group_objid
    AND    ROWNUM = 1;
  EXCEPTION
    WHEN OTHERS THEN
      cst.response := cst.response || '|GROUP Contact OBJID FAILED';
  END;
  --
  IF cst.bus_org_objid IS NOT NULL THEN
    BEGIN
      SELECT org_id
      INTO   cst.bus_org_id
              FROM   table_bus_org
              WHERE  objid = cst.bus_org_objid;
     EXCEPTION
       WHEN others THEN
         cst.response := cst.response || '|BRAND NOT FOUND';
            END;

  END IF;

  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  -- Return the type
  RETURN cst;

EXCEPTION
   WHEN OTHERS THEN
     cst.response := 'ERROR RETRIEVING GROUP: ' || SQLERRM;
     RETURN cst;
     --
END retrieve_group;

-- Function used to get all the attributes for a particular customer by login name
MEMBER FUNCTION retrieve_login ( i_login_name IN VARCHAR2 ) RETURN red_card_type IS

  cst  red_card_type := SELF;

BEGIN

  -- Initialize entire cst type with an empty object
  cst := red_card_type ();

  cst.web_login_name := i_login_name;

  -- Exit when the ESN is not passed
  IF cst.web_login_name IS NULL THEN
    cst.response := 'LOGIN NAME NOT PASSED';
    RETURN cst;
  END IF;

  BEGIN
    SELECT objid web_user_objid,
           web_user2contact contact_objid
            INTO   cst.web_user_objid,
           cst.web_contact_objid
    FROM   table_web_user
    WHERE  1 = 1
    AND    ( login_name = i_login_name OR
             s_login_name = UPPER(i_login_name)
           );
   EXCEPTION
     WHEN others THEN
       cst.response := 'LOGIN NAME NOT FOUND';
               RETURN cst;
  END;

  --
  IF cst.web_contact_objid IS NOT NULL THEN
    BEGIN
      SELECT x_pin
      INTO   cst.security_pin
      FROM   sa.table_x_contact_add_info
      WHERE  add_info2contact = cst.web_contact_objid;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
    --
    BEGIN
      SELECT first_name,
             last_name
      INTO   cst.first_name,
             cst.last_name
      FROM   sa.table_contact
      WHERE  objid = cst.web_contact_objid;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
    --
  END IF;

  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  -- Return the type
  RETURN cst;

EXCEPTION
   WHEN OTHERS THEN
     cst.response := 'ERROR RETRIEVING LOGIN: ' || SQLERRM;
     RETURN cst;
     --
END retrieve_login;

-- Function used to get all the attributes for a particular customer by login name and brand
MEMBER FUNCTION retrieve_login ( i_login_name IN VARCHAR2 ,
                                 i_bus_org_id IN VARCHAR2 ) RETURN red_card_type IS

  cst  red_card_type := SELF;

BEGIN

  -- Initialize entire cst type with an empty object
  cst := red_card_type ();

  cst.web_login_name := i_login_name;

  -- Exit when the ESN is not passed
  IF cst.web_login_name IS NULL THEN
    cst.response := 'LOGIN NAME NOT PASSED';
    RETURN cst;
  END IF;

  BEGIN
    SELECT wu.objid web_user_objid,
           wu.web_user2contact contact_objid
            INTO   cst.web_user_objid,
           cst.web_contact_objid
    FROM   table_web_user wu,
                   table_bus_org bo
    WHERE  1 = 1
    AND    ( wu.login_name = i_login_name OR
             wu.s_login_name = UPPER(i_login_name)
           )
    AND    wu.web_user2bus_org = bo.objid
            AND    bo.org_id = i_bus_org_id;
   EXCEPTION
     WHEN others THEN
       cst.response := 'LOGIN NAME NOT FOUND';
               RETURN cst;
  END;

  --
  IF cst.web_contact_objid IS NOT NULL THEN
    BEGIN
      SELECT x_pin
      INTO   cst.security_pin
      FROM   sa.table_x_contact_add_info
      WHERE  add_info2contact = cst.web_contact_objid;
     EXCEPTION
       WHEN dup_val_on_index THEN
         BEGIN
           SELECT x_pin
           INTO   cst.security_pin
           FROM   sa.table_x_contact_add_info
           WHERE  add_info2contact = cst.web_contact_objid
           AND    add_info2bus_org = i_bus_org_id;
          EXCEPTION
                    WHEN others THEN
              NULL;
         END;
       WHEN others THEN
         NULL;
    END;
    --
    BEGIN
      SELECT first_name,
             last_name
      INTO   cst.first_name,
             cst.last_name
      FROM   sa.table_contact
      WHERE  objid = cst.web_contact_objid;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
    --
  END IF;

  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  -- Return the type
  RETURN cst;

EXCEPTION
   WHEN OTHERS THEN
     cst.response := 'ERROR RETRIEVING LOGIN: ' || SQLERRM;
     RETURN cst;
     --
END retrieve_login;


-- Function used to get all the attributes for a particular customer by min
MEMBER FUNCTION retrieve_min ( i_min IN VARCHAR2 ) RETURN red_card_type IS

  cst  red_card_type := SELF;
  c    red_card_type := SELF;

BEGIN

  -- Initialize entire cst type with an empty object
  cst := red_card_type ();

  cst.min := i_min;

  -- Exit when the ESN is not passed
  IF cst.min IS NULL THEN
    cst.response := 'MIN NOT PASSED';
    RETURN cst;
  END IF;

  -- Get the ESN
  BEGIN
    SELECT pi_esn.part_serial_no
    INTO   cst.esn
    FROM   table_part_inst pi_min,
           table_part_inst pi_esn
    WHERE  pi_min.part_serial_no = cst.min
    AND    pi_min.x_domain = 'LINES'
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst;
   EXCEPTION
     WHEN others THEN
       BEGIN
         SELECT sp.x_service_id
         INTO   cst.esn
         FROM   sa.table_site_part sp,
                sa.table_part_inst pi_min
         WHERE  sp.x_min = cst.min
         AND    sp.objid = pi_min.x_part_inst2site_part;
        EXCEPTION
          WHEN others THEN
            cst.response := 'MIN NOT FOUND';
            RETURN cst;
       END;
  END;

  -- call the retrieve method
  c := cst.retrieve;

  -- Return the type
  RETURN c;

EXCEPTION
   WHEN OTHERS THEN
     c.response := 'ERROR RETRIEVING MIN: ' || SQLERRM;
     RETURN c;
     --
END retrieve_min;

-- Function used to get all the attributes for a particular pin
MEMBER FUNCTION retrieve_pin ( i_red_card_code IN VARCHAR2 ) RETURN red_card_type IS

  cst  red_card_type := SELF;
  c    red_card_type := SELF;

BEGIN

  -- Initialize entire cst type with an empty object
  cst := red_card_type ();

  cst.pin := i_red_card_code;

  -- Exit when the ESN is not passed
  IF cst.pin IS NULL THEN
    cst.response := 'PIN NOT PASSED';
    RETURN cst;
  END IF;

  -- Get the smp from pin
  cst.smp := c.convert_pin_to_smp ( i_red_card_code => cst.pin );
  -- get the lease id
  BEGIN
    SELECT application_req_num
    INTO   cst.application_req_num
    FROM   sa.x_customer_lease
    WHERE  smp = cst.smp;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  BEGIN
    -- Get the part class of the pin
            SELECT part_class_objid,
           bus_org_objid,
           bus_org_id,
                           part_number
    INTO   cst.part_class_objid,
           cst.bus_org_objid,
           cst.bus_org_id,
                           cst.pin_part_number
    FROM   ( SELECT pn.part_num2part_class part_class_objid,
                    pn.part_num2bus_org bus_org_objid,
                    bo.org_id bus_org_id,
                    pn.part_number
             FROM   table_part_inst pi,
                    table_mod_level ml,
                    table_part_num pn,
                    table_bus_org bo
             WHERE  1 = 1
             AND    pi.x_red_code = cst.pin
             AND    pi.x_domain = 'REDEMPTION CARDS'
             AND    pi.n_part_inst2part_mod = ml.objid
             AND    ml.part_info2part_num = pn.objid
             AND    pn.domain = 'REDEMPTION CARDS'
             AND    pn.part_num2bus_org = bo.objid
             UNION
             SELECT pn.part_num2part_class part_class_objid,
                    pn.part_num2bus_org bus_org_objid,
                    bo.org_id bus_org_id,
                    pn.part_number
             FROM   table_x_red_card rc,
                    table_mod_level ml,
                    table_part_num pn,
                    table_bus_org bo
             WHERE  rc.x_red_code = cst.pin
             AND    ml.objid = rc.x_red_card2part_mod
             AND    ml.part_info2part_num = pn.objid
             AND    pn.domain = 'REDEMPTION CARDS'
             AND    pn.part_num2bus_org = bo.objid
             UNION
             SELECT pn.part_num2part_class pc_objid,
                    pn.part_num2bus_org bus_org_objid,
                    bo.org_id bus_org_id,
                    pn.part_number
             FROM   table_x_posa_card_inv pi,
                    table_mod_level ml,
                    table_part_num pn,
                    table_bus_org bo
             WHERE  1 = 1
             AND    pi.x_red_code = cst.pin
             AND    ml.objid = pi.x_posa_inv2part_mod
             AND    pn.objid = ml.part_info2part_num
             AND    pn.domain = 'REDEMPTION CARDS'
             AND    pn.part_num2bus_org = bo.objid
           );
   EXCEPTION
     WHEN others THEN
       cst.response := 'PIN NOT FOUND';
       RETURN cst;
  END;

  --
  IF cst.part_class_objid IS NOT NULL THEN
    -- Get the dealer, brand and other features
    BEGIN
      SELECT pcpv.firmware firmware,
             pcpv.motricity_denomination motricity_denomination,
             pcpv.model_type model_type,
             pcpv.technology,
             pcpv.part_class part_class_name,
             pcpv.device_type,
             pcpv.non_ppe non_ppe_flag,
             pcpv.phone_gen phone_generation
      INTO   cst.firmware,
             cst.motricity_denomination,
             cst.model_type,
             cst.technology,
             cst.part_class_name,
             cst.device_type,
             cst.non_ppe_flag,
             cst.phone_generation
      FROM   sa.pcpv_mv pcpv
      WHERE  pcpv.pc_objid = cst.part_class_objid;
     EXCEPTION
      WHEN others THEN
        cst.response := cst.response || '|PART CLASS NOT FOUND';
    END;
  END IF;

  -- Determine when the brand allows device leasing
  IF cst.bus_org_objid IS NOT NULL THEN
    cst.brand_leasing_flag := c.get_leasing_flag ( i_bus_org_objid => cst.bus_org_objid);
  END IF;

  -- Determine when the brand allows shared groups
  IF cst.bus_org_id IS NOT NULL THEN
    cst.brand_shared_group_flag := c.get_shared_group_flag ( i_bus_org_id => cst.bus_org_id);
  END IF;

  -- Get the service plan attributes and features
  BEGIN
    SELECT sp.objid,
           sp.customer_price,
           sp.mkt_name,
           mv.number_of_lines,
           CASE WHEN UPPER(mv.data) IN ('UNLIMITED','NA','DYNAMIC') THEN 0 ELSE TO_NUMBER(mv.data) END service_plan_data,
           mv.plan_purchase_part_number,
           mv.service_plan_group
    INTO   cst.service_plan_objid,
           cst.service_plan_price,
           cst.service_plan_name,
           cst.group_allowed_lines,
           cst.service_plan_data,
           cst.service_plan_part_number,
           cst.service_plan_group
    FROM   sa.x_serviceplanfeaturevalue_def a,
           sa.mtm_partclass_x_spf_value_def b,
           sa.x_serviceplanfeature_value spfv,
           sa.x_service_plan_feature spf,
           sa.x_service_plan sp,
           sa.service_plan_feat_pivot_mv mv
    WHERE  1 = 1
    AND    b.part_class_id = cst.part_class_objid
    AND    a.objid = b.spfeaturevalue_def_id
    AND    spfv.value_ref = a.objid
    AND    spf.objid = spfv.spf_value2spf
    AND    sp.objid = spf.sp_feature2service_plan
    AND    sp.objid = mv.service_plan_objid;
   EXCEPTION
     WHEN too_many_rows THEN
       cst.response := cst.response || '|DUPLICATE SERVICE PLAN PART CLASS';
       RETURN cst;
     WHEN others THEN
       cst.response := cst.response || '|SERVICE PLAN PART CLASS NOT FOUND';
       RETURN cst;
  END;

  -- Since we do not have the group, set the lines in a group as zero
  cst.group_total_lines := 0;

  -- Get lease blocked slots
  BEGIN
    SELECT COUNT(DISTINCT esn)
    INTO   cst.lease_blocked_slots
    FROM   ( SELECT x_esn esn
             FROM   sa.x_customer_lease
             WHERE  application_req_num = cst.application_req_num
             AND    lease_status IN ('1001','1002','1005')
             UNION
             SELECT x_esn esn
             FROM   sa.x_customer_lease
             WHERE  smp = cst.smp
             AND    lease_status IN ('1001','1002','1005')
           ) a;
   EXCEPTION
     WHEN others THEN
       cst.lease_blocked_slots := 0;
  END;

  -- Get the number of lines a service plan allows for a particular group
  IF cst.service_plan_objid IS NOT NULL AND cst.group_allowed_lines IS NULL
  THEN
    BEGIN
      SELECT NVL(fea.number_of_lines,1)
      INTO   cst.group_allowed_lines
      FROM   sa.service_plan_feat_pivot_mv fea
      WHERE  service_plan_objid = cst.service_plan_objid;
     EXCEPTION
       WHEN others THEN
         cst.group_allowed_lines := 0;
    END;
  END IF;

  -- Calculate the quantity of available lines for a particular group
  IF cst.group_allowed_lines > 0 THEN
    cst.group_available_capacity := cst.group_allowed_lines - ( NVL(cst.group_total_lines,0) + NVL(cst.lease_blocked_slots,0) );
    cst.group_available_capacity := GREATEST ( cst.group_available_capacity, 0);
  END IF;

  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  -- Return the type
  RETURN cst;

EXCEPTION
   WHEN OTHERS THEN
     cst.response := 'ERROR RETRIEVING PIN: ' || SQLERRM;
     RETURN cst;
     --
END retrieve_pin;

-- Function used to determine when the brand allows leasing
MEMBER FUNCTION get_leasing_flag ( i_bus_org_objid  IN NUMBER) RETURN VARCHAR2 IS
  c red_card_type := red_card_type();
BEGIN
  -- Default to N
  c.brand_leasing_flag := 'N';

  -- STRAIGHT TALK allows device leasing
  IF i_bus_org_objid = 536876745 THEN -- STRAIGHT_TALK
    c.brand_leasing_flag := 'Y';
  END IF;

  -- TOTAL_WIRELESS allows device leasing
  IF i_bus_org_objid = 268448087 THEN -- TOTAL_WIRELESS
    c.brand_leasing_flag := 'Y';
  END IF;

  RETURN(c.brand_leasing_flag);

EXCEPTION
   WHEN others THEN
     RETURN('N');
END get_leasing_flag;

-- Get the brand
MEMBER FUNCTION get_bus_org_id ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS

  c   red_card_type := red_card_type ();

BEGIN
  --
  BEGIN
    SELECT bo.org_id
    INTO   c.bus_org_id
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           table_bus_org bo
    WHERE  1 = 1
    AND    pi.part_serial_no = i_esn
    AND    pi.x_domain = 'PHONES'
    AND    pi.n_part_inst2part_mod = ml.objid
    AND    ml.part_info2part_num = pn.objid
    AND    pn.domain = 'PHONES'
    AND    pn.part_num2bus_org = bo.objid;
   EXCEPTION
    WHEN others THEN
      NULL;
  END;
  --
  RETURN(c.bus_org_id);
  --
EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_bus_org_id;

-- Get the brand objid
MEMBER FUNCTION get_bus_org_objid ( i_esn IN VARCHAR2 ) RETURN NUMBER IS

  c   red_card_type := red_card_type ();

BEGIN
  --
  BEGIN
    SELECT bo.objid
    INTO   c.bus_org_objid
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           table_bus_org bo
    WHERE  1 = 1
    AND    pi.part_serial_no = i_esn
    AND    pi.x_domain = 'PHONES'
    AND    pi.n_part_inst2part_mod = ml.objid
    AND    ml.part_info2part_num = pn.objid
    AND    pn.domain = 'PHONES'
    AND    pn.part_num2bus_org = bo.objid;
   EXCEPTION
    WHEN others THEN
      NULL;
  END;
  --
  RETURN(c.bus_org_objid);
  --
EXCEPTION
   WHEN others THEN
     RETURN NULL;

END get_bus_org_objid;

-- Function used to get the necessary attributes for the cos rule engine
MEMBER FUNCTION get_cos ( i_esn                IN VARCHAR2,
                          i_min                IN VARCHAR2,
                          i_part_class_name    IN VARCHAR2,
                          i_bus_org_objid      IN NUMBER,
                          i_parent_name        IN VARCHAR2,
                          i_service_plan_objid IN NUMBER,
                          i_site_id            IN VARCHAR2,
                          i_as_of_date         IN DATE DEFAULT SYSDATE ) RETURN VARCHAR2 AS

  cst                 red_card_type := SELF;
  l_cos               sa.x_policy_rule_config.cos%TYPE;
  l_part_class_objid  NUMBER;
  l_install_date      DATE;
  l_active_days       NUMBER;

BEGIN

  -- Validate the ESN is passed
  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  -- Get the cos value from a subscriber list
  BEGIN
    SELECT cos
    INTO   l_cos
    FROM   x_policy_rule_subscriber
    WHERE  esn = i_esn
    AND    i_as_of_date BETWEEN start_date AND NVL(end_date,SYSDATE)
    AND    inactive_flag = 'N';
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
  END;

  -- Return the cos value from the subscriber list when available
  IF l_cos IS NOT NULL THEN
    RETURN l_cos;
  END IF;

  -- Get the part class objid
  IF i_part_class_name IS NOT NULL THEN
    BEGIN
      SELECT objid
      INTO   l_part_class_objid
      FROM   table_part_class
      WHERE  name = i_part_class_name;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
  END IF;

  -- Get the activation date
  BEGIN
    SELECT MAX(install_date)
    INTO   l_install_date
    FROM   table_site_part
    WHERE  x_service_id = i_esn
    AND    x_min = i_min;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- Calculate the amount of days a customer has been active
  IF l_install_date IS NOT NULL THEN
    l_active_days := FLOOR(i_as_of_date - l_install_date);
  END IF;

  -- Select the COS value from the rule table
  BEGIN
    SELECT cos
    INTO   l_cos
    FROM   ( SELECT cos
             FROM   x_policy_rule_config xprc
             WHERE  1 = 1
             AND    SYSDATE BETWEEN xprc.start_date AND xprc.end_date -- rule is not expired
             AND    xprc.inactive_flag = 'N' -- rule is active
             AND    ( ( xprc.install_date_applicable_flag = 'Y' AND
                        l_install_date BETWEEN xprc.activation_date_from AND xprc.activation_date_to
                      )
                      OR xprc.install_date_applicable_flag = 'N'
                    )
             AND    ( ( xprc.active_days_applicable_flag = 'Y' AND
                        l_active_days BETWEEN xprc.active_days_from AND xprc.active_days_to
                      )
                      OR xprc.active_days_applicable_flag = 'N'
                    )
             AND    ( ( ( xprc.parent_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_parent
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    parent_name = i_parent_name -- subscriber's carrier parent name
                                   AND    inactive_flag = 'N'
                                 )
                         )
                         OR xprc.parent_applicable_flag = 'N'
                      )
                      AND
                      ( ( xprc.part_class_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_part_class
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    part_class_objid = l_part_class_objid -- subscriber's part class
                                   AND    inactive_flag = 'N'
                                 )
                        )
                        OR xprc.part_class_applicable_flag = 'N'
                      )
                      AND
                      ( ( xprc.service_plan_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_service_plan
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    service_plan_objid = i_service_plan_objid -- subscriber's service plan
                                   AND    inactive_flag = 'N'
                                 )
                        )
                        OR xprc.service_plan_applicable_flag = 'N'
                      )
                      AND
                      ( ( xprc.dealer_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_dealer
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    site_id = i_site_id -- subscriber's dealer
                                   AND    inactive_flag = 'N'
                                 )
                        )
                        OR xprc.dealer_applicable_flag = 'N'
                      )
                      AND
                      ( ( xprc.brand_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_brand
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    bus_org_objid = i_bus_org_objid -- subscriber's brand
                                   AND    inactive_flag = 'N'
                                 )
                        )
                        OR xprc.brand_applicable_flag = 'N'
                      )
                    )
              ORDER BY priority -- order by the priority hierarchy
            )
     WHERE ROWNUM = 1; -- only return one rule

     --
     IF l_cos IS NOT NULL THEN
       NULL;
     END IF;
     --
    EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- If a rule was not determined
  IF l_cos IS NULL THEN
    -- Use original function to get the COS
    l_cos := cst.get_min_cos_value ( i_min              => i_min,
                                     i_as_of_date       => i_as_of_date,
                                     i_bypass_date_flag => 'Y');
  END IF;

  -- If a rule was not found use the cos value passed from the customer type
  IF l_cos IS NULL OR
     l_cos = '0'
  THEN
    IF i_service_plan_objid IS NOT NULL THEN
      -- get the cos from the service plan feature
      BEGIN
        SELECT cos cos
        INTO   l_cos
        FROM   sa.service_plan_feat_pivot_mv
        WHERE  service_plan_objid = i_service_plan_objid;
       EXCEPTION
         WHEN OTHERS THEN
           NULL;
      END;
    END IF;
  END IF;

  RETURN l_cos;

EXCEPTION
   WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE('ERROR IN GET_COS: ' || SQLERRM);
     RETURN ('0');
END get_cos;

-- Overloaded method used to get the necessary attributes to calculate the cos from the rule engine
MEMBER FUNCTION get_cos ( i_esn                IN VARCHAR2,
                          i_as_of_date         IN DATE DEFAULT SYSDATE) RETURN VARCHAR2 AS

  rc                  red_card_type := red_card_type ();
  c                   red_card_type;
  l_cos               sa.x_policy_rule_config.cos%TYPE;
  l_active_days       NUMBER;

BEGIN

  -- Validate the ESN is passed
  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  -- Get the cos value from a subscriber list
  BEGIN
    SELECT cos
    INTO   l_cos
    FROM   x_policy_rule_subscriber
    WHERE  esn = i_esn
    AND    i_as_of_date BETWEEN start_date AND NVL(end_date,SYSDATE)
    AND    inactive_flag = 'N';
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
  END;

  -- Return the cos value from the subscriber list when available
  IF l_cos IS NOT NULL THEN
    RETURN l_cos;
  END IF;

  -- Call the get_cos_attributes method from the subscriber type
  c := rc.get_cos_attributes ( i_esn => i_esn);

  -- Calculate the amount of days a customer has been active
  IF c.install_date IS NOT NULL THEN
    l_active_days := FLOOR(i_as_of_date - c.install_date);
  END IF;

  -- Select the COS value from the rule table
  BEGIN
    SELECT cos
    INTO   l_cos
    FROM   ( SELECT cos
             FROM   x_policy_rule_config xprc
             WHERE  1 = 1
             AND    SYSDATE BETWEEN xprc.start_date AND xprc.end_date -- rule is not expired
             AND    xprc.inactive_flag = 'N' -- rule is active
             AND    ( ( xprc.install_date_applicable_flag = 'Y' AND
                        c.install_date BETWEEN xprc.activation_date_from AND xprc.activation_date_to
                      )
                      OR xprc.install_date_applicable_flag = 'N'
                    )
             AND    ( ( xprc.active_days_applicable_flag = 'Y' AND
                        l_active_days BETWEEN xprc.active_days_from AND xprc.active_days_to
                      )
                      OR xprc.active_days_applicable_flag = 'N'
                    )
             AND    ( ( ( xprc.parent_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_parent
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    parent_name = c.parent_name -- subscriber's carrier parent name
                                   AND    inactive_flag = 'N'
                                 )
                         )
                         OR xprc.parent_applicable_flag = 'N'
                      )
                      AND
                      ( ( xprc.part_class_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_part_class
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    part_class_objid = c.part_class_objid -- subscriber's part class
                                   AND    inactive_flag = 'N'
                                 )
                        )
                        OR xprc.part_class_applicable_flag = 'N'
                      )
                      AND
                      ( ( xprc.service_plan_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_service_plan
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    service_plan_objid = c.service_plan_objid -- subscriber's service plan
                                   AND    inactive_flag = 'N'
                                 )
                        )
                        OR xprc.service_plan_applicable_flag = 'N'
                      )
                      AND
                      ( ( xprc.dealer_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_dealer
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    site_id = c.site_id -- subscriber's dealer
                                   AND    inactive_flag = 'N'
                                 )
                        )
                        OR xprc.dealer_applicable_flag = 'N'
                      )
                      AND
                      ( ( xprc.brand_applicable_flag = 'Y' AND
                          EXISTS ( SELECT 1
                                   FROM   sa.x_policy_rule_brand
                                   WHERE  policy_rule_config_objid = xprc.objid
                                   AND    bus_org_objid = c.bus_org_objid -- subscriber's brand
                                   AND    inactive_flag = 'N'
                                 )
                        )
                        OR xprc.brand_applicable_flag = 'N'
                      )
                    )
              ORDER BY priority -- order by the priority hierarchy
            )
     WHERE ROWNUM = 1; -- only return one rule

     --
     IF l_cos IS NOT NULL THEN
       NULL;
     END IF;
     --
    EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- If a rule was not determined
  IF l_cos IS NULL THEN
    -- Use original function to get the COS
    l_cos := c.get_min_cos_value ( i_min              => c.min,
                                    i_as_of_date       => i_as_of_date,
                                    i_bypass_date_flag => 'Y');
  END IF;

  -- If a rule was not found use the cos value passed from the customer type
  IF l_cos IS NULL OR
     l_cos = '0'
  THEN
    IF c.service_plan_objid IS NOT NULL THEN
      -- get the cos from the service plan feature
      BEGIN
        SELECT cos cos
        INTO   l_cos
        FROM   sa.service_plan_feat_pivot_mv
        WHERE  service_plan_objid = c.service_plan_objid;
       EXCEPTION
         WHEN OTHERS THEN
           NULL;
      END;
    END IF;
  END IF;

  RETURN l_cos;

EXCEPTION
   WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE('ERROR IN OVERLOADED GET_COS: ' || SQLERRM);
     RETURN ('0');
END get_cos;

-- Function used to get the cos value from a given MIN in Clarify
MEMBER FUNCTION get_min_cos_value ( i_min              IN VARCHAR2,
                                    i_as_of_date       IN DATE DEFAULT SYSDATE,
                                    i_bypass_date_flag IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2 AS

  l_site_part_objid            NUMBER;
  l_service_plan_objid         NUMBER;
  l_activation_date            DATE;
  l_cos                        VARCHAR2(30);
  l_exception_cos_value_exists NUMBER;
  l_esn                        VARCHAR2(30);
BEGIN

  -- Bypass historical data check
  IF ( i_bypass_date_flag = 'N' ) THEN

    IF TRUNC(i_as_of_date) < TRUNC(SYSDATE) THEN
      -- Get the service plan history data
      BEGIN
        SELECT sp.objid site_part_objid,
               plan_hist2service_plan service_plan_id,
               sph.x_start_date activation_date,
               sp.x_service_id esn
        INTO   l_site_part_objid,
               l_service_plan_objid,
               l_activation_date,
               l_esn
        FROM   x_service_plan_hist sph,
               table_site_part sp
        WHERE  1 = 1
        AND    sp.x_min = i_min
        AND    sp.objid = sph.plan_hist2site_part
        AND    sph.x_start_date = ( SELECT MAX(sph2.x_start_date)
                                      FROM table_site_part sp2,
                                           x_service_plan_hist sph2
                                     WHERE sp2.x_min = sp.x_min
                                       AND sp2.objid = sph2.plan_hist2site_part
                                       AND sph2.x_start_date < i_as_of_date
                                  );
       EXCEPTION
          WHEN others THEN
            NULL;
      END;

    END IF;

  END IF;

  -- If the service plan history data was not found
  IF l_activation_date IS NULL OR
     l_esn IS NULL OR
     l_service_plan_objid IS NULL
  THEN
     -- Get the site part info
     BEGIN
       SELECT sp.objid,
              spsp.x_service_plan_id service_plan_id,
              sp.install_date activation_date,
              sp.x_service_id esn
       INTO   l_site_part_objid,
              l_service_plan_objid,
              l_activation_date,
              l_esn
       FROM   sa.table_site_part sp,
              sa.x_service_plan_site_part spsp
       WHERE  sp.x_min = i_min
       AND    sp.part_status = 'Active'
       AND    sp.objid = spsp.table_site_part_id
       AND    EXISTS ( SELECT 1
                       FROM   x_service_plan
                       WHERE  objid = spsp.x_service_plan_id
                     )
       AND    ROWNUM = 1;
      EXCEPTION
         WHEN no_data_found THEN
           BEGIN
             SELECT objid,
                    service_plan_id,
                    activation_date,
                    esn
             INTO   l_site_part_objid,
                    l_service_plan_objid,
                    l_activation_date,
                    l_esn
             FROM   ( SELECT sp.objid,
                             spsp.x_service_plan_id service_plan_id,
                             sp.install_date activation_date,
                             sp.x_service_id esn
                      FROM   sa.table_site_part sp,
                             sa.x_service_plan_site_part spsp
                      WHERE  sp.x_min = i_min
                      AND    sp.objid = spsp.table_site_part_id
                      ORDER BY sp.install_date DESC
                    )
             WHERE  ROWNUM = 1;
            EXCEPTION
              WHEN others THEN
                RETURN('0');
           END;
         WHEN others THEN
           RETURN('0');
     END;
  END IF;

  -- Added by Juda Pena for CR34362 to determine the COS value from a feature exception driven by the case table
  BEGIN
    -- Get the COS value from the case exception created
    SELECT COUNT(1)
    INTO   l_exception_cos_value_exists
    FROM   sa.table_case c
    WHERE  x_esn = l_esn
    AND    x_case_type = 'Data Issues'
    AND    title = 'CDMA 5G Exception'
    -- Make sure the case is not closed
    AND    NOT EXISTS ( SELECT 1
                        FROM   sa.table_condition
                        WHERE  objid = c.case_state2condition
                        AND    s_title||'' = 'CLOSED'
                      );
    -- If there is one or more case(s) then ...
    IF l_exception_cos_value_exists > 0 THEN
      BEGIN
        SELECT exception_cos --
        INTO   l_cos
        FROM   sa.service_plan_feat_pivot_mv
        WHERE  1 = 1
        AND    service_plan_objid = l_service_plan_objid;
       EXCEPTION
         WHEN others THEN
           -- Do not fail when an error occurs
           NULL;
      END;
    END IF;
   EXCEPTION
     WHEN no_data_found THEN
       -- Do not fail when not available
       NULL;
     WHEN others THEN
       -- Do not fail when an error occurred
       NULL;
  END;
  -- End logic CR34362

  IF l_cos IS NOT NULL THEN
    RETURN l_cos;
  END IF;

  IF l_service_plan_objid IS NOT NULL THEN
    --
    BEGIN
      SELECT cos
      INTO   l_cos
      FROM   sa.service_plan_feat_pivot_mv
      WHERE  service_plan_objid = l_service_plan_objid;
     EXCEPTION
       WHEN OTHERS THEN
         NULL;
    END;
  END IF;

  RETURN l_cos;

EXCEPTION
   WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE('ERROR IN GET_MIN_COS_VALUE: ' || SQLERRM);
     RETURN('0');
END get_min_cos_value;

-- Function used to get the necessary attributes for the cos rule engine
MEMBER FUNCTION get_cos_attributes ( i_esn IN VARCHAR2 ) RETURN red_card_type IS

  cst  red_card_type := red_card_type();
  c    red_card_type := SELF;

BEGIN

  cst.esn := i_esn;

  cst.min := NULL;

  --
  IF cst.esn IS NULL THEN
    cst.response := 'NO ESN PASSED';
    RETURN cst;
  END IF;

  -- Get the min, carrier parent and wf_mac_id
  BEGIN
    SELECT pi_min.part_serial_no min,
           pi_esn.objid esn_part_inst_objid,
           pi_min.objid min_part_inst_objid,
           pi_min.part_inst2carrier_mkt carrier_objid
    INTO   cst.min,
           cst.esn_part_inst_objid,
           cst.min_part_inst_objid,
           cst.carrier_objid
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
         SELECT pi_esn.objid esn_part_inst_objid,
                pi_esn.x_wf_mac_id wf_mac_id,
                pi_esn.x_part_inst_status esn_part_inst_status
         INTO   cst.esn_part_inst_objid,
                cst.wf_mac_id,
                cst.esn_part_inst_status
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
  END;

  -- get carrier parent name
  IF cst.carrier_objid IS NOT NULL THEN
    BEGIN
      SELECT p.x_parent_name parent_name
      INTO   cst.parent_name
      FROM   table_x_parent p,
             table_x_carrier_group cg,
             table_x_carrier c
      WHERE  c.objid = cst.carrier_objid
      AND    c.carrier2carrier_group = cg.objid
      AND    cg.x_carrier_group2x_parent = p.objid;
     EXCEPTION
       WHEN others THEN
         cst.response := cst.response || 'CARRIER PARENT NAME NOT FOUND';
    END;
  END IF;

  -- Get the web user and contact (Active site part status)
  BEGIN
    SELECT sp.objid site_part_objid,
           NVL2(cst.min, cst.min, sp.x_min) min,
           sp.install_date
    INTO   cst.site_part_objid,
           cst.min,
           cst.install_date
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
                NVL2(cst.min, cst.min, sp.x_min) min,
                sp.install_date
         INTO   cst.site_part_objid,
                cst.min,
                cst.install_date
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
            cst.response := cst.response || '|STATUS, ZIPCODE NOT FOUND';
          WHEN others THEN
            cst.response := cst.response || '|STATUS, ZIPCODE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       END;
     WHEN others THEN
       cst.response := cst.response || '|STATUS, ZIPCODE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN cst;
  END;

  -- Get the activation date
  IF cst.install_date IS NULL THEN
    BEGIN
      SELECT MAX(install_date)
      INTO   cst.install_date
      FROM   table_site_part
      WHERE  x_service_id = cst.esn
      AND    x_min = cst.min;
     EXCEPTION
       WHEN others THEN
         cst.response := cst.response || '|INSTALL DATE NOT FOUND';
    END;
  END IF;

  --
  IF cst.site_part_objid IS NOT NULL THEN
    -- Get the service plan and cos
    BEGIN
      SELECT spsp.x_service_plan_id,
             fea.cos
      INTO   cst.service_plan_objid,
             cst.cos
      FROM   x_service_plan_site_part spsp,
             sa.service_plan_feat_pivot_mv fea
      WHERE  spsp.table_site_part_id = cst.site_part_objid
      AND    spsp.x_service_plan_id = fea.service_plan_objid;
     EXCEPTION
      WHEN too_many_rows THEN
        cst.response := cst.response || '|DUPLICATE SERVICE PLAN, COS';
      WHEN OTHERS THEN
        cst.response := cst.response || '|SERVICE PLAN NOT FOUND';
    END;

  END IF;

  -- Get the dealer, brand and other features
  BEGIN
    SELECT pcpv.bus_org bus_org_id,
           pn.part_num2bus_org bus_org_objid,
           pcpv.part_class part_class_name,
           pn.part_num2part_class part_class_objid,
           pi.part_inst2inv_bin inv_bin_objid
    INTO   cst.bus_org_id,
           cst.bus_org_objid,
           cst.part_class_name,
           cst.part_class_objid,
           cst.inv_bin_objid
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           pcpv_mv pcpv
    WHERE  1 = 1
    AND    pi.part_serial_no = cst.esn
    AND    pi.x_domain = 'PHONES'
    AND    pi.n_part_inst2part_mod = ml.objid
    AND    ml.part_info2part_num = pn.objid
    AND    pn.domain = 'PHONES'
    AND    pn.part_num2part_class = pcpv.pc_objid;
   EXCEPTION
    WHEN others THEN
      cst.response := cst.response || '|PART NUMBER, PART CLASS NOT FOUND';
  END;

  -- get dealer id
  IF cst.inv_bin_objid IS NOT NULL THEN
    BEGIN
      SELECT bin_name
      INTO   cst.dealer_id
      FROM   table_inv_bin
      WHERE  objid = cst.inv_bin_objid;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
  END IF;

  -- Get the activation site id
  BEGIN
    SELECT s.site_id
    INTO   cst.site_id
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

  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  RETURN cst;

EXCEPTION
   WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE('ERROR IN GET_COS_ATTRIBUTES: ' || SQLERRM);
     cst.response := 'ERROR RETRIEVING COS ATTRIBUTES: ' || SQLERRM;
     RETURN cst;
     --
END get_cos_attributes;

-- Function used get the expiration date from site part
MEMBER FUNCTION get_expiration_date ( i_esn IN VARCHAR2 ) RETURN DATE IS

  cst red_card_type := SELF;

BEGIN

  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  BEGIN
    SELECT MAX(sp.x_expire_dt)
    INTO   cst.expiration_date
    FROM   table_site_part sp
    WHERE  1 = 1
    AND    sp.x_service_id = i_esn
    AND    ( ( sp.part_status = 'Active' AND
               sp.x_min IN ( SELECT pi_min.part_serial_no
                             FROM   table_part_inst pi_esn,
                                    table_part_inst pi_min
                             WHERE  1 = 1
                             AND    pi_esn.part_serial_no = sp.x_service_id
                             AND    pi_esn.x_domain = 'PHONES'
                             AND    pi_esn.objid = pi_min.part_to_esn2part_inst
                             AND    pi_min.x_domain = 'LINES'
                           )
             )
             OR
             ( sp.part_status <> 'Active')
           );
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  RETURN cst.expiration_date;

EXCEPTION
   WHEN others THEN
     DBMS_OUTPUT.PUT_LINE('ERROR IN GET_EXPIRATION_DATE: ' || SQLERRM);
     RETURN NULL;
END get_expiration_date;

-- Function used get the last redemption date from site part
MEMBER FUNCTION get_last_redemption_date ( i_esn IN VARCHAR2) RETURN DATE IS

  cst  red_card_type := SELF;
  c    red_card_type := red_card_type();
BEGIN
   BEGIN
     SELECT NVL(vw.device_type,'FEATURE_PHONE')
     INTO   c.device_type
     FROM   table_part_inst pi,
            table_mod_level ml,
            table_part_num pn,
            table_part_class pc,
            sa.pcpv_mv vw
     WHERE  pi.part_serial_no = i_esn
     AND    pi.n_part_inst2part_mod= ml.objid
     AND    ml.part_info2part_num = pn.objid
     AND    pn.part_num2part_class = pc.objid
     AND    pc.name = vw.part_class;
    EXCEPTION
      WHEN OTHERS THEN
        c.device_type := 'FEATURE_PHONE';
  END;

  IF c.device_type IN ('WIRELESS_HOME_PHONE', 'FEATURE_PHONE') THEN
    BEGIN
      SELECT MAX(ct.x_transact_date)
      INTO   c.last_redemption_date
      FROM   table_x_call_trans ct
      WHERE  x_service_id = i_esn
      AND    x_action_type+0 in ( 1, 3, 6)
      AND    x_result = 'Completed';
      --
      RETURN c.last_redemption_date;
     EXCEPTION
       WHEN OTHERS THEN
         RETURN NULL;
    END;
  END IF;

  -- Get the min and install date
  BEGIN
    SELECT min,
           install_date
            INTO   c.min,
                   c.install_date
    FROM   ( SELECT x_min min,
                    install_date
             FROM   table_site_part
             WHERE  x_service_id = i_esn
             ORDER  BY install_date DESC
           )
    WHERE  ROWNUM = 1;
   EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
  END;

  FOR all_esns IN ( SELECT x_service_id, install_date, part_status
                    FROM   table_site_part
                    WHERE  x_min = c.min
                                                            AND    TRUNC(install_date) <= c.install_date
                    ORDER BY install_date DESC
                  )
  LOOP
    SELECT MAX(x_transact_date)
    INTO   c.last_redemption_date
    FROM   ( WITH esns AS ( SELECT esn
                            FROM   x_account_group_member
                            WHERE  account_group_id in ( SELECT account_group_id
                                                         FROM   x_account_group_member
                                                         WHERE  UPPER(status) <> 'EXPIRED'
                                                         AND    esn = all_esns.x_service_id
                                                       )
                            UNION
                            SELECT part_serial_no
                            FROM   table_part_inst
                            WHERE  part_serial_no = all_esns.x_service_id
                          ) ,
                  pph AS ( SELECT /*+ ORDERED */
                                  ppd.x_esn esn,hdr.x_rqst_date --  ppd.*, ppd.x_esn,tsp.x_min,sp.objid
                           FROM   x_program_purch_dtl ppd,
                                  x_program_purch_hdr hdr,
                                  x_program_enrolled pe,
                                  x_service_plan_site_part spsp,
                                  table_site_part tsp,
                                  x_program_parameters pp,
                                  mtm_sp_x_program_param mtm,
                                  x_service_plan sp
                           WHERE  1 = 1
                           AND    hdr.x_ics_rflag in ('ACCEPT', 'SOK')
                           AND    NVL(hdr.x_ics_rcode,'0') IN ('1','100')
                           AND    hdr.x_merchant_id IS NOT NULL -- Exclude BML
                           AND    hdr.x_payment_type NOT IN ('REFUND', 'OTAPURCH') -- Exclude Refunds and mobile billing
                           AND    ppd.pgm_purch_dtl2prog_hdr = hdr.objid
                           AND    pe.objid = ppd.pgm_purch_dtl2pgm_enrolled
                           AND    spsp.table_site_part_id = pe.pgm_enroll2site_part
                           AND    tsp.objid = spsp.table_site_part_id
                           AND    pp.objid = pe.pgm_enroll2pgm_parameter
                           AND    mtm.x_sp2program_param = pp.objid
                           AND    mtm.program_para2x_sp = spsp.x_service_plan_id
                           AND    sp.objid = mtm.program_para2x_sp
                         ) ,
                  ct AS ( SELECT ct.x_service_id esn,
                                 ct.x_transact_date
                          FROM   table_x_call_trans ct
                          WHERE  ct.x_action_type+0 in ( 1, 3, 6)
                          AND EXISTS ( SELECT 1
                                       FROM   x_serviceplanfeaturevalue_def a,
                                              sa.mtm_partclass_x_spf_value_def b,
                                              sa.x_serviceplanfeaturevalue_def c,
                                              sa.mtm_partclass_x_spf_value_def d,
                                              x_serviceplanfeature_value spfv,
                                              x_service_plan_feature spf,
                                              x_service_plan sp
                                       WHERE  a.objid = b.spfeaturevalue_def_id
                                       AND    b.part_class_id in ( SELECT pn.part_num2part_class
                                                                   FROM   table_x_red_card rc,
                                                                          -- validate there is a base service plan redemption from red card
                                                                          table_mod_level ml,
                                                                          table_part_num pn
                                                                   WHERE  1 = 1
                                                                   AND    rc.red_card2call_trans = ct.objid
                                                                   AND    ml.objid = rc.x_red_card2part_mod
                                                                   AND    pn.objid = ml.part_info2part_num
                                                                   AND    pn.domain = 'REDEMPTION CARDS'
                                                                 )
                                       -- Include the base service plans only (not the add on)
                                       AND NOT EXISTS ( SELECT 1
                                                        FROM   sa.service_plan_feat_pivot_mv
                                                        WHERE  service_plan_objid = sp.objid
                                                        AND    service_plan_group = 'ADD_ON_DATA'
                                                      )
                                       AND    c.objid = d.spfeaturevalue_def_id
                                       AND    d.part_class_id = ( SELECT pn.part_num2part_class
                                                                  FROM   table_part_inst pi,
                                                                         table_mod_level ml,
                                                                         table_part_num pn
                                                                  WHERE  1 = 1
                                                                  AND    pi.part_serial_no   = ct.x_service_id
                                                                  AND    pi.x_domain         = 'PHONES'
                                                                  AND    ml.objid            = pi.n_part_inst2part_mod
                                                                  AND    pn.objid            = ml.PART_INFO2PART_NUM
                                                                  AND    pn.domain           = 'PHONES'
                                                                )
                                       AND    a.value_name = c.value_name
                                       AND    spfv.value_ref = c.objid
                                       AND    spf.objid = spfv.spf_value2spf
                                       AND    sp.objid = spf.sp_feature2service_plan
                                     )
                        )
             SELECT ct.*
             FROM   ct,
                    esns
             WHERE  ct.esn = esns.esn
             UNION
             SELECT pph.*
             FROM   esns,
                    pph
             WHERE  pph.esn = esns.esn
           );

    EXIT WHEN c.last_redemption_date IS NOT NULL;

  END LOOP;

  IF c.last_redemption_date IS NULL THEN
    SELECT MAX(x_transact_date)
    INTO   c.last_redemption_date
    FROM   table_x_call_trans ct
    WHERE  x_action_type IN ( 1, 3, 6)
    AND    x_service_id = i_esn;
  END IF;

  IF c.last_redemption_date IS NULL THEN
    SELECT MAX(install_date)
    INTO   c.last_redemption_date
    FROM   table_site_part sp
    WHERE  x_service_id = i_esn;
  END IF;

  RETURN (c.last_redemption_date);

EXCEPTION
   WHEN others THEN
     DBMS_OUTPUT.PUT_LINE('ERROR IN GET_LAST_REDEMPTION_DATE: ' || SQLERRM);
     RETURN NULL;
END get_last_redemption_date;

-- Function used to get the ota conversion rate
MEMBER FUNCTION get_ota_conversion_rate ( i_esn_part_inst_objid IN NUMBER ) RETURN VARCHAR2 IS

  cst  red_card_type := SELF;

BEGIN
  --
  BEGIN
    SELECT x_current_conv_rate
            INTO   cst.conversion_rate
    FROM   table_x_ota_features
    WHERE  x_ota_features2part_inst = i_esn_part_inst_objid;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;
  --
  RETURN cst.conversion_rate;
EXCEPTION
   WHEN others THEN
     DBMS_OUTPUT.PUT_LINE('ERROR IN GET_OTA_CONVERSION_RATE: ' || SQLERRM);
     RETURN NULL;
END get_ota_conversion_rate;

-- Function used to get all the attributes related to part class
MEMBER FUNCTION get_part_class_attributes ( i_esn IN VARCHAR2 ) RETURN red_card_type IS

  cst  red_card_type := SELF;
  c    red_card_type := SELF;

BEGIN

  -- Initialize entire cst type with an empty object
  cst := red_card_type ();

  cst.esn := i_esn;

  -- Exit when the ESN is not passed
  IF cst.esn IS NULL THEN
    cst.response := 'ESN NOT PASSED';
    RETURN cst;
  END IF;

  -- Get the dealer, brand and other features
  BEGIN
    SELECT pcpv.bus_org bus_org_id,
           pcpv.firmware firmware,
           pcpv.motricity_denomination motricity_denomination,
           pn.x_manufacturer phone_manufacturer,
           pcpv.model_type model_type,
           pn.part_num2bus_org bus_org_objid,
           pcpv.technology,
           pcpv.part_class part_class_name,
           pcpv.device_type,
           pn.part_num2part_class part_class_objid,
           pn.part_number,
           pi.part_inst2inv_bin inv_bin_objid,
           pcpv.non_ppe non_ppe_flag,
           pcpv.phone_gen phone_generation,
           pcpv.data_speed
    INTO   cst.bus_org_id,
           cst.firmware,
           cst.motricity_denomination,
           cst.phone_manufacturer,
           cst.model_type,
           cst.bus_org_objid,
           cst.technology,
           cst.part_class_name,
           cst.device_type,
           cst.part_class_objid,
           cst.esn_part_number,
           cst.inv_bin_objid,
           cst.non_ppe_flag,
           cst.phone_generation,
           cst.data_speed
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           pcpv_mv pcpv
    WHERE  1 = 1
    AND    pi.part_serial_no = cst.esn
    AND    pi.x_domain = 'PHONES'
    AND    pi.n_part_inst2part_mod = ml.objid
    AND    ml.part_info2part_num = pn.objid
    AND    pn.domain = 'PHONES'
    AND    pn.part_num2part_class = pcpv.pc_objid;
   EXCEPTION
    WHEN others THEN
      cst.response := 'PART CLASS NOT FOUND';
  END;

  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  -- Return the type
  RETURN cst;

EXCEPTION
   WHEN OTHERS THEN
     cst.response := 'ERROR RETRIEVING CUSTOMER: ' || SQLERRM;
     RETURN cst;
END get_part_class_attributes;

-- Function used to get the attributes pertinent to a port out request
MEMBER FUNCTION get_port_out_attributes ( i_min IN VARCHAR2 ) RETURN red_card_type IS

  cst  red_card_type := red_card_type ();
  c    red_card_type := red_card_type ();

BEGIN

  -- Initialize entire cst type with an empty object
  cst := red_card_type ();

  cst.min := i_min;

  -- Exit when the ESN is not passed
  IF cst.min IS NULL THEN
    cst.response := 'MIN NOT PASSED';
    RETURN cst;
  END IF;

  -- Get the ESN from part inst relationship
  BEGIN
    SELECT pi_esn.part_serial_no        ,
                   pi_min.x_part_inst_status,
           pi_min.status2x_code_table,
           pi_min.x_cool_end_date,
           pi_min.warr_end_date,
           pi_min.repair_date,
           pi_min.part_inst2x_pers,
           pi_min.part_inst2x_new_pers,
           pi_min.part_to_esn2part_inst,
           pi_min.last_cycle_ct,
           pi_min.x_port_in
    INTO   cst.esn                        ,
           cst.min_part_inst_status       ,
           cst.min_part_inst_code         ,
           cst.min_cool_end_date          ,
           cst.min_warr_end_date          ,
           cst.repair_date                ,
           cst.min_personality_objid      ,
           cst.min_new_personality_objid  ,
           cst.min_to_esn_part_inst_objid ,
           cst.last_cycle_date            ,
           cst.port_in
    FROM   table_part_inst pi_min,
           table_part_inst pi_esn
    WHERE  pi_min.part_serial_no = cst.min
    AND    pi_min.x_domain = 'LINES'
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst;
   EXCEPTION
     WHEN others THEN
       -- Get the ESN from site part relationship
       BEGIN
         SELECT sp.x_service_id
         INTO   cst.esn
         FROM   sa.table_site_part sp,
                sa.table_part_inst pi_min
         WHERE  sp.x_min = cst.min
         AND    sp.objid = pi_min.x_part_inst2site_part;
        EXCEPTION
          WHEN others THEN
            cst.response := 'MIN NOT FOUND';
            RETURN cst;
       END;
  END;

  c := cst.retrieve;

  cst.response := c.response;

  IF c.site_part_objid IS NOT NULL THEN
    BEGIN
      SELECT service_end_dt,
             x_deact_reason,
             x_notify_carrier,
             part_status,
             site_part2x_new_plan
      INTO   c.service_end_date,
             c.deactivation_reason,
             c.notify_carrier,
             c.site_part_status,
             c.service_plan_objid
      FROM   sa.table_site_part
              WHERE  objid = c.site_part_objid;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
            --
  END IF;

  --
  BEGIN
    SELECT objid,
           x_ild_status
    INTO   c.ild_transaction_objid,
           c.ild_transaction_status
    FROM   table_x_ild_transaction
            WHERE  x_esn = c.esn;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- Set successful response
  c.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  -- Return the type
  RETURN c;

EXCEPTION
   WHEN OTHERS THEN
     c.response := 'ERROR RETRIEVING PORT OUT ATTRIBUTES: ' || SQLERRM;
     RETURN c;
END get_port_out_attributes;

-- Function used to get the propagate flag from the rate plan table
MEMBER FUNCTION get_propagate_flag ( i_rate_plan IN VARCHAR2 ) RETURN NUMBER IS

  cst  red_card_type := SELF;

BEGIN
  --
  BEGIN
    SELECT NVL(propagate_flag_value,0)
    INTO   cst.propagate_flag
    FROM   x_rate_plan
    WHERE  x_rate_plan = i_rate_plan;
   EXCEPTION
     WHEN OTHERS THEN
       cst.propagate_flag := 0;
  END;

  --
  RETURN cst.propagate_flag;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR IN GET_PROPAGATE_FLAG: ' || SQLERRM);
    RETURN NULL;
END get_propagate_flag;

-- Function used to get the rate plan of an ESN
MEMBER FUNCTION get_rate_plan ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS

  cst  red_card_type := SELF;

BEGIN
  -- ESN is a mandatory input parameter
  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  -- Get the rate plan from the ig rate plan tables
  BEGIN
    SELECT rate_plan
    INTO   cst.rate_plan
    FROM   ( SELECT *
             FROM   ( SELECT rate_plan,
                             rate_plan_date
                      FROM   gw1.ig_rate_plan_history
                      WHERE  esn = i_esn
                      AND    order_type NOT IN  ('S','D')
                      UNION
                      SELECT rate_plan,
                             rate_plan_date
                      FROM   gw1.ig_rate_plan_history_archive
                      WHERE  esn = i_esn
                      AND    order_type NOT IN  ('S','D')
                    )
             ORDER BY rate_plan_date DESC
           )
    WHERE ROWNUM = 1;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  --
  IF cst.rate_plan IS NULL THEN
    -- call the function from the service plan package
    RETURN service_plan.f_get_esn_rate_plan ( p_esn => i_esn);
  ELSE
    RETURN cst.rate_plan;
  END IF;

EXCEPTION
   WHEN others THEN
     DBMS_OUTPUT.PUT_LINE('ERROR IN GET_RATE_PLAN: ' || SQLERRM);
     RETURN NULL;
END get_rate_plan;

-- Added on 11/26/2014 by Juda Pena to determine if the brand allows shared groups
MEMBER FUNCTION get_service_plan_attributes RETURN red_card_type IS
  cst red_card_type := SELF;
BEGIN

  -- Get the web user and contact (Active site part status)
  BEGIN
    SELECT sp.x_zipcode zipcode,
           sp.objid site_part_objid,
           sp.part_status,
           sp.x_iccid,
           NVL2(cst.min, cst.min, sp.x_min) min,
           sp.install_date
    INTO   cst.zipcode,
           cst.site_part_objid,
           cst.site_part_status,
           cst.iccid,
           cst.min,
           cst.install_date
    FROM   table_site_part sp
    WHERE  1 = 1
    AND    sp.x_service_id = cst.esn
    AND    sp.part_status = 'Active';
   EXCEPTION
     WHEN no_data_found THEN
       -- get the zipcode, iccid and site part status for the last updated row in site part
       BEGIN
         SELECT sp.x_zipcode zipcode,
                sp.objid site_part_objid,
                sp.part_status,
                sp.x_iccid,
                NVL2(cst.min, cst.min, sp.x_min) min
         INTO   cst.zipcode,
                cst.site_part_objid,
                cst.site_part_status,
                cst.iccid,
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
         SELECT sp.x_zipcode zipcode,
                sp.objid site_part_objid,
                sp.part_status,
                sp.x_iccid,
                NVL2(cst.min, cst.min, sp.x_min) min,
                sp.install_date
         INTO   cst.zipcode,
                cst.site_part_objid,
                cst.site_part_status,
                cst.iccid,
                cst.min,
                cst.install_date
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
            cst.response := cst.response || '|STATUS, ZIPCODE NOT FOUND';
          WHEN others THEN
            cst.response := cst.response || '|STATUS, ZIPCODE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       END;
     WHEN others THEN
       cst.response := cst.response || '|STATUS, ZIPCODE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN cst;
  END;

  --
  IF cst.site_part_objid IS NOT NULL THEN
    -- Get the service plan and cos
    BEGIN
      SELECT spsp.x_service_plan_id,
             fea.mkt_name,
             NVL(fea.number_of_lines,1),
                                    fea.service_plan_group,
             CASE WHEN UPPER(fea.data) IN ('UNLIMITED','NA','DYNAMIC') THEN 0 ELSE TO_NUMBER(fea.data) END service_plan_data,
             fea.plan_purchase_part_number,
                                    TRIM(regexp_replace(NVL(fea.service_days,0),'[[:alpha:]]','') )
      INTO   cst.service_plan_objid,
             cst.service_plan_name,
             cst.group_allowed_lines,
             cst.service_plan_group,
             cst.service_plan_data,
             cst.service_plan_part_number,
                                    cst.service_plan_days
      FROM   x_service_plan_site_part spsp,
             sa.service_plan_feat_pivot_mv fea
      WHERE  spsp.table_site_part_id = cst.site_part_objid
      AND    spsp.x_service_plan_id = fea.service_plan_objid;
     EXCEPTION
      WHEN too_many_rows THEN
        cst.response := cst.response || '|DUPLICATE SERVICE PLAN, COS';
      WHEN OTHERS THEN
        cst.response := cst.response || '|SERVICE PLAN NOT FOUND';
    END;

  ELSE
    cst.response := cst.response || '|SERVICE PLAN NOT FOUND';
  END IF;

  -- Set the response
  cst.response := CASE WHEN (cst.response IS NULL OR cst.response = 'SUCCESS') THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  --
  RETURN cst;

EXCEPTION
   WHEN OTHERS  THEN
     cst.response := 'ERROR IN GET_SERVICE_PLAN_ATTRIBUTES: ' || SQLERRM;
     RETURN cst;
END get_service_plan_attributes;


-- Added on 11/26/2014 by Juda Pena to determine if the brand allows shared groups
MEMBER FUNCTION get_shared_group_flag ( i_bus_org_id IN VARCHAR2) RETURN VARCHAR2 IS
  c red_card_type := red_card_type();
BEGIN
  --
  IF i_bus_org_id = 'TOTAL_WIRELESS' THEN
    -- Set the flag to Y when shared groups are allowed
    c.brand_shared_group_flag := 'Y';
  ELSE
    -- Set the flag to N when shared groups are NOT allowed
    c.brand_shared_group_flag := 'N';
  END IF;

  -- Return output value
  RETURN(c.brand_shared_group_flag);

EXCEPTION
   WHEN OTHERS THEN
     -- Return as N (No) whenever an error occurs
     RETURN('N');
END get_shared_group_flag;

-- Added on 11/26/2014 by Juda Pena to determine if the esn's brand allows shared groups
MEMBER FUNCTION get_shared_group_flag ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS
  cst red_card_type := red_card_type();
  c   red_card_type := red_card_type();
BEGIN

  IF i_esn IS NULL THEN
    RETURN('N');
  END IF;

  --
  BEGIN
    SELECT bo.org_id
    INTO   cst.bus_org_id
    FROM   table_part_inst pi,
                           table_part_num pn,
           table_mod_level ml,
           table_bus_org bo
    WHERE  pi.part_serial_no = i_esn
    AND    pi.n_part_inst2part_mod = ml.objid
    AND    ml.part_info2part_num = pn.objid
            AND    pn.part_num2bus_org = bo.objid;
   EXCEPTION
     WHEN others THEN
               NULL;
  END;

  -- call the member function to get the value based on the brand (bus_org_id)
  cst.brand_shared_group_flag := c.get_shared_group_flag ( i_bus_org_id => cst.bus_org_id );

  -- Return output value
  RETURN(cst.brand_shared_group_flag);

EXCEPTION
   WHEN OTHERS THEN
     -- Return as N (No) whenever an error occurs
     RETURN('N');
END get_shared_group_flag;

-- Function used to get the short description of the parent name based on the logic from the previous get inquiry process
MEMBER FUNCTION get_short_parent_name ( i_parent_name IN VARCHAR2 ) RETURN VARCHAR2 IS

  cst  red_card_type := SELF;

BEGIN
  --
  cst.short_parent_name := CASE i_parent_name
                             WHEN 'T-MOBILE'                 THEN 'TMO'
                             WHEN 'T-MOBILE SAFELINK'        THEN 'TMO'
                             WHEN 'T-MOBILE PREPAY PLATFORM' THEN 'TMO'
                             WHEN 'T-MOBILE SIMPLE'          THEN 'TMO'
                             WHEN 'CINGULAR'                 THEN 'ATT'
                             WHEN 'CLARO'                    THEN 'CLR'
                             WHEN 'CLARO SAFELINK'           THEN 'CLR'
                             WHEN 'VERIZON PREPAY PLATFORM'  THEN 'VZW'
                             WHEN 'VERIZON'                  THEN 'VZW'
                             WHEN 'VERIZON SAFELINK'         THEN 'VZW'
                             WHEN 'VERIZON WIRELESS'         THEN 'VZW'
                             WHEN 'AT&T SAFELINK'            THEN 'ATT'
                             WHEN 'AT&T WIRELESS'            THEN 'ATT'
                             WHEN 'ATT WIRELESS'             THEN 'ATT'
                             WHEN 'AT&T PREPAY PLATFORM'     THEN 'ATT'
                             WHEN 'AT&T_NET10'               THEN 'ATT'
                             WHEN 'DOBSON CELLULAR'          THEN 'ATT'
                             WHEN 'DOBSON GSM'               THEN 'ATT'
                             WHEN 'SPRINT'                   THEN 'SPRINT'
                             WHEN 'SPRINT_NET10'             THEN 'SPRINT'
                             WHEN 'WIRELESS_NET10'           THEN 'VZW'
                             WHEN 'VERIZON_PPP_SAFELINK'     THEN 'VZW'
                             ELSE i_parent_name
                           END;
  --
  RETURN cst.short_parent_name;

EXCEPTION
   WHEN OTHERS  THEN
     DBMS_OUTPUT.PUT_LINE('ERROR IN GET_SHORT_PARENT_NAME: ' || SQLERRM);
     RETURN NULL;
END get_short_parent_name;
--
-- Function used to get the short description of the parent name based on the logic from the previous get inquiry process
MEMBER FUNCTION get_web_user_attributes RETURN red_card_type IS

  cst  red_card_type := SELF;
BEGIN
  -- reset response to null
  cst.response := NULL;

  IF cst.esn IS NULL THEN
    cst.response := 'ESN NOT PASSED';
            RETURN cst;
  END IF;

  -- Get the min, carrier parent and wf_mac_id
  BEGIN
    SELECT pi_min.part_serial_no min,
           pi_min.x_msid msid,
           pi_esn.objid esn_part_inst_objid,
           pi_min.objid min_part_inst_objid,
           pi_min.part_inst2carrier_mkt carrier_objid,
           pi_esn.x_part_inst_status esn_part_inst_status,
           pi_min.x_part_inst_status min_part_inst_status,
           pi_esn.x_part_inst2contact
    INTO   cst.min,
           cst.msid,
           cst.esn_part_inst_objid,
           cst.min_part_inst_objid,
           cst.carrier_objid,
           cst.esn_part_inst_status,
           cst.min_part_inst_status,
           cst.contact_objid
    FROM   table_part_inst pi_esn,
           table_part_inst pi_min
    WHERE  pi_esn.part_serial_no = cst.esn
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_min.part_to_esn2part_inst = pi_esn.objid
    AND    pi_min.x_domain = 'LINES';
   EXCEPTION
     WHEN too_many_rows THEN
       cst.response := 'DUPLICATE ESN FOUND';
               RETURN cst;
     WHEN no_data_found THEN
       BEGIN
         SELECT pi_esn.objid esn_part_inst_objid,
                pi_esn.x_part_inst_status esn_part_inst_status
         INTO   cst.esn_part_inst_objid,
                cst.esn_part_inst_status
         FROM   table_part_inst pi_esn
         WHERE  pi_esn.part_serial_no = cst.esn
         AND    pi_esn.x_domain = 'PHONES';
         EXCEPTION
           WHEN others THEN
             cst.response := 'ESN NOT FOUND';
             RETURN cst;
       END;
     WHEN others THEN
       cst.response := 'UNHANDLED ERROR GETTING ESN: ' || SQLERRM;
               RETURN cst;
  END;

  -- Get the site part data (Active site part status)
  BEGIN
    SELECT sp.x_zipcode zipcode,
           sp.objid site_part_objid,
           sp.part_status,
           sp.x_iccid,
           NVL2(cst.min, cst.min, sp.x_min) min,
           sp.install_date
    INTO   cst.zipcode,
           cst.site_part_objid,
           cst.site_part_status,
           cst.iccid,
           cst.min,
           cst.install_date
    FROM   table_site_part sp
    WHERE  1 = 1
    AND    sp.x_service_id = cst.esn
    AND    sp.part_status = 'Active';
   EXCEPTION
     WHEN no_data_found THEN
       -- get the zipcode, iccid and site part status for the last updated row in site part
       BEGIN
         SELECT sp.x_zipcode zipcode,
                sp.objid site_part_objid,
                sp.part_status,
                sp.x_iccid,
                NVL2(cst.min, cst.min, sp.x_min) min
         INTO   cst.zipcode,
                cst.site_part_objid,
                cst.site_part_status,
                cst.iccid,
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
         SELECT sp.x_zipcode zipcode,
                sp.objid site_part_objid,
                sp.part_status,
                sp.x_iccid,
                NVL2(cst.min, cst.min, sp.x_min) min,
                sp.install_date
         INTO   cst.zipcode,
                cst.site_part_objid,
                cst.site_part_status,
                cst.iccid,
                cst.min,
                cst.install_date
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
            cst.response := cst.response || '|SITE PART STATUS, ZIPCODE NOT FOUND';
          WHEN others THEN
            cst.response := cst.response || '|SITE PART STATUS, ZIPCODE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       END;
     WHEN others THEN
       cst.response := cst.response || '|SITE PART STATUS, ZIPCODE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN cst;
  END;

  -- Get the min, carrier parent and wf_mac_id
  BEGIN
    SELECT pn.part_num2bus_org,
           bo.org_id,
           pn.part_number
    INTO   cst.bus_org_objid,
                   cst.bus_org_id,
           cst.esn_part_number
    FROM   table_part_num pn,
           table_mod_level ml,
           table_part_inst pi,
                           table_bus_org bo
    WHERE  pi.part_serial_no = cst.esn
    AND    ml.objid = pi.n_part_inst2part_mod
    AND    pn.objid = ml.part_info2part_num
            AND    pn.part_num2bus_org = bo.objid;
   EXCEPTION
     WHEN others THEN
       cst.response := 'BRAND NOT FOUND';
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
       RETURN cst;
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
            RETURN cst;
       END;
     WHEN OTHERS THEN
       cst.response := cst.response || '|WEB USER NOT FOUND: '|| SUBSTR(SQLERRM,1,100);
  END;

  -- Set the response
  cst.response := CASE WHEN (cst.response IS NULL OR cst.response = 'SUCCESS') THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  --
  RETURN cst;

EXCEPTION
   WHEN OTHERS  THEN
     cst.response := 'ERROR IN GET_WEB_USER_ATTRIBUTES: ' || SQLERRM;
     RETURN cst;
END get_web_user_attributes;

MEMBER FUNCTION retrieve_red_card ( i_red_card   IN VARCHAR2 ,
                                    i_smp_number IN VARCHAR2 ) RETURN red_card_type IS

  r red_card_type := SELF;

BEGIN
  IF (i_smp_number IS NOT NULL) THEN
    BEGIN
      SELECT red_card2call_trans,
             x_red_units
      INTO   r.call_trans_objid,
             r.units
      FROM   sa.table_x_red_card
      WHERE  x_red_code = i_red_card
      AND    x_smp = i_smp_number
      AND    x_result || '' = 'Completed';
     EXCEPTION
       WHEN others THEN
         r.response := 'RED CARD AND SMP NOT FOUND: ' || SQLERRM;
                 RETURN r;
    END;
  ELSE
    BEGIN
      SELECT red_card2call_trans,
             x_red_units
      INTO   r.call_trans_objid,
             r.units
      FROM   sa.table_x_red_card
      WHERE  x_red_code = i_red_card
      AND    x_result || '' = 'Completed';
     EXCEPTION
       WHEN others THEN
         r.response := 'RED CARD NOT FOUND: ' || SQLERRM;
                 RETURN r;
    END;
  END IF;

  r.response := 'SUCCESS';
  RETURN r;

EXCEPTION
   WHEN others THEN
     r.response := 'RED CARD NOT FOUND: ' || SQLERRM;
            RETURN r;
END retrieve_red_card;

MEMBER FUNCTION get_esn ( i_call_trans_objid IN NUMBER) RETURN red_card_type IS

  r red_card_type := SELF;

BEGIN
  BEGIN
    SELECT x_service_id
    INTO   r.esn
    FROM   sa.table_x_call_trans
    WHERE  objid = i_call_trans_objid;
   EXCEPTION
     WHEN others THEN
       r.response := 'CALL TRANS NOT FOUND: ' || SQLERRM;
               RETURN r;
  END;

  r.response := 'SUCCESS';
  RETURN r;

EXCEPTION
   WHEN others THEN
     r.response := 'CALL TRANS NOT FOUND: ' || SQLERRM;
            RETURN r;
END get_esn;

MEMBER FUNCTION get_esn ( i_part_inst_objid IN NUMBER) RETURN red_card_type IS

  r red_card_type := SELF;

BEGIN
  --
  BEGIN
    SELECT part_serial_no
    INTO   r.esn
    FROM   sa.table_part_inst
    WHERE  objid = i_part_inst_objid;
   EXCEPTION
     WHEN others THEN
               r.esn := NULL;
       r.response := 'PART INST NOT FOUND: ' || SQLERRM;
               RETURN r;
  END;

  r.response := 'SUCCESS';
  RETURN r;

EXCEPTION
   WHEN others THEN
     r.response := 'PART INST NOT FOUND: ' || SQLERRM;
            RETURN r;
END get_esn;

MEMBER FUNCTION is_card_redeemed ( i_esn      IN VARCHAR2,
                                   i_red_card IN VARCHAR2 ) RETURN red_card_type IS
  r red_card_type := SELF;

BEGIN

  r.is_card_redeemed_flag := 'N';

  BEGIN
            SELECT 'Y'
    INTO   r.is_card_redeemed_flag
    FROM   sa.table_site_part sp,
           sa.table_x_call_trans ct,
           sa.table_x_red_card code
     WHERE 1 = 1
     AND   sp.x_service_id || '' = i_esn
     AND   sp.part_status || '' = 'Active'
     AND   sp.objid = ct.call_trans2site_part
     AND   ct.x_action_type || '' = '6'
     AND   ct.objid = code.red_card2call_trans
     AND   code.x_red_code = i_red_card;
   EXCEPTION
     WHEN too_many_rows THEN
               r.is_card_redeemed_flag := 'Y';
     WHEN no_data_found THEN
               r.is_card_redeemed_flag := 'N';
     WHEN others THEN
               r.is_card_redeemed_flag := 'N';
  END;

  r.response := 'SUCCESS';
  RETURN r;

EXCEPTION
   WHEN others THEN
     r.is_card_redeemed_flag := 'N';
     r.response := 'CALL TRANS NOT FOUND: ' || SQLERRM;
            RETURN r;
END is_card_redeemed;

MEMBER FUNCTION get_gtt_part_number_attributes ( i_red_card IN VARCHAR2 ) RETURN red_card_type IS

  r red_card_type := SELF;

BEGIN

  r.is_card_redeemed_flag := 'N';

  BEGIN
      SELECT pn.x_redeem_units,
             pn.x_redeem_days,
             bo.org_id,
             pn.part_number,
             pn.x_card_type,
             pi.part_to_esn2part_inst,
             pi.x_part_inst_status,
             pn.part_type,
             pc.objid pc_objid,
             txp.x_promo_code,
             pn.part_num2x_promotion,
             pn.x_web_card_desc,
             pn.x_sp_web_card_desc,
             pn.description,
             pn.x_ild_type,
             pn.objid part_num_objid
     INTO    r.redeem_units,
             r.redeem_days,
             r.card_brand,
             r.card_part_number,
             r.card_type,
             r.part_inst_objid,
             r.card_part_inst_status,
             r.part_type,
             r.part_class_objid,
             r.promo_code,
             r.promo_objid,
             r.web_card_desc,
             r.sp_web_card_desc,
             r.part_number_description,
             r.ild_type,
             r.card_part_number_objid
     FROM    sa.table_part_num   pn,
             sa.table_mod_level  ml,
             sa.gtt_part_inst  pi,
             sa.table_bus_org    bo,
             sa.table_part_class pc,
             sa.table_x_promotion txp
     WHERE   1 = 1
     AND     pi.x_red_code = i_red_card
     AND     pn.objid = ml.part_info2part_num
     AND     ml.objid = pi.n_part_inst2part_mod
     AND     pn.part_num2bus_org = bo.objid
     AND     pn.part_num2x_promotion = txp.objid(+)
     AND     pn.part_num2part_class = pc.objid;

   EXCEPTION
     WHEN too_many_rows THEN
               r.response := 'DUPLICATE RED CARD PART NUMBER';
     WHEN no_data_found THEN
       BEGIN
         SELECT pn.x_redeem_units,
                pn.x_redeem_days,
                bo.org_id,
                pn.part_number,
                pn.x_card_type,
                pi.part_to_esn2part_inst,
                pi.x_part_inst_status,
                pn.part_type,
                pc.objid pc_objid,
                txp.x_promo_code,
                pn.part_num2x_promotion,
                pn.x_web_card_desc,
                pn.x_sp_web_card_desc,
                pn.description,
                pn.x_ild_type,
                pn.objid part_num_objid
         INTO   r.redeem_units,
                r.redeem_days,
                r.card_brand,
                r.card_part_number,
                r.card_type,
                r.part_inst_objid,
                r.card_part_inst_status,
                r.part_type,
                r.part_class_objid,
                r.promo_code,
                r.promo_objid,
                r.web_card_desc,
                r.sp_web_card_desc,
                r.part_number_description,
                r.ild_type,
                r.card_part_number_objid
         FROM   sa.table_part_num   pn,
                sa.table_mod_level  ml,
                sa.table_part_inst  pi,
                sa.table_bus_org    bo,
                sa.table_part_class pc,
                sa.table_x_promotion txp
         WHERE  1 = 1
         AND    pi.x_red_code = i_red_card
         AND    pn.objid = ml.part_info2part_num
         AND    ml.objid = pi.n_part_inst2part_mod
         AND    pn.part_num2bus_org = bo.objid
         AND    pn.part_num2x_promotion = txp.objid(+)
         AND    pn.part_num2part_class = pc.objid;

        EXCEPTION
          WHEN others THEN
                    r.response := 'RED CARD PART NUMBER ATTRIBUTES NOT FOUND';
       END;
     WHEN others THEN
               r.response := 'UNHANDLED ERROR: ' || SQLERRM;
  END;

  r.group_allowed_lines := 1;

  IF r.card_part_number IS NOT NULL THEN
    BEGIN
              SELECT number_of_lines
      INTO   r.group_allowed_lines
      FROM   sa.service_plan_feat_pivot_mv
      WHERE  service_plan_objid IN ( SELECT sp_objid
                                     FROM   sa.adfcrm_serv_plan_class_matview
                                     WHERE  part_class_objid IN ( SELECT part_num2part_class
                                                                  FROM   table_part_num
                                                                  WHERE  part_number = r.card_part_number
                                                                )
                                   )
      AND    ROWNUM = 1;
     EXCEPTION
       WHEN others THEN
         r.group_allowed_lines := 1;
            END;
  END IF;

  r.response := 'SUCCESS';
  RETURN r;

EXCEPTION
   WHEN others THEN
     r.response := 'RED CARD PART NUMBER ATTRIBUTES NOT FOUND: ' || SQLERRM;
            RETURN r;
END get_gtt_part_number_attributes;

MEMBER FUNCTION get_gtt_esn_attributes ( i_esn IN VARCHAR2 ) RETURN red_card_type IS

  r red_card_type := SELF;

BEGIN

  BEGIN
    SELECT bo.org_id,
           pn.part_num2part_class,
           pn.x_technology,
           pn.x_dll,
           pcpv.non_ppe non_ppe_flag,
           bo.org_flow,
           pi.x_part_inst_status
    INTO   r.bus_org_id,
           r.part_class_objid,
           r.technology       ,
           r.dll,
           r.non_ppe_flag,
                           r.bus_org_flow,
                           r.esn_part_inst_status
    FROM   sa.table_part_num   pn,
           sa.table_mod_level  ml,
           sa.gtt_part_inst    pi,
           sa.table_bus_org    bo,
           sa.table_part_class pc,
                           pcpv_mv             pcpv
    WHERE  1 = 1
    AND    pi.part_serial_no = i_esn
            AND    pn.objid = ml.part_info2part_num
    AND    ml.objid = pi.n_part_inst2part_mod
    AND    pn.part_num2bus_org = bo.objid
    AND    pc.objid = pn.part_num2part_class
            AND    pc.objid = pcpv.pc_objid;
   EXCEPTION
     WHEN too_many_rows THEN
               r.response := 'DUPLICATE ESN';
     WHEN no_data_found THEN
       BEGIN
         SELECT bo.org_id,
                pn.part_num2part_class,
                pn.x_technology,
                pn.x_dll,
                pcpv.non_ppe non_ppe_flag,
                bo.org_flow,
                pi.x_part_inst_status
         INTO   r.bus_org_id,
                r.part_class_objid,
                r.technology  ,
                r.dll,
                r.non_ppe_flag,
                r.bus_org_flow,
                r.esn_part_inst_status
         FROM   sa.table_part_num   pn,
                sa.table_mod_level  ml,
                sa.table_part_inst  pi,
                sa.table_bus_org    bo,
                sa.table_part_class pc,
                sa.pcpv_mv          pcpv
         WHERE  1 = 1
         AND    pi.part_serial_no = i_esn
         AND    pn.objid = ml.part_info2part_num
         AND    ml.objid = pi.n_part_inst2part_mod
         AND    pn.part_num2bus_org = bo.objid
         AND    pc.objid = pn.part_num2part_class
         AND    pc.objid = pcpv.pc_objid;
        EXCEPTION
          WHEN too_many_rows THEN
            r.response := 'DUPLICATE ESN';
          WHEN no_data_found THEN
            r.response := 'ESN NOT FOUND';
          WHEN others THEN
            r.response := 'UNHANDLED ERROR: ' || SQLERRM;
       END;
     WHEN others THEN
               r.response := 'UNHANDLED ERROR: ' || SQLERRM;
  END;

  r.response := 'SUCCESS';
  RETURN r;

EXCEPTION
   WHEN others THEN
     r.response := 'RED CARD PART NUMBER ATTRIBUTES NOT FOUND: ' || SQLERRM;
            RETURN r;
END get_gtt_esn_attributes;

MEMBER FUNCTION is_card_compatible_with_esn ( i_esn_part_class_objid  IN NUMBER ,
                                              i_card_part_class_objid IN NUMBER ) RETURN red_card_type IS

  r red_card_type := SELF;

BEGIN

  r.card_esn_compatibility_flag := 'N';

  -- Determine if the card is compatible with the esn
  BEGIN
    SELECT 'Y'
    INTO   r.card_esn_compatibility_flag
    FROM   x_serviceplanfeaturevalue_def a,
           mtm_partclass_x_spf_value_def b,
           x_serviceplanfeaturevalue_def c,
           mtm_partclass_x_spf_value_def d
    WHERE  a.objid = b.spfeaturevalue_def_id
    AND    b.part_class_id = i_card_part_class_objid -- part_class_objid
    AND    c.objid = d.spfeaturevalue_def_id
    AND    d.part_class_id = i_esn_part_class_objid -- phone class objid
    AND    a.value_name = c.value_name;
   EXCEPTION
     WHEN too_many_rows THEN
               r.card_esn_compatibility_flag := 'Y';
     WHEN no_data_found THEN
               r.card_esn_compatibility_flag := 'N';
     WHEN others THEN
               r.card_esn_compatibility_flag := 'N';
  END;

  RETURN r;

EXCEPTION
   WHEN others THEN
     r.card_esn_compatibility_flag := 'N';
            RETURN r;
END is_card_compatible_with_esn;

MEMBER FUNCTION get_vas_part_class_name ( i_part_class_objid IN NUMBER ) RETURN red_card_type IS

  r red_card_type := SELF;

BEGIN

  r.vas_part_class_name := NULL;

  -- Determine if the card is compatible with the esn
  BEGIN
    SELECT pc.name
    INTO   r.vas_part_class_name
    FROM   table_part_class pc,
           vas_programs_view pv
    WHERE  1 = 1
    AND    pc.objid = i_part_class_objid
    AND    pc.name = pv.vas_card_class
            AND    ROWNUM = 1;
   EXCEPTION
     WHEN others THEN
               r.vas_part_class_name := NULL;
  END;

  RETURN r;

EXCEPTION
   WHEN others THEN
     r.vas_part_class_name := NULL;
            RETURN r;
END get_vas_part_class_name;

-- Function used to get the safelink attributes and flags
MEMBER FUNCTION get_safelink_flag ( i_esn                   IN VARCHAR2 ,
                                    i_esn_part_number_objid IN NUMBER   ) RETURN red_card_type IS
  r red_card_type := SELF;
BEGIN

  r.safelink_flag := 'N';

  -- Get the safelink program enrollment flag
  BEGIN
    SELECT safelink_flag
    INTO   r.safelink_flag
            FROM   ( SELECT 'Y' safelink_flag
             FROM   x_program_enrolled pe,
                    x_program_parameters pgm,
                    x_sl_currentvals slcur,
                    x_sl_subs slsub,
                    sa.mtm_program_safelink ps,
                    table_part_num pn
             WHERE  1 = 1
             AND    pgm.objid = pe.pgm_enroll2pgm_parameter
             AND    slcur.x_current_esn = pe.x_esn
             AND    slcur.lid = slsub.lid
             AND    ps.program_param_objid = pgm.objid
             AND    sysdate BETWEEN ps.start_date AND ps.end_date
             AND    sysdate BETWEEN pgm.x_start_date AND pgm.x_end_date
             AND    pgm.x_prog_class = 'LIFELINE'
             AND    pe.x_sourcesystem in ('VMBC', 'WEB')
             AND    pgm.x_is_recurring = 1
             AND    pe.x_esn = i_esn
             AND    pe.x_enrollment_status = 'ENROLLED'
             AND    ps.part_num_objid = pn.objid
             AND    pn.objid = i_esn_part_number_objid
             UNION
             SELECT 'Y' safelink_flag
             FROM   x_program_enrolled pe,
                    x_program_parameters pgm,
                    x_sl_currentvals slcur,
                    x_sl_subs slsub,
                    sa.mtm_program_safelink ps,
                    table_part_num pn
             WHERE  1 = 1
             AND    pgm.objid = pe.pgm_enroll2pgm_parameter
             AND    slcur.x_current_esn = pe.x_esn
             AND    slcur.lid = slsub.lid
             AND    ps.program_param_objid = pgm.objid
             AND    pgm.x_prog_class = 'LIFELINE'
             AND    pe.x_sourcesystem in ('VMBC', 'WEB')
             AND    pgm.x_is_recurring = 1
             AND    pe.x_esn = i_esn
             AND    pe.x_enrollment_status <> 'ENROLLED'
             AND    pe.x_enrolled_date = ( SELECT MAX(i_pe.x_enrolled_date)
                                           FROM   x_program_enrolled i_pe,
                                                  x_program_parameters i_pgm
                                           WHERE  i_pe.x_esn = pe.x_esn
                                           AND    i_pgm.objid = i_pe.pgm_enroll2pgm_parameter
                                           AND    i_pgm.x_prog_class = 'LIFELINE'
                                           AND    i_pgm.x_is_recurring = 1
                                         )
                     AND NOT EXISTS ( SELECT 1
                              FROM   x_program_enrolled i_pe,
                                     x_program_parameters i_pgm
                              WHERE  i_pe.x_esn = pe.x_esn
                              AND    i_pgm.objid = i_pe.pgm_enroll2pgm_parameter
                              AND    i_pgm.x_prog_class = 'LIFELINE'
                              AND    i_pgm.x_is_recurring = 1
                              AND    i_pe.x_enrollment_status = 'ENROLLED' )
                     AND    ps.allow_non_sl_customer   = 'Y'
                     AND    ps.part_num_objid = pn.objid
                     AND    pn.objid     = i_esn_part_number_objid
    );
   EXCEPTION
     WHEN too_many_rows THEN
       r.safelink_flag := 'Y';
     WHEN others THEN
       r.safelink_flag := 'N';
  END;

  --
  RETURN r;

EXCEPTION
   WHEN OTHERS  THEN
     r.safelink_flag := 'N';
     RETURN r;
END get_safelink_flag;

-- Function used to delete the gtt_part_inst table
MEMBER FUNCTION del_gtt_part_inst ( i_gtt_part_inst_objid IN NUMBER ) RETURN VARCHAR2 IS
  c_response VARCHAR2(1000);
BEGIN

  --
  BEGIN
    DELETE sa.gtt_part_inst
    WHERE  objid = i_gtt_part_inst_objid;
    --
    DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row deleted from GTT PART INST (' || i_gtt_part_inst_objid || ')');
    --
   EXCEPTION
     WHEN others THEN
       c_response := SUBSTR(SQLERRM,1,300);
       RETURN('ERROR DELETING GTT_PART_INST: ' || c_response);
  END;

  --
  RETURN('SUCCESS');

EXCEPTION
   WHEN OTHERS  THEN
     c_response := SUBSTR(SQLERRM,1,300);
     RETURN('UNHANDLED ERROR DELETING GTT_PART_INST: ' || c_response);
END del_gtt_part_inst;

MEMBER FUNCTION save_gtt_part_inst ( io_gpi IN OUT red_card_type ) RETURN VARCHAR2 IS

BEGIN

  --
  BEGIN
    INSERT
    INTO   sa.gtt_part_inst
           ( objid,
             part_serial_no,
             x_domain,
             x_red_code,
             x_part_inst_status,
             x_insert_date,
             x_creation_date,
             x_po_num,
             x_order_number,
             created_by2user,
             status2x_code_table,
             n_part_inst2part_mod,
             part_inst2inv_bin,
             last_trans_time,
             x_parent_part_serial_no
           )
    VALUES
    ( NVL(FLOOR(DBMS_RANDOM.VALUE( low => 1, high => 9999999)),1) ,
      io_gpi.part_serial_no,
      io_gpi.domain,
      io_gpi.red_code,
      io_gpi.part_inst_status,
      io_gpi.insert_date,
      io_gpi.creation_date,
      io_gpi.po_num,
      io_gpi.order_number,
      io_gpi.created_by2user,
      io_gpi.status2x_code_table,
      io_gpi.n_part_inst2part_mod,
      io_gpi.part_inst2inv_bin,
      io_gpi.last_trans_time,
      io_gpi.parent_part_serial_no
    )
    RETURNING objid INTO io_gpi.gtt_part_inst_objid;

   EXCEPTION
    WHEN dup_val_on_index then
      RETURN('DUPLICATE VALUE INSERTING INTO GTT PART INST');
    WHEN others then
      io_gpi.response := SUBSTR(SQLERRM,1,300);
      RETURN('ERROR INSERTING INTO GTT PART INST: ' || io_gpi.response);
  END;

  DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row created in GTT PART INST (' || io_gpi.gtt_part_inst_objid || ')');

  RETURN('SUCCESS');

EXCEPTION
   WHEN OTHERS THEN
     io_gpi.response := SUBSTR(SQLERRM,1,300);
     RETURN 'ERROR SAVING GTT PART INST RECORD: ' || io_gpi.response;
     --
END save_gtt_part_inst;

-- Function used to delete the gtt_posa_card table
MEMBER FUNCTION del_gtt_posa_card ( i_gtt_posa_card_objid IN NUMBER ) RETURN VARCHAR2 IS
  c_response VARCHAR2(1000);
BEGIN

  --
  BEGIN
    DELETE sa.gtt_posa_card
    WHERE  objid = i_gtt_posa_card_objid;
            --
    DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row deleted from GTT POSA CARD (' || i_gtt_posa_card_objid || ')');
    --
   EXCEPTION
     WHEN others THEN
       c_response := SUBSTR(SQLERRM,1,300);
       RETURN('ERROR DELETING GTT POSA CARD: ' || c_response);
  END;

  --
  RETURN('SUCCESS');

EXCEPTION
   WHEN OTHERS  THEN
     c_response := SUBSTR(SQLERRM,1,300);
     RETURN('UNHANDLED ERROR DELETING GTT PART INST: ' || c_response);
END del_gtt_posa_card;

MEMBER FUNCTION save_gtt_posa_card ( io_gpc IN OUT red_card_type ) RETURN VARCHAR2 IS

BEGIN

  --
  BEGIN
    INSERT
    INTO   sa.gtt_posa_card
           ( tf_part_num_parent,
             tf_serial_num,
             toss_att_customer,
             toss_att_location,
             toss_posa_code,
             toss_posa_date,
             tf_extract_flag,
             tf_extract_date,
             toss_site_id,
             toss_posa_action,
             objid,
             remote_trans_id,
             sourcesystem,
             toss_att_trans_date
           )
    VALUES
    ( io_gpc.part_number ,
      io_gpc.part_serial_no,
      io_gpc.toss_att_customer,
      io_gpc.toss_att_location,
      io_gpc.toss_posa_code,
      io_gpc.toss_posa_date,
      io_gpc.tf_extract_flag,
      io_gpc.tf_extract_date,
      io_gpc.toss_site_id,
      io_gpc.toss_posa_action,
      NVL(FLOOR(DBMS_RANDOM.VALUE( low => 1, high => 9999999)),1),
      io_gpc.remote_trans_id,
      io_gpc.sourcesystem,
      io_gpc.toss_att_trans_date
    )
    RETURNING objid INTO io_gpc.gtt_posa_card_objid;

   EXCEPTION
    WHEN dup_val_on_index then
      RETURN('DUPLICATE VALUE INSERTING INTO GTT POSA CARD');
    WHEN others then
      io_gpc.response := SUBSTR(SQLERRM,1,300);
      RETURN('ERROR INSERTING INTO GTT POSA CARD: ' || io_gpc.response);
  END;

  DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row created in GTT POSA CARD (' || io_gpc.gtt_posa_card_objid || ')');

  RETURN('SUCCESS');

EXCEPTION
   WHEN OTHERS THEN
     io_gpc.response := SUBSTR(SQLERRM,1,300);
     RETURN 'ERROR SAVING GTT POSA CARD RECORD: ' || io_gpc.response;
     --
END save_gtt_posa_card;

MEMBER FUNCTION choose_random_esn ( i_red_card IN VARCHAR2 ) RETURN VARCHAR2 IS

  -- Get the part classes related to a given pin
  CURSOR c_get_part_class_id IS
    SELECT d.part_class_id,
           sp.objid service_plan_id
    FROM   sa.x_serviceplanfeaturevalue_def a,
           sa.mtm_partclass_x_spf_value_def b,  -- card
           sa.x_serviceplanfeaturevalue_def c,
           sa.mtm_partclass_x_spf_value_def d,  -- phones
           sa.x_serviceplanfeature_value spfv,
           sa.x_service_plan_feature spf,
           sa.x_service_plan sp
    WHERE  a.objid = b.spfeaturevalue_def_id
    AND    b.part_class_id IN ( SELECT pn.part_num2part_class
                                FROM   table_part_inst rc,
                                       table_mod_level ml,
                                       table_part_num pn
                                WHERE  1 = 1
                                AND    rc.x_red_code = i_red_card
                                AND    ml.objid      = rc.n_part_inst2part_mod
                                AND    pn.objid      = ml.part_info2part_num
                                --
                                UNION
                                SELECT pn.part_num2part_class
                                FROM   table_x_red_card rc,
                                       table_mod_level ml,
                                       table_part_num pn
                                WHERE  1 = 1
                                AND    rc.x_red_code = i_red_card
                                AND    ml.objid      = rc.x_red_card2part_mod
                                AND    pn.objid      = ml.part_info2part_num
                                --
                              )
    AND    c.objid        = d.spfeaturevalue_def_id
    AND    a.value_name   = c.value_name
    AND    spfv.value_ref = a.objid
    AND    spf.objid      = spfv.spf_value2spf
    AND    sp.objid       = spf.sp_feature2service_plan;

  -- Get the available ESNs based on a given part class
  CURSOR c_get_esn (p_part_class IN NUMBER) IS
      SELECT pi.part_serial_no,
             pi.x_red_code,
             pi.x_domain,
             pn.part_num2part_class,
             pi.x_part_inst_status
      FROM   table_part_num pn,
             table_mod_level ml,
             table_part_inst pi
      WHERE  1 = 1
      AND    pn.part_num2part_class = p_part_class
      AND    pn.domain = 'PHONES'
      AND    ml.part_info2part_num = pn.objid
      AND    pi.n_part_inst2part_mod = ml.objid
      AND    pi.x_part_inst_status = '50';

BEGIN
  -- Loop through the part classes related to the provided pin
  FOR i IN c_get_part_class_id LOOP
    -- Loop through ALL the available ESNs based on a given part class
    FOR j IN c_get_esn (i.part_class_id) LOOP
      IF j.part_serial_no IS NOT NULL THEN
        RETURN(j.part_serial_no);
      END IF;
    END LOOP; -- j
  END LOOP; -- i
EXCEPTION
   WHEN OTHERS THEN
    RETURN(NULL);
END choose_random_esn;

MEMBER FUNCTION is_esn_compatible_with_group ( i_account_group_objid IN NUMBER,
                                               i_esn                 IN VARCHAR2 ) RETURN VARCHAR2 IS

  -- Get the service plan, and domain for a given account group id
  CURSOR c_compatibility IS
    SELECT mv.sp_objid,
           pi.part_serial_no,
           pi.x_domain
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           sa.adfcrm_serv_plan_class_matview mv
    WHERE  1 = 1
    AND    pi.part_serial_no   = i_esn
    AND    pi.x_domain         = 'PHONES'
    AND    ml.objid            = pi.n_part_inst2part_mod
    AND    pn.objid            = ml.part_info2part_num
    AND    mv.part_class_objid = pn.part_num2part_class
    AND    mv.sp_objid IN ( SELECT service_plan_id
                            FROM   x_account_group
                            WHERE  objid = i_account_group_objid
                          );
  sp_compatibility_rec c_compatibility%ROWTYPE;
BEGIN
  OPEN c_compatibility;
  FETCH c_compatibility INTO sp_compatibility_rec;
  IF c_compatibility%NOTFOUND THEN
    -- Close the cursor and continue
    CLOSE c_compatibility;
    -- Incompatible service plan and esn combination
    RETURN('N');
  ELSE
    -- Close the cursor and continue
    CLOSE c_compatibility;
  END IF;
  -- Service plan and esn are compatible
  RETURN('Y');
EXCEPTION
WHEN OTHERS THEN
  -- Incompatible service plan and esn combination
  RETURN('N');
END is_esn_compatible_with_group;

-- Function used to get all the attributes for a particular pin
MEMBER FUNCTION retrieve_gtt_pin ( i_red_card IN VARCHAR2 ) RETURN red_card_type IS

  cst  red_card_type := SELF;
  c    red_card_type := SELF;

BEGIN

  -- Initialize entire cst type with an empty object
  cst := red_card_type ();

  cst.pin := i_red_card;

  -- Exit when the ESN is not passed
  IF cst.pin IS NULL THEN
    cst.response := 'PIN NOT PASSED';
    RETURN cst;
  END IF;

  -- Get the smp from pin
  cst.smp := c.convert_pin_to_smp ( i_red_card_code => cst.pin );

  BEGIN
    SELECT application_req_num
    INTO   cst.application_req_num
    FROM   sa.x_customer_lease
    WHERE  smp = cst.smp;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  BEGIN
    -- Get the part class of the pin
            SELECT part_class_objid,
           bus_org_objid,
           bus_org_id,
                           part_number
    INTO   cst.part_class_objid,
           cst.bus_org_objid,
           cst.bus_org_id,
                           cst.pin_part_number
    FROM   ( SELECT pn.part_num2part_class part_class_objid,
                    pn.part_num2bus_org bus_org_objid,
                    bo.org_id bus_org_id,
                    pn.part_number
             FROM   sa.gtt_part_inst pi,
                    table_mod_level ml,
                    table_part_num pn,
                    table_bus_org bo
             WHERE  1 = 1
             AND    pi.x_red_code = cst.pin
             AND    pi.x_domain = 'REDEMPTION CARDS'
             AND    pi.n_part_inst2part_mod = ml.objid
             AND    ml.part_info2part_num = pn.objid
             AND    pn.domain = 'REDEMPTION CARDS'
             AND    pn.part_num2bus_org = bo.objid
             UNION
             SELECT pn.part_num2part_class part_class_objid,
                    pn.part_num2bus_org bus_org_objid,
                    bo.org_id bus_org_id,
                    pn.part_number
             FROM   table_x_red_card rc,
                    table_mod_level ml,
                    table_part_num pn,
                    table_bus_org bo
             WHERE  rc.x_red_code = cst.pin
             AND    ml.objid = rc.x_red_card2part_mod
             AND    ml.part_info2part_num = pn.objid
             AND    pn.domain = 'REDEMPTION CARDS'
             AND    pn.part_num2bus_org = bo.objid
             UNION
             SELECT pn.part_num2part_class pc_objid,
                    pn.part_num2bus_org bus_org_objid,
                    bo.org_id bus_org_id,
                    pn.part_number
             FROM   sa.gtt_posa_card_inv pi,
                    table_mod_level ml,
                    table_part_num pn,
                    table_bus_org bo
             WHERE  1 = 1
             AND    pi.x_red_code = cst.pin
             AND    ml.objid = pi.x_posa_inv2part_mod
             AND    pn.objid = ml.part_info2part_num
             AND    pn.domain = 'REDEMPTION CARDS'
             AND    pn.part_num2bus_org = bo.objid
           );
   EXCEPTION
     WHEN others THEN
       cst.response := 'PIN NOT FOUND';
       RETURN cst;
  END;

  --
  IF cst.part_class_objid IS NOT NULL THEN
    -- Get the dealer, brand and other features
    BEGIN
      SELECT pcpv.firmware firmware,
             pcpv.motricity_denomination motricity_denomination,
             pcpv.model_type model_type,
             pcpv.technology,
             pcpv.part_class part_class_name,
             pcpv.device_type,
             pcpv.non_ppe non_ppe_flag,
             pcpv.phone_gen phone_generation
      INTO   cst.firmware,
             cst.motricity_denomination,
             cst.model_type,
             cst.technology,
             cst.part_class_name,
             cst.device_type,
             cst.non_ppe_flag,
             cst.phone_generation
      FROM   sa.pcpv_mv pcpv
      WHERE  pcpv.pc_objid = cst.part_class_objid;
     EXCEPTION
      WHEN others THEN
        cst.response := cst.response || '|PART CLASS NOT FOUND';
    END;
  END IF;

  -- Determine when the brand allows device leasing
  IF cst.bus_org_objid IS NOT NULL THEN
    cst.brand_leasing_flag := c.get_leasing_flag ( i_bus_org_objid => cst.bus_org_objid);
  END IF;

  -- Determine when the brand allows shared groups
  IF cst.bus_org_id IS NOT NULL THEN
    cst.brand_shared_group_flag := c.get_shared_group_flag ( i_bus_org_id => cst.bus_org_id);
  END IF;

  -- Get the service plan attributes and features
  BEGIN
    SELECT sp.objid,
           sp.customer_price,
           sp.mkt_name,
           mv.number_of_lines,
           CASE WHEN UPPER(mv.data) IN ('UNLIMITED','NA','DYNAMIC') THEN 0 ELSE TO_NUMBER(mv.data) END service_plan_data,
           mv.plan_purchase_part_number,
           mv.service_plan_group
    INTO   cst.service_plan_objid,
           cst.service_plan_price,
           cst.service_plan_name,
           cst.group_allowed_lines,
           cst.service_plan_data,
           cst.service_plan_part_number,
                           cst.service_plan_group
    FROM   sa.x_serviceplanfeaturevalue_def a,
           sa.mtm_partclass_x_spf_value_def b,
           sa.x_serviceplanfeature_value spfv,
           sa.x_service_plan_feature spf,
           sa.x_service_plan sp,
           sa.service_plan_feat_pivot_mv mv
    WHERE  1 = 1
    AND    b.part_class_id = cst.part_class_objid
    AND    a.objid = b.spfeaturevalue_def_id
    AND    spfv.value_ref = a.objid
    AND    spf.objid = spfv.spf_value2spf
    AND    sp.objid = spf.sp_feature2service_plan
    AND    sp.objid = mv.service_plan_objid;
   EXCEPTION
     WHEN too_many_rows THEN
       cst.response := cst.response || '|DUPLICATE SERVICE PLAN PART CLASS';
       RETURN cst;
     WHEN others THEN
       cst.response := cst.response || '|SERVICE PLAN PART CLASS NOT FOUND';
       RETURN cst;
  END;

  -- Since we do not have the group, set the lines in a group as zero
  cst.group_total_lines := 0;

  -- Get lease blocked slots
  BEGIN
    SELECT COUNT(DISTINCT esn)
    INTO   cst.lease_blocked_slots
    FROM   ( SELECT x_esn esn
             FROM   sa.x_customer_lease
             WHERE  application_req_num = cst.application_req_num
             AND    lease_status IN ('1001','1002','1005')
             UNION
             SELECT x_esn esn
             FROM   sa.x_customer_lease
             WHERE  smp = cst.smp
             AND    lease_status IN ('1001','1002','1005')
           ) a;
   EXCEPTION
     WHEN others THEN
       cst.lease_blocked_slots := 0;
  END;

  -- Get the number of lines a service plan allows for a particular group
  IF cst.service_plan_objid IS NOT NULL AND cst.group_allowed_lines IS NULL
  THEN
    BEGIN
      SELECT NVL(fea.number_of_lines,1)
      INTO   cst.group_allowed_lines
      FROM   sa.service_plan_feat_pivot_mv fea
      WHERE  service_plan_objid = cst.service_plan_objid;
     EXCEPTION
       WHEN others THEN
         cst.group_allowed_lines := 0;
    END;
  END IF;

  -- Calculate the quantity of available lines for a particular group
  IF cst.group_allowed_lines > 0 THEN
    cst.group_available_capacity := cst.group_allowed_lines - ( NVL(cst.group_total_lines,0) + NVL(cst.lease_blocked_slots,0) );
    cst.group_available_capacity := GREATEST ( cst.group_available_capacity, 0);
  END IF;

  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  -- Return the type
  RETURN cst;

EXCEPTION
   WHEN OTHERS THEN
     cst.response := 'ERROR RETRIEVING PIN: ' || SQLERRM;
     RETURN cst;
     --
END retrieve_gtt_pin;

-- Function used to get all the attributes for a particular pin
MEMBER FUNCTION retrieve_pin ( i_red_card IN VARCHAR2 ) RETURN red_card_type IS

  cst  red_card_type := SELF;
  c    red_card_type := SELF;

BEGIN

  -- Initialize entire cst type with an empty object
  cst := red_card_type ();

  cst.pin := i_red_card;

  -- Exit when the ESN is not passed
  IF cst.pin IS NULL THEN
    cst.response := 'PIN NOT PASSED';
    RETURN cst;
  END IF;

  -- Get the smp from pin
  cst.smp := c.convert_pin_to_smp ( i_red_card_code => cst.pin );

  BEGIN
    SELECT application_req_num
    INTO   cst.application_req_num
    FROM   sa.x_customer_lease
    WHERE  smp = cst.smp;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  BEGIN
    SELECT application_req_num
    INTO   cst.application_req_num
    FROM   sa.x_customer_lease
    WHERE  smp = cst.smp;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  BEGIN
    -- Get the part class of the pin
            SELECT part_class_objid,
           bus_org_objid,
           bus_org_id,
                           part_number
    INTO   cst.part_class_objid,
           cst.bus_org_objid,
           cst.bus_org_id,
                           cst.pin_part_number
    FROM   ( SELECT pn.part_num2part_class part_class_objid,
                    pn.part_num2bus_org bus_org_objid,
                    bo.org_id bus_org_id,
                    pn.part_number
             FROM   table_part_inst pi,
                    table_mod_level ml,
                    table_part_num pn,
                    table_bus_org bo
             WHERE  1 = 1
             AND    pi.x_red_code = cst.pin
             AND    pi.x_domain = 'REDEMPTION CARDS'
             AND    pi.n_part_inst2part_mod = ml.objid
             AND    ml.part_info2part_num = pn.objid
             AND    pn.domain = 'REDEMPTION CARDS'
             AND    pn.part_num2bus_org = bo.objid
             UNION
             SELECT pn.part_num2part_class part_class_objid,
                    pn.part_num2bus_org bus_org_objid,
                    bo.org_id bus_org_id,
                    pn.part_number
             FROM   table_x_red_card rc,
                    table_mod_level ml,
                    table_part_num pn,
                    table_bus_org bo
             WHERE  rc.x_red_code = cst.pin
             AND    ml.objid = rc.x_red_card2part_mod
             AND    ml.part_info2part_num = pn.objid
             AND    pn.domain = 'REDEMPTION CARDS'
             AND    pn.part_num2bus_org = bo.objid
             UNION
             SELECT pn.part_num2part_class pc_objid,
                    pn.part_num2bus_org bus_org_objid,
                    bo.org_id bus_org_id,
                    pn.part_number
             FROM   table_x_posa_card_inv pi,
                    table_mod_level ml,
                    table_part_num pn,
                    table_bus_org bo
             WHERE  1 = 1
             AND    pi.x_red_code = cst.pin
             AND    ml.objid = pi.x_posa_inv2part_mod
             AND    pn.objid = ml.part_info2part_num
             AND    pn.domain = 'REDEMPTION CARDS'
             AND    pn.part_num2bus_org = bo.objid
           );
   EXCEPTION
     WHEN others THEN
       cst.response := 'PIN NOT FOUND';
       RETURN cst;
  END;

  --
  IF cst.part_class_objid IS NOT NULL THEN
    -- Get the dealer, brand and other features
    BEGIN
      SELECT pcpv.firmware firmware,
             pcpv.motricity_denomination motricity_denomination,
             pcpv.model_type model_type,
             pcpv.technology,
             pcpv.part_class part_class_name,
             pcpv.device_type,
             pcpv.non_ppe non_ppe_flag,
             pcpv.phone_gen phone_generation
      INTO   cst.firmware,
             cst.motricity_denomination,
             cst.model_type,
             cst.technology,
             cst.part_class_name,
             cst.device_type,
             cst.non_ppe_flag,
             cst.phone_generation
      FROM   sa.pcpv_mv pcpv
      WHERE  pcpv.pc_objid = cst.part_class_objid;
     EXCEPTION
      WHEN others THEN
        cst.response := cst.response || '|PART CLASS NOT FOUND';
    END;
  END IF;

  -- Determine when the brand allows device leasing
  IF cst.bus_org_objid IS NOT NULL THEN
    cst.brand_leasing_flag := c.get_leasing_flag ( i_bus_org_objid => cst.bus_org_objid);
  END IF;

  -- Determine when the brand allows shared groups
  IF cst.bus_org_id IS NOT NULL THEN
    cst.brand_shared_group_flag := c.get_shared_group_flag ( i_bus_org_id => cst.bus_org_id);
  END IF;

  -- Get the service plan attributes and features
  BEGIN
    SELECT sp.objid,
           sp.customer_price,
           sp.mkt_name,
           mv.number_of_lines,
           CASE WHEN UPPER(mv.data) IN ('UNLIMITED','NA','DYNAMIC') THEN 0 ELSE TO_NUMBER(mv.data) END service_plan_data,
           mv.plan_purchase_part_number,
           mv.service_plan_group
    INTO   cst.service_plan_objid,
           cst.service_plan_price,
           cst.service_plan_name,
           cst.group_allowed_lines,
           cst.service_plan_data,
           cst.service_plan_part_number,
           cst.service_plan_group
    FROM   sa.x_serviceplanfeaturevalue_def a,
           sa.mtm_partclass_x_spf_value_def b,
           sa.x_serviceplanfeature_value spfv,
           sa.x_service_plan_feature spf,
           sa.x_service_plan sp,
           sa.service_plan_feat_pivot_mv mv
    WHERE  1 = 1
    AND    b.part_class_id = cst.part_class_objid
    AND    a.objid = b.spfeaturevalue_def_id
    AND    spfv.value_ref = a.objid
    AND    spf.objid = spfv.spf_value2spf
    AND    sp.objid = spf.sp_feature2service_plan
    AND    sp.objid = mv.service_plan_objid;
   EXCEPTION
     WHEN too_many_rows THEN
       cst.response := cst.response || '|DUPLICATE SERVICE PLAN PART CLASS';
       RETURN cst;
     WHEN others THEN
       cst.response := cst.response || '|SERVICE PLAN PART CLASS NOT FOUND';
       RETURN cst;
  END;

  -- Since we do not have the group, set the lines in a group as zero
  cst.group_total_lines := 0;

  -- Get lease blocked slots
  BEGIN
    SELECT COUNT(DISTINCT esn)
    INTO   cst.lease_blocked_slots
    FROM   ( SELECT x_esn esn
             FROM   sa.x_customer_lease
             WHERE  application_req_num = cst.application_req_num
             AND    lease_status IN ('1001','1002','1005')
             UNION
             SELECT x_esn esn
             FROM   sa.x_customer_lease
             WHERE  smp = cst.smp
             AND    lease_status IN ('1001','1002','1005')
           ) a;
   EXCEPTION
     WHEN others THEN
       cst.lease_blocked_slots := 0;
  END;

  -- Get the number of lines a service plan allows for a particular group
  IF cst.service_plan_objid IS NOT NULL AND cst.group_allowed_lines IS NULL
  THEN
    BEGIN
      SELECT NVL(fea.number_of_lines,1)
      INTO   cst.group_allowed_lines
      FROM   sa.service_plan_feat_pivot_mv fea
      WHERE  service_plan_objid = cst.service_plan_objid;
     EXCEPTION
       WHEN others THEN
         cst.group_allowed_lines := 0;
    END;
  END IF;

  -- Calculate the quantity of available lines for a particular group
  IF cst.group_allowed_lines > 0 THEN
    cst.group_available_capacity := cst.group_allowed_lines - ( NVL(cst.group_total_lines,0) + NVL(cst.lease_blocked_slots,0) );
    cst.group_available_capacity := GREATEST ( cst.group_available_capacity, 0);
  END IF;

  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  -- Return the type
  RETURN cst;

EXCEPTION
   WHEN OTHERS THEN
     cst.response := 'ERROR RETRIEVING PIN: ' || SQLERRM;
     RETURN cst;
     --
END retrieve_pin;

MEMBER FUNCTION get_smartphone ( i_esn IN VARCHAR2) RETURN NUMBER IS
  --
  rc   red_card_type := red_card_type ();
  --
BEGIN

  BEGIN
    SELECT (SELECT x_param_value
            FROM   table_x_part_class_params pcp,
                   table_x_part_class_values pcv
            WHERE  pcp.objid = pcv.value2class_param
            AND    pcv.value2part_class = pn.part_num2part_class
            AND    x_param_name = 'BALANCE_METERING') BALANCE_METERING,
           (SELECT x_param_value
            FROM   table_x_part_class_params pcp,
                   table_x_part_class_values pcv
            WHERE  pcp.objid = pcv.value2class_param
            AND    pcv.value2part_class = pn.part_num2part_class
            AND    x_param_name = 'BUS_ORG') BUS_ORG,
           (SELECT x_param_value
            FROM   table_x_part_class_params pcp,
                   table_x_part_class_values pcv
            WHERE  pcp.objid = pcv.value2class_param
            AND    pcv.value2part_class = pn.part_num2part_class
            AND    pcp.x_param_name = 'NON_PPE') non_ppe
    INTO   rc.balance_metering,
           rc.bus_org_id,
           rc.non_ppe_flag
    FROM   table_part_num pn,
           table_mod_level ml,
           gtt_part_inst pi
    WHERE  1 = 1
    AND    pn.objid = ml.part_info2part_num
    AND    ml.objid = pi.n_part_inst2part_mod
    AND    pi.part_serial_no = i_esn;
   EXCEPTION
     WHEN no_data_found THEN
       BEGIN
         SELECT (SELECT x_param_value
                 FROM   table_x_part_class_params pcp,
                        table_x_part_class_values pcv
                 WHERE  pcp.objid = pcv.value2class_param
                 AND    pcv.value2part_class = pn.part_num2part_class
                 AND    x_param_name = 'BALANCE_METERING') BALANCE_METERING,
                (SELECT x_param_value
                 FROM   table_x_part_class_params pcp,
                        table_x_part_class_values pcv
                 WHERE  pcp.objid = pcv.value2class_param
                 AND    pcv.value2part_class = pn.part_num2part_class
                 AND    x_param_name = 'BUS_ORG') BUS_ORG,
                (SELECT x_param_value
                 FROM   table_x_part_class_params pcp,
                        table_x_part_class_values pcv
                 WHERE  pcp.objid = pcv.value2class_param
                 AND    pcv.value2part_class = pn.part_num2part_class
                 AND    pcp.x_param_name = 'NON_PPE') non_ppe
         INTO   rc.balance_metering,
                rc.bus_org_id,
                rc.non_ppe_flag
         FROM   table_part_num pn,
                table_mod_level ml,
                table_part_inst pi
         WHERE  1 = 1
         AND    pn.objid = ml.part_info2part_num
         AND    ml.objid = pi.n_part_inst2part_mod
         AND    pi.part_serial_no = i_esn;
        EXCEPTION
          WHEN others THEN
            NULL;
       END;
     WHEN others THEN
       NULL;
  END;

  --
  IF (rc.balance_metering = 'SUREPAY') THEN
    IF rc.non_ppe_flag = '1' THEN
      rc.numeric_value := 0; -- surepay android non ppe phone
    ELSE
      rc.numeric_value := 2; -- surepay android ppe phone
    END IF;
  ELSE
    rc.numeric_value := 1; --  not surepay phone (PPE_STT, PPE_MTT, Unlimited,)
  END IF;

  RETURN rc.numeric_value;

EXCEPTION
   WHEN others THEN
     rc.numeric_value := NULL ;
     RETURN rc.numeric_value;
END get_smartphone;

MEMBER FUNCTION is_sl_red_card_compatible ( i_red_code IN VARCHAR2) RETURN BOOLEAN IS

  rc  red_card_type := SELF;

BEGIN
  --
  IF ( i_red_code IS NOT NULL ) THEN
    rc.numeric_value := 0;
    --
    BEGIN
      SELECT SUM(cnt)
      INTO   rc.numeric_value
      FROM   ( SELECT 1 cnt
               FROM   table_part_class pc,
                      table_part_inst pi ,
                      table_mod_level ml ,
                      table_part_num pn,
                      adfcrm_serv_plan_class_matview spcmv,
                      mtm_program_safelink mtm
               WHERE  pc.objid = pn.part_num2part_class
               AND    ml.objid = pi.n_part_inst2part_mod
               AND    pn.objid = ml.part_info2part_num
               AND    pn.domain = 'REDEMPTION CARDS'
               AND    spcmv.part_class_objid = pn.part_num2part_class
               AND    mtm.is_sl_red_card_compatible = 'Y'
               AND    pi.x_part_inst_status = '42'
               AND    pi.x_red_code = i_red_code
               UNION
               SELECT 1 cnt
               FROM   table_part_class pc,
                      sa.gtt_part_inst pi ,
                      table_mod_level ml ,
                      table_part_num pn,
                      adfcrm_serv_plan_class_matview spcmv,
                      mtm_program_safelink mtm
               WHERE  pc.objid = pn.part_num2part_class
               AND    ml.objid = pi.n_part_inst2part_mod
               AND    pn.objid = ml.part_info2part_num
               AND    pn.domain = 'REDEMPTION CARDS'
               AND    spcmv.part_class_objid = pn.part_num2part_class
               AND    mtm.is_sl_red_card_compatible = 'Y'
               AND    pi.x_part_inst_status = '42'
               AND    pi.x_red_code = i_red_code
             );
      EXCEPTION
        WHEN others THEN
          rc.numeric_value := 0;
    END;

  END IF;

  RETURN (rc.numeric_value != 0);

END is_sl_red_card_compatible;
-- CR43162  Added function for qpintoesn copy of standalone qpintoesn
MEMBER FUNCTION qPinToEsn(  i_esn       IN  VARCHAR2,
                            i_pin       IN  VARCHAR2,
                            o_err_code  OUT VARCHAR2,
                            o_err_msg   OUT VARCHAR2) RETURN NUMBER
IS
  l_esn_pi_objid      NUMBER;
  l_pin_pi_objid      NUMBER;
  l_pin_status        NUMBER;
  l_pin_attached_to   NUMBER;
  k_newpin            CONSTANT  VARCHAR2(2) :=  '42';
  k_attached          CONSTANT  VARCHAR2(3) := '400';
BEGIN
  BEGIN
    SELECT  pi.objid
    INTO    l_esn_pi_objid
    FROM    table_part_inst pi
    WHERE   part_serial_no = i_esn;
  EXCEPTION
    WHEN OTHERS THEN
      o_err_code :=  '1000';
      o_err_msg  :=  'ESN Rec not found';
      RETURN 1;
  END;
  --
  BEGIN
    SELECT  pi.objid,
            part_to_esn2part_inst,
            x_part_inst_status
    INTO    l_pin_pi_objid,
            l_pin_attached_to,
            l_pin_status
    FROM    table_part_inst pi
    WHERE   x_red_code = i_pin;
  EXCEPTION
    WHEN OTHERS THEN
      o_err_code :=  '1100';
      o_err_msg := 'PIN Rec not found';
      RETURN 1;
  END;
  --
  IF l_pin_status <> k_newpin
  THEN
    IF l_pin_status = k_attached and l_pin_attached_to  = l_esn_pi_objid
    THEN
      o_err_code  :=  '1200';
      o_err_msg   :=  'Pin already attached to this ESN';
      RETURN 0;
    ELSE
      o_err_code  :=  '1300';
      o_err_msg   :=  'Pin cannot be attached-Not in proper Status';
      RETURN 1;
    END IF;
  END IF;
  --
  UPDATE  table_part_inst
  SET     part_to_esn2part_inst = l_esn_pi_objid,
          x_part_inst_status    = k_attached,
          x_ext                 = (SELECT TO_NUMBER(nvl(max(x_ext),'0')) + 1
                                   FROM   table_part_inst
                                   WHERE  part_to_esn2part_inst = l_esn_pi_objid
                                   AND    x_domain = 'REDEMPTION CARDS')
  WHERE   objid  = l_pin_pi_objid;
  --
  o_err_code  :=  '0';
  o_err_msg   :=  'SUCCESS';
  --
  RETURN 0;
  --
EXCEPTION
   WHEN OTHERS THEN
    RETURN 1;
END qPinToEsn;
--
MEMBER FUNCTION get_brand_partnum ( i_partnumber IN VARCHAR2)
RETURN VARCHAR2
IS
--
  CURSOR c_brand  IS
    SELECT  bo.*
    FROM    table_part_num pn,
            table_bus_org bo
    WHERE   1 = 1
    AND     pn.part_num2bus_org = bo.objid
    AND     pn.part_number      = i_partnumber;
  --
  l_brand_rec    c_brand%ROWTYPE;
  --
BEGIN
  --
  OPEN c_brand;
  FETCH c_brand INTO l_brand_rec;
  IF c_brand%NOTFOUND
  THEN
    CLOSE c_brand;
    RETURN NULL;
  ELSE
    CLOSE c_brand;
    RETURN l_brand_rec.org_id;
  END IF;
EXCEPTION
  WHEN OTHERS  THEN
    RETURN NULL;
END get_brand_partnum;
--
MEMBER FUNCTION get_brand_pin ( i_pin IN VARCHAR2)
RETURN VARCHAR2
IS
--
  CURSOR c_brand  IS
    select  bo.*
    FROM    table_part_inst pi,
            table_mod_level ml,
            table_part_num  pn,
            table_part_class  pc,
            table_bus_org   bo
    WHERE   pi.x_red_code           = i_pin
    AND     pi.x_domain             = 'REDEMPTION CARDS'
    AND     pi.n_part_inst2part_mod = ml.objid
    AND     ml.PART_INFO2PART_NUM   = pn.objid
    AND     pn.PART_NUM2PART_CLASS  = pc.objid
    AND     pn.PART_NUM2BUS_ORG     = bo.objid
    UNION
    SELECT  bo.*
    FROM    TABLE_X_RED_CARD rc,
            table_mod_level ml,
            table_part_num  pn,
            table_part_class  pc,
            table_bus_org   bo
    WHERE   rc.X_RED_CODE           = i_pin
    AND     rc.X_RED_CARD2PART_MOD  = ml.objid
    AND     ml.PART_INFO2PART_NUM   = pn.objid
    AND     pn.PART_NUM2PART_CLASS  = pc.objid
    AND     pn.PART_NUM2BUS_ORG     = bo.objid;
  --
  l_brand_rec    c_brand%ROWTYPE;
  --
BEGIN
  --
  OPEN c_brand;
  FETCH c_brand INTO l_brand_rec;
  IF c_brand%NOTFOUND
  THEN
    CLOSE c_brand;
    RETURN NULL;
  ELSE
    CLOSE c_brand;
    RETURN l_brand_rec.org_id;
  END IF;
EXCEPTION
  WHEN OTHERS  THEN
    RETURN NULL;
END get_brand_pin;
--
-- CR49721 new member function to expire add ons based on esn
MEMBER FUNCTION expire_addons ( i_esn IN VARCHAR2)
RETURN addon_bucket_details_tab
IS
--
  CURSOR  get_addons_detail
  IS
  SELECT agb.objid,
         agb.service_plan_id ,
         spmv.data_bucket_name,
         spmv.data_bucket_value
  FROM   x_account_group_benefit       agb,
         x_account_group_member        agm,
         sa.service_plan_feat_pivot_mv spmv
  WHERE  agb.service_plan_id        =   spmv.service_plan_objid
  AND    agb.account_group_id       =   agm.account_group_id
  AND    agm.ESN                    =   i_esn
  AND    SYSDATE BETWEEN agb.start_date AND NVL(agb.end_date,SYSDATE)
  AND    spmv.rollover_flag = 'N';
  --
  expire_addon_buckets     sa.addon_bucket_details_tab := sa.addon_bucket_details_tab();
  n_bucket_id_count     NUMBER := 0;
--
BEGIN
--
  FOR each_rec IN get_addons_detail
  LOOP
    --
    n_bucket_id_count := n_bucket_id_count + 1;
    --
    UPDATE x_account_group_benefit
    SET    status   = 'EXPIRED',
           reason   = 'EXPIRED DUE TO DEACTIVATION',
           end_date = SYSDATE
    WHERE  objid    = each_rec.objid;
    --
    IF each_rec.data_bucket_name IS NOT NULL
    THEN
      expire_addon_buckets.extend;
      expire_addon_buckets(n_bucket_id_count) := sa.addon_bucket_details_type ( each_rec.service_plan_id,     --  service_plan_objid
                                                                                each_rec.data_bucket_name,    --  bucket_name
                                                                                each_rec.data_bucket_value,   --  bucket_value
                                                                                SYSDATE,                      --  expiration_date
                                                                                'DELETE',                     --  benefit_type
                                                                                NULL );                       --  bucket_group
    END IF;
    --
  END LOOP;
  --
  RETURN  expire_addon_buckets;
--
EXCEPTION
  WHEN OTHERS THEN
    --RETURN 'FAILED IN WHEN OTHERS red_card_type.expire_addons';
    RETURN NULL;
END expire_addons;
--
END;
/