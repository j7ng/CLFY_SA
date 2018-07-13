CREATE OR REPLACE FUNCTION sa."GET_MIN_COS_VALUE" ( i_min        IN VARCHAR2,
                                                  i_as_of_date IN DATE DEFAULT SYSDATE,
                                                  i_bypass_flg IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2 IS
 cst customer_type := sa.customer_type ();
 l_esn varchar2(30);
 l_cos varchar2(30);
BEGIN

  if i_min is not null then
      -- get esn
      l_esn := cst.get_esn(i_min => i_min);

      l_cos := sa.get_cos (i_esn        => l_esn,
                           i_as_of_date => i_as_of_date);

  else
      l_cos := '0';

  end if;

  return l_cos;

EXCEPTION
   WHEN OTHERS THEN
     RETURN('0');
END;
/