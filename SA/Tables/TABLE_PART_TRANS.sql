CREATE TABLE sa.table_part_trans (
  objid NUMBER,
  transaction_id VARCHAR2(20 BYTE),
  creation_date DATE,
  reference_no VARCHAR2(20 BYTE),
  part_number VARCHAR2(30 BYTE),
  quantity NUMBER,
  movement_type NUMBER,
  notes VARCHAR2(60 BYTE),
  standard_cost NUMBER(19,4),
  trans_type NUMBER,
  rol_ind NUMBER,
  open_ord_ind NUMBER,
  arch_ind NUMBER,
  dev NUMBER,
  part_trans_owner2user NUMBER(*,0),
  from_bin2inv_bin NUMBER(*,0),
  to_bin2inv_bin NUMBER(*,0),
  from_inst2part_inst NUMBER(*,0),
  to_inst2part_inst NUMBER(*,0),
  part_trans2demand_dtl NUMBER(*,0),
  recv_trans2recv_parts NUMBER(*,0),
  fulf_trans2recv_parts NUMBER(*,0),
  fulf_trans2ship_parts NUMBER(*,0),
  install_trans2demand_dtl NUMBER(*,0),
  from_inst2x_pi_hist NUMBER,
  to_inst2x_pi_hist NUMBER,
  from_fixed2inv_bin NUMBER,
  rem_trans2demand_dtl NUMBER,
  to_fixed2inv_bin NUMBER
);
ALTER TABLE sa.table_part_trans ADD SUPPLEMENTAL LOG GROUP dmtsora1598653116_0 (arch_ind, creation_date, dev, from_bin2inv_bin, from_fixed2inv_bin, from_inst2part_inst, from_inst2x_pi_hist, fulf_trans2recv_parts, fulf_trans2ship_parts, install_trans2demand_dtl, movement_type, notes, objid, open_ord_ind, part_number, part_trans2demand_dtl, part_trans_owner2user, quantity, recv_trans2recv_parts, reference_no, rem_trans2demand_dtl, rol_ind, standard_cost, to_bin2inv_bin, to_fixed2inv_bin, to_inst2part_inst, to_inst2x_pi_hist, transaction_id, trans_type) ALWAYS;
COMMENT ON TABLE sa.table_part_trans IS 'Stores core information about part movements within the inventory';
COMMENT ON COLUMN sa.table_part_trans.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_part_trans.transaction_id IS 'Unique number generated for the part transaction';
COMMENT ON COLUMN sa.table_part_trans.creation_date IS 'Date the part transaction was created';
COMMENT ON COLUMN sa.table_part_trans.reference_no IS 'A reference identifier associated with the part transfer';
COMMENT ON COLUMN sa.table_part_trans.part_number IS 'Part number used in the transaction';
COMMENT ON COLUMN sa.table_part_trans.quantity IS 'Quantity of parts transferred';
COMMENT ON COLUMN sa.table_part_trans.movement_type IS 'Movement type; i.e., 0=good to good, 1=good to bad, 2=bad to good, 3=bad to bad';
COMMENT ON COLUMN sa.table_part_trans.notes IS 'Notes for the transaction';
COMMENT ON COLUMN sa.table_part_trans.standard_cost IS 'Standard cost of the part number used in the transaction';
COMMENT ON COLUMN sa.table_part_trans.trans_type IS 'Part Transaction type; i.e., 1=fulfill; 2=receive; 3=remove; 4=transfer; 5=install; 6=inventory reconciliation; 7=de-bundle; 8=de-manufacture; 9=container move';
COMMENT ON COLUMN sa.table_part_trans.rol_ind IS 'Reorder level  indicator; i.e., 0=good qoh is above FROM bin s part_auth reorder level, 1=good qoh is equal to or below FROM bin s part_auth reorder level';
COMMENT ON COLUMN sa.table_part_trans.open_ord_ind IS 'Open Replenishment Order indicator; i.e., 0=there is no open replenishment part request for the FROM bin s part_auth, 1=there is an open replenishment part request for the FROM bin s part auth';
COMMENT ON COLUMN sa.table_part_trans.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_part_trans.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_part_trans.part_trans_owner2user IS 'The originator of the part transaction';
COMMENT ON COLUMN sa.table_part_trans.from_bin2inv_bin IS 'Immediate bin FROM which the part was moved. If from a moveable bin, it is the moveable bin';
COMMENT ON COLUMN sa.table_part_trans.to_bin2inv_bin IS 'Immediate bin TO which the part was moved. If to a moveable bin, it is the moveable bin ';
COMMENT ON COLUMN sa.table_part_trans.from_inst2part_inst IS 'Part whose quantity was decremented by the transaction. This is the credited instance. For serialized parts, same as the TO instance';
COMMENT ON COLUMN sa.table_part_trans.to_inst2part_inst IS 'Part whose quantity was incremented by the transaction. This is the debited instance. For serialized parts, same as the FROM instance';
COMMENT ON COLUMN sa.table_part_trans.part_trans2demand_dtl IS 'Related part request detail for the transaction. This is the part request which the part_trans fulfills';
COMMENT ON COLUMN sa.table_part_trans.recv_trans2recv_parts IS 'Related received parts object for the receive parts transaction';
COMMENT ON COLUMN sa.table_part_trans.fulf_trans2recv_parts IS 'Related received parts object for the fulfill parts transaction';
COMMENT ON COLUMN sa.table_part_trans.fulf_trans2ship_parts IS 'Shipper for the current fulfill part transaction';
COMMENT ON COLUMN sa.table_part_trans.install_trans2demand_dtl IS 'Part request related to the install part transaction';
COMMENT ON COLUMN sa.table_part_trans.from_inst2x_pi_hist IS 'History: Part transactions which decremented a quantity of the inventory part';
COMMENT ON COLUMN sa.table_part_trans.to_inst2x_pi_hist IS 'History: Part transactions which incremented a quantity of the part';
COMMENT ON COLUMN sa.table_part_trans.from_fixed2inv_bin IS 'Fixed bin FROM which the part was moved. This tracks the TO GL and must be a fixed bin. For movements not involving a moveable bin, it is the same as the from_bin2inv_bin';
COMMENT ON COLUMN sa.table_part_trans.rem_trans2demand_dtl IS 'Part request related to the remove part transaction';
COMMENT ON COLUMN sa.table_part_trans.to_fixed2inv_bin IS 'Fixed bin TO which the part was moved. This tracks the FROM GL and must be a fixed bin. For movements not involving a moveable bin, it is the same as the to_bin2inv_bin';