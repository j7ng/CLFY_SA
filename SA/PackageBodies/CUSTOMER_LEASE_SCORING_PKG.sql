CREATE OR REPLACE PACKAGE BODY sa.customer_lease_scoring_pkg AS
 /******************************************************************************/
 /* Copyright 2002 Tracfone Wireless Inc. All rights reserved */
 /*
 * --$RCSfile: CUSTOMER_LEASE_SCORING_PKB.sql,v $
 --$Revision: 1.80 $
 --$Author: skambhammettu $
 --$Date: 2018/03/01 19:14:31 $
 --$ $Log: CUSTOMER_LEASE_SCORING_PKB.sql,v $
 --$ Revision 1.80  2018/03/01 19:14:31  skambhammettu
 --$ Change in get_group_summary
 --$
 --$ Revision 1.79  2018/02/28 22:05:08  skambhammettu
 --$ CR55236--Add new input parameter i_language in get_full_account_summary
 --$
 --$ Revision 1.78 2017/06/16 21:57:01 nmuthukkaruppan
 --$ CR50154 - ST LTO - Updating with Subrelease tag
 --$
 --$ Revision 1.77 2017/05/19 19:18:37 nmuthukkaruppan
 --$ CR50154 - ST LTO merged with Production version
 --$
 --$ Revision 1.76 2017/04/27 21:38:12 sgangineni
 --$ CR49875 - Chaanges in get_full_account_summary overloaded procedure
 --$
 --$ Revision 1.75 2017/04/27 21:34:46 sgangineni
 --$ CR49875 - Emergency CR changes
 --$
 --$ Revision 1.73 2017/04/11 21:55:50 smeganathan
 --$ removed get_full_account_summary overloaded procedure
 --$
 --$ Revision 1.72 2017/04/11 19:08:25 sgangineni
 --$ CR48944 - New overloaded procedure get_full_account_summary by Sabu
 --$
 --$ Revision 1.71 2017/03/20 20:46:18 nsurapaneni
 --$ Replaced Migration Package with Customer info
 --$
 --$ Revision 1.70 2017/03/16 21:45:18 sraman
 --$ CR47564 - WFM - Changes to get_full_account_summary procedure to return additional
 --$
 --$ Revision 1.69 2017/03/14 19:03:24 sgangineni
 --$ CR47564 - WFM - Changes to get_full_account_summary procedure to return additional
 --$ output parameters carrier_name, sim_status and sim_legacy_flag
 --$
 --$ Revision 1.68 2017/03/10 21:48:00 nsurapaneni
 --$ Added Transaction Pending column
 --$
 --$ Revision 1.67 2017/03/08 22:57:51 nsurapaneni
 --$ Added TRANSACTION_PENDING to ref cursor in get full account summary
 --$
 --$ Revision 1.66 2017/02/01 16:11:30 nmuthukkaruppan
 --$ CR47564 - Added new attributes in overloaded proc get_full_account_summary for WFM
 --$
 --$ Revision 1.65 2017/01/31 23:24:58 nmuthukkaruppan
 --$ CR47564 - Added new attributes in overloaded proc get_full_account_summary for WFM
 --$
 --$ Revision 1.64 2017/01/24 20:30:41 smeganathan
 --$ CR47564 Merged with 1/23 prod release
 --$
 --$ Revision 1.62 2017/01/12 23:50:51 abustos
 --$ CR46039 - get_info_for_pin - include logic for status 42. Also return min and esn for all scenarios
 --$
 --$ Revision 1.61 2016/11/15 19:28:38 vyegnamurthy
 --$ CR46039
 --$
 --$ Revision 1.61 2016/11/10 23:05:57 SMEGANATHAN
 --$ CR46039 - New proc p_get_info_for_pin added
 /* NAME: CUSTOMER_LEASE_SCORING_PKG */
 /* PURPOSE: SA.CUSTOMER_LEASE_SCORING_PKG -CR37233 */
 /* FREQUENCY: */
 /* PLATFORMS: Oracle 11g AND newer versions. */
 /* */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------- ---------- --------- ----------------------------------------*/
 /* 1.0 09/22/2015 Veda Initial Revision */
 /* 1.1 11/22/2015 SMEGANATHAN / Changes for Total Wireless Plus CR39389 */
 /* JPENA */
 /******************************************************************************/
procedure p_log_scoring_transaction ( in_application_req_num IN VARCHAR2,
 in_min IN VARCHAR2,
 in_first_name IN VARCHAR2,
 in_email_id IN VARCHAR2,
 in_client_id IN VARCHAR2,
 in_score_code IN VARCHAR2,
 out_transaction_id OUT VARCHAR2,
 out_transaction_date OUT TIMESTAMP,
 out_error_code OUT NUMBER,
 out_error_message OUT VARCHAR2 ) AS

BEGIN
 INSERT
 INTO sa.phbx_scoring_transaction
 ( objid ,
 application_req_num ,
 x_min ,
 customer_fname ,
 email_address ,
 client_id ,
 transaction_dt ,
 scoring_code ,
 transaction_id
 )
 VALUES
 ( seq_phbx_scoring_transaction.NEXTVAL,
 in_application_req_num,
 in_min,
 in_first_name,
 in_email_id ,
 in_client_id,
 systimestamp,
 in_score_code,
 randomuuid
 )
 RETURNING transaction_id,
 transaction_dt
 INTO out_transaction_id,
 out_error_message;
 EXCEPTION
 WHEN OTHERS THEN
 out_error_code := -99;
 out_error_message := SQLERRM;
END;

-- Procedure to update the group id called by SOA
PROCEDURE update_lease_group_id ( i_application_req_num IN VARCHAR2 ,
 i_account_group_id IN NUMBER ,
 o_error_code OUT NUMBER ,
 o_error_msg OUT VARCHAR2 ) AS

BEGIN
 --
 IF i_application_req_num IS NULL THEN
 o_error_code := 100;
 o_error_msg := 'APPLICATION ID CANNOT BE NULL';
 RETURN;
 END IF;

 --
 UPDATE sa.x_customer_lease
 SET account_group_id = i_account_group_id
 WHERE application_req_num = i_application_req_num;

 o_error_code := 0;
 o_error_msg := 'SUCCESS';

 EXCEPTION
 WHEN OTHERS THEN
 o_error_code := 999;
 o_error_msg := SQLERRM;
END update_lease_group_id;


PROCEDURE p_update_esn_lease_status ( in_esn IN VARCHAR2,
 in_application_req_num IN VARCHAR2,
 in_lease_status IN VARCHAR2,
 in_brand IN VARCHAR2,
 in_client_id IN VARCHAR2,
 in_smp IN VARCHAR2 DEFAULT NULL, -- new parameter for TW+ CR39389
 in_account_group_id IN NUMBER DEFAULT NULL, -- new parameter for TW+ CR39389
 in_merchant_id IN VARCHAR2 DEFAULT NULL, --CR41570 Dollar General
 out_error_code OUT NUMBER,
 out_error_msg OUT VARCHAR2,
 in_lease_scope		 IN VARCHAR2 DEFAULT NULL) AS --CR48014 ST LTO

 lv_error_code NUMBER;
 lv_error_msg VARCHAR2(4000);
 e_invalid_input EXCEPTION;
 esn_exist NUMBER;
 lv_lease_cnt NUMBER;
 lease_status_rec sa.x_lease_status%ROWTYPE;
 l_new_master_esn VARCHAR2(30);
 --
 -- instantiate initial values
 rc sa.customer_type := customer_type ( i_esn => in_esn );
 rcg sa.customer_type := customer_type ();
 --
 -- type to hold retrieved attributes
 cst sa.customer_type;
 cstg sa.customer_type;
 --
 -- Alert type initialization
 alt alert_type := alert_type();
 a alert_type;

begin

 if in_esn is null then
 lv_error_code := -311;
 lv_error_msg := 'Please provide a valid Serial Number(ESN)';
 raise e_invalid_input;
 end if;


 if in_application_req_num is null
 then
 lv_error_code := -311;
 lv_error_msg := 'Please provide a valid Application Request Number';
 raise e_invalid_input;
 end if;

 if in_lease_status is null then
 lv_error_code := -311;
 lv_error_msg := 'Please provide a valid Lease Status';
 raise e_invalid_input;
 end if;

 if in_brand is null then
 lv_error_code := -311;
 lv_error_msg := 'Please provide a valid Brand';
 raise e_invalid_input;
 end if;

 if in_client_id is null then
 lv_error_code := -311;
 lv_error_msg := 'Please provide a valid Client Id';
 raise e_invalid_input;
 end if;

 SELECT count(1)
 INTO lv_lease_cnt
 FROM x_lease_status
 WHERE lease_status = in_lease_status;

 IF lv_lease_cnt = 0 THEN
 out_error_code := -311;
 out_error_msg := 'Please provide a valid Lease Status';
 END IF;

 -- Check if ESN is available on table_part_inst
 SELECT COUNT(1)
 INTO esn_exist
 FROM table_part_inst
 WHERE part_serial_no = in_esn;

 IF esn_exist = 0 THEN
 out_error_code := 101;
 out_error_msg := 'Serial Number not found';
 RETURN;
 END IF;

 -- call the customer type retrieve method
 cst := rc.retrieve;

 -- Check brand for ESN for Phone in a box the brand to be checked is STRAIGHT_TALK
 IF NVL(cst.brand_leasing_flag,'N') <> 'Y' THEN
 out_error_code := 125;
 out_error_msg := 'ESN/Brand does not allow device leasing';
 RETURN;
 END IF;

 -- Only validate the lease application id for passed groups
 IF in_account_group_id IS NOT NULL THEN
 BEGIN
 SELECT application_req_num
 INTO rc.application_req_num
 FROM sa.x_customer_lease
 WHERE account_group_id = in_account_group_id;
 EXCEPTION
 WHEN others THEN
 NULL;
 END;
 -- When there is a different existing lease application id for an existing group
 IF rc.application_req_num IS NOT NULL AND
 cst.application_req_num IS NOT NULL AND
 rc.application_req_num != cst.application_req_num
 THEN
 out_error_code := 155;
 out_error_msg := 'Group belongs to another lease application id ( ' || rc.application_req_num || ' )';
 RETURN;
 -- When there is a different existing lease application id (vs the new passed lease application id) for an existing group
 ELSIF rc.application_req_num IS NOT NULL AND
 in_application_req_num IS NOT NULL AND
 rc.application_req_num != in_application_req_num
 THEN
 out_error_code := 165;
 out_error_msg := 'Group belongs to another lease application id ( ' || rc.application_req_num || ' )';
 RETURN;
 END IF;
	--
 END IF;

 --
 MERGE
 INTO sa.x_customer_lease els
 USING ( SELECT in_esn esn,
 in_lease_status lease_status,
 in_client_id client_id,
 in_application_req_num application_req_num,
 in_smp smp,
 in_account_group_id account_group_id,
 in_merchant_id merchant_id,
 in_lease_scope lease_scope --CR48014
 FROM DUAL
 ) input
 ON ( input.esn = els.x_esn )
 WHEN MATCHED THEN
 UPDATE
 SET els.lease_status = NVL(input.lease_status,els.lease_status),
 els.client_id = NVL(input.client_id,els.client_id),
 els.application_req_num = NVL(input.application_req_num,els.application_req_num),
 els.update_dt = systimestamp,
 els.smp = NVL(input.smp,els.smp),
 els.account_group_id = NVL(input.account_group_id,els.account_group_id),
 els.x_merchant_id = NVL(input.merchant_id,els.x_merchant_id),
 els.lease_scope = NVL(input.lease_scope,els.lease_scope) --CR48014
 WHEN NOT MATCHED THEN
 INSERT ( objid,
 x_esn,
 application_req_num,
 lease_status,
 client_id,
 insert_dt,
 update_dt,
 smp,
 account_group_id,
 x_merchant_id,
 lease_scope --CR48014
 )
 VALUES
	( seq_x_customer_lease.NEXTVAL,
 input.esn,
 input.application_req_num,
 input.lease_status,
 input.client_id,
 systimestamp,
 systimestamp,
 input.smp,
 input.account_group_id,
 input.merchant_id,
 input.lease_scope --CR48014
 );
 --
 -- When a new leased device is added to an existing Leased / Non Lease Group.
 IF in_account_group_id IS NOT NULL AND in_lease_status = '1001'
 AND cst.brand_shared_group_flag = 'Y' -- CR43400
 THEN
 --
 cstg := rcg.retrieve_group (i_account_group_objid => in_account_group_id);
 --
 INSERT INTO table_x_contact_part_inst
 (objid
 ,x_contact_part_inst2contact
 ,x_contact_part_inst2part_inst
 ,X_ESN_NICK_NAME
 ,X_IS_DEFAULT)
 VALUES
 (seq('x_contact_part_inst')
 ,cstg.group_contact_objid
 ,cst.esn_part_inst_objid
 ,NULL
 ,0
 );
 END IF;
 --
 -- Get the lease status flags
 IF in_lease_status IS NOT NULL THEN
 BEGIN
 SELECT *
 INTO lease_status_rec
 FROM sa.x_lease_status
 WHERE lease_status = in_lease_status;
 EXCEPTION
 WHEN others THEN
 NULL;
 END;
 --
 IF lease_status_rec.lease_status <> '1005'
 THEN
 -- instantiate the alert values
 alt := alert_type ( i_esn_part_inst_objid => cst.esn_part_inst_objid,
 i_title => 'Lease on Risk Assessment Alert');
 --
 -- delete the alert row of the same ESN and TITLE due to change in Risk Status
 a := alt.del;
 --
 END IF;
 --
 END IF;
 out_error_code := 0;
 out_error_msg := 'SUCCESS';

 EXCEPTION
 WHEN e_invalid_input THEN
 out_error_code := lv_error_code;
 out_error_msg := lv_error_msg;
 WHEN OTHERS THEN
 out_error_code := -99;
 out_error_msg := SQLERRM;
END p_update_esn_lease_status;
--
PROCEDURE p_get_time_as_cust_score ( io_application_req_num IN OUT VARCHAR2,
 io_min IN OUT VARCHAR2,
 in_first_name IN VARCHAR2,
 in_email_id IN VARCHAR2,
 in_client_id IN VARCHAR2,
 out_trans_date OUT VARCHAR2,
 out_score_code OUT VARCHAR2,
 out_transaction_id OUT VARCHAR2,
 out_error_code OUT NUMBER,
 out_error_msg OUT VARCHAR2 ) AS

 /*07232015: This procedure is created for Phone in a Box project.
 The aim of this procedure is to return a score code based on the time a
 customer has been associated to Tracfone*/
 lv_part_status TABLE_SITE_PART.PART_STATUS%TYPE;
 lv_service_end_dt TABLE_SITE_PART.service_end_dt%TYPE;
 c_active_part CONSTANT TABLE_SITE_PART.PART_STATUS%TYPE := 'Active';
 lv_install_dt TABLE_SITE_PART.INSTALL_DATE%TYPE;
 lv_error_code NUMBER;
 lv_error_msg VARCHAR2(4000);
 lv_months_between NUMBER;
 lv_days_between NUMBER;
 lv_break_threshold number;
 lv_transaction_id varchar2(50);
 lv_score_code varchar2(30);
 lv_trans_date timestamp;
 lv_err_code number;
 lv_err_message varchar2(4000);

