CREATE OR REPLACE FUNCTION sa."HEX2DEC"
(hexval in char) RETURN varchar2 IS

  ---------------------------------------------------------------------------------------------
  --$RCSfile: HEX2DEC.sql,v $
  --$Revision: 1.6 $
  --$Author: icanavan $
  --$Date: 2012/11/19 21:18:06 $
  --$ $Log: HEX2DEC.sql,v $
  --$ Revision 1.6  2012/11/19 21:18:06  icanavan
  --$ update role
  --$
  --$ Revision 1.5  2012/11/12 16:17:40  icanavan
  --$ Put sa. in front of function
  --$
  --$ Revision 1.4  2012/11/12 14:36:31  icanavan
  --$ added the synonym
  --$
  --$ Revision 1.3  2012/11/09 14:45:06  icanavan
  --$ added grants
  --$
  --$ Revision 1.2  2012/11/07 19:10:56  icanavan
  --$ ACMI ACME change return value to varchar, it was a number
  --$
  ---------------------------------------------------------------------------------------------

  /********************************************************************************/
  /* Copyright . 2012 Tracfone Wireless Inc. All rights reserved                  */
  /* Name         :   HEX2DEC                                                     */
  /* Purpose      :   Convert HEX to decimal MEID                                 */
  /*                  1st 8 digits calculated and concatinated with the remainder */
  /*                                                                              */
  /* PARAMETERS:                                                                  */
  /* HEX_ESN          Hexidecimal ESN value                                       */
  /* RETURN:          DECIMAL MEID                                                */
  /* Platforms    :   Oracle 8.0.6 AND newer versions                             */
  /* Revisions   :                                                                */
  /* Version  Date       Who        Purpose                                       */
  /* -------  --------   -------    --------------------------------------        */
  /* 1.1      10/31/2012 ICanavan   Initial revision                              */
  /********************************************************************************/

  i                 number;
  digits            number;
  digits_a          number ;
  result            number := 0;
  result_a          number := 0;
  result_b          number := 0;
  current_digit     char(1);
  current_digit_dec number;
BEGIN
  digits := length(hexval);
  digits_a := 8 ;

  for i in 1..digits_a loop
     current_digit := SUBSTR(hexval, i, 1);
     if current_digit in ('A','B','C','D','E','F') then
        current_digit_dec := ascii(current_digit) - ascii('A') + 10;
     else
        current_digit_dec := to_number(current_digit);
     end if;
     result_a := (result_a * 16) + current_digit_dec;
  end loop;

    for i in 9..digits loop
     current_digit := SUBSTR(hexval, i, 1);
     if current_digit in ('A','B','C','D','E','F') then
        current_digit_dec := ascii(current_digit) - ascii('A') + 10;
     else
        current_digit_dec := to_number(current_digit);
     end if;
     result_b := (result_b * 16) + current_digit_dec;
  end loop;

  result := result_a || lpad(result_b,8,'0') ;

  return result;
END hex2dec;
/