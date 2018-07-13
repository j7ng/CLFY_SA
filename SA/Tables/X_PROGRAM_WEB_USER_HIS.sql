CREATE TABLE sa.x_program_web_user_his (
  objid NUMBER,
  login_name VARCHAR2(30 BYTE),
  s_login_name VARCHAR2(30 BYTE),
  "PASSWORD" VARCHAR2(255 BYTE),
  user_key VARCHAR2(30 BYTE),
  status NUMBER,
  passwd_chg DATE,
  dev NUMBER,
  ship_via VARCHAR2(80 BYTE),
  x_secret_questn VARCHAR2(200 BYTE),
  s_x_secret_questn VARCHAR2(200 BYTE),
  x_secret_ans VARCHAR2(200 BYTE),
  s_x_secret_ans VARCHAR2(200 BYTE),
  web_user2user NUMBER,
  web_user2contact NUMBER,
  web_user2lead NUMBER,
  web_user2bus_org NUMBER
);
ALTER TABLE sa.x_program_web_user_his ADD SUPPLEMENTAL LOG GROUP dmtsora1645895036_0 (dev, login_name, objid, passwd_chg, "PASSWORD", ship_via, status, s_login_name, s_x_secret_ans, s_x_secret_questn, user_key, web_user2bus_org, web_user2contact, web_user2lead, web_user2user, x_secret_ans, x_secret_questn) ALWAYS;