begin
 /* Check if required inputs are being passed*/
 if io_application_req_num is null then
 out_trans_date := to_char(sysdate, 'DD-MON-YY');
 out_error_code := -311;
 out_error_msg := 'Please provide a valid Application Request Number';
 return;
 end if;

 if io_min is null then
 out_trans_date := to_char(sysdate, 'DD-MON-YY');
 out_error_code := -311;
 out_error_msg := 'Please provide a valid Mobile Number';
 return;
 end if;

 if in_client_id is null then
 out_trans_date := to_char(sysdate, 'DD-MON-YY');
 out_error_code := -311;
 out_error_msg := 'Please provide a valid Client Id';
 return;
 end if;

 -- find the status and service end date of the given MIN. If the MIN is not found return X1 as the score
 begin
 WITH find_min_stat
 AS ( SELECT RANK() OVER (ORDER BY objid desc) site_rank, x_min, part_status, SP.INSTALL_DATE, service_end_dt, SP.X_DEACT_REASON
 FROM table_site_part sp
 WHERE x_min = io_min
 AND part_status <> 'Obsolete'
 )
 SELECT part_status,
 service_end_dt
 INTO lv_part_status,
 lv_service_end_dt
 FROM find_min_stat
 WHERE site_rank = 1;

 EXCEPTION
 WHEN no_data_found THEN
 -- Score code is set to X1 as the MIN is not found.
 lv_score_code := 'X1';

 -- logging the success transaction
 p_log_scoring_transaction ( in_application_req_num => io_application_req_num,
 in_min => io_min,
 in_first_name => in_first_name,
 in_email_id => in_email_id,
 in_client_id => in_client_id,
 in_score_code => lv_score_code,
 out_transaction_id => lv_transaction_id,
 out_transaction_date => lv_trans_date,
 out_error_code => lv_err_code,
 out_error_message => lv_err_message );
 IF lv_err_code <> 0 THEN
 out_error_code := lv_err_code;
 out_error_msg := lv_err_message ;
 RETURN;
 ELSE
 out_score_code := lv_score_code;
 out_transaction_id := lv_transaction_id;
 out_trans_date := to_char(lv_trans_date, 'DD-MON-YY');
 out_error_code := 0;
 out_error_msg := 'SUCCESS';
 --dbms_output.put_line( 'out_score_code excep:'||out_score_code);

 RETURN; --exit the procedure if this exception block is executed

 END IF;
 END;

 --dbms_output.put_line('lv_part_status:'||lv_part_status||' lv_service_end_dt:'||lv_service_end_dt);

 -- select the break threshold defined
 select range_start
 into lv_break_threshold
 from x_lease_scoring_rules
 where score_code = 'BREAK';

 --dbms_output.put_line('lv_break_threshold:'||lv_break_threshold);


 /*For Active MIN find the first activation date was.
 Considering Install date as activation date from site part
 Get this logic reviewed*/

 with temp as (
 select rank()over(partition by x_min order by objid asc) site_rank,
 x_min,
 part_status,
 SP.INSTALL_DATE,
 service_end_dt,
 lag(service_end_dt) over (order by objid) prev_service_end_dt,
 round( (SP.INSTALL_DATE - lag(service_end_dt) over (order by objid) ), 2) Inactive_days,
 SP.X_DEACT_REASON
 from table_site_part sp
 where
 x_min = io_min and
 part_status <> 'Obsolete'
 )
 select install_date , months_between(sysdate, install_date)
 into lv_install_dt , lv_months_between
 from (
 select INSTALL_DATE, row_number () over (order by INSTALL_DATE desc) rnum
 from (
 select INSTALL_DATE from temp where site_rank = 1
 union
 select INSTALL_DATE from temp where Inactive_days >= lv_break_threshold
 ))
 where rnum = 1;



 --dbms_output.put_line('lv_install_dt:'||lv_install_dt||' lv_months_between:'||lv_months_between);

 if lv_part_status = c_active_part -- part status if block
 then

 /*Get the score code based on the lv_months_between which is value of
 time customer is associated to tracfone*/
 select score_code
 into
 lv_score_code
 from
 X_LEASE_SCORING_RULES tcsr
 where
 lv_months_between >= tcsr.range_start
 and
 lv_months_between < nvl(tcsr.range_stop, binary_float_infinity);

 elsif (lv_part_status <> c_active_part)
 then

 lv_days_between := sysdate - lv_service_end_dt;
 --dbms_output.put_line('lv_days_between:'||lv_days_between);


 if lv_days_between >= lv_break_threshold -- deact days count if block
 then
 lv_score_code:= 'X1';
 else
 -- lv_months_between := months_between (lv_service_end_dt, lv_install_dt);
 --dbms_output.put_line( 'lv_months_between deact block:'||lv_months_between);


 /*Get the score code based on the lv_months_between which is value of
 time customer is associated to tracfone*/
 select score_code
 into
 lv_score_code
 from
 X_LEASE_SCORING_RULES tcsr
 where
 lv_months_between >= tcsr.range_start
 and
 lv_months_between < nvl(tcsr.range_stop, binary_float_infinity);

 end if; -- deact days count if block

 end if; -- part status if block


 --logging the success transaction
 p_log_scoring_transaction ( in_application_req_num => io_application_req_num,
 in_min => io_min,
 in_first_name => in_first_name,
 in_email_id => in_email_id,
 in_client_id => in_client_id,
 in_score_code => lv_score_code,
 out_transaction_id => lv_transaction_id,
 out_transaction_date => lv_trans_date,
 out_error_code => lv_err_code,
 out_error_message => lv_err_message );
 if lv_err_code <> 0 then
 out_error_code := lv_err_code;
 out_error_msg := lv_err_message ;
 return;
 else
 --dbms_output.put_line('setting out vals on success' );
 out_score_code := lv_score_code;
 out_transaction_id := lv_transaction_id;
 out_trans_date := to_char(lv_trans_date, 'DD-MON-YY');
 out_error_code := 0;
 out_error_msg := 'SUCCESS';
 --dbms_output.put_line( 'out_score_code:'||out_score_code);
 --dbms_output.put_line('logged:'||SQL%ROWCOUNT);
 end if;

 EXCEPTION
 WHEN OTHERS THEN
 out_trans_date := to_char(sysdate, 'DD-MON-YY');
 out_score_code := null;
 out_transaction_id := null;
 out_error_code := -99;
 out_error_msg := SQLERRM;

end p_get_time_as_cust_score;
--
-- CR39389 Changes Starts.
-- This procedure accepts Application Req num / Lease ID and return the OUTPUT variables
PROCEDURE p_group_esn_details ( i_application_req_num IN VARCHAR2,
 o_application_req_num OUT VARCHAR2,
 o_number_of_lines OUT VARCHAR2,
 o_available_lines OUT VARCHAR2,
 o_service_plan_id OUT VARCHAR2,
 o_red_card_code OUT VARCHAR2,
 o_group_id OUT VARCHAR2,
 o_refcursor OUT SYS_REFCURSOR ,
 o_err_code OUT NUMBER ,
 o_err_msg OUT VARCHAR2 ) AS

 -- type to hold attributes
 c sa.customer_type := customer_type();
 rc sa.customer_type := customer_type();
 cst sa.customer_type := customer_type();

 rct sa.red_card_type := sa.red_card_type();
 r sa.red_card_type := sa.red_card_type();
BEGIN

 -- Get the ESN
 BEGIN
 SELECT esn,
 smp,
 account_group_id
 INTO c.esn,
 c.smp,
 c.account_group_objid
 FROM ( SELECT x_esn esn,
 smp,
 account_group_id
 FROM x_customer_lease
 WHERE application_req_num = i_application_req_num
 ORDER BY CASE
 WHEN smp IS NOT NULL THEN 1
 ELSE 2
 END,
 lease_status
 )
 WHERE ROWNUM = 1;
 EXCEPTION
 WHEN others THEN
 o_err_code := '100';
 o_err_msg := 'ERROR: APPLICATION REQUEST NUMBER NOT FOUND';
 RETURN;
 END;

 -- initialize esn
 rc := customer_type ( i_esn => c.esn);


 -- call the retrieve method
 cst := rc.retrieve;

 -- Set the variables from the ESN
 IF cst.account_group_objid IS NOT NULL THEN

 --
 o_application_req_num := cst.application_req_num;
 o_number_of_lines := cst.group_allowed_lines;
 o_available_lines := cst.group_available_capacity;
 o_group_id := cst.account_group_objid;
 o_service_plan_id := cst.group_service_plan_objid;
 o_red_card_code := c.convert_smp_to_pin ( i_smp => cst.smp );

 ELSIF c.account_group_objid IS NOT NULL THEN
 -- Search for the output variables from the smp from the lease
 cst := customer_type ();
 cst := rc.retrieve_group ( i_account_group_objid => c.account_group_objid );

 o_application_req_num := i_application_req_num;
 o_number_of_lines := cst.group_allowed_lines;
 o_available_lines := cst.group_available_capacity;
 o_group_id := cst.account_group_objid;
 o_service_plan_id := cst.group_service_plan_objid;
 o_red_card_code := c.convert_smp_to_pin ( i_smp => cst.smp );

 ELSE
 -- Search for the output variables from the smp from the lease
 cst := customer_type ();
 cst := rc.retrieve_pin ( i_red_card_code => rc.convert_smp_to_pin ( i_smp => c.smp ));

 --
 o_application_req_num := cst.application_req_num;
 o_number_of_lines := cst.group_allowed_lines;
 o_available_lines := cst.group_available_capacity;
 o_group_id := cst.account_group_objid;
 o_service_plan_id := cst.service_plan_objid;
 o_red_card_code := c.convert_smp_to_pin ( i_smp => cst.smp );

 END IF;

 --
 OPEN o_refcursor
 FOR SELECT a.*,
 ( SELECT objid
 FROM x_account_group_member
 WHERE account_group_id = cst.account_group_objid
 AND esn = a.esn
 AND status <> 'EXPIRED'
 AND ROWNUM = 1 ) AS member_objid,
 (SELECT NVL(MASTER_FLAG,'N')
 FROM x_account_group_member
 WHERE account_group_id = cst.account_group_objid
 AND esn = a.esn
 AND status <> 'EXPIRED'
 AND ROWNUM = 1 ) AS esn_master_flag -- CR43088
 FROM ( SELECT cl.x_esn AS esn,
 ( SELECT pi_min.part_serial_no
 FROM table_part_inst pi_esn,
 table_part_inst pi_min
 WHERE pi_esn.part_serial_no = cl.x_esn
 AND pi_esn.x_domain = 'PHONES'
 AND pi_esn.objid = pi_min.part_to_esn2part_inst
 AND pi_min.x_domain = 'LINES'
 AND ROWNUM = 1
 ) AS min,
 (CASE
 WHEN ls.lease_status NOT IN ('1000','1003','1004','1006')
 THEN 'Y'
 ELSE 'N'
 END) AS isleased,
 ls.lease_status AS leasestatus,
 ( SELECT x_part_inst_status
 FROM table_part_inst
 WHERE part_serial_no = cl.x_esn
 AND x_domain = 'PHONES'
 ) AS esnstatus -- device status from part inst
 FROM sa.x_customer_lease cl,
 sa.x_lease_status ls
 WHERE cl.application_req_num = i_application_req_num
 AND cl.lease_status = ls.lease_status(+)
	 UNION
	 SELECT agm.esn AS esn,
 ( SELECT part_serial_no
 FROM table_part_inst
 WHERE part_to_esn2part_inst = pi_esn.objid
 AND x_domain = 'LINES'
 AND ROWNUM = 1
 ) AS min,
 (CASE
 WHEN ls.lease_status NOT IN ('1000','1003','1004','1006')
 THEN 'Y'
 ELSE 'N'
 END) AS isleased,
 (CASE
 WHEN ls.lease_status IS NULL THEN '1000' -- Default Non-Leased Status
 ELSE ls.lease_status
 END) AS leasestatus,
 pi_esn.x_part_inst_status AS esnstatus -- device status from part inst
 FROM sa.x_account_group_member agm,
 sa.table_part_inst pi_esn,
 sa.x_customer_lease cl,
 sa.x_lease_status ls
 WHERE agm.account_group_id = cst.account_group_objid
 AND UPPER(agm.status) != 'EXPIRED'
 AND agm.esn = pi_esn.part_serial_no
 AND pi_esn.x_domain = 'PHONES'
 AND agm.esn = cl.x_esn(+)
 AND cl.lease_status = ls.lease_status(+)
 ) a;

 o_err_code := 0;
 o_err_msg := 'SUCCESS';

 --
 EXCEPTION
 WHEN OTHERS THEN
 o_err_code := 999;
 o_err_msg := 'UNHANDLED EXCEPTION : ' || SQLERRM;
END p_group_esn_details;
--
-- Procedure which accepts esn and call the overloaded function with application req num
PROCEDURE p_group_esn_details ( i_esn IN VARCHAR2,
 o_application_req_num OUT VARCHAR2,
 o_number_of_lines OUT VARCHAR2,
 o_available_lines OUT VARCHAR2,
 o_service_plan_id OUT VARCHAR2,
 o_red_card_code OUT VARCHAR2,
 o_group_id OUT VARCHAR2,
 o_refcursor OUT SYS_REFCURSOR ,
 o_err_code OUT NUMBER ,
 o_err_msg OUT VARCHAR2 ) AS

 c sa.customer_type := customer_type();

 -- instantiate initial values
 rc sa.customer_type := customer_type ( i_esn => i_esn );

 -- type to hold retrieved attributes from retrieve method
 cst sa.customer_type := customer_type();

 -- type to hold retrieved attributes from pin retrieve method
 pct sa.customer_type := customer_type();

BEGIN
--
 IF i_esn IS NULL THEN
 o_err_code := 200;
 o_err_msg := 'ESN CANNOT BE NULL';
 RETURN;
 END IF;

 -- Get the ESN
 BEGIN
 SELECT smp,
 account_group_id,
 application_req_num
 INTO c.smp,
 c.account_group_objid,
 c.application_req_num
 FROM ( SELECT smp,
 account_group_id,
 application_req_num
 FROM x_customer_lease
 WHERE x_esn = i_esn
 UNION -- to include non leased ESN
 SELECT NULL as "smp",
 account_group_id,
 NULL as "application_req_num"
 FROM x_account_group_member
 WHERE esn = i_esn
 AND UPPER(status) != 'EXPIRED'
-- ORDER BY CASE
-- WHEN smp IS NOT NULL THEN 1
-- ELSE 2
-- END,
-- lease_status
 )
 WHERE ROWNUM = 1;
 EXCEPTION
 WHEN others THEN
 o_err_code := '100';
 o_err_msg := 'ERROR: ESN NOT FOUND';
 RETURN;
 END;

 -- call the retrieve method
 cst := rc.retrieve;

 IF cst.response NOT LIKE '%SUCCESS%' THEN
 o_err_code := 210;
 o_err_msg := 'ESN NOT FOUND: ' || cst.response;
 END IF;


 -- Set the variables from the ESN
 IF cst.account_group_objid IS NOT NULL THEN
 --
 o_application_req_num := cst.application_req_num;
 o_number_of_lines := cst.group_allowed_lines;
 o_available_lines := cst.group_available_capacity;
 o_group_id := cst.account_group_objid;
 o_service_plan_id := cst.group_service_plan_objid;
 o_red_card_code := c.convert_smp_to_pin ( i_smp => cst.smp );

 ELSIF c.account_group_objid IS NOT NULL THEN
 -- Search for the output variables from the smp from the lease
 cst := customer_type ();
 cst := rc.retrieve_group ( i_account_group_objid => c.account_group_objid );

 o_application_req_num := c.application_req_num;
 o_number_of_lines := cst.group_allowed_lines;
 o_available_lines := cst.group_available_capacity;
 o_group_id := cst.account_group_objid;
 o_service_plan_id := cst.group_service_plan_objid;
 o_red_card_code := c.convert_smp_to_pin ( i_smp => cst.smp );

 ELSE
 -- Search for the output variables from the smp from the lease
 cst := customer_type ();
 cst := rc.retrieve_pin ( i_red_card_code => rc.convert_smp_to_pin ( i_smp => c.smp ));

 --
 o_application_req_num := cst.application_req_num;
 o_number_of_lines := cst.group_allowed_lines;
 o_available_lines := cst.group_available_capacity;
 o_group_id := cst.account_group_objid;
 o_service_plan_id := cst.service_plan_objid;
 o_red_card_code := c.convert_smp_to_pin ( i_smp => cst.smp );

 END IF;

 -- Perform the search by group id
 IF cst.account_group_objid IS NOT NULL THEN

 -- Get the list of esns that belong to the group
 OPEN o_refcursor
 FOR SELECT a.*,
	 ( SELECT objid
 FROM x_account_group_member
 WHERE account_group_id = cst.account_group_objid
 AND esn = a.esn
 AND status <> 'EXPIRED'
 AND ROWNUM = 1 ) AS member_objid,
 ( SELECT NVL(MASTER_FLAG,'N')
 FROM x_account_group_member
 WHERE account_group_id = cst.account_group_objid
 AND esn = a.esn
 AND status <> 'EXPIRED'
 AND ROWNUM = 1 ) AS esn_master_flag -- CR43088
 FROM ( SELECT agm.esn AS esn,
 ( SELECT part_serial_no
 FROM table_part_inst
 WHERE part_to_esn2part_inst = pi_esn.objid
 AND x_domain = 'LINES'
 AND ROWNUM = 1
 ) AS min,
 (CASE
 WHEN ls.lease_status NOT IN ('1000','1003','1004','1006')
 THEN 'Y'
 ELSE 'N'
 END) AS isleased,
 (CASE
 WHEN ls.lease_status IS NULL THEN '1000' -- Default Non-Leased Status
 ELSE ls.lease_status
 END) AS leasestatus,
 pi_esn.x_part_inst_status AS esnstatus -- device status from part inst
 FROM sa.x_account_group_member agm,
 sa.table_part_inst pi_esn,
 sa.x_customer_lease cl,
 sa.x_lease_status ls
 WHERE agm.account_group_id = cst.account_group_objid
 AND UPPER(agm.status) != 'EXPIRED'
 AND agm.esn = pi_esn.part_serial_no
 AND pi_esn.x_domain = 'PHONES'
 AND agm.esn = cl.x_esn(+)
 AND cl.lease_status = ls.lease_status(+)
		 UNION
		 SELECT cl.x_esn AS esn,
 ( SELECT pi_min.part_serial_no
 FROM table_part_inst pi_esn,
 table_part_inst pi_min
 WHERE pi_esn.part_serial_no = cl.x_esn
 AND pi_esn.x_domain = 'PHONES'
 AND pi_esn.objid = pi_min.part_to_esn2part_inst
 AND pi_min.x_domain = 'LINES'
 AND ROWNUM = 1
 ) AS min,
 (CASE
 WHEN ls.lease_status NOT IN ('1000','1003','1004','1006')
 THEN 'Y'
 ELSE 'N'
 END) AS isleased,
 ls.lease_status AS leasestatus,
 ( SELECT x_part_inst_status
 FROM table_part_inst
 WHERE part_serial_no = cl.x_esn
 AND x_domain = 'PHONES'
 ) AS esnstatus -- device status from part inst
 FROM sa.x_customer_lease cl,
 sa.x_lease_status ls
 WHERE ( cl.application_req_num = c.application_req_num OR
				 cl.account_group_id = cst.account_group_objid
 )
 AND cl.lease_status = ls.lease_status(+)
	 ) a;

 -- Perform the search by SMP
 ELSE

 -- Call the retrieve pin method only the pin is available
 IF o_red_card_code IS NOT NULL THEN
 --
 rc := customer_type();

 pct := rc.retrieve_pin ( i_red_card_code => o_red_card_code );

 o_service_plan_id := pct.service_plan_objid;
 o_number_of_lines := pct.group_allowed_lines;
 o_available_lines := pct.group_available_capacity;

 END IF;

 --
 OPEN o_refcursor
 FOR SELECT cl.x_esn AS esn,
 ( SELECT pi_min.part_serial_no
 FROM table_part_inst pi_esn,
 table_part_inst pi_min
 WHERE pi_esn.part_serial_no = cl.x_esn
 AND pi_esn.x_domain = 'PHONES'
 AND pi_esn.objid = pi_min.part_to_esn2part_inst
 AND pi_min.x_domain = 'LINES'
 AND ROWNUM = 1
 ) AS min,
 (CASE
 WHEN ls.lease_status NOT IN ('1000','1003','1004','1006')
 THEN 'Y'
 ELSE 'N'
 END) AS isleased,
 ls.lease_status AS leasestatus,
 ( SELECT x_part_inst_status
 FROM table_part_inst
 WHERE part_serial_no = cl.x_esn
 AND x_domain = 'PHONES'
 ) AS esnstatus, -- device status from part inst
 ( SELECT objid
 FROM x_account_group_member
 WHERE esn = cl.x_esn
 AND status <> 'EXPIRED'
 AND ROWNUM = 1 ) AS member_objid,
 ( SELECT NVL(MASTER_FLAG,'N')
 FROM x_account_group_member
 WHERE esn = cl.x_esn
 AND status <> 'EXPIRED'
 AND ROWNUM = 1 ) AS esn_master_flag -- CR43088
 FROM sa.x_customer_lease cl,
 sa.x_lease_status ls
 WHERE cl.smp = cst.smp
 AND cl.lease_status = ls.lease_status(+);
 END IF;

 o_err_code := 0;
 o_err_msg := 'SUCCESS';

