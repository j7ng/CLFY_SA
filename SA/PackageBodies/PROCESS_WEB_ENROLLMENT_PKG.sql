CREATE OR REPLACE PACKAGE BODY sa.process_web_enrollment_pkg IS
-- Pre payment procs start
PROCEDURE p_get_enrollment_details( i_esn              IN  VARCHAR2 ,
                                    i_program_param_id IN  NUMBER   ,
                                    i_language         IN  VARCHAR2 ,
                                    o_enrl_objid       OUT  NUMBER  ,
                                    o_enrl_status      OUT VARCHAR2 ,
                                    o_code_num         OUT VARCHAR2 ,
                                    o_code_desc        OUT VARCHAR2 ,
                                    o_pb_error_code    OUT NUMBER   ,
                                    o_pb_error_msg     OUT VARCHAR2 ,
                                    o_error_code       OUT NUMBER   ,
                                    o_error_msg        OUT VARCHAR2 ) IS

  n_enroll_days   NUMBER;
  n_noof_paymns   NUMBER;
BEGIN

  IF i_esn IS NULL OR
     i_program_param_id IS NULL
  THEN
    o_error_code    := 702;
    o_error_msg     := 'I_ESN OR I_PROGRAM_PARAM_ID VARIABLES ARE PASSING AS NULL!!';
    RETURN;
  END IF;

  BEGIN
    SELECT objid,
           x_enrollment_status
    INTO   o_enrl_objid,
           o_enrl_status
    FROM   x_program_enrolled
    WHERE  pgm_enroll2pgm_parameter = i_program_param_id
    AND    x_esn = i_esn
    AND    ROWNUM = 1;
  EXCEPTION
  WHEN no_data_found
  THEN
	o_error_code    := 0;
	o_error_msg     := 'SUCCESS';
	o_enrl_objid    := NULL;
	o_enrl_status   := NULL;
	RETURN;
  WHEN OTHERS THEN
    o_error_code    := 702;
    o_error_msg     := SQLCODE||' - '||SUBSTR(SQLERRM, 1, 300);
    RETURN;
  END;

  IF o_enrl_status = 'ENROLLED' AND
     o_enrl_objid IS NOT NULL
  THEN
    BEGIN
      SELECT TO_NUMBER(x_param_value)
      INTO   n_enroll_days
      FROM   table_x_parameters
      WHERE  x_param_name = 'DUPLICATE_ENROLLMENT_PURCHASE'
      AND    ROWNUM = 1;
    EXCEPTION
    WHEN OTHERS
	THEN
      n_enroll_days    := 0;
    END;

	SELECT COUNT(1)
	INTO   n_noof_paymns
	FROM   x_program_purch_hdr ph
	INNER JOIN x_program_purch_dtl pd ON pd.pgm_purch_dtl2prog_hdr = ph.objid
	WHERE  pd.pgm_purch_dtl2pgm_enrolled = i_program_param_id
	AND    x_rqst_date >= TRUNC (SYSDATE - n_enroll_days)
	AND    x_merchant_id IS NOT NULL
	AND    x_ics_rcode IN ('1','100')
	AND    x_bill_trans_ref_no IS NOT NULL
	AND    ph.prog_hdr2prog_batch IS NULL;

    IF n_noof_paymns > 0 THEN
      BEGIN
        SELECT txpc.x_code_num,
               txpc.x_code_descr,
               txpc.objid,
               txpc.x_internal_doc
        INTO   o_code_num,
               o_code_desc,
               o_pb_error_code,
               o_pb_error_msg
        FROM   table_x_purch_codes txpc
        WHERE  txpc.x_app = 'process_enrollment'
        AND    txpc.x_code_type = 'PB_err'
        AND    txpc.x_code_value = 'PB116'
        AND    txpc.x_language = i_language
        AND rownum = 1;
      EXCEPTION
      WHEN no_data_found
	  THEN
        o_error_code    := 702;
        o_error_msg     := 'NO DATA FOUND FROM TABLE_X_PURCH_CODES FOR GIVEN LANGUAGE!!';
		RETURN;
	  WHEN OTHERS
	  THEN
        o_error_code    := 702;
        o_error_msg     := 'NO DATA FOUND FROM TABLE_X_PURCH_CODES FOR GIVEN LANGUAGE!! ' || SQLERRM;
		RETURN;
	  END;
    ELSE
      o_enrl_objid  := NULL;
    END IF;
  END IF;

  o_error_code    := 0;
  o_error_msg     := 'SUCCESS';

 EXCEPTION
 WHEN OTHERS
 THEN
    o_error_code    := 702;
    o_error_msg     := ' ERROR IN PROCESS_WEB_ENROLLMENT_PKG.P_GET_ENROLLMENT_DETAILS PROCEDURE. ' || SQLERRM;
END p_get_enrollment_details;
    --
PROCEDURE p_get_purch_error_code ( i_application   IN  VARCHAR2 ,
                                   i_code_type     IN  VARCHAR2 ,
                                   i_code_value    IN  VARCHAR2 ,
                                   i_language      IN  VARCHAR2 ,
                                   o_code_num      OUT VARCHAR2 ,
                                   o_code_desc     OUT VARCHAR2 ,
                                   o_error_code    OUT NUMBER   ,
                                   o_error_msg     OUT VARCHAR2 ) IS
BEGIN

  IF i_application IS NULL OR
     i_language IS NULL OR
	 i_code_type IS NULL OR
	 i_code_value IS NULL
  THEN
    o_error_code    := 702;
    o_error_msg     := 'ALL INPUT VARIABLES ARE MANDATORY!!';
    RETURN;
  END IF;

  SELECT txpc.x_code_num,
         txpc.x_code_descr
  INTO   o_code_num,
         o_code_desc
  FROM   table_x_purch_codes txpc
  WHERE  txpc.x_app = i_application
  AND    txpc.x_code_type = i_code_type
  AND    txpc.x_code_value = i_code_value
  AND    txpc.x_language = i_language
  AND    ROWNUM = 1;

  o_error_code    := 0;
  o_error_msg     := 'SUCCESS';

 EXCEPTION
 WHEN OTHERS
 THEN
   o_error_code    := 702;
   o_error_msg     := 'ERROR IN PROCESS_WEB_ENROLLMENT_PKG.P_GET_PURCH_ERROR_CODE PROCEDURE.!!' || SQLERRM;
END p_get_purch_error_code;
    --
PROCEDURE p_insert_program_purch_dtl ( i_esn               IN  VARCHAR2 ,
									   i_charge_amount     IN  NUMBER   ,
									   i_charge_desc       IN  VARCHAR2 ,
									   i_next_charge_date  IN  DATE     ,
									   i_program_enroll_id IN  NUMBER   ,
									   i_purch_hdr_id      IN  NUMBER   ,
									   i_combs_tax_amount  IN  NUMBER   ,
									   i_e911_tax_amount   IN  NUMBER   ,
									   i_usf_tax_amount    IN  NUMBER   ,
									   i_rcrf_tax_amount   IN  NUMBER   ,
									   o_error_code        OUT NUMBER   ,
									   o_error_msg         OUT VARCHAR2 ) IS
  t_ppd program_purch_dtl_type := program_purch_dtl_type();
