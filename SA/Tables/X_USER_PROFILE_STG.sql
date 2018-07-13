CREATE TABLE sa.x_user_profile_stg (
  username VARCHAR2(50 BYTE),
  "ROLE" VARCHAR2(150 BYTE),
  new_priv_class VARCHAR2(100 BYTE),
  new_sec_grp VARCHAR2(100 BYTE),
  status VARCHAR2(500 BYTE),
  profile_chg_dt DATE,
  sd_ticket VARCHAR2(25 BYTE),
  insert_user VARCHAR2(50 BYTE),
  insert_date DATE
);