CREATE TABLE sa.x_deact_airtouch (
  site_part_objid NUMBER,
  x_service_id VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  carrier_objid NUMBER,
  site_objid NUMBER(*,0)
);
ALTER TABLE sa.x_deact_airtouch ADD SUPPLEMENTAL LOG GROUP dmtsora1017890566_0 (carrier_objid, site_objid, site_part_objid, x_min, x_service_id) ALWAYS;