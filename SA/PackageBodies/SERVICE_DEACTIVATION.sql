CREATE OR REPLACE PACKAGE BODY sa."SERVICE_DEACTIVATION" AS
/********************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved
/*
/********************************************************************************/

--------------------------------------------------------------------------------------------
--$RCSfile: SERVICE_DEACTIVATION.sql,v $
--$Revision: 1.7 $
--$Author: oimana $
--$Date: 2018/04/11 15:29:50 $
--$ $Log: SERVICE_DEACTIVATION.sql,v $
--$ Revision 1.7  2018/04/11 15:29:50  oimana
--$ CR52412 - Package Body
--$
--------------------------------------------------------------------------------------------

   v_package_name VARCHAR2 (80) := '.SERVICE_DEACTIVATION()';

/********************************************************************************/
/*
/* NAME:         SERVICE_DEACTIVATION_PKG (BODY)
/* PURPOSE:      This package deactivate services attached to tracfone product
/* FREQUENCY:
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.
/*
/* REVISIONS:
/* VERSION  DATE        WHO     PURPOSE
/* -------  ---------- ----- ---------------------------------------------
/*  1.0                      Initial  Revision
/*  1.1    05/10/2002 Mleon  Added new carrier id on main cursor on deact-
/*                           ivate_past_due.(changed was med by JR).
/*                           Created a new procedure deactivate_any()
/*                           Changed write_to_monitor to created contact info
/*                           when there;s no info attahced to the esn that is
/*                           beeb deactivated
/*  1.1  08/09/02  GP        Added logic to Reserve numbers when
/*                           DEACT_HOLD is set to 1
/*  1.2  07/05/02  SL        Add X_SUB_SOURCESYSTEM field for call trans
/*                           insert statement
/*  1.3  08/16/02  SL        Promo Code Project
/*                           Remove TFU group
/*  1.3  03/06/02  TCS       Added a new procedure which will stop the ESN
/*                           from deactivation, if that ESN is subscribed for
/*                           deactivation protection program. It gets the
/*                           ESN details from autopay_details table
/*                           and insert it into x_send_ftp_auto table
/*  1.4   10/18/02   VA      Number Pooling Changes
/*  1.5   10/23/02   NS      Number Pooling Changes
/*  1.6   04/10/03   SL      Clarify Upgrade - sequence
/*  1.7   07/21/03   GP      Included CarrierID 101912 to(deactivate_past_due)
/*  1.8   08/15/03   MN      Modified deactivate_past_due to use table for
/*                                   carrier IDS to be excluded
/*  1.9   11/07/03   GP      Return line if flagged for number portability
/*  2.0   03/03/04   CWL     Changes for CR2564 (MT43886) in deactivate_any
/*  2.1   04/27/04   MH      CR2740 Changes for CR2740  Remove_Autopay_prc
/*  2.2   06/25/04   MN      Change past_due cursor clause pi2.x_port_in <> 1
/*                           to pi2.x_port_in <> 1 or pi2.x_port_in is null
/*  2.1   07/09/04   GP      Added new procedure(deactService) that deactivates
/*                           service from TOSS(WEBCSR). Logic comes from a
/*                           combination of both deactivateservice.java and
/*                           deactivateGSMService.java.
/*  1.5   08/31/2004 TCS     CR3200 Added new in parameter (ip_samemin)
/*                           in procedure(deactService) this variable will
/*                           be used to determine whether relate the line with
/*                           new ESN in case of Upgrade phone process
/*  2.3   09/07/2004 GP      CR3208 Old code was mistakenly put back in for
/*                           procedure(deactService), fixed it by using variable
/*                           "intNotifycarr"
/*  2.4   09/14/2004 GP      CR3209 Bypass carrier rules when reserving MIN to
/*                           new ESN for procedure(deactService)
/*  2.5   09/17/2004 RG      CR3153 Modifications for T-Mobile. In deactService
/*                           set status of temp line to Deleted.
/*  2.6   10/04/2004 GP      CR3153 Modified deactivate_past_due to call
/*                           deactService instead of deactivate_service.
/*                           (deactivate_service has been removed)
/*  2.7   10/12/2004 GP      CR2620 Modified deactService's main cursor (cur_ph)
/*                           added decode statement in x_part_inst_status field
/*                           in the where clause.
/*  2.8   10/25/2004 GP      CR3318 Changed the order of param (strDeactType)
/*                           from 3rd to 2nd param and added logic for
/*                           NTN (Non Tracfone Number) deactivations. Also
/*                           removed inticap function in order to conserve
/*                           resources
/*  2.9   11/02/2004 RG      CR3327 Return Internal Port In lines instead of
/*                           reserving it
/*  3.0   11/08/2004 GP      CR3353 Break Reserving GSM line in DeactService
/*                           procedure
/*  3.1   12/10/2004 GP      CR3190 Flag ESN to expire minutes for NET10 phones
/*                           if deact_reason = PastDue or Stolen in DeactService
/*                           procedure
/*  3.2   02/16/2005 GP      CR3667 Void SIM if deactivation is GSM and
/*                           deactivation code_type = 'DANEW'
/*  3.3   02/03/2005 RG      CR3327-1 Reset the x_port_in flag to 0 when internal
/*                           port in lines are returned
/*  3.4   03/07/2005 GP      CR3728 removed greatest function from where clause
/*                           in deactivate_past_due procedure
/*  3.5   03/24/2005 RG      CR3647 - Added new deact code MINCHANGE
/*                          This will not send an action item for deactivation
/*                          to the carrier - Will be used for T-Mobile Min change
/*  PVCS Revision No.
/*  1.27  04/11/2005 GP      CR3905 - Add ota_pending check in past_due proc.
/*        04/12/05   VS      CR3865 - Add few more deactivation reason code to
/*                           remove_autopay_prc to de-enroll from autopay
/*                           after the deactivation
/* 1.28   04/20/05   VS      Merged with existing code.
/* 1.29   04/20/05   VS      Modified to remove the reason "WAREHOUSE" (CR3865)
/* 1.32   04/27/05   GP      CR3971 - Set GSM line status to "Reserved Used" instead of
/*                           "Reserved" in (deactService) procedure
/* 1.33   05/20/2005 GP      CR3830 - Delete OTA Pending records in (deactService)
/* 1.34   06/03/2005 FL      CR4091 - Provide a mechanism or wrapper for Oracle package
/*                           to enable modifications to be done within the package without
/*                           affecting dependent modules.
/*                           This package specs replace the original which new name is
/*                           service_deactivation_code
/* 1.35   06/15/2005 FL      CR4091 - Change the position of the function CheckProcName to
/*                           allow the package to compile Ok.
/********************************************************************************/
--
--
/*****************************************************************************/
/*
/* Name: CheckProcName
/* Description: Returns the name of the procedure/package to be call.
/*****************************************************************************/
   FUNCTION CheckProcName (ip_ProcID IN NUMBER) RETURN VARCHAR2

   IS
   v_active    varchar2(100);
   v_procedure_name     varchar2(100) := v_package_name || '.CHECKPROCNAME()';

   BEGIN

     SELECT decode(package_active, 'A', package_A, package_B)
    into v_active
    From package_switch
   where package_id = ip_ProcID;

  RETURN trim(v_active);

   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         Toss_util_pkg.Insert_error_tab_proc (
            'Procedure Not found',
            ip_ProcID,
            v_procedure_name);
         RETURN '';
      WHEN OTHERS
      THEN
         Toss_util_pkg.Insert_error_tab_proc (
            'Not specified error',
            ip_ProcID,
            v_procedure_name);
         RETURN '';
   END CheckProcName;
