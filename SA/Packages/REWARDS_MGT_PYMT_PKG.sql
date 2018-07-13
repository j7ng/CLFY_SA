CREATE OR REPLACE PACKAGE sa.rewards_mgt_pymt_pkg AS

 --$RCSfile: REWARDS_MGT_PYMT_PKG.SQL,v $
 --$Revision: 1.10 $
 --$Author: sethiraj $
 --$Date: 2016/09/16 12:49:27 $
 --$ $Log: REWARDS_MGT_PYMT_PKG.SQL,v $
 --$ Revision 1.10  2016/09/16 12:49:27  sethiraj
 --$ CR41473-LRP2-Added Modification History Template
 --$
 --$ Revision 1.9  2016/08/09 11:40:21  sethiraj
 --$ CR41473 - CR41473-LRP2-Code changes done as per the internal review comments.
 --$


--------------------------------------------------------------------------------------------
-- Author: Usha S
-- Date: 2015/10/05
-- <CR# 33098> Benefit Payment
--
-- Revision 1.1  yyyy/mm/dd hh:mm:ss  <tf userid>
-- <CR# Description>
--
--------------------------------------------------------------------------------------------
--function to get next benefit transaction sequence value
FUNCTION f_get_transaction_id
  RETURN NUMBER;

--proc to fetch action and transaction description for the even type and transaction type passed
PROCEDURE p_get_benefit_trans_desc
(i_trans_type   IN  x_reward_benefit_transaction.trans_type%TYPE,
 i_event_type   IN  VARCHAR2,
 o_action       out VARCHAR2,
 o_action_type  out VARCHAR2,
 o_trans_desc   out VARCHAR2
);

--proc to insert record into x_reward_benefit_transaction table
PROCEDURE p_create_benefit_trans(
      i_event_type    VARCHAR2,
      i_transaction_id x_reward_benefit_transaction.objid%TYPE,
      i_trans_date    x_reward_benefit_transaction.trans_date%TYPE,
      i_WEB_account_id    x_reward_benefit_transaction.WEB_account_id%TYPE,
      i_subscriber_id x_reward_benefit_transaction.subscriber_id%TYPE,
      i_min           x_reward_benefit_transaction.MIN%TYPE,
      i_esn           x_reward_benefit_transaction.esn%TYPE,
      i_old_min       x_reward_benefit_transaction.old_min%TYPE,
      i_old_esn       x_reward_benefit_transaction.old_esn%TYPE,
      i_trans_type    x_reward_benefit_transaction.trans_type%TYPE,
      i_trans_desc    x_reward_benefit_transaction.trans_desc%TYPE DEFAULT NULL,
      i_amount        x_reward_benefit_transaction.amount%TYPE,
      i_benefit_type_CODE  x_reward_benefit_transaction.benefit_type_CODE%TYPE,
      i_action        x_reward_benefit_transaction.action%TYPE DEFAULT NULL,
      i_action_type   x_reward_benefit_transaction.action_type%TYPE DEFAULT NULL,
      i_action_reason x_reward_benefit_transaction.action_reason%TYPE,
      i_btrans2btrans x_reward_benefit_transaction.benefit_trans2benefit_trans%TYPE,
      i_svc_plan_pin  x_reward_benefit_transaction.svc_plan_pin%TYPE,
      i_svc_plan_id   x_reward_benefit_transaction.svc_plan_id%TYPE,
      i_brand         x_reward_benefit_transaction.brand%TYPE,
      i_btrans2benefit x_reward_benefit_transaction.benefit_trans2benefit%TYPE,
      o_transaction_status   out x_reward_benefit_transaction.transaction_status%type );        -- CR41473 PMistry 08/04/2016 LRP2 Added new output parameter.


/* utility procedure for creating benefit transactions from a benefit transaction object */
PROCEDURE p_create_benefit_trans (
  i_event_type            IN  VARCHAR2,
	i_ben_trans					    IN  typ_lrp_benefit_trans,
  o_transaction_status    OUT x_reward_benefit_transaction.transaction_status%type         -- CR41473 PMistry 08/04/2016 LRP2 Added new output parameter.
  );


