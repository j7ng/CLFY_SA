CREATE OR REPLACE PACKAGE BODY sa.REWARDS_MGT_API_PKG AS
 --$RCSfile: REWARDS_MGT_API_PKG.SQL,v $
 --$
 --$ Revision 1.58  2017/09/15 16:07:21  Sinturi
 --$ CR53454 - Modified query in f_get_benefits_history function to utilize the less db resources.
 --$
 --$Revision: 1.62 $
 --$Author: abustos $
 --$Date: 2017/11/28 16:33:57 $
 --$ $Log: REWARDS_MGT_API_PKG.SQL,v $
 --$ Revision 1.62  2017/11/28 16:33:57  abustos
 --$ C88132 Use pin to determine Service Plan as AddOns will not change base plan
 --$
 --$ Revision 1.60  2017/11/08 16:09:00  mshah
 --$ Fix for defect - 32603
 --$ TAS : LRP transaction history showing wrong records
 --$
 --$ Merged with CR54413
 --$
 --$ Revision 1.59  2017/10/05 20:50:20  abustos
 --$ CR49726 - LRP Redesign modify p_get_reward_benefits to return redeemed_pts for an account
 --$
 --$ Revision 1.58  2017/09/15 20:29:25  sinturi
 --$ CR53454 - Modified the query in f_get_benefits_history function for performance issue.
 --$
 --$ Revision 1.57  2017/07/26 14:09:50  hcampano
 --$ CR52543 Straight Talks Rewards Program enrollment is failing in TAS - Part of REL900 - Scheduled for 8/22/17 - SITB
 --$
 --$ Revision 1.56  2017/07/21 15:00:33  hcampano
 --$ CR PENDING - Fixing production issue on p_get_reward_benefits that generates an sql error while trying to assign an empty value.
 --$
 --$ Revision 1.55  2017/06/20 20:39:30  tbaney
 --$ Added logic to convert to to_char after deployment.
 --$
 --$ Revision 1.54  2017/06/13 19:03:23  tbaney
 --$ Logic change.
 --$
 --$ Revision 1.53  2017/06/13 14:45:07  tbaney
 --$ CR49699 Added logic to block corp cards.
 --$
 --$ Revision 1.52  2016/12/21 22:49:52  vmallela
 --$ CR45015
 --$
 --$ Revision 1.51  2016/12/13 21:35:25  skota
 --$ Added new procedure for earn points
 --$
 --$ Revision 1.50  2016/11/10 17:05:51  abustos
 --$ CR44460 - Merge with production
 --$
 --$ Revision 1.49  2016/09/20 20:56:00  pamistry
 --$ CR41473 - LRP2 Modified f_get_benefits_history function to return appropriate transaction status based on Defect # 15900
 --$
 --$ Revision 1.48  2016/09/20 17:43:08  pamistry
 --$ CR41473 - LRP2 Modified f_get_benefits_history function to return appropriate transaction status based on Defect # 15900
 --$
 --$ Revision 1.47  2016/09/20 14:38:27  pamistry
 --$ Modify the f_get_benefits_history function to return correct catalog provider for Deduct / charge transaction
 --$
 --$ Revision 1.46  2016/09/16 12:49:58  sethiraj
 --$ CR41473-LRP2-Added Modification History Template
 --$
 --$ Revision 1.45  2016/09/12 17:37:21  pamistry
 --$ CR41473 - Modify the f_get_benefits_history function to add Transaction_type in result set
 --$

--------------------------------------------------------------------------------------------
-- Author: snulu (Sujatha Nulu)
-- Date: 2015/10/01
-- <CR# 33098>
-- Loyalty Rewards Program is to build a capability to give rewards for certain customer Actions
-- and increase the Life Time value of the customer.
-- This program is precisely targeting the customers who fall under the umbrella of Straight Talk.
--------------------------------------------------------------------------------------------
 PROCEDURE P_GET_REWARD_BENEFITS (
             in_key                     IN VARCHAR2
            ,in_value                   IN VARCHAR2
            ,in_program_name            IN VARCHAR2
            ,in_benefit_type_CODE       IN VARCHAR2
            ,out_reward_benefits_list   OUT sa.reward_benefits_table
            ,out_err_code               OUT NUMBER
            ,out_err_msg                OUT VARCHAR2
  ) AS

    --lv_rec    typ_reward_benefits_obj;
    lv_tab_benefit_tab            reward_benefits_table ;
    allow_purch                   purch_usage_allow;
    i                             NUMBER;
    get_benefit_validation_failed EXCEPTION;
    l_web_account_id              table_web_user.objid%TYPE;
--
CURSOR cur_rew_benf (c_web_account_id IN NUMBER)
IS
SELECT  txb.objid,
        txb.benefit_type_CODE,
        txb.program_name,
        txbp.benefit_unit,
        txb.quantity,
        txb.pending_quantity,         -- CR41473 - LRP2 - sethiraj
        txb.total_quantity,           -- CR41473 - LRP2 - sethiraj
        txb.VALUE,
        txbp.partial_usage_allowed,
        txbp.min_threshold_value,
        txpe.enroll_date,
        txb.created_date,
        txb.account_status,
        txb.expiry_date,
        txb.expired_quantity,         -- CR41473 - LRP2 - sethiraj
        txpe.enrollment_type,
        txb.loyalty_tier              -- CR41473 - LRP2 - sethiraj
FROM x_reward_benefit txb,
     X_REWARD_BENEFIT_PROGRAM txbp,
     x_reward_program_enrollment txpe
