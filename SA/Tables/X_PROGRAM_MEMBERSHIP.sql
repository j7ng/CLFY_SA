CREATE TABLE sa.x_program_membership (
  x_membership_id NUMBER NOT NULL,
  x_membership_name VARCHAR2(80 BYTE) NOT NULL,
  x_membership_desc VARCHAR2(255 BYTE),
  x_membership_group VARCHAR2(50 BYTE) NOT NULL,
  x_membership_code VARCHAR2(50 BYTE),
  x_start_date DATE DEFAULT SYSDATE,
  x_end_date DATE,
  x_member_hierarchy NUMBER NOT NULL,
  x_member2bus_org NUMBER
);