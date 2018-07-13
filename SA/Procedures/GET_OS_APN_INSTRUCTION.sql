CREATE OR REPLACE PROCEDURE sa."GET_OS_APN_INSTRUCTION" (ip_operating_system varchar2,
                                  ip_language varchar2,
                                  ip_brand    varchar2,
                                  op_script_text out varchar2)
as

--$RCSfile: GET_OS_APN_INSTRUCTION.sql,v $
--$Revision: 1.2 $
--$Author: jarza $
--$Date: 2014/09/25 13:33:33 $
--$ $Log: GET_OS_APN_INSTRUCTION.sql,v $
--$ Revision 1.2  2014/09/25 13:33:33  jarza
--$ CR25378 Adding additional input parameter to this procedure
--$
--$ Revision 1.1  2013/06/21 15:38:45  icanavan
--$ initial revision wrapper APN 24195
--$
--$ Revision 1.1  2013/06/21 19:23:19  icanavan
--$ Initial Revision
--$

  op_objid varchar2(200);
  op_description varchar2(200);
  op_publish_by varchar2(200);
  op_publish_date date;
  op_sm_link varchar2(200);
  v_prefix varchar2(30);
  v_suffix varchar2(30);
  ERR_CODE VARCHAR2(4000) ;
  ERR_MSG VARCHAR2(4000) ;

begin

  select substr(script_id,0,instr(script_id,'_')-1) prefix,
         substr(script_id,instr(script_id,'_')+1) suffix
  into   v_prefix,v_suffix
  from   X_SCRIPT_HANDSET_OS
  where  operating_system = ip_operating_system;

  scripts_pkg.get_script_prc (ip_sourcesystem => null,
                              ip_brand_name => nvl(ip_brand,'GENERIC'),
                              ip_script_type => v_prefix,
                              ip_script_id => v_suffix,
                              ip_language => ip_language,
                              ip_carrier_id => null,
                              ip_part_class => null,
                              op_objid => op_objid,
                              op_description => op_description,
                              op_script_text => op_script_text,
                              op_publish_by => op_publish_by,
                              op_publish_date => op_publish_date,
                              op_sm_link => op_sm_link);

  --dbms_output.put_line('OP_OBJID = ' || op_objid);
  --dbms_output.put_line('OP_DESCRIPTION = ' || op_description);
  --dbms_output.put_line('OP_SCRIPT_TEXT = ' || op_script_text);
  --dbms_output.put_line('OP_PUBLISH_BY = ' || op_publish_by);
  --dbms_output.put_line('OP_PUBLISH_DATE = ' || op_publish_date);
  --dbms_output.put_line('OP_SM_LINK = ' || op_sm_link);
EXCEPTION
   WHEN OTHERS THEN
      err_code := SQLCODE;
      err_msg := substr(SQLERRM, 1, 200);
      INSERT INTO ERROR_TABLE (ERROR_TEXT,ERROR_DATE,ACTION,KEY,PROGRAM_NAME)
      VALUES (err_code,SYSDATE,err_msg,ip_operating_system,'GET_OS_APN_INSTRUCTION');
END; -- get_os_apn_instruction;
/