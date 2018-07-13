CREATE OR REPLACE PROCEDURE sa."BILLING_DELIVERBENEFITS" (
/**********************************************************************************************/
/* */
/* Name : billing_deliverbenefits */
/* */
/* Purpose : Delivers benefits for the given enrollment - includes and past pending */
/* deliveries till the current date. */
/* */
/* Platforms : Oracle 9i */
/* */
/* Author : RSI */
/* */
/* Date : 01-19-2006 */
/* REVISIONS: */
/* VERSION DATE WHO PURPOSE */
/* ------- ---------- ----- -------------------------------------------- */
/* 1.0 Initial Revision */
/* 1.1 04/02/2008 Ramu Added Code to retrieve the latest purchase details */
/* 1.2 06/15/2008 Ramu Modified for Lifeline Project */
/* 1.3/1.4 Ramu CR7326 */
/* 1.12 smacha CR48080 Not to write error code into error log table if the program enrolled is a SWITCHBASE class */
/**********************************************************************************************/
/**********CVS STRUCTURE***********************************************************************/
/* 1.1 09/03/10 NEG CR13581 */
/* 1.2 09/10/10 NEG CR14290 B2B and DLL issues */
/**********************************************************************************************/
 p_enrolled_objid x_program_enrolled.objid%TYPE,
 p_return_code OUT NUMBER,
 p_return_message OUT VARCHAR2
)
IS
 /* -----------------------------------------------------------------------
 This procedure delivers the benefits for the given enrolled esn in the program.
 This is a real time delivery and is supposed to be called from the batch/realtime
 jobs. Also, this procedure delivers benefits only to the enrolled esn and does
 *not* deliver to the additional phones if the given entry is a group primary.
 For delivering to primary and the group esn, use BILLING_DELIVERGRPBENEFITS.
 BILLING_DELIVERGRPBENEFITS can also be used for individual programs.

 ASSUMPTION: x_next_delivery_date < sysdate

 ASSUMPTION: Incase past deliveries are to be skipped, update the next_delivery_date
 ------------------------------------------------------------------------------ */

 /* Change History: 05-Jan-06
 As per discussion, deliver benefits needs to deliver minutes on and not
 worry about service days. Service days will be delivered upon charge to customer
 and is not related to weekly/any other schedule.
 The service delivery portion in this proc, is being moved to a new proc.
 */

 --start CR13581 is business account cursor NEG 9/3/2010
 Cursor C_Bus_Acc
 Is Select X_Business_Accounts.*
 From X_Program_Enrolled, X_Business_Accounts, Table_Web_User
 Where Pgm_Enroll2web_User = Table_Web_User.Objid
 and Bus_Primary2contact = WEB_USER2CONTACT
 And X_Program_Enrolled.Objid = P_Enrolled_Objid;

 r_bus_acc c_bus_acc%rowtype;
 -- end CR13581

 -- Cursor for retrieving the relevant parameters for the enrolled program.
 CURSOR enrollment_c (c_enrolled_objid NUMBER)
 IS
 SELECT a.objid, a.x_esn, b.x_type, a.x_delivery_cycle_number,
 a.x_enrollment_status, a.x_is_grp_primary,
 a.x_next_delivery_date, a.pgm_enroll2pgm_parameter,
 b.x_incl_service_days, b.x_delivery_frq_code,
 b.x_promo_incl_min_at, b.x_promo_incr_min_at, a.x_wait_exp_date,
 b.x_promo_incl_grpmin_at, b.x_promo_incr_grpmin_at,
 b.x_incr_minutes_dlv_cyl, b.x_incr_minutes_dlv_days,
 b.x_incr_grp_minutes_dlv_cyl, b.x_incr_grp_minutes_dlv_days,
 b.x_stack_dur_enroll, (SELECT MAX(SP.OBJID)
						 FROM sa.TABLE_SITE_PART SP
						 WHERE 1=1
						 and SP.X_SERVICE_ID = a.x_esn
						 AND SP.PART_STATUS||''= 'Active') as pgm_enroll2site_part,
 a.pgm_enroll2x_promotion, b.prog_param2bus_org,
 a.pgm_enroll2web_user, b.x_program_name,
 a.x_tot_grace_period_given,
 b.x_prog_class   --CR48080
 FROM sa.x_program_enrolled a, sa.x_program_parameters b
 WHERE 1 = 1
 AND (b.x_prog_class IS NULL OR b.x_prog_class <> 'LIFELINE')
 AND a.objid = c_enrolled_objid
 AND a.pgm_enroll2pgm_parameter = b.objid
  --CR43305 exclude Simple mobile
	  AND NOT EXISTS
      (SELECT 1
       FROM   x_program_parameters xpp
       WHERE  xpp.objid = a.pgm_enroll2pgm_parameter
       AND    get_brm_applicable_flag(i_bus_org_objid => xpp.prog_param2bus_org,i_program_parameter_objid => xpp.objid ) = 'Y' );

 -- Where clause modified for Lifeline Project .. CR7512 .. Ramu
 -- Not to deliver any benefits for Lifelink Wireless Customers from this job.
 v_enrollment_rec enrollment_c%ROWTYPE;

 -- Cursor for retrieving the ESN status from the site part table.
 CURSOR esn_status_c (c_esn x_program_enrolled.x_esn%TYPE)
 IS
 --
 -- Start CR13082 Kacosta 01/21/2011
 --SELECT service_end_dt
 -- FROM table_site_part
 -- WHERE x_service_id IN (c_esn) AND part_status = 'Active';
 SELECT tsp.service_end_dt
 FROM table_part_inst tpi
 ,table_site_part tsp
 WHERE tsp.x_service_id IN (c_esn)
 AND tsp.part_status = 'Active'
 AND tsp.objid = tpi.x_part_inst2site_part
 AND tpi.x_part_inst_status = '52'
 AND tpi.x_domain = 'PHONES';
 -- End CR13082 Kacosta 01/21/2011
 --
 v_esn_status_rec esn_status_c%ROWTYPE;

 CURSOR c_prog_purch_priority (c_objid x_program_purch_hdr.objid%TYPE)          --CR25625
 IS
 SELECT purch.x_priority
   FROM x_program_purch_hdr purch
  WHERE purch.objid = c_objid;
   rec_prog_purch_priority  c_prog_purch_priority%ROWTYPE;

 l_count NUMBER;
 l_enroll_type VARCHAR2 (30);
 -- Whether the promotion is onetime/recurring
 l_enroll_amount NUMBER DEFAULT 0;
 -- Dollar Discount given
 l_enroll_units NUMBER DEFAULT 0;
 -- Units given
 l_enroll_days NUMBER DEFAULT 0;
 -- Days given
 l_error_code NUMBER; -- Error Code
 l_error_message VARCHAR2 (255); -- Error Message
 l_index NUMBER;
 l_primary_included_minutes NUMBER;
 l_primary_increment_minutes NUMBER;
 l_addition_included_minutes NUMBER;
 l_addition_increment_minutes NUMBER;
 l_service_days_given NUMBER;
 l_delivery_cycle_number NUMBER;
 l_increment_dlvy_number NUMBER;
 l_service_exp_date DATE;
 l_enrollment_benefits NUMBER;
 l_next_delivery_date DATE; -- Next delivery date
 l_benefits_desc VARCHAR2 (1000);
 -- Description for the benefits used/delivered
 l_prog_purch_objid NUMBER; -- Added for CR7265 .. Ramu
 l_business_account NUMBER;
 l_priority  x_program_purch_dtl.x_priority%TYPE;  -- CR25625
