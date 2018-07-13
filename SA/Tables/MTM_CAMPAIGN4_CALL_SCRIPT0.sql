CREATE TABLE sa.mtm_campaign4_call_script0 (
  campaign2call_script NUMBER(*,0) NOT NULL,
  scr2campaign NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_campaign4_call_script0 ADD SUPPLEMENTAL LOG GROUP dmtsora919646638_0 (campaign2call_script, scr2campaign) ALWAYS;