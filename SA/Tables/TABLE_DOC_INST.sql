CREATE TABLE sa.table_doc_inst (
  objid NUMBER,
  title VARCHAR2(40 BYTE),
  deleted NUMBER,
  description VARCHAR2(255 BYTE),
  keywords VARCHAR2(255 BYTE),
  dev NUMBER,
  attachment2workaround NUMBER(*,0),
  attach_info2doc_path NUMBER(*,0),
  doc_info2diag_hint NUMBER(*,0),
  doc_inst2case NUMBER(*,0),
  doc_inst2bug NUMBER(*,0),
  doc_inst2subcase NUMBER(*,0),
  doc_inst2contract NUMBER(*,0),
  doc_inst2site NUMBER(*,0),
  doc_inst2site_part NUMBER(*,0),
  doc_inst2campaign NUMBER(*,0),
  doc_inst2eco_hdr NUMBER(*,0),
  doc_inst2eco_dtl NUMBER(*,0),
  doc_inst2interact NUMBER(*,0),
  doc_inst2bus_org NUMBER,
  doc_inst2contact NUMBER,
  doc_inst2demand_hdr NUMBER,
  doc_inst2email_log NUMBER,
  doc_inst2lead NUMBER,
  doc_inst2lit_req NUMBER,
  doc_inst2lit_ship_req NUMBER,
  doc_inst2mod_level NUMBER,
  doc_inst2opportunity NUMBER,
  doc_inst2communication NUMBER,
  doc_inst2template NUMBER
);
ALTER TABLE sa.table_doc_inst ADD SUPPLEMENTAL LOG GROUP dmtsora698513573_0 (attachment2workaround, attach_info2doc_path, deleted, description, dev, doc_info2diag_hint, doc_inst2bug, doc_inst2bus_org, doc_inst2campaign, doc_inst2case, doc_inst2communication, doc_inst2contact, doc_inst2contract, doc_inst2demand_hdr, doc_inst2eco_dtl, doc_inst2eco_hdr, doc_inst2email_log, doc_inst2interact, doc_inst2lead, doc_inst2lit_req, doc_inst2lit_ship_req, doc_inst2mod_level, doc_inst2opportunity, doc_inst2site, doc_inst2site_part, doc_inst2subcase, doc_inst2template, keywords, objid, title) ALWAYS;
COMMENT ON TABLE sa.table_doc_inst IS 'Defines instance of a document. It may be an attachment to a CR, case, contract, dianostic hint, site, part, subcase, or solution. It may be a publication';
COMMENT ON COLUMN sa.table_doc_inst.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_doc_inst.title IS 'Document title';
COMMENT ON COLUMN sa.table_doc_inst.deleted IS 'Indicates if document has been deleted. Reserved; future';
COMMENT ON COLUMN sa.table_doc_inst.description IS 'The description of the document';
COMMENT ON COLUMN sa.table_doc_inst.keywords IS 'Keywords for the document; used with FTS';
COMMENT ON COLUMN sa.table_doc_inst.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_doc_inst.attachment2workaround IS 'Workaround which is related to the document';
COMMENT ON COLUMN sa.table_doc_inst.attach_info2doc_path IS 'File path which is used to access the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_info2diag_hint IS 'Diagnostic hint related to the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2case IS 'Case related to the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2bug IS 'Change request related to the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2subcase IS 'Subcase which is related to the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2contract IS 'Contract related to the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2site IS 'Site which is related to the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2site_part IS 'Installed part which is related to the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2campaign IS 'Campaign using the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2eco_hdr IS 'ECO using the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2eco_dtl IS 'ECO details using the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2interact IS 'Interaction using the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2bus_org IS 'Account using the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2contact IS 'Contact having the attachment. Reserved; future';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2demand_hdr IS 'Part request header using the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2email_log IS 'Email having the attachment';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2lead IS 'Lead having the attachment';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2lit_req IS 'Literature request templates using the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2lit_ship_req IS 'Shipment containing the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2mod_level IS 'Part revision using the document';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2opportunity IS 'Opportunity having the attachment';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2communication IS 'Communication having the attachment';
COMMENT ON COLUMN sa.table_doc_inst.doc_inst2template IS 'Template having the attachment';