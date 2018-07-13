CREATE OR REPLACE PROCEDURE sa."GET_PAYMENT_SERVICE_PARAMS"
(inv_ics_applications varchar2,
out_payment_service_params_tbl OUT payment_service_params_tbl,
out_err_code	OUT varchar2,
out_err_msg		OUT varchar2
)
AS

CURSOR CUR_PAYMENT_SERVICE_PARAMS IS
SELECT X_AFS_FLAG, X_DAV_FLAG
FROM x_payment_service_parameters
where lower(X_ICS_APPLICATIONS)	=	lower(inv_ics_applications)
;

REC_PAYMENT_SERVICE_PARAMS	CUR_PAYMENT_SERVICE_PARAMS%rowtype;

payment_serv_params_obj_type payment_service_params_obj;
i INTEGER := 1;

BEGIN

out_err_code 	:= '0';
out_err_msg		:= 'Success';

dbms_output.put_line('GET_PAYMENT_SERVICE_PARAMS Begin '||'inv_ics_applications' ||' '||inv_ics_applications);

	out_payment_service_params_tbl 	:= payment_service_params_tbl();

	OPEN CUR_PAYMENT_SERVICE_PARAMS;
	FETCH CUR_PAYMENT_SERVICE_PARAMS INTO REC_PAYMENT_SERVICE_PARAMS;

	IF CUR_PAYMENT_SERVICE_PARAMS%NOTFOUND
	THEN
		CLOSE CUR_PAYMENT_SERVICE_PARAMS;
		out_err_code	:= '1';
		out_err_msg		:= 'No record found in table x_payment_service_parameters for ICS_APPLICATIONS value '||inv_ics_applications;
		RETURN;
	END IF;

		CLOSE CUR_PAYMENT_SERVICE_PARAMS;



	i := 1;

	FOR REC_PAYMENT_SERVICE_PARAMS IN CUR_PAYMENT_SERVICE_PARAMS
	LOOP



		payment_serv_params_obj_type	:= 	payment_service_params_obj(lower(inv_ics_applications),REC_PAYMENT_SERVICE_PARAMS.X_AFS_FLAG,REC_PAYMENT_SERVICE_PARAMS.X_DAV_FLAG);



	   out_payment_service_params_tbl.EXTEND();

		out_payment_service_params_tbl(i) := payment_serv_params_obj_type;

		i := i + 1;

	END LOOP;


	/*
	if cur_ans_returned%notfound
	then
		out_err_code := '1';
		out_err_msg := 'Data doesnot exist in ANSWER_TABLE for given inputs';
		sa.ota_util_pkg.err_log(p_action        => ''
							  ,p_error_date   => SYSDATE
							  ,p_key          =>  ''
							  ,p_program_name => 'GET_PAYMENT_SERVICE_PARAMS'
							  ,p_error_text   => out_err_msg);

		return;
	end if ;
	*/

Exception when others
THEN
	out_err_code := '1';
	out_err_msg := sqlerrm;
	dbms_output.put_line('GET_PAYMENT_SERVICE_PARAMS exception '||out_err_code ||' '||sqlerrm);

End;
/