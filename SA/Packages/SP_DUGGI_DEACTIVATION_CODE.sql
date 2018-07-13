CREATE OR REPLACE PACKAGE sa."SP_DUGGI_DEACTIVATION_CODE"
AS
/******************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         SERVICE_DEACTIVATION_PKG (SPECIFICATION)                     */
/* PURPOSE:      This package deactivate services attached to tracfone product*/
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/*                                                                            */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO          PURPOSE                                  */
/* -------  ---------- -----  ---------------------------------------------   */
/*  1.0                       Initial  Revision                               */
/*                                                                            */
/*  1.1    05/10/2002 Mleon   Added new carruier id on main cursor on deact-  */
/*                            ivate_past_due.(changed was med by JR).         */
/*                            Created a new procedure deactivate_any()        */
/*                            Changed write_to_monitor to created contact info*/
/*                            when there;s no info attahced to the esn that is*/
/*                            beeb deactivated                                */
/*  1.2    06/29/2002 Mleon   Removed carrier ids 101290,101912 and 110024    */
/*                            from deactivate_any() procedure.                */
/*  1.3  03/06/2002 TCS       Added a new procedure which will stop the ESN   */
/*                            from deactivation if that ESN is subscribed for */
/*                            deactivation protection program. It gets the    */
/*                            ESn details from autopay_details table          */
/*                            and insert it into x_send_ftp_auto table        */
/*  1.4   07/09/2004   GP     Added new procedure(deactService) that deactivates */
/*                            service from TOSS(WEBCSR). Logic comes from a   */
/*                            combination of both deactivateservice.java and  */
/*                            deactivateGSMService.java.                      */
/*  1.5   08/31/2004   TCS    CR3200 Added new in parameter (ip_samemin)      */
/*                            in procedure(deactService) this variable will   */
/*                            be used to determine whether relate the line    */
/*                            with new ESN in case of Upgrade phone process   */
/*  1.6   09/17/2004 RG      CR3153 Modifications for T-Mobile. In deactService */
/*                           set status of temp line to Deleted.                */
/*  1.7   10/04/2004 GP      CR3153 Modified deactivate_past_due to call        */
/*                           deactService instead of deactivate_service.        */
/*                           (deactivate_service has been removed)              */
/*  1.8   06/06/2005 FL      CR4091 - Provide a mechanism or wrapper for Oracle */
/*                           package to enable modifications to be done within  */
/*                           the package without affecting dependent modules.   */
/********************************************************************************/
/* NEW PLSQL STRUCTURE NEW_PLSQL
/* 1.0     09/02/09  NG      BRAND_SEP Separate the Brand and Source System     */
/*                           incorporate use of new table TABLE_BUS_ORG         */
/*                           to retrieve brand information that was previously  */
/*                           identified by the fields x_restricted_use,         */
/*                           and/or amigo from table_part_num, x_subsourcesystem*/
/*                           modified insert to call_trans                      */
/*  1.4  03/16/2011 CL  CR15146 CR15144 CR15317         */
/*  1.5  09/27/2011 CL  CR18207 Fix ST deact job to work faster in the deact_past_due_proc   */
/******************************************************************************/
/******************************************************************************/
/*                                                                            */
/* Name:    create_call_trans                                                 */
/* Objective  :                                                               */
/*                                                                            */
/* In Parameters :                                                            */
/* Out Parameters :                                                           */
/*                                                                            */
/*                                                                            */
/* Assumption:                                                                */
/******************************************************************************/
     PROCEDURE create_call_trans (
      ip_site_part     IN   NUMBER,
      ip_action        IN   NUMBER,
      ip_carrier       IN   NUMBER,
      ip_dealer        IN   NUMBER,
      ip_user          IN   NUMBER,
      ip_min           IN   VARCHAR2,
      ip_phone         IN   VARCHAR2,
      ip_source        IN   VARCHAR2,
      ip_transdate     IN   DATE,
      ip_units         IN   NUMBER,
      ip_action_text   IN   VARCHAR2,
      ip_reason        IN   VARCHAR2,
      ip_result        IN   VARCHAR2,
      ip_iccid         IN   VARCHAR2,
      ip_brand_name    IN   VARCHAR2,
      op_CallTranObj   Out Number);

/******************************************************************************/
/*                                                                            */
/* Name:    deactivate_past_due                                               */
/* Objective  :                                                               */
/*                                                                            */
/* In Parameters :                                                            */
/* Out Parameters :                                                           */
/*                                                                            */
/*                                                                            */
/* Assumption:                                                                */
/******************************************************************************/
    PROCEDURE DEACTIVATE_PAST_DUE(p_bus_org_id    in varchar2,
                                  p_mod_divisor   in number default 1,
                                  p_mod_remainder in number default 0);
/******************************************************************************/
/*                                                                            */
/* Name:    deactivate_airtouch                                               */
/* Objective  :                                                               */
/*                                                                            */
/* In Parameters :                                                            */
/* Out Parameters :                                                           */
/*                                                                            */
/*                                                                            */
/* Assumption:                                                                */
/******************************************************************************/
     PROCEDURE deactivate_airtouch;
/******************************************************************************/
/*                                                                            */
/* Name:    deact_road_past_due                                               */
/* Objective  :                                                               */
/*                                                                            */
/* In Parameters :                                                            */
/* Out Parameters :                                                           */
/*                                                                            */
/*                                                                            */
/* Assumption:                                                                */
/******************************************************************************/
     PROCEDURE deact_road_past_due;
