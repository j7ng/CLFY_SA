CREATE OR REPLACE FUNCTION sa.luhn (val_num NUMBER)
RETURN NUMBER
IS
  --
  holder      NUMBER := 0;
  y           NUMBER := 0;
  conv_string VARCHAR2(20);
  --
BEGIN
  --
  conv_string := val_num;
  --
  FOR x IN 1..LENGTH(conv_string)
  LOOP
    y := to_number(substr(conv_string, -x, 1));
    IF MOD(x,2) = 0
    THEN
      y := y * 2;
      IF y > 9
      THEN
        y := y - 9;
      END IF;
    END IF;
    holder := holder + y;
  END LOOP;
  --
  IF MOD (holder, 10) = 0
  THEN
    RETURN 0;
  ELSE
    RETURN 1;
  END IF;
  --
END luhn;
/