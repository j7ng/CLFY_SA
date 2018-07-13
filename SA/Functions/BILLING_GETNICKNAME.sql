CREATE OR REPLACE Function sa.BILLING_GETNICKNAME
  (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_GETNICKNAME												 	 	 	 */
/*                                                                                          	 */
/* Purpose      :   Get nick name																 */
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
  p_esn       x_program_enrolled.x_esn%TYPE )
  RETURN  varchar2 IS
  /*  This function returns the nick name for a given ESN */
  l_nick_name   varchar2(30);
BEGIN
    select b.x_esn_nick_name into l_nick_name
    from   table_part_inst a, table_x_contact_part_inst b
    where  a.objid = b.x_contact_part_inst2part_inst
    and    a.part_serial_no = p_esn;
    RETURN l_nick_name ;
EXCEPTION
   WHEN OTHERS THEN
       return NULL ;       -- No records found, so there is no nick name
END; -- Function BILLING_GETNICKNAME
/