CREATE OR REPLACE PROCEDURE sa."UPD_PROMO_CLICK_PLAN_PRC" (
   ip_esn IN VARCHAR2,
   op_result OUT NUMBER -- 0=SUCCESS,1=FAILURE
)
AS
   i_dll NUMBER;
   i_tech VARCHAR2(20);
BEGIN
   SELECT pn.x_dll,
      pn.x_technology
   INTO i_dll, i_tech
   FROM table_mod_level ml, table_part_num pn, table_part_inst pi
   WHERE pi.n_part_inst2part_mod + 0 = ml.objid
   AND ml.part_info2part_num = pn.objid
   AND pi.part_serial_no = ip_esn;
   IF (i_tech = 'ANALOG' )
   OR (i_dll IN (6, 7, 8))
   THEN
      UPDATE table_site_part SET SITE_PART2X_NEW_PLAN = (
      SELECT objid
      FROM table_x_click_plan
      WHERE x_click_type = 'R1_PROMO')
      WHERE x_service_id = ip_esn
      AND part_status ||'' = 'Active';
   ELSIF (i_dll >= 10 )
   AND (i_dll NOT BETWEEN 11
   AND 17)
   THEN
      UPDATE table_site_part SET SITE_PART2X_NEW_PLAN = (
      SELECT objid
      FROM table_x_click_plan
      WHERE x_click_type = 'R2_PROMO')
      WHERE x_service_id = ip_esn
      AND part_status ||'' = 'Active';
   ELSIF i_dll IN (12, 13, 17)
   THEN
      UPDATE table_site_part SET SITE_PART2X_NEW_PLAN = (
      SELECT objid
      FROM table_x_click_plan
      WHERE x_click_type = 'R3_PROMO')
      WHERE x_service_id = ip_esn
      AND part_status ||'' = 'Active';
   ELSIF i_dll IN (11, 14, 15, 16)
   THEN
      UPDATE table_site_part SET SITE_PART2X_NEW_PLAN = (
      SELECT objid
      FROM table_x_click_plan
      WHERE x_click_type = 'R4_PROMO')
      WHERE x_service_id = ip_esn
      AND part_status ||'' = 'Active';
   END IF;
   IF SQL%rowcount = 1
   THEN
      COMMIT;
      op_result := 0;
   ELSE
      op_result := 1;
   END IF;
   EXCEPTION
   WHEN OTHERS
   THEN
      op_result := 1;
END upd_promo_click_plan_prc;
/