--
 EXCEPTION
 WHEN OTHERS THEN
 o_err_code := 999;
 o_err_msg := 'UNHANDLED EXCEPTION : ' || SQLERRM;
END p_group_esn_details;
--
-- Procedure which accepts PIN and call the overloaded function with application req num
PROCEDURE p_group_esn_details ( i_red_card_code IN VARCHAR2,
 o_application_req_num OUT VARCHAR2,
 o_number_of_lines OUT VARCHAR2,
 o_available_lines OUT VARCHAR2,
 o_service_plan_id OUT VARCHAR2,
 o_red_card_code OUT VARCHAR2,
 o_group_id OUT VARCHAR2,
 o_refcursor OUT SYS_REFCURSOR ,
 o_err_code OUT NUMBER ,
 o_err_msg OUT VARCHAR2 ) AS

 --
 c customer_type := customer_type();
 --
 cst customer_type := customer_type();

BEGIN
 --
 IF i_red_card_code IS NULL THEN
 o_err_code := '300';
 o_err_msg := 'PIN CANNOT BE NULL';
 RETURN;
 END IF;

 --
 c.smp := cst.convert_pin_to_smp ( i_red_card_code => i_red_card_code );
 --

 IF c.smp IS NULL THEN
 o_err_code := '310';
 o_err_msg := 'SMP NOT FOUND';
 RETURN;
 END IF;

 -- Get the ESN
 BEGIN
 SELECT x_esn
 INTO c.esn
 FROM x_customer_lease
 WHERE smp = c.smp
 AND ROWNUM = 1;
 EXCEPTION
 WHEN others THEN
 o_err_code := '320';
 o_err_msg := 'ERROR: LEASED PIN NOT FOUND';
 RETURN;
 END;

 --
 p_group_esn_details ( i_esn => c.esn,
 o_application_req_num => o_application_req_num,
 o_number_of_lines => o_number_of_lines,
 o_available_lines => o_available_lines,
 o_service_plan_id => o_service_plan_id,
 o_red_card_code => o_red_card_code,
 o_group_id => o_group_id,
 o_refcursor => o_refcursor,
 o_err_code => o_err_code,
 o_err_msg => o_err_msg);
--
 EXCEPTION
 WHEN OTHERS THEN
 o_err_code := 999;
 o_err_msg := 'UNHANDLED EXCEPTION : ' || SQLERRM;
END p_group_esn_details;
--
-- Procedure which accepts group ID and call the overloaded function with application req num
PROCEDURE p_group_esn_details ( i_group_id IN VARCHAR2,
 o_application_req_num OUT VARCHAR2,
 o_number_of_lines OUT VARCHAR2,
 o_available_lines OUT VARCHAR2,
 o_service_plan_id OUT VARCHAR2,
 o_red_card_code OUT VARCHAR2,
 o_group_id OUT VARCHAR2,
 o_refcursor OUT SYS_REFCURSOR ,
 o_err_code OUT NUMBER ,
 o_err_msg OUT VARCHAR2 ) AS

 --
 c customer_type := customer_type();

BEGIN
 --
 IF i_group_id IS NULL THEN
 o_err_code := 400;
 o_err_msg := 'GROUP ID CANNOT BE NULL';
 RETURN;
 END IF;

 -- Get the ESN
 BEGIN
 SELECT esn
 INTO c.esn
 FROM x_account_group_member
 WHERE account_group_id = i_group_id
 AND UPPER(status) != 'EXPIRED'
 AND ROWNUM = 1;
 EXCEPTION
 WHEN others THEN
 o_err_code := 410;
 o_err_msg := 'ERROR: LEASED GROUP ID NOT FOUND';
 RETURN;
 END;

 --
 p_group_esn_details ( i_esn => c.esn,
 o_application_req_num => o_application_req_num,
 o_number_of_lines => o_number_of_lines,
 o_available_lines => o_available_lines,
 o_service_plan_id => o_service_plan_id,
 o_red_card_code => o_red_card_code,
 o_group_id => o_group_id,
 o_refcursor => o_refcursor,
 o_err_code => o_err_code,
 o_err_msg => o_err_msg);
--
 EXCEPTION
 WHEN OTHERS THEN
 o_err_code := 999;
 o_err_msg := 'UNHANDLED EXCEPTION : ' || SQLERRM;
END p_group_esn_details;
--

-- Procedure which accepts MIN and call the overloaded function with esn
PROCEDURE p_group_esn_details ( i_min IN VARCHAR2,
 o_application_req_num OUT VARCHAR2,
 o_number_of_lines OUT VARCHAR2,
 o_available_lines OUT VARCHAR2,
 o_service_plan_id OUT VARCHAR2,
 o_red_card_code OUT VARCHAR2,
 o_group_id OUT VARCHAR2,
 o_refcursor OUT SYS_REFCURSOR ,
 o_err_code OUT NUMBER ,
 o_err_msg OUT VARCHAR2 ) AS

 -- initialize retrieve ct
 rc customer_type := customer_type ();

 -- initialize type
 c customer_type := customer_type();

BEGIN

 --
 IF i_min IS NULL THEN
 o_err_code := 500;
 o_err_msg := 'MIN CANNOT BE NULL';
 RETURN;
 END IF;

 -- Get the ESN
 c := rc.retrieve_min ( i_min => i_min );

 IF c.esn IS NULL THEN
 o_err_code := 510;
 o_err_msg := 'MIN NOT FOUND';
 RETURN;
 END IF;

 --
 p_group_esn_details ( i_esn => c.esn,
 o_application_req_num => o_application_req_num,
 o_number_of_lines => o_number_of_lines,
 o_available_lines => o_available_lines,
 o_service_plan_id => o_service_plan_id,
 o_red_card_code => o_red_card_code,
 o_group_id => o_group_id,
 o_refcursor => o_refcursor,
 o_err_code => o_err_code,
 o_err_msg => o_err_msg);
 --
 EXCEPTION
 WHEN OTHERS THEN
 o_err_code := 999;
 o_err_msg := 'UNHANDLED EXCEPTION : ' || SQLERRM;
END p_group_esn_details;
--
-- Procedure to get all the esns in the group
PROCEDURE getaccountsummary ( i_esn IN VARCHAR2,
 i_security_pin IN VARCHAR2,
 o_application_req_num OUT VARCHAR2,
 o_number_of_lines OUT NUMBER,
 o_available_lines OUT NUMBER,
 o_service_plan_id OUT VARCHAR2,
 o_service_plan_name OUT VARCHAR2,
 o_group_id OUT NUMBER,
 o_group_name OUT VARCHAR2,
 o_red_card_code OUT VARCHAR2,
 o_brand OUT VARCHAR2,
 o_first_name OUT VARCHAR2,
 o_last_name OUT VARCHAR2,
 o_login_name OUT VARCHAR2,
 o_refcursor OUT SYS_REFCURSOR ,
 o_err_code OUT NUMBER ,
 o_err_msg OUT VARCHAR2 ) IS

 -- instantiate initial values
 rc sa.customer_type := customer_type();

 -- type to hold retrieved attributes
 cst sa.customer_type := customer_type();

BEGIN

 --
 IF i_esn IS NULL THEN
 o_err_code := 600;
 o_err_msg := 'ESN NOT PASSED';
 RETURN;
 END IF;

 --
 IF i_security_pin IS NULL THEN
 o_err_code := 610;
 o_err_msg := 'SECURITY PIN NOT PASSED';
 RETURN;
 END IF;

 -- call the retrieve method
 cst := rc.retrieve ( i_esn => i_esn );

 IF cst.esn IS NULL THEN
 o_err_code := 620;
 o_err_msg := 'ESN NOT FOUND';
 END IF;

 IF cst.security_pin IS NULL THEN
 o_err_code := 630;
 o_err_msg := 'SECURITY PIN NOT FOUND IN ACCOUNT';
 RETURN;
 END IF;

 IF cst.security_pin != i_security_pin THEN
 o_err_code := 640;
 o_err_msg := 'SECURITY PIN NOT VALID FOR THE ACCOUNT ASSOCIATED WITH THE MIN';
 RETURN;
 END IF;

 -- Set the values from customer type
 o_brand := cst.bus_org_id;
 o_group_name := cst.account_group_name;
 o_first_name := cst.first_name;
 o_last_name := cst.last_name;
 o_login_name := cst.web_login_name;
 o_service_plan_name := cst.service_plan_name;

 --
 p_group_esn_details ( i_esn => cst.esn,
 o_application_req_num => o_application_req_num,
 o_number_of_lines => o_number_of_lines,
 o_available_lines => o_available_lines,
 o_service_plan_id => o_service_plan_id,
 o_red_card_code => o_red_card_code,
 o_group_id => o_group_id,
 o_refcursor => o_refcursor,
 o_err_code => o_err_code,
 o_err_msg => o_err_msg );

 IF o_err_msg != 'SUCCESS' THEN
 o_err_code := 650;
 o_err_msg := 'ERROR IN GET GROUP ESN DETAILS: ' || o_err_msg;
 RETURN;
 END IF;

 o_err_code := 0;
 o_err_msg := 'SUCCESS';

 EXCEPTION
 WHEN others THEN
 o_err_code := 999;
 o_err_msg := 'ERROR VALIDATING ESN AND SECURITY PIN: ' || SQLERRM;
END getaccountsummary;

-- Get the entire list of ESNs tied to a min (account / all groups in the account)
PROCEDURE getfullaccountsummary ( i_esn IN VARCHAR2,
 i_security_pin IN VARCHAR2,
 i_bus_org_id IN VARCHAR2,
 o_application_req_num OUT VARCHAR2,
 o_number_of_lines OUT NUMBER,
 o_available_lines OUT NUMBER,
 o_service_plan_id OUT VARCHAR2,
 o_service_plan_name OUT VARCHAR2,
 o_group_id OUT NUMBER,
 o_group_name OUT VARCHAR2,
 o_red_card_code OUT VARCHAR2,
 o_brand OUT VARCHAR2,
 o_first_name OUT VARCHAR2,
 o_last_name OUT VARCHAR2,
 o_login_name OUT VARCHAR2,
 o_refcursor OUT SYS_REFCURSOR ,
 o_err_code OUT NUMBER ,
 o_err_msg OUT VARCHAR2 ) IS

 -- instantiate initial values
 rc sa.customer_type := customer_type();

 -- type to hold retrieved attributes
 cst sa.customer_type := customer_type();

BEGIN

 --
 IF i_esn IS NULL THEN
 o_err_code := 600;
 o_err_msg := 'ESN NOT PASSED';
 RETURN;
 END IF;

 --
 IF i_security_pin IS NULL THEN
 o_err_code := 610;
 o_err_msg := 'SECURITY PIN NOT PASSED';
 RETURN;
 END IF;

 --
 IF i_bus_org_id IS NULL THEN
 o_err_code := 610;
 o_err_msg := 'BRAND NOT PASSED';
 RETURN;
 END IF;

 -- call the retrieve function by min
 cst := rc.retrieve ( i_esn => i_esn );

 IF cst.esn IS NULL THEN
 o_err_code := 620;
 o_err_msg := 'ESN NOT FOUND';
 END IF;

 IF cst.web_user_objid IS NULL THEN
 o_err_code := 630;
 o_err_msg := 'WEB ACCOUNT LOGIN NAME NOT FOUND';
 RETURN;
 END IF;

 IF cst.security_pin IS NULL THEN
 o_err_code := 640;
 o_err_msg := 'SECURITY PIN NOT FOUND IN ACCOUNT';
 RETURN;
 END IF;

 IF cst.security_pin != i_security_pin THEN
 o_err_code := 650;
 o_err_msg := 'SECURITY PIN NOT VALID FOR THE ACCOUNT ASSOCIATED WITH THE MIN';
 RETURN;
 END IF;

 -- Set the values from customer type
 o_brand := cst.bus_org_id;
 o_group_name := cst.account_group_name;
 o_application_req_num := cst.application_req_num;
 o_number_of_lines := cst.group_allowed_lines;
 o_available_lines := cst.group_available_capacity;
 o_service_plan_id := cst.service_plan_objid;
 o_service_plan_name := cst.service_plan_name;
 o_red_card_code := cst.pin;
 o_group_id := cst.account_group_objid;
 o_first_name := cst.first_name;
 o_last_name := cst.last_name;
 o_login_name := cst.web_login_name;

 -- instantiate the brand (bus_org_id)
 rc.bus_org_id := i_bus_org_id;

 -- call the get function to set the brand objid
 cst.bus_org_objid := rc.get_bus_org_objid;

 -- Get the list of esns that belong to the group
 OPEN o_refcursor
 FOR SELECT agm.esn AS esn,
 ( SELECT part_serial_no
 FROM table_part_inst
 WHERE part_to_esn2part_inst = pi_esn.objid
 AND x_domain = 'LINES'
 AND ROWNUM = 1
 ) AS min,
 (CASE
 WHEN ls.lease_status NOT IN ('1000','1003','1004','1006')
 THEN 'Y'
 ELSE 'N'
 END) AS isleased,
 (CASE
 WHEN ls.lease_status IS NULL THEN '1000' -- Default Non-Leased Status
 ELSE ls.lease_status
 END) AS leasestatus,
 pi_esn.x_part_inst_status AS esnstatus, -- device status from part inst
 agm.account_group_id AS account_group_id,
 ag.account_group_name AS account_group_name,
 ag.status AS account_group_status,
 agm.status AS account_group_member_status,
 rc.get_bus_org_id ( i_esn => agm.esn ) AS brand,
 cl.application_req_num AS application_req_num,
 rc.get_service_plan_objid (i_esn => agm.esn ) AS service_plan_id,
 rc.get_service_plan_name (i_esn => agm.esn ) AS service_plan_name,
 rc.get_number_of_lines (i_esn => agm.esn ) AS number_of_lines,
 rc.get_group_available_capacity (i_esn => agm.esn,
 i_account_group_objid => agm.account_group_id,
 i_application_req_num => cl.application_req_num ) AS available_lines,
 cst.web_user_objid AS web_user_objid,
	 --start WARP 2.0 changes
 (SELECT co.x_code_name
 FROM table_x_code_table co
 WHERE pi_esn.status2x_code_table = co.objid
 ) AS esnstatusdesc, --device status desc
 (CASE
	 WHEN ls.lease_status_name IS NULL THEN 'Prepaid'
 ELSE ls.lease_status_name
 END) AS leasestatusname , --leasestatusname
 pcpv.manufacturer AS make,
 pcpv.model_type AS model,
 rc.get_expiration_date (i_esn => agm.esn ) AS service_end_dt,
 --end WARP 2.0 changes
 pcpv.device_type AS device_type, --CR44390
 (SELECT (CASE
 WHEN count(*) > 0 THEN 'Y'
 ELSE 'N'
 END)
 FROM x_program_enrolled
 WHERE x_enrollment_status = 'ENROLLED'
 AND x_esn = agm.esn) AS auto_enrolled --CR44390
 FROM sa.table_web_user web,
 sa.table_x_contact_part_inst conpi,
 sa.x_account_group_member agm,
 sa.x_account_group ag,
 sa.table_part_inst pi_esn,
 sa.table_mod_level ml,
 sa.table_part_num pn,
 sa.x_customer_lease cl,
 sa.x_lease_status ls,
	 sa.pcpv_mv pcpv -- WARP 2.0 changes
 WHERE web.objid = cst.web_user_objid
 AND web.web_user2bus_org = cst.bus_org_objid
 AND web.web_user2contact = conpi.x_contact_part_inst2contact
 AND conpi.x_contact_part_inst2part_inst = pi_esn.objid
 AND pi_esn.part_serial_no = agm.esn
 AND pi_esn.x_domain = 'PHONES'
 AND UPPER(agm.status) != 'EXPIRED'
 AND agm.account_group_id = ag.objid
 AND pi_esn.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid
 AND pn.domain = 'PHONES'
 AND pn.part_num2part_class = pcpv.pc_objid --WARP 2.0 changes
 AND agm.esn = cl.x_esn(+)
 AND cl.lease_status = ls.lease_status(+)
 UNION
 -- CR45170 query to get ESNs without group in the same account
 SELECT pi_esn.part_serial_no AS esn,
 ( SELECT part_serial_no
 FROM table_part_inst
 WHERE part_to_esn2part_inst = pi_esn.objid
 AND x_domain = 'LINES'
 AND ROWNUM = 1
 ) AS min,
 (CASE
 WHEN ls.lease_status NOT IN ('1000','1003','1004','1006')
 THEN 'Y'
 ELSE 'N'
 END) AS isleased,
 (CASE
 WHEN ls.lease_status IS NULL THEN '1000' -- Default Non-Leased Status
 ELSE ls.lease_status
 END) AS leasestatus,
 pi_esn.x_part_inst_status AS esnstatus, -- device status from part inst
 NULL AS account_group_id,
 NULL AS account_group_name,
 NULL AS account_group_status,
 NULL AS account_group_member_status,
 rc.get_bus_org_id ( i_esn => pi_esn.part_serial_no ) AS brand,
 cl.application_req_num AS application_req_num,
 rc.get_service_plan_objid (i_esn => pi_esn.part_serial_no ) AS service_plan_id,
 rc.get_service_plan_name (i_esn => pi_esn.part_serial_no ) AS service_plan_name,
 rc.get_number_of_lines (i_esn => pi_esn.part_serial_no ) AS number_of_lines,
 NUll AS available_lines,
 cst.web_user_objid AS web_user_objid,
	 --start WARP 2.0 changes
 (SELECT co.x_code_name
 FROM table_x_code_table co
 WHERE pi_esn.status2x_code_table = co.objid
 ) AS esnstatusdesc, --device status desc
 (CASE
	 WHEN ls.lease_status_name IS NULL THEN 'Prepaid'
 ELSE ls.lease_status_name
 END) AS leasestatusname , --leasestatusname
 pcpv.manufacturer AS make,
 pcpv.model_type AS model,
 rc.get_expiration_date (i_esn => pi_esn.part_serial_no ) AS service_end_dt,
 --end WARP 2.0 changes
 pcpv.device_type AS device_type, --CR44390
 (SELECT (CASE
 WHEN count(*) > 0 THEN 'Y'
 ELSE 'N'
 END)
 FROM x_program_enrolled
 WHERE x_enrollment_status = 'ENROLLED'
 AND x_esn = pi_esn.part_serial_no) AS auto_enrolled --CR44390
 FROM sa.table_web_user web,
 sa.table_x_contact_part_inst conpi,
 -- sa.x_account_group_member agm,
 -- sa.x_account_group ag,
 sa.table_part_inst pi_esn,
 sa.table_mod_level ml,
 sa.table_part_num pn,
 sa.x_customer_lease cl,
 sa.x_lease_status ls,
	 sa.pcpv_mv pcpv -- WARP 2.0 changes
 WHERE web.objid = cst.web_user_objid
 AND web.web_user2bus_org = cst.bus_org_objid
 AND web.web_user2contact = conpi.x_contact_part_inst2contact
 AND conpi.x_contact_part_inst2part_inst = pi_esn.objid
 -- AND pi_esn.part_serial_no = agm.esn
 AND pi_esn.x_domain = 'PHONES'
 -- AND UPPER(agm.status) != 'EXPIRED'
 -- AND agm.account_group_id = ag.objid
 AND pi_esn.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid
 AND pn.domain = 'PHONES'
 AND pn.part_num2part_class = pcpv.pc_objid --WARP 2.0 changes
 AND pi_esn.part_serial_no = cl.x_esn(+)
 AND cl.lease_status = ls.lease_status(+)
 AND NOT EXISTS
 (
 SELECT 1
 FROM sa.x_account_group_member agm,
 sa.x_account_group ag
 WHERE agm.esn = pi_esn.part_serial_no
 AND agm.account_group_id = ag.objid
 );

 o_err_code := 0;
 o_err_msg := 'SUCCESS';

 EXCEPTION
 WHEN others THEN
 o_err_code := 999;
 o_err_msg := 'ERROR VALIDATING ESN AND SECURITY PIN: ' || SQLERRM;
