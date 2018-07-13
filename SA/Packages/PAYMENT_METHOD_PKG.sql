CREATE OR REPLACE PACKAGE sa.PAYMENT_METHOD_PKG AS
  /********************************************************************************/
  /*    Copyright 2009 Tracfone  Wireless Inc. All rights reserved                */
  /*                                                                              */
  /* NAME     : PAYMENT_METHOD_PKG                                                */
  /* PURPOSE  : Package to handle all payment method related functionality        */
  /* FREQUENCY:                                                                   */
  /* PLATFORMS:                                                                   */
  /* REVISIONS:                                                                   */
  /*                                                                              */
  /* CR 16988: SOA 2011 project                                                   */
  /* VERSION DATE                WHO        PURPOSE                               */
  /* ------- -------- ---------- -------------------------------------------------*/
  /* 1.0     06/21/11 CR16988    vgeorge    Initial  Revision                     */
  /*                             Package body has been developed to support the   */
  /*                             payment method related features                  */
  /********************************************************************************/

  PROCEDURE retrieve_creditcard_list(
  p_esn        		   IN table_part_inst.part_serial_no%TYPE,
  p_filter_out_expired IN integer,
  p_result_set         OUT sys_refcursor,
  p_error_code		   OUT NUMBER,
  p_error_msg		   OUT VARCHAR2
  );

END PAYMENT_METHOD_PKG;
/