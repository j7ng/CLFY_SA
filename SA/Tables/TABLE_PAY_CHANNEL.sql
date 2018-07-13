CREATE TABLE sa.table_pay_channel (
  objid NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  dev NUMBER,
  last_update DATE,
  status VARCHAR2(20 BYTE),
  pc_child2bus_org NUMBER,
  pc_parent2bus_org NUMBER
);
ALTER TABLE sa.table_pay_channel ADD SUPPLEMENTAL LOG GROUP dmtsora779128642_0 (dev, last_update, "NAME", objid, pc_child2bus_org, pc_parent2bus_org, status, s_name) ALWAYS;
COMMENT ON TABLE sa.table_pay_channel IS 'Channel through which a customer requests a financial system to initiate payment collection on a regular basis';
COMMENT ON COLUMN sa.table_pay_channel.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_pay_channel."NAME" IS 'Name given to the pay channel, e.g. Personal, Business, Voice, Data etc';
COMMENT ON COLUMN sa.table_pay_channel.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_pay_channel.last_update IS 'Date time of last update';
COMMENT ON COLUMN sa.table_pay_channel.status IS 'Status of pay channel, e.g. Active, Close';
COMMENT ON COLUMN sa.table_pay_channel.pc_child2bus_org IS 'Organization this pay channel is managed';
COMMENT ON COLUMN sa.table_pay_channel.pc_parent2bus_org IS 'Parent organization this pay channel is managed';