END getfullaccountsummary;

-- Get the entire list of ESNs tied to a min (account / all groups in the account)
PROCEDURE getfullaccountsummary ( i_login_name IN VARCHAR2,
 i_security_pin IN VARCHAR2,
 i_bus_org_id IN VARCHAR2,
 o_application_req_num OUT VARCHAR2,
 o_number_of_lines OUT NUMBER,
 o_available_lines OUT NUMBER,
 o_service_plan_id OUT VARCHAR2,
 o_service_plan_name OUT VARCHAR2,
 o_group_id OUT NUMBER,
 o_group_name OUT VARCHAR2,
 o_red_card_code OUT VARCHAR2,
 o_brand OUT VARCHAR2,
 o_first_name OUT VARCHAR2,
 o_last_name OUT VARCHAR2,
 o_login_name OUT VARCHAR2,
 o_refcursor OUT SYS_REFCURSOR ,
 o_err_code OUT NUMBER ,
 o_err_msg OUT VARCHAR2 ) IS

 -- instantiate initial values
 rc sa.customer_type := customer_type();

 -- type to hold retrieved attributes
 cst sa.customer_type := customer_type();

BEGIN

 --
 IF i_login_name IS NULL THEN
 o_err_code := 600;
 o_err_msg := 'LOGIN NAME NOT PASSED';
 RETURN;
 END IF;

 --
 IF i_security_pin IS NULL THEN
 o_err_code := 610;
 o_err_msg := 'SECURITY PIN NOT PASSED';
 RETURN;
 END IF;

 -- call the retrieve function by min
 cst := rc.retrieve_login ( i_login_name => i_login_name ,
 i_bus_org_id => i_bus_org_id );

 IF cst.web_user_objid IS NULL THEN
 o_err_code := 630;
 o_err_msg := 'LOGIN NAME NOT FOUND';
 RETURN;
 END IF;

 IF cst.security_pin IS NULL THEN
 o_err_code := 640;
 o_err_msg := 'SECURITY PIN NOT FOUND IN ACCOUNT';
 RETURN;
 END IF;

 IF cst.security_pin != i_security_pin THEN
 o_err_code := 650;
 o_err_msg := 'SECURITY PIN NOT VALID FOR THE ACCOUNT ASSOCIATED WITH THE MIN';
 RETURN;
 END IF;

 -- Set the values from customer type
 o_brand := cst.bus_org_id;
 o_group_name := cst.account_group_name;
 o_application_req_num := cst.application_req_num;
 o_number_of_lines := cst.group_allowed_lines;
 o_available_lines := cst.group_available_capacity;
 o_service_plan_id := cst.service_plan_objid;
 o_service_plan_name := cst.service_plan_name;
 o_red_card_code := cst.pin;
 o_group_id := cst.account_group_objid;
 o_first_name := cst.first_name;
 o_last_name := cst.last_name;
 o_login_name := cst.web_login_name;

 -- Get the list of esns that belong to the group
 OPEN o_refcursor
 FOR SELECT agm.esn AS esn,
 ( SELECT part_serial_no
 FROM table_part_inst
 WHERE part_to_esn2part_inst = pi_esn.objid
 AND x_domain = 'LINES'
 AND ROWNUM = 1
 ) AS min,
 (CASE
 WHEN ls.lease_status NOT IN ('1000','1003','1004','1006')
 THEN 'Y'
 ELSE 'N'
 END) AS isleased,
 (CASE
 WHEN ls.lease_status IS NULL THEN '1000' -- Default Non-Leased Status
 ELSE ls.lease_status
 END) AS leasestatus,
 pi_esn.x_part_inst_status AS esnstatus, -- device status from part inst
 agm.account_group_id AS account_group_id,
 ag.account_group_name AS account_group_name,
 ag.status AS account_group_status,
 agm.status AS account_group_member_status,
 rc.get_bus_org_id ( i_esn => agm.esn ) brand,
 cl.application_req_num AS application_req_num,
 rc.get_service_plan_objid (i_esn => agm.esn ) AS service_plan_id,
 rc.get_service_plan_name (i_esn => agm.esn ) AS service_plan_name,
 rc.get_number_of_lines (i_esn => agm.esn ) AS number_of_lines,
 rc.get_group_available_capacity (i_esn => agm.esn,
 i_account_group_objid => agm.account_group_id,
 i_application_req_num => cl.application_req_num ) AS available_lines,
 cst.web_user_objid AS web_user_objid,
	 --start WARP 2.0 Changes
	 (SELECT co.x_code_name
 FROM table_x_code_table co
 WHERE pi_esn.status2x_code_table=co.objid
 ) AS esnstatusdesc, --device status desc
 (CASE
	 WHEN ls.lease_status_name IS NULL THEN 'Prepaid'
 ELSE ls.lease_status_name
 END) AS leasestatusname ,--leasestatusname
 pcpv.manufacturer make,
 pcpv.model_type model,
 rc.get_expiration_date (i_esn => agm.esn ) AS	service_end_dt,
	 --end WARP 2.0 Changes
 pcpv.device_type AS device_type, --CR44390
 (SELECT (CASE
 WHEN count(*) > 0 THEN 'Y'
 ELSE 'N'
 END)
 FROM x_program_enrolled
 WHERE x_enrollment_status = 'ENROLLED'
 AND x_esn = agm.esn) AS auto_enrolled --CR44390

 FROM sa.table_web_user web,
 sa.table_x_contact_part_inst conpi,
 sa.x_account_group_member agm,
 sa.x_account_group ag,
 sa.table_part_inst pi_esn,
 sa.table_mod_level ml,
 sa.table_part_num pn,
 sa.x_customer_lease cl,
 sa.x_lease_status ls,
	 sa.pcpv_mv pcpv
 WHERE web.objid = cst.web_user_objid
 AND web.web_user2bus_org = cst.bus_org_objid
 AND web.web_user2contact = conpi.x_contact_part_inst2contact
 AND conpi.x_contact_part_inst2part_inst = pi_esn.objid
 AND pi_esn.part_serial_no = agm.esn
 AND pi_esn.x_domain = 'PHONES'
 AND UPPER(agm.status) != 'EXPIRED'
 AND agm.account_group_id = ag.objid
 AND pi_esn.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid
 AND pn.domain = 'PHONES'
 AND pn.part_num2part_class = pcpv.pc_objid
 AND agm.esn = cl.x_esn(+)
 AND cl.lease_status = ls.lease_status(+)
 UNION -- Get ESNs which are part of a group but yet to be in group memeber and yet to be activated
 SELECT cl.x_esn AS esn,
 ( SELECT part_serial_no
 FROM table_part_inst
 WHERE part_to_esn2part_inst = pi_esn.objid
 AND x_domain = 'LINES'
 AND ROWNUM = 1
 ) AS min,
 (CASE
 WHEN ls.lease_status NOT IN ('1000','1003','1004','1006')
 THEN 'Y'
 ELSE 'N'
 END) AS isleased,
 (CASE
 WHEN ls.lease_status IS NULL THEN '1000' -- Default Non-Leased Status
 ELSE ls.lease_status
 END) AS leasestatus,
 pi_esn.x_part_inst_status AS esnstatus, -- device status from part inst
 ag.objid AS account_group_id,
 ag.account_group_name AS account_group_name,
 ag.status AS account_group_status,
 NULL AS account_group_member_status,
 rc.get_bus_org_id ( i_esn => cl.x_esn ) brand,
 cl.application_req_num AS application_req_num,
 rc.get_service_plan_objid (i_esn => cl.x_esn ) AS service_plan_id,
 rc.get_service_plan_name (i_esn => cl.x_esn ) AS service_plan_name,
 rc.get_number_of_lines (i_esn => cl.x_esn ) AS number_of_lines,
 rc.get_group_available_capacity (i_esn => cl.x_esn,
 i_account_group_objid => ag.objid,
 i_application_req_num => cl.application_req_num ) AS available_lines,
 cst.web_user_objid AS web_user_objid,
	 --start WARP 2.0 Changes
	 (SELECT co.x_code_name
 FROM table_x_code_table co
 WHERE pi_esn.status2x_code_table=co.objid
 ) AS esnstatusdesc, --device status desc
 (CASE
	 WHEN ls.lease_status_name IS NULL THEN 'Prepaid'
 ELSE ls.lease_status_name
 END) AS leasestatusname , --leasestatusname
 pcpv.manufacturer AS make,
 pcpv.model_type AS model,
 rc.get_expiration_date (i_esn => cl.x_esn ) AS	service_end_dt,
	 --end WARP 2.0 Changes
 pcpv.device_type AS device_type, --CR44390
 (SELECT (CASE
 WHEN count(*) > 0 THEN 'Y'
 ELSE 'N'
 END)
 FROM x_program_enrolled
 WHERE x_enrollment_status = 'ENROLLED'
 AND x_esn = cl.x_esn) AS auto_enrolled --CR44390
 FROM sa.x_customer_lease cl,
 sa.x_lease_status ls,
 sa.table_part_inst pi_esn,
 sa.x_account_group ag,
 sa.table_mod_level ml,
 sa.table_part_num pn,
	 sa.pcpv_mv pcpv
 WHERE cl.account_group_id IN ( SELECT ag.objid
 FROM sa.table_web_user web,
 sa.table_x_contact_part_inst conpi,
 sa.x_account_group_member agm,
 sa.x_account_group ag,
 sa.table_part_inst pi_esn
 WHERE web.objid = cst.web_user_objid
 AND web.web_user2bus_org = cst.bus_org_objid
 AND web.web_user2contact = conpi.x_contact_part_inst2contact
 AND conpi.x_contact_part_inst2part_inst = pi_esn.objid
 AND pi_esn.part_serial_no = agm.esn
 AND pi_esn.x_domain = 'PHONES'
 AND UPPER(agm.status) != 'EXPIRED'
 AND agm.account_group_id = ag.objid
 )
 AND cl.account_group_id = ag.objid
 AND pi_esn.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid
 AND pn.part_num2part_class = pcpv.pc_objid
 AND cl.lease_status = ls.lease_status(+)
 AND cl.x_esn = pi_esn.part_serial_no
 AND pi_esn.x_domain = 'PHONES'
 AND NOT EXISTS ( SELECT 1
 FROM x_account_group_member
 WHERE esn = cl.x_esn
 AND status <> 'EXPIRED'
 )
 -- CR45170 query to get ESNs in the account without group
 UNION
 SELECT pi_esn.part_serial_no AS esn,
 ( SELECT part_serial_no
 FROM table_part_inst
 WHERE part_to_esn2part_inst = pi_esn.objid
 AND x_domain = 'LINES'
 AND ROWNUM = 1
 ) AS min,
 (CASE
 WHEN ls.lease_status NOT IN ('1000','1003','1004','1006')
 THEN 'Y'
 ELSE 'N'
 END) AS isleased,
 (CASE
 WHEN ls.lease_status IS NULL THEN '1000' -- Default Non-Leased Status
 ELSE ls.lease_status
 END) AS leasestatus,
 pi_esn.x_part_inst_status AS esnstatus, -- device status from part inst
 NULL AS account_group_id,
 NULL AS account_group_name,
 NULL AS account_group_status,
 NULL AS account_group_member_status,
 rc.get_bus_org_id ( i_esn => pi_esn.part_serial_no ) brand,
 cl.application_req_num AS application_req_num,
 rc.get_service_plan_objid (i_esn => pi_esn.part_serial_no ) AS service_plan_id,
 rc.get_service_plan_name (i_esn => pi_esn.part_serial_no ) AS service_plan_name,
 rc.get_number_of_lines (i_esn => pi_esn.part_serial_no ) AS number_of_lines,
 NULL AS available_lines,
 cst.web_user_objid AS web_user_objid,
	 --start WARP 2.0 Changes
	 (SELECT co.x_code_name
 FROM table_x_code_table co
 WHERE pi_esn.status2x_code_table=co.objid
 ) AS esnstatusdesc, --device status desc
 (CASE
	 WHEN ls.lease_status_name IS NULL THEN 'Prepaid'
 ELSE ls.lease_status_name
 END) AS leasestatusname ,--leasestatusname
 pcpv.manufacturer make,
 pcpv.model_type model,
 rc.get_expiration_date (i_esn => pi_esn.part_serial_no ) AS	service_end_dt,
	 --end WARP 2.0 Changes
 pcpv.device_type AS device_type, --CR44390
 (SELECT (CASE
 WHEN count(*) > 0 THEN 'Y'
 ELSE 'N'
 END)
 FROM x_program_enrolled
 WHERE x_enrollment_status = 'ENROLLED'
 AND x_esn = pi_esn.part_serial_no ) AS auto_enrolled --CR44390
 FROM sa.table_web_user web,
 sa.table_x_contact_part_inst conpi,
 -- sa.x_account_group_member agm,
 -- sa.x_account_group ag,
 sa.table_part_inst pi_esn,
 sa.table_mod_level ml,
 sa.table_part_num pn,
 sa.x_customer_lease cl,
 sa.x_lease_status ls,
	 sa.pcpv_mv pcpv
 WHERE web.objid = cst.web_user_objid
 AND web.web_user2bus_org = cst.bus_org_objid
 AND web.web_user2contact = conpi.x_contact_part_inst2contact
 AND conpi.x_contact_part_inst2part_inst = pi_esn.objid
 -- AND pi_esn.part_serial_no = agm.esn
 AND pi_esn.x_domain = 'PHONES'
 -- AND UPPER(agm.status) != 'EXPIRED'
 -- AND agm.account_group_id = ag.objid
 AND pi_esn.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid
 AND pn.domain = 'PHONES'
 AND pn.part_num2part_class = pcpv.pc_objid
 AND pi_esn.part_serial_no = cl.x_esn(+)
 AND cl.lease_status = ls.lease_status(+)
 AND NOT EXISTS
 (
 SELECT 1
 FROM sa.x_account_group_member agm,
 sa.x_account_group ag
 WHERE agm.esn = pi_esn.part_serial_no
 AND agm.account_group_id = ag.objid
 );

 --
 o_err_code := 0;
 o_err_msg := 'SUCCESS';
 --
 EXCEPTION
 WHEN others THEN
 o_err_code := 999;
 o_err_msg := 'ERROR VALIDATING ESN AND SECURITY PIN: ' || SQLERRM;
END getfullaccountsummary;

-- Get the entire list of ESNs tied to a min (account / all groups in the account)
PROCEDURE getfullaccountsummary ( i_login_name IN VARCHAR2,
 i_bus_org_id IN VARCHAR2,
 o_application_req_num OUT VARCHAR2,
 o_number_of_lines OUT NUMBER,
 o_available_lines OUT NUMBER,
 o_service_plan_id OUT VARCHAR2,
 o_service_plan_name OUT VARCHAR2,
 o_group_id OUT NUMBER,
 o_group_name OUT VARCHAR2,
 o_red_card_code OUT VARCHAR2,
 o_brand OUT VARCHAR2,
 o_first_name OUT VARCHAR2,
 o_last_name OUT VARCHAR2,
 o_login_name OUT VARCHAR2,
 o_refcursor OUT SYS_REFCURSOR ,
 o_err_code OUT NUMBER ,
 o_err_msg OUT VARCHAR2 ) IS

 -- instantiate initial values
 rc sa.customer_type := customer_type();

 -- type to hold retrieved attributes
 cst sa.customer_type := customer_type();

