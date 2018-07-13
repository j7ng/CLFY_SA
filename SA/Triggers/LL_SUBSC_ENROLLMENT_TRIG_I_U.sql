CREATE OR REPLACE TRIGGER sa.LL_SUBSC_ENROLLMENT_TRIG_I_U
AFTER INSERT OR UPDATE
ON sa.LL_SUBSCRIBERS
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
    /******************************************************************************
    * Name: LL_SUBSCRIBER_ENROLLMENT_TRIG
    *
    * History
    * Version             Date             Who            Description
    * ============        ============     ============== ==========================
    * 1.0                  05/26/2017      MDave          Initial Version
     ********************************************************************************/
--
DECLARE
o_response 			 VARCHAR2(2000);
c_deenrollment		 VARCHAR2(30) := 'DEENROLLED';
c_enrollment		 VARCHAR2(30) := 'ENROLLED';
--
BEGIN
  IF INSERTING THEN
  	  --   call proc. to create AQ event in case of new enrollment record
    	sa.enqueue_transactions_pkg.enqueue_lifeline_enrollments(:NEW.CURRENT_ESN,:NEW.CURRENT_MIN,:NEW.ENROLLMENT_STATUS,o_response);
  END IF;

	IF UPDATING THEN
    --   call proc to create AQ event in case of enrollment status update
		IF :NEW.ENROLLMENT_STATUS <> :OLD.ENROLLMENT_STATUS THEN
				sa.enqueue_transactions_pkg.enqueue_lifeline_enrollments(:OLD.CURRENT_ESN,:OLD.CURRENT_MIN,:NEW.ENROLLMENT_STATUS,o_response);
		END IF;
    -- call procedure in case of MIN change under same account for the same LID.
    --	two procedure calls, once with enrollment N another with Y

		IF (:NEW.CURRENT_MIN <> :OLD.CURRENT_MIN) AND (:NEW.LAST_MODIFIED_EVENT = 'LL_TRANSFER')THEN -- assuming existing ( old-min) is with ENROLLED status
		-- for N
		        sa.enqueue_transactions_pkg.enqueue_lifeline_enrollments(:OLD.CURRENT_ESN,:OLD.CURRENT_MIN,c_deenrollment,o_response);
		-- for Y
		    	sa.enqueue_transactions_pkg.enqueue_lifeline_enrollments(:NEW.CURRENT_ESN,:NEW.CURRENT_MIN,c_enrollment,o_response);
		END IF;
	END IF;
EXCEPTION
		WHEN OTHERS THEN
		NULL;
END;  -- end of LL_SUBSC_ENROLLMENT_TRIG_I_U
/