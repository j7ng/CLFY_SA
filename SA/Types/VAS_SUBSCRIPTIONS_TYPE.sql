CREATE OR REPLACE TYPE sa.vas_subscriptions_type AS OBJECT (
addl_info                 VARCHAR2(50)  ,
case_id_number            VARCHAR2(255) ,
device_price_tier         NUMBER        ,
ecommerce_order_id        VARCHAR2(100) ,
insert_date               DATE          ,
objid                     NUMBER        ,
part_inst_objid           NUMBER        ,
program_enrolled_id       NUMBER        ,
program_parameters_objid  NUMBER        ,
program_purch_hdr_objid   NUMBER        ,
promotion_objid           NUMBER        ,
refund_amount	            NUMBER        ,
refund_type	              VARCHAR2(100) ,
status                    VARCHAR2(50)  ,
update_date               DATE          ,
vas_account               VARCHAR2(50)  ,
vas_esn                   VARCHAR2(30)  ,
vas_expiry_date           DATE          ,
vas_id                    NUMBER        ,
vas_is_active             VARCHAR2(1)   ,
vas_min                   VARCHAR2(30)  ,
vas_name                  VARCHAR2(30)  ,
vas_sim                   VARCHAR2(30)  ,
vas_subscription_date     DATE          ,
vas_subscription_id       NUMBER        ,
vas_x_ig_order_type       VARCHAR2(30)  ,
vendor_contract_id        VARCHAR2(100) ,
web_user_objid            NUMBER        ,
x_email                   VARCHAR2(100) ,
x_manufacturer            VARCHAR2(80)  ,
x_model_number            VARCHAR2(80)  ,
x_purch_hdr_objid         NUMBER        ,
x_real_esn                VARCHAR2(30)  ,
is_claimed                VARCHAR2(3)   ,
response                  VARCHAR2(1000),

--
CONSTRUCTOR FUNCTION vas_subscriptions_type RETURN SELF AS RESULT,
-- Function used to get all the attributes for a particular vas program
CONSTRUCTOR FUNCTION vas_subscriptions_type ( i_vas_subscription_id IN NUMBER ) RETURN SELF AS RESULT,
--
CONSTRUCTOR FUNCTION vas_subscriptions_type ( i_esn                 IN  VARCHAR2,
                                              i_vas_service_id      IN  NUMBER
                                            )
RETURN SELF AS RESULT,
--
CONSTRUCTOR FUNCTION vas_subscriptions_type ( i_esn                 IN  VARCHAR2,
                                              i_vendor_contract_id  IN  VARCHAR2,
                                              i_vas_subscription_id IN  VARCHAR2
                                            )
RETURN SELF AS RESULT,
CONSTRUCTOR FUNCTION vas_subscriptions_type ( i_esn                  IN  NUMBER,
                                              i_vas_subscription_id  IN  NUMBER)
RETURN SELF AS RESULT,
--
MEMBER FUNCTION ins ( i_vas_subscriptions_type IN vas_subscriptions_type) RETURN vas_subscriptions_type
--
);
/
CREATE OR REPLACE TYPE BODY sa.vas_subscriptions_type
AS
CONSTRUCTOR FUNCTION vas_subscriptions_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END vas_subscriptions_type;
--
CONSTRUCTOR FUNCTION vas_subscriptions_type ( i_vas_subscription_id IN NUMBER )
RETURN SELF AS RESULT
IS
BEGIN
  SELECT vas_subscriptions_type ( addl_info                 ,
                                  case_id_number            ,
                                  device_price_tier         ,
                                  ecommerce_order_id        ,
                                  insert_date               ,
                                  objid                     ,
                                  part_inst_objid           ,
                                  program_enrolled_id       ,
                                  program_parameters_objid  ,
                                  program_purch_hdr_objid   ,
                                  promotion_objid           ,
                                  refund_amount             ,
                                  refund_type               ,
                                  status                    ,
                                  update_date               ,
                                  vas_account               ,
                                  vas_esn                   ,
                                  vas_expiry_date           ,
                                  vas_id                    ,
                                  vas_is_active             ,
                                  vas_min                   ,
                                  vas_name                  ,
                                  vas_sim                   ,
                                  vas_subscription_date     ,
                                  vas_subscription_id       ,
                                  vas_x_ig_order_type       ,
                                  vendor_contract_id        ,
                                  web_user_objid            ,
                                  x_email                   ,
                                  x_manufacturer            ,
                                  x_model_number            ,
                                  x_purch_hdr_objid         ,
                                  x_real_esn                ,
                                  is_claimed                ,
                                  NULL                         -- response
                                )
  INTO   SELF
  FROM   x_vas_subscriptions
  WHERE  vas_subscription_id  = i_vas_subscription_id
  AND    vas_is_active        = 'T';
  --
  SELF.response := 'SUCCESS';
  --
  RETURN;
  --
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response              := 'VAS SUBSCRIPTION NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     SELF.vas_subscription_id   := i_vas_subscription_id;
     RETURN;