BEGIN

 p_return_code := 0;

 /*
 This procedures delivers the benefits given the enrolled objid.
 Steps:
 1. Check if the customer is still enrolled
 2. Check if the ESN is still active
 3. Find if this is a primary / additional phone
 4. Get the promocodes associated with the program - check the validity of the promocode
 5. Find if there are any benefits to be delivered (x additional every 3rd cycle)
 6. Insert into x_pending_redemption table
 7. if the phone is ota enabled, drop the record into x_program_gencode
 */
 LOOP -- Loop for handing past deliveries
 -- Step 0: Retrieve the values
 OPEN enrollment_c (p_enrolled_objid);

 FETCH enrollment_c
 INTO v_enrollment_rec;

 IF enrollment_c%NOTFOUND
 THEN
 p_return_code := 6500;
 p_return_message :=
 'Unable to retrive the enrollment record for the given input';
 --For CR33218
  INSERT INTO x_program_error_log
 (x_source, x_error_code,
 x_error_msg, x_date,
 x_description,
 x_severity
 )
 VALUES ('SA.BILLING_DELIVERBENEFITS', p_return_code,
 p_return_message, SYSDATE,
 'p_enrolled_objid '||p_enrolled_objid,
 1 -- HIGH
 );
-----end CR33218
 RETURN;
 END IF;

 CLOSE enrollment_c;

 --Step 1: Check for the current status of Enrollment
 IF ( v_enrollment_rec.x_enrollment_status <> 'ENROLLED'
 AND ( v_enrollment_rec.x_enrollment_status = 'DEENROLLED'
 AND NVL (v_enrollment_rec.x_tot_grace_period_given, 0) <> 1
 )
 )
 /*
 Continue to deliver benefits, till the "de-enrollment happens at cycle date"
 */
 THEN
 p_return_code := 6501;
 p_return_message :=
 'Current status '
 || v_enrollment_rec.x_enrollment_status
 || ' does not permit delivery of minutes';

 END IF;

 -- Step 1: Check if the current delivery qualifies for a next delivery
 IF (v_enrollment_rec.x_next_delivery_date > SYSDATE)
 THEN
 EXIT; -- Benefits delivery not possible.
 END IF;

 -- Step 1a: Check for Wait Period (Transfers)
 IF (v_enrollment_rec.x_wait_exp_date IS NOT NULL)
 THEN
 IF (v_enrollment_rec.x_wait_exp_date > SYSDATE)
 THEN
 p_return_code := 6501;
 p_return_message :=
 'Current status - Wait Period - does not permit delivery of minutes';
 END IF;
 END IF;

 OPEN esn_status_c (v_enrollment_rec.x_esn);

 FETCH esn_status_c
 INTO v_esn_status_rec;

 IF esn_status_c%NOTFOUND
 THEN
 p_return_code := 6502;
 p_return_message :=
 'ESN ' || v_enrollment_rec.x_esn || ' is not active / not found';
 END IF;

 CLOSE esn_status_c;

 DBMS_OUTPUT.put_line ('Completed ESN check ');


 -- Incase there is any error, do not process further
 -- Return back from the procedure
 IF (p_return_code <> 0)
  THEN
  -----For CR33218
  INSERT INTO x_program_error_log
 (x_source, x_error_code,
 x_error_msg, x_date,
 x_description,
 x_severity
 )
 VALUES ('SA.BILLING_DELIVERBENEFITS', p_return_code,
 p_return_message, SYSDATE,
 'ESN '||v_enrollment_rec.x_esn,
 1 -- HIGH
 );

