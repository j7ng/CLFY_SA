CREATE OR REPLACE PROCEDURE sa."GET_ACH_FLAG_CONFIG"
							(
								i_brand			IN	TABLE_ACH_FLAG_CONFIG.BRAND%TYPE,
								i_source		IN	TABLE_ACH_FLAG_CONFIG.X_SOURCE_SYSTEM%TYPE,
								i_flow			IN	TABLE_ACH_FLAG_CONFIG.TXN_FLOW%TYPE,
								o_flag			OUT	TABLE_ACH_FLAG_CONFIG.IS_FLAG_ON%TYPE,
								o_error_code	OUT	VARCHAR2,
								o_error_message	OUT	VARCHAR2
							)
AS
/*************************************************************************************************************************************
  * $Revision: 1.4 $
  * $Author: mshah $
  * $Date: 2016/11/01 14:07:17 $
  * $Log: get_ach_flag_config.sql,v $
  * Revision 1.4  2016/11/01 14:07:17  mshah
  * CR41563
  *
  * Revision 1.3  2016/10/31 17:34:00  mshah
  * CR41563
  *
  * Revision 1.2  2016/10/20 18:46:08  mshah
  * CR41563 - Post code review
  *
  *************************************************************************************************************************************/
 all_flag VARCHAR2(10);
BEGIN

DBMS_OUTPUT.PUT_LINE('Procedure Starts: get_ach_flag_config');
DBMS_OUTPUT.PUT_LINE('i_brand '||i_brand);
DBMS_OUTPUT.PUT_LINE('i_source '||i_source);
DBMS_OUTPUT.PUT_LINE('i_flow '||i_flow);

 IF	i_brand IS NULL
 THEN
  o_error_code := '99';
  o_error_message := 'Please provide brand information.';
  RETURN;
 ELSIF	i_source IS NULL
 THEN
  o_error_code := '99';
  o_error_message := 'Please provide source information.';
  RETURN;
 END IF;

BEGIN --{
 SELECT UPPER(IS_FLAG_ON)
 INTO   all_flag
 FROM   TABLE_ACH_FLAG_CONFIG
 WHERE  UPPER(BRAND)               = UPPER(i_brand)
 AND		UPPER(X_SOURCE_SYSTEM)     = UPPER(i_source)
 AND    UPPER(TXN_FLOW)            = 'ALL';
EXCEPTION
WHEN OTHERS THEN
 all_flag := NULL;
END; --}

IF all_flag = 'FALSE'
THEN --{
 o_flag          := 'FALSE';
 o_error_code    := '0'; -- Pass 0 to not the log the record in error table
 o_error_message := 'Success';
ELSE
 BEGIN --{
  SELECT UPPER(IS_FLAG_ON)
  INTO	 o_flag
  FROM	 TABLE_ACH_FLAG_CONFIG
  WHERE	 UPPER(BRAND) 			       = UPPER(i_brand)
  AND		 UPPER(X_SOURCE_SYSTEM) = UPPER(i_source)
  AND		 UPPER(TXN_FLOW) 		     = UPPER(i_flow);
 EXCEPTION
  WHEN OTHERS THEN
  o_flag          := 'FALSE';
  o_error_code    := '0'; -- Pass 0 to not the log the record in error table
  o_error_message := 'Success';
 END; --}
END IF; --}
o_error_code := '0';
o_error_message := 'Success';
DBMS_OUTPUT.PUT_LINE('o_flag: '||o_flag);
DBMS_OUTPUT.PUT_LINE('Procedure Ends: get_ach_flag_config');

EXCEPTION
WHEN OTHERS THEN
 o_flag := 'FALSE';
 o_error_code := '0'; -- Pass 0 to not the log the record in error table
 o_error_message := 'Success';
END;
/