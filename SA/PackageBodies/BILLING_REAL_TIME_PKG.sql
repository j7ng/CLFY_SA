CREATE OR REPLACE PACKAGE BODY sa."BILLING_REAL_TIME_PKG"
AS
   PROCEDURE realtime_create_proc (
      i_process_date   IN       DATE,
      i_input_xml      IN       VARCHAR2,
      i_output_xml     IN       VARCHAR2,
      i_status         IN       VARCHAR2,
      i_last_updated   IN       DATE,
      o_seq_id1        OUT      NUMBER,
      o_err_num        OUT      NUMBER,
      o_err_msg        OUT      VARCHAR2
   )
   IS
      real_time_objid   NUMBER;
   BEGIN
      real_time_objid := billing_seq ('X_PAYMENT_REAL_TIME');

      INSERT INTO x_payment_real_time
           VALUES (real_time_objid, i_process_date, i_input_xml, i_output_xml, i_status, i_last_updated)
        RETURNING seq_id
             INTO o_seq_id1;
   EXCEPTION
      WHEN OTHERS
      THEN
         o_err_num := -900;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);

         IF (o_err_num = -1400)
         THEN
            o_err_num := -1400;
            o_err_msg := 'Cannot Insert NULL into Real_time_payment Table';
         END IF;

         IF (o_err_num = -1)
         THEN
            o_err_num := -0001;
            o_err_msg :=    'Cannot Insert duplicate Id'
                         || TO_NUMBER (o_seq_id1)
                         || ' in Real_time_payment Table';
         END IF;
   END realtime_create_proc;

   PROCEDURE realtime_update_proc (
      i_seq_id         IN       NUMBER,
      i_output_xml     IN       VARCHAR2,
      i_status         IN       VARCHAR2,
      i_last_updated   IN       DATE,
      o_err_num        OUT      NUMBER,
      o_err_msg        OUT      VARCHAR2
   )
   IS
   BEGIN
      UPDATE x_payment_real_time
         SET output_xml = i_output_xml,
             status = i_status,
             last_updated = i_last_updated
       WHERE seq_id = i_seq_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg :=    'Such Record Id'
                      || TO_NUMBER (i_seq_id)
                      || 'not Found ';
      WHEN OTHERS
      THEN
         o_err_num := -900;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);

         IF (o_err_num = -1400)
         THEN
            o_err_num := -1400;
            o_err_msg :=    'Entered is NULL, You cannot modify'
                         || TO_NUMBER (i_seq_id)
                         || ' records';
         END IF;
   END realtime_update_proc;
END billing_real_time_pkg;
/