BEGIN

  IF i_esn IS NULL OR
     i_charge_amount IS NULL
  THEN
    o_error_code    := 702;
    o_error_msg     := 'I_ESN OR I_CHARGE_AMOUNT VARIABLES DATA IS MISSING!!';
    RETURN;
  END IF;

  t_ppd.esn                         := i_esn;
  t_ppd.amount                      := i_charge_amount;
  t_ppd.charge_desc                 := i_charge_desc;
  t_ppd.cycle_start_date            := SYSDATE;
  t_ppd.cycle_end_date              := i_next_charge_date;
  t_ppd.pgm_purch_dtl2pgm_enrolled  := i_program_enroll_id;
  t_ppd.pgm_purch_dtl2prog_hdr      := i_purch_hdr_id;
  t_ppd.tax_amount                  := i_combs_tax_amount;
  t_ppd.e911_tax_amount             := i_e911_tax_amount;
  t_ppd.usf_taxamount               := i_usf_tax_amount;
  t_ppd.rcrf_tax_amount             := i_rcrf_tax_amount;

  t_ppd := t_ppd.ins ( i_program_purch_dtl_type => t_ppd );

  IF t_ppd.response NOT LIKE '%SUCCESS%'
  THEN
    o_error_code    := 702;
    o_error_msg     := 'PPD ERR :'||t_ppd.response;
    RETURN;
  END IF;

  o_error_code    := 0;
  o_error_msg     := 'SUCCESS';
 EXCEPTION
 WHEN OTHERS
 THEN
  o_error_code    := 702;
  o_error_msg     := ' ERROR IN PROCESS_WEB_ENROLLMENT_PKG.P_INSERT_PROGRAM_PURCH_DTL PROCEDURE. ' || SQLERRM;
END p_insert_program_purch_dtl;
--
PROCEDURE p_get_program_details ( i_program_param_id     IN  NUMBER             ,
                                  o_program_details_tab  OUT program_details_tab,
                                  o_error_code           OUT NUMBER             ,
                                  o_error_msg            OUT VARCHAR2           ) IS
BEGIN

  IF i_program_param_id IS NULL
  THEN
    o_error_code    := 702;
    o_error_msg     := 'I_PROGRAM_PARAM_ID VARIABLE IS NULL!!';
    RETURN;
  END IF;

  SELECT program_details_type( pgmprm.x_web_channel,
  		                     TRUNC(pgmprm.x_start_date),
  		                     TRUNC(pgmprm.x_end_date),
  		                     bus.s_org_id
  	                       )
  BULK COLLECT INTO o_program_details_tab
  FROM  table_x_pricing price,
        table_part_num pn,
        table_bus_org bus,
        x_program_parameters pgmprm,
  	  ( SELECT pgmprm.objid,
  	           x_retail_price monfee
          FROM   table_x_pricing price,
                 table_part_num pn,
                 x_program_parameters pgmprm
          WHERE  price.x_pricing2part_num = pn.objid
          AND    price.x_end_date > TRUNC(SYSDATE)
          AND    price.x_start_date <= TRUNC(SYSDATE)
          AND    pgmprm.prog_param2prtnum_monfee = pn.objid
          AND    pgmprm.objid = i_program_param_id
         ) tab1,
        ( SELECT pgmprm.objid,
  	           x_retail_price grpenrfee
          FROM   table_x_pricing price,
                 table_part_num pn,
                 x_program_parameters pgmprm
          WHERE  price.x_pricing2part_num = pn.objid
          AND    price.x_end_date > TRUNC(SYSDATE)
          AND    price.x_start_date <= TRUNC(SYSDATE)
          AND    pgmprm.prog_param2prtnum_grpenrlfee = pn.objid
          AND    pgmprm.objid = i_program_param_id
         ) tab2,
        ( SELECT pgmprm.objid,
  	           x_retail_price grpmonfee
          FROM   table_x_pricing price,
                 table_part_num pn,
                 x_program_parameters pgmprm
          WHERE  price.x_pricing2part_num = pn.objid
          AND    price.x_end_date > TRUNC(SYSDATE)
          AND    price.x_start_date <= TRUNC(SYSDATE)
          AND    pgmprm.prog_param2prtnum_grpmonfee = pn.objid
          AND    pgmprm.objid = i_program_param_id
         ) tab3
  WHERE  tab3.objid(+) = pgmprm.objid
  AND    tab2.objid(+) = pgmprm.objid
  AND    tab1.objid = pgmprm.objid
  AND    price.x_pricing2part_num = pn.objid
  AND    price.x_end_date > TRUNC(SYSDATE)
  AND    price.x_start_date <= TRUNC(SYSDATE)
  AND    pgmprm.prog_param2prtnum_enrlfee = pn.objid
  AND    bus.objid = pgmprm.prog_param2bus_org
  AND    pgmprm.objid = i_program_param_id;

  o_error_code    := 0;
  o_error_msg     := 'SUCCESS';
 EXCEPTION
 WHEN OTHERS
 THEN
   o_error_code    := 702;
   o_error_msg     := ' ERROR IN PROCESS_WEB_ENROLLMENT_PKG.P_GET_PROGRAM_DETAILS PROCEDURE. ' || SQLERRM;
END p_get_program_details;
	--
PROCEDURE p_insert_program_enrolled ( i_esn               	    IN  VARCHAR2 ,
	                                  i_program_param_id 		IN  NUMBER   ,
                                      i_program_type      	    IN  VARCHAR2 ,
                                      i_next_charge_date  	    IN  DATE     ,
	                                  i_enrl_reason       	    IN  VARCHAR2 ,
	                                  i_action_type			    IN	VARCHAR2 ,
	                                  i_action_txt			    IN  VARCHAR2 ,
	                                  i_web_user_id			    IN  NUMBER   ,
	                                  i_payment_src_id			IN  NUMBER   ,
	                                  i_purch_hdr_id      	    IN  NUMBER   ,
                                      i_promo_objid       	    IN  NUMBER   ,
                                      i_agent_name  		    IN  VARCHAR2 ,
                                      i_bus_org   			    IN  VARCHAR2 ,
                                      i_source_system    		IN  VARCHAR2 ,
                                      i_language      			IN  VARCHAR2 ,
	                                  o_program_name			OUT	VARCHAR2 ,
	                                  o_prog_enrl_id			OUT NUMBER   ,
	                                  o_prog_trans_id			OUT NUMBER   ,
	                                  o_prog_charge_freq		OUT VARCHAR2 ,
	                                  o_prog_cycle_start_date 	OUT DATE     ,
	                                  o_prog_cycle_end_date	    OUT DATE     ,
	                                  o_prog_enrollmt_fee		OUT NUMBER   ,
	                                  o_prog_monthly_fee		OUT NUMBER   ,
	                                  o_prog_is_recurring		OUT VARCHAR2 ,
                                      o_error_code        	    OUT NUMBER   ,
                                      o_error_msg         	    OUT VARCHAR2 ) IS
  n_pec_enrl_cnt 			NUMBER;
  t_pet 					program_enrolled_type   :=  program_enrolled_type ();
  n_pgm_enroll2site_part 	table_site_part.objid%TYPE;
  n_pgm_enroll2part_inst 	table_part_inst.objid%TYPE;
  n_pgm_enroll2contact   	table_part_inst.x_part_inst2contact%TYPE;
  t_ppt 					program_trans_type := program_trans_type();
  t_cst               		customer_type;
  t_c                 		customer_type;
