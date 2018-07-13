CREATE OR REPLACE PROCEDURE sa.Wms_Manual_Update_Prc(
                                                                       in_start_date IN DATE DEFAULT TRUNC(SYSDATE)
                                                                                                                                      )
AS
/*******************************************************************
Description: This procedure is to update   sa.x_migr_extra_info table
             x_flag_migration  column after processing orders into OFS.
  The procedure updates to Status 'M' -(Manual) and process_date to sysdate after processing 'Y' status orders
Requirement author:  Jason virtue
Developer:                    Ramesh Vanapalli
Date:                               11/14/05
********************************************************************/

CURSOR  Update_wms_orders_cur
IS
 SELECT       '940' RECORD_CODE,
              ' ' TF_ORDER_NUMBER,
              'OR' TRANSACTION_TYPE_CODE,
              c.ID_NUMBER REF_NUM,
              'TW640' CUSTOMER_NUMBER,
              c.ALT_FIRST_NAME || ' ' || c.ALT_LAST_NAME SHIP_TO_NAME,
              c.ALT_ADDRESS SHIP_TO_ADDRESS,
              c.ALT_CITY SHIP_TO_CITY,
              c.ALT_STATE SHIP_TO_STATE,
              c.ALT_ZIPCODE SHIP_TO_ZIP,
              '0616960000013' LOCATION_CODE,
              c.ALT_FIRST_NAME || ' ' || c.ALT_LAST_NAME CONTACT_TO_NAME,
              c.ALT_PHONE_NUM CONTACT_TO_PHONE,
  	          c.ALT_FIRST_NAME || ' ' || c.ALT_LAST_NAME STORE_NUMBER,
             TO_CHAR(TRUNC(SYSDATE) + 3,'YYYYMMDD') DELIVERY_DATE,
              1 LINE_NUMBER,
              c.X_REPL_PART_NUM TF_PART_NUMBER,
              1 QUANTITY,
              c.title CASE_TITLE,
              g.TITLE CASE_STATUS,
              f.E_MAIL SHIP_TO_EMAIL,
              A.x_migra2x_case   x_migra2x_case
            FROM TABLE_CONTACT f ,
                 TABLE_GBST_ELM g,
				 sa.X_MIGR_EXTRA_INFO A,
                 TABLE_CASE c
            WHERE c.casests2gbst_elm = g.objid(+)
            AND c.case_reporter2contact = f.objid(+)
            AND c.X_REPL_PART_NUM IS NOT NULL
            AND c.objid = A.x_migra2x_case
            AND A.x_flag_migration = 'Y';

    v_error_text				VARCHAR2(4000);
    v_error_code           		NUMBER;
    nCommitCount                NUMBER :=0;
    nUpdateCount                NUMBER :=0;
BEGIN

       FOR  Update_wms_orders_rec IN Update_wms_orders_cur  LOOP


	   INSERT INTO WMS_MANUAL_ORDERS_PROCESS
	               (RECORD_CODE,
				   TF_ORDER_NUMBER,
				   TRANSACTION_TYPE_CODE,
				   REF_NUM,
				   CUSTOMER_NUMBER,
				   SHIP_TO_NAME,
				   SHIP_TO_ADDRESS,
				   SHIP_TO_CITY,
				   SHIP_TO_STATE,
				   SHIP_TO_ZIP,
				   LOCATION_CODE,
				   CONTACT_TO_NAME,
				   CONTACT_TO_PHONE,
				   STORE_NUMBER,
				   DELIVERY_DATE,
				   LINE_NUMBER,
				   TF_PART_NUMBER,
				   QUANTITY,
				   CASE_TITLE,
				   CASE_STATUS,
				   SHIP_TO_EMAIL,
				   X_MIGRA2X_CASE,
				   LOAD_DATE)
		VALUES
		        (Update_wms_orders_rec.RECORD_CODE,
					Update_wms_orders_rec.TF_ORDER_NUMBER,
					Update_wms_orders_rec.TRANSACTION_TYPE_CODE,
					Update_wms_orders_rec.REF_NUM,
					Update_wms_orders_rec.CUSTOMER_NUMBER,
					Update_wms_orders_rec.SHIP_TO_NAME,
					Update_wms_orders_rec.SHIP_TO_ADDRESS,
					Update_wms_orders_rec.SHIP_TO_CITY,
					Update_wms_orders_rec.SHIP_TO_STATE,
					Update_wms_orders_rec.SHIP_TO_ZIP,
					Update_wms_orders_rec.LOCATION_CODE,
					Update_wms_orders_rec.CONTACT_TO_NAME,
					Update_wms_orders_rec.CONTACT_TO_PHONE,
					Update_wms_orders_rec.STORE_NUMBER,
					Update_wms_orders_rec.DELIVERY_DATE,
					Update_wms_orders_rec.LINE_NUMBER,
					Update_wms_orders_rec.TF_PART_NUMBER,
					Update_wms_orders_rec.QUANTITY,
					Update_wms_orders_rec.CASE_TITLE,
					Update_wms_orders_rec.CASE_STATUS,
					Update_wms_orders_rec.SHIP_TO_EMAIL,
					Update_wms_orders_rec.X_MIGRA2X_CASE,
                     SYSDATE);

        nCommitCount  :=  nCommitCount +1;

               UPDATE 	sa.X_MIGR_EXTRA_INFO
               SET     x_flag_migration  ='M' ,
                       x_date_process    = SYSDATE
               WHERE  x_migra2x_case   =Update_wms_orders_rec.x_migra2x_case ;

				nUpdateCount    := nUpdateCount    +SQL%ROWCOUNT;

       END LOOP;

COMMIT;
      dbms_output.put_line ('Records Processed:  '|| nCommitCount );
      dbms_output.put_line ('Orders  Updated to M status : ' ||nUpdateCount );

EXCEPTION
    WHEN OTHERS THEN
      v_error_text := SQLERRM;
      v_error_code := SQLCODE;
      dbms_output.put_line ('Exception Occured while updating x_migr_extra_info ' || '  v_error=' || v_error_text ||'; v_error_code=' || v_error_code);

END;
/