WHERE /*decode(in_key,'ACCOUNT',txb.WEB_account_id,
--                    'EMAILID',txb.WEB_account_id) = to_char(c_web_account_id)
                    'EMAILID',txb.WEB_account_id) = to_char(c_web_account_id)*/
      txb.WEB_account_id      = to_char(c_web_account_id) -- CR44460 commented above decode
  AND txb.program_name        = in_program_name
  AND txb.benefit_type_CODE   = in_benefit_type_CODE
  --
  AND txb.benefit_owner       = txbp.benefit_owner
  AND txb.program_name        = txbp.program_name
  AND txb.benefit_type_CODE   = txbp.benefit_type_CODE
  AND txb.brand               = txbp.brand
  --
  AND txbp.brand              = txpe.brand
  AND txbp.program_name       = txpe.program_name
  AND txbp.benefit_type_CODE  = txpe.benefit_type_CODE
  AND txb.WEB_account_id      = txpe.WEB_account_id
  AND txpe.ENROLLMENT_TYPE    = 'PROGRAM_ENROLLMENT' -- CR44460 added
  AND(txb.expiry_date IS NULL OR txb.expiry_date > SYSDATE) ;
  --
 CURSOR cur_ben_usg(ben_typ VARCHAR2) IS
 SELECT  xbu.benefit_usage,
         xbu.start_date,
         xbu.end_date
 FROM x_reward_benefit_usage xbu
 WHERE  xbu.benefit_type_CODE = ben_typ ;

 l_redeemed_pts NUMBER := 0; -- CR49726 - LRP Redesign

  BEGIN

    out_err_code      := 0;
    out_err_msg       := 'SUCCESS';
    out_reward_benefits_list  := reward_benefits_table(NULL);
    --
    IF upper(nvl(trim(in_key),'XX')) = 'XX'  OR trim(in_value) IS NULL  OR UPPER(trim(IN_VALUE))= 'NULL'  THEN
      out_err_code      := -311;
      out_err_msg       := 'Error. Unsupported or Null values received for IN_KEY and IN_VALUE';
      raise get_benefit_validation_failed;
    END IF;
    IF  upper(nvl(trim(in_program_name),'~')) <> 'LOYALTY_PROGRAM' THEN

      out_err_code      := -312;
      out_err_msg       := 'Error. Unsupported or Null values received for IN_PROGRAM_NAME';
      raise get_benefit_validation_failed;
    END IF;
    IF  upper(nvl(trim(in_benefit_type_CODE),'~'))  <> 'LOYALTY_POINTS' THEN

      out_err_code      := -313;
      out_err_msg       := 'Error. Unsupported or Null values received for IN_BENEFIT_TYPE_CODE';
      raise get_benefit_validation_failed;

    END IF;
    --
    lv_tab_benefit_tab := reward_benefits_table();
    --
    IF in_key  = 'EMAILID'
    THEN
      BEGIN
        SELECT  wu.objid
        INTO    l_web_account_id
        FROM    table_web_user  wu,
                table_bus_org   bo
        WHERE   wu.WEB_USER2BUS_ORG = bo.objid
        AND     bo.ORG_ID           = 'STRAIGHT_TALK'
        AND     ( wu.login_name   = in_value OR
                  wu.s_login_name = UPPER(in_value) );
      EXCEPTION
        WHEN OTHERS THEN
          l_web_account_id  :=  NULL;
      END;
      --
    ELSE
      l_web_account_id  :=  in_value;
    END IF;
    --
    -- CR49726 Get the Redeemed pts for the account
    BEGIN--{
      SELECT ABS(SUM(amount)) redeemed_amount
        INTO l_redeemed_pts
      FROM   x_reward_benefit_transaction xrbt
      WHERE  web_account_id = to_char(l_web_account_id)
        AND  amount < 0;
    END; --}

     FOR icur IN cur_rew_benf (l_web_account_id)
     loop
      allow_purch := purch_usage_allow();

       FOR iusg IN cur_ben_usg(icur.benefit_type_CODE) loop
        allow_purch.EXTEND(1);
        allow_purch(allow_purch.count) := (purch_usage_allow_rec(iusg.benefit_usage,iusg.start_date,iusg.end_date));

        END loop;
        lv_tab_benefit_tab.extend(1);
        lv_tab_benefit_tab(lv_tab_benefit_tab.count) := TYP_REWARD_BENEFITS_OBJ(
                                      icur.objid,                           -- BENEFIT_ID
                                      icur.benefit_type_CODE,               -- BENEFIT_TYPE_CODE
                                      icur.program_name,                    -- BENEFIT_PROGRAM_NAME
                                      icur.benefit_unit,                    -- BENEFIT_UNIT
                                      icur.quantity,                        -- BENEFIT_QUANTITY
                                      icur.pending_quantity,                -- PENDING_QUANTITY         -- CR41473 - LRP2 - sethiraj
                                      icur.total_quantity,                  -- TOTAL_QUANTITY           -- CR41473 - LRP2 - sethiraj
                                      icur.VALUE,                           -- BENEFIT_VALUE
                                      icur.partial_usage_allowed,           -- PARTIAL_USAGE_ALLOWED
                                      allow_purch,                          -- PURCH_USAGE_ALLOWED
                                      icur.min_threshold_value,             -- MIN_THRESHOLD
                                      icur.enroll_date,                     -- ENROLLMENT_DATE
                                      icur.created_date,                    -- CREATED_DATE
                                      icur.account_status,                  -- ACCOUNT_STATUS
                                      icur.program_name,                    -- PROGRAM_NAME
                                      icur.expiry_date,                     -- EXPIRY_DATE
                                      icur.expired_quantity,                -- EXPIRED_QUANTITY         -- CR41473 - LRP2 - sethiraj
                                      icur.enrollment_type,                 -- ENROLLMENT_TYPE
                                      icur.loyalty_tier,                    -- LOYALTY_TIER             -- CR41473 - LRP2 - sethiraj
                                      NVL(l_redeemed_pts,0)                 -- REDEEMED_QUANTITY        -- CR49726 - LRP Redesign
                                      );

      END loop;

      if lv_tab_benefit_tab.count > 0 then
        out_reward_benefits_list := lv_tab_benefit_tab ;
      else
        out_err_msg := null;
        for i in (
                  select count(*) cnt,'x_reward_program_enrollment' table_name
                  from x_reward_program_enrollment
                  where web_account_id = l_web_account_id
                  union
                  select count(*),'x_reward_benefit' table_name
                  from x_reward_benefit
                  where web_account_id = l_web_account_id
                  order by table_name
                  )
        loop
          if i.cnt = 0 then
            out_err_code      := 401;
            out_err_msg       := out_err_msg||i.table_name||',';
          end if;
        end loop;
      end if;

      if out_err_code = '401' then
        dbms_output.put_line('INFO MISSING IN TABLE/S ('||out_err_msg||') - CHECK FOR CUSTOMER REDEMPTIONS');
        out_err_msg := 'No benefits available for input ' || in_key|| ' [' || in_value || ']' ;
      else
        out_err_code      := 0;
        out_err_msg       := 'SUCCESS';
      end if;

  exception
    WHEN get_benefit_validation_failed THEN

     out_err_msg:='Error_code: '||out_err_code||' Error_msg: '||out_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;
