CREATE TABLE sa.table_gbst_elm (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  "RANK" NUMBER,
  "STATE" NUMBER,
  description VARCHAR2(255 BYTE),
  dev NUMBER,
  gbst_elm2gbst_lst NUMBER(*,0),
  addnl_info VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_gbst_elm ADD SUPPLEMENTAL LOG GROUP dmtsora1546711086_0 (addnl_info, description, dev, gbst_elm2gbst_lst, objid, "RANK", "STATE", s_title, title) ALWAYS;
COMMENT ON TABLE sa.table_gbst_elm IS 'Defines a Clarify (Global String) element; Defines the ClearSupport and ClearQuality status Code and pop up list items <does not include user-defined pop up lists>; used with object 78, which defines the lists themselves';
COMMENT ON COLUMN sa.table_gbst_elm.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_gbst_elm.title IS 'Name of the item/element';
COMMENT ON COLUMN sa.table_gbst_elm."RANK" IS 'Position of the item in the list; important in tracking scheduled/unscheduled and config time for service interuption report';
COMMENT ON COLUMN sa.table_gbst_elm."STATE" IS 'State/status of the item; i.e., 0=Active, 1=inactive, 2=Default';
COMMENT ON COLUMN sa.table_gbst_elm.description IS 'Long description of the item';
COMMENT ON COLUMN sa.table_gbst_elm.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_gbst_elm.gbst_elm2gbst_lst IS 'Global String list to which the element belongs';
COMMENT ON COLUMN sa.table_gbst_elm.addnl_info IS 'Additional application-specific control data used to process the element';