BEGIN

  IF i_program_param_id IS NULL OR
     i_bus_org IS NULL OR
	 i_payment_src_id IS NULL
  THEN
    o_error_code    := 702;
    o_error_msg     := 'I_BUS_ORG OR I_PROGRAM_PARAM_ID OR I_PAYMENT_SRC_ID VARIABLE IS NULL!!';
    RETURN;
  END IF;

  BEGIN
    SELECT xpp.x_program_name,
           NVL(CASE
               WHEN xpp.prog_param2prtnum_enrlfee IS NOT NULL
  			   THEN
  			   ( SELECT Max(txp.x_retail_price)
  			     FROM   table_x_pricing txp,
  			            table_part_num   pn
  			     WHERE  pn.objid = xpp.prog_param2prtnum_enrlfee
  			     AND    pn.objid = txp.x_pricing2part_num
  			     AND    txp.x_end_date > TRUNC(SYSDATE)
  			     AND    txp.x_start_date <= TRUNC(SYSDATE))
  			   END, 0 ) enrfee,
  		  NVL(CASE
  		      WHEN xpp.prog_param2prtnum_monfee IS NOT NULL
  		  	  THEN
  		        ( SELECT Max(txp.x_retail_price)
  		  	      FROM   table_x_pricing txp,
  		  	             table_part_num pn
  		  	      WHERE  pn.objid = xpp.prog_param2prtnum_monfee
  		  	      AND    pn.objid = txp.x_pricing2part_num
  		  	      AND    txp.x_end_date > TRUNC(SYSDATE)
  		  	      AND txp.x_start_date <= TRUNC(SYSDATE))
  		  	  END, 0 ) monfee,
          NVL(xpp.x_charge_frq_code, 0) chargefrq,
          NVL(xpp.x_is_recurring, 0) is_recurring
    INTO  o_program_name,
          o_prog_enrollmt_fee,
          o_prog_monthly_fee,
          o_prog_charge_freq,
          o_prog_is_recurring
    FROM  x_program_parameters xpp,
          table_bus_org bus
    WHERE bus.objid = xpp.prog_param2bus_org
    AND   bus.s_org_id = i_bus_org
    AND   xpp.prog_param2prtnum_monfee IS NOT NULL
    AND   xpp.prog_param2prtnum_enrlfee IS NOT NULL
    AND   xpp.objid = i_program_param_id
    AND   ROWNUM = 1;

  EXCEPTION
  WHEN no_data_found
  THEN
    o_error_code    := 702;
    o_error_msg     := 'NO DATA FOUND FROM MAIN QUERY TO PROCEED!!';
    RETURN;
  WHEN OTHERS THEN
    o_error_code    := 702;
    o_error_msg     := 'NO DATA FOUND FROM MAIN QUERY TO PROCEED!!' ||SQLERRM;
    RETURN;
  END;

  SELECT CASE
         WHEN COUNT(*) > 0
  	   THEN 1
  	   ELSE 0
  	   END
  INTO   n_pec_enrl_cnt
  FROM   table_x_autopay_details
  WHERE  x_esn = i_esn
  AND    x_status = 'A'
  AND    (x_end_date IS NULL OR x_end_date = TO_DATE('01-JAN-1753', 'DD-MON-YYYY'))
  AND    ROWNUM = 1;
  --
  t_cst := customer_type ( i_esn => i_esn );
  t_c   := t_cst.retrieve;

  IF t_c.site_part_status = 'Active' THEN
    n_pgm_enroll2site_part := t_c.site_part_objid;
  END IF;

  BEGIN
    SELECT objid,
           x_part_inst2contact
    INTO   n_pgm_enroll2part_inst,
           n_pgm_enroll2contact
    FROM   table_part_inst
    WHERE  part_serial_no = i_esn
    AND    x_domain = 'PHONES'
    AND    ROWNUM = 1;
  EXCEPTION
  WHEN OTHERS
  THEN
    n_pgm_enroll2part_inst := NULL;
    n_pgm_enroll2contact := NULL;
  END;
  --
  t_pet.esn                       := i_esn;
  t_pet.amount                    := o_prog_monthly_fee;
  t_pet.type                      := i_program_type;
  t_pet.sourcesystem              := i_source_system;
  t_pet.insert_date               := SYSDATE;
  t_pet.charge_date               := SYSDATE;
  t_pet.pec_customer              := n_pec_enrl_cnt;
  t_pet.enrolled_date             := SYSDATE;
  t_pet.start_date                := SYSDATE;
  t_pet.reason                    := i_enrl_reason;
  t_pet.enroll_amount             := o_prog_enrollmt_fee;
  t_pet.language                  := i_language;
  t_pet.service_days              := 0;
  t_pet.enrollment_status         := 'ENROLLMENTPENDING';
  t_pet.is_grp_primary            := 1;
  t_pet.update_user               := i_agent_name;
  t_pet.pgm_enroll2pgm_parameter  := i_program_param_id;
  t_pet.pgm_enroll2pgm_group      := NULL;
  t_pet.pgm_enroll2site_part      := n_pgm_enroll2site_part;
  t_pet.pgm_enroll2part_inst      := n_pgm_enroll2part_inst;
  t_pet.pgm_enroll2contact        := n_pgm_enroll2contact;
  t_pet.pgm_enroll2web_user       := i_web_user_id;
  t_pet.pgm_enroll2x_pymt_src     := i_payment_src_id;
  t_pet.pgm_enroll2x_promotion    := i_promo_objid;
  t_pet.pgm_enroll2prog_hdr       := i_purch_hdr_id;

  t_pet := t_pet.ins ( i_program_enrolled_type => t_pet );
  --
  IF t_pet.response NOT LIKE '%SUCCESS%' THEN
    o_error_code    := 702;
    o_error_msg     := 'ERR :'||t_pet.response;
    RETURN;
  END IF;
  --
  o_prog_enrl_id := t_pet.program_enrolled_objid;

  t_ppt.enrollment_status      := 'ENROLLMENTPENDING';
  t_ppt.enroll_status_reason   := i_enrl_reason;
  t_ppt.trans_DATE             := SYSDATE;
  t_ppt.action_text            := i_action_txt;
  t_ppt.action_type            := i_action_type;
  t_ppt.reason                 := i_enrl_reason;
  t_ppt.sourcesystem           := i_source_system;
  t_ppt.esn                    := i_esn;
  t_ppt.upDATE_user            := i_agent_name;
  t_ppt.pgm_tran2pgm_entrolled := t_pet.program_enrolled_objid;
  t_ppt.pgm_trans2web_user     := i_web_user_id;
  t_ppt.pgm_trans2site_part    := n_pgm_enroll2site_part;

  t_ppt := t_ppt.ins (i_program_trans_type => t_ppt);

  IF t_ppt.response NOT LIKE '%SUCCESS%' THEN
    o_error_code    := 702;
    o_error_msg     := 'ERR :'||t_ppt.response;
    RETURN;
  END IF;

  o_prog_trans_id := t_ppt.program_trans_objid;

  o_error_code    := 0;
  o_error_msg     := 'SUCCESS';
 EXCEPTION
 WHEN OTHERS THEN
   o_error_code    := 702;
   o_error_msg     := ' ERROR IN PROCESS_WEB_ENROLLMENT_PKG.P_INSERT_PROGRAM_ENROLLED PROCEDURE. ' || SQLERRM;
END p_insert_program_enrolled;
	--
