CREATE TABLE sa.smp_vds_sessions_table (
  session_id NUMBER,
  principal_name VARCHAR2(128 BYTE) NOT NULL,
  principal_type VARCHAR2(128 BYTE) NOT NULL,
  principal_ior VARCHAR2(2000 BYTE),
  login_time DATE,
  oms VARCHAR2(128 BYTE) NOT NULL
);
ALTER TABLE sa.smp_vds_sessions_table ADD SUPPLEMENTAL LOG GROUP dmtsora1063825037_0 (login_time, oms, principal_ior, principal_name, principal_type, session_id) ALWAYS;