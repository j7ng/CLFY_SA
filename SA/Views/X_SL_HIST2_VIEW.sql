CREATE OR REPLACE FORCE VIEW sa.x_sl_hist2_view (lid,x_esn,x_event_dt,x_insert_date,x_event_value,x_event_code,x_event_data,x_min,username,x_sourcesystem,x_code_number,x_src_table,x_src_objid,x_program_enrolled_id) AS
SELECT
LID,X_ESN,X_EVENT_DT,SYSDATE AS X_INSERT_DATE ,X_EVENT_VALUE,X_EVENT_CODE,X_EVENT_DATA,X_MIN,
USERNAME,X_SOURCESYSTEM,X_CODE_NUMBER,X_SRC_TABLE,X_SRC_OBJID,NULL AS X_PROGRAM_ENROLLED_ID
FROM
(
-- subs
select   ht.LID,
         ht.x_event_dt ,
         ht.X_EVENT_CODE,
         ht.X_EVENT_VALUE,
         ht.X_EVENT_DATA,
         ht.X_CODE_NUMBER,
         ht.X_ESN,
         ht.X_MIN,
         ht.USERNAME,
         ht.X_SOURCESYSTEM,
         ht.X_SRC_TABLE,
         ht.X_SRC_OBJID
FROM   sa.X_SL_HIST ht
union
-- ota transactions
select  esns.LID,
        ota.X_TRANSACTION_DATE,
        701,
        ''||ct.X_TOTAL_UNITS,
       'STATUS:'||ota.X_STATUS||',ACTION:'||ota.X_ACTION_TYPE||',REASON:'||nvl(ota.X_REASON,'null'),
        ''||0,
        ota.X_ESN,
        ota.X_MIN,
       'SYSTEM', -- can be calltrans2user
        ota.X_MODE,
       'table_x_ota_transaction',
        ota.OBJID
from sa.table_x_ota_transaction ota, sa.X_SL_ESNS_VIEW esns, table_x_call_trans ct
where esns.X_ESN = ota.X_ESN and ota.X_OTA_TRANS2X_CALL_TRANS = ct.objid
union
-- minutes delivery (program_gencode)
select  esns.LID,
        NVL(pg.X_UPDATE_STAMP, pg.X_INSERT_DATE),
        702,
        '',--ct.X_TOTAL_UNITS,
        null,
        pg.X_ERROR_NUM,
        pg.X_ESN,
        '', -- no min
        'SYSTEM', -- can be calltrans2user
        'BILLING', -- sourcesystem
        'x_program_gencode',
         pg.OBJID
from sa.x_program_gencode pg, sa.X_SL_ESNS_VIEW esns--, table_x_call_trans ct
where esns.X_ESN = pg.X_ESN                    --WAS OUTER JOIN, WHY:1 and pg.GENCODE2CALL_TRANS = ct.objid(+)
and pg.X_STATUS='PROCESSED'
union
-- minutes delivery ackd (ota_ack)
select    esns.LID,
          ot.X_TRANSACTION_DATE, --nvl(otd.X_RECEIVED_DATE,otd.X_SENT_DATE),
          703,
          ''||oa.X_UNITS,
          'SEQ:'||oa.X_PHONE_SEQUENCE||',STATUS:'||ot.X_STATUS,
          ''||0,
          ot.X_ESN,
          '', -- no min
          'SYSTEM', -- can be calltrans2user
          'BILLING', -- sourcesystem
          'table_x_ota_ack',
           oa.OBJID
from sa.table_x_ota_ack oa, sa.X_SL_ESNS_VIEW esns, table_x_ota_trans_dtl otd, sa.table_x_ota_transaction ot
where 1=1
and esns.X_ESN = ot.X_ESN
and oa.X_OTA_ACK2X_OTA_TRANS_DTL = otd.objid
and otd.X_OTA_TRANS_DTL2X_OTA_TRANS = ot.objid
and ot.X_ACTION_TYPE=3
union
-- minutes delivery sent (pending_red)
select  esns.LID,
         pph.X_RQST_DATE,
         704,
         '',--||pph.X_UNITS,
         null,
         ''||0,
         sp.X_SERVICE_ID,
         '', -- no min
         'SYSTEM', -- can be calltrans2user
         'BILLING', -- sourcesystem
         'table_x_pending_redemption',
          pr.OBJID
from sa.table_x_pending_redemption pr, table_site_part sp, sa.X_SL_ESNS_VIEW esns, sa.x_program_purch_hdr pph
where pr.x_pend_red2site_part = sp.objid and esns.X_ESN = sp.X_SERVICE_ID and pr.PEND_RED2PROG_PURCH_HDR = pph.objid
union
-- activations, deactivations
select  esns.LID,
         ct.X_TRANSACT_DATE,
         (CASE WHEN ct.X_ACTION_TYPE=1 THEN 706 ELSE 705 END),
         ''||ct.X_TOTAL_UNITS,
         null,
         ''||0,
         ct.X_SERVICE_ID,
         '', -- no min
         'SYSTEM', -- can be calltrans2user
         ct.X_SOURCESYSTEM, -- sourcesystem
         'table_x_call_trans',
          ct.OBJID
from sa.table_x_call_trans ct, sa.X_SL_ESNS_VIEW esns
where esns.X_ESN = ct.X_SERVICE_ID
and (ct.X_ACTION_TYPE=2 or ct.X_ACTION_TYPE=1)
)
WHERE LID !=-1;