/******************************************************************************/
/*                                                                            */
/* Name:    deactivate_any                                                    */
/* Objective  :  This procedure deactivate esn for different reasons specified*/
/*             by the ip_reason.                                              */
/*                                                                            */
/* In Parameters :   ip_esn   given esn                                       */
/*                   ip_reason deactivation reason (REFURBISHED< UNREPAIRABLE)*/
/*                   ip_caller_program  name of program calling this proc     */
/*                                      for logging purposes                  */
/* Out Parameters :  TRUE  sucess                                             */
/*                   FALSE  failed                                            */
/*                                                                            */
/* Assumption:    ip_reason should have an entry in the table_x_code_table    */
/******************************************************************************/
     PROCEDURE deactivate_any(
     ip_esn IN VARCHAR2,
     ip_reason IN VARCHAR2,
     ip_caller_program IN VARCHAR2,
     ip_result IN OUT PLS_INTEGER);
/******************************************************************************/
/*                                                                            */
/* Name:    CHECK_DPP_REGISTERED_PRC                                          */
/* Objective  :This procedure checks whether the given ESN is registered for  */
/*             Deactivation protection Program,if yes then the customer is    */
/*             given 10 days grace period by updating the x_expire_dt by      */
/*             additional 10 days and inserting the ESN and the mothly fee    */
/*             detail in to send_ftp_auto table.                              */
/*                                                                            */
/* In Parameters :  p_esn given ESN                                              */
/*                                                                            */
/*                                                                            */
/*                                                                            */
/* Out Parameters : out_result                                                */
/*                  TRUE  REGISTERED  for deactivation protection program     */
/*                  FALSE  NOT REGISTERED for deactivation protection program */
/* Assumption:                                                                */
/******************************************************************************/
 PROCEDURE CHECK_DPP_REGISTERED_PRC ( p_esn IN VARCHAR2,
                  out_result OUT PLS_INTEGER);
 /******************************************
 * Function get_amount_fun
 * IN: p_prg_type Given Program Type NUMBER
 * RETURN: number  -- monthly fee
 *******************************************/
 FUNCTION get_amount_fun (
  p_prg_type IN NUMBER ) RETURN NUMBER;
 /*****************************************************************************/
 /*                                                                           */
 /* Name:    remove_autopay_prc                                               */
 /* Objective :The ESN will be unsubscribed from autopay_details ,if the esn  */
 /*            is registered for the deactivation Protection program or       */
 /*            autopay or Hybrid PrePost Paid program                         */
 /*                                                                           */
 /*                                                                           */
 /* In Parameters :  p_esn , given esn                                          */
 /*                                                                           */
 /*                                                                           */
 /*                                                                           */
 /* Out Parameters :   out_success   1 - OK                                     */
 /*                                                                           */
 /*                                                                           */
 /* Assumption:                                                               */
 /*****************************************************************************/
 PROCEDURE remove_autopay_prc(
     p_esn         IN VARCHAR2,
     p_brand_name  IN VARCHAR2,
     out_success OUT NUMBER );
 /*****************************************************************************/
 /*                                                                           */
 /* Name:    sp_update_exp_date-prc                                           */
 /* Objective :The ESN will be updated with the given expire_dt               */
 /*                                                                           */
 /*                                                                           */
 /*                                                                           */
 /* In Parameters :  p_esn , given esn                                          */
 /*                p_grace_time, the date will be updated as the new          */
 /*                sp_update_exp_date                                         */
 /* Out Parameters :   op_result '0' for OK and '1' Error                     */
 /*                    op_msg Error Details                                   */
 /*                                                                           */
 /* Assumption:                                                               */
 /*****************************************************************************/
 PROCEDURE sp_update_exp_date_prc(
     p_esn        IN        VARCHAR2,
     p_grace_time    IN    DATE,
     op_Result       OUT     NUMBER,   --0=Ok,1=Error
    op_msg          OUT     VARCHAR2 );

/******************************************************************************/
/*                                                                            */
/* Name:    deactService                                                      */
/* Objective:  This procedure deactivate esns for different reasons specified */
/*             by the ip_reason.                                              */
/*                                                                            */
/* Assumption:    ip_reason should have an entry in the table_x_code_table    */
/******************************************************************************/

 PROCEDURE deactService (
            ip_sourcesystem in varchar2,
            ip_userObjId    in varchar2,
            ip_esn          in varchar2,
            ip_min          in varchar2,
            ip_DeactReason  in varchar2,
            intByPassOrderType in number,
            ip_newESN       in varchar2,
            ip_samemin      in varchar2, --CR3200
            op_return      out varchar2,
            op_returnMsg   out varchar2
   );

 FUNCTION WritePIHistory(
      ip_userObjid        IN   VARCHAR2,
      ip_part_serial_no   IN   VARCHAR2,
      ip_oldNPA           IN   VARCHAR2,
      ip_oldNXX           IN   VARCHAR2,
      ip_oldEXT           IN   VARCHAR2,
      ip_action           IN   VARCHAR2,
      ip_iccid            IN   VARCHAR2
   ) RETURN PLS_INTEGER;
--cwl 2/7/2011 new proc to do sendcarrdeact
   PROCEDURE sendcarrdeact;

END SP_DUGGI_DEACTIVATION_CODE;
/