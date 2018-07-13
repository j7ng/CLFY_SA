CREATE OR REPLACE FUNCTION sa."GET_QUEUE_PRIORITY" ( i_esn IN VARCHAR2 ) RETURN NUMBER IS

  c customer_type := customer_type();
  n_priority  NUMBER;

BEGIN

  -- return a default of 1 when the esn is not passed
  IF i_esn IS NULL THEN
    RETURN 1;
  END IF;

  -- call the customer_type.get_cos function to determine the cos of the esn
  c.cos := c.get_cos ( i_esn             => i_esn   ,
                       i_as_of_date      => SYSDATE ,
                       i_skip_rules_flag => 'Y'     );

  -- return the highest priority of 5 when the cos is unknown
  IF c.cos = '0' THEN
    RETURN 5;
  END IF;

  -- get the priority based on the derived cos value
  IF c.cos IS NOT NULL THEN
    BEGIN
      SELECT queue_priority
      INTO   n_priority
      FROM   x_cos
      WHERE  cos = c.cos;
     EXCEPTION
       WHEN others THEN
         RETURN 1;
    END;
  END IF;

  -- return results (default to 1 when not determined)
  RETURN NVL(n_priority,1);

 EXCEPTION
   WHEN OTHERS THEN
     -- return 1 when not determined
     RETURN 1;
END get_queue_priority;
/