CREATE OR REPLACE FUNCTION sa."BILLING_CAN_PAYNOW"
  (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_CAN_PAYNOW													 	 	 */
/*                                                                                          	 */
/* Purpose      :   Validated pay now process													 */
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
    p_enroll_objid      x_program_enrolled.objid%TYPE,
    p_payment_src_objid x_payment_source.objid%TYPE                        -- ACH/CC
  )
  RETURN  NUMBER IS

  /* -----------------------------------------------------------------------------------------
        This procedure returns whether PayNow can be done at this time.
        For ACH, if a next charge date is within 5 days, Paynow cannot be done.
        For CC, if the next charge date is within 4 hrs of the payment batch run, then paynow is not
        allowed.
        ASSUMPTION: Billing_Is_PayNow_Enabled is called prior to this in the workflow.
     ------------------------------------------------------------------------------------------------ */
  l_next_charge_date     DATE;
  l_payment_type         varchar2(30);
BEGIN

    BEGIN
    select x_next_charge_date
    into   l_next_charge_date
    from   x_program_enrolled
    where  objid = p_enroll_objid
      and  x_enrollment_status = 'ENROLLED';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            return 1; -- Since the customer has already clicked PayNow, and this is not a future payment allow Paynow.
    END;

    select X_PYMT_TYPE into l_payment_type
    from   X_PAYMENT_SOURCE
    where  objid = p_payment_src_objid;

    if ( l_payment_type = 'ACH' ) then
        if ( l_next_charge_date - sysdate < 5 ) then
            return 0; -- Cannot do a paynow.
        end if;
    else  --- Payment type is CREDITCARD. Allow upto 4 hrs of charge.
        if (trunc(sysdate) >= trunc(l_next_charge_date) ) then -- 4hrs from now.
            return 0;   -- Cannot do a paynow.
        end if;
    end if;

    RETURN 1;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
       return 0;    -- Unable to find entry in the payment source table. Most probably funding source not created properly
   WHEN OTHERS THEN
       return 0 ;   -- Any database error
END; -- Function BILLING_CAN_PAYNOW
/