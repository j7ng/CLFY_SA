CREATE OR REPLACE TYPE sa.customer_contact_info_type
AS
  OBJECT
  (
   x_login_name        VARCHAR2(50)
  ,x_org_id            VARCHAR2(40)
  ,x_esn               VARCHAR2(30)
  ,x_min               VARCHAR2(30)
  ,x_part_number       VARCHAR2(30)
  ,x_part_class        VARCHAR2(40)
  ,x_source_system     VARCHAR2(250)
  ,x_do_not_email      NUMBER
  ,x_do_not_phone      NUMBER
  ,x_do_not_sms        NUMBER
  ,x_do_not_mail       NUMBER
  ,error_code          VARCHAR2(30)
  ,error_msg           VARCHAR2(30)
   ,CONSTRUCTOR  FUNCTION customer_contact_info_type RETURN SELF AS  RESULT
  )
/