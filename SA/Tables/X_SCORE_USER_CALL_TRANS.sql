CREATE TABLE sa.x_score_user_call_trans (
  call_trans2site_part NUMBER,
  x_call_trans2user NUMBER
);
ALTER TABLE sa.x_score_user_call_trans ADD SUPPLEMENTAL LOG GROUP dmtsora2084935075_0 (call_trans2site_part, x_call_trans2user) ALWAYS;