BEGIN

 --
 IF i_login_name IS NULL THEN
 o_err_code := 600;
 o_err_msg := 'LOGIN NAME NOT PASSED';
 RETURN;
 END IF;

 --
 IF i_bus_org_id IS NULL THEN
 o_err_code := 610;
 o_err_msg := 'BRAND NOT PASSED';
 RETURN;
 END IF;

 -- call the retrieve function by min
 cst := rc.retrieve_login ( i_login_name => i_login_name ,
 i_bus_org_id => i_bus_org_id );

 IF cst.web_user_objid IS NULL THEN
 o_err_code := 630;
 o_err_msg := 'LOGIN NAME | BRAND NOT FOUND';
 RETURN;
 END IF;

 -- Set the values from customer type
 o_brand := cst.bus_org_id;
 o_group_name := cst.account_group_name;
 o_application_req_num := cst.application_req_num;
 o_number_of_lines := cst.group_allowed_lines;
 o_available_lines := cst.group_available_capacity;
 o_service_plan_id := cst.service_plan_objid;
 o_service_plan_name := cst.service_plan_name;
 o_red_card_code := cst.pin;
 o_group_id := cst.account_group_objid;
 o_first_name := cst.first_name;
 o_last_name := cst.last_name;
 o_login_name := cst.web_login_name;

 -- Get the list of esns that belong to the group
 OPEN o_refcursor
 FOR SELECT agm.esn AS esn,
 ( SELECT part_serial_no
 FROM table_part_inst
 WHERE part_to_esn2part_inst = pi_esn.objid
 AND x_domain = 'LINES'
 AND ROWNUM = 1
 ) AS min,
 (CASE
 WHEN ls.lease_status NOT IN ('1000','1003','1004','1006')
 THEN 'Y'
 ELSE 'N'
 END) AS isleased,
 (CASE
 WHEN ls.lease_status IS NULL THEN '1000' -- Default Non-Leased Status
 ELSE ls.lease_status
 END) AS leasestatus,
 pi_esn.x_part_inst_status AS esnstatus, -- device status from part inst
 agm.account_group_id AS account_group_id,
 ag.account_group_name AS account_group_name,
 ag.status AS account_group_status,
 agm.status AS account_group_member_status,
 rc.get_bus_org_id ( i_esn => agm.esn ) brand,
 cl.application_req_num AS application_req_num,
 rc.get_service_plan_objid (i_esn => agm.esn ) AS service_plan_id,
 rc.get_service_plan_name (i_esn => agm.esn ) AS service_plan_name,
 rc.get_number_of_lines (i_esn => agm.esn ) AS number_of_lines,
 rc.get_group_available_capacity (i_esn => agm.esn,
 i_account_group_objid => agm.account_group_id,
 i_application_req_num => cl.application_req_num ) AS available_lines,
 cst.web_user_objid AS web_user_objid,
	 -- start WARP 2.0 changes
	 (SELECT co.x_code_name
 FROM table_x_code_table co
 WHERE pi_esn.status2x_code_table=co.objid
 ) AS esnstatusdesc, --device status desc
 (CASE
	 WHEN ls.lease_status_name IS NULL THEN 'Prepaid'
 ELSE ls.lease_status_name
 END) AS leasestatusname, --leasestatusname
 pcpv.manufacturer AS make,
 pcpv.model_type AS model,
 rc.get_expiration_date (i_esn => agm.esn ) AS service_end_dt,
 -- end WARP 2.0 changes
 pcpv.device_type AS device_type, --CR44390
 (SELECT (CASE
 WHEN count(*) > 0 THEN 'Y'
 ELSE 'N'
 END)
 FROM x_program_enrolled
 WHERE x_enrollment_status = 'ENROLLED'
 AND x_esn = agm.esn ) AS auto_enrolled --CR44390
 FROM sa.table_web_user web,
 sa.table_x_contact_part_inst conpi,
 sa.x_account_group_member agm,
 sa.x_account_group ag,
 sa.table_part_inst pi_esn,
 sa.table_mod_level ml,
 sa.table_part_num pn,
 sa.x_customer_lease cl,
 sa.x_lease_status ls,
	 sa.pcpv_mv pcpv --WARP 2.0
 WHERE web.objid = cst.web_user_objid
 AND web.web_user2bus_org = cst.bus_org_objid
 AND web.web_user2contact = conpi.x_contact_part_inst2contact
 AND conpi.x_contact_part_inst2part_inst = pi_esn.objid
 AND pi_esn.part_serial_no = agm.esn
 AND pi_esn.x_domain = 'PHONES'
 AND UPPER(agm.status) != 'EXPIRED'
 AND agm.account_group_id = ag.objid
 AND pi_esn.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid
 AND pn.domain = 'PHONES'
 AND pn.part_num2part_class = pcpv.pc_objid --WARP 2.0
 AND agm.esn = cl.x_esn(+)
 AND cl.lease_status = ls.lease_status(+)
 UNION -- Get ESNs which are part of a group but yet to be in group memeber and yet to be activated
 SELECT cl.x_esn AS esn,
 ( SELECT part_serial_no
 FROM table_part_inst
 WHERE part_to_esn2part_inst = pi_esn.objid
 AND x_domain = 'LINES'
 AND ROWNUM = 1
 ) AS min,
 (CASE
 WHEN ls.lease_status NOT IN ('1000','1003','1004','1006')
 THEN 'Y'
 ELSE 'N'
 END) AS isleased,
 (CASE
 WHEN ls.lease_status IS NULL THEN '1000' -- Default Non-Leased Status
 ELSE ls.lease_status
 END) AS leasestatus,
 pi_esn.x_part_inst_status AS esnstatus, -- device status from part inst
 ag.objid AS account_group_id,
 ag.account_group_name AS account_group_name,
 ag.status AS account_group_status,
 NULL AS account_group_member_status,
 rc.get_bus_org_id ( i_esn => cl.x_esn ) brand,
 cl.application_req_num AS application_req_num,
 rc.get_service_plan_objid (i_esn => cl.x_esn ) AS service_plan_id,
 rc.get_service_plan_name (i_esn => cl.x_esn ) AS service_plan_name,
 rc.get_number_of_lines (i_esn => cl.x_esn ) AS number_of_lines,
 rc.get_group_available_capacity (i_esn => cl.x_esn,
 i_account_group_objid => ag.objid,
 i_application_req_num => cl.application_req_num ) AS available_lines,
 cst.web_user_objid AS web_user_objid,
	 -- start WARP 2.0 changes
	 (SELECT co.x_code_name
 FROM table_x_code_table co
 WHERE pi_esn.status2x_code_table=co.objid
 ) AS esnstatusdesc, --device status desc
 (CASE
	 WHEN ls.lease_status_name IS NULL THEN 'Prepaid'
 ELSE ls.lease_status_name
 END) AS leasestatusname, --leasestatusname
 pcpv.manufacturer AS make,
 pcpv.model_type AS model,
 rc.get_expiration_date (i_esn => cl.x_esn ) AS service_end_dt,
	 -- end WARP 2.0 changes
 pcpv.device_type AS device_type, --CR44390
 (SELECT (CASE
 WHEN count(*) > 0 THEN 'Y'
 ELSE 'N'
 END)
 FROM x_program_enrolled
 WHERE x_enrollment_status = 'ENROLLED'
 AND x_esn = cl.x_esn ) AS auto_enrolled --CR44390

 FROM sa.x_customer_lease cl,
 sa.x_lease_status ls,
 sa.table_part_inst pi_esn,
 sa.x_account_group ag,
	 --WARP 2.0
	 sa.table_mod_level ml,
 sa.table_part_num pn,
	 sa.pcpv_mv pcpv
	 --WARP 2.0
 WHERE cl.account_group_id IN ( SELECT ag.objid
 FROM sa.table_web_user web,
 sa.table_x_contact_part_inst conpi,
 sa.x_account_group_member agm,
 sa.x_account_group ag,
 sa.table_part_inst pi_esn
 WHERE web.objid = cst.web_user_objid
 AND web.web_user2bus_org = cst.bus_org_objid
 AND web.web_user2contact = conpi.x_contact_part_inst2contact
 AND conpi.x_contact_part_inst2part_inst = pi_esn.objid
 AND pi_esn.part_serial_no = agm.esn
 AND pi_esn.x_domain = 'PHONES'
 AND UPPER(agm.status) != 'EXPIRED'
 AND agm.account_group_id = ag.objid
 )
 AND cl.account_group_id = ag.objid
 --WARP 2.0
 AND pi_esn.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid
 AND pn.part_num2part_class = pcpv.pc_objid
 --WARP 2.0
 AND cl.lease_status = ls.lease_status(+)
 AND cl.x_esn = pi_esn.part_serial_no
 AND pi_esn.x_domain = 'PHONES'
 AND NOT EXISTS ( SELECT 1
 FROM x_account_group_member
 WHERE esn = cl.x_esn
 AND status <> 'EXPIRED'
 )
 --CR45170 query to get ESNs in the account without group
 UNION
 SELECT pi_esn.part_serial_no AS esn,
 ( SELECT part_serial_no
 FROM table_part_inst
 WHERE part_to_esn2part_inst = pi_esn.objid
 AND x_domain = 'LINES'
 AND ROWNUM = 1
 ) AS min,
 (CASE
 WHEN ls.lease_status NOT IN ('1000','1003','1004','1006')
 THEN 'Y'
 ELSE 'N'
 END) AS isleased,
 (CASE
 WHEN ls.lease_status IS NULL THEN '1000' -- Default Non-Leased Status
 ELSE ls.lease_status
 END) AS leasestatus,
 pi_esn.x_part_inst_status AS esnstatus, -- device status from part inst
 NULL AS account_group_id,
 NULL AS account_group_name,
 NULL AS account_group_status,
 NULL AS account_group_member_status,
 rc.get_bus_org_id ( i_esn => pi_esn.part_serial_no ) brand,
 cl.application_req_num AS application_req_num,
 rc.get_service_plan_objid (i_esn => pi_esn.part_serial_no ) AS service_plan_id,
 rc.get_service_plan_name (i_esn => pi_esn.part_serial_no ) AS service_plan_name,
 rc.get_number_of_lines (i_esn => pi_esn.part_serial_no ) AS number_of_lines,
 NULL AS available_lines,
 cst.web_user_objid AS web_user_objid,
	 -- start WARP 2.0 changes
	 (SELECT co.x_code_name
 FROM table_x_code_table co
 WHERE pi_esn.status2x_code_table=co.objid
 ) AS esnstatusdesc, --device status desc
 (CASE
	 WHEN ls.lease_status_name IS NULL THEN 'Prepaid'
 ELSE ls.lease_status_name
 END) AS leasestatusname, --leasestatusname
 pcpv.manufacturer AS make,
 pcpv.model_type AS model,
 rc.get_expiration_date (i_esn => pi_esn.part_serial_no ) AS service_end_dt,
 -- end WARP 2.0 changes
 pcpv.device_type AS device_type, --CR44390
 (SELECT (CASE
 WHEN count(*) > 0 THEN 'Y'
 ELSE 'N'
 END)
 FROM x_program_enrolled
 WHERE x_enrollment_status = 'ENROLLED'
 AND x_esn = pi_esn.part_serial_no ) AS auto_enrolled --CR44390

 FROM sa.table_web_user web,
 sa.table_x_contact_part_inst conpi,
 -- sa.x_account_group_member agm,
 -- sa.x_account_group ag,
 sa.table_part_inst pi_esn,
 sa.table_mod_level ml,
 sa.table_part_num pn,
 sa.x_customer_lease cl,
 sa.x_lease_status ls,
	 sa.pcpv_mv pcpv --WARP 2.0
 WHERE web.objid = cst.web_user_objid
 AND web.web_user2bus_org = cst.bus_org_objid
 AND web.web_user2contact = conpi.x_contact_part_inst2contact
 AND conpi.x_contact_part_inst2part_inst = pi_esn.objid
 -- AND pi_esn.part_serial_no = agm.esn
 AND pi_esn.x_domain = 'PHONES'
 -- AND UPPER(agm.status) != 'EXPIRED'
 -- AND agm.account_group_id = ag.objid
 AND pi_esn.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid
 AND pn.domain = 'PHONES'
 AND pn.part_num2part_class = pcpv.pc_objid --WARP 2.0
 AND pi_esn.part_serial_no = cl.x_esn(+)
 AND cl.lease_status = ls.lease_status(+)
 AND NOT EXISTS
 (
 SELECT 1
 FROM sa.x_account_group_member agm,
 sa.x_account_group ag
 WHERE agm.esn = pi_esn.part_serial_no
 AND agm.account_group_id = ag.objid
 );
 o_err_code := 0;
 o_err_msg := 'SUCCESS';
 --
 EXCEPTION
 WHEN others THEN
 o_err_code := 999;
 o_err_msg := 'ERROR VALIDATING ESN AND SECURITY PIN: ' || SQLERRM;
END getfullaccountsummary;
--
-- Procedure to get all the groups related to the web login id. As requested by CBO
--
PROCEDURE get_full_account_summary ( i_login_name  IN  VARCHAR2,
                                     i_web_user_id IN  VARCHAR2,
                                     i_group_id    IN  VARCHAR2,
                                     i_bus_org     IN  VARCHAR2,
                                     i_language    IN  VARCHAR2 DEFAULT 'ENGLISH', --Added for CR55236 TW Web common standards
                                     o_refcursor   OUT SYS_REFCURSOR,
                                     o_error_code  OUT VARCHAR2,
                                     o_error_msg   OUT VARCHAR2)
IS
--
 l_web_user_id table_web_user.objid%TYPE;
 -- instantiate initial values
 rc sa.customer_type := customer_type();
 -- type to hold retrieved attributes
 cst_login sa.customer_type := customer_type();
