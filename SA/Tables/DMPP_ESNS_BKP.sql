CREATE TABLE sa.dmpp_esns_bkp (
  esn VARCHAR2(20 BYTE),
  last_red_date DATE,
  esn_objid NUMBER(*,0),
  gesn_yn CHAR,
  gesn_start_date DATE,
  gesn_end_date DATE,
  x_annual_plan NUMBER(*,0),
  trans_date DATE,
  trans_result VARCHAR2(20 BYTE),
  promo_yn CHAR,
  red_date DATE,
  red_card_yn CHAR,
  ins_gesn_yn CHAR
);