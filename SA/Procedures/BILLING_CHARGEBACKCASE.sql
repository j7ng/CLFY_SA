CREATE OR REPLACE Procedure sa.BILLING_CHARGEBACKCASE
 (

/*************************************************************************************************/
/* 	 */
/* Name : BILLING_CHARGEBACKCASE 								 */
/* 	 */
/* Purpose : Case creation for chargeback 																			 */
/* 	 */
/* 	 */
/* Platforms : Oracle 9i 				 */
/* 	 */
/* Author : RSI 	 			 */
/* 	 */
/* Date : 01-19-2006																	 */
/* REVISIONS: 							 */
/* VERSION DATE WHO PURPOSE 					 */
/* ------- ---------- 	----- 		 -------------------------------------------- 			 */
/* 1.0 		 Initial Revision 			 */
/* 1.1 03/01/2007 Ramu Modified the Cast Title as discussed with Armando			 */
/* 	 */
/*************************************************************************************************/

 p_esn IN varchar2,
 p_caseid OUT varchar2
 )
 IS
 /* This procedure creates a new case for chargeback jobs. Since the cronjobs do not have
 an interface with the CBO, direct database interface is necessiated.
 ASSUMPTION: This procedure calls the available interface for creating case.
 */
 l_queue_name table_queue.title%TYPE;
 l_type table_x_case_conf_hdr.x_case_type%TYPE;
 l_title table_x_case_conf_hdr.x_title%TYPE;
 l_status		VARCHAR2(25);
 l_priority	VARCHAR2(25);
 l_issue		VARCHAR2(25);
 l_source	VARCHAR2(50);
 l_point_contact	VARCHAR2(25);
 l_contact_objid	NUMBER;
 l_user_objid 	NUMBER;

 l_case_id VARCHAR2(50);
 l_case_objid NUMBER;
 /* Error Logging */
 l_error_code NUMBER;
 l_error_msg VARCHAR2(255);

BEGIN

 /* For Chargeback - Set the following */
 l_queue_name := 'Chargeback';
 l_type := 'Chargeback';
	 -- RAMU .. Modified After Discussing with Armando and Chandra on 03/01/2007
 --l_title := 'Chargeback, ESN=' || p_esn; --CR53722
 l_title := 'Chargeback';
 l_status :='Pending';
 l_priority :='Medium';
 l_issue :='Chargeback';
 l_source :='Customer';
 l_point_contact := 'WebCSR';

 select X_PART_INST2CONTACT into l_contact_objid
 from table_part_inst where PART_SERIAL_NO=p_esn;

 --CR53722 - Fix for CLOSE_CASE error when user is not found in table_user
 -- select CREATED_BY2USER into l_user_objid
 -- from table_part_inst where PART_SERIAL_NO=p_esn;
  BEGIN
    SELECT pi.created_by2user
     INTO l_user_objid
    FROM table_part_inst pi,
         table_user tu
    WHERE pi.part_serial_no  = p_esn
      AND pi.created_by2user = tu.objid;
  EXCEPTION
    WHEN OTHERS THEN
       --Default user to SA
       SELECT objid
        INTO l_user_objid
       FROM table_user
       WHERE s_login_name = 'SA';
  END;

