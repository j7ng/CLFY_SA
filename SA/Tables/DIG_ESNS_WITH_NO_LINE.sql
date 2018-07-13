CREATE TABLE sa.dig_esns_with_no_line (
  esn_objid NUMBER,
  esn VARCHAR2(30 BYTE),
  esn_part_inst_status VARCHAR2(20 BYTE),
  active_site_part_objid VARCHAR2(255 BYTE)
);
ALTER TABLE sa.dig_esns_with_no_line ADD SUPPLEMENTAL LOG GROUP dmtsora1632999124_0 (active_site_part_objid, esn, esn_objid, esn_part_inst_status) ALWAYS;