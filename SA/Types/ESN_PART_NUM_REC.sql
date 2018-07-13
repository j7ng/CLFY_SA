CREATE OR REPLACE TYPE sa.esn_part_num_rec
IS
 object
  (
    ESN             			VARCHAR2(50),
    MIN             			VARCHAR2(50),
    DEVICE_PART_NUM 			VARCHAR2(50),
    APP_PART_NUM    			VARCHAR2(50),
    PRICING_ID      			NUMBER, ---TABle_x_pricing.x_fin_priceline_id;
    PROMO_CODES    			VARCHAR2(50),
    ACTION_TYPE     			VARCHAR2(50),
    CONFIRMATIONID  			VARCHAR2(50),
    is_enrolled				VARCHAR2(1),
    autorefill_max_limit 		NUMBER,
    In_Key_obj       			Keys_tbl
   );
/