CREATE OR REPLACE FUNCTION sa."CONVERT_TIME_BY_TIMEZONE"
                                               (
                                                i_zipcode        IN x_zip2time_zone.zip%TYPE, --Optional
                                                i_timestamp      IN DATE,
                                                i_from_timezone  VARCHAR2 DEFAULT  'EST',
                                                i_to_timezone    VARCHAR2
                                                )
RETURN DATE AS

v_conv_timestamp DATE;
v_from_timezone  VARCHAR2(10);
v_to_timezone    VARCHAR2(10);

BEGIN --{

IF i_timestamp IS NULL
THEN --{
 DBMS_OUTPUT.PUT_LINE('Invalid Input');
 RETURN NULL;
END IF; --}

 SELECT CASE
            WHEN i_from_timezone IN ('AKDT','HDT')
            THEN 'HDT'
            WHEN i_from_timezone IN ('CST')
            THEN 'CST'
            WHEN i_from_timezone IN ('HAST', 'HST')
            THEN 'HST'
            WHEN i_from_timezone IN ('MST', 'MTZ')
            THEN 'MST'
            WHEN i_from_timezone IN ('PST')
            THEN 'PST'
            ELSE 'EST'
          END FROM_TIMEZONE,
          CASE
            WHEN i_to_timezone IN ('AKDT','HDT')
            THEN 'HDT'
            WHEN i_to_timezone IN ('CST')
            THEN 'CST'
            WHEN i_to_timezone IN ('HAST', 'HST')
            THEN 'HST'
            WHEN i_to_timezone IN ('MST', 'MTZ')
            THEN 'MST'
            WHEN i_to_timezone IN ('PST')
            THEN 'PST'
            ELSE 'EST'
          END TO_TIMEZONE
 INTO  v_from_timezone,
       v_to_timezone
 FROM  dual;

 BEGIN --{
  SELECT CASE
              WHEN timezone IN ('AKDT','HDT')
              THEN NEW_TIME(i_timestamp,v_from_timezone, 'HDT')
              WHEN timezone IN ('CST')
              THEN NEW_TIME(i_timestamp,v_from_timezone, 'CST')
              WHEN timezone IN ('HAST', 'HST')
              THEN NEW_TIME(i_timestamp,v_from_timezone, 'HST')
              WHEN timezone IN ('MST', 'MTZ')
              THEN NEW_TIME(i_timestamp,v_from_timezone, 'MST')
              WHEN timezone IN ('PST')
              THEN NEW_TIME(i_timestamp,v_from_timezone, 'PST')
              ELSE NEW_TIME(i_timestamp,v_from_timezone, 'EST')
          END
  INTO   v_conv_timestamp
  FROM   x_zip2time_zone
  WHERE  zip    = i_zipcode
  AND    ROWNUM = 1;

 EXCEPTION
 WHEN OTHERS THEN

  SELECT NEW_TIME(i_timestamp,v_from_timezone, i_to_timezone)
  INTO    v_conv_timestamp
  FROM    dual;

 END; --}

RETURN v_conv_timestamp;

EXCEPTION
WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE('In convert_time_by_timezone exception: '||sqlerrm);
 RETURN NULL;
END; --}
/