END vas_subscriptions_type;
--
--
CONSTRUCTOR FUNCTION vas_subscriptions_type ( i_esn             IN  VARCHAR2,
                                              i_vas_service_id  IN  NUMBER
                                            )
RETURN SELF AS RESULT
IS
BEGIN
  SELECT vas_subscriptions_type ( addl_info                 ,
                                  case_id_number            ,
                                  device_price_tier         ,
                                  ecommerce_order_id        ,
                                  insert_date               ,
                                  objid                     ,
                                  part_inst_objid           ,
                                  program_enrolled_id       ,
                                  program_parameters_objid  ,
                                  program_purch_hdr_objid   ,
                                  promotion_objid           ,
                                  refund_amount             ,
                                  refund_type               ,
                                  status                    ,
                                  update_date               ,
                                  vas_account               ,
                                  vas_esn                   ,
                                  vas_expiry_date           ,
                                  vas_id                    ,
                                  vas_is_active             ,
                                  vas_min                   ,
                                  vas_name                  ,
                                  vas_sim                   ,
                                  vas_subscription_date     ,
                                  vas_subscription_id       ,
                                  vas_x_ig_order_type       ,
                                  vendor_contract_id        ,
                                  web_user_objid            ,
                                  x_email                   ,
                                  x_manufacturer            ,
                                  x_model_number            ,
                                  x_purch_hdr_objid         ,
                                  x_real_esn                ,
                                  is_claimed                ,
                                  NULL                         -- response
                                )
  INTO   SELF
  FROM   x_vas_subscriptions
  WHERE  vas_esn              = i_esn
  AND    vas_id               = i_vas_service_id
  AND    vas_is_active        = 'T';
  --
  SELF.response := 'SUCCESS';
  --
  RETURN;
  --
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response        := 'VAS SUBSCRIPTION NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END vas_subscriptions_type;
--
--
CONSTRUCTOR FUNCTION vas_subscriptions_type ( i_esn                 IN  VARCHAR2,
                                              i_vendor_contract_id  IN  VARCHAR2,
                                              i_vas_subscription_id IN  VARCHAR2
                                            )
RETURN SELF AS RESULT
IS
BEGIN
  SELECT vas_subscriptions_type ( addl_info                 ,
                                  case_id_number            ,
                                  device_price_tier         ,
                                  ecommerce_order_id        ,
                                  insert_date               ,
                                  objid                     ,
                                  part_inst_objid           ,
                                  program_enrolled_id       ,
                                  program_parameters_objid  ,
                                  program_purch_hdr_objid   ,
                                  promotion_objid           ,
                                  refund_amount             ,
                                  refund_type               ,
                                  status                    ,
                                  update_date               ,
                                  vas_account               ,
                                  vas_esn                   ,
                                  vas_expiry_date           ,
                                  vas_id                    ,
                                  vas_is_active             ,
                                  vas_min                   ,
                                  vas_name                  ,
                                  vas_sim                   ,
                                  vas_subscription_date     ,
                                  vas_subscription_id       ,
                                  vas_x_ig_order_type       ,
                                  vendor_contract_id        ,
                                  web_user_objid            ,
                                  x_email                   ,
                                  x_manufacturer            ,
                                  x_model_number            ,
                                  x_purch_hdr_objid         ,
                                  x_real_esn                ,
                                  is_claimed                ,
                                  NULL                         -- response
                                )
  INTO   SELF
  FROM   x_vas_subscriptions
  WHERE  vas_esn              = i_esn
  AND    vendor_contract_id   = i_vendor_contract_id
  AND    vas_subscription_id  = i_vas_subscription_id
  AND    vas_is_active        = 'T';
  --
  SELF.response := 'SUCCESS';
  --
  RETURN;
  --
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response        := 'VAS SUBSCRIPTION NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END vas_subscriptions_type;
--
CONSTRUCTOR FUNCTION vas_subscriptions_type ( i_esn                   IN  NUMBER,
                                              i_vas_subscription_id   IN  NUMBER)
