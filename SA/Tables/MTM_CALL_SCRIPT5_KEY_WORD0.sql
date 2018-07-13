CREATE TABLE sa.mtm_call_script5_key_word0 (
  scr2key_word NUMBER(*,0) NOT NULL,
  key_word2call_script NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_call_script5_key_word0 ADD SUPPLEMENTAL LOG GROUP dmtsora1167425923_0 (key_word2call_script, scr2key_word) ALWAYS;