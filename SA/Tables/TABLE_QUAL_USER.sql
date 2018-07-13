CREATE TABLE sa.table_qual_user (
  objid NUMBER,
  dev NUMBER,
  qualifier_id NUMBER,
  qual_user2qualifier NUMBER,
  qual_user2user NUMBER
);
ALTER TABLE sa.table_qual_user ADD SUPPLEMENTAL LOG GROUP dmtsora98488394_0 (dev, objid, qualifier_id, qual_user2qualifier, qual_user2user) ALWAYS;