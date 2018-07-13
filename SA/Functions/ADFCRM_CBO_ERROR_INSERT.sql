CREATE OR REPLACE FUNCTION sa."ADFCRM_CBO_ERROR_INSERT" (
   p_esn            IN   VARCHAR2,
   p_cbo_method     IN   VARCHAR2,
   p_error          IN   VARCHAR2,
   p_promo_code     IN   VARCHAR2,
   p_red_card       IN   VARCHAR2,
   p_zip_code       IN   VARCHAR2
)
   RETURN VARCHAR2
IS

BEGIN
INSERT
INTO sa.table_x_cbo_error
  (
    objid,
    x_esn_imei,
    x_source_system,
    x_cbo_method,
    x_error_string,
    x_error_date,
    x_promo_code,
    x_red_card,
    x_zip_code
  )
  VALUES
  (
    sa.seq('x_cbo_error'),
    SUBSTR(p_esn,1,30),
    'TAS',
    SUBSTR(p_cbo_method,1,50),
    SUBSTR(p_error,1,300),
    sysdate,
    SUBSTR(p_promo_code,1,10),
    SUBSTR(p_red_card,1,30),
    SUBSTR(p_zip_code,1,10)
  );

   commit;
   return 'SUCCESS';

exception

   when others then
      rollback;
      return 'ERROR: '||SQLCODE;

end;
/