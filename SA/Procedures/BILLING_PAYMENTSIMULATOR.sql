CREATE OR REPLACE Procedure sa.BILLING_PAYMENTSIMULATOR
   (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_PAYMENTSIMULATOR                   							 		 */
/*                                                                                          	 */
/* Purpose      :   Used for simulating all the failures from the cybersource gateway	     	 */
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
       p_payment_number     IN  x_payment_simulator.x_payment_number%TYPE,
       p_ics_rcode          OUT x_payment_simulator.x_ics_rcode%TYPE,
       p_ics_rflag          OUT x_payment_simulator.x_ics_rflag%TYPE,
       p_ics_rmsg           OUT x_payment_simulator.x_ics_rmsg%TYPE
   )
   IS
--  This procedure is used for simulating all the failures from the cybersource gateway.
--  Given a unique funding source, it will return a pre-defined return code from table.
CURSOR payment_sim_c ( c_payment_number IN NUMBER )
is
    select * from x_payment_simulator
    where    x_payment_number = c_payment_number;

payment_sim_rec payment_sim_c%ROWTYPE;

BEGIN
    OPEN payment_sim_c ( p_payment_number );

    FETCH payment_sim_c into payment_sim_rec;   -- Always fetch the first matched record only
    if ( payment_sim_c%NOTFOUND ) then
        -- No Records found. Use some random values.
        p_ics_rcode := 1;
        p_ics_rflag := 'SOK';
        p_ics_rmsg  := 'Request was processed successfully.';
    else
        p_ics_rcode := payment_sim_rec.x_ics_rcode;
        p_ics_rflag := payment_sim_rec.x_ics_rflag;
        p_ics_rmsg  := payment_sim_rec.x_ics_rmsg;
    end if;

    CLOSE payment_sim_c;


EXCEPTION
    WHEN OTHERS THEN
        p_ics_rcode := 1;
        p_ics_rflag := 'SOK';
        p_ics_rmsg  := 'Request was processed successfully.';
END; -- Procedure BILLING_PAYMENTSIMULATOR
/