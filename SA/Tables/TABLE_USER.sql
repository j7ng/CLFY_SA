CREATE TABLE sa.table_user (
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
ALTER TABLE sa.table_user ADD SUPPLEMENTAL LOG GROUP dmtsora252566411_0 (agent_id, ccn_lic, clfo_lic, cqfts_lic, cq_lic, cq_lic_type, csde_lic, csftsde_lic, csfts_lic, cs_lic, cs_lic_type, dev, equip_id, last_login, locale, login_name, node_id, objid, passwd_chg, "PASSWORD", sfa_lic, status, submitter_ind, supvr_default2monitor, s_login_name, s_web_login, univ_lic, user2rc_config, user2srvr, user_access2privclass, user_default2wipbin, web_login, web_password) ALWAYS;
ALTER TABLE sa.table_user ADD SUPPLEMENTAL LOG GROUP dmtsora252566411_1 (alt_login_name, offline2privclass, s_alt_login_name, user2page_class, wireless_email) ALWAYS;
COMMENT ON TABLE sa.table_user IS 'System object; defines a database user with login name and password';
COMMENT ON COLUMN sa.table_user.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_user.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_user."PASSWORD" IS 'User password';
COMMENT ON COLUMN sa.table_user.agent_id IS 'Used by ACD to identify agent number';
COMMENT ON COLUMN sa.table_user.status IS 'User status; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_user.equip_id IS 'Used by ACD to identify telephone set ID';
COMMENT ON COLUMN sa.table_user.cs_lic IS 'Date/time ClearSupport License checked out';
COMMENT ON COLUMN sa.table_user.csde_lic IS 'Date/time ClearSupport Diagnosis Engine License checked out';
COMMENT ON COLUMN sa.table_user.cq_lic IS 'Date/time ClearQuality License checked out';
COMMENT ON COLUMN sa.table_user.passwd_chg IS 'Date/Time password was last changed; used to check for expiration of password';
COMMENT ON COLUMN sa.table_user.last_login IS 'Date/Time of last successful login by the user';
COMMENT ON COLUMN sa.table_user.clfo_lic IS 'Date/timeClear Logistics License checked out';
COMMENT ON COLUMN sa.table_user.cs_lic_type IS '0=CS, 1=CS-DE, 2=CS-FTS, 3=CS-FTS-DE';
COMMENT ON COLUMN sa.table_user.cq_lic_type IS '0=CQ, 1=CQ-FTS';
COMMENT ON COLUMN sa.table_user.csfts_lic IS 'Date/time ClearSupport Full Text Search License checked out';
COMMENT ON COLUMN sa.table_user.csftsde_lic IS 'Date/time ClearSupport Full Text Search and DE License checked out';
COMMENT ON COLUMN sa.table_user.cqfts_lic IS 'Reserved; internal';
COMMENT ON COLUMN sa.table_user.web_login IS 'User s Web login name. Reserved; not used';
COMMENT ON COLUMN sa.table_user.web_password IS 'User s Web password. Reserved; not used';
COMMENT ON COLUMN sa.table_user.submitter_ind IS 'User has Web submitter privileges; i.e., 0=no, 1=yes. Reserved; not used';
COMMENT ON COLUMN sa.table_user.sfa_lic IS 'Date/time ClearSales License checked out';
COMMENT ON COLUMN sa.table_user.ccn_lic IS 'Date/time Sales Force Automation License checked out';
COMMENT ON COLUMN sa.table_user.univ_lic IS 'Date/time Universal License checked out';
COMMENT ON COLUMN sa.table_user.node_id IS 'Base36 string representation of Node ID. Used by distribution engine';
COMMENT ON COLUMN sa.table_user.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_user.locale IS 'Preferred language for receiving communications from the system; i.e., 0=English, 1=SJIS, 2=French, 3=German, 4=Spanish, 5=Chinese Big5 (traditional character), 6=Chinese GB (simplified character), 7=Korean, 8-12 (Reserved), Default=0';
COMMENT ON COLUMN sa.table_user.user_access2privclass IS 'User s privilege class';
COMMENT ON COLUMN sa.table_user.user_default2wipbin IS 'User s default WIPbin';
COMMENT ON COLUMN sa.table_user.supvr_default2monitor IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_user.user2rc_config IS 'User s resource config';
COMMENT ON COLUMN sa.table_user.user2srvr IS 'Home server of the user. Reserved';
COMMENT ON COLUMN sa.table_user.offline2privclass IS 'Offline privclass for the user';
COMMENT ON COLUMN sa.table_user.wireless_email IS 'User s wireless email address';
COMMENT ON COLUMN sa.table_user.alt_login_name IS 'Alternate systems login name';
COMMENT ON COLUMN sa.table_user.user2page_class IS 'User s resource configuration';
COMMENT ON COLUMN sa.table_user.x_start_date IS 'SIMPLE MOBILE DEALER/AGENT CREATION DATE';
COMMENT ON COLUMN sa.table_user.x_end_date IS 'SIMPLE MOBILE DEALER/AGENT EXPIRATION DATE';