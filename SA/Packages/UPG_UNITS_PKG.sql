CREATE OR REPLACE PACKAGE sa."UPG_UNITS_PKG"
AS
/* Formatted on 2006/10/27 18:11 (Formatter Plus v4.8.6) */
   /************************************************************************************************
   |    Copyright   Tracfone  Wireless Inc. All rights reserved
   |
   | PURPOSE  :  To return the promo_units for internal port-in and migration
   /       To flag the old esn once the units are returned
   | FREQUENCY:
   | PLATFORMS:
   |
   | REVISIONS:
   | VERSION  DATE        WHO              PURPOSE
   | -------  ---------- -----             ------------------------------------------------------
   | 1.0      10/27/05   VAdapa         Initial revision
   | 1.1      10/23/07   VAdapa         WEB Upgrade Flow
   |************************************************************************************************/
   PROCEDURE get_promo_units(
      p_param_type IN VARCHAR2,
      p_param_out OUT NUMBER,
      p_esn IN VARCHAR2
      DEFAULT NULL --rev. 1.1
   );
   PROCEDURE get_promo_flag(
      p_param_type IN VARCHAR2,
      p_param_out OUT VARCHAR2
   );
   PROCEDURE set_promo_units(
      p_esn IN VARCHAR2,
      p_units_type IN VARCHAR2,
      p_case_id IN VARCHAR2
      DEFAULT NULL,
      p_result OUT NUMBER
   );
END upg_units_pkg;
/