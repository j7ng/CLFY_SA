CREATE TABLE sa.table_disptchfe (
  objid NUMBER,
  disptime DATE,
  work_order VARCHAR2(80 BYTE),
  appointment DATE,
  duration NUMBER,
  description VARCHAR2(255 BYTE),
  cont_fname VARCHAR2(30 BYTE),
  cont_lname VARCHAR2(30 BYTE),
  address1 VARCHAR2(200 BYTE),
  address2 VARCHAR2(200 BYTE),
  city VARCHAR2(30 BYTE),
  "STATE" VARCHAR2(30 BYTE),
  zip VARCHAR2(20 BYTE),
  main_phone VARCHAR2(20 BYTE),
  alt_phone VARCHAR2(20 BYTE),
  pay_method VARCHAR2(30 BYTE),
  ref_number VARCHAR2(80 BYTE),
  notes LONG,
  requested_eta DATE,
  appt_confirm NUMBER,
  cell_text VARCHAR2(255 BYTE),
  dev NUMBER,
  disptchfe2case NUMBER(*,0),
  disptchfe_orig2user NUMBER(*,0),
  disptchfe2fcs_detail NUMBER(*,0),
  disptchfe2subcase NUMBER(*,0)
);
ALTER TABLE sa.table_disptchfe ADD SUPPLEMENTAL LOG GROUP dmtsora1721861303_0 (address1, address2, alt_phone, appointment, appt_confirm, cell_text, city, cont_fname, cont_lname, description, dev, disptchfe2case, disptchfe2fcs_detail, disptchfe2subcase, disptchfe_orig2user, disptime, duration, main_phone, objid, pay_method, ref_number, requested_eta, "STATE", work_order, zip) ALWAYS;
COMMENT ON TABLE sa.table_disptchfe IS 'Dispatch Engineer object which contains all the info required for the field engineer to perform a task at a customer site.  Site and contact info comes from the case, but can be edited and is stored locally on the object';
COMMENT ON COLUMN sa.table_disptchfe.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_disptchfe.disptime IS 'Date and time the dispatch engineer object was created';
COMMENT ON COLUMN sa.table_disptchfe.work_order IS 'Work order number entered by the user';
COMMENT ON COLUMN sa.table_disptchfe.appointment IS 'Proposed date/time of scheduled appointment or commitment';
COMMENT ON COLUMN sa.table_disptchfe.duration IS 'Expected/actual amount of time to complete the task in seconds';
COMMENT ON COLUMN sa.table_disptchfe.description IS 'Task description';
COMMENT ON COLUMN sa.table_disptchfe.cont_fname IS 'Contact first name';
COMMENT ON COLUMN sa.table_disptchfe.cont_lname IS 'Contact last name';
COMMENT ON COLUMN sa.table_disptchfe.address1 IS 'Line one of street address of site at which FE is to perform work';
COMMENT ON COLUMN sa.table_disptchfe.address2 IS 'Line two of street address of site at which FE is to perform work';
COMMENT ON COLUMN sa.table_disptchfe.city IS 'City where site is located';
COMMENT ON COLUMN sa.table_disptchfe."STATE" IS 'State where site is located';
COMMENT ON COLUMN sa.table_disptchfe.zip IS 'Site zip or other postal code';
COMMENT ON COLUMN sa.table_disptchfe.main_phone IS 'Contact main phone number';
COMMENT ON COLUMN sa.table_disptchfe.alt_phone IS 'Contact alternate phone number';
COMMENT ON COLUMN sa.table_disptchfe.pay_method IS 'Method of payment for the service; e.g., credit card, PO, etc';
COMMENT ON COLUMN sa.table_disptchfe.ref_number IS 'Reference number for payment method; e.g., PO number, etc';
COMMENT ON COLUMN sa.table_disptchfe.notes IS 'Notes describing additional information needed by the engineer to complete the task';
COMMENT ON COLUMN sa.table_disptchfe.requested_eta IS 'Requested date and time of field engineer s arrival at dispatch site';
COMMENT ON COLUMN sa.table_disptchfe.appt_confirm IS '0=unconfirmed, 1=confirmed, default=0';
COMMENT ON COLUMN sa.table_disptchfe.cell_text IS 'Contains a concatination of locally-selected fields for display by Schedule Tracker. Default is field case.id_number';
COMMENT ON COLUMN sa.table_disptchfe.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_disptchfe.disptchfe2case IS 'Case for the field engineer dispatch';
COMMENT ON COLUMN sa.table_disptchfe.disptchfe_orig2user IS 'User that originated the dispatch';
COMMENT ON COLUMN sa.table_disptchfe.disptchfe2fcs_detail IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_disptchfe.disptchfe2subcase IS 'Subcase for the field engineer dispatch';