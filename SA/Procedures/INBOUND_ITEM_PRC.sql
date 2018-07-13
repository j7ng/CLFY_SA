CREATE OR REPLACE PROCEDURE sa.inbound_item_prc (v_part_num_in IN table_part_num.part_number%TYPE DEFAULT NULL)
AS

    l_data_phone         NUMBER;
    v_procedure_name     VARCHAR2 (80) := 'inbound_item_prc';
    v_recs_processed     NUMBER := 0;
    v_start_date         DATE := SYSDATE;
    v_action             VARCHAR2 (500) := NULL;
    l_partnum_objid      table_part_num.objid%TYPE;
    l_pc_objid           table_part_class.objid%TYPE;
    l_promo_objid        table_x_promotion.objid%TYPE;
    l_prt_dom_objid      table_prt_domain.objid%TYPE;
    l_restricted_use     NUMBER := 0;
    l_similar_pn_objid   table_part_num.objid%TYPE;
    l_mod_level          table_mod_level.mod_level%TYPE;
    inb_item_cur         SYS_REFCURSOR;
    sqlstmt              VARCHAR2 (400);
    inbound_item_rec     tf.tf_toss_extract_items@ofsprd%ROWTYPE;
    l_unit_measure       table_part_num.unit_measure%TYPE;

    user_exception       EXCEPTION;
/*****************************************************************************/
/*                                                                           */
/* Name:     UPD_OFS_EXTRACTFLAG_ITEM_PROC                                           */
/* Description : This procedure will update extract flag for records related part_number
				in ofs, once an inbound job ran successfully for this record  */
/*****************************************************************************/
   PROCEDURE UPD_OFS_EXTRACTFLAG_ITEM_PROC(
      P_TOSS_EXTRACT_ITEMS_ID         			IN   NUMBER
   )
   IS
	BEGIN
		UPDATE	TF.TF_TOSS_EXTRACT_ITEMS@OFSPRD
		SET		TOSS_EXTRACT_FLAG ='YES',
				TOSS_EXTRACT_DATE = SYSDATE,
				COMMENTS='Clarify Inbound job executed successfully'
		WHERE	TOSS_EXTRACT_ITEMS_ID=P_TOSS_EXTRACT_ITEMS_ID;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			OTA_UTIL_PKG.ERR_LOG (  'Error while updating extract flag for P_TOSS_EXTRACT_ITEMS_ID:'||P_TOSS_EXTRACT_ITEMS_ID, --p_action
										SYSDATE, --p_error_date
                                        P_TOSS_EXTRACT_ITEMS_ID, --p_key
                                        'UPD_OFS_EXTRACTFLAG_ITEM_PROC',--p_program_name
										'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
										);
	END UPD_OFS_EXTRACTFLAG_ITEM_PROC;
/*****************************************************************************/
/*                                                                           */
/* Name:     UPD_OFS_EXTRACTFLAG_PRICE_PROC                                           */
/* Description : This procedure will update extract flag for record related to a part number and price_list_line_id
				in ofs, once an inbound job ran successfully for this record  */
/*****************************************************************************/
   PROCEDURE UPD_OFS_EXTRACTFLAG_PRICE_PROC(
      P_TOSS_EXTRACT_ITEM_PRICES_ID            	IN   NUMBER
   )
   IS
	BEGIN
		UPDATE	tf.tf_toss_extract_item_prices@ofsprd
		SET		toss_extract_flag ='YES',
				toss_extract_date = SYSDATE,
				COMMENTS='Clarify Inbound job executed successfully'
		WHERE	TOSS_EXTRACT_ITEM_PRICES_ID=P_TOSS_EXTRACT_ITEM_PRICES_ID;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			ota_util_pkg.err_log (  'Error while updating extract flag for P_TOSS_EXTRACT_ITEM_PRICES_ID:'||P_TOSS_EXTRACT_ITEM_PRICES_ID, --p_action
										SYSDATE, --p_error_date
                                        P_TOSS_EXTRACT_ITEM_PRICES_ID, --p_key
                                        'UPD_OFS_EXTRACTFLAG_PRICE_PROC',--p_program_name
										'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
										);
	END UPD_OFS_EXTRACTFLAG_PRICE_PROC;
 /*****************************************************************************/
/*                                                                           */
/* Name:     UPD_OFS_COMMENTS_ITEM_PROC                                           */
/* Description : This procedure will update comments for records related to part_number
				in ofs, if an inbound job errors for this record in Clarify
				As this record will be updated when error occurs, making this procedure as autonomous transaction */
