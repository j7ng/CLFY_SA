CREATE TABLE sa.x_rp_ancillary_code_discount (
  ancillary_code VARCHAR2(5 BYTE) NOT NULL,
  brm_equivalent VARCHAR2(500 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  CONSTRAINT fk1_rp_ancillary_code_disc FOREIGN KEY (ancillary_code) REFERENCES sa.x_rp_ancillary_code (ancillary_code)
);