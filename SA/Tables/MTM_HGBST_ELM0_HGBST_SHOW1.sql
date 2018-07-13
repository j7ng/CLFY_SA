CREATE TABLE sa.mtm_hgbst_elm0_hgbst_show1 (
  hgbst_elm2hgbst_show NUMBER(*,0) NOT NULL,
  hgbst_show2hgbst_elm NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_hgbst_elm0_hgbst_show1 ADD SUPPLEMENTAL LOG GROUP dmtsora1495709078_0 (hgbst_elm2hgbst_show, hgbst_show2hgbst_elm) ALWAYS;
COMMENT ON TABLE sa.mtm_hgbst_elm0_hgbst_show1 IS 'User Defined Pop-up List Table';
COMMENT ON COLUMN sa.mtm_hgbst_elm0_hgbst_show1.hgbst_elm2hgbst_show IS 'Reference to objid of table table_HGBST_ELM';
COMMENT ON COLUMN sa.mtm_hgbst_elm0_hgbst_show1.hgbst_show2hgbst_elm IS 'Elements in the level of the user-defined pop up list';