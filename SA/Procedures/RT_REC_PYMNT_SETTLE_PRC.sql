CREATE OR REPLACE PROCEDURE sa."RT_REC_PYMNT_SETTLE_PRC" ( i_process_date IN DATE DEFAULT SYSDATE ) AS

  -- Cursor definition to retrieve records to payment settlement
  CURSOR pay_settle_cur IS
   SELECT  xse.objid                 sub_enroll_objid        ,
           xse.bill_acct_num         sub_enroll_ban          ,
           xse.wu_objid              sub_enroll_wuobjid      ,
           xse.x_esn                 sub_enroll_esn          ,
           pph.x_merchant_ref_number pph_merchant_ref_number ,
           pph.x_auth_amount         pph_auth_amount         ,
           CASE
           WHEN  pph.x_ics_rcode = 1   THEN 1
           WHEN  pph.x_ics_rcode = 100 THEN 1
           ELSE
           0
           END                     pph_bill_result    ,
           pph.x_ics_rcode         pph_ics_rcode
    FROM   x_subscriber_enrollments xse,
           x_program_enrolled       pe ,
           x_program_purch_hdr      pph,
           x_program_purch_dtl      ppd
    WHERE 1 = 1
    AND   xse.pgm_enrolled_objid         = pe.objid
    AND   pe.objid                       = ppd.pgm_purch_dtl2pgm_enrolled
    AND   ppd.pgm_purch_dtl2prog_hdr     = pph.objid
   -- AND   pe.x_enrollment_status         IN ('ENROLLED','ENROLLMENTSCHEDULED') --commented based on request
    AND   xse.bill_acct_num              IS NOT NULL
    AND   xse.x_esn                      = pe.x_esn
    --AND   pph.x_payment_type             = 'RECURRING' -- Commented based on architecture's request
    AND   pph.prog_hdr2prog_batch        IS NOT NULL
    AND   pph.x_process_date BETWEEN TRUNC(i_process_date) AND TRUNC(i_process_date) + .99999;
    -- Commented based on architecture's request
    /*AND   NOT EXISTS (SELECT '1'
                      FROM   x_enroll_event_log eel
                      WHERE  eel.x_esn              =  xse.x_esn
                      AND    eel.event_send_status  <> 'I'
                      AND    eel.event_generate_date = pph.x_process_date
                      ); */

   -- Variables declaration
   payload    q_payload_t                     ;
   nameval    q_nameval_tab := q_nameval_tab();
   op_msg     VARCHAR2(400)                   ;
   l_min      VARCHAR2(30)                    ;
   l_brand    VARCHAR2(30)                    ;

BEGIN -- Main Section

  --Loop through the payment settle cursor
  FOR pay_settle_rec in pay_settle_cur
  LOOP

    -- Calling the customer type get_bus_org_id method
    l_brand  := sa.util_pkg.get_bus_org_id ( i_esn => pay_settle_rec.sub_enroll_esn );

    -- To retrieve MIN by ESN
    l_min := sa.util_pkg.get_min_by_esn(i_esn => pay_settle_rec.sub_enroll_esn);

	--Initialize
	nameval  := q_nameval_tab();

    --
    sa.queue_pkg.add_nameval_elmt('SOURCE'            ,'Clarify'                              ,nameval);
    sa.queue_pkg.add_nameval_elmt('WEB_USER_OBJID'    ,pay_settle_rec.sub_enroll_wuobjid      ,nameval);
    sa.queue_pkg.add_nameval_elmt('BRM_EMS_OBJID'     ,pay_settle_rec.sub_enroll_objid        ,nameval);
    sa.queue_pkg.add_nameval_elmt('BRM_ACCOUNT_NO'    ,pay_settle_rec.sub_enroll_ban          ,nameval);
    sa.queue_pkg.add_nameval_elmt('PAY_TRANS_ID'      ,pay_settle_rec.pph_merchant_ref_number ,nameval);
    sa.queue_pkg.add_nameval_elmt('PAY_AMOUNT'        ,pay_settle_rec.pph_auth_amount         ,nameval);
    sa.queue_pkg.add_nameval_elmt('RESULT'            ,pay_settle_rec.pph_bill_result         ,nameval);
    sa.queue_pkg.add_nameval_elmt('PAY_DECLINE_CODE'  ,pay_settle_rec.pph_ics_rcode           ,nameval);

    -- Assigning to pay load for EMS
     payload := q_payload_t('ENROLLMENTS'                 , --source_type
                            'X_PROGRAM_ENROLLED'          , --source_tbl
                            'COMPLETE'                    , --source_status
                            pay_settle_rec.sub_enroll_esn , --esn
                            l_min                         , --min
                            l_brand                       , --brand
                            'PAYMENTSETTLE'               , --event_name
                            nameval                       , --varray
                            'INIT'                        --Step complete
                            );
      --
      IF NOT (sa.queue_pkg.enq(i_q_name      => 'SA.CLFY_MAIN_Q' ,
                               io_q_payload  =>  payload         ,
                               o_op_msg      =>  op_msg          ))
      THEN

        sa.util_pkg.insert_error_tab(i_action        => 'Writing queue: CLFY_MAIN_Q',
                                     i_key           =>  payload.esn             ,
                                     i_program_name  => 'rt_rec_pymnt_settle_prc',
                                     i_error_text    =>  op_msg
                                     );
      ELSE
      --
      BEGIN
        -- Insert record into enroll event log table
        INSERT
        INTO   sa.x_enroll_event_log
               ( x_esn               ,
                 event               ,
                 event_send_status   ,
                 event_generate_date
                )
        VALUES  ( payload.esn,
        	  payload    ,
        	  'I'        , -- 'I' means initialization (Init) This record will be updated by SOA E(Error) or C (Completed)
        	  SYSDATE
        	  );

       EXCEPTION
         WHEN OTHERS THEN
           util_pkg.insert_error_tab ( i_action        => 'Insert into X_ENROLL_EVENT_LOG table' ,
                                       i_key           =>  payload.esn                           ,
                                       i_program_name  => 'rt_rec_pymnt_settle_prc'              ,
                                       i_error_text    => SUBSTR(SQLERRM,1,200)                  );
      END;

      -- Commit for every transaction
      COMMIT;

    END IF;

  --
  END LOOP; -- End of FOR Loop

 EXCEPTION
   WHEN OTHERS THEN
     util_pkg.insert_error_tab( i_action        => 'MAIN EXCEPTION: BRM Payment Settlement',
                                i_key           =>  payload.esn                            ,
                                i_program_name  => 'rt_rec_pymnt_settle_prc'               ,
                                i_error_text    => SUBSTR(SQLERRM,1,200)
                                );

END rt_rec_pymnt_settle_prc;
/