PROCEDURE p_insert_pre_payment_details ( i_esn					IN	VARCHAR2 ,
		                                 i_payment_src_id       IN  NUMBER   ,
		                                 i_program_type         IN  VARCHAR2 ,   -- Not using
		                                 i_payment_type		    IN  VARCHAR2 ,
		                                 i_agent_name           IN  VARCHAR2 ,
		                                 i_agent_recogn         IN  VARCHAR2 ,
		                                 i_web_user_id          IN  NUMBER   ,
		                                 i_cust_hostname        IN  VARCHAR2 ,
		                                 i_cust_ipaddress       IN  VARCHAR2 ,
		                                 i_purch_hdr2cr_purch   IN  VARCHAR2 ,
		                                 i_amount	  			IN  NUMBER   ,
		                                 i_combs_tax_amount	    IN  NUMBER   ,
		                                 i_e911_tax_amount 	  	IN  NUMBER   ,
		                                 i_usf_tax_amount 	  	IN  NUMBER   ,
		                                 i_rcrf_tax_amount	    IN  NUMBER   ,
		                                 i_discount_amount	    IN  NUMBER   ,
		                                 i_bus_org              IN  VARCHAR2 ,
		                                 i_source_system        IN  VARCHAR2 ,
		                                 i_language             IN  VARCHAR2 ,       -- Not using
		                                 o_purch_hdr_id			OUT NUMBER   ,
		                                 o_error_code           OUT NUMBER   ,
		                                 o_error_msg            OUT VARCHAR2 ) IS
  TYPE payment_details_rec IS RECORD
  ( pymtsrctype 		x_payment_source.x_pymt_type%TYPE,
  	customer_act_number	table_x_credit_card.x_customer_cc_number%TYPE,
  	securitynum			table_x_bank_account.x_routing%TYPE,
  	acctype				table_x_bank_account.x_aba_transit%TYPE,
  	firstname			table_x_bank_account.x_customer_firstname%TYPE,
  	lastname			table_x_bank_account.x_customer_lastname%TYPE,
  	email				table_x_bank_account.x_customer_email%TYPE,
  	phone				table_x_bank_account.x_customer_phone%TYPE,
  	adrid				table_address.objid%TYPE,
  	address				table_address.s_address%TYPE,
  	address_2			table_address.address_2%TYPE,
  	city				table_address.s_city%TYPE,
  	state				table_address.s_state%TYPE,
  	zipcode				table_address.zipcode%TYPE,
  	purch_amt			table_x_bank_account.x_customer_phone%TYPE,
  	accountobjid		table_x_bank_account.x_customer_phone%TYPE,
  	expyr				table_x_credit_card.x_customer_cc_expyr%TYPE,
  	expmo				table_x_credit_card.x_customer_cc_expmo%TYPE,
  	srcname				x_payment_source.x_pymt_src_name%TYPE,
  	bill_country		table_country.name%TYPE,
  	postal_code			table_country.x_postal_code%TYPE,
  	merchant_ref_number VARCHAR2 (100),
  	merchant_id			table_x_cc_parms.x_merchant_id%TYPE,
  	ignore_bad_cv 		table_x_cc_parms.x_ignore_bad_cv%TYPE,
  	purch_hdr2user      NUMBER
  );
  t_payment_details_rec payment_details_rec;
  t_pph                 program_purch_hdr_type := program_purch_hdr_type();
