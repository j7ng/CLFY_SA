CREATE OR REPLACE PACKAGE sa."B2B_SUPPORT_PKG" AS

/*****************************************************************
  * Package Name: B2B_SUPPORT_PKG
  * Purpose     : Support DB Updates for the B2B App.
  *
  * Platform    : Oracle 8.0.6 and newer versions.
  * Created by  : Natalio Guada
  * Date        : 04/23/2009
  *
  * Frequency   : All weekdays
  * History
  * REVISIONS    VERSION  DATE          WHO            PURPOSE
  * -------------------------------------------------------------
  *              1.0      04/23/2009    Nguada     Initial Revision
  *              1.1      08/20/2010    Nguada     CR13581
  *              1.2      09/15/2010    Nguada     Primary ESN Fix
  *              1.3      11/01/2010    Akhan      CR14676 Description Update
  *              1.4      11/19/2010    Nguada     CR14676 Port Case Close Email;
************************************************************************/

Procedure Account_Primary_Esn_Fix (ip_account_id in number);

PROCEDURE refund_pre_processing;      --------CR13581

PROCEDURE port_case_notification; --CR14676

PROCEDURE get_price_list(bus_org in varchar2,
                         zip_code in varchar2,
                         ip_domain in varchar2,
                         price_list out SYS_REFCURSOR);

PROCEDURE get_esn_by_bus_acc(ip_acc_id in varchar2,
                             esn_list out SYS_REFCURSOR);

PROCEDURE insert_business_account (
IP_NAME               IN   VARCHAR2,
IP_TAX_EXEMPT           IN   VARCHAR2,
IP_BUS_ORG            IN   VARCHAR2,
IP_BUSINESS_DESC      IN   VARCHAR2,
IP_WEB_SITE           IN   VARCHAR2,
IP_COMMENTS           IN   VARCHAR2,
IP_ACC_STATUS         IN   VARCHAR2,
IP_FED_TAX_ID         IN   VARCHAR2,
IP_SALES_TAX_ID       IN   VARCHAR2,
IP_DEFAULT_ACT_ZIPCODE IN   VARCHAR2,
IP_BUS_PRIMARY2CONTACT IN  NUMBER,
IP_CREATED_BY          IN  VARCHAR2 ,
OP_ACCOUNT_ID  OUT    NUMBER,
OP_ERROR_NO    OUT    VARCHAR2,
OP_ERROR_STR   OUT    VARCHAR2);

PROCEDURE insert_sales_order(
    IP_ACCOUNT_ID IN NUMBER,
  IP_SHIP_ADDRESS IN VARCHAR2,
    IP_SHIP_ADDRESS_2 IN VARCHAR2,
    IP_SHIP_CITY  IN VARCHAR2,
    IP_SHIP_STATE IN VARCHAR2,
    IP_SHIP_ZIPCODE IN VARCHAR2,
  IP_BILL_ADDRESS IN VARCHAR2,
    IP_BILL_ADDRESS_2 IN VARCHAR2,
    IP_BILL_CITY IN VARCHAR2,
    IP_BILL_STATE IN VARCHAR2,
    IP_BILL_ZIPCODE IN VARCHAR2,
    IP_ORDER2PAYMENT_SOURCE IN NUMBER,
  IP_ORDER2PURCH_HDR IN  NUMBER,
  IP_TERMS_AND_COND_CHECK IN  NUMBER,
  IP_SUB_TOTAL_ITEMS IN  NUMBER,
  IP_SUB_TOTAL_AIR IN NUMBER,
  IP_ITEMS_TAX IN NUMBER,
  IP_AIR_TAX IN NUMBER,
  IP_E911_FEE IN NUMBER,
  IP_SHIPPING_OPTION IN VARCHAR2,
  IP_SHIPPING_COST IN NUMBER,
    IP_ORDER_TOTAL IN NUMBER,
  IP_ORDER_STATUS IN VARCHAR2,
  IP_ENROLL_STATUS IN VARCHAR2,
    IP_CREATED_BY IN VARCHAR2,
  IP_NOTES IN VARCHAR2,
  OP_ORDER_DATE OUT DATE,
  OP_ORDER_ID    OUT NUMBER,
  OP_ERROR_NO    OUT    VARCHAR2,
  OP_ERROR_STR   OUT    VARCHAR2);

PROCEDURE insert_sale_order_item(
  IP_ORDER_ID IN NUMBER,
  IP_LINE_TYPE IN  VARCHAR2,
  IP_ZIP_CODE IN VARCHAR2,
    IP_PART_NUMBER IN VARCHAR2,
  IP_AIRTIME_PLAN IN VARCHAR2,
    IP_QUANTITY IN NUMBER,
    IP_UNIT_PRICE IN NUMBER,
  IP_PLAN_PRICE IN NUMBER,
    IP_CREATED_BY IN VARCHAR2,
    OP_LINE_ITEM_ID OUT NUMBER,
  OP_ERROR_NO    OUT    VARCHAR2,
  OP_ERROR_STR   OUT    VARCHAR2);

PROCEDURE insert_sales_order_service(
  IP_ORDER_ID NUMBER,
  IP_LINE_ITEM_ID NUMBER,
  IP_SERVICE_TYPE IN VARCHAR2,
  IP_ACT_ZIP_CODE IN VARCHAR2,
    IP_PART_NUMBER IN VARCHAR2,
  IP_PART_SERIAL_NO IN VARCHAR2,
  IP_SIM_SERIAL_NO IN VARCHAR2,
  IP_AIRTIME_PLAN IN VARCHAR2,
  IP_FIRST_NAME IN VARCHAR2,
  IP_LAST_NAME  IN VARCHAR2,
  IP_BUSINESS_NAME IN VARCHAR2,
  IP_TAX_ID_NUMBER IN VARCHAR2,
  IP_CONTACT_FIRST_NAME IN VARCHAR2,
  IP_CONTACT_LAST_NAME IN VARCHAR2,
  IP_ADDRESS IN VARCHAR2,
    IP_ADDRESS_2 IN VARCHAR2,
    IP_CITY IN VARCHAR2,
    IP_STATE IN VARCHAR2,
    IP_ZIP_CODE IN VARCHAR2,
  IP_NUMBER_TO_PORT IN VARCHAR2,
  IP_SSN_LAST_4 IN VARCHAR2,
  IP_PROVIDER IN VARCHAR2,
  IP_PROV_ACC_NUMBER IN VARCHAR2,
  IP_PROV_PASS_PIN IN VARCHAR2,
  IP_PORT_REQ_STATUS IN VARCHAR2,
  IP_PORT_CASE_ID IN VARCHAR2,
    IP_CREATED_BY  IN VARCHAR2,
    IP_CREATION_DATE  IN DATE,
    IP_LAST_UPDATED_BY IN VARCHAR2,
    IP_LAST_UPDATE_DATE  IN DATE,
  OP_LINE_SERV_ID OUT   NUMBER,
  OP_ERROR_NO    OUT    VARCHAR2,
  OP_ERROR_STR   OUT    VARCHAR2);

PROCEDURE insert_sales_order_refund(
  IP_LINE_ITEM_ID IN NUMBER,
  IP_QTY IN NUMBER,
  IP_CREATED_BY IN VARCHAR2,
  OP_REFUND_ITEM_ID OUT NUMBER,
  OP_ERROR_NO    OUT    VARCHAR2,
  OP_ERROR_STR   OUT    VARCHAR2);

PROCEDURE update_x_pricing_desc (ip_desc in varchar2,
                                 ip_type  in varchar2,
                                 ip_price_objid in number,
                                 op_result out number);

END B2B_SUPPORT_PKG;
/