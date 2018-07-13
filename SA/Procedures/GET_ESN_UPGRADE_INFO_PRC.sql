CREATE OR REPLACE PROCEDURE sa."GET_ESN_UPGRADE_INFO_PRC" (
   p_esn       IN       VARCHAR2,
   p_qualify   OUT      NUMBER
)
IS
/********************************************************************************************/
   /*    Copyright   2004 Tracfone  Wireless Inc. All rights reserved
   /*
   /* NAME     :       get_esn_upgrade_info_prc
   /* PURPOSE  :       To find if the esn is qualified for "Tracfone Airtime Upgrade" promotion
   /* FREQUENCY:
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.
   /*
   /* REVISIONS:
   /* VERSION  DATE        WHO                 PURPOSE
   /* -------  ---------- -----                ---------------------------------------------
   /*  1.0     11/18/05   VA         I       Initial  Revision
   /*  1.1     11/22/05   VA              Changed the qualifying date
   /*  1.2     11/22/05   VA              Fixed a bug for CR4792
   /*  1.3     01/19/06   VA             CR4949 - Modify to qualify inactive esns from their first redemption onwards
   /********************************************************************************************/
   l_esn_status      VARCHAR2 (20);
   l_red_count       NUMBER        := 0;
   l_orig_act_date   DATE;
BEGIN
   BEGIN
      SELECT x_part_inst_status
        INTO l_esn_status
        FROM table_part_inst
       WHERE part_serial_no = p_esn;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_esn_status := NULL;
   END;

   SELECT NVL (MIN ((DECODE (refurb_yes.is_refurb,
                             0, nonrefurb_act_date.init_act_date,
                             refurb_act_date.init_act_date
                            )
                    )
                   ),
               SYSDATE
              )
     INTO l_orig_act_date
     FROM (SELECT COUNT (1) is_refurb
             FROM table_site_part sp_a
            WHERE sp_a.x_service_id = p_esn                                  --
                  AND sp_a.x_refurb_flag = 1) refurb_yes,
          (SELECT MIN (install_date) init_act_date
             FROM table_site_part sp_b
            WHERE sp_b.x_service_id = p_esn                                  --
              AND sp_b.part_status || '' IN ('Active', 'Inactive')
              AND x_refurb_flag <> 1) refurb_act_date,
          (SELECT MIN (install_date) init_act_date
             FROM table_site_part sp_d
            WHERE sp_d.x_service_id = p_esn                                  --
              AND sp_d.part_status || '' IN ('Active', 'Inactive')) nonrefurb_act_date;

   IF l_esn_status IS NULL
   THEN
      p_qualify := 1;
      RETURN;
   ELSIF l_esn_status IN ('50', '150')                               --New ESN
   THEN
      IF l_orig_act_date >= '23-nov-05'
      THEN
         p_qualify := 0;
         RETURN;
      ELSE
         p_qualify := 2;
         RETURN;
      END IF;
   ELSIF l_esn_status = '52'                                          --CR4949
   THEN                                                           --Active ESN
      SELECT COUNT (1)
        INTO l_red_count
        FROM table_x_red_card rc, table_x_call_trans ct
       WHERE ct.objid = rc.red_card2call_trans
         AND rc.x_red_date >= TO_DATE ('23-nov-05')
         AND ct.x_result = 'Completed'
         AND ct.x_service_id = p_esn;

      IF l_red_count = 0 AND l_orig_act_date >= TO_DATE ('23-nov-05')
      THEN
         p_qualify := 0;
         RETURN;
      ELSIF l_red_count >= 1 AND SYSDATE >= '23-nov-05'
      THEN
         p_qualify := 0;
         RETURN;
      ELSE
         p_qualify := 2;
         RETURN;
      END IF;
   ELSE                                                               --CR4949
      IF SYSDATE >= '24-jan-06'
      THEN                                                    --inactive esns
         p_qualify := 0;
         RETURN;
      ELSE
         p_qualify := 2;
         RETURN;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      p_qualify := 3;
      RETURN;
END;
/