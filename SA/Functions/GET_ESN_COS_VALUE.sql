CREATE OR REPLACE FUNCTION sa."GET_ESN_COS_VALUE" ( i_esn        IN VARCHAR2,
                                                  i_as_of_date IN DATE DEFAULT SYSDATE ) RETURN VARCHAR2 IS

  l_cos                        VARCHAR2(30);
  l_min                        VARCHAR2(30);

BEGIN

  -- Get the min based on the ESN
  BEGIN
    SELECT pi_min.part_serial_no min
    INTO   l_min
    FROM   table_part_inst pi_esn,
           table_part_inst pi_min
    WHERE  1 = 1
    AND    pi_esn.part_serial_no = i_esn
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_min.part_to_esn2part_inst = pi_esn.objid
    AND    pi_min.x_domain = 'LINES'
    AND    ROWNUM = 1;
   EXCEPTION
     WHEN others THEN
       -- Get active site part
       BEGIN
         SELECT x_min
         INTO   l_min
         FROM   table_site_part
         WHERE  x_service_id = i_esn
         AND    part_status = 'Active';
        EXCEPTION
          WHEN others THEN
            -- Get inactive site parts
            BEGIN
               SELECT x_min
               INTO   l_min
               FROM   ( SELECT x_min
                        FROM   sa.table_site_part
                        WHERE  x_service_id = i_esn
                        ORDER BY install_date DESC
                      )
               WHERE  ROWNUM = 1;
             EXCEPTION
               WHEN others THEN
                 RETURN('0');
            END;
       END;
  END;

  -- Get the COS value based on the min
  l_cos := get_min_cos_value ( i_min        => l_min,
                               i_as_of_date => i_as_of_date,
                               i_bypass_flg => 'Y');

  RETURN l_cos;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN('0');
END;
/