CREATE TABLE sa.x_free_voice_mail (
  x_fvm_status NUMBER,
  x_fvm_time_stamp DATE,
  x_fvm_number VARCHAR2(30 BYTE),
  free_vm2part_inst NUMBER
);
ALTER TABLE sa.x_free_voice_mail ADD SUPPLEMENTAL LOG GROUP dmtsora821727198_0 (free_vm2part_inst, x_fvm_number, x_fvm_status, x_fvm_time_stamp) ALWAYS;