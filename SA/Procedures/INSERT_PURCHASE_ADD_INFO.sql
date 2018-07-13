CREATE OR REPLACE PROCEDURE sa."INSERT_PURCHASE_ADD_INFO" (
    in_merchant_ref_id     IN VARCHAR2,
    io_purchase_add_info_tbl IN OUT purchase_add_info_tbl,
    out_err_code OUT VARCHAR2,  -- 0 for success and 1 for failure
    out_err_msg OUT VARCHAR2
	)
is
l_purchase_add_info_tbl purchase_add_info_tbl := purchase_add_info_tbl();
begin
out_err_code 	:= '0';
out_err_msg		:= 'Success';

	l_purchase_add_info_tbl   := io_purchase_add_info_tbl;

	FOR i IN 1..l_purchase_add_info_tbl.COUNT
    LOOP

		INSERT INTO X_PURCHASE_ADD_INFO
		(OBJID,
		X_MERCHANT_REF_NUMBER,
		X_CREATED_ON,
		X_AFS_REASON_CODE,
		X_AFS_RESULT,
		X_HOSTSERVERITY,
		X_CONSUMER_LOCAL_TIME,
		X_AFS_FACTOR_CODE,
		X_ADDR_INFO_CODE,
		X_INTERNET_INFO_CODE,
		X_SUSPICIOUS_INFO_CODE,
		X_VELOCITY_INFO_CODE,
		X_SCORE_MODEL_USED,
		X_BIN_COUNTRY,
		X_CARD_SCHEME,
		X_DEVICE_FP_COOKIESENABLED,
		X_DEVICE_FP_FLASH_ENABLED,
		X_DEVICE_FP_IMAGES_ENABLED,
		X_DEVICE_FP_JAVA_SCRPT_ENABLED,
		X_DEVICE_FP_TRUE_IP_ADDRESS,
		X_DEVICE_FP_TRUE_IP_ADDR_ATTBR,
		X_DAV_REASON_CODE,
		X_ADDRESS_TYPE,
		X_BAR_CODE,
		X_BARCODE_CHECKDIGIT,
		X_MATCH_SCORE,
		X_STD_ADDR,
		X_STD_ADDR_NOAPT,
		X_STD_CITY,
		X_STD_COUNTY,
		X_STD_CSP,
		X_STD_STATE,
		X_STD_POSTAL_CODE,
		X_STD_COUNTRY,
		X_STD_ISO_COUNTRY,
		X_US_INFO)
		VALUES
		(
		sa.sequ_x_purchase_add_info.NEXTVAL,
		in_merchant_ref_id,
		sysdate,
		l_purchase_add_info_tbl(i).afs_reason_code,
		l_purchase_add_info_tbl(i).afs_result,
		l_purchase_add_info_tbl(i).HOSTSERVERITY,
		l_purchase_add_info_tbl(i).CONSUMER_LOCAL_TIME,
		l_purchase_add_info_tbl(i).AFS_FACTOR_CODE,
		l_purchase_add_info_tbl(i).ADDR_INFO_CODE,
		l_purchase_add_info_tbl(i).INTERNET_INFO_CODE,
		l_purchase_add_info_tbl(i).SUSPICIOUS_INFO_CODE,
		l_purchase_add_info_tbl(i).VELOCITY_INFO_CODE,
		l_purchase_add_info_tbl(i).SCORE_MODEL_USED,
		l_purchase_add_info_tbl(i).BIN_COUNTRY,
		l_purchase_add_info_tbl(i).CARD_SCHEME,
		l_purchase_add_info_tbl(i).DEVICE_FP_COOKIESENABLED,
		l_purchase_add_info_tbl(i).DEVICE_FP_FLASH_ENABLED,
		l_purchase_add_info_tbl(i).DEVICE_FP_IMAGES_ENABLED,
		l_purchase_add_info_tbl(i).DEVICE_FP_JAVA_SCRIPT_ENABLED,
		l_purchase_add_info_tbl(i).DEVICE_FP_TRUE_IP_ADDRESS,
		l_purchase_add_info_tbl(i).DEVICE_FP_TRUE_IP_ADDR_ATTBR,
		l_purchase_add_info_tbl(i).DAV_REASON_CODE,
		l_purchase_add_info_tbl(i).ADDRESS_TYPE,
		l_purchase_add_info_tbl(i).BAR_CODE,
		l_purchase_add_info_tbl(i).BARCODE_CHECKDIGIT,
		l_purchase_add_info_tbl(i).MATCH_SCORE,
		l_purchase_add_info_tbl(i).STD_ADDR,
		l_purchase_add_info_tbl(i).STD_ADDR_NOAPT,
		l_purchase_add_info_tbl(i).STD_CITY,
		l_purchase_add_info_tbl(i).STD_COUNTY,
		l_purchase_add_info_tbl(i).STD_CSP,
		l_purchase_add_info_tbl(i).STD_STATE,
		l_purchase_add_info_tbl(i).STD_POSTAL_CODE,
		l_purchase_add_info_tbl(i).STD_COUNTRY,
		l_purchase_add_info_tbl(i).STD_ISO_COUNTRY,
		l_purchase_add_info_tbl(i).US_INFO
		);



    END LOOP;

	--COMMIT;

EXCEPTION WHEN OTHERS
THEN

	out_err_code 	:= '1';
	out_err_msg		:= 'Failure '|| substr(sqlerrm,1,200);
	sa.ota_util_pkg.err_log(p_action        => ''
							  ,p_error_date   => SYSDATE
							  ,p_key          =>  ''
							  ,p_program_name => 'INSERT_PURCHASE_ADD_INFO'
							  ,p_error_text   => out_err_msg);
	dbms_output.put_line('GET_ANSWER_TAB_RETURN_VAL exception '||substr(sqlerrm,1,200));

End;
/