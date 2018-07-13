CREATE OR REPLACE function sa.billing_parseAction
(

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_parseAction									 	 	 	 	 		 */
/*                                                                                          	 */
/* Purpose      :   Parsing function															 */
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
 		 p_string	 	IN varchar2,
		 p_graceperiod  OUT number,
		 p_penalty		OUT number,
		 p_coolingperiod out number,
		 P_DAYS out number
)
RETURN NUMBER
IS
l_string	  varchar2(2000) := p_string;
l_index		  number;
l_loop_flag	  boolean := true;
l_param		  varchar2(50);
l_value       number ;
l_temp_string varchar2(255);
BEGIN
	 while  ( l_loop_flag )
	 loop
	 	  -- Some processing done here
		  l_index := instr(l_string,';');	 -- Get the index of the ';''
		  if ( l_index = 0 and length(l_string) = 0 ) -- We have a parsed all the strings.
		  then
		  	  l_loop_flag := false;   --- Do not parse anymore
	 	  else
		  	  -- We have valid data. Parse the string given.
			  if ( l_index = 0 ) then
			  	 l_index := length(l_string)+1;
				 l_loop_flag := false;
			  end if;

			  l_temp_string := substr(l_string, 1, l_index-1);

			  l_param := substr(l_temp_string, 1, instr(l_temp_string,'=') - 1);
			  l_value := to_number( substr ( l_temp_string, instr(l_temp_string,'=') + 1) );

			  if ( l_param = 'GP' ) then
			  	 p_graceperiod := l_value;
			  elsif ( l_param = 'SCP' ) then
			  	 p_coolingperiod := l_value;
			  elsif ( l_param = 'PENALTY' ) then
			  	 p_penalty := l_value;
			  elsif ( l_param = 'DAYS' ) then
			  	 p_penalty := l_value;
			  end if;

	  	 	  l_string := substr ( l_string, l_index+1 );
		  end if;



	 end loop;

	 return 0;
EXCEPTION
		 WHEN OTHERS THEN
		 	  return -1;
END;
/