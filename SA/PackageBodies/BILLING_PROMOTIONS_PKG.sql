CREATE OR REPLACE PACKAGE BODY sa."BILLING_PROMOTIONS_PKG"
IS

/*************************************************************************************************/
/* */
/* Name : SA.BILLING_PROMOTIONS_PKG */
/* */
/* Purpose : For Delivering the ValuePlans and Easy Minutes Promotions                    */
/*                                                                                               */
/*                                                                                               */
/* Platforms    :   Oracle 9i                                                                    */
/*                                                                                               */
/* Author       :   Ramu                                                                         */
/*                                                                                               */
/* Date         :   09-11-2007                                                                   */
/* REVISIONS:                                                                                    */
/* VERSION  DATE        WHO          PURPOSE                                                     */
/* -------  ----------  -----        --------------------------------------------                */
/*  1.0     09-11-2007  Ramu         Initial  Revision (CR6586)                                  */
/*  1.2     01-28-2011  LS           CR14153 ADDED DATE CHECK                                    */
/*  1.5     08-16-2011  kacosta    CR16038 NET10_AAA_PLANS  CR16275 TF_AAA-NEW PLANS            */
/*                                 Created get_esn_dealer_program_promo function				  */
/* 1.6		03-27-2017   mdave     CR48383 (3X removal TracFone) Changes to block triple benefits */
/*									for TF smartphones released after 4/4/17. 					  */
/* ********************************************************************************************** */
  FUNCTION BILLING_NT100_RNTIME_ELIGIBLE
   (p_esn     IN VARCHAR2)
    RETURN  NUMBER
  IS
  l_count         NUMBER := 0;

  BEGIN
    IF p_esn IS NULL THEN
       DBMS_OUTPUT.PUT_LINE('ESN is NULL. Fix it ...');
       RETURN l_count;   -- ESN Not Found
    END IF;

  -- This Logic is extracted from table_x_promotion Dynamic SQL column for'RTNT0100' promo code.
  IF get_restricted_use( p_esn ) = 3 THEN
    SELECT COUNT(1)
    INTO l_count
    FROM TABLE_PART_INST PI
    WHERE 1=1
    AND PI.PART_SERIAL_NO = p_esn
    AND (3 >
          GET_PROMO_USAGE_FUN(PI.PART_SERIAL_NO, PI.X_PART_INST2SITE_PART, 'RTNT0100')  +
          GET_RTNT0100_FUN(PI.PART_SERIAL_NO, 'RTNT0100')
         )
    AND (0 < GET_PROMO_USAGE_FUN(PI.PART_SERIAL_NO, PI.X_PART_INST2SITE_PART, 'DEFNET10_3')
        OR EXISTS (SELECT 1 FROM TABLE_MOD_LEVEL ML, TABLE_PART_NUM PN
                   WHERE 1=1
                   AND PART_INFO2PART_NUM = PN.OBJID
                   AND PI.N_PART_INST2PART_MOD = ML.OBJID
                   AND PART_NUMBER LIKE 'NT%'
                   AND DOMAIN = 'PHONES' AND PART_NUM2X_PROMOTION IS NULL)
        )
    AND (0 = GET_PROMO_USAGE_FUN(PI.PART_SERIAL_NO, PI.X_PART_INST2SITE_PART, 'DEFNET10_2'));
  ELSE
    DBMS_OUTPUT.PUT_LINE('This is not a Net10 ESN');
    RETURN l_count; -- Return Esn not Eligible as Incorrect PartNumber for Promo or Incorrect Bus Org
  END IF;

  RETURN l_count ;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0 ;       -- Returns FALSE
  END BILLING_NT100_RNTIME_ELIGIBLE;


  PROCEDURE    BILLING_NT100_RNTIME_PROMO (
    p_esn           IN       VARCHAR2, -- ESN
    p_objid         IN       NUMBER,   -- Call Trans objid
    op_units        OUT      NUMBER,   -- Runtime Units
    op_msg          OUT      VARCHAR2, -- Output Message
    op_status       OUT      VARCHAR2  -- Output Status
                                       -- S = Success, F = Failed
                                       -- N = Not Eligible
    )

    IS
    -- Variable Declarations
    l_nt100_eligible                 NUMBER := 0 ;
    l_promo_rec              table_x_promotion%ROWTYPE;
    l_site_part_objid        table_site_part.objid%TYPE;
    l_total_units            NUMBER := 0;

    -- Cursor Declarations

    -- End of Cursors

    BEGIN
    l_nt100_eligible := BILLING_NT100_RNTIME_ELIGIBLE (p_esn);

    IF l_nt100_eligible = 0 THEN -- ESN IS NOT ELIGIBLE FOR THIS PROMOTION
    -- Return P_Units as 0, P_status='N'
       op_units  := 0;
       op_status := 'N';
       op_msg    := 'ESN ' ||p_esn||' is not eligible for NT 100 100 100 Runtime Promo ';
    ELSE
      BEGIN
            SELECT objid
                INTO l_site_part_objid
            FROM table_site_part
            WHERE 2=2
            AND part_status||'' = 'Active'
            AND x_service_id = p_esn;
      END;

    IF l_site_part_objid IS NULL THEN -- SITE PART OBJID IS NULL .. Typically this will not arise.
           op_units  := 0;
           op_status := 'N'; -- Sets 'N' as per SP_RUNTIME_PROMO Package
           op_msg    := 'Failed to find objid for esn ' || p_esn;
    ELSE -- SITE PART OBJID Found
        DBMS_OUTPUT.PUT_LINE('Inserting in to Pending Redemption as RunTime');

        --Find the list of Pending codes in table_x_pending_redemption which are from
    -- BPREdemption. use query 1. If no records found return p_units = 0 and p_status+N
       op_units := 0;
       op_status := 'N';

        FOR idx IN  (

            SELECT pr.*
              FROM table_x_pending_redemption pend,
                   table_x_promotion pr,
                   table_site_part sp
                   WHERE 1=1
                   AND sp.objid = pend.x_pend_red2site_part
                   AND pend.pend_red2x_promotion = pr.objid
                   AND pr.objid in (SELECT c.OBJID
                       FROM x_program_parameters b, table_x_promotion c, table_bus_org d
                       WHERE  1=1
                         AND (c.OBJID=b.X_PROMO_INCL_MIN_AT
                           OR c.OBJID=b.X_PROMO_INCL_GRPMIN_AT
                           OR c.OBJID=b.X_PROMO_INCR_MIN_AT
                           OR c.OBJID=b.X_PROMO_INCR_GRPMIN_AT
                           )
                        AND d.OBJID = b.PROG_PARAM2BUS_ORG
                        AND upper(d.org_id)||'' = 'NET10'
                       )
                   AND pr.x_promo_type||'' = 'BPRedemption'
                   AND pr.x_revenue_type||'' = 'PAID' -- For Life Line Value Plans, This will come as FREE as per CR6518-1
                   AND pr.x_units > 0
                   AND sp.x_service_id = p_esn
                   ORDER BY pr.x_promo_code
                )
        LOOP -- Associated Runtime Promo
            op_status := 'S';
            --Check for Associated Runtime Promo
            BEGIN
            SELECT A.* INTO l_promo_rec
            FROM TABLE_X_PROMOTION A
            WHERE 1=1
            AND A.X_PROMO_CODE = 'RTNT0100'
            AND A.X_END_DATE > SYSDATE         --NTLG500GP4 CR14153
            AND ROWNUM <2;

            DBMS_OUTPUT.PUT_LINE('Associated Runtime Promo: '||l_promo_rec.x_promo_code);

            -- Insert record into table_x_pending_redemption for Runtime Promo Delivery

            INSERT INTO table_x_pending_redemption
                              (OBJID,
                               PEND_RED2X_PROMOTION, X_PEND_RED2SITE_PART,
                               X_PEND_TYPE
                               , REDEEM_IN2CALL_TRANS -- Column changed from CR5150
                              )
                       VALUES (
                               seq ('x_pending_redemption'),
                               l_promo_rec.objid, l_site_part_objid,
                               'Runtime'
                               , p_objid
                              );

            --- Insert Record into table_x_promo_hist
            --- may be this is not required. But should not be an issue.

            INSERT INTO table_x_promo_hist
                        (objid,
                        promo_hist2x_promotion)
                      VALUES (seq ('x_promo_hist'),
                             l_promo_rec.objid) ;
            -- Add total units qualified for runtime promo
            l_total_units := l_total_units + l_promo_rec.x_units;
            op_status := 'S';
            EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                 NULL;
            END;
        END LOOP; -- Associated Runtime Promo

            --Check if Records where not found
            IF op_status = 'N' THEN -- No Records Found
               op_units := 0;
               op_status := 'N';
               op_msg := 'No Pending Redemption codes found for ' || p_esn;
            ELSE
                op_units := l_total_units; -- SET Total units as units Out
            END IF; -- NO Records Found



    END IF; -- SITE PART OF OBJID Found

  END IF; -- ESN IS ELIGIBLE


    EXCEPTION
     WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
     END; -- Procedure BILLING_NT100_RNTIME_PROMO
  --
  --*********************************************************************************
  -- Function to retreive ESN dealer promo based on program
  --*********************************************************************************
  --
  FUNCTION get_esn_dealer_program_promo
  (
    p_esn                      table_part_inst.part_serial_no%TYPE
   ,p_promo_type               table_x_promotion.x_promo_type%TYPE
   ,p_source_system            table_x_promotion.x_source_system%TYPE
   ,p_program_parameters_objid x_program_parameters.objid%TYPE
   ,p_debug                    BOOLEAN DEFAULT FALSE
  ) RETURN table_x_promotion.x_promo_code%TYPE AS
    --
    CURSOR get_dealer_promotion_curs
    (
      c_v_esn           table_part_inst.part_serial_no%TYPE
     ,c_v_promo_type    table_x_promotion.x_promo_type%TYPE
     ,c_v_source_system table_x_promotion.x_source_system%TYPE
    ) IS
      SELECT txp.x_promo_code
            ,txp.x_sql_statement sql_statement
        FROM table_part_inst tpi_esn
        JOIN table_inv_bin tib
          ON tpi_esn.part_inst2inv_bin = tib.objid
        JOIN table_site tbs
          ON tib.bin_name = tbs.site_id
        JOIN x_promotion_addl_info pai
          ON tbs.objid = pai.x_site_objid
        JOIN table_x_promotion txp
          ON pai.x_promo_addl2x_promo = txp.objid
        JOIN table_mod_level tml_esn
          ON tpi_esn.n_part_inst2part_mod = tml_esn.objid
        JOIN table_part_num tpn_esn
          ON tml_esn.part_info2part_num = tpn_esn.objid
       WHERE tpi_esn.part_serial_no = c_v_esn
         AND pai.x_active = 'Y'
         AND txp.x_promo_type = c_v_promo_type
         AND txp.x_sql_statement IS NOT NULL
         AND SYSDATE BETWEEN txp.x_start_date AND txp.x_end_date
         AND NVL(txp.x_source_system
                ,NVL(c_v_source_system
                    ,'-1')) = NVL(c_v_source_system
                                 ,'-1')
         AND txp.promotion2bus_org = tpn_esn.part_num2bus_org;
    --
    l_b_debug BOOLEAN := FALSE;
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := 'billing_promotions_pkg.get_esn_dealer_program_promo';
    l_i_error_code           PLS_INTEGER := 0;
    l_i_promo_found          PLS_INTEGER := 0;
    get_dealer_promotion_rec get_dealer_promotion_curs%ROWTYPE;
    l_v_error_message        VARCHAR2(32767) := 'SUCCESS';
    l_v_position             VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note                 VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    l_v_promo_code           sa.table_x_promotion.x_promo_code%TYPE;
    --
  BEGIN
    --
    l_b_debug := NVL(p_debug
                    ,FALSE);
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_esn                     : ' || NVL(p_esn
                                                                ,'Value is null'));
      dbms_output.put_line('p_promo_type              : ' || NVL(p_promo_type
                                                                ,'Value is null'));
      dbms_output.put_line('p_source_system           : ' || NVL(p_source_system
                                                                ,'Value is null'));
      dbms_output.put_line('p_program_parameters_objid: ' || NVL(TO_CHAR(p_program_parameters_objid)
                                                                ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Get dealer promotion for ESN';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    OPEN get_dealer_promotion_curs(c_v_esn           => p_esn
                                  ,c_v_promo_type    => p_promo_type
                                  ,c_v_source_system => p_source_system);
    --
    LOOP
      --
      FETCH get_dealer_promotion_curs
        INTO get_dealer_promotion_rec;
      --
      EXIT WHEN get_dealer_promotion_curs%NOTFOUND OR l_v_promo_code IS NOT NULL;
      --
      l_v_position := l_cv_subprogram_name || '.3';
      l_v_note     := 'Check if dealer promotion for ESN was found';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      IF (get_dealer_promotion_rec.sql_statement IS NOT NULL) THEN
        --
        l_v_position := l_cv_subprogram_name || '.4';
        l_v_note     := 'Dealer promotion for ESN was found; executing promo sql statment';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        BEGIN
          --
          EXECUTE IMMEDIATE get_dealer_promotion_rec.sql_statement
            INTO l_i_promo_found
            USING p_program_parameters_objid, p_esn;
          --
        EXCEPTION
          WHEN OTHERS THEN
            --
            l_i_promo_found := 0;
            --
        END;
        --
        l_v_position := l_cv_subprogram_name || '.5';
        l_v_note     := 'Checking if promo is valid for ESN';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        IF (l_i_promo_found > 0) THEN
          --
          l_v_position := l_cv_subprogram_name || '.6';
          l_v_note     := 'Yes, promo is valid for ESN';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          l_v_promo_code := get_dealer_promotion_rec.x_promo_code;
          --
        END IF;
        --
      END IF;
      --
    END LOOP;
    --
    CLOSE get_dealer_promotion_curs;
    --
    l_v_position := l_cv_subprogram_name || '.7';
    l_v_note     := 'Returning dealer promotion for ESN';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    RETURN l_v_promo_code;
    --
  EXCEPTION
    WHEN others THEN
      --
      l_i_error_code    := SQLCODE;
      l_v_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.5';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(l_i_error_code)
                                                       ,'Value is null'));
        dbms_output.put_line('p_error_message: ' || NVL(l_v_error_message
                                                       ,'Value is null'));
        --
      END IF;
      --
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => p_esn
                          ,p_program_name => l_v_position
                          ,p_error_text   => l_v_error_message);
      --
      IF get_dealer_promotion_curs%ISOPEN THEN
        --
        CLOSE get_dealer_promotion_curs;
        --
      END IF;
      --
      RAISE;
      --
  END get_esn_dealer_program_promo;
  --

  /* CR23513 TF Surepay  by MVadlapally */
  PROCEDURE get_benefits_by_units (
        in_total_units      IN     NUMBER,
        in_total_days       IN     NUMBER,
        in_service_plan     IN     x_service_plan.objid%TYPE,
        out_voice_units         OUT NUMBER,
        out_days_units          OUT NUMBER,
        out_text_units          OUT NUMBER,
        out_data_units          OUT NUMBER,
        out_errorcode           OUT VARCHAR2,
        out_errormsg            OUT VARCHAR2,
		in_esn 			    IN sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE DEFAULT NULL --CR48383 mdave 03272017
		)
    IS
	-- CR48383 Changes to block triple benefits for TF smartphones released after 4/4/17. mdave 03272017
	l_block_triple_benefits_flag VARCHAR2(1);
	-- end CR48383  mdave 03272017
    ----------------------------------
    CURSOR c_conv
    IS
    SELECT c.trans_voice,
           c.trans_text,
           c.trans_data,
           c.trans_days
      FROM x_surepay_conv c, sp_mtm_surepay mtm
     WHERE c.objid = mtm.surepay_conv_objid
     AND service_plan_objid = in_service_plan;
    r_conv c_conv%ROWTYPE;
    ----------------------------------
    BEGIN
        IF (in_total_units IS NULL)
        THEN
            out_errorcode := '771';
            out_errormsg := sa.get_code_fun('BILLING_PROMOTIONS_PKG' ,out_errorcode ,'ENGLISH');
        END IF;
        IF (in_service_plan IS NULL)
        THEN
            out_errorcode := '772';
            out_errormsg := sa.get_code_fun('BILLING_PROMOTIONS_PKG' ,out_errorcode ,'ENGLISH');
        END IF;
                    OPEN c_conv;
                    FETCH c_conv INTO r_conv;

                    IF c_conv%NOTFOUND THEN
                        out_errorcode := '773';
                        out_errormsg := sa.get_code_fun('BILLING_PROMOTIONS_PKG' ,out_errorcode ,'ENGLISH');

                    ELSE
                        	-- CR48383 commented below and added condition to block Triple benefits for new TF smartphones.

                      /*  out_data_units  := r_conv.trans_data*  in_total_units;
                        out_days_units  := r_conv.trans_days*  in_total_days;
                        out_text_units  := r_conv.trans_text*  in_total_units;
                        out_voice_units := r_conv.trans_voice* in_total_units;*/

                          l_block_triple_benefits_flag := NULL;
                              l_block_triple_benefits_flag := sa.BLOCK_TRIPLE_BENEFITS(in_esn);

							  IF NVL(l_block_triple_benefits_flag, 'N') = 'Y' THEN
												out_data_units  := in_total_units;
												out_days_units  := in_total_days;
												out_text_units  := in_total_units;
												out_voice_units := in_total_units;
									ELSIF NVL(l_block_triple_benefits_flag, 'N') = 'N' THEN
												out_data_units  := r_conv.trans_data*  in_total_units;
												out_days_units  := r_conv.trans_days*  in_total_days;
												out_text_units  := r_conv.trans_text*  in_total_units;
												out_voice_units := r_conv.trans_voice* in_total_units;
								END IF;
                  -- End CR48383 Changes to block triple benefits for TF smartphones released after 4/4/17.
                    out_errorcode := '0';
              END IF;
          CLOSE c_conv;
    EXCEPTION
        WHEN OTHERS
        THEN
            out_errorcode := SQLCODE;
            out_errormsg  := SUBSTR(SQLERRM, 1, 200);
