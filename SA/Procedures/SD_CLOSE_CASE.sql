CREATE OR REPLACE PROCEDURE sa."SD_CLOSE_CASE" ( p_case_num in varchar2)  AS
  CURSOR c1 IS
  SELECT objid, id_number
  FROM table_case
  WHERE id_number = p_case_num;

  p_CASE_OBJID   NUMBER ;
  p_user_objid number;
  p_ERROR_NO    VARCHAR2(10);
  p_ERROR_STR   VARCHAR2(2000);
BEGIN
  begin
  	select objid
  	into p_user_objid
  	from table_user
  	where s_login_name = (select user from dual);
  exception
     when others then

  	select objid
  	into p_user_objid
  	from table_user
  	where s_login_name = 'SA';

  end;
   FOR i IN c1 LOOP
        sa.Clarify_Case_Pkg.UPDATE_STATUS(  i.OBJID,
                                            p_user_objid,
                                            'Isolated',
                                            'Try Again',
                                            p_ERROR_NO ,
                                            p_ERROR_STR );
         IF p_ERROR_NO = '0' THEN
             sa.Clarify_Case_Pkg.DISPATCH_CASE(   i.OBJID ,
                                                  p_user_objid,
                                                  'Outbound',
                                                  p_error_no ,
                                                  p_error_str );
         END IF;
   END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM );
END;
/