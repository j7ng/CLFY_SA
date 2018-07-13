CREATE TABLE sa.centene_net10_subs (
  x_esn VARCHAR2(30 BYTE),
  x_min VARCHAR2(20 BYTE),
  part_number VARCHAR2(100 BYTE),
  phone_dealer VARCHAR2(200 BYTE),
  act_date DATE,
  esn_expiry_date DATE,
  phone_status VARCHAR2(100 BYTE),
  current_plan VARCHAR2(100 BYTE),
  extra_units NUMBER,
  enrollment_status VARCHAR2(100 BYTE),
  enroll_date DATE,
  start_date DATE,
  bill VARCHAR2(1 BYTE),
  deenroll VARCHAR2(3 BYTE),
  deenroll_date DATE,
  last_delivery_date DATE,
  customer_commit_date DATE
);