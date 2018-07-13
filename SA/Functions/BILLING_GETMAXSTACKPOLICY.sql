CREATE OR REPLACE FUNCTION sa."BILLING_GETMAXSTACKPOLICY"
  (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_GETMAXSTACKPOLICY											 	 	 */
/*                                                                                          	 */
/* Purpose      :   Computes the Max. Stacking Policy for a given ESN Enrollment				 */
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

        p_esn IN x_program_enrolled.x_esn%TYPE
  )
  RETURN  VARCHAR2 IS
  l_stack_no                NUMBER;   -- 3 - Full , 2 - Gap, 1 - No, null - not enrolled.
BEGIN

    select max ( decode (b.X_STACK_DUR_ENROLL,'FULL',3,'GAP',2,'NO',1, null) )
    into   l_stack_no
    from   x_program_enrolled a, x_program_parameters b
    where  a.PGM_ENROLL2PGM_PARAMETER = b.objid
    and    a.x_enrollment_status = 'ENROLLED'
    and    ( a.x_wait_exp_date is null or a.x_wait_exp_date < sysdate )
    and    a.x_esn = p_esn;

    if ( l_stack_no = 3 ) then
        RETURN 'FULL' ;
    elsif ( l_stack_no = 2 ) then
        RETURN 'GAP';
    elsif ( l_stack_no = 1 ) then
        RETURN 'NO';
    else
        RETURN 'NONE';
    end if;

EXCEPTION
   WHEN OTHERS THEN
       RETURN 'NONE' ;
END; -- Function BILLING_GETMAXSTACKPOLICY
/