CREATE TABLE sa.x_sme_2mobileuser_b (
  x_social_media_uid VARCHAR2(100 BYTE) NOT NULL,
  x_sme_id NUMBER NOT NULL,
  x_sme_mobileuser2webuser NUMBER NOT NULL,
  x_status NUMBER,
  x_status_desc VARCHAR2(150 BYTE),
  x_createdate DATE NOT NULL,
  x_lastupdate DATE
);