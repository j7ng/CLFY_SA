CREATE OR REPLACE PACKAGE sa."OTA_TRANS_PKG"
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
       | 1.1      06/27/05   Shaowei Luo       Added new OUT parameter p_ota_trans_objid to create_mrkt_transaction
       |                                       procedure
       |                                       Added new procedure to the package: create_inq_transaction
   | 1.2      09/26/06   Vani Adapa        CR5613 - OTA Enhancements changes
   | 1.3      11/08/06   Vani Adapa        CR5613
   | 1.4      09/03/07   JAL        	   CR6922 - BUY NOW
   |************************************************************************************************/

   /************************************************************************
   | create_transaction procedure is executed after         |
   | the DLL (C program) is called in either Batch (DBMS_JOB)     |
   | or Online (WEB, WEB CSR) mode                 |
   | This procedure inserts 1 record in each of the following tables:   |
   | TABLE_X_OTA_TRANSACTION                 |
   | TABLE_X_OTA_TRANS_DTL                   |
   | TABLE_X_OTA_ACKNOWLEDGEMENT                |
   | The values for individual columns of each table are either passed as  |
   | input parameters or returned by cursor get_call_trans_data_cur  |
   ************************************************************************/
   PROCEDURE create_transaction
--------------------------------------------------------------------------------------------
-- ota trans and trans detail required parameters:    Value/Parameter description:
--------------------------------------------------------------------------------------------
   (
      p_call_trans_objid      IN   NUMBER      -- objid of TABLE_X_CALL_TRANS
                                         ,
      p_psms_counter          IN   NUMBER -- PSMS sequence number (x_counter)
                                         ,
      p_mode                  IN   VARCHAR2                     -- WEB, BATCH
                                           ,
      p_resent_date           IN   DATE            -- the value might be NULL
                                       -- ota acknowledgment parameters:
   ,
      p_ota_number_of_codes   IN   NUMBER
                                         -- number of codes sent to the phone
                                         -- DLL message
   ,
      p_psms_text             IN   VARCHAR2              -- PSMS message text
                                           -- ota trans and trans detail optional params:
   ,
      p_ota_trans_reason      IN   VARCHAR2 DEFAULT NULL,             -- NULL
      p_mobile365_id          IN   VARCHAR2 DEFAULT NULL, -- OTA Enhancements
	  p_denomination 		  IN   VARCHAR2 DEFAULT NULL  -- Buy NOW
   );

   /************************************************************************
   | create_mrkt_transaction procedure is executed after       |
   | the DLL (C program) is called in either Batch (DBMS_JOB)     |
   | or Online (WEB, WEB CSR) mode                 |
   | This procedure inserts 1 record in each of the following tables:   |
   | TABLE_X_OTA_TRANSACTION                 |
   | TABLE_X_OTA_TRANS_DTL                   |
   | The values for individual columns of each table are either passed as  |
   | input parameters or returned by cursor get_call_trans_data_cur  |
   ************************************************************************/
   PROCEDURE create_mrkt_transaction
--------------------------------------------------------------------------------------------
-- ota trans and trans detail required parameters:    Value/Parameter description:
--------------------------------------------------------------------------------------------
   (
      p_esn                         IN       VARCHAR2                  -- ESN
                                                     ,
      p_min                         IN       VARCHAR2                  -- MIN
                                                     ,
      p_psms_counter                IN       NUMBER       -- ota psms counter
                                                   ,
      p_carrier_id                  IN       NUMBER
                                                   -- carrier_id from table_x_carrier
   ,
      p_mode                        IN       VARCHAR2           -- WEB, BATCH
                                                     -- DLL message
   ,
      p_psms_text                   IN       VARCHAR2    -- PSMS message text
                                                     -- ota trans and trans detail optional params:
   ,
      p_ota_trans2x_ota_mrkt_info   IN       NUMBER
            DEFAULT NULL                         -- FK to ota mrkt info table
                        ,
      p_ota_trans_reason            IN       VARCHAR2 DEFAULT NULL    -- NULL
                                                                  ,
      p_ota_trans2x_call_tran       IN       NUMBER
            DEFAULT NULL                            -- FK to call trans table
                        ,
      p_cbo_error_message           IN       VARCHAR2
            DEFAULT NULL                     -- error message passed from CBO
                        ,
      p_mobile365_id                IN       VARCHAR2 DEFAULT NULL,
      -- OTA Enhancements
      p_ota_trans_objid             OUT      NUMBER       -- 06/27/05  CR4169
   );

   /************************************************************************
   | create_redemp_history procedure is executed from CBO code    |
   | after the redemption codes are generated by DLL (C program).    |
   | It inserts 1 record into each of the following code history tables:   |
   | TABLE_X_CODE_HIST                    |
   | TABLE_X_OTA_CODE_HIST                   |
   | and updates  redemption card table:              |
   | TABLE_PART_INST                   |
   | The values for individual columns of each table are either passed as  |
   | input parameters to this procedure               |
   ************************************************************************/
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
   );

   /************************************************************************
   | get_failed_redemp_count function is executed from CBO code      |
   | It calculates how many failed redemptions were recorded in      |
   | TABLE_X_OTA_TRANSACTION for given ESN   in the specified time period  |
   ************************************************************************/
   FUNCTION get_failed_redemp_count (p_esn VARCHAR2)
      RETURN NUMBER;

   /************************************************************************
   | create_detail_transaction function is executed from CBO code    |
   | It creates new record in TABLE_X_OTA_TRANS_DTL table         |
   ************************************************************************/
   PROCEDURE create_detail_transaction (
      p_x_psms_text                   VARCHAR2,
      p_x_sent_date                   DATE DEFAULT SYSDATE,
      p_x_received_date               DATE DEFAULT NULL,
      p_x_resent_date                 DATE DEFAULT NULL,
      p_x_ota_message_direction       VARCHAR2,
      p_x_action_type                 VARCHAR2,
      p_x_ota_trans_dtl2x_ota_trans   NUMBER
   );

   /************************************************************************
   | create_inq_transaction procedure is executed
   ************************************************************************/
   PROCEDURE create_inq_transaction
--------------------------------------------------------------------------------------------
-- ota trans and trans detail required parameters:    Value/Parameter description:
--------------------------------------------------------------------------------------------
   (
      p_esn                IN       VARCHAR2                           -- ESN
                                            ,
      p_min                IN       VARCHAR2                           -- MIN
                                            ,
      p_psms_counter       IN       NUMBER                -- ota psms counter
                                          ,
      p_mode               IN       VARCHAR2                    -- WEB, BATCH
                                            ,
      p_psms_text          IN       VARCHAR2             -- PSMS message text
                                            ,
      p_ota_trans_reason   IN       VARCHAR2 DEFAULT NULL             -- NULL
                                                         ,
      p_mobile365_id       IN       VARCHAR2 DEFAULT NULL,
      -- OTA Enhancements
      p_ota_trans_objid    OUT      NUMBER                 -- 06/27/05 CR4169
   );
END;
/