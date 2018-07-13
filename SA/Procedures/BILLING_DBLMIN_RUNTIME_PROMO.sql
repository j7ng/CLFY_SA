CREATE OR REPLACE PROCEDURE sa."BILLING_DBLMIN_RUNTIME_PROMO" (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_DBLMIN_RUNTIME_PROMO                       							 */
/*                                                                                          	 */
/* Purpose      :   Delivers Double Minute Runtime Promo						 				 */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   04-17-2007																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*  1.1     04/24/2007  Ramu         Optimized the Code 									     */
/*  1.2     05/07/2007  Ramu         Changed the Column Name for table_x_pending_redemption  	 */
/*                                   This is changed as per SP_RUNTIME_PROMO Proc				 */
/*  1.4     07/29/2011  Kacosta    CR16862 Extra double Minute Promo units for Value plan customers                                  															 */
/*  1.5     08/08/2011  Kacosta    CR16862 Extra double Minute Promo units for Value plan customers                                  															 */
/*                                 Added a commit */
/*************************************************************************************************/

   p_esn                 IN       VARCHAR2, -- ESN
   p_objid     			 IN       NUMBER, -- Call Trans objid
   op_units				 OUT	  NUMBER, -- Runtime Units
   op_msg				 OUT      VARCHAR2, -- Output Message
   op_status             OUT      VARCHAR2 -- Output Status S = Success, F = Failed
   						 		  		   -- N = Not Eligible
)
IS
l_eligible 				 NUMBER :=0 ;
l_promo_rec		   		 table_x_promotion%ROWTYPE;
l_site_part_objid   	 table_site_part.objid%TYPE;
l_total_units			 NUMBER := 0;
BEGIN

   -- Call to check if ESN is Eligible for Double Minute Runtime Promo
   l_eligible := BILLING_DBLMIN_RNTIME_ELIGIBLE (p_esn);

   IF l_eligible = 0
   THEN -- ESN IS NOT ELIGIBLE
    -- Return P_Units as 0, P_status='N'
	   op_units := 0;
       op_status := 'N';
       op_msg := 'Not Eligible for Double Minute Runtime Promo ' || p_esn;

	ELSE -- ESN IS ELIGIBLE
	BEGIN
		SELECT objid
     	 		INTO l_site_part_objid
     			FROM table_site_part
    			WHERE part_status||'' = 'Active'
      			AND x_service_id = p_esn;
		EXCEPTION WHEN OTHERS THEN
				op_msg := 'Error finding Site part objid for esn ' || p_esn;
	END;

	IF l_site_part_objid IS NULL -- SITE PART OBJID Not Found
      	   THEN
           op_units := 0;
       	   op_status := 'N'; -- Sets 'N' as per SP_RUNTIME_PROMO Package
           op_msg := 'Failed to find objid for esn ' || p_esn;
    ELSE -- SITE PART OBJID Found

	--Find the list of Pending codes in table_x_pending_redemption which are from
	-- BPREdemption. use query 1. If no records found return p_units = 0 and p_status+N
   	   op_units := 0;
       op_status := 'N';

	   	-- CR16862 Start KACOSTA 7/29/2011
      --FOR idx IN  (
      --
			--SELECT pr.*
  	  -- 		  FROM table_x_pending_redemption pend,
      -- 		  	   table_x_promotion pr,
      -- 		  	   table_site_part sp
 			--	   WHERE 1=1
 			--	   AND sp.objid = pend.x_pend_red2site_part
   		--	  	   AND pend.pend_red2x_promotion = pr.objid
			--   	   AND pr.objid in (SELECT c.OBJID
      --                 FROM x_program_parameters b, table_x_promotion c, table_bus_org d
      --                 WHERE  1=1
			--		     AND (c.OBJID=b.X_PROMO_INCL_MIN_AT
			--		   	   OR c.OBJID=b.X_PROMO_INCL_GRPMIN_AT
			--		       OR c.OBJID=b.X_PROMO_INCR_MIN_AT
			--			   OR c.OBJID=b.X_PROMO_INCR_GRPMIN_AT
			--		   	   )
			--		    AND d.OBJID = b.PROG_PARAM2BUS_ORG
			--			AND upper(d.org_id)||'' = 'TRACFONE'
			--		   )
   		--	  	   AND pr.x_promo_type||'' = 'BPRedemption'
			--	   AND pr.x_revenue_type||'' = 'PAID'
			--       AND pr.x_units > 0
			--       AND sp.x_service_id = p_esn
	  	--	       ORDER BY pr.x_promo_code
      --          )
   		--LOOP -- Associated Runtime Promo

      FOR idx IN (SELECT x_units
                    FROM (SELECT DISTINCT txp.x_units
                                         ,NVL(prd.process_date
                                             ,TO_DATE('1/1/1753'
                                                     ,'MM/DD/YYYY')) process_date
                            FROM table_x_pending_redemption xpr
                            JOIN table_x_promotion txp
                              ON xpr.pend_red2x_promotion = txp.objid
                            LEFT OUTER JOIN x_pending_redemption_det prd
                              ON xpr.objid = prd.pend_red_det2pend_red
                             AND prd.process_flag = 'I'
                           WHERE xpr.x_pend_red2site_part = l_site_part_objid
                             AND txp.x_promo_type = 'BPRedemption'
                             AND txp.x_revenue_type = 'PAID'
                             AND txp.x_units > 0
                             AND EXISTS (SELECT 1
                                    FROM x_program_parameters xpp
                                    JOIN table_bus_org tbo
                                      ON xpp.prog_param2bus_org = tbo.objid
                                   WHERE (xpp.x_promo_incl_min_at = txp.objid OR xpp.x_promo_incl_grpmin_at = txp.objid OR xpp.x_promo_incr_min_at = txp.objid OR xpp.x_promo_incr_grpmin_at = txp.objid)
                                     AND tbo.org_id = 'TRACFONE')
                           ORDER BY NVL(prd.process_date
                                       ,TO_DATE('1/1/1753'
                                               ,'MM/DD/YYYY')) DESC
                                   ,txp.x_units DESC)
                   WHERE ROWNUM <= 1) LOOP
      -- CR16862 End KACOSTA 7/29/2011
			op_status := 'S';
			--DBMS_OUTPUT.PUT_LINE('Inside loop - x_units: '||idx.X_UNITS);
			--Check for Associated Runtime Promo
			BEGIN
			SELECT A.* INTO l_promo_rec
			FROM TABLE_X_PROMOTION A
			WHERE A.X_PROMO_CODE LIKE 'RTDBL%' AND A.X_PROMO_CODE != 'RTDBL000'
				  --AND UPPER(A.X_SQL_STATEMENT) NOT LIKE '% :PART_NUM%' -- WE DO NOT HAVE PART_NUM, SO WE CAN NOT USE THIS PROMO. ALSO, IT IS NOT DOUBLE MIN PROMO.
				  AND UPPER(A.X_SQL_STATEMENT) NOT LIKE '% :ACCESS_DAYS%' -- IT IS NOT A DOUBLE MIN PROMO. JUST IN CASE WE ARE ELIMINATING THIS.
				  AND UPPER(A.X_SQL_STATEMENT) NOT LIKE '% :CARD_TYPE%' -- WE DO NOT HAVE CARD_TYPE VARIABLE, SO WE CAN NOT USE THIS. ALSO IT IS NOT DOUBLE MIN PROMO
				  AND UPPER(A.X_SQL_STATEMENT) NOT LIKE '% :PIN_PROMOCODE%' -- WE DO NOT HAVE CARD_TYPE VARIABLE, SO WE CAN NOT USE THIS. ALSO IT IS NOT DOUBLE MIN PROMO
				  AND UPPER(A.X_SQL_STATEMENT) NOT LIKE '% :SOURCE%' -- WE DO NOT HAVE CARD_TYPE VARIABLE, SO WE CAN NOT USE THIS. ALSO IT IS NOT DOUBLE MIN PROMO
				  AND A.X_GROUP_NAME_FILTER||''='DBLMIN_GRP'
				  AND A.X_UNITS = idx.X_UNITS
				  AND ROWNUM <2;

			--DBMS_OUTPUT.PUT_LINE('Associated Runtime Promo: '||l_promo_rec.x_promo_code);

			-- Insert record into table_x_pending_redemption for Runtime Promo Delivery

			INSERT INTO table_x_pending_redemption
                              (OBJID,
                               PEND_RED2X_PROMOTION, X_PEND_RED2SITE_PART,
                               X_PEND_TYPE
                               , REDEEM_IN2CALL_TRANS -- Column changed from CR5150
                              )
                       VALUES (
                               seq ('x_pending_redemption'),
                               l_promo_rec.objid, l_site_part_objid,
                               'Runtime'
                               , p_objid
                              );

        	--- Insert Record into table_x_promo_hist

       		INSERT INTO table_x_promo_hist
                     	(objid,
                      	promo_hist2x_promotion)
              		  VALUES (seq ('x_promo_hist'),
                      		 l_promo_rec.objid) ;
			-- Add total units qualified for runtime promo
			l_total_units := l_total_units + l_promo_rec.x_units;
			op_status := 'S';
			EXCEPTION
				 WHEN NO_DATA_FOUND THEN
				 NULL;
			END;
        END LOOP; -- Associated Runtime Promo

			--Check if Records where not found
			IF op_status = 'N' THEN -- No Records Found
		   	   op_units := 0;
       	   	   op_status := 'N';
       	   	   op_msg := 'No Pending Redemption codes found for ' || p_esn;
			ELSE
				op_units := l_total_units; -- SET Total units as units Out
        -- CR16862 Start KACOSTA 8/08/2011
        COMMIT;
        -- CR16862 End KACOSTA 8/08/2011
			END IF; -- NO Records Found
   		END IF; -- SITE PART OF OBJID Found
   END IF; -- ESN IS ELIGIBLE

EXCEPTION
   WHEN OTHERS
   THEN
   	  Rollback; -- Rollback when Exception occurres
   	  op_units := 0;
      op_status := 'F';
      op_msg :=    SQLCODE
                    || SUBSTR (SQLERRM, 1, 100);
END BILLING_DBLMIN_RUNTIME_PROMO; -- Procedure BILLING_DBLMIN_RUNTIME_PROMO
/