CREATE TABLE sa.adfcrm_activity_log (
  objid NUMBER NOT NULL,
  esn VARCHAR2(30 BYTE),
  smp VARCHAR2(30 BYTE),
  agent VARCHAR2(50 BYTE),
  log_date DATE,
  flow_name VARCHAR2(100 BYTE),
  flow_description VARCHAR2(4000 BYTE),
  status VARCHAR2(50 BYTE),
  tbd_reason LONG,
  permission_name VARCHAR2(30 BYTE),
  call_id VARCHAR2(50 BYTE),
  reason VARCHAR2(4000 BYTE),
  cust_id VARCHAR2(80 BYTE),
  ani VARCHAR2(30 BYTE),
  source_system VARCHAR2(30 BYTE),
  new_cc_added_flag VARCHAR2(30 BYTE),
  CONSTRAINT adfcrm_activity_log_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.adfcrm_activity_log IS 'ALL LOG USER/AGENT ADFCRM ACTIVITIES';
COMMENT ON COLUMN sa.adfcrm_activity_log.objid IS 'USER SOURCE SYSTEM';
COMMENT ON COLUMN sa.adfcrm_activity_log.esn IS 'ESN USED IN THE ACTIVITY/FLOW';
COMMENT ON COLUMN sa.adfcrm_activity_log.smp IS 'SMP USED IN THE TRANSACTION';
COMMENT ON COLUMN sa.adfcrm_activity_log.agent IS 'AGENT NAME';
COMMENT ON COLUMN sa.adfcrm_activity_log.log_date IS 'LOG DATE';
COMMENT ON COLUMN sa.adfcrm_activity_log.flow_name IS 'NAME OF FLOW THAT IS BEING ACCESSED BY AGENT';
COMMENT ON COLUMN sa.adfcrm_activity_log.flow_description IS 'DESCRIPTION OF FLOW';
COMMENT ON COLUMN sa.adfcrm_activity_log.status IS 'SUCCESS/FAILED BASED ON AGENT AUTHORIZATION';
COMMENT ON COLUMN sa.adfcrm_activity_log.tbd_reason IS 'Old reason column - to delete at your prd dba discretion';
COMMENT ON COLUMN sa.adfcrm_activity_log.permission_name IS 'PERMISSION NAME USED IN THE FLOW';
COMMENT ON COLUMN sa.adfcrm_activity_log.call_id IS 'CTI INTEGRATION ID, PROVIDED BY IVR';
COMMENT ON COLUMN sa.adfcrm_activity_log.reason IS 'REASON TO PERFORM THE TRANSACTION';
COMMENT ON COLUMN sa.adfcrm_activity_log.new_cc_added_flag IS 'Flag indicates new Credit Card added';