/*
 CREATE_CASE_PKG.sp_create_case (
 p_esn,
 p_esn, -- No need for replacement ESN (p_repl_esn),
 l_queue_name,
 l_type,
 l_title,
 null, -- Not used in the create case procedure (p_repl_part),
 null, -- Alternate fields not required (p_FirstName, p_LastName,p_address,p_city, p_state, p_zip ),
 null, --p_LastName IN VARCHAR2,
 null, --p_address IN VARCHAR2,
 null, --p_city IN VARCHAR2,
 null, --p_state IN VARCHAR2,
 null, --p_zip IN VARCHAR2,
 null, --p_tracking IN VARCHAR2,
 l_case_objid,
 l_case_id
 );
*/

   CLARIFY_CASE_PKG.CREATE_CASE (
   l_title, 		-- P_TITLE IN	VARCHAR2,
   l_type, 		-- P_CASE_TYPE IN	VARCHAR2,
   l_status, 		-- P_STATUS		IN	VARCHAR2,
   l_priority, 		-- P_PRIORITY		IN	VARCHAR2,
   l_issue, 		-- P_ISSUE		IN	VARCHAR2,
   l_source,		-- P_SOURCE		IN	VARCHAR2,
   l_point_contact, 	-- P_POINT_CONTACT	IN VARCHAR2,
   NULL, 		-- P_CREATION_TIME IN DATE,
   NULL, 		-- P_TASK_OBJID	IN	NUMBER,
   l_contact_objid, 	-- P_CONTACT_OBJID	IN	NUMBER,
   l_user_objid,	-- P_USER_OBJID	IN	NUMBER,
   p_esn, 		-- P_ESN	 IN	VARCHAR2,
   NULL,		-- P_PHONE_NUM IN 	VARCHAR2,
   NULL, 		-- P_FIRST_NAME IN 	VARCHAR2,
   NULL, 		-- P_LAST_NAME IN 	VARCHAR2,
   NULL, 		-- P_E_MAIL IN VARCHAR2,
   NULL, 		-- P_DELIVERY_TYPE IN VARCHAR2,
   NULL, 		-- P_ADDRESS IN VARCHAR2,
   NULL, 		-- P_CITY IN VARCHAR2,
   NULL, 		-- P_STATE IN VARCHAR2,
   NULL, 		-- P_ZIPCODE IN VARCHAR2,
   NULL, 		-- P_REPL_UNITS	IN	NUMBER,
   NULL,		-- P_FRAUD_OBJID	IN	NUMBER,
   NULL,		-- P_CASE_DETAIL	IN	VARCHAR2,
   NULL, 		-- P_PART_REQUEST	IN	VARCHAR2,
   l_case_id, 	-- P_ID_NUMBER OUT VARCHAR2,
   l_case_objid,	-- P_CASE_OBJID OUT NUMBER,
   l_error_code, 	-- P_ERROR_NO	 OUT	VARCHAR2,
   l_error_msg	-- P_ERROR_STR	 OUT VARCHAR2);
   );

  IF l_error_code != '0' --CR53722
  THEN
     INSERT
     INTO x_program_error_log
       (
         x_source,
         x_error_code,
         x_error_msg,
         x_date,
         x_description,
         x_severity
       )
       VALUES
       (
         'BILLING_CHARGEBACKCASE',
         l_error_code,
         'CREATE CASE - '|| l_error_msg,
         sysdate,
         'ESN ' || p_esn || ' Chargeback Case Creation Error ',
         2 -- MEDIUM
       );
     RETURN; --Exit procedure on error
  END IF;

 p_caseid := l_case_id;

/* CR53722 - Commented out, since case is only for reference purpose and should not be in dispatched in any queue.

CLARIFY_CASE_PKG.LOG_NOTES(
l_case_objid, 	-- P_CASE_OBJID in number,
l_user_objid, 	-- P_USER_OBJID in number,
l_title, 		-- P_NOTES in varchar2,
NULL,		-- P_ACTION_TYPE in varchar2,
l_error_code, 	-- P_ERROR_NO out varchar2,
l_error_msg	-- P_ERROR_STR out varchar2
);


CLARIFY_CASE_PKG.DISPATCH_CASE (
l_case_objid, 	-- p_case_objid IN NUMBER,
l_user_objid, 	-- p_user_objid in number,
l_queue_name,	-- p_queue_name IN VARCHAR2,
l_error_code,	-- p_error_no OUT varchar2,
l_error_msg	-- p_error_str OUT varchar2
);
*/

  --CR53722 - Close the case
  CLARIFY_CASE_PKG.CLOSE_CASE ( p_case_objid => l_case_objid,
                                p_user_objid => l_user_objid,
                                p_source     => l_source, -- Optional
                                p_resolution => NULL,     -- Optional
                                p_status     => 'Closed', -- Optional
                                p_error_no   => l_error_code,
                                p_error_str  => l_error_msg
                              );
  IF l_error_code != '0'
  THEN
     INSERT
     INTO x_program_error_log
       (
         x_source,
         x_error_code,
         x_error_msg,
         x_date,
         x_description,
         x_severity
       )
       VALUES
       (
         'BILLING_CHARGEBACKCASE',
         l_error_code,
         'CLOSE CASE - '|| l_error_msg,
         sysdate,
         'ESN ' || p_esn || ' Chargeback Case Creation Error ',
         2 -- MEDIUM
       );
     RETURN; --Exit procedure on error
  END IF;

EXCEPTION
 WHEN OTHERS THEN
 p_caseid := 0; -- Set the caseid to null. BUG: CreateCase package gives ESN Errors randomly for selected ESNs.
 --- Incase of any Exceptions, Log the data in the Error Log table for debugging purposes.
 l_error_code := SQLCODE;
 l_error_msg := SQLERRM;

 insert into x_program_error_log
 (
 x_source,
 x_error_code,
 x_error_msg,
 x_date,
 x_description,
 x_severity
 )
 values
 (
 'BILLING_CHARGEBACKCASE',
 l_error_code,
 l_error_msg,
 sysdate,
 'ESN ' || p_esn || ' Chargeback Case Creation Error ',
 2 -- MEDIUM
 );
 ------------------------ Exception Logging --------------------------------------------------------------------
 dbms_output.put_line(SQLERRM);
END; -- Procedure SA.BILLING_CHARGEBACKCASE
/