--end CR33218
 RETURN;
 END IF;

 -- Added for CR7265 .. Ramu
 SELECT MAX (purch.objid)
 INTO l_prog_purch_objid
 FROM x_program_purch_hdr purch,
 x_program_enrolled enroll,
 x_program_purch_dtl dtl
 WHERE 1 = 1
 AND purch.x_ics_rcode IN ('1', '100')
 AND purch.objid = dtl.pgm_purch_dtl2prog_hdr
 AND enroll.objid = p_enrolled_objid
 AND dtl.pgm_purch_dtl2pgm_enrolled = enroll.objid;

 -- End of CR7265 Changes .. Ramu

 -------------------- Start processing -------------------------------------------------------------
 DBMS_OUTPUT.put_line ('Starting delivery processing ');

 --start CR13581 is business account cursor NEG 9/3/2010
 Open C_Bus_Acc;
 Fetch C_Bus_Acc INTO R_Bus_Acc;
 IF C_Bus_Acc%Found THEN
 l_business_account:=1;
 ELSE
 l_business_account:=0;
 END IF;
 CLOSE c_bus_acc;

 --IF (v_enrollment_rec.x_is_grp_primary = 1)
 IF (v_enrollment_rec.x_is_grp_primary = 1 OR l_business_account = 1)
 -- end CR13581
-------------------------------------------------------------------------------------------------------------------
 THEN
 -- Is a primary phone. Get the benefits.
 -- Validate the promocode and get the benefits associated.
 DBMS_OUTPUT.put_line ('Processing for Primary Phone ');

------------- Check -------------------------------------------------------------------------------------
--- For a primary phone, if no incremental / included minutes found,
--- benefits cannot be delivered.
 IF ( v_enrollment_rec.x_promo_incl_min_at IS NULL
 AND v_enrollment_rec.x_promo_incr_min_at IS NULL
 )
 THEN
 p_return_code := 6503;
 p_return_message := 'No promo found for the primary phone - Cannot delivery benefits';

 DBMS_OUTPUT.put_line
 ('No promo found for the primary phone - Cannot delivery benefits'
 );
 -----------For CR33218
 --CR54410
 IF NVL(v_enrollment_rec.x_prog_class, 'X') NOT IN ('SWITCHBASE','HMO','LIFELINE','LOWBALANCE','ONDEMAND','WARRANTY','UNLIMITED')
 THEN
    INSERT INTO x_program_error_log
    (x_source, x_error_code,
    x_error_msg, x_date,
    x_description,
    x_severity
    )
    VALUES ('SA.BILLING_DELIVERBENEFITS', p_return_code,
    p_return_message, SYSDATE,
    'v_enrollment_rec.x_promo_incl_min_at and v_enrollment_rec.x_promo_incr_min_at is null -'||v_enrollment_rec.x_prog_class||'-'||v_enrollment_rec.x_esn,
    1 -- HIGH
    );
 END IF;
-----end CR33218
 EXIT;
 END IF;

----------------------------------------------------------------------------------------------------------
 IF (v_enrollment_rec.x_promo_incl_min_at IS NOT NULL)
 THEN
 ----- Get Included Minutes.
 billing_validateredeemcode (v_enrollment_rec.x_promo_incl_min_at,
 l_enroll_type,
 l_enroll_amount,
 l_enroll_units,
 l_enroll_days,
 l_error_code,
 l_error_message
 );

----------------------------------------------------------------------------------------------------
-- Ignore the service days given by the program

 -- Get the included minutes
 IF (l_error_code = 0)
 THEN -- Success
 l_primary_included_minutes := l_enroll_units;
 -- Ignoring the service days provided by the promocode
 DBMS_OUTPUT.put_line
 ( 'Got promocode primary '
 || TO_CHAR (v_enrollment_rec.x_promo_incl_min_at)
 || ' with '
 || l_primary_included_minutes
 || ' included minutes '
 );
 ELSE
 p_return_code := 6504;
 p_return_message := 'Included Minutes: ' || l_error_message;
 -----For CR33218
  INSERT INTO x_program_error_log
 (x_source, x_error_code,
 x_error_msg, x_date,
 x_description,
 x_severity
 )
 VALUES ('SA.BILLING_DELIVERBENEFITS', p_return_code,
 p_return_message, SYSDATE,
 'ESN '||v_enrollment_rec.x_esn,
 1 -- HIGH
 );

--end CR33218
 RETURN;
 END IF;
 END IF;

 IF (v_enrollment_rec.x_promo_incr_min_at IS NOT NULL)
 THEN
 ----- Get Incremental Minutes for additional phone.
 billing_validateredeemcode (v_enrollment_rec.x_promo_incr_min_at,
 l_enroll_type,
 l_enroll_amount,
 l_enroll_units,
 l_enroll_days,
 l_error_code,
 l_error_message
 );

----------------------------------------------------------------------------------------------------
-- Ignore the service days given by the program
-- Get the included minutes
 IF (l_error_code = 0)
 THEN -- Success
 l_primary_increment_minutes := l_enroll_units;
 -- Ignoring the service days provided by the promocode
 DBMS_OUTPUT.put_line
 ( 'Got promocode primary '
 || TO_CHAR (v_enrollment_rec.x_promo_incr_min_at)
 || ' with '
 || l_primary_increment_minutes
 || ' incremental minutes '
 );
 ELSE
 p_return_code := 6505;
 p_return_message := 'Incremental Minute ' || l_error_message;
 -----For CR33218
  INSERT INTO x_program_error_log
 (x_source, x_error_code,
 x_error_msg, x_date,
 x_description,
 x_severity
 )
 VALUES ('SA.BILLING_DELIVERBENEFITS', p_return_code,
 p_return_message, SYSDATE,
 'ESN '||v_enrollment_rec.x_esn,
 1 -- HIGH
 );

