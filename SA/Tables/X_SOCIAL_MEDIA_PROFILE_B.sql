CREATE TABLE sa.x_social_media_profile_b (
  x_social_media_uid VARCHAR2(100 BYTE) NOT NULL,
  x_uname VARCHAR2(100 BYTE),
  x_first_name VARCHAR2(50 BYTE),
  x_last_name VARCHAR2(50 BYTE),
  x_ulink VARCHAR2(150 BYTE),
  x_username VARCHAR2(50 BYTE),
  x_gender VARCHAR2(10 BYTE),
  x_locale VARCHAR2(200 BYTE),
  x_age_range VARCHAR2(100 BYTE),
  x_email VARCHAR2(60 BYTE),
  x_friend_list_node CLOB,
  x_nonpublicattribute CLOB,
  x_createdate DATE,
  x_lastupdatedate DATE,
  x_interest_share VARCHAR2(50 BYTE),
  x_sme_id NUMBER,
  x_sme_mobileuser2webuser NUMBER
);