--
--
/********************************************************************************/
/*
/* Name:     create_call_trans
/* Description : Available in the specification part of package
/********************************************************************************/
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
      op_CallTranObj   Out Number
   )
   IS
   v_sql varchar2(1000);
   BEGIN
     v_sql := 'Begin ' || CheckProcName(1) || '.create_call_trans(';
  for n in 1 .. 15 loop
   v_sql := v_sql || ':p' || n || ', ';
  End loop;
  v_sql := Substr(v_sql, 1, Length(v_sql) - 2) || '); End;';
     EXECUTE IMMEDIATE (v_sql) Using IN ip_site_part,
                   IN ip_action,
               IN ip_carrier,
          IN ip_dealer,
               IN ip_user,
               IN ip_min,
               IN ip_phone,
               IN ip_source,
               IN ip_transdate,
               IN ip_units,
               IN ip_action_text,
               IN ip_reason,
               IN ip_result,
               IN ip_iccid,
          OUT op_CallTranObj;

   END create_call_trans;
--
--
/***************************************************/
/* Name: write_to_monitor
/* Description : Writes into monitor table
/*
/****************************************************/
   PROCEDURE write_to_monitor (
      site_part_objid   IN   NUMBER,
      cust_site_objid   IN   NUMBER,
      x_carrier_id      IN   NUMBER,
      site_part_msid    IN   VARCHAR2
   )
   IS
   v_sql varchar2(1000);
   BEGIN
     v_sql := 'Begin ' || CheckProcName(1) || '.write_to_monitor(';
  for n in 1 .. 4 loop
   v_sql := v_sql || ':p' || n || ', ';
  End loop;
  v_sql := Substr(v_sql, 1, Length(v_sql) - 2) || '); End;';
     EXECUTE IMMEDIATE (v_sql) Using IN site_part_objid,
                   IN cust_site_objid,
               IN x_carrier_id,
               IN site_part_msid;
   END write_to_monitor;
