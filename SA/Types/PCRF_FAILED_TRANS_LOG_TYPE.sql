CREATE OR REPLACE TYPE sa."PCRF_FAILED_TRANS_LOG_TYPE" AS OBJECT
(
  objid                        NUMBER(22)             ,
  pcrf_transaction_id          NUMBER(22)             ,
  order_type                   VARCHAR2(30)           ,
  min                          VARCHAR2(30)           ,
  esn                          VARCHAR2(30)           ,
  rate_plan                    VARCHAR2(60)           ,
  template                     VARCHAR2(30)           ,
  status_message               VARCHAR2(1000)         ,
  insert_timestamp             DATE                   ,
  update_timestamp             DATE                   ,
  mdn                          VARCHAR2(30)           ,
  subscriber_id                VARCHAR2(50)           ,
  group_id                     VARCHAR2(50)           ,
  phone_manufacturer           VARCHAR2(30)           ,
  action_type                  VARCHAR2(1)            ,
  sim                          VARCHAR2(30)           ,
  zipcode                      VARCHAR2(10)           ,
  service_plan_id              NUMBER(22)             ,
  case_id                      NUMBER(22)             ,
  pcrf_status_code             VARCHAR2(2)            ,
  web_objid                    NUMBER(22)             ,
  bus_org_id                   VARCHAR2(40)           ,
  sourcesystem                 VARCHAR2(30)           ,
  blackout_wait_date           DATE                   ,
  retry_count                  NUMBER(10)             ,
  data_usage                   NUMBER(20,2)           ,
  hi_speed_data_usage          NUMBER(20,2)           ,
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
  response                     VARCHAR2(1000)         ,
  numeric_value                NUMBER                 ,
  varchar2_value               VARCHAR2(2000)         ,
  CONSTRUCTOR FUNCTION pcrf_failed_trans_log_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION pcrf_failed_trans_log_type ( i_pcrf_transaction_id IN NUMBER ) RETURN SELF AS RESULT,
  MEMBER FUNCTION ins RETURN pcrf_failed_trans_log_type,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION exist ( i_pcrf_transaction_id IN NUMBER) RETURN BOOLEAN,
  MEMBER FUNCTION del ( i_pcrf_transaction_id IN NUMBER) RETURN BOOLEAN,
  MEMBER FUNCTION upd RETURN pcrf_failed_trans_log_type
);
/
CREATE OR REPLACE TYPE BODY sa."PCRF_FAILED_TRANS_LOG_TYPE" IS
CONSTRUCTOR FUNCTION pcrf_failed_trans_log_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

CONSTRUCTOR FUNCTION pcrf_failed_trans_log_type ( i_pcrf_transaction_id IN NUMBER ) RETURN SELF AS RESULT AS

BEGIN
  --
  IF i_pcrf_transaction_id IS NULL THEN
    --
    SELF.response := 'PCRF TRANSACTION ID IS NULL';
    RETURN;
  END IF;

  --
  SELECT pcrf_failed_trans_log_type ( objid                    ,
                                      pcrf_transaction_id      ,
                                      order_type               ,
                                      min                      ,
                                      esn                      ,
                                      rate_plan                ,
                                      template                 ,
                                      status_message           ,
                                      insert_timestamp         ,
                                      update_timestamp         ,
                                      mdn                      ,
                                      subscriber_id            ,
                                      group_id                 ,
                                      phone_manufacturer       ,
                                      action_type              ,
                                      sim                      ,
                                      zipcode                  ,
                                      service_plan_id          ,
                                      case_id                  ,
                                      pcrf_status_code         ,
                                      web_objid                ,
                                      bus_org_id               ,
                                      sourcesystem             ,
                                      blackout_wait_date       ,
                                      retry_count              ,
                                      data_usage               ,
                                      hi_speed_data_usage      ,
                                      conversion_factor        ,
                                      dealer_id                ,
                                      denomination             ,
                                      pcrf_parent_name         ,
                                      propagate_flag           ,
                                      service_plan_type        ,
                                      part_inst_status         ,
                                      phone_model              ,
                                      content_delivery_format  ,
                                      language                 ,
                                      wf_mac_id                ,
                                      pcrf_cos                 ,
                                      ttl                      ,
                                      future_ttl               ,
                                      redemption_date          ,
                                      contact_objid            ,
                                      NULL                     , -- response
                                      NULL                     , -- numeric_value
                                      NULL                       -- varchar2_value
                                    )
  INTO   SELF
  FROM   x_pcrf_failed_trans_log
  WHERE  pcrf_transaction_id = i_pcrf_transaction_id;

  --
  SELF.response := 'SUCCESS';

  --
  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'PCRF TRANSACTION NOT FOUND: ' || SQLERRM;
     SELF.pcrf_transaction_id := i_pcrf_transaction_id;
     RETURN;
