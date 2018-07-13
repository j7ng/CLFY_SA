CREATE OR REPLACE PACKAGE BODY sa."OTA_TRANS_PKG"
IS
   /************************************************************************************************
   |    Copyright   Tracfone  Wireless Inc. All rights reserved
   |
   | PURPOSE  :
   | FREQUENCY:
   | PLATFORMS:
   |
   | REVISIONS:
   | VERSION  DATE        WHO              PURPOSE
   | -------  ---------- -----             ------------------------------------------------------
   | 1.0      03/11/05   Novak Lalovic     Initial revision
       | 1.1      06/27/05   Shaowei Luo       Added p_ota_trans_objid OUT parameter to create_mrkt_transaction procedure
       |                                       Added new procedure: create_inq_transaction
   | 1.2      03/11/05   Novak Lalovic     Modified function get_failed_redemp_count to always return 0
   |                                       The previous logic is commented
   | 1.3      09/26/06   Vani Adapa        CR5613 - OTA Enhancements changes
   | 1.4      11/08/06   Vani Adapa        CR5613
   | 1.5      09/03/07   JAL        	   CR6292 - BUY NOW
   |************************************************************************************************/

   /******************************************************************
   | Refer to package spec for detailed description of this procedure|
   ******************************************************************/
   PROCEDURE create_transaction
