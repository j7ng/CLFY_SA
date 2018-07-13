CREATE OR REPLACE PROCEDURE sa."SP_RATE_PLAN_CHANGE_MIGR" (
   in_esn         IN     VARCHAR2,
   out_err_code      OUT VARCHAR2,
   out_err_msg       OUT VARCHAR2)
AS
   /* CR33658  9-Apr-2015 */

   CURSOR cur_site_part
   IS
      SELECT objid,
             x_min,
             x_service_id,
             part_status,
             x_zipcode,
             x_iccid
        FROM table_site_part tsp
       WHERE x_servicE_id = in_esn AND part_status = 'Active';

   rec_site_part  cur_site_part%ROWTYPE;

   CURSOR c_nap_rc (p_zipcode IN VARCHAR2) IS
      SELECT * FROM sa.x_cingular_mrkt_info WHERE zip = p_zipcode AND ROWNUM < 2;

   c_nap_rc_rec         c_nap_rc%ROWTYPE;

BEGIN

   IF TRIM (in_esn) IS NULL THEN
      out_err_code := -1;
      out_erR_msg := 'Please provide value for Input ESN';
      RETURN;
   END IF;

   OPEN cur_site_part;
   FETCH cur_site_part INTO rec_site_part;
   CLOSE cur_site_part;

   IF rec_site_part.objid IS NULL THEN
      RAISE NO_DATA_FOUND;
   END IF;


   OPEN c_nap_rc (rec_site_part.x_zipcode);
   FETCH c_nap_rc INTO c_nap_rc_rec;

   IF c_nap_rc%NOTFOUND THEN
      DBMS_OUTPUT.put_line ('NOT FOUND c_nap_rc:' || rec_site_part.x_zipcode);
      INSERT INTO error_table (ERROR_TEXT,ERROR_DATE,ACTION,KEY,PROGRAM_NAME)
      VALUES ('c_nap_rc%NOTFOUND',
               SYSDATE,
               'c_nap_rc( '|| rec_site_part.x_zipcode|| ' )',
               in_esn,
               'sp_rate_plan_change_migr'
             );
   ELSE
      CLOSE c_nap_rc;
   END IF;

   INSERT INTO gw1.ig_transaction
                 ( action_item_id,
				   transaction_id,
				   order_type,
				   MIN,
				   msid,
				   esn,
				   esn_hex,
				   iccid,
				   account_num,
				   market_code,
				   dealer_code,
				   rate_plan,
				   template,
				   status,
				   technology_flag,
				   application_system,
				   zip_code
				 )
     VALUES ( 'TFWAP' || rec_site_part.x_min, --action_item_id
			  gw1.trans_id_seq.nextval+(power(2,28)), --transaction_id
			  'R', --order_type
			  rec_site_part.x_min, --MIN
			  rec_site_part.x_min, -- msid
			  rec_site_part.x_service_id, -- esn
			  sa.igate.f_get_hex_esn(rec_site_part.x_service_id),
			  rec_site_part.x_iccid, -- iccid
			  c_nap_rc_rec.account_num, -- account_num
			  c_nap_rc_rec.market_code, -- market_code
			  c_nap_rc_rec.dealer_code, -- dealer_code
			  'TFWAP2', -- rate_plan
			  'CSI_TLG', -- template
			  'Q',-- status
			  'G', -- technology_flag
			  'APN_CHANGES', -- application_system
			  NVL (rec_site_part.x_zipcode, '33178') --zip_code
          );

   out_err_code := 0;
   out_erR_msg := 'SUCCESS';
EXCEPTION
   WHEN OTHERS THEN NULL;
   out_err_code := -99;
   out_erR_msg := SUBSTR (SQLERRM, 1, 2000);
END sp_rate_plan_change_migr;
/