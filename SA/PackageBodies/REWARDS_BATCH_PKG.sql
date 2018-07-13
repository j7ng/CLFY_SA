CREATE OR REPLACE PACKAGE BODY sa.REWARDS_BATCH_PKG
IS
 --$RCSfile: REWARDS_BATCH_PKG.sql,v $
 --$Revision: 1.58 $
 --$Author: abustos $
 --$Date: 2018/03/27 22:50:25 $
 --$ $Log: REWARDS_BATCH_PKG.sql,v $
 --$ Revision 1.58  2018/03/27 22:50:25  abustos
 --$ Add > 0 CR57330
 --$
 --$ Revision 1.57  2018/03/27 20:44:56  rmorthala
 --$ CR57330 - Prod fix to deenroll only those accounts having all esns expired greater than 60 days
 --$
 --$ Revision 1.56  2018/02/16 20:10:49  rkommineni
 --$ comment added.
 --$
 --$ Revision 1.55  2018/02/15 18:58:22  rmorthala
 --$ *** empty log message ***
 --$
 --$ Revision 1.51  2018/01/15 17:03:41  mshah
 --$ CR49941 - ST Loyalty points with Autorefill Dummy Credit Card from WEB
 --$
 --$ Revision 1.50  2018/01/15 15:24:08  mshah
 --$ CR49941 - ST Loyalty points with Autorefill Dummy Credit Card from WEB
 --$
 --$ Revision 1.49  2018/01/11 23:01:57  mshah
 --$ CR49941 - ST Loyalty points with Autorefill Dummy Credit Card from WEB
 --$
 --$ Revision 1.48  2018/01/10 18:59:34  mshah
 --$ CR49941 - ST Loyalty points with Autorefill Dummy Credit Card from WEB
 --$
 --$ Revision 1.47  2017/12/15 22:11:23  mshah
 --$ CR49941 - ST Loyalty points with Autorefill Dummy Credit Card from WEB
 --$
 --$ Revision 1.46  2016/09/19 19:28:27  pamistry
 --$ CR41473 - LRP2 modified the p_acct_anniversary procedure to include 18 and 24 month bonus.
 --$
 --$ Revision 1.44  2016/09/15 21:46:21  pamistry
 --$ CR41473 - LRP2 Corrected old code to log the failure error
 --$
 --$ Revision 1.41  2016/09/14 14:22:50  pamistry
 --$ CR41473 - LRP2 Modify p_acct_anniversary procedure to make is continue execution for all candidate as it was coming out of loop from first failure.
 --$
 --$ Revision 1.1  2016/09/14 21:28:51  pamistry
 --$ CR41473 - Modify p_acct_anniversary procedure to make is continue execution for all candidate as it was coming out of loop from first failure.
 --$

  FUNCTION f_expire_benefit(
             in_webaccount_id  IN VARCHAR2
            )
  RETURN VARCHAR2 --Modified for 2269
  IS
    l_inactive_days   NUMBER;
    l_expire_benefit VARCHAR2(20) ; --Modified for 2269
    l_active_cnt   NUMBER;
    l_err_code  NUMBER;
    l_err_msg   VARCHAR2(1000);
    n_inactive_count     NUMBER := 0; --CR57330
    n_expire_count       NUMBER := 0; --CR57330

    CURSOR cur_part_status
    IS

    --CR55198 changes start
        SELECT web.objid,
               PI_ESN.PART_SERIAL_NO esn,
               sp.x_min MIN,
               SP.PART_STATUS
        FROM TABLE_WEB_USER WEB,
             TABLE_X_CONTACT_PART_INST CONPI,
             TABLE_PART_INST PI_ESN,
             TABLE_SITE_PART SP
        WHERE PI_ESN.OBJID                    = CONPI.X_CONTACT_PART_INST2PART_INST
        AND CONPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT
        AND SP.objid = PI_ESN.X_PART_INST2SITE_PART
        AND web.objid       = in_webaccount_id
        AND web.objid NOT  IN
          (SELECT web.objid
          FROM TABLE_WEB_USER WEB,
            TABLE_X_CONTACT_PART_INST CONPI,
            TABLE_PART_INST PI_ESN,
            TABLE_SITE_PART SP
          WHERE PI_ESN.OBJID                    = CONPI.X_CONTACT_PART_INST2PART_INST
          AND CONPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT
          AND SP.objid       = PI_ESN.X_PART_INST2SITE_PART
          AND web.objid             = in_webaccount_id
          AND UPPER(SP.PART_STATUS) = 'ACTIVE');
    --CR55198 changes end

    rec_part_status cur_part_status%rowtype;
BEGIN
    OPEN cur_part_status;
    LOOP
     l_inactive_days := 0;
     FETCH cur_part_status INTO rec_part_status;
     EXIT WHEN cur_part_status%NOTFOUND;

     IF  UPPER(rec_part_status.PART_STATUS) = 'INACTIVE' THEN
         n_inactive_count := n_inactive_count + 1; --CR57330

         --CR55198 changes start
         BEGIN
           select trunc(SYSDATE) - trunc(max(service_end_dt))
           INTO l_inactive_days
           from TABLE_WEB_USER WEB, TABLE_X_CONTACT_PART_INST CONPI,TABLE_PART_INST PI_ESN, TABLE_SITE_PART SP
           where PI_ESN.OBJID = CONPI.X_CONTACT_PART_INST2PART_INST
           and CONPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT
           AND SP.objid       = PI_ESN.X_PART_INST2SITE_PART
           and web.objid = in_webaccount_id
           and sp.x_min = rec_part_status.min;
         EXCEPTION
         WHEN OTHERS THEN
           l_inactive_days := 0;
         END;
         --CR55198 changes end
     END IF;

           IF l_inactive_days > 60 THEN
             --l_expire_benefit:= 'EXPIRED';   -- Yes, Expire the benefit --Modified for 2269
             n_expire_count := n_expire_count + 1; --CR57330
           ELSE
             l_expire_benefit:= 'SUSPENDED';   -- No, Dont Expire the benefit --Modified for 2269

             CLOSE cur_part_status; --CR57330
             RETURN l_expire_benefit; --CR57330
           END IF;

    END LOOP;
    CLOSE cur_part_status;

   --CR57330 start
   IF n_inactive_count = n_expire_count AND n_inactive_count > 0
   THEN
     l_expire_benefit:= 'EXPIRED';
   END IF;
   --CR57330 end
   RETURN l_expire_benefit;

