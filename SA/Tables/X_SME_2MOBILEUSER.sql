CREATE TABLE sa.x_sme_2mobileuser (
  x_social_media_uid VARCHAR2(100 BYTE) NOT NULL,
  x_sme_id NUMBER NOT NULL,
  x_sme_mobileuser2webuser NUMBER NOT NULL,
  x_token_for_business VARCHAR2(150 BYTE),
  x_status NUMBER,
  x_status_desc VARCHAR2(150 BYTE),
  x_createdate DATE NOT NULL,
  x_lastupdate DATE,
  CONSTRAINT x_sme_2mobileuser_pk PRIMARY KEY (x_social_media_uid,x_sme_id,x_sme_mobileuser2webuser)
);