BEGIN

  IF i_payment_src_id IS NULL
  THEN
    o_error_code    := 702;
    o_error_msg     := 'I_PAYMENT_SRC_ID VARIABLE IS MANDATORY.';
    RETURN;
  END IF;

  BEGIN
  SELECT pymtsrctype,
         customer_act_number,
         securitynum,
         acttype,
         firstname,
         lastname,
         email,
         phone,
         adrid,
         address,
         address_2,
         city,
         state,
         zipcode,
         purch_amt,
         accountobjid,
         expyr,
         expmo,
         srcname,
         bill_country,
         postal_code,
         NULL, NULL, NULL, NULL
  INTO   t_payment_details_rec
  FROM   ( SELECT pymtsrc.x_pymt_type pymtsrctype,
                  bank.x_customer_acct customer_act_number,
                  bank.x_routing securitynum,
                  bank.x_aba_transit acttype,
                  bank.x_customer_firstname firstname,
                  bank.x_customer_lastname lastname,
                  NVL(bank.x_customer_email,'null@cybersource.com') email,
                  bank.x_customer_phone phone,
                  adr.objid adrid,
                  adr.s_address address,
                  adr.address_2 address_2,
                  adr.s_city city,
                  adr.s_state state,
                  adr.zipcode zipcode,
                  bank.x_max_purch_amt purch_amt,
                  bank.objid accountobjid,
                  '0000' expyr,
                  '00' expmo,
                  pymtsrc.x_pymt_src_name srcname,
                  cntr.name bill_country,
                  cntr.x_postal_code postal_code
           FROM   table_address adr,
                  table_country cntr,
                  table_x_bank_account bank,
                  x_payment_source pymtsrc
           WHERE  adr.objid = bank.x_bank_acct2address
           AND    cntr.objid(+) = adr.address2country
           AND    bank.objid = pymtsrc.pymt_src2x_bank_account
           AND    bank.x_status = 'ACTIVE'
           AND    Pymtsrc.x_status = 'ACTIVE'
           AND    pymtsrc.objid  = i_payment_src_id
           UNION
           SELECT pymtsrc.x_pymt_type pymtsrctype,
                  cc.x_customer_cc_number customer_act_number,
                  cc.x_customer_cc_cv_number securitynum,
                  cc.x_cc_type acctype,
                  cc.x_customer_firstname firstname,
                  cc.x_customer_lastname lastname,
                  NVL(cc.x_customer_email,'null@cybersource.com') email,
                  cc.x_customer_phone phone,
                  adr.objid adrid,
                  adr.s_address address,
                  adr.address_2 address_2,
                  adr.s_city city,
                  adr.s_state state,
                  adr.zipcode zipcode,
                  cc.x_max_purch_amt purch_amt,
                  cc.objid accountobjid,
                  cc.x_customer_cc_expyr expyr,
                  cc.x_customer_cc_expmo expmo,
                  pymtsrc.x_pymt_src_name srcname,
                  cntr.name bill_country,
                  cntr.x_postal_code postal_code
           FROM   table_address adr,
                  table_country cntr,
                  table_x_credit_card cc,
                  x_payment_source pymtsrc
           WHERE  adr.objid = cc.x_credit_card2address
           AND    cntr.objid(+) = adr.address2country
           AND    cc.objid = pymtsrc.pymt_src2x_credit_card
           AND    cc.x_card_status = 'ACTIVE'
           AND    pymtsrc.x_status = 'ACTIVE'
           AND    pymtsrc.objid  = i_payment_src_id
          ) a;
  EXCEPTION
  WHEN no_data_found
  THEN
  	o_error_code    := 702;
  	o_error_msg     := 'NO DATA FOUND WITH i_payment_src_id';
  	RETURN;
  WHEN OTHERS
  THEN
  	o_error_code    := 702;
  	o_error_msg     := 'NO DATA FOUND WITH i_payment_src_id'||SQLERRM;
  	RETURN;
  END;

  SELECT x_merchant_id,
  	   x_ignore_bad_cv
  INTO   t_payment_details_rec.merchant_id,
  	   t_payment_details_rec.ignore_bad_cv
  FROM  ( SELECT x_merchant_id,
  			   x_ignore_bad_cv
  		FROM   ( SELECT '1' as priority,
  						parm.x_merchant_id,
  						parm.x_ignore_bad_cv
  				 FROM 	sa.table_part_num tpn,
  						sa.table_part_inst tpi,
  						sa.table_mod_level tml,
  						sa.table_x_cc_parms parm,
  						sa.table_x_cc_parms_mapping parm_map
  				 WHERE tpi.n_part_inst2part_mod = tml.objid
  				 AND   tml.part_info2part_num = tpn.objid
  				 AND   tpn.objid = parm_map.mapping2part_num
  				 AND   parm.objid = parm_map.mapping2cc_parms
  				 AND   tpi.part_serial_no = i_esn
  				 AND   parm.x_bus_org like '%BILLING%'
  				 UNION ALL
  				 SELECT '2' as priority,
  						parm.x_merchant_id,
  						parm.x_ignore_bad_cv
  				 FROM   sa.table_x_cc_parms parm
  				 WHERE  x_bus_org = 'BILLING ' || i_bus_org -- CR55665 - merchant id fix
  			    )
  		ORDER BY priority
  	   )
  WHERE  ROWNUM = 1;

  SELECT sa.merchant_ref_number
  INTO   t_payment_details_rec.merchant_ref_number
  FROM   dual;

  IF i_agent_recogn = 'N' AND
     i_agent_name <> NULL
  THEN
    BEGIN
      SELECT objid
      INTO   t_payment_details_rec.purch_hdr2user
      FROM   table_user
      WHERE  s_login_name = UPPER(i_agent_name)
      AND    ROWNUM = 1;
    EXCEPTION
    WHEN OTHERS
    THEN
      t_payment_details_rec.purch_hdr2user := NULL;
    END;
  END IF;

  t_pph.rqst_source			:= i_source_system;
  t_pph.rqst_type			:= t_payment_details_rec.pymtsrctype||'_PURCH';
  t_pph.rqst_date			:= SYSDATE;
  t_pph.ics_applications	:= CASE
                                  WHEN t_payment_details_rec.pymtsrctype='CREDITCARD'
  							    THEN
                                    'ics_auth, ics_bill'
                                  ELSE 'ecp_debit'
                                 END; --	pymtHeader.X_ICS_APPLICATIONS = "ics_auth, ics_bill" OR "ecp_debit" (depending on pymtHeader.PYMTSRCTYPE = CC or not)
  t_pph.merchant_id			:= t_payment_details_rec.merchant_id;
  t_pph.merchant_ref_number	:= t_payment_details_rec.merchant_ref_number;
  t_pph.offer_num			:= 'offer0';
  t_pph.quantity			:= 1;
  t_pph.ignore_avs			:= 'YES';
  t_pph.disable_avs			:= 	'False';
  t_pph.customer_hostname	:= i_cust_hostname;
  t_pph.customer_ipaddress	:= i_cust_ipaddress;
  t_pph.ics_rcode			:= 0;
  t_pph.ics_rflag			:= 'INCOMPLETE';
  t_pph.auth_rcode			:= 0;
  t_pph.auth_rflag			:= 'INCOMPLETE';
  t_pph.bill_rcode			:= 0;
  t_pph.bill_rflag			:= 'INCOMPLETE';
  t_pph.bill_rmsg			:= 'Transaction incomplete';
  t_pph.customer_firstname	:= NVL(t_payment_details_rec.firstname,'NoReal'); --	pymtHeader.X_CUSTOMER_FIRSTNAME	= 'NoReal'			(IF pymtHeader.X_CUSTOMER_FIRSTNAME	 IS NOT NULL AND NUMERIC)
  t_pph.customer_lastname	:= NVL(t_payment_details_rec.lastname,'Name');--	pymtHeader.X_CUSTOMER_LASTNAME	= 'Name'			(IF pymtHeader.X_CUSTOMER_LASTNAME	 IS NOT NULL AND NUMERIC)
  t_pph.customer_phone		:= t_payment_details_rec.phone;
  t_pph.customer_email		:= t_payment_details_rec.email;
  t_pph.bill_address1		:= NVL(t_payment_details_rec.address,'No Street Address');--	pymtHeader.X_BILL_ADDRESS1	= 'No Street Address'	(IF pymtHeader.X_BILL_ADDRESS1	 IS NOT NULL AND NUMERIC)
  t_pph.bill_address2		:= NVL(t_payment_details_rec.address_2,'No Street Address');--	pymtHeader.X_BILL_ADDRESS2	= 'No Street Address'	(IF pymtHeader.X_BILL_ADDRESS2	 IS NOT NULL AND NUMERIC)
  t_pph.bill_city			:= t_payment_details_rec.city;
  t_pph.bill_state			:= t_payment_details_rec.state;
  t_pph.bill_zip			:= t_payment_details_rec.zipcode;
  t_pph.bill_country		:= t_payment_details_rec.bill_country;
  t_pph.amount				:= i_amount;
  t_pph.tax_amount			:= i_combs_tax_amount;
  t_pph.userid				:= i_agent_name;
  t_pph.purch_hdr2creditcard:= CASE
                                  WHEN t_payment_details_rec.pymtsrctype='CREDITCARD'
  								THEN
                                    t_payment_details_rec.accountobjid
                                  ELSE ''
                                 END;
  t_pph.purch_hdr2bank_acct	:= CASE
                                  WHEN t_payment_details_rec.pymtsrctype='ACH'
  								THEN
                                    t_payment_details_rec.accountobjid
                                  ELSE ''
                                 END;
  t_pph.purch_hdr2user		:= t_payment_details_rec.purch_hdr2user;
  t_pph.purch_hdr2cr_purch	:= i_purch_hdr2cr_purch;
  t_pph.e911_taamount		:= i_e911_tax_amount;
  t_pph.usf_taxamount		:= i_usf_tax_amount;
  t_pph.rcrf_tax_amount		:= i_rcrf_tax_amount;
  t_pph.discount_amount		:= i_discount_amount;
  t_pph.prog_hdr2web_user   := i_web_user_id;
  t_pph.payment_type        := i_payment_type;
  t_pph.prog_hdr2pymt_src   := i_payment_src_id;
  t_pph.program_purch_hdr_objid  := sa.billing_seq ('X_PROGRAM_PURCH_HDR'); -- added for objid seq issue

  t_pph := t_pph.ins ( i_program_purch_hdr_type => t_pph);

  IF t_pph.response NOT LIKE '%SUCCESS%' THEN
    o_error_code    := 702;
    o_error_msg     := 'PPD ERR :'||t_pph.response;
    RETURN;
  END IF;

  o_purch_hdr_id := t_pph.program_purch_hdr_objid;

  IF t_payment_details_rec.pymtsrctype = 'CREDITCARD'
  THEN
    INSERT INTO x_cc_prog_trans
    ( objid,
      x_ignore_bad_cv,
      x_customer_cc_number,
      x_customer_cc_expmo,
      x_customer_cc_expyr,
      x_customer_cvv_num,
      x_cc_lastfour,
      x_cc_trans2x_purch_hdr
    )
    VALUES
    ( sa.seq_x_cc_prog_trans.NEXTVAL,
      t_payment_details_rec.ignore_bad_cv,
      t_payment_details_rec.customer_act_number,
      t_payment_details_rec.expmo,
      t_payment_details_rec.expyr,
      'null',
      SUBSTR(t_payment_details_rec.customer_act_number, -4, 4),
      t_pph.program_purch_hdr_objid
    );
  ELSIF t_payment_details_rec.pymtsrctype = 'ACH'
  THEN
    INSERT INTO X_ACH_PROG_TRANS
    ( objid,
      x_ecp_account_no,
      x_ecp_account_type,
      x_ecp_rdfi,
      ach_trans2x_purch_hdr,
      ach_trans2x_bank_account
    )
    VALUES
    ( sa.seq_x_ach_prog_trans.NEXTVAL,
      t_payment_details_rec.customer_act_number,
      t_payment_details_rec.acctype,
      t_payment_details_rec.securitynum,
      ''||t_pph.program_purch_hdr_objid,
      t_payment_details_rec.accountobjid
    );
  END IF;

  o_error_code    := 0;
  o_error_msg     := 'SUCCESS';
 EXCEPTION
 WHEN OTHERS THEN
   o_error_code    := 702;
   o_error_msg     := ' ERROR IN PROCESS_WEB_ENROLLMENT_PKG.P_INSERT_PRE_PAYMENT_DETAILS PROCEDURE. ' || SQLERRM;
