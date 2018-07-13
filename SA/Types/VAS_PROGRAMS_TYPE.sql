CREATE OR REPLACE TYPE sa.vas_programs_type AS OBJECT (
auto_pay_program_objid            VARCHAR2(50)	  ,
direct_cancel_flag                VARCHAR2(50)    ,
grace_period                      VARCHAR2(50)    ,
ild_rates_url                     VARCHAR2(1000)  ,
mobile_description                VARCHAR2(30)    ,
mobile_description2               VARCHAR2(30)    ,
mobile_description3               VARCHAR2(30)    ,
mobile_description4               VARCHAR2(30)    ,
mobile_plan_type                  VARCHAR2(30)    ,
offer_expiry                      VARCHAR2(50)    ,
part_class_objid                  VARCHAR2(50)    ,
product_id                        VARCHAR2(50)    ,
program_parameters_objid          VARCHAR2(50)    ,
proration_flag                    VARCHAR2(50)    ,
reenroll_allow_flag               VARCHAR2(50)    ,
refund_on_cancellation_flag       VARCHAR2(50)    ,
refund_on_replacement_flag        VARCHAR2(50)    ,
refund_on_upgrade_flag            VARCHAR2(50)    ,
service_days                      VARCHAR2(50)    ,
show_due_before_days              VARCHAR2(50)    ,
transfer_on_replacement_flag      VARCHAR2(50)    ,
transfer_on_upgrade_flag          VARCHAR2(50)    ,
vas_app_card                      VARCHAR2(50)    ,
vas_association                   VARCHAR2(50)    ,
vas_bus_org                       VARCHAR2(50)    ,
vas_card_class                    VARCHAR2(50)    ,
vas_category                      VARCHAR2(50)    ,
vas_description_english           VARCHAR2(50)    ,
vas_description_spanish           VARCHAR2(50)    ,
vas_end_date                      DATE            ,
vas_group_name                    VARCHAR2(50)    ,
vas_is_active                     VARCHAR2(50)    ,
vas_name                          VARCHAR2(30)    ,
vas_price                         VARCHAR2(50)    ,
vas_product_type                  VARCHAR2(50)    ,
vas_recurring_days                VARCHAR2(50)    ,
vas_service_id                    NUMBER          ,
vas_sponsor                       VARCHAR2(50)    ,
vas_start_date                    DATE            ,
vas_tax_calculation               VARCHAR2(50)    ,
vas_type                          VARCHAR2(50)    ,
vas_vendor                        VARCHAR2(50)    ,
x_promotion_objid                 VARCHAR2(50)    ,
response                          VARCHAR2(1000)  ,
--
CONSTRUCTOR FUNCTION vas_programs_type RETURN SELF AS RESULT,
-- Function used to get all the attributes for a particular vas program
CONSTRUCTOR FUNCTION vas_programs_type ( i_vas_service_id IN NUMBER ) RETURN SELF AS RESULT,
CONSTRUCTOR FUNCTION vas_programs_type ( i_program_param_id IN NUMBER ) RETURN SELF AS RESULT
--
);
/
CREATE OR REPLACE TYPE BODY sa.vas_programs_type
AS
CONSTRUCTOR FUNCTION vas_programs_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END vas_programs_type;
--
CONSTRUCTOR FUNCTION vas_programs_type ( i_vas_service_id IN NUMBER )
RETURN SELF AS RESULT
IS
BEGIN
  SELECT vas_programs_type  ( auto_pay_program_objid       ,
                              direct_cancel_flag           ,
                              grace_period                 ,
                              ild_rates_url                ,
                              mobile_description           ,
                              mobile_description2          ,
                              mobile_description3          ,
                              mobile_description4          ,
                              mobile_plan_type             ,
                              offer_expiry                 ,
                              part_class_objid             ,
                              product_id                   ,
                              program_parameters_objid     ,
                              proration_flag               ,
                              reenroll_allow_flag          ,
                              refund_on_cancellation_flag  ,
                              refund_on_replacement_flag   ,
                              refund_on_upgrade_flag       ,
                              service_days                 ,
                              show_due_before_days         ,
                              transfer_on_replacement_flag ,
                              transfer_on_upgrade_flag     ,
                              vas_app_card                 ,
                              vas_association              ,
                              vas_bus_org                  ,
                              vas_card_class               ,
                              vas_category                 ,
                              vas_description_english      ,
                              vas_description_spanish      ,
                              vas_end_date                 ,
                              vas_group_name               ,
                              vas_is_active                ,
                              vas_name                     ,
                              vas_price                    ,
                              vas_product_type             ,
                              vas_recurring_days           ,
                              vas_service_id               ,
                              vas_sponsor                  ,
                              vas_start_date               ,
                              vas_tax_calculation          ,
                              vas_type                     ,
                              vas_vendor                   ,
                              x_promotion_objid            ,
                              NULL                         -- response
                              )
  INTO   SELF
  FROM   vas_programs_view
  WHERE  vas_service_id = i_vas_service_id;
  --
  SELF.response := 'SUCCESS';

  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     SELF.response        := 'SERVICE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     SELF.vas_service_id  := i_vas_service_id;
     RETURN;
END vas_programs_type;
--
CONSTRUCTOR FUNCTION vas_programs_type ( i_program_param_id IN NUMBER )
RETURN SELF AS RESULT
IS
BEGIN
  SELECT vas_programs_type  ( auto_pay_program_objid       ,
                              direct_cancel_flag           ,
                              grace_period                 ,
                              ild_rates_url                ,
                              mobile_description           ,
                              mobile_description2          ,
                              mobile_description3          ,
                              mobile_description4          ,
                              mobile_plan_type             ,
                              offer_expiry                 ,
                              part_class_objid             ,
                              product_id                   ,
                              program_parameters_objid     ,
                              proration_flag               ,
                              reenroll_allow_flag          ,
                              refund_on_cancellation_flag  ,
                              refund_on_replacement_flag   ,
                              refund_on_upgrade_flag       ,
                              service_days                 ,
                              show_due_before_days         ,
                              transfer_on_replacement_flag ,
                              transfer_on_upgrade_flag     ,
                              vas_app_card                 ,
                              vas_association              ,
                              vas_bus_org                  ,
                              vas_card_class               ,
                              vas_category                 ,
                              vas_description_english      ,
                              vas_description_spanish      ,
                              vas_end_date                 ,
                              vas_group_name               ,
                              vas_is_active                ,
                              vas_name                     ,
                              vas_price                    ,
                              vas_product_type             ,
                              vas_recurring_days           ,
                              vas_service_id               ,
                              vas_sponsor                  ,
                              vas_start_date               ,
                              vas_tax_calculation          ,
                              vas_type                     ,
                              vas_vendor                   ,
                              x_promotion_objid            ,
                              NULL                         -- response
                              )
  INTO   SELF
  FROM   vas_programs_view
  WHERE  (NVL(program_parameters_objid, 1) = i_program_param_id OR
          NVL(auto_pay_program_objid, 1)   = i_program_param_id);
  --
  SELF.response := 'SUCCESS';

  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     SELF.response        := 'SERVICE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END vas_programs_type;
--
END;
/