CREATE TABLE sa.stg_bonus_points_load (
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  points NUMBER(12,2),
  reason VARCHAR2(2000 BYTE),
  benefit_type VARCHAR2(50 BYTE)
);