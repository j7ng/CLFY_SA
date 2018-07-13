CREATE TABLE sa.stg_for_trigger (
  queue2user NUMBER(38) NOT NULL,
  user_assigned2queue NUMBER(38) NOT NULL,
  dt DATE,
  "ACTION" VARCHAR2(10 BYTE)
);