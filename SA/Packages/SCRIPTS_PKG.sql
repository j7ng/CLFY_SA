CREATE OR REPLACE PACKAGE sa."SCRIPTS_PKG" AS
----------------------------------------------------------------
----------------------------------------------------------------
--$RCSfile: SCRIPTS_PKG.sql,v $
--$Revision: 1.11 $
--$Author: hcampano $
--$Date: 2017/03/01 19:31:26 $
--$ $Log: SCRIPTS_PKG.sql,v $
--$ Revision 1.11  2017/03/01 19:31:26  hcampano
--$ REL853B_TAS - 3.21.2017 - CR48373 - update
--$
--$ Revision 1.10  2016/10/04 15:50:33  nmuthukkaruppan
--$ CR44680 - Getting Language as Input param
--$
--$ Revision 1.9  2015/08/11 19:28:38  smeganathan
--$ Changes for 35913 - My accounts
--$
--$ Revision 1.8  2015/08/07 17:11:01  smeganathan
--$ Changes for 35913 - My accounts
--$
--$ Revision 1.6  2014/09/04 18:42:02  dtunk
--$ Added for CR28413
--$
--$ Revision 1.5  2013/08/27 14:57:55  hcampano
--$ Added function replace_script_token_variables to pkg
--$
--$ Revision 1.4  2013/07/16 12:31:17  hcampano
--$ Added new Procedure for next ADF release to get esn
--$
--$ Revision 1.3  2010/05/25 16:26:13  akhan
--$ Added default 'ENGLISH' to get_script_prc
--$
--$ Revision 1.2  2010/04/21 17:57:50  akhan
--$ Modified get_script_prc for defect
----------------------------------------------------------------
----------------------------------------------------------------
  function error_number_generator(ip_msg varchar2)
  return varchar2;
----------------------------------------------------------------
  function replace_script_token_variables (ip_script_text in varchar2,
                                           ip_bus_org in varchar2,
                                           ip_language in varchar2)
  return varchar2;

-- PROCESURE OVERLOADED DO NOT MODIFY
   PROCEDURE get_script_prc (
      ip_sourcesystem   IN       VARCHAR2,
      ip_script_type    IN       VARCHAR2,
      ip_script_id      IN       VARCHAR2,
      ip_language       IN       VARCHAR2,
      ip_carrier_id     IN       VARCHAR2,
      ip_part_class     IN       VARCHAR2,
      op_objid          OUT      VARCHAR2,
      op_description    OUT      VARCHAR2,
      op_script_text    OUT      VARCHAR2,
      op_publish_by     OUT      VARCHAR2,
      op_publish_date   OUT      DATE,
      op_sm_link        OUT      VARCHAR2
   );

   PROCEDURE get_script_prc (
      ip_sourcesystem   IN       VARCHAR2,                   --WEB,WEBCSR,ALL
      ip_brand_name     IN       VARCHAR2 default 'GENERIC', --TRACFONE,NET10,STRAIGHT_TALK
      ip_script_type    IN       VARCHAR2,                   --required
      ip_script_id      IN       VARCHAR2,                   -- if null it is assume to be part script
      ip_language       IN       VARCHAR2 default 'ENGLISH',                   -- required
      ip_carrier_id     IN       VARCHAR2,                   -- objid carrier null carrier ==> look by part_class
      ip_part_class     IN       VARCHAR2,                   -- null part class ==> look generic
      op_objid          OUT      VARCHAR2,
      op_description    OUT      VARCHAR2,
      op_script_text    OUT      VARCHAR2,
      op_publish_by     OUT      VARCHAR2,
      op_publish_date   OUT      DATE,
      op_sm_link        OUT      VARCHAR2
   );

   PROCEDURE sp_error_code2script (
      ERROR_CODE             VARCHAR2,
      func                   VARCHAR2,
      flow                   VARCHAR2,
      script_name   IN OUT   VARCHAR2,
      script_text   IN       VARCHAR2,
      prefix        IN       VARCHAR2
   );

   PROCEDURE sp_error_code2script (
      ERROR_CODE             VARCHAR2,
      func                   VARCHAR2,
      flow                   VARCHAR2,
      script_name   IN OUT   VARCHAR2,
      script_text   IN       VARCHAR2
   );


  procedure get_error_map_script (ip_func_name varchar2, -- USE THE METHOD NAME
                                  ip_flow_name varchar2, -- USE THE PERMISSION NAME
                                  ip_error_code varchar2, -- USE W/E NUMBER
                                  ip_default_msg varchar2, -- DEFAULT ERROR MESSAGE
                                  ip_default_script_id varchar2, -- OPTIONAL
                                  ip_brand varchar2, -- TRACFONE,NET10,STRAIGHT_TALK (TO OBTAIN SCRIPT)
                                  ip_language varchar2, -- ENGLISH,SPANISH
                                  ip_source_system varchar2, --
                                  ip_part_class varchar2, -- OPTIONAL FOR PART CLASS ERROR SCRIPT
                                  ip_replace_tokens varchar2, -- Y OR N - FLAG TO REPLACE VARIABLES EXAMPLE [COMPANY_NAME]
                                  op_script_text out varchar2);

PROCEDURE GET_SCRIPT_DETAILS(
		IP_SCRIPT_VALUES	IN VARCHAR2,
		IP_LANGUAGE 		IN VARCHAR2,
		IP_SOURCESYSTEM 	IN VARCHAR2,
		OP_RESULT_SET		OUT SYS_REFCURSOR,
		OP_ERRORNUM	 	OUT VARCHAR2,
		OP_ERRORMSG	 	OUT VARCHAR2);
--
-- CR35913 changes
PROCEDURE p_get_error_script_text( ip_brand         IN VARCHAR2,
                                   ip_source_system IN VARCHAR2,
                                   ip_language      IN VARCHAR2 default 'ENGLISH',  --CR44680 - Getting Language as Input param
                                   ip_error_code    IN VARCHAR2,
                                   ip_func          IN VARCHAR2,
                                   ip_flow          IN VARCHAR2,
                                   io_script_name   IN OUT VARCHAR2,
                                   ip_script_type   IN VARCHAR2,
                                   io_script_text   IN OUT VARCHAR2);


  procedure get_carrier_tech_script(ip_pc varchar2,
                                    ip_script_id varchar2,
                                    ip_carrier_id varchar2,
                                    ip_language varchar2,
                                    ip_sourcesystem VARCHAR2,
                                    op_objid out varchar2,
                                    op_description out varchar2,
                                    op_script_text out varchar2,
                                    op_publish_by out varchar2,
                                    op_publish_date out varchar2,
                                    op_sm_link out varchar2);

  procedure get_err_map_carrier_tech_scpt(ip_func_name varchar2, -- USE THE METHOD NAME
                                          ip_flow_name varchar2, -- USE THE PERMISSION NAME
                                          ip_error_code varchar2, -- USE W/E NUMBER
                                          ip_default_msg varchar2, -- DEFAULT ERROR MESSAGE
                                          ip_default_script_id varchar2, -- OPTIONAL
                                          ip_carrier varchar2, -- TABLE_X_CARRIER.X_CARRIER_ID - NEW MANDATORY
                                          ip_language varchar2, -- ENGLISH,SPANISH
                                          ip_part_class varchar2, -- MANDATORY
                                          ip_source_system varchar2, --
                                          ip_replace_tokens varchar2, -- Y OR N - FLAG TO REPLACE VARIABLES EXAMPLE [COMPANY_NAME]
                                          op_script_text out varchar2);
END scripts_pkg;
/