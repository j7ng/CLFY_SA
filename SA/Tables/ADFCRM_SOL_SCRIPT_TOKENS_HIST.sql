CREATE TABLE sa.adfcrm_sol_script_tokens_hist (
  token VARCHAR2(100 BYTE) NOT NULL,
  description VARCHAR2(400 BYTE) NOT NULL,
  token_value VARCHAR2(4000 BYTE) NOT NULL,
  changed_date DATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE)
);