--Modified for CR41118
   /* ota_util_pkg.err_log (p_action      => 'CALLING REWARDS_MGT_API_PKG.P_GET_REWARD_BENEFITS',
                         p_error_date     => SYSDATE,
                         p_key            => in_key,
                         p_program_name   => 'REWARDS_MGT_API_PKG.P_GET_REWARD_BENEFITS',
                         p_error_text     => out_err_msg);
*/
    WHEN others THEN
      out_err_code      := -99;
      out_err_msg       :='Error_code: '||out_err_code||' Error_msg: '||sqlerrm ||' - '||dbms_utility.format_error_backtrace;



      ota_util_pkg.err_log (p_action      => 'CALLING REWARDS_MGT_API_PKG.P_GET_REWARD_BENEFITS',
                         p_error_date     => SYSDATE,
                         p_key            => in_key,
                         p_program_name   => 'REWARDS_MGT_API_PKG.P_GET_REWARD_BENEFITS',
                         p_error_text     => out_err_msg);


  END P_GET_REWARD_BENEFITS;

  PROCEDURE p_get_reward_points(
            in_event_type         IN VARCHAR2 ,
            in_program_name       IN VARCHAR2 ,
            in_benefit_type_code  IN VARCHAR2 ,
            in_brand              IN VARCHAR2 ,
            in_service_plan_id    IN VARCHAR2 ,
            in_trans_type         IN VARCHAR2 ,
            out_points            OUT NUMBER ,
            out_err_code          OUT NUMBER ,
            out_err_msg           OUT VARCHAR2 )
  AS

    input_validation_failed EXCEPTION;

    CURSOR cur_sp_to_program_pts
    IS
      SELECT srp.reward_point reward_point
      FROM sa.mtm_sp_reward_program srp,
        x_reward_benefit_program rbp
      WHERE 1                      = 1
      AND srp.service_plan_objid   = in_service_plan_id
      AND srp.reward_program_objid = rbp.objid
      AND SYSDATE BETWEEN srp.start_date AND srp.end_date
      AND rbp.program_name      = in_program_name
      AND rbp.benefit_type_code = in_benefit_type_code
      AND rbp.brand             = in_brand
      AND SYSDATE BETWEEN rbp.start_date AND rbp.end_date;
    --
    rec_sp_to_program_pts cur_sp_to_program_pts%rowtype;
    --
    CURSOR cur_benefit_earning_pts
    IS
      SELECT benefits_earned reward_point
      FROM x_reward_benefit_earning rbe,
        x_reward_benefit_program rbp
      WHERE 1                   = 1
      AND rbe.program_name      = rbp.program_name
      AND rbe.benefit_type_code = rbp.benefit_type_code
      AND rbe.transaction_type  = in_trans_type
      AND SYSDATE BETWEEN rbe.start_date AND rbe.end_date
      AND rbp.program_name      = in_program_name
      AND rbp.benefit_type_code = in_benefit_type_code
      AND rbp.brand             = in_brand
      AND SYSDATE BETWEEN rbp.start_date AND rbp.end_date;
    --
    rec_benefit_earning_pts cur_benefit_earning_pts%rowtype;
    --
  BEGIN
    out_err_code := 0;
    out_err_msg  := 'SUCCESS';

    IF upper(NVL(trim(in_event_type),'~')) NOT IN ('ACTIVATION', 'REDEMPTION', 'ENROLLMENT', 'ANNIVERSARY_6', 'ANNIVERSARY_12') THEN
      out_err_code                          := -10;
      out_err_msg                           := 'IN PARAMETER is not passed correctly';
      raise input_validation_failed;
    END IF;
    IF upper(NVL(trim(in_program_name),'~')) <> 'LOYALTY_PROGRAM' THEN
      out_err_code                           := -10;
      out_err_msg                            := 'IN PARAMETER is not passed correctly';
      raise input_validation_failed;
    END IF;
    IF upper(NVL(trim(in_benefit_type_code),'~')) <> 'LOYALTY_POINTS' THEN
      out_err_code                                := -313;
      out_err_msg                                 := 'IN PARAMETER is not passed correctly';
      raise input_validation_failed;
    END IF;
    IF upper(NVL(trim(in_brand),'~')) NOT IN ( 'STRAIGHT_TALK') THEN
      out_err_code :=                      -10;
      out_err_msg  := 'IN PARAMETER is not passed correctly';
      raise input_validation_failed;
    END IF;

    IF upper(NVL(trim(in_event_type),'~')) IN ('ACTIVATION', 'REDEMPTION') THEN

      IF trim(in_service_plan_id) IS NULL THEN
        out_err_code              := -10;
        out_err_msg               := 'IN PARAMETER is not passed correctly';
        raise input_validation_failed;
      ELSE
        --POPULATE THE REWARD POINTS
        OPEN cur_sp_to_program_pts;
        FETCH cur_sp_to_program_pts INTO rec_sp_to_program_pts;

        IF cur_sp_to_program_pts%found THEN
          out_points := rec_sp_to_program_pts.reward_point;
        ELSE
          out_points := NULL;
        END IF;
        CLOSE cur_sp_to_program_pts;

      END IF;

    elsif upper(NVL(trim(in_event_type),'~')) IN ('ENROLLMENT', 'ANNIVERSARY_6', 'ANNIVERSARY_12') THEN

      IF trim(in_trans_type) IS NULL THEN
        out_err_code         := -10;
        out_err_msg          := 'IN PARAMETER is not passed correctly';
        raise input_validation_failed;
      ELSE
        --POPULATE THE REWARD POINTS
        OPEN cur_benefit_earning_pts;
        FETCH cur_benefit_earning_pts INTO rec_benefit_earning_pts;

        IF cur_benefit_earning_pts%found THEN
          out_points := rec_benefit_earning_pts.reward_point;
        ELSE
          out_points := NULL;
        END IF;
        CLOSE cur_benefit_earning_pts;

      END IF;

    END IF;

  EXCEPTION
  WHEN input_validation_failed THEN
    out_err_msg:='Error_code: '||out_err_code||' Error_msg: '||out_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;
