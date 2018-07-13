CREATE OR REPLACE FORCE VIEW sa.ota_resend_personality_v (ot_objid,otd_objid,x_min,x_esn,x_counter,x_sequence,x_dll,x_psms_text) AS
SELECT /*+ ORDERED INDEX(otd, IND_X_OTA_TRANS_DTL2TRANS) */
       ot.OBJID ot_objid ,
       otd.OBJID otd_objid ,
       ot.X_MIN ,
       ot.X_ESN ,
       ot.X_COUNTER ,
       pi.X_SEQUENCE ,
       pn.X_DLL ,
       otd.X_PSMS_TEXT
  FROM
       TABLE_X_OTA_TRANSACTION ot,
       TABLE_X_OTA_TRANS_DTL otd ,
       TABLE_PART_INST pi,
       TABLE_MOD_LEVEL ml ,
       TABLE_PART_NUM pn
 WHERE 1=1
   AND pn.OBJID  = ml.PART_INFO2PART_NUM
   AND ml.OBJID = pi.N_PART_INST2PART_MOD
   AND pi.X_DOMAIN||'' = 'PHONES'
   AND pi.PART_SERIAL_NO = ot.X_ESN
   and otd.X_RESENT_DATE IS NULL
   AND otd.X_RECEIVED_DATE IS NULL
   AND otd.OBJID+0 = ( SELECT /*+ INDEX(otd2, IND_X_OTA_TRANS_DTL2TRANS) */
                            MIN(otd2.objid)
                       FROM TABLE_X_OTA_TRANS_DTL otd2
                      WHERE otd2.X_OTA_TRANS_DTL2X_OTA_TRANS = ot.OBJID )
   and otd.X_OTA_TRANS_DTL2X_OTA_TRANS = ot.OBJID
   AND otd.X_SENT_DATE < SYSDATE - ( .000694444 * 1 )
   AND ot.X_ACTION_TYPE LIKE NVL('6', '%')
   AND ot.X_STATUS = 'OTA PENDING'
   AND ROWNUM < 200 ;