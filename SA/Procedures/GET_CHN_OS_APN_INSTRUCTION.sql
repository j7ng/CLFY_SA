CREATE OR REPLACE PROCEDURE sa."GET_CHN_OS_APN_INSTRUCTION" (ip_operating_system VARCHAR2,
                                                        ip_language         VARCHAR2,
                                                        ip_brand            VARCHAR2,
                                                        ip_source_system    VARCHAR2,
                                                        op_script_text  OUT VARCHAR2)
AS
--
--$RCSfile: get_chn_os_apn_instruction.sql,v $
--$ Revision 1.1  2015/08/21 13:20:00  sethiraj
--$ Cloned from get_os_apn_instruction procedure
--$ CR35913 Added additional IN parameter ip_source_system
--$
  op_objid            VARCHAR2(200);
  op_description      VARCHAR2(200);
  op_publish_by       VARCHAR2(200);
  op_publish_date     DATE;
  op_sm_link          VARCHAR2(200);
  v_prefix            VARCHAR2(30);
  v_suffix            VARCHAR2(30);
  err_code            VARCHAR2(4000);
  err_msg             VARCHAR2(4000);
  --
BEGIN
  -- cr39960 modify PROCEDURE get_chn_os_apn_instruction to avoid duplicates (added distinct in select statement as part of defect#745 fix
  SELECT distinct substr(script_id,0,instr(script_id,'_')-1) prefix,
         substr(script_id,instr(script_id,'_')+1) suffix
  INTO   v_prefix,v_suffix
  FROM   X_SCRIPT_HANDSET_OS
  WHERE  operating_system = ip_operating_system;
  dbms_output.put_line ('v_prefix: '||v_prefix||' v_suffix: '||v_suffix);
  --
  scripts_pkg.get_script_prc (ip_sourcesystem       => nvl(ip_source_system,'ALL'),
                              ip_brand_name         => nvl(ip_brand,'GENERIC'),
                              ip_script_type        => v_prefix,
                              ip_script_id          => v_suffix,
                              ip_language           => ip_language,
                              ip_carrier_id         => NULL,
                              ip_part_class         => NULL,
                              op_objid              => op_objid,
                              op_description        => op_description,
                              op_script_text        => op_script_text,
                              op_publish_by         => op_publish_by,
                              op_publish_date       => op_publish_date,
                              op_sm_link            => op_sm_link);
  dbms_output.put_line ('op_script_text***'||op_script_text);
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
  DBMS_OUTPUT.PUT_LINE ('err_code='||err_code||'; err_msg'||err_msg||'; ip_operating_system'||ip_operating_system);
  util_pkg.insert_error_tab ( i_action       => err_msg,
                              i_key          => ip_operating_system,
                              i_program_name => 'GET_CHN_OS_APN_INSTRUCTION',
                              i_error_text   => err_code );
END; -- get_chn_os_apn_instruction;
/