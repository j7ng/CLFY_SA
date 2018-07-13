CREATE TABLE sa.x_carrier_rules_hist (
  x_cooling_period NUMBER,
  x_esn_change_flag NUMBER,
  x_line_expire_days NUMBER,
  x_line_return_days NUMBER,
  x_cooling_after_insert NUMBER,
  x_npa_nxx_flag NUMBER,
  x_used_line_expire_days NUMBER,
  x_change_date DATE DEFAULT SYSDATE NOT NULL,
  x_user VARCHAR2(30 BYTE) DEFAULT USER NOT NULL,
  rules_hist2carrier_rules NUMBER(38) NOT NULL,
  x_old_cooling_period NUMBER,
  x_old_esn_change_flag NUMBER,
  x_old_line_expire_days NUMBER,
  x_old_line_return_days NUMBER,
  x_old_cool_after_insert NUMBER,
  x_old_npa_nxx_flag NUMBER,
  x_old_used_line_expire_days NUMBER
);
ALTER TABLE sa.x_carrier_rules_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1081834612_0 (rules_hist2carrier_rules, x_change_date, x_cooling_after_insert, x_cooling_period, x_esn_change_flag, x_line_expire_days, x_line_return_days, x_npa_nxx_flag, x_old_cooling_period, x_old_cool_after_insert, x_old_esn_change_flag, x_old_line_expire_days, x_old_line_return_days, x_old_npa_nxx_flag, x_old_used_line_expire_days, x_used_line_expire_days, x_user) ALWAYS;