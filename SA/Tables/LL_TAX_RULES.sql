CREATE TABLE sa.ll_tax_rules (
  state_code VARCHAR2(40 BYTE) NOT NULL,
  apply_combstax NUMBER,
  apply_e911 NUMBER,
  apply_usf NUMBER,
  apply_rcr NUMBER,
  CONSTRAINT pk1_ll_tax_rules PRIMARY KEY (state_code)
);