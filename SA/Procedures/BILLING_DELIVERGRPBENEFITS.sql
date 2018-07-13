CREATE OR REPLACE PROCEDURE sa."BILLING_DELIVERGRPBENEFITS"
 (

/*************************************************************************************************/
/*      */
/* Name : BILLING_DELIVERGRPBENEFITS                              */
/*      */
/* Purpose : deliver benefits to the primary phone and the additional phones                 */
/*      */
/*      */
/* Platforms : Oracle 9i                  */
/*      */
/* Author : RSI                   */
/*      */
/* Date : 01-19-2006                                                                     */
/* REVISIONS:                              */
/* VERSION DATE WHO PURPOSE                      */
/* ------- ----------     -----          --------------------------------------------              */
/* 1.0          Initial Revision              */
/*      */
/*      */
/*************************************************************************************************/


 p_enrolled_objid x_program_enrolled.objid%TYPE,
 p_return_code OUT Number,
 p_return_message OUT varchar2
 )
 IS

 /* ----------------------------------------------------------------------------------------------
 This procedure is used to deliver the benefits to the primary phone and the
 additional phones. In addition, this procedure checks if the benefits need
 to be delivered immediately. If the benefits are not to be delivered immedidately,
 then the next_delivery_date is scheduled for the minutes delivery job to pickup.

 ASSUMPTION: BILLING_DELIVERBENEFITS will the called in a loop for delivery.
 OBJID passed will be the objid for the Primary phone.
 ----------------------------------------------------------------------------------------------- */

 cursor grp_deliver_c ( c_enroll_objid NUMBER )
 IS
 select objid, x_next_delivery_date, x_delivery_cycle_number, PGM_ENROLL2PGM_PARAMETER
 from x_program_enrolled
 where
 objid = c_enroll_objid
 or PGM_ENROLL2PGM_GROUP = c_enroll_objid;

 grp_deliver_rec grp_deliver_c%ROWTYPE;

 l_error_code NUMBER := 0;
 l_error_message VARCHAR2(255) := 'Success';

 l_delivery_frq_code x_program_parameters.x_delivery_frq_code%TYPE;

BEGIN

 dbms_output.put_line('Begin Delivering grp benefits ');
 OPEN grp_deliver_c ( p_enrolled_objid );
 LOOP
 fetch grp_deliver_c into grp_deliver_rec;
 exit when grp_deliver_c%NOTFOUND;

 dbms_output.put_line('Delivering benefits for : ' || to_char(grp_deliver_rec.objid) );

 /* Cover a possible scenario where during enrollment, next delivery date is not set.
 Get the delivery cycle number and the next cycle date. If delivery_cycle_number and
 next_delivery_date is null, then the next delivery date needs to be set, before
 delivering benefits */

 if ( grp_deliver_rec.x_next_delivery_date is NULL and grp_deliver_rec.x_delivery_cycle_number is null ) then
 dbms_output.put_line('Processing Enrollment Bug ');
 select x_delivery_frq_code
 into l_delivery_frq_code
 from x_program_parameters
 where objid = grp_deliver_rec.PGM_ENROLL2PGM_PARAMETER;

 update x_program_enrolled
 set x_next_delivery_date =
 DECODE (
 NVL (upper(l_delivery_frq_code), 0),
 'MONTHLY', ADD_MONTHS (sysdate, 1),
 'MON', NEXT_DAY (sysdate, 'MON'),
 'TUE', NEXT_DAY (sysdate, 'TUE'),
 'WED', NEXT_DAY (sysdate, 'WED'),
 'THU', NEXT_DAY (sysdate, 'THU'),
 'FRI', NEXT_DAY (sysdate, 'FRI'),
 'SAT', NEXT_DAY (sysdate, 'SAT'),
 'SUN', NEXT_DAY (sysdate, 'SUN'),
 'AFTERCHARGE', null, --Immediately after charged
 sysdate+TO_NUMBER (l_delivery_frq_code) -- Every x days
 )
 where objid = grp_deliver_rec.objid;

 commit;

 dbms_output.put_line('Updated the Next delivery date for ' || to_char(grp_deliver_rec.objid) );
 end if;
 /* Enrollment No date entry fix */

 BILLING_DELIVERBENEFITS ( grp_deliver_rec.objid, l_error_code, l_error_message);

 if ( l_error_code <> 0 ) then
 p_return_code := l_error_code;
 p_return_message := l_error_message;
 exit;
 end if;

 END LOOP;
 CLOSE grp_deliver_c;




EXCEPTION
 WHEN OTHERS THEN
 IF grp_deliver_c%ISOPEN then
 close grp_deliver_c;
 end if;

 p_return_code := -100 ;
 p_return_message := 'Unable to deliver group benefits';
END; -- Procedure SA.BILLING_DELIVERGRPBENEFITS
/