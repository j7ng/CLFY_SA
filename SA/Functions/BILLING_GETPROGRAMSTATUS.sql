CREATE OR REPLACE FUNCTION sa."BILLING_GETPROGRAMSTATUS"
  (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_GETPROGRAMSTATUS										 	 	 	 */
/*                                                                                          	 */
/* Purpose      :   Returns the current status of the program given any purchase ID.			 */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   01-19-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
  p_prog_purch_objid      x_program_purch_hdr.objid%TYPE )
  RETURN  VARCHAR2 IS
  /*
        This function returns the current status of the program given any purchase ID.
        This will be used for reports
  */
  l_enroll_status     x_program_enrolled.x_enrollment_status%TYPE;
  p_return_code number(10);
  p_return_message varchar2(300);
BEGIN
    select c.x_enrollment_status
    into   l_enroll_status
    from   x_program_purch_hdr a, x_program_purch_dtl b, x_program_enrolled c
    where  a.objid = b.PGM_PURCH_DTL2PROG_HDR
      and  b.PGM_PURCH_DTL2PGM_ENROLLED = c.objid
      and  b.PGM_PURCH_DTL2PENAL_PEND is null
      and  c.x_is_grp_primary = 1
      and  a.objid = p_prog_purch_objid;


    RETURN l_enroll_status ;

   EXCEPTION
   WHEN OTHERS
   THEN
      p_return_code := SQLCODE;
      p_return_message := SQLERRM;
      /*
      ------------------------ Exception Logging --------------------------------------------------------------------
      ---  Incase of any Exceptions, Log the data in the Error Log table for debugging purposes.
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
            'BILLING_GETPROGRAMSTATUS',
            p_return_code,
            to_char(p_return_message),
            sysdate,
            to_char(p_prog_purch_objid) ,
            3 -- HIGH
      );
      ------------------------ Exception Logging --------------------------------------------------------------------
      */
END; -- Function BILLING_GETPROGRAMSTATUS
/