--Modified for CR41118
  --  ota_util_pkg.err_log (p_action => 'CALLING REWARDS_MGT_API_PKG.P_GET_REWARD_POINTS', p_error_date => SYSDATE, p_key => in_event_type, p_program_name => 'REWARDS_MGT_API_PKG.P_GET_REWARD_POINTS', p_error_text => out_err_msg);
  WHEN OTHERS THEN
    out_err_code := -99;
    out_err_msg  :='Error_code: '||out_err_code||' Error_msg: '||sqlerrm ||' - '||dbms_utility.format_error_backtrace;
    ota_util_pkg.err_log (p_action => 'CALLING REWARDS_MGT_API_PKG.P_GET_REWARD_POINTS', p_error_date => SYSDATE, p_key => in_event_type, p_program_name => 'REWARDS_MGT_API_PKG.P_GET_REWARD_POINTS', p_error_text => out_err_msg);

  END p_get_reward_points;



 PROCEDURE p_get_reward_benefit_trans (in_esn IN VARCHAR2,
      in_web_account_id IN VARCHAR2,
      in_svc_plan_pin IN NUMBER,
      in_brand IN VARCHAR2,
      in_benefit_type_code IN  VARCHAR2,
      in_trans_type IN VARCHAR2,
      in_program_name IN VARCHAR2,
      out_trans_detail out typ_lrp_redem_trans,
      out_err_code               out NUMBER,
      out_err_msg                out VARCHAR2
)
IS
l_exist VARCHAR2(10);

CURSOR cur_trans(c_account VARCHAR2,c_svc_pin VARCHAR2,c_brand VARCHAR2,c_benf_type VARCHAR2,c_trans_type VARCHAR2,c_esn VARCHAR2)
IS
SELECT *
FROM x_reward_benefit_transaction
WHERE web_account_id =c_account
AND esn=c_esn
AND svc_plan_pin = c_svc_pin
AND brand = c_brand
AND benefit_type_code= c_benf_type
AND trans_type= c_trans_type;

lv_red_trans typ_lrp_redem_trans;

benefit_validation_failed   exception;
BEGIN

lv_red_trans := typ_lrp_redem_trans ();

IF upper(trim(in_esn))IS NULL THEN
out_err_code:= -400;
out_err_msg := 'Error. Unsupported or Null values received for ESN';
raise   benefit_validation_failed;
END IF;

IF upper(trim(in_web_account_id))IS NULL THEN
out_err_code:= -401;
out_err_msg := 'Error. Unsupported or Null values received for Web Account Id';

raise  benefit_validation_failed;
END IF;

IF upper(trim(in_svc_plan_pin))IS NULL THEN

out_err_code:= -360;
out_err_msg := ' Error. Unsupported or Null values received for Service Plan Pin';

raise  benefit_validation_failed;
END IF;

IF upper(trim(in_brand)) IS NULL OR upper(trim(in_brand)) NOT IN ( 'STRAIGHT_TALK','ST') THEN
out_err_code:= -352;
out_err_msg := 'Error. Unsupported or Null values received for Brand';

raise  benefit_validation_failed;
END IF;

IF upper(trim(in_benefit_type_code))IS NULL  OR upper(trim(in_benefit_type_code)) <> 'LOYALTY_POINTS' THEN
out_err_code:= -313;
out_err_msg := 'Error. Unsupported or Null values received for Benefit type';

raise  benefit_validation_failed;
END IF;

IF upper(trim(in_trans_type)) IS NULL THEN
out_err_code:= -402;
out_err_msg := 'Error. Unsupported or Null values received for Trans type';

raise  benefit_validation_failed;
END IF;
IF upper(trim(in_program_name)) IS NULL OR  upper(trim(in_program_name)) <>'LOYALTY_PROGRAM' THEN
out_err_code:= -312;
out_err_msg := 'Error. Unsupported or Null values received for Program name';

raise  benefit_validation_failed;
END IF;

BEGIN
 SELECT 'Y'
 INTO l_exist
 FROM x_reward_program_enrollment
 WHERE web_account_id=in_web_account_id
 AND enrollment_flag <> 'N';

exception
WHEN others THEN
  l_exist :='N';
