CREATE TABLE sa.ll_subscribers_hist (
  objid NUMBER NOT NULL,
  ll_hist2ll_subs NUMBER,
  lid VARCHAR2(200 BYTE),
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  username VARCHAR2(30 BYTE),
  sourcesystem VARCHAR2(30 BYTE),
  event_insert DATE,
  event_update DATE,
  event_code VARCHAR2(20 BYTE),
  event_notes VARCHAR2(300 BYTE),
  sp_objid NUMBER,
  ll_plan_id NUMBER,
  smp VARCHAR2(30 BYTE),
  call_trans_objid NUMBER,
  CONSTRAINT pk1_ll_subscribers_hist PRIMARY KEY (objid)
);