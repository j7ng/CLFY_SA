CREATE OR REPLACE TYPE sa.spr_transaction_log_type IS OBJECT
(
  spr_transaction_log_objid    NUMBER(22)     ,
  esn                          VARCHAR2(30)   ,
  min                          VARCHAR2(30)   ,
  subscriber_id                VARCHAR2(50)   ,
  group_id                     VARCHAR2(50)   ,
  pcrf_transaction_id          NUMBER(22)     ,
  program_step                 VARCHAR2(100)  ,
  program_name                 VARCHAR2(500)  ,
  message                      VARCHAR2(1000) ,
  response_code                NUMBER(3)      ,
  response_message             VARCHAR2(1000) ,
  sourcesystem                 VARCHAR2(30)   ,
  offer_id                     VARCHAR2(50)   ,
  throttle_source              VARCHAR2(50)   ,
  parent_name                  VARCHAR2(40)   ,
  usage_tier_id                NUMBER(2)      ,
  cos                          VARCHAR2(30)   ,
  policy_name                  VARCHAR2(30)   ,
  entitlement                  VARCHAR2(30)   ,
  threshold_reached_time       DATE           ,
  status                       VARCHAR2(1000) ,
  last_redemption_date         DATE           ,
  CONSTRUCTOR FUNCTION spr_transaction_log_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION spr_transaction_log_type ( i_spr_transaction_log_objid IN  NUMBER   DEFAULT NULL,
                                                  i_esn                       IN  VARCHAR2 DEFAULT NULL,
                                                  i_min                       IN  VARCHAR2 DEFAULT NULL,
                                                  i_subscriber_id             IN  VARCHAR2 DEFAULT NULL,
                                                  i_group_id                  IN  VARCHAR2 DEFAULT NULL,
                                                  i_pcrf_transaction_id       IN  NUMBER   DEFAULT NULL,
                                                  i_program_step              IN  VARCHAR2 DEFAULT NULL,
                                                  i_program_name              IN  VARCHAR2 DEFAULT NULL,
                                                  i_message                   IN  VARCHAR2 DEFAULT NULL,
                                                  i_response_code             IN  NUMBER   DEFAULT NULL,
                                                  i_response_message          IN  VARCHAR2 DEFAULT NULL,
                                                  i_sourcesystem              IN  VARCHAR2 DEFAULT NULL,
                                                  i_offer_id                  IN  VARCHAR2 DEFAULT NULL,
                                                  i_throttle_source           IN  VARCHAR2 DEFAULT NULL,
                                                  i_parent_name               IN  VARCHAR2 DEFAULT NULL,
                                                  i_usage_tier_id             IN  NUMBER   DEFAULT NULL,
                                                  i_cos                       IN  VARCHAR2 DEFAULT NULL,
                                                  i_policy_name               IN  VARCHAR2 DEFAULT NULL,
                                                  i_entitlement               IN  VARCHAR2 DEFAULT NULL,
                                                  i_threshold_reached_time    IN  DATE     DEFAULT NULL,
                                                  i_last_redemption_date      IN  DATE     DEFAULT NULL) RETURN SELF AS RESULT,

  MEMBER FUNCTION ins ( o_result OUT VARCHAR2 ) RETURN NUMBER,
  MEMBER FUNCTION upd ( i_spr_transaction_log_objid IN NUMBER, o_result OUT VARCHAR2 ) RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY sa.spr_transaction_log_type AS

CONSTRUCTOR FUNCTION spr_transaction_log_type RETURN SELF AS RESULT AS
BEGIN
  --
  RETURN;
END spr_transaction_log_type;

CONSTRUCTOR FUNCTION spr_transaction_log_type (i_spr_transaction_log_objid IN  NUMBER   DEFAULT NULL,
                                               i_esn                       IN  VARCHAR2 DEFAULT NULL,
                                               i_min                       IN  VARCHAR2 DEFAULT NULL,
                                               i_subscriber_id             IN  VARCHAR2 DEFAULT NULL,
                                               i_group_id                  IN  VARCHAR2 DEFAULT NULL,
                                               i_pcrf_transaction_id       IN  NUMBER   DEFAULT NULL,
                                               i_program_step              IN  VARCHAR2 DEFAULT NULL,
                                               i_program_name              IN  VARCHAR2 DEFAULT NULL,
                                               i_message                   IN  VARCHAR2 DEFAULT NULL,
                                               i_response_code             IN  NUMBER   DEFAULT NULL,
                                               i_response_message          IN  VARCHAR2 DEFAULT NULL,
                                               i_sourcesystem              IN  VARCHAR2 DEFAULT NULL,
                                               i_offer_id                  IN  VARCHAR2 DEFAULT NULL,
                                               i_throttle_source           IN  VARCHAR2 DEFAULT NULL,
                                               i_parent_name               IN  VARCHAR2 DEFAULT NULL,
                                               i_usage_tier_id             IN  NUMBER   DEFAULT NULL,
                                               i_cos                       IN  VARCHAR2 DEFAULT NULL,
                                               i_policy_name               IN  VARCHAR2 DEFAULT NULL,
                                               i_entitlement               IN  VARCHAR2 DEFAULT NULL,
                                               i_threshold_reached_time    IN  DATE     DEFAULT NULL,
                                               i_last_redemption_date      IN  DATE     DEFAULT NULL  ) RETURN SELF AS RESULT AS
BEGIN


  SELF.spr_transaction_log_objid := i_spr_transaction_log_objid;
  SELF.esn                       := i_esn                      ;
  SELF.min                       := i_min                      ;
  SELF.subscriber_id             := i_subscriber_id            ;
  SELF.group_id                  := i_group_id                 ;
  SELF.pcrf_transaction_id       := i_pcrf_transaction_id      ;
  SELF.program_step              := i_program_step             ;
  SELF.program_name              := i_program_name             ;
  SELF.message                   := i_message                  ;
  SELF.response_code             := i_response_code            ;
  SELF.response_message          := i_response_message         ;
  SELF.sourcesystem              := i_sourcesystem             ;
  SELF.offer_id                  := i_offer_id                 ;
  SELF.throttle_source           := NVL(i_throttle_source, SELF.throttle_source);
  SELF.parent_name               := NVL(i_parent_name, SELF.parent_name);
  SELF.usage_tier_id             := NVL(i_usage_tier_id, SELF.usage_tier_id);
  SELF.cos                       := NVL(i_cos, SELF.cos);
  SELF.policy_name               := NVL(i_policy_name, SELF.policy_name);
  SELF.entitlement               := NVL(i_entitlement, SELF.entitlement);
  SELF.threshold_reached_time    := NVL(i_threshold_reached_time, SELF.threshold_reached_time);
  SELF.last_redemption_date      := i_last_redemption_date;
  --
  RETURN;
END spr_transaction_log_type;

MEMBER FUNCTION ins ( o_result OUT VARCHAR2) RETURN NUMBER AS

  log spr_transaction_log_type := SELF;
  -- Declare block as an autonomous transaction
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_spr_transaction_log_objid NUMBER;
BEGIN
  -- Insert log message
  INSERT
  INTO x_spr_transaction_log
       ( objid                   ,
         esn                     ,
         min                     ,
         subscriber_id           ,
         group_id                ,
         program_step            ,
         program_name            ,
         message                 ,
         sourcesystem            ,
         response_code           ,
         response_message        ,
         pcrf_transaction_id     ,
         throttle_source         ,
         parent_name             ,
         usage_tier_id           ,
         cos                     ,
         policy_name             ,
         entitlement             ,
         threshold_reached_time  ,
         last_redemption_date
       )
  VALUES
  ( sequ_spr_transaction_log.NEXTVAL,
    SELF.esn,
    SELF.min ,
    SELF.subscriber_id,
    SELF.group_id,
    SELF.program_step,
    SELF.program_name,
    SELF.message,
    SELF.sourcesystem,
    SELF.response_code,
    SELF.response_message,
    SELF.pcrf_transaction_id,
    SELF.throttle_source         ,
    SELF.parent_name             ,
    SELF.usage_tier_id           ,
    SELF.cos                     ,
    SELF.policy_name             ,
    SELF.entitlement             ,
    SELF.threshold_reached_time  ,
    SELF.last_redemption_date
  )
  RETURN objid
  INTO   l_spr_transaction_log_objid;

  -- Save changes
  COMMIT;
  log.status := 'SUCCESS';
  o_result := 'SUCCESS';
  RETURN l_spr_transaction_log_objid;
 EXCEPTION WHEN OTHERS THEN
   ROLLBACK;
   -- Do not fail whenever an error occurs
   log.status := 'ERROR INSERTING TRANSACTION LOG '|| SUBSTR(SQLERRM,1,100);
   o_result := log.status;
   RETURN(0);
END ins;

MEMBER FUNCTION upd ( i_spr_transaction_log_objid IN NUMBER, o_result OUT VARCHAR2 ) RETURN NUMBER IS

  log spr_transaction_log_type := SELF;
  -- Declare block as an autonomous transaction
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  --
  IF i_spr_transaction_log_objid IS NULL THEN
    log.status := 'TRANSACTION LOG ID IS A REQUIRED INPUT PARAM';
    o_result := 'TRANSACTION LOG ID IS A REQUIRED INPUT PARAM';
    RETURN(0);
  END IF;

  -- Update log message
  UPDATE x_spr_transaction_log
  SET    esn                    = NVL(SELF.esn,esn)                                 ,
         min                    = NVL(SELF.min,min)                                 ,
         subscriber_id          = NVL(SELF.subscriber_id,subscriber_id)             ,
         group_id               = NVL(SELF.group_id,group_id)                       ,
         program_step           = NVL(SELF.program_step,program_step)               ,
         program_name           = NVL(SELF.program_name,program_name)               ,
         message                = NVL(SELF.message,message)                         ,
         sourcesystem           = NVL(SELF.sourcesystem,sourcesystem)               ,
         response_code          = NVL(SELF.response_code,response_code)             ,
         response_message       = NVL(SELF.response_message,response_message)       ,
         pcrf_transaction_id    = NVL(SELF.pcrf_transaction_id,pcrf_transaction_id) ,
         throttle_source        = NVL(SELF.throttle_source, throttle_source)        ,
         parent_name            = NVL(SELF.parent_name, parent_name)                ,
         usage_tier_id          = NVL(SELF.usage_tier_id, usage_tier_id)            ,
         cos                    = NVL(SELF.cos, cos)                                ,
         policy_name            = NVL(SELF.policy_name, policy_name)                ,
         entitlement            = NVL(SELF.entitlement, entitlement)                ,
         threshold_reached_time	= NVL(SELF.threshold_reached_time, threshold_reached_time) ,
         last_redemption_date   = NVL(SELF.last_redemption_date, last_redemption_date)
  WHERE  objid = i_spr_transaction_log_objid;

  -- Save changes
  COMMIT;
  log.status := 'SUCCESS';
  o_result := 'SUCCESS';
  RETURN i_spr_transaction_log_objid;
 EXCEPTION WHEN OTHERS THEN
   ROLLBACK;
   -- Do not fail whenever an error occurs
   log.status := 'ERROR UPDATING TRANSACTION LOG '|| SUBSTR(SQLERRM,1,100);
   o_result := log.status;
   RETURN(0);
END upd;

END;
/