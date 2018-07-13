CREATE OR REPLACE FUNCTION sa."IS_SHIPPABLE" ( p_sim VARCHAR2 )
RETURN VARCHAR2 DETERMINISTIC
IS
  CURSOR c_sim IS
    SELECT CASE
             WHEN b.part_num2ff_center IS NULL THEN 'N'
             ELSE 'Y'
           END AS shippable
    FROM   TABLE_PART_NUM a
           left outer join ( SELECT DISTINCT part_num2ff_center
                             FROM   MTM_PART_NUM22_X_FF_CENTER2 ) b
                        ON a.objid = b.part_num2ff_center
    WHERE  a.part_number = TRIM(UPPER(p_sim)) AND
           a.domain = 'SIM CARDS';

  sim_rec   c_sim%ROWTYPE;

  v_ret_val VARCHAR2(1) := 'N';
BEGIN
    OPEN c_sim;

    FETCH c_sim INTO sim_rec;

    IF c_sim%NOTFOUND THEN
      v_ret_val := 'N';
    ELSE
      v_ret_val := sim_rec.shippable;
    END IF;

    CLOSE c_sim;

    RETURN v_ret_val;

EXCEPTION
  WHEN OTHERS THEN
             IF c_sim%isopen THEN
               CLOSE c_sim;
             END IF;

             RETURN v_ret_val;
END;
/