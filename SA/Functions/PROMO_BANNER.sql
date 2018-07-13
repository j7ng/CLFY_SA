CREATE OR REPLACE FUNCTION sa."PROMO_BANNER" ( i_esn IN VARCHAR2)
                              RETURN VARCHAR2 AS

v_banner NUMBER := 0;
BEGIN --{

IF i_esn IS NULL
THEN --{
 RETURN 'N';
END IF; --}

 BEGIN --{
 WITH PARAM AS
            (
             SELECT X_PARAM_VALUE str
             FROM   table_x_parameters
             WHERE  X_PARAM_NAME ='PROMO_BANNER_COS'
            )
 SELECT COUNT(1)
 INTO   v_banner
 FROM    (
         SELECT trim(regexp_substr(str, '[^,]+', 1, LEVEL)) str
         FROM PARAM
         CONNECT BY regexp_substr(str , '[^,]+', 1, LEVEL) IS NOT NULL
         )
 WHERE   str = sa.get_cos(i_esn);

 EXCEPTION
   WHEN OTHERS THEN
   RETURN 'N';
 END; --}

 IF v_banner > 0
 THEN --{
  RETURN 'Y';
 ELSE
  RETURN 'N';
 END IF; --}

EXCEPTION
WHEN OTHERS THEN
  RETURN 'N';
END promo_banner; --}
/