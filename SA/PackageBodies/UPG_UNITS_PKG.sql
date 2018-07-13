CREATE OR REPLACE PACKAGE BODY sa."UPG_UNITS_PKG"
AS

   /************************************************************************************************
   |    Copyright   Tracfone  Wireless Inc. All rights reserved
   |
   | PURPOSE  :      To return the promo_units for internal port-in and migration
   /           To flag the old esn once the units are returned
   | FREQUENCY:
   | PLATFORMS:
   |
   | REVISIONS:
   | VERSION  DATE        WHO              PURPOSE
   | -------  ---------- -----             ------------------------------------------------------
   | 1.0      10/27/05   VAdapa              Initial revision
   | 1.1      10/23/05   VAdapa              WEB Upgrade Flow
   | 1.1      01/23/08   VAdapa              CR6578 (New PL/SQL) PVCS structure
   |************************************************************************************************/
   PROCEDURE get_promo_units(
      p_param_type IN VARCHAR2,
      p_param_out OUT NUMBER,
      p_esn IN VARCHAR2
      DEFAULT NULL --rev. 1.1
   )
   IS
      CURSOR get_enroll_info_cur
      IS
      SELECT upg.x_end_date
      FROM table_x_upg_units2esn upg, table_part_inst pi
      WHERE 1 = 1
      AND upg.x_units_type = p_param_type
      AND upg.upg_units2part_inst = pi.objid
      AND pi.part_serial_no = p_esn ;
      get_enroll_info_rec get_enroll_info_cur%ROWTYPE;
      CURSOR get_param_value
      IS
      SELECT x_param_value
      FROM table_x_parameters
      WHERE x_param_name = p_param_type;
      get_param_value_rec get_param_value%ROWTYPE;
   BEGIN
      OPEN get_param_value;
      FETCH get_param_value
      INTO get_param_value_rec;
      CLOSE get_param_value;
      IF p_esn
      IS
      NULL
      THEN
         p_param_out := 0;
         RETURN;
      ELSE
         OPEN get_enroll_info_cur;
         FETCH get_enroll_info_cur
         INTO get_enroll_info_rec;
         IF get_enroll_info_cur%FOUND
         THEN
            IF get_enroll_info_rec.x_end_Date
            IS
            NOT NULL
            THEN
               p_param_out := 0;
               CLOSE get_enroll_info_cur;
               RETURN;
            ELSE
               IF p_param_type = 'TDMA_MIGR_PROMO_UNITS'
               THEN
                  p_param_out := get_param_value_rec.x_param_value;
                  CLOSE get_enroll_info_cur;
                  RETURN;
               END IF;
            END IF;
         ELSE
            IF p_param_type = 'TDMA_MIGR_PROMO_UNITS'
            THEN
               p_param_out := 0;
               CLOSE get_enroll_info_cur;
               RETURN;
            ELSIF p_param_type = 'INTPORTIN_PROMO_UNITS'
            THEN
               p_param_out := get_param_value_rec.x_param_value;
               CLOSE get_enroll_info_cur;
               RETURN;
            END IF;
         END IF;
      END IF;
      EXCEPTION
      WHEN OTHERS
      THEN
         p_param_out := 0;
   END get_promo_units;
   --
   PROCEDURE get_promo_flag(
      p_param_type IN VARCHAR2,
      p_param_out OUT VARCHAR2
   )
   IS
   BEGIN
      SELECT x_param_value
      INTO p_param_out
      FROM table_x_parameters
      WHERE x_param_name = p_param_type;
      EXCEPTION
      WHEN OTHERS
      THEN
         p_param_out := 0;
   END get_promo_flag;
   --
   PROCEDURE set_promo_units(
      p_esn IN VARCHAR2,
      p_units_type IN VARCHAR2,
      p_case_id IN VARCHAR2
      DEFAULT NULL,
      p_result OUT NUMBER
   )
   IS
      CURSOR get_enroll_info_cur
      IS
      SELECT upg.objid,
         pr.x_param_value
      FROM table_x_parameters pr, table_x_upg_units2esn upg, table_part_inst pi
      WHERE pi.objid = upg.upg_units2part_inst
      AND SYSDATE BETWEEN upg.x_start_date
      AND NVL (upg.x_end_date, SYSDATE + 1)
      AND upg.x_units_type = pr.x_param_name
      AND upg.x_units_type = p_units_type
      AND pi.part_serial_no = p_esn;
      get_enroll_info_rec get_enroll_info_cur%ROWTYPE;
      CURSOR get_esn_objid_cur
      IS
      SELECT objid
      FROM table_part_inst
      WHERE part_serial_no = p_esn;
      get_esn_objid_rec get_esn_objid_cur%ROWTYPE;
      CURSOR get_case_objid_cur
      IS
      SELECT objid
      FROM table_case
      WHERE id_number = p_case_id;
      get_case_objid_rec get_case_objid_cur%ROWTYPE;
      l_upg_objid NUMBER := 0;
      l_upg_units NUMBER := 0;
      l_case_objid NUMBER;
      l_promo_units NUMBER := 0;
   BEGIN
      upg_units_pkg.get_promo_units (p_units_type, l_promo_units);
      IF p_units_type = 'TDMA_MIGR_PROMO_UNITS'
      THEN
         OPEN get_enroll_info_cur;
         FETCH get_enroll_info_cur
         INTO get_enroll_info_rec;
         IF get_enroll_info_cur%FOUND
         THEN
            l_upg_objid := get_enroll_info_rec.objid;
            l_upg_units := get_enroll_info_rec.x_param_value;
         ELSE
            l_upg_objid := 0;
            l_upg_units := 0;
         END IF;
         CLOSE get_enroll_info_cur;
         IF l_upg_objid = 0
         THEN
            p_result := 0;
            RETURN;
         ELSE
            UPDATE table_x_upg_units2esn SET x_end_date = SYSDATE
            WHERE objid = l_upg_objid;
            COMMIT;
            p_result := l_promo_units;
            RETURN;
         END IF;
      ELSIF p_units_type = 'INTPORTIN_PROMO_UNITS'
      THEN
         OPEN get_esn_objid_cur;
         FETCH get_esn_objid_cur
         INTO get_esn_objid_rec;
         CLOSE get_esn_objid_cur;
         IF p_case_id
         IS
         NOT NULL
         THEN
            OPEN get_case_objid_cur;
            FETCH get_case_objid_cur
            INTO get_case_objid_rec;
            IF get_case_objid_cur%FOUND
            THEN
               l_case_objid := get_case_objid_rec.objid;
            ELSE
               l_case_objid := NULL;
            END IF;
            CLOSE get_case_objid_cur;
         ELSE
            l_case_objid := NULL;
         END IF;
         INSERT
         INTO table_x_upg_units2esn(
            objid,
            upg_units2part_inst,
            upg_units2case,
            x_start_date,
            x_end_date,
            x_units_type
         )         VALUES(
            seq ('x_upg_units2esn'),
            get_esn_objid_rec.objid,
            l_case_objid,
            SYSDATE,
            SYSDATE,
            p_units_type
         );
         COMMIT;
         p_result := l_promo_units;
         RETURN;
      END IF;
      EXCEPTION
      WHEN OTHERS
      THEN
         p_result := 0;
         RETURN;
   END set_promo_units;
END upg_units_pkg;
/