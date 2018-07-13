CREATE TABLE sa.red_card_log (
  serail_no VARCHAR2(30 BYTE),
  old_part_number VARCHAR2(30 BYTE),
  new_part_number VARCHAR2(30 BYTE),
  s_x_pi_status VARCHAR2(30 BYTE),
  log_date DATE
);
ALTER TABLE sa.red_card_log ADD SUPPLEMENTAL LOG GROUP dmtsora2123713548_0 (log_date, new_part_number, old_part_number, serail_no, s_x_pi_status) ALWAYS;