CREATE OR REPLACE PACKAGE sa."IGATE_INDV"
AS
/*******************************************************************************
    Name         :  SA.IGATE_INDV
    Purpose      :  To return the carrier and its features based on an esn
                    or task id or case id
    Author       :  Gerald Pintado / Vanisri Adapa
    Date         :  ???
    Revisions    :
    Version     Date      Who       Purpose
    -------   --------  -------     --------------------------
    1.0         ???     GPintado    Initial revision
                        VAdapa
    1.1       06/28/04  VAdapa      CR3016 - Modify to get the features from
                                    TABLE_X_CARRIER_FEATURES instead from
                                    TABLE_X_CARRIER
    1.2       07/07/04  VAdapa      CR2739 - Remove p_curr_method input parameter
                                    Exclude task from SP_CHECK_BLACKOUT
    1.3       08/26/04  RGandhi     CR3153 - Add procedure sp_esn_min_status
    1.4       11/04/04 Gpintado     CR3327 Added procedure sp_igate_update for
                                    single User Interface, logic is identical to
                                    the igate_in3 package except with input params
    1.5       11/23/04 Gpintado     CR3327 Removed prcoedure sp_igate_update due to
                                    table locking.

   /*********************************************************************************/
   PROCEDURE sp_ig_info(
      p_task_id IN VARCHAR2,
      p_esn IN VARCHAR2,
      p_case_id IN VARCHAR2,
      p_min IN VARCHAR2, --CR2739D
      p_message OUT VARCHAR2,
      rc IN OUT sa.igateindvpkg.igateinfocursor
   );
   PROCEDURE sp_ordertype_info(
      p_min IN VARCHAR2,
      p_order_type IN VARCHAR2,
      p_carrier_objid IN NUMBER,
      --      p_curr_method     IN       VARCHAR2, CR2739C
      p_technology IN VARCHAR2,
      p_message OUT VARCHAR2,
      rc IN OUT sa.igateindvpkg.igateordercursor
   );
   FUNCTION sp_check_blackout(
--      p_task_id IN VARCHAR2,
      p_min IN VARCHAR2,
      p_order_type IN VARCHAR2,
      p_carrier_objid IN NUMBER
   )
   RETURN NUMBER;
   FUNCTION sp_ret_order_type(
      p_min IN VARCHAR2,
      p_carrier_objid IN NUMBER
   )
   RETURN VARCHAR2;
   PROCEDURE sp_flag_new_msid(
      p_min IN VARCHAR2,
      p_task_id IN VARCHAR2,
      p_msid IN VARCHAR2,
      p_message OUT VARCHAR2
   );
    PROCEDURE sp_esn_min_status(
      p_esn IN VARCHAR2,
      p_esn_status OUT VARCHAR2,
      p_min_status OUT VARCHAR2,
      p_min OUT VARCHAR2,
      p_message OUT VARCHAR2
   );

END igate_indv;
/