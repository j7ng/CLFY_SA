CREATE OR REPLACE PROCEDURE sa."GETFORMATS_PRC" (
-- *********************************************************
-- Service  getformats_Prc
-- Object type:  Procedure
-- Desc: Return all values of the input parameter
--       format type from table X_CLARIFY_FORMATS
-- Input parameter:
-- Name IP_FORMAT_TYPE Varchar2(30) Values (STREET_TYPE/DIRECTION)
-- Output:
-- Name  OP_CLARIFY_FORMATS SYS_REFCURSOR Components Value
-- How to call:   Getformats_prc ( ip_format_type )
-- *********************************************************
IP_FORMAT_TYPE        in varchar2, -- STREET_TYPE or DIRECTION
OP_CLARIFY_FORMATS    out sys_refcursor,
op_result             out number,
op_msg                out varchar2 )
as

begin
  op_result := '0';
  op_msg := NULL;

  open OP_CLARIFY_FORMATS
  for select * from X_CLARIFY_FORMATS
  where FORMAT_TYPE = IP_FORMAT_TYPE
  order by FORMAT_TYPE ;

  if OP_CLARIFY_FORMATS%NOTFOUND
  then
  op_result := '630';
  op_msg := get_code_fun('GETFORMATS_PRC','630','ENGLISH');
  sa.ota_util_pkg.err_log(p_action        => get_code_fun('GETFORMATS_PRC','630','ENGLISH')
                          ,p_error_date   => SYSDATE
                          ,p_key          =>  ip_format_type
                          ,p_program_name => 'GETFORMATS_PRC'
                          ,p_error_text   => op_msg);
  -- close Services ; we dont close the cursor JAVA team closes the cursor
  return ;
  end if ;
end ;
/