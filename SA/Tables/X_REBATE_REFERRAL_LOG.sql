CREATE TABLE sa.x_rebate_referral_log (
  file_name VARCHAR2(50 BYTE),
  file_create_date DATE,
  file_type VARCHAR2(15 BYTE)
);
ALTER TABLE sa.x_rebate_referral_log ADD SUPPLEMENTAL LOG GROUP dmtsora216244625_0 (file_create_date, file_name, file_type) ALWAYS;