CREATE OR REPLACE FUNCTION sa."BILLING_GETPAYMENTDETAILS" (p_purch_hdr_objid IN NUMBER -- Payment Header Objid Id
                                                        ) RETURN VARCHAR2 IS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: BILLING_GETPAYMENTDETAILS.sql,v $
  --$Revision: 1.4 $
  --$Author: kacosta $
  --$Date: 2012/08/08 18:13:46 $
  --$ $Log: BILLING_GETPAYMENTDETAILS.sql,v $
  --$ Revision 1.4  2012/08/08 18:13:46  kacosta
  --$ CR20288 Changes in MyAccount payment history
  --$
  --$ Revision 1.3  2012/02/21 22:51:15  kacosta
  --$ CR18997 ST Fix for Activation with Credit Card - Payment History
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  /*
  This function returns the payment details associated with a purchase header.
  This is used in the payment logs for display of details associated with
  a payment.
  */

  l_payment_details VARCHAR2(4000);

  CURSOR c_enrollment_details(c_purch_objid NUMBER) IS
    SELECT a.x_esn
          ,billing_getnickname(a.x_esn) nickname
          ,c.x_program_name
           -- CR20288 Start KACOSTA 08/08/2012
           --,TO_CHAR((a.x_amount + a.x_tax_amount + a.x_e911_tax_amount + a.x_usf_taxamount + a.x_rcrf_tax_amount)
           --        ,'$999999999999.99') x_total_amount
          ,TO_CHAR((a.x_amount + a.x_tax_amount + a.x_e911_tax_amount + pph.x_usf_taxamount + pph.x_rcrf_tax_amount)
                  ,'$999999999999.99') x_total_amount
           -- CR20288 End KACOSTA 08/08/2012
          , --CR11553
           --c.x_incl_service_days
           -- Modified by Ramu for defect 59
           DECODE(c.x_charge_frq_code
                 ,NULL
                 ,'No Next Payment'
                 ,'MONTHLY'
                 ,'Every Month.'
                 ,'PASTDUE'
                 ,'On Past Due.'
                 ,'LOWBALANCE'
                 ,'Low Balance.'
                 ,'0'
                 ,'No Next Payment'
                 ,'null'
                 ,'No Next Payment'
                 ,'Every ' || c.x_charge_frq_code || ' day(s).') x_charge_frq
          ,(SELECT x_payment_type
              FROM x_program_purch_hdr
             WHERE objid = c_purch_objid) x_payment_type
          ,
           -- Added by Ramu for defect 107
           (SELECT TO_CHAR((x_amount + x_tax_amount + a.x_e911_tax_amount + a.x_usf_taxamount + a.x_rcrf_tax_amount)
                          ,'$999999999.99') --CR11553
              FROM x_program_purch_hdr
             WHERE objid = c_purch_objid) x_total_amount_old
          ,b.pgm_enroll2x_promotion
          ,a.pgm_purch_dtl2penal_pend
      FROM x_program_purch_dtl  a
          ,x_program_enrolled   b
          ,x_program_parameters c
           -- CR20288 Start KACOSTA 08/08/2012
          ,x_program_purch_hdr pph
    -- CR20288 End KACOSTA 08/08/2012
     WHERE a.pgm_purch_dtl2prog_hdr = c_purch_objid
       AND a.pgm_purch_dtl2pgm_enrolled = b.objid
       AND b.pgm_enroll2pgm_parameter = c.objid
          -- CR20288 Start KACOSTA 08/08/2012
       AND pph.objid = a.pgm_purch_dtl2prog_hdr
    -- CR20288 End KACOSTA 08/08/2012
     ORDER BY c.objid
             ,b.x_is_grp_primary DESC;

  c_enrollment_details_rec c_enrollment_details%ROWTYPE;

  l_incl_days      NUMBER;
  v_promotion_text VARCHAR2(4000);
  v_promotion_type VARCHAR2(20);

