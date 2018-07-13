CREATE OR REPLACE PACKAGE sa.ILD_TRANSACTION_PKG IS

 PROCEDURE INSERT_TABLE_X_ILD_TRANS ( ip_dev in sa.table_x_ild_transaction.dev%type
 , ip_x_min in sa.table_x_ild_transaction.x_min%type
 , ip_x_esn in sa.table_x_ild_transaction.x_esn%type
 , ip_x_transact_date in sa.table_x_ild_transaction.x_transact_date%type
 , ip_x_ild_trans_type in sa.table_x_ild_transaction.x_ild_trans_type%type
 , ip_x_ild_status in sa.table_x_ild_transaction.x_ild_status%type
 , ip_x_last_update in sa.table_x_ild_transaction.x_last_update%type
 , ip_x_ild_account in sa.table_x_ild_transaction.x_ild_account%type
 , ip_ild_trans2site_part in sa.table_x_ild_transaction.ild_trans2site_part%type
 , ip_ild_trans2user in sa.table_x_ild_transaction.ild_trans2user%type
 , ip_x_conv_rate in sa.table_x_ild_transaction.x_conv_rate%type
 , ip_x_target_system in sa.table_x_ild_transaction.x_target_system%type
 , ip_x_product_id in sa.table_x_ild_transaction.x_product_id%type
 , ip_x_api_status in sa.table_x_ild_transaction.x_api_status%type
 , ip_x_api_message in sa.table_x_ild_transaction.x_api_message%type
 , ip_x_ild_trans2ig_trans_id in sa.table_x_ild_transaction.x_ild_trans2ig_trans_id%type
 , ip_x_ild_trans2call_trans			in sa.table_x_ild_transaction.x_ild_trans2call_trans%type
 , op_objid out sa.table_x_ild_transaction.objid%type
 , op_err_num out number
 , op_err_string out varchar2
 ) ;

 procedure get_ild_params_by_sitepart ( ip_site_part_objid in sa.table_site_part.objid%type
 , ip_esn in sa.table_site_part.x_service_id%type
 , ip_bus_org in sa.table_bus_org.s_org_id%type
 , op_ild_product_id out sa.table_x_ild_transaction.x_product_id%type
 , op_ild_ig_account out sa.table_x_ild_transaction.x_ild_account%type
 , op_err_num out number
 , op_err_string out varchar2) ;

 FUNCTION get_sl_ild_prd_def (v_bus_org IN VARCHAR2) RETURN VARCHAR2;

 FUNCTION GET_DISPLAY_FLAG ( i_country 		IN VARCHAR2,
 i_language		IN VARCHAR2 DEFAULT 'ENGLISH',
 i_bus_org_id	IN sa.TABLE_BUS_ORG.S_ORG_ID%TYPE )RETURN NUMBER;

 procedure p_insert_ild_transaction_sl_1( p_min NUMBER,
 p_esn_from VARCHAR2, -- UPGRADE/DEENROLL/PLAN CHANGE
 p_esn_to VARCHAR2, --UPGRADE
 p_action VARCHAR2, --UPGRADE ELSE NULL
 p_brand VARCHAR2,
 p_ild_trans_type VARCHAR2, --D, A
 p_err_num OUT NUMBER,
 p_err_string OUT VARCHAR2);

 procedure p_insert_10ild_transaction (i_esn in varchar2 ,
 i_min in number ,
 i_brand in varchar2 ,
 i_sourcesystem in varchar2 ,
 i_action in varchar2 , --REFUND
 i_ild_trans_type in varchar2 , --'D'
 i_purch_hdr_objid in number ,
 o_err_num out number ,
 o_err_str out varchar2,
 i_pgm_hdr_objid in number default null --CR43101
 );

	 PROCEDURE GET_REGIONS (	i_language		IN VARCHAR2 DEFAULT 'ENGLISH',
 i_bus_org_id	IN sa.TABLE_BUS_ORG.S_ORG_ID%TYPE,
 o_regions		OUT ild_reg_tab,
 o_err_num		OUT VARCHAR2,
 o_err_string	OUT VARCHAR2
 );


   PROCEDURE P_UPDATE_TABLE_X_ILD_TRAN(i_esn     		IN VARCHAR2,
                                       i_order_type 	IN VARCHAR2,
                                       i_min		      IN  VARCHAR2,
                                       o_err_num		  OUT VARCHAR2,
                                       o_err_string	OUT VARCHAR2
                                      );
--CR53217 Net10 web common standards
PROCEDURE get_ild_transaction_flag(
    i_esn IN VARCHAR2,
    i_min IN VARCHAR2,
    o_ild_transaction_flag OUT VARCHAR2,
    o_err_num OUT NUMBER,
    o_err_string OUT VARCHAR2);

--CR48260 SM MLD new procedure
PROCEDURE provision_10_ild(
    i_device_id          IN VARCHAR2,             --esn or min expected here.
    i_ild_pin            IN VARCHAR2,             --x_red_code
    i_Enroll_low_balance IN VARCHAR2 DEFAULT 'N', -- Y/N ( if nothing passed,assume no)
    i_sourcesystem       IN VARCHAR2,
    o_err_num            OUT NUMBER,
    o_err_string         OUT VARCHAR2,
    o_call_trans_objid   OUT NUMBER);


END ILD_TRANSACTION_PKG;
/