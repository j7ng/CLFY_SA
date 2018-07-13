CREATE TABLE sa.mtm_x79telcom_tr1_x79mo_inst2 (
  rel2x79mo_inst NUMBER(*,0) NOT NULL,
  rel2x79telcom_tr NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_x79telcom_tr1_x79mo_inst2 ADD SUPPLEMENTAL LOG GROUP dmtsora1181236832_0 (rel2x79mo_inst, rel2x79telcom_tr) ALWAYS;