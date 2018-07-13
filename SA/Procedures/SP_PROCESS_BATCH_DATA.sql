CREATE OR REPLACE PROCEDURE sa."SP_PROCESS_BATCH_DATA"
/***********************************************************************************/
/* Name         :   GW1.SP_PROCESS_BATCH_DATA
/* Purpose      :   To insert batch processed data into table (BATCHIGTRANSACTION)
/*
/* Parameters   :   ip_order_type, ip_ignoreESN, op_result, op_msg
/* Author       :   Gerald Pintado
/* Date         :   03/29/2005
/* Revisions    :
/* Version     Date       Who        Purpose
/* -------     --------   --------   -------------------------------------
/* 1.0         03/29/2005  Gpintado   Initial revision
/* 1.1 /1.4    03/10/2006  VAdapa   CR4981_4982 Data Phones Logic
/***********************************************************************************/

/***********************************************************************************/
/* NEW PVCS STRUCTURE
   Version  Date       Who        Purpose
/* -------  --------   --------   -------------------------------------
/* 1.0     08/26/2008  CLindner   added NET10  changes to table_x_carrir_features
/* 1.1/1.2     08/31/2009  NGuada     BRAND_SEP Separate the Brand and Source System

/***********************************************************************************/
(
   ip_order_type   IN       VARCHAR2,
   ip_ignoreesn    IN       VARCHAR2,
   op_result       OUT      VARCHAR2,
   op_msg          OUT      VARCHAR2
)
IS
   CURSOR c1
   IS
      SELECT j.ROWID,
             gw1.trans_id_seq.NEXTVAL + (POWER (2, 28)) action_item_id,
             g.x_npa, b.x_carrier_id carrier_id, A.part_serial_no MIN,
             c.part_serial_no esn,
             DECODE (e.x_technology,
                     'ANALOG', 'A',
                     'TDMA', 'T',
                     'CDMA', 'C',
                     'GSM', 'G'
                    ) technology_flag,
             g.x_dealer_code dealer_code, g.x_market_code market_code,
             g.x_ld_account_num account_num, f.x_rate_plan rate_plan,
             'AOL' transmission_method, 'Q' status, 'Y' q_transaction,
             DECODE (f.x_voicemail, '1', 'Y', '0', 'N') voice_mail,
             f.x_vm_code voice_mail_package,
             DECODE (f.x_caller_id, '1', 'Y', '0', 'N') caller_id,
             f.x_id_code caller_id_package,
             DECODE (f.x_call_waiting, '1', 'Y', '0', 'N') call_waiting,
             f.x_cw_code call_waiting_package,
             DECODE (f.x_sms, '1', 'Y', '0', 'N') sms,
             f.x_sms_code sms_package,
             DECODE (f.x_dig_feature, '1', 'Y', '0', 'N') digital_feature,
             f.x_digital_feature digital_feature_code, A.x_msid msid,
             h.x_zipcode zip_code, j.esn batch_esn
        FROM TABLE_X_ORDER_TYPE g,
             TABLE_PART_INST A,
             TABLE_X_CARRIER b,
             TABLE_PART_INST c,
             TABLE_MOD_LEVEL d,
             TABLE_PART_NUM e,
             TABLE_X_CARRIER_FEATURES f,
             TABLE_SITE_PART h,
             TABLE_X_TRANS_PROFILE i,
             gw1.igbatchdata j
       WHERE A.part_serial_no = j.MIN
         AND j.processed = 0
         AND A.x_part_inst_status || '' <> '13'
         AND A.part_inst2carrier_mkt = g.x_order_type2x_carrier
         AND (A.x_npa = g.x_npa OR g.x_npa IS NULL)
         AND (A.x_nxx = g.x_nxx OR g.x_nxx IS NULL)
         AND g.x_order_type || '' = 'Activation'
         AND g.x_order_type2x_trans_profile = i.objid
         AND A.part_inst2carrier_mkt = b.objid
         AND A.part_to_esn2part_inst = c.objid
         AND c.x_part_inst2site_part = h.objid
         AND c.part_serial_no = h.x_service_id
         AND h.objid = (SELECT MAX (objid)
                          FROM TABLE_SITE_PART
                         WHERE x_service_id = c.part_serial_no)
         AND c.n_part_inst2part_mod = d.objid
         AND d.part_info2part_num = e.objid
         AND b.objid = f.x_feature2x_carrier
--cr7691
-- BRAND_SEP
	 --AND f.x_restricted_use = e.x_restricted_use
	 AND f.x_features2bus_org = e.part_num2bus_org
         AND f.x_technology || '' = e.x_technology
         AND f.x_data = e.x_data_capable;                        --CR4981_4982

   counter   NUMBER        := 0;
   v_min     VARCHAR2 (20) := '0';
BEGIN
   FOR c1_rec IN c1
   LOOP
      IF (v_min <> c1_rec.MIN)
      THEN
         IF ((c1_rec.esn = c1_rec.batch_esn) OR (ip_ignoreesn = 'Y'))
         THEN
            INSERT INTO gw1.ig_transaction_batch
                        (action_item_id, transaction_id,
                         carrier_id, order_type, MIN,
                         esn, technology_flag,
                         market_code, rate_plan,
                         transmission_method, status,
                         q_transaction, voice_mail,
                         voice_mail_package, caller_id,
                         caller_id_package, call_waiting,
                         call_waiting_package, sms,
                         sms_package, digital_feature,
                         digital_feature_code, msid,
                         zip_code
                        )
                 VALUES (c1_rec.action_item_id, c1_rec.action_item_id,
                         c1_rec.carrier_id, ip_order_type, c1_rec.MIN,
                         c1_rec.esn, c1_rec.technology_flag,
                         c1_rec.market_code, c1_rec.rate_plan,
                         c1_rec.transmission_method, c1_rec.status,
                         c1_rec.q_transaction, c1_rec.voice_mail,
                         c1_rec.voice_mail_package, c1_rec.caller_id,
                         c1_rec.caller_id_package, c1_rec.call_waiting,
                         c1_rec.call_waiting_package, c1_rec.sms,
                         c1_rec.sms_package, c1_rec.digital_feature,
                         c1_rec.digital_feature_code, c1_rec.msid,
                         c1_rec.zip_code
                        );

            IF SQL%ROWCOUNT > 0
            THEN
               counter := counter + 1;
            END IF;

            UPDATE gw1.igbatchdata
               SET processed = 1
             WHERE ROWID = c1_rec.ROWID;

            IF MOD (counter, 100) = 0
            THEN
               COMMIT;
            END IF;
         END IF;
      END IF;

      v_min := c1_rec.MIN;
   END LOOP;

   COMMIT;
   op_result := 'TRUE';
   op_msg := 'SUCCESSFUL QTY: ' || counter;
EXCEPTION
   WHEN OTHERS
   THEN
      op_result := 'FALSE';
      op_msg := SUBSTR (SQLERRM, 1, 200);
      DBMS_OUTPUT.put_line ('Error has occured: ' || SQLERRM);
END;
/