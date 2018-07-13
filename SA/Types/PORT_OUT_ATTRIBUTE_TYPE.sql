CREATE OR REPLACE TYPE sa.port_out_attribute_type
AS OBJECT (key_column          VARCHAR2(50),
           key_value           VARCHAR2(20),
           param_value         VARCHAR2(500),
           null_input_flag     VARCHAR2(1),
           valid_input_flag    VARCHAR2(1),
           validation_message  VARCHAR2(500),
           CONSTRUCTOR FUNCTION port_out_attribute_type
                RETURN SELF AS RESULT);
/
CREATE OR REPLACE TYPE BODY sa.port_out_attribute_type IS
    CONSTRUCTOR FUNCTION port_out_attribute_type
    RETURN SELF AS RESULT
    IS
    BEGIN
      RETURN;
    END;
END;
/