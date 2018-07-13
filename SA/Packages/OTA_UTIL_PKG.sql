CREATE OR REPLACE PACKAGE sa."OTA_UTIL_PKG"
IS
   /************************************************************************************************|
   |    Copyright   Tracfone  Wireless Inc. All rights reserved
   |
   | NAME     :       OTA_UTIL_PKG  package
   | PURPOSE  :
   | FREQUENCY:
   | PLATFORMS:
   |
   | REVISIONS:
   | VERSION  DATE        WHO              PURPOSE
   | -------  ---------- -----             ------------------------------------------------------
   | 1.0      03/11/05   Novak Lalovic     Initial revision
   | 1.1     06/14/05   Novak Lalovic     Modified comments for get_next_esn_counter function
   |                                       to say that we are now generating the new numbers
   |                                       starting with number 6 insted of number 1.
   |                                       Added constant OTA_REDEMPTION
   |      06/27/05   Shaowei Luo       Added constant OTA_INQUIRY
   |      06/07/06   Vani Adapa       CR5349 - Added constant PORT_CANCELLED
   |      06/06/07   Cosmin Ioan      CR6293  -- added constant esn_used and esn_pastdue
   |************************************************************************************************/

   /********************************************************
   | get_next_esn_counter function returns the next valid     |
   | value for the column table_x_ota_transaction.X_COUNTER|
   | each esn record in this table has its counter value.    |
   | Counter is incremented by 1 for each new esn record.    |
   | When counter reaches max number: 255 it is recycled     |
   | and it starts from number 1 again                        |
   | This function is called from CBO layer as well        |
   | We modified this function to start generating the new |
   | numbers starting with number 6 instead of number 1.   |
   ********************************************************/
   FUNCTION get_next_esn_counter (p_esn IN VARCHAR2)
      RETURN NUMBER;

   /********************************************************
   | err_log procedure inserts new record into ERROR_TABLE    |
   | when something goes wrong...                            |
   ********************************************************/
   PROCEDURE err_log (
      p_action         IN   error_table.action%TYPE,
      p_error_date     IN   error_table.error_date%TYPE DEFAULT SYSDATE,
      p_key            IN   error_table.KEY%TYPE DEFAULT NULL,
      p_program_name   IN   error_table.program_name%TYPE,
      p_error_text     IN   error_table.ERROR_TEXT%TYPE
   );

   /* constants used for OTA project */
   ota_activation            CONSTANT VARCHAR2 (3)  := '264';
   ota_redemption            CONSTANT VARCHAR2 (3)  := '265';
   ota_queued                CONSTANT VARCHAR2 (30) := 'Queued';
   ota_success               CONSTANT VARCHAR2 (30) := 'Success';
   ota_failed                CONSTANT VARCHAR2 (30) := 'Failed';
   ota_send                  CONSTANT VARCHAR2 (30) := 'OTA SEND';
   msid_update               CONSTANT VARCHAR2 (3)  := '110';
   line_active               CONSTANT VARCHAR2 (2)  := '13';
   pending_ac_change         CONSTANT VARCHAR2 (2)  := '34';
   reserved                  CONSTANT VARCHAR2 (2)  := '37';
   reserved_used             CONSTANT VARCHAR2 (2)  := '39';
   esn_active                CONSTANT VARCHAR2 (2)  := '52';
   esn_refurbished           CONSTANT VARCHAR2 (3)  := '150';
   esn_used                  CONSTANT VARCHAR2 (2)  := '51';  --CR6293
   esn_pastdue               CONSTANT VARCHAR2 (2)  := '54';  --CR6293
   esn_new                   CONSTANT VARCHAR2 (2)  := '50';
   dummy_esn                 CONSTANT VARCHAR2 (15) := '111111111111111';
                                       -- 15 digits number for technology GSM
   dummy_sequence            CONSTANT NUMBER        := 0;
   activation                CONSTANT VARCHAR2 (1)  := '1';
   redemption_action_type    CONSTANT VARCHAR2 (1)  := '3';
   ota_marketing             CONSTANT NUMBER        := 261;
   mobile_terminated         CONSTANT VARCHAR2 (2)  := 'MT';
   pending_redemption        CONSTANT NUMBER        := 43;
   ota_redemption_code       CONSTANT VARCHAR2 (2)  := '26';
   marketing_code            CONSTANT VARCHAR2 (3)  := '261';
   failed_redemption_error   CONSTANT VARCHAR2 (20) := 'ERROR 405';
   invalid_tries_time        CONSTANT VARCHAR2 (3)  := '268';
   ota_send_last_ack         CONSTANT VARCHAR2 (3)  := '269';
   ota_inquiry               CONSTANT VARCHAR2 (3)  := '271';
                                                           -- 06/27/05 CR4169
   port_cancelled            CONSTANT VARCHAR2 (2)  := '79';        -- CR5349
END ota_util_pkg;
/