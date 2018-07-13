CREATE OR REPLACE PROCEDURE sa."GET_MOBILE_COMPLETE_URL"
 (
 ip_sourcesystem in varchar2, -- WEB,WEBCSR
 ip_language in varchar2, -- ENGLISH, SPANISH
 ip_part_class in varchar2, -- PART_CLASS NAME
 op_url out varchar2,
 op_error_no out varchar2,
 op_error_str out varchar2,
 ip_instruction in varchar2 default null -- SPECIFIC TUTORIAL
 )
is


--$RCSfile: GET_MOBILE_COMPLETE_URL.sql,v $
--$Revision: 1.9 $
--$Author: sraman $
--$Date: 2017/04/06 18:59:16 $
--$ $Log: GET_MOBILE_COMPLETE_URL.sql,v $
--$ Revision 1.9  2017/04/06 18:59:16  sraman
--$ CR47564 - In the URL if the brand is WFM changing it to familymobile
--$
--$ Revision 1.8  2015/12/29 19:33:35  sraman
--$ 39804
--$
--$
--$ Revision 1.7  2015/06/18 19:39:17  hcampano
--$ CR35688 - Get Mobile Complete now reads "Y" as the device_id value and builds the url dynamically using the part class. Legacy still supported.
--$
--$ Revision 1.6  2013/04/04 19:23:19  ymillan
--$ CR22451
--$
--$ Revision 1.5  2013/04/04 15:55:30  ymillan
--$ CR22451 TAS Simple Mobile
--$
--$ Revision 1.4  2010/06/23 14:29:09  icanavan
--$ initial revision
--$
--$ Revision 1.1  2010/06/25 15:31:57  akhan
--$ Initial Revision
--$

  v_link      varchar2(200)  := 'http://tracfone.deviceanywhere.com/';
  v_brand     varchar2(30)   := '';
  v_link_2    varchar2(200)  := '/home.seam?custId=';
  v_device_id varchar2(30)   := '';
  v_csr       varchar2(30)   := '';
  v_locale    varchar2(30)   := '';
  v_tut_flag  varchar2(1)    := 'N';

begin
  -- ORIGINALLY THE DEVICE ID WAS DISCTINCT BETWEEN ENGLISH AND SPANISH FOR
  -- EACH PART CLASS AND WAS UNMANAGABLE TO CREATE A MAPPING TO THEIR URLS.
  -- THIS WAS FIXED SO THAT ANY DEVICE CREATED BY MOBILE COMPLETE IS NOW
  -- EASY TO MANAGE BY DRIVING IT THROUGH THE PART CLASS PARAMETER
  -- DEVICE_ID_ENGLISH OR DEVICE_ID_SPANISH.
  -- THIS HAS BEEN FINE UNTIL NOW THAT OUR PART CLASS LIST HAS GROWN. IT'S NOW
  -- CAUSING ISSUES IN THE APEX TOOL DROP DOWN THAT DRIVES THE VALUES
  -- SINCE FOR A VERY LONG TIME NOW THE IDENTIFIER HAS BEEN THE
  -- PART CLASS ITSELF FOR EN AND THE PART CLASS + "S" FOR SPANISH
  -- FOR PARTCLASSES GOING FORWARD THE PARAMETER JUST NEEDS TO BE 'Y' OR 'N'
  -- WE WILL MANAGE LEGACY PART CLASSES AS WE ALWAYS HAVE BEEN

--CR39804:- Check if a Paramter value available use that otherwise use the hard coded old value
 SELECT
    CASE
      WHEN EXISTS (SELECT 1 FROM TABLE_X_PARAMETERS WHERE X_PARAM_NAME='MC_URL_HOST' AND rownum=1)
      THEN (SELECT X_PARAM_VALUE FROM TABLE_X_PARAMETERS WHERE X_PARAM_NAME='MC_URL_HOST' AND rownum=1)
      ELSE v_link
    END  INTO v_link
  FROM dual;

  -- DEFINE THE BRAND
  select replace(lower(get_param_by_name_fun (ip_part_class,'BUS_ORG')),'_','')
  into v_brand
  from dual;

  --CR47564 WFM
  IF v_brand = 'wfm' THEN
    v_brand := 'familymobile';
  END IF;

  -- CHECK
  begin
    select x_param_value
    into   v_tut_flag
    from   table_x_parameters
    where  x_param_name = 'MC_DISPLAY_TUT';
  exception when others then
    null;
  end;

  -- SPECIFY LANG
  if upper(ip_language)='SPANISH' then
    v_device_id := get_param_by_name_fun (ip_part_class,'DEVICE_ID_SPANISH');
    v_locale := '&locale=es_US';
  else
    v_device_id := get_param_by_name_fun (ip_part_class,'DEVICE_ID_ENGLISH');
    v_locale := '&locale=en_US';
  end if;

  -- REMOVED TUTORIAL MAPPING (NEVER WAS USED)

  -- SPECIFY CHANNEL (ST NOT APPLY)
  if ip_sourcesystem in ('TAS','WEBCSR') then  --CR22451
     v_csr:='&crd=webcsr:webcsr';
  end if;

  if instr(v_device_id,'Y') > 0 and upper(ip_language) = 'SPANISH' then
    dbms_output.put_line('NEW:    ip_part_class/ip_language/v_device_id  =============> ('||ip_part_class||'/'||ip_language||'/'||v_device_id||')');
     op_url:= v_link || v_brand || v_link_2 || ip_part_class || 'S' || v_csr || v_locale;
     op_error_no:='0';
     op_error_str:='';
  elsif instr(v_device_id,'Y') > 0 then
    dbms_output.put_line('NEW:    ip_part_class/ip_language/v_device_id  =============> ('||ip_part_class||'/'||ip_language||'/'||v_device_id||')');
     op_url:= v_link || v_brand || v_link_2 || ip_part_class || v_csr || v_locale;
     op_error_no:='0';
     op_error_str:='';
  elsif instr(v_device_id,'NOT FOUND') > 0 then
     op_url:='';
     op_error_no:='100';
     op_error_str:='Model not supported';
  else
    dbms_output.put_line('LEGACY: ip_part_class/v_device_id ===========> ('||ip_part_class||'/'||v_device_id||')');
     op_url:= v_link || v_brand || v_link_2 || v_device_id || v_csr || v_locale;
     op_error_no:='0';
     op_error_str:='';
  end if;

end;
/