END p_insert_pre_payment_details;
--
PROCEDURE p_update_program_enrolled ( i_esn					  IN  VARCHAR2 ,
		                              i_program_enroll_id     IN  NUMBER   ,
		                              i_program_param_id      IN  NUMBER   ,
		                              i_next_charge_date      IN  DATE        DEFAULT NULL,
		                              i_enrl_reason           IN  VARCHAR2 ,
		                              i_action_type           IN  VARCHAR2 ,
		                              i_action_txt            IN  VARCHAR2 ,
		                              i_web_user_id           IN  NUMBER   ,
		                              i_payment_src_id        IN  NUMBER   ,
		                              i_promo_objid           IN  NUMBER   ,
		                              i_agent_name            IN  VARCHAR2 ,
		                              i_bus_org               IN  VARCHAR2 ,
		                              i_source_system         IN  VARCHAR2 ,
		                              i_language              IN  VARCHAR2 ,
		                              o_prog_charge_freq	  OUT VARCHAR2 ,
		                              o_prog_cycle_start_date OUT DATE     ,
		                              o_prog_cycle_end_date   OUT DATE     ,
		                              o_prog_enrollmt_fee     OUT NUMBER   ,
		                              o_prog_monthly_fee      OUT NUMBER   ,
		                              o_prog_is_recurring     OUT VARCHAR2 ,
		                              o_error_code            OUT NUMBER   ,
		                              o_error_msg             OUT VARCHAR2 ) IS
  t_pet                  program_enrolled_type   :=  program_enrolled_type();
  t_ppt                  program_trans_type      :=  program_trans_type();
  n_pgm_enroll2site_part table_site_part.objid%TYPE;
  n_pgm_enroll2contact   table_part_inst.x_part_inst2contact%TYPE;
  t_cst               	 customer_type;
  t_c                    customer_type;
BEGIN

  IF i_program_param_id IS NULL OR
     i_bus_org IS NULL OR
     i_payment_src_id IS NULL
  THEN
    o_error_code    := 702;
    o_error_msg     := 'I_BUS_ORG OR I_PROGRAM_PARAM_ID OR I_PAYMENT_SRC_ID VARIABLE IS NULL!!';
    RETURN;
  END IF;

  BEGIN
    SELECT NVL( CASE
                WHEN xpp.prog_param2prtnum_enrlfee IS NOT NULL
  			    THEN
  		        ( SELECT MAX(txp.x_retail_price)
  		          FROM   table_x_pricing txp,
  		                 table_part_num   pn
  		          WHERE  pn.objid = xpp.prog_param2prtnum_enrlfee
  		          AND    pn.objid = txp.x_pricing2part_num
  		          AND    txp.x_end_date > TRUNC(SYSDATE)
  		          AND    txp.x_start_date <= TRUNC(SYSDATE))
  		        END, 0) enrfee,
  		   NVL( CASE
  		        WHEN xpp.prog_param2prtnum_monfee IS NOT NULL
  			    THEN
  		        ( SELECT Max(txp.x_retail_price)
  		          FROM   table_x_pricing txp,
  		                 table_part_num pn
  		          WHERE  pn.objid = xpp.prog_param2prtnum_monfee
  		          AND    pn.objid = txp.x_pricing2part_num
  		          AND    txp.x_end_date > TRUNC(SYSDATE)
  		          AND txp.x_start_date <= TRUNC(SYSDATE))
  		        END, 0) monfee,
           NVL(xpp.x_charge_frq_code, 0) chargefrq,
           NVL(xpp.x_is_recurring, 0) is_recurring
    INTO   o_prog_enrollmt_fee,
           o_prog_monthly_fee,
           o_prog_charge_freq,
           o_prog_is_recurring
    FROM   x_program_parameters xpp,
  	       table_bus_org bus
    WHERE  bus.objid = xpp.prog_param2bus_org
    AND    bus.s_org_id = i_bus_org
    AND    xpp.prog_param2prtnum_monfee IS NOT NULL
    AND    xpp.prog_param2prtnum_enrlfee IS NOT NULL
    AND    xpp.objid = i_program_param_id
    AND    ROWNUM = 1;

  EXCEPTION
  WHEN no_data_found
  THEN
    o_error_code    := 702;
    o_error_msg     := 'NO DATA FOUND FROM MAIN QUERY TO PROCEED!!';
    RETURN;
  WHEN OTHERS
  THEN
    o_error_code    := 702;
    o_error_msg     := 'NO DATA FOUND FROM MAIN QUERY TO PROCEED!!'||SQLERRM;
    RETURN;
  END;
  --
  t_cst := customer_type ( i_esn => i_esn );
  t_c   := t_cst.retrieve;

  IF t_c.site_part_status = 'Active'
  THEN
    n_pgm_enroll2site_part := t_c.site_part_objid;
  END IF;
  --
  BEGIN
    SELECT x_part_inst2contact
    INTO   n_pgm_enroll2contact
    FROM   table_part_inst
    WHERE  part_serial_no = i_esn
    AND    x_domain = 'PHONES'
    AND    ROWNUM = 1;
  EXCEPTION
  WHEN no_data_found
  THEN
    n_pgm_enroll2contact := NULL;
  END;
  --
  t_pet.program_enrolled_objid	  := i_program_enroll_id;
  t_pet.amount                    := o_prog_monthly_fee;
  t_pet.enroll_amount             := o_prog_enrollmt_fee;
  t_pet.charge_date               := SYSDATE;
  t_pet.service_days              := 0;
  t_pet.grace_period 			  := 0;
  t_pet.sourcesystem              := i_source_system;
  t_pet.enrolled_date             := SYSDATE;
  t_pet.update_stamp 			  := SYSDATE;
  t_pet.start_date                := SYSDATE;
  t_pet.update_user               := i_agent_name;
  t_pet.language                  := i_language;
  t_pet.enrollment_status         := 'ENROLLMENTPENDING';
  t_pet.is_grp_primary            := 1;
  t_pet.next_charge_date 		  := TO_DATE(i_next_charge_date,'MM/DD/YYYY');
  t_pet.next_delivery_date 		  := NULL;
  t_pet.pgm_enroll2x_promotion    := i_promo_objid;
  t_pet.pgm_enroll2pgm_parameter  := i_program_param_id;
  t_pet.pgm_enroll2web_user       := i_web_user_id;
  t_pet.pgm_enroll2x_pymt_src     := i_payment_src_id;
  t_pet.pgm_enroll2pgm_group      := NULL;
  t_pet.pgm_enroll2site_part      := n_pgm_enroll2site_part;
  t_pet.pgm_enroll2contact        := n_pgm_enroll2contact;

  t_pet := t_pet.upd ( i_program_enrolled_type => t_pet );

  IF t_pet.response NOT LIKE '%SUCCESS%'
  THEN
    o_error_code    := 702;
    o_error_msg     := 'ERR :'||t_pet.response;
  RETURN;
  END IF;

  t_ppt.enrollment_status      := 'ENROLLMENTPENDING';
  t_ppt.enroll_status_reason   := i_enrl_reason;
  t_ppt.trans_DATE             := SYSDATE;
  t_ppt.action_text            := i_action_txt;
  t_ppt.action_type            := i_action_type;
  t_ppt.reason                 := i_enrl_reason;
  t_ppt.sourcesystem           := i_source_system;
  t_ppt.esn                    := i_esn;
  t_ppt.upDATE_user            := i_agent_name;
  t_ppt.pgm_tran2pgm_entrolled := t_pet.program_enrolled_objid;
  t_ppt.pgm_trans2web_user     := i_web_user_id;
  t_ppt.pgm_trans2site_part    := n_pgm_enroll2site_part;

  t_ppt := t_ppt.ins (i_program_trans_type => t_ppt);

  IF t_ppt.response NOT LIKE '%SUCCESS%' THEN
    o_error_code    := 702;
    o_error_msg     := 'Err :'||t_ppt.response;
    RETURN;
  END IF;

  o_error_code    := 0;
  o_error_msg     := 'SUCCESS';
 EXCEPTION
 WHEN OTHERS THEN
   o_error_code    := 702;
   o_error_msg     := ' ERROR IN PROCESS_WEB_ENROLLMENT_PKG.P_UPDATE_PROGRAM_ENROLLED PROCEDURE. ' || SQLERRM;
