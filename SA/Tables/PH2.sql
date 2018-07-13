CREATE TABLE sa.ph2 (
  ph_esn_num VARCHAR2(11 BYTE) NOT NULL,
  ph_esn_hex VARCHAR2(8 BYTE) NOT NULL,
  ph_old_type VARCHAR2(2 BYTE) NOT NULL,
  ph_cust_id VARCHAR2(14 BYTE),
  ph_carrier_id VARCHAR2(7 BYTE),
  ph_cel_num VARCHAR2(10 BYTE),
  ph_debsn VARCHAR2(5 BYTE) NOT NULL,
  ph_odacc VARCHAR2(3 BYTE) NOT NULL,
  ph_counter NUMBER(10) NOT NULL,
  ph_time_redeemed NUMBER(10) NOT NULL,
  ph_grp VARCHAR2(5 BYTE),
  ph_active_due DATE,
  ph_last_red_time NUMBER(10),
  ph_last_red_date DATE,
  ph_def_pers VARCHAR2(5 BYTE) NOT NULL,
  ph_po_num VARCHAR2(10 BYTE),
  ph_ship_dt DATE,
  ph_version VARCHAR2(4 BYTE),
  ph_modif_d DATE,
  ph_red_flag NUMBER(10),
  ph_cloned NUMBER(10),
  ph_cust_po_num VARCHAR2(10 BYTE),
  ph_modif_n NUMBER(10),
  ph_pers VARCHAR2(5 BYTE),
  ph_pers_d DATE,
  ph_alt_cel NUMBER(10),
  ph_dealer_id VARCHAR2(7 BYTE),
  ph_p2g VARCHAR2(1 BYTE),
  ph_source VARCHAR2(7 BYTE),
  ph_akey VARCHAR2(26 BYTE),
  ph_host VARCHAR2(10 BYTE),
  ph_oper VARCHAR2(10 BYTE),
  ph_first_code VARCHAR2(25 BYTE),
  ph_notes VARCHAR2(80 BYTE),
  ph_last_phone VARCHAR2(10 BYTE),
  ph_time_flag VARCHAR2(3 BYTE),
  ph_model_num NUMBER(10),
  ident_id NUMBER(18) NOT NULL,
  ph_numof_cards NUMBER(10),
  ph_reset_count NUMBER(10),
  ph_datetime_stamp DATE
);
ALTER TABLE sa.ph2 ADD SUPPLEMENTAL LOG GROUP dmtsora248961032_0 (ph_active_due, ph_akey, ph_alt_cel, ph_carrier_id, ph_cel_num, ph_cloned, ph_counter, ph_cust_id, ph_cust_po_num, ph_dealer_id, ph_debsn, ph_def_pers, ph_esn_hex, ph_esn_num, ph_first_code, ph_grp, ph_host, ph_last_red_date, ph_last_red_time, ph_modif_d, ph_modif_n, ph_odacc, ph_old_type, ph_oper, ph_p2g, ph_pers, ph_pers_d, ph_po_num, ph_red_flag, ph_ship_dt, ph_source, ph_time_redeemed, ph_version) ALWAYS;
ALTER TABLE sa.ph2 ADD SUPPLEMENTAL LOG GROUP dmtsora248961032_1 (ident_id, ph_datetime_stamp, ph_last_phone, ph_model_num, ph_notes, ph_numof_cards, ph_reset_count, ph_time_flag) ALWAYS;