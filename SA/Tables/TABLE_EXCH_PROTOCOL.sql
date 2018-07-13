CREATE TABLE sa.table_exch_protocol (
  objid NUMBER,
  server_id NUMBER,
  server_name VARCHAR2(40 BYTE),
  dflt_mode NUMBER,
  "ACTIVE" NUMBER,
  live_ind NUMBER,
  protocol NUMBER,
  exch_protocol NUMBER,
  ip_address VARCHAR2(15 BYTE),
  port VARCHAR2(10 BYTE),
  create_date DATE,
  modify_date DATE,
  comm_param_0 VARCHAR2(255 BYTE),
  comm_param_1 VARCHAR2(255 BYTE),
  comm_param_2 VARCHAR2(255 BYTE),
  comm_param_3 VARCHAR2(255 BYTE),
  dev NUMBER,
  protocol2exch_cat NUMBER(*,0),
  clfy_site_ind NUMBER,
  cstm_schm_ind NUMBER,
  routing_mode NUMBER
);
ALTER TABLE sa.table_exch_protocol ADD SUPPLEMENTAL LOG GROUP dmtsora964078381_0 ("ACTIVE", clfy_site_ind, comm_param_0, comm_param_1, comm_param_2, comm_param_3, create_date, cstm_schm_ind, dev, dflt_mode, exch_protocol, ip_address, live_ind, modify_date, objid, port, protocol, protocol2exch_cat, routing_mode, server_id, server_name) ALWAYS;
COMMENT ON TABLE sa.table_exch_protocol IS 'Describes each exchange partners data exchange and communication protocols. Also defines the channel to reach an external partner';
COMMENT ON COLUMN sa.table_exch_protocol.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_exch_protocol.server_id IS 'Server ID number';
COMMENT ON COLUMN sa.table_exch_protocol.server_name IS 'Server logical name';
COMMENT ON COLUMN sa.table_exch_protocol.dflt_mode IS 'Default exchange mode; i.e., 0=unknown, 1=transfer, 2=collaborative';
COMMENT ON COLUMN sa.table_exch_protocol."ACTIVE" IS 'Current status of the exchange partner; i.e., 0=inactive, 1=active, 2=pending';
COMMENT ON COLUMN sa.table_exch_protocol.live_ind IS 'Status of the server; i.e., 0=down, 1=up';
COMMENT ON COLUMN sa.table_exch_protocol.protocol IS 'Communication exchange protocol: i.e., 0=DCOM, 1=CORBA, 2=MSMQ, 3=HTTP';
COMMENT ON COLUMN sa.table_exch_protocol.exch_protocol IS 'Exchange standard protocol: i.e., 0=Clarify, 1=Z790, 2=CSC';
COMMENT ON COLUMN sa.table_exch_protocol.ip_address IS 'IP address to be used';
COMMENT ON COLUMN sa.table_exch_protocol.port IS 'Port address';
COMMENT ON COLUMN sa.table_exch_protocol.create_date IS 'The date and time the object was created';
COMMENT ON COLUMN sa.table_exch_protocol.modify_date IS 'The date and time the object was last modified';
COMMENT ON COLUMN sa.table_exch_protocol.comm_param_0 IS 'Communications parameter used in processing the exchange';
COMMENT ON COLUMN sa.table_exch_protocol.comm_param_1 IS 'Communications parameter used in processing the exchange';
COMMENT ON COLUMN sa.table_exch_protocol.comm_param_2 IS 'Communications parameter used in processing the exchange';
COMMENT ON COLUMN sa.table_exch_protocol.comm_param_3 IS 'Communications parameter used in processing the exchange';
COMMENT ON COLUMN sa.table_exch_protocol.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_exch_protocol.protocol2exch_cat IS 'Related exchange category';
COMMENT ON COLUMN sa.table_exch_protocol.clfy_site_ind IS 'Indicates whether the target site is a clarify installation; i.e., 0=no, 1=yes, default=1';
COMMENT ON COLUMN sa.table_exch_protocol.cstm_schm_ind IS 'Indicates whether the target site will understand customized Vendor Interchange schema, i.e., X.790 conditional packages; i.e, 0=no, 1=yes, default=1';
COMMENT ON COLUMN sa.table_exch_protocol.routing_mode IS 'Controls automated routing of create requests i.e., 0=none, 1=pending intervention), 2=unattended (route all create requests to service provider), 3=attended, default=0';