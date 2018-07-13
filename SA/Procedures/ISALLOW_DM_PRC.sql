CREATE OR REPLACE PROCEDURE sa.isallow_dm_prc(
   ip_esn IN VARCHAR2,
   ip_promo IN VARCHAR2,
   ip_chk IN VARCHAR2,
   op_cnt OUT NUMBER
)
/*****************************************************************
 * Procedure Name   : isallow_dm_enroll_prc
 * Description      : check if an esn is allowed for double minute
 *                    enrollment
 * Created by       : Vani Adapa
 * Date             : 04/26/2004
 *
 * History
 * ---------------------------------------------------------------
 * 04/26/04    VA      Initial Revision
 *                     CR3509 Changes - Double Minute Advantage Card
 *****************************************************************/
AS
   l_cnt PLS_INTEGER := 0;
   --Total Counts
   l_autopay_dm_tot PLS_INTEGER := 0; -- autopay double minute
   l_dbl_promo_tot PLS_INTEGER := 0; -- double minute promotion
   l_ph_promo_tot PLS_INTEGER := 0; -- double minute promo hist promotions
   l_pend_promo_tot PLS_INTEGER := 0; -- double minute pending promotions
   --Grand Total
   l_usage_cnt PLS_INTEGER := 0;
   --Variables to get individual double minute promocodes
   l_promo_code VARCHAR2 (100) := ip_promo;
   l_bigstr VARCHAR2 (2000) := l_promo_code;
   l_smlstr VARCHAR2 (2000);
   l_idxval PLS_INTEGER;
   --Temp Table to store individual promocodes
   TYPE promo_tab_type
   IS
   TABLE OF table_x_promotion.x_promo_code%TYPE INDEX BY BINARY_INTEGER;
   l_promo_tab promo_tab_type;
   l_promo_var VARCHAR2 (4000);
   l_ap_sql VARCHAR2 (4000);
   l_dm_sql VARCHAR2 (4000);
   l_pend_dm_sql VARCHAR2 (4000);
BEGIN
   LOOP
      l_idxval := INSTR (l_bigstr, ',');
      IF l_idxval = 0
      THEN
         l_smlstr := l_bigstr;
      ELSE
         l_smlstr := SUBSTR (l_bigstr, 1, l_idxval - 1);
         l_bigstr := SUBSTR (l_bigstr, l_idxval + 1);
      END IF;
      IF l_cnt = 0
      THEN
         l_promo_var := l_promo_var || '''' || l_smlstr || '''';
      ELSE
         l_promo_var := l_promo_var || ',' || '''' || l_smlstr || '''';
      END IF;
      l_promo_tab (l_cnt) := l_smlstr;
      l_cnt := l_cnt + 1;
      EXIT
      WHEN l_idxval = 0;
   END LOOP;
   l_promo_var := '(' || l_promo_var || ')';
   --
--   DBMS_OUTPUT.put_line(l_promo_var);
--   DBMS_OUTPUT.PUT_LINE('PEND SQL 1'||l_pend_dm_sql);
   --Autopay double minute counter
   l_ap_sql :=
   'SELECT COUNT (1)
     FROM table_x_autopay_details
    WHERE x_program_type = 3
      AND x_status IN (''A'',  ''E'')
      AND x_end_date IS NULL
      AND x_esn = :1';
   --
   --     DBMS_OUTPUT.PUT_LINE('l_ap_sql '||l_ap_sql);
   --DMPPCARD and DMUCARD enrollment counter
   l_dm_sql :=
   'SELECT COUNT (1)
        FROM table_x_promotion p,
             table_part_inst pi,
             table_x_group2esn ge,
             table_x_promotion_group pg,
             table_x_promotion_mtm mtm
       WHERE SYSDATE BETWEEN ge.x_start_date AND ge.x_end_date
         AND ge.groupesn2x_promo_group + 0 = pg.objid
         AND ge.x_annual_plan = 1
         AND pg.objid = mtm.x_promo_mtm2x_promo_group
         AND pi.objid = ge.groupesn2part_inst
         AND p.objid = mtm.x_promo_mtm2x_promotion
         AND pi.part_serial_no = :1
         AND p.x_promo_code IN ' || l_promo_var;
   --
   --   DBMS_OUTPUT.PUT_LINE('l_dm_sql '||l_dm_sql);
   --Seasonal Double minute ((program type '5') pending promotions counter
   l_pend_dm_sql :=
   'SELECT COUNT (1)
        FROM table_x_promotion a,
             table_x_pending_redemption b,
             table_part_inst c
       WHERE ((a.x_program_type = 5
        AND a.x_promo_code NOT LIKE ''DBLMNAD%'')
        OR (a.x_program_type <> 5
        AND a.x_promo_code LIKE ''RTDBL%''))
         AND SYSDATE BETWEEN a.x_start_date AND a.x_end_date
         AND a.objid = b.pend_red2x_promotion
         AND b.x_pend_red2site_part = c.x_part_inst2site_part
         AND c.part_serial_no = :1
         AND a.x_promo_code not in ' || l_promo_var;
   --
   --        DBMS_OUTPUT.PUT_LINE('l_pend_dm_sql '||l_pend_dm_sql);
   --Execute SQLs to get the counts
   IF ip_chk = 'YES'
   THEN
      EXECUTE IMMEDIATE l_dm_sql
      INTO l_dbl_promo_tot
      USING ip_esn;
   END IF;
   EXECUTE IMMEDIATE l_ap_sql
   INTO l_autopay_dm_tot
   USING ip_esn;
   EXECUTE IMMEDIATE l_pend_dm_sql
   INTO l_pend_promo_tot
   USING ip_esn;
   --
   --     DBMS_OUTPUT.PUT_LINE('PEND SQL '||l_pend_dm_sql);
   l_usage_cnt := NVL (l_autopay_dm_tot, 0) + NVL (l_dbl_promo_tot, 0) + NVL (
   l_pend_promo_tot, 0);
   op_cnt := l_usage_cnt;
   EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      l_usage_cnt := NVL (l_autopay_dm_tot, 0) + NVL (l_dbl_promo_tot, 0) + NVL
      (l_pend_promo_tot, 0);
      op_cnt := l_usage_cnt;
END isallow_dm_prc;
/