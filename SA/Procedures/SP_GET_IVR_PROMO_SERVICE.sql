CREATE OR REPLACE PROCEDURE sa.sp_get_ivr_promo_service(
   promo_id IN VARCHAR2,
   p_act_type IN VARCHAR2,
   source_system IN VARCHAR2,
   script OUT VARCHAR2,
   startphrase OUT VARCHAR2,
   endphrase OUT VARCHAR2,
   r_promo OUT VARCHAR2,
   c_promo OUT VARCHAR2,
   e_promo OUT VARCHAR2,
   n_options OUT NUMBER,
   promo1_now OUT VARCHAR2,
   promo1_future OUT VARCHAR2,
   promo1_code OUT VARCHAR2,
   promo1_type OUT VARCHAR2,
   promo1_val OUT VARCHAR2,
   promo2_now OUT VARCHAR2,
   promo2_future OUT VARCHAR2,
   promo2_code OUT VARCHAR2,
   promo2_type OUT VARCHAR2,
   promo2_val OUT VARCHAR2,
   promo3_now OUT VARCHAR2,
   promo3_future OUT VARCHAR2,
   promo3_code OUT VARCHAR2,
   promo3_type OUT VARCHAR2,
   promo3_val OUT VARCHAR2,
   promo4_now OUT VARCHAR2,
   promo4_future OUT VARCHAR2,
   promo4_code OUT VARCHAR2,
   promo4_type OUT VARCHAR2,
   promo4_val OUT VARCHAR2,
   promo5_now OUT VARCHAR2,
   promo5_future OUT VARCHAR2,
   promo5_code OUT VARCHAR2,
   promo5_type OUT VARCHAR2,
   promo5_val OUT VARCHAR2,
   p_result OUT NUMBER,
   p_msg OUT VARCHAR2
)
AS

   /*************************************************************************************************|
   	|    Copyright   Tracfone  Wireless Inc. All rights reserved                          	         |
   	|                                                                                          	     |
   	| NAME     :       SP_GET_IVR_PROMO_SERVICE  procedure                        	 		         |
   	| PURPOSE                                                                                        |
   	| FREQUENCY:                                                                               	     |
   	| PLATFORMS:                                                                                     |
   	|                                                                                                |
   	| REVISIONS:                                                                               	     |
   	| VERSION  DATE        WHO              PURPOSE                                         	     |
   	| -------  ---------- -----             ------------------------------------------------------	 |
   	| 1.0      08/09/05   HM                Initial revision                            		     |
   	|************************************************************************************************/
   CURSOR c_promo_ivr
   IS
   SELECT pi.x_script,
      x_startphrase,
      x_endphrase,
      x_repeate,
      x_confirm,
      x_exclusivepromo
   FROM x_promo_ivr pi, x_promo_ivr_options pio
   WHERE UPPER(pi.x_script) = UPPER(TRIM(promo_id))
   AND pi.x_script = pio.x_script
   AND pi.x_status = 'ACT';
   CURSOR c_promo_ivr_options
   IS
   SELECT pi.x_script,
      x_promonow,
      x_promofuture,
      x_op_order,
      x_promocode,
      x_promotype,
      x_customerval
   FROM x_promo_ivr pi, x_promo_ivr_options pio
   WHERE UPPER(pio.x_script) = UPPER(TRIM(promo_id))
   AND pi.x_script = pio.x_script
   AND pi.x_status = 'ACT'
   ORDER BY pio.x_op_order ASC;
   c_promo_ivr_rec c_promo_ivr%ROWTYPE;
   c_promo_ivr_options_rec c_promo_ivr_options%ROWTYPE;
   n_num_promo_options NUMBER := 0;
