CREATE OR REPLACE PACKAGE sa."OTA_EXTPROC_PKG" IS

/************************************************************************************************
|    Copyright   Tracfone  Wireless Inc. All rights reserved
|
| NAME     :     OTA_EXTPROC_PKG
| PURPOSE  :     Calls external procedures written in "C" language, so called DLLs
| FREQUENCY:
| PLATFORMS:     Oracle 8.1.7 and above
|
| REVISIONS:
| VERSION  DATE        WHO              PURPOSE
| -------  ---------- -----             ------------------------------------------------------
| 1.0      12/01/04   Novak Lalovic     Initial creation
| 1.1      06/27/05   Shaowei Luo       Removed input parameter p_technology_in from parse_acknowledgment procedure

| REVISIONS IN NEW_PLSQL
| VERSION  DATE        WHO              PURPOSE
| -------  ---------- -----             ------------------------------------------------------
| 1.0      08/27/09    NGuada CR11670   BRAND_SEP Separate the Brand and Source System TO BE RELEASED WITH OR AFTER HANDSETS
| 1.1      09/02/09                    Latest
| 1.3     02/17/10    NGuada          CR12569


************************************************************************************************/
	/* generic ref cursor variable */
	TYPE ref_cur_type IS REF CURSOR;

	/* Command structure (IN parameter)
	|  This record layout MUST match the structure of PL_COMMAND_STRUCTURE SQL type in database
	|  the only deviation is order_by field which doesn't exist in the SQL type but it does here in this recordtype.
	|  We use order_by field to put our PSMS commands in the proper order and send them to the DLL (C program)
	|  For example: redemption command always goes as the last one in the list of commands.
	|  In that case CBO will send us a sql string made of at least 2 sql statements
	|  (joined with UNION statement into one SQL)
	|  and we will order that sql statement using its order_by column (it's always the first column in the query).
	|  In our case the value of order_by column in the sql statement for
	|  the redemption command will be the highest one in the UNION query (see below value 222).
	|  Example: SELECT 222,'63',10, 12, 20, 2006, 0, 0, 0, 0, 0, 0, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' from dual
	| 	    UNION
	| 	    SELECT 111,'66',0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' from dual
	| 	    ORDER BY 1
	|           Redemption command is the first one ('63') in the SQL statement but when sql gets executed
	| 	    and ordered by its first column that record will show up as the last one in the result set
	|  Note: the reason why we use select statement to pass data between CBO and PL/SQL is
	|        because we are unable to do it directly through the Oracle TYPE.
	| 	 We were able however, to map Oracle SQL type to the appropriate Java data type on CBO side
	| 	 and we passed the data ditectly from Java to PL/SQL and from PL/SQL to Java via Oracle Object(Type)
	| 	 but we did it in the new version of the "Web Logic" software.
	| 	 Unfortunatelly the old one (used in our system)
	| 	 doesn't have that advanced feature and we came up with this method.
	*/

	TYPE command_rec_type IS RECORD
				    ( order_by		NUMBER
				    , command		NUMBER
				    , first_double      NUMBER
				    , second_double     NUMBER
				    , third_double      NUMBER
				    , fourth_double     NUMBER
				    , fifth_double      NUMBER
				    , sixth_double      NUMBER
				    , serventh_double   NUMBER
				    , eight_double      NUMBER
				    , ninth_double      NUMBER
				    , tenth_double      NUMBER
				    , first_string      VARCHAR2(200)
				    , second_string     VARCHAR2(200)
				    , third_string      VARCHAR2(200)
				    , fourth_string     VARCHAR2(200)
				    , fifth_string      VARCHAR2(200)
				    , sixth_string      VARCHAR2(200)
				    , seventh_string    VARCHAR2(200)
				    , eighth_string     VARCHAR2(200)
				    , ninth_string      VARCHAR2(200)
				    , tenth_string      VARCHAR2(200));

	/* Inquiry structure (IN parameter) */
	-- this record layout MUST match the structure of PL_INQUIRY_STRUCTURE SQL type in database
	TYPE inquiry_rec_type IS RECORD
				    ( first_string	VARCHAR2(100)
				    , second_string	VARCHAR2(100)
				    , third_string	VARCHAR2(100)
				    , fourth_string	VARCHAR2(100)
				    , fifth_string	VARCHAR2(100)
				    , sixth_string	VARCHAR2(100)
				    , seventh_string	VARCHAR2(100)
				    , eighth_string	VARCHAR2(100)
				    , ninth_string	VARCHAR2(100)
				    , tenth_string	VARCHAR2(100));

	/* Command codes structure (OUT parameter) */
	-- this record layout MUST match the structure of PL_GENCODE_STRUCTURE SQL type in database
	TYPE cmdcode_rec_type IS RECORD (command NUMBER
					,gencode VARCHAR2(200));

	/* Command structure (OUT parameter) */
	-- this record layout MUST match the structure of PL_REDEMPTION_STRUCTURE SQL type in database
	TYPE redemption_rec_type IS RECORD
				    ( first_string         VARCHAR2(100)
				     ,first_denomination   VARCHAR2(100)
				     ,first_promo_code     VARCHAR2(100)
				     ,second_string        VARCHAR2(100)
				     ,second_denomination  VARCHAR2(100)
				     ,second_promo_code    VARCHAR2(100)
				     ,third_string         VARCHAR2(100)
				     ,third_denomination   VARCHAR2(100)
				     ,third_promo_code     VARCHAR2(100));

	/* Public procedures and functions */
	PROCEDURE send_marketing_psms
				    ( p_esn_in 			IN  	VARCHAR2
				    , p_sequence_in		IN	NUMBER
				    , p_technology_in		IN	NUMBER	DEFAULT 3
				    , p_transid_in		IN	NUMBER
				    , p_message_in		IN	VARCHAR2
				    , p_int_dll_to_use		IN	NUMBER
				    , p_error_number_out	OUT	NUMBER
				    , p_message_out		OUT	VARCHAR2);

	/***** Card redemption stuff *****/
	PROCEDURE send_redemption_psms
				   ( p_esn_in 			IN  	VARCHAR2
				   , p_sequence_in		IN	NUMBER
				   , p_technology_in		IN	NUMBER	DEFAULT 3
				   , p_transid_in		IN	NUMBER
				   , p_command_struct_sql_in	IN	VARCHAR2
				   , p_inquiry_struct_sql_in	IN	VARCHAR2
				   , p_int_dll_to_use		IN	NUMBER
				   , p_cmdcode_rs_out		OUT	Ota_extproc_pkg.ref_cur_type
				   , p_message_out		OUT	VARCHAR2
				   , p_error_number_out		OUT	NUMBER);

	PROCEDURE send_redemption_psms_obj
				  ( p_esn_in 			IN  	VARCHAR2
				  , p_sequence_in		IN	NUMBER
				  , p_technology_in		IN	NUMBER	DEFAULT 3
				  , p_transid_in		IN	NUMBER
				  , p_command_struct_array_in	IN	PL_COMMAND_STRUCT_ARRAY
				  , p_inquiry_structure_in	IN	PL_INQUIRY_STRUCTURE
				  , p_int_dll_to_use		IN	NUMBER
				  , p_error_number_out		OUT	NUMBER
				  , p_gencode_out		OUT	VARCHAR2
				  , p_message_out		OUT	VARCHAR2);

	/***** Acknowledgment stuff *****/

	-- PROCEDURE OVERLOADED SHOULD NOT BE MODIFIED
	PROCEDURE parse_acknowledgment
				  ( p_message_in		IN	VARCHAR2
				  , p_min_in 			IN  	VARCHAR2
				  -- , p_technology_in		IN	NUMBER 	DEFAULT 3 06/27/05 not used CR4169
				  , p_esn_out			OUT	VARCHAR2
				  , p_sequence_out		OUT	NUMBER
				  , p_transid_out		OUT	NUMBER
				  , p_ack_code_out		OUT	NUMBER
				  , p_inquiry_rs_out		OUT	Ota_extproc_pkg.ref_cur_type
				  , p_redemption_rs_out		OUT	Ota_extproc_pkg.ref_cur_type
				  , p_error_number_out		OUT	NUMBER
				  , p_x_dll_out			OUT	NUMBER
				  , p_restricted_use		OUT	NUMBER);

	-- PROCEDURE OVERLOADED SHOULD NOT BE MODIFIED
	PROCEDURE parse_acknowledgment_obj
				  ( p_message_in		IN	VARCHAR2
				  , p_min_in 			IN  	VARCHAR2
				  , p_technology_in		IN	NUMBER 	DEFAULT 3
				  , p_esn_out			OUT	VARCHAR2
				  , p_sequence_out		OUT	NUMBER
				  , p_transid_out		OUT	NUMBER
				  , p_ack_code_out		OUT	NUMBER
				  , p_inquiry_obj_out		OUT	PL_INQUIRACK_ARRAY
				  , p_redemption_obj_out	OUT	PL_REDEMPTION_STRUCTURE
				  , p_error_number_out		OUT	NUMBER
				  , p_x_dll_out			OUT	NUMBER
				  , p_restricted_use		OUT	NUMBER);

	PROCEDURE parse_acknowledgment
				  ( p_message_in		IN	VARCHAR2
				  , p_min_in 			IN  	VARCHAR2
				  -- , p_technology_in		IN	NUMBER 	DEFAULT 3 06/27/05 not used CR4169
				  , p_esn_out			OUT	VARCHAR2
				  , p_sequence_out		OUT	NUMBER
				  , p_transid_out		OUT	NUMBER
				  , p_ack_code_out		OUT	NUMBER
				  , p_inquiry_rs_out		OUT	Ota_extproc_pkg.ref_cur_type
				  , p_redemption_rs_out		OUT	Ota_extproc_pkg.ref_cur_type
				  , p_error_number_out		OUT	NUMBER
				  , p_x_dll_out			OUT	NUMBER
				  , p_brand_name		OUT	VARCHAR2);

	PROCEDURE parse_acknowledgment_obj
				  ( p_message_in		IN	VARCHAR2
				  , p_min_in 			IN  	VARCHAR2
				  , p_technology_in		IN	NUMBER 	DEFAULT 3
				  , p_esn_out			OUT	VARCHAR2
				  , p_sequence_out		OUT	NUMBER
				  , p_transid_out		OUT	NUMBER
				  , p_ack_code_out		OUT	NUMBER
				  , p_inquiry_obj_out		OUT	PL_INQUIRACK_ARRAY
				  , p_redemption_obj_out	OUT	PL_REDEMPTION_STRUCTURE
				  , p_error_number_out		OUT	NUMBER
				  , p_x_dll_out			OUT	NUMBER
				  , p_brand_name		OUT	VARCHAR2);

	/****** Command stuff ******/
	PROCEDURE send_command
				 ( p_esn_in 			IN  	VARCHAR2
			     	 , p_sequence_in		IN	NUMBER
			     	 , p_technology_in		IN	NUMBER	DEFAULT 3
			     	 , p_transid_in			IN	NUMBER
			     	 , p_command_struct_sql_in	IN	VARCHAR2
			     	 , p_string_value_in		IN	NUMBER
			     	 , p_int_dll_to_use		IN	NUMBER
			     	 , p_error_number_out		OUT	NUMBER
      			     	 , p_cmdcode_rs_out		OUT 	Ota_extproc_pkg.ref_cur_type
			     	 , p_message_out 		OUT 	VARCHAR2);

	PROCEDURE send_command_obj
				 ( p_esn_in 		IN  	VARCHAR2
			     	 , p_sequence_in	IN	NUMBER
			     	 , p_technology_in	IN	NUMBER	DEFAULT 3
			     	 , p_transid_in		IN	NUMBER
			     	 , p_command_obj_in	IN	PL_COMMAND_STRUCT_ARRAY
			     	 , p_string_value_in	IN	NUMBER
			     	 , p_int_dll_to_use	IN	NUMBER
			     	 , p_error_number_out	OUT	NUMBER
      			     	 , p_cmdcode_obj_out	OUT 	PL_COMCODE_ARRAY
			     	 , p_psmscode_obj_out 	OUT 	PL_PSMS_CODE_STRUCTURE);

	FUNCTION get_last_sent_ack_func( p_esn_in 		IN 	VARCHAR2
				       , p_technology_in	IN	NUMBER	DEFAULT 3
				       , p_sequence_in		IN	NUMBER
				       , p_send_last_in		IN	VARCHAR2 DEFAULT 'Y'
				       , p_int_dll_to_use	IN	NUMBER)
	RETURN VARCHAR2;

END;
/