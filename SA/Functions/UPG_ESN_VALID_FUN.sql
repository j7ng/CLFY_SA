CREATE OR REPLACE FUNCTION sa."UPG_ESN_VALID_FUN" (
   ip_old_esn   IN   VARCHAR2,
   ip_new_esn   IN   VARCHAR2
)
   RETURN NUMBER
IS
/******************************************************************************/
/* Copyright (r) 2008 Tracfone Wireless Inc. All rights reserved
/*
/* Name         :   upg_esn_valid_fun
/* Purpose      :   Validates if an esn is valid for upgrade or not
/* Parameters   :   NONE
/* Platforms    :   Oracle 8.0.6 AND newer versions
/* Author       :   Curt Lindner
/* Date         :   01/23/2008
/* Revisions    :
/*
/* Version  Date      Who              Purpose
/* -------  --------  -------          --------------------------------------
/* 1.0     01/23/2008 Clindner         CR6578 - Initial revision

/******************************************************************************/

   CURSOR get_exch_esn_cur
   IS
      SELECT c.x_esn, cd.x_value
        FROM table_x_case_detail cd, table_case c
       WHERE 1 = 1
         AND cd.x_value || '' = ip_new_esn
         AND cd.x_name || '' = 'NEW_ESN'
         AND cd.detail2case = c.objid + 0
         AND c.s_title = 'DEFECTIVE PHONE'
         AND c.creation_time + 0 > TRUNC (SYSDATE) - 45
         AND c.x_esn = ip_old_esn;

   get_exch_esn_rec     get_exch_esn_cur%ROWTYPE;

   CURSOR get_oldesn_min_cur
   IS
      SELECT   x_min
          FROM table_site_part sp
         WHERE 1 = 1
           AND x_service_id = ip_old_esn
           AND part_status || '' IN ('Inactive')
      ORDER BY install_date DESC;

   get_oldesn_min_rec   get_oldesn_min_cur%ROWTYPE;

   CURSOR get_newesn_min_cur (ip_oldesn_min IN VARCHAR2)
   IS
      SELECT line.x_part_inst_status
        FROM table_part_inst line, table_part_inst new_esn
       WHERE 1 = 1
         AND line.part_serial_no = ip_oldesn_min
         AND line.part_to_esn2part_inst = new_esn.objid
         AND new_esn.part_serial_no = ip_new_esn;

   get_newesn_min_rec   get_newesn_min_cur%ROWTYPE;
BEGIN
   OPEN get_exch_esn_cur;

   FETCH get_exch_esn_cur
    INTO get_exch_esn_rec;

   IF get_exch_esn_cur%FOUND
   THEN
      OPEN get_oldesn_min_cur;

      FETCH get_oldesn_min_cur
       INTO get_oldesn_min_rec;

      IF get_oldesn_min_cur%FOUND
      THEN
         OPEN get_newesn_min_cur (get_oldesn_min_rec.x_min);

         FETCH get_newesn_min_cur
          INTO get_newesn_min_rec;

         IF     get_newesn_min_cur%FOUND
            AND get_newesn_min_rec.x_part_inst_status IN ('37', '39')
         THEN
            CLOSE get_exch_esn_cur;

            CLOSE get_oldesn_min_cur;

            CLOSE get_newesn_min_cur;

            RETURN 0;                                               --Success
         ELSE
            CLOSE get_exch_esn_cur;

            CLOSE get_oldesn_min_cur;

            CLOSE get_newesn_min_cur;

            RETURN 3;                --Min of old esn not reserved to new esn
         END IF;

         CLOSE get_newesn_min_cur;
      ELSE
         CLOSE get_exch_esn_cur;

         CLOSE get_oldesn_min_cur;

         RETURN 2;                            --Min not found for the old esn
      END IF;

      CLOSE get_oldesn_min_cur;
   ELSE
      CLOSE get_exch_esn_cur;

      RETURN 1;                                       --No exchange esn found
   END IF;

   CLOSE get_exch_esn_cur;
EXCEPTION
   WHEN OTHERS
   THEN
      CLOSE get_exch_esn_cur;

      CLOSE get_oldesn_min_cur;

      CLOSE get_newesn_min_cur;

      RETURN 4;                                           --any other failure
END;
/