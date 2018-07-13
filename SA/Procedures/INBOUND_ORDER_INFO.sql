CREATE OR REPLACE PROCEDURE sa."INBOUND_ORDER_INFO"
IS
/*******************************************************************************************************
* --$RCSfile: inbound_order_info.sql,v $
  --$Revision: 1.10 $
  --$Author: abustos $
  --$Date: 2018/04/09 21:33:35 $
  --$ $Log: inbound_order_info.sql,v $
  --$ Revision 1.10  2018/04/09 21:33:35  abustos
  --$ CR57145 - Pull the ship_tax from OFS to CLFY
  --$
  --$ Revision 1.9  2017/07/24 21:01:38  smeganathan
  --$ Reinitialized a local variable within LOOP
  --$
  --$ Revision 1.8  2017/02/22 15:56:12  smeganathan
  --$ CR47779  added new column x_vendor_id in x_biz_order_dtl
  --$
  --$ Revision 1.7  2016/04/22 23:28:52  nmuthukkaruppan
  --$ CR38620 - eBay Integration - Modification to the shipment related column names
  --$
  --$ Revision 1.6  2016/04/21 18:18:36  nmuthukkaruppan
  --$ CR 38620: eBay Integration and Store Front
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
    SELECT eoi.ROWID, eoi.*
    FROM tf.tf_ecomm_orders_interface@OFSPRD eoi
    WHERE extract_flag   = 'NEW'
      AND creation_date <= SYSDATE ;
  order_dtl_rec order_dtl_cur%ROWTYPE;

  l_item_value VARCHAR2(50);
  l_objid      NUMBER;
  l_counter    NUMBER := 0;

BEGIN
  FOR order_dtl_rec IN order_dtl_cur
  LOOP
    l_counter    := l_counter + 1;
    l_objid      := sequ_order_dtl.NEXTVAL;
    l_item_value := NULL; -- CR51737 Reintialize the variable

    IF order_dtl_rec.item_type = 'PLAN'
    THEN
      BEGIN
        SELECT x_target_part_num2
          INTO l_item_value
        FROM x_ff_part_num_mapping
        WHERE x_source_part_num = order_dtl_rec.item_part;
      --
      EXCEPTION
      WHEN OTHERS THEN
        l_item_value  :=  NULL; -- CR51737
        util_pkg.insert_error_tab_proc( ip_action       => 'Order details',
                                        ip_key          => order_dtl_rec.item_part,
                                        ip_program_name => 'inbound_order_info',
                                        ip_error_text   => 'Plan Value Not Found');
      END;
    END IF;
    --
    BEGIN
      INSERT INTO sa.x_biz_order_dtl
              ( objid ,
                x_item_type ,
                x_item_value ,
                x_item_part ,
                x_ecom_order_number,
                x_ofs_order_number ,
                x_order_line_number,
                x_amount ,
                x_sales_tax_amount ,
                x_e911_tax_amount ,
                x_usf_tax_amount ,
                x_rcrf_tax_amount ,
                x_total_tax_amount ,
                x_total_amount ,
                x_ecom_group_id,
                x_extract_flag ,
                x_extract_date ,
                x_creation_date ,
                x_create_by ,
                x_last_update_date,
                x_last_updated_by,
                biz_order_dtl2biz_purch_hdr_cr ,
                biz_order_dtl2biz_order_dtl_cr,
                --CR38620 - Modified to add the shipment related details
                shipment_tracking_number,
                shipment_date,
                shipment_carrier,
                x_vendor_id,      --CR47779
                x_ship_tax_amount --CR57145 Include the shipping tax for reconciliation purposes
              )
          VALUES
              ( l_objid,
                order_dtl_rec.item_type,
                NVL(order_dtl_rec.item_value ,l_item_value),
                order_dtl_rec.item_part ,
                order_dtl_rec.ecommerce_order_number,
                order_dtl_rec.ofs_order_number,
                order_dtl_rec.order_line_number,
                order_dtl_rec.amount ,
                order_dtl_rec.sales_tax_amount ,
                order_dtl_rec.e911_tax_amount ,
                order_dtl_rec.usf_tax_amount,
                order_dtl_rec.rcrf_tax_amount,
                order_dtl_rec.total_tax_amount,
                order_dtl_rec.total_amount,
                order_dtl_rec.group_id,
                'YES',  --order_dtl_rec.EXTRACT_FLAG ,
                SYSDATE,--order_dtl_rec.EXTRACT_DATE,
                order_dtl_rec.creation_date,
                order_dtl_rec.create_by,
                SYSDATE,             --order_dtl_rec.LAST_UPDATE_DATE,
                'INBOUND_ORDER_INFO',--order_dtl_rec.LAST_UPDATED_BY
                NULL,
                NULL,
                --CR38620 - Modified to add the shipment related details
                order_dtl_rec.tracking_number,
                order_dtl_rec.shipped_date,
                order_dtl_rec.carrier,
                order_dtl_rec.vendor_id,            --CR47779
                NVL(order_dtl_rec.ship_tax_amount,0)--CR57145
              );
      --
      UPDATE  tf.TF_ECOMM_ORDERS_INTERFACE@ofsprd eoi
         SET  eoi.EXTRACT_FLAG      = 'YES',
              eoi.EXTRACT_DATE      = SYSDATE,
              eoi.LAST_UPDATE_DATE  = SYSDATE,
              eoi.LAST_UPDATED_BY   = 'inbound_order_info'
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
      UPDATE x_biz_order_dtl
         SET x_extract_flag = 'NO'
      WHERE  objid = l_objid;
      --
      util_pkg.insert_error_tab_proc( ip_action       => 'Order details',
                                      ip_key          => order_dtl_rec.item_value,
                                      ip_program_name => 'inbound_order_info',
                                      ip_error_text   => 'ESN/Plan Value Not Found');
    END;
  --
  END LOOP;

  COMMIT;
END inbound_order_info;
/