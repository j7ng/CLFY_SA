CREATE OR REPLACE TYPE sa.subscribe_vas_programs_type
IS
OBJECT  (
          program_id                  NUMBER,
          program_enrolled_id         NUMBER,
          subscription_start_date     DATE,
          subscription_end_date       DATE,
          vas_service_id              NUMBER,
          x_purch_hdr_objid           NUMBER,
          program_purch_hdr_objid     NUMBER,
          vas_subscription_id         NUMBER,
          CONSTRUCTOR  FUNCTION subscribe_vas_programs_type RETURN SELF AS  RESULT
        );
/