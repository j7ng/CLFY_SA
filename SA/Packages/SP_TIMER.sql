CREATE OR REPLACE PACKAGE sa.sp_timer
IS
	/* Capture current value in DBMS_UTILITY.GET_TIME */
	PROCEDURE capture (context_in IN VARCHAR2 := NULL);

	/* Calculate and return amount of time elapsed since call to capture
*/
	FUNCTION elapsed RETURN NUMBER;

	/* Construct message showing time elapsed since call to capture */
	FUNCTION elapsed_message
		(prefix_in IN VARCHAR2 := NULL,
		 reset_in IN VARCHAR2 := 'RESET',
		 reset_context_in IN VARCHAR2 := NULL)
	RETURN VARCHAR2;

	/* Display message with DBMS_OUTPUT.PUT_LINE of elapsed time */
	PROCEDURE show_elapsed
		(prefix_in IN VARCHAR2 := NULL,
		 reset_in IN VARCHAR2 := 'RESET');

END sp_timer;
/