END;

  IF l_exist ='Y' THEN

   FOR rec_cur_trans IN cur_trans(upper(trim(in_web_account_id)),upper(trim(in_svc_plan_pin)),upper(trim(in_brand)),upper(trim(in_benefit_type_code)),upper(trim(in_trans_type)),upper(trim(in_esn)))
   loop

   lv_red_trans.EXTEND(1);

   lv_red_trans(lv_red_trans.count) := typ_lrp_redem_trans_obj(rec_cur_trans.objid                  ,
                                                                rec_cur_trans.trans_date             ,
                                                                rec_cur_trans.web_account_id         ,
                                                                rec_cur_trans.subscriber_id          ,
                                                                rec_cur_trans.MIN                    ,
                                                                rec_cur_trans.esn                    ,
                                                                rec_cur_trans.old_min                ,
                                                                rec_cur_trans.old_esn                ,
                                                                rec_cur_trans.trans_type             ,
                                                                rec_cur_trans.trans_desc             ,
                                                                rec_cur_trans.amount                 ,
                                                                rec_cur_trans.benefit_type_code      ,
                                                                rec_cur_trans.action                 ,
                                                                rec_cur_trans.action_type            ,
                                                                rec_cur_trans.action_reason          ,
                                                                rec_cur_trans.benefit_trans2benefit_trans ,
                                                                rec_cur_trans.svc_plan_pin           ,
                                                                rec_cur_trans.svc_plan_id            ,
                                                                rec_cur_trans.brand                  ,
                                                                rec_cur_trans.benefit_trans2benefit  ,
                                                                rec_cur_trans.transaction_status     , -- CR41473 - LRP2 - sethiraj - Added new column
                                                                rec_cur_trans.maturity_date          , -- CR41473 - LRP2 - sethiraj - Added new column
                                                                rec_cur_trans.expiration_date        , -- CR41473 - LRP2 - sethiraj - Added new column
                                                                rec_cur_trans.source                 , -- CR41473 - LRP2 - sethiraj - Added new column
                                                                rec_cur_trans.source_trans_id          -- CR41473 - LRP2 - sethiraj - Added new column
                                                              );
   END loop;
  END IF;
  out_trans_detail := lv_red_trans ;

    IF lv_red_trans.count = 0 THEN
      out_err_code      := 401;
      out_err_msg       := 'No transactions asscoiated with provided inputs ' || in_web_account_id ;
    ELSE

      out_err_code      := 0;
      out_err_msg       := 'SUCCESS';
    END IF;

  EXCEPTION
    WHEN benefit_validation_failed THEN
     out_err_msg:='Error_code: '||out_err_code||' Error_msg: '||out_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;
--Modified for CR41118
   /*  ota_util_pkg.err_log (p_action      => 'CALLING REWARDS_MGT_API_PKG.P_GET_REWARD_BENEFIT_TRANS',
                         p_error_date     => SYSDATE,
                         p_key            => in_web_account_id,
                         p_program_name   => 'REWARDS_MGT_API_PKG.P_GET_REWARD_BENEFIT_TRANS',
                         p_error_text     => out_err_msg);
*/
    WHEN others THEN
      out_err_code      := -99;
      out_err_msg       :='Error_code: '||out_err_code||' Error_msg: '||sqlerrm ||' - '||dbms_utility.format_error_backtrace;
      --
      ota_util_pkg.err_log (p_action      => 'CALLING REWARDS_MGT_API_PKG.P_GET_REWARD_BENEFIT_TRANS',
                         p_error_date     => SYSDATE,
                         p_key            => in_web_account_id,
                         p_program_name   => 'REWARDS_MGT_API_PKG.P_GET_REWARD_BENEFIT_TRANS',
                         p_error_text     => out_err_msg);
--
END p_get_reward_benefit_trans;
--
FUNCTION f_get_benefits_history(
                                in_key   IN VARCHAR2,
                                in_value IN VARCHAR2,
                                in_benefit_type_code  IN VARCHAR2
                               )
      RETURN tab_benefits_hist PIPELINED
    IS
    --
    rec_benefits_hist               typ_rec_benefits_hist;
    l_error_code                    NUMBER(5);
    l_error_msg                     VARCHAR2(500);
    benefit_hist_validation_failed  EXCEPTION;
    --
    CURSOR cur_benefits_hist (in_val IN VARCHAR2)
      IS
   SELECT xb.objid ,
			xt.trans_date,
			xt.MIN ,
			xt.esn ,
			xt.web_account_id,
			xt.action,
			xbp.benefit_value,
			xt.amount,
			xt.trans_desc,
			xt.action_reason,
			xt.action_notes,
			(case when xt.action = 'DEDUCT' and  xt.transaction_status = 'COMPLETE' then
				  'N/A'
				when xt.transaction_status = 'COMPLETE' then
					'AVAILABLE'
				else
					xt.transaction_status
			end) transaction_status	, 			              -- CR41473 - LRP2 - sethiraj - Added new column
			xt.maturity_date,      				                  -- CR41473 - LRP2 - sethiraj - Added new column
			xt.expiration_date,    				                  -- CR41473 - LRP2 - sethiraj - Added new column
			xt.trans_type,                                  -- CR41473 - LRP2 - PMistry - Added new column
   nvl(rc.catalog_provider, 'TRACFONE') catalog_provider, --Fix for defect - 32603. Release 11-16-2017
			/*CASE
				WHEN xt.trans_type <> 'CHARGE' AND rbe.transaction_type = xt.trans_type THEN
					nvl(rc.catalog_provider, 'TRACFONE')
				WHEN xt.trans_type = 'CHARGE' AND rbe.transaction_description = xt.trans_desc THEN
					nvl(rc.catalog_provider, 'TRACFONE')
			END AS  catalog_provider, -- CR41473 - LRP2 - sethiraj - Added new column and CR53454 - Sinturi - Modified the column condition*/
			cpi.x_esn_nick_name nick_name -- CR53454 - Sinturi - Modified the column condition
        FROM x_reward_benefit_transaction xt
			INNER JOIN x_reward_benefit xb ON xb.web_account_id = xt.web_account_id AND xt.benefit_trans2benefit = xb.objid
			INNER JOIN x_reward_benefit_program xbp ON xb.benefit_owner = xbp.benefit_owner
				   AND xb.program_name = xbp.program_name AND xb.benefit_type_code = xbp.benefit_type_code  AND xb.brand = xbp.brand
			LEFT JOIN x_reward_benefit_earning rbe ON ((rbe.transaction_type = xt.trans_type AND xt.trans_type <> 'CHARGE')
                                              OR
                                              (rbe.transaction_description = xt.trans_desc AND xt.trans_type = 'CHARGE')) --Fix for defect - 32603. Release 11-16-2017
                                              AND rbe.end_date > sysdate
			LEFT JOIN x_mtm_catalog_benefit_earning mtm ON mtm.benefit_earning_objid = rbe.objid
			LEFT JOIN x_reward_catalog rc ON mtm.catalog_objid = rc.objid
			LEFT JOIN table_part_inst pi ON pi.part_serial_no = xt.esn
			LEFT JOIN table_x_contact_part_inst cpi ON pi.objid = cpi.x_contact_part_inst2part_inst
			-- CR53454 - Sinturi - Joined the related tables
        --WHERE decode(in_key,'ACCOUNT',xt.web_account_id) = in_val
        WHERE xt.web_account_id = in_val
			AND xb.benefit_type_code = in_benefit_type_code
			AND xt.action       IN ( 'ADD','DEDUCT','NOTE' )
		ORDER BY 1, 2;
    --
