CREATE OR REPLACE PACKAGE sa."DUMMY_LINE_INSERT_PKG" AS
/********************************************************************************/
/* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved                */
/*                                                                              */
/* Name         :   dummy_line_insert_pkg                                       */
/* Purpose      :   Insert a dummy line for no inventory carriers               */
/* Parameters   :                                                               */
/* Platforms    :   Oracle 8.0.6 AND newer versions                             */
/* Author       :   Natalio Guada                                               */
/* Date         :   07/27/2004                                                  */
/* Revisions    :                                                               */
/*                                                                              */
/* Version  Date        Who             Purpose                                 */
/* -------  --------    -------         --------------------------------------  */
/*  1.0	    07/27/2004  Natalio		New package created to insert dummy lines*/
/********************************************************************************/
   /* NEW PVCS STRUCTURE /NEW_PLSQL/CODE
   /* 1.0   09/05/08        VAdapa    Prod Version as of 09/05/08
   /* 1.1   09/05/08        VAdapa    CDMA NA
/********************************************************************************/
  PROCEDURE DUMMY_LINE  (ip_account       IN     VARCHAR2,
                         ip_carrier_id    IN     NUMBER,
                         ip_user          IN     VARCHAR2,
                         ip_esn           IN     VARCHAR2,
                         ip_zip           in     varchar2, --CDMA_NAVAIL
                         op_min          OUT     VARCHAR2,
                         op_result       OUT     NUMBER,
                         op_msg          OUT     VARCHAR2);


  FUNCTION INSERT_LINE_REC   (ip_objid         IN VARCHAR2,
                              ip_min          IN VARCHAR2,
                              ip_npa          IN VARCHAR2,
                              ip_nxx          IN VARCHAR2,
                              ip_ext          IN VARCHAR2,
                              ip_file_name    IN VARCHAR2,
                              ip_expire_date  IN DATE,
                              ip_cooling_end_date IN DATE,
                              ip_code_number  IN VARCHAR2,
                              ip_mod_objid    IN NUMBER,
                              ip_pers_objid   IN NUMBER,
                              ip_carrier_objid IN NUMBER,
                              ip_code_objid   IN NUMBER,
                              ip_user_objid   IN NUMBER,
                              ip_esn_objid    IN NUMBER) RETURN BOOLEAN;

  FUNCTION INSERT_ACCOUNT_HIST (ip_line_objid    IN NUMBER,
                                ip_account_objid IN NUMBER) RETURN BOOLEAN;


  FUNCTION WRITE_TO_PI_HIST    (ip_line_objid IN NUMBER,
                                ip_reason     IN VARCHAR2) RETURN BOOLEAN;


END DUMMY_LINE_INSERT_PKG;
/