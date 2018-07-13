CREATE TABLE sa.table_communication (
  objid NUMBER,
  dev NUMBER,
  title VARCHAR2(255 BYTE),
  s_title VARCHAR2(255 BYTE),
  "TEXT" LONG,
  creation_time DATE,
  direction NUMBER,
  to_list VARCHAR2(255 BYTE),
  from_address VARCHAR2(255 BYTE),
  delivery_status NUMBER,
  auto_exec_ind NUMBER,
  communication2dialogue NUMBER,
  communication2channel NUMBER,
  cmcn_respons2gbst_elm NUMBER,
  cmcn2template NUMBER
);
ALTER TABLE sa.table_communication ADD SUPPLEMENTAL LOG GROUP dmtsora577988433_0 (auto_exec_ind, cmcn2template, cmcn_respons2gbst_elm, communication2channel, communication2dialogue, creation_time, delivery_status, dev, direction, from_address, objid, s_title, title, to_list) ALWAYS;
COMMENT ON TABLE sa.table_communication IS 'Records an instance of a communication on a channel; e.g., a specific email';
COMMENT ON COLUMN sa.table_communication.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_communication.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_communication.title IS 'Title or subject of the communication';
COMMENT ON COLUMN sa.table_communication."TEXT" IS 'Text of the communication after conversion from any medium-specific data format';
COMMENT ON COLUMN sa.table_communication.creation_time IS 'Date and time the communication was created';
COMMENT ON COLUMN sa.table_communication.direction IS 'The direction of the communication; i.e., 0=unknown, 1=inbound, 2=outbound, 3=both, default=0';
COMMENT ON COLUMN sa.table_communication.to_list IS 'Contains the list of the TO addresses';
COMMENT ON COLUMN sa.table_communication.from_address IS 'For email, contains the email address of the sender';
COMMENT ON COLUMN sa.table_communication.delivery_status IS 'The delivery status of the communication; i.e., 0=draft, 1=pending, 2=sent, 3=received, 4=failed, 5=bounced, default=0';
COMMENT ON COLUMN sa.table_communication.auto_exec_ind IS 'Indicates if the communication was generated and sent without review; i.e., 0=no, suggested only, 1=yes, sent automatically, default=0. Derives from cl_action.auto_exec_ind at time of rule execution';
COMMENT ON COLUMN sa.table_communication.communication2dialogue IS 'Dialogue in which the communication occurred';
COMMENT ON COLUMN sa.table_communication.communication2channel IS 'Channel on which the communication occurred';
COMMENT ON COLUMN sa.table_communication.cmcn_respons2gbst_elm IS 'Requested response type of the communication';
COMMENT ON COLUMN sa.table_communication.cmcn2template IS 'For communications generated from a template, the template generated from';