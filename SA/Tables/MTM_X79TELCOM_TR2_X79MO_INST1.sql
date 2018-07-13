CREATE TABLE sa.mtm_x79telcom_tr2_x79mo_inst1 (
  sus2x79mo_inst NUMBER(*,0) NOT NULL,
  sus2x79telcom_tr NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_x79telcom_tr2_x79mo_inst1 ADD SUPPLEMENTAL LOG GROUP dmtsora1022913168_0 (sus2x79mo_inst, sus2x79telcom_tr) ALWAYS;