RETURN SELF AS RESULT
IS
BEGIN
  SELECT vas_subscriptions_type ( addl_info                 ,
                                  case_id_number            ,
                                  device_price_tier         ,
                                  ecommerce_order_id        ,
                                  insert_date               ,
                                  objid                     ,
                                  part_inst_objid           ,
                                  program_enrolled_id       ,
                                  program_parameters_objid  ,
                                  program_purch_hdr_objid   ,
                                  promotion_objid           ,
                                  refund_amount             ,
                                  refund_type               ,
                                  status                    ,
                                  update_date               ,
                                  vas_account               ,
                                  vas_esn                   ,
                                  vas_expiry_date           ,
                                  vas_id                    ,
                                  vas_is_active             ,
                                  vas_min                   ,
                                  vas_name                  ,
                                  vas_sim                   ,
                                  vas_subscription_date     ,
                                  vas_subscription_id       ,
                                  vas_x_ig_order_type       ,
                                  vendor_contract_id        ,
                                  web_user_objid            ,
                                  x_email                   ,
                                  x_manufacturer            ,
                                  x_model_number            ,
                                  x_purch_hdr_objid         ,
                                  x_real_esn                ,
                                  is_claimed                ,
                                  NULL                         -- response
                                )
  INTO   SELF
  FROM   x_vas_subscriptions
  WHERE  vas_esn              = i_esn
  AND    vas_subscription_id  = i_vas_subscription_id
  AND    vas_is_active        = 'T';
  --
  SELF.response := 'SUCCESS';
  --
  RETURN;
  --
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response        := 'VAS SUBSCRIPTION NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END vas_subscriptions_type;
--
MEMBER FUNCTION ins ( i_vas_subscriptions_type IN vas_subscriptions_type ) RETURN vas_subscriptions_type AS
  i_vs  vas_subscriptions_type := i_vas_subscriptions_type;
BEGIN
  --
  IF i_vs.objid IS NULL
  THEN
    i_vs.objid  := seq_x_vas_subscriptions.NEXTVAL;
  END IF;
  --
  INSERT  INTO x_vas_subscriptions
  (   addl_info                 ,
      case_id_number            ,
      device_price_tier         ,
      ecommerce_order_id        ,
      insert_date               ,
      objid                     ,
      part_inst_objid           ,
      program_enrolled_id       ,
      program_parameters_objid  ,
      program_purch_hdr_objid   ,
      promotion_objid           ,
      refund_amount             ,
      refund_type               ,
      status                    ,
      update_date               ,
      vas_account               ,
      vas_esn                   ,
      vas_expiry_date           ,
      vas_id                    ,
      vas_is_active             ,
      vas_min                   ,
      vas_name                  ,
      vas_sim                   ,
      vas_subscription_date     ,
      vas_subscription_id       ,
      vas_x_ig_order_type       ,
      vendor_contract_id        ,
      web_user_objid            ,
      x_email                   ,
      x_manufacturer            ,
      x_model_number            ,
      x_purch_hdr_objid         ,
      x_real_esn                ,
      is_claimed                )
  VALUES
  (
      i_vs.addl_info                 ,
      i_vs.case_id_number            ,
      i_vs.device_price_tier         ,
      i_vs.ecommerce_order_id        ,
      SYSDATE                        ,
      i_vs.objid                     ,
      i_vs.part_inst_objid           ,
      i_vs.program_enrolled_id       ,
      i_vs.program_parameters_objid  ,
      i_vs.program_purch_hdr_objid   ,
      i_vs.promotion_objid           ,
      i_vs.refund_amount             ,
      i_vs.refund_type               ,
      i_vs.status                    ,
      SYSDATE                        ,
      i_vs.vas_account               ,
      i_vs.vas_esn                   ,
      i_vs.vas_expiry_date           ,
      i_vs.vas_id                    ,
      i_vs.vas_is_active             ,
      i_vs.vas_min                   ,
      i_vs.vas_name                  ,
      i_vs.vas_sim                   ,
      i_vs.vas_subscription_date     ,
      i_vs.vas_subscription_id       ,
      i_vs.vas_x_ig_order_type       ,
      i_vs.vendor_contract_id        ,
      i_vs.web_user_objid            ,
      i_vs.x_email                   ,
      i_vs.x_manufacturer            ,
      i_vs.x_model_number            ,
      i_vs.x_purch_hdr_objid         ,
      i_vs.x_real_esn                ,
      i_vs.is_claimed
  );
  --
  -- set Success Response
  i_vs.response :=  'SUCCESS';
  RETURN i_vs;
  --
EXCEPTION
  WHEN OTHERS THEN
  i_vs.response := i_vs.response || '|ERROR INSERTING VAS SUBSCRIPTION RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN i_vs;
END ins;
END;
/