--
BEGIN
--
  IF i_login_name IS NULL AND i_web_user_id IS NULL AND i_group_id IS NULL
  THEN
    o_error_code := '100';
    o_error_msg := 'Web Login Name / User ID / Group ID cannot be null';
    RETURN;
  END IF;
 --
  IF i_bus_org IS NULL
  THEN
    o_error_code := '110';
    o_error_msg := 'Brand cannot be null';
    RETURN;
  END IF;
  --
  l_web_user_id := i_web_user_id;
  --
  IF i_web_user_id IS NULL
  THEN
    IF i_group_id IS NOT NULL AND i_login_name IS NULL
    THEN
      --
      get_group_summary ( i_group_id => i_group_id,
                          i_bus_org => i_bus_org,
                          i_language =>i_language,
                          o_refcursor => o_refcursor,
                          o_error_code => o_error_code,
                          o_error_msg => o_error_msg);
      RETURN;
      --
    END IF;
    --
    IF i_login_name IS NOT NULL
    THEN
      cst_login := rc.retrieve_login ( i_login_name => i_login_name,
                                      i_bus_org_id => i_bus_org );

      l_web_user_id := cst_login.web_user_objid;
    END IF;
  END IF;
  --
  OPEN o_refcursor
  FOR
  SELECT WEB.objid WEBOBJID,
         PI.part_serial_no ESN,
         PI.x_iccid ICCID,
         CONPI.x_esn_nick_name ESN_NICK_NAME,
         LEASE.lease_status LEASE_STATUS,
         (SELECT CASE
                  WHEN i_language = 'SPANISH' THEN LEASE_STATUS_NAME_SPANISH
                  ELSE
                  case when lease.lease_status in (1001,1002) then 'Active'
                       when lease.lease_status=1005 then 'In Review'
                       when lease.lease_status=1006 then 'Returned'
                       else null end
                END
         FROM   x_lease_status
         where lease_status = lease.lease_status)
         LEASE_STATUS_NAME, --Added for CR55236 TW Web common standards
         LEASE.application_req_num LEASE_APPLICATION_NUMBER,
         NVL(CONPI.x_is_default, 0) IS_DEFAULT,
         NVL(CONPI.x_transfer_flag, 0) TRANSFER_FLAG,
         WEB.web_user2contact WEB_CONTACT_OBJID,
         PI.x_part_inst2contact PART_CONTACT_OBJID,
         CODE.x_code_name CODE_NAME,
         CODE.x_code_number CODE_NUMBER,
         BUS.org_id BUS_ORGID,
         PI.x_port_in IS_PORTIN,
         PC.name PC_NAME,
         CONPI.x_verified IS_VERIFIED,
         (SELECT 'Y'
         FROM table_part_inst b
         WHERE b.part_to_esn2part_inst = pi.objid
         AND b.x_domain = 'LINES'
         AND b.x_part_inst_status IN ( 37, 38, 39, 73 )
         AND NOT EXISTS (SELECT 1
         FROM table_case t_case,
         table_condition t_cond
         WHERE t_case.x_esn = pi.part_serial_no
         AND t_case.case_state2condition = t_cond.objid
         AND UPPER(t_cond.title) NOT LIKE 'CLOSE%'
         AND UPPER(t_case.title) LIKE '%SIM%')
         AND ROWNUM <= 1) RESERVED_LINE_AVAILABLE,
         PI.x_hex_serial_no,
         (SELECT OPERATING_SYSTEM
         FROM sa.pcpv pcpv
         WHERE pcpv.pc_objid = PC.objid
         ) OPERATING_SYS,
         WEB.s_login_name S_LOGIN_NAME,
         ag.account_group_name GROUP_NAME,
         ag.program_enrolled_id GROUP_PROG_ENROLL_ID,
         ag.end_date GROUP_END_DATE,
         ag.service_plan_feature_date GROUP_PLAN_FEATURE_DT,
         ag.service_plan_id GROUP_PLAN_ID,
         ag.start_date GROUP_START_DT,
         ag.status GROUP_STATUS,
         sa.customer_lease_scoring_pkg.Get_application_id(ag.objid, '' , '')
         GROUP_LEASE_APPLICATION_NUM,
         agm.master_flag ESN_MASTER_FLAG,
         agm.account_group_id GROUP_ID,
         agm.esn GROUP_ESN_NO,
         agm.member_order ESN_ORDER,
         agm.start_date ESN_START_DT,
         agm.end_date ESN_END_DATE,
         agm.status GROUP_ESN_STATUS,
         agm.program_param_id ESN_PROG_ID,
         rc.get_service_plan_objid (i_esn => PI.part_serial_no ) AS ESN_CURR_PLAN_ID, -- CR37756 PMistry Defect # 1470 (ITQ) 05/31/2016
         rc.get_contact_security_pin (i_contact_objid => pi.x_part_inst2contact) AS contact_security_pin, -- CR47564
         tc.x_cust_id CUSTOMER_ID,
         tc.first_name FIRST_NAME ,
         tc.last_name LAST_NAME ,
         pn.part_number PART_NUMBER,
         mv.manufacturer MANUFACTURER,
         mv.model_type DEVICE_MODEL,
         mv.device_type DEVICE_TYPE,
         customer_info.get_transaction_status(i_esn => PI.part_serial_no ) TRANSACTION_PENDING,
         customer_info.get_carrier_name (i_sim_serial => PI.x_iccid) carrier_name,
         customer_info.get_sim_status (i_sim_serial => PI.x_iccid) sim_status,
         customer_info.get_sim_legacy_flag (i_sim => PI.x_iccid) sim_legacy_flag
  FROM   table_x_code_table CODE,
         table_part_num PN,
         table_mod_level ML,
         table_part_inst PI,
         table_x_contact_part_inst CONPI,
         table_contact tc,
         table_bus_org BUS,
         table_web_user WEB,
         table_part_class PC,
         x_account_group_member AGM,
         x_account_group AG,
         x_customer_lease LEASE,
         pcpv_mv mv
  WHERE  PI.n_part_inst2part_mod = ML.objid
  AND    ML.part_info2part_num = PN.objid
  AND    CODE.objid(+) = PI.status2x_code_table
  AND    PI.objid(+) = CONPI.x_contact_part_inst2part_inst
  AND    conpi.x_contact_part_inst2contact = tc.objid (+)
  AND    pc.objid = mv.pc_objid
  AND    web.web_user2bus_org = bus.objid
  AND    pn.part_num2part_class = pc.objid
  AND    pn.part_num2bus_org = bus.objid
  AND    conpi.x_contact_part_inst2contact(+) = web.web_user2contact
  AND    agm.esn(+) = pi.part_serial_no
  AND    agm.account_group_id = ag.objid (+)
  AND    lease.x_esn(+) = pi.part_serial_no
  AND    bus.s_org_id = i_bus_org
  AND    web.objid = l_web_user_id
  UNION
  SELECT web.objid webobjid,
         pi.part_serial_no esn,
         pi.x_iccid iccid,
         conpi.x_esn_nick_name esn_nick_name,
         lease.lease_status lease_status,
          (SELECT CASE
                  WHEN i_language = 'SPANISH' THEN LEASE_STATUS_NAME_SPANISH
                  ELSE
                  case when lease.lease_status in (1001,1002) then 'Active'
                       when lease.lease_status=1005 then 'In Review'
                       when lease.lease_status=1006 then 'Returned'
                       else null end
                END
         FROM   x_lease_status
         where lease_status = lease.lease_status)
         LEASE_STATUS_NAME, --Added for CR55236 TW Web common standards
         lease.application_req_num lease_application_number,
         NVL(conpi.x_is_default, 0) is_default,
         NVL(conpi.x_transfer_flag, 0) transfer_flag,
         web.web_user2contact web_contact_objid,
         pi.x_part_inst2contact part_contact_objid,
         code.x_code_name code_name,
         code.x_code_number code_number,
         bus.org_id bus_orgid,
         pi.x_port_in is_portin,
         pc.name pc_name,
         conpi.x_verified is_verified,
         (SELECT 'Y'
         FROM table_part_inst b
         WHERE b.part_to_esn2part_inst = pi.objid
         AND b.x_domain = 'LINES'
         AND b.x_part_inst_status IN ( 37, 38, 39, 73 )
         AND NOT EXISTS (SELECT 1
         FROM table_case t_case,
         table_condition t_cond
         WHERE t_case.x_esn = pi.part_serial_no
         AND t_case.case_state2condition = t_cond.objid
         AND UPPER(t_cond.title) NOT LIKE 'CLOSE%'
         AND UPPER(t_case.title) LIKE '%SIM%')
         AND ROWNUM <= 1) reserved_line_available,
         pi.x_hex_serial_no,
         (SELECT OPERATING_SYSTEM
         FROM sa.pcpv pcpv
         WHERE pcpv.pc_objid = PC.objid
         ) OPERATING_SYS,
         web.s_login_name s_login_name,
         NULL group_name,
         ag.program_enrolled_id group_prog_enroll_id,
         ag.end_date group_end_date,
         ag.service_plan_feature_date group_plan_feature_dt,
         NULL group_plan_id,
         NULL group_start_dt,
         NULL group_status,
         sa.customer_lease_scoring_pkg.Get_application_id(ag.objid, '' , '')
         GROUP_LEASE_APPLICATION_NUM,
         NULL esn_master_flag,
         NULL GROUP_ID,
         lease.x_esn group_esn_no,
         NULL ESN_ORDER,
         NULL esn_start_dt,
         NULL esn_end_date,
         NULL group_esn_status,
         NULL esn_prog_id,
         rc.get_service_plan_objid (i_esn => PI.part_serial_no ) AS ESN_CURR_PLAN_ID, -- CR37756 PMistry Defect # 1470 (ITQ) 05/31/2016
         rc.get_contact_security_pin (i_contact_objid => pi.x_part_inst2contact) AS contact_security_pin, -- CR47564
         tc.x_cust_id CUSTOMER_ID,
         tc.first_name FIRST_NAME ,
         tc.last_name LAST_NAME ,
         pn.part_number PART_NUMBER,
         mv.manufacturer MANUFACTURER,
         mv.model_type DEVICE_MODEL,
         mv.device_type DEVICE_TYPE        ,
         customer_info.get_transaction_status(i_esn => PI.part_serial_no ) TRANSACTION_PENDING,
         customer_info.get_carrier_name (i_sim_serial => PI.x_iccid) carrier_name,
         customer_info.get_sim_status (i_sim_serial => PI.x_iccid) sim_status,
         customer_info.get_sim_legacy_flag (i_sim => PI.x_iccid) sim_legacy_flag
  FROM   table_x_code_table code,
         table_part_num pn,
         table_mod_level ml,
         table_part_inst pi,
         table_x_contact_part_inst conpi,
         table_contact tc,
         table_bus_org bus,
         table_web_user web,
         table_part_class pc,
         x_account_group ag,
         x_customer_lease lease,
         pcpv_mv mv
  WHERE  pi.n_part_inst2part_mod = ml.objid
  AND    ml.part_info2part_num = pn.objid
  AND    code.objid(+) = pi.status2x_code_table
  AND    pi.objid(+) = conpi.x_contact_part_inst2part_inst
  AND    CONPI.X_CONTACT_PART_INST2CONTACT = tc.objid (+)
  AND    PC.objid = mv.pc_objid
  AND    web.web_user2bus_org = bus.objid
  AND    pn.part_num2part_class = pc.objid
  AND    pn.part_num2bus_org = bus.objid
  AND    conpi.x_contact_part_inst2contact(+) = web.web_user2contact
  AND    lease.x_esn(+) = PI.part_serial_no
  AND    bus.s_org_id = i_bus_org
  AND    lease.account_group_id IN ( SELECT ag.objid
                                     FROM   sa.table_web_user web,
                                            sa.table_x_contact_part_inst conpi,
                                            sa.x_account_group_member agm,
                                            sa.x_account_group ag,
                                            sa.table_part_inst pi_esn
                                     WHERE  web.objid = l_web_user_id
                                     AND    web.web_user2contact = conpi.x_contact_part_inst2contact
                                     AND    conpi.x_contact_part_inst2part_inst = pi_esn.objid
                                     and    PI_ESN.PART_SERIAL_NO = AGM.ESN
                                     AND    PI_ESN.X_DOMAIN = 'PHONES'
                                     AND    UPPER(agm.status) != 'EXPIRED'
                                     AND    agm.account_group_id = ag.objid
                                   )
  AND    lease.account_group_id = AG.OBJID
  AND    lease.x_esn = pi.part_serial_no
  AND    pi.x_domain = 'PHONES'
  AND NOT EXISTS ( SELECT 1
                   FROM   x_account_group_member
                   WHERE  esn = lease.x_esn
                   AND    status <> 'EXPIRED'
                 )
  ORDER BY group_id,
          group_esn_status;
  --
  o_error_code := 0;
  o_error_msg := 'SUCCESS';
 --
EXCEPTION
WHEN OTHERS
THEN
  o_error_code := 99;
  o_error_msg := 'Failed in When others '|| SQLERRM;
END get_full_account_summary;
--
-- Procedure to get all the ESNs related to the group id. As requested by CBO
--
PROCEDURE get_group_summary ( i_group_id IN VARCHAR2,
 i_bus_org IN VARCHAR2,
 i_language  IN VARCHAR2 DEFAULT 'ENGLISH', --CR52336 TW Web common standards
 o_refcursor OUT SYS_REFCURSOR,
 o_error_code OUT VARCHAR2,
 o_error_msg OUT VARCHAR2)
IS
--

 -- instantiate initial values
 rc sa.customer_type := customer_type();
 -- type to hold retrieved attributes
 cst_login sa.customer_type := customer_type();
 cst_group_id sa.customer_type := customer_type();
--
BEGIN
--
 IF i_group_id IS NULL
 THEN
 o_error_code := '100';
 o_error_msg := 'Group ID cannot be null';
 RETURN;
 END IF;
 --
 IF i_bus_org IS NULL
 THEN
 o_error_code := '110';
 o_error_msg := 'Brand cannot be null';
 RETURN;
 END IF;
 --
 OPEN o_refcursor
 FOR SELECT WEB.objid WEBOBJID,
 PI.part_serial_no ESN,
 PI.x_iccid ICCID,
 CONPI.x_esn_nick_name ESN_NICK_NAME,
 LEASE.lease_status LEASE_STATUS,
 (SELECT CASE
                  WHEN i_language = 'SPANISH' THEN LEASE_STATUS_NAME_SPANISH
                  ELSE
                  case when lease.lease_status in (1001,1002) then 'Active'
                       when lease.lease_status=1005 then 'In Review'
                       when lease.lease_status=1006 then 'Returned'
                       else null end
                END
         FROM   x_lease_status
         where lease_status = lease.lease_status)
         LEASE_STATUS_NAME, --CR52336 TW Web common standards
 LEASE.application_req_num LEASE_APPLICATION_NUMBER,
 Nvl(CONPI.x_is_default, 0) IS_DEFAULT,
 Nvl(CONPI.x_transfer_flag, 0) TRANSFER_FLAG,
 WEB.web_user2contact WEB_CONTACT_OBJID,
 PI.x_part_inst2contact PART_CONTACT_OBJID,
 CODE.x_code_name CODE_NAME,
 CODE.x_code_number CODE_NUMBER,
 BUS.org_id BUS_ORGID,
 PI.x_port_in IS_PORTIN,
 PC.name PC_NAME,
 CONPI.x_verified IS_VERIFIED,
 (SELECT 'Y'
 FROM table_part_inst b
 WHERE b.part_to_esn2part_inst = pi.objid
 AND b.x_domain = 'LINES'
 AND b.x_part_inst_status IN ( 37, 38, 39, 73 )
 AND NOT EXISTS (SELECT 1
 FROM table_case t_case,
 table_condition t_cond
 WHERE t_case.x_esn = pi.part_serial_no
 AND t_case.case_state2condition = t_cond.objid
 AND Upper(t_cond.title) NOT LIKE 'CLOSE%'
 AND Upper(t_case.title) LIKE '%SIM%')
 AND ROWNUM <= 1) RESERVED_LINE_AVAILABLE,
 PI.x_hex_serial_no,
 (SELECT OPERATING_SYSTEM
 FROM sa.pcpv pcpv
 WHERE pcpv.pc_objid = PC.objid
 ) OPERATING_SYS,
 WEB.s_login_name S_LOGIN_NAME,
 ag.account_group_name GROUP_NAME,
 ag.program_enrolled_id GROUP_PROG_ENROLL_ID,
 ag.end_date GROUP_END_DATE,
 ag.service_plan_feature_date GROUP_PLAN_FEATURE_DT,
 ag.service_plan_id GROUP_PLAN_ID,
 ag.start_date GROUP_START_DT,
 ag.status GROUP_STATUS,
 sa.customer_lease_scoring_pkg.Get_application_id(ag.objid, '' , '')
 GROUP_LEASE_APPLICATION_NUM,
 agm.master_flag ESN_MASTER_FLAG,
 agm.account_group_id GROUP_ID,
 agm.esn GROUP_ESN_NO,
 agm.member_order ESN_ORDER,
 agm.start_date ESN_START_DT,
 agm.end_date ESN_END_DATE,
 agm.status GROUP_ESN_STATUS,
 agm.program_param_id ESN_PROG_ID,
 rc.get_service_plan_objid (i_esn => PI.part_serial_no ) AS ESN_CURR_PLAN_ID, -- CR37756 PMistry Defect # 1470 (ITQ) 05/31/2016
 rc.get_contact_security_pin (i_contact_objid => pi.x_part_inst2contact) AS contact_security_pin, -- CR47564
			 NULL CUSTOMER_ID,
			 NULL FIRST_NAME ,
			 NULL LAST_NAME ,
			 pn.part_number PART_NUMBER,
			 NULL MANUFACTURER,
			 NULL DEVICE_MODEL,
			 NULL DEVICE_TYPE,
 customer_info.get_transaction_status(i_esn => PI.part_serial_no ) TRANSACTION_PENDING,
 customer_info.get_carrier_name (i_sim_serial => PI.x_iccid) carrier_name,
 customer_info.get_sim_status (i_sim_serial => PI.x_iccid) sim_status,
 customer_info.get_sim_legacy_flag (i_sim => PI.x_iccid) sim_legacy_flag
 FROM table_x_code_table CODE,
 table_part_num PN,
 table_mod_level ML,
 table_part_inst PI,
 table_x_contact_part_inst CONPI,
 table_bus_org BUS,
 table_web_user WEB,
 table_part_class PC,
 x_account_group_member AGM,
 x_account_group AG,
 x_customer_lease LEASE
 WHERE PI.n_part_inst2part_mod = ML.objid
 AND ML.part_info2part_num = PN.objid
 AND CODE.objid(+) = PI.status2x_code_table
 AND PI.objid(+) = CONPI.x_contact_part_inst2part_inst
 AND WEB.web_user2bus_org = BUS.objid
 AND PN.part_num2part_class = PC.objid
 AND PN.part_num2bus_org = BUS.objid
 AND CONPI.x_contact_part_inst2contact(+) = WEB.web_user2contact
 AND agm.esn = PI.part_serial_no
 AND agm.account_group_id = ag.objid (+)
 AND LEASE.x_esn(+) = PI.part_serial_no
 AND BUS.s_org_id = i_bus_org
 AND ag.objid = i_group_id
 UNION
 SELECT web.objid webobjid,
 pi.part_serial_no esn,
 pi.x_iccid iccid,
 conpi.x_esn_nick_name esn_nick_name,
 lease.lease_status lease_status,
 (SELECT CASE
                  WHEN i_language = 'SPANISH' THEN LEASE_STATUS_NAME_SPANISH
                  ELSE
                  case when lease.lease_status in (1001,1002) then 'Active'
                       when lease.lease_status=1005 then 'In Review'
                       when lease.lease_status=1006 then 'Returned'
                       else null end
                END
         FROM   x_lease_status
         where lease_status = lease.lease_status)
         LEASE_STATUS_NAME, --CR52336 TW Web common standards
 lease.application_req_num lease_application_number,
 Nvl(conpi.x_is_default, 0) is_default,
 Nvl(conpi.x_transfer_flag, 0) transfer_flag,
 web.web_user2contact web_contact_objid,
 pi.x_part_inst2contact part_contact_objid,
 code.x_code_name code_name,
 code.x_code_number code_number,
 bus.org_id bus_orgid,
 pi.x_port_in is_portin,
 pc.name pc_name,
 conpi.x_verified is_verified,
 (SELECT 'Y'
 FROM table_part_inst b
 WHERE b.part_to_esn2part_inst = pi.objid
 AND b.x_domain = 'LINES'
 AND b.x_part_inst_status IN ( 37, 38, 39, 73 )
 AND NOT EXISTS (SELECT 1
 FROM table_case t_case,
 table_condition t_cond
 WHERE t_case.x_esn = pi.part_serial_no
 AND t_case.case_state2condition = t_cond.objid
 AND Upper(t_cond.title) NOT LIKE 'CLOSE%'
 AND Upper(t_case.title) LIKE '%SIM%')
 AND ROWNUM <= 1) reserved_line_available,
 pi.x_hex_serial_no,
 (SELECT OPERATING_SYSTEM
 FROM sa.pcpv pcpv
 WHERE pcpv.pc_objid = PC.objid
 ) OPERATING_SYS,
 web.s_login_name s_login_name,
 NULL group_name,
 ag.program_enrolled_id group_prog_enroll_id,
 ag.end_date group_end_date,
 ag.service_plan_feature_date group_plan_feature_dt,
 NULL group_plan_id,
 NULL group_start_dt,
 null group_status,
 sa.customer_lease_scoring_pkg.Get_application_id(ag.objid, '' , '')
 GROUP_LEASE_APPLICATION_NUM,
 null esn_master_flag,
 NULL group_id,
 lease.x_esn group_esn_no,
 null ESN_ORDER,
 null esn_start_dt,
 null esn_end_date,
 null group_esn_status,
 null esn_prog_id,
 rc.get_service_plan_objid (i_esn => PI.part_serial_no ) AS ESN_CURR_PLAN_ID, -- CR37756 PMistry Defect # 1470 (ITQ) 05/31/2016
 rc.get_contact_security_pin (i_contact_objid => pi.x_part_inst2contact) AS contact_security_pin, -- CR47564
			 NULL CUSTOMER_ID,
			 NULL FIRST_NAME ,
			 NULL LAST_NAME ,
			 pn.part_number PART_NUMBER,
			 NULL MANUFACTURER,
			 NULL DEVICE_MODEL,
			 NULL DEVICE_TYPE,
 customer_info.get_transaction_status(i_esn => PI.part_serial_no ) TRANSACTION_PENDING,
 customer_info.get_carrier_name (i_sim_serial => PI.x_iccid) carrier_name,
 customer_info.get_sim_status (i_sim_serial => PI.x_iccid) sim_status,
 customer_info.get_sim_legacy_flag (i_sim => PI.x_iccid) sim_legacy_flag
 FROM table_x_code_table code,
 table_part_num pn,
 table_mod_level ml,
 table_part_inst pi,
 table_x_contact_part_inst conpi,
 table_bus_org bus,
 table_web_user web,
 table_part_class pc,
 x_account_group ag,
 x_customer_lease lease
 WHERE pi.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid
 AND code.objid(+) = pi.status2x_code_table
 AND pi.objid(+) = conpi.x_contact_part_inst2part_inst
 AND web.web_user2bus_org = bus.objid
 AND pn.part_num2part_class = pc.objid
 AND pn.part_num2bus_org = bus.objid
 AND conpi.x_contact_part_inst2contact(+) = web.web_user2contact
 AND lease.x_esn(+) = PI.part_serial_no
 AND bus.s_org_id = i_bus_org
 AND lease.account_group_id = i_group_id
 AND lease.account_group_id = ag.objid
 AND lease.x_esn = pi.part_serial_no
 AND pi.x_domain = 'PHONES'
 AND NOT EXISTS (SELECT 1
 FROM x_account_group_member
 WHERE esn = lease.x_esn
 AND status <> 'EXPIRED')
 ORDER BY group_id,GROUP_ESN_STATUS;
 --
 o_error_code := 0;
 o_error_msg := 'SUCCESS';
 --
