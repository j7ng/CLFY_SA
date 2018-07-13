CREATE OR REPLACE PACKAGE BODY sa.rewards_mgt_pymt_pkg
AS
 --$RCSfile: REWARDS_MGT_PYMT_PKG.SQL,v $
 --$Revision: 1.36 $
 --$Author: pamistry $
 --$Date: 2016/09/19 21:31:05 $
 --$ $Log: REWARDS_MGT_PYMT_PKG.SQL,v $
 --$ Revision 1.36  2016/09/19 21:31:05  pamistry
 --$ CR41473 - LRP2 Corrected the cursor query in Create Benefit Transcation to fetch active benefit earning record for transaction type.
 --$
 --$ Revision 1.35  2016/09/14 23:14:19  pamistry
 --$ CR41473 - LRP2 Modify p_update_pin procedure to update the pin for Settlement or Charge.
 --$
 --$ Revision 1.1  2016/09/14 14:22:50  pamistry
 --$ CR41473 - LRP2 Modify p_update_pin procedure to update the pin for Settlement or Charge.
 --$

--------------------------------------------------------------------------------------------
-- Author: Usha S
-- Date: 2015/10/05
-- <CR# 33098>
--
-- Revision 1.1  yyyy/mm/dd hh:mm:ss  <tf userid>
-- <CR# Description>
--
--------------------------------------------------------------------------------------------
--function to get next benefit transaction sequence value
FUNCTION f_get_transaction_id
  RETURN NUMBER
AS
BEGIN
  --RETURN to_number ( to_char(seq_x_rew_ben_trans_id.nextval) || to_char(trunc(dbms_random.VALUE(1,99999999))) || to_char(SYSDATE,'rrdddsssss') );
  RETURN seq_x_rew_ben_trans_id.nextval;
exception
WHEN others THEN
  sa.ota_util_pkg.err_log ( p_action => 'OTHERS EXCEPTION', p_error_date => SYSDATE, p_key => 'CR32367', p_program_name => 'f_get_transaction_id', p_error_text => 'unable to generate new transaction ID...' || ', sqlerrm='|| substr(sqlerrm,1,300) );
  RETURN NULL;
END f_get_transaction_id;
--
--proc to fetch action and transaction description for the even type and transaction type passed
PROCEDURE p_get_benefit_trans_desc
(i_trans_type   IN  x_reward_benefit_transaction.trans_type%TYPE,
 i_event_type   IN  VARCHAR2,
 o_action       out VARCHAR2,
 o_action_type  out VARCHAR2,
 o_trans_desc   out VARCHAR2
)
IS
BEGIN
 o_action       := NULL;
 o_action_type  := NULL;
 o_trans_desc   := NULL;
 SELECT action, action_type, transaction_desc
   INTO o_action, o_action_type, o_trans_desc
   FROM x_reward_event_action
   WHERE transaction_type = i_trans_type
     AND event_type = i_event_type;
exception WHEN others THEN
--dbms_output.put_line('Error in job: '||sqlerrm||' - ' || dbms_utility.format_error_backtrace);
o_action       := NULL;
o_action_type  := NULL;
o_trans_desc   := NULL;
END p_get_benefit_trans_desc;

--proc to insert record into x_reward_benefit_transaction table
PROCEDURE p_create_benefit_trans (
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
      I_BENEFIT_TYPE_CODE  x_reward_benefit_transaction.BENEFIT_TYPE_CODE%TYPE,
      i_action        x_reward_benefit_transaction.action%TYPE DEFAULT NULL,
      i_action_type   x_reward_benefit_transaction.action_type%TYPE DEFAULT NULL,
      i_action_reason x_reward_benefit_transaction.action_reason%TYPE,
      i_btrans2btrans x_reward_benefit_transaction.benefit_trans2benefit_trans%TYPE,
      i_svc_plan_pin  x_reward_benefit_transaction.svc_plan_pin%TYPE,
      i_svc_plan_id   x_reward_benefit_transaction.svc_plan_id%TYPE,
      i_brand         x_reward_benefit_transaction.brand%TYPE,
      i_btrans2benefit x_reward_benefit_transaction.benefit_trans2benefit%TYPE,
      o_transaction_status   out x_reward_benefit_transaction.transaction_status%type )        -- CR41473 PMistry 08/04/2016 LRP2 Added new output parameter.

IS
o_action      x_reward_benefit_transaction.action%TYPE;
o_action_type x_reward_benefit_transaction.action_type%TYPE;
o_trans_desc  x_reward_benefit_transaction.trans_desc%TYPE;

  -- CR41473 Start 07/21/2016 PMistry Added to consider cooling period.
  l_status    varchar2(60 char);

  cursor cur_benefit_earning_detail(c_transaction_type   VARCHAR2) is
      select *
      from   sa.x_reward_benefit_earning
      where  transaction_type = c_transaction_type
      and    end_date > sysdate
      and    rownum = 1;
  rec_benefit_earning_detail     cur_benefit_earning_detail%rowtype;

  l_maturity_date   date;
  -- CR41473 End 07/21/2016 PMistry Added to consider cooling period.

BEGIN

  --proc to fetch action and transaction description for the even type and transaction type passed
  p_get_benefit_trans_desc(
                          i_trans_type   => i_trans_type,
                          i_event_type   => i_event_type,
                          o_action       => o_action,
                          o_action_type  => o_action_type,
                          o_trans_desc   => o_trans_desc);

  o_trans_desc  := nvl(o_trans_desc, i_trans_desc);
  o_action      := nvl(o_action, i_action);
  o_action_type := nvl(o_action_type, i_action_type);

  -- CR41473 Start 07/21/2016 PMistry Added to consider cooling period.
    if o_action = 'ADD' then

      open cur_benefit_earning_detail( i_trans_type );
      fetch cur_benefit_earning_detail into rec_benefit_earning_detail;

      if cur_benefit_earning_detail%found and nvl(rec_benefit_earning_detail.POINT_COOLDOWN_DAYS,0) <> 0 then
        l_maturity_date := i_trans_date + rec_benefit_earning_detail.POINT_COOLDOWN_DAYS;
        o_transaction_status := 'PENDING';
      else
        o_transaction_status := 'COMPLETE';
        l_maturity_date := i_trans_date;
      end if;
      close cur_benefit_earning_detail;
    else
      o_transaction_status := 'COMPLETE';
      l_maturity_date := i_trans_date;
    end if;
  -- CR41473 End 07/21/2016 PMistry Added to consider cooling period.


  INSERT
  INTO x_reward_benefit_transaction
          (OBJID
          ,TRANS_DATE
          ,WEB_ACCOUNT_ID
          ,SUBSCRIBER_ID
          ,MIN
          ,ESN
          ,OLD_MIN
          ,OLD_ESN
          ,TRANS_TYPE
          ,TRANS_DESC
          ,AMOUNT
          ,BENEFIT_TYPE_CODE
          ,ACTION
          ,ACTION_TYPE
          ,ACTION_REASON
          ,BENEFIT_TRANS2BENEFIT_TRANS
          ,SVC_PLAN_PIN
          ,SVC_PLAN_ID
          ,BRAND
          ,BENEFIT_TRANS2BENEFIT
          ,TRANSACTION_STATUS  -- CR41473 -- LRP2 -- PMistry
          ,Maturity_date       -- CR41473 -- LRP2 -- PMistry
          )
  VALUES (
      i_transaction_id,
      i_trans_date ,
      i_WEB_account_id ,
      i_subscriber_id ,
      i_min ,
      i_esn ,
      i_old_min ,
      i_old_esn ,
      i_trans_type ,
      o_trans_desc ,
      i_amount ,
      i_benefit_type_CODE ,
      o_action ,
      o_action_type ,
      i_action_reason ,  --i_event_type
      i_btrans2btrans ,
      i_svc_plan_pin ,
      i_svc_plan_id ,
      i_brand ,
      i_btrans2benefit,
      o_transaction_status,             -- CR41473 -- LRP2 -- PMistry
      l_maturity_date                   -- CR41473 -- LRP2 -- PMistry
    );
