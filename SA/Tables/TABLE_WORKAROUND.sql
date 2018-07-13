CREATE TABLE sa.table_workaround (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  description LONG,
  hits NUMBER,
  "ACTIONS" NUMBER,
  public_ind NUMBER,
  id_number VARCHAR2(32 BYTE),
  creation_time DATE,
  dev NUMBER,
  workaround2probdesc NUMBER(*,0),
  resolution2gbst_elm NUMBER(*,0)
);
ALTER TABLE sa.table_workaround ADD SUPPLEMENTAL LOG GROUP dmtsora1693245737_0 ("ACTIONS", creation_time, dev, hits, id_number, objid, public_ind, resolution2gbst_elm, title, workaround2probdesc) ALWAYS;
COMMENT ON TABLE sa.table_workaround IS 'Contains resolutions to a problem';
COMMENT ON COLUMN sa.table_workaround.objid IS 'Internal record ID number';
COMMENT ON COLUMN sa.table_workaround.title IS 'Title of resolution.  Reserved; future';
COMMENT ON COLUMN sa.table_workaround.description IS 'Description of workaround or resolution';
COMMENT ON COLUMN sa.table_workaround.hits IS 'Number of times resolution has been linked to a case';
COMMENT ON COLUMN sa.table_workaround."ACTIONS" IS 'Predefined actions to take. Reserved; future';
COMMENT ON COLUMN sa.table_workaround.public_ind IS 'The workaround is available for public view; i.e., 0=no, 1=yes, default=0, e.g., via Web Browser';
COMMENT ON COLUMN sa.table_workaround.id_number IS 'Unique ID number for the workaround; consists of solution number-#';
COMMENT ON COLUMN sa.table_workaround.creation_time IS 'The date and time the workaround was created';
COMMENT ON COLUMN sa.table_workaround.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_workaround.workaround2probdesc IS 'Solution the workaround is related to';
COMMENT ON COLUMN sa.table_workaround.resolution2gbst_elm IS 'Resolution classification: This is a Clarify-defined pop up list';