/* procedure for authorizing and settling purchases made with benefits */
PROCEDURE p_authorize_benefit_payment (
	in_order_source				IN VARCHAR2,	--source system ID, this will just be stored for ref
	in_order_id					  IN VARCHAR2,	--source system order ID, stored for ref
	in_trans_date				  IN DATE,	--transaction date
	in_trans_desc				  IN VARCHAR2,	--transaction descr, stored for ref (opt)
	in_brand					    IN VARCHAR2,	--one of: NT, SM, ST, TC, SL, TW, TF
	in_customer_key				IN VARCHAR2,	--one of: ACCOUNT, SID, ESN, MIN (identifies benefit owner)
	in_customer_value			IN VARCHAR2,	--value for the above key
  in_esn                IN VARCHAR2,   -- esn
	in_order_amount				IN VARCHAR2,	--amount of order, stored for ref (opt)
	in_benefit_amount			IN VARCHAR2,	--amount of benefit to be applied
	in_benefit_type_code				IN VARCHAR2,	--one of: LOYALTY_POINTS, UPGRADE_BENEFIT, UPGRADE_POINTS
	in_customer_name			IN VARCHAR2,	--customer info and billing address info, stored for ref
	in_address_line_1			IN VARCHAR2,
	in_address_line_2			IN VARCHAR2,
	in_address_zipcode			IN VARCHAR2,
	in_address_city				IN VARCHAR2,
	in_address_state			IN VARCHAR2,
	in_address_country			IN VARCHAR2,
	in_settlement_flag			IN VARCHAR2 DEFAULT 'N',	--pass 'T' to authorize and settle in one transaction (opt, default = 'N')
  in_ben_earning_objid      IN NUMBER,            -- CR41473 PMistyry 07/27/2016 LRP2
	out_transaction_id			out VARCHAR2,	--unique trans id for this transaction
	out_err_code				out VARCHAR2,	--errror codes (TBD)
	out_err_msg					out VARCHAR2	--errror msgs (TBD - not to be displayed to end user)
);


/* procedure for settling authorizaed purchases made with benefits */
PROCEDURE p_settle_benefit_payment (
	in_auth_trans_id			IN VARCHAR2,	--authorization trans ID returned from p_authorize_benefit_payment
	in_order_id					IN VARCHAR2,
	in_trans_date				IN DATE,
	in_trans_desc				IN VARCHAR2,
	out_transaction_id			out VARCHAR2,
	out_err_code				out VARCHAR2,
	out_err_msg					out VARCHAR2
);


/* procedure for cancelling authorized purchases made with benefits */
PROCEDURE p_cancel_benefit_payment (
	in_auth_trans_id			IN VARCHAR2,	--authorization trans ID returned from p_authorize_benefit_payment
	in_order_id					IN VARCHAR2,
	in_trans_date				IN DATE,
	in_trans_desc				IN VARCHAR2,
	out_transaction_id			out VARCHAR2,
	out_err_code				out VARCHAR2,
	out_err_msg					out VARCHAR2
);


/* procedure for refunding settled purchases made with benefits */
PROCEDURE p_refund_benefit_payment (
	in_settlement_trans_id		IN VARCHAR2,	--settlement trans ID returned from p_settle_benefit_payment
	in_order_id					IN VARCHAR2,
	in_trans_date				IN DATE,
	in_trans_desc				IN VARCHAR2,
	out_transaction_id			out VARCHAR2,
	out_err_code				out VARCHAR2,
	out_err_msg					out VARCHAR2
);
/* Procedure for updating the pin in rewards_benefit_transaction table for settlement */
PROCEDURE p_update_pin(
    in_transaction_id      IN   VARCHAR2, -- settlement auth ID
    in_transaction_type    IN   VARCHAR2, -- Transaction type
    in_pin                 IN   VARCHAR2, -- Pin# purchased through Loyalty points
    out_err_code           OUT  VARCHAR2,
    out_err_msg            OUT  VARCHAR2 );
--
END rewards_mgt_pymt_pkg;
/