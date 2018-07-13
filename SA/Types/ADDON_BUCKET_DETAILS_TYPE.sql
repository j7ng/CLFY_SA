CREATE OR REPLACE TYPE sa.addon_bucket_details_type
AS
  OBJECT
  (
    service_plan_objid      NUMBER,
    bucket_name             VARCHAR2(100),
    bucket_value            VARCHAR2(100),
    expiration_date         DATE,
    benefit_type            VARCHAR2(100),
    bucket_group            VARCHAR2(50),
    CONSTRUCTOR  FUNCTION addon_bucket_details_type RETURN SELF AS  RESULT
  );
/