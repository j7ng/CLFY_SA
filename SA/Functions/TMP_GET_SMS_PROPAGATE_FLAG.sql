CREATE OR REPLACE FUNCTION sa."TMP_GET_SMS_PROPAGATE_FLAG" ( i_brand       IN VARCHAR2 ,
                                                           i_parent_name IN VARCHAR2 ,
                                                           i_device_type IN VARCHAR2 ) RETURN NUMBER IS

  l_meter_source   VARCHAR2(50);
  l_propagate_flag_value NUMBER;
BEGIN
  -- Get the metering source
  BEGIN
    SELECT sms_mtg_source
    INTO   l_meter_source
    FROM   sa.x_product_config
    WHERE  brand_name = i_brand
    AND    parent_name = i_parent_name
    AND    device_type = (CASE i_device_type WHEN 'BYOP' THEN 'SMARTPHONE' ELSE i_device_type END);
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  --
  IF l_meter_source IS NOT NULL THEN
    BEGIN
      SELECT carrier_mtg_id
      INTO   l_propagate_flag_value
      FROM   x_usage_host
      WHERE  short_name = l_meter_source;
    END;
  END IF;

  RETURN l_propagate_flag_value;
 EXCEPTION
   WHEN others THEN
     RETURN 0;
END;
/