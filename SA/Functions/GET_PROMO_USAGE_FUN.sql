CREATE OR REPLACE FUNCTION sa."GET_PROMO_USAGE_FUN" (
   ip_esn          IN   VARCHAR2,
   ip_objid        IN   NUMBER,
   ip_promo_code   IN   VARCHAR2
)
   RETURN NUMBER
AS
/*********************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved               */
/*                                                                               */
/* NAME:         GET_PROMO_USAGE_FUN                                             */
/* PURPOSE:      To get promo usage for an ESN                                   */
/* FREQUENCY:                                                                    */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                */
/*                                                                               */
/* REVISIONS:                                                                    */
/* VERSION  DATE        WHO          PURPOSE                                     */
/* -------  ---------- -----  ---------------------------------------------      */
/*  1.0     10/28/02   VA     Initial  Revision                                  */
/*  1.1     05/20/03   VA     Added to pass a string of promocodes instead of one*/
/*  1.2     01/11/06   VA    CR4775 - Modified to take refurb phones into consideration
/*                        when checking for promo usage
/*  1.3      11/07/06   CL    CR5631 changes
/*********************************************************************************/
   l_promo_hist_cnt   NUMBER          := 0;
   l_pend_red_cnt     NUMBER          := 0;
   l_usage_cnt        NUMBER          := 0;
   l_pend_red_tot     NUMBER          := 0;
   l_promo_hist_tot   NUMBER          := 0;
   l_cnt              NUMBER          := 0;
   l_bigstr           VARCHAR2 (2000) := ip_promo_code;
   l_smlstr           VARCHAR2 (2000);
   l_idxval           NUMBER;

   TYPE promo_tab_type IS TABLE OF table_x_promotion.x_promo_code%TYPE
      INDEX BY BINARY_INTEGER;

   l_promo_tab        promo_tab_type;
   l_orig_act_date    DATE;                                          --CR4775

   CURSOR orig_act_date_curs
   IS
      SELECT (DECODE (refurb_yes.is_refurb,
                      0, NVL (nonrefurb_act_date.init_act_date,
                              refurb_act_date.init_act_date
                             ),
                      NVL (refurb_act_date.init_act_date,
                           nonrefurb_act_date.init_act_date
                          )
                     )
             ) orig_act_date
        FROM (SELECT COUNT (1) is_refurb
                FROM table_site_part sp_a
               WHERE sp_a.x_service_id = ip_esn AND sp_a.x_refurb_flag = 1) refurb_yes,
             (SELECT MIN (install_date) init_act_date
                FROM table_site_part sp_b
               WHERE sp_b.x_service_id = ip_esn
                 AND sp_b.part_status || '' IN ('Active', 'Inactive')
                 AND NVL (sp_b.x_refurb_flag, 0) <> 1) refurb_act_date,
             (SELECT MIN (install_date) init_act_date
                FROM table_site_part sp_c
               WHERE sp_c.x_service_id = ip_esn
                 AND sp_c.part_status || '' IN ('Active', 'Inactive')) nonrefurb_act_date;

   CURSOR promo_hist_curs (c_orig_act_date IN DATE)
   IS
      SELECT c.x_promo_code
        FROM table_x_promotion c, table_x_promo_hist a, table_x_call_trans b
       WHERE 1 = 1
         AND c.objid = a.promo_hist2x_promotion + 0
         AND a.promo_hist2x_call_trans = b.objid
         AND b.x_transact_date >= c_orig_act_date
         AND b.x_service_id = ip_esn;

   CURSOR pend_rec_curs
   IS
      SELECT p.x_promo_code
        FROM table_x_promotion p, table_x_pending_redemption pr
       WHERE 1 = 1
         AND p.objid = pr.pend_red2x_promotion
         AND pr.x_pend_red2site_part = ip_objid;
BEGIN
   OPEN orig_act_date_curs;

   FETCH orig_act_date_curs
    INTO l_orig_act_date;

   IF orig_act_date_curs%NOTFOUND
   THEN
      RETURN 0;
   END IF;

   CLOSE orig_act_date_curs;

   LOOP
      l_idxval := INSTR (l_bigstr, ',');

      IF l_idxval = 0
      THEN
         l_smlstr := l_bigstr;
      ELSE
         l_smlstr := SUBSTR (l_bigstr, 1, l_idxval - 1);
         l_bigstr := SUBSTR (l_bigstr, l_idxval + 1);
      END IF;

      l_promo_tab (l_cnt) := l_smlstr;
      l_cnt := l_cnt + 1;
      EXIT WHEN l_idxval = 0;
   END LOOP;

   FOR promo_hist_rec IN promo_hist_curs (l_orig_act_date)
   LOOP
      FOR i IN l_promo_tab.FIRST .. l_promo_tab.LAST
      LOOP
         IF promo_hist_rec.x_promo_code = l_promo_tab (i)
         THEN
            l_promo_hist_tot := l_promo_hist_tot + 1;
         END IF;
      END LOOP;
   END LOOP;

   FOR pend_red_rec IN pend_rec_curs
   LOOP
      FOR i IN l_promo_tab.FIRST .. l_promo_tab.LAST
      LOOP
         IF pend_red_rec.x_promo_code = l_promo_tab (i)
         THEN
            l_pend_red_tot := l_pend_red_tot + 1;
         END IF;
      END LOOP;
   END LOOP;

   l_usage_cnt := NVL (l_promo_hist_tot, 0) + NVL (l_pend_red_tot, 0);
   RETURN l_usage_cnt;
EXCEPTION
   WHEN OTHERS
   THEN
      l_usage_cnt := NVL (l_promo_hist_tot, 0) + NVL (l_pend_red_tot, 0);
      RETURN l_usage_cnt;
END get_promo_usage_fun;
/