--end CR33218
 RETURN;
 END IF;
 END IF;

 DBMS_OUTPUT.put_line ('Primary phone processing over ');
-------------------------------------------------------------------------------------------------------------
 ELSE -- Not a primary phone
 -- Validate the promocode and get the benefits associated.
 DBMS_OUTPUT.put_line ('Processing for additional phone ');

------------- Check -------------------------------------------------------------------------------------
--- For a additional phone, if no incremental / included minutes found,
--- benefits cannot be delivered.

 IF ( v_enrollment_rec.x_promo_incl_grpmin_at IS NULL
 AND v_enrollment_rec.x_promo_incr_grpmin_at IS NULL) THEN
 DBMS_OUTPUT.put_line ('No promo found for the additional phone - Cannot delivery benefits'
 );
 EXIT;
 END IF;
----------------------------------------------------------------------------------------------------------
 IF (v_enrollment_rec.x_promo_incl_grpmin_at IS NOT NULL)
 THEN
 billing_validateredeemcode
 (v_enrollment_rec.x_promo_incl_grpmin_at,
 l_enroll_type,
 l_enroll_amount,
 l_enroll_units,
 l_enroll_days,
 l_error_code,
 l_error_message
 );

----------------------------------------------------------------------------------------------------
-- Ignore the service days given by the program
 IF (l_error_code = 0)
 THEN -- Success
 l_addition_included_minutes := l_enroll_units;
 -- Ignoring the service days provided by the promocode
 DBMS_OUTPUT.put_line
 ( 'Got promocode for additional phone '
 || TO_CHAR (v_enrollment_rec.x_promo_incl_grpmin_at)
 || ' with '
 || l_addition_included_minutes
 || ' included minutes '
 );
 ELSE
 p_return_code := 6506;
 p_return_message :=
 'Include Minutes Additional ' || l_error_message;
 -----For CR33218
  INSERT INTO x_program_error_log
 (x_source, x_error_code,
 x_error_msg, x_date,
 x_description,
 x_severity
 )
 VALUES ('SA.BILLING_DELIVERBENEFITS', p_return_code,
 p_return_message, SYSDATE,
 'ESN '||v_enrollment_rec.x_esn,
 1 -- HIGH
 );

--end CR33218
 RETURN;
 END IF;
 END IF;

 IF (v_enrollment_rec.x_promo_incr_grpmin_at IS NOT NULL)
 THEN
 ----- Get Incremental Minutes.
 billing_validateredeemcode
 (v_enrollment_rec.x_promo_incr_grpmin_at,
 l_enroll_type,
 l_enroll_amount,
 l_enroll_units,
 l_enroll_days,
 l_error_code,
 l_error_message
 );

----------------------------------------------------------------------------------------------------
-- Ignore the service days given by the program
-- Get the included minutes
 IF (l_error_code = 0)
 THEN -- Success
 l_addition_increment_minutes := l_enroll_units;
 -- Ignoring the service days provided by the promocode
 DBMS_OUTPUT.put_line
 ( 'Got promocode additional '
 || TO_CHAR (v_enrollment_rec.x_promo_incr_grpmin_at)
 || ' with '
 || l_addition_increment_minutes
 || ' incremental minutes '
 );
 ELSE
 p_return_code := 6507;
 p_return_message :=
 'Included Minutes Incremental ' || l_error_message;
 -----For CR33218
  INSERT INTO x_program_error_log
 (x_source, x_error_code,
 x_error_msg, x_date,
 x_description,
 x_severity
 )
 VALUES ('SA.BILLING_DELIVERBENEFITS', p_return_code,
 p_return_message, SYSDATE,
 'ESN '||v_enrollment_rec.x_esn,
 1 -- HIGH
 );

--end CR33218
 RETURN;
 END IF;
 END IF;

 DBMS_OUTPUT.put_line ('Additional phone processing over ');
 END IF;

/* Service Days Processing
------------------------------------------------------
-- Get the Service days for the program.

 DBMS_OUTPUT.put_line ('Service Days processing ');
 billing_validateredeemcode (
 v_enrollment_rec.x_incl_service_days,
 l_enroll_type,
 l_enroll_amount,
 l_enroll_units,
 l_enroll_days,
 l_error_code,
 l_error_message
 );

 IF (l_error_code = 0)
 THEN -- Success
 l_service_days_given := l_enroll_days; -- Ignoring the service days provided by the promocode
 DBMS_OUTPUT.put_line (
 'Got promocode included service days '
 || TO_CHAR (v_enrollment_rec.x_incl_service_days)
 || ' with '
 || l_service_days_given
 || ' service days '
 );
 ELSE
 p_return_code := 6509;
 p_return_message :=
 l_error_message
 || '. PromoCode for Service Days is invalid';
 END IF;
*/ ------------- Get the delivery cycle number
 l_delivery_cycle_number :=
 NVL (v_enrollment_rec.x_delivery_cycle_number, 0);
 -- If null value, this is the first delivery
 DBMS_OUTPUT.put_line ( 'Current Delivery cycle : '
 || l_delivery_cycle_number
 );

