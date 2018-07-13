CREATE OR REPLACE PACKAGE BODY sa."OUTBOUND_AUTOPAY_PKG"
AS
 /*****************************************************************
  * Package Name: Outbound_Autopay_Pkg
  * Purpose     :This package will pick up the data everyday which has to be
  *		 sent to PEC for recurring monthly re-debit for every ESN enrolled on that specific
  *		 day of the month (with program type 2 and 3). The relevant data is inserted into the
  *		?x_send_ftp_auto? table with the account status =?A?
  *
  * Author      : TCS
  * Date        :  05/23/2002
  * History     :
   ---------------------------------------------------------------------
    06/17/2002          TCS                 Initial version
    04/10/2003          SL                  Clarify Upgrade - sequence
    05/10/2003		SU		    CR 1157 - Correct autopay details table
    05/10/2003	        Raju                CR 1142 - Billing Date.
    06/05/2003		SU		    CR 1171 - Allow 10 days to Change Funding.
    08/26/2003          Raju                CR 1857 - Correct no_fund_change_cur Curser
    04/21/2004          Raju                CR 2158 - Correct data in table_x_call_trans
    06/30/2004          Hanif               CR 3001 - added subquery just to make sure that
					                                   update statement,  update only one record
    08/05/2004 		Raju	            CR 3120 -   To Include 'D" status records when the MAM
    11/18/2004      	Raju                Autopay Fix - Extended 10 days for Change of funding customers.				                                file is run manually
    *********************************************************************/
 FUNCTION get_amount_fun(p_prg_type NUMBER) RETURN NUMBER
 IS amount NUMBER;
 v_part_num VARCHAR2(30);
 err_no NUMBER;
 v_function_name VARCHAR2(80) := 'OUTBOUND_AUTOAPY_PKG.get_amount_fun';
 BEGIN
		  IF p_prg_type = 2
			  THEN
				v_part_num := 'APPAUTOMON';
			 ELSE
				 IF p_prg_type = 3
				 THEN
					  v_part_num := 'APPBONUSMON';
			     END IF;
		     END IF;
		     SELECT  X_RETAIL_PRICE INTO amount FROM TABLE_X_PRICING WHERE
		     X_PRICING2PART_NUM = (SELECT objid FROM TABLE_PART_NUM
		     WHERE part_number = v_part_num);
			  RETURN amount;
			 EXCEPTION
			 WHEN OTHERS THEN
				  err_no := Toss_Util_Pkg.insert_error_tab_fun (
						  'Failed retrieving Amount - Mnthly fee ',
			  p_prg_type,
			  v_function_name
				  );
				  RETURN amount;
END get_amount_fun;
	 --***********************************************
	 FUNCTION validateESN_fun(p_esn VARCHAR2) RETURN BOOLEAN
 	 IS valid_flag BOOLEAN;
	 	v_PartInstCount NUMBER;
	 BEGIN
	 	valid_flag := TRUE;
		SELECT COUNT(*)
	    INTO   v_PartInstCount
	    FROM   sa.TABLE_PART_INST
	    WHERE  Part_Serial_No = p_esn
	    AND    x_domain = 'PHONES'
	    AND    X_Part_Inst_Status = '52';
	    IF v_PartInstCount = 0 THEN
	      -- op_msg := 'ERROR - Active esn NOT FOUND';
		valid_flag := FALSE;
	     END IF;
		 RETURN valid_flag;
	 END validateESN_fun;
	--*************************************************
	 PROCEDURE   INSERT_CALL_TRANS_PRC(
  			  p_esn VARCHAR2,
			  p_action_type VARCHAR2,
			  p_source VARCHAR2,
			  p_action_text VARCHAR2,
			  p_reason VARCHAR2,
			  p_result VARCHAR2)
	  IS
CURSOR sp_curs_c(esn in varchar2)
	IS
Select sp.objid                    site_part_objid,
    sp.x_min                    x_min,
    ca.objid                    carrier_objid,
    ir.inv_role2site            site_objid,
    ca.x_carrier_id             x_carrier_id,
    sp.site_objid               cust_site_objid,
    sp.state_code               v_state_code
from
    table_x_carrier  ca,
    table_part_inst  pi2, ---x_Domain=Line
    table_inv_role   ir,
    table_inv_bin    ib,
    table_part_inst  pi,  ---x_Domain=Phone
    table_site_part  sp