EXCEPTION WHEN OTHERS THEN
  --ROLLBACK;
  l_err_code:=-99;
  l_err_msg:='Error in Expiration job: '||sqlerrm||' - ' || dbms_utility.format_error_backtrace || ' in_webaccount_id: ' || in_webaccount_id;
  sa.ota_util_pkg.err_log ( p_action => 'OTHERS EXCEPTION', p_error_date => sysdate, p_key => 'LRP', p_program_name => 'f_expire_benefit', p_error_text => 'input params: ' || 'webaccount_id ='||in_webaccount_id  || ', l_err_code='||l_err_code || ', l_err_msg='|| l_err_msg );
END f_expire_benefit;
--
PROCEDURE p_expire_benefit
  (i_rundate in date,
   o_err_code out number,
   o_err_msg  out varchar2
  )
IS
  l_count             NUMBER:=0;
  l_rundate           DATE:=NVL(i_rundate,sysdate);
  l_ENROLLMENT_STATUS  VARCHAR2(30);
  --Modified for 2269
  l_reward_benefit_trans_objid      x_reward_benefit_transaction.objid%TYPE;
  btrans                        typ_lrp_benefit_trans;
  l_expire_benefit            VARCHAR2(30);
  l_eligible_status     varchar2(50);
  --Modified for 2269
  CURSOR cur_benefit
  IS
    SELECT  xrb.web_account_id, xrb.quantity, xrb.objid, xrb.benefit_type_code, xrb.brand  --Modified for 2269
    FROM x_reward_benefit xrb
    WHERE expiry_date IS NULL
    AND benefit_type_code = 'LOYALTY_POINTS'
    AND PROGRAM_NAME = 'LOYALTY_PROGRAM'
    AND BRAND='STRAIGHT_TALK';
  --
  trec_benefit cur_benefit%rowtype;
  --
  l_transaction_status     x_reward_benefit_transaction.transaction_status%type;     -- CR41473 PMistry 08/03/2016 LRP2

