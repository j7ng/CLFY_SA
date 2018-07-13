CREATE TABLE sa.table_user_sit1_092413 (
  objid NUMBER,
  login_name VARCHAR2(50 BYTE),
  s_login_name VARCHAR2(50 BYTE),
  "PASSWORD" VARCHAR2(30 BYTE),
  agent_id VARCHAR2(30 BYTE),
  status NUMBER,
  equip_id VARCHAR2(30 BYTE),
  cs_lic DATE,
  csde_lic DATE,
  cq_lic DATE,
  passwd_chg DATE,
  last_login DATE,
  clfo_lic DATE,
  cs_lic_type NUMBER,
  cq_lic_type NUMBER,
  csfts_lic DATE,
  csftsde_lic DATE,
  cqfts_lic DATE,
  web_login VARCHAR2(30 BYTE),
  s_web_login VARCHAR2(30 BYTE),
  web_password VARCHAR2(30 BYTE),
  submitter_ind NUMBER,
  sfa_lic DATE,
  ccn_lic DATE,
  univ_lic DATE,
  node_id VARCHAR2(3 BYTE),
  dev NUMBER,
  locale NUMBER,
  user_access2privclass NUMBER(*,0),
  user_default2wipbin NUMBER(*,0),
  supvr_default2monitor NUMBER(*,0),
  user2rc_config NUMBER(*,0),
  user2srvr NUMBER(*,0),
  offline2privclass NUMBER(*,0),
  wireless_email VARCHAR2(80 BYTE),
  alt_login_name VARCHAR2(30 BYTE),
  s_alt_login_name VARCHAR2(30 BYTE),
  user2page_class NUMBER,
  web_last_login DATE,
  web_passwd_chg DATE,
  x_start_date DATE,
  x_end_date DATE
);