EXCEPTION
 WHEN OTHERS THEN
 o_error_code := 99;
 o_error_msg := 'Failed in When others '|| SQLERRM;
END get_group_summary;
--
-- Procedure used to determine a customer's credit refund amount
PROCEDURE get_credit_refund ( i_account_group_id IN NUMBER ,
 i_new_service_plan_id IN NUMBER ,
 i_start_date IN DATE ,
 o_credit_refund_amount OUT NUMBER ,
 o_error_code OUT NUMBER ,
 o_response OUT VARCHAR2 ) IS

 l_new_service_plan_price NUMBER;
 l_number_of_lines NUMBER;
 c_service_days CONSTANT NUMBER := 30;
 days_between INTEGER;

 c customer_type := customer_type();
 cstg customer_type;

BEGIN
 --
 IF i_account_group_id IS NULL THEN
 o_error_code := 100;
 o_response := 'GROUP ID NOT PASSED';
 RETURN;
 END IF;

 --
 IF i_new_service_plan_id IS NULL THEN
 o_error_code := 200;
 o_response := 'SERVICE PLAN NOT PASSED';
 RETURN;
 END IF;

 --
 IF i_start_date IS NULL THEN
 o_error_code := 300;
 o_response := 'START DATE NOT PASSED';
 RETURN;
 END IF;

 -- Get the price of the new service plan
 BEGIN
 SELECT customer_price
 INTO l_new_service_plan_price
 FROM sa.x_service_plan
 WHERE objid = i_new_service_plan_id;
 EXCEPTION
 WHEN others THEN
 o_error_code := 400;
 o_response := 'NEW SERVICE PLAN PRICE NOT FOUND: ' || SQLERRM;
 RETURN;
 END;

 -- Get the price of the new service plan
 BEGIN
 SELECT TO_NUMBER(NVL(number_of_lines,1))
 INTO l_number_of_lines
 FROM sa.service_plan_feat_pivot_mv
 WHERE service_plan_objid = i_new_service_plan_id;
 EXCEPTION
 WHEN others THEN
 l_number_of_lines := 1;
 END;

 --
 cstg := c.retrieve_group ( i_account_group_objid => i_account_group_id );

 IF cstg.response NOT LIKE '%SUCCESS%' THEN
 o_error_code := 500;
 o_response := 'GROUP NOT FOUND: ' || cstg.response;
 RETURN;
 END IF;

 -- Removed the below Validation as it fails when adding a leased to Non leased Group. Requested by Services Team
 /*IF cstg.application_req_num IS NULL THEN
 o_error_code := 600;
 o_response := 'GROUP IS NOT LEASED';
 RETURN;
 END IF; */

 IF cstg.group_service_plan_objid = i_new_service_plan_id THEN
 o_error_code := 700;
 o_response := 'SERVICE PLANS ARE EXACTLY THE SAME';
 RETURN;
 END IF;

 -- Validate when the new service plan is a lesser plan than the existing
 IF l_number_of_lines < cstg.group_allowed_lines THEN
 o_error_code := 600;
 o_response := 'NO DISCOUNT WILL BE GRANTED IF THE NEW PLAN SUPPORTS FEWER LINES THAT THE CURRENT PLAN';
 RETURN;
 END IF;

 -- No refund will be given when the new service plan has already started
 IF i_start_date < TRUNC(SYSDATE) THEN
 --
 o_credit_refund_amount := 0;
 o_error_code := 0;
 o_response := 'SUCCESS';
 RETURN;
 END IF;
 --

 --
 SELECT CAST( TRUNC(i_start_date) - TRUNC(cstg.group_start_date) AS INTEGER) AS diff
 INTO days_between
 FROM DUAL;
 --
 -- Per Sunil adding the below IF condition to check whether the difference in days > 0
 IF (cstg.service_plan_days - days_between) > 0 AND cstg.service_plan_days > 0
 THEN
 -- perform calculation
 BEGIN
 -- Rounding to nearest cent per the request finance / business team
 o_credit_refund_amount := ROUND((( cstg.service_plan_price / cstg.service_plan_days) * (cstg.service_plan_days - days_between)),2);
 EXCEPTION
 WHEN others THEN
 o_error_code := 800;
 o_response := 'ERROR CALCULATING FORMULA: ' || SQLERRM;
 RETURN;
 END;
 ELSE
 o_credit_refund_amount := 0;
 END IF;
 --
 IF o_credit_refund_amount < 0
 THEN
 o_credit_refund_amount := 0;
 END IF;
 --
 o_error_code := 0;
 o_response := 'SUCCESS';
 --
 EXCEPTION
 WHEN others THEN
 o_error_code := 999;
 o_response := 'UNHANDLED EXCEPTION: ' || SQLERRM;
 RETURN;
END get_credit_refund;
--
PROCEDURE get_data_usage_level ( i_min IN VARCHAR2 ,
 i_data_usage IN NUMBER ,
 o_usage_level OUT VARCHAR2 ,
 o_error_code OUT NUMBER ,
 o_response OUT VARCHAR2 ) IS


 -- instantiate initial values
 rc sa.customer_type := customer_type ();

 -- type to hold retrieved attributes
 cst sa.customer_type;

BEGIN

 IF i_min IS NULL THEN
 o_error_code := 100;
 o_response := 'MIN NOT PASSED';
 o_usage_level := 'None';
 RETURN;
 END IF;

 -- call the retrieve method
 cst := rc.retrieve_min ( i_min => i_min );

 IF cst.response NOT LIKE '%SUCCESS%' THEN
 o_error_code := 110;
 o_response := cst.response;
	RETURN;
 END IF;

 -- Calculate the usage percentage
 cst.numeric_value := (i_data_usage / cst.service_plan_data) * 100;

 -- Determine the usage level
 IF cst.numeric_value BETWEEN 1 AND 30 THEN
 o_usage_level := 'Low';
 ELSIF cst.numeric_value BETWEEN 31 AND 70 THEN
 o_usage_level := 'Medium';
 ELSIF cst.numeric_value > 70 THEN
 o_usage_level := 'High';
 ELSE
 o_usage_level := 'None';
 END IF;

 --
 o_error_code := 0;
 o_response := 'SUCCESS';

 EXCEPTION
 WHEN others THEN
 --
 o_error_code := 999;
 o_response := 'ERROR FINDING USAGE LEVEL: ' || SQLERRM;
 --
 o_usage_level := 'None';
END get_data_usage_level;

-- Determine when an ESN is leased or not
PROCEDURE get_esn_leased_flag ( i_esn IN VARCHAR2 ,
 o_leased_flag OUT VARCHAR2 ) IS

 rc customer_type := customer_type ( i_esn => i_esn );
 cst customer_type;

BEGIN

 -- call the retrieve method
 cst := rc.retrieve;

 IF cst.lease_status IS NULL THEN
 o_leased_flag := 'N';
 ELSE
 --
 BEGIN
 SELECT CASE remove_leased_group_flag WHEN 'Y' THEN 'N'
 ELSE 'Y'
 		 END
 INTO o_leased_flag
 FROM sa.x_lease_status
 WHERE lease_status = cst.lease_status;
 EXCEPTION
 WHEN others THEN
 o_leased_flag := 'N';
 END;
 END IF;
 EXCEPTION
 WHEN others THEN
 o_leased_flag := 'N';
END get_esn_leased_flag;