--
--
/*******************************************************************************************/
/* Name:   sp_update_exp_date_prc
/* Description:  New Procedure added to extend the expire_dt - Modified by TCS offshore Team
/*
/*******************************************************************************************/
   PROCEDURE sp_update_exp_date_prc (
      p_esn          IN       VARCHAR2,
      p_grace_time   IN       DATE,
      op_result      OUT      NUMBER,
      op_msg         OUT      VARCHAR2
   )
   IS
   v_sql varchar2(1000);
   BEGIN
     v_sql := 'Begin ' || CheckProcName(1) || '.sp_update_exp_date_prc(';
  for n in 1 .. 4 loop
   v_sql := v_sql || ':p' || n || ', ';
  End loop;
  v_sql := Substr(v_sql, 1, Length(v_sql) - 2) || '); End;';
     EXECUTE IMMEDIATE (v_sql) Using IN p_esn,
                   IN p_grace_time,
               OUT op_result,
               OUT op_msg;
   END sp_update_exp_date_prc;
--
--
/**********************************************************************************************/
/*   Name:   check_dpp_registered_prc
/*   Description:   New Procedure added to check whether the ESN is subscribed for Deactivation
/*                  Protection Program - Modified by TCS offshore Team
/*
/**********************************************************************************************/
   PROCEDURE check_dpp_registered_prc (
      p_esn        IN       VARCHAR2,
      out_result   OUT      BOOLEAN
   )
   IS
   v_sql varchar2(1000);
   v_bol pls_integer;
   BEGIN
     v_sql := 'Begin ' || CheckProcName(1) || '.check_dpp_registered_prc(';
   for n in 1 .. 2 loop
    v_sql := v_sql || ':p' || n || ', ';
   End loop;
   v_sql := Substr(v_sql, 1, Length(v_sql) - 2) || '); End;';
     EXECUTE IMMEDIATE (v_sql) Using IN p_esn,
               OUT v_bol;
   If v_bol = 1 then
     out_result := True;
   Else
     out_result := False;
   End if;
   END check_dpp_registered_prc;
