CREATE OR REPLACE PACKAGE BODY sa."TOSS_CURSOR_PKG"
IS
/******************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         TOSS_CURSOR_PKG(BODY)                                        */
/* PURPOSE:      This package serves as a common repository of commomnly used */
/*               cursor by the TOSS applications and related batch process    */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO               PURPOSE                             */
/* -------  ----------  ---------------   ----------------------------------- */
/* 1.0      12/18/01     Miguel Leon      Initial Revision                    */
/*                                                                            */
/* 1.1      03/17/02     Miguel Leon      Added cursor table_mod_unique_cur   */
/*                                                                            */
/* 1.2      07/15/02     Miguel Leon      Adding new cursor table_site_part   */
/*                                                                            */
/* 1.3      09/11/02     Miguel Leon      Added new cursor table_ml_null_cur  */
/*                                                                            */
/******************************************************************************/



/*****************************************************************************/
   CURSOR table_part_inst_cur (ip_part_serial_no VARCHAR2)
   RETURN table_part_inst%ROWTYPE
   IS
      SELECT *
        FROM table_part_inst
       WHERE part_serial_no = ip_part_serial_no;

/*****************************************************************************/
   CURSOR table_site_cur (ip_part_serial_no VARCHAR2,  ip_domain VARCHAR2)
   RETURN table_site%ROWTYPE
   IS
      SELECT ts.*
        FROM table_site ts, table_inv_bin ib, table_part_inst pi
       WHERE pi.part_serial_no = ip_part_serial_no
         AND pi.x_domain = ip_domain
         AND pi.part_inst2inv_bin = ib.objid
         AND ib.bin_name = ts.site_id;


/*****************************************************************************/
   CURSOR table_part_num_cur (ip_part_serial_no VARCHAR2)
   RETURN table_part_num%ROWTYPE
   IS
      SELECT pn.*
        FROM table_part_num pn, table_part_inst pi, table_mod_level ml
       WHERE pi.N_PART_INST2PART_MOD = ml.objid
         AND ml.part_info2part_num = pn.objid
         AND pi.part_serial_no = ip_part_serial_no;


/*****************************************************************************/
   CURSOR table_part_num_upc_cur (ip_upc_code VARCHAR2)
   RETURN table_part_num%ROWTYPE
   IS
      SELECT pn.*
        FROM table_part_num pn
       WHERE pn.x_upc = ip_upc_code;

/*****************************************************************************/
   CURSOR table_mod_level_cur (ip_pn_objid NUMBER)
   RETURN table_mod_level%ROWTYPE
   IS
      SELECT ml.*
        FROM table_mod_level ml
       WHERE ml.part_info2part_num = ip_pn_objid;

/*****************************************************************************/

   CURSOR table_mod_unique_cur (ip_ml_level VARCHAR2, ip_ml_pi2pn NUMBER, ip_active VARCHAR2)
     RETURN table_mod_level%ROWTYPE
	 IS
	    SELECT ml.*
		  FROM table_mod_level ml
		 WHERE ml.part_info2part_num = ip_ml_pi2pn
		   AND ml.MOD_LEVEL = ip_ml_level
		   AND ml.ACTIVE = ip_active;

/*****************************************************************************/

   CURSOR table_ml_null_cur (ip_ml_pi2pn NUMBER, ip_active VARCHAR2)
     RETURN table_mod_level%ROWTYPE
	 IS
	   SELECT ml.*
	     FROM table_mod_level ml
		WHERE ml.part_info2part_num = ip_ml_pi2pn
		  AND ml.active  = ip_active
		  AND ml.mod_level IS NULL;



/*****************************************************************************/
   CURSOR table_inv_bin_cur (ip_bin_name VARCHAR2)
   RETURN table_inv_bin%ROWTYPE
   IS
      SELECT ib.*
        FROM table_inv_bin ib
       WHERE ib.bin_name = ip_bin_name;

/*****************************************************************************/
   CURSOR table_x_code_cur (ip_code_number IN VARCHAR2)
   RETURN table_x_code_table%ROWTYPE
   IS
      SELECT xc.*
        FROM table_x_code_table xc
       WHERE x_code_number = ip_code_number;

/*****************************************************************************/
   CURSOR table_user_cur (ip_login_name VARCHAR2)
   RETURN table_user%ROWTYPE
   IS
      SELECT tu.*
        FROM table_user tu
       WHERE tu.LOGIN_NAME = ip_login_name;

