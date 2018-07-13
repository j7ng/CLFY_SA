CREATE OR REPLACE PROCEDURE sa."GET_BUYGETFREE_QUAL_PRC" (
   p_esn                  IN       VARCHAR2,
   p_group_name   IN       VARCHAR2,
   p_result           OUT      VARCHAR2
)
AS
/***********************************************************************************************/
/* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved                               */
/*                                                                                                                                 */
/* Name         :   get_buygetfree_qual_prc                                                                 */
/* Purpose      :   checks if an esn is qualified for a "buy1get1free" promotion         */
/* Parameters   :                                                                                                        */
/* Platforms    :   Oracle 8.0.6 AND newer versions                                                 */
/* Author       :                                                                                                             */
/* Date         :   11/09/2006                                                                                         */
/* Revisions    :                                                                                                           */
/*                                                                                                                                 */
/* Version  PVCS Revision  Date        Who             Purpose                                     */
/* -------  -------------  ----------  -------         --------------------------------------  */
/* 1.0     1.0          11/09/06     VAdapa         Initial Revision
/* 1.1     1.1          11/13/06     VAdapa         Fixed a defect for CR5759
/* 1.2     1.2          11/14/06     VAdapa         Fixed a defect for CR5759
/* 1.3     1.3          06/28/07     ICanavan      CR6424 Remove validation
/* 		   							 				   	   	   		 of Suspension and Promise to Pay
/* 1.4     1.4          01/03/08     ICanavan      CR6657 change promo date range to 7 days
/*
/****************************************************************************/

   l_result         NUMBER;
--  CR6424   l_esn_deact_dt   DATE;
--  CR6424   l_old_expy_dt      DATE;
-- CR6424    l_new_expy_dt    DATE;
-- CR6424    l_esn_type           VARCHAR2 (20);

-- CR6424
--    CURSOR c1
--    IS
--       SELECT program_name
--         FROM buy_get_free_esns
--        WHERE esn = p_esn;
--
--    r1               c1%ROWTYPE;

   CURSOR c2
   IS
      SELECT 1 RESULT
        FROM table_x_promotion_group pg, table_x_group2esn ge
       WHERE pg.group_name = p_group_name
         AND ge.groupesn2x_promo_group + 0 = pg.objid
         AND ge.groupesn2part_inst
             = (SELECT objid
                     FROM table_part_inst
                  WHERE part_serial_no = p_esn)
         AND SYSDATE BETWEEN ge.x_start_date
         AND ((trunc(ge.x_start_date) + 7)-(1 / 86400)) ;

-- CR6657  AND SYSDATE BETWEEN ge.x_start_date AND NVL (ge.x_end_date,SYSDATE + 1 );
-- CR6424  AND (SYSDATE BETWEEN l_esn_deact_dt AND l_esn_deact_dt + 30
--                  OR SYSDATE BETWEEN l_old_expy_dt AND l_new_expy_dt

   r2               c2%ROWTYPE;

-- CR6424
--    CURSOR c3
--    IS
--       SELECT old_expy_dt, new_expy_dt
--         FROM x_duedate_ext_esn
--        WHERE esn = p_esn
--          AND updt_yn = 'Y'
--          AND SYSDATE BETWEEN old_expy_dt AND new_expy_dt
--          AND ROWNUM < 2;
--
--    r3               c3%ROWTYPE;

-- CR6424
--    CURSOR c4
--    IS
--       SELECT MAX (service_end_dt) serv_end_dt
--         FROM table_site_part sp1
--        WHERE sp1.x_service_id = p_esn AND x_deact_reason LIKE 'PASTDUE%';
--
--    r4               c4%ROWTYPE;
BEGIN

-- CR6424
--    OPEN c1;
--    FETCH c1
--     INTO r1;
--    IF c1%FOUND
--    THEN
--       l_esn_type := r1.program_name;
--    ELSE
--       l_esn_type := NULL;
--    END IF;
--    CLOSE c1;
--    IF l_esn_type = 'SUS'
--    THEN
--       OPEN c4;
--       FETCH c4
--        INTO r4;
--       IF c4%FOUND
--       THEN
--          l_esn_deact_dt := r4.serv_end_dt;
--       ELSE
--          l_esn_deact_dt := SYSDATE - 1;
--       END IF;
--       CLOSE c4;
--    ELSIF l_esn_type = 'PTP'
--    THEN
--       OPEN c3;
--       FETCH c3
--        INTO r3;
--       IF c3%FOUND
--       THEN
--          l_old_expy_dt := r3.old_expy_dt;
--          l_new_expy_dt := r3.new_expy_dt;
--       ELSE
--          l_old_expy_dt := SYSDATE - 2;
--          l_new_expy_dt := SYSDATE - 1;
--       END IF;
--       CLOSE c3;
--    ELSE
--       p_result := 'F';
--    END IF;

   OPEN c2;

   FETCH c2
    INTO r2;

   IF c2%FOUND
   THEN
      l_result := r2.RESULT;
   ELSE
      l_result := 0;
   END IF;

   CLOSE c2;

   IF l_result = 1
   THEN
      p_result := 'S';
   ELSE
      p_result := 'F';
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      p_result := 'F';
END get_buygetfree_qual_prc;
/