/*****************************************************************************/
   PROCEDURE UPD_OFS_COMMENTS_ITEM_PROC(
      P_TOSS_EXTRACT_ITEMS_ID         			IN   NUMBER,
	  P_ERROR_MSG								IN   VARCHAR2
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN
		UPDATE	TF.TF_TOSS_EXTRACT_ITEMS@OFSPRD
		SET		COMMENTS ='Clarify Inbound job error: '||P_ERROR_MSG,
				TOSS_EXTRACT_DATE = SYSDATE
		WHERE	TOSS_EXTRACT_ITEMS_ID=P_TOSS_EXTRACT_ITEMS_ID;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			OTA_UTIL_PKG.ERR_LOG (  'Error while updating Comments for P_TOSS_EXTRACT_ITEMS_ID:'||P_TOSS_EXTRACT_ITEMS_ID, --p_action
										SYSDATE, --p_error_date
                                        P_TOSS_EXTRACT_ITEMS_ID, --p_key
                                        'UPD_OFS_COMMENTS_ITEM_PROC',--p_program_name
										'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
										);
	END UPD_OFS_COMMENTS_ITEM_PROC;

/*****************************************************************************/
/*                                                                           */
/* Name:     UPD_OFS_COMMENTS_PRICE_PROC                                           */
/* Description : This procedure will update comments for a record related to a part number and price_list_line_id
				in ofs, if an inbound job errors for this record in Clarify
				As this record will be updated when error occurs, making this procedure as autonomous transaction */
/*****************************************************************************/
   PROCEDURE UPD_OFS_COMMENTS_PRICE_PROC(
      P_TOSS_EXTRACT_ITEM_PRICES_ID            	IN   NUMBER,
	  P_ERROR_MSG								IN   VARCHAR2
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN
		UPDATE	TF.TF_TOSS_EXTRACT_ITEM_PRICES@OFSPRD
		SET		COMMENTS ='Clarify Inbound job error: '||P_ERROR_MSG,
				TOSS_EXTRACT_DATE = SYSDATE
		WHERE	TOSS_EXTRACT_ITEM_PRICES_ID=P_TOSS_EXTRACT_ITEM_PRICES_ID;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			ota_util_pkg.err_log (  'Error while updating comments for P_TOSS_EXTRACT_ITEM_PRICES_ID:'||P_TOSS_EXTRACT_ITEM_PRICES_ID, --p_action
										SYSDATE, --p_error_date
                                        P_TOSS_EXTRACT_ITEM_PRICES_ID, --p_key
                                        'UPD_OFS_COMMENTS_PRICE_PROC',--p_program_name
										'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
										);
	END UPD_OFS_COMMENTS_PRICE_PROC;
    ----------------------------------------------------------------------------------------
    PROCEDURE adjust_conv_hist (v_pn_objid    IN table_part_num.objid%TYPE,
                                v_conv_rate   IN table_x_ext_conversion_hist.x_conversion%TYPE)
    IS
        ----------------------------------------------------------------------------------------
        l_conversion_rate   table_x_ext_conversion_hist.x_conversion%TYPE;

        PROCEDURE insert_conv_hist_row (
            v1_pn_objid    IN table_part_num.objid%TYPE,
            v1_conv_rate   IN table_x_ext_conversion_hist.x_conversion%TYPE)
        IS
            l_ch_objid   NUMBER;
        BEGIN
            sa.sp_seq ('x_ext_conversion_hist', l_ch_objid);

            INSERT INTO table_x_ext_conversion_hist (objid,
                                                     dev,
                                                     x_start_date,
                                                     x_end_date,
                                                     x_conversion,
                                                     conv_hist2part_num)
                 VALUES (l_ch_objid,
                         1,
                         SYSDATE,
                         NULL,
                         v1_conv_rate,
                         v1_pn_objid);
END;  -- PLSQL/SA/Procedures/INBOUND_ITEM_PRC.sql REV:1.22 info For DBA only
    BEGIN
        BEGIN
            SELECT x_conversion
              INTO l_conversion_rate
              FROM table_x_ext_conversion_hist
             WHERE SYSDATE BETWEEN x_start_date AND NVL (x_end_date, SYSDATE)
               AND conv_hist2part_num = v_pn_objid;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                insert_conv_hist_row (v_pn_objid, v_conv_rate);
                l_conversion_rate := v_conv_rate;
        END;

        IF v_conv_rate <> l_conversion_rate
        THEN
            UPDATE table_x_ext_conversion_hist
               SET x_end_date        = SYSDATE - 1
             WHERE conv_hist2part_num = v_pn_objid;

            insert_conv_hist_row (v_pn_objid, v_conv_rate);
        END IF;
    END;

    ----------------------------------------------------------------------------------------
    FUNCTION sanity_check_part_class (pc_name IN VARCHAR2)
        RETURN VARCHAR2
    IS
        ----------------------------------------------------------------------------------------
        f_value   VARCHAR2 (100);
        ret_msg   VARCHAR2 (500) := NULL;
    BEGIN
        FOR i IN (SELECT 'RESTRICTED_USE' attrib_name FROM DUAL
                  UNION
                  SELECT 'DLL' FROM DUAL
                  UNION
                  SELECT 'ILD_TYPE' FROM DUAL
                  UNION
                  SELECT 'TECHNOLOGY' FROM DUAL
                  UNION
                  SELECT 'NON_PPE' FROM DUAL
                  UNION
                  SELECT 'MEID_PHONE' FROM DUAL
                  UNION
                  SELECT 'MANUFACTURER' FROM DUAL
                  UNION
                  SELECT 'DATA_CAPABLE' FROM DUAL
                  UNION
                  SELECT 'INITIAL_MOTRICITY_CONVERSION' FROM DUAL
                  UNION
                  SELECT 'OTA_ALLOWED' FROM DUAL
                  UNION
                  SELECT 'EXTD_WARRANTY' FROM DUAL
                  UNION
                  --select 'PRELOADED_CLICK_ID'           from dual union
                  SELECT 'DEFAULT_CLICK_ID' FROM DUAL
                  UNION
                  --select 'PRELOADED_DATA_CONFIG'        from dual union
                  SELECT 'FREQUENCY_1' FROM DUAL
                  UNION
                  SELECT 'FREQUENCY_2' FROM DUAL)
        LOOP
            f_value          := get_param_by_name_fun (pc_name, i.attrib_name);

            IF f_value = 'NOT FOUND'
            THEN
                ret_msg          := ret_msg || ',' || i.attrib_name;
            END IF;
        END LOOP;

        IF ret_msg IS NOT NULL
        THEN
            ret_msg          := 'PC Attributes ' || SUBSTR (ret_msg, 2) || ' not set';
        ELSE
            ret_msg          := 'SUCCESS';
        END IF;

        RETURN (ret_msg);
    END;

    ----------------------------------------------------------------------------------------
    FUNCTION create_or_update_modlevel (p_pn_objid    IN     NUMBER,
                                        p_mod_level   IN     VARCHAR2,
                                        p_msg            OUT VARCHAR2)
        RETURN BOOLEAN
    IS
        ----------------------------------------------------------------------------------------
        l_mod_objid   table_mod_level.objid%TYPE;
        l_mod_bool    BOOLEAN;
        l_mod_temp    NUMBER;
    BEGIN
        BEGIN
            SELECT objid, DECODE (mod_level, NULL, 1, 0)
              INTO l_mod_objid, l_mod_temp
              FROM table_mod_level
             WHERE active = 'Active'
               AND mod_level = p_mod_level
               AND part_info2part_num = p_pn_objid;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                SELECT objid, DECODE (mod_level, NULL, 1, 0)
                  INTO l_mod_objid, l_mod_temp
                  FROM table_mod_level
                 WHERE active = 'Active' AND part_info2part_num = p_pn_objid;
        END;

        IF l_mod_temp = 1
        THEN
            l_mod_bool       := TRUE;
        ELSE
            l_mod_bool       := FALSE;
        END IF;

        IF NOT toss_util_pkg.update_mod_level_fun (l_mod_bool,
                                                   p_mod_level,
                                                   UPPER (p_mod_level),
                                                   'Active',
                                                   SYSDATE,
                                                   p_pn_objid,
                                                   0,
                                                   v_procedure_name)
        THEN
            p_msg            := 'Failed updating mod level';
            RAISE user_exception;
        END IF;

        RETURN TRUE;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            IF NOT toss_util_pkg.insert_mod_level_fun (p_mod_level,
                                                       UPPER (p_mod_level),
                                                       'Active',
                                                       SYSDATE,
                                                       p_pn_objid,
                                                       0,
                                                       v_procedure_name)
            THEN
                p_msg            := 'Failed inserting mod level';
                RETURN FALSE;
            ELSE
                RETURN TRUE;
            END IF;
        WHEN OTHERS
        THEN
            p_msg            := 'create_or_update_modlevel ' || SQLERRM;
            RETURN FALSE;
    END;

    ----------------------------------------------------------------------------------------
    PROCEDURE lf_insert_clicks_prc (p_pn_objid IN NUMBER, p_pc_name IN VARCHAR2)
    IS
        ----------------------------------------------------------------------------------------
        l_click_plan_objid   NUMBER;
        l_pc_name            table_part_class.name%TYPE;
        l_param_val          table_x_part_class_values.x_param_value%TYPE;
        cp_rec               table_x_click_plan%ROWTYPE;
    BEGIN
        BEGIN
            SELECT table_x_click_plan.objid
              INTO l_click_plan_objid
              FROM table_x_click_plan
             WHERE click_plan2part_num = p_pn_objid;

            RETURN;
        EXCEPTION
            WHEN OTHERS
            THEN
                l_click_plan_objid := -1;
        END;

        l_param_val      := get_param_by_name_fun (p_pc_name, 'DEFAULT_CLICK_ID');

        IF l_param_val = 'NOT FOUND'
        THEN
            RETURN;
        ELSE
            BEGIN
                SELECT *
                  INTO cp_rec
                  FROM table_x_click_plan
                 WHERE x_plan_id = l_param_val;
            EXCEPTION
                WHEN OTHERS
                THEN
                    cp_rec.x_click_type := ' ';
            END;

            IF cp_rec.x_click_type LIKE '%DEFAULT%'
            THEN
                RETURN;
            ELSE
                cp_rec.click_plan2part_num := p_pn_objid;

                INSERT INTO sa.table_x_click_plan (objid,
                                                   x_plan_id,
                                                   x_click_local,
                                                   x_click_ld,
                                                   x_click_rl,
                                                   x_click_rld,
                                                   x_grace_period,
                                                   x_is_default,
                                                   x_status,
                                                   click_plan2dealer,
                                                   click_plan2carrier,
                                                   x_click_home_intl,
                                                   x_click_in_sms,
                                                   x_click_out_sms,
                                                   x_click_roam_intl,
                                                   x_click_type,
                                                   x_grace_period_in,
                                                   x_home_inbound,
                                                   x_roam_inbound,
                                                   click_plan2part_num,
                                                   x_browsing_rate,
                                                   x_bus_org,
                                                   x_mms_inbound,
                                                   x_mms_outbound,
                                                   x_technology)
                     VALUES (sa.seq ('x_click_plan'),
                             (SELECT MAX (x_plan_id) + 1 FROM table_x_click_plan),
                             cp_rec.x_click_local,
                             cp_rec.x_click_ld,
                             cp_rec.x_click_rl,
                             cp_rec.x_click_rld,
                             cp_rec.x_grace_period,
                             cp_rec.x_is_default,
                             cp_rec.x_status,
                             cp_rec.click_plan2dealer,
                             cp_rec.click_plan2carrier,
                             cp_rec.x_click_home_intl,
                             cp_rec.x_click_in_sms,
                             cp_rec.x_click_out_sms,
                             cp_rec.x_click_roam_intl,
                             cp_rec.x_click_type,
                             cp_rec.x_grace_period_in,
                             cp_rec.x_home_inbound,
                             cp_rec.x_roam_inbound,
                             cp_rec.click_plan2part_num,
                             cp_rec.x_browsing_rate,
                             cp_rec.x_bus_org,
                             cp_rec.x_mms_inbound,
                             cp_rec.x_mms_outbound,
                             cp_rec.x_technology);
            END IF;
        END IF;
    END;

    ----------------------------------------------------------------------------------------
    FUNCTION get_part_num_objid (v_part_number IN table_part_num.part_number%TYPE)
        RETURN table_part_num.objid%TYPE
    IS
        ----------------------------------------------------------------------------------------
        l_partnum_objid   table_part_num.objid%TYPE;
    BEGIN
        SELECT objid
          INTO l_partnum_objid
          FROM table_part_num
         WHERE part_number = v_part_number;

        RETURN l_partnum_objid;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN -1;
    END;

    ----------------------------------------------------------------------------------------
    FUNCTION process_pricing (p_part_num   IN     table_part_num.part_number%TYPE,
                              p_pn_objid   IN     table_part_num.objid%TYPE,
                              p_msg           OUT VARCHAR2)
        RETURN BOOLEAN
    IS
    ----------------------------------------------------------------------------------------
        CURSOR inbound_price_cur
        IS
			SELECT  AIP.*,
					PL.X_PRICE_LIST_CHANNEL
			FROM    TF.TF_TOSS_EXTRACT_ITEM_PRICES@OFSPRD AIP,
					X_INB_PRICE_LISTS PL
			WHERE   AIP.PART_NUMBER = P_PART_NUM
			AND     PL.PRICE_LIST_ID = AIP.PRICE_LIST_ID
			AND     AIP.TOSS_EXTRACT_ITEM_PRICES_ID= (
													SELECT  MAX(AIP_2.TOSS_EXTRACT_ITEM_PRICES_ID)
													FROM    TF.TF_TOSS_EXTRACT_ITEM_PRICES@OFSPRD AIP_2
													WHERE   AIP_2.PART_NUMBER=AIP.PART_NUMBER
													AND     AIP_2.PRICE_LIST_LINE_ID=AIP.PRICE_LIST_LINE_ID
												  );

        price_found    BOOLEAN := FALSE;
        l_price_type   VARCHAR2 (50);
        v_price number;
    BEGIN
		--DBMS_OUTPUT.PUT_LINE('Entered process_pricing for p_part_num: '||p_part_num);
		--DBMS_OUTPUT.PUT_LINE('Entered process_pricing for p_pn_objid: '||p_pn_objid);

        FOR inbound_price_rec IN inbound_price_cur
         LOOP
          --CR 33998
            BEGIN
                    IF inbound_price_rec.price_list_name LIKE  'CHARTIS%' THEN
                        V_PRICE:= inbound_price_rec.list_price;
                    ELSE
                        V_PRICE:= inbound_price_rec.RETAiL_price;
                    END IF;
                price_found      := TRUE;

                -- check if the price exist for a part number
                IF toss_util_pkg.x_price_exist_fun (p_pn_objid,
                                                    inbound_price_rec.price_list_line_id,
                                                    v_procedure_name)
                THEN
                    --------------------------
                    --- update price line  ---
                    --------------------------
                    IF NOT toss_util_pkg.update_pricing_fun (
                               inbound_price_rec.start_date_active,
                               inbound_price_rec.end_date_active,
                               NULL,
                               NULL,
                               v_price,  -- CR 33998 -- SRINIVAS KARUMURI
                               inbound_price_rec.x_price_list_channel,
                               p_pn_objid,
                               inbound_price_rec.price_list_line_id,
                               v_procedure_name)
                    THEN
                        p_msg            := 'Failed update x_pricing';
                        RAISE user_exception;
                    END IF;
                ELSE
                    IF NOT toss_util_pkg.insert_pricing_fun (
                               inbound_price_rec.start_date_active,
                               inbound_price_rec.end_date_active,
                               NULL,
                               NULL,
                               v_price, --CR 33998
                               inbound_price_rec.x_price_list_channel,
                               p_pn_objid,
                               inbound_price_rec.price_list_line_id,
                               v_procedure_name)
                    THEN
                        p_msg            := 'Failed insert x_pricing';
                        RAISE user_exception;
                    END IF;
                END IF;
				UPD_OFS_EXTRACTFLAG_PRICE_PROC(inbound_price_rec.toss_extract_item_prices_id);
            EXCEPTION
                WHEN OTHERS
                THEN
					UPD_OFS_COMMENTS_PRICE_PROC(
						inbound_price_rec.toss_extract_item_prices_id,
						p_msg);
                    RETURN FALSE;
            END;
        END LOOP;

        RETURN TRUE;
    END;

    -- CR26500 Start
    FUNCTION is_valid_pc (ip_part_class IN VARCHAR2)
        RETURN BOOLEAN                                                                    -- CR26500
    IS
        v_objid   NUMBER;
    BEGIN
        SELECT objid
          INTO v_objid
          FROM table_part_class
         WHERE name = ip_part_class;

        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN FALSE;
    END;
-- CR26500 End
--------------------------------------------------------------------------
-------------------- MAIN/Main/main  Program starts here -----------------
--------------------------------------------------------------------------
BEGIN
	--DBMS_OUTPUT.PUT_LINE('START');
    sqlstmt          := sqlstmt || 'SELECT  ti.*';
    sqlstmt          := sqlstmt || ' FROM tf.tf_toss_extract_items@ofsprd ti ';
    sqlstmt          := sqlstmt || ' WHERE 1 = 1 ';

    IF v_part_num_in IS NOT NULL
    THEN
        sqlstmt          := sqlstmt || ' AND     ti.TOSS_EXTRACT_ITEMS_ID =  (SELECT MAX(TI_2.TOSS_EXTRACT_ITEMS_ID) ';
        sqlstmt          := sqlstmt || ' FROM    TF.tf_toss_extract_items@ofsprd  TI_2 ';
        sqlstmt          := sqlstmt || ' WHERE   TI_2.part_number =ti.part_number) ';
		sqlstmt          := sqlstmt || ' AND  Ti.Part_Number = ''' || v_part_num_in || '''';
    ELSE
        sqlstmt          := sqlstmt || ' AND ti.toss_extract_flag=''NEW''';
    END IF;

	--DBMS_OUTPUT.PUT_LINE('sqlstmt: '||sqlstmt);

    OPEN inb_item_cur FOR sqlstmt;

    LOOP
        FETCH inb_item_cur INTO inbound_item_rec;
        EXIT WHEN inb_item_cur%NOTFOUND;
        v_action         := 'Processing part_number and mod_level';
        l_restricted_use := 0;

        BEGIN

			IF inbound_item_rec.part_assignment NOT IN( 'PARENT', 'TRANSPOSE') THEN
				v_action         := ' Data issue: Part_assignment is not set to PARENT or TRANSPOSE.';
                RAISE user_exception;
			END IF;

			IF inbound_item_rec.product_code IS NULL THEN
				v_action         := ' Data issue: Product_code is null.';
                RAISE user_exception;
			END IF;

			IF inbound_item_rec.toss_extract_flag NOT IN ('NEW', 'YES') THEN
				v_action         := ' Failed inbound request: Part is either in an approval process i.e. STG on OFS (or) NOT status on OFS';
                RAISE user_exception;
			END IF;
			-------------- SANITY CHECK OFS DATA -------------------------

            IF (inbound_item_rec.clfy_domain = 'NONE')
            THEN
                v_action         := 'OFS parameter CLFY_DOMAIN';
            END IF;

            IF (inbound_item_rec.product_code IS NULL)
            THEN
                SELECT DECODE (SUBSTR (v_action, 1, 13),
                               'OFS parameter', v_action || ',PRODUCT_CODE',
                               'OFS parameter PRODUCT_CODE')
                  INTO v_action
                  FROM DUAL;
            END IF;

            IF (NOT is_valid_pc (inbound_item_rec.part_class))
            THEN                                                                          -- CR26500
                SELECT DECODE (SUBSTR (v_action, 1, 13),
                               'OFS parameter', v_action || ',PART CLASS',
                               'OFS parameter PART CLASS')
                  INTO v_action
                  FROM DUAL;
            END IF;

            IF (SUBSTR (v_action, 1, 13) = 'OFS parameter')
            THEN
                RAISE user_exception;
            END IF;

            -------------- SANITY CHECK ASSOCIATED PART CLASS ------------
            IF (inbound_item_rec.clfy_domain = 'PHONES')
            THEN
                v_action         := sanity_check_part_class (inbound_item_rec.part_class);

                IF v_action <> 'SUCCESS'
                THEN
                    RAISE user_exception;
                END IF;
            --  elsif ( inbound_item_rec.clfy_domain not in ('REDEMPTION CARDS','BUNDLE','CONTENT','BILLING PROGRAM')) then -- CR23786 is cancelled; removed
            --       raise user_exception;
            END IF;

            --------------------------------------------------------------
            v_recs_processed := v_recs_processed + 1;                                          --PSE
            l_data_phone     := 0;                                                     --CR4981_4982

            IF inbound_item_rec.part_number LIKE 'NT%'
            THEN
                l_restricted_use := 3;

                IF inbound_item_rec.x_ild_type IS NULL
                THEN
                    IF inbound_item_rec.manufacturer = 'MOTOROLA INC'
                    THEN
                        inbound_item_rec.x_ild_type := 1;
                    ELSIF inbound_item_rec.manufacturer = 'NOKIA INC'
                    THEN
                        inbound_item_rec.x_ild_type := 2;
                    END IF;
                END IF;
            ELSIF inbound_item_rec.part_number LIKE 'TF%'
            THEN
                l_restricted_use := 0;
                inbound_item_rec.x_ild_type := 4;
            ELSE
                l_restricted_use := 0;
            END IF;

            IF NVL (inbound_item_rec.data_phone, 'N') = 'N'
            THEN
                l_data_phone     := 0;
            ELSE
                l_data_phone     := 1;
            END IF;

            v_action         := 'Get Promo Objid for Esns Promo';

            BEGIN
                SELECT objid
                  INTO l_promo_objid
                  FROM table_x_promotion
                 WHERE x_promo_code = inbound_item_rec.promo_code;
            EXCEPTION
                WHEN OTHERS
                THEN
                    IF inbound_item_rec.promo_code = 'NONE'
                    THEN
                        l_promo_objid    := -1;
                    ELSE
                        l_promo_objid    := NULL;
                    END IF;
            END;

			v_action         := 'Checking part num exist';
            l_partnum_objid  := get_part_num_objid (inbound_item_rec.part_number);
            DBMS_OUTPUT.put_line ('l_partnum_objid = ' || l_partnum_objid);
            --GET prt_dom_objid
            v_action         := 'Getting part domain objid';

            BEGIN
                SELECT objid
                  INTO l_prt_dom_objid
                  FROM table_prt_domain
                 WHERE name =
                           (CASE
                                WHEN inbound_item_rec.clfy_domain = 'BUNDLE'
                                 -- CR49104 Select based on source system
                                THEN
                                    inbound_item_rec.source_system
                                ELSE
                                    inbound_item_rec.clfy_domain
                            END);
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_prt_dom_objid  := -1;
            END;

            BEGIN
                SELECT pn.objid, pc.objid
                  INTO l_similar_pn_objid, l_pc_objid
                  FROM table_part_class pc, table_part_num pn
                 WHERE 1 = 1
                   AND pn.part_number(+) != inbound_item_rec.part_number
                   AND pn.part_num2part_class(+) = pc.objid
                   AND pc.name = inbound_item_rec.part_class
                   AND ROWNUM < 2;
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_similar_pn_objid := NULL;
            END;

            -------BEGIN CR21541---------
            IF (inbound_item_rec.clfy_domain = 'BUNDLE'
            AND inbound_item_rec.product_family = 'CARDS')
            THEN
                BEGIN
                    SELECT tq.component_quantity + 1
                      INTO l_unit_measure
                      FROM tf.tf_bom_quantity@ofsprd tq
                     WHERE tq.part_number = inbound_item_rec.part_number;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        l_unit_measure   := NULL;
                END;
            END IF;

            -------END CR21541---------
            IF (l_partnum_objid <> -1)                        --part number exists in table_part_num
            THEN
                IF toss_util_pkg.update_part_num_fun (
                       inbound_item_rec.clfy_domain,
                       inbound_item_rec.part_number,
                       UPPER (inbound_item_rec.clfy_domain),
                       inbound_item_rec.charge_code,
                       l_prt_dom_objid,
                       SUBSTR (inbound_item_rec.manufacturer, 1, 20),
                       inbound_item_rec.technology,
                       inbound_item_rec.upc,
                       inbound_item_rec.product_code,
                       inbound_item_rec.source_system,
                       l_promo_objid,
                       inbound_item_rec.cardless_bundle_flag,
                       l_data_phone,                                                   --CR4981_4982
                       inbound_item_rec.conversion_rate,                               --CR4981_4982
                       inbound_item_rec.x_ild_type,
                       inbound_item_rec.x_ota_allowed,
                       inbound_item_rec.extd_warranty,
                       v_procedure_name,
                       l_pc_objid,
                       l_unit_measure,                                                     --CR21541
                       inbound_item_rec.card_type,
                       inbound_item_rec.card_plan,        -- CR27270/CR28538
                       inbound_item_rec.description,--description_in                     -- CR30292
                       UPPER(inbound_item_rec.description),--s_description_in            -- CR30292
                       inbound_item_rec.redemption_days,-- x_redeem_days_in              -- CR30292
                       inbound_item_rec.redemption_units,-- x_redeem_units_in            -- CR30292
                       inbound_item_rec.programming_flag, -- x_programmable_flag_in      -- CR30292
                       inbound_item_rec.device_lock_state, --device_lock_state            -- CR33844
                       inbound_item_rec.rcs_capable        -- rcs_capable                --CR53920_RCS_Flag_clfy_DDL
					   )
                THEN
                    adjust_conv_hist (l_partnum_objid, inbound_item_rec.conversion_rate);
                ELSE
                    v_action         := 'Failed Updating Part Num';
                    RAISE user_exception;
                END IF;
            ELSE                                                    -- part number does not exist --
                IF inbound_item_rec.clfy_domain IN ('REDEMPTION CARDS',
                                                    'ROADSIDE',
                                                    'ILD',
                                                    'SIM CARDS',
                                                    'AUTOPAY',
                                                    'BILLING PROGRAM',
                                                    'CONTENT') --CR23786 is cancelled removed 'CONTENT'
                OR (inbound_item_rec.clfy_domain = 'BUNDLE'                                --CR21541
                AND inbound_item_rec.product_family <> 'PHONES')
                THEN
                    IF toss_util_pkg.insert_part_num_fun (
                           inbound_item_rec.description,
                           UPPER (inbound_item_rec.description),
                           inbound_item_rec.clfy_domain,
                           UPPER (inbound_item_rec.clfy_domain),
                           inbound_item_rec.part_number,
                           UPPER (inbound_item_rec.part_number),
                           'Active',
                           inbound_item_rec.charge_code,
                           l_prt_dom_objid,
                           inbound_item_rec.dll,
                           SUBSTR (inbound_item_rec.manufacturer, 1, 20),
                           inbound_item_rec.redemption_days,
                           inbound_item_rec.redemption_units,
                           inbound_item_rec.programming_flag,
                           inbound_item_rec.technology,
                           inbound_item_rec.upc,
                           NULL,
                           inbound_item_rec.product_code,
                           inbound_item_rec.source_system,
                           l_promo_objid,
                           l_pc_objid,
                           inbound_item_rec.cardless_bundle_flag,
                           l_data_phone,                                               --CR4981_4982
                           inbound_item_rec.conversion_rate,                           --CR4981_4982
                           inbound_item_rec.x_ild_type,
                           inbound_item_rec.x_ota_allowed,
                           inbound_item_rec.extd_warranty,
                           v_procedure_name,
                           l_unit_measure,
                           inbound_item_rec.card_type,                                --CR21541
						   inbound_item_rec.device_lock_state,                        --CR33844
                           inbound_item_rec.rcs_capable)        -- rcs_capable        --CR53920_RCS_Flag_clfy_DDL
                    THEN
                        l_partnum_objid  := get_part_num_objid (inbound_item_rec.part_number);
                        adjust_conv_hist (l_partnum_objid, inbound_item_rec.conversion_rate);
                    ELSE
                        v_action         := 'Failed inserting part num';
                        RAISE user_exception;
                    END IF;
                ELSE                                                --Part number coming in is PHONE
                    IF sa.toss_util_pkg.insert_part_num_fun_ph (
                           inbound_item_rec.description,
                           UPPER (inbound_item_rec.description),
                           inbound_item_rec.clfy_domain,
                           UPPER (inbound_item_rec.clfy_domain),
                           inbound_item_rec.part_number,
                           UPPER (inbound_item_rec.part_number),
                           'Active',
                           inbound_item_rec.charge_code,
                           l_prt_dom_objid,
                           inbound_item_rec.redemption_days,
                           inbound_item_rec.redemption_units,
                           inbound_item_rec.programming_flag,
                           inbound_item_rec.upc,
                           inbound_item_rec.product_code,
                           inbound_item_rec.source_system,
                           l_promo_objid,
                           l_pc_objid,
                           inbound_item_rec.cardless_bundle_flag,
                           v_procedure_name,
                           inbound_item_rec.card_plan,          -- CR27270/ CR28538
						   inbound_item_rec.device_lock_state,   --CR33844
                           inbound_item_rec.rcs_capable        -- CR53920_RCS_Flag_clfy_DDL
                           )
                    THEN
                        l_partnum_objid  := get_part_num_objid (inbound_item_rec.part_number);

                        IF l_similar_pn_objid IS NOT NULL
                        THEN
                            IF NOT toss_util_pkg.insert_part_script_fun (
                                       inbound_item_rec.part_number,
                                       l_similar_pn_objid,
                                       l_partnum_objid,
                                       v_procedure_name)
                            THEN
                                v_action         := 'Failed inserting part script';
                                RAISE user_exception;
                            END IF;
                        END IF;
                    ELSE
                        v_action         := 'Failed inserting part num';
                        RAISE user_exception;
                    END IF;
                END IF;
            END IF;

            IF (inbound_item_rec.clfy_domain = 'PHONES')
            THEN
                l_mod_level      := inbound_item_rec.part_number;
            ELSE
                l_mod_level      := inbound_item_rec.redemption_units;
            END IF;

            IF NOT create_or_update_modlevel (l_partnum_objid, l_mod_level, v_action)
            THEN
                RAISE user_exception;
            END IF;

			IF NOT process_pricing (inbound_item_rec.part_number, l_partnum_objid, v_action)
            THEN
                RAISE user_exception;
            END IF;
			UPD_OFS_EXTRACTFLAG_ITEM_PROC(inbound_item_rec.toss_extract_items_id); --Updating OFS extract flag
            COMMIT;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                OTA_UTIL_PKG.ERR_LOG(  v_action, --p_action
										SYSDATE, --p_error_date
                                        inbound_item_rec.part_number, --p_key
                                        v_procedure_name,--p_program_name
										'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
										);
				UPD_OFS_COMMENTS_ITEM_PROC(
					inbound_item_rec.toss_extract_items_id,
					v_action);
        END;
    END LOOP;

    CLOSE inb_item_cur;

    IF v_part_num_in IS NULL
    THEN
        FOR price_rec
            IN (	select  aip.*, pl.x_price_list_channel
					from    tf.tf_toss_extract_item_prices@ofsprd aip,
							x_inb_price_lists pl
					where   TOSS_EXTRACT_FLAG='NEW'
					and		pl.price_list_id = aip.price_list_id)
        LOOP
            l_partnum_objid  := get_part_num_objid (price_rec.part_number);

            IF (l_partnum_objid <> -1)
            THEN
                BEGIN
                    IF NOT process_pricing (price_rec.part_number, l_partnum_objid, v_action)
                    THEN
                        RAISE user_exception;
                    END IF;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        ROLLBACK;
                        ota_util_pkg.err_log (  v_action, --p_action
										SYSDATE, --p_error_date
                                        price_rec.part_number, --p_key
                                        v_procedure_name,--p_program_name
										'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
										);
                END;
				COMMIT;
            END IF;
        END LOOP;
    END IF;
    -- now update interface jobs
    IF v_part_num_in IS NULL
    THEN
        IF toss_util_pkg.insert_interface_jobs_fun ('INBOUND_ITEM_PRC',
                                                    v_start_date,
                                                    SYSDATE,
                                                    v_recs_processed,
                                                    'SUCCESS',
                                                    v_procedure_name)
        THEN
            COMMIT;
        END IF;
    ELSE
        COMMIT;
    END IF;

	--DBMS_OUTPUT.PUT_LINE('END');
END;
/