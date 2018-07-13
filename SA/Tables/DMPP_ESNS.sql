CREATE TABLE sa.dmpp_esns (
  esn VARCHAR2(20 BYTE),
  last_red_date DATE,
  esn_objid NUMBER(38),
  gesn_yn CHAR,
  gesn_start_date DATE,
  gesn_end_date DATE,
  x_annual_plan NUMBER(38),
  trans_date DATE,
  trans_result VARCHAR2(20 BYTE),
  promo_yn CHAR,
  red_date DATE,
  red_card_yn CHAR,
  ins_gesn_yn CHAR
);
ALTER TABLE sa.dmpp_esns ADD SUPPLEMENTAL LOG GROUP dmtsora917952175_0 (esn, esn_objid, gesn_end_date, gesn_start_date, gesn_yn, ins_gesn_yn, last_red_date, promo_yn, red_card_yn, red_date, trans_date, trans_result, x_annual_plan) ALWAYS;