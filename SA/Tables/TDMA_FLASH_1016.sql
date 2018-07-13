CREATE TABLE sa.tdma_flash_1016 (
  x_esn VARCHAR2(30 BYTE),
  part_inst_objid NUMBER
);
ALTER TABLE sa.tdma_flash_1016 ADD SUPPLEMENTAL LOG GROUP dmtsora2005014496_0 (part_inst_objid, x_esn) ALWAYS;