--
--
/*****************************************************************************/
/*   Name:    get_amount_fun
/*   Description: New Procedure added to get the monthly fee for  Deactivation
/*                Protection Program - Modified by TCS
/*
/******************************************************************************/
   FUNCTION get_amount_fun (p_prg_type NUMBER)
      RETURN NUMBER
   IS
   v_sql   varchar2(1000);
   v_return  NUMBER;
   BEGIN
     v_sql := 'Begin :r1 :=' || CheckProcName(1) || '.get_amount_fun(';
   for n in 1 .. 1 loop
    v_sql := v_sql || ':p' || n || ', ';
   End loop;
   v_sql := Substr(v_sql, 1, Length(v_sql) - 2) || '); End;';
     EXECUTE IMMEDIATE (v_sql) Using OUT v_return,
               IN p_prg_type;
   Return v_return;
   END get_amount_fun;
--
--
/**********************************************************************************************/
/*  Name:        remove_autopay_prc
/*  Description : New Procedure added to remove the ESN from Autopay promotions and
/*                unsubscribe from Autopay program - Modified by TCS offshore Team
/*******************************************************************************************/
   PROCEDURE remove_autopay_prc (p_esn IN VARCHAR2, out_success OUT NUMBER) IS
   v_sql varchar2(1000);
   BEGIN
     v_sql := 'Begin ' || CheckProcName(1) || '.remove_autopay_prc(';
   for n in 1 .. 2 loop
   v_sql := v_sql || ':p' || n || ', ';
   End loop;
   v_sql := Substr(v_sql, 1, Length(v_sql) - 2) || '); End;';
     EXECUTE IMMEDIATE (v_sql) Using IN p_esn,
               OUT out_success;
   END remove_autopay_prc;
--
--
/*****************************************************************************/
/*                                                                           */
/* Name:     deactivate_past_due                                             */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   PROCEDURE deactivate_past_due
   IS
   v_sql varchar2(1000);
   BEGIN
     v_sql := 'Begin ' || CheckProcName(1) || '.deactivate_past_due; End;';
     EXECUTE IMMEDIATE (v_sql);
   END deactivate_past_due;
--
--
/*****************************************************************************/
/*                                                                           */
/* Name:     deactivate_airtouch                                             */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   PROCEDURE deactivate_airtouch
   IS
   v_sql varchar2(1000);
   BEGIN
     v_sql := 'Begin ' || CheckProcName(1) || '.deactivate_airtouch; End;';
     EXECUTE IMMEDIATE (v_sql);
   END deactivate_airtouch;
--
--
/*****************************************************************************/
/*                                                                           */
/* Name:     deact_road_past_due                                             */
/* Description : Available in the specification part of package              */
/*               VAdapa on 02/13/02 to deactivate expired ROADSIDE cards     */
/*****************************************************************************/
   PROCEDURE deact_road_past_due
   IS
   v_sql varchar2(1000);
   BEGIN
     v_sql := 'Begin ' || CheckProcName(1) || '.deact_road_past_due; End;';
     EXECUTE IMMEDIATE (v_sql);
   END deact_road_past_due;
--
--
/*****************************************************************************/
/*                                                                           */
/* Name:     deactivate_any                                                  */
/* Description : Available in the specification part of package              */
/*****************************************************************************/
   PROCEDURE deactivate_any (
      ip_esn              IN       VARCHAR2,
      ip_reason           IN       VARCHAR2,
      ip_caller_program   IN       VARCHAR2,
      ip_result           IN OUT   BOOLEAN
   )
   AS
   v_sql varchar2(1000);
   v_bol pls_integer;
   BEGIN
     v_sql := 'Begin ' || CheckProcName(1) || '.deactivate_any(';
   for n in 1 .. 4 loop
    v_sql := v_sql || ':p' || n || ', ';
   End loop;
   v_sql := Substr(v_sql, 1, Length(v_sql) - 2) || '); End;';
   If ip_result then
     v_bol := 1;
   Else
     v_bol := 0;
   End if;
     EXECUTE IMMEDIATE (v_sql) Using IN ip_esn,
              IN ip_reason,
          IN ip_caller_program,
               IN OUT v_bol;
   If v_bol = 1 then
     ip_result := True;
   Else
     ip_result := False;
   End if;
   END deactivate_any;
