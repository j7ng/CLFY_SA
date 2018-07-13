CREATE OR REPLACE PACKAGE BODY sa."OTA_UTIL_PKG" IS

	/************************************************************************************************|
	|    Copyright   Tracfone  Wireless Inc. All rights reserved
	|
	| NAME     :       OTA_UTIL_PKG  package
	| PURPOSE  :
	| FREQUENCY:
	| PLATFORMS:
	|
	| REVISIONS:
	| VERSION  DATE        WHO             PURPOSE
	| -------  ---------- -----            ------------------------------------------------------
	| 1.0      03/11/05   Novak Lalovic    Initial revision
	| 1.1	   06/14/05   Novak Lalovic    Modified function get_next_esn_counter to start generating new
	|                                      numbers from number 6 instead of number 1 (Set MIN_VALUE to 5).
	| 1.2	   07/28/05   Novak Lalovic    Modified function get_next_esn_counter
	|                                      If the value of X_COUNTER column in database table TABLE_X_OTA_TRANSACTION
	|                                      is les then MIN_VALUE (5) then set it to the MIN_VALUE.
	|                                      This functionality was made for the existing database records that were
	|                                      created at the time when the MIN_VALUE was set to 0.
	| 1.3	   06/15/09   Ingrid Canavan   CR10881 Segregate SafeLink ACKs change max value from 255
    | 1.4       09/22/09   VAdapa        CR11766
	|************************************************************************************************/

	--
	-- PUBLIC procedures and functions:
	--

	/******************************************************************
	| Refer to package spec for detailed description of this function |
	******************************************************************/
	FUNCTION get_next_esn_counter(p_esn IN VARCHAR2)
	RETURN NUMBER IS

		-- MAX(objid) returns the most recently inserted record
		-- in table for given ESN
		CURSOR cur_objid IS
		SELECT MAX(objid) objid
		FROM table_x_ota_transaction
		WHERE x_esn = p_esn;

		-- This cursor returns x_counter from
		-- the most recently inserted record for given ESN
		-- the value of this number will be incremented by 1 in this function
		CURSOR cur_x_counter (p_objid table_x_ota_transaction.X_COUNTER%TYPE) IS
		SELECT x_counter
		FROM table_x_ota_transaction
		WHERE objid = p_objid;

		MIN_VALUE constant NUMBER      := 5; -- first 5 numbers are reserved for OTA special case handling
		                                     -- more information can be found in CBO
		MAX_VALUE constant NUMBER      := 235;   -- CR10881 CHANGED FROM 255;

		n_return_value    NUMBER       := 0;

	BEGIN

		FOR cur_objid_rec IN cur_objid LOOP
			FOR cur_x_counter_rec IN cur_x_counter(cur_objid_rec.OBJID) LOOP
				n_return_value := NVL(cur_x_counter_rec.x_counter, MIN_VALUE);
			END LOOP;
		END LOOP;

		-- value range for counter is MIN_VALUE+1 to MAX_VALUE
		-- recycle when the counter reaches maximum
        --CR11766
		--IF n_return_value = MAX_VALUE
        IF (n_return_value >= MAX_VALUE --CR11766
		OR n_return_value < MIN_VALUE) THEN
			n_return_value := MIN_VALUE;
		END IF;
		n_return_value := n_return_value + 1;

		RETURN n_return_value;

	EXCEPTION
		WHEN OTHERS THEN
			err_log (p_action 	=> 'Getting next OTA esn counter number'
				,p_program_name => 'OTA_UTIL_PKG.get_next_esn_counter'
				,p_key		=> p_esn
		  		,p_error_text 	=> SQLERRM);

			RAISE_APPLICATION_ERROR(-20001, 'Failed to generate the next sequence number (x_counter) for ESN ' || p_esn || ' ' || SQLERRM);

	END get_next_esn_counter;


	/*******************************************************************
	| Refer to package spec for detailed description of this procedure |
	*******************************************************************/
	PROCEDURE err_log (p_action		IN error_table.ACTION%TYPE
			  ,p_error_date		IN error_table.ERROR_DATE%TYPE	DEFAULT SYSDATE
			  ,p_key 		IN error_table.KEY%TYPE		DEFAULT NULL
			  ,p_program_name 	IN error_table.PROGRAM_NAME%TYPE
		  	  ,p_error_text 	IN error_table.ERROR_TEXT%TYPE) IS
		PRAGMA AUTONOMOUS_TRANSACTION;

	BEGIN

		INSERT INTO error_table
			(ERROR_TEXT
			,ERROR_DATE
			,ACTION
			,KEY
			,PROGRAM_NAME)
		VALUES
			(p_error_text
			,p_error_date
			,p_action
			,p_key
			,p_program_name);
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			RAISE_APPLICATION_ERROR (-20001, 'Failed to insert record into ERROR_TABLE: '||SQLERRM);

	END err_log;

END ota_util_pkg;
/