END p_update_program_enrolled;
-- Pre payment procs end
-- Post Payment procs Start
PROCEDURE p_insert_enrol_log_details ( i_esn 			 	IN	VARCHAR2 ,
                                       i_program_name   	IN  VARCHAR2 ,
                                       i_log_title          IN  VARCHAR2 ,
                                       i_log_details 		IN 	VARCHAR2 ,
                                       i_web_user_id 		IN 	NUMBER   ,
                                       i_agent_name		    IN  VARCHAR2 ,
                                       i_source_system		IN  VARCHAR2 ,
                                       o_error_code        OUT  NUMBER   ,
                                       o_error_msg         OUT  VARCHAR2 ) IS
  c_first_name    table_contact.first_name%TYPE;
  c_last_name     table_contact.last_name%TYPE;
  c_esn_nickname  table_x_contact_part_inst.x_esn_nick_name%TYPE;
BEGIN

  IF i_esn IS NULL AND
     i_web_user_id IS NULL
  THEN
    o_error_code    := 702;
    o_error_msg     := 'I_ESN AND I_WEB_USER_ID VARIABLES ARE PASSING AS NULL!!';
    RETURN;
  END IF;

  BEGIN
    SELECT NVL(txcp.x_esn_nick_name,'N/A')
    INTO   c_esn_nickname
    FROM   table_part_inst tpi
    INNER JOIN table_x_contact_part_inst txcp ON tpi.objid = txcp.x_contact_part_inst2part_inst
    AND    tpi.part_serial_no = i_esn
    WHERE  ROWNUM = 1;
  EXCEPTION
  WHEN OTHERS
  THEN
    c_esn_nickname := NULL;
  END;
  --
  BEGIN
    SELECT con.first_name,
           con.last_name
    INTO   c_first_name,
           c_last_name
    FROM   table_contact con
    INNER JOIN table_web_user web ON web.web_user2contact = con.objid
    AND    web.objid = i_web_user_id
    WHERE  ROWNUM = 1;
  EXCEPTION
  WHEN OTHERS
  THEN
    c_first_name := NULL;
    c_last_name  := NULL;
  END;
  --
  INSERT INTO sa.x_billing_log
  ( objid,
    x_log_category,
    x_log_title,
    x_log_date,
    x_details,
    x_additional_details,
    x_program_name,
    x_nickname,
    x_esn,
    x_originator,
    x_contact_first_name,
    x_contact_last_name,
    x_agent_name,
    x_sourcesystem,
    billing_log2web_user
  )
  VALUES
  ( sa.seq_x_billing_log.NEXTVAL,
    'Program',
    i_log_title,
    SYSDATE,
    i_log_details,
    '',
    i_program_name,
    c_esn_nickname,
    i_esn,
    i_agent_name,
    c_first_name,
    c_last_name,
    i_agent_name,
    i_source_system,
    i_web_user_id
  );

  o_error_code    := 0;
  o_error_msg     := 'SUCCESS';
 EXCEPTION
 WHEN OTHERS
 THEN
   o_error_code    := 702;
   o_error_msg     := ' ERROR IN PROCESS_WEB_ENROLLMENT_PKG.P_INSERT_ENROL_LOG_DETAILS PROCEDURE. ' || SQLERRM;
END p_insert_enrol_log_details;
--
PROCEDURE p_update_enrol_details_error ( i_esn 			 	IN	VARCHAR2 ,
										 i_program_enroll_id		IN 	NUMBER   ,
										 i_program_param_id	IN 	NUMBER   ,
										 i_purch_hdr_id		IN 	NUMBER   ,
										 i_web_user_id		IN 	NUMBER   ,
										 i_enroll_status    IN VARCHAR2  ,
										 o_error_code       OUT NUMBER   ,
										 o_error_msg        OUT VARCHAR2 ) IS
BEGIN

  IF i_esn IS NULL AND
     i_program_enroll_id IS NULL
  THEN
    o_error_code    := 702;
    o_error_msg     := 'I_ESN AND I_PROGRAM_ENROLL_ID VARIABLES ARE PASSING AS NULL!!';
    RETURN;
  END IF;

  UPDATE x_program_enrolled
  SET    x_enrollment_status = i_enroll_status
  WHERE  objid = i_program_enroll_id;

  INSERT INTO x_metrics_enroll_attempt
  ( objid,
    x_esn,
    x_attempt_date,
    x_reason,
    enroll_atp2prog_param,
    enroll_atp2web_user,
    enroll_atp2purch_hdr
  )
  VALUES
  ( sa.seq_x_metx_enrl_attmt.NEXTVAL,
    i_esn,
    SYSDATE,
    'Enrollment Attempt Failed',
    i_program_param_id,
    i_web_user_id,
    i_purch_hdr_id
  );

  o_error_code    := 0;
  o_error_msg     := 'SUCCESS';
 EXCEPTION
 WHEN OTHERS
 THEN
   o_error_code    := 702;
   o_error_msg     := SQLCODE||' - '||SUBSTR(SQLERRM, 1, 300);
END p_update_enrol_details_error;
--
PROCEDURE p_update_enrol_details_success ( i_esn			   IN  VARCHAR2 ,
                                           i_program_enroll_id IN  NUMBER   ,
                                           i_prog_trans_id     IN  NUMBER   ,
                                           i_next_exp_date     IN  DATE     ,
                                           i_dealer_id		   IN  VARCHAR2 ,
                                           i_bus_org           IN  VARCHAR2 ,
                                           o_error_code		   OUT NUMBER   ,
                                           o_error_msg		   OUT VARCHAR2 ) IS
  n_is_recurring  	x_program_parameters.x_is_recurring%TYPE;