/*            ota_util_pkg.err_log (
                p_action         => 'Get service_plan details ',
                p_error_date     => SYSDATE,
                p_key            => in_program_id,
                p_program_name   => 'GET_BENIFITS_BY_PROGID',
                p_error_text     => out_errormsg);*/
    END get_benefits_by_units;

--- Start CR42543 - Not to triple benefits for smartphone autorefill

PROCEDURE get_benefits_by_program (
in_esn			IN  table_part_inst.part_serial_no%TYPE,
in_bill_prog_objid	IN  x_program_parameters.objid%type,
out_voice_units         OUT NUMBER,
out_days_units          OUT NUMBER,
out_text_units          OUT NUMBER,
out_data_units          OUT NUMBER,
out_errorcode           OUT VARCHAR2,
out_errormsg            OUT VARCHAR2)
IS
	l_sl_flag VARCHAR2(1) := 'N';

	CURSOR CUR_PART_NUM IS
	SELECT  sp.objid SP_OBJID
	,pn.PART_NUMBER
	,pn.x_redeem_days
	,NVL (pn.x_redeem_units, 0) x_redeem_units
	,NVL (pn.x_conversion, 0) x_conversion
	,DECODE(pn.x_card_type,'WORKFORCE','A',NVL(pn.x_card_type, 'A')) x_card_type
	FROM  x_serviceplanfeaturevalue_def spfvdef,
	x_serviceplanfeature_value SPFV,
	x_service_plan_feature spf,
	x_serviceplanfeaturevalue_def spfvdef2,
	x_service_plan sp,
	mtm_partclass_x_spf_value_def mtm,
	table_part_class pc,
	table_part_num pn
	WHERE 1=1
	AND spfvdef.value_name = 'SUPPORTED PART CLASS'
	AND spf.sp_feature2service_plan = sp.objid
	AND mtm.spfeaturevalue_def_id = spfvdef2.objid
	AND spf.sp_feature2rest_value_def = spfvdef.objid
	AND mtm.part_class_id = pc.objid
	AND SPF.OBJID = SPFV.SPF_VALUE2SPF
	AND PC.OBJID = PN.PART_NUM2PART_CLASS
	and pn.domain =  'REDEMPTION CARDS'
	AND SPFVDEF2.OBJID = SPFV.VALUE_REF
	AND pn.objid = ( 	select part_number_objid
				from x_mtm_part_num2prog_parameters
				where program_param_objid	= 	in_bill_prog_objid
				)
	;

	rec_part_num	CUR_PART_NUM%rowtype;

	CURSOR conversion_sl_curs(c_part_num IN VARCHAR2)
	IS
	SELECT unit_voice,
	unit_days,
	unit_data,
	unit_text,
	x_part_number,
	safelink_flag
	FROM sa.x_surepay_conv
	WHERE x_part_number = c_part_num
	AND product_id      ='SL_TF_PLANS'
	AND active_flag     = 'Y';

	conv_sl_rec conversion_sl_curs%ROWTYPE;


	CURSOR conversion_curs (v_sp x_service_plan.objid%TYPE)
	IS
	SELECT c.trans_voice,
	c.trans_text,
	c.trans_data,
	c.trans_days
	FROM x_surepay_conv c,
	sp_mtm_surepay mtm
	WHERE c.objid          = mtm.surepay_conv_objid
	AND service_plan_objid = v_sp;
	conv_rec conversion_curs%ROWTYPE;

	CURSOR pay_go_curs (c_part_num IN VARCHAR2)
	IS
	SELECT unit_voice,
	unit_days,
	unit_data,
	unit_text,
	x_part_number,
	safelink_flag
	FROM sa.x_surepay_conv
	WHERE x_part_number = c_part_num
	AND active_flag     = 'Y';
	pay_go_rec pay_go_curs%ROWTYPE;

	/*
	CURSOR CUR_SERVICE_PLAN IS
	SELECT sp.OBJID SP_OBJID
	FROM x_service_plan_site_part spsp
	INNER JOIN x_service_plan sp
	ON spsp.x_service_plan_id = sp.objid
	WHERE table_site_part_id IN
	(SELECT MAX(objid)
	FROM table_site_part
	WHERE x_service_id = in_esn
	);

	REC_SERVICE_PLAN	CUR_SERVICE_PLAN%ROWTYPE;
	*/

	l_at_days table_part_num.x_redeem_days%TYPE   := 0;
	l_at_voice table_part_num.x_redeem_units%TYPE := 0;
	l_at_text NUMBER                              := 0;
	l_at_data NUMBER                              := 0;
	l_dc_days table_part_num.x_redeem_days%TYPE   := 0;
	l_dc_voice table_part_num.x_redeem_units%TYPE := 0;
	l_dc_text      NUMBER                              := 0;
	l_dc_data      NUMBER                              := 0;
	lv_sms_units   VARCHAR2(100);
	lv_sms_units_1 NUMBER(10);
	v_count        NUMBER;

