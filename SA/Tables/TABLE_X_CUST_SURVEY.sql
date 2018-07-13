CREATE TABLE sa.table_x_cust_survey (
  objid NUMBER,
  x_survey_question VARCHAR2(150 BYTE),
  x_survey_answer VARCHAR2(150 BYTE),
  x_cust_survey2contact NUMBER
);
ALTER TABLE sa.table_x_cust_survey ADD SUPPLEMENTAL LOG GROUP dmtsora339824110_0 (objid, x_cust_survey2contact, x_survey_answer, x_survey_question) ALWAYS;