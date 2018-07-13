CREATE OR REPLACE PACKAGE sa."SERVICE_DEACT_CATCHUP"
AS
/******************************************************************************/
   /*    Copyright ) 2010 Tracfone  Wireless Inc. All rights reserved            */
   /*                                                                            */
   /* NAME:         ST_SERVICE_DEACT_CATCHUP (SPECIFICATION)                     */
   /* PURPOSE:      This package deactivate services attached to tracfone product*/
   /* FREQUENCY:                                                                 */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
   /*                                                                            */
   /* REVISIONS:                                                                 */
   /* VERSION  DATE        WHO          PURPOSE                                  */
   /* -------  ---------- -----  ---------------------------------------------   */
   /*  1.2                     Initial  Revision (clone of service_deactivation_code with a modified pastdue procedure logic)
   /******************************************************************************/
   PROCEDURE DEACTIVATE_PAST_DUE(p_bus_org_id in varchar2);
   PROCEDURE deactService(
      ip_sourcesystem IN VARCHAR2,
      ip_userObjId IN VARCHAR2,
      ip_esn IN VARCHAR2,
      ip_min IN VARCHAR2,
      ip_DeactReason IN VARCHAR2,
      intByPassOrderType IN NUMBER,
      ip_newESN IN VARCHAR2,
      ip_samemin IN VARCHAR2,
      op_return OUT VARCHAR2,
      op_returnMsg OUT VARCHAR2
   );
END SERVICE_DEACT_CATCHUP;
/