CREATE OR REPLACE FUNCTION sa."BILLING_DEACTPROTECT"
  (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_DEACTPROTECT												 	 	 */
/*                                                                                          	 */
/* Purpose      :   Deactivation protection program												 */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   01-19-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
  --  p_webobjid  table_web_user.objid%TYPE,
    p_esn       x_program_enrolled.x_esn%TYPE
  )
  RETURN  NUMBER IS

  l_count   Number;

  CURSOR deactivation_c ( c_esn varchar2)
  is
    select a.objid enrollObjid, b.objid paramObjid, a.objid, a.x_enrollment_status, a.x_esn, a.x_exp_date,
           a.PGM_ENROLL2WEB_USER, a.PGM_ENROLL2SITE_PART, b.x_program_name, a.x_next_charge_date, b.x_is_recurring,
           a.x_sourcesystem
    from   x_program_enrolled a, x_program_parameters b
    where  a.PGM_ENROLL2PGM_PARAMETER = b.objid
    and    a.x_enrollment_status      = 'ENROLLED'
    and    b.x_charge_frq_code        = 'PASTDUE'
	and    a.X_WAIT_EXP_DATE 		  IS NULL
    and    a.x_esn                    = c_esn;
--    and    a.PGM_ENROLL2WEB_USER      = c_WebUserId;

  v_deactivation_rec     deactivation_c%ROWTYPE;

  l_expire_dt           DATE;

  l_return_code     Number;
  l_return_message  varchar2(255);
  l_pending_payment_flag NUMBER;

BEGIN

    /*
        It is possible that the customer may be enrolled into multiple de-activation programs.
        At this time, pick up the program that delivers the maximum benefits.
        Kludge: Currently work with a single deactivation protection program.
    */

    -- Check for deactivation protection enrollment.
    OPEN deactivation_c ( p_esn);
    fetch deactivation_c into v_deactivation_rec;
    if deactivation_c%NOTFOUND then
        return 0;       -- Not enrolled into deactivation protection program
    end if;
    CLOSE deactivation_c;

    -- Defect 339: It appears that this procedure has been called multiple times.
    --             We will supress it at this time itself
    if ( v_deactivation_rec.x_next_charge_date is not null ) then
        return 0; -- These are additional calls to the same ESN for deactivation. Just ignore subsequent calls
    end if;

    -- Check if there any pending payment against this deactivation protection program. ---------
    l_pending_payment_flag := BILLING_JOB_PKG.ISPAYMENTPROCESSINGPENDING(v_deactivation_rec.enrollObjid);
    if ( l_pending_payment_flag = 1 ) then
        return 0;   -- Pending payments exists. Allow deactivation to happen.
    end if;
    -- -------------------------------------------------------------------------------------------
    dbms_output.put_line('Delivering benefits for ' || to_char(v_deactivation_rec.enrollObjid ));
    /* Benefits cannot be delivered since the customer needs to be charged.
        At this point, we simply update the next charge date for the program and extend the service
        days grace period :: To be verified.

    --Billing_deliverbenefits ( v_deactivation_rec.enrollObjid, l_return_code, l_return_message );

        Code review of the existing deactivation protection shows that 10 days are added to exp. date.
    */
      SELECT x_expire_dt
           INTO l_expire_dt
           FROM TABLE_SITE_PART
          WHERE x_service_id = p_esn
                AND part_status = 'Active'
            ;


      /* For sample non-recurring program - deliver the benefits associated with the program */
      if ( v_deactivation_rec.x_is_recurring = 0 ) then
                    BILLING_DELIVERSERVICEDAYS ( v_deactivation_rec.enrollObjid, l_return_code, l_return_message );
                    --- DeEnroll the program
                    update x_program_enrolled
                       set x_enrollment_status = 'DEENROLLED',
                           x_exp_date          = null,
                           x_reason            = 'System Deenrollment',
                           x_update_stamp      = sysdate,
                           x_next_charge_date  = null,
                           PGM_ENROLL2X_PYMT_SRC = null
                     where objid = v_deactivation_rec.enrollObjid;

                    insert into x_program_trans
                     ( objid,
                       x_enrollment_status,
                       x_enroll_status_reason,
                       x_grace_period_given,
                       x_trans_date,
                       x_action_text,
                       x_action_type,
                       x_reason,
                       x_sourcesystem,
                       x_esn,
                       PGM_TRAN2PGM_ENTROLLED,
                       PGM_TRANS2WEB_USER,
                       PGM_TRANS2SITE_PART,
                       x_update_user
                     )
                    values
                    (
                      BILLING_SEQ('x_program_trans'),
                      v_deactivation_rec.x_enrollment_status,
                      'Deactivation Protection DeEnrolled',
                      null,
                      sysdate,
                      'System Deenrollment',
                      'DE_ENROLL',
                      v_deactivation_rec.x_program_name || '    Deactivation Protection Sample Program DeEnrollment',
                      v_deactivation_rec.x_sourcesystem,
                      v_deactivation_rec.x_esn,
                      v_deactivation_rec.enrollObjid,
                      v_deactivation_rec.PGM_ENROLL2WEB_USER,
                      v_deactivation_rec.PGM_ENROLL2SITE_PART,
                      'System'
                    );

                    commit;

                    return 1;

    else

                    /* As per discussions, use sysdate instead of l_expire_date */
                    --SERVICE_DEACTIVATION.SP_UPDATE_EXP_DATE_PRC(p_esn, l_expire_dt + 2, l_return_code, l_return_message );
                    SERVICE_DEACTIVATION.SP_UPDATE_EXP_DATE_PRC(p_esn, sysdate + 2, l_return_code, l_return_message );

                    if ( l_return_code = 0 ) then
                    /* Update the next charge date from the customer */
                        dbms_output.put_line('Before insert prog trans ');
                        insert into x_program_trans
                            ( objid,
                              x_enrollment_status,
                              x_enroll_status_reason,
                              x_grace_period_given,
                              x_trans_date,
                              x_action_text,
                              x_action_type,
                              x_reason,
                              X_SOURCESYSTEM,
                              x_esn,
                              PGM_TRAN2PGM_ENTROLLED,
                              PGM_TRANS2WEB_USER,
                              PGM_TRANS2SITE_PART,
                              x_update_user
                            )
                    values (
                              BILLING_SEQ('x_program_trans'),
                              v_deactivation_rec.x_enrollment_status,
                              'Deactivation Protection',
                              2,
                              sysdate,
                              'Deactivation Protection',
                              'DEACTPROTECT',
                              v_deactivation_rec.x_program_name || '    Deactivation Protection',
                              v_deactivation_rec.x_sourcesystem,
                              v_deactivation_rec.x_esn,
                              v_deactivation_rec.enrollObjid,
                              v_deactivation_rec.PGM_ENROLL2WEB_USER,
                              v_deactivation_rec.PGM_ENROLL2SITE_PART,
                              'System'
                            );


                          /*
                            Schedule the program for payment for midnight.
                          */
                         update x_program_enrolled
                            set x_next_charge_date = trunc(sysdate),
                                X_SERVICE_DAYS = 2
                          where objid = v_deactivation_rec.enrollObjid;
                           dbms_output.put_line('After program enrolled update ');

                         commit;

                         return 1;    -- Success
                else
                         return l_return_code; -- Return code as returned by the deliverybenefits procedure
                end if;

    end if;

EXCEPTION
   WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       return -100;
END; -- Function BILLING_DEACTPROTECT
/