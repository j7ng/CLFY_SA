CREATE OR REPLACE PROCEDURE sa."VALIDATE_SERVICE_PRC" (
   p_esn       IN       VARCHAR2,
   p_service   IN       VARCHAR2,
   p_res       OUT      NUMBER
)
AS
/* **************************************************************************************
* Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved                          *
* Purpose   :   This procedure is used to verify if the user can subscribe to one       *
*               of the Autopay programs and the Annual program                          *
* Author    :   TCS                                                                     *
* Date      :   6/xx/02                                                                 *
* 10182001  :   tcs     Commented the code to allow annual plan customers to            *
*                       register for Stayactive club--CR 895                            *
* 11192003  :   Vadapa  CR2196 Do not allow already enrolled DM customers with promos   *
*                       51777 / to reenroll                                       *
* 04212004  :   Gpintado CR2676 Do not allow already enrolled DM customers with promo   *
*                       55281                                                           *
* 03292005  : VShimoga  Applied 90 day colling period to ONLY Bonus Plan                *
*                       90 Days cooling perioed was applied to all the Autopay programs *
*                       Changed that to ONLY Bonus Plan                                 *
*****************************************************************************************/
   v_subser NUMBER := 0;
   v_apdet_count NUMBER := 0;
   v_annl_count NUMBER := 0;
   v_esn_not_null NUMBER := 0;
   v_warranty_dt DATE;
   v_end_date DATE;
   v_technology VARCHAR2 (20);
   v_count NUMBER := 0;


   CURSOR autopay_c
   IS
      SELECT *
        FROM table_x_autopay_details apd
       WHERE p_esn = apd.x_esn
         AND apd.x_end_date IS NULL
       ORDER BY apd.x_program_type;
--CR2196
   CURSOR dmpromo_enrol_chk_c (c_ip_esn IN VARCHAR2)
   IS
      SELECT 'X'
        FROM table_x_group2esn
       WHERE groupesn2x_promotion in (SELECT objid
                                       FROM table_x_promotion          -- took out due to customers wanting to upgrade to new promo.
                                      WHERE x_promo_code IN ('55281')) --('51777','50974','55281'))
         AND groupesn2part_inst = (SELECT objid
                                     FROM table_part_inst
                                    WHERE part_serial_no = c_ip_esn);


   dmpromo_enrol_chk_r dmpromo_enrol_chk_c%ROWTYPE;
--End CR2196

BEGIN
   SELECT COUNT (*)
     INTO v_apdet_count
     FROM table_x_autopay_details apd
    WHERE apd.x_esn = p_esn
      AND apd.x_end_date IS NULL;

   SELECT COUNT (*)
     INTO v_esn_not_null
     FROM table_x_autopay_details apd
    WHERE apd.x_esn = p_esn
      AND x_program_type = 3
      AND apd.x_end_date IS NOT NULL;


   IF (v_apdet_count <> 0)
   THEN
      FOR i IN autopay_c
      LOOP

         v_subser := i.x_program_type;


         IF (v_subser = 2)
         THEN
            -- Already subscribed for AutoPay(APP)
            p_res := 2;
            EXIT;
         ELSIF (v_subser = 3)
         THEN
--CR2196
            OPEN dmpromo_enrol_chk_c (i.x_esn);
            FETCH dmpromo_enrol_chk_c INTO dmpromo_enrol_chk_r;


            IF dmpromo_enrol_chk_c%FOUND
            THEN

               p_res := 8;
            ELSE
               -- Already subscribed for Hybrid Plan(HPP)
               p_res := 3;
            END IF;

            CLOSE dmpromo_enrol_chk_c;
--End CR2196

            EXIT;
         ELSIF (v_subser = 4)
         THEN
            -- Already subscribed for Deactivation Protection Plan (DPP)
            p_res := 4;

            --Can buy an Annual Card, if he is registered for DPP
            IF p_service = 5
            THEN
               p_res := 0;
            END IF;
         ELSE
            -- It isn't a valid service in Tracfone System.
            p_res := -1;
         END IF;
      END LOOP;
   ELSE
      -- There are no Auto Pay services associated with this customer
      IF (    p_service <> 4
          AND p_service <> 5)   -- IF APP/HPP, then check for the Annual Plan
      THEN
         /* Should not allow the Esn to enroll for the program if the warranty end date
         is not greater than or equal to sysdate+5 */
         SELECT COUNT (*)
           INTO v_count
           FROM table_site_part
          WHERE x_service_id = p_esn
            AND part_status = 'Active'
            AND x_expire_dt >= (SYSDATE + 5);


         IF v_count > 0
         THEN

            p_res := 0;
         ELSE
            p_res := 6;
            RETURN;
         END IF;

         -- Change done as per the CR 895, To allow both annual plan customers and one year service card customers
         --   to register for the Stay active club.   -10182002
         --change start CR 895


         -- Check Annual Plan
         /*   SELECT count(*) into v_annl_count FROM table_x_group2esn
                   WHERE groupesn2x_promo_group = (select objid from
                           table_x_promotion_group
                           where group_name ='ANNUALPLAN')
                     AND groupesn2part_inst = (select objid from
                           TABLE_PART_INST
                           where part_serial_no = p_esn
                             and x_domain = 'PHONES');
            IF (v_annl_count <> 0)
            THEN
                -- Annual Plan is registred for the customer.
                -- Check if the card due date is within 90 days from sysdate.
                -- In that case he can register.
                SELECT Sp.x_expire_dt INTO v_warranty_dt FROM table_site_part SP
                      WHERE SP.x_Service_Id = p_esn
                        AND SP.Part_Status = 'Active';
                IF (v_warranty_dt - 90 > sysdate)
                THEN
                    p_res := 5;
                    return;
                ELSE
                    p_res := 0;

                END IF;
            END IF;

   */    --change end CR 895


         --For Hybrid check if the phone is digital. If not, he is not allowed to
         --register
         IF p_service = 3
         THEN
            /*
 SELECT x_technology INTO v_technology
            FROM table_part_num PN, table_mod_level M, table_part_inst PI
            WHERE PI.n_Part_Inst2part_Mod = M.Objid
            AND M.Part_Info2part_Num = PN.Objid
            AND PI.Part_Serial_No = p_esn;
            IF v_technology = 'ANALOG' OR v_technology = '' OR v_technology is null THEN
               p_res:= 6;
            ELSE
  */

  -- Check whether the last enrolled program is Bonus Plan.
            IF (v_esn_not_null <> 0)
            THEN
               SELECT MAX (x_end_date)
                 INTO v_end_date
                 FROM table_x_autopay_details
                WHERE x_esn = p_esn
                AND   x_program_type = 3;


               IF (v_end_date + 90 > SYSDATE)
               THEN
                  p_res := 7;
               END IF;
            ELSE
               p_res := 0;
            END IF;
         --  END IF;

         ELSE
            -- Newly subscribing for the service
            p_res := 0;
         END IF;
      ELSE
         /* Should not allow the Esn to enroll for the program if the warranty end date
          is not greater than or equal to sysdate+5 */
         IF (p_service = 4)
         THEN
            SELECT COUNT (*)
              INTO v_count
              FROM table_site_part
             WHERE x_service_id = p_esn
               AND part_status = 'Active'
               AND x_expire_dt >= (SYSDATE + 5);


            IF v_count > 0
            THEN

               p_res := 0;
            ELSE
               p_res := 6;
               RETURN;
            END IF;
         END IF;

         -- Newly subscribing(May be for the Annual Plan service)
         p_res := 0;
      END IF;
   END IF;

   RETURN;
END;
/