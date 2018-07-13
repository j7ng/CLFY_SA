CREATE TABLE sa.ll_subscribers (
  objid NUMBER NOT NULL,
  lid VARCHAR2(200 BYTE),
  old_lid VARCHAR2(200 BYTE),
  current_min VARCHAR2(30 BYTE),
  current_esn VARCHAR2(30 BYTE),
  ll_subs2contact NUMBER,
  ll_subs2web_user NUMBER,
  lastmodified DATE,
  enrollment_status VARCHAR2(30 BYTE),
  deenroll_reason VARCHAR2(300 BYTE),
  current_enrollment_date DATE,
  original_enrollment_date DATE,
  original_deenrollment_reason VARCHAR2(300 BYTE),
  current_ll_plan_id NUMBER,
  last_discount_dt DATE,
  projected_deenrollment DATE,
  full_name VARCHAR2(200 BYTE),
  address_1 VARCHAR2(200 BYTE),
  address_2 VARCHAR2(200 BYTE),
  city VARCHAR2(30 BYTE),
  "STATE" VARCHAR2(40 BYTE),
  zip VARCHAR2(20 BYTE),
  zip2 VARCHAR2(20 BYTE),
  e_mail VARCHAR2(80 BYTE),
  homenumber VARCHAR2(20 BYTE),
  allow_prerecorded VARCHAR2(1 BYTE),
  email_pref VARCHAR2(10 BYTE),
  last_av_date DATE,
  av_due_date DATE,
  qualify_date VARCHAR2(200 BYTE),
  qualify_type VARCHAR2(10 BYTE),
  external_account VARCHAR2(200 BYTE),
  stateidname VARCHAR2(40 BYTE),
  stateidvalue VARCHAR2(40 BYTE),
  adl VARCHAR2(50 BYTE),
  usacform VARCHAR2(50 BYTE),
  eligiblefirstname VARCHAR2(50 BYTE),
  eligiblelastname VARCHAR2(50 BYTE),
  eligiblemiddlenameinitial VARCHAR2(50 BYTE),
  hmodisclaimer VARCHAR2(1 BYTE),
  ipaddress VARCHAR2(30 BYTE),
  personid NUMBER,
  personisinvalid VARCHAR2(1 BYTE),
  stateagencyqualification VARCHAR2(1 BYTE),
  transferflag VARCHAR2(1 BYTE),
  qualify_programs VARCHAR2(800 BYTE),
  dobisinvalid VARCHAR2(1 BYTE),
  ssnisinvalid VARCHAR2(1 BYTE),
  addressiscommercial VARCHAR2(1 BYTE),
  addressisduplicated VARCHAR2(1 BYTE),
  addressisinvalid VARCHAR2(1 BYTE),
  addressistemporary VARCHAR2(1 BYTE),
  campaign VARCHAR2(100 BYTE),
  promotion VARCHAR2(50 BYTE),
  promocode VARCHAR2(50 BYTE),
  channel_type VARCHAR2(10 BYTE),
  last_modified_event VARCHAR2(50 BYTE),
  CONSTRAINT pk1_ll_subscribers PRIMARY KEY (objid)
);