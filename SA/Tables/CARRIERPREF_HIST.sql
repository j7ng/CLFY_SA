CREATE TABLE sa.carrierpref_hist (
  uniqueid VARCHAR2(20 BYTE),
  agent VARCHAR2(35 BYTE),
  datestamp DATE,
  action_text VARCHAR2(50 BYTE),
  st VARCHAR2(2 BYTE),
  county VARCHAR2(50 BYTE),
  carrier_id NUMBER,
  carrier_name VARCHAR2(255 BYTE),
  new_rank VARCHAR2(30 BYTE)
);
ALTER TABLE sa.carrierpref_hist ADD SUPPLEMENTAL LOG GROUP dmtsora167137294_0 (action_text, agent, carrier_id, carrier_name, county, datestamp, new_rank, st, uniqueid) ALWAYS;