BEGIN
  --
  IF upper(nvl(trim(in_key),'~')) <>  'ACCOUNT'  OR trim(in_value) IS NULL  OR upper(trim(in_value))= 'NULL'  THEN
    l_error_code      := -311;
    l_error_msg       := 'Error. Unsupported or Null values received for IN_KEY and IN_VALUE';
    raise benefit_hist_validation_failed;
  END IF;
  --
  IF  upper(nvl(trim(in_benefit_type_code),'~'))  <> 'LOYALTY_POINTS' THEN
    --
    l_error_code      := -313;
    l_error_msg       := 'Error. Unsupported or Null values received for IN_BENEFIT_TYPE_CODE';
    --
    RAISE benefit_hist_validation_failed;
    --
  END IF;
  --
  FOR irec IN cur_benefits_hist (in_value)
  LOOP
    --
    rec_benefits_hist.objid                  := irec.objid;
    rec_benefits_hist.x_trans_date           := irec.trans_date;
    rec_benefits_hist.x_min                  := irec.MIN;
    rec_benefits_hist.x_esn                  := irec.esn;
    rec_benefits_hist.web_account_id         := irec.web_account_id;
    rec_benefits_hist.x_points_action        := irec.action;
    rec_benefits_hist.x_benefit_value        := irec.benefit_value;
    rec_benefits_hist.points_action_reason   := irec.action_reason;
    rec_benefits_hist.display_action_reason  := irec.trans_desc;
    rec_benefits_hist.amount                 := irec.amount;
    rec_benefits_hist.action_notes           := irec.action_notes;  --action notes added
    rec_benefits_hist.transaction_status     := irec.transaction_status; -- CR41473 - LRP2 - sethiraj - Added new column
    rec_benefits_hist.maturity_date          := irec.maturity_date;      -- CR41473 - LRP2 - sethiraj - Added new column
    rec_benefits_hist.expiration_date        := irec.expiration_date;    -- CR41473 - LRP2 - sethiraj - Added new column
    rec_benefits_hist.catalog_provider		   := irec.catalog_provider;	 -- CR41473 - LRP2 - sethiraj - Added new column
    rec_benefits_hist.transaction_type		   := irec.trans_type;	       -- CR41473 - LRP2 - PMistry - Added new column
    rec_benefits_hist.nick_name              := irec.nick_name;
    --
    PIPE ROW (rec_benefits_hist);
  END LOOP;
  --
EXCEPTION
  --
  WHEN benefit_hist_validation_failed THEN
    --
    l_error_msg:='Error_code: '||l_error_code||' Error_msg: '||l_error_msg || ' - ' ||dbms_utility.format_error_backtrace ;
    --Modified for CR41118
 /*   ota_util_pkg.err_log (p_action      => 'CALLING REWARDS_MGT_API_PKG.F_GET_BENEFITS_HISTORY',
                         p_error_date     => SYSDATE,
                         p_key            => in_value,
                         p_program_name   => 'REWARDS_MGT_API_PKG.F_GET_BENEFITS_HISTORY',
                         p_error_text     => l_error_msg);
  */
  WHEN others THEN
    l_error_code      := -99;
    l_error_msg       :='Error_code: '||l_error_code||' Error_msg: '||sqlerrm ||' - '||dbms_utility.format_error_backtrace;
    --
    ota_util_pkg.err_log (p_action      => 'CALLING REWARDS_MGT_API_PKG.F_GET_BENEFITS_HISTORY',
                       p_error_date     => SYSDATE,
                       p_key            => in_value,
                       p_program_name   => 'REWARDS_MGT_API_PKG.F_GET_BENEFITS_HISTORY',
                       p_error_text     => l_error_msg);
    RETURN;
END f_get_benefits_history;

-- CR41473 - LRP2 - sethiraj - Added procedure which returns reward benefit earnings
FUNCTION f_get_reward_catalog(
          in_catalog_provider  IN x_reward_catalog.catalog_provider%TYPE DEFAULT NULL,
          in_catalog_type      IN x_reward_catalog.catalog_type%TYPE DEFAULT NULL,
          in_benefit_type_code IN x_reward_benefit_earning.benefit_type_code%TYPE DEFAULT NULL,
          in_program_name      IN x_reward_benefit_earning.program_name%TYPE DEFAULT NULL,
          in_transaction_type  IN x_reward_benefit_earning.transaction_type%TYPE DEFAULT NULL)
  RETURN typ_reward_catalog_tbl pipelined
IS
    rec_reward_catalog typ_reward_catalog_obj;

    --Cursor to get the rewards categlog information
    cursor cur_reward_catalog is
      SELECT rbe.objid,
            rbe.program_name,
            rbe.benefit_type_code,
            rbe.transaction_type,
            rbe.benefits_earned,
            rbe.start_date,
            rbe.end_date,
            rbe.category,
            rbe.sub_category,
            rbe.individual_action_count,
            rbe.max_usage,
            rbe.max_usage_freq_days,
            rbe.point_cooldown_days,
            rbe.point_expiration_days,
            rbe.revenue_direction,
            rbe.transaction_revenue_direction,
            rbe.transaction_description,
            rc.objid as catalog_id,
            rc.catalog_name,
            rc.catalog_type,
            rc.catalog_version,
            rc.catalog_status,
			rc.catalog_provider
        FROM x_reward_benefit_earning rbe,
              x_reward_catalog rc,
              x_mtm_catalog_benefit_earning mtm
       WHERE rc.catalog_provider = NVL(in_catalog_provider,rc.catalog_provider)
         AND rc.catalog_type = NVL(in_catalog_type,rc.catalog_type)
         AND benefit_type_code = NVL(in_benefit_type_code,benefit_type_code)
         AND program_name = NVL(in_program_name,program_name)
         AND transaction_type = nvl(in_transaction_type,transaction_type)
         and mtm.benefit_earning_objid = rbe.objid
         and rbe.end_date >= trunc(sysdate)
         and rc.objid = mtm.catalog_objid;

    --OUT_REWARD_CATELOG SYS_REFCURSOR;
    l_err_code NUMBER;
    l_err_msg  VARCHAR2(200);