------------------------------------------------------------------------------------------
-- Check the enrollment promocode. If it gives dollar discount, ignore days/units.
 IF (v_enrollment_rec.pgm_enroll2x_promotion IS NOT NULL)
 THEN
 billing_validateenrollid (v_enrollment_rec.x_esn,
 v_enrollment_rec.pgm_enroll2x_promotion,
 v_enrollment_rec.prog_param2bus_org,
 l_enroll_type,
 l_enroll_amount,
 l_enroll_units,
 l_enroll_days,
 l_error_code,
 l_error_message
 );

 IF (l_error_code <> 0)
 THEN -- Promocode validation failes.
 DBMS_OUTPUT.put_line ('Promocode invalid ');
 -- Typically these will not occur
 -- RETURN;
 -- Modified for SEP project.. Ramu
 -- Do not Return if promo is Invalid
 -----For CR33218
  INSERT INTO x_program_error_log
 (x_source, x_error_code,
 x_error_msg, x_date,
 x_description,
 x_severity
 )
 VALUES ('SA.BILLING_DELIVERBENEFITS', l_error_code,
 l_error_message, SYSDATE,
 'Promocode invalid ESN '||v_enrollment_rec.x_esn,
 1 -- HIGH
 );

--end CR33218

 END IF;
 END IF;

 -- Check if it gives a dollar discount. Incase a dollar discount is given, ignore servicedays/minutes parameters
 IF (l_enroll_amount = 0)
 THEN -- Does not have any money discount
 IF ( ( (l_enroll_type = 'ONETIME')
 AND (l_delivery_cycle_number = 0)
 )
 OR (l_enroll_type = 'RECURRING')
 )
 THEN
 -- Delivery benefits for minutes/service days
 l_enrollment_benefits := 1;
 ELSE
 -- Benefits need not be given
 l_enrollment_benefits := 0;
 END IF;
 ELSE
 -- Dollar discount given, ignore benefits given by this promocode.
 DBMS_OUTPUT.put_line
 ('This promo code gives dollar discount. Minutes / Service benefits not eligible '
 );
 END IF;

/* Service Days delivery not a part of this procedure now.
 -------------- Get the current expiry date (TABLE_SITE_PART)---------------------------------------
 IF (v_esn_status_rec.service_end_dt IS NULL)
 THEN
 DBMS_OUTPUT.put_line ('Service End date is NULL ');
 ELSE
 DBMS_OUTPUT.put_line (v_esn_status_rec.service_end_dt);
 END IF;

 DBMS_OUTPUT.put_line (
 'Checking stacking policy for '
 || v_enrollment_rec.x_stack_dur_enroll
 || ' Stacking'
 );

 --- Check the stacking policy and decide on the benefits.

 IF (l_enrollment_benefits = 1)
 THEN
 l_service_days_given := l_service_days_given
 + l_enroll_days;
 END IF;

 -- Sample data contains service_end_date as NULL. Temporarily, if service_end_date is NULL , set the service end date to sysdate.
 IF (v_enrollment_rec.x_stack_dur_enroll = 'FULL')
 THEN
 l_service_exp_date := NVL (v_esn_status_rec.service_end_dt, SYSDATE)
 + l_service_days_given;
 ELSIF (v_enrollment_rec.x_stack_dur_enroll = 'GAP')
 THEN
 IF ( SYSDATE
 + l_service_days_given >
 NVL (v_esn_status_rec.service_end_dt, SYSDATE)
 )
 THEN
 l_service_exp_date := SYSDATE
 + l_service_days_given;
 END IF;
 ELSE
 l_service_exp_date := SYSDATE
 + l_service_days_given;
 END IF;

 DBMS_OUTPUT.put_line (
 'New computed expiry for '
 || v_enrollment_rec.x_stack_dur_enroll
 || ' Stacking is '
 || l_service_exp_date
 );

 IF (l_service_exp_date IS NULL)
 THEN
 DBMS_OUTPUT.put_line (
 '6510 : Error Computing Service End Date. Please check the data '
 );
 RETURN;
 END IF;

 -- Apply the max. service days rule
 l_service_exp_date := LEAST (l_service_exp_date, SYSDATE
 + 730);
*/ -- Insert record into table_x_pending_redemption.
 IF ( v_enrollment_rec.x_type = 'GROUP'
 AND v_enrollment_rec.x_is_grp_primary = 0
 )
 THEN
 -- deliver additional benefits
 -- l_addition_included_minutes, l_addition_increment_minutes
 DBMS_OUTPUT.put_line
 ('Insert into pending redemption - Included Minutes ');

 IF (v_enrollment_rec.x_promo_incl_grpmin_at IS NOT NULL)
 THEN
 INSERT INTO table_x_pending_redemption
 (objid,
 pend_red2x_promotion,
 x_pend_red2site_part,
 x_pend_type, pend_redemption2esn, x_case_id,
 x_granted_from2x_call_trans, pend_red2prog_purch_hdr
 ) -- Added for CR7265 .. Ramu
 VALUES (seq ('x_pending_redemption'),
 v_enrollment_rec.x_promo_incl_grpmin_at,
 v_enrollment_rec.pgm_enroll2site_part,
 'BPDelivery', NULL, NULL,
 NULL, l_prog_purch_objid
 ); -- Added for CR7265 .. Ramu

 INSERT INTO table_x_promo_hist
 (objid,
 promo_hist2x_promotion
 )
 VALUES (seq ('x_promo_hist'),
 v_enrollment_rec.x_promo_incl_grpmin_at
 );

 /* ---------------------------------------------------------------------------------------------
 UnComment if x_gencode requires one record for each table_x_pending redemption
 insert into x_program_gencode ( objid, x_esn, x_insert_date, x_status )
 values ( billing_seq('x_program_gencode'), v_enrollment_rec.x_esn, sysdate, 'INSERTED');
 */
 DBMS_OUTPUT.put_line ('Delivered Included Additional Minutes ');
 END IF;

 IF (v_enrollment_rec.x_promo_incr_grpmin_at IS NOT NULL)
 THEN
 -- Does this ESN qualify for incremental minutes?
 IF ( l_delivery_cycle_number
 MOD v_enrollment_rec.x_incr_grp_minutes_dlv_cyl = 0
 )
 THEN
 DBMS_OUTPUT.put_line
 ( 'Qualified for additional delivery: Current Delivery '
 || v_enrollment_rec.x_incr_grp_minutes_dlv_cyl
 || ' Parameter '
 || l_delivery_cycle_number
 );

 -- check if max deliveries are made.
 IF (v_enrollment_rec.x_incr_grp_minutes_dlv_cyl != 0)
 THEN
 l_increment_dlvy_number :=
 l_delivery_cycle_number
 / v_enrollment_rec.x_incr_grp_minutes_dlv_cyl;
 /* Defect 265:
 IF (l_increment_dlvy_number <
 v_enrollment_rec.x_incr_grp_minutes_dlv_days
 )
 THEN
 */ --- Continue delivering benefits until the max. level.
 l_increment_dlvy_number :=
 LEAST (l_increment_dlvy_number,
 v_enrollment_rec.x_incr_grp_minutes_dlv_days
 );

 FOR l_index IN 1 .. l_increment_dlvy_number
 LOOP
 INSERT INTO table_x_pending_redemption
 (objid,
 pend_red2x_promotion,
 x_pend_red2site_part,
 x_pend_type, pend_redemption2esn,
 x_case_id, x_granted_from2x_call_trans,
 pend_red2prog_purch_hdr
 ) -- Added for CR7265 .. Ramu
 VALUES (seq ('x_pending_redemption'),
 v_enrollment_rec.x_promo_incr_grpmin_at,
 v_enrollment_rec.pgm_enroll2site_part,
 'BPDelivery', NULL,
 NULL, NULL,
 l_prog_purch_objid
 ); -- Added for CR7265 .. Ramu

 INSERT INTO table_x_promo_hist
 (objid,
 promo_hist2x_promotion
 )
 VALUES (seq ('x_promo_hist'),
 v_enrollment_rec.x_promo_incr_grpmin_at
 );

 /* ---------------------------------------------------------------------------------------------
 UnComment if x_gencode requires one record for each table_x_pending redemption

 insert into x_program_gencode ( objid, x_esn, x_insert_date, x_status )
 values ( billing_seq('x_program_gencode'), v_enrollment_rec.x_esn, sysdate, 'INSERTED');
 */
 DBMS_OUTPUT.put_line
 ('Delivered Incremental Minutes Additional');
 END LOOP;
