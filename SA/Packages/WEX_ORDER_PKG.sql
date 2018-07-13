CREATE OR REPLACE PACKAGE sa.WEX_ORDER_PKG
AS

/*************************************************************************************************************************************
  * $Revision: 1.3 $
  * $Author: abustos $
  * $Date: 2017/08/30 15:19:32 $
  * $Log: WEX_ORDER_PKG.sql,v $
  * Revision 1.3  2017/08/30 15:19:32  abustos
  * New function get_wex_inventory to return inv based on item_code
  *
  * Revision 1.2  2017/08/25 14:06:40  abustos
  * Added grants
  *
  * Revision 1.1  2017/08/10 22:32:32  abustos
  * CR49957 new package for WEX OFS inbound and TAS service
  *
  *************************************************************************************************************************************/

TYPE get_wex_info_rec IS RECORD
    ( RECEIVED_DATE    DATE,
      CASE_CREATION    DATE,
      CASE_STATUS      VARCHAR2(10),
      PRODUCT_STATUS   VARCHAR2(10),
      WH_QUEUE_CASE    VARCHAR2(10),
      AGING_DATE       DATE,
      AIRBILL          VARCHAR2(60),
      ITEM_CODE        VARCHAR2(60),
      ITEM_CLASS       VARCHAR2(60),
      ITEM_DESCRIPTION VARCHAR2(255),
      SHIP_STATUS      VARCHAR2(10),
      TRACKING_NUM     VARCHAR2(60),
      SALE_PRICE       VARCHAR2(10),
      SHIP_EMAIL       VARCHAR2(255),
      ORDER_DATE       DATE,
      SHIP_NAME        VARCHAR2(30),
      CITY             VARCHAR2(30),
      STATE            VARCHAR2(2),
      ORDER_NUM        VARCHAR2(60)
    );

TYPE get_wex_info_tab IS TABLE OF get_wex_info_rec;

--Bring WEX order tables from OFS to Clarify
--
PROCEDURE wex_inbound_job ( op_result OUT NUMBER,
                            op_msg    OUT VARCHAR2);

--Based on Input parameter we will return all information for the WEX order
--
FUNCTION get_wex_order_info( p_esn        IN  VARCHAR2,
                             p_case_id    IN  VARCHAR2,
                             p_min        IN  VARCHAR2,
                             p_order_num  IN  VARCHAR2)
  RETURN get_wex_info_tab PIPELINED;


TYPE get_wex_inventory_tab IS TABLE OF wex_bp_inv_receipts%ROWTYPE;

--Return inventory of specified item code
FUNCTION get_wex_inventory ( p_item_code  IN  VARCHAR2)
  RETURN get_wex_inventory_tab PIPELINED;

END WEX_ORDER_PKG;
/