BEGIN
   p_result := 1;
   SELECT COUNT(*)
   INTO n_num_promo_options
   FROM x_promo_ivr_options pn
   WHERE UPPER(pn.x_script) = UPPER(TRIM(promo_id));
   IF n_num_promo_options
   IS
   NULL
   THEN
      p_result := 1;
      p_msg := 'Invalid promotion id '||promo_id;
      RETURN;
   ELSIF n_num_promo_options = 0
   THEN
      p_result := 1;
      p_msg := 'Invalid promotion id '||promo_id;
      RETURN;
   END IF;
   OPEN c_promo_ivr;
   FETCH c_promo_ivr
   INTO c_promo_ivr_rec;
   CLOSE c_promo_ivr;
   IF c_promo_ivr_rec.x_script
   IS
   NULL
   THEN
      p_result := 1;
      p_msg := 'Invalid promotion id '||promo_id;
      RETURN;
   END IF;
   script := c_promo_ivr_rec.x_script;
   startphrase := c_promo_ivr_rec.x_startphrase;
   endphrase := c_promo_ivr_rec.x_endphrase;
   r_promo := c_promo_ivr_rec.x_repeate;
   c_promo := c_promo_ivr_rec.x_confirm;
   e_promo := c_promo_ivr_rec.x_exclusivepromo;
   n_options := n_num_promo_options;
   OPEN c_promo_ivr_options;
   LOOP
      FETCH c_promo_ivr_options
      INTO c_promo_ivr_options_rec;
      EXIT
      WHEN c_promo_ivr_options%NOTFOUND;
      IF c_promo_ivr_options_rec.x_op_order = 1
      THEN
         promo1_now := c_promo_ivr_options_rec.x_promonow;
         promo1_future := c_promo_ivr_options_rec.x_promofuture;
         promo1_code := c_promo_ivr_options_rec.x_promocode;
         promo1_type := c_promo_ivr_options_rec.x_promotype;
         promo1_val := c_promo_ivr_options_rec.x_customerval;
      END IF;
      IF c_promo_ivr_options_rec.x_op_order = 2
      THEN
         promo2_now := c_promo_ivr_options_rec.x_promonow;
         promo2_future := c_promo_ivr_options_rec.x_promofuture;
         promo2_code := c_promo_ivr_options_rec.x_promocode;
         promo2_type := c_promo_ivr_options_rec.x_promotype;
         promo2_val := c_promo_ivr_options_rec.x_customerval;
      END IF;
      IF c_promo_ivr_options_rec.x_op_order = 3
      THEN
         promo3_now := c_promo_ivr_options_rec.x_promonow;
         promo3_future := c_promo_ivr_options_rec.x_promofuture;
         promo3_code := c_promo_ivr_options_rec.x_promocode;
         promo3_type := c_promo_ivr_options_rec.x_promotype;
         promo3_val := c_promo_ivr_options_rec.x_customerval;
      END IF;
      IF c_promo_ivr_options_rec.x_op_order = 4
      THEN
         promo4_now := c_promo_ivr_options_rec.x_promonow;
         promo4_future := c_promo_ivr_options_rec.x_promofuture;
         promo4_code := c_promo_ivr_options_rec.x_promocode;
         promo4_type := c_promo_ivr_options_rec.x_promotype;
         promo4_val := c_promo_ivr_options_rec.x_customerval;
      END IF;
      IF c_promo_ivr_options_rec.x_op_order = 5
      THEN
         promo5_now := c_promo_ivr_options_rec.x_promonow;
         promo5_future := c_promo_ivr_options_rec.x_promofuture;
         promo5_code := c_promo_ivr_options_rec.x_promocode;
         promo5_type := c_promo_ivr_options_rec.x_promotype;
         promo5_val := c_promo_ivr_options_rec.x_customerval;
      END IF;
   END LOOP;
   CLOSE c_promo_ivr_options;
   p_result := 0;
   p_msg := 'Promotion '||promo_id||' is ready to use';
   EXCEPTION
   WHEN OTHERS
   THEN
      p_result := 99;
      p_msg := 'SQL error: '||SQLERRM;
END;
/