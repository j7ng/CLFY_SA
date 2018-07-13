CREATE OR REPLACE FORCE VIEW sa.sl_gencodes_days_ahead_view (promo_code,part_number,days_ahead) AS
SELECT SUBSTR(txp.x_param_value
             ,1
             ,INSTR(txp.x_param_value
                   ,'|'
                   ,1
                   ,1) - 1) promo_code
      ,SUBSTR(txp.x_param_value
             ,INSTR(txp.x_param_value
                   ,'|'
                   ,1
                   ,1) + 1
             ,(INSTR(txp.x_param_value
                    ,'|'
                    ,1
                    ,2)) - (INSTR(txp.x_param_value
                                 ,'|'
                                 ,1
                                 ,1) + 1)) part_number
      ,SUBSTR(txp.x_param_value
             ,INSTR(txp.x_param_value
                   ,'|'
                   ,1
                   ,2) + 1) days_ahead
  FROM table_x_parameters txp
 WHERE txp.x_param_name = 'SAFELINK_GENCODES_DAYS_AHEAD_EXCEPTION'
UNION
SELECT 'ALL'
      ,'ALL'
      ,txp.x_param_value
  FROM table_x_parameters txp
 WHERE txp.x_param_name = 'SAFELINK_GENCODES_DAYS_AHEAD';
COMMENT ON TABLE sa.sl_gencodes_days_ahead_view IS 'To store days ahead value used to determine sweep/add for SafeLink ESNs';
COMMENT ON COLUMN sa.sl_gencodes_days_ahead_view.promo_code IS 'Sweep/add decision based on promo code (default is ALL)';
COMMENT ON COLUMN sa.sl_gencodes_days_ahead_view.part_number IS 'Sweep/add decision based on redemption card part number (default is ALL) ';
COMMENT ON COLUMN sa.sl_gencodes_days_ahead_view.days_ahead IS 'Days ahead value used to determine sweep/add for SafeLink ESNs';