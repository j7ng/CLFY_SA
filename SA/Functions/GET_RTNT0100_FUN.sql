CREATE OR REPLACE FUNCTION sa."GET_RTNT0100_FUN" (
   ip_esn IN VARCHAR2,
   ip_promo_code IN VARCHAR2
)
   RETURN NUMBER
AS
/********************************************************************************************************************/
   /* Copyright   2002 Tracfone  Wireless Inc. All rights reserved                                                                                */
   /*                                                                                                                                                                                                  */
   /* NAME:               GET_RTNT0100_FUN                                                                                                                         */
   /* PURPOSE:      To get default promo usage for an ESN  that is a replacement for a Defective Phone  */
   /* FREQUENCY:                                                                                                                                                             */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                                                                         */
   /*                                                                                                                                                                                            */
   /* REVISIONS:                                                                                                                                                                  */
   /* VERSION  DATE        WHO          PURPOSE                                                                                                   */
   /* -------  ---------- -----  --------------------------------------------                                                                                         */
   /*  1.0     08/10/07                 IC               Initial  Revision                                                                               */
   /* 1.1    11/21/07      CL          Fix to WEBCSR issue
   /*******************************************************************************/
   l_defect_red_tot NUMBER := 0;
   l_defect_esn VARCHAR2 (18) ;
   l_usage_cnt NUMBER := 0 ;
   CURSOR Activation_promo_used_curs(
      ip_esn IN VARCHAR2
   )
   IS
   SELECT x_service_id
   FROM TABLE_X_PROMO_HIST ph, TABLE_X_PROMOTION p, TABLE_X_CALL_TRANS xct, (
      SELECT tc.X_ESN
      FROM TABLE_CASE tc, TABLE_X_PART_REQUEST pr
      WHERE tc.title = 'Defective Phone'
      AND tc.objid = pr.request2case
      AND pr.x_part_num_domain = 'PHONES'
      AND pr.x_part_serial_no = ip_esn) tab1
   WHERE p.x_is_default = 1
   AND p.objid = ph.promo_hist2x_promotion
   AND xct.objid = ph.promo_hist2x_call_trans
   AND x_service_id = tab1.X_ESN;
   CURSOR Found_NT100_curs(
      l_defect_esn IN VARCHAR2
   )
   IS
      --11/21/07 WCSR_FIX
   -- SELECT COUNT(*)
   --     FROM TABLE_X_PROMO_HIST ph , TABLE_X_PROMOTION p , TABLE_X_CALL_TRANS xct
   --    WHERE  p.x_promo_code= ip_promo_code -- 'RTNT0100'
   --    AND p.objid = ph.promo_hist2x_promotion
   --      AND xct.objid  = ph.promo_hist2x_call_trans  AND x_service_id =l_defect_esn ;
   SELECT COUNT(*)
   FROM TABLE_X_PROMOTION p, tABLE_X_PROMO_HIST ph, TABLE_X_CALL_TRANS xct
   WHERE p.x_promo_code||'' = ip_promo_code -- 'RTNT0100'
   AND p.objid = ph.promo_hist2x_promotion
   AND ph.promo_hist2x_call_trans = xct.objid
   AND XCT.x_service_id = l_defect_esn ;
   --11/21/07   WCSR_FIX
BEGIN
   OPEN Activation_promo_used_curs(IP_ESN) ;
   FETCH Activation_promo_used_curs
   INTO l_defect_esn;
   IF Activation_promo_used_curs%NOTFOUND
   THEN
      RETURN 0;
   END IF;
   CLOSE Activation_promo_used_curs ;
   OPEN Found_NT100_curs(l_defect_esn) ;
   FETCH Found_NT100_curs
   INTO l_defect_red_tot ;
   IF Found_NT100_curs%NOTFOUND
   THEN
      RETURN 0;
   END IF;
   CLOSE Found_NT100_curs;
   l_usage_cnt := NVL (l_defect_red_tot, 0) ;
   RETURN l_usage_cnt;
   EXCEPTION
   WHEN OTHERS
   THEN
      l_usage_cnt := NVL (l_defect_red_tot, 0) ;
      RETURN l_usage_cnt;
END get_RTNT0100_fun;
/