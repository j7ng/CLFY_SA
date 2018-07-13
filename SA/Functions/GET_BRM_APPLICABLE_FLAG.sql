CREATE OR REPLACE FUNCTION sa."GET_BRM_APPLICABLE_FLAG" ( i_bus_org_objid           IN NUMBER ,
                                                     i_program_parameter_objid IN NUMBER ) RETURN VARCHAR2 DETERMINISTIC IS

  c customer_type := customer_type();

BEGIN

  -- return N when not brand passed
  IF i_bus_org_objid IS NULL THEN
    RETURN('N');
  END IF;

  -- call the customer type function
  RETURN(c.get_brm_applicable_flag ( i_bus_org_objid           => i_bus_org_objid,
                                     i_program_parameter_objid => i_program_parameter_objid) );

 EXCEPTION
   WHEN others THEN
     RETURN('N');
END get_brm_applicable_flag;
/