/*exception
WHEN others THEN
  dbms_output.put_line('EXCEPTION!');*/
END p_create_benefit_trans;

/* utility procedure for creating benefit transactions from a benefit transaction object */
PROCEDURE p_create_benefit_trans(
    i_event_type            IN  VARCHAR2,
    i_ben_trans             IN  typ_lrp_benefit_trans,
    o_transaction_status    OUT x_reward_benefit_transaction.transaction_status%type         -- CR41473 PMistry 08/04/2016 LRP2 Added new output parameter.
    )

IS
o_action      x_reward_benefit_transaction.action%TYPE;
o_action_type x_reward_benefit_transaction.action_type%TYPE;
o_trans_desc  x_reward_benefit_transaction.trans_desc%TYPE;

  -- CR41473 Start 07/21/2016 PMistry Added to consider cooling period.
  l_status    varchar2(60 char);

  cursor cur_benefit_earning_detail(c_transaction_type   VARCHAR2) is
      select *
      from   sa.x_reward_benefit_earning
      where  transaction_type = c_transaction_type
      and    end_date > sysdate
      and    rownum = 1;
  rec_benefit_earning_detail     cur_benefit_earning_detail%rowtype;

  l_maturity_date   date;
  -- CR41473 End 07/21/2016 PMistry Added to consider cooling period.

BEGIN

  --proc to fetch action and transaction description for the even type and transaction type passed
  p_get_benefit_trans_desc(
                          i_trans_type   => i_ben_trans.trans_type,
                          i_event_type   => i_event_type,
                          o_action       => o_action,
                          o_action_type  => o_action_type,
                          o_trans_desc   => o_trans_desc);
  --
  o_trans_desc  := nvl(o_trans_desc, i_ben_trans.trans_desc);
  o_action      := nvl(o_action, i_ben_trans.action);
  o_action_type := nvl(o_action_type, i_ben_trans.action_type);

  -- CR41473 Start 07/21/2016 PMistry Added to consider cooling period.
    if o_action = 'ADD' then
      open cur_benefit_earning_detail( i_ben_trans.trans_type );
      fetch cur_benefit_earning_detail into rec_benefit_earning_detail;

      if cur_benefit_earning_detail%found and nvl(rec_benefit_earning_detail.POINT_COOLDOWN_DAYS,0) <> 0 then
        l_maturity_date := i_ben_trans.trans_date + rec_benefit_earning_detail.POINT_COOLDOWN_DAYS;
        o_transaction_status := 'PENDING';
      else
        o_transaction_status := 'COMPLETE';
        l_maturity_date := i_ben_trans.trans_date;
      end if;
      close cur_benefit_earning_detail;

    else
      o_transaction_status := 'COMPLETE';
      l_maturity_date := i_ben_trans.trans_date;
    end if;
  -- CR41473 End 07/21/2016 PMistry Added to consider cooling period.

  INSERT INTO x_reward_benefit_transaction
      (OBJID
      ,TRANS_DATE
      ,WEB_ACCOUNT_ID
      ,SUBSCRIBER_ID
      ,MIN
      ,ESN
      ,OLD_MIN
      ,OLD_ESN
      ,TRANS_TYPE
      ,TRANS_DESC
      ,AMOUNT
      ,BENEFIT_TYPE_CODE
      ,ACTION
      ,ACTION_TYPE
      ,ACTION_REASON
      ,BENEFIT_TRANS2BENEFIT_TRANS
      ,SVC_PLAN_PIN
      ,SVC_PLAN_ID
      ,BRAND
      ,BENEFIT_TRANS2BENEFIT
      ,TRANSACTION_STATUS   -- CR41473 -- LRP2 -- PMistry
      ,Maturity_date        -- CR41473 -- LRP2 -- PMistry
      )
  VALUES
    (
      f_get_transaction_id,
      i_ben_trans.trans_date ,
      i_ben_trans.web_account_id ,
      i_ben_trans.subscriber_id ,
      i_ben_trans.MIN ,
      i_ben_trans.esn ,
      i_ben_trans.old_min ,
      i_ben_trans.old_esn ,
      i_ben_trans.trans_type ,
      o_trans_desc ,
      i_ben_trans.amount ,
      i_ben_trans.benefit_type_code ,
      o_action ,
      o_action_type ,
      i_event_type,  --i_ben_trans.action_reason,
      i_ben_trans.benefit_trans2benefit_trans ,
      i_ben_trans.svc_plan_pin ,
      i_ben_trans.svc_plan_id ,
      i_ben_trans.brand ,
      i_ben_trans.benefit_trans2benefit,
      l_status,             -- CR41473 -- LRP2 -- PMistry
      l_maturity_date       -- CR41473 -- LRP2 -- PMistry
    );
/*exception
WHEN others THEN
  dbms_output.put_line('EXCEPTION!');*/
END p_create_benefit_trans;


/* procedure for authorizing and settling purchases made with benefits */
PROCEDURE p_authorize_benefit_payment(
    in_order_source    IN VARCHAR2,  --source system ID, this will just be stored for ref
    in_order_id        IN VARCHAR2,  --source system order ID, stored for ref
    in_trans_date      IN DATE, --transaction date
    in_trans_desc      IN VARCHAR2,  --transaction descr, stored for ref (opt)
    in_brand           IN VARCHAR2,  --one of: NT, SM, ST, TC, SL, TW, TF
    in_customer_key    IN VARCHAR2,  --one of: ACCOUNT, SID, ESN, MIN (identifies benefit owner)
    in_customer_value  IN VARCHAR2,  --value for the above key
    in_esn             IN VARCHAR2,   -- esn
    in_order_amount    IN VARCHAR2,  --amount of order, stored for ref (opt)
    in_benefit_amount  IN VARCHAR2,  --amount of benefit to be applied
    in_benefit_type_code    IN VARCHAR2,  --one of: LOYALTY_POINTS, UPGRADE_BENEFIT, UPGRADE_POINTS
    in_customer_name   IN VARCHAR2,  --customer info and billing address info, stored for ref
    in_address_line_1  IN VARCHAR2,
    in_address_line_2  IN VARCHAR2,
    in_address_zipcode IN VARCHAR2,
    in_address_city    IN VARCHAR2,
    in_address_state   IN VARCHAR2,
    in_address_country IN VARCHAR2,
    in_settlement_flag IN VARCHAR2 DEFAULT 'N', --pass 'T' to authorize and settle in one transaction (opt, default = 'N')
    in_ben_earning_objid      IN NUMBER,            -- CR41473 PMistyry 07/27/2016 LRP2
    out_transaction_id out VARCHAR2,            --unique trans id for this transaction
    out_err_code out VARCHAR2,                  --errror codes (TBD)
    out_err_msg out VARCHAR2                    --errror msgs (TBD - not to be displayed to end user)
  )
IS
  l_new_auth_trans_id NUMBER;
  auth_input_failed    exception;
  --rec_order_det TYP_VOUCHER_ORDER_DETAILS;
  l_err_code      NUMBER;
  l_err_msg       VARCHAR2(2000);
  l_benefit_value NUMBER;
  /*l_token_rec              cur_voucher_token%rowtype;
  db_vouchers               typ_voucher_tab ;*/
  l_auth_benefit_cnt NUMBER;
  l_order_hdr_objid  NUMBER;
  l_benefit_count    NUMBER;
  trec_benefit        x_reward_benefit%rowtype;
  l_min              table_site_part.x_min%TYPE;

  -- CR41473 Start PMistry 07/27/2016
  cursor cur_reward_ben_earning (c_ben_earning_objid   number) is
      select *
      from   x_reward_benefit_earning
      where objid = c_ben_earning_objid;

  rec_reward_ben_earning      cur_reward_ben_earning%rowtype;

  l_transaction_status     x_reward_benefit_transaction.transaction_status%type;
  -- CR41473 End

