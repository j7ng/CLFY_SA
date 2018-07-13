CREATE OR REPLACE PACKAGE sa."CARRIERS_VERIFICATION" AS
  /********************************************************************************/
  /*    Copyright 2011 Tracfone  Wireless Inc. All rights reserved                */
  /*                                                                              */
  /* NAME     : carriers_verification                                                     */
  /* PURPOSE  : Package to handle all ESN service verification functionality      */
  /* FREQUENCY:                                                                   */
  /* PLATFORMS:                                                                   */
  /* REVISIONS:                                                                   */
  /*                                                                              */
  /* VERSION DATE       WHO        PURPOSE                                        */
  /* ------- ---------- ---------- -----------------------------------------------*/
  /* 1.1     03/21/2011 kacosta    Initial  Revision                              */
  /*                               Package spec was developed to support CR15767  */
  /*                               FIX ST MIN CHANGE ISSUES                       */
  /*                               Originally written by Curt Lindner             */
  /* 1.2     03/31/2011 kacosta    Changed package name                           */
  /********************************************************************************/
  --
  -- Global Package Variables
  --
  l_b_debug BOOLEAN := FALSE;
  --
  -- Public Functions
  --
  --********************************************************************************
  -- Function retreives the active site part objid by ESN
  --********************************************************************************
  --
  FUNCTION f_actve_site_part_objid_by_esn(p_esn IN table_site_part.x_service_id%TYPE) RETURN table_site_part.objid%TYPE;
  --
  -- Public Procedures
  --
  PROCEDURE min_change_allowed
  (
    p_esn             IN VARCHAR2
   ,p_zip             IN VARCHAR2
   ,p_site_part_objid IN NUMBER
   ,p_msg             OUT VARCHAR2
   ,p_sim_out         OUT VARCHAR2
  );
  --
  PROCEDURE min_change_allowed
  (
    p_esn     IN VARCHAR2
   ,p_zip     IN VARCHAR2
   ,p_msg     OUT VARCHAR2
   ,p_sim_out OUT VARCHAR2
  );
  --
--
END carriers_verification;
/