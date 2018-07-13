CREATE OR REPLACE PACKAGE sa.ADFCRM_PERSONALITY_PKG
AS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_PERSONALITY_PKG.sql,v $
--$Revision: 1.12 $
--$Author: nguada $
--$Date: 2017/02/15 20:51:12 $
--$ $Log: ADFCRM_PERSONALITY_PKG.sql,v $
--$ Revision 1.12  2017/02/15 20:51:12  nguada
--$ CR47838 Personality updates for SL phones
--$
--$ Revision 1.11  2015/04/17 02:32:11  mmunoz
--$ CR29505 added cmd_list in update_before_ota
--$
--$ Revision 1.10  2015/04/17 01:43:52  mmunoz
--$ CR29505 Added procedure UPDATE_BEFORE_OTA
--$
--$ Revision 1.9  2015/04/15 22:54:49  mmunoz
--$ Added Clicks
--$
--$ Revision 1.8  2015/04/13 16:47:26  mmunoz
--$ CR29505
--$
--$ Revision 1.7  2015/03/24 21:51:27  mmunoz
--$ added click_611 and free_dial
--$
--$ Revision 1.6  2015/02/05 20:49:41  nguada
--$ grants restored
--$
--$ Revision 1.5  2015/02/05 20:47:03  nguada
--$ restriction procedure added
--$
--$ Revision 1.4  2014/07/15 15:09:14  hcampano
--$ TAS_2014_06 - Page Plus
--$
--$ Revision 1.3  2013/03/13 20:00:39  mmunoz
--$ CR23043 ADF Oracle Application - Third Release  -- Added procedure MASTER_SID_GSM
--$
--------------------------------------------------------------------------------------------

  /* TODO enter package declarations (types, exceptions, methods etc) here */
PROCEDURE Get_Personality_Codes(
    Ip_Esn           IN VARCHAR2,
    Ip_Source_System IN VARCHAR2,
    Ip_User_Objid    IN NUMBER,
    Ip_Cmd_List      IN VARCHAR2, --(Comma separated command list)
    Ip_Send_Ota      IN NUMBER,   --(0 No,1=Yes)
    Op_Call_Trans_Objid OUT NUMBER,
    op_ota_stmt         OUT VARCHAR2,
    op_orig_seq  OUT NUMBER,
    op_new_seq   OUT NUMBER,
    OP_TECH_NUM  OUT number,
    op_trans_id  out number,
    Op_Error OUT VARCHAR2,
    Op_Message Out Varchar2);

PROCEDURE PAGE_PLUS_GET_PERSNLTY_CODES(
    ip_esn           in varchar2,
    ip_min           in number,
    ip_seq           in number,
    Ip_Source_System IN VARCHAR2,
    ip_user_name    in varchar2,
    Op_Call_Trans_Objid OUT NUMBER,
    op_ota_stmt         OUT VARCHAR2,
    op_orig_seq  OUT NUMBER,
    op_new_seq   OUT NUMBER,
    OP_TECH_NUM  OUT number,
    op_trans_id  out number,
    Op_Error OUT VARCHAR2,
    op_message out varchar2);

Procedure Find_Parameters(
    Op_Error Out Varchar2,
    op_message OUT VARCHAR2);

procedure find_page_plus_parameters (
    op_error out varchar2,
    op_message out varchar2);

procedure validate_page_plus_min (
    op_error out varchar2,
    op_message OUT VARCHAR2);

PROCEDURE UPDATE_CODE_HIST_TEMP (
    Ip_code_temp_objid  IN NUMBER,
    Ip_gen_code         IN VARCHAR2,
    Op_Error           OUT VARCHAR2,
    op_message         OUT VARCHAR2);

PROCEDURE REJECT_PERS_CODES (
    ip_call_trans_objid NUMBER,
    op_Error           OUT VARCHAR2,
    op_message         OUT VARCHAR2);

PROCEDURE ACCEPT_PERS_CODES (
    ip_call_trans_objid NUMBER,
    op_Error           OUT VARCHAR2,
    op_message         OUT VARCHAR2);

PROCEDURE UPDATE_OTA_TRANSACTION (
     ip_call_trans_objid IN NUMBER,
     ip_psms_text        IN VARCHAR2,
     Op_Error            OUT VARCHAR2,
     op_message          OUT VARCHAR2);

PROCEDURE CLICKS;
PROCEDURE CLICKS_19;
PROCEDURE CLICKS_20;
PROCEDURE CLICKS_21;
PROCEDURE CLICKS_22;
PROCEDURE CLICKS_23;
PROCEDURE LOCAL_SID_32;
PROCEDURE LOCAL_SID_33;
PROCEDURE LOCAL_SID_34;
PROCEDURE LOCAL_SID_35;
PROCEDURE RED_MENU_ON;
PROCEDURE RED_MENU_OFF;
PROCEDURE MO_ADDRESS;
PROCEDURE MASTER_SID;
PROCEDURE MASTER_SID_GSM;
PROCEDURE PRL_SID;
PROCEDURE PSMS_UNLOCK2;
PROCEDURE TIME_CODE;
PROCEDURE GATEWAY_IP_UPDATE;
PROCEDURE GATEWAY_PORT_UPDATE;
PROCEDURE CLEAR_PROXY;
PROCEDURE GPRS_APN;
PROCEDURE GATEWAY_HOME;
PROCEDURE MMSC_UPDATE;
PROCEDURE CARRIER_DATA_SWITCH;
PROCEDURE PROD_SELECTION;
PROCEDURE PRL;
Procedure Clean_Command_Parameters;
Procedure RESTRICTIONS;
PROCEDURE FREE_611;
PROCEDURE FREE_1611;
PROCEDURE FREE_DIAL;
PROCEDURE FREE_DIAL_1;
PROCEDURE FREE_MO_MMS;
PROCEDURE FREE_MT_MMS;
PROCEDURE FREE_BROWSING;

PROCEDURE INSERT_COMMAND_PARAMETERS(
    Op_Error Out Varchar2,
    op_message OUT VARCHAR2);

PROCEDURE UPDATE_BEFORE_OTA(
    ip_call_trans_objid NUMBER,
    Ip_Cmd_List VARCHAR2,
    op_Error           out VARCHAR2,
    op_message         out VARCHAR2);

END ADFCRM_PERSONALITY_PKG;
/