BEGIN
  -- Get the enrollment details for which the payment was requested.
  OPEN c_enrollment_details(p_purch_hdr_objid);
  LOOP
    FETCH c_enrollment_details
      INTO c_enrollment_details_rec;
    EXIT WHEN c_enrollment_details%NOTFOUND;

    --- Create the string for logging:

    IF (l_payment_details IS NOT NULL) THEN
      l_payment_details := l_payment_details || ' \n ';
      dbms_output.put_line('Added suffix ');
    END IF;

    -- Added for not displaying the Transaction Details if this is a PayNow transaction
    -- and amount is $0.00
    IF (c_enrollment_details_rec.x_payment_type = 'PAYNOW' AND TRIM(c_enrollment_details_rec.x_total_amount) = '$0.00') THEN
      IF l_payment_details IS NULL THEN
        l_payment_details := c_enrollment_details_rec.x_esn || ' ' || c_enrollment_details_rec.x_program_name || ' ' || TRIM(c_enrollment_details_rec.x_total_amount);
      ELSE
        l_payment_details := l_payment_details;
      END IF;
      -- Added by Ramu to append the text 'Penalty' if it is a Penalty Amount
    ELSIF (c_enrollment_details_rec.pgm_purch_dtl2penal_pend IS NOT NULL) THEN
      l_payment_details := l_payment_details || ' Penalty : ' || c_enrollment_details_rec.x_esn || ' ' || c_enrollment_details_rec.x_program_name || ' ' || TRIM(c_enrollment_details_rec.x_total_amount);

    ELSE
      l_payment_details := l_payment_details || c_enrollment_details_rec.x_esn || ' ' || c_enrollment_details_rec.x_program_name || ' ' || TRIM(c_enrollment_details_rec.x_total_amount);
    END IF;

    /*
    --- Get the included service days provided by the enrollment. -----------------------------------------
    BEGIN
    SELECT x_access_days
    into l_incl_days
    FROM table_x_promotion
    WHERE objid = c_enrollment_details_rec.x_incl_service_days
    AND x_promo_type = 'BPRedemption'
    AND sysdate between x_start_date and x_end_date;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    l_incl_days := null;
    END;
    -------------------------------------------------------------------------------------------------------
    if ( l_incl_days is not null ) then
    l_payment_details := l_payment_details || ' ' || to_char(l_incl_days) || ' days';
    end if;
    */

  END LOOP;
  CLOSE c_enrollment_details;
  -- Added for not displaying the Charge Frequency Details if this is a PayNow transaction
  IF (c_enrollment_details_rec.x_payment_type != 'PAYNOW') THEN
    l_payment_details := l_payment_details || ' ' || c_enrollment_details_rec.x_charge_frq;
  END IF;

  -- Added by Ramu to insert the Promotion Details if any Promo Code is applied while
  -- Enrollment
  IF (c_enrollment_details_rec.pgm_enroll2x_promotion IS NOT NULL AND (c_enrollment_details_rec.x_payment_type = 'PAYNOW' OR c_enrollment_details_rec.x_payment_type = 'RECURRING')) THEN
    --CR18997 Start Kacosta 02/21/2012
    BEGIN
      --CR18997 End Kacosta 02/21/2012
      SELECT x_promotion_text
            ,x_transaction_type
        INTO v_promotion_text
            ,v_promotion_type
        FROM table_x_promotion
       WHERE objid = c_enrollment_details_rec.pgm_enroll2x_promotion;
      IF (v_promotion_text IS NOT NULL AND v_promotion_type != 'ONETIME') THEN
        l_payment_details := l_payment_details || ' \n' || v_promotion_text || v_promotion_type;
      END IF;
      --CR18997 Start Kacosta 02/21/2012
    EXCEPTION
      WHEN others THEN
        --
        NULL;
        --
    END;
    --CR18997 End Kacosta 02/21/2012
  ELSIF (c_enrollment_details_rec.pgm_enroll2x_promotion IS NOT NULL AND (c_enrollment_details_rec.x_payment_type = 'ENROLLMENT')) THEN
    --CR18997 Start Kacosta 02/21/2012
    BEGIN
      --CR18997 End Kacosta 02/21/2012
      SELECT x_promotion_text
        INTO v_promotion_text
        FROM table_x_promotion
       WHERE objid = c_enrollment_details_rec.pgm_enroll2x_promotion;
      IF (v_promotion_text IS NOT NULL) THEN
        l_payment_details := l_payment_details || ' \n' || v_promotion_text;
      END IF;
      --CR18997 Start Kacosta 02/21/2012
    EXCEPTION
      WHEN others THEN
        --
        NULL;
        --
    END;
    --CR18997 End Kacosta 02/21/2012
    --l_payment_details := l_payment_details || ' \n' || v_promotion_text;
  END IF;

  RETURN l_payment_details;
EXCEPTION
  WHEN others THEN
    l_payment_details := '';
    --CR18997 Start Kacosta 02/21/2012
    RETURN l_payment_details;
    --CR18997 End Kacosta 02/21/2012
END;
-- Function SA.BILLING_GETPAYMENTDETAILS
/