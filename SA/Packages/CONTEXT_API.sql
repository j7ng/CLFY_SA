CREATE OR REPLACE PACKAGE sa.context_api AS
  /********************************************************************************/
  /*    Copyright 2011 Tracfone  Wireless Inc. All rights reserved                */
  /*                                                                              */
  /* NAME     : context_api                                                       */
  /* PURPOSE  : Package to handle set parameter namespace context functionality   */
  /* FREQUENCY:                                                                   */
  /* PLATFORMS:                                                                   */
  /* REVISIONS:                                                                   */
  /*                                                                              */
  /* VERSION DATE     WHO        PURPOSE                                          */
  /* ------- -------- ---------- -------------------------------------------------*/
  /* 1.0     02/17/11 kacosta    Initial  Revision                                */
  /*                             Package body was developed to support CR15468    */
  /*                             Tune high cpu/io sql from web csr                */
  /********************************************************************************/
  --
  -- Global Package Variables
  --
  l_b_debug BOOLEAN := FALSE;
  --
  -- Public Procedures
  --
  PROCEDURE set_parameter
  (
    p_name          IN VARCHAR2
   ,p_value         IN VARCHAR2
   ,p_error_code    OUT INTEGER
   ,p_error_message OUT VARCHAR2
  );
  --
END context_api;
/