CREATE TABLE sa.smp_vdm_notification_nvpairs (
  sequence_num NUMBER(*,0),
  "NAME" VARCHAR2(256 BYTE),
  value_length NUMBER,
  "VALUE" LONG RAW
);
ALTER TABLE sa.smp_vdm_notification_nvpairs ADD SUPPLEMENTAL LOG GROUP dmtsora301835937_0 ("NAME", sequence_num, value_length) ALWAYS;