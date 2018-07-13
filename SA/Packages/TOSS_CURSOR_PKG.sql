CREATE OR REPLACE PACKAGE sa."TOSS_CURSOR_PKG"
IS
/******************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         TOSS_CURSOR_PKG(SPECIFICATIONS)                              */
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


   /* cursor to retrieve table_part_inst based on part_serial_no  */
   CURSOR table_part_inst_cur (ip_part_serial_no VARCHAR2) RETURN table_part_inst%ROWTYPE;

   /* cursor to retrieve table_site record associated with part_serial_no */
   CURSOR table_site_cur (ip_part_serial_no VARCHAR2,  ip_domain VARCHAR2) RETURN table_site%ROWTYPE;

   /* cursor to retrieve table_part_num record associated with a given part_serial_no */
   CURSOR table_part_num_cur (ip_part_serial_no VARCHAR2) RETURN table_part_num%ROWTYPE;

   /* cursor to retrieve table_part_num record associated with upc_code */
   CURSOR table_part_num_upc_cur (ip_upc_code VARCHAR2) RETURN table_part_num%ROWTYPE;

   /* cursor to retrieve table_mod_level record associated with the table_part_number.objid*/
   CURSOR table_mod_level_cur (ip_pn_objid NUMBER) RETURN table_mod_level%ROWTYPE;

   /* cursor to retrieve table_mod_level record based on the table_mod_level.objid */
   CURSOR table_mod_objid_cur (ip_ml_objid NUMBER) RETURN table_mod_level%ROWTYPE;

   /* cursor to retrieve table_mod_level record based on unique key(mod_level,partinfo2partnum) */
   /* and active */
   CURSOR table_mod_unique_cur (ip_ml_level VARCHAR2, ip_ml_pi2pn NUMBER, ip_active VARCHAR2)
     RETURN table_mod_level%ROWTYPE;

   /* cursor to retrive table_mod_level record based on mod level being NULL (cards) */
   /* revision */
   CURSOR table_ml_null_cur (ip_ml_pi2pn NUMBER, ip_active VARCHAR2)
     RETURN table_mod_level%ROWTYPE;

   /* cursor to retrieve table_inv_bin record assouciated with the table_inv_bin.bin_name */
   CURSOR table_inv_bin_cur (ip_bin_name VARCHAR2) RETURN table_inv_bin%ROWTYPE;

   /* cursor to retrieve table_x_posa record associated with the table_site.site_id */
   CURSOR table_x_posa_cur (ip_site_id VARCHAR2) RETURN table_x_posa%ROWTYPE;

   /* cursor to retrive table_user record associated with the given login_name */
   CURSOR table_user_cur (ip_login_name VARCHAR2) RETURN table_user%ROWTYPE;

   /* cursor to retrieve table_x_code_table record associated with the given code number */
   CURSOR table_x_code_cur (ip_code_number IN VARCHAR2) RETURN table_x_code_table%ROWTYPE;
/** over loading ***/
--CURSOR table_site_cur (ip_site_id VARCHAR2) RETURN  table_site%ROWTYPE;
   /* ROADSIDE */
  /* cursor to retrieve table_road_inst based on part_serial_no  */
  CURSOR table_road_inst_cur (ip_part_serial_no VARCHAR2) RETURN table_x_road_inst%ROWTYPE;

  /* cursor to retrieve table_part_num record based on the objid */
  CURSOR table_part_number_cur (ip_objid NUMBER)  RETURN table_part_num%ROWTYPE;

  /* cursor to retrieve table_site record based on the x_fin_cust_id */
  CURSOR site_part_fin_cust_id_cur (ip_fin_cust_id VARCHAR2) RETURN table_site%ROWTYPE;

  /* cursor to retrieve table_prt_domain record based on the domain*/
  CURSOR table_prt_domain_cur (ip_domain VARCHAR2) RETURN table_prt_domain%ROWTYPE;

  /* Cursor to retrieve table_part_num record based on part_num */
  CURSOR table_pn_part_cur (ip_part_number VARCHAR2) RETURN table_part_num%ROWTYPE;


  /* Cursor to retrieve table_x_pricing record based on the part_num_objid */
  CURSOR table_pricing_cur (ip_part_num_objid NUMBER, ip_price_line_id NUMBER) RETURN table_x_pricing%ROWTYPE;

  /*Cursor to retrieve part_num record based on table_x_road_inst.part_serial_no*/
     CURSOR table_part_num_road_cur (ip_part_serial_no VARCHAR2)
   RETURN table_part_num%ROWTYPE;

  /* Cursot to retrieve table_site rec based on table_x_road_inst.part_serial_no*/
  /*  and table_x_road_inst.x_domain */
     CURSOR table_site_road_cur (ip_part_serial_no VARCHAR2,  ip_domain VARCHAR2)
   RETURN table_site%ROWTYPE;

   /*Cursor to retrieve table_site_part rec based on the x_service_id  and    */
   /* ip_part_status   */
   CURSOR table_site_part_cur  (ip_x_service_id  VARCHAR2, ip_part_status VARCHAR2)
   RETURN table_site_part%ROWTYPE;

  /* Cursor to retrieve table_x_frequency record based on frequency */
  CURSOR table_x_frequency_cur (ip_frequency NUMBER) RETURN table_x_frequency%ROWTYPE;

  /* Cursor to retrieve mtm_part_num14_x_frequency0 record based on frequency */
  CURSOR part_num14_x_frequency0_cur (ip_part_num2x_frequency NUMBER, ip_x_frequency2part_num NUMBER)
  RETURN mtm_part_num14_x_frequency0%ROWTYPE;

  /* Cursor to retrieve table_x_default_preload record. */
  CURSOR table_x_default_preload_cur RETURN table_x_default_preload%ROWTYPE;

END TOSS_CURSOR_PKG;
/