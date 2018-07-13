CREATE OR REPLACE TYPE sa.add_on_data_details_type
AS OBJECT
(
    service_plan_objid        NUMBER ,
    red_code                VARCHAR2(50) ,
    data_bucket_name          VARCHAR2(50) ,
    data_bucket_value         VARCHAR2(50) ,
    start_date                DATE,
    end_date                  DATE,
    CONSTRUCTOR  FUNCTION add_on_data_details_type RETURN SELF AS  RESULT
);
/