CREATE TABLE sa.x_clarify_formats (
  format_type VARCHAR2(30 BYTE),
  x_value VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_clarify_formats IS 'ADDRESS FORMAT RULES TABLE';
COMMENT ON COLUMN sa.x_clarify_formats.format_type IS 'WHAT IS BEING FORMATTED';
COMMENT ON COLUMN sa.x_clarify_formats.x_value IS 'ITEM FORMAT';