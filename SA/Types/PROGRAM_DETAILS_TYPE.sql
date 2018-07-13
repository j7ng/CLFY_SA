CREATE OR REPLACE TYPE sa.program_details_type FORCE AS OBJECT
(
  web_channel 	NUMBER,
  start_date	DATE,
  end_date		DATE,
  s_org_id		VARCHAR2(40)
);
-- ANTHILL_TEST PLSQL/SA/Types/program_details_type.sql 	CR55214: 1.2
/