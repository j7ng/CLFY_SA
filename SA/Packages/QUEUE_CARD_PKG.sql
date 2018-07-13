CREATE OR REPLACE PACKAGE sa."QUEUE_CARD_PKG"
IS
  PROCEDURE sp_get_queue_by_esn(
      p_esn IN VARCHAR2 ,
      p_queue_detail_by_esn OUT SYS_REFCURSOR ,
      p_err_num OUT NUMBER ,
      p_err_string OUT VARCHAR2 );
  FUNCTION FN_GET_SCRIPT_TEXT_BY_SP_DESC(
      IP_SERVICEPLAN_OBJID  IN sa.X_SERVICE_PLAN.OBJID%TYPE
      , IP_FEATURE          IN sa.X_SERVICEPLANFEATUREVALUE_DEF.VALUE_NAME%TYPE
      , IP_ORG_ID           IN sa.TABLE_BUS_ORG.ORG_ID%TYPE
      )
  RETURN VARCHAR2;

  PROCEDURE sp_my_acct_get_queue_by_esn(
      p_esn IN VARCHAR2 ,
      p_queue_detail_by_esn OUT SYS_REFCURSOR ,
      p_err_num OUT NUMBER ,
      p_err_string OUT VARCHAR2 );
  PROCEDURE sp_get_queue_all_esn(
      p_queue_detail_all_esn OUT SYS_REFCURSOR ,
      p_err_num OUT NUMBER ,
      p_err_string OUT VARCHAR2 );
  PROCEDURE sp_redeem_card(
      p_esn           IN VARCHAR2 ,
      p_red_card      IN VARCHAR2 ,
      p_source_system IN VARCHAR2 , -- WAP Redemption 12/29/2010
      p_call_trans_objid OUT NUMBER ,
      p_err_num OUT NUMBER ,
      p_err_string OUT VARCHAR2 );

      --CR#38582 - Added overloaded procedure to accept the call trans objid
    PROCEDURE sp_redeem_card(
      p_esn           IN VARCHAR2 ,
      p_red_card      IN VARCHAR2 ,
      p_source_system IN VARCHAR2 , -- WAP Redemption 12/29/2010
      p_i_call_trans_objid IN NUMBER ,
      p_call_trans_objid OUT NUMBER ,
      p_err_num OUT NUMBER ,
      p_err_string OUT VARCHAR2 );

  PROCEDURE sp_add_queue(
      p_esn           IN VARCHAR2 ,
      p_red_card      IN VARCHAR2 ,
      p_source_system IN VARCHAR2 -- WAP Redemption 12/29/2010
      ,
      p_create_call_trans IN VARCHAR2 DEFAULT 'Y' -- CR15847 ST Stacking
      ,
      p_call_trans_objid IN OUT NUMBER -- CR15847 ST Stacking
      ,
      p_err_num OUT NUMBER ,
      p_err_string OUT VARCHAR2 );
  PROCEDURE sp_update_queue_priority(
      p_esn      IN VARCHAR2 ,
      p_red_card IN VARCHAR2 ,
      p_err_num OUT NUMBER ,
      p_err_string OUT VARCHAR2 );
  PROCEDURE sp_trnsfr_queue_to_active_esn(
      p_err_num OUT NUMBER ,
      p_err_string OUT VARCHAR2 );
  FUNCTION sf_move_queue_oldesn_to_newesn(
      ip_old_esn IN VARCHAR2,
      ip_new_esn IN VARCHAR2,
      p_err_num OUT NUMBER,     -- CR13249
      p_err_string OUT VARCHAR2 -- CR13249
    )
    RETURN NUMBER;
  --------------------for CR22623-----------by Chaitanya
TYPE typ_q_esn_pin_rec
IS
  RECORD
  (
    esn               VARCHAR2 (30),
    pin               VARCHAR2 (30),
    create_call_trans VARCHAR2(1) DEFAULT 'Y',
    call_trans_objid  NUMBER);
TYPE typ_q_esn_pin_tbl
IS
  TABLE OF typ_q_esn_pin_rec INDEX BY BINARY_INTEGER;
TYPE out_rec
IS
  RECORD
  (
    call_trans_objid NUMBER,
    ERR_NUM          NUMBER,
    err_string       VARCHAR2 (300));
TYPE out_tbl
IS
  TABLE OF out_rec INDEX BY BINARY_INTEGER;
  PROCEDURE queuepintoesn(
      p_esn_list      IN typ_q_esn_pin_tbl,
      p_source_system IN VARCHAR2,
      out_message OUT out_tbl);
END queue_card_pkg;
/