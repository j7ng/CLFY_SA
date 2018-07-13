CREATE TABLE sa.red12 (
  esnpi_part_serial_no VARCHAR2(30 BYTE),
  esnpi_x_po_num VARCHAR2(30 BYTE),
  esnpi_n_part_inst2part_mod NUMBER,
  esnpi_part_inst2inv_bin NUMBER,
  esnib_bin_name VARCHAR2(20 BYTE),
  esnst_objid NUMBER,
  esnst_site_id VARCHAR2(80 BYTE),
  esnst_name VARCHAR2(80 BYTE),
  esnml_part_info2part_num NUMBER(*,0),
  esnpn_objid NUMBER,
  esnpn_part_number VARCHAR2(30 BYTE),
  esnpn_description VARCHAR2(255 BYTE),
  esnpn_x_technology VARCHAR2(20 BYTE)
);
ALTER TABLE sa.red12 ADD SUPPLEMENTAL LOG GROUP dmtsora421497243_0 (esnib_bin_name, esnml_part_info2part_num, esnpi_n_part_inst2part_mod, esnpi_part_inst2inv_bin, esnpi_part_serial_no, esnpi_x_po_num, esnpn_description, esnpn_objid, esnpn_part_number, esnpn_x_technology, esnst_name, esnst_objid, esnst_site_id) ALWAYS;