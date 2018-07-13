CREATE OR REPLACE PROCEDURE sa.inbound_order_info_ofssit
IS
/*******************************************************************************************************
*  --$RCSfile: INBOUND_ORDER_INFO_ofssit.sql,v $
  --$Revision: 1.8 $
  --$Author: smeganathan $
  --$Date: 2014/11/04 14:37:25 $
  --$ $Log: INBOUND_ORDER_INFO_ofssit.sql,v $
  --$ Revision 1.8  2017/02/22 15:56:12  smeganathan
  --$ CR47779  added new column x_vendor_id in x_biz_order_dtl
  --$
  --$ Revision 1.7  2016/04/22 23:28:52  nmuthukkaruppan
  --$ CR38620 - eBay Integration - Modification to the shipment related column names
  --$
  --$ Revision 1.6  2016/04/21 18:18:36  nmuthukkaruppan
  --$ CR 38620: eBay Integration & Store Front
  --$
  --$ Revision 1.5  2014/11/04 14:37:25  cpannala
  --$ Cr30348 Changes for diff SIT env
  --$
  --$ Revision 1.4  2014/09/08 16:16:28  cpannala
  --$ Cr30646 Fix to update the OFS View values for Plans accuratley.
  --$
  --$ Revision 1.3  2014/09/02 09:08:02  ahabeeb
  --$ *** empty log message ***
  --$
  --$ Revision 1.1  2014/08/13 14:57:23  cpannala
  --$ CR30255 inbound to pull data from OFS to Clarify
  --$
  --$ Revision 1.1  2014/08/13 10:44:15  cpannala
  --$ CR25490 inbound procedure added
* -----------------------------------------------------------------------------------------------------
*******************************************************************************************************/
  CURSOR order_dtl_cur
  IS
   SELECT eoi.rowid, eoi.*
    FROM tf.TF_ECOMM_ORDERS_INTERFACE@OFSPRD eoi
    WHERE EXTRACT_FLAG = 'NEW'
    AND CREATION_DATE <= sysdate
    and ECOMMERCE_ORDER_NUMBER in (select c_orderid from sa.x_biz_purch_hdr);--Cr30348 Changes for diff SIT env
  order_dtl_rec order_dtl_cur%rowtype;
  l_item_value VARCHAR2(50);
  l_objid number;
  l_counter number := 0;
BEGIN
  FOR order_dtl_rec IN order_dtl_cur
  LOOP
   l_counter := l_counter + 1;
   l_objid := SEQU_order_dtl.nextval;
    IF order_dtl_rec.ITEM_TYPE = 'PLAN'THEN
      BEGIN
        SELECT X_TARGET_PART_NUM2
        INTO l_item_value
        FROM x_ff_part_num_mapping
        WHERE X_SOURCE_PART_NUM = order_dtl_rec.ITEM_part;
      EXCEPTION
      WHEN OTHERS THEN
        UTIL_PKG.INSERT_ERROR_TAB_PROC( IP_ACTION => 'Order details',
                                        IP_KEY => order_dtl_rec.ITEM_part,
                                        IP_PROGRAM_NAME => 'INBOUND_ORDER_INFO_ofssit',
                                        ip_error_text => 'Plan Value Not Found');
      END;
    END IF;
    BEGIN
      INSERT INTO sa.x_biz_order_dtl
              ( objid ,
                x_item_type ,
                x_item_value ,
                x_item_part ,
                x_ECOM_ORDER_NUMBER,
                x_OFS_ORDER_NUMBER ,
                x_ORDER_LINE_NUMBER,
                x_amount ,
                x_sales_tax_amount ,
                x_e911_tax_amount ,
                x_usf_tax_amount ,
                x_rcrf_tax_amount ,
                x_total_tax_amount ,
                x_total_amount ,
                x_ecom_group_id,
                x_EXTRACT_FLAG ,
                x_EXTRACT_DATE ,
                x_CREATION_DATE ,
                x_CREATE_BY ,
                x_LAST_UPDATE_DATE,
                x_LAST_UPDATED_BY,
                BIZ_ORDER_DTL2BIZ_PURCH_HDR_CR ,
                BIZ_ORDER_DTL2BIZ_order_dtl_cr,
                --CR38620 - Modified to add the shipment related details
                SHIPMENT_TRACKING_NUMBER,
                SHIPMENT_DATE,
                SHIPMENT_CARRIER,
                x_vendor_id   -- CR47779
              )
              VALUES
              ( l_objid,
                order_dtl_rec.ITEM_TYPE,
                NVL(order_dtl_rec.ITEM_value ,l_item_value),
                order_dtl_rec.ITEM_part ,
                order_dtl_rec.ECOMMERCE_ORDER_NUMBER,
                order_dtl_rec.OFS_ORDER_NUMBER,
                order_dtl_rec.ORDER_LINE_NUMBER,
                order_dtl_rec.AMOUNT ,
                order_dtl_rec.SALES_TAX_AMOUNT ,
                order_dtl_rec.E911_TAX_AMOUNT ,
                order_dtl_rec.usf_tax_amount,
                order_dtl_rec.rcrf_tax_amount,
                order_dtl_rec.total_tax_amount,
                order_dtl_rec.total_amount,
                order_dtl_rec.GROUP_ID,
                'YES',  --order_dtl_rec.EXTRACT_FLAG ,
                sysdate,--order_dtl_rec.EXTRACT_DATE,
                order_dtl_rec.CREATION_DATE,
                order_dtl_rec.CREATE_BY,
                sysdate,            --order_dtl_rec.LAST_UPDATE_DATE,
                'INBOUND_ORDER_INFO_ofssit',--order_dtl_rec.LAST_UPDATED_BY
                null,
                null,
                --CR38620 - Modified to add the shipment related details
                order_dtl_rec.TRACKING_NUMBER,
                order_dtl_rec.SHIPPED_DATE,
                order_dtl_rec.CARRIER,
                order_dtl_rec.vendor_id   -- CR47779
              );
      UPDATE tf.TF_ECOMM_ORDERS_INTERFACE@OFSPRD eoi
        SET eoi.EXTRACT_FLAG = 'YES',
            eoi.EXTRACT_DATE = SYSDATE,
            eoi.LAST_UPDATE_DATE = SYSDATE,
            eoi.LAST_UPDATED_BY = 'INBOUND_ORDER_INFO_ofssit'
        WHERE rowid = order_dtl_rec.rowid;
        /*ITEM_VALUE = NVL(order_dtl_rec.ITEM_value ,l_item_value)
        AND ITEM_PART = order_dtl_rec.ITEM_part
        AND ECOMMERCE_ORDER_NUMBER = order_dtl_rec.ECOMMERCE_ORDER_NUMBER
        AND OFS_ORDER_NUMBER = order_dtl_rec.OFS_ORDER_NUMBER;*/
        IF l_counter = 800 THEN
            COMMIT;
            l_counter := 0;
        END IF;
    EXCEPTION
      WHEN OTHERS THEN
        UPDATE  x_biz_order_dtl
        SET     x_EXTRACT_FLAG = 'NO'
        WHERE   objid = l_objid;
        --
         UTIL_PKG.INSERT_ERROR_TAB_PROC( IP_ACTION => 'Order details',
                                          IP_KEY => order_dtl_rec.ITEM_value,
                                          IP_PROGRAM_NAME => 'INBOUND_ORDER_INFO_ofssit',
                                          ip_error_text => 'ESN/Plan Value Not Found');
    END;
  END LOOP;
  COMMIT;
END INBOUND_ORDER_INFO_ofssit;
/