BEGIN
  l_rundate:=nvl(i_rundate, sysdate);
  o_err_code:=0;
  o_err_msg:='Success';
  --
  OPEN cur_benefit;
  LOOP
  FETCH cur_benefit into trec_benefit;
  EXIT WHEN cur_benefit%notfound;
    BEGIN
      sa.REWARDS_MGT_UTIL_PKG.P_CUSTOMER_IS_ENROLLED  (in_cust_key             => 'ACCOUNT',
                                                       in_cust_value           => trec_benefit.web_account_id,
                                                       in_program_name         => 'LOYALTY_PROGRAM',
                                                       in_enrollment_type      => 'PROGRAM_ENROLLMENT',
                                                       in_brand                => 'STRAIGHT_TALK',
                                                       out_enrollment_status   => l_ENROLLMENT_STATUS,
                                                       out_enrollment_elig_status    => l_eligible_status,
                                                       out_err_code            => O_ERR_CODE,
                                                       out_err_msg                   => O_ERR_MSG);
      --dbms_output.put_line(l_ENROLLMENT_STATUS||','||l_eligible_status);
      --IF l_eligible_status = 'N' AND l_ENROLLMENT_STATUS <> 'RISK ASSESSMENT' THEN
      IF l_ENROLLMENT_STATUS IN ('ENROLLED', 'SUSPENDED') THEN --CR42428
        BEGIN
          --Modified for defect 2269
          l_expire_benefit:=f_expire_benefit (trec_benefit.web_account_id);
      --    dbms_output.put_line('l_expire_benefit: '||l_expire_benefit);
          IF l_expire_benefit IN ('EXPIRED','SUSPENDED')  THEN
          --Modified for defect 2269
          -- Insert a Record for Re-enrollment
      --     dbms_output.put_line('web:'||trec_benefit.web_account_id);
            btrans                            := typ_lrp_benefit_trans();
            btrans.objid                       := 0;
            btrans.trans_date                  := SYSDATE;
            btrans.web_account_id              := trec_benefit.web_account_id;
            btrans.subscriber_id               := NULL;
            btrans.MIN                         := NULL;
            btrans.esn                         := NULL;
            btrans.old_min                     := NULL;
            btrans.old_esn                     := NULL;
            btrans.trans_type                  := case l_expire_benefit when 'EXPIRED' THEN 'EXPIRED' WHEN 'SUSPENDED' THEN 'SUSPENDED' END;
            btrans.trans_desc                  := case l_expire_benefit when 'EXPIRED' THEN 'EXPIRED' WHEN 'SUSPENDED' THEN 'SUSPENDED' END;
            btrans.amount                      := 0;
            btrans.benefit_type_code           := trec_benefit.benefit_type_code;
            btrans.action                      := 'NOTE';
            btrans.action_type                 := case l_expire_benefit when 'EXPIRED' THEN 'EXPIRED' WHEN 'SUSPENDED' THEN 'SUSPENDED' END;
            btrans.action_reason               := case l_expire_benefit when 'EXPIRED' THEN 'EXPIRED' WHEN 'SUSPENDED' THEN 'SUSPENDED' END;
            btrans.action_notes                := NULL;
            btrans.benefit_trans2benefit_trans := NULL;
            btrans.svc_plan_pin                := NULL;
            btrans.svc_plan_id                 := NULL;
            btrans.brand                       := trec_benefit.brand;
            btrans.benefit_trans2benefit       := trec_benefit.objid;
            btrans.agent_login_name               := NULL;
        --Modified for defect 2269
            sa.rewards_mgt_util_pkg.p_create_benefit_trans( ben_trans                   => btrans,
                                                            reward_benefit_trans_objid  => l_reward_benefit_trans_objid,
                                                            o_transaction_status        => l_transaction_status);               -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.
      --        dbms_output.put_line('objid:'||l_reward_benefit_trans_objid);
          --Modified for defect 2269
            --
            UPDATE  x_reward_benefit
            SET     status          = case l_expire_benefit when 'EXPIRED'         THEN 'UNAVAILABLE'
                                                            WHEN 'RISK ASSESSMENT' THEN 'HOLD'
                                                            else status END,--Modified for 2269
                    quantity        = case l_expire_benefit when 'EXPIRED' THEN 0
                                                            else quantity end,
                    -- CR41473 - Start - LRP2 - sethiraj
                    pending_quantity = case l_expire_benefit when 'EXPIRED' THEN 0
                                                            else pending_quantity end,
                    total_quantity = case l_expire_benefit when 'EXPIRED' THEN 0
                                                            else total_quantity end,
                    -- CR41473 - End - LRP2 - sethiraj
                    expiry_date     = case l_expire_benefit when 'EXPIRED' THEN l_rundate
                                                            else expiry_date end,
                    account_status  = l_expire_benefit  --Modified for 2269
             WHERE  web_account_id   = trec_benefit.web_account_id;
             --2269
             IF l_expire_benefit IN ('EXPIRED')
             THEN
               UPDATE x_reward_program_enrollment txpe
               SET    enrollment_flag             = 'N',
                      deenroll_date               = SYSDATE
               WHERE  txpe.benefit_type_code    = 'LOYALTY_POINTS'
               AND    txpe.web_account_id         = trec_benefit.web_account_id
               AND    txpe.enrollment_flag        = 'Y' -- To check if a customer is already en-rolled.
               AND    txpe.program_name           = 'LOYALTY_PROGRAM'
               AND    txpe.enrollment_type        = 'PROGRAM_ENROLLMENT'
               AND    txpe.brand                  = 'STRAIGHT_TALK'
               AND    txpe.enroll_date           IS NOT NULL
               AND    txpe.deenroll_date         IS NULL;
               --
               --Updating the payment source table to set the status to "DELETED"
               UPDATE Table_X_Altpymtsource
               SET    X_Application_Key = X_Application_Key ||'--' ||Objid ,
                      X_Status   = 'DELETED'
               WHERE objid IN
                        (SELECT Pymt_Src2x_Altpymtsource
                        FROM X_Payment_Source
                        WHERE pymt_src2web_user = trec_benefit.web_account_id
                        )
               AND X_Alt_Pymt_Source = 'LOYALTY_PTS';
               --
               UPDATE X_Payment_Source Ps
               SET    X_Status                   =  'DELETED'
               WHERE ps.Pymt_Src2web_User        =  trec_benefit.web_account_id
               AND  ps.x_pymt_type               =  'APS'
               AND  ps.pymt_src2x_altpymtsource IN
                        (SELECT aps.objid
                        FROM Table_X_Altpymtsource aps
                        WHERE aps.Objid           = ps.Pymt_Src2x_Altpymtsource
                        AND aps.X_Alt_Pymt_Source = 'LOYALTY_PTS'
                        );
                --
             END IF;
             --2269
             l_count := l_count + 1;
             IF MOD(l_count, 500) =  0 THEN
             COMMIT;
             END IF;
          END IF;
        END;
      END IF;
    EXCEPTION
    -- CR42235 Changes Starts
    WHEN DUP_VAL_ON_INDEX THEN
    o_err_code := -99;
    o_err_msg  := o_err_msg || chr(10) || 'Error: '||sqlerrm||' - ' || dbms_utility.format_error_backtrace || ' trec_benefit.web_account_id: ' || trec_benefit.web_account_id;
    -- CR42235 Changes Ends
    WHEN OTHERS THEN
    o_err_msg:= o_err_msg || chr(10) || 'Error: '||sqlerrm||' - ' || dbms_utility.format_error_backtrace || ' trec_benefit.web_account_id: ' || trec_benefit.web_account_id;
    --dbms_output.put_line('o_err_msg:'||o_err_msg);
    END;
  END LOOP;
  CLOSE cur_benefit;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
