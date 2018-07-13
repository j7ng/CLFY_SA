CREATE OR REPLACE PACKAGE sa."BILLING_REPORT_PKG"
  IS

  /*
        This function computes the active base till the date given as the input parameter.
         The two parameters ( p_business_line and p_program_id ) return the active base
         for the selection.
  */
  FUNCTION getActiveBase
     ( p_date               IN DATE,
       p_business_line      IN NUMBER DEFAULT NULL,
       p_program_id         IN NUMBER DEFAULT NULL
     )
     RETURN  NUMBER;

  /*
    This procedure returns the summary details for the chargeback ESN. Used in the Chargeback
    summary report.
  */
  PROCEDURE    BILLING_REPORT (
        p_merchant_ref_number IN VARCHAR2  ,
        o_esn               OUT VARCHAR2 ,
        o_first_name        OUT VARCHAR2 ,
        o_last_name         OUT VARCHAR2 ,
    	o_login_name        OUT VARCHAR2 ,
        o_program_name      OUT VARCHAR2 ,  -- Can be multiple programs against an Order
        o_ENROLLED_DATE     OUT VARCHAR2 ,  -- Multiple enrollment dates for each of the program
        o_amount            OUT VARCHAR2 ,  -- Amount
        o_tax_amount        OUT VARCHAR2 ,
        o_e911_tax_amount   OUT VARCHAR2 ,
        o_total_amount      OUT VARCHAR2 ,
        o_PYMT_SRC_NAME     OUT VARCHAR2 ,
        o_starred_number    OUT VARCHAR2 ,
        o_source_system     OUT VARCHAR2 ,
        o_bus_org           OUT VARCHAR2 ,
        o_charge_freq       OUT VARCHAR2
    );

END; -- Package Specification BILLING_REPORT_PKG
/