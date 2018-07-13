CREATE OR REPLACE FUNCTION sa."BILLING_DBLMIN_RNTIME_ELIGIBLE"
  (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_DBLMIN_RNTIME_ELIGIBLE												 	 	 	 */
/*                                                                                          	 */
/* Purpose      :   Returs if ESN is eligible for Double Minute Runtime Promo																 */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   Ruchi                                                            	  			 */
/*                                                                                          	 */
/* Date         :   04-05-2007																 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*  1.1     04/24/2007  Ramu         Optimized the Queries 									     */
/*                                                                                          	 */
/*************************************************************************************************/
  p_esn VARCHAR2
  )
  RETURN  NUMBER IS
   /*PRAGMA autonomous_transaction; */
  /*  This function returns the if ESN is Eligible for Double Minute Runitme Promo*/
  l_count NUMBER := 0;

BEGIN


	-- If ESN is Null Return Esn not Eligible
	IF p_esn IS NULL THEN
	   RETURN l_count;	 	 -- ESN Not Found
	END IF;

	IF get_restricted_use( p_esn ) = 0 THEN
	   SELECT COUNT (1)
	   	INTO l_count
  	   	FROM table_site_part sp,
	    ( SELECT pi2.part_serial_no
            FROM table_x_promotion_group pg,
                 table_part_inst pi2,
                 table_x_group2esn ge
           WHERE 1=1
             AND pg.group_name = 'DBLMIN_GRP'
             AND ge.groupesn2x_promo_group = pg.objid+0
             AND ge.groupesn2part_inst = pi2.objid+0
             AND pi2.part_serial_no = p_esn
             AND SYSDATE BETWEEN ge.x_start_date AND ge.x_end_date
             AND pi2.x_domain||'' = 'PHONES'
         ) tab1
   		     WHERE 1=1
   		     AND tab1.part_serial_no = sp.x_service_id
   		     AND sp.part_status ||'' IN ('Active', 'Obsolete');

	ELSE
		RETURN l_count; -- Return Esn not Eligible as Incorrect PartNumber for Promo

	END IF;



	RETURN l_count ;

EXCEPTION
   WHEN OTHERS THEN
       RETURN 0 ;       -- Returns FALSE
END;
 -- BILLING_DBLMIN_RNTIME_ELIGIBLE
/