--
--
/******************************************************************************/
/*                                                                            */
/* Name:       deactService                                                   */
/* Objective:  This procedure deactivate esns for different reasons specified */
/*             by the ip_reason.                                              */
/*                                                                            */
/* Assumption: ip_reason should have an entry in the table_x_code_table       */
/*             CR52412-Added ip_brm_enrolled_flag to insert ILD trans records */
/******************************************************************************/
   PROCEDURE deactservice (ip_sourcesystem      IN    VARCHAR2,
                           ip_userobjid         IN    VARCHAR2,
                           ip_esn               IN    VARCHAR2,
                           ip_min               IN    VARCHAR2,
                           ip_deactreason       IN    VARCHAR2,
                           intbypassordertype   IN    NUMBER,
                           ip_newesn            IN    VARCHAR2,
                           ip_samemin           IN    VARCHAR2,
                           op_return            OUT   VARCHAR2,
                           op_returnmsg         OUT   VARCHAR2,
                           ip_brm_enrolled_flag IN    VARCHAR2 DEFAULT 'N')
   IS

   v_sql VARCHAR2(2400);

   BEGIN

     v_sql := 'Begin ' || CheckProcName(1) || '.deactService(';

     FOR n IN 1 .. 11 LOOP
       v_sql := v_sql || ':p' || n || ', ';
     END LOOP;

     v_sql := SUBSTR(v_sql, 1, LENGTH(v_sql) - 2) || '); End;';

     EXECUTE IMMEDIATE (v_sql) USING IN  ip_sourcesystem,
                                     IN  ip_userObjId,
                                     IN  ip_esn,
                                     IN  ip_min,
                                     IN  ip_DeactReason,
                                     IN  intByPassOrderType,
                                     IN  ip_newESN,
                                     IN  ip_samemin,
                                     OUT op_return,
                                     OUT op_returnMsg,
                                     IN  ip_brm_enrolled_flag;

   END deactservice;
--
--
/*****************************************************************************/
/*
/* Name: WritePiHistory
/* Description: Inserts new records into table_x_pi_hist
/*****************************************************************************/
   FUNCTION WritePIHistory (
      ip_userObjid        IN   VARCHAR2,
      ip_part_serial_no   IN   VARCHAR2,
      ip_oldNPA           IN   VARCHAR2,
      ip_oldNXX           IN   VARCHAR2,
      ip_oldEXT           IN   VARCHAR2,
      ip_action           IN   VARCHAR2,
      ip_iccid            IN   VARCHAR2
   )
   RETURN BOOLEAN
   IS
   v_sql   varchar2(1000);
   v_return  PLS_INTEGER;
   BEGIN
     v_sql := 'Begin :r1 :=' || CheckProcName(1) || '.WritePIHistory(';
   for n in 1 .. 7 loop
   v_sql := v_sql || ':p' || n || ', ';
   End loop;
   v_sql := Substr(v_sql, 1, Length(v_sql) - 2) || '); End;';
     EXECUTE IMMEDIATE (v_sql) Using OUT v_return,
               IN ip_userObjid,
          IN ip_part_serial_no,
          IN ip_oldNPA,
          IN ip_oldNXX,
          IN ip_oldEXT,
          IN ip_action,
          IN ip_iccid;
   If v_return = 1 then
     Return True;
   Else
     Return False;
   End If;
   END WritePIHistory;
--
--
END SERVICE_DEACTIVATION;
/