END pcrf_failed_trans_log_type;

--
MEMBER FUNCTION ins RETURN pcrf_failed_trans_log_type IS

  pftl  pcrf_failed_trans_log_type := pcrf_failed_trans_log_type ( i_pcrf_transaction_id => SELF.pcrf_transaction_id );
  pcrf  pcrf_transaction_type := pcrf_transaction_type ( i_pcrf_transaction_id => pftl.pcrf_transaction_id);

BEGIN

  IF pcrf.status NOT LIKE '%SUCCESS%' THEN
    pftl.response := pcrf.status;
    RETURN pftl;
  END IF;

  -- Assign input values
  pftl.pcrf_transaction_id           := pcrf.pcrf_transaction_id     ;
  pftl.order_type                    := pcrf.order_type              ;
  pftl.min                           := pcrf.min                     ;
  pftl.esn                           := pcrf.esn                     ;
  pftl.rate_plan                     := pcrf.rate_plan               ;
  pftl.template                      := pcrf.template                ;
  pftl.status_message                := pcrf.status_message          ;
  pftl.insert_timestamp              := SYSDATE                      ;
  pftl.update_timestamp              := SYSDATE                      ;
  pftl.mdn                           := pcrf.mdn                     ;
  pftl.subscriber_id                 := pcrf.subscriber_id           ;
  pftl.group_id                      := pcrf.group_id                ;
  pftl.phone_manufacturer            := pcrf.phone_manufacturer      ;
  pftl.action_type                   := pcrf.action_type             ;
  pftl.sim                           := pcrf.sim                     ;
  pftl.zipcode                       := pcrf.zipcode                 ;
  pftl.service_plan_id               := pcrf.service_plan_id         ;
  pftl.case_id                       := pcrf.case_id                 ;
  pftl.pcrf_status_code              := pcrf.pcrf_status_code        ;
  pftl.web_objid                     := pcrf.web_objid               ;
  pftl.bus_org_id                    := pcrf.bus_org_id              ;
  pftl.sourcesystem                  := pcrf.sourcesystem            ;
  pftl.blackout_wait_date            := pcrf.blackout_wait_date      ;
  pftl.retry_count                   := pcrf.retry_count             ;
  pftl.data_usage                    := pcrf.data_usage              ;
  pftl.hi_speed_data_usage           := pcrf.hi_speed_data_usage     ;
  pftl.conversion_factor             := pcrf.conversion_factor       ;
  pftl.dealer_id                     := pcrf.dealer_id               ;
  pftl.denomination                  := pcrf.denomination            ;
  pftl.pcrf_parent_name              := pcrf.pcrf_parent_name        ;
  pftl.propagate_flag                := pcrf.propagate_flag          ;
  pftl.service_plan_type             := pcrf.service_plan_type       ;
  pftl.part_inst_status              := pcrf.part_inst_status        ;
  pftl.phone_model                   := pcrf.phone_model             ;
  pftl.content_delivery_format       := pcrf.content_delivery_format ;
  pftl.language                      := pcrf.language                ;
  pftl.wf_mac_id                     := pcrf.wf_mac_id               ;
  pftl.pcrf_cos                      := pcrf.pcrf_cos                ;
  pftl.ttl                           := pcrf.ttl                     ;
  pftl.future_ttl                    := pcrf.future_ttl              ;
  pftl.redemption_date               := pcrf.redemption_date         ;
  pftl.contact_objid                 := pcrf.contact_objid           ;

  --
  BEGIN
    INSERT
    INTO   x_pcrf_failed_trans_log
           ( objid                   ,
             pcrf_transaction_id     ,
             order_type              ,
             min                     ,
             esn                     ,
             rate_plan               ,
             template                ,
             status_message          ,
             mdn                     ,
             subscriber_id           ,
             group_id                ,
             phone_manufacturer      ,
             action_type             ,
             sim                     ,
             zipcode                 ,
             service_plan_id         ,
             case_id                 ,
             pcrf_status_code        ,
             web_objid               ,
             brand                   ,
             sourcesystem            ,
             blackout_wait_date      ,
             retry_count             ,
             data_usage              ,
             hi_speed_data_usage     ,
             conversion_factor       ,
             dealer_id               ,
             denomination            ,
             pcrf_parent_name        ,
             propagate_flag          ,
             service_plan_type       ,
             part_inst_status        ,
             phone_model             ,
             content_delivery_format ,
             language                ,
             wf_mac_id               ,
             pcrf_cos                ,
             ttl                     ,
             future_ttl              ,
             redemption_date         ,
             contact_objid           ,
             logged_date
           )
    VALUES
    ( sequ_pcrf_transaction.NEXTVAL,
      pftl.pcrf_transaction_id     ,
      pftl.order_type              ,
      pftl.min                     ,
      pftl.esn                     ,
      pftl.rate_plan               ,
      pftl.template                ,
      pftl.status_message          ,
      pftl.mdn                     ,
      pftl.subscriber_id           ,
      pftl.group_id                ,
      pftl.phone_manufacturer      ,
      pftl.action_type             ,
      pftl.sim                     ,
      pftl.zipcode                 ,
      pftl.service_plan_id         ,
      pftl.case_id                 ,
      pftl.pcrf_status_code        ,
      pftl.web_objid               ,
      pftl.bus_org_id              ,
      pftl.sourcesystem            ,
      pftl.blackout_wait_date      ,
      pftl.retry_count             ,
      pftl.data_usage              ,
      pftl.hi_speed_data_usage     ,
      pftl.conversion_factor       ,
      pftl.dealer_id               ,
      pftl.denomination            ,
      pftl.pcrf_parent_name        ,
      pftl.propagate_flag          ,
      pftl.service_plan_type       ,
      pftl.part_inst_status        ,
      pftl.phone_model             ,
      pftl.content_delivery_format ,
      pftl.language                ,
      pftl.wf_mac_id               ,
      pftl.pcrf_cos                ,
      pftl.ttl                     ,
      pftl.future_ttl              ,
      pftl.redemption_date         ,
      pftl.contact_objid,
      SYSDATE
    )
    RETURNING objid
    INTO      pftl.objid;
   EXCEPTION
     WHEN OTHERS THEN
       pftl.response := 'ERROR INSERTING PCRF FAILED TRANS LOG: ' ||SQLERRM;
       RETURN pftl;
  END;

  --
  pftl.response := 'SUCCESS';
  RETURN pftl;

 EXCEPTION
   WHEN OTHERS THEN
     --
     pftl.response := 'UNHANDLED ERROR ADDING PCRF FAILED TRANS LOG: ' || SQLERRM;
     RETURN pftl;
     --
