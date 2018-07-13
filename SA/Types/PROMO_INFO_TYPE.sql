CREATE OR REPLACE TYPE sa.promo_info_type IS OBJECT(
  promo_code                    VARCHAR2(30)
 ,voice_units                   NUMBER
 ,data_units                    NUMBER
 ,sms_units                     NUMBER
 ,service_days                  NUMBER
)
/