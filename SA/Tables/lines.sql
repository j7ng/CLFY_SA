CREATE TABLE sa."lines" (
  li_num CHAR(10 BYTE) NOT NULL,
  li_carrier_id CHAR(7 BYTE) NOT NULL,
  li_esn CHAR(11 BYTE),
  li_dealer_id CHAR(7 BYTE),
  li_cust_id CHAR(7 BYTE),
  li_date DATE NOT NULL,
  li_f_act_d DATE,
  li_disc_d DATE,
  li_usable CHAR,
  li_city VARCHAR2(30 BYTE) NOT NULL,
  li_st CHAR(2 BYTE) NOT NULL,
  li_market VARCHAR2(3 BYTE),
  li_useagain_d DATE,
  ident_id NUMBER(18) NOT NULL,
  li_region NUMBER(10),
  li_reseller_id CHAR(7 BYTE),
  li_newline NUMBER(10),
  li_carr_acct CHAR(30 BYTE),
  li_deact_reason NUMBER(10),
  li_npa CHAR(8 BYTE),
  li_nxx CHAR(8 BYTE),
  li_expiration_date DATE,
  li_used_level NUMBER(10),
  li_datetimestamp DATE
);