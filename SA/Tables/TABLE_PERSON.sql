CREATE TABLE sa.table_person (
  objid NUMBER,
  first_name VARCHAR2(30 BYTE),
  s_first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  s_last_name VARCHAR2(30 BYTE),
  phone VARCHAR2(20 BYTE),
  middle_name VARCHAR2(30 BYTE),
  suffix VARCHAR2(25 BYTE),
  salutation VARCHAR2(25 BYTE),
  title VARCHAR2(80 BYTE),
  title_cat VARCHAR2(25 BYTE),
  family_info VARCHAR2(255 BYTE),
  birthday DATE,
  comments VARCHAR2(255 BYTE),
  dev NUMBER,
  person2contact NUMBER(*,0),
  person2employee NUMBER(*,0)
);
ALTER TABLE sa.table_person ADD SUPPLEMENTAL LOG GROUP dmtsora1095191210_0 (birthday, comments, dev, family_info, first_name, last_name, middle_name, objid, person2contact, person2employee, phone, salutation, suffix, s_first_name, s_last_name, title, title_cat) ALWAYS;
COMMENT ON TABLE sa.table_person IS 'Person supertype object. Reserved; not used';
COMMENT ON COLUMN sa.table_person.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_person.first_name IS 'Person s first name';
COMMENT ON COLUMN sa.table_person.last_name IS 'Person s last name';
COMMENT ON COLUMN sa.table_person.phone IS 'Person s phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_person.middle_name IS 'Person s middle name';
COMMENT ON COLUMN sa.table_person.suffix IS 'Suffix for the person';
COMMENT ON COLUMN sa.table_person.salutation IS 'Salutation for the person';
COMMENT ON COLUMN sa.table_person.title IS 'Primary title of the person';
COMMENT ON COLUMN sa.table_person.title_cat IS 'Title category; e.g., executive, middle manager. This is a user-defined pop up';
COMMENT ON COLUMN sa.table_person.family_info IS 'Information about the person s relatives';
COMMENT ON COLUMN sa.table_person.birthday IS 'Person s birthday';
COMMENT ON COLUMN sa.table_person.comments IS 'Comments about the person';
COMMENT ON COLUMN sa.table_person.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_person.person2contact IS 'If the person is a contact, the related contact object';
COMMENT ON COLUMN sa.table_person.person2employee IS 'If the person is an employee, the related employee object';