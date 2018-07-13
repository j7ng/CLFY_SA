CREATE TABLE sa.table_exch_timebomb (
  objid NUMBER,
  dev NUMBER,
  rsp_id NUMBER,
  bomb2exch_protocol NUMBER,
  bomb2act_entry NUMBER
);
ALTER TABLE sa.table_exch_timebomb ADD SUPPLEMENTAL LOG GROUP dmtsora630205385_0 (bomb2act_entry, bomb2exch_protocol, dev, objid, rsp_id) ALWAYS;