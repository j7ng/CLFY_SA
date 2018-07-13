CREATE OR REPLACE PACKAGE BODY sa.sp_timer
IS
	/* Package variable which stores the last timing made */
	last_timing NUMBER := NULL;

	/* Package variable which stores context of last timing */
	last_context VARCHAR2 (500) := NULL;

	PROCEDURE capture (context_in IN VARCHAR2 := NULL)
	/* Save current time and context to package variables. */
	IS
	BEGIN
		last_timing := DBMS_UTILITY.GET_TIME;
		last_context := context_in;
	END;

	FUNCTION elapsed_message
		(prefix_in IN VARCHAR2 := NULL,
		 reset_in IN VARCHAR2 := 'RESET',
		 reset_context_in IN VARCHAR2 := NULL)
	RETURN VARCHAR2
	/*
	|| Construct message for display of elapsed time. Programmer can
	|| include a prefix to the message and also ask that the last
	|| timing variable be reset/updated. This saves a separate call
	|| to elapsed.
	*/
	IS
		current_timing NUMBER;
		return_value VARCHAR2 (500);
	BEGIN
		IF last_timing IS NULL
		THEN
			/* If there is no last_timing, cannot show anything. */
			return_value := NULL;

		ELSIF last_context IS NOT NULL
		THEN
			/* Construct message with context of last call to elapsed */
			current_timing := elapsed;
			return_value :=
				(prefix_in || ' Elapsed since ' ||
				 last_context || ': ' ||
				 TO_CHAR (ROUND (current_timing/100, 2)) ||
				 ' seconds.');
			last_context := NULL;

		ELSE
			/* Construct message without the context. */
			current_timing := elapsed;
			return_value :=
				(prefix_in || ' Elapsed: ' || TO_CHAR (current_timing));
		END IF;

		IF UPPER (reset_in) = 'RESET'
		THEN
			capture (reset_context_in);
		END IF;

		RETURN return_value;
	END;

	FUNCTION elapsed RETURN NUMBER IS
	BEGIN
		IF last_timing IS NULL
		THEN
			RETURN NULL;
		ELSE
			RETURN DBMS_UTILITY.GET_TIME - last_timing;
		END IF;
	END;

	PROCEDURE show_elapsed
		(prefix_in IN VARCHAR2 := NULL,
		 reset_in IN VARCHAR2 := 'RESET')
	/* Little more than a call to the elapsed_message function! */
	IS
	BEGIN
		DBMS_OUTPUT.PUT_LINE (elapsed_message (prefix_in, reset_in));
	END;

END sp_timer;
/