CREATE TABLE sa.past_due_error (
  esn VARCHAR2(11 BYTE),
  "MIN" VARCHAR2(10 BYTE),
  error_date DATE,
  error_msg VARCHAR2(100 BYTE)
);
ALTER TABLE sa.past_due_error ADD SUPPLEMENTAL LOG GROUP dmtsora413322727_0 (error_date, error_msg, esn, "MIN") ALWAYS;