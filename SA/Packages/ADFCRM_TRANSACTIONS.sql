CREATE OR REPLACE PACKAGE sa."ADFCRM_TRANSACTIONS" AS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_TRANSACTIONS_PKG.sql,v $
--$Revision: 1.5 $
--$Author: mmunoz $
--$Date: 2015/04/27 14:12:38 $
--$ $Log: ADFCRM_TRANSACTIONS_PKG.sql,v $
--$ Revision 1.5  2015/04/27 14:12:38  mmunoz
--$ New procedure validate_address for CR32682
--$
--$ Revision 1.4  2014/10/27 15:28:16  mmunoz
--$ Added procedure address
--$
--$ Revision 1.3  2014/10/22 22:07:20  mmunoz
--$ CR30527
--$
--$ Revision 1.2  2014/08/21 22:11:34  mmunoz
--$ Added function balance_metering
--$
--$ Revision 1.1  2014/03/12 18:58:34  mmunoz
--$ CR27508 Transactions from TAS not logging user info in call trans
--$
--------------------------------------------------------------------------------------------

  function update_call_trans_user (p_esn              in varchar2,
                                   p_call_trans_objid in number,
                                   p_user_name        in varchar2) return varchar2;

	function balance_metering (
	   p_esn varchar2,
	   p_action varchar2,  --COMPENSATION / REPLACEMENT
	   p_serv_plan_group varchar2
	)
	return varchar2;

    function is_balance_inq_required (
       from_esn varchar2,
       to_esn varchar2,
       ip_action varchar2  --TRANSFER_UNITS, UPGRADE
    )
    return varchar2;
-----------------------------------------------------------------------------------------------------------------------------
--New procedure validate_address for CR32682
-----------------------------------------------------------------------------------------------------------------------------
 procedure validate_address(p_add_1 in varchar2,
                            p_add_2 in varchar2,
                            p_city in varchar2,
                            p_st in varchar2,
                            p_zip in varchar2,
                            p_country in varchar2,
                            p_err_code out varchar2,
                            p_err_msg  out varchar2);

  procedure address (p_add_1 in varchar2,
                            p_add_2 in varchar2,
                            p_city in varchar2,
                            p_st in varchar2,
                            p_zip in varchar2,
                            p_country in varchar2,
                            p_address_objid in out number,  -- null--> Create / not null --> Update Address
                            p_address_type in varchar2, --PRIMARY, BILLING, SHIPPING
                            p_contact_objid in varchar2,
                            p_err_code out varchar2,
                            p_err_msg  out varchar2);

END ADFCRM_TRANSACTIONS;
/