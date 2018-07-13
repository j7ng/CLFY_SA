CREATE OR REPLACE PROCEDURE sa."IG_THROTTLING_PRC" (
                                              IP_ORDER_TYPE in varchar2,
                                              IP_TEMPLATE IN VARCHAR2,
                                              IP_TECHNOLOGY_FLAG in varchar2,
                                              IP_STATE_FIELD in varchar2,
                                              IP_ZIP_CODE in varchar2,
                                              IP_APPLICATION_SYSTEM in varchar2,
                                              --IP_RATE_PLAN IN VARCHAR2,
                                              IP_ACCOUNT_NUM in varchar2,
                                              IP_DEALER_CODE in varchar2,
                                              IP_DEBUG IN BOOLEAN DEFAULT FALSE
                                              )
as
--exec IG_THROTTLING_PRC('R','CSI_TLG','G','FL','33178','APN_UPDATE','FLP','DQ601',    TRUE);
------------------------------------------------------------------------
--$RCSfile: ig_throttling_prc.sql,v $
--$Revision: 1.10 $
--$Author: akhan $
--$Date: 2013/03/26 16:35:11 $
--$Log: ig_throttling_prc.sql,v $
--Revision 1.10  2013/03/26 16:35:11  akhan
--Added the ICCID to ig_transaction
--
--Revision 1.8  2013/03/20 20:03:41  dbecerril
--Gets carrier_id from part_inst
--Revision 1.9  2014/06/06 egarcia
--changed main_curs to look for x_apn_update_flag = 'P' instead of null
------------------------------------------------------------------------

V_TRANS_ID NUMBER;

CURSOR MAIN_CURS IS
SELECT DEV.OBJID,DEV.X_MIN,DEV.X_ESN,DEV.X_NEW_RATE_PLAN,CARR.X_CARRIER_ID,phone.x_iccid--, info.account_num,info.dealer_code
from sa.X_DEVICE_MGMT dev, table_part_inst tpi ,table_x_carrier carr, table_part_inst phone--,table_x_call_trans ct--,SA.x_cingular_mrkt_info info
where 1=1
   AND DEV.X_APN_UPDATE_FLAG = 'P' --changed on 6/6/2014 by Elliot via ticket 789479 --IS NULL --not yet loaded
   --and DEV.X_TRANSACTION_ID is null
    AND TPI.PART_SERIAL_NO = DEV.X_MIN
    and phone.part_serial_no = dev.x_esn
   and DEV.X_LAST_UPDATE_DATE >= TRUNC(sysdate)-5 --Time limit of 5 days back
  -- AND TPI.X_PART_INST_STATUS = '52'--Active phone
   AND DEV.X_MIN NOT LIKE 'T%'
   AND LENGTH(DEV.X_MIN) = 10
  /*AND CT.X_TRANSACT_DATE = (--Get Carrier Id
                              SELECT MAX(X_TRANSACT_DATE)
                              FROM TABLE_X_CALL_TRANS
                              WHERE X_SERVICE_ID = dev.X_ESN AND ROWNUM < 2
                            )
  and CARR.OBJID(+) = CT.X_CALL_TRANS2CARRIER */
  AND TPI.PART_INST2CARRIER_MKT = CARR.OBJID(+)
  AND X_TRANSACTION_ID IS NULL
  --and info.zip = (select x_zipcode from table_site_part where x_service_id = DEV.X_ESN and part_status = 'Active' and rownum < 2) --get Dealer_code and account num
  and rownum < 1001; --load 1000 per run

begin
for main_rec in main_curs
  loop
   insert into ig_transaction
         (action_item_id,
          transaction_id,
          order_type,
          template,
          status,
          min,
          msid,
          esn,
          esn_hex,
          technology_flag,
          state_field,
          ZIP_CODE,
          APPLICATION_SYSTEM,
          RATE_PLAN,
          ACCOUNT_NUM,
          DEALER_CODE,
          CARRIER_ID,
          ICCID

)
  values ('APN'||MAIN_REC.X_MIN,                --action_item_id,
          GW1.TRANS_ID_SEQ.NEXTVAL,             --transaction_id
          IP_ORDER_TYPE,                                  --order_type
          IP_TEMPLATE,                            --template
          'Q',                                  --status
          MAIN_REC.X_MIN,                       --min
          MAIN_REC.X_MIN,                       --msid
          MAIN_REC.X_ESN,                       --esn
          IGATE.F_GET_HEX_ESN(MAIN_REC.X_ESN),  --esn_hex
          IP_TECHNOLOGY_FLAG,                                  --technology_flag
          IP_STATE_FIELD,                                 --state_field
          IP_ZIP_CODE,                              --ZIP_CODE
          IP_APPLICATION_SYSTEM,                         --application_system
          MAIN_REC.X_NEW_RATE_PLAN,                              --rate_plan
          IP_ACCOUNT_NUM,                                                            --          ACCOUNT_NUM,
          IP_DEALER_CODE,                                                --        DEALER_CODE,
          MAIN_REC.x_carrier_id,                                               --      CARRIER_ID
          MAIN_REC.x_iccid--ICCID

) returning transaction_id into v_trans_id;

--FLAG WILL NOW BE SET WHEN ACTION ITEM COMES BACK WITH STATUS 'S'
  UPDATE sa.X_DEVICE_MGMT
     set X_TRANSACTION_ID = V_TRANS_ID
   WHERE objid = MAIN_REC.objid;

  IF IP_DEBUG then
    DBMS_OUTPUT.PUT_LINE('Count: ' || SQL%ROWCOUNT);
  end if;
   commit;

  end LOOP;
end;
/