END ins;

--
MEMBER FUNCTION exist RETURN BOOLEAN IS

 pftl  pcrf_failed_trans_log_type := pcrf_failed_trans_log_type ( i_pcrf_transaction_id => SELF.pcrf_transaction_id);

BEGIN
 IF pftl.pcrf_transaction_id IS NOT NULL THEN
    RETURN TRUE;
 ELSE
    RETURN FALSE;
 END IF;
END exist;

MEMBER FUNCTION exist ( i_pcrf_transaction_id IN NUMBER) RETURN BOOLEAN IS

 pftl  pcrf_failed_trans_log_type := pcrf_failed_trans_log_type ( i_pcrf_transaction_id => i_pcrf_transaction_id);

BEGIN
 IF pftl.pcrf_transaction_id IS NOT NULL THEN
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
MEMBER FUNCTION upd RETURN pcrf_failed_trans_log_type IS

  pftl  pcrf_failed_trans_log_type := SELF;
BEGIN
  --
  UPDATE x_pcrf_failed_trans_log
  SET    update_timestamp = SYSDATE
  WHERE  pcrf_transaction_id = pftl.pcrf_transaction_id;

  pftl.response := 'SUCCESS';
  RETURN pftl;
 EXCEPTION
   WHEN OTHERS THEN
     pftl.response := 'ERROR UPDATING PCRF FAILED TRANS LOG: ' || SUBSTR(SQLERRM,1,100);
     RETURN pftl;
END upd;
END;
/