-- Get the application_id for the lease
FUNCTION get_application_id ( i_account_group_id IN NUMBER ,
 i_red_card_code IN VARCHAR2 ,
 i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS

 c sa.customer_type := customer_type();
 rc sa.customer_type := customer_type();
 cst sa.customer_type := customer_type();
 --
 l_account_group_id x_account_group.objid%TYPE;
 --
BEGIN
 -- Just making sure at least one of the optional params is passed
 IF i_account_group_id IS NULL AND
 i_red_card_code IS NULL AND
 i_esn IS NULL
 THEN
 RETURN(NULL);
 END IF;

 c.smp := c.convert_pin_to_smp( i_red_card_code => i_red_card_code );
 --
 IF i_esn IS NOT NULL OR i_account_group_id IS NOT NULL
 THEN
 IF i_esn IS NOT NULL
 THEN
 BEGIN
 SELECT application_req_num
 INTO c.application_req_num
 FROM sa.x_customer_lease
 WHERE x_esn = i_esn
 AND lease_status in ('1001','1002','1005')
 AND ROWNUM = 1;
 EXCEPTION
 WHEN others THEN
 rc := customer_type ( i_esn => i_esn);
 cst := rc.retrieve;
 l_account_group_id := cst.account_group_objid;
 END;
 END IF;
 --
 IF i_account_group_id IS NOT NULL
 THEN
 l_account_group_id := i_account_group_id;
 END IF;
 --
 IF c.application_req_num IS NULL
 THEN
 -- Get the application id by GROUP ID
 BEGIN
 SELECT application_req_num
 INTO c.application_req_num
 FROM sa.x_customer_lease
 WHERE account_group_id = l_account_group_id
 AND lease_status in ('1001','1002','1005')
 AND ROWNUM = 1;
 EXCEPTION
 WHEN others THEN
 RETURN(NULL);
 END;
 END IF;
 ELSIF c.smp IS NOT NULL THEN
 -- Get the application id by SMP
 BEGIN
 SELECT application_req_num
 INTO c.application_req_num
 FROM sa.x_customer_lease
 WHERE smp = c.smp
 AND lease_status in ('1001','1002','1005')
 AND ROWNUM = 1;
 EXCEPTION
 WHEN others THEN
 RETURN(NULL);
 END;

 END IF;

 --
 RETURN(c.application_req_num);
 --

 EXCEPTION
 WHEN others THEN
 RETURN(NULL);
END get_application_id;
--

-- PROCEDURE used to update an esn part inst to Risk Assessment
PROCEDURE set_status_risk_assessment ( i_esn IN VARCHAR2 ,
 i_user_objid IN VARCHAR2 ,
 o_message OUT VARCHAR2 ) IS
--
 CURSOR cur_esn IS
 SELECT x_part_inst_status,
 objid
 FROM table_part_inst
 WHERE part_serial_no = i_esn
 AND x_domain = 'PHONES';

 rec_esn cur_esn%ROWTYPE;
 --
 l_reason VARCHAR2(30) := 'STATUS CHANGE';
 l_output VARCHAR2(200);
 l_objid VARCHAR2(20);
 l_code VARCHAR2(20);
 l_desc VARCHAR2(200);
 l_return VARCHAR2(30);

 --
 rc customer_type := customer_type ( i_esn => i_esn );
 c customer_type;
 --
 alt alert_type := alert_type();
 a alert_type;

BEGIN

 -- Validate the ESN is passed
 IF i_esn IS NULL THEN
 o_message := 'ESN CANNOT BE NULL';
 RETURN;
 END IF;
 --
 BEGIN
 SELECT objid,
 x_code_number,
 x_code_name
 INTO l_objid,
 l_code,
 l_desc
 FROM table_x_code_table
 WHERE x_code_name = 'RISK ASSESMENT'
 AND x_code_type = 'PS';
 EXCEPTION
 WHEN others THEN
 o_message := 'Risk Assessment Code not found';
 RETURN;
 END;
 --
 OPEN cur_esn;
 FETCH cur_esn INTO rec_esn;
 IF cur_esn%FOUND THEN
 CLOSE cur_esn;
 IF rec_esn.x_part_inst_status NOT IN ('50','51','52','53','54','50','150') THEN
 o_message := 'The Status Change, you are trying is not allowed.';
 RETURN;
 END IF;

 -- update lease row to risk assessment
 UPDATE x_customer_lease
 SET lease_status = '1005',
 update_dt = SYSDATE
 WHERE x_esn = i_esn;

 -- if the lease was not updated then return with an error
 IF SQL%ROWCOUNT = 0 THEN
 o_message := 'Lease not found for the provided ESN.';
 RETURN;
 END IF;

 -- update the part inst table as risk assessment
 UPDATE table_part_inst
 SET x_part_inst_status = l_code,
 status2x_code_table = l_objid
 WHERE part_serial_no = i_esn
 AND x_domain = 'PHONES';

 -- Set commit global variable to FALSE
 globals_pkg.g_perform_commit := FALSE;

 -- update part inst history table
 sa.insert_pi_hist_prc ( ip_user_objid => i_user_objid,
 ip_min => i_esn,
 ip_old_npa => '',
 ip_old_nxx => '',
 ip_old_ext => '',
 ip_reason => l_reason,
 ip_out_val => l_output);

 -- Set commit global variable to TRUE
 globals_pkg.g_perform_commit := TRUE;

 -- call the retrieve method to get the esn attributes
 c := rc.retrieve;

	-- instantiate the alert values
 alt := alert_type ( i_esn_part_inst_objid => c.esn_part_inst_objid,
 i_title => 'Lease on Risk Assessment Alert');

 -- delete the previous alert row of the same ESN and TITLE
 a := alt.del;

	-- instantiate the alert values
 alt := alert_type ( i_esn => c.esn,
 i_type => 'SQL',
 i_alert_text => 'Temporary text.',
 i_start_date => SYSDATE,
 i_end_date => TO_DATE('31-DEC-2055','DD-MON-YYYY'),
 i_active => 1,
 i_title => 'Lease on Risk Assessment Alert',
 i_hotline => 1,
 i_user_objid => i_user_objid,
 i_esn_part_inst_objid => c.esn_part_inst_objid,
 i_modify_stmp => SYSDATE,
 i_ivr_script_id => '8006',
 i_web_text_english => NULL,
 i_web_text_spanish => NULL,
 i_tts_english => '.',
 i_tts_spanish => '.',
 i_cancel_sql => 'SELECT COUNT(1) FROM sa.x_customer_lease WHERE x_esn = :esn AND lease_status <> ''1005'' ' );

 -- call the insert method to insert the alert message
 a := alt.ins;

 -- Display error when the alert was not created successfully
 IF a.response != 'SUCCESS' THEN
 o_message := a.response;
 RETURN;
 END IF;

 --
 o_message := 'SUCCESS';
 --
 ELSE
 CLOSE cur_esn;
 --
 o_message := 'ESN NOT FOUND';
 --
 END IF;
 --
 EXCEPTION
 WHEN OTHERS THEN
 o_message := 'Failed In when others' ||SQLERRM;
END set_status_risk_assessment;

-- Procedure to validate Group ID of From PHONE and To PHONE
PROCEDURE validate_upgrade ( i_from_esn IN VARCHAR2 ,
 i_to_esn IN VARCHAR2 ,
 o_err_code OUT VARCHAR2 ,
 o_err_msg OUT VARCHAR2 ) IS
--
 l_to_esn_group x_customer_lease.account_group_id%TYPE;
 --
 rc customer_type := customer_type ( i_esn => i_from_esn );
 c customer_type;
--
BEGIN
 --
 c := rc.retrieve;
 --
 IF i_from_esn IS NULL OR i_to_esn IS NULL
 THEN
 o_err_code := 99;
 o_err_msg := 'FROM PHONE or TO PHONE cannot be null ';
 RETURN;
 END IF;
 --
 IF c.account_group_objid IS NULL
 THEN
 o_err_code := 100;
 o_err_msg := 'FROM PHONE Group ID cannot be retrieved ';
 RETURN;
 END IF;
 --
 BEGIN
 SELECT agid.account_group_id
 INTO l_to_esn_group
 FROM ( SELECT account_group_id
 FROM x_customer_lease
 WHERE x_esn = i_to_esn
 UNION
 SELECT account_group_id
 FROM x_account_group_member
 WHERE esn = i_to_esn
 ) agid
 WHERE ROWNUM = 1;
 EXCEPTION
 WHEN OTHERS THEN
 o_err_code := 110;
 o_err_msg := 'Failed in when others while selecting GROUP ID of TO ESN '||SQLERRM;
 RETURN;
 END;
 --
 IF c.account_group_objid <> l_to_esn_group
 THEN
 o_err_code := 120;
 o_err_msg := 'FROM PHONE and TO PHONE group are different';
 RETURN;
 END IF;
 --
 o_err_code := 0;
 o_err_msg := 'SUCCESS';
 --
EXCEPTION
WHEN OTHERS THEN
 o_err_code := 130;
 o_err_msg := 'Failed In when others' ||SQLERRM;
END validate_upgrade;
--
-- CR31456 WARP changes
-- procedure used to validate if an esn and login name are under the same web account
PROCEDURE esn_email_validation ( i_esn IN VARCHAR2 ,
 i_login_name IN VARCHAR2 ,
 i_validate_account_flag IN VARCHAR2 DEFAULT 'Y',
 o_error_code OUT NUMBER ,
 o_error_msg OUT VARCHAR2 ) IS

 cst customer_type := customer_type ( i_esn => i_esn );
 c customer_type;
BEGIN

 -- validate passed ESN
 IF i_esn IS NULL THEN
 IF i_validate_account_flag = 'N' THEN
 o_error_code := 1;
 o_error_msg := 'ESN NOT PASSED';
 --
 RETURN;
 --
 ELSE
 o_error_code := 0;
 o_error_msg := 'SUCCESS';
 RETURN;
 END IF;
 END IF;



 -- validate passed login name
 IF i_login_name IS NULL THEN
 o_error_code := 1;
 o_error_msg := 'LOGIN NAME NOT PASSED';
 --
 RETURN;
 --
 END IF;

 -- call the member function to get the login name
 c := cst.get_web_user_attributes;

 --added for WARP 2.0
 IF i_validate_account_flag = 'N' AND c.web_login_name IS NULL THEN
 o_error_code := 0;
 o_error_msg := 'SUCCESS';
 RETURN;
 END IF;
 --added for WARP 2.0
 -- if the response is not successful it means the web login name was not found
 IF c.response NOT LIKE '%SUCCESS%' THEN
 o_error_code := 1;
 o_error_msg := c.response || ': ESN (' || i_esn ||')';
 --
 RETURN;
 --
 END IF;

 -- IF i_validate_account_flag = 'Y' THEN --commented for WARP 2.0
 -- if the web login name was not found
 IF c.web_login_name IS NULL THEN
 o_error_code := 1;
 o_error_msg := 'LOGIN NAME NOT FOUND FOR ESN (' || i_esn || ')';
 --
 RETURN;
 --
 END IF;
 -- END IF;

 IF LOWER(c.web_login_name) <> LOWER(i_login_name) THEN
 o_error_code := 1;
 o_error_msg := 'ESN DOES NOT BELONG TO ACCOUNT';
 --o_error_msg := 'EMAIL LOGIN NAME OF ESN (' || i_esn ||') DOES NOT MATCH ( ' || c.web_login_name || ')';
 --
 RETURN;
 --
 END IF;
 --
 o_error_code := 0;
 o_error_msg := 'SUCCESS';
 --
EXCEPTION
 WHEN others THEN
 o_error_code := 1;
 o_error_msg := 'ERROR VALIDATING ESN (' || i_esn ||') | EMAIL (' || i_login_name ||'): ' ||SQLERRM;
 --
 RETURN;
 --
END esn_email_validation;
--

-- procedure used to validate if an esn and login name are under the same web account
PROCEDURE esn_email_validation ( i_from_esn IN VARCHAR2 ,
 i_to_esn IN VARCHAR2 ,
 i_login_name IN VARCHAR2 ,
 o_error_code OUT NUMBER ,
 o_error_msg OUT VARCHAR2 ) IS
BEGIN
 -- validate the from esn
 esn_email_validation ( i_esn => i_from_esn ,
 i_login_name => i_login_name ,
 i_validate_account_flag => 'Y',
 o_error_code => o_error_code,
 o_error_msg => o_error_msg);

 IF o_error_code != 0 THEN
 RETURN;
 END IF;

 -- validate the to esn
 esn_email_validation ( i_esn => i_to_esn ,
 i_login_name => i_login_name ,
 i_validate_account_flag => 'N',
 o_error_code => o_error_code,
 o_error_msg => o_error_msg);

EXCEPTION
 WHEN others THEN
 o_error_code := 1;
 o_error_msg := 'ERROR VALIDATING FROM ESN | TO ESN | EMAIL: ' ||SQLERRM;
 --
 RETURN;
 --
END esn_email_validation;
--
-- CR46039 changes starts..
PROCEDURE p_get_info_for_pin ( i_red_card IN table_x_red_card.x_red_code%TYPE,
 o_is_redeemed OUT VARCHAR2,
 o_is_reserved OUT VARCHAR2,
 o_redeem_date OUT DATE,
 o_associated_esn OUT table_part_inst.part_serial_no%TYPE,
 o_associated_min OUT table_part_inst.part_serial_no%TYPE,
 o_err_code OUT VARCHAR2,
 o_err_msg OUT VARCHAR2)
IS
BEGIN
 -- Input validation
 IF TRIM(i_red_card) IS NULL
 THEN
 o_err_code := 100;
 o_err_msg := 'PIN cannot be NULL';
 RETURN;
 END IF;
 --
 BEGIN
 SELECT 'Y',
 'N',
 rc.x_red_date,
 ct.x_service_id,
 ct.x_min
 INTO o_is_redeemed,
 o_is_reserved,
 o_redeem_date,
 o_associated_esn,
 o_associated_min
 FROM table_x_red_card rc,
 table_x_call_trans ct
 WHERE rc.x_red_code = i_red_card
 AND rc.red_card2call_trans = ct.objid;
 --
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
 BEGIN
 SELECT 'N',
 (CASE
 WHEN pi.x_part_inst_status = 42 THEN 'N'
 ELSE 'Y'
 END) is_reserved,
 piesn.part_serial_no,
 (select part_serial_no from table_part_inst where part_to_esn2part_inst = piesn.objid and x_domain = 'LINES') min
 INTO o_is_redeemed,
 o_is_reserved,
 o_associated_esn,
 o_associated_min
 FROM table_part_inst pi,
 table_part_inst piesn
 WHERE pi.part_to_esn2part_inst = piesn.objid(+)
 AND pi.x_red_code = i_red_card
 AND pi.x_domain = 'REDEMPTION CARDS'
 AND pi.x_part_inst_status IN (40, 400, 42); -- Reserved, Queued, Not Redeemed
 EXCEPTION
 WHEN OTHERS THEN
 o_err_code := 101;
 o_err_msg := 'Failed while fetching from part inst '|| SQLERRM;
 RETURN;
 END;
 WHEN OTHERS THEN
 o_err_code := 102;
 o_err_msg := 'Failed while fetching from red card '|| SQLERRM;
 RETURN;
 END;
 --
 o_err_code := 0;
 o_err_msg := 'SUCCESS';
 --
EXCEPTION
WHEN OTHERS THEN
 o_err_code := 103;
 o_err_msg := 'Failed in when others of p_get_info_for_pin '|| SQLERRM;
END p_get_info_for_pin;
-- CR46039 changes ends.
-- CR47564 changes starts..
PROCEDURE get_full_account_summary ( i_login_name IN VARCHAR2,
 i_web_user_id IN VARCHAR2,
 i_group_id IN VARCHAR2,
 i_bus_org IN VARCHAR2,
 i_esn IN VARCHAR2,
 i_min IN VARCHAR2,
 i_language  IN VARCHAR2 DEFAULT 'ENGLISH', --Added for CR55236 TW Web common standards
 o_refcursor OUT SYS_REFCURSOR,
 o_error_code OUT VARCHAR2,
 o_error_msg OUT VARCHAR2)
IS
 c_esn table_part_inst.part_serial_no%TYPE;
 -- instantiate initial values
 --rc sa.customer_type := customer_type();
 -- type to hold retrieved attributes
 cst sa.customer_type := customer_type();
 --CR49875 start
 --Modified the procedure to get all the aatributes with ESN/MIN call. i.e. it will retrun al the attributes which are similar to the web user id call.
 --Limiting the required attributes will be handled at datapower
 n_web_user_objid table_web_user.objid%TYPE;
 c_web_user_login_name table_web_user.login_name%TYPE;
 n_group_id x_account_group.objid%TYPE;
 --CR49875 end
--
BEGIN
-- NULL Initialization
 OPEN o_refcursor
 FOR SELECT NULL FROM DUAL;

 IF i_bus_org IS NULL
 THEN
 o_error_code := '710';
 o_error_msg := 'Brand cannot be null';
 RETURN;
 END IF;

 IF i_login_name IS NOT NULL OR
 i_web_user_id IS NOT NULL OR
 i_group_id IS NOT NULL
 THEN
 --CR49875 start
 n_web_user_objid := i_web_user_id;
 c_web_user_login_name := i_login_name;
 n_group_id := i_group_id;
 ELSE
 IF i_esn IS NULL AND i_min IS NULL
 THEN
 o_error_code := '700';
 o_error_msg := 'ESN / MIN cannot be null';
 RETURN;
 END IF;
 --
 IF i_esn IS NULL
 THEN
 c_esn := cst.get_esn (i_min => i_min);
 ELSE
 c_esn := i_esn;
 END IF;
 --
 IF c_esn IS NULL
 THEN
 o_error_code := '720';
 o_error_msg := 'Cannot Retrieve ESN for the MIN';
 RETURN;
 END IF;

 --Get the web user login name for the ESN
 n_web_user_objid := sa.customer_info.get_web_user_attributes ( i_esn => c_esn,
 i_value => 'WEB_USER_ID' );
 --CR49875 changes end
 END IF;

 get_full_account_summary ( i_login_name => c_web_user_login_name,
 i_web_user_id => n_web_user_objid,
 i_group_id => n_group_id,
 i_bus_org => i_bus_org,
 i_language => i_language, --Added for CR55236 TW Web common standards
 o_refcursor => o_refcursor,
 o_error_code => o_error_code,
 o_error_msg => o_error_msg);

 --CR49875 changes start - commented below ref cursor query
 /*OPEN o_refcursor
 FOR SELECT NULL WEBOBJID,
 PI.part_serial_no ESN,
 PI.x_iccid ICCID,
 CONPI.x_esn_nick_name ESN_NICK_NAME,
 NULL LEASE_STATUS,
 NULL LEASE_APPLICATION_NUMBER,
 Nvl(CONPI.x_is_default, 0) IS_DEFAULT,
 Nvl(CONPI.x_transfer_flag, 0) TRANSFER_FLAG,
 NULL WEB_CONTACT_OBJID,
 PI.x_part_inst2contact PART_CONTACT_OBJID,
 CODE.x_code_name CODE_NAME,
 CODE.x_code_number CODE_NUMBER,
 BUS.org_id BUS_ORGID,
 PI.x_port_in IS_PORTIN,
 PC.name PC_NAME,
 CONPI.x_verified IS_VERIFIED,
 (SELECT 'Y'
 FROM table_part_inst b
 WHERE b.part_to_esn2part_inst = pi.objid
 AND b.x_domain = 'LINES'
 AND b.x_part_inst_status IN ( 37, 38, 39, 73 )
 AND NOT EXISTS (SELECT 1
 FROM table_case t_case,
 table_condition t_cond
 WHERE t_case.x_esn = pi.part_serial_no
 AND t_case.case_state2condition = t_cond.objid
 AND Upper(t_cond.title) NOT LIKE 'CLOSE%'
 AND Upper(t_case.title) LIKE '%SIM%')
 AND ROWNUM <= 1) RESERVED_LINE_AVAILABLE,
 PI.x_hex_serial_no,
 (SELECT OPERATING_SYSTEM
 FROM sa.pcpv pcpv
 WHERE pcpv.pc_objid = PC.objid
 ) OPERATING_SYS,
 NULL S_LOGIN_NAME,
 ag.account_group_name GROUP_NAME,
 ag.program_enrolled_id GROUP_PROG_ENROLL_ID,
 ag.end_date GROUP_END_DATE,
 ag.service_plan_feature_date GROUP_PLAN_FEATURE_DT,
 ag.service_plan_id GROUP_PLAN_ID,
 ag.start_date GROUP_START_DT,
 ag.status GROUP_STATUS,
 sa.customer_lease_scoring_pkg.Get_application_id(ag.objid, '' , '')
 GROUP_LEASE_APPLICATION_NUM,
 agm.master_flag ESN_MASTER_FLAG,
 agm.account_group_id GROUP_ID,
 agm.esn GROUP_ESN_NO,
 agm.member_order ESN_ORDER,
 agm.start_date ESN_START_DT,
 agm.end_date ESN_END_DATE,
 agm.status GROUP_ESN_STATUS,
 agm.program_param_id ESN_PROG_ID,
 rc.get_service_plan_objid (i_esn => PI.part_serial_no ) AS ESN_CURR_PLAN_ID,
 rc.get_contact_security_pin (i_contact_objid => pi.x_part_inst2contact) AS contact_security_pin,
			 tc.x_cust_id CUSTOMER_ID,
			 tc.first_name FIRST_NAME ,
			 tc.last_name LAST_NAME ,
			 pn.part_number PART_NUMBER,
			 mv.manufacturer MANUFACTURER,
			 mv.model_type DEVICE_MODEL,
			 mv.device_type DEVICE_TYPE,
 customer_info.get_transaction_status(i_esn => PI.part_serial_no ) TRANSACTION_PENDING,
 customer_info.get_carrier_name (i_sim_serial => PI.x_iccid) carrier_name,
 customer_info.get_sim_status (i_sim_serial => PI.x_iccid) sim_status,
 customer_info.get_sim_legacy_flag (i_sim => PI.x_iccid) sim_legacy_flag
 FROM table_x_code_table CODE,
 table_part_class PC,
 table_part_num PN,
 table_mod_level ML,
 table_part_inst PI,
 table_x_contact_part_inst CONPI,
 table_contact tc,
 table_bus_org BUS,
 x_account_group_member AGM,
 x_account_group AG,
 pcpv_mv MV
 WHERE PI.n_part_inst2part_mod = ML.objid
 AND ML.part_info2part_num = PN.objid
 AND CODE.objid(+) = PI.status2x_code_table
 AND PI.objid(+) = CONPI.x_contact_part_inst2part_inst
 AND CONPI.X_CONTACT_PART_INST2CONTACT = tc.objid (+)
 AND PC.objid = mv.pc_objid
 AND PN.part_num2part_class = PC.objid
 AND PN.part_num2bus_org = BUS.objid
 AND agm.esn(+) = PI.part_serial_no
 AND agm.account_group_id = ag.objid (+)
 AND PI.part_serial_no = c_esn
 AND BUS.s_org_id = i_bus_org
 UNION
 SELECT NULL webobjid,
 pi.part_serial_no esn,
 pi.x_iccid iccid,
 conpi.x_esn_nick_name esn_nick_name,
 NULL lease_status,
 NULL lease_application_number,
 Nvl(conpi.x_is_default, 0) is_default,
 Nvl(conpi.x_transfer_flag, 0) transfer_flag,
 NULL web_contact_objid,
 pi.x_part_inst2contact part_contact_objid,
 code.x_code_name code_name,
 code.x_code_number code_number,
 bus.org_id bus_orgid,
 pi.x_port_in is_portin,
 pc.name pc_name,
 conpi.x_verified is_verified,
 (SELECT 'Y'
 FROM table_part_inst b
 WHERE b.part_to_esn2part_inst = pi.objid
 AND b.x_domain = 'LINES'
 AND b.x_part_inst_status IN ( 37, 38, 39, 73 )
 AND NOT EXISTS (SELECT 1
 FROM table_case t_case,
 table_condition t_cond
 WHERE t_case.x_esn = pi.part_serial_no
 AND t_case.case_state2condition = t_cond.objid
 AND Upper(t_cond.title) NOT LIKE 'CLOSE%'
 AND Upper(t_case.title) LIKE '%SIM%')
 AND ROWNUM <= 1) reserved_line_available,
 pi.x_hex_serial_no,
 (SELECT OPERATING_SYSTEM
 FROM sa.pcpv pcpv
 WHERE pcpv.pc_objid = PC.objid
 ) OPERATING_SYS,
 NULL s_login_name,
 NULL group_name,
 NULL group_prog_enroll_id,
 NULL group_end_date,
 NULL group_plan_feature_dt,
 NULL group_plan_id,
 NULL group_start_dt,
 NULL group_status,
 NULL GROUP_LEASE_APPLICATION_NUM,
 null esn_master_flag,
 NULL group_id,
 NULL group_esn_no,
 null ESN_ORDER,
 null esn_start_dt,
 null esn_end_date,
 null group_esn_status,
 null esn_prog_id,
 rc.get_service_plan_objid (i_esn => PI.part_serial_no ) AS ESN_CURR_PLAN_ID,
 rc.get_contact_security_pin (i_contact_objid => pi.x_part_inst2contact) AS contact_security_pin,
			 tc.x_cust_id CUSTOMER_ID,
			 tc.first_name FIRST_NAME ,
			 tc.last_name LAST_NAME ,
			 pn.part_number PART_NUMBER,
			 mv.manufacturer MANUFACTURER,
			 mv.model_type DEVICE_MODEL,
			 mv.device_type DEVICE_TYPE,
 customer_info.get_transaction_status(i_esn => PI.part_serial_no ) TRANSACTION_PENDING,
 customer_info.get_carrier_name (i_sim_serial => PI.x_iccid) carrier_name,
 customer_info.get_sim_status (i_sim_serial => PI.x_iccid) sim_status,
 customer_info.get_sim_legacy_flag (i_sim => PI.x_iccid) sim_legacy_flag
 FROM table_x_code_table code,
 table_part_class pc,
 table_part_num pn,
 table_mod_level ml,
 table_part_inst pi,
 table_x_contact_part_inst conpi,
 table_contact tc,
 table_bus_org bus,
 pcpv_mv MV
 WHERE pi.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid
 AND code.objid(+) = pi.status2x_code_table
 AND pi.objid(+) = conpi.x_contact_part_inst2part_inst
 AND CONPI.X_CONTACT_PART_INST2CONTACT = tc.objid (+)
 AND PC.objid = mv.pc_objid
 AND pn.part_num2part_class = pc.objid
 AND pn.part_num2bus_org = bus.objid
 AND bus.s_org_id = i_bus_org
 AND PI.part_serial_no = c_esn
 AND pi.x_domain = 'PHONES'
 AND NOT EXISTS (SELECT 1
 FROM x_account_group_member
 WHERE esn = PI.part_serial_no
 AND status <> 'EXPIRED')
 ORDER BY group_id,GROUP_ESN_STATUS;*/
 --
 --o_error_code := 0;
 --o_error_msg := 'SUCCESS';
 --CR49875 changes end
 --
EXCEPTION
 WHEN OTHERS THEN
 o_error_code := 99;
 o_error_msg := 'Failed in When others '|| SQLERRM;
END get_full_account_summary;
--
-- CR47564 changes ends
--
END customer_lease_scoring_pkg;
-- ANTHILL_TEST PLSQL/SA/PackageBodies/CUSTOMER_LEASE_SCORING_PKB.sql 	CR55236: 1.79
-- ANTHILL_TEST PLSQL/SA/PackageBodies/CUSTOMER_LEASE_SCORING_PKB.sql 	CR55236: 1.80
/