BEGIN


	IF device_util_pkg.get_smartphone_fun(in_esn) = 0 THEN -------------- TF SUREPAY PHONE CHK SMARTPHONE

		BEGIN
			SELECT 'Y'
			INTO l_sl_flag
			FROM x_sl_currentvals cv ,
			table_bus_org bo ,
			table_part_num pn ,
			table_part_inst pi ,
			table_mod_level ml
			WHERE x_current_esn         = in_esn
			AND pi.part_serial_no       = cv.x_current_esn
			AND pi.n_part_inst2part_mod = ml.objid
			AND ml.part_info2part_num   = pn.objid
			AND bo.objid                = pn.part_num2bus_org
			AND bo.org_id               ='TRACFONE'
			AND ROWNUM                  =1;
		EXCEPTION
		WHEN OTHERS THEN
			l_sl_flag := 'N';
		END;




		OPEN CUR_PART_NUM;
		FETCH CUR_PART_NUM INTO rec_part_num;


		IF CUR_PART_NUM%FOUND
		THEN
			CLOSE CUR_PART_NUM;
			BEGIN
				SELECT COUNT(1)
				INTO v_count
				FROM TABLE_X_PARAMETERS
				WHERE X_PARAM_NAME = 'REPLACEMENT_PARTNUMBERS'
				AND X_PARAM_VALUE  =	REC_PART_NUM.PART_NUMBER;

			EXCEPTION
			WHEN OTHERS THEN
			-- dbms_output.put_line('exception'||sqlerrm);
				v_count := 1;
			END;
			/*
			OPEN CUR_SERVICE_PLAN;
			FETCH CUR_SERVICE_PLAN INTO REC_SERVICE_PLAN;
			CLOSE CUR_SERVICE_PLAN;
			*/

			IF rec_part_num.x_card_type IN ('DATA CARD','TEXT ONLY') THEN
				lv_sms_units   := 0 ;
				lv_sms_units_1 := 0;
				lv_sms_units   := get_serv_plan_value (rec_part_num.SP_OBJID, 'SMS');

				BEGIN
					SELECT NVL(DECODE(lv_sms_units,'NA', 0, TO_NUMBER(lv_sms_units)),0)
					INTO lv_sms_units_1
					FROM DUAL;
				EXCEPTION
				WHEN OTHERS THEN
					RAISE;
				END;
			l_dc_data               := l_dc_data + get_serv_plan_value (rec_part_num.SP_OBJID, 'DATA');
			l_dc_days               := l_dc_days + get_serv_plan_value (rec_part_num.SP_OBJID, 'SERVICE DAYS');
			l_dc_text               := l_dc_text + lv_sms_units_1; ---CR32572

			ELSIF rec_part_num.x_card_type = 'A'  AND v_count=0 THEN

				OPEN conversion_curs(rec_part_num.SP_OBJID);
				FETCH conversion_curs INTO conv_rec;
				CLOSE conversion_curs;




				OPEN pay_go_curs(rec_part_num.part_number);
				FETCH pay_go_curs INTO pay_go_rec;


				IF pay_go_curs%FOUND AND NVL(pay_go_rec.safelink_flag,'N') ='N' THEN --CR41433 SL Smartphone upgrade  VZN
					l_at_voice := l_at_voice + rec_part_num.x_redeem_units;
					l_at_days  := l_at_days  + rec_part_num.x_redeem_days;
					l_at_text  := l_at_text  + pay_go_rec.unit_text;
					l_at_data  := l_at_data  + pay_go_rec.unit_data;
					CLOSE pay_go_curs;
				ELSE --END CR38145
					CLOSE pay_go_curs;
					IF l_sl_flag='Y'  AND  NVL(pay_go_rec.safelink_flag,'N')='Y' THEN  --for  safelink --CR41433 SL Smartphone upgrade  VZN
					l_at_voice := l_at_voice + pay_go_rec.unit_voice;
					l_at_days  := l_at_days  + rec_part_num.x_redeem_days;
					l_at_text  := l_at_text  + pay_go_rec.unit_text;
					l_at_data  := l_at_data  + pay_go_rec.unit_data;
					ELSE ---not safelink BAU
					l_at_voice := l_at_voice + conv_rec.trans_voice* rec_part_num.x_redeem_units;
					l_at_days  := l_at_days  + conv_rec.trans_days* rec_part_num.x_redeem_days;
					l_at_text  := l_at_text  + conv_rec.trans_text* rec_part_num.x_redeem_units;
					l_at_data  := l_at_data  + conv_rec.trans_data* rec_part_num.x_redeem_units;
					END IF; --for non safelink
				END IF;

			ELSIF rec_part_num.x_card_type = 'A' AND v_count=1 THEN ---FOR CR37027                                 ----- Chk for airtime cards
				dbms_output.put_line('2.1');
				OPEN conversion_curs(rec_part_num.SP_OBJID);
				FETCH conversion_curs INTO conv_rec;
				CLOSE conversion_curs;
				l_at_voice := 0;
				l_at_days  := l_at_days + conv_rec.trans_days* rec_part_num.x_redeem_days;
				l_at_text  := 0;
				l_at_data  := (l_at_data + conv_rec.trans_data* rec_part_num.x_redeem_units)/3;
			END IF;

			OPEN conversion_sl_curs (rec_part_num.part_number);
			FETCH conversion_sl_curs INTO conv_sl_rec;
			CLOSE conversion_sl_curs;
			IF l_sl_flag  = 'Y' AND conv_sl_rec.safelink_flag='Y' THEN --CR41433 SL Smartphone upgrade  VZN
				dbms_output.put_line('in safelink 350');
				l_at_voice := l_at_voice + conv_sl_rec.unit_voice;
				l_at_days  := l_at_days  + rec_part_num.x_redeem_days;
				l_at_text  := l_at_text  + conv_sl_rec.unit_text;
				l_at_data  := l_at_data  + conv_sl_rec.unit_data;
			END IF; --CR41433 SL Smartphone upgrade  VZN



		ELSE
			CLOSE CUR_PART_NUM;
			out_errorcode	:=	'99';
			out_errormsg	:= 'Part Number Not Found';

		END IF;

		out_days_units 		:= l_at_days  + l_dc_days;
		out_data_units 		:= l_at_data  + l_dc_data;
		out_voice_units 	:= l_at_voice + l_dc_voice ;
		out_text_units 		:= l_at_text  + l_dc_text;


	END IF;

EXCEPTION
WHEN OTHERS
THEN
out_errorcode := SQLCODE;
out_errormsg  := SUBSTR(SQLERRM, 1, 200);

END get_benefits_by_program;

--- End CR42543 - Not to triple benefits for smartphone autorefill

END BILLING_PROMOTIONS_PKG; -- Package Body BILLING_PROMOTIONS_PKG
/