CREATE OR REPLACE TYPE sa.esn_program_enroll_type IS
OBJECT (program_enroll_objid            NUMBER(22),
        enrollment_status               VARCHAR2(30),
        enrolled_date                   DATE,
        program_name                    VARCHAR2(240),
        program_class                   VARCHAR2(30),
        program_type                    VARCHAR2(30),
        product_id                      VARCHAR2(30),
        vas_group_name                  VARCHAR2(240),
        vas_product_type                VARCHAR2(60),
        vas_name                        VARCHAR2(60),
        vas_category                    VARCHAR2(30),
        vas_vendor                      VARCHAR2(30),
        vas_association                 VARCHAR2(30),
        vas_bus_org_id                  VARCHAR2(40),
        vas_esn                         VARCHAR2(30),
        vas_min                         VARCHAR2(30),
        vas_sim                         VARCHAR2(60),
        vas_id                          NUMBER,
        vas_subscription_status         VARCHAR2(60),
        CONSTRUCTOR FUNCTION esn_program_enroll_type
             RETURN SELF AS RESULT);
/
CREATE OR REPLACE TYPE BODY sa.esn_program_enroll_type IS
  CONSTRUCTOR FUNCTION esn_program_enroll_type
  RETURN SELF AS RESULT IS
  BEGIN
    RETURN;
  END;
END;
/