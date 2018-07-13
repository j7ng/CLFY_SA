CREATE OR REPLACE TYPE sa.CUSTOMER_TYPE AS OBJECT (
  esn                             VARCHAR2(30),
  min                             VARCHAR2(30),
  msid                            VARCHAR2(30),
  account_group_objid             NUMBER(22),
  account_group_uid               VARCHAR2(50),
  account_group_name              VARCHAR2(50),
  act_react_flag                  VARCHAR2(1),
  activation_date                 DATE,         -- CR52567
  activation_parent_name          VARCHAR2(40),
  activation_service_plan         NUMBER(20),   -- CR52567
  activation_sp_objid             NUMBER(20),   -- CR52567
  add_on_data_details             add_on_data_details_tab,  -- CR49087
  add_ons_cos                     VARCHAR2(30), -- CR46350
  application_req_num             VARCHAR2(100),
  brand_leasing_flag              VARCHAR2(1),
  brand_shared_group_flag         VARCHAR2(1),
  brm_applicable_flag             VARCHAR2(1),
  brm_notification_flag           VARCHAR2(1),
  bus_org_id                      VARCHAR2(40),
  bus_org_objid                   NUMBER(22),
  card_dealer_id                  VARCHAR2(80),
  carrier_id                      VARCHAR2(40),
  carrier_name                    VARCHAR2(50),
  carrier_objid                   NUMBER(22),
  click_plan_hist_objid           NUMBER(22),
  click_plan_hist_end_date        DATE,
  call_trans_objid                NUMBER,
  click_status                    VARCHAR2(30),
  contact_objid                   NUMBER(22),
  contact_first_name              VARCHAR2(30),  -- CR49058
  contact_last_name               VARCHAR2(30),  -- CR49058
  contact_email                   VARCHAR2(100), -- CR49058
  contact_phone                   VARCHAR2(20),
  contact_security_pin            VARCHAR2(6),   -- CR47564
  conversion_rate                 VARCHAR2(50),
  cos                             VARCHAR2(30),
  credit_cards_count              NUMBER,
  customer_id                     VARCHAR2(80),  -- CR47564
  data_speed                      VARCHAR2(50),
  deactivation_reason             VARCHAR2(30),
  dealer_id                       VARCHAR2(80),
  device_type                     VARCHAR2(50),
  do_not_email                    NUMBER(1),
  do_not_phone                    NUMBER(1),
  do_not_sms                      NUMBER(1),
  do_not_mail                     NUMBER(1),
  do_not_mobile_ads               NUMBER(1),
  esn_new_personality_objid       NUMBER(22),
  esn_part_inst_code              NUMBER,
  esn_part_inst_objid             NUMBER,
  esn_part_inst_status            VARCHAR2(30),
  esn_part_number                 VARCHAR2(30),
  expiration_date                 DATE,
  extra_info                      VARCHAR2(1000),
  firmware                        VARCHAR2(50),
  fvm_status                      NUMBER(3),
  fvm_number                      VARCHAR2(50),
  first_name                      VARCHAR2(30),
  last_name                       VARCHAR2(30),
  group_available_capacity        NUMBER(3),
  group_total_lines               NUMBER(3),
  group_allowed_lines             NUMBER(3),
  group_service_plan_objid        NUMBER(22),
  group_start_date                DATE,
  group_leased_flag               VARCHAR2(1),
  group_contact_objid             NUMBER,
  group_program_enrolled_id       NUMBER,
  iccid                           VARCHAR2(30),
  ild_transaction_objid           NUMBER(22),
  ild_transaction_status          VARCHAR2(10),
  install_date                    DATE,
  install_date_by_min             DATE,       -- CR52611
  ivr_balance_config_id           NUMBER(22),
  inv_bin_objid                   NUMBER,
  is_swb_carrier                  NUMBER(1),
  language_preference             VARCHAR2(30),  -- CR49058
  latest_activation_date          DATE,       -- CR52672
  latest_activation_service_plan  NUMBER(20), -- CR52672
  latest_activation_sp_objid      NUMBER(20), -- CR52672
  last_cycle_date                 DATE,
  last_redemption_date            DATE,
  lease_status                    VARCHAR2(20),
  lease_blocked_slots             NUMBER(3),
  ll_service_type                 VARCHAR2(20),
  ll_tribal_service_type          VARCHAR2(20),
  member_objid                    NUMBER(22),
  member_status                   VARCHAR2(30),
  member_start_date               DATE,
  member_end_date                 DATE,
  member_master_flag              VARCHAR2(1),
  member_order                    NUMBER(2),
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
  motricity_deno                  VARCHAR2(50),
  mtg_source_det                  mtg_source_type,
  multiline_discount_flag         VARCHAR2(1),  -- CR52120  MultiLine Development
  no_of_add_ons                   NUMBER,       -- CR46350
  non_ppe_flag                    VARCHAR2(50),
  notify_carrier                  NUMBER,
  numeric_value                   NUMBER,
  ota_feat_objid                  NUMBER(22),
  ota_feat_ild_account            VARCHAR2(50),
  ota_feat_ild_carr_status        VARCHAR2(50),
  ota_feat_ild_prog_status        VARCHAR2(50),
  ota_transaction_objid           NUMBER(22),
  ota_transaction_status          VARCHAR2(50),
  ota_transaction_reason          VARCHAR2(150),
  parent_name                     VARCHAR2(40),
  parent_id                       VARCHAR2(30),
  parent_objid                    NUMBER(38),
  part_class_objid                NUMBER(22),
  part_class_name                 VARCHAR2(50),
  part_inst_sequence              NUMBER,
  part_number_description         VARCHAR2(255),
  part_number_dll                 NUMBER,
  part_number_manufacturer        VARCHAR2(20),
  part_number_technology          VARCHAR2(20),
  pending_redemption_status       VARCHAR2(30),
  personality_status              VARCHAR2(30),
  phone_generation                VARCHAR2(50),
  phone_manufacturer              VARCHAR2(30),
  pin                             VARCHAR2(30),
  pin_part_number                 VARCHAR2(30),
  pgm_enroll_objid                NUMBER(22),
  pgm_enrollment_status           VARCHAR2(30),
  pgm_enroll_exp_date             DATE,
  pgm_enroll_cooling_exp_date     DATE,
  pgm_enroll_next_delivery_date   DATE,
  pgm_enroll_next_charge_date     DATE,
  pgm_enroll_grace_period         NUMBER(3),
  pgm_enroll_cooling_period       NUMBER(3),
  pgm_enroll_service_days         NUMBER(3),
  pgm_enroll_wait_exp_date        DATE,
  pgm_enroll_charge_type          VARCHAR2(30),
  pgm_enrol_tot_grace_period_gn   NUMBER,
  preactivate_benefits_flag       VARCHAR2(1),
  prod_config_objid               NUMBER,     -- CR44729
  promo_access_days               NUMBER,
  promo_units                     NUMBER,
  promo_objid                     NUMBER,
  program_parameter_days          NUMBER,
  program_parameter_name          VARCHAR2(40),
  program_parameter_units         NUMBER,
  redemption_required_flag        NUMBER,
  sms_flag                        NUMBER,
  warranty_end_date               VARCHAR2(100),
  psms_outbox_objid               NUMBER(22),
  psms_outbox_status              VARCHAR2(50),
  port_in                         NUMBER,
  program_parameter_objid         NUMBER(22),
  propagate_flag                  NUMBER(4),
  prerecorded_consent             NUMBER,
  queued_cards                    customer_queued_card_tab,
  queued_days                     NUMBER(4),
  repair_date                     DATE,
  rate_plan                       VARCHAR2(60),
  reactivation_flag               NUMBER,
  response                        VARCHAR2(1000),
  safelink_flag                   VARCHAR2(1),
  safelink_lid                    VARCHAR2(20),
  safelink_pgm_param_objid        NUMBER(22),
  security_pin                    VARCHAR2(6),
  send_welcome_sms                VARCHAR2(1),
  service_end_date                DATE,
  service_order_stage_objid       NUMBER(22),
  service_order_stage_status      VARCHAR2(30),
  service_plan_benefit_type       VARCHAR2(50),  -- CR49058
  service_plan_objid              NUMBER(22),
  service_plan_data               NUMBER(12,2),
  service_plan_display_name       VARCHAR2(50),
  service_plan_name               VARCHAR2(100),
  service_plan_part_class_name    VARCHAR2(40) , -- CR47564
  service_plan_part_number        VARCHAR2(30),
  service_plan_price              NUMBER,
  service_plan_group              VARCHAR2(50),
  service_plan_days               VARCHAR2(50),
  sim_part_number                 VARCHAR2(30),
  sim_required_flag               VARCHAR2(10),
  site_id                         VARCHAR2(80),
  site_part_objid                 NUMBER,
  site_objid                      NUMBER,
  site_part_status                VARCHAR2(50),
  short_parent_name               VARCHAR2(40),
  smp                             VARCHAR2(30),
  subscriber_uid                  VARCHAR2(50),
  subscriber_spr_objid            NUMBER(22),
  sub_brand                       VARCHAR2(40),
  technology                      VARCHAR2(50),
  throttle_date                   DATE,
  throttle_policy_id              NUMBER(22),
  varchar2_value                  VARCHAR2(2000),
  warranty_date                   DATE,
  web_balance_config_id           NUMBER(22),
  web_contact_objid               NUMBER(22),
  web_login_name                  VARCHAR2(50),
  web_user_key                    VARCHAR2(30), -- CR54384
  web_user_objid                  NUMBER(22),
  wf_mac_id                       VARCHAR2(50),
  zipcode                         VARCHAR2(10),
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION customer_type RETURN SELF AS RESULT,
  -- Constructor used to initialize the ESN and or MIN
  CONSTRUCTOR FUNCTION customer_type ( i_esn  IN VARCHAR2,
                                       i_min  IN VARCHAR2 DEFAULT NULL ) RETURN SELF AS RESULT,
  -- Function used to convert a pin to an smp
  MEMBER FUNCTION convert_pin_to_smp ( i_red_card_code IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to convert an smp to an pin
  MEMBER FUNCTION convert_smp_to_pin ( i_smp IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get all the attributes for a particular customer
  MEMBER FUNCTION retrieve RETURN customer_type,
  -- Function used to get all the attributes for a particular customer
  MEMBER FUNCTION retrieve ( i_esn IN VARCHAR2 ) RETURN customer_type,
  -- Function used to get all the attributes for a particular group
  MEMBER FUNCTION retrieve_group ( i_account_group_objid IN NUMBER ) RETURN customer_type,
  -- Function used to get all the attributes for a particular customer by login name
  MEMBER FUNCTION retrieve_login ( i_login_name IN VARCHAR2 ) RETURN customer_type,
  -- Function used to get all the attributes for a particular customer by login name
  MEMBER FUNCTION retrieve_login ( i_login_name IN VARCHAR2 ,
                                   i_bus_org_id IN VARCHAR2 ) RETURN customer_type,
  -- Function used to get all the attributes for a particular customer by min
  MEMBER FUNCTION retrieve_min ( i_min IN VARCHAR2 ) RETURN customer_type,
  -- Function used to get all the attributes for a particular pin
  MEMBER FUNCTION retrieve_pin ( i_red_card_code IN VARCHAR2 ) RETURN customer_type,
  -- Function used to determine when the brand allows leasing
  MEMBER FUNCTION get_leasing_flag ( i_bus_org_objid  IN NUMBER) RETURN VARCHAR2,
  -- Function used to determine when the brand is managed by BRM
  MEMBER FUNCTION get_brm_applicable_flag ( i_bus_org_objid           IN NUMBER ,
                                            i_program_parameter_objid IN NUMBER ) RETURN VARCHAR2,
  -- Function used to determine when the brand is managed by BRM
  MEMBER FUNCTION get_brm_applicable_flag ( i_bus_org_id      IN VARCHAR2 ,
                                            i_program_parameter_objid IN NUMBER   ) RETURN VARCHAR2,
  MEMBER FUNCTION get_brm_applicable_flag ( i_busorg_objid    IN NUMBER ) RETURN VARCHAR2,    --CR47564 - WFM Changes
  MEMBER FUNCTION get_brm_applicable_flag ( i_esn             IN VARCHAR2 ) RETURN VARCHAR2,  --CR47564 - WFM Changes
  MEMBER FUNCTION get_brm_notification_flag ( i_bus_org_objid IN NUMBER ) RETURN VARCHAR2,    --CR47564 - WFM Changes
  MEMBER FUNCTION get_brm_notification_flag ( i_esn           IN VARCHAR2 ) RETURN VARCHAR2,  --CR47564 - WFM Changes
  -- Function used to determine the metering sources from the product config table
  MEMBER FUNCTION get_meter_sources ( i_device_type         IN VARCHAR2,
                                      i_brand               IN VARCHAR2,
                                      i_parent_name         IN VARCHAR2,
                                      i_service_plan_group  IN VARCHAR2 DEFAULT NULL,
                                      i_source_system       IN VARCHAR2 DEFAULT NULL          -- CR46475
                                    ) RETURN customer_type,
  -- Function used to get the brand
  MEMBER FUNCTION get_bus_org_id ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get the brand objid
  MEMBER FUNCTION get_bus_org_objid ( i_esn IN VARCHAR2 ) RETURN NUMBER,
  -- Function used to get the brand objid based on the esn or bus_org_id
  MEMBER FUNCTION get_bus_org_objid RETURN NUMBER,
  -- Function used to get the contact additional information
  MEMBER FUNCTION get_contact_add_info ( i_esn IN VARCHAR2 ) RETURN customer_type,
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
                            i_as_of_date         IN DATE DEFAULT SYSDATE ,
                            i_skip_rules_flag    IN VARCHAR2 DEFAULT 'N' ) RETURN VARCHAR2,
  -- Function used to get the cos value from a given MIN in Clarify
  MEMBER FUNCTION get_min_cos_value  ( i_min              IN VARCHAR2,
                                       i_as_of_date       IN DATE DEFAULT SYSDATE,
                                       i_bypass_date_flag IN VARCHAR2 DEFAULT 'N' ) RETURN VARCHAR2,
  -- Function used to get the necessary attributes for the cos rule engine
  MEMBER FUNCTION get_cos_attributes ( i_esn IN VARCHAR2 ) RETURN customer_type,
  -- Function used get the expiration date from site part
  MEMBER FUNCTION get_expiration_date ( i_esn IN VARCHAR2 ) RETURN DATE,
  -- Function used get the last redemption date from site part
  MEMBER FUNCTION get_last_redemption_date ( i_esn         IN VARCHAR2,
                                             i_exclude_esn IN  VARCHAR2 DEFAULT NULL ) RETURN DATE,
  MEMBER FUNCTION get_min ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get the ota conversion rate
  MEMBER FUNCTION get_ota_conversion_rate ( i_esn_part_inst_objid IN NUMBER ) RETURN VARCHAR2,
  -- Function used to get all the attributes related to part class
  MEMBER FUNCTION get_part_class_attributes ( i_esn IN VARCHAR2 ) RETURN customer_type,
  -- Function used to get the attributes pertinent to a port out request
  MEMBER FUNCTION get_port_out_attributes ( i_min IN VARCHAR2 ) RETURN customer_type,
  -- Function used to get the propagate flag from the rate plan table
  MEMBER FUNCTION get_propagate_flag ( i_rate_plan IN VARCHAR2 ) RETURN NUMBER,
  -- Function used to get the rate plan of an ESN
  MEMBER FUNCTION get_rate_plan ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get the safelink attributes and flags
  MEMBER FUNCTION get_safelink_attributes RETURN customer_type,
  -- Function used to get the attributes related to a service plan
  MEMBER FUNCTION get_service_plan_attributes RETURN customer_type,
  -- Function used to determine when the brand allows shared groups
  MEMBER FUNCTION get_shared_group_flag ( i_bus_org_id IN VARCHAR2) RETURN VARCHAR2,
  -- Added on 11/26/2014 by Juda Pena to determine if the esn's brand allows shared groups
  MEMBER FUNCTION get_shared_group_flag ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get the short description of the parent name based on the provided esn
  MEMBER FUNCTION get_short_parent_name ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get the short description of the parent name based on the logic from the previous get inquiry process
  MEMBER FUNCTION get_short_parent_name ( i_parent_name IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get the web user objid
  MEMBER FUNCTION get_web_user_attributes RETURN customer_type,
  -- Function used to get
  MEMBER FUNCTION get_service_plan_name ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get
  MEMBER FUNCTION get_service_plan_objid ( i_esn IN VARCHAR2 ) RETURN NUMBER,
  -- get the sub brand of an esn (from the part class of the phone)
  MEMBER FUNCTION get_sub_brand RETURN VARCHAR2,
  -- Function used to get the number of lines (service plan) esn
  MEMBER FUNCTION get_number_of_lines ( i_esn IN VARCHAR2 ) RETURN NUMBER,
  -- Function used to get
  MEMBER FUNCTION get_group_available_capacity ( i_esn                 IN VARCHAR2 ,
                                                 i_account_group_objid IN NUMBER   ,
                                                 i_application_req_num IN VARCHAR2 ) RETURN NUMBER,
  --
  MEMBER FUNCTION get_parent_name ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,
  -- get the esn based on the min
  MEMBER FUNCTION get_esn ( i_min IN VARCHAR2 ) RETURN VARCHAR2,
  -- CR46350  to get all the active ADD ONs and the total ADD ON threshold COS
  MEMBER FUNCTION get_add_ons ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,

  --CR44729 GO SMART ADDING NEW MEMBER FUNCTION
  MEMBER FUNCTION get_migration_flag ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,

  --CR44729 GO SMART ADDING NEW MEMBER FUNCTION
  MEMBER FUNCTION get_migration_flag ( i_min IN VARCHAR2 ) RETURN VARCHAR2,

  --CR44729 GO SMART ADDING NEW MEMBER OVERLOADED MEMBER FUNCTION
  MEMBER FUNCTION get_contact_add_info ( i_contact_objid IN NUMBER ) RETURN customer_type,
  -- CR47564 added new member function to get security pin
  MEMBER FUNCTION get_contact_security_pin ( i_contact_objid IN NUMBER   ) RETURN VARCHAR2,
  MEMBER FUNCTION get_contact_security_pin ( i_esn           IN VARCHAR2 ) RETURN VARCHAR2,
  --
  MEMBER FUNCTION get_contact_info ( i_esn IN VARCHAR2 ) RETURN customer_type,
  MEMBER FUNCTION get_web_user_id ( i_hash_webuserid IN VARCHAR2 ) RETURN NUMBER,
  MEMBER FUNCTION get_esn_part_inst_objid (i_esn IN VARCHAR2) RETURN NUMBER,
  MEMBER FUNCTION get_esn_part_inst_status (i_esn IN VARCHAR2) RETURN VARCHAR2,
  MEMBER FUNCTION get_esn_queued_cards ( i_esn IN VARCHAR2 ) RETURN customer_queued_card_tab,
  MEMBER FUNCTION get_esn_pin_redeem_days ( i_esn IN VARCHAR2, i_pin IN VARCHAR2 ) RETURN NUMBER,
  MEMBER FUNCTION get_service_plan_days ( i_esn IN VARCHAR2,
                                          i_pin IN VARCHAR2,
                                          i_service_plan_objid NUMBER DEFAULT NULL) RETURN VARCHAR2,
  MEMBER FUNCTION get_service_plan_days_name ( i_esn IN VARCHAR2,
                                               i_pin IN VARCHAR2,
                                               i_service_plan_objid NUMBER DEFAULT NULL) RETURN VARCHAR2,
  -- CR49087 function to get details of active add on of the esn
  MEMBER FUNCTION get_add_on_details  (i_esn  IN  VARCHAR2) RETURN  add_on_data_details_tab,
  MEMBER FUNCTION get_pin_redeem_days (i_pin  IN VARCHAR2)  RETURN NUMBER,
  --CR52120 for MultiLine Development
  MEMBER FUNCTION get_bus_org_attributes (i_bus_org_id IN VARCHAR2) RETURN customer_type,
  MEMBER FUNCTION get_bus_org_attributes (i_esn IN VARCHAR2) RETURN customer_type,
  MEMBER FUNCTION get_bus_org_attributes (i_bus_org_objid IN NUMBER) RETURN customer_type,
  MEMBER FUNCTION get_part_class (i_part_num IN VARCHAR2) RETURN VARCHAR2,
  MEMBER FUNCTION get_multiline_discount_flag (i_bus_org_id IN VARCHAR2) RETURN VARCHAR2,
  -- Function used to get the carrier related attributes based on esn or min
  MEMBER FUNCTION get_carrier_attributes RETURN customer_type,
  -- Function used to get the carrier name of the parent name based on the provided esn
  MEMBER FUNCTION get_carrier_name ( i_esn IN VARCHAR2 ) RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY sa.CUSTOMER_TYPE IS
-- Constructor used to initialize the entire type
CONSTRUCTOR FUNCTION customer_type RETURN SELF AS RESULT IS
BEGIN
  SELF.queued_cards := customer_queued_card_tab();
  RETURN;
END;

-- Constructor used to initialize the ESN and or MIN
CONSTRUCTOR FUNCTION customer_type ( i_esn IN VARCHAR2,
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

     -- Initialize the customer_queued_card_tab collection when the customer is not found
     SELF.queued_cards := customer_queued_card_tab();
     RETURN;
END;

-- Function used to convert a pin to an smp
MEMBER FUNCTION convert_pin_to_smp ( i_red_card_code IN VARCHAR2 ) RETURN VARCHAR2 IS

  cst customer_type := customer_type();

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

  cst customer_type := customer_type();

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
MEMBER FUNCTION retrieve RETURN customer_type IS

  cst  customer_type := SELF;
  c    customer_type := SELF;
  q    customer_queued_card_type := customer_queued_card_type();

BEGIN

  -- Initialize entire cst type with an empty object
  cst := customer_type ();

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
                pi_esn.x_part_inst_status esn_part_inst_status,
                pi_esn.x_part_inst2contact
         INTO   cst.esn_part_inst_objid,
                cst.wf_mac_id,
                cst.esn_part_inst_status,
                cst.contact_objid
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
      SELECT p.x_parent_name parent_name,
             p.x_parent_id,
             p.objid,
             p.x_queue_name
      INTO   cst.parent_name,
             cst.parent_id,
             cst.parent_objid,
             cst.carrier_name
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
  BEGIN --{ 52672 Start
  SELECT MIN(x_transact_date)
  INTO   cst.activation_date
  FROM   table_x_call_trans
  WHERE  x_service_id = cst.esn
  AND    x_action_type = '1';

  EXCEPTION
  WHEN OTHERS THEN
   NULL;
  END; --} 52672 End

  -- Get the web user and contact (Active site part status)
  BEGIN
    SELECT sp.x_zipcode zipcode,
           sp.objid site_part_objid,
           sp.part_status,
           sp.x_iccid,
           NVL2(cst.min, cst.min, sp.x_min) min,
           sp.install_date,
           sp.warranty_date,
           sp.site_part2site
    INTO   cst.zipcode,
           cst.site_part_objid,
           cst.site_part_status,
           cst.iccid,
           cst.min,
           cst.install_date,
           cst.warranty_date,
           cst.site_objid
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
                NVL2(cst.min, cst.min, sp.x_min) min,
                sp.warranty_date,
                sp.site_part2site
         INTO   cst.zipcode,
                cst.site_part_objid,
                cst.site_part_status,
                cst.iccid,
                cst.min,
                cst.warranty_date,
                cst.site_objid
         FROM   table_site_part sp
         WHERE  1 = 1
         AND    sp.x_service_id = cst.esn
         AND    sp.install_date = ( SELECT MAX(install_date)
                                    FROM   table_site_part
                                    WHERE  x_service_id = sp.x_service_id
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
                sp.install_date,
                sp.warranty_date,
                sp.site_part2site
         INTO   cst.zipcode,
                cst.site_part_objid,
                cst.site_part_status,
                cst.iccid,
                cst.min,
                cst.install_date,
                cst.warranty_date,
                cst.site_objid
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

  -- Get queued days
  BEGIN
    SELECT NVL(SUM( NVL(x_redeem_days,0) ),0) queued_days
    INTO   cst.queued_days
    FROM   table_part_inst cards,
           table_mod_level ml,
           table_part_num  pn
    WHERE  cards.part_to_esn2part_inst = cst.esn_part_inst_objid
    AND    cards.x_part_inst_status = '400'
    AND    cards.x_domain = 'REDEMPTION CARDS'
    AND    cards.n_part_inst2part_mod = ml.objid
    AND    ml.part_info2part_num = pn.objid;
   EXCEPTION
    WHEN OTHERS THEN
      cst.queued_days := 0;
  END;

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
           cst.motricity_deno,
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
      SELECT NVL2(cst.motricity_deno, cst.motricity_deno, TO_CHAR(x_motricity_deno)) ,
             x_current_conv_rate
      INTO   cst.motricity_deno,
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
           wu.web_user2contact,
           wu.user_key
    INTO   cst.web_user_objid,
           cst.web_login_name,
           cst.web_contact_objid,
           cst.web_user_key
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
         SELECT DISTINCT
                web_user_objid,
                web_login_name,
                web_user2contact,
                user_key
         INTO   cst.web_user_objid,
                cst.web_login_name,
                cst.web_contact_objid,
                cst.web_user_key
         FROM   (SELECT wu.objid web_user_objid,
                        wu.login_name web_login_name,
                        wu.web_user2contact,
                        wu.user_key
                 FROM   table_x_contact_part_inst cpi,
                        table_web_user wu
                 WHERE  1 = 1
                 AND    cpi.x_contact_part_inst2part_inst = cst.esn_part_inst_objid
                 AND    wu.web_user2contact = cpi.x_contact_part_inst2contact
                 AND    web_user2bus_org = cst.bus_org_objid);
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
           slcur.lid,
           'Y' safelink_flag
    INTO   cst.safelink_pgm_param_objid,
           cst.safelink_lid,
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

  -- Get the customer application id and lease status
  BEGIN
    SELECT cl.application_req_num,
           cl.lease_status,
           cl.smp,
           c.convert_smp_to_pin ( i_smp => cl.smp ) pin
    INTO   cst.application_req_num,
           cst.lease_status,
           cst.smp,
           cst.pin
    FROM   sa.x_customer_lease cl
    WHERE  x_esn = cst.esn;
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

  -- Get the number of lines a group
  IF cst.account_group_objid IS NOT NULL THEN
    BEGIN
      -- Get group total active lines
      SELECT COUNT(DISTINCT esn)
      INTO   cst.group_total_lines
      FROM   ( SELECT esn
               FROM   sa.x_account_group_member
               WHERE  account_group_id = cst.account_group_objid
               AND    UPPER(status) <> 'EXPIRED'
             );
     EXCEPTION
       WHEN others THEN
         cst.group_total_lines := 0;
    END;
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
               WHERE  account_group_id = cst.account_group_objid
               AND    lease_status IN ('1001','1002','1005')
             ) a
      WHERE  NOT EXISTS ( SELECT 1
                          FROM   x_account_group_member
                          WHERE  account_group_id = cst.account_group_objid
                          AND    esn = a.esn
                          AND    UPPER(status) <> 'EXPIRED'
                        );
     EXCEPTION
       WHEN others THEN
         cst.lease_blocked_slots := 0;
    END;
    --
    IF cst.group_service_plan_objid IS NOT NULL AND cst.brand_shared_group_flag = 'Y'--cst.group_allowed_lines IS NULL Changed for CR55236 TW Web common standards
    THEN
      BEGIN
        SELECT NVL(fea.number_of_lines,1)
        INTO   cst.group_allowed_lines
        FROM   sa.service_plan_feat_pivot_mv fea
        WHERE  service_plan_objid = cst.group_service_plan_objid;
       EXCEPTION
         WHEN others THEN
           cst.group_allowed_lines := 0;
      END;
    END IF;
    --
    IF cst.group_allowed_lines > 0 THEN
      cst.group_available_capacity := cst.group_allowed_lines - ( NVL(cst.group_total_lines,0) + NVL(cst.lease_blocked_slots,0) );
      cst.group_available_capacity := GREATEST ( cst.group_available_capacity, 0);
    END IF;
  END IF;

  -- Get the account group member data
  BEGIN
    SELECT subscriber_uid,
           objid,
           status,
           member_order,
           MASTER_FLAG
    INTO   cst.subscriber_uid,
           cst.member_objid,
           cst.member_status,
           cst.member_order,
           cst.member_master_flag
    FROM   ( SELECT subscriber_uid,
                    objid,
                    status,
                    member_order,
                    MASTER_FLAG
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
             NVL(x_do_not_mail,0),
             x_pin
      INTO   cst.do_not_email,
             cst.do_not_phone,
             cst.do_not_sms,
             cst.do_not_mail,
             cst.contact_security_pin
      FROM   sa.table_x_contact_add_info
      WHERE  add_info2contact = cst.contact_objid;
     EXCEPTION
       WHEN others THEN
         cst.do_not_email := 0;
         cst.do_not_phone := 0;
         cst.do_not_sms   := 0;
         cst.do_not_mail  := 0;
    END;
    -- CR49058 get contact information
    BEGIN
      SELECT tc.s_first_name,
             tc.s_last_name,
             tc.e_mail,
             xai.x_lang_pref
      INTO   cst.contact_first_name,
             cst.contact_last_name,
             cst.contact_email,
             cst.language_preference
      FROM   sa.table_contact tc,
             sa.table_x_contact_add_info xai
      WHERE  tc.objid = cst.contact_objid
      AND    xai.add_info2contact = tc.objid;
     EXCEPTION
       WHEN others THEN
         cst.contact_first_name := '';
         cst.contact_last_name  := '';
         cst.contact_email      := '';
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
    --
    -- CR40903_My_Account_App_Data_Balance_Inquiry_Update Tim 7/5/2016 added service plan group
    --
  -- Get the metering sources
--CR44107 - use the function transform_device_type as below
  c := get_meter_sources ( i_device_type        => sa.Transform_device_type(cst.device_type,cst.esn),
                           i_brand              => cst.bus_org_id,
                           i_parent_name        => cst.parent_name,
                           i_service_plan_group => cst.service_plan_group);

  cst.meter_source_voice := c.meter_source_voice;
  cst.meter_source_sms   := c.meter_source_sms;
  cst.meter_source_data  := c.meter_source_data;
  cst.meter_source_ild   := c.meter_source_ild;
  cst.prod_config_objid  := c.prod_config_objid;  -- CR44729
  cst.mtg_source_det     := c.mtg_source_det;     -- CR44729
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

  -- Get the queued cards
  SELECT customer_queued_card_type ( pi_card.part_serial_no , -- smp
                                     pi_card.x_ext          , -- ext
                                     NVL(pn.x_redeem_days,0), -- queued_days
                                     pn.part_number         , -- part_number
                                     NULL                   ) -- response
  BULK COLLECT
  INTO   cst.queued_cards
  FROM   table_part_inst pi_esn,
         table_part_inst pi_card,
         table_mod_level ml,
         table_part_num  pn
  WHERE  1 = 1
  AND    pi_esn.part_serial_no = cst.esn
  AND    pi_esn.x_domain = 'PHONES'
  AND    pi_card.part_to_esn2part_inst = pi_esn.objid
  AND    pi_card.x_part_inst_status||'' = '400'
  AND    pi_card.x_domain||'' = 'REDEMPTION CARDS'
  AND    pi_card.n_part_inst2part_mod = ml.objid
  AND    ml.part_info2part_num = pn.objid;

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
MEMBER FUNCTION retrieve ( i_esn IN VARCHAR2 ) RETURN customer_type IS

  -- instantiate initial values
  rc     sa.customer_type  := customer_type ( i_esn => i_esn );

  -- type to hold retrieved attributes
  cst    sa.customer_type;

BEGIN

  -- call the retrieve method
  cst := rc.retrieve;

  RETURN cst;

END retrieve;

-- Function used to get all the attributes for a particular customer
MEMBER FUNCTION retrieve_group ( i_account_group_objid IN NUMBER ) RETURN customer_type IS

  cst  customer_type := SELF;
  c    customer_type := SELF;
  q    customer_queued_card_type := customer_queued_card_type();

BEGIN

  -- Initialize entire cst type with an empty object
  cst := customer_type ();

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
           start_date,
           program_enrolled_id
    INTO   cst.account_group_uid,
           cst.account_group_name,
           cst.group_service_plan_objid,
           cst.bus_org_objid,
           cst.group_start_date,
           cst.group_program_enrolled_id
    FROM   sa.x_account_group
    WHERE  objid = cst.account_group_objid;
   EXCEPTION
     WHEN others THEN
       cst.response := cst.response || '|GROUP NOT FOUND';
  END;
  --
  -- Get group leased flag
  BEGIN
    SELECT 'Y'
    INTO   cst.group_leased_flag
    FROM   sa.x_customer_lease
    WHERE  account_group_id  = cst.account_group_objid
    AND    lease_status  NOT IN ('1000','1003','1004','1006');
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       cst.group_leased_flag := 'N';
     WHEN too_many_rows THEN
       cst.group_leased_flag := 'Y';
     WHEN others THEN
        cst.response := cst.response || '|GROUP LEASED FLAG FAILED';
  END;
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

  -- Get the customer application id and lease status
  IF cst.account_group_objid IS NOT NULL THEN
    BEGIN
      SELECT cl.application_req_num,
             cl.smp,
             c.convert_smp_to_pin ( i_smp => cl.smp ) pin
      INTO   cst.application_req_num,
             cst.smp,
             cst.pin
      FROM   sa.x_customer_lease cl
      WHERE  cl.account_group_id = cst.account_group_objid
      AND    ROWNUM = 1;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
    --
  END IF;

  IF cst.group_service_plan_objid IS NOT NULL THEN
    BEGIN
      SELECT sp.customer_price,
             NVL(fea.number_of_lines,1),
             CASE WHEN UPPER(fea.data) IN ('UNLIMITED','NA','DYNAMIC') THEN 0 ELSE TO_NUMBER(fea.data) END service_plan_data,
             fea.plan_purchase_part_number,
             TRIM(regexp_replace(NVL(fea.service_days,0),'[[:alpha:]]','') )
      INTO   cst.service_plan_price,
             cst.group_allowed_lines,
             cst.service_plan_data,
             cst.service_plan_part_number,
             cst.service_plan_days
      FROM   sa.x_service_plan sp,
             sa.service_plan_feat_pivot_mv fea
      WHERE  sp.objid = cst.group_service_plan_objid
      AND    sp.objid = fea.service_plan_objid;
     EXCEPTION
      WHEN too_many_rows THEN
        cst.response := cst.response || '|DUPLICATE SERVICE PLAN';
      WHEN OTHERS THEN
        cst.response := cst.response || '|SERVICE PLAN NOT FOUND';
    END;
  END IF;

  -- Get the number of lines a group
  IF cst.account_group_objid IS NOT NULL THEN
    BEGIN

      SELECT COUNT(DISTINCT esn)
      INTO   cst.group_total_lines
      FROM   ( SELECT esn
               FROM   sa.x_account_group_member
               WHERE  account_group_id = cst.account_group_objid
               AND    UPPER(status) <> 'EXPIRED'
             );
     EXCEPTION
       WHEN others THEN
         cst.group_total_lines := 0;
    END;
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
               WHERE  account_group_id = cst.account_group_objid
               AND    lease_status IN ('1001','1002','1005')
             ) a
      WHERE  NOT EXISTS ( SELECT 1
                          FROM   x_account_group_member
                          WHERE  account_group_id = cst.account_group_objid
                          AND    esn = a.esn
                          AND    UPPER(status) <> 'EXPIRED'
                        );
     EXCEPTION
       WHEN others THEN
         cst.lease_blocked_slots := 0;
    END;

    --
    IF cst.group_allowed_lines > 0 THEN
      cst.group_available_capacity := cst.group_allowed_lines - ( NVL(cst.group_total_lines,0) + NVL(cst.lease_blocked_slots,0) );
      cst.group_available_capacity := GREATEST ( cst.group_available_capacity, 0);
    END IF;
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
MEMBER FUNCTION retrieve_login ( i_login_name IN VARCHAR2 ) RETURN customer_type IS

  cst  customer_type := SELF;
  q    customer_queued_card_type := customer_queued_card_type();

BEGIN

  -- Initialize entire cst type with an empty object
  cst := customer_type ();

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
                                 i_bus_org_id IN VARCHAR2 ) RETURN customer_type IS

  cst  customer_type := SELF;
  q    customer_queued_card_type := customer_queued_card_type();

BEGIN

  -- Initialize entire cst type with an empty object
  cst := customer_type ();

  cst.bus_org_id := i_bus_org_id;

  cst.web_login_name := i_login_name;

  -- Exit when the ESN is not passed
  IF cst.web_login_name IS NULL THEN
    cst.response := 'LOGIN NAME NOT PASSED';
    RETURN cst;
  END IF;

  BEGIN
    SELECT wu.objid web_user_objid,
           wu.web_user2contact contact_objid,
           wu.web_user2bus_org
    INTO   cst.web_user_objid,
           cst.web_contact_objid,
           cst.bus_org_objid
    FROM   table_web_user wu,
           table_bus_org bo
    WHERE  1 = 1
    AND    ( wu.login_name = i_login_name OR
             wu.s_login_name = UPPER(i_login_name)
           )
    AND    wu.web_user2bus_org = bo.objid
    AND    bo.org_id = i_bus_org_id;
   EXCEPTION
     WHEN too_many_rows THEN
       cst.response := 'DUPLICATE LOGIN NAME, BRAND';
       RETURN cst;
     WHEN others THEN
       BEGIN
         SELECT COUNT(1)
         INTO   cst.numeric_value
         FROM   table_web_user
         WHERE  ( login_name = i_login_name OR
                  s_login_name = UPPER(i_login_name)
                );
        EXCEPTION
          WHEN others THEN
            cst.response := 'LOGIN NAME NOT FOUND';
            RETURN cst;
       END;
       --
       IF cst.numeric_value > 0 THEN
         cst.response := 'LOGIN NAME NOT FOUND FOR PROVIDED BRAND';
         RETURN cst;
       --
       ELSIF NVL(cst.numeric_value,0) = 0 THEN
         cst.response := 'LOGIN NAME NOT FOUND';
         RETURN cst;
       END IF;
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
MEMBER FUNCTION retrieve_min ( i_min IN VARCHAR2 ) RETURN customer_type IS

  cst  customer_type := SELF;
  c    customer_type := SELF;
  q    customer_queued_card_type := customer_queued_card_type();

BEGIN

  -- Initialize entire cst type with an empty object
 cst := customer_type ();

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
MEMBER FUNCTION retrieve_pin ( i_red_card_code IN VARCHAR2 ) RETURN customer_type IS

  cst  customer_type := SELF;
  c    customer_type := SELF;
  q    customer_queued_card_type := customer_queued_card_type();

BEGIN

  -- Initialize entire cst type with an empty object
  cst := customer_type ();

  cst.pin := i_red_card_code;

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
             cst.motricity_deno,
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

  c customer_type := customer_type();

BEGIN
  -- Default to N
  c.brand_leasing_flag := 'N';

  --To retrieve the leasing flag for given brand
  SELECT NVL(leasing_flag,'N')
  INTO   c.brand_leasing_flag
  FROM   table_bus_org bo
  WHERE  objid = i_bus_org_objid;

  RETURN(c.brand_leasing_flag);

EXCEPTION
   WHEN others THEN
     RETURN('N');

END get_leasing_flag;

-- Function used to determine when the brand is managed by BRM
MEMBER FUNCTION get_brm_applicable_flag ( i_bus_org_objid           IN NUMBER ,
                                          i_program_parameter_objid IN NUMBER ) RETURN VARCHAR2 IS

  c customer_type := customer_type();

BEGIN

  -- Default to N
  c.brm_applicable_flag := 'N';

  IF i_bus_org_objid IS NULL OR
     i_program_parameter_objid IS NULL
  THEN
    RETURN(NVL(c.brm_applicable_flag,'N'));
  END IF;

  -- To retrieve the leasing flag for given brand
  BEGIN
    SELECT NVL(brm_applicable_flag,'N')
    INTO   c.brm_applicable_flag
    FROM   table_bus_org bo
    WHERE  objid = i_bus_org_objid;
   EXCEPTION
     WHEN others THEN
       c.brm_applicable_flag := 'N';
  END;

  IF c.brm_applicable_flag = 'Y' THEN
    c.brm_applicable_flag := 'N';
    --
    BEGIN
      SELECT NVL(brm_applicable_flag,'N')
              INTO   c.brm_applicable_flag
              FROM   x_program_parameters
              WHERE  objid = i_program_parameter_objid;
     EXCEPTION
       WHEN others THEN
         c.brm_applicable_flag := 'N';
            END;
    --
  END IF;
  --
  RETURN(NVL(c.brm_applicable_flag,'N'));

EXCEPTION
   WHEN others THEN
     RETURN('N');
END get_brm_applicable_flag;

-- Function used to determine when the brand is managed by BRM
MEMBER FUNCTION get_brm_applicable_flag ( i_bus_org_id              IN VARCHAR2 ,
                                          i_program_parameter_objid IN NUMBER   ) RETURN VARCHAR2 IS

  c customer_type := customer_type();

BEGIN
  -- default to N
  c.brm_applicable_flag := 'N';

  -- exit when both parameters are not passed
  IF i_bus_org_id IS NULL OR
     i_program_parameter_objid IS NULL
  THEN
    RETURN(NVL(c.brm_applicable_flag,'N'));
  END IF;

  -- retrieve the brm applicable flag for given brand
  BEGIN
    SELECT NVL(brm_applicable_flag,'N')
    INTO   c.brm_applicable_flag
    FROM   table_bus_org bo
    WHERE  org_id = i_bus_org_id;
   EXCEPTION
     WHEN others THEN
       c.brm_applicable_flag := 'N';
  END;

  -- both (brand and program parameter) conditions have to be true to be supported by brm
  IF c.brm_applicable_flag = 'Y' THEN
    c.brm_applicable_flag := 'N';
    -- retrieve the brm applicable flag for given program parameter
    BEGIN
      SELECT NVL(brm_applicable_flag,'N')
              INTO   c.brm_applicable_flag
              FROM   x_program_parameters
              WHERE  objid = i_program_parameter_objid;
     EXCEPTION
       WHEN others THEN
         c.brm_applicable_flag := 'N';
            END;
    --
  END IF;
  --
  RETURN(NVL(c.brm_applicable_flag,'N'));

EXCEPTION
   WHEN others THEN
     RETURN('N');
END get_brm_applicable_flag;

--CR47564 - WFM Changes start
-- Function used to determine brm_applicable_flag using bus org id when the brand is managed by BRM
MEMBER FUNCTION get_brm_applicable_flag ( i_busorg_objid IN NUMBER ) RETURN VARCHAR2 IS

  c customer_type := customer_type();

BEGIN

  -- Default to N
  c.brm_applicable_flag := 'N';

  IF i_busorg_objid IS NULL
  THEN
    RETURN(NVL(c.brm_applicable_flag,'N'));
  END IF;

  -- To retrieve the leasing flag for given brand
  BEGIN
    SELECT NVL(brm_applicable_flag,'N')
    INTO   c.brm_applicable_flag
    FROM   table_bus_org bo
    WHERE  objid = i_busorg_objid;
   EXCEPTION
     WHEN others THEN
       c.brm_applicable_flag := 'N';
  END;
  --
  RETURN(NVL(c.brm_applicable_flag,'N'));

EXCEPTION
   WHEN others THEN
     RETURN('N');
END get_brm_applicable_flag;

-- Function used to determine brm_applicable_flag using ESN
MEMBER FUNCTION get_brm_applicable_flag ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS

  c customer_type := customer_type();

BEGIN
  -- Default to N
  c.brm_applicable_flag := 'N';

  IF i_esn IS NULL
  THEN
    RETURN ('N');
  END IF;

  --Get bus org objid
  c.bus_org_objid := c.get_bus_org_objid (i_esn => i_esn);

  --Get brm applicable flag for the bus org objid
  c.brm_applicable_flag := c.get_brm_applicable_flag(c.bus_org_objid);

  --
  RETURN(NVL(c.brm_applicable_flag,'N'));

EXCEPTION
   WHEN others THEN
     RETURN ('N');
END get_brm_applicable_flag;

MEMBER FUNCTION get_brm_notification_flag ( i_bus_org_objid IN NUMBER )
RETURN VARCHAR2 IS

  c customer_type := customer_type();

BEGIN

  -- Default to N
  c.brm_notification_flag := 'N';

  IF i_bus_org_objid IS NULL
  THEN
    RETURN(NVL(c.brm_notification_flag,'N'));
  END IF;

  -- To retrieve the leasing flag for given brand
  BEGIN
    SELECT NVL(brm_notification_flag,'N')
    INTO   c.brm_notification_flag
    FROM   table_bus_org bo
    WHERE  objid = i_bus_org_objid;
   EXCEPTION
     WHEN others THEN
       c.brm_notification_flag := 'N';
  END;
  --
  RETURN(NVL(c.brm_notification_flag,'N'));

EXCEPTION
   WHEN others THEN
     RETURN('N');
END get_brm_notification_flag;

MEMBER FUNCTION get_brm_notification_flag ( i_esn IN VARCHAR2 )
RETURN VARCHAR2 IS

  c customer_type := customer_type();

BEGIN

  -- Default to N
  c.brm_notification_flag := 'N';

  IF i_esn IS NULL THEN
    RETURN(NVL(c.brm_notification_flag,'N'));
  END IF;

  --Get the bus org objid for the given ESN
  c.bus_org_objid := c.get_bus_org_objid (i_esn => i_esn);

  --Changes for CR48260 start - Check for sub brand
  c.esn       := i_esn;
  c.sub_brand := c.get_sub_brand;

  IF c.sub_brand IS NOT NULL THEN
    c.bus_org_id    := c.sub_brand;
    c.bus_org_objid := c.get_bus_org_objid;
  END IF;
  --Changes for CR48260 end

  --Get the brm notification flag
  c.brm_notification_flag := c.get_brm_notification_flag (i_bus_org_objid => c.bus_org_objid);

  RETURN(NVL(c.brm_notification_flag,'N'));

EXCEPTION
   WHEN others THEN
     RETURN('N');
END get_brm_notification_flag;
--CR47564 - WFM Changes end

-- Function used to determine the metering sources from the product config table
MEMBER FUNCTION get_meter_sources ( i_device_type        IN VARCHAR2,
                                    i_brand              IN VARCHAR2,
                                    i_parent_name        IN VARCHAR2,
                                    i_service_plan_group IN VARCHAR2 DEFAULT NULL,
                                    i_source_system      IN VARCHAR2 DEFAULT NULL) -- CR46475
RETURN customer_type
IS
--
c                 customer_type   :=  customer_type();
mtg_nameval       Keys_Tbl        :=  Keys_Tbl(); -- CR44729
--
BEGIN

  -- Validate input parameters
  IF i_device_type IS NULL OR i_brand IS NULL OR i_parent_name IS NULL THEN
    c.response := 'METERING PARAMETERS NOT PASSED';
    RETURN c;
  END IF;
  -- Set device type as SMARTPHONE when passed BYOP
  c.device_type := CASE
                     WHEN i_device_type = 'BYOP' THEN 'SMARTPHONE'
                     ELSE i_device_type
                   END;

  -- Get the metering source id
  BEGIN
    SELECT  ( SELECT carrier_mtg_id
              FROM   x_usage_host
              WHERE  short_name = pc.voice_mtg_source
            ) voice_mtg_source,
            ( SELECT carrier_mtg_id
              FROM   x_usage_host
              WHERE  short_name = pc.sms_mtg_source
            ) voice_sms_source,
            ( SELECT carrier_mtg_id
              FROM   x_usage_host
              WHERE  short_name = pc.data_mtg_source
            ) voice_data_source,
            ( SELECT carrier_mtg_id
              FROM   x_usage_host
              WHERE  short_name = pc.ild_mtg_source
            ) voice_ild_source,
            bal_cfg_id_web,
            bal_cfg_id_ivr,
            objid                       -- CR44729
    INTO    c.meter_source_voice  ,
            c.meter_source_sms    ,
            c.meter_source_data   ,
            c.meter_source_ild    ,
            c.web_balance_config_id,
            c.ivr_balance_config_id,
            c.prod_config_objid         -- CR44729
    FROM   ( SELECT voice_mtg_source      ,
                    sms_mtg_source        ,
                    data_mtg_source       ,
                    ild_mtg_source        ,
                    bal_cfg_id_web        ,
                    bal_cfg_id_ivr        ,
                    objid               -- CR44729
             FROM   x_product_config
             WHERE  1= 1
             AND    brand_name = i_brand
             AND    device_type = c.device_type
             AND    parent_name = i_parent_name
             AND    NVL(source_system,'X')  = NVL(i_source_system,'X') -- CR46475
             AND    ( service_plan_group = i_service_plan_group OR
                      service_plan_group IS NULL)
             ORDER BY CASE WHEN service_plan_group = i_service_plan_group THEN 1
                           ELSE 2
                      END
           ) pc
    WHERE  ROWNUM = 1;
  EXCEPTION
    WHEN others THEN
      c.meter_source_voice    := NULL;
      c.meter_source_sms      := NULL;
      c.meter_source_data     := NULL;
      c.meter_source_ild      := NULL;
      c.web_balance_config_id := NULL;
      c.ivr_balance_config_id := NULL;
      c.prod_config_objid     := NULL; -- CR44729
  END;
  --
  -- CR44729  changes starts..
  FOR each_rec  IN  (SELECT dtl.bucket_id, uh.carrier_mtg_id
                     FROM   x_product_config_detail  dtl,
                            x_usage_host          uh
                     WHERE  dtl.PROD_CONF2PROD_CONF_DTL       = c.prod_config_objid
                     AND    uh.short_name                     = dtl.mtg_src_id  )
  LOOP
    mtg_nameval.extend;
    mtg_nameval(mtg_nameval.count) := Keys_obj (each_rec.bucket_id,each_rec.carrier_mtg_id, '');
  END LOOP;
  --
  c.mtg_source_det  :=  mtg_source_type (c.meter_source_voice    ,
                                         c.meter_source_sms      ,
                                         c.meter_source_data     ,
                                         c.meter_source_ild      ,
                                         c.web_balance_config_id ,
                                         c.ivr_balance_config_id ,
                                         mtg_nameval);
  -- CR44729  changes ends
  --
  RETURN c;
  --
EXCEPTION
  WHEN OTHERS THEN
    c.response := 'ERROR GETTING METER SOURCES: ' || SQLERRM;
    RETURN c;
    --
END get_meter_sources;

-- Get the brand
MEMBER FUNCTION get_bus_org_id ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS

  c  customer_type := customer_type ();

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

  c   customer_type := customer_type ();

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

-- Function used to get the brand objid based on the esn or bus_org_id
MEMBER FUNCTION get_bus_org_objid RETURN NUMBER IS

  c    customer_type := SELF;
  cst  customer_type := customer_type ();
BEGIN

  IF c.bus_org_id IS NOT NULL THEN
    --
    BEGIN
      SELECT bo.objid
      INTO   cst.bus_org_objid
      FROM   table_bus_org bo
      WHERE  1 = 1
      AND    org_id = c.bus_org_id;
     EXCEPTION
      WHEN others THEN
        NULL;
    END;
  END IF;

  IF cst.bus_org_objid IS NOT NULL THEN
    RETURN( cst.bus_org_objid );
  END IF;

  IF c.esn IS NOT NULL THEN
    cst.bus_org_objid := c.get_bus_org_objid ( i_esn => c.esn);
    RETURN( cst.bus_org_objid );
  END IF;

  --
  RETURN(cst.bus_org_objid);
  --
EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_bus_org_objid;

-- Function used to get the contact additional information
MEMBER FUNCTION get_contact_add_info ( i_esn IN VARCHAR2 ) RETURN customer_type IS

  cst  customer_type := customer_type();

BEGIN

  -- Initialize entire cst type with an empty object
  cst := customer_type ();

  cst.esn := i_esn;

  -- Exit when the ESN is not passed
  IF cst.esn IS NULL THEN
    cst.response := 'ESN NOT PASSED';
    RETURN cst;
  END IF;

  -- Get the contact
  BEGIN
    SELECT pi_esn.x_part_inst2contact
    INTO   cst.contact_objid
    FROM   table_part_inst pi_esn
    WHERE  pi_esn.part_serial_no = cst.esn
    AND    pi_esn.x_domain = 'PHONES';
  EXCEPTION
     WHEN too_many_rows THEN
       cst.response := 'DUPLICATE ESN FOUND';
       RETURN cst;
     WHEN no_data_found THEN
       cst.response := 'ESN NOT FOUND';
       RETURN cst;
     WHEN others THEN
       cst.response := 'UNHANDLED ERROR: ' || SQLERRM;
       RETURN cst;
  END;

  --
  IF cst.contact_objid IS NOT NULL THEN
    BEGIN
      SELECT NVL(x_do_not_email,0),
             NVL(x_do_not_phone,0),
             NVL(x_do_not_sms,0),
             NVL(x_do_not_mail,0),
             x_pin                      -- CR47564
      INTO   cst.do_not_email,
             cst.do_not_phone,
             cst.do_not_sms,
             cst.do_not_mail,
             cst.contact_security_pin   -- CR47564
      FROM   sa.table_x_contact_add_info
      WHERE  add_info2contact = cst.contact_objid;
     EXCEPTION
       WHEN others THEN
         cst.do_not_email := 0;
         cst.do_not_phone := 0;
         cst.do_not_sms   := 0;
         cst.do_not_mail  := 0;
    END;
    -- CR49058 get contact information
    BEGIN
      SELECT tc.s_first_name,
             tc.s_last_name,
             tc.e_mail,
             xai.x_lang_pref
      INTO   cst.contact_first_name,
             cst.contact_last_name,
             cst.contact_email,
             cst.language_preference
      FROM   sa.table_contact tc,
             sa.table_x_contact_add_info xai
      WHERE  tc.objid = cst.contact_objid
       AND   xai.add_info2contact = tc.objid;
    EXCEPTION
       WHEN others THEN
         cst.contact_first_name := '';
         cst.contact_last_name  := '';
         cst.contact_email      := '';
    END;
  END IF;

  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  -- Return the type
  RETURN cst;

EXCEPTION
   WHEN OTHERS THEN
     cst.response := 'ERROR RETRIEVING CONTACT ADD INFO: ' || SQLERRM;
     RETURN cst;
END get_contact_add_info;

-- Function used to get the necessary attributes for the cos rule engine
MEMBER FUNCTION get_cos ( i_esn                IN VARCHAR2,
                          i_min                IN VARCHAR2,
                          i_part_class_name    IN VARCHAR2,
                          i_bus_org_objid      IN NUMBER,
                          i_parent_name        IN VARCHAR2,
                          i_service_plan_objid IN NUMBER,
                          i_site_id            IN VARCHAR2,
                          i_as_of_date         IN DATE DEFAULT SYSDATE ) RETURN VARCHAR2 AS

  cst                 customer_type := SELF;
  l_cos               sa.x_policy_rule_config.cos%TYPE;
  l_part_class_objid  NUMBER;
  l_install_date      DATE;
  l_active_days       NUMBER;

  -- CR39916 Start - 10/05/2016 PMistry added new cursor to get cos value for compensation flow if it exists.
  cursor cur_get_cos_from_case is
      select c.x_esn, c.title, c.x_case_type, cd_cos.x_value cos_value, cd_pf.objid process_flag_objid, cd_pf.x_value process_flag_value
      from table_case c, TABLE_X_CASE_DETAIL cd_cos, TABLE_X_CASE_DETAIL cd_pf
      where 1 = 1
      and   c.x_esn = i_esn
      and   c.title in ('Replacement Units', 'Replacement Service Plan', 'Compensation Units')
      and   c.x_case_type = 'Units'
      and   cd_cos.detail2case = c.objid
      and   cd_pf.detail2case = c.objid
      and   cd_cos.x_name = 'COS'
      and   cd_pf.x_name = 'PROCESS_FLAG'
                  order by creation_time desc;

  rec_get_cos_from_case  cur_get_cos_from_case%rowtype;
  -- CR39916 End

BEGIN

  -- Validate the ESN is passed
  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  -- CR39916 Start - 10/05/2016 PMistry Get the cos value from case if the ESN have compensation flow.
  open cur_get_cos_from_case;
  fetch cur_get_cos_from_case into rec_get_cos_from_case;
  if cur_get_cos_from_case%found and  nvl(rec_get_cos_from_case.process_flag_value,'X') = 'N' then
    close cur_get_cos_from_case;

    -- update the process flag so that the cos value will not get picked up from case for second time.
   --update TABLE_X_CASE_DETAIL
    --set   x_value = 'Y'
    --where objid = rec_get_cos_from_case.process_flag_objid;

    return rec_get_cos_from_case.cos_value;

  end if;
  close cur_get_cos_from_case;
  -- CR39916 End

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
     --DBMS_OUTPUT.PUT_LINE('ERROR IN GET_COS: ' || SQLERRM);
     RETURN ('0');
END get_cos;

-- Overloaded method used to get the necessary attributes to calculate the cos from the rule engine
MEMBER FUNCTION get_cos ( i_esn                IN VARCHAR2,
                          i_as_of_date         IN DATE DEFAULT SYSDATE ,
                          i_skip_rules_flag    IN VARCHAR2 DEFAULT 'N' ) RETURN VARCHAR2 AS

  rc                  customer_type := customer_type ();
  c                   customer_type := customer_type ();
  l_cos               sa.x_policy_rule_config.cos%TYPE;
  l_active_days       NUMBER;

  -- CR39916 Start - 10/05/2016 PMistry added new cursor to get cos value for compensation flow if it exists.
  cursor cur_get_cos_from_case is
      select c.x_esn, c.title, c.x_case_type, cd_cos.x_value cos_value, cd_pf.objid process_flag_objid, cd_pf.x_value process_flag_value
      from table_case c, TABLE_X_CASE_DETAIL cd_cos, TABLE_X_CASE_DETAIL cd_pf
      where 1 = 1
      and   c.x_esn = i_esn
      and   c.title in ('Replacement Units', 'Replacement Service Plan', 'Compensation Units')
      and   c.x_case_type = 'Units'
      and   cd_cos.detail2case = c.objid
      and   cd_pf.detail2case = c.objid
      and   cd_cos.x_name = 'COS'
      and   cd_pf.x_name = 'PROCESS_FLAG'
                  order by creation_time desc;

  rec_get_cos_from_case  cur_get_cos_from_case%rowtype;
  -- CR39916 End


BEGIN

  -- Validate the ESN is passed
  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  -- CR39916 Start - 10/05/2016 PMistry Get the cos value from case if the ESN have compensation flow.
  open cur_get_cos_from_case;
  fetch cur_get_cos_from_case into rec_get_cos_from_case;
  if cur_get_cos_from_case%found and  nvl(rec_get_cos_from_case.process_flag_value,'X') = 'N' then
    close cur_get_cos_from_case;

    -- update the process flag so that the cos value will not get picked up from case for second time.
    --update TABLE_X_CASE_DETAIL
    --set   x_value = 'Y'
    --where objid = rec_get_cos_from_case.process_flag_objid;

    return rec_get_cos_from_case.cos_value;

  end if;
  close cur_get_cos_from_case;
  -- CR39916 End



  IF i_skip_rules_flag = 'N' THEN
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
  c := rc.get_cos_attributes ( i_esn => i_esn );

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
  END IF; -- IF i_skip_rules_flag = 'N' ...

  IF c.min IS NULL THEN
    c.min := rc.get_min ( i_esn => i_esn);
  END IF;

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
     --DBMS_OUTPUT.PUT_LINE('ERROR IN OVERLOADED GET_COS: ' || SQLERRM);
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
     --DBMS_OUTPUT.PUT_LINE('ERROR IN GET_MIN_COS_VALUE: ' || SQLERRM);
     RETURN('0');
END get_min_cos_value;

-- Function used to get the necessary attributes for the cos rule engine
MEMBER FUNCTION get_cos_attributes ( i_esn IN VARCHAR2 ) RETURN customer_type IS

  cst  customer_type := customer_type();
  c    customer_type := SELF;

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
         AND    sp.install_date = ( SELECT MAX(install_date)
                                    FROM   table_site_part
                                    WHERE  x_service_id = sp.x_service_id
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

  ----------------------------------------------------------------------------------
  BEGIN --{ 52567 Start --get the minimum Action type 1 record

  SELECT x_transact_date, call_trans2site_part
  INTO   cst.activation_date, cst.activation_sp_objid
  FROM
         (
          SELECT  x_transact_date, CALL_TRANS2SITE_PART
          FROM    table_x_call_trans
          WHERE   x_service_id = cst.esn
          AND     x_action_type = '1'
          ORDER BY objid
          )
  WHERE    ROWNUM = 1;

  EXCEPTION
  WHEN OTHERS THEN
   NULL;
  END; --} 52567 End

  IF cst.activation_sp_objid IS NOT NULL
  THEN --{
   BEGIN --{ 52567 Start

   SELECT plan_hist2service_plan
   INTO   cst.activation_service_plan
   FROM
       (
        SELECT *
        FROM  sa.x_service_plan_hist
        WHERE plan_hist2site_part = cst.activation_sp_objid
        ORDER BY x_insert_date
        )
   WHERE ROWNUM = 1;

   EXCEPTION
   WHEN OTHERS THEN
    NULL;
   END; --} 52567 End
  END IF; --}

----------------

  BEGIN --{ 52672 Start --get the latest Action type 1 record

  SELECT x_transact_date, call_trans2site_part
  INTO   cst.latest_activation_date, cst.latest_activation_sp_objid
  FROM
         (
          SELECT  x_transact_date, CALL_TRANS2SITE_PART
          FROM    table_x_call_trans
          WHERE   x_service_id = cst.esn
          AND     x_action_type = '1'
          ORDER BY objid DESC
          )
  WHERE    ROWNUM = 1;

  EXCEPTION
  WHEN OTHERS THEN
   NULL;
  END; --} 52672 End

  IF cst.latest_activation_sp_objid IS NOT NULL
  THEN --{
   BEGIN --{ 52567 Start

   SELECT plan_hist2service_plan
   INTO   cst.latest_activation_service_plan
   FROM
       (
        SELECT *
        FROM  sa.x_service_plan_hist
        WHERE plan_hist2site_part = cst.latest_activation_sp_objid
        ORDER BY x_insert_date
        )
   WHERE ROWNUM = 1;

   EXCEPTION
   WHEN OTHERS THEN
    NULL;
   END; --} 52567 End
  END IF; --}

  --52611 start Do not add status condition in below queries. It is used for providing Promos for the line activated during some install dates.
  BEGIN --{
   SELECT  MIN(install_date)
   INTO    cst.install_date_by_min
   FROM    table_site_part
   WHERE   x_min = cst.min
   AND     sa.customer_info.get_bus_org_id(x_service_id) = sa.customer_info.get_bus_org_id(sa.customer_info.get_esn (cst.min)) --to handle upgrades
   AND     install_date IS NOT NULL
   AND     NVL(x_refurb_flag,10000)  <> 1;
  EXCEPTION
  WHEN OTHERS THEN
   RETURN NULL;
  END; --}
  --52611 end
  ----------------------------------------------------------------------------------

  --
  IF cst.site_part_objid IS NOT NULL THEN
    -- Get the service plan and cos
    BEGIN
      SELECT spsp.x_service_plan_id,
             fea.cos,
             fea.plan_purchase_part_number
      INTO   cst.service_plan_objid,
             cst.cos,
             cst.service_plan_part_number
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
           pi.part_inst2inv_bin inv_bin_objid,
           pn.part_number
    INTO   cst.bus_org_id,
           cst.bus_org_objid,
           cst.part_class_name,
           cst.part_class_objid,
           cst.inv_bin_objid,
           cst.esn_part_number
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

  -- Get the activation site id, activation carrier name
  BEGIN
    SELECT s.site_id,
          (SELECT p.x_parent_name
            FROM table_x_parent p ,
                 table_x_carrier_group g ,
                 table_x_carrier c
          WHERE  p.objid = g.x_carrier_group2x_parent
            AND  g.objid = c.carrier2carrier_group
            AND  c.objid = ct.x_call_trans2carrier) activation_parent_name
    INTO   cst.site_id,
           cst.activation_parent_name
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

  -- get card dealer id
  BEGIN
    SELECT ib.bin_name
      INTO cst.card_dealer_id
      FROM table_x_red_card rc,
           table_mod_level ml,
           table_part_num pn,
           table_x_call_trans ct,
           table_inv_bin ib
     WHERE rc.x_red_card2part_mod   = ml.objid
       AND ml.part_info2part_num    = pn.objid
       AND pn.domain                = 'REDEMPTION CARDS'
       AND rc.red_card2call_trans   = ct.objid
       AND ib.objid                 = rc.x_red_card2inv_bin
       AND ct.x_service_id          = cst.esn
       AND ct.x_transact_date       = sa.util_pkg.get_last_base_red_date ( i_esn => cst.esn);

  EXCEPTION
       WHEN others THEN
         NULL;
  END;

  -- Get the last redemption date
  cst.last_redemption_date := c.get_last_redemption_date ( i_esn => cst.esn );
  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  RETURN cst;

EXCEPTION
   WHEN OTHERS THEN
     --DBMS_OUTPUT.PUT_LINE('ERROR IN GET_COS_ATTRIBUTES: ' || SQLERRM);
     cst.response := 'ERROR RETRIEVING COS ATTRIBUTES: ' || SQLERRM;
     RETURN cst;
     --
END get_cos_attributes;

-- Function used get the expiration date from site part
MEMBER FUNCTION get_expiration_date ( i_esn IN VARCHAR2 ) RETURN DATE IS

  cst customer_type := SELF;

BEGIN

  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  BEGIN
  SELECT x_expire_dt
    INTO cst.expiration_date
    FROM (
    SELECT sp.x_expire_dt
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
           )
    ORDER BY (CASE WHEN sp.part_status = 'Active' then 1
               ELSE 2
               END
              ),
              sp.x_expire_dt DESC
    )
    where rownum  = 1;

   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  RETURN cst.expiration_date;

EXCEPTION
   WHEN others THEN
     --DBMS_OUTPUT.PUT_LINE('ERROR IN GET_EXPIRATION_DATE: ' || SQLERRM);
     RETURN NULL;
END get_expiration_date;

-- Function used get the last redemption date from site part
-- CR53137 Modified get_last_redemption_date function for increasing the performance.
MEMBER FUNCTION get_last_redemption_date ( i_esn         IN VARCHAR2 ,
                                           i_exclude_esn IN VARCHAR2 DEFAULT NULL ) RETURN DATE IS

  cst  customer_type := SELF;
  c    customer_type := customer_type();
  n_days                 NUMBER;
  n_transaction_days     NUMBER;
  FUNCTION f_get_red_date ( i_esn   IN VARCHAR2,
                            i_transaction_days  IN NUMBER
      ) RETURN DATE IS
   l_red_date DATE;
  BEGIN
   SELECT MAX(x_transact_date)
   INTO   l_red_date
   FROM   ( SELECT x_transact_date  -- purch hdr
             FROM   table_x_call_trans ct
             WHERE  ct.x_service_id = i_esn
    AND    ct.x_transact_date >= TRUNC(SYSDATE) - i_transaction_days
    AND    ct.x_action_type+0 IN ( 1, 3, 6)
    AND    x_result = 'Completed'
    AND    NVL(x_reason,'X') NOT IN ('ADD_ON','COMPENSATION') --
             AND    EXISTS (SELECT  1
                            FROM   sa.x_program_purch_hdr hdr,
                                   sa.x_program_gencode pg
                            WHERE  1 = 1
                            AND    pg.gencode2call_trans     = ct.objid
                            AND    pg.gencode2prog_purch_hdr = hdr.objid
                            AND    hdr.x_ics_rflag IN ('ACCEPT', 'SOK')
                            AND    NVL(hdr.x_ics_rcode,'0') IN ('1','100')
                            AND    ( hdr.x_merchant_id IS NOT NULL OR hdr.x_payment_type = 'LL_RECURRING' )
                            AND    hdr.x_payment_type NOT IN ('REFUND', 'OTAPURCH')
                            )

             UNION
             SELECT  ct.x_transact_date  -- red card
             FROM    table_x_call_trans ct,
                     table_x_red_card rc
             WHERE   ct.x_service_id = i_esn
    AND     ct.x_transact_date >= TRUNC(SYSDATE) - i_transaction_days
    AND     ct.x_action_type+0 IN ( 1, 3, 6)
    AND     ct.x_result = 'Completed'
    AND     rc.red_card2call_trans = ct.objid
    AND     NVL(x_reason,'X') NOT IN ('ADD_ON','COMPENSATION') -- it will avoid the data addons and ild addons
             UNION
             SELECT  ct.x_transact_date  -- awop/replacement
             FROM    table_x_call_trans ct
             WHERE   ct.x_service_id = i_esn
    AND     ct.x_transact_date >= TRUNC(SYSDATE) - i_transaction_days
    AND     ct.x_action_type+0 IN ( 1, 3, 6)
    AND     ct.x_result = 'Completed'
    AND     NVL(x_reason,'X') IN ('AWOP', 'REPLACEMENT')
             );

        RETURN l_red_date;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END f_get_red_date;

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
             ORDER BY (CASE
                        WHEN part_status = 'Active' THEN 1
                         ELSE 2
                        END
                       ),
                       install_date DESC
           )
    WHERE  ROWNUM = 1;
   EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
  END;

  FOR all_esns IN ( SELECT objid,
                           x_service_id,
                           install_date,
                           part_status
                    FROM   table_site_part tsp
                    WHERE  x_min = c.min
                    AND NOT EXISTS ( SELECT 1
                                     FROM   table_site_part
                                     WHERE  x_min = tsp.x_min
                                     AND    x_service_id = tsp.x_service_id
                                     AND    x_service_id = i_exclude_esn
                                   )
                    ORDER BY (CASE
                               WHEN tsp.part_status = 'Active' THEN 1
                                ELSE 2
                              END
                             ),
                             install_date DESC
                  )
  LOOP
 -- Fteching plan sevice days
 BEGIN
   SELECT mv.days
   INTO n_days
   FROM x_service_plan_site_part xspsp
   INNER JOIN service_plan_feat_pivot_mv mv ON mv.service_plan_objid = x_service_plan_id
   AND xspsp.table_site_part_id = all_esns.objid;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     n_days := 0;
 END;
   --
    IF n_days <= 30 THEN
     SELECT TO_NUMBER(x_param_value)
       INTO n_transaction_days
       FROM table_x_parameters
      WHERE x_param_name = 'CALL_TRANS_LIMIT4NON_MULTI_MNTH'
        AND ROWNUM = 1; -- Defining days limit for Non-Multi month plans
    ELSE
     SELECT TO_NUMBER(x_param_value)
       INTO n_transaction_days
       FROM table_x_parameters
      WHERE x_param_name = 'CALL_TRANS_LIMIT4MULTI_MNTH'
        AND ROWNUM = 1;
    END IF;
 --
    IF c.get_shared_group_flag (i_esn => i_esn) = 'N' THEN
      c.last_redemption_date := f_get_red_date (i_esn               => all_esns.x_service_id,
                                                i_transaction_days  => n_transaction_days);
      EXIT WHEN c.last_redemption_date IS NOT NULL;
    ELSE
      FOR grp_esn in ( SELECT esn, master_flag
                       FROM   x_account_group_member
                       WHERE  account_group_id IN ( SELECT account_group_id
                                                    FROM   x_account_group_member
                                                    WHERE  UPPER(status) <> 'EXPIRED'
                                                    AND    esn = all_esns.x_service_id)
                       UNION
                       SELECT part_serial_no, 'N' master_flag
                       FROM   table_part_inst
                       WHERE  part_serial_no = all_esns.x_service_id
                       ORDER BY master_flag DESC
     )
      LOOP
  -- Shared plans doesn't have the multi-month subscribers, so transaction days are fixed to parameter.
  SELECT TO_NUMBER(x_param_value)
  INTO n_transaction_days
  FROM table_x_parameters
  WHERE x_param_name = 'CALL_TRANS_LIMIT4NON_MULTI_MNTH'
   AND ROWNUM = 1; -- Defining days limit for Non-Multi month plans
        c.last_redemption_date := f_get_red_date (i_esn               => grp_esn.esn,
                                                  i_transaction_days  => n_transaction_days
             );
        EXIT WHEN c.last_redemption_date IS NOT NULL;
      END LOOP;

    EXIT WHEN c.last_redemption_date IS NOT NULL;
    END IF;

  END LOOP;
  -- If the above logic does not return a valid redemption date, then pick max tran date from call trans
  IF c.last_redemption_date IS NULL THEN
    SELECT MAX(x_transact_date)
    INTO   c.last_redemption_date
    FROM   table_x_call_trans ct
    WHERE  x_action_type IN ( 1, 3, 6)
    AND    x_service_id = i_esn
    AND    NVL(x_reason,'X') NOT IN ('ADD_ON', 'MINCHANGE','COMPENSATION');
  END IF;
   -- If the above logic does not return a valid redemption date from call trans, then use site part (install date)
  IF c.last_redemption_date IS NULL THEN
    SELECT MAX(install_date)
    INTO   c.last_redemption_date
    FROM   table_site_part sp
    WHERE  x_service_id = i_esn;
  END IF;

  RETURN (c.last_redemption_date);

EXCEPTION
   WHEN others THEN
     --DBMS_OUTPUT.PUT_LINE('ERROR IN GET_LAST_REDEMPTION_DATE: ' || SQLERRM);
     RETURN NULL;
END get_last_redemption_date;

MEMBER FUNCTION get_min ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS
cst customer_type := customer_type();
BEGIN
  cst.esn := i_esn;

  IF cst.esn IS NULL THEN
    RETURN NULL;
  END IF;

  -- Get the min, carrier parent and wf_mac_id
  BEGIN
    SELECT pi_min.part_serial_no min
    INTO   cst.min
    FROM   table_part_inst pi_esn,
           table_part_inst pi_min
    WHERE  pi_esn.part_serial_no = cst.esn
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_min.part_to_esn2part_inst = pi_esn.objid
    AND    pi_min.x_domain = 'LINES';
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  IF cst.min IS NULL THEN
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
           SELECT NVL2(cst.min, cst.min, sp.x_min) min
           INTO   cst.min
           FROM   table_site_part sp
           WHERE  1 = 1
           AND    sp.x_service_id = cst.esn
           AND    sp.install_date = ( SELECT MAX(install_date)
                                      FROM   table_site_part
                                      WHERE  x_service_id = sp.x_service_id
                                     );
          EXCEPTION
            WHEN others THEN
              NULL;
         END;
       WHEN too_many_rows THEN
         -- Get the max objid when there is more than one active site part
         BEGIN
           SELECT NVL2(cst.min, cst.min, sp.x_min) min
           INTO   cst.min
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
            WHEN others THEN
              NULL;
         END;
       WHEN others THEN
         NULL;
    END;
  END IF;

  RETURN cst.min;

EXCEPTION
  WHEN others THEN
    RETURN NULL;
END get_min;
-- Function used to get the ota conversion rate
MEMBER FUNCTION get_ota_conversion_rate ( i_esn_part_inst_objid IN NUMBER ) RETURN VARCHAR2 IS

  cst  customer_type := SELF;

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
     --DBMS_OUTPUT.PUT_LINE('ERROR IN GET_OTA_CONVERSION_RATE: ' || SQLERRM);
     RETURN NULL;
END get_ota_conversion_rate;

-- Function used to get all the attributes related to part class
MEMBER FUNCTION get_part_class_attributes ( i_esn IN VARCHAR2 ) RETURN customer_type IS

  cst  customer_type := SELF;
  c    customer_type := SELF;
  q    customer_queued_card_type := customer_queued_card_type();

BEGIN

  -- Initialize entire cst type with an empty object
  cst := customer_type ();

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
           pcpv.data_speed,
           pcpv.sub_brand,
           pcpv.send_welcome_sms
    INTO   cst.bus_org_id,
           cst.firmware,
           cst.motricity_deno,
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
           cst.data_speed,
           cst.sub_brand,
           cst.send_welcome_sms
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
MEMBER FUNCTION get_port_out_attributes ( i_min IN VARCHAR2 ) RETURN customer_type IS

  cst  customer_type := customer_type ();
  c    customer_type := customer_type ();
  q    customer_queued_card_type := customer_queued_card_type();

BEGIN

  -- Initialize entire cst type with an empty object
  cst := customer_type ();

  cst.min := i_min;

  -- Exit when the ESN is not passed
  IF cst.min IS NULL THEN
    cst.response := 'MIN NOT PASSED';
    RETURN cst;
  END IF;

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

  c := cst.retrieve;

  cst.response := c.response;

  -- Get the ESN from part inst relationship
  BEGIN
    SELECT pi_min.x_part_inst_status,
           pi_min.status2x_code_table,
           pi_min.x_cool_end_date,
           pi_min.warr_end_date,
           pi_min.repair_date,
           pi_min.part_inst2x_pers,
           pi_min.part_inst2x_new_pers,
           pi_min.part_to_esn2part_inst,
           pi_min.last_cycle_ct,
           pi_min.x_port_in
    INTO   c.min_part_inst_status       ,
           c.min_part_inst_code         ,
           c.min_cool_end_date          ,
           c.min_warr_end_date          ,
           c.repair_date                ,
           c.min_personality_objid      ,
           c.min_new_personality_objid  ,
           c.min_to_esn_part_inst_objid ,
           c.last_cycle_date            ,
           c.port_in
    FROM   table_part_inst pi_min,
           table_part_inst pi_esn
    WHERE  pi_min.part_serial_no = cst.min
    AND    pi_min.x_domain = 'LINES'
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst;
   EXCEPTION
     WHEN others THEN
       -- Get the ESN from site part relationship
         cst.response := 'MIN PARAMETERS NOT FOUND';
            RETURN cst;
  END;

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

  BEGIN
      SELECT
              objid,
              x_enrollment_status ,
              x_exp_date ,
              x_cooling_exp_date ,
              x_next_delivery_date,
              x_next_charge_date ,
              x_grace_period ,
              x_cooling_period,
              x_service_days ,
              x_wait_exp_date ,
              x_charge_type,
              x_tot_grace_period_given
      INTO    c.pgm_enroll_objid,
              c.pgm_enrollment_status,
              c.pgm_enroll_exp_date,
              c.pgm_enroll_cooling_exp_date,
              c.pgm_enroll_next_delivery_date,
              c.pgm_enroll_next_charge_date,
              c.pgm_enroll_grace_period,
              c.pgm_enroll_cooling_period,
              c.pgm_enroll_service_days,
              c.pgm_enroll_wait_exp_date,
              c.pgm_enroll_charge_type,
              c.pgm_enrol_tot_grace_period_gn
      FROM   ( SELECT enr.objid,
                      enr.x_enrollment_status ,
                      enr.x_exp_date ,
                      enr.x_cooling_exp_date ,
                      enr.x_next_delivery_date,
                      enr.x_next_charge_date ,
                      enr.x_grace_period ,
                      enr.x_cooling_period,
                      enr.x_service_days ,
                      enr.x_wait_exp_date ,
                      enr.x_charge_type,
                      enr.x_tot_grace_period_given
               FROM   x_program_enrolled enr
               WHERE  enr.x_esn = cst.esn
               AND    x_enrollment_status IN ('ENROLLED','ENROLLMENTSCHEDULED')
               AND    x_next_charge_date > SYSDATE
               UNION ALL
               SELECT enr.objid,
                      enr.x_enrollment_status ,
                      enr.x_exp_date ,
                      enr.x_cooling_exp_date ,
                      enr.x_next_delivery_date,
                      enr.x_next_charge_date ,
                      enr.x_grace_period ,
                      enr.x_cooling_period,
                      enr.x_service_days ,
                      enr.x_wait_exp_date ,
                      enr.x_charge_type,
                      enr.x_tot_grace_period_given
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
      NULL;
      --dbms_output.put_line('not found'||sqlcode);
  END;

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

  BEGIN
    SELECT objid,
           x_status
    INTO  c.psms_outbox_objid,
          c.psms_outbox_status
    FROM table_x_psms_outbox
    WHERE x_esn = c.esn
    AND x_status = 'Pending';
  EXCEPTION
   WHEN OTHERS THEN
     null;
  END;

  BEGIN
    SELECT  objid,
            x_ild_account ,
            x_ild_carr_status,
            x_ild_prog_status
    INTO    c.ota_feat_objid,
            c.ota_feat_ild_account    ,
            c.ota_feat_ild_carr_status,
            c.ota_feat_ild_prog_status
    FROM    table_x_ota_features
    WHERE   x_ota_features2part_inst = c.esn_part_inst_objid
    AND     x_ild_prog_status = 'InQueue';
  EXCEPTION
   WHEN OTHERS THEN
     null;
  END;

   BEGIN
    SELECT x_fvm_status,
           x_fvm_number
    INTO   c.fvm_status ,
           c.fvm_number
    FROM x_free_voice_mail
    WHERE  x_fvm_status = 2
    AND free_vm2part_inst = c.esn_part_inst_objid;
  EXCEPTION
   WHEN OTHERS THEN
     null;
  END;

  BEGIN
    SELECT objid,
           x_end_date
    INTO   c.click_plan_hist_objid ,
           c.click_plan_hist_end_date
    FROM   table_x_click_plan_hist
    WHERE  curr_hist2site_part =c.site_part_objid
    AND (x_end_date IS NULL OR x_end_date = TRUNC(TO_DATE('01/01/1753' ,'MM/DD/YYYY')));
  EXCEPTION
   WHEN OTHERS THEN
     null;
  END;

   BEGIN
    SELECT  objid,
            x_status,
            x_reason
    INTO    c.ota_transaction_objid,
            c.ota_transaction_status,
            c.ota_transaction_reason
    FROM    table_x_ota_transaction
    WHERE   x_status = 'OTA PENDING'
    AND     x_esn = c.esn;
  EXCEPTION
   WHEN OTHERS THEN
     null;
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

  cst  customer_type := SELF;

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
    --DBMS_OUTPUT.PUT_LINE('ERROR IN GET_PROPAGATE_FLAG: ' || SQLERRM);
    RETURN NULL;
END get_propagate_flag;

-- Function used to get the rate plan of an ESN
MEMBER FUNCTION get_rate_plan ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS

  cst  customer_type := SELF;

BEGIN

  -- ESN is a mandatory input parameter
  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  -- get rate plan from configuration tables
  cst.rate_plan := service_plan.f_get_esn_rate_plan ( p_esn => i_esn);

  IF cst.rate_plan IS NULL
  THEN
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
  END IF;

  --
  RETURN cst.rate_plan;

EXCEPTION
  WHEN others THEN
    --DBMS_OUTPUT.PUT_LINE('ERROR IN GET_RATE_PLAN: ' || SQLERRM);
    RETURN NULL;
END get_rate_plan;

-- Function used to get the safelink attributes and flags
MEMBER FUNCTION get_safelink_attributes RETURN customer_type IS
  cst customer_type := SELF;
  c   customer_type := customer_type();
BEGIN

  -- validate input parameters
  IF cst.esn IS NULL AND cst.min IS NULL THEN
    cst.response := 'MIN OR ESN MUST BE PASSED';
    RETURN cst;
  END IF;

  -- get the esn with the min
  IF cst.esn IS NULL THEN
    cst.esn := c.get_esn ( i_min => cst.min );
  END IF;

  -- Get the safelink program parameter
  BEGIN
    SELECT DISTINCT
           pgm.objid,
           pe.x_next_charge_date,
           pe.x_next_delivery_date,
           'Y' safelink_flag,
           slcur.lid safelink_lid
    INTO   cst.safelink_pgm_param_objid,
           cst.pgm_enroll_next_charge_date,
           cst.pgm_enroll_next_delivery_date,
           cst.safelink_flag,
           cst.safelink_lid
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

  -- Set successful response
  cst.response := CASE WHEN (cst.response IS NULL OR cst.response = 'SUCCESS')
                       THEN 'SUCCESS'
                       ELSE (cst.response || '|SUCCESS')
                  END;

  --
  RETURN cst;

EXCEPTION
   WHEN OTHERS  THEN
     cst.response := 'ERROR IN GET_SAFELINK_ATTRIBUTES: ' || SQLERRM;
    RETURN cst;
END get_safelink_attributes;

-- Added on 11/26/2014 by Juda Pena to determine if the brand allows shared groups
MEMBER FUNCTION get_service_plan_attributes RETURN customer_type IS
  cst customer_type := SELF;
  c   customer_type := customer_type();

BEGIN

  -- validate input parameters
  IF cst.esn IS NULL AND
     cst.min IS NULL
  THEN
    cst.response := 'MIN OR ESN MUST BE PASSED';
    RETURN cst;
  END IF;

  -- get the esn with the min
  IF cst.esn IS NULL
  THEN
    cst.esn := cst.get_esn ( i_min => cst.min );
  END IF;

  -- Get
  BEGIN
    SELECT pi_esn.objid esn_part_inst_objid
    INTO   cst.esn_part_inst_objid
    FROM   table_part_inst pi_esn
    WHERE  pi_esn.part_serial_no = cst.esn
    AND    pi_esn.x_domain = 'PHONES';
  EXCEPTION
  WHEN others
  THEN
    NULL;
    --RETURN cst;
  END;

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
         AND    sp.install_date = ( SELECT MAX(install_date)
                                    FROM   table_site_part
                                    WHERE  x_service_id = sp.x_service_id
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
             TRIM(regexp_replace(NVL(fea.service_days,0),'[[:alpha:]]','') ),
             sp.customer_price,
             fea.ll_tribal_serv_type, -- CR49915 WFM LIFELINE changes
             fea.ll_serv_type         -- CR49915 WFM LIFELINE changes
      INTO   cst.service_plan_objid,
             cst.service_plan_name,
             cst.group_allowed_lines,
             cst.service_plan_group,
             cst.service_plan_data,
             cst.service_plan_part_number,
             cst.service_plan_days,
             cst.service_plan_price,
             cst.ll_tribal_service_type, -- CR49915 WFM LIFELINE changes
             cst.ll_service_type         -- CR49915 WFM LIFELINE changes
      FROM   x_service_plan_site_part spsp,
             sa.service_plan_feat_pivot_mv fea,
             x_service_plan sp
      WHERE  spsp.table_site_part_id = cst.site_part_objid
      AND    spsp.x_service_plan_id = fea.service_plan_objid
      AND    fea.service_plan_objid = sp.objid;
     EXCEPTION
      WHEN too_many_rows THEN
        cst.response := cst.response || '|DUPLICATE SERVICE PLAN, COS';
      WHEN OTHERS THEN
        cst.response := cst.response || '|SERVICE PLAN NOT FOUND';
    END;

    IF  cst.service_plan_part_number IS NOT NULL THEN

      -- Get the service plan part class name
       SELECT pc.name service_plan_part_class_name
         INTO cst.service_plan_part_class_name
         FROM table_part_num pn,
              table_part_class pc
       WHERE  pn.part_num2part_class = pc.objid
         AND  pn.part_number   = cst.service_plan_part_number;
    END IF;

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

  c customer_type := customer_type();

BEGIN

  -- Added for CR37756 by sethiraj to get the shared_flag for the bus_org_id.
  SELECT NVL(shared_group_flag,'N')
  INTO   c.brand_shared_group_flag
  FROM   table_bus_org
  WHERE  org_id = i_bus_org_id;

  -- Return output value
  RETURN(c.brand_shared_group_flag);

EXCEPTION
   WHEN OTHERS THEN
     -- Return as N (No) whenever an error occurs
     RETURN('N');
END get_shared_group_flag;

-- Added on 11/26/2014 by Juda Pena to determine if the esn's brand allows shared groups
MEMBER FUNCTION get_shared_group_flag ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS
  cst customer_type := customer_type();
  c   customer_type := customer_type();
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

-- Function used to get the short description of the parent name based on the provided esn
MEMBER FUNCTION get_short_parent_name ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS
  cst  customer_type := customer_type();
BEGIN
  --
  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  --
  BEGIN
    SELECT p.x_parent_name parent_name
    INTO   cst.parent_name
    FROM   table_part_inst pi_esn,
           table_part_inst pi_min,
           table_x_parent p,
           table_x_carrier_group cg,
           table_x_carrier c
    WHERE  1 = 1
    AND    pi_esn.part_serial_no = i_esn
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst
    AND    pi_min.part_inst2carrier_mkt = c.objid
    AND    c.carrier2carrier_group = cg.objid
    AND    cg.x_carrier_group2x_parent = p.objid;
   EXCEPTION
     WHEN others THEN
       cst.parent_name := NULL;
  END;

  --
  IF cst.parent_name IS NOT NULL THEN
    --
    cst.short_parent_name := cst.get_short_parent_name ( i_parent_name => cst.parent_name );
    --
  END IF;

  --
  RETURN cst.short_parent_name;

EXCEPTION
   WHEN OTHERS  THEN
     RETURN NULL;
END get_short_parent_name;


-- Function used to get the short description of the parent name based on the logic from the previous get inquiry process
MEMBER FUNCTION get_short_parent_name ( i_parent_name IN VARCHAR2 ) RETURN VARCHAR2 IS

  cst  customer_type := SELF;
  v_parent_name table_x_parent.x_parent_name%TYPE; --CR46073

BEGIN
  --
  v_parent_name := REGEXP_REPLACE( i_parent_name ,'[^[:alnum:]'' '']', NULL); --CR46073  - Remove special characters

  -- CR46073 - ELSE i_parent_name commented this line and added below ELSE clause
  cst.short_parent_name := CASE i_parent_name
                             WHEN 'T-MOBILE'                 THEN 'TMO'
                             WHEN 'T-MOBILE SAFELINK'        THEN 'TMO'
                             WHEN 'T-MOBILE PREPAY PLATFORM' THEN 'TMO'
                             WHEN 'T-MOBILE SIMPLE'          THEN 'TMO'
                             WHEN 'TMOSM'                    THEN 'TMO'
                             WHEN 'TMOWFM'                   THEN 'TMO'
                             WHEN 'CLARO'                    THEN 'CLR'
                             WHEN 'CLARO SAFELINK'           THEN 'CLR'
                             WHEN 'VERIZON PREPAY PLATFORM'  THEN 'VZW'
                             WHEN 'VERIZON'                  THEN 'VZW'
                             WHEN 'VERIZON SAFELINK'         THEN 'VZW'
                             WHEN 'VERIZON WIRELESS'         THEN 'VZW'
                             WHEN 'WIRELESS_NET10'           THEN 'VZW'
                             WHEN 'VERIZON_PPP_SAFELINK'     THEN 'VZW'
                             WHEN 'AT&T SAFELINK'            THEN 'ATT'
                             WHEN 'AT&T WIRELESS'            THEN 'ATT'
                             WHEN 'ATT WIRELESS'             THEN 'ATT'
                             WHEN 'AT&T PREPAY PLATFORM'     THEN 'ATT'
                             WHEN 'AT&T_NET10'               THEN 'ATT'
                             WHEN 'AT&T WIRELESS LL'         THEN 'ATT'
                             WHEN 'DOBSON CELLULAR'          THEN 'ATT'
                             WHEN 'DOBSON GSM'               THEN 'ATT'
                             WHEN 'CINGULAR'                 THEN 'ATT'
                             WHEN 'SPRINT'                   THEN 'SPRINT'
                             WHEN 'SPRINT_NET10'             THEN 'SPRINT'
                             ELSE CASE WHEN v_parent_name like '%TMOBILE%' THEN 'TMO'
                                       WHEN v_parent_name like '%VERIZON%' THEN 'VZW'
                                       WHEN v_parent_name like '%ATT%'     THEN 'ATT'
                                       WHEN v_parent_name like '%SPRINT%'  THEN 'SPRINT'
                                  ELSE i_parent_name
                                  END
                           END;
  --
  RETURN cst.short_parent_name;

EXCEPTION
   WHEN OTHERS  THEN
     --DBMS_OUTPUT.PUT_LINE('ERROR IN GET_SHORT_PARENT_NAME: ' || SQLERRM);
     RETURN NULL;
END get_short_parent_name;
--
-- Function used to get the short description of the parent name based on the logic from the previous get inquiry process
MEMBER FUNCTION get_web_user_attributes RETURN customer_type IS

  cst  customer_type := SELF;
  q    customer_queued_card_type := customer_queued_card_type();
BEGIN
  -- reset response to null
  cst.response := NULL;

  -- validate input parameters
  IF cst.esn IS NULL AND
     cst.min IS NULL
  THEN
    cst.response := 'MIN AND ESN NOT PASSED';
    RETURN cst;
  END IF;

  -- get the esn with the min
  IF cst.esn IS NULL
  THEN
    cst.esn := cst.get_esn ( i_min => cst.min );
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
         AND    sp.install_date = (SELECT MAX(install_date)
                                   FROM   table_site_part
                                   WHERE  x_service_id = sp.x_service_id);
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
         AND    sp.objid = (SELECT MAX(objid)
                            FROM   table_site_part
                            WHERE  x_service_id = sp.x_service_id
                            AND    part_status = 'Active');
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
           wu.web_user2contact,
           wu.user_key
    INTO   cst.web_user_objid,
           cst.web_login_name,
           cst.web_contact_objid,
           cst.web_user_key
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
                wu.web_user2contact,
                wu.user_key
         INTO   cst.web_user_objid,
                cst.web_login_name,
                cst.web_contact_objid,
                cst.web_user_key
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

  -- get the security pin of the esn contact
  BEGIN
    SELECT x_pin
    INTO   cst.contact_security_pin
    FROM   sa.table_x_contact_add_info
    WHERE  add_info2contact = cst.contact_objid;
  EXCEPTION
  WHEN others
  THEN
    cst.contact_security_pin := NULL;
  END;

  -- get the security pin of the web contact
  BEGIN
    SELECT x_pin
    INTO   cst.security_pin
    FROM   sa.table_x_contact_add_info
    WHERE  add_info2contact = cst.web_contact_objid;
  EXCEPTION
  WHEN others
  THEN
    cst.security_pin := NULL;
  END;

  -- Set the response
  cst.response := CASE WHEN (cst.response IS NULL OR cst.response = 'SUCCESS')
                       THEN 'SUCCESS'
                       ELSE (cst.response || '|SUCCESS')
                   END;

  --
  RETURN cst;

EXCEPTION
WHEN OTHERS
THEN
  cst.response := 'ERROR IN GET_WEB_USER_ATTRIBUTES: ' || SQLERRM;
  RETURN cst;
END get_web_user_attributes;

-- Function used to get
MEMBER FUNCTION get_service_plan_name ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS

  cst customer_type := customer_type();

BEGIN

  -- Get the web user and contact (Active site part status)
  BEGIN
    SELECT sp.objid site_part_objid
    INTO   cst.site_part_objid
    FROM   table_site_part sp
    WHERE  1 = 1
    AND    sp.x_service_id = i_esn
    AND    sp.part_status = 'Active';
   EXCEPTION
     WHEN no_data_found THEN
       -- get the zipcode, iccid and site part status for the last updated row in site part
       BEGIN
         SELECT sp.objid site_part_objid
         INTO   cst.site_part_objid
         FROM   table_site_part sp
         WHERE  1 = 1
         AND    sp.x_service_id = i_esn
         AND    sp.install_date = ( SELECT MAX(install_date)
                                    FROM   table_site_part
                                    WHERE  x_service_id = sp.x_service_id
                                  );
        EXCEPTION
          WHEN others THEN
            cst.response := cst.response || '|SITE PART STATUS, ZIPCODE NOT FOUND';
       END;
     WHEN too_many_rows THEN
       -- Get the max objid when there is more than one active site part
       BEGIN
         SELECT sp.objid site_part_objid
         INTO   cst.site_part_objid
         FROM   table_site_part sp
         WHERE  1 = 1
         AND    sp.x_service_id = i_esn
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
  END;

  --
  IF cst.site_part_objid IS NOT NULL THEN
    -- Get the service plan and cos
    BEGIN
      SELECT fea.mkt_name
      INTO   cst.service_plan_name
      FROM   x_service_plan_site_part spsp,
             sa.service_plan_feat_pivot_mv fea
      WHERE  spsp.table_site_part_id = cst.site_part_objid
      AND    spsp.x_service_plan_id = fea.service_plan_objid;
     EXCEPTION
      WHEN OTHERS THEN
        cst.response := cst.response || '|SERVICE PLAN NOT FOUND';
    END;

  END IF;

  RETURN cst.service_plan_name;

EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_service_plan_name;

-- Function used to get
MEMBER FUNCTION get_service_plan_objid ( i_esn IN VARCHAR2 ) RETURN NUMBER IS

  cst customer_type := customer_type();

BEGIN

  -- Get the web user and contact (Active site part status)
  BEGIN
    SELECT sp.objid site_part_objid
    INTO   cst.site_part_objid
    FROM   table_site_part sp
    WHERE  1 = 1
    AND    sp.x_service_id = i_esn
    AND    sp.part_status = 'Active';
   EXCEPTION
     WHEN no_data_found THEN
       -- get the zipcode, iccid and site part status for the last updated row in site part
       BEGIN
         SELECT sp.objid site_part_objid
         INTO   cst.site_part_objid
         FROM   table_site_part sp
         WHERE  1 = 1
         AND    sp.x_service_id = i_esn
         AND    sp.install_date = ( SELECT MAX(install_date)
                                    FROM   table_site_part
                                    WHERE  x_service_id = sp.x_service_id
                                  );
        EXCEPTION
          WHEN others THEN
            cst.response := cst.response || '|SITE PART STATUS, ZIPCODE NOT FOUND';
       END;
     WHEN too_many_rows THEN
       -- Get the max objid when there is more than one active site part
       BEGIN
         SELECT sp.objid site_part_objid
         INTO   cst.site_part_objid
         FROM   table_site_part sp
         WHERE  1 = 1
         AND    sp.x_service_id = i_esn
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
  END;

  --
  IF cst.site_part_objid IS NOT NULL THEN
    -- Get the service plan and cos
    BEGIN
      SELECT fea.service_plan_objid
      INTO   cst.service_plan_objid
      FROM   x_service_plan_site_part spsp,
             sa.service_plan_feat_pivot_mv fea
      WHERE  spsp.table_site_part_id = cst.site_part_objid
      AND    spsp.x_service_plan_id = fea.service_plan_objid;
     EXCEPTION
      WHEN OTHERS THEN
        cst.response := cst.response || '|SERVICE PLAN NOT FOUND';
    END;

  END IF;

  RETURN cst.service_plan_objid;

EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_service_plan_objid;

-- get the sub brand of an esn or min (from the part class of the phone)
MEMBER FUNCTION get_sub_brand RETURN VARCHAR2 IS
c  customer_type := SELF;
BEGIN
  --
  -- either esn or min or web user id needs to be passed
  IF c.esn IS NULL AND
     c.min                IS NULL AND
     c.web_contact_objid  IS NULL
  THEN
    RETURN NULL;
  END IF;
  --
  -- get the esn
  IF c.min IS NOT NULL THEN
    c.esn := c.get_esn ( i_min => c.min );
  END IF;
  --
  IF c.web_contact_objid IS NOT NULL AND c.esn  IS NULL
  THEN
    SELECT  pi.part_serial_no
    INTO    c.esn
    FROM    table_x_contact_part_inst cpi,
            table_part_inst pi
    WHERE   cpi.X_CONTACT_PART_INST2CONTACT     =  c.web_contact_objid
    AND     cpi.X_CONTACT_PART_INST2PART_INST   =  pi.objid
    AND     ROWNUM  = 1;
  END IF;
  --
  -- get all the part class attributes
  c := c.get_part_class_attributes ( i_esn => c.esn );

  -- return acquired value for sub brand
  RETURN c.sub_brand;

EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_sub_brand;

-- Function used to get
MEMBER FUNCTION get_number_of_lines ( i_esn IN VARCHAR2 ) RETURN NUMBER IS

  cst customer_type := customer_type();

BEGIN

  -- Get the web user and contact (Active site part status)
  BEGIN
    SELECT sp.objid site_part_objid
    INTO   cst.site_part_objid
    FROM   table_site_part sp
    WHERE  1 = 1
    AND    sp.x_service_id = i_esn
    AND    sp.part_status = 'Active';
   EXCEPTION
     WHEN no_data_found THEN
       -- get the zipcode, iccid and site part status for the last updated row in site part
       BEGIN
         SELECT sp.objid site_part_objid
         INTO   cst.site_part_objid
         FROM   table_site_part sp
         WHERE  1 = 1
         AND    sp.x_service_id = i_esn
         AND    sp.install_date = ( SELECT MAX(install_date)
                                    FROM   table_site_part
                                    WHERE  x_service_id = sp.x_service_id
                                  );
        EXCEPTION
          WHEN others THEN
            cst.response := cst.response || '|SITE PART STATUS, ZIPCODE NOT FOUND';
       END;
     WHEN too_many_rows THEN
       -- Get the max objid when there is more than one active site part
       BEGIN
         SELECT sp.objid site_part_objid
         INTO   cst.site_part_objid
         FROM   table_site_part sp
         WHERE  1 = 1
         AND    sp.x_service_id = i_esn
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
  END;

  --
  IF cst.site_part_objid IS NOT NULL THEN
    -- Get the service plan and cos
    BEGIN
      SELECT NVL(fea.number_of_lines,1)
      INTO   cst.group_allowed_lines
      FROM   x_service_plan_site_part spsp,
             sa.service_plan_feat_pivot_mv fea
      WHERE  spsp.table_site_part_id = cst.site_part_objid
      AND    spsp.x_service_plan_id = fea.service_plan_objid;
     EXCEPTION
      WHEN OTHERS THEN
        cst.response := cst.response || '|SERVICE PLAN NOT FOUND';
    END;

  END IF;

  --
  RETURN cst.group_allowed_lines;
  --

EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_number_of_lines;

-- Function used to get
MEMBER FUNCTION get_group_available_capacity ( i_esn                 IN VARCHAR2 ,
                                               i_account_group_objid IN NUMBER   ,
                                               i_application_req_num IN VARCHAR2 ) RETURN NUMBER IS

  cst customer_type := customer_type ();

BEGIN

  cst.account_group_objid := i_account_group_objid;
  cst.group_total_lines := 0;

  BEGIN
    SELECT service_plan_id
    INTO   cst.group_service_plan_objid
    FROM   x_account_group
    WHERE  objid = cst.account_group_objid;
   EXCEPTION
     WHEN others THEN
       cst.group_service_plan_objid := NULL;
  END;

  -- Get the number of lines a group
  IF cst.account_group_objid IS NOT NULL THEN
    BEGIN
      -- Get group total active lines
      SELECT COUNT(DISTINCT esn)
      INTO   cst.group_total_lines
      FROM   ( SELECT esn
               FROM   sa.x_account_group_member
               WHERE  account_group_id = cst.account_group_objid
               AND    UPPER(status) <> 'EXPIRED'
             );
     EXCEPTION
       WHEN others THEN
         cst.group_total_lines := 0;
    END;
  END IF;

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
             WHERE  account_group_id = cst.account_group_objid
             AND    lease_status IN ('1001','1002','1005')
           ) a
    WHERE  NOT EXISTS ( SELECT 1
                        FROM   x_account_group_member
                        WHERE  account_group_id = cst.account_group_objid
                        AND    esn = a.esn
                        AND    UPPER(status) <> 'EXPIRED'
                      );
   EXCEPTION
     WHEN others THEN
       cst.lease_blocked_slots := 0;
  END;

  --
  IF cst.group_service_plan_objid IS NOT NULL THEN
    BEGIN
      SELECT NVL(fea.number_of_lines,1)
      INTO   cst.group_allowed_lines
      FROM   sa.service_plan_feat_pivot_mv fea
      WHERE  service_plan_objid = cst.group_service_plan_objid;
     EXCEPTION
       WHEN others THEN
         cst.group_allowed_lines := 0;
    END;
  END IF;

  --
  IF cst.group_allowed_lines > 0 THEN
    cst.group_available_capacity := cst.group_allowed_lines - ( NVL(cst.group_total_lines,0) + NVL(cst.lease_blocked_slots,0) );
    cst.group_available_capacity := GREATEST ( cst.group_available_capacity, 0);
  END IF;

  RETURN cst.group_available_capacity;

END get_group_available_capacity;

MEMBER FUNCTION get_parent_name ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS

  c  customer_type := customer_type ();

BEGIN
  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  -- get the parent name based on ESN
  BEGIN
    SELECT p.x_parent_name parent_name,
           p.x_queue_name
    INTO   c.parent_name,
           c.carrier_name
    FROM   table_part_inst pi_esn,
           table_part_inst pi_min,
           table_x_parent p,
           table_x_carrier_group cg,
           table_x_carrier c
    WHERE  1 = 1
    AND    pi_esn.part_serial_no = i_esn
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst
    AND    pi_min.part_inst2carrier_mkt = c.objid
    AND    c.carrier2carrier_group = cg.objid
    AND    cg.x_carrier_group2x_parent = p.objid;
  EXCEPTION
    WHEN others THEN
      c.parent_name  := NULL;
      c.carrier_name := NULL;
  END;

  --
  RETURN c.parent_name;

EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_parent_name;
--
MEMBER FUNCTION get_esn ( i_min IN VARCHAR2 ) RETURN VARCHAR2 IS
cst customer_type := customer_type();
BEGIN
  cst.min := i_min;

  IF cst.min IS NULL THEN
    RETURN NULL;
  END IF;

  -- get esn
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
            NULL;
       END;
  END;

RETURN cst.esn;

EXCEPTION
  WHEN others THEN
    RETURN NULL;
END get_esn;
--
-- CR46350 Changes starts..
-- Function to get Active ADD ONS threshold value and no of ADD ONs
MEMBER FUNCTION get_add_ons ( i_esn IN VARCHAR2 ) RETURN VARCHAR2
IS
  --
  CURSOR c_add_on_cos
  IS
  SELECT  spp.cos           add_on_offer_id
  FROM    x_account_group_member   agm,
          x_account_group_benefit  agb,
          table_x_red_card         rc,
          sa.service_plan_feat_pivot_mv spp
  WHERE  agm.esn                = i_esn
  AND    agm.account_group_id   = agb.account_group_id
  AND    agb.call_trans_id      = rc.red_card2call_trans
  AND    agb.service_plan_id    = spp.service_plan_objid
  AND    EXISTS ( SELECT 1
                  FROM   table_x_call_trans
                  WHERE  objid = agb.call_trans_id
                  AND    x_service_id = agm.esn)
  AND    SYSDATE BETWEEN agb.start_date AND  NVL(agb.end_date,SYSDATE) -- CR49696 WFM Changes
  AND    EXISTS ( SELECT 1
                  FROM   service_plan_feat_pivot_mv mv
                  WHERE  mv.service_plan_objid = sa.get_service_plan_id(  f_esn      => i_esn,
                                                                          f_red_code => rc.x_red_code)
                  AND    mv.service_plan_group = 'ADD_ON_DATA');
  --
  CURSOR get_threshold_cur ( c_cos_value         x_serviceplanfeaturevalue_def.value_name%TYPE,
                             c_short_parent_name VARCHAR2)
  IS
  SELECT threshold
  FROM   x_policy_mapping_config
  WHERE  cos            =   c_cos_value
  AND    PARENT_NAME    =   c_short_parent_name
  AND    usage_tier_id  =   2
  AND    ROWNUM         =   1;
  --
  c     customer_type := customer_type ();
  l_threshold_value     x_policy_mapping_config.threshold%TYPE;
  --
BEGIN
  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;
  --
  c.no_of_add_ons   :=  0;
  c.short_parent_name  := c.get_short_parent_name (i_esn =>  i_esn);
  --
  FOR each_rec IN c_add_on_cos
  LOOP
    --
    c.no_of_add_ons   :=  c.no_of_add_ons + 1;
    l_threshold_value :=   NULL;
    --
    OPEN get_threshold_cur(each_rec.add_on_offer_id, c.short_parent_name);
    FETCH get_threshold_cur INTO l_threshold_value;
    CLOSE get_threshold_cur;
    --
    c.add_ons_cos :=  NVL(c.add_ons_cos,0) + NVL(l_threshold_value,0);
    --
  END LOOP;
  --
  RETURN  c.add_ons_cos;
  --
EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_add_ons;
-- CR46350 Changes ends.

--CR44729 GO SMART ADDING NEW MEMBER FUNCTION
MEMBER FUNCTION get_migration_flag ( i_esn IN VARCHAR2 ) RETURN VARCHAR2
IS
  c_ret_val VARCHAR2(1);
  cdt       code_table_type := code_table_type ();
BEGIN
-- CHECK IF ESN IS PASSED
  IF i_esn IS NULL THEN
    RETURN 'Y';
  ELSE
    BEGIN
      SELECT cdt.get_migration_flag( i_code_number => x_part_inst_status )
      INTO   c_ret_val
      FROM   table_part_inst
      WHERE  part_serial_no = i_esn
      AND    x_domain       = 'PHONES' ;
    EXCEPTION
     WHEN OTHERS THEN
      RETURN 'Y';
    END;
    RETURN c_ret_val;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
   RETURN 'Y';
END get_migration_flag;


MEMBER FUNCTION get_migration_flag ( i_min IN VARCHAR2 ) RETURN VARCHAR2
IS
  c_ret_val VARCHAR2(1);
  cdt       code_table_type := code_table_type ();
BEGIN
-- CHECK IF MIN IS PASSED
  IF i_min IS NULL THEN
    RETURN 'Y';
  ELSE
    BEGIN
      SELECT cdt.get_migration_flag( i_code_number => x_part_inst_status )
      INTO   c_ret_val
      FROM   table_part_inst
      WHERE  part_serial_no = i_min
      AND    x_domain       = 'LINES' ;
    EXCEPTION
     WHEN OTHERS THEN
      RETURN 'Y';
    END;
    RETURN c_ret_val;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
   RETURN 'Y';
END get_migration_flag;

-- CR44729 GO SMART NEW OVERLOADED FUNCTION
-- Function used to get the contact additional information
MEMBER FUNCTION get_contact_add_info ( i_contact_objid IN NUMBER ) RETURN customer_type IS

  cst  customer_type := customer_type();

BEGIN

  -- Initialize entire cst type with an empty object
  cst := customer_type ();

  cst.contact_objid := i_contact_objid;

  -- Exit when the ESN is not passed
  IF cst.contact_objid IS NULL THEN
    cst.response := 'CONTACT OBJID NOT PASSED';
    RETURN cst;
  END IF;

  -- Get the contact
  BEGIN
    SELECT pi_esn.part_serial_no
    INTO   cst.esn
    FROM   table_part_inst pi_esn
    WHERE  pi_esn.x_part_inst2contact = i_contact_objid
    AND    pi_esn.x_domain = 'PHONES'
    AND    ROWNUM = 1;
   EXCEPTION
     WHEN no_data_found THEN
       cst.response := 'CONTACT NOT FOUND';
       RETURN cst;
     WHEN others THEN
       cst.response := 'UNHANDLED ERROR: ' || SQLERRM;
       RETURN cst;
  END;

  --
  IF cst.contact_objid IS NOT NULL THEN
    BEGIN
      SELECT NVL(x_do_not_email,0),
             NVL(x_do_not_phone,0),
             NVL(x_do_not_sms,0),
             NVL(x_do_not_mail,0),
             x_pin                      -- CR47564
      INTO   cst.do_not_email,
             cst.do_not_phone,
             cst.do_not_sms,
             cst.do_not_mail,
             cst.contact_security_pin   -- CR47564
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

  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  -- Return the type
  RETURN cst;

EXCEPTION
   WHEN OTHERS THEN
     cst.response := 'ERROR RETRIEVING CONTACT ADD INFO: ' || SQLERRM;
     RETURN cst;
     --
END get_contact_add_info;
-- CR47564 changes starts..
-- Member function to return the security pin by contact objid
MEMBER FUNCTION get_contact_security_pin ( i_contact_objid IN NUMBER ) RETURN VARCHAR2 IS

  cst  customer_type := customer_type();
  --
BEGIN
  -- Initialize entire cst type with an empty object
  cst := customer_type ();
  --
  cst.contact_objid := i_contact_objid;
  -- Exit when the ESN is not passed
  IF cst.contact_objid IS NULL THEN
    cst.response := 'CONTACT OBJID NOT PASSED';
    RETURN NULL;
  END IF;
  --
  -- Get the contact
  BEGIN
    SELECT pi_esn.part_serial_no
    INTO   cst.esn
    FROM   table_part_inst pi_esn
    WHERE  pi_esn.x_part_inst2contact = i_contact_objid
    AND    pi_esn.x_domain = 'PHONES'
    AND    ROWNUM = 1;
   EXCEPTION
     WHEN no_data_found THEN
       cst.response := 'CONTACT NOT FOUND';
       RETURN NULL;
     WHEN others THEN
       cst.response := 'UNHANDLED ERROR: ' || SQLERRM;
       RETURN NULL;
  END;
  --
  IF cst.contact_objid IS NOT NULL THEN
    BEGIN
      SELECT x_pin
      INTO   cst.contact_security_pin
      FROM   sa.table_x_contact_add_info
      WHERE  add_info2contact = cst.contact_objid;
    EXCEPTION
      WHEN others THEN
      NULL;
    END;
  END IF;
  --
  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;
  -- Return the type
  RETURN cst.contact_security_pin;

EXCEPTION
   WHEN OTHERS THEN
     cst.response := 'ERROR RETRIEVING CONTACT ADD INFO: ' || SQLERRM;
     RETURN NULL;
     --
END get_contact_security_pin;
--
-- Member function to return the security pin by ESN
MEMBER FUNCTION get_contact_security_pin ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS

  cst  customer_type := customer_type();
  --
BEGIN
  -- Initialize entire cst type with an empty object
  cst := customer_type ();
  --
  cst.esn := i_esn;
  -- Exit when the ESN is not passed
  IF cst.esn IS NULL THEN
    cst.response := 'ESN NOT PASSED';
    RETURN NULL;
  END IF;
  -- Get the contact
  BEGIN
    SELECT pi_esn.x_part_inst2contact
    INTO   cst.contact_objid
    FROM   table_part_inst pi_esn
    WHERE  pi_esn.part_serial_no = cst.esn
    AND    pi_esn.x_domain = 'PHONES';
   EXCEPTION
     WHEN too_many_rows THEN
       cst.response := 'DUPLICATE ESN FOUND';
       RETURN NULL;
     WHEN no_data_found THEN
       cst.response := 'ESN NOT FOUND';
       RETURN NULL;
     WHEN others THEN
       cst.response := 'UNHANDLED ERROR: ' || SQLERRM;
       RETURN NULL;
  END;
  --
  IF cst.contact_objid IS NOT NULL THEN
    BEGIN
      SELECT x_pin
      INTO   cst.contact_security_pin
      FROM   sa.table_x_contact_add_info
      WHERE  add_info2contact = cst.contact_objid;
     EXCEPTION
       WHEN OTHERS THEN
         NULL;
    END;
  END IF;
  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;
  -- Return the type
  RETURN cst.contact_security_pin;
  --
EXCEPTION
   WHEN OTHERS THEN
     cst.response := 'ERROR RETRIEVING CONTACT ADD INFO: ' || SQLERRM;
     RETURN NULL;
     --
END get_contact_security_pin;
-- CR47564 changes ends.
--
MEMBER FUNCTION get_contact_info ( i_esn IN VARCHAR2 ) RETURN customer_type IS

  cst  customer_type := customer_type();

BEGIN

  -- Initialize entire cst type with an empty object
  cst := customer_type ();

  cst.esn := i_esn;

  -- Exit when the ESN is not passed
  IF cst.esn IS NULL THEN
    cst.response := 'CONTACT OBJID NOT PASSED';
    RETURN cst;
  END IF;

  -- Get the basic contact info
  BEGIN
     SELECT
           tc.first_name,
           tc.last_name,
           tc.x_cust_id
      INTO cst.first_name,
           cst.last_name,
           cst.customer_id
      FROM sa.TABLE_CONTACT tc,
           sa.table_x_contact_part_inst cpi,
           sa.table_part_inst pi
     WHERE 1=1
       AND cpi.X_CONTACT_PART_INST2CONTACT = TC.OBJID
       AND cpi.X_CONTACT_PART_INST2PART_INST = PI.OBJID
       AND pi.part_serial_no = cst.esn;
  EXCEPTION
    WHEN no_data_found THEN
      cst.response := 'CONTACT NOT FOUND';
      RETURN cst;
    WHEN others THEN
      cst.response := 'UNHANDLED ERROR: ' || SQLERRM;
      RETURN cst;
  END;

  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  -- Return the type
  RETURN cst;

EXCEPTION
   WHEN OTHERS THEN
     cst.response := 'ERROR RETRIEVING CONTACT ADD INFO: ' || SQLERRM;
     RETURN cst;
     --
END get_contact_info;

MEMBER FUNCTION get_web_user_id ( i_hash_webuserid IN VARCHAR2 ) RETURN NUMBER
IS
  c  customer_type := customer_type ();
BEGIN

   -- Exit when the I_HASH_WEBUSERID is not passed
  IF i_hash_webuserid IS NULL THEN
    c.response := 'HASH_WEBUSERID NOT PASSED';
    RETURN NULL;
  END IF;
  --

  --Retrieve Web_user_objid
    BEGIN
                   SELECT wu.objid
                                INTO c.web_user_objid
                                FROM table_web_user wu
                                WHERE NAMED_USERID = i_hash_webuserid
                                and rownum = 1;
                EXCEPTION
                                WHEN no_data_found THEN
                                   c.response := 'WEBUSER NOT FOUND';
                                   RETURN NULL;
                                WHEN others THEN
                                   c.response := 'UNHANDLED ERROR: ' || SQLERRM;
                                   RETURN NULL;
                  END;

  -- Return web_user_objid
  RETURN c.web_user_objid;

END;

MEMBER FUNCTION get_esn_part_inst_objid (i_esn IN VARCHAR2) RETURN NUMBER
IS

  c  customer_type       := customer_type ();
  l_esn_part_inst_objid   table_part_inst.objid%type;

BEGIN

   -- Exit when the ESN is not passed
  IF i_esn IS NULL THEN
    c.response := 'ESN NOT PASSED';
    RETURN NULL;
  END IF;

    -- Get the esn_part_inst_objid
  BEGIN
    SELECT pi_esn.objid esn_part_inst_objid
    INTO   l_esn_part_inst_objid
    FROM   table_part_inst pi_esn
    WHERE  pi_esn.part_serial_no = i_esn
    AND    pi_esn.x_domain = 'PHONES';
  EXCEPTION
    WHEN others THEN
      NULL;
  END;

  -- Return the esn_part_inst_objid
  RETURN l_esn_part_inst_objid;

END;

MEMBER FUNCTION get_esn_part_inst_status (i_esn IN VARCHAR2) RETURN VARCHAR2
IS

  c  customer_type       := customer_type ();
  l_esn_part_inst_status   table_part_inst.x_part_inst_status%type;

BEGIN

   -- Exit when the ESN is not passed
  IF i_esn IS NULL THEN
     c.response := 'ESN NOT PASSED';
     RETURN NULL;
  END IF;

    -- Get the esn_part_inst_objid
  BEGIN
    SELECT pi_esn.x_part_inst_status
    INTO  l_esn_part_inst_status
    FROM   table_part_inst pi_esn
    WHERE  pi_esn.part_serial_no = i_esn
    AND    pi_esn.x_domain = 'PHONES';
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- Return the esn_part_inst_objid
  RETURN l_esn_part_inst_status;

END;

--CR47564 - added new member function to get the queue card details for esn
MEMBER FUNCTION get_esn_queued_cards (i_esn IN VARCHAR2) RETURN customer_queued_card_tab
IS
  queued_cards            customer_queued_card_tab := customer_queued_card_tab();
  c  customer_type       := customer_type ();
BEGIN

  IF i_esn IS NULL THEN
    RETURN queued_cards;
  END IF;

  --Get the brm notification flag
  c.brm_notification_flag := c.get_brm_notification_flag ( i_esn => i_esn );

  SELECT customer_queued_card_type (pi_card.part_serial_no , -- smp
                                   pi_card.x_ext          , -- ext
                                   (CASE c.brm_notification_flag
                                      WHEN  'Y'
                                      THEN
                                        (SELECT NVL(SUM(NVL(piext.brm_service_days,0)),0)
                                         FROM   x_part_inst_ext piext
                                         WHERE  1 = 1
                                         AND    piext.part_inst_objid = pi_card.objid)
                                      ELSE
                                         NVL(pn.x_redeem_days,0)
                                    END), -- queued_days
                                   pn.part_number         , -- part_number
                                   NULL) -- response
  BULK COLLECT
  INTO   queued_cards
  FROM   table_part_inst pi_esn,
         table_part_inst pi_card,
         table_mod_level ml,
         table_part_num  pn
  WHERE  1 = 1
  AND    pi_esn.part_serial_no = i_esn
  AND    pi_esn.x_domain = 'PHONES'
  AND    pi_card.part_to_esn2part_inst = pi_esn.objid
  AND    pi_card.x_part_inst_status||'' = '400'
  AND    pi_card.x_domain||'' = 'REDEMPTION CARDS'
  AND    pi_card.n_part_inst2part_mod = ml.objid
  AND    ml.part_info2part_num = pn.objid;

  -- Return the queue cards table
  RETURN queued_cards;
EXCEPTION
  WHEN OTHERS
  THEN
    RETURN queued_cards;
END get_esn_queued_cards;

--CR47564 - added new member function to get the queue card details for esn
MEMBER FUNCTION get_esn_pin_redeem_days (i_esn IN VARCHAR2,
                                         i_pin IN VARCHAR2) RETURN NUMBER
IS
  c  customer_type       := customer_type ();
BEGIN
  IF i_esn IS NULL OR
    i_pin IS NULL
  THEN
    RETURN NULL;
  END IF;

  --Get the brm notification flag
  c.brm_notification_flag := c.get_brm_notification_flag ( i_esn => i_esn );

  --Get ESN objid
  c.esn_part_inst_objid := c.get_esn_part_inst_objid ( i_esn => i_esn );

  IF c.brm_notification_flag = 'Y'
  THEN
    SELECT NVL(SUM(NVL(piext.brm_service_days,0)),0)
    INTO   c.queued_days
    FROM   table_part_inst pi,
           x_part_inst_ext piext
    WHERE  1 = 1
    AND    pi.x_red_code = i_pin
    AND    pi.objid = piext.part_inst_objid;
  ELSE
    SELECT  NVL(SUM(NVL(pn.x_redeem_days,0)),0)
    INTO c.queued_days
    FROM --table_x_promotion pr , commented as not fecthing any value
      table_part_num pn ,
      table_mod_level ml ,
      table_part_inst pi
    WHERE 1                     = 1
    AND pn.objid                = ml.part_info2part_num
    AND ml.objid                = pi.n_part_inst2part_mod
    AND pi.x_red_code           = i_pin
    AND (pi.x_part_inst_status IN ('42' ,'280')
    OR (pi.x_part_inst_status  IN ('40' ,'43')
    AND c.esn_part_inst_objid             = pi.part_to_esn2part_inst)
    OR (pi.x_part_inst_status IN ('400')
    AND c.esn_part_inst_objid            = pi.part_to_esn2part_inst)
      );
    --AND pn.part_num2x_promotion = pr.objid(+); commented as not fecthing any value
  END IF;

  RETURN c.queued_days;

EXCEPTION
  WHEN OTHERS
  THEN
    c.queued_days := 0;
   RETURN c.queued_days;
END get_esn_pin_redeem_days;

--CR47564 - added new member function to get the queue card details for esn
MEMBER FUNCTION get_service_plan_days (i_esn IN VARCHAR2,
                                       i_pin IN VARCHAR2,
                                       i_service_plan_objid IN NUMBER DEFAULT NULL) RETURN VARCHAR2
IS
  c  customer_type       := customer_type ();
BEGIN

  IF i_esn IS NULL OR i_pin IS NULL THEN
    RETURN NULL;
  END IF;

  c.service_plan_days := get_service_plan_days_name (i_esn => i_esn,
                                                     i_pin => i_pin,
                                                     i_service_plan_objid => i_service_plan_objid);

  --Remove the days string from service plan days
  c.service_plan_days := TRIM(regexp_replace(NVL(c.service_plan_days,0),'[[:alpha:]]','') );

  RETURN c.service_plan_days;
EXCEPTION
  WHEN OTHERS
  THEN
    c.service_plan_days := '0';
    RETURN c.service_plan_days;
END get_service_plan_days;
--
--CR47564 - added new member function to get the queue card details for esn
MEMBER FUNCTION get_service_plan_days_name (i_esn IN VARCHAR2,
                                            i_pin IN VARCHAR2,
                                            i_service_plan_objid IN NUMBER DEFAULT NULL) RETURN VARCHAR2
IS
  c  customer_type       := customer_type ();
BEGIN

  IF i_esn IS NULL OR i_pin IS NULL THEN
    RETURN NULL;
  END IF;

  IF i_service_plan_objid IS NOT NULL THEN
    c.service_plan_objid := i_service_plan_objid;
  ELSE
    c.service_plan_objid := c.get_service_plan_objid (i_esn => i_esn);
  END IF;

  --Get the brm notification flag
  c.brm_notification_flag := c.get_brm_notification_flag ( i_esn => i_esn );

  IF c.brm_notification_flag = 'Y' THEN
    SELECT TO_CHAR(NVL(SUM(NVL(piext.brm_service_days,0)),0)) || ' Days'
    INTO   c.service_plan_days
    FROM   table_part_inst pi,
           x_part_inst_ext piext
    WHERE  1 = 1
    AND    pi.x_red_code = i_pin
    AND    pi.objid = piext.part_inst_objid;
  ELSE
    SELECT DISTINCT spfvdef2.display_name property_name
    INTO   c.service_plan_days
    FROM   x_serviceplanfeaturevalue_def spfvdef1,
           x_serviceplanfeature_value aspfv,
           x_service_plan_feature aspf,
           x_serviceplanfeaturevalue_def spfvdef2,
           x_service_plan asp
    WHERE  1 = 1
    AND    aspf.sp_feature2service_plan = asp.objid
    AND    aspf.sp_feature2rest_value_def = spfvdef1.objid
    AND    aspf.objid                     = aspfv.spf_value2spf
    AND    spfvdef2.objid                 = aspfv.value_ref
    AND    spfvdef1.value_name           IN ('SERVICE DAYS')
    AND    asp.objid = c.service_plan_objid;
  END IF;

  RETURN c.service_plan_days;

EXCEPTION
  WHEN OTHERS
  THEN
    c.service_plan_days := '0 Days';
    RETURN c.service_plan_days;
END get_service_plan_days_name;

-- CR49087 function to get details of active add on of the esn
MEMBER FUNCTION get_add_on_details  (i_esn  IN  VARCHAR2) RETURN  add_on_data_details_tab
IS
--
  cst                   customer_type             :=    customer_type();
  add_on_data_details   add_on_data_details_tab   :=    add_on_data_details_tab();
--
BEGIN
--
  cst.esn     :=  i_esn;
  --
  SELECT  add_on_data_details_type (spp.service_plan_objid,
                                    rc.x_red_code,
                                    spp.data_bucket_name,
                                    spp.data_bucket_value,
                                    agb.start_date,
                                    agb.end_date)
  BULK COLLECT
  INTO    add_on_data_details
  FROM    x_account_group_member   agm,
          x_account_group_benefit  agb,
          table_x_red_card         rc,
          sa.service_plan_feat_pivot_mv spp
  WHERE  agm.esn                = cst.esn
  AND    agm.account_group_id   = agb.account_group_id
  AND    agb.call_trans_id      = rc.red_card2call_trans
  AND    agb.service_plan_id    = spp.service_plan_objid
  AND    EXISTS ( SELECT 1
                  FROM   table_x_call_trans
                  WHERE  objid = agb.call_trans_id
                  AND    x_service_id = agm.esn)
  AND    SYSDATE BETWEEN agb.start_date AND  NVL(agb.end_date,SYSDATE)
  AND    EXISTS ( SELECT 1
                  FROM   service_plan_feat_pivot_mv mv
                  WHERE  mv.service_plan_objid = sa.get_service_plan_id ( f_esn      => cst.esn,
                                                                          f_red_code => rc.x_red_code)
                  AND    mv.service_plan_group = 'ADD_ON_DATA');
  --
  -- return add on details table
  RETURN add_on_data_details;
--
EXCEPTION
  WHEN OTHERS THEN
    RETURN add_on_data_details;
END get_add_on_details;
--
MEMBER FUNCTION get_pin_redeem_days (i_pin IN VARCHAR2) RETURN NUMBER IS

  c sa.customer_type := sa.customer_type();

BEGIN

  BEGIN
    SELECT c.get_brm_notification_flag ( i_bus_org_objid => a.bus_org_objid )
    INTO   c.brm_notification_flag
    FROM   ( -- get from part inst
             SELECT bo.objid bus_org_objid
             FROM   table_part_inst pi,
                    table_mod_level ml,
                    table_part_num pn,
                    table_bus_org bo
             WHERE  1 = 1
             AND    pi.x_red_code = i_pin
             AND    pi.x_domain = 'REDEMPTION CARDS'
             AND    pi.n_part_inst2part_mod = ml.objid
             AND    ml.part_info2part_num = pn.objid
             AND    pn.domain = 'REDEMPTION CARDS'
             AND    pn.part_num2bus_org = bo.objid
             -- get from red card
             UNION
             SELECT bo.objid bus_org_objid
             FROM   table_x_red_card rc ,
                    table_mod_level ml ,
                    table_part_num pn ,
                    table_bus_org bo
             WHERE  rc.x_red_code = i_pin
             AND    pn.domain = 'REDEMPTION CARDS'
             AND    ml.objid = rc.x_red_card2part_mod
             AND    ml.part_info2part_num = pn.objid
             AND    pn.part_num2bus_org   = bo.objid
           ) a;
   EXCEPTION
     WHEN others THEN
       c.brm_notification_flag := 'N';
  END;

  DBMS_OUTPUT.PUT_LINE('c.brm_notification_flag : '|| c.brm_notification_flag);

  --
  IF c.brm_notification_flag = 'Y' THEN
    BEGIN
      SELECT NVL(SUM(NVL(piext.brm_service_days,0)),0)
      INTO   c.queued_days
      FROM   table_part_inst pi,
             x_part_inst_ext piext
      WHERE  1 = 1
      AND    pi.x_red_code = i_pin
      AND    pi.objid = piext.part_inst_objid
      AND    pi.x_domain = 'REDEMPTION CARDS';
    EXCEPTION
      WHEN others THEN
        NULL;
    END;
  ELSE
    BEGIN
      SELECT NVL(SUM(NVL(pn.x_redeem_days,0)),0)
      INTO   c.queued_days
      FROM   table_part_num pn,
             table_mod_level ml,
             table_part_inst pi
      WHERE  1 = 1
      AND    pi.x_red_code = i_pin
      AND    ml.objid = pi.n_part_inst2part_mod
      AND    pn.objid = ml.part_info2part_num
      AND    ( pi.x_part_inst_status IN ('42','280')  -- NOT REDEEMED
               OR
               ( pi.x_part_inst_status  IN ('40','43') AND -- RESERVED, REDEMPTION PENDING
                 c.esn_part_inst_objid = pi.part_to_esn2part_inst )
               OR
               ( pi.x_part_inst_status IN ('400') AND -- RESERVED QUEUED
                 c.esn_part_inst_objid = pi.part_to_esn2part_inst )
             );
    EXCEPTION
      WHEN others THEN
        NULL;
    END;
  END IF;

  --
  RETURN c.queued_days;

 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_pin_redeem_days;
--
-- Member Function takes org_id as input and returns bus org attributes.
MEMBER FUNCTION get_bus_org_attributes (i_bus_org_id IN VARCHAR2) RETURN customer_type IS

  cst  customer_type       :=  SELF;

BEGIN
     -- Initialize entire cst type with an empty object
    cst := customer_type ();

    cst.bus_org_id := i_bus_org_id;

    IF i_bus_org_id IS NULL THEN
      cst.response := 'BUS ORG ID  NOT PASSED';
      RETURN cst;
    END IF;

    cst.bus_org_objid := cst.get_bus_org_objid;

    cst := cst.get_bus_org_attributes (i_bus_org_objid => cst.bus_org_objid);

    cst.response:='SUCCESS';

    RETURN cst;

EXCEPTION
  WHEN OTHERS THEN
    cst.response := 'ERROR RETRIEVING BUS ORG ATTRIBUTES: ' || SQLERRM;
    RETURN cst;
END get_bus_org_attributes;
--
-- Member Function takes ESN as input and returns bus org attributes.
MEMBER FUNCTION get_bus_org_attributes (i_esn IN VARCHAR2) RETURN customer_type IS

  cst  customer_type :=  SELF;

BEGIN
     -- Initialize entire cst type with an empty object
    cst := customer_type ();

    cst.esn := i_esn;

    IF i_esn IS NULL THEN
      cst.response := 'ESN NOT PASSED';
      RETURN cst;
    END IF;

    cst.bus_org_objid := cst.get_bus_org_objid ( i_esn => i_esn );

    cst := cst.get_bus_org_attributes (i_bus_org_objid => cst.bus_org_objid);

    cst.response:='SUCCESS';

    RETURN cst;

EXCEPTION
  WHEN OTHERS THEN
    cst.response := 'ERROR RETRIEVING BUS ORG ATTRIBUTES: ' || SQLERRM;
    RETURN cst;
END get_bus_org_attributes;
--
-- Member Function takes objid as input and returns bus org attributes.
MEMBER FUNCTION get_bus_org_attributes (i_bus_org_objid IN NUMBER) RETURN customer_type IS

  cst  customer_type       :=  SELF;

BEGIN
    -- Initialize entire cst type with an empty object
    cst := customer_type ();

    cst.bus_org_objid := i_bus_org_objid;

    IF i_bus_org_objid IS NULL THEN
      cst.response := 'BUS ORG OBJID  NOT PASSED';
      RETURN cst;
    END IF;

    SELECT NVL(bo.multiline_discount_flag,'N'),
           NVL(bo.brm_notification_flag,'N'),
           NVL(bo.brm_applicable_flag,'N'),
           NVL(bo.shared_group_flag,'N'),
           bo.objid
    INTO   cst.multiline_discount_flag,
           cst.brm_notification_flag,
           cst.brm_applicable_flag,
           cst.brand_shared_group_flag,
           cst.bus_org_objid
    FROM   table_bus_org bo
    WHERE  bo.objid = cst.bus_org_objid;

    cst.response := 'SUCCESS';

    RETURN cst;

EXCEPTION
  WHEN OTHERS THEN
    cst.response := 'ERROR RETRIEVING BUS ORG ATTRIBUTES: ' || SQLERRM;
    RETURN cst;
END get_bus_org_attributes;
--
MEMBER FUNCTION get_part_class (i_part_num IN VARCHAR2) RETURN VARCHAR2 IS

  c_part_class VARCHAR2(40);

BEGIN

  IF (i_part_num IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT pc.name
    INTO c_part_class
    FROM table_part_num pn,
         table_part_class pc
   WHERE 1 = 1
     AND pn.part_number = i_part_num  --input
     AND pc.objid = pn.part_num2part_class;

  RETURN c_part_class;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_part_class;
--
-- CR48260  retrieve multiline discount flag for any Brand
MEMBER FUNCTION get_multiline_discount_flag (i_bus_org_id IN VARCHAR2) RETURN VARCHAR2 IS

  c customer_type:=customer_type();

BEGIN

  IF (i_bus_org_id IS NULL) THEN
    RETURN 'N';
  END IF;

  SELECT NVL(multiline_discount_flag,'N')
    INTO c.multiline_discount_flag
    FROM table_bus_org
   WHERE org_id = i_bus_org_id;

  RETURN c.multiline_discount_flag;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_multiline_discount_flag;

-- Function used to get the carrier related attributes based on ESN
MEMBER FUNCTION get_carrier_attributes RETURN customer_type IS

  cst customer_type := SELF;
  c   customer_type := customer_type ();

BEGIN

  -- validate input parameters
  IF cst.esn IS NULL AND cst.min IS NULL THEN
    cst.response := 'MIN OR ESN MUST BE PASSED';
    RETURN cst;
  END IF;

  -- get the esn with the min
  IF cst.esn IS NULL THEN
    cst.esn := cst.get_esn ( i_min => cst.min );
  END IF;

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
    FROM   sa.table_part_inst pi_esn,
           sa.table_part_inst pi_min
    WHERE  pi_min.x_domain = 'LINES'
    AND    pi_min.part_to_esn2part_inst = pi_esn.objid
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_esn.part_serial_no = cst.esn;
  EXCEPTION
    WHEN too_many_rows THEN
      cst.response := 'DUPLICATE ESN FOUND';
    WHEN no_data_found THEN
      cst.response := 'ESN NOT FOUND';
      RETURN cst;
    WHEN others THEN
      cst.response := 'UNHANDLED ERROR: ' || SQLERRM;
      RETURN cst;
  END;

  -- get the rate plan
  cst.rate_plan := c.get_rate_plan ( i_esn => cst.esn );

  -- Get carrier parent name
  IF cst.carrier_objid IS NOT NULL THEN
    BEGIN
      SELECT p.x_parent_name parent_name,
             p.x_parent_id,
             p.objid,
             p.x_queue_name
      INTO   cst.parent_name,
             cst.parent_id,
             cst.parent_objid,
             cst.carrier_name
      FROM   sa.table_x_carrier c,
             sa.table_x_carrier_group cg,
             sa.table_x_parent p
      WHERE  p.objid  = cg.x_carrier_group2x_parent
      AND    cg.objid = c.carrier2carrier_group
      AND    c.objid  = cst.carrier_objid;
    EXCEPTION
      WHEN others THEN
        cst.response := cst.response || '|CARRIER PARENT NAME NOT FOUND';
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
           sp.install_date,
           sp.warranty_date
    INTO   cst.zipcode,
           cst.site_part_objid,
           cst.site_part_status,
           cst.iccid,
           cst.min,
           cst.install_date,
           cst.warranty_date
    FROM   sa.table_site_part sp
    WHERE  sp.part_status = 'Active'
    AND    sp.x_service_id = cst.esn;
  EXCEPTION
    WHEN no_data_found THEN
      -- get the zipcode, iccid and site part status for the last updated row in site part
      BEGIN
        SELECT sp.x_zipcode zipcode,
               sp.objid site_part_objid,
               sp.part_status,
               sp.x_iccid,
               NVL2(cst.min, cst.min, sp.x_min) min,
               sp.warranty_date
        INTO   cst.zipcode,
               cst.site_part_objid,
               cst.site_part_status,
               cst.iccid,
               cst.min,
               cst.warranty_date
        FROM   sa.table_site_part sp
        WHERE  sp.install_date = (SELECT MAX(install_date)
                                  FROM   sa.table_site_part
                                  WHERE  x_service_id = sp.x_service_id)
        AND    sp.x_service_id = cst.esn;
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
               sp.install_date,
               sp.warranty_date
        INTO   cst.zipcode,
               cst.site_part_objid,
               cst.site_part_status,
               cst.iccid,
               cst.min,
               cst.install_date,
               cst.warranty_date
        FROM   sa.table_site_part sp
        WHERE  sp.objid = (SELECT MAX(objid)
                           FROM   sa.table_site_part
                           WHERE  part_status = 'Active'
                           AND    x_service_id = sp.x_service_id)
        AND    sp.part_status = 'Active'
        AND    sp.x_service_id = cst.esn;
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
           cst.motricity_deno,
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
    FROM   sa.table_part_inst pi,
           sa.table_mod_level ml,
           sa.table_part_num pn,
           sa.pcpv_mv pcpv
    WHERE  pcpv.pc_objid = pn.part_num2part_class
    AND    pn.domain = 'PHONES'
    AND    pn.objid = ml.part_info2part_num
    AND    ml.objid = pi.n_part_inst2part_mod
    AND    pi.x_domain = 'PHONES'
    AND    pi.part_serial_no = cst.esn;
  EXCEPTION
    WHEN others THEN
      cst.response := cst.response || '|PART NUMBER, PART CLASS NOT FOUND';
  END;

  -- Set successful response
  cst.response := CASE WHEN cst.response IS NULL THEN 'SUCCESS' ELSE (cst.response || '|SUCCESS') END;

  -- Return the type
  RETURN cst;

EXCEPTION
  WHEN OTHERS THEN
    cst.response := 'ERROR RETRIEVING CARRIER ATTRIBUTES: ' || SQLERRM;
    RETURN cst;
END get_carrier_attributes;

-- Function used to get the carrier name of the parent name based on the provided esn
MEMBER FUNCTION get_carrier_name ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS
  cst  customer_type := customer_type();
BEGIN
  --
  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  --
  BEGIN
    SELECT p.x_queue_name carrier_name
    INTO   cst.carrier_name
    FROM   sa.table_part_inst pi_esn,
           sa.table_part_inst pi_min,
           sa.table_x_parent p,
           sa.table_x_carrier_group cg,
           sa.table_x_carrier c
    WHERE  p.objid = cg.x_carrier_group2x_parent
    AND    cg.objid = c.carrier2carrier_group
    AND    c.objid = pi_min.part_inst2carrier_mkt
    AND    pi_min.part_to_esn2part_inst = pi_esn.objid
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_esn.part_serial_no = i_esn;
  EXCEPTION
    WHEN others THEN
      cst.carrier_name := NULL;
  END;

  --
  RETURN cst.carrier_name;

EXCEPTION
   WHEN OTHERS  THEN
     RETURN NULL;
END get_carrier_name;
--
END;
-- ANTHILL_TEST PLSQL/SA/Schema/customer_type.sql     CR52152: 1.167
/