-- END IF; //Bug 269:
 END IF; -- MOD Check
 END IF;
 END IF;
 ELSE
 IF (v_enrollment_rec.x_promo_incl_min_at IS NOT NULL)
 THEN
 DBMS_OUTPUT.put_line
 ('Insert into pending redemption - Included Minutes primary ');

 INSERT INTO table_x_pending_redemption
 (objid,
 pend_red2x_promotion,
 x_pend_red2site_part,
 x_pend_type, pend_redemption2esn, x_case_id,
 x_granted_from2x_call_trans, pend_red2prog_purch_hdr
 ) -- Added for CR7265 .. Ramu
 VALUES (seq ('x_pending_redemption'),
 v_enrollment_rec.x_promo_incl_min_at,
 v_enrollment_rec.pgm_enroll2site_part,
 'BPDelivery', NULL, NULL,
 NULL, l_prog_purch_objid
 ); -- Added for CR7265 .. Ramu

 INSERT INTO table_x_promo_hist
 (objid,
 promo_hist2x_promotion
 )
 VALUES (seq ('x_promo_hist'),
 v_enrollment_rec.x_promo_incl_min_at
 );

 /* ---------------------------------------------------------------------------------------------
 UnComment if x_gencode requires one record for each table_x_pending redemption

 insert into x_program_gencode ( objid, x_esn, x_insert_date, x_status )
 values ( billing_seq('x_program_gencode'), v_enrollment_rec.x_esn, sysdate, 'INSERTED');
 */
 DBMS_OUTPUT.put_line ('Delivered Included Primary Minutes ');
 END IF;

 IF (v_enrollment_rec.x_promo_incr_min_at IS NOT NULL)
 THEN
 DBMS_OUTPUT.put_line
 ('Insert into pending redemption - Incremental Minutes Primary '
 );

 -- Does this ESN qualify for incremental minutes?
 IF ( l_delivery_cycle_number
 MOD v_enrollment_rec.x_incr_minutes_dlv_cyl = 0
 )
 THEN
 DBMS_OUTPUT.put_line
 ( 'Qualified for additional delivery: Current Delivery '
 || v_enrollment_rec.x_incr_minutes_dlv_cyl
 || ' Parameter '
 || l_delivery_cycle_number
 );

 ------------- Check for divide by 0 exception. -----------------------
 IF (v_enrollment_rec.x_incr_minutes_dlv_cyl != 0)
 THEN
 -- check if max deliveries are made.
 l_increment_dlvy_number :=
 l_delivery_cycle_number
 / v_enrollment_rec.x_incr_minutes_dlv_cyl;
 /* Defect 265:
 IF (l_increment_dlvy_number <
 v_enrollment_rec.x_incr_minutes_dlv_days
 )
 THEN
 */ --- Continue delivering benefits until the max. level.
 l_increment_dlvy_number :=
 LEAST (l_increment_dlvy_number,
 v_enrollment_rec.x_incr_minutes_dlv_days
 );

 FOR l_index IN 1 .. l_increment_dlvy_number
 LOOP
 INSERT INTO table_x_pending_redemption
 (objid,
 pend_red2x_promotion,
 x_pend_red2site_part,
 x_pend_type, pend_redemption2esn,
 x_case_id, x_granted_from2x_call_trans,
 pend_red2prog_purch_hdr
 ) -- Added for CR7265 .. Ramu
 VALUES (seq ('x_pending_redemption'),
 v_enrollment_rec.x_promo_incr_min_at,
 v_enrollment_rec.pgm_enroll2site_part,
 'BPDelivery', NULL,
 NULL, NULL,
 l_prog_purch_objid
 ); -- Added for CR7265 .. Ramu

 INSERT INTO table_x_promo_hist
 (objid,
 promo_hist2x_promotion
 )
 VALUES (seq ('x_promo_hist'),
 v_enrollment_rec.x_promo_incr_min_at
 );
 /* ---------------------------------------------------------------------------------------------
 UnComment if x_gencode requires one record for each table_x_pending redemption

 insert into x_program_gencode ( objid, x_esn, x_insert_date, x_status )
 values ( billing_seq('x_program_gencode'), v_enrollment_rec.x_esn, sysdate, 'INSERTED');
 */
 END LOOP;
 END IF;

