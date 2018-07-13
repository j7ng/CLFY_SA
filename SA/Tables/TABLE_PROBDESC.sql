CREATE TABLE sa.table_probdesc (
  objid NUMBER,
  title VARCHAR2(255 BYTE),
  s_title VARCHAR2(255 BYTE),
  creation_time DATE,
  description LONG,
  rating NUMBER,
  hits NUMBER,
  solns NUMBER,
  id_number VARCHAR2(32 BYTE),
  yank_flag NUMBER,
  ownership_stmp DATE,
  modify_stmp DATE,
  dist NUMBER,
  public_ind NUMBER,
  dev NUMBER,
  probdesc_owner2user NUMBER(*,0),
  probdesc_orig2user NUMBER(*,0),
  probdesc2condition NUMBER(*,0),
  probdesc_q2queue NUMBER(*,0),
  probdesc_wip2wipbin NUMBER(*,0),
  probdesc_prevq2queue NUMBER(*,0)
);
ALTER TABLE sa.table_probdesc ADD SUPPLEMENTAL LOG GROUP dmtsora282550475_0 (creation_time, dev, dist, hits, id_number, modify_stmp, objid, ownership_stmp, probdesc2condition, probdesc_orig2user, probdesc_owner2user, probdesc_prevq2queue, probdesc_q2queue, probdesc_wip2wipbin, public_ind, rating, solns, s_title, title, yank_flag) ALWAYS;
COMMENT ON TABLE sa.table_probdesc IS 'Solution object:  Description of known solutions';
COMMENT ON COLUMN sa.table_probdesc.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_probdesc.title IS 'Solution title -describes main details of the solution';
COMMENT ON COLUMN sa.table_probdesc.creation_time IS 'Date and time the solution was created';
COMMENT ON COLUMN sa.table_probdesc.description IS 'Full description of the solution';
COMMENT ON COLUMN sa.table_probdesc.rating IS 'Solution rating';
COMMENT ON COLUMN sa.table_probdesc.hits IS 'Number of times the solution has been linked to a case';
COMMENT ON COLUMN sa.table_probdesc.solns IS 'Number of resolutions for the solution. Reserved; not used';
COMMENT ON COLUMN sa.table_probdesc.id_number IS 'Unique ID number for the solution; assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_probdesc.yank_flag IS 'Indicates whether solution is being modified externally. Reserved; not used';
COMMENT ON COLUMN sa.table_probdesc.ownership_stmp IS 'The date and time when ownership changes';
COMMENT ON COLUMN sa.table_probdesc.modify_stmp IS 'The date and time when object is saved';
COMMENT ON COLUMN sa.table_probdesc.dist IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_probdesc.public_ind IS 'Indicates whether the solution is available for public view (i.e., 0=no, 1=yes, default=0) and via which method (e.g., WebBrowser)';
COMMENT ON COLUMN sa.table_probdesc.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_probdesc.probdesc_owner2user IS 'Owner of the solution';
COMMENT ON COLUMN sa.table_probdesc.probdesc_orig2user IS 'Originator of the solution';
COMMENT ON COLUMN sa.table_probdesc.probdesc2condition IS 'Condition of the solution';
COMMENT ON COLUMN sa.table_probdesc.probdesc_q2queue IS 'Queue the solution is dispatched to';
COMMENT ON COLUMN sa.table_probdesc.probdesc_wip2wipbin IS 'Wipbin into which the soluction is accepted';
COMMENT ON COLUMN sa.table_probdesc.probdesc_prevq2queue IS 'Immediately prior queue the solution was dispatched to; used in temporary accept feature';