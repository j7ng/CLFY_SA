CREATE TABLE sa.table_pay_chnl_extern (
  objid NUMBER,
  dev NUMBER,
  last_update DATE,
  ext_src VARCHAR2(30 BYTE),
  ext_ref VARCHAR2(64 BYTE),
  pay_chnl_extern2pay_channel NUMBER
);
ALTER TABLE sa.table_pay_chnl_extern ADD SUPPLEMENTAL LOG GROUP dmtsora781987927_0 (dev, ext_ref, ext_src, last_update, objid, pay_chnl_extern2pay_channel) ALWAYS;