-- END IF;
 DBMS_OUTPUT.put_line ('Delivered Incremental Minutes Primary');
 END IF;
 END IF;
 END IF;

 /* ---------------------- Update the site part table --------------------------------- */
/* Service days delivery not a part of this proc now.
 UPDATE table_site_part
 SET service_end_dt = l_service_exp_date
 WHERE x_service_id IN (v_enrollment_rec.x_esn)
 AND part_status = 'Active';

dbms_output.put_line('Updated Site Part ');

 IF (l_enrollment_benefits = 1)
 THEN
 DBMS_OUTPUT.put_line ('Delivery Enrollment Benefits ');

 INSERT INTO table_x_pending_redemption
 (objid,
 pend_red2x_promotion,
 x_pend_red2site_part, x_pend_type, pend_redemption2esn,
 x_case_id, x_granted_from2x_call_trans)
 VALUES (seq ('x_pending_redemption'),
 v_enrollment_rec.pgm_enroll2x_promotion,
 v_enrollment_rec.pgm_enroll2site_part, 'BPDelivery', NULL,
 NULL, NULL);

 INSERT INTO table_x_promo_hist
 (objid,
 promo_hist2x_promotion)
 VALUES (seq ('x_promo_hist'),
 v_enrollment_rec.pgm_enroll2x_promotion);
 END IF;

dbms_output.put_line('Updating Pending Redemption ');
 INSERT INTO table_x_pending_redemption
 (objid,
 pend_red2x_promotion,
 x_pend_red2site_part, x_pend_type, pend_redemption2esn,
 x_case_id, x_granted_from2x_call_trans)
 VALUES (seq ('x_pending_redemption'),
 v_enrollment_rec.x_incl_service_days,
 v_enrollment_rec.pgm_enroll2site_part, 'BPDelivery', NULL,
 NULL, NULL);

 INSERT INTO table_x_promo_hist
 (objid, promo_hist2x_promotion)
 VALUES (seq ('x_promo_hist'), v_enrollment_rec.x_incl_service_days);
*/
 -- Drop the record into the x_program_gencode only if the phone and the carrier is OTA Enabled.
 IF (billing_isotaenabled (v_enrollment_rec.x_esn) = 1)
 THEN
 OPEN c_prog_purch_priority(l_prog_purch_objid);
 FETCH c_prog_purch_priority INTO rec_prog_purch_priority;
 CLOSE c_prog_purch_priority;

 INSERT INTO x_program_gencode
 (objid,
 x_esn, x_insert_date, x_status,
 gencode2prog_purch_hdr,
 x_priority
 ) -- Modified for CR7265 .. Ramu
 VALUES (billing_seq ('x_program_gencode'),
 v_enrollment_rec.x_esn, SYSDATE, 'INSERTED',
 l_prog_purch_objid,
 rec_prog_purch_priority.x_priority   --CR25625
 ); -- Modified for CR7265 .. Ramu
 ELSE
 DBMS_OUTPUT.put_line ( 'Phone/Carrier is not OTA Enabled for : '
 || v_enrollment_rec.x_esn
 );
 END IF;

 /* ---------------------- Update delivery cycle for the Enrollment -------------------- */
 -- Compute the next delivery date.
 DBMS_OUTPUT.put_line
 ( 'Updating Enrolled table with New next_delivery date :: '
 || v_enrollment_rec.x_delivery_frq_code
 );

 UPDATE x_program_enrolled
 SET x_delivery_cycle_number = NVL (x_delivery_cycle_number, 0) + 1,
 x_next_delivery_date =
 DECODE
 (UPPER (v_enrollment_rec.x_delivery_frq_code),
 'MONTHLY', ADD_MONTHS (NVL (x_next_delivery_date, SYSDATE),
 1
 ),
 'MON', TRUNC (NEXT_DAY (NVL (x_next_delivery_date,
 SYSDATE),
 'MON'
 )
 ),
 'TUE', TRUNC (NEXT_DAY (NVL (x_next_delivery_date,
 SYSDATE),
 'TUE'
 )
 ),
 'WED', TRUNC (NEXT_DAY (NVL (x_next_delivery_date,
 SYSDATE),
 'WED'
 )
 ),
 'THU', TRUNC (NEXT_DAY (NVL (x_next_delivery_date,
 SYSDATE),
 'THU'
 )
 ),
 'FRI', TRUNC (NEXT_DAY (NVL (x_next_delivery_date,
 SYSDATE),
 'FRI'
 )
 ),
 'SAT', TRUNC (NEXT_DAY (NVL (x_next_delivery_date,
 SYSDATE),
 'SAT'
 )
 ),
 'SUN', TRUNC (NEXT_DAY (NVL (x_next_delivery_date,
 SYSDATE),
 'SUN'
 )
 ),
 'AFTERCHARGE', NULL,
 --Immediately after charged. Always set the next delivery date as null.
 TRUNC
 ( x_next_delivery_date
 + TO_NUMBER (v_enrollment_rec.x_delivery_frq_code)
 ) -- Every x days
 )
 WHERE objid = p_enrolled_objid;

 /* --- If the next delivery date < sysdate, another delivery needs to be made: HOW to handle this? */

 /* ---------------------- update the program transaction history --------------------- */
 DBMS_OUTPUT.put_line ('Before program trans');
 --- Construct the benefits description data.
 l_benefits_desc := v_enrollment_rec.x_program_name || ' - ';

 -- Program Name
 IF (l_primary_included_minutes IS NOT NULL)
 THEN
 l_benefits_desc :=
 l_benefits_desc
 || ' - Included Minutes '
 || l_primary_included_minutes;
 END IF;

 IF ( l_primary_increment_minutes IS NOT NULL
 AND l_increment_dlvy_number IS NOT NULL
 )
 THEN
 l_benefits_desc :=
 l_benefits_desc
 || ' - Incremental Minutes '
 ||
 -- Bug 275
 CASE
 WHEN v_enrollment_rec.x_incr_minutes_dlv_cyl != 0
 THEN l_primary_increment_minutes
 * (l_increment_dlvy_number)
 ELSE l_primary_increment_minutes
 END;
 END IF;

 IF ( l_addition_included_minutes IS NOT NULL
 AND l_increment_dlvy_number IS NOT NULL
 )
 THEN
 l_benefits_desc :=
 l_benefits_desc
 || ' - Additional Included Minutes '
 ||
 -- Bug 275
 CASE
 WHEN v_enrollment_rec.x_incr_grp_minutes_dlv_cyl != 0
 THEN l_addition_included_minutes
 * (l_increment_dlvy_number)
 ELSE l_addition_included_minutes
 END;
 END IF;

 IF (l_addition_increment_minutes IS NOT NULL)
 THEN
 l_benefits_desc :=
 l_benefits_desc
 || ' - Additional Incremental Minutes '
 || l_addition_increment_minutes;
 END IF;

 IF (l_enrollment_benefits IS NOT NULL AND l_enrollment_benefits <> 0)
 THEN
 --BUG 482 Corollary: Dispay Promo code used as well in the program history
 SELECT x_promo_code
 INTO l_enrollment_benefits
 FROM table_x_promotion
 WHERE objid = v_enrollment_rec.pgm_enroll2x_promotion;

 l_benefits_desc :=
 l_benefits_desc || ' Promo code used : ' || l_enrollment_benefits;
 -- BUG 483 End:
 END IF;

 INSERT INTO x_program_trans
 (objid,
 x_enrollment_status, x_enroll_status_reason,
 x_float_given, x_cooling_given, x_trans_date,
 x_action_text, x_action_type, x_reason, x_sourcesystem,
 x_esn, x_exp_date, x_cooling_exp_date, x_update_status,
 x_update_user, pgm_tran2pgm_entrolled,
 pgm_trans2web_user,
 pgm_trans2site_part
 )
 VALUES (billing_seq ('X_PROGRAM_TRANS'),
 v_enrollment_rec.x_enrollment_status, 'Benefits Granted',
 NULL, NULL, SYSDATE,
 'Benefits Granted', 'BENEFITS',
 /*
 'Service Days=>'
 || l_service_exp_date
 || ' Primary Included Min => '
 || l_primary_included_minutes
 || ' Primary Incremental Min => '
 || l_primary_increment_minutes
 || ' Additional Incl. Min =>'
 || l_addition_included_minutes
 || ' Additional Incr. Min => '
 || l_addition_increment_minutes
 || ' PromoUsed => '
 || l_enrollment_benefits
 || ':'
 || l_enroll_type
 */
 l_benefits_desc, 'SYSTEM',
 v_enrollment_rec.x_esn, NULL, NULL, 'I',
 'System', v_enrollment_rec.objid,
 v_enrollment_rec.pgm_enroll2web_user,
 v_enrollment_rec.pgm_enroll2site_part
 );

 -- Deliver benefits continuously till the next_delivery_date > sysdate.

 --- If the record is immediately after charge, do not loop for past deliveries.
 IF (v_enrollment_rec.x_delivery_frq_code = 'AFTERCHARGE')
 THEN
 EXIT;
 END IF;
 END LOOP;

 DBMS_OUTPUT.put_line ('Procedure executed successfully ');
 RETURN; -- All OK.
EXCEPTION
 WHEN OTHERS
 THEN
 DBMS_OUTPUT.put_line ('Error ' || TO_CHAR (SQLCODE) || ': ' || SQLERRM);
 p_return_code := SQLCODE;
 p_return_message := SQLERRM;

------------------------ Exception Logging --------------------------------------------------------------------
--- Incase of any Exceptions, Log the data in the Error Log table for debugging purposes.
 INSERT INTO x_program_error_log
 (x_source, x_error_code,
 x_error_msg, x_date,
 x_description,
 x_severity
 )
 VALUES ('SA.BILLING_DELIVERBENEFITS', p_return_code,
 p_return_message, SYSDATE,
 'ESN '
 || (SELECT x_esn
 FROM x_program_enrolled
 WHERE objid = p_enrolled_objid)
 || ' Enrollment ID '
 || TO_CHAR (p_enrolled_objid),
 1 -- HIGH
 );

------------------------ Exception Logging --------------------------------------------------------------------
 p_return_code := -100;
 RETURN;
END; -- Procedure BILLING_DELIVERBENEFITS
/