BEGIN
    FOR i IN cur_reward_catalog
    LOOP
        rec_reward_catalog.objid                         := i.objid;
        rec_reward_catalog.program_name                  := i.program_name;
        rec_reward_catalog.benefit_type_code             := i.benefit_type_code;
        rec_reward_catalog.transaction_type              := i.transaction_type;
        rec_reward_catalog.benefits_earned               := i.benefits_earned;
        rec_reward_catalog.start_date                    := i.start_date;
        rec_reward_catalog.end_date                      := i.end_date;
        rec_reward_catalog.category                      := i.category;
        rec_reward_catalog.sub_category                  := i.sub_category;
        rec_reward_catalog.individual_action_count       := i.individual_action_count;
        rec_reward_catalog.max_usage                     := i.max_usage;
        rec_reward_catalog.max_usage_freq_days           := i.max_usage_freq_days;
        rec_reward_catalog.point_cooldown_days           := i.point_cooldown_days;
        rec_reward_catalog.point_expiration_days         := i.point_expiration_days;
        rec_reward_catalog.revenue_direction             := i.revenue_direction;
        rec_reward_catalog.transaction_revenue_direction := i.transaction_revenue_direction;
        rec_reward_catalog.transaction_description       := i.transaction_description;
        rec_reward_catalog.catalog_id                    := i.catalog_id;
        rec_reward_catalog.catalog_name                  := i.catalog_name;
        rec_reward_catalog.catalog_type                  := i.catalog_type;
        rec_reward_catalog.catalog_version               := i.catalog_version;
        rec_reward_catalog.catalog_status                := i.catalog_status;
		rec_reward_catalog.catalog_provider				 := i.catalog_provider;
        PIPE ROW (rec_reward_catalog);
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
    l_err_code := -99;
    l_err_msg  :='Error_code: '||l_err_code||' Error_msg: '||sqlerrm ||' - '||dbms_utility.format_error_backtrace;
    --
    ota_util_pkg.err_log (p_action => 'CALLING REWARDS_MGT_API_PKG.f_get_reward_catalog',
                          p_error_date => SYSDATE,
                          p_key => 'in_catalog_provider: '||in_catalog_provider||' - in_catalog_type: '||in_catalog_type||
                                    ' - in_benefit_type_code: '||in_benefit_type_code||' - in_program_name: '||in_program_name||
                                    ' - in_transaction_type: '||in_transaction_type,
                          p_program_name => 'REWARDS_MGT_API_PKG.f_get_reward_catalog',
                          p_error_text => l_err_msg);
    RETURN;
END f_get_reward_catalog;
--
PROCEDURE get_reward_catalog(
          in_catalog_provider  IN x_reward_catalog.catalog_provider%TYPE DEFAULT NULL,
          in_catalog_type      IN x_reward_catalog.catalog_type%TYPE DEFAULT NULL,
          in_benefit_type_code IN x_reward_benefit_earning.benefit_type_code%TYPE DEFAULT NULL,
          in_program_name      IN x_reward_benefit_earning.program_name%TYPE DEFAULT NULL,
          in_transaction_type  IN x_reward_benefit_earning.transaction_type%TYPE DEFAULT NULL,
          out_reward_catelog   OUT SYS_REFCURSOR,
          out_err_code         OUT NUMBER,
          out_err_msg          OUT VARCHAR2) IS

BEGIN
  out_err_code := 0;
  out_err_msg := 'SUCCESS';

  --Cursor to get the rewards categlog information
  OPEN out_reward_catelog FOR
        SELECT *
        FROM TABLE(f_get_reward_catalog(in_catalog_provider 	=> in_catalog_provider,
                                        in_catalog_type 		  => in_catalog_type,
                                        in_benefit_type_code 	=> in_benefit_type_code,
                                        in_program_name 		  => in_program_name,
                                        in_transaction_type 	=> in_transaction_type ));

EXCEPTION
  WHEN OTHERS THEN
    out_err_code      := -99;
    out_err_msg       :='Error_code: '||out_err_code||' Error_msg: '||sqlerrm ||' - '||dbms_utility.format_error_backtrace;

    --
    ota_util_pkg.err_log (p_action      => 'Calling REWARDS_MGT_API_PKG.get_reward_catalog',
                       p_error_date     => SYSDATE,
                       p_key            => 'in_catalog_provider: '|| in_catalog_provider || ', in_catalog_type' || in_catalog_type || ', in_benefit_type_code: ' || in_benefit_type_code || ', in_program_name: ' || in_program_name || ', in_transaction_type: ' || in_transaction_type,
                       p_program_name   => 'REWARDS_MGT_API_PKG.get_reward_catalog',
                       p_error_text     => out_err_msg);

END get_reward_catalog;

PROCEDURE get_reward_transactions(
          IN_WEB_ACCOUNT_ID IN VARCHAR2,
          IN_BRAND IN VARCHAR2,
          out_reward_transaction   OUT SYS_REFCURSOR,
          out_err_code         OUT NUMBER,
          out_err_msg          OUT VARCHAR2)IS
