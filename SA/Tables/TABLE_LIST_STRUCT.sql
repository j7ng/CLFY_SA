CREATE TABLE sa.table_list_struct (
  objid NUMBER,
  hdr_type NUMBER,
  dtl_type NUMBER,
  hdr_name_fld VARCHAR2(18 BYTE),
  dtl_rel_name VARCHAR2(32 BYTE),
  dtl_display_fld VARCHAR2(18 BYTE),
  dtl_rank_fld VARCHAR2(18 BYTE),
  dtl_status_fld VARCHAR2(18 BYTE),
  dtl_dflt_val NUMBER,
  dtl_descr_fld VARCHAR2(255 BYTE),
  locale NUMBER,
  filter_cond VARCHAR2(255 BYTE),
  sort_expr VARCHAR2(255 BYTE),
  description VARCHAR2(255 BYTE),
  dev NUMBER,
  hdr_locale_fld VARCHAR2(18 BYTE),
  dtl_inactv_val NUMBER
);
ALTER TABLE sa.table_list_struct ADD SUPPLEMENTAL LOG GROUP dmtsora656176400_0 (description, dev, dtl_descr_fld, dtl_dflt_val, dtl_display_fld, dtl_inactv_val, dtl_rank_fld, dtl_rel_name, dtl_status_fld, dtl_type, filter_cond, hdr_locale_fld, hdr_name_fld, hdr_type, locale, objid, sort_expr) ALWAYS;