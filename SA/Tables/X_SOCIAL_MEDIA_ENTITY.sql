CREATE TABLE sa.x_social_media_entity (
  x_sme_id NUMBER NOT NULL,
  x_social_media_name VARCHAR2(100 BYTE) NOT NULL,
  x_social_media_desc VARCHAR2(500 BYTE) NOT NULL,
  x_social_media_start_date DATE,
  x_social_media_end_date DATE,
  x_social_media_create_date DATE NOT NULL,
  x_social_media_update_date DATE,
  CONSTRAINT x_sme_id_pk UNIQUE (x_sme_id)
);