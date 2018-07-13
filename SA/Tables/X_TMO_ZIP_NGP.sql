CREATE TABLE sa.x_tmo_zip_ngp (
  x_zip VARCHAR2(5 BYTE),
  x_ngp VARCHAR2(30 BYTE),
  x_ngp_name VARCHAR2(255 BYTE),
  x_priority NUMBER
);
COMMENT ON COLUMN sa.x_tmo_zip_ngp.x_zip IS 'Zip code';
COMMENT ON COLUMN sa.x_tmo_zip_ngp.x_ngp IS 'ngp value';
COMMENT ON COLUMN sa.x_tmo_zip_ngp.x_ngp_name IS 'ngp name';
COMMENT ON COLUMN sa.x_tmo_zip_ngp.x_priority IS 'Priority';