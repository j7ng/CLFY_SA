CREATE OR REPLACE FUNCTION sa."GET_DBLMIN_USAGE_FUN" (
   ip_esn        IN   VARCHAR2,
   ip_promocode  IN   VARCHAR2,
   ip_promounits IN   NUMBER,
   ip_chkpromo   IN   VARCHAR2
)
   RETURN NUMBER
AS
   l_ap_dtls_cnt    NUMBER := 0; -- autopay counter
   l_ph_promo_cnt   NUMBER := 0; -- double minute promotions
   l_dbl_promo_cnt  NUMBER := 0; -- double minute promotion
   l_ph_pending_cnt NUMBER := 0; -- double minute pending promotions
   l_usage_cnt      NUMBER := 0;
BEGIN

SELECT COUNT(1)
  INTO l_ap_dtls_cnt
  FROM TABLE_X_AUTOPAY_DETAILS
 WHERE x_program_type = 3
   AND x_status = 'A'
   AND X_ESN = ip_esn;

/*SELECT COUNT(1)
  INTO l_ph_promo_cnt
  FROM table_x_promo_hist a,
       table_x_call_trans b,
       table_x_promotion c,
       table_part_inst d
 WHERE c.x_program_type = 5 --:Double Minute promotions
   AND sysdate between c.x_start_date and c.x_end_date  --:Double minute promos still active
   AND c.x_promo_code <> ip_promocode
   AND a.promo_hist2x_promotion + 0 = c.objid
   AND a.promo_hist2x_call_trans = b.objid
   AND b.call_trans2site_part = d.x_part_inst2site_part
   AND d.part_serial_no = ip_esn;
*/

SELECT COUNT(1)
  INTO l_ph_pending_cnt
  FROM table_x_promotion a, table_x_pending_redemption b, table_part_inst c
 WHERE a.x_program_type = 5 --:Double Minute promotions
   AND a.x_units = ip_promounits
   AND a.x_promo_code <> ip_promocode
   AND a.objid = b.pend_red2x_promotion
   AND b.x_pend_red2site_part = c.x_part_inst2site_part
   AND c.part_serial_no = ip_esn;

IF UPPER(ip_chkpromo) = 'YES' THEN

      SELECT COUNT(1)
        INTO l_dbl_promo_cnt
        FROM table_x_promotion p, table_part_inst pi, table_x_group2esn ge
       WHERE p.x_promo_code = ip_promocode
         AND sysdate BETWEEN ge.x_start_date AND ge.x_end_date
         AND ge.groupesn2x_promotion+0 = p.objid
         AND ge.x_annual_plan = 1
         AND pi.objid = ge.groupesn2part_inst
         AND pi.part_serial_no = ip_esn
         AND pi.x_domain = 'PHONES';

END IF;

   l_usage_cnt := NVL(l_ph_pending_cnt,0) + NVL (l_ap_dtls_cnt, 0) + NVL (l_ph_promo_cnt, 0) + NVL (l_dbl_promo_cnt, 0);
   RETURN l_usage_cnt;
EXCEPTION
   WHEN OTHERS
   THEN
      l_usage_cnt := NVL(l_ap_dtls_cnt, 0);
      RETURN l_usage_cnt;
END get_dblmin_usage_fun;
/