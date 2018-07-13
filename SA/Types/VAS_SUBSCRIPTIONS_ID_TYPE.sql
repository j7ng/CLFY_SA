CREATE OR REPLACE TYPE sa.vas_subscriptions_id_type
IS
OBJECT  (
          vas_subscriptions_id        NUMBER,
          error_code                  NUMBER,
          error_msg                   VARCHAR2 (1000),
          CONSTRUCTOR  FUNCTION vas_subscriptions_id_type RETURN SELF AS  RESULT
        );
/