where ca.objid                 = pi2.part_inst2carrier_mkt
    and initcap(pi2.x_domain)    = 'Lines'
    and pi2.part_serial_no       = sp.x_min
    and ir.inv_role2inv_locatn   = ib.inv_bin2inv_locatn
    and ib.objid                 = pi.part_inst2inv_bin
    and pi.x_part_inst2site_part = sp.objid
    and (sp.part_status)         = 'Active'
    and sp.x_service_id          = p_esn;
 sp_curs_rec sp_curs_c%rowtype;
 v_user     number;
	  v_procedure_name VARCHAR2(80) := 'OUTBOUND_AUTOPAY_PKG.INSERT_CALL_TRANS_PRC';
	  CURSOR esn_details_c(in_serviceId VARCHAR2) IS
		   SELECT * FROM TABLE_SITE_PART  WHERE
		   x_service_id = in_serviceId and part_status = 'Active';
	  esn_details_rec esn_details_c%ROWTYPE;
	  BEGIN
			 v_user := get_user_objid_fun('SA');
			  OPEN esn_details_c(p_esn);
			  FETCH esn_details_c INTO esn_details_rec;
			  CLOSE esn_details_c;
			 OPEN 	sp_curs_c(p_esn);
                         FETCH sp_curs_c INTO sp_curs_rec;
                         CLOSE sp_curs_c;
			  INSERT INTO TABLE_X_CALL_TRANS (
			  		 objid,
					 CALL_TRANS2SITE_PART,
					 X_ACTION_TYPE,
					 X_MIN,
					 X_SERVICE_ID,
					 X_SOURCESYSTEM,
					 X_TRANSACT_DATE,
					 X_ACTION_TEXT,
					 X_REASON,
					 X_RESULT,
					 x_sub_sourcesystem,
                                         x_call_trans2carrier,
		 			 x_call_trans2dealer,
					 x_call_trans2user,
					 x_total_units
					)VALUES
					(
					--04/10/03 seq_x_call_trans.NEXTVAL + POWER (2, 28),
					seq('x_call_trans'),
					esn_details_rec.objid,
					p_action_type,
					esn_details_rec.x_min,
					p_esn,
					p_source,
					SYSDATE,
					p_action_text,
					p_reason,
					p_result,
					'202',
					sp_curs_rec.carrier_objid,
                                        sp_curs_rec.site_objid,
                                        v_user,
                                        0
				);
 		EXCEPTION
				WHEN OTHERS THEN
				 	Toss_Util_Pkg.INSERT_ERROR_TAB_PROC('Error IN
insert_x_call_trans',NVL(p_esn,'N/A'),v_procedure_name);
					RETURN;
	  END INSERT_CALL_TRANS_PRC;
	PROCEDURE FETCH_AHP_ESN_PRC(p_date IN DATE)
	IS
	CURSOR app_details_c(in_date DATE) IS
		   SELECT * FROM TABLE_X_AUTOPAY_DETAILS WHERE
		   -- x_end_date IS NULL --to handle radioshack phase 1:  01/28/2003
		   (x_end_date is  NULL  or trunc(x_end_date) =trunc(to_date('1/1/1753','dd/mm/yyyy')))--fixed by Suganthi 01/28/2003
		   AND (x_program_type = 2 OR x_program_type = 3)
		   AND x_account_status <> 9
		   AND x_status = 'A'
		   AND TO_CHAR(x_enroll_date,'dd') = TO_CHAR(in_date,'dd')
		   AND x_enroll_date < trunc(in_date);--modified by Suganthi
		   --TO_CHAR(x_enroll_date,'mm') < TO_CHAR(in_date,'mm') AND
		   --TO_CHAR(x_enroll_date,'yyyy') <= TO_CHAR(in_date,'yyyy');
	app_details_rec app_details_c%ROWTYPE;
   	--if sysdate is the last day of the month
	CURSOR app_details_adv_c(in_date DATE) IS
	       SELECT * FROM TABLE_X_AUTOPAY_DETAILS WHERE
		   --x_end_date IS NULL --to handle radioshack phase 1: 01/28/2003
		   (x_end_date is  NULL  or  trunc(x_end_date) =trunc(to_date('1/1/1753','dd/mm/yyyy')))--fixed by Suganthi 01/28/2003
		   AND (x_program_type = 2 OR x_program_type = 3)
		   AND x_account_status <> 9
		   AND x_status = 'A'
		   AND TO_CHAR(x_enroll_date,'dd') >= TO_CHAR(in_date,'dd')
		   AND x_enroll_date < trunc(in_date); --modified by suganthi
		   --TO_CHAR(x_enroll_date,'mm') < TO_CHAR(in_date,'mm') AND
		   --TO_CHAR(x_enroll_date,'yyyy') <= TO_CHAR(in_date,'yyyy');
	app_details_rec app_details_adv_c%ROWTYPE;
		-- 11/14/02
	  CURSOR app_radio_shack ( in_date DATE) IS
	  SELECT dtl.rowid, dtl.*
	  FROM TABLE_X_AUTOPAY_DETAILS  dtl
	  WHERE x_receive_status IS NULL
	  AND x_enroll_date < trunc(in_date) - 30;
	--Start CR1171
	-----------------start CR 3120----------------------------
	cursor  no_fund_change_cur  is
	select *
	  from table_X_autopay_details ap,sa.x_receive_ftp_auto recv
	 where 1=1
	  and ap.x_account_status != 5
	  and ap.x_status='I'
	  and ap.objid = (select max(d.objid) from table_x_autopay_details d where d.x_Esn = ap.x_esn)
	  and ap.x_esn = recv.esn and recv.REC_SEQ_NO = (select max(a2.REC_SEQ_NO) from sa.x_receive_ftp_auto a2
	  where a2.esn= recv.esn) and not exists (select 1 from sa.x_send_ftp_auto a2
	  where trunc(SENT_DATE) > trunc(sysdate)-13 and ACCOUNT_STATUS='D' and a2.esn = recv.esn)
	  and recv.pay_type_ind ='REV'
	  and recv.date_received <=  trunc(sysdate)-10
          and recv.date_received >=  trunc(sysdate)-13;
	 ------------------End CR 3120---------------------
	--End CR 1171
	v_msg VARCHAR2(500);
	v_status VARCHAR2(25);
	v_last_day NUMBER := 1;
	v_amount NUMBER;
	v_date DATE;
	validESN BOOLEAN;
	v_esn VARCHAR2(15); ---- for CR2600
	dayVal varchar2(30); ---for CR 1142
	v_procedure_name VARCHAR2(80) := 'OUTBOUND_AUTOPAY_PKG.FETCH_AHP_ESN_PRC';
	BEGIN
		--if the i/p is null then make the date as sysdate
		v_date := NVL(p_date,SYSDATE);
		--Start CR 1171
		FOR  no_fund_change_rec in no_fund_change_cur
		LOOP
		BEGIN
			INSERT INTO X_SEND_FTP_AUTO
		       	 	(
			       	 	SEND_SEQ_NO,
			       	 	file_type_ind,
			       	 	esn,
			       	 	program_type,
			       	 	account_status,
					amount_due,
					debit_date
					 )
		       	 	 VALUES
		       	 	 (
			       	 	seq_X_send_ftp_auto.NEXTVAL,
			       	 	'D',
			       	 	no_fund_change_rec.x_esn,
			       	 	no_fund_change_rec.x_program_type,
			       	 	'D',
					NULL,
					NULL
		       	 	  );
--                update table_x_call_trans set x_transact_date=sysdate, x_result='Completed' where x_reason='Payment Failure-Rev' and x_result='Pending' and x_service_id=no_fund_change_rec.x_esn;
-- start CR3001
 update table_x_call_trans set x_transact_date=sysdate,
 x_result='Completed' where x_reason='Payment Failure-Rev' and x_result='Pending'
 and x_service_id=no_fund_change_rec.x_esn
   and  x_transact_date =
  (select max(x_transact_date) from table_x_call_trans where x_reason='Payment Failure-Rev' and x_result='Pending' and x_service_id=no_fund_change_rec.x_esn);
-- end CR3001
                --CR2158
                EXCEPTION
		WHEN OTHERS THEN
            	Toss_Util_Pkg.INSERT_ERROR_TAB_PROC('Insert D in x_send_ftp_auto.',
	                                                NVL(no_fund_change_rec.x_esn,'N/A'),
	                                                v_procedure_name,substr(sqlerrm,150));
		END;
                END LOOP;
                --End CR 1171
		-- 11/14/02
		--   Inactivate unprocessed 30-day old autopay detail.
				FOR app_radio_shack_rec in app_radio_shack ( v_date) LOOP
		 BEGIN
		  deactive_program_prc(app_radio_shack_rec.x_esn,'Bonus Plan',v_msg,v_status);
		  IF NVL(v_status,'F') = 'S' THEN
		     -- start CR 1157
		     Update table_x_autopay_details dtl
		     set x_status ='I', x_end_date=sysdate
		     where dtl.rowid = app_radio_shack_rec.rowid;
		      /*DELETE FROM table_x_autopay_details dtl
		     WHERE dtl.rowid = app_radio_shack_rec.rowid;*/
		     --end CR 1157
		  ELSE
		     Toss_Util_Pkg.INSERT_ERROR_TAB_PROC('Deactivate Bonus Plan program.',
	                                                NVL(app_radio_shack_rec.x_esn,'N/A'),
	                                                v_procedure_name,v_msg);
		     GOTO next_rec;
		  END IF;
		 EXCEPTION
		   WHEN others THEN
	            Toss_Util_Pkg.INSERT_ERROR_TAB_PROC('Update unprocessed autopay record.',
	                                                NVL(app_radio_shack_rec.x_esn,'N/A'),
	                                                v_procedure_name,substr(sqlerrm,150));
		 END;
		 <<next_rec>>
		 NULL;
		END LOOP;
		--
		-- End of 11/14/02
		--
		SELECT COUNT(*) INTO v_last_day FROM dual WHERE TRUNC(v_date) = TRUNC(LAST_DAY(v_date));
		IF v_last_day = 0
		THEN
			FOR app_details_rec IN app_details_c(v_date)
			LOOP
				v_esn := app_details_rec.x_esn;
				validESN := validateESN_fun(app_details_rec.x_esn);
				IF validESN = TRUE
				THEN
				        select trim(to_char(sysdate,'DAY')) into dayVal from dual; -- CR 1142
				        dbms_output.put_line(dayVal);
					v_amount := get_amount_fun(app_details_rec.x_program_type);
					INSERT INTO X_SEND_FTP_AUTO
		       	 	(
			       	 	SEND_SEQ_NO,
			       	 	file_type_ind,
			       	 	esn,
			       	 	program_type,
			       	 	account_status,
						amount_due,
						debit_date
					 )
		       	 	 VALUES
		       	 	 (
			       	 	seq_X_send_ftp_auto.NEXTVAL,
			       	 	'D',
			       	 	app_details_rec.x_esn,
			       	 	app_details_rec.x_program_type,
			       	 	'A',
					v_amount,
					decode(dayVal,'FRIDAY',sysdate+3,'SATURDAY',sysdate+2,sysdate+1) -- CR 1142
		       	 	  );
					  INSERT_CALL_TRANS_PRC(app_details_rec.x_esn,84,'AUTOPAY PROGRAM BATCH','Monthly
Payments','STAYACT PAYMENT','Pending');
		             END IF;
				--insert into send_ftp
			END LOOP;
		--exec cursor_adv
		ELSE
			FOR app_details_adv_rec IN app_details_adv_c(v_date)
			LOOP
				v_esn := app_details_adv_rec.x_esn;
				validESN := validateESN_fun(app_details_adv_rec.x_esn);
				IF validESN = TRUE
				THEN
				        select trim(to_char(sysdate,'DAY')) into dayVal from dual; -- CR 1142
				        dbms_output.put_line(dayVal);
					v_amount := get_amount_fun(app_details_adv_rec.x_program_type);
					INSERT INTO X_SEND_FTP_AUTO
		       	 	 (
			       	 	SEND_SEQ_NO,
			       	  	file_type_ind,
			       	 	esn,
			       	 	program_type,
			       	 	account_status,
						amount_due,
						debit_date
		       	  	 )
		       	 	 VALUES
		       	 	 (
			       	 	seq_x_send_ftp_auto.NEXTVAL,
			       	  	'D',
			       	 	app_details_adv_rec.x_esn,
			       	 	app_details_adv_rec.x_program_type,
			       	 	'A',
					v_amount,
					decode(dayVal,'FRIDAY',sysdate+3,'SATURDAY',sysdate+2,sysdate+1) -- CR 1142
		       	 	 );
INSERT_CALL_TRANS_PRC(app_details_adv_rec.x_esn,84,'AUTOPAY PROGRAM BATCH','Monthly Payments','STAYACT PAYMENT','Pending');
		             END IF;
				--insert into send_ftp
			END LOOP;
		--exec cursor_nor
		END IF;
	COMMIT;
		EXCEPTION WHEN OTHERS
		THEN
			Toss_Util_Pkg.INSERT_ERROR_TAB_PROC('Error IN Fetch_AHP_esn_prc',NVL(v_esn,'N/A'),v_procedure_name);
	END FETCH_AHP_ESN_PRC;
/*************************************************************************
 * Procedure: DEACTIVE_PROGRAM
 * Purpose  : Scan through all the autopay promotions for the ESN,
 *            If Payment Not Success then DoBillerNote Procedure call this
 *            Procedure to remove from Program.
 **************************************************************************/
PROCEDURE DEACTIVE_PROGRAM_prc
  			   (
  			     p_accountNumber varchar2,
  			     p_name varchar2,
  			     p_msgs OUT varchar2,
  			     c_p_statuss OUT varchar2
  			   )
  IS
  v_count number;
  v_call_trans_objid NUMBER;
  BEGIN
  	select count(*) into v_count from table_x_autopay_details where X_ESN=p_accountNumber and X_STATUS='E';
	---p_msgs:= 'Sucessfull';
 	IF v_count=0 THEN
	IF  p_name='AutoPay' THEN  --Check for AP
	   	INSERT_CALL_TRANS_prc(
	   			  p_accountNumber,
				  '83',
				  '13',
				  'STAYACT UNSUBSCRIBE',--'Cancellation',--CR 1157
				  'No Biller Radioshack',--'STAYACT UNSUBSCRIBE',
				  'Completed',
				  p_msgs,
	 			  c_p_statuss
	 		        );
        END IF;
        IF  p_name='Bonus Plan' THEN  --Check for BP
        	INSERT_CALL_TRANS_prc(
				  p_accountNumber,
				  '83',
				  '13',
				  'STAYACT UNSUBSCRIBE',--'Cancellation',
				  'No Biller Radioshack',--'STAYACT UNSUBSCRIBE',--CR 1157
				  'Completed',
				   p_msgs,
				   c_p_statuss
			         );
	END IF;
	IF p_name='Deactivation Protection' THEN  --Check for DP
	       INSERT_CALL_TRANS_prc(
	       			 p_accountNumber,
				 '83',
				 '13',
				 'STAYACT UNSUBSCRIBE',--'Cancellation',
				 'No Biller Radioshack',--'STAYACT UNSUBSCRIBE',--CR 1157
				 'Completed',
				 p_msgs,
				 c_p_statuss
	        	        );
       END IF;
       ELSE
       Select objid into v_call_trans_objid from table_x_call_trans
       where x_action_type='82' and x_service_id= p_accountNumber and x_result='Pending';
       Update table_x_call_trans set x_result='Cancel',x_transact_date=sysdate where objid=v_call_trans_objid;
       END IF;
       c_p_statuss := 'S';
       EXCEPTION
          WHEN OTHERS THEN
            c_p_statuss := 'F';
            p_msgs := 'Fail to insert record into table_x_call_trans >> '
                         ||SUBSTR(SQLERRM,1,100);
       RETURN;
  END DEACTIVE_PROGRAM_prc;
  /*************************************************************************
   * Procedure: INSERT_CALL_TRANS
   * Purpose  : To Insert Record into TABLE_X_CALL_TRANS
   **************************************************************************/
   PROCEDURE INSERT_CALL_TRANS_prc(
  			    p_accountNumber Varchar2,
  			    p_act_type Varchar2,
  			    p_ls Varchar2,
  			    p_action_t Varchar2,
  			    p_Reason Varchar2,
  			    p_res   Varchar2,
  			    p_msgs OUT Varchar2,
  			    c_p_statusss OUT Varchar2
  			    )
  IS
  /* cursor to retrieve DATA from tables table_x_carrier,table_part_inst,table_inv_role
   * table_inv_bin,table_part_inst and sp.state_code for active Line*/
  CURSOR sp_curs_c(esn in varchar2)
  IS
  Select sp.objid                    site_part_objid,
      sp.x_min                    x_min,
      ca.objid                    carrier_objid,
      ir.inv_role2site            site_objid,
      ca.x_carrier_id             x_carrier_id,
      sp.site_objid               cust_site_objid,
      sp.state_code               v_state_code
  from
      table_x_carrier  ca,
      table_part_inst  pi2, ---x_Domain=Line
      table_inv_role   ir,
      table_inv_bin    ib,
      table_part_inst  pi,  ---x_Domain=Phone
      table_site_part  sp
  where ca.objid                 = pi2.part_inst2carrier_mkt
      and initcap(pi2.x_domain)    = 'Lines'
      and pi2.part_serial_no       = sp.x_min
      and ir.inv_role2inv_locatn   = ib.inv_bin2inv_locatn
      and ib.objid                 = pi.part_inst2inv_bin
      and pi.x_part_inst2site_part = sp.objid
      and (sp.part_status)         = 'Active'
      and sp.x_service_id          = esn;
  sp_curs_rec sp_curs_c%rowtype;
  /* cursor to generate objid*/
  CURSOR call_trans_seq_c
  IS
  -- 04/10/03 SELECT seq_x_call_trans.NEXTVAL + POWER (2, 28) val
  select seq('x_call_trans') val
  FROM dual;
   call_trans_seq_rec call_trans_seq_c%ROWTYPE;
  v_user number;
  BEGIN
        OPEN sp_curs_c(p_accountNumber);
        	             Fetch sp_curs_c into sp_curs_rec;
        CLOSE sp_curs_c;
        -- Get objid for the call trans
        OPEN call_trans_seq_c;
  	      FETCH call_trans_seq_c INTO call_trans_seq_rec;
        CLOSE call_trans_seq_c;
        v_user := get_user_objid_fun('SA');
        ---Insert into TABLE_X_CALL_TRANS
        INSERT INTO TABLE_X_CALL_TRANS
        (
  		 objid,
  		 call_trans2site_part,
  		 x_action_type,
  		 x_call_trans2carrier,
  		 x_call_trans2dealer,
  		 x_call_trans2user,
  		 x_line_status,
  		 x_min,
  		 x_service_id,
  		 x_sourcesystem,
  		 x_transact_date,
  		 x_total_units,
  		 x_action_text,
  		 x_reason,
  		 x_result,
  		 x_sub_sourcesystem
         )
         VALUES(
  	      call_trans_seq_rec.val,
  	      sp_curs_rec.site_part_objid,
  	      p_act_type,
  	      sp_curs_rec.carrier_objid,
  	      sp_curs_rec.site_objid,
  	      v_user,
  	      p_ls,
  	      sp_curs_rec.x_min,
  	      p_accountNumber,
  	      'AUTOPAY_BATCH',
  	      sysdate,
  	      0,
  	      p_action_t,
  	      p_Reason,
  	      p_res,
  	      '202'
  	     );
      	p_msgs:='Sucessfull';
  	c_p_statusss :='S';
   	EXCEPTION
     	WHEN OTHERS THEN
	  IF call_trans_seq_c%ISOPEN THEN
     	 CLOSE call_trans_seq_c;
		  END IF ;
  		  IF sp_curs_c%ISOPEN THEN
     	 CLOSE sp_curs_c;
		  END IF ;
           c_p_statusss := 'F';
           p_msgs := 'Fail to insert record into table_x_call_trans >> '
                    ||SUBSTR(SQLERRM,1,100);
          RETURN;
END INSERT_CALL_TRANS_prc;
/******************************************
* Function : get_user_objid
* Purpose  : get user Object Id
* IN: varchar2
* OUT: number  -- objid
*******************************************/
FUNCTION get_user_objid_fun (p_login_name varchar2) return number
IS
v_user_objid number;
BEGIN
	Select objid into v_user_objid
	from table_user
	where upper(s_login_name) = p_login_name;
	RETURN v_user_objid;
	EXCEPTION
	WHEN others THEN
	RETURN NULL;
END get_user_objid_fun;
END Outbound_Autopay_Pkg;
/