BEGIN
  out_err_code := 0;
  out_err_msg := 'SUCCESS';

  --Cursor to get the rewards categlog information
  OPEN out_reward_transaction FOR
        select
                  bt.objid trans_objid
                  ,bt.WEB_ACCOUNT_ID
                  ,nvl(be.category, 'TRACFONE') category
                  ,nvl(be.sub_category, 'INTERNAL') sub_category
                  ,bt.ACTION
                  ,bt.ACTION_TYPE
                  ,bt.action_reason
                  ,bt.transaction_status
                  ,bt.amount
                  ,bt.BENEFIT_TYPE_CODE
                  ,bt.trans_date
                  ,bt.TRANS_TYPE
                  ,bt.TRANS_DESC
                  ,bt.source
                  ,bt.source_trans_id EXT_TRANS_ID
        from x_reward_benefit_transaction  bt, x_reward_benefit_earning be
        where bt.web_account_id = in_web_account_id
        and   be.TRANSACTION_TYPE(+) = bt.TRANS_TYPE
		and   be.end_date(+) > sysdate
        ;

EXCEPTION
  WHEN OTHERS THEN
    out_err_code      := -99;
    out_err_msg       :='Error_code: '||out_err_code||' Error_msg: '||sqlerrm ||' - '||dbms_utility.format_error_backtrace;

    ota_util_pkg.err_log (p_action      => 'Calling REWARDS_MGT_API_PKG.get_reward_transactions',
                       p_error_date     => SYSDATE,
                       p_key            => 'IN_WEB_ACCOUNT_ID: '|| IN_WEB_ACCOUNT_ID || ', IN_BRAND' || IN_BRAND,
                       p_program_name   => 'REWARDS_MGT_API_PKG.get_reward_transactions',
                       p_error_text     => out_err_msg);

END get_reward_transactions;

PROCEDURE p_get_reward_earn_point ( i_esn         		in  varchar2,
                                    i_pin				      in  varchar2,
                                    out_ern_point     out number,
                                    out_err_code      out number,
                                    out_err_msg       out varchar2) AS

 l_cnt                number;
 l_web_objid          number;
 l_service_plan_objid number; --C88132
 cst sa.customer_type := sa.customer_type();
 v_discounted         varchar2(1);

BEGIN
   --
   if i_esn is null or i_pin is null then
       out_err_code      := -100;
       out_err_msg       := 'INVALID INPUT';
        return;
   end if;

   -- get brand and service plan
   cst.bus_org_id          := cst.get_bus_org_id(i_esn);

   --C88132 Cannot depend on Base Plan for AddOn Redemptions as it does not change
   BEGIN
     select sa.get_service_plan_id(i_esn,i_pin)
       into l_service_plan_objid
     from   dual;
     --If function does not return set to base plan of ESN
     if l_service_plan_objid is null
     then
       l_service_plan_objid := cst.get_service_plan_objid(i_esn);
     end if;
   EXCEPTION WHEN OTHERS
   THEN
     l_service_plan_objid  := cst.get_service_plan_objid(i_esn); -- C88132 Moved to Exception
   END;

   --get the web objid for the esn
   BEGIN
       select web.objid web_user_objid
       into   l_web_objid
       from   table_web_user web,
              table_x_contact_part_inst conpi,
              table_part_inst pi
       where  conpi.x_contact_part_inst2contact(+) = web.web_user2contact
       and    pi.objid(+)                          = conpi.x_contact_part_inst2part_inst
       and    pi.part_serial_no                    = i_esn;
   EXCEPTION
      WHEN OTHERS THEN
	       out_err_code      := -200;
         out_err_msg       := 'WEB ACCUNT NOT FOUND';
	   RETURN;
   END;

   --Rewards LRP points
   -- CR49699_fix_to_char
   BEGIN
     select 0
     into   out_ern_point
     from   sa.x_reward_benefit_transaction
     where  trans_type = 'CHARGE'
     and    web_account_id = TO_CHAR(l_web_objid)
     and    svc_plan_pin   = i_pin;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        --
        -- CR49699 Tim 6/13/2017 Added check to see if they used corp card.
        -- if so then no points.
        --
        --
        BEGIN
           v_discounted := 'N';
           out_ern_point := 0;

                SELECT 'Y'
                  INTO v_discounted
                  FROM sa.table_x_red_card rc,
                       sa.table_x_call_trans ct,
                       sa.table_inv_bin inv,
                       sa.table_site ts
                 WHERE 1 = 1
                   AND ct.objid = RC.RED_CARD2CALL_TRANS
                   AND X_RED_CARD2INV_BIN = inv.objid
                   AND inv.bin_name = ts.site_id
                   AND (ts.name like 'CORP FREE%' or ts.name = 'TRACFONE WIRELESS - AUTOMATED STORES (ZOOM SYSTEMS)')
                   AND rc.x_red_code        = i_pin  -- Red card
                   AND ct.x_service_id = i_esn;      -- ESN


        EXCEPTION WHEN OTHERS THEN

           v_discounted := 'N';


        END;
        --
        -- If no corp discount the show the plan points.
        --
        IF v_discounted = 'N' THEN

           out_ern_point := sa.rewards_mgt_util_pkg.f_get_svc_plan_benefits(   in_svc_plan_id       => l_service_plan_objid,
                                                                               in_program_name      => 'LOYALTY_PROGRAM',
                                                                               in_benefit_type_code => 'LOYALTY_POINTS',
                                                                               in_brand             => cst.bus_org_id,
                                                                               in_autorefill_flag   => 'N');

         END IF;


     WHEN OTHERS THEN
        out_ern_point := null;
        out_err_code  := -101;
        out_err_msg   := 'FAILURE';
        RETURN;
   END;

    out_err_code                         := 0;
    out_err_msg                          := 'SUCCESS';

EXCEPTION
 WHEN OTHERS THEN
      out_err_code      := -100;
      out_err_msg       := 'ERROR_CODE: '||out_err_code||' ERROR_MSG: '||sqlerrm ||' - '||dbms_utility.format_error_backtrace;
END P_GET_REWARD_EARN_POINT;

END  REWARDS_MGT_API_PKG;
/