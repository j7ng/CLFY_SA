CREATE TABLE sa.table_keyphrase (
  objid NUMBER,
  "RANK" NUMBER,
  last_mod_time DATE,
  dev NUMBER,
  keyphrase2prtkp_subc NUMBER(*,0),
  keyphrase2gb_kp NUMBER(*,0)
);
ALTER TABLE sa.table_keyphrase ADD SUPPLEMENTAL LOG GROUP dmtsora1782330265_0 (dev, keyphrase2gb_kp, keyphrase2prtkp_subc, last_mod_time, objid, "RANK") ALWAYS;
COMMENT ON TABLE sa.table_keyphrase IS 'Part keyphrase object';
COMMENT ON COLUMN sa.table_keyphrase.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_keyphrase."RANK" IS 'Presentation rank of the keyphrase; used for user interface';
COMMENT ON COLUMN sa.table_keyphrase.last_mod_time IS 'Time and date of last modification';
COMMENT ON COLUMN sa.table_keyphrase.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_keyphrase.keyphrase2prtkp_subc IS 'The part keyphrase sub-category that includes the part keyphrase';
COMMENT ON COLUMN sa.table_keyphrase.keyphrase2gb_kp IS 'Global keyphrase related to the part keyphrase';