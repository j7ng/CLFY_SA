CREATE TABLE sa.x_esn_promo_hist (
  objid NUMBER,
  esn VARCHAR2(30 BYTE),
  promo_hist2call_trans NUMBER,
  promo_hist2x_promotion NUMBER,
  insert_timestamp DATE,
  expiration_date DATE,
  bucket_id VARCHAR2(30 BYTE),
  discount_code_list sa.discount_code_tab
)
NESTED TABLE discount_code_list STORE AS discount_code_list_ph;