CREATE OR REPLACE FUNCTION sa."BILLING_GETREDEEMPARTOBJID"
  (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_GETREDEEMPARTOBJID										 	 	 	 */
/*                                                                                          	 */
/* Purpose      :   Returns part-number associated to Redemption code							 */
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
   p_red_code        VARCHAR2
  )
  RETURN  NUMBER IS
--
-- Given a Redemption code, return the partnum associated with it..
--
    l_part_num  NUMBER;
BEGIN

     /* Get the part number associated with the given redemption code */
     SELECT pn.objid
     INTO   l_part_num
     FROM   table_part_inst pi,
            table_mod_level ml,
            table_part_num pn
     WHERE
            pi.x_red_code = p_red_code
      AND   pi.n_part_inst2part_mod = ml.objid
      AND   pi.x_domain = 'REDEMPTION CARDS'
      AND   ml.part_info2part_num = pn.objid
      AND   pn.domain = 'REDEMPTION CARDS'
      AND   pn.active = 'Active';

    RETURN l_part_num ;
EXCEPTION
   WHEN OTHERS THEN
       RETURN null ;
END; -- Function BILLING_GETREDEEMPARTOBJID
/