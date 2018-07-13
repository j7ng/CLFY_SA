CREATE OR REPLACE package sa.ecommerce_supply_chain
IS
/*******************************************************************************************************
* --$RCSfile: ecommerce_supply_chain.sql,v $
 --$Revision: 1.5 $
  --$Author: tbaney $
  --$Date: 2017/11/09 14:22:17 $
  --$ $Log: ecommerce_supply_chain.sql,v $
  --$ Revision 1.5  2017/11/09 14:22:17  tbaney
  --$ CR54238_Resolve_Issue_with_Orders_Not_Found_in_Commerce
  --$
  --$ Revision 1.4  2014/02/25 21:37:12  cpannala
  --$ CR25490
  --$
  --$ Revision 1.2  2013/12/27 17:14:47  cpannala
  --$ CR22623 Changes
  --$
  --$ Revision 1.1  2013/12/05 16:22:36 cpannala
  --$ CR22623 - B2B Initiative
  --$
* Description:
* -----------------------------------------------------------------------------------------------------
*******************************************************************************************************/
PROCEDURE list_of_carriers(p_zip        in  varchar2,
                          p_device_type in  varchar2,
                          p_att         out varchar2,
                          p_verizon     out varchar2,
                          P_SPRINT      OUT VARCHAR2,
                          P_Tmobile     Out Varchar2);
----
PROCEDURE PHONE_CART_PRC(P_PHONE_CART IN OUT PHONE_CART_OBJECT);
------

FUNCTION CARRIERS_BY_PART_NUM(P_PART_NUMBER IN VARCHAR2) RETURN VARCHAR2;
---
PROCEDURE GET_BP_CODES(
    IN_ZIPCODE     IN VARCHAR2 ,
    IN_BRAND       IN VARCHAR2 ,
    IN_PRODUCT_KEY IN VARCHAR2 ,
    IN_LANGUAGE    IN VARCHAR2 DEFAULT 'EN' ,
    in_carrier     IN VARCHAR2 ,
    OUT_BP_CODE OUT SYS_REFCURSOR,
    OUT_ERR_NUM OUT NUMBER ,
    OUT_ERR_MSG OUT VARCHAR2 );
---

--  EME Tim 10/21/2017 CR54238_Resolve_Issue_with_Orders_Not_Found_in_Commerce

PROCEDURE get_ecomm_biz_purch_hdr_dtl(
                                      i_c_orderid      IN      VARCHAR2,
                                      i_x_ics_rflag    IN      VARCHAR2,
                                      i_x_payment_type IN      VARCHAR2,
                                      po_refcursor         OUT SYS_REFCURSOR);

END ecommerce_supply_chain;
/