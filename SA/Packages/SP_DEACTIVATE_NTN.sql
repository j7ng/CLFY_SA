CREATE OR REPLACE PACKAGE sa."SP_DEACTIVATE_NTN" AS
/*******************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved             */
/*                                                                             */
/* NAME:         SP_DEACTIVATE_NTN (SPECIFICATION)                             */
/* PURPOSE:                                                                    */
/* FREQUENCY:                                                                  */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                              */
/*                                                                             */
/* REVISIONS:                                                                  */
/* VERSION  DATE        WHO          PURPOSE                                   */
/* -------  ---------- -----  ---------------------------------------------    */
/*  1.0                       Initial  Revision                                */
/*                                                                             */
/*  1.2     07/05/2002  SL    Add X_SUB_SOURCESYSTEM field for call trans      */
/*                            insert statement                                 */
/*  1.3     04/10/2003  SL    Clarify Upgrade - sequence                       */
/*  1.4     10/28/2004  GP    CR3318 Removed old deactivate_service logic to   */
/*                            use new sa.service_deactivation.DeactService pkg */
/*******************************************************************************/
PROCEDURE deactivate_ntn     (str_esn   IN VARCHAR2,
                              str_out   OUT VARCHAR2);
END Sp_deactivate_ntn;
/