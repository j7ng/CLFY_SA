CREATE OR REPLACE FUNCTION sa.is_shared_group_talk_n_text ( i_service_plan_id IN NUMBER ) RETURN VARCHAR2 IS
 c_shared_group_talk_n_text VARCHAR2(1) := 'N';
BEGIN

  -- set service plan talk and text flag
  IF i_service_plan_id IN ( 379, -- TOTAL_WIRELESS NON-AR service plan
	                    418  -- TOTAL_WIRELESS AR service plan
                          )
  THEN
    c_shared_group_talk_n_text := 'Y';
  END IF;

  -- return mapping
  RETURN NVL(c_shared_group_talk_n_text,'N');

 EXCEPTION
   WHEN others THEN
     RETURN ('N');
END;
/