BEGIN
  --
  IF (in_order_source IS NULL OR in_order_source NOT IN ('APP', 'BEAST', 'IVR', 'NETCSR', 'NETWEB', 'WAP','WEB','WEBCSR','API')) THEN
    out_transaction_id := 0;
    l_err_code        := -350;
    l_err_msg         := 'Error. Invalid or null value received for ORDER SOURCE';
    raise auth_input_failed;
  elsif in_order_id    IS NULL THEN
    out_transaction_id := 0;
    l_err_code        := -336;
    l_err_msg         := 'Error. Invalid or Null value received for Input ORDER ID';
    raise auth_input_failed;
  elsif in_trans_date  IS NULL THEN
    out_transaction_id := 0;
    l_err_code        := -362;
    l_err_msg         := 'Error. Invalid or Null value received for Input IN_TRANS_DATE';
    raise auth_input_failed;
  elsif in_trans_desc  IS NULL THEN
    out_transaction_id := 0;
    l_err_code        := -351;
    l_err_msg         := 'Error. Invalid or null value received for TRANS DESC';
    raise auth_input_failed;
  elsif (in_brand       IS NULL OR  in_brand NOT IN ('STRAIGHT_TALK','ST'))   THEN
    out_transaction_id := 0;
    l_err_code        := -352;
    l_err_msg         := 'Error. Invalid or null value received for BRAND';
    raise auth_input_failed;
  elsif in_customer_key IS NULL THEN
    out_transaction_id  := 0;
    l_err_code         := -311;
    l_err_msg          := 'Error. Unsupported or Null values received for IN_KEY and IN_VALUE';
    raise auth_input_failed;
  elsif in_customer_value IS NULL THEN
    out_transaction_id    := 0;
    l_err_code           := -311;
    l_err_msg            := 'Error. Unsupported or Null values received for IN_KEY and IN_VALUE';
    raise auth_input_failed;
  elsif (in_order_amount IS NULL or in_order_amount = 0) THEN
    out_transaction_id  := 0;
    l_err_code         := -353;
    l_err_msg          := 'Error. Invalid or null value received for ORDER AMOUNT';
    raise auth_input_failed;
  elsif (in_benefit_amount IS NULL or in_benefit_amount = 0) THEN
    out_transaction_id  := 0;
    l_err_code         := -365;
    l_err_msg          := 'Please provide value for input IN_BENEFIT_AMOUNT';
    raise auth_input_failed;
  elsif in_benefit_type_code IS NULL THEN
    out_transaction_id  := 0;
    l_err_code         := -313;
    l_err_msg          := 'Error. Invalid or null value received for benefit type';
    raise auth_input_failed;
  elsif NVL(in_order_source,'XX') !='API' AND in_esn IS NULL THEN			-- CR41473 PMistry LRP2
    out_transaction_id  := 0;
    l_err_code         := -354;
    l_err_msg          := 'Error. Invalid or null value received for ESN';
    raise auth_input_failed;
  END IF;
  BEGIN
    SELECT count(1)
    INTO l_benefit_count
    FROM x_reward_benefit tb
--    WHERE decode(in_customer_key,'ACCOUNT',tb.web_account_id,'SID', tb.subscriber_id, 'ESN', tb.esn, 'MIN', tb.MIN) = in_customer_value
    WHERE in_customer_key     = 'ACCOUNT'
    AND tb.web_account_id         = in_customer_value
    AND tb.benefit_type_code       = in_benefit_type_code
    AND tb.brand              = in_brand
   -- AND tb.benefit_owner    = in_customer_key
    AND tb.status             = 'AVAILABLE';
  exception
  WHEN others THEN
    l_benefit_count := 0;
  END;
  --
  BEGIN
    SELECT x_min
    INTO   l_min
    FROM   table_site_part
    where  x_service_id = in_esn
    and    part_status  = 'Active';
  exception
  WHEN others THEN
    l_min := NULL;
  END;
  --
  IF l_benefit_count   = 0 THEN
    out_transaction_id := 0;
    l_err_code        := -366;
    l_err_msg         := 'Invalid Benefit Status';
    raise auth_input_failed;
  END IF;
  -- get all the benefits related to the customer account id which are in available status
  BEGIN
  SELECT tb.*
  INTO trec_benefit
  FROM x_reward_benefit tb
  --WHERE decode(in_customer_key,'ACCOUNT',tb.web_account_id,'SID', tb.subscriber_id, 'ESN', tb.esn, 'MIN', tb.MIN)  = in_customer_value
  WHERE in_customer_key     = 'ACCOUNT'
  AND tb.web_account_id     = in_customer_value
  AND tb.benefit_type_code       = in_benefit_type_code
  AND tb.brand              = in_brand
  --AND tb.benefit_owner    = in_customer_key
  AND tb.status             = 'AVAILABLE';
  exception WHEN others THEN
    out_transaction_id := 0;
    l_err_code        := -366;
    l_err_msg         := 'Invalid Benefit Status';
    raise auth_input_failed;
  END;

  -- CR41473 Start PMistry 07/27/2016
  if in_ben_earning_objid is not null then
    open cur_reward_ben_earning (in_ben_earning_objid ) ;
    fetch cur_reward_ben_earning into rec_reward_ben_earning;
    close cur_reward_ben_earning;
  end if;
  -- CR41473 End


    IF trec_benefit.expiry_date <= SYSDATE AND trec_benefit.expiry_date IS NOT NULL THEN
      UPDATE x_reward_benefit
      SET status = 'UNAVAILABLE'--Modified for 2269
        ,expiry_date = SYSDATE
		, account_status = 'EXPIRED'  --Modified for 2269
      WHERE objid     = trec_benefit.objid;
      l_err_code    := -363;
      l_err_msg     := 'Benefit is Expired';
      raise auth_input_failed;
    elsif trec_benefit.benefit_type_code  IN ('LOYALTY_POINTS','UPGRADE_POINTS') AND nvl(trec_benefit.quantity,0) < in_benefit_amount THEN
      l_err_code    := -364;
      l_err_msg     := 'Benefit Points are not sufficient';
      raise auth_input_failed;
    ELSE
      --generate new transaction id
      l_new_auth_trans_id := f_get_transaction_id;
      out_transaction_id   := l_new_auth_trans_id;
      --Create a new benefit transaction
      p_create_benefit_trans
      (           CASE
                    WHEN nvl(in_settlement_flag,'N') = 'T'
                    --THEN 'SETTLEMENT'    -----settlement
                    THEN 'CHARGE'    -----Charge                            -- CR41473 PMistry 07/27/2016 For LRP2
                    ELSE 'AUTHORIZATION' -----authorization
                  END
          ,l_new_auth_trans_id --objid
          ,in_trans_date
          ,trec_benefit.web_account_id
          ,trec_benefit.subscriber_id
          ,l_min
          ,in_esn
          ,NULL --trec_benefit.NEW_MIN
          ,NULL --trec_benefit.NEW_ESN
          , CASE
                      WHEN nvl(in_settlement_flag,'N') = 'T'
                      --THEN 'SETTLEMENT'    -----settlement
                      THEN 'CHARGE'    -----Charge                            -- CR41473 PMistry 07/27/2016 For LRP2
                      ELSE 'AUTHORIZATION' -----authorization --Modified for 2269
                    END --trec_benefit.TRANS_TYPE

          ,        nvl(rec_reward_ben_earning.Transaction_Description,'Redemption of AT Card')		-- CR41473 PMistry 07/27/2016 For LRP2
          --,in_benefit_amount --X_POINTS
        ,CASE
            WHEN nvl(in_settlement_flag,'N') = 'T'
              THEN in_benefit_amount * -1 -----settlement/ charge
            ELSE in_benefit_amount   -----authorization
          END           --X_POINTS     -- CR41473 PMistry 07/28/2016 LRP2
		  ,trec_benefit.benefit_type_code
          ,
                  CASE
                    WHEN nvl(in_settlement_flag,'N') = 'T'
                    THEN 'DEDUCT' -----settlement/charge
                    ELSE 'NOTE'   -----authorization
                  END                --X_POINTS_ACTION -- CR35343:070215 changing to CONVERT from ADD		-- CR41473 PMistry 07/27/2016 For LRP2
          ,
                  CASE
                    WHEN nvl(in_settlement_flag,'N') = 'T'
                    --THEN 'SETTLEMENT'    -----settlement
                    THEN 'CHARGE'    -----charge
                    ELSE 'AUTHORIZATION' -----authorization
                  END                       -- ACTION_TYPE		-- CR41473 PMistry 07/27/2016 For LRP2
          ,
          nvl(rec_reward_ben_earning.Transaction_Description,'Redemption of AT Card')		-- CR41473 PMistry 07/27/2016 For LRP2
          , NULL --POINT_TRANS2POINT_TRANS
          , NULL --trec_benefit.SVC_PLAN_PIN
          , NULL --trec_benefit.SVC_PLAN_ID
          , in_brand
          , trec_benefit.objid
          , l_transaction_status                     -- CR41473 08/04/2016 PMistry Added new output parameter with LRP phase 2
        );
    --During settlement either benefit values or points are updated based on benefit types
    --IF nvl(in_settlement_flag,'N') = 'T' THEN --settlement
      --mark the benefits as unavailable for authorize transaction and used for settle
      -- CR41473 PMistry 07/27/2016 modify the update to include pending_quantity and total_quantity update for LRP2.
      rewards_mgt_util_pkg.p_update_benefit(  in_cust_key => 'OBJID',
                                              in_cust_value => trec_benefit.objid,
                                              in_program_name => NULL,
                                              in_benefit_type => NULL,
                                              in_brand => NULL,
                                              in_new_min => NULL,
                                              in_new_esn => NULL,
                                              in_new_status => NULL,
                                              in_new_notes => NULL,
                                              in_new_expiry_date => NULL,
                                              in_change_quantity => (CASE in_benefit_type_code
                                                                        WHEN 'LOYALTY_POINTS'   THEN in_benefit_amount * -1
                                                                        WHEN 'UPGRADE_POINTS'   THEN in_benefit_amount * -1
                                                                        WHEN 'UPGRADE_BENEFITS' THEN 0
                                                                        ELSE 0
                                                                      END),
                                              in_transaction_status => l_transaction_status,
                                              in_account_status => NULL
                                            );
    --
    /*  CR41473 07/27/2016 PMistry commented out by as both update were updating the same columns with same values.
    ELSE --authorization
      --When authorizing only points are updated and no benefit amounts are updated.
      -- CR41473 PMistry 07/27/2016 modify the update to include pending_quantity and total_quantity update for LRP2.
      UPDATE x_reward_benefit
      SET    quantity       = CASE in_benefit_type_code
                              WHEN 'LOYALTY_POINTS'   THEN quantity - in_benefit_amount
                              WHEN 'UPGRADE_POINTS'   THEN quantity - in_benefit_amount
                              WHEN 'UPGRADE_BENEFITS' THEN quantity
                              ELSE quantity
                              END ,
             update_date    = SYSDATE
      WHERE  objid          = trec_benefit.objid;
    END IF;
    */
    END IF;

  COMMIT;
  --OUT_TRANSACTION_ID    :=  f_get_transaction_id;
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
exception
-- CR42235 Changes Starts
WHEN DUP_VAL_ON_INDEX THEN
  out_err_code := -99;
  out_err_msg  := 'p_compensate_reward_points ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