BEGIN
  IF i_program_enroll_id IS NULL AND
     i_prog_trans_id IS NULL AND
     i_next_exp_date IS NULL
  THEN
    o_error_code    := 702;
    o_error_msg     := 'I_PROGRAM_ENROLL_ID, I_NEXT_EXP_DATE AND I_PROG_TRANS_ID VARIABLES ARE PASSING AS NULL!!';
    RETURN;
  END IF;
  BEGIN
    SELECT pp.x_is_recurring
    INTO   n_is_recurring
    FROM   x_program_parameters pp
    INNER JOIN x_program_enrolled pe  ON  pe.objid = i_program_enroll_id
                                      AND pe.pgm_enroll2pgm_parameter = pp.objid;
  EXCEPTION
  WHEN OTHERS
  THEN
	o_error_code    := 702;
    o_error_msg     := 'NOT ABLE TO FOUND THE RECURRING DATA - '||SQLERRM;
    RETURN;
  END;
  UPDATE x_program_enrolled
  SET    x_delivery_cycle_number = 1,
         x_enrollment_status = 'ENROLLED',
         x_next_charge_date = CASE
		                      WHEN n_is_recurring = 1
							  THEN i_next_exp_date
							  ELSE NULL
							  END,
         x_next_delivery_date = NULL,
         x_exp_date = i_next_exp_date
  WHERE  objid = i_program_enroll_id;

  UPDATE x_program_trans
  SET    x_enrollment_status = 'ENROLLED'
  WHERE  objid = i_prog_trans_id;

  IF i_bus_org = 'SIMPLE_MOBILE' AND
     NVL(i_dealer_id,'') <> ''
  THEN
    INSERT INTO x_program_dealer_info
    ( objid,
      x_dealer_id,
      x_esn,
      x_enrolled_date,
      x_created_date,
      x_enrollment_status,
      pgm_dealer2pgm_parameter,
      pcrf_subscriber_id,
      pcrf_group_id
    )
    VALUES
    ( sa.sequ_x_dealer.NEXTVAL,
      i_dealer_id,
      i_esn,
      SYSDATE,
      SYSDATE,
      'ENROLLED',
      i_esn,
      ( SELECT MAX(pcrf_subscriber_id)
        FROM x_subscriber_spr
        WHERE pcrf_esn = i_esn),
      ( SELECT MAX(pcrf_group_id)
        FROM x_subscriber_spr
        WHERE pcrf_esn = i_esn)
    );
  END IF;

  o_error_code    := 0;
  o_error_msg     := 'SUCCESS';
 EXCEPTION
 WHEN OTHERS THEN
   o_error_code    := 702;
   o_error_msg     := ' ERROR IN PROCESS_WEB_ENROLLMENT_PKG.P_UPDATE_ENROL_DETAILS_SUCCESS PROCEDURE. ' || SQLERRM;
END p_update_enrol_details_success;
--
PROCEDURE p_update_post_paymnt_details ( i_purch_hdr_id			  IN  NUMBER   ,
                                         i_enrl_op_status         IN  VARCHAR2 ,
                                         i_request_id             IN  VARCHAR2 ,
                                         i_avs                    IN  VARCHAR2 ,
                                         i_ics_rcode              IN  VARCHAR2 ,
                                         i_ics_rflag              IN  VARCHAR2 ,
                                         i_ics_rmsg	              IN  VARCHAR2 ,
                                         i_auth_request_id		  IN  VARCHAR2 ,
                                         i_auth_auth_code		  IN  VARCHAR2 ,
                                         i_auth_auth_avs		  IN  VARCHAR2 ,
                                         i_auth_auth_response	  IN  VARCHAR2 ,
                                         i_auth_auth_time         IN  VARCHAR2 ,
                                         i_auth_rcode             IN  NUMBER   ,
                                         i_auth_rflag             IN  VARCHAR2 ,
                                         i_auth_rmsg              IN  VARCHAR2 ,
                                         i_bill_bill_request_time IN  VARCHAR2 ,
                                         i_bill_rcode             IN  NUMBER   ,
                                         i_bill_rmsg              IN  VARCHAR2 ,
                                         i_bill_rflag             IN  VARCHAR2 ,
                                         i_bill_trans_ref_no	  IN  VARCHAR2 ,
                                         i_auth_auth_amount       IN  NUMBER   ,
                                         i_bill_bill_amount       IN  NUMBER   ,
                                         i_auth_cv_result	      IN  VARCHAR2 ,
                                         i_score_factors	      IN  VARCHAR2 ,
                                         i_score_host_severity	  IN  VARCHAR2 ,
                                         i_score_rcode	          IN  NUMBER   ,
                                         i_score_rflag	          IN  VARCHAR2 ,
                                         i_score_rmsg	          IN  VARCHAR2 ,
                                         i_score_score_result	  IN  VARCHAR2 ,
                                         i_score_time_local       IN  VARCHAR2 ,
                                         o_num_rows				  OUT NUMBER   ,
                                         o_error_code             OUT NUMBER   ,
                                         o_error_msg              OUT VARCHAR2 ) IS
  n_purch_cde_objid 	table_x_purch_codes.objid%TYPE;
  t_pph program_purch_hdr_type := program_purch_hdr_type();
BEGIN
  IF i_purch_hdr_id IS NULL
  THEN
    o_error_code    := 702;
    o_error_msg     := 'I_PURCH_HDR_ID VARIABLE IS NULL!!';
    RETURN;
  END IF;

  BEGIN
    SELECT NVL(MIN(objid),0) AS objid
    INTO   n_purch_cde_objid
    FROM   table_x_purch_codes
    WHERE  x_app = 'CyberSource'
    AND    x_code_type = 'rflag'
    AND    x_ics_rcode = i_ics_rcode
    AND    x_auth_response = i_auth_auth_response
    AND    x_language = 'English';
  EXCEPTION
  WHEN OTHERS
  THEN
    n_purch_cde_objid := NULL;
  END;
  --
  t_pph.program_purch_hdr_objid := i_purch_hdr_id;
  t_pph.rqst_date				:= SYSDATE;
  t_pph.avs					    := i_avs;
  t_pph.auth_request_id		    := i_auth_request_id;
  t_pph.ics_rcode				:= i_ics_rcode;
  t_pph.ics_rflag				:= i_ics_rflag;
  t_pph.ics_rmsg				:= i_ics_rmsg;
  t_pph.request_id			    := i_request_id;
  t_pph.auth_avs				:= i_auth_auth_avs;
  t_pph.auth_response			:= i_auth_auth_response;
  t_pph.auth_time				:= i_auth_auth_time;
  t_pph.auth_rcode			    := i_auth_rcode;
  t_pph.auth_rflag			    := i_auth_rflag;
  t_pph.auth_rmsg				:= i_auth_rmsg;
  t_pph.bill_request_time		:= i_bill_bill_request_time;
  t_pph.bill_rcode			    := i_bill_rcode;
  t_pph.bill_rflag			    := i_bill_rflag;
  t_pph.bill_rmsg				:= i_bill_rmsg;
  t_pph.bill_trans_ref_no		:= i_bill_trans_ref_no;
  t_pph.status				    := i_enrl_op_status;
  t_pph.auth_amount			    := i_auth_auth_amount;
  t_pph.bill_amount			    := i_bill_bill_amount;
  t_pph.purch_hdr2rmsg_codes	:= n_purch_cde_objid;
  --
  t_pph := t_pph.upd ( i_program_purch_hdr_type => t_pph );

  IF t_pph.response NOT LIKE '%SUCCESS%'
  THEN
    o_error_code    := 702;
    o_error_msg     := 'Err :'||t_pph.response;
    RETURN;
  END IF;

  SELECT COUNT(1)
  INTO   o_num_rows
  FROM   x_program_purch_hdr
  WHERE  objid = t_pph.program_purch_hdr_objid;

  UPDATE x_cc_prog_trans
  SET    x_auth_cv_result = i_auth_cv_result,
         x_score_factors= i_score_factors,
         x_score_host_severity= i_score_host_severity,
         x_score_rcode = i_score_rcode,
         x_score_rflag = i_score_rflag,
         x_score_rmsg = i_score_rmsg,
         x_score_result = i_score_score_result,
         x_score_time_local = i_score_time_local
  WHERE  x_cc_trans2x_purch_hdr = i_purch_hdr_id;

  o_error_code    := 0;
  o_error_msg     := 'SUCCESS';
 EXCEPTION
 WHEN OTHERS
 THEN
   o_error_code    := 702;
   o_error_msg     := ' ERROR IN PROCESS_WEB_ENROLLMENT_PKG.P_UPDATE_POST_PAYMNT_DETAILS PROCEDURE. ' || SQLERRM;
END p_update_post_paymnt_details;
-- Post Payment Procs end
END process_web_enrollment_pkg;
/