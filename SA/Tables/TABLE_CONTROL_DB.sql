CREATE TABLE sa.table_control_db (
  objid NUMBER,
  "TYPE" NUMBER,
  "ID" NUMBER,
  title VARCHAR2(255 BYTE),
  top_c NUMBER,
  bottom_c NUMBER,
  left_c NUMBER,
  right_c NUMBER,
  from_side NUMBER,
  to_ctrl_id NUMBER,
  same_side NUMBER,
  justification NUMBER,
  flags NUMBER,
  vlink_name VARCHAR2(80 BYTE),
  vlink_fld NUMBER,
  vlink_dtype NUMBER,
  tlink_name VARCHAR2(80 BYTE),
  tlink_fld NUMBER,
  tlink_dtype NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  intval1 NUMBER,
  intval2 NUMBER,
  intval3 NUMBER,
  intval4 NUMBER,
  value1 VARCHAR2(255 BYTE),
  value2 VARCHAR2(255 BYTE),
  win_id NUMBER,
  function_id NUMBER,
  description VARCHAR2(255 BYTE),
  dimmable NUMBER,
  vlink_fld_name VARCHAR2(80 BYTE),
  tlink_fld_name VARCHAR2(80 BYTE),
  dev NUMBER,
  flags2 NUMBER,
  backcolor NUMBER,
  forecolor NUMBER,
  font VARCHAR2(80 BYTE),
  control2window_db NUMBER(*,0),
  value3 VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_control_db ADD SUPPLEMENTAL LOG GROUP dmtsora1942738167_0 (bottom_c, description, dev, dimmable, flags, from_side, function_id, "ID", intval1, intval2, intval3, intval4, justification, left_c, "NAME", objid, right_c, same_side, title, tlink_dtype, tlink_fld, tlink_fld_name, tlink_name, top_c, to_ctrl_id, "TYPE", value1, value2, vlink_dtype, vlink_fld, vlink_fld_name, vlink_name, win_id) ALWAYS;
ALTER TABLE sa.table_control_db ADD SUPPLEMENTAL LOG GROUP dmtsora1942738167_1 (backcolor, control2window_db, flags2, font, forecolor, value3) ALWAYS;
COMMENT ON TABLE sa.table_control_db IS 'A control appearing on a Clarify form; used with privilege class mechanism to indicate that a control is disabled for particular privilege classes';
COMMENT ON COLUMN sa.table_control_db.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_control_db."TYPE" IS 'Type of control; e.g., menubutton, button, etc';
COMMENT ON COLUMN sa.table_control_db."ID" IS 'Control ID in .dat file';
COMMENT ON COLUMN sa.table_control_db.title IS 'Displayed label of the control';
COMMENT ON COLUMN sa.table_control_db.top_c IS 'Top boundary of the control';
COMMENT ON COLUMN sa.table_control_db.bottom_c IS 'Bottom boundary of the control';
COMMENT ON COLUMN sa.table_control_db.left_c IS 'Left boundary of the control';
COMMENT ON COLUMN sa.table_control_db.right_c IS 'Right boundary of the control';
COMMENT ON COLUMN sa.table_control_db.from_side IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_control_db.to_ctrl_id IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_control_db.same_side IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_control_db.justification IS 'Indicates left, right or center justification of the control s label';
COMMENT ON COLUMN sa.table_control_db.flags IS 'Stores a control s attribute in bitmap form; e.g., readonly, visible';
COMMENT ON COLUMN sa.table_control_db.vlink_name IS 'Title of the control s (destination link) contextual object';
COMMENT ON COLUMN sa.table_control_db.vlink_fld IS 'Stores the field ID of the control s database field (or temporary data structure). It is a field belonging to the contextual object that is referenced by title in the vlink_name field';
COMMENT ON COLUMN sa.table_control_db.vlink_dtype IS 'Data type of the control s value link (destination link) to the contextual object';
COMMENT ON COLUMN sa.table_control_db.tlink_name IS 'Name of the control s title (source link) contextual object';
COMMENT ON COLUMN sa.table_control_db.tlink_fld IS 'Field name of the control s title (source link) contextual object';
COMMENT ON COLUMN sa.table_control_db.tlink_dtype IS 'Data type of the control s title (source link) contextual object';
COMMENT ON COLUMN sa.table_control_db."NAME" IS 'Name of the control';
COMMENT ON COLUMN sa.table_control_db.intval1 IS 'Multi-purpose integer attribute; use depends on type of control';
COMMENT ON COLUMN sa.table_control_db.intval2 IS 'Additional multi-purpose integer attribute; use depends on type of control';
COMMENT ON COLUMN sa.table_control_db.intval3 IS 'Additional multi-purpose integer attribute; use depends on type of control';
COMMENT ON COLUMN sa.table_control_db.intval4 IS 'Additional multi-purpose integer attribute; use depends on type of control';
COMMENT ON COLUMN sa.table_control_db.value1 IS 'Multipurpose string attribute for a control s string value; use depends on the control';
COMMENT ON COLUMN sa.table_control_db.value2 IS 'Second multipurpose string attribute for a control s string value; use depends on the control';
COMMENT ON COLUMN sa.table_control_db.win_id IS 'ID of form in which the control appears';
COMMENT ON COLUMN sa.table_control_db.function_id IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_control_db.description IS 'Description of the purpose/use of the control; currently used only for buttons to indicate access restriction by privilege class';
COMMENT ON COLUMN sa.table_control_db.dimmable IS 'Indicates whether the item can be dimmed by the user; i.e., 0=dimmable, 1=not dimmable';
COMMENT ON COLUMN sa.table_control_db.vlink_fld_name IS 'Field name of the contextual object the control is value linked to';
COMMENT ON COLUMN sa.table_control_db.tlink_fld_name IS 'Field name of the contextual object the control is title linked to';
COMMENT ON COLUMN sa.table_control_db.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_control_db.flags2 IS 'Stores additional bitmapped control attributes';
COMMENT ON COLUMN sa.table_control_db.backcolor IS 'Value of the background color assigned to the control';
COMMENT ON COLUMN sa.table_control_db.forecolor IS 'Value of the foreground color assigned to the control';
COMMENT ON COLUMN sa.table_control_db.font IS 'The font assigned to the control';
COMMENT ON COLUMN sa.table_control_db.value3 IS 'Stores an edit mask for a control';