--------------------------------------------------------------------------------------------
-- ota trans and trans detail required parameters  Value/Parameter description:
--------------------------------------------------------------------------------------------
   (
      p_call_trans_objid      IN   NUMBER      -- objid of TABLE_X_CALL_TRANS
                                         ,
      p_psms_counter          IN   NUMBER -- PSMS sequence number (x_counter)
                                         ,
      p_mode                  IN   VARCHAR2                     -- WEB, BATCH
                                           ,
      p_resent_date           IN   DATE            -- the value might be NULL
                                       -- ota acknowledgment parameters
   ,
      p_ota_number_of_codes   IN   NUMBER
                                         --     number of codes sent to the phone
                                             -- DLL message
   ,
      p_psms_text             IN   VARCHAR2              -- PSMS message text
                                           -- ota trans and trans detail optional params
   ,
      p_ota_trans_reason      IN   VARCHAR2 DEFAULT NULL,
      p_mobile365_id          IN   VARCHAR2 DEFAULT NULL,  -- OTA Enhancements
	  p_denomination 		  IN   VARCHAR2 DEFAULT NULL   -- Buy Now
   )
   IS
      CURSOR get_call_trans_data_cur (p_ct_objid IN NUMBER)
      IS
         SELECT ct.x_service_id esn, ct.x_min MIN, ct.x_result status,
                ct.x_ota_type ota_type, ct.x_action_type action_type,
                ct.x_ota_req_type ota_req_type, ca.x_carrier_id carrier_id
           FROM table_x_call_trans ct, table_x_carrier ca
          WHERE ct.x_call_trans2carrier = ca.objid AND ct.objid = p_ct_objid;

      get_call_trans_data_rec   get_call_trans_data_cur%ROWTYPE;
      n_ota_trans_dtl_objid     NUMBER;
      n_ota_trans_objid         NUMBER;
      n_ota_ackn_objid          NUMBER;
      d_sent_date               DATE;
      d_received_date           DATE;
   BEGIN
      OPEN get_call_trans_data_cur (p_call_trans_objid);

      FETCH get_call_trans_data_cur
       INTO get_call_trans_data_rec;

      CLOSE get_call_trans_data_cur;

      -- generate objid number for ota trans table
      n_ota_trans_objid := seq ('x_ota_transaction');

      INSERT INTO table_x_ota_transaction
                  (objid, x_transaction_date,
                   x_status,
                   x_esn, x_min,
                   x_action_type, x_mode,
                   x_counter, x_reason,
                   x_carrier_code, x_ota_trans2x_ota_mrkt_info,
                   x_ota_trans2x_call_trans,
                   x_mobile365_id, -- OTA Enhancements
				   x_ota_trans2x_denomination -- BUY NOW
                  )
           VALUES (n_ota_trans_objid, SYSDATE,
                   get_call_trans_data_rec.status,
                   get_call_trans_data_rec.esn, get_call_trans_data_rec.MIN,
                   get_call_trans_data_rec.action_type, p_mode,
                   p_psms_counter, p_ota_trans_reason,
                   get_call_trans_data_rec.carrier_id, NULL,
                   p_call_trans_objid,
                   p_mobile365_id, --O TA Enhancements
				   p_denomination -- BUY NOW
                  );

      -- generate objid number for ota trans detail table
      n_ota_trans_dtl_objid := seq ('x_ota_trans_dtl');

      -- assign sysdate to all transactions, except ota activation
      IF get_call_trans_data_rec.action_type <> ota_util_pkg.activation
      THEN
         d_sent_date := SYSDATE;
      END IF;

      INSERT INTO table_x_ota_trans_dtl
                  (objid, x_psms_text,
                   x_action_type, x_sent_date,
                   x_received_date, x_resent_date,
                   x_ota_message_direction, x_ota_trans_dtl2x_ota_trans
                  )
           VALUES (n_ota_trans_dtl_objid, p_psms_text,
                   get_call_trans_data_rec.ota_type
                                                   -- it was ACTION_TYPE before
      ,            d_sent_date,
                   d_received_date
                                  -- NULL for Activation and SYSDATE for Redemption
      ,            p_resent_date,
                   get_call_trans_data_rec.ota_req_type
                                                       -- it was OTA_TYPE before
      ,            n_ota_trans_objid
                  );

      -- generate objid number for table_x_ota_ack
      n_ota_ackn_objid := seq ('x_ota_ack');

      INSERT INTO table_x_ota_ack

                  -- populating only 3 columns:
      (            objid, x_ota_number_of_codes,
                   x_ota_ack2x_ota_trans_dtl
                                            -- not passing values for the following columns:
      ,            x_ota_error_code,
                   x_ota_error_message, x_ota_codes_accepted, x_units,
                   x_phone_sequence, x_psms_ack_msg
                  )
           VALUES (n_ota_ackn_objid, p_ota_number_of_codes,
                   n_ota_trans_dtl_objid, NULL,
                   NULL, NULL, NULL,
                   NULL, NULL
                  );

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         raise_application_error (-20001,
                                     'Failed to create ota transaction: '
                                  || SQLERRM
                                 );
   END create_transaction;

   /******************************************************************
   | Refer to package spec for detailed description of this procedure|
   ******************************************************************/
   PROCEDURE create_mrkt_transaction
                                     -- ota trans and trans detail required parameters:    Value/Parameter description:
   (
      p_esn                         IN       VARCHAR2                   -- ESN
                                                     ,
      p_min                         IN       VARCHAR2                   -- MIN
                                                     ,
      p_psms_counter                IN       NUMBER        -- ota psms counter
                                                   ,
      p_carrier_id                  IN       NUMBER
                                                   -- carrier_id from table_x_carrier
   ,
      p_mode                        IN       VARCHAR2            -- WEB, BATCH
                                                     -- DLL message
   ,
      p_psms_text                   IN       VARCHAR2     -- PSMS message text
                                                     -- ota trans and trans detail optional params:
   ,
      p_ota_trans2x_ota_mrkt_info   IN       NUMBER
            DEFAULT NULL                          -- FK to ota mrkt info table
                        ,
      p_ota_trans_reason            IN       VARCHAR2 DEFAULT NULL     -- NULL
                                                                  ,
      p_ota_trans2x_call_tran       IN       NUMBER
            DEFAULT NULL                             -- FK to call trans table
                        ,
      p_cbo_error_message           IN       VARCHAR2 DEFAULT NULL,
      -- error message passed from CBO
      p_mobile365_id                IN       VARCHAR2 DEFAULT NULL,
      -- OTA Enhancements
      p_ota_trans_objid             OUT      NUMBER         -- 06/27/05 CR4169
   )
   IS
      n_ota_trans_dtl_objid    NUMBER;
      n_ota_trans_objid        NUMBER;
      n_ota_error_info_objid   NUMBER;
      d_sent_date              DATE;
   BEGIN
      -- generate objid number for ota trans table
      n_ota_trans_objid := seq ('x_ota_transaction');

      INSERT INTO table_x_ota_transaction
                  (objid, x_transaction_date, x_status, x_esn, x_min,
                   x_action_type, x_mode, x_counter,
                   x_reason, x_carrier_code,
                   x_ota_trans2x_ota_mrkt_info, x_ota_trans2x_call_trans,
                   x_mobile365_id                          -- OTA Enhancements
                  )
           VALUES (n_ota_trans_objid, SYSDATE, 'Completed', p_esn, p_min,
                   ota_util_pkg.ota_marketing, p_mode, p_psms_counter,
                   p_ota_trans_reason, p_carrier_id,
                   p_ota_trans2x_ota_mrkt_info, p_ota_trans2x_call_tran,
                   p_mobile365_id                          -- OTA Enhancements
                  );

      -- generate objid number for ota trans detail table
      n_ota_trans_dtl_objid := seq ('x_ota_trans_dtl');
      d_sent_date := SYSDATE;

      INSERT INTO table_x_ota_trans_dtl
                  (objid, x_psms_text,
                   x_action_type, x_sent_date, x_received_date,
                   x_resent_date, x_ota_message_direction,
                   x_ota_trans_dtl2x_ota_trans
                  )
           VALUES (n_ota_trans_dtl_objid, p_psms_text,
                   ota_util_pkg.ota_marketing, d_sent_date, NULL,
                   NULL, ota_util_pkg.mobile_terminated,
                   n_ota_trans_objid
                  );

      IF p_cbo_error_message IS NOT NULL
      THEN
         -- generate objid number for ota error info table
         n_ota_error_info_objid := seq ('x_ota_error_info');

         INSERT INTO table_x_ota_error_info
                     (objid,
                      x_ota_error_code,
                      x_ota_error_type, x_ota_error_message,
                      ota_err2ota_trans_dtl
                     )
              VALUES (n_ota_error_info_objid,
                      NULL                  -- for now we have only error text
                          ,
                      'CBO ERROR MSG', SUBSTR (p_cbo_error_message, 1, 200),
                      n_ota_trans_dtl_objid
                     );
      END IF;

      COMMIT;
      p_ota_trans_objid := n_ota_trans_objid;              -- 06/27/05  CR4169
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         raise_application_error
               (-20001,
                   'Failed to create ota transaction for marketing message: '
                || SQLERRM
               );
   END create_mrkt_transaction;

   /******************************************************************
   | Refer to package spec for detailed description of this procedure|
   ******************************************************************/
   PROCEDURE create_redemp_history
                                   -- parameters for table_x_ota_code_hist
   (
      p_transaction_type   IN   VARCHAR2
                                        -- common parameter
   ,
      p_call_trans_objid   IN   NUMBER
                                      -- paremeters for table_x_code_hist
   ,
      p_gen_code           IN   VARCHAR2,
      p_sequence           IN   NUMBER,
      p_code_type          IN   VARCHAR2
                                        -- parameters for redemption card table_part_inst update
   ,
      p_red_code           IN   VARCHAR2
                                        -- parameters for esn table_part_inst update
   ,
      p_esn                IN   VARCHAR2
   )
   IS
      n_ota_code_hist_objid   NUMBER;
   BEGIN
      -- table_x_ota_code_hist
      n_ota_code_hist_objid := seq ('x_ota_code_hist');

      INSERT INTO table_x_ota_code_hist
                  (objid, x_transaction_type
                  )
           VALUES (n_ota_code_hist_objid, p_transaction_type
                  );

      -- table_x_code_hist
      INSERT INTO table_x_code_hist
                  (objid, x_gen_code, x_sequence,
                   code_hist2call_trans, x_code_type
                  )
           VALUES (seq ('x_code_hist'), p_gen_code, p_sequence,
                   p_call_trans_objid, p_code_type
                  );

      -- part inst update for redemption card
      UPDATE table_part_inst
         SET x_part_inst_status = ota_util_pkg.pending_redemption,
             last_trans_time = SYSDATE,
             status2x_code_table = ota_util_pkg.ota_redemption_code
       WHERE x_red_code = p_red_code;

      -- call trans update
      UPDATE table_x_call_trans
         SET x_call_trans2x_ota_code_hist = n_ota_code_hist_objid
       WHERE objid = p_call_trans_objid;

      -- part inst update for esn sequence increment
      -- IMPORTANT NOTE:
      -- this increment here is for the redemption only
      -- assuming that only 1 code is generated
      UPDATE table_part_inst
         SET x_sequence = NVL (x_sequence, 0) + 1
       WHERE part_serial_no = p_esn;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         raise_application_error (-20001,
                                     'Failed to create redemption history: '
                                  || SQLERRM
                                 );
   END create_redemp_history;

   /******************************************************************
   | Refer to package spec for detailed description of this function |
   ******************************************************************/
   FUNCTION get_failed_redemp_count (p_esn IN VARCHAR2)
      RETURN NUMBER
   IS
      n_return_value         NUMBER;

      CURSOR c
      IS
         SELECT x_value
           FROM table_x_code_table
          WHERE x_code_number = ota_util_pkg.invalid_tries_time;

      n_invalid_tries_time   table_x_code_table.x_value%TYPE;
      e_no_parameter_found   EXCEPTION;
   BEGIN
              /**********************************************************************************************
              The code below is commented in revision 1.2
              From now on we will always return 0 from this function
              BEGIN COMMENT CODE
      -- get parameter value from TABLE_X_CODE_TABLE table
      OPEN c;
      FETCH c INTO n_invalid_tries_time;
      IF c%NOTFOUND THEN
         CLOSE c;
         RAISE e_no_parameter_found;
      END IF;
      CLOSE c;

      -- get the current count of failed/invalid redemption attempts for the given period of time
      SELECT COUNT(*) INTO n_return_value
      FROM table_x_ota_transaction
      WHERE FLOOR((SYSDATE - x_transaction_date)*24) <= n_invalid_tries_time
      AND x_reason = ota_util_pkg.FAILED_REDEMPTION_ERROR
      AND x_action_type = ota_util_pkg.MARKETING_CODE
      AND x_esn = p_esn;

      RETURN n_return_value;
      END COMMENT CODE
      **********************************************************************************************/
      RETURN 0;
   EXCEPTION
      WHEN e_no_parameter_found
      THEN
         raise_application_error
            (-20001,
                'Value for OTA parameter INVALID TRIES TIME (x_code_number = '
             || ota_util_pkg.invalid_tries_time
             || ') not found in table TABLE_X_CODE_TABLE'
            );
   END get_failed_redemp_count;

   PROCEDURE create_detail_transaction (
      p_x_psms_text                   VARCHAR2,
      p_x_sent_date                   DATE DEFAULT SYSDATE,
      p_x_received_date               DATE DEFAULT NULL,
      p_x_resent_date                 DATE DEFAULT NULL,
      p_x_ota_message_direction       VARCHAR2,
      p_x_action_type                 VARCHAR2,
      p_x_ota_trans_dtl2x_ota_trans   NUMBER
   )
   IS
   BEGIN
      INSERT INTO table_x_ota_trans_dtl
                  (objid, x_psms_text, x_sent_date,
                   x_received_date, x_resent_date,
                   x_ota_message_direction, x_action_type,
                   x_ota_trans_dtl2x_ota_trans
                  )
           VALUES (seq ('X_OTA_TRANS_DTL'), p_x_psms_text, p_x_sent_date,
                   p_x_received_date, p_x_resent_date,
                   p_x_ota_message_direction, p_x_action_type,
                   p_x_ota_trans_dtl2x_ota_trans
                  );

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ota_util_pkg.err_log
                (p_action            => 'Creteing OTA detail transaction record',
                 p_program_name      => 'OTA_TRANS_PKG.create_detail_transaction',
                 p_error_text        => SQLERRM
                );
         raise_application_error (-20002,
                                  'Procedure failed with error: ' || SQLERRM
                                 );
   END create_detail_transaction;

   /******************************************************************
   | Refer to package spec for detailed description of this procedure|
   ******************************************************************/
   PROCEDURE create_inq_transaction (
      p_esn                IN       VARCHAR2                            -- ESN
                                            ,
      p_min                IN       VARCHAR2                            -- MIN
                                            ,
      p_psms_counter       IN       NUMBER                 -- ota psms counter
                                          ,
      p_mode               IN       VARCHAR2                     -- WEB, BATCH
                                            ,
      p_psms_text          IN       VARCHAR2              -- PSMS message text
                                            ,
      p_ota_trans_reason   IN       VARCHAR2 DEFAULT NULL              -- NULL
                                                         ,
      p_mobile365_id       IN       VARCHAR2 DEFAULT NULL, -- OTA Enhancements
      p_ota_trans_objid    OUT      NUMBER
   )
   IS
      n_ota_trans_dtl_objid    NUMBER;
      n_ota_trans_objid        NUMBER;
      n_ota_error_info_objid   NUMBER;
      d_sent_date              DATE;
   BEGIN
      -- generate objid number for ota trans table
      n_ota_trans_objid := seq ('x_ota_transaction');

      INSERT INTO table_x_ota_transaction
                  (objid, x_transaction_date, x_status, x_esn, x_min,
                   x_action_type, x_mode, x_counter,
                   x_reason, x_mobile365_id                -- OTA Enhancements
                  )
           VALUES (n_ota_trans_objid, SYSDATE, 'Completed', p_esn, p_min,
                   ota_util_pkg.ota_inquiry, p_mode, p_psms_counter,
                   p_ota_trans_reason, p_mobile365_id      -- OTA Enhancements
                  );

      -- generate objid number for ota trans detail table
      n_ota_trans_dtl_objid := seq ('x_ota_trans_dtl');
      d_sent_date := SYSDATE;

      INSERT INTO table_x_ota_trans_dtl
                  (objid, x_psms_text,
                   x_action_type, x_sent_date, x_received_date,
                   x_resent_date, x_ota_message_direction,
                   x_ota_trans_dtl2x_ota_trans
                  )
           VALUES (n_ota_trans_dtl_objid, p_psms_text,
                   ota_util_pkg.ota_inquiry, d_sent_date, NULL,
                   NULL, ota_util_pkg.mobile_terminated,
                   n_ota_trans_objid
                  );

      COMMIT;
      p_ota_trans_objid := n_ota_trans_objid;              -- 06/27/05  CR4169
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         raise_application_error
               (-20001,
                   'Failed to create ota transaction for marketing message: '
                || SQLERRM
               );
   END create_inq_transaction;
END;                                                           -- package body
/