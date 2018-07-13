CREATE OR REPLACE PACKAGE sa.REWARDS_BATCH_PKG
IS
 --$RCSfile: REWARDS_BATCH_PKG.sql,v $
 --$Revision: 1.6 $
 --$Author: sethiraj $
 --$Date: 2016/09/16 12:49:27 $
 --$ $Log: REWARDS_BATCH_PKG.sql,v $
 --$ Revision 1.6  2016/09/16 12:49:27  sethiraj
 --$ CR41473-LRP2-Added Modification History Template
 --$
 --$ Revision 1.5  2016/09/01 13:41:21  pamistry
 --$ CR41473 - LRP2 added run date as input parameter in new procedure created with phase 2 for completing pending transaction
 --$


  FUNCTION f_expire_benefit(
      in_webaccount_id IN VARCHAR2)
    RETURN VARCHAR2; --Modified for 2269
  PROCEDURE P_EXPIRE_BENEFIT(
      i_rundate IN DATE,
      o_err_code OUT NUMBER,
      o_err_msg OUT VARCHAR2);
  PROCEDURE P_ACCT_ANNIVERSARY(
      i_rundate IN DATE,
      o_err_code OUT NUMBER,
      o_err_msg OUT VARCHAR2);
  PROCEDURE P_REWARD_BONUS_POINTS(
      i_rundate IN DATE,
      o_err_code OUT VARCHAR2,
      o_err_msg OUT VARCHAR2);
  -- CR41473 - LRP2 - sethiraj
  PROCEDURE P_COMPLETE_TRANSACTION(
      i_rundate IN DATE,
      o_err_code OUT VARCHAR2,
      o_err_msg OUT VARCHAR2);
END REWARDS_BATCH_PKG;
/