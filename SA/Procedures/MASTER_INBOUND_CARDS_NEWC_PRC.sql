CREATE OR REPLACE PROCEDURE sa.MASTER_INBOUND_CARDS_NEWC_PRC IS
/*****************************************************************************/
/* Copyright (R) 2002 Tracfone Wireless Inc. All rights reserved             */
/*                                                                           */
/* Name         :   MASTER_INBOUND_CARDS_NEWC_PRC                            */
/* Purpose      :   This proceduer calls sp_inbound_inv_cards_prc in the     */
/*                  event of major failure (from calling program), it will   */
/*                  run the procedure three times waiting 15 minutes in      */
/*                  between before restarting execution                      */
/*                                                                           */
/* Parameters   :   NONE                                                     */
/* Platforms    :   Oracle 8.0.6 AND newer versions                          */
/* Author	    :   Miguel Leon                               		     */
/* Date         :   12/04/2002                                               */
/* Revisions    :                                                            */
/* Version  Date      Who      Purpose                                       */
/* -------  --------  -------  --------------------------------------------- */
/*     1.0 12/04/2002 MNazir    Initial revision (Cloned for NEWC)           */
/*****************************************************************************/

c_max_number_of_tries CONSTANT NUMBER := 3;
l_sucessful_completion BOOLEAN := FALSE;
l_trial_counter NUMBER := 0;
l_time_of_last_retry DATE ;
l_time_of_next_retry  DATE;
--l_waiting_time CONSTANT NUMBER  := 15;
l_waiting_time CONSTANT NUMBER  := 2; --testing
l_procedure_name CONSTANT VARCHAR2(80) := '.MASTER_INBOUND_CARDS_NEWC_PRC()';
l_start_date DATE := SYSDATE;

BEGIN

 WHILE (NOT(l_sucessful_completion) AND (l_trial_counter < c_max_number_of_tries)) LOOP
     /* increase the counter of loops */
	 l_trial_counter := l_trial_counter + 1;

	 /** CALL THE INBOUND_INV_NEWC_CARDS PROCEDURE */

     /**test_loop(v_sucessful_completion); */
     INBOUND_CARDS_INV_NEWC_PRC(l_sucessful_completion);
	 /** set the time start of retrial */
	 l_time_of_last_retry := sysdate;

	 /* set the next time the retrial starts */
	 SELECT l_time_of_last_retry +
	        (l_waiting_time*60/86400)
	   INTO l_time_of_next_retry
	   FROM DUAL;

	/** at this point we have set v_sucess_ful_compeltion **/
	IF NOT(l_sucessful_completion) THEN

     /* loop for 30 minutes until pmon does the cleaning job*/
	 WHILE l_time_of_last_retry < l_time_of_next_retry LOOP
         l_time_of_last_retry := sysdate;
     END LOOP;

	END IF;


 END LOOP;



       IF Toss_Util_Pkg.insert_interface_jobs_fun (
            l_procedure_name,
            l_start_date,
            SYSDATE,
            l_trial_counter,
            'SUCCESS',
            l_procedure_name
         ) THEN
         COMMIT;
      END IF;

EXCEPTION

  WHEN OTHERS THEN
            toss_util_pkg.insert_error_tab_proc (
            'Failure retrying ',
            'times tried: ' ||to_char(l_trial_counter),
            l_procedure_name
         );

		 IF Toss_Util_Pkg.insert_interface_jobs_fun (
            l_procedure_name,
            l_start_date,
            SYSDATE,
            l_trial_counter,
            'FAILED',
            l_procedure_name
         ) THEN
         COMMIT;
		 END IF;



END;
/