CREATE TABLE sa.table_rsrc (
  objid NUMBER,
  dev NUMBER,
  focus_type NUMBER,
  focus_lowid NUMBER,
  last_update DATE,
  rsrc_state NUMBER
);
ALTER TABLE sa.table_rsrc ADD SUPPLEMENTAL LOG GROUP dmtsora806661214_0 (dev, focus_lowid, focus_type, last_update, objid, rsrc_state) ALWAYS;
COMMENT ON TABLE sa.table_rsrc IS 'Represents availability of a resource, either queue or user, for assignment of routing requests';
COMMENT ON COLUMN sa.table_rsrc.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_rsrc.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_rsrc.focus_type IS 'Type ID of the resource; i.e., 4=queue, 20=user';
COMMENT ON COLUMN sa.table_rsrc.focus_lowid IS 'Internal record number of the resource';
COMMENT ON COLUMN sa.table_rsrc.last_update IS 'Date and time of last update to the rscr_state field';
COMMENT ON COLUMN sa.table_rsrc.rsrc_state IS 'State of the resource; i.e., 0=free; 1=busy, default=0. Used by routing server';