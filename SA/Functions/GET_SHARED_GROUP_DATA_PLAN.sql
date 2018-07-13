CREATE OR REPLACE FUNCTION sa.get_shared_group_data_plan ( i_service_plan_id IN NUMBER ) RETURN NUMBER IS
  n_service_plan_id NUMBER;
BEGIN

  -- calculate mapping
  n_service_plan_id := CASE i_service_plan_id
	                     WHEN 379 THEN 380 -- map the Talk and Text with NON-AR service plan
	                     WHEN 418 THEN 419 -- map the Talk and Text with AR service plan
						 ELSE NULL
                       END;

  -- return mapping
  RETURN n_service_plan_id;

 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END;
/