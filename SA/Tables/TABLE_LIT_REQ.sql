CREATE TABLE sa.table_lit_req (
  objid NUMBER,
  dev NUMBER,
  lit_req_id VARCHAR2(40 BYTE),
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  comments VARCHAR2(255 BYTE),
  create_date DATE,
  required_date DATE,
  fulfilled_date DATE,
  ship_via VARCHAR2(20 BYTE),
  lit_owner2user NUMBER,
  lit_orig2user NUMBER,
  lit_send2gbst_elm NUMBER,
  lit_status2gbst_elm NUMBER
);
ALTER TABLE sa.table_lit_req ADD SUPPLEMENTAL LOG GROUP dmtsora2047699160_0 (comments, create_date, dev, fulfilled_date, lit_orig2user, lit_owner2user, lit_req_id, lit_send2gbst_elm, lit_status2gbst_elm, objid, required_date, ship_via, s_title, title) ALWAYS;
COMMENT ON TABLE sa.table_lit_req IS 'Header template for the shipment (see lit_ship_req) of a literature request';
COMMENT ON COLUMN sa.table_lit_req.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_lit_req.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_lit_req.lit_req_id IS 'Unique ID number of the template; assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_lit_req.title IS 'Title of the literature request';
COMMENT ON COLUMN sa.table_lit_req.comments IS 'Comments about the literature request';
COMMENT ON COLUMN sa.table_lit_req.create_date IS 'Date the template was created';
COMMENT ON COLUMN sa.table_lit_req.required_date IS 'Date that shipment to the addressees is required (lit_ship_req)';
COMMENT ON COLUMN sa.table_lit_req.fulfilled_date IS 'Date that shipment to the addressees was completed';
COMMENT ON COLUMN sa.table_lit_req.ship_via IS 'Requested means of shipment. This is from a Clarify-defined popup list with default name SHIP_VIA';
COMMENT ON COLUMN sa.table_lit_req.lit_owner2user IS 'User owning the template';
COMMENT ON COLUMN sa.table_lit_req.lit_orig2user IS 'User originating the template';
COMMENT ON COLUMN sa.table_lit_req.lit_send2gbst_elm IS 'The sending method for the template';
COMMENT ON COLUMN sa.table_lit_req.lit_status2gbst_elm IS 'The status of the template';