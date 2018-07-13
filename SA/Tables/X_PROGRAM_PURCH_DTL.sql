CREATE TABLE sa.x_program_purch_dtl (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_amount NUMBER(19,2),
  x_charge_desc VARCHAR2(255 BYTE),
  x_cycle_start_date DATE,
  x_cycle_end_date DATE,
  pgm_purch_dtl2pgm_enrolled NUMBER,
  pgm_purch_dtl2prog_hdr NUMBER,
  pgm_purch_dtl2penal_pend NUMBER,
  x_tax_amount NUMBER DEFAULT 0.0,
  x_e911_tax_amount NUMBER DEFAULT 0,
  x_usf_taxamount NUMBER,
  x_rcrf_tax_amount NUMBER,
  x_priority NUMBER,
  x_discount_amount NUMBER(22)
);
ALTER TABLE sa.x_program_purch_dtl ADD SUPPLEMENTAL LOG GROUP dmtsora43222121_0 (objid, pgm_purch_dtl2penal_pend, pgm_purch_dtl2pgm_enrolled, pgm_purch_dtl2prog_hdr, x_amount, x_charge_desc, x_cycle_end_date, x_cycle_start_date, x_e911_tax_amount, x_esn, x_tax_amount, x_usf_taxamount) ALWAYS;
COMMENT ON TABLE sa.x_program_purch_dtl IS 'Billing Programs Purchase Transaction Details.  This is one of the support tables for the Enrollment and Recurrent Charges.';
COMMENT ON COLUMN sa.x_program_purch_dtl.objid IS 'Internal Id Number';
COMMENT ON COLUMN sa.x_program_purch_dtl.x_esn IS 'Phone Serial Number, References part_serial_no in table_part_inst';
COMMENT ON COLUMN sa.x_program_purch_dtl.x_amount IS 'Purchase Dollar Amount for the record.';
COMMENT ON COLUMN sa.x_program_purch_dtl.x_charge_desc IS 'Description of the Charge';
COMMENT ON COLUMN sa.x_program_purch_dtl.x_cycle_start_date IS 'Billing Cycle Start Date';
COMMENT ON COLUMN sa.x_program_purch_dtl.x_cycle_end_date IS 'Billing Cycle End Date';
COMMENT ON COLUMN sa.x_program_purch_dtl.pgm_purch_dtl2pgm_enrolled IS 'Reference to x_program_enrolled';
COMMENT ON COLUMN sa.x_program_purch_dtl.pgm_purch_dtl2prog_hdr IS 'Reference to x_purchase_hdr';
COMMENT ON COLUMN sa.x_program_purch_dtl.pgm_purch_dtl2penal_pend IS 'Reference to X_PROGRAM_PENALTY_PEND';
COMMENT ON COLUMN sa.x_program_purch_dtl.x_tax_amount IS 'TAX amount';
COMMENT ON COLUMN sa.x_program_purch_dtl.x_e911_tax_amount IS 'E911 Tax Amount';
COMMENT ON COLUMN sa.x_program_purch_dtl.x_usf_taxamount IS 'USF Tax Amount';
COMMENT ON COLUMN sa.x_program_purch_dtl.x_rcrf_tax_amount IS 'RCRF Tax Amount';