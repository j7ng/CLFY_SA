CREATE OR REPLACE FUNCTION sa.get_code_fun(
   ip_program_name IN VARCHAR2,
   ip_clfy_code IN VARCHAR2,
   ip_language IN VARCHAR2
)
   RETURN VARCHAR2
AS
/********************************************************************************************************************/
   /* Copyright   2008 Tracfone  Wireless Inc. All rights reserved                                                                        */
   /*                                                                                                                                                                        */
   /* NAME:               GET_CODE_FUN                                                                                                               */
   /* PURPOSE:      Pass in code get message  */
   /* FREQUENCY:                                                                                                                                              */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                                                                    */
   /*                                                                                                                                                                        */
   /* REVISIONS:                                                                                                                                                   */
   /* VERSION  DATE        WHO          PURPOSE                                                                                             */
   /* -------  ---------- -----  --------------------------------------------                                                                               */
   /*  1.0     01/10/08                 IC               Initial  Revision                                                                                  */
   /*******************************************************************************/

   l_return_text VARCHAR2 (300) ;
BEGIN

Select DECODE(IP_LANGUAGE,'ENGLISH',CLFY_MESSAGE,CLFY_SP_MESSAGE)
INTO l_return_text
From X_CLARIFY_CODES
Where program_name = ip_program_name
        and clfy_code=ip_clfy_code
        and active='Y';
   RETURN l_return_text;

EXCEPTION
   WHEN OTHERS THEN
      l_return_text :=ip_clfy_code ||  ' Not Available' ;
      RETURN l_return_text;
END;
/