-- CR42235 Changes Ends

WHEN auth_input_failed THEN
  out_err_code       := l_err_code;
  out_err_msg        := l_err_msg;
  out_transaction_id := NULL;
  --ROLLBACK;
  --Modified for CR41118
  --sa.ota_util_pkg.err_log ( p_action => 'Validation Failed', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_authorize_benefit_payment', p_error_text => 'input params: ' || 'IN_SETTLEMENT_FLAG='||in_settlement_flag || ', ORDER_ID='|| in_order_id || ', IN_CUSTOMER_KEY=' || in_customer_key || ', IN_CUSTOMER_VALUE=' || in_customer_value || ', out_trans_id= ' || l_new_auth_trans_id || ', out_error_code='||out_err_code || ', out_error_msg='|| out_err_msg );
WHEN others THEN
  ROLLBACK;
  out_transaction_id := l_new_auth_trans_id;
  out_err_code       := -99;
  out_err_msg        := 'p_authorize_benefit_payment=' ||substr(sqlerrm, 1, 2000) || ' - ' ||dbms_utility.format_error_backtrace ;
  sa.ota_util_pkg.err_log ( p_action => 'OTHERS EXCEPTION', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_authorize_benefit_payment', p_error_text => 'input params: ' || 'IN_SETTLEMENT_FLAG='||in_settlement_flag || ', ORDER_ID='|| in_order_id || ', IN_CUSTOMER_KEY=' || in_customer_key || ', IN_CUSTOMER_VALUE=' || in_customer_value || ', out_trans_id= ' || l_new_auth_trans_id || ', out_error_code='||out_err_code || ', out_error_msg='|| out_err_msg );
END p_authorize_benefit_payment;

/* procedure for settling authorizaed purchases made with benefits */
PROCEDURE p_settle_benefit_payment(
    in_auth_trans_id IN VARCHAR2, --authorization trans ID returned from p_authorize_benefit_payment
    in_order_id      IN VARCHAR2,
    in_trans_date    IN DATE,
    in_trans_desc    IN VARCHAR2,
    out_transaction_id out VARCHAR2,
    out_err_code out VARCHAR2,
    out_err_msg out VARCHAR2 )
IS
  l_new_settle_trans_id   NUMBER;
  settle_input_failed     exception;
  l_err_code              NUMBER;
  l_err_msg               VARCHAR2(2000);
  l_status                VARCHAR2(100);
  l_auth_benefit_cnt      NUMBER;
  l_transaction_status     x_reward_benefit_transaction.transaction_status%type;     -- CR41473 PMistry 08/03/2016 LRP2

BEGIN
  --
  IF trim(in_auth_trans_id) IS NULL THEN
    out_transaction_id      := 0;
    l_err_code            := -381;
    l_err_msg             := 'Error. Invalid or Null value received for Input Auth transaction ID';
    raise settle_input_failed;
  elsif in_order_id    IS NULL THEN
    out_transaction_id := 0;
    l_err_code       := -382;
    l_err_msg        := 'Error. Invalid or Null value received for Input Order ID';
    raise settle_input_failed;
  elsif in_trans_date  IS NULL THEN
    out_transaction_id := 0;
    l_err_code        := -362;
    l_err_msg         := 'Error. Invalid or Null value received for Input IN_TRANS_DATE';
    raise settle_input_failed;
  elsif in_trans_desc  IS NULL THEN
    out_transaction_id := 0;
    l_err_code        := -351;
    l_err_msg         := 'Error. Invalid or null value received for TRANS DESC';
    raise settle_input_failed;
  ELSE
    BEGIN
    SELECT count(1)
    INTO l_err_code
    FROM x_reward_benefit_transaction y
    WHERE y.benefit_trans2benefit_trans = in_auth_trans_id
      AND trans_type IN ('SETTLEMENT', 'CANCELLATION'); --Modified for 2269
      IF   l_err_code > 0 THEN
        l_err_code := -381;
        l_err_msg  := 'Error. Invalid or Null value received for Input Auth transaction ID ';
        raise settle_input_failed;
      END IF;
    END;

    BEGIN
      l_err_code:=0;
      SELECT count(1)
      INTO l_err_code
      FROM x_reward_benefit_transaction x
      WHERE objid    = in_auth_trans_id
      AND trans_type = 'AUTHORIZATION' ; --951=Authorized transaction --Modified for 2269
    exception
    WHEN others THEN
      l_err_code := 0 ;
    END;
    --raise error if auth trans id not found
    IF l_err_code = 0 THEN
      l_err_code := -381;
      l_err_msg  := 'Error. Invalid or Null value received for Input Auth transaction ID ';
      raise settle_input_failed;
    END IF;
  END IF;
  -- get the count of vouchers associated to the transaction id
  FOR trec_benefit IN
  (SELECT tbt.benefit_trans2benefit benefit_objid,
    tbt.objid authtrans_objid,
    tbt.web_account_id,
    tbt.subscriber_id,
    tbt.MIN,
    tbt.esn,
    tbt.old_min,
    tbt.old_esn,
    tbt.trans_type,
    tbt.trans_desc,
    tbt.amount,
    tbt.benefit_type_code ,
    tbt.svc_plan_pin,
    tbt.svc_plan_id,
    tbt.brand,
    tb.expiry_date,
    tb.quantity,
    tb.status
  FROM x_reward_benefit tb,
    x_reward_benefit_transaction tbt
  WHERE tb.objid     = tbt.benefit_trans2benefit
  AND tbt.objid      = in_auth_trans_id
  AND tbt.trans_type = 'AUTHORIZATION' --Authorized transaction --Modified for 2269
  AND tb.account_status      <> ('EXPIRED') --Modified for 2269
  )
  loop
    IF trec_benefit.expiry_date <= SYSDATE THEN
      UPDATE x_reward_benefit
      SET status = 'UNAVAILABLE' --Modified for 2269
        ,expiry_date = SYSDATE
		, account_status = 'EXPIRED'  --Modified for 2269
      WHERE objid     = trec_benefit.benefit_objid;
      l_err_code    := -363;
      l_err_msg     := 'Benefit is Expired';
      raise settle_input_failed;
    elsif trec_benefit.status <>  'AVAILABLE' THEN
      l_err_code    := -366;
      l_err_msg     := 'Invalid Benefit status';
      raise settle_input_failed;
    ELSE
      --generate new transaction id
      l_new_settle_trans_id := f_get_transaction_id ;
      out_transaction_id     := l_new_settle_trans_id;
      --Create a new benefit transaction
      p_create_benefit_trans
      (   'SETTLEMENT',
          l_new_settle_trans_id --objid
          ,
          in_trans_date ,
          trec_benefit.web_account_id ,
          trec_benefit.subscriber_id ,
          trec_benefit.MIN ,
          trec_benefit.esn ,
          trec_benefit.old_min ,
          trec_benefit.old_esn ,
          'SETTLEMENT' --trec_benefit.TRANS_TYPE --Modified for 2269
          ,
          --'REFUND OF BENEFIT PAYMENT'
          'Redemption of AT Card',--in_trans_desc , --Modified for 2269
          trec_benefit.amount * - 1 --X_POINTS
          ,
          trec_benefit.benefit_type_code ,
          'DEDUCT' --X_POINTS_ACTION -- CR35343:070215 changing to CONVERT from ADD
          ,
          'SETTLEMENT' -- ACTION_TYPE
          ,
          'Redemption of AT Card'--in_trans_desc ---ACTION_REASON --Modified for 2269
          ,
          trec_benefit.authtrans_objid --POINT_TRANS2POINT_TRANS
          ,
          trec_benefit.svc_plan_pin ,
          trec_benefit.svc_plan_id ,
          trec_benefit.brand ,
          trec_benefit.benefit_objid,
          l_transaction_status               -- CR41473 08/04/2016 PMistry Added new output parameter with LRP phase 2
        );
      --mark the benefits as USED
      --During settlement either benefit values are updated if the payment is already authorized.
      --For upgrade_points and loyalty_points, the points updation will be done during authorization

      /*l_status :=
      CASE
      WHEN trec_benefit.benefit_type_code  = 'UPGRADE_BENEFITS' THEN
        'USED'
      ELSE
        CASE
        WHEN trec_benefit.quantity = 0 THEN
          '962'
        ELSE
          '961'
        END
      END;
      UPDATE x_reward_benefit
      SET status    = l_status ,
        update_date = SYSDATE ,
        VALUE         = decode(trec_benefit.benefit_type_code , 'UPGRADE_BENEFITS', VALUE - trec_benefit.amount, VALUE)
      WHERE objid     = trec_benefit.benefit_objid;
      */
    END IF;
  END loop;
  COMMIT;
  --OUT_TRANSACTION_ID :=  f_get_transaction_id;
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
exception
-- CR42235 Changes Starts
WHEN DUP_VAL_ON_INDEX THEN
  out_err_code := -99;
  out_err_msg  := 'p_compensate_reward_points ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
-- CR42235 Changes Ends

WHEN settle_input_failed THEN
  out_err_code       := l_err_code;
  out_err_msg        := l_err_msg;
  out_transaction_id := NULL;
  --ROLLBACK;
  --Modified for CR41118
  --sa.ota_util_pkg.err_log ( p_action => 'Validation Failed', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_settle_benefit_payment', p_error_text => 'input params: ' || 'IN_AUTH_TRANS_ID ='||in_auth_trans_id  || ', IN_ORDER_ID='|| in_order_id || ', IN_TRANS_DATE=' || in_trans_date || ', IN_TRANS_DESC=' || in_trans_desc || ', out_trans_id= ' || l_new_settle_trans_id || ', out_error_code='||out_err_code || ', out_error_msg='|| out_err_msg );
WHEN others THEN
  ROLLBACK;
  out_err_code := -99;
  out_err_msg  := 'P_SETTLE_BENEFIT_PAYMENT='||substr(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace ;
  sa.ota_util_pkg.err_log ( p_action => 'OTHERS EXCEPTION', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_settle_benefit_payment', p_error_text => 'input params: ' || 'IN_AUTH_TRANS_ID ='||in_auth_trans_id  || ', IN_ORDER_ID='|| in_order_id || ', IN_TRANS_DATE=' || in_trans_date || ', IN_TRANS_DESC=' || in_trans_desc || ', out_trans_id= ' || l_new_settle_trans_id || ', out_error_code='||out_err_code || ', out_error_msg='|| out_err_msg );
END p_settle_benefit_payment;

/* procedure for cancelling authorized purchases made with benefits */
PROCEDURE p_cancel_benefit_payment(
    in_auth_trans_id IN VARCHAR2, --authorization trans ID returned from p_authorize_benefit_payment
    in_order_id      IN VARCHAR2,
    in_trans_date    IN DATE,
    in_trans_desc    IN VARCHAR2,
    out_transaction_id out VARCHAR2,
    out_err_code out VARCHAR2,
    out_err_msg out VARCHAR2 )
IS
  l_new_cancel_trans_id     NUMBER;
  cancel_input_failed       exception;
  l_err_code                NUMBER;
  l_err_msg                 VARCHAR2(2000);
  l_auth_benefit_cnt        NUMBER;
  l_transaction_status      x_reward_benefit_transaction.transaction_status%type;     -- CR41473 PMistry 08/03/2016 LRP2

BEGIN
  --
  IF trim(in_auth_trans_id) IS NULL THEN
    out_transaction_id      := 0;
    l_err_code            := -383;
    l_err_msg             := 'Error. Invalid or Null value received for Input Auth transaction ID';
    raise cancel_input_failed;
  elsif in_order_id    IS NULL THEN
    out_transaction_id := 0;
    l_err_code       := -384;
    l_err_msg        := 'Error. Invalid or Null value received for Input Order ID';
    raise cancel_input_failed;
  elsif in_trans_date  IS NULL THEN
    out_transaction_id := 0;
    l_err_code        := -362;
    l_err_msg         := 'Error. Invalid or Null value received for Input IN_TRANS_DATE';
    raise cancel_input_failed;
  elsif in_trans_desc  IS NULL THEN
    out_transaction_id := 0;
    l_err_code        := -351;
    l_err_msg         := 'Error. Invalid or null value received for TRANS DESC';
    raise cancel_input_failed;
  ELSE

    BEGIN
    SELECT count(1)
    INTO l_err_code
    FROM x_reward_benefit_transaction y
    WHERE y.benefit_trans2benefit_trans = in_auth_trans_id
      AND trans_type IN ('SETTLEMENT', 'CANCELLATION'); --Modified for 2269
      IF   l_err_code > 0 THEN
        l_err_code := -383;
        l_err_msg  := 'Error. Invalid or Null value received for Input Auth transaction ID ';
        raise cancel_input_failed;
      END IF;
    END;

    BEGIN
      SELECT count(1)
      INTO l_err_code
      FROM x_reward_benefit_transaction
      WHERE objid    = in_auth_trans_id
      AND trans_type = 'AUTHORIZATION'; --951=authorization transaction --Modified for 2269
    exception
    WHEN others THEN
      l_err_code := 0 ;
    END;
    --raise error if auth trans id not found
    IF l_err_code = 0 THEN
      l_err_code := -383;
      l_err_msg  := 'Error. Invalid or Null value received for Input Auth transaction ID';
      raise cancel_input_failed;
    END IF;
  END IF;
  -- get the count of vouchers associated to the transaction id
  FOR trec_benefit IN
  (SELECT tb.objid benefit_objid,
    tbt.objid authtrans_objid,
    tbt.web_account_id,
    tbt.subscriber_id,
    tbt.MIN,
    tbt.esn,
    tbt.old_min,
    tbt.old_esn,
    tbt.trans_type,
    tbt.trans_desc,
    tbt.amount,
    tbt.benefit_type_code ,
    tbt.svc_plan_pin,
    tbt.svc_plan_id,
    tbt.brand,
    tb.expiry_date,
    tb.status
  FROM x_reward_benefit tb,
    x_reward_benefit_transaction tbt
  WHERE tb.objid     = tbt.benefit_trans2benefit
  AND tbt.objid      = in_auth_trans_id
  AND tbt.trans_type = 'AUTHORIZATION' --transaction authorized --Modified for 2269
  --AND tb.status    <> ('EXPIRED') --benefit not expired
   AND tb.account_status    <> ('EXPIRED')  --Modified for 2269
  )
  loop
    IF trec_benefit.expiry_date <= SYSDATE THEN
      UPDATE x_reward_benefit
      SET status = 'UNAVAILABLE' --Modified for 2269
        , expiry_date = SYSDATE
		, account_status = 'EXPIRED'  --Modified for 2269
      WHERE objid     = trec_benefit.benefit_objid;
      l_err_code    := -363;
      l_err_msg     := 'Benefit is Expired';
      raise cancel_input_failed;
    elsif trec_benefit.status <>  'AVAILABLE' THEN
      l_err_code    := -366;
      l_err_msg     := 'Invalid Benefit status';
      raise cancel_input_failed;
    ELSE
      --generate new transaction id
      l_new_cancel_trans_id := f_get_transaction_id ;
      out_transaction_id     := l_new_cancel_trans_id;
      --Create a new benefit transaction
      p_create_benefit_trans
      (   'CANCELLATION',
          l_new_cancel_trans_id --objid
          ,
          in_trans_date ,
          trec_benefit.web_account_id ,
          trec_benefit.subscriber_id ,
          trec_benefit.MIN ,
          trec_benefit.esn ,
          trec_benefit.old_min ,
          trec_benefit.old_esn ,
          'CANCELLATION' --trec_benefit.TRANS_TYPE --Modified for 2269
          ,
          --'CANCELLATION OF BENEFIT PAYMENT'
          'Refund of AT Card',--in_trans_desc , --Modified for 2269
          abs(trec_benefit.amount) --X_POINTS --Modified for 2269
          ,
          trec_benefit.benefit_type_code ,
          'NOTE' --X_POINTS_ACTION -- CR35343:070215 changing to CONVERT from ADD
          ,
          'CANCELLATION' -- ACTION_TYPE
          ,
          'Refund of AT Card' ---ACTION_REASON --Modified for 2269
          ,
          trec_benefit.authtrans_objid --POINT_TRANS2POINT_TRANS
          ,
          trec_benefit.svc_plan_pin ,
          trec_benefit.svc_plan_id ,
          trec_benefit.brand ,
          trec_benefit.benefit_objid,
          l_transaction_status          -- CR41473 08/04/2016 PMistry Added new output parameter with LRP phase 2
        );
      --mark the benefits as cancelled
      rewards_mgt_util_pkg.p_update_benefit(  in_cust_key => 'OBJID',
                                              in_cust_value => trec_benefit.benefit_objid,
                                              in_program_name => NULL,
                                              in_benefit_type => NULL,
                                              in_brand => NULL,
                                              in_new_min => NULL,
                                              in_new_esn => NULL,
                                              in_new_status => 'AVAILABLE',
                                              in_new_notes => NULL,
                                              in_new_expiry_date => NULL,
                                              in_change_quantity => (CASE trec_benefit.benefit_type_code
                                                                        WHEN 'LOYALTY_POINTS'   THEN abs(trec_benefit.amount)
                                                                        WHEN 'UPGRADE_POINTS'   THEN trec_benefit.amount
                                                                        WHEN 'UPGRADE_BENEFITS' THEN 0
                                                                        ELSE 0
                                                                      END),                   -- CR41473 - LRP2
                                              in_transaction_status => l_transaction_status,  -- CR41473 - LRP2
                                              in_value              => (CASE trec_benefit.benefit_type_code
                                                                          WHEN 'UPGRADE_BENEFITS' THEN trec_benefit.amount
                                                                          ELSE 0
                                                                        END),                 -- CR41473 - LRP2
                                              in_account_status => NULL
                                            );
      /*
      UPDATE  x_reward_benefit
      SET   status        = 'AVAILABLE'  ,
            quantity      =  CASE benefit_type_code
                                WHEN 'LOYALTY_POINTS'   THEN quantity + abs(trec_benefit.amount)
                                WHEN 'UPGRADE_POINTS'   THEN quantity + trec_benefit.amount
                                WHEN 'UPGRADE_BENEFITS' THEN quantity
                                ELSE quantity
                            END
            VALUE         = CASE benefit_type_code
                            WHEN 'UPGRADE_BENEFITS' THEN VALUE  + trec_benefit.amount
                            ELSE VALUE
                            END ,
            update_date   = SYSDATE
      WHERE objid         = trec_benefit.benefit_objid;
      */
    END IF;
  END loop;
  COMMIT;
  --OUT_TRANSACTION_ID    :=  f_get_transaction_id;
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
exception
-- CR42235 Changes Starts
WHEN DUP_VAL_ON_INDEX THEN
  out_err_code := -99;
  out_err_msg  := 'p_compensate_reward_points ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
-- CR42235 Changes Ends

WHEN cancel_input_failed THEN
  out_err_code       := l_err_code;
  out_err_msg        := l_err_msg;
  out_transaction_id := NULL;
  --ROLLBACK;
  --Modified for CR41118
  --sa.ota_util_pkg.err_log ( p_action => 'Validation Failed', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_cancel_benefit_payment', p_error_text => 'input params: ' || 'IN_AUTH_TRANS_ID ='||in_auth_trans_id  || ', IN_ORDER_ID='|| in_order_id || ', IN_TRANS_DATE=' || in_trans_date || ', IN_TRANS_DESC=' || in_trans_desc || ', out_trans_id= ' || l_new_cancel_trans_id || ', out_error_code='||out_err_code || ', out_error_msg='|| out_err_msg );
WHEN others THEN
  ROLLBACK;
  out_err_code := -99;
  out_err_msg  := 'P_CANCEL_BENEFIT_PAYMENT='||substr(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace ;
  sa.ota_util_pkg.err_log ( p_action => 'OTHERS EXCEPTION', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_cancel_benefit_payment', p_error_text => 'input params: ' || 'IN_AUTH_TRANS_ID ='||in_auth_trans_id  || ', IN_ORDER_ID='|| in_order_id || ', IN_TRANS_DATE=' || in_trans_date || ', IN_TRANS_DESC=' || in_trans_desc || ', out_trans_id= ' || l_new_cancel_trans_id || ', out_error_code='||out_err_code || ', out_error_msg='|| out_err_msg );
END p_cancel_benefit_payment;
/* procedure for refunding settled purchases made with benefits */
PROCEDURE p_refund_benefit_payment(
    in_settlement_trans_id IN VARCHAR2, --settlement trans ID returned from p_settle_benefit_payment
    in_order_id            IN VARCHAR2,
    in_trans_date          IN DATE,
    in_trans_desc          IN VARCHAR2,
    out_transaction_id out VARCHAR2,
    out_err_code out VARCHAR2,
    out_err_msg out VARCHAR2 )
IS
  l_new_refund_trans_id   NUMBER;
  refund_input_failed     exception;
  l_err_code              NUMBER;
  l_err_msg               VARCHAR2(2000);
  l_transaction_status    x_reward_benefit_transaction.transaction_status%type;     -- CR41473 PMistry 08/03/2016 LRP2

BEGIN
  --
  IF trim(in_settlement_trans_id) IS NULL THEN
    out_transaction_id            := 0;
    l_err_code                  := -385;
    l_err_msg                   := 'Error. Invalid or Null value received for Input Settlement transaction ID';
    raise refund_input_failed;
  elsif in_order_id    IS NULL THEN
    out_transaction_id := 0;
    l_err_code       := -386;
    l_err_msg        := 'Error. Invalid or Null value received for Input Order ID';
    raise refund_input_failed;
  elsif in_trans_date  IS NULL THEN
    out_transaction_id := 0;
    l_err_code        := -362;
    l_err_msg         := 'Error. Invalid or Null value received for Input IN_TRANS_DATE';
    raise refund_input_failed;
  elsif in_trans_desc  IS NULL THEN
    out_transaction_id := 0;
    l_err_code        := -351;
    l_err_msg         := 'Error. Invalid or null value received for TRANS DESC';
    raise refund_input_failed;
  ELSE

    BEGIN
    SELECT count(1)
    INTO l_err_code
    FROM x_reward_benefit_transaction y
    WHERE y.benefit_trans2benefit_trans = in_settlement_trans_id
      AND trans_type IN ('REFUND', 'CANCELLATION'); --Modified for 2269
      IF   l_err_code > 0 THEN
        l_err_code := -385;
        l_err_msg  := 'Error. Invalid or Null value received for Input Settlement transaction ID';
        raise refund_input_failed;
      END IF;
    END;

    BEGIN
      SELECT count(1)
      INTO l_err_code
      FROM x_reward_benefit_transaction
      WHERE objid    = in_settlement_trans_id
      AND trans_type = 'SETTLEMENT'; --952=Settled transaction --Modified for 2269
    exception
    WHEN others THEN
      l_err_code := 0 ;
    END;
    --raise error if auth trans id not found
    IF l_err_code = 0 THEN
      l_err_code := -385;
      l_err_msg  := 'Error. Invalid or Null value received for Input Settlement transaction ID';
      raise refund_input_failed;
    END IF;
  END IF;
  -- get the count of vouchers associated to the transaction id
  FOR trec_benefit IN
  (SELECT tb.objid benefit_objid,
    tbt.objid authtrans_objid,
    tbt.web_account_id,
    tbt.subscriber_id,
    tbt.MIN,
    tbt.esn,
    tbt.old_min,
    tbt.old_esn,
    tbt.trans_type,
    tbt.trans_desc,
    tbt.amount,
    tbt.benefit_type_code ,
    tbt.svc_plan_pin,
    tbt.svc_plan_id,
    tbt.brand,
    tb.expiry_date,
    tb.status
  FROM x_reward_benefit tb,
    x_reward_benefit_transaction tbt
  WHERE tb.objid     = tbt.benefit_trans2benefit
  AND tbt.objid      = in_settlement_trans_id
  AND tbt.trans_type = 'SETTLEMENT' --Modified for 2269
  --AND tb.status     <> 'EXPIRED'
  AND account_status <> 'EXPIRED'--Modified for 2269
  )
  loop
    IF trec_benefit.expiry_date <= SYSDATE THEN
      UPDATE x_reward_benefit
      SET status = 'UNAVAILABLE' --Modified for 2269
        , expiry_date = SYSDATE
		, account_status = 'EXPIRED'  --Modified for 2269
      WHERE objid     = trec_benefit.benefit_objid;
      l_err_code    := -363;
      l_err_msg     := 'Benefit is Expired';
      raise refund_input_failed;
    elsif trec_benefit.status <> 'AVAILABLE' THEN
      l_err_code    := -366;
      l_err_msg     := 'Invalid Benefit status';
      raise refund_input_failed;
    ELSE
    --generate new transaction id
    l_new_refund_trans_id  := f_get_transaction_id ;
    out_transaction_id     := l_new_refund_trans_id;
    --Create a new benefit transaction
    p_create_benefit_trans (
      i_event_type        => 'REFUND',
		  i_transaction_id    => l_new_refund_trans_id,
		  i_trans_date        => in_trans_date,
		  i_WEB_account_id    => trec_benefit.web_account_id,
		  i_subscriber_id     => trec_benefit.subscriber_id,
		  i_min               => trec_benefit.MIN,
		  i_esn               => trec_benefit.esn,
		  i_old_min           => trec_benefit.old_min,
		  i_old_esn           => trec_benefit.old_esn,
		  i_trans_type        => 'REFUND', --Modified for 2269
		  i_trans_desc        => 'Refund of AT Card',--in_trans_desc, --Modified for 2269
		  i_amount            => abs(trec_benefit.amount), --Modified for 2269
		  i_benefit_type_CODE => trec_benefit.benefit_type_code,
		  i_action            => 'ADD',
		  i_action_type       => 'REFUND',
		  i_action_reason     => 'Refund of AT Card', --Modified for 2269
		  i_btrans2btrans     => trec_benefit.authtrans_objid,
		  i_svc_plan_pin      => trec_benefit.svc_plan_pin,
		  i_svc_plan_id       => trec_benefit.svc_plan_id,
		  i_brand             => trec_benefit.brand,
		  i_btrans2benefit    => trec_benefit.benefit_objid,
      o_transaction_status  => l_transaction_status          -- CR41473 08/04/2016 PMistry Added new output parameter with LRP phase 2
      );
    --mark the benefits as Refund
      rewards_mgt_util_pkg.p_update_benefit(  in_cust_key => 'OBJID',
                                              in_cust_value => trec_benefit.benefit_objid,
                                              in_program_name => NULL,
                                              in_benefit_type => NULL,
                                              in_brand => NULL,
                                              in_new_min => NULL,
                                              in_new_esn => NULL,
                                              in_new_status => 'AVAILABLE',
                                              in_new_notes => NULL,
                                              in_new_expiry_date => NULL,
                                              in_change_quantity => (CASE trec_benefit.benefit_type_code
                                                                        WHEN 'LOYALTY_POINTS'   THEN abs(trec_benefit.amount)
                                                                        WHEN 'UPGRADE_POINTS'   THEN trec_benefit.amount
                                                                        WHEN 'UPGRADE_BENEFITS' THEN 0
                                                                        ELSE 0
                                                                      END),                  -- CR41473 - LRP2
                                              in_transaction_status => l_transaction_status, -- CR41473 - LRP2
                                              in_value              => (CASE trec_benefit.benefit_type_code
                                                                          WHEN 'UPGRADE_BENEFITS' THEN trec_benefit.amount
                                                                          ELSE 0
                                                                        END),                 -- CR41473 - LRP2
                                              in_account_status => 'ENROLLED' --Modified for 2269
                                            );
    /*
    UPDATE  x_reward_benefit
    SET     status        = 'AVAILABLE'  ,
            account_status ='ENROLLED', --Modified for 2269
            quantity              = CASE benefit_type_code
                                      WHEN 'LOYALTY_POINTS'   THEN quantity + abs(trec_benefit.amount)
                                      WHEN 'UPGRADE_POINTS'   THEN quantity + trec_benefit.amount
                                      WHEN 'UPGRADE_BENEFITS' THEN quantity
                                      ELSE quantity
                                    END ,
            VALUE         = CASE  benefit_type_code
                            WHEN  'UPGRADE_BENEFITS'  THEN  VALUE  + trec_benefit.amount
                            ELSE  VALUE
                            END ,
            update_date   = SYSDATE
    WHERE   objid         = trec_benefit.benefit_objid;
    */
    --
  END IF;
  --
  END loop;
  COMMIT;
  --OUT_TRANSACTION_ID :=  f_get_transaction_id;
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
exception
-- CR42235 Changes Starts
WHEN DUP_VAL_ON_INDEX THEN
  out_err_code := -99;
  out_err_msg  := 'p_compensate_reward_points ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
-- CR42235 Changes Ends

WHEN refund_input_failed THEN
  out_err_code       := l_err_code;
  out_err_msg        := l_err_msg;
  out_transaction_id := NULL;
  --ROLLBACK;
  --Modified for CR41118
  --sa.ota_util_pkg.err_log ( p_action => 'Validation Failed', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_refund_benefit_payment', p_error_text => 'input params: ' || 'IN_SETTLEMENT_TRANS_ID ='||in_settlement_trans_id  || ', IN_ORDER_ID='|| in_order_id || ', IN_TRANS_DATE=' || in_trans_date || ', IN_TRANS_DESC=' || in_trans_desc || ', out_trans_id= ' || l_new_refund_trans_id || ', out_error_code='||out_err_code || ', out_error_msg='|| out_err_msg );
WHEN others THEN
  ROLLBACK;
  out_err_code := -99;
  out_err_msg  := 'P_REFUND_BENEFIT_PAYMENT='||substr(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace ;
  sa.ota_util_pkg.err_log ( p_action => 'OTHERS EXCEPTION', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_refund_benefit_payment', p_error_text => 'input params: ' || 'IN_SETTLEMENT_TRANS_ID ='||in_settlement_trans_id  || ', IN_ORDER_ID='|| in_order_id || ', IN_TRANS_DATE=' || in_trans_date || ', IN_TRANS_DESC=' || in_trans_desc || ', out_trans_id= ' || l_new_refund_trans_id || ', out_error_code='||out_err_code || ', out_error_msg='|| out_err_msg );
END p_refund_benefit_payment;
--
-- Procedure to update pin in rewards_benefit_transaction table  for the transaction type and transaction id
--
PROCEDURE p_update_pin(
    in_transaction_id      IN   VARCHAR2, -- settlement auth ID
    in_transaction_type    IN   VARCHAR2, -- Transaction type
    in_pin                 IN   VARCHAR2, -- Pin# purchased through Loyalty points
    out_err_code           OUT  VARCHAR2,
    out_err_msg            OUT  VARCHAR2 )
IS
  l_service_plan_id         NUMBER;
  l_esn						VARCHAR2(200);
  l_plan_desc 				VARCHAR2(100);
  l_rewards_btrans_objid    x_reward_benefit_transaction.objid%TYPE;
  rcg    sa.customer_type  := customer_type ();
  cst    sa.customer_type;
BEGIN
  --
  cst := rcg.retrieve_pin ( i_red_card_code => in_pin );
  --
  IF TRIM(in_transaction_id) IS NULL THEN
    out_err_code       := 400;
    out_err_msg        := 'Error. Invalid or Null value received for Input transaction ID';
    RETURN;
  --ELSIF in_transaction_type    IS NULL THEN
  --  out_err_code       := 401;
  --  out_err_msg        := 'Error. Invalid or Null value received for Input in_transaction_type';
  --  RETURN;
  ELSIF in_pin  IS NULL THEN
    out_err_code       := 402;
    out_err_msg        := 'Error. Invalid or Null value received for Input in_pin';
    RETURN;
  END IF;
  --
  BEGIN
    SELECT /*+ INDEX(xt IDX_TRANS_OBJID) */ rbt.objid, rbt.esn
    INTO  l_rewards_btrans_objid, l_esn
    FROM  X_Biz_Purch_Hdr               ph,
          x_reward_benefit_transaction  rbt,
          X_Biz_Purch_Dtl               Pd,
          x_payment                     XP,
          X_TRANSACTION                 xt
    WHERE ph.X_AUTH_REQUEST_ID       =  in_transaction_id --'d605bf84-63eb-4e0c-ad9b-1ae1d144d2af'
    AND   Ph.X_AUTH_REQUEST_ID       =  XP.X_TRANS_ID
    AND   XP.OBJID                   =  xt.X_TRANS2PAYMENT
    AND   xt.x_transaction_id        =  Rbt.OBJID
    AND   Rbt.esn                    =  Ph.x_esn
    AND   rbt.ACTION_TYPE            in ('SETTLEMENT','CHARGE')--in_transaction_type -- 'SETTLEMENT'
    AND   Ph.Objid                   =  Pd.Biz_Purch_Dtl2biz_Purch_Hdr;
  EXCEPTION
    WHEN OTHERS THEN
      out_err_code    :=  410;
      out_err_msg     :=  'Invalid transaction ID/ transaction_type / PIN';
      RETURN;
  END;
  --Modified for Defect 472
  begin
  SELECT sa.get_service_plan_id(l_esn,in_pin)
  INTO   l_service_plan_id
  FROM 	DUAL;
  exception when others then
  null;
  end;

   BEGIN
    IF cst.part_class_name='STILDCARD' THEN
      SELECT substr(': $[' || vas_price || '] - [' || vas_description_english || ']', 1, 100)
        INTO l_plan_desc
        FROM vas_programs_view
        WHERE vas_bus_org='STRAIGHT_TALK'
        AND product_id='ST_ILD_10'
        AND vas_card_class= cst.part_class_name;

	BEGIN
            SELECT vas_service_id
            INTO cst.service_plan_objid
            FROM vas_programs_view
            WHERE vas_bus_org = 'STRAIGHT_TALK'
            AND product_id    = 'ST_ILD_10';
        EXCEPTION
        WHEN OTHERS THEN
           NULL;
         END ;

    ELSE
      SELECT substr(': $[' || customer_price || '] - [' || webcsr_display_name ||']', 1, 100)
      INTO l_plan_desc
      FROM x_service_plan
      WHERE objid =   l_service_plan_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      l_plan_desc:=NULL;
  END;

  /*begin
  select substr(': $[' || customer_price || '] - [' || WEBCSR_DISPLAY_NAME ||']', 1, 100)
  into l_plan_desc
  from x_service_plan
  where objid =   l_service_plan_id;
  exception when others then
  l_plan_desc:=null;
  end;*/
  UPDATE  x_reward_benefit_transaction
  SET     SVC_PLAN_PIN    =   in_pin,
          SVC_PLAN_ID     =   nvl(cst.service_plan_objid,l_service_plan_id),
		  trans_desc      =   substr(trans_desc || l_plan_desc, 1, 100),
		  action_reason   =   substr(action_reason || l_plan_desc, 1, 100)
  WHERE   objid           =   l_rewards_btrans_objid;
  --Modified for Defect 472
  out_err_code    :=  0;
  out_err_msg     :=  'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
    out_err_code := -99;
    out_err_msg  := 'p_update_pin='||substr(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace ;
END p_update_pin;
--
END rewards_mgt_pymt_pkg;
/