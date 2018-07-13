CREATE TABLE sa.scripts_content (
  script_content_id VARCHAR2(1000 BYTE) NOT NULL,
  content_id VARCHAR2(100 BYTE) NOT NULL,
  did VARCHAR2(50 BYTE) NOT NULL,
  description VARCHAR2(4000 BYTE),
  expiry_date DATE,
  publish_date DATE,
  release_date DATE,
  title VARCHAR2(100 BYTE),
  "CATEGORY" VARCHAR2(50 BYTE),
  db_script VARCHAR2(50 BYTE),
  script_type VARCHAR2(50 BYTE),
  carrier VARCHAR2(50 BYTE),
  technology VARCHAR2(50 BYTE),
  isgeneric_script VARCHAR2(1 BYTE) NOT NULL,
  script_image VARCHAR2(500 BYTE),
  script_text VARCHAR2(4000 BYTE) NOT NULL,
  "LABEL" VARCHAR2(50 BYTE),
  phrase_number VARCHAR2(50 BYTE),
  promotion_group VARCHAR2(20 BYTE),
  channel_name VARCHAR2(20 BYTE) NOT NULL
);
ALTER TABLE sa.scripts_content ADD SUPPLEMENTAL LOG GROUP dmtsora2018889466_0 (carrier, "CATEGORY", channel_name, content_id, db_script, description, did, expiry_date, isgeneric_script, "LABEL", phrase_number, promotion_group, publish_date, release_date, script_content_id, script_image, script_text, script_type, technology, title) ALWAYS;