/*****************************************************************************/
   CURSOR table_x_posa_cur (ip_site_id VARCHAR2)
   RETURN table_x_posa%ROWTYPE
   IS
      SELECT *
        FROM table_x_posa
       WHERE site_id = ip_site_id;

/*****************************************************************************/
   CURSOR table_road_inst_cur (ip_part_serial_no VARCHAR2)
   RETURN table_x_road_inst%ROWTYPE
   IS
      SELECT *
        FROM table_x_road_inst
       WHERE part_serial_no = ip_part_serial_no;

/*****************************************************************************/
  CURSOR table_part_number_cur (ip_objid NUMBER)
  RETURN table_part_num%ROWTYPE
  IS
     SELECT *
	   FROM table_part_num
	  WHERE objid = ip_objid;

/*****************************************************************************/
 CURSOR site_part_fin_cust_id_cur (ip_fin_cust_id VARCHAR2)
 RETURN table_site%ROWTYPE
 IS
     SELECT *
	   FROM table_site
	  WHERE type = 3
	    AND x_fin_cust_id = ip_fin_cust_id;

/*****************************************************************************/

  CURSOR table_prt_domain_cur (ip_domain VARCHAR2)
  RETURN table_prt_domain%ROWTYPE
  IS
     SELECT *
	   FROM table_prt_domain
	  WHERE name = ip_domain;

/*****************************************************************************/
  CURSOR table_pn_part_cur (ip_part_number VARCHAR2)
  RETURN table_part_num%ROWTYPE
  IS
     SELECT *
	   FROM table_part_num
	  WHERE part_number = ip_part_number;


/*****************************************************************************/
  CURSOR table_pricing_cur (ip_part_num_objid NUMBER, ip_price_line_id NUMBER)
  RETURN table_x_pricing%ROWTYPE
  IS
     SELECT *
	   FROM table_x_pricing
	  WHERE x_pricing2part_num = ip_part_num_objid
	    AND x_fin_priceline_id = ip_price_line_id ;

/******************************************************************************/
CURSOR table_mod_objid_cur (ip_ml_objid NUMBER) RETURN table_mod_level%ROWTYPE
IS
   SELECT *
     FROM table_mod_level
    WHERE objid = ip_ml_objid;

/******************************************************************************/
     CURSOR table_part_num_road_cur (ip_part_serial_no VARCHAR2)
   RETURN table_part_num%ROWTYPE
   IS
      SELECT pn.*
        FROM table_part_num pn, table_x_road_inst ri, table_mod_level ml
       WHERE ri.N_ROAD_INST2PART_MOD = ml.objid
         AND ml.part_info2part_num = pn.objid
         AND ri.part_serial_no = ip_part_serial_no;

/******************************************************************************/
   CURSOR table_site_road_cur (ip_part_serial_no VARCHAR2,  ip_domain VARCHAR2)
   RETURN table_site%ROWTYPE
   IS
      SELECT ts.*
        FROM table_site ts, table_inv_bin ib, table_x_road_inst ri
       WHERE ri.part_serial_no = ip_part_serial_no
         AND ri.x_domain = ip_domain
         AND ri.road_inst2inv_bin = ib.objid
         AND ib.bin_name = ts.site_id;

/******************************************************************************/
   CURSOR table_site_part_cur (ip_x_service_id VARCHAR2, ip_part_status VARCHAR2)
   RETURN table_site_Part%ROWTYPE
   IS
      SELECT sp.*
	    FROM table_site_part sp
	   WHERE x_service_id = ip_x_service_id
	     AND part_status||'' = ip_part_status;

/*****************************************************************************/
  CURSOR table_x_frequency_cur (ip_frequency NUMBER)
  RETURN table_x_frequency%ROWTYPE
  IS
     SELECT *
	   FROM table_x_frequency
	  WHERE x_frequency = ip_frequency;

/*****************************************************************************/
  CURSOR part_num14_x_frequency0_cur (ip_part_num2x_frequency NUMBER, ip_x_frequency2part_num NUMBER)
  RETURN mtm_part_num14_x_frequency0%ROWTYPE
  IS
     SELECT *
	   FROM mtm_part_num14_x_frequency0
	  WHERE part_num2x_frequency = ip_part_num2x_frequency
          AND x_frequency2part_num = ip_x_frequency2part_num;

/*****************************************************************************/
  CURSOR table_x_default_preload_cur
  RETURN table_x_default_preload%ROWTYPE
  IS
     SELECT *
	   FROM table_x_default_preload;
END;
/