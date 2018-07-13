CREATE TABLE sa.table_part_event (
  objid NUMBER,
  rpt_time DATE,
  rpt_event_gid NUMBER,
  snmp_nm VARCHAR2(30 BYTE),
  snmp_mib VARCHAR2(30 BYTE),
  rpt_agent VARCHAR2(30 BYTE),
  rpt_part_nm VARCHAR2(255 BYTE),
  rpt_severity VARCHAR2(20 BYTE),
  snmp_cm_nm VARCHAR2(30 BYTE),
  rpt_event_sid NUMBER,
  instance_nm VARCHAR2(80 BYTE),
  dev NUMBER,
  part_event2site_part NUMBER(*,0)
);
ALTER TABLE sa.table_part_event ADD SUPPLEMENTAL LOG GROUP dmtsora917766594_0 (dev, instance_nm, objid, part_event2site_part, rpt_agent, rpt_event_gid, rpt_event_sid, rpt_part_nm, rpt_severity, rpt_time, snmp_cm_nm, snmp_mib, snmp_nm) ALWAYS;