ROLLBACK;
o_err_code:=-99;
--Modified for CR41118
--o_err_msg:='Error in Expiration job: '||sqlerrm||' - ' || dbms_utility.format_error_backtrace || ' Objid: ' || l_objid;
sa.ota_util_pkg.err_log ( p_action => 'OTHERS EXCEPTION', p_error_date => sysdate, p_key => 'LRP', p_program_name => 'p_expire_benefit', p_error_text => 'input params: ' || 'l_rundate ='||l_rundate  || ', IN_ORDER_ID='|| ', o_err_code='||o_err_code || ', o_err_msg='|| o_err_msg );
END p_expire_benefit;
-- CR41473 09/19/2016 Modified the procedure to remove transaction processing via hard coded values and included 18 and 24 months (As part of defect # 15755 which was decided by business.
PROCEDURE p_acct_anniversary( i_rundate   In  DATE,
                              o_err_code  OUT NUMBER,
                              o_err_msg   OUT VARCHAR2 )
  --------------------------------------------------------------------------------------------
  -- Author: Usha Sivaraman
  -- Date: 2015/11/17
  -- <CR# 33098>
  -- Loyalty Rewards Program is to build a capability to give rewards for certain customer Actions
  -- and increase the Life Time value of the customer.
  -- This program is precisely targeting the customers who fall under the umbrella of Straight Talk.
  -- Purpose: The procedure will be called from Batch Job to assign bonus points for customers
  --          on reaching their 6 months and 12 months anniversaries.
  --------------------------------------------------------------------------------------------
IS
  l_anni_points               NUMBER:=0;
  l_anni_trans_desc           VARCHAR2(100);
  l_anni_trans_type           VARCHAR2(100);
  l_anni_period               NUMBER := 6;
  l_count                     NUMBER := 0;

  l_enrollment_status         VARCHAR2(30):='NOT ENROLLED'; --Modified for 2269
  l_eligible_status           VARCHAR2(20):='N';            --Modified for 2269
  l_new_anniv_trans_id        NUMBER;
  l_objid                     NUMBER;
  l_rundate                   DATE:=NVL(i_rundate,SYSDATE);
  input_validation_failed     EXCEPTION;
  already_awarded_anniversary EXCEPTION;
  l_error_message             VARCHAR2(4000 CHAR);
  CURSOR cur_anni_acct(c_anni_freq NUMBER) IS
          SELECT objid,
                  benefit_type_code,
                  program_name,
                  web_account_id,
                  subscriber_id,
                  MIN,
                  esn,
                  --quantity BENEFIT_AMOUNT,
                  brand
          FROM x_reward_program_enrollment txpe
          WHERE txpe.enrollment_flag = 'Y'
          AND txpe.enroll_date    between add_months(SYSDATE,-((c_anni_freq* l_anni_period) + l_anni_period)) and  add_months(SYSDATE,-(c_anni_freq * l_anni_period ))
          AND txpe.deenroll_date    IS NULL
          AND NOT EXISTS  (SELECT 1
                          FROM x_reward_benefit_transaction xrbt
                          WHERE xrbt.web_account_id = txpe.web_account_id
                          AND xrbt.trans_type       = 'ANNIVERSARY_' ||c_anni_freq * l_anni_period ); -- ANNIVERSARY_6, ANNIVERSARY_12, ANNIVERSARY_18 and ANNIVERSARY_24
  rec_anni_acct cur_anni_acct%rowtype;

  cursor cur_trans_exist   (c_web_account_id      x_reward_benefit_transaction.web_account_id%type,
                            c_trans_type          x_reward_benefit_transaction.trans_type%type)  IS
                  select *
                  from x_reward_benefit_transaction
                  where  web_account_id = c_web_account_id
                  and    trans_type = c_trans_type;

  rec_trans_exist cur_trans_exist%rowtype;


  --
  l_transaction_status x_reward_benefit_transaction.transaction_status%TYPE; -- CR41473 PMistry 08/03/2016 LRP2
BEGIN
  --
  o_err_code:=0;
  o_err_msg :='Success';
  FOR i IN 1..4
  LOOP
    --

    BEGIN
      SELECT benefits_earned,
        transaction_description, --Modified for 2269
        transaction_type
      INTO l_anni_points,
        l_anni_trans_desc,
        l_anni_trans_type
      FROM x_reward_benefit_earning txp
      WHERE program_name    = 'LOYALTY_PROGRAM'
      AND benefit_type_code = 'LOYALTY_POINTS'
      AND transaction_type  = 'ANNIVERSARY_'  ||i*l_anni_period
      AND SYSDATE BETWEEN txp.start_date AND txp.end_date; --Modified for CR41661;
    EXCEPTION
    WHEN no_data_found THEN
      l_anni_points      := 1;
      l_anni_trans_desc := NULL;
      l_anni_trans_type := null;
    END;
    --
    OPEN cur_anni_acct(i);
    LOOP
      FETCH cur_anni_acct INTO rec_anni_acct;
      EXIT
        WHEN cur_anni_acct%notfound;

      BEGIN
        -- Check whether the anniversary bonus already provided to the customer or not.
        open cur_trans_exist(rec_anni_acct.web_account_id,
                             l_anni_trans_type);
        fetch cur_trans_exist into rec_trans_exist;

        if cur_trans_exist%found then
          close cur_trans_exist;
          raise already_awarded_anniversary;
        end if;
        close cur_trans_exist;
        --l_ENROLLMENT_STATUS:='N';
        --
        rewards_mgt_util_pkg.p_customer_is_enrolled ( in_cust_key                 => 'ACCOUNT',
                                                      in_cust_value               => rec_anni_acct.web_account_id,
                                                      in_program_name             => 'LOYALTY_PROGRAM',
                                                      in_enrollment_type          => 'PROGRAM_ENROLLMENT',
                                                      in_brand                    => 'STRAIGHT_TALK',
                                                      out_enrollment_status       => l_enrollment_status,
                                                      out_enrollment_elig_status  => l_eligible_status, --Modified for 2269
                                                      out_err_code                => o_err_code,
                                                      out_err_msg                 => o_err_msg);

        IF l_enrollment_status NOT IN ('ENROLLED','SUSPENDED','RISK ASSESSMENT') THEN --Modified for 2269
          o_err_code :=             -200;
          o_err_msg  := 'Account Status Is Not Eligible to get Bonus - ' || rec_anni_acct.web_account_id;
          raise input_validation_failed;
        END IF;
        --
        IF f_expire_benefit (rec_anni_acct.web_account_id) = 'EXPIRED' THEN --Modified for 2269
          dbms_output.put_line('Customer account Is Inactive for more than 60 days WEB_ACCOUNT: ' || rec_anni_acct.web_account_id);
          o_err_code := 1;
          o_err_msg  := 'Customer account Is Inactive for more than 60 days WEB_ACCOUNT: ' || rec_anni_acct.web_account_id;
        ELSE
          l_new_anniv_trans_id := rewards_mgt_pymt_pkg.f_get_transaction_id;
          --
          BEGIN
            SELECT objid
            INTO l_objid
            FROM x_reward_benefit b
            WHERE b.web_account_id = rec_anni_acct.web_account_id
              --AND b.min                   = nvl(rec_anni_acct.min,b.min)
              --AND b.esn                   = nvl(rec_anni_acct.esn,b.esn)
            AND b.benefit_type_code = NVL(rec_anni_acct.benefit_type_code,'LOYALTY_POINTS')
            AND b.program_name      = NVL(rec_anni_acct.program_name,'LOYALTY_PROGRAM')
            AND b.brand             = NVL(rec_anni_acct.brand,'STRAIGHT_TALK');
          EXCEPTION
          WHEN OTHERS THEN
            l_objid := NULL;
            raise input_validation_failed;
          END;
          --
          rewards_mgt_pymt_pkg. p_create_benefit_trans (i_event_type          => 'SIX_MONTHS_BONUS',
                                                        i_transaction_id      => l_new_anniv_trans_id,
                                                        i_trans_date          => l_rundate,
                                                        i_web_account_id      => rec_anni_acct.web_account_id,
                                                        i_subscriber_id       => rec_anni_acct.subscriber_id,
                                                        i_min                 => rec_anni_acct.MIN,
                                                        i_esn                 => rec_anni_acct.esn,
                                                        i_old_min             => NULL,
                                                        i_old_esn             => NULL,
                                                        i_trans_type          => l_anni_trans_type,
                                                        i_trans_desc          => l_anni_trans_desc,
                                                        i_amount              => l_anni_points,
                                                        i_benefit_type_code   => rec_anni_acct.benefit_type_code,
                                                        i_action              => 'ADD',
                                                        i_action_type         => 'FREE',
                                                        i_action_reason       => l_anni_trans_desc,
                                                        i_btrans2btrans       => NULL,
                                                        i_svc_plan_pin        => NULL,
                                                        i_svc_plan_id         => NULL,
                                                        i_brand               => rec_anni_acct.brand,
                                                        i_btrans2benefit      => l_objid,
                                                        o_transaction_status  => l_transaction_status); -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.
          -- CR41473 - LRP2
          rewards_mgt_util_pkg.p_update_benefit(in_cust_key               => 'OBJID',
                                                in_cust_value             => l_objid,
                                                in_program_name           => NULL,
                                                in_benefit_type           => NULL,
                                                in_brand                  => NULL,
                                                in_new_min                => NULL,
                                                in_new_esn                => NULL,
                                                in_new_status             => NULL,
                                                in_new_notes              => NULL,
                                                in_new_expiry_date        => NULL,
                                                in_change_quantity        => l_anni_points,
                                                in_transaction_status     => l_transaction_status,
                                                in_value                  => NULL,
                                                in_account_status         => NULL );
          /*
          UPDATE  x_reward_benefit b
          SET     quantity            = quantity + l_points_6,
          update_date         = l_rundate
          WHERE   b.objid = l_objid;
          */
          --
          l_count := l_count + 1;
          --
          IF mod(l_count, 500) = 0 THEN
            COMMIT;
          END IF;
          --
        END IF;
      EXCEPTION
      when already_awarded_anniversary then     -- CR41473 Added new user define exception for not logging the error message.
        null;
      WHEN input_validation_failed THEN
        l_error_message:=o_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;
        --Modified for CR41118  -- CR41473 09/15/2016 PMistry loging the error as this is failure error not just message.
        ota_util_pkg.err_log (p_action => 'CALLING p_acct_anniversary', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_acct_anniversary', p_error_text => l_error_message);
        l_error_message := NULL;
        -- CR42235 Changes Starts
      WHEN dup_val_on_index THEN
        l_error_message:=o_err_msg || chr(10) || 'Error: '||sqlerrm||' - ' || dbms_utility.format_error_backtrace || ' rec_anni_acct.web_account_id: ' || rec_anni_acct.web_account_id;
        --Modified for CR41118   -- CR41473 09/15/2016 PMistry loging the error as this is failure error not just message.
        ota_util_pkg.err_log (p_action => 'CALLING p_acct_anniversary', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_acct_anniversary', p_error_text => l_error_message);
        l_error_message := NULL;
        -- CR41473 09/15/2016 PMistry Added Others loging the error as this is failure error not just message.
      WHEN OTHERS THEN
        l_error_message:=o_err_msg || chr(10) || 'Error: '||sqlerrm||' - ' || dbms_utility.format_error_backtrace || ' rec_anni_acct.web_account_id: ' || rec_anni_acct.web_account_id;
        ota_util_pkg.err_log (p_action => 'CALLING p_acct_anniversary', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_acct_anniversary', p_error_text => l_error_message);
        l_error_message := NULL;
        -- CR42235 Changes Ends
      END;
    END LOOP;
    CLOSE cur_anni_acct;
  END LOOP;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  o_err_code:=-99;
  o_err_msg :='Error in Anniversary job: '||sqlerrm||' - ' || dbms_utility.format_error_backtrace || ' Objid: ' || l_objid;
  sa.ota_util_pkg.err_log ( p_action => 'OTHERS EXCEPTION', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_acct_anniversary', p_error_text => 'input params: ' || 'i_rundate ='||i_rundate || ', o_err_code='||o_err_code || ', o_err_msg='|| o_err_msg );
END p_acct_anniversary;
--
PROCEDURE p_reward_bonus_points
(
i_rundate in date,
o_err_code out VARCHAR2,
o_err_msg out VARCHAR2
)
AS
  l_web_account_id       VARCHAR2(30);
  --v_subscriber_id        VARCHAR2(30);
  l_min                  VARCHAR2(30);
  l_esn                  VARCHAR2(30);
  l_reason               VARCHAR2(100);
  l_benefit_type         VARCHAR2(30);
  l_points               NUMBER;
  --c_bonus_pts            CONSTANT VARCHAR2(40) := 'BONUS_POINTS';
  c_add_action           CONSTANT VARCHAR2(40) := 'ADD';
  --c_user_objid           CONSTANT NUMBER       := 0;
  l_action               VARCHAR2(200);
  --l_service_plan_objid   NUMBER := NULL;
  l_out_total_points     NUMBER;
  l_inout_transaction_id NUMBER;
  v_o_err_code           NUMBER  := 0;
  v_o_err_msg            VARCHAR2(200) := null;
  --v_pts_catgry           VARCHAR2(40);
  v_point_acc_objid      NUMBER;
  v_brand                VARCHAR2(40);
  v_program_name         VARCHAR2(100);
  --pts                    NUMBER;
  l_bonus_trans_id       number;
  l_ENROLLMENT_STATUS    VARCHAR2(50):='NOT ENROLLED'; --Modified for 2269
  l_enrolled_status             VARCHAR2(30):='NOT ENROLLED'; --Modified for 2269
  l_eligible_status             VARCHAR2(20):='N'; --Modified for 2269
  input_validation_failed EXCEPTION;
  l_rundate         date:=nvl(i_rundate,sysdate); --Modified for 2269
  CURSOR cur_bonus
  IS
    SELECT
      bpl.web_account_id,
      bpl.min,
      bpl.esn ,
      bpl.points,
      bpl.action,
      bpl.reason,
      bpl.benefit_type
    FROM sa.x_reward_bonus_points_load bpl
    WHERE bpl.status = 'PENDING' ;

type rec_bonus_pts
IS
  TABLE OF cur_bonus%rowtype;
  tab_bonus_pts rec_bonus_pts;

  l_transaction_status     x_reward_benefit_transaction.transaction_status%type;     -- CR41473 PMistry 08/03/2016 LRP2

BEGIN
o_err_code:=0;
o_err_msg:='SUCCESS';

  OPEN cur_bonus;
  LOOP
    FETCH cur_bonus bulk collect INTO tab_bonus_pts limit 1000;
    EXIT
  WHEN tab_bonus_pts.count = 0;

    FOR i IN 1 .. tab_bonus_pts.count
    LOOP
    BEGIN
      l_web_account_id    := trim(regexp_replace(tab_bonus_pts(i).web_account_id,'[[:punct:]]', ''));

      l_min               := trim(regexp_replace(tab_bonus_pts(i).min,'[[:punct:]]', ''));
      l_esn               := trim(regexp_replace(tab_bonus_pts(i).esn,'[[:punct:]]', ''));
      l_points            := trim(tab_bonus_pts(i).points);
      l_action            := NVL(trim(SUBSTR(tab_bonus_pts(i).action, 1, 2000)), 'BONUS_POINTS');
      l_reason            := 'Business provided: '||trim(tab_bonus_pts(i).reason);
      l_benefit_type      := trim(tab_bonus_pts(i).benefit_type);

       IF l_web_account_id is null THEN
       BEGIN
        select distinct web.objid
        into l_web_account_id
        from TABLE_WEB_USER WEB, TABLE_X_CONTACT_PART_INST CONPI,TABLE_PART_INST PI_ESN, TABLE_PART_INST PI_MIN
        where PI_ESN.OBJID = CONPI.X_CONTACT_PART_INST2PART_INST
        and CONPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT
        and pi_esn.objid          = pi_min.part_to_esn2part_inst
        and (PI_ESN.PART_SERIAL_NO = l_esn
             OR PI_MIN.PART_SERIAL_NO =   l_min );
       EXCEPTION WHEN OTHERS THEN
          o_err_code           := -201;
          o_err_msg            := 'Web Account Id not found for ESN ' || l_esn;
          raise input_validation_failed;
       END;
       END IF;
       sa.REWARDS_MGT_UTIL_PKG.P_CUSTOMER_IS_ENROLLED (in_cust_key   => 'ACCOUNT',
          in_cust_value           => l_web_account_id,
          in_program_name         => 'LOYALTY_PROGRAM',
          in_enrollment_type      => 'PROGRAM_ENROLLMENT',
          in_brand                => 'STRAIGHT_TALK',
          out_enrollment_status   => l_ENROLLMENT_STATUS,
          out_enrollment_elig_status    => l_eligible_status, --Modified for 2269
          out_err_code            => O_ERR_CODE,
          out_err_msg               => O_ERR_MSG);


      IF l_ENROLLMENT_STATUS NOT IN ('ENROLLED','SUSPENDED','RISK ASSESSMENT') THEN
        o_err_code           := -200;
        o_err_msg            := 'Customer Is Not Enrolled - ' || l_web_account_id;
        raise input_validation_failed;
      END IF;

      IF f_expire_benefit (l_web_account_id) = 'EXPIRED' THEN --Modified for 2269
         o_err_code           := 1;
         o_err_msg            := 'Customer account Is Inactive for more than 60 days WEB_ACCOUNT: ' || l_web_account_id||' '||'MIN: ' || tab_bonus_pts(i).min;
         raise input_validation_failed;
      ELSE
          IF l_action    = 'DEDUCT' THEN
             l_points     := l_points * -1;
          END IF;

          BEGIN
              SELECT objid,
                brand,
                program_name
              INTO v_point_acc_objid,
                v_brand,
                v_program_name
              FROM x_reward_benefit
              WHERE web_account_id = l_web_account_id;
          EXCEPTION
          WHEN no_data_found THEN
            v_point_acc_objid  :=  seq_x_reward_benefit.nextval;

             INSERT INTO x_reward_benefit
                  (OBJID
                  ,WEB_ACCOUNT_ID
                  ,SUBSCRIBER_ID
                  ,MIN
                  ,ESN
                  ,BENEFIT_OWNER
                  ,CREATED_DATE
                  ,STATUS
                  ,NOTES
                  ,BENEFIT_TYPE_CODE
                  ,UPDATE_DATE
                  ,EXPIRY_DATE
                  ,BRAND
                  ,QUANTITY
                  ,PENDING_QUANTITY -- CR41473 - LRP2 - sethiraj
                  ,VALUE
                  ,PROGRAM_NAME
                  ,ACCOUNT_STATUS --Modified for 2269
                  ,TOTAL_QUANTITY -- CR41473 - LRP2 - sethiraj
                  )
          VALUES (v_point_acc_objid,
                    l_web_account_id,
                    null, --benefit.subscriber_id       ,
                    l_min,
                    l_esn,
                    'ACCOUNT',
                    i_rundate,
                    'AVAILABLE',
                    l_reason,
                    l_benefit_type,
                    null, --benefit.update_date         ,
                    null, --benefit.expiry_date      ,
                    'STRAIGHT_TALK', --benefit.brand           ,
                    l_points,
                    0,                -- CR41473 - LRP2 - sethiraj
                    null, --benefit.VALUE           ,
                    'LOYALTY_PROGRAM', --benefit.program_name
                    'ENROLLED', --Modified for 2269
                    l_points  -- CR41473 - LRP2 - sethiraj
             );

          WHEN OTHERS THEN
            v_o_err_code    := 1;
            v_o_err_msg  := 'Error in fetching x_reward_benefit objid for web_account_id: '||l_web_account_id;
            o_err_code := v_o_err_code;
            o_err_msg  := v_o_err_msg;
            v_point_acc_objid := NULL;
          END ;
          l_bonus_trans_id := rewards_mgt_pymt_pkg.f_get_transaction_id;

         IF v_o_err_code = 0 THEN
            rewards_mgt_pymt_pkg.p_create_benefit_trans (
            i_event_type    => 'BONUS',
            i_transaction_id => l_bonus_trans_id,
            i_trans_date    => sysdate,
            i_WEB_account_id => l_web_account_id,
            i_subscriber_id =>  null,
            i_min           => l_min,
            i_esn           => l_esn,
            i_old_min       => NULL,
            i_old_esn       => NULL,
            i_trans_type    => 'BATCH',
            i_trans_desc    => l_reason,
            i_amount        => l_points,
            i_benefit_type_CODE  => l_benefit_type,
            i_action        => l_action,
            i_action_type   => 'FREE',
            i_action_reason => l_reason,
            i_btrans2btrans => NULL,
            i_svc_plan_pin  => NULL,
            i_svc_plan_id   => NULL,
            i_brand         => v_brand,
            i_btrans2benefit      => v_point_acc_objid,
            o_transaction_status  => l_transaction_status);       -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.
            --
            rewards_mgt_util_pkg.p_update_benefit(  in_cust_key           => 'ACCOUNT',
                                                    in_cust_value         => l_web_account_id,
                                                    in_program_name       => NVL(v_program_name,'LOYALTY_PROGRAM'),
                                                    in_benefit_type       => NULL,
                                                    in_brand              => NVL(v_brand,'STRAIGHT_TALK'),
                                                    in_new_min            => NULL,
                                                    in_new_esn            => NULL,
                                                    in_new_status         => NULL,
                                                    in_new_notes          => NULL,
                                                    in_new_expiry_date    => NULL,
                                                    in_change_quantity    => l_points,
                                                    in_transaction_status => l_transaction_status,
                                                    in_value              => NULL,
                                                    in_account_status     => NULL
                                                  );
            /*
            UPDATE  x_reward_benefit b
            SET     quantity            = nvl(quantity,0) + l_points,                                                                                 -- CR41473 - LRP2 - sethriaj
                    update_date         = i_rundate
            WHERE   web_account_id = l_web_account_id;
            */
            --
            UPDATE sa.x_reward_bonus_points_load
            SET status    = 'SUCCESS'
            WHERE status  = 'PENDING'
            AND (web_account_id = tab_bonus_pts(i).web_account_id
              OR esn            = tab_bonus_pts(i).esn
              OR min            = tab_bonus_pts(i).min);

          ELSE

            UPDATE sa.x_reward_bonus_points_load
               SET status           = 'FAIL',
                  error_msg          = v_o_err_msg
            WHERE status  = 'PENDING'
              AND (web_account_id = tab_bonus_pts(i).web_account_id
                OR esn            = tab_bonus_pts(i).esn
                OR min            = tab_bonus_pts(i).min);

          END IF;
      END IF;
      EXCEPTION
      -- CR42235 Changes Starts
      WHEN DUP_VAL_ON_INDEX THEN
      o_err_code := -99;
      o_err_msg  := o_err_msg || chr(10) || 'Error: '||sqlerrm||' - ' || dbms_utility.format_error_backtrace || ' l_web_account_id: ' || l_web_account_id;
      -- CR42235 Changes Ends
      WHEN input_validation_failed THEN
        dbms_output.put_line('input_validation_failed others  '||SQLERRM ||' '||tab_bonus_pts(i).web_account_id);
         UPDATE sa.x_reward_bonus_points_load
            SET status           = 'FAIL',
                error_msg          = o_err_msg
          WHERE status  = 'PENDING'
            AND (web_account_id = tab_bonus_pts(i).web_account_id
              OR esn            = tab_bonus_pts(i).esn
              OR min            = tab_bonus_pts(i).min);

        o_err_msg:=o_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;
--Modified for CR41118
--        ota_util_pkg.err_log (p_action => 'CALLING p_reward_bonus_points', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_reward_bonus_points', p_error_text =>  'out_error_code='||o_err_code || ', out_error_msg='|| o_err_msg );
      WHEN OTHERS THEN
         o_err_msg:=o_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;
        ota_util_pkg.err_log (p_action => 'CALLING p_reward_bonus_points', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_reward_bonus_points', p_error_text =>  'out_error_code='||o_err_code || ', out_error_msg='|| o_err_msg );

          UPDATE x_reward_bonus_points_load
              SET status           = 'FAIL',
                  error_msg          = o_err_msg
            WHERE status  = 'PENDING'
              AND (web_account_id = tab_bonus_pts(i).web_account_id
                OR esn            = tab_bonus_pts(i).esn
                OR min            = tab_bonus_pts(i).min);
    END;
    END LOOP;
  END LOOP;
  CLOSE cur_bonus;
EXCEPTION
WHEN others THEN
  ROLLBACK;
  o_err_code := -99;
  o_err_msg  := 'p_reward_bonus_points='||substr(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace ;
  sa.ota_util_pkg.err_log ( p_action => 'OTHERS EXCEPTION', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_reward_bonus_points', p_error_text =>  'out_error_code='||o_err_code || ', out_error_msg='|| o_err_msg );
END p_reward_bonus_points;
--
-- CR41473 - LRP2 - sethiraj
PROCEDURE p_complete_transaction(
      i_rundate IN DATE,
    o_err_code OUT VARCHAR2,
    o_err_msg OUT VARCHAR2) IS
  --
  -- To pick all the transactions matured as of today
  CURSOR cur_trans IS
    SELECT benefit.objid     AS benefit_objid,
           benefit.program_name,
           benefit.benefit_type_code AS benefit_type,
           benefit.brand,
           trans.objid         AS trans_objid,
           trans.amount        AS matured_amount,
           'COMPLETE'          AS transaction_status,
           trans.esn           AS esn,
           trans.trans_type    AS trans_type,
           trans.trans_date    AS trans_date,
           trans.maturity_date AS maturity_date
      FROM x_reward_benefit_transaction trans,
           x_reward_benefit benefit
     WHERE TRUNC(trans.maturity_date)  < TRUNC(i_rundate)
       AND trans.benefit_trans2benefit = benefit.objid
       AND transaction_status          = 'PENDING';
  --
  v_recur_pmt NUMBER := 0;
  l_err_code  NUMBER;
  l_err_msg   VARCHAR2(200);
  v_expire_AR_days NUMBER;
  --
BEGIN
  --
  FOR rec_trans IN cur_trans
  LOOP --{
    IF rec_trans.trans_type = 'AUTO_REFILL'
    THEN --{
     DBMS_OUTPUT.PUT_LINE('AUTO_REFILL ESN:'||rec_trans.esn);

      BEGIN --{
       SELECT TO_NUMBER(x_param_value)
       INTO   v_expire_AR_days
       FROM   table_x_parameters
       WHERE  x_param_name = 'EXPIRE_AUTO_REFILL_LRP';
      EXCEPTION
      WHEN OTHERS THEN
       v_expire_AR_days := 0;
      END; --}


      SELECT COUNT(1)
      INTO   v_recur_pmt
      FROM   sa.x_program_purch_dtl dtl,
             sa.x_program_purch_hdr hdr
      WHERE  dtl.x_esn                  = rec_trans.esn
      AND    dtl.pgm_purch_dtl2prog_hdr = hdr.objid
      AND    hdr.x_payment_type         = 'RECURRING'
      AND    hdr.x_process_date         >= rec_trans.trans_date
      AND    hdr.x_ics_rflag            = 'ACCEPT';

      IF v_recur_pmt > 0
      THEN --{
       UPDATE x_reward_benefit
       SET    pending_quantity = pending_quantity - rec_trans.matured_amount,
              quantity         = quantity + rec_trans.matured_amount
       WHERE  objid            =  rec_trans.benefit_objid;

       --
       -- Update the benefit transaction status to COMPLETE
       UPDATE x_reward_benefit_transaction
        SET   transaction_status = rec_trans.transaction_status
       WHERE  objid              = rec_trans.trans_objid;

      ELSIF rec_trans.maturity_date + v_expire_AR_days < SYSDATE THEN--}{ --Expire after 3 days
       UPDATE x_reward_benefit
       SET    pending_quantity = pending_quantity - rec_trans.matured_amount,
              --expired_quantity = NVL(expired_quantity, 0) + rec_trans.matured_amount,
              total_quantity   = total_quantity - rec_trans.matured_amount
       WHERE  objid            =  rec_trans.benefit_objid;

       UPDATE x_reward_benefit_transaction
          SET transaction_status = 'FAILED'
        WHERE objid              = rec_trans.trans_objid;
      END IF; --}
    ELSE --}{

       UPDATE x_reward_benefit
       SET    pending_quantity = pending_quantity - rec_trans.matured_amount,
              quantity         = quantity + rec_trans.matured_amount
       WHERE  objid            =  rec_trans.benefit_objid;

       --
       -- Update the benefit transaction status to COMPLETE
       UPDATE x_reward_benefit_transaction
        SET   transaction_status = rec_trans.transaction_status
       WHERE  objid              = rec_trans.trans_objid;

     --
    END IF; --}
  END LOOP; --}
  --
  o_err_code := 0;
  o_err_msg  := 'Success';
EXCEPTION
WHEN OTHERS THEN
  o_err_code := -99;
  o_err_msg  := 'p_complete_transaction='||substr(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace ;
  sa.ota_util_pkg.err_log ( p_action => 'OTHERS EXCEPTION', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'p_complete_transaction', p_error_text =>  'out_error_code='||o_err_code || ', out_error_msg='|| o_err_msg );
END p_complete_transaction;
--
END REWARDS_BATCH_PKG;
/