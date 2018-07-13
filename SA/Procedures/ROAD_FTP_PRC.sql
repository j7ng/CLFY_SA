CREATE OR REPLACE PROCEDURE sa.road_ftp_prc
/********************************************************************************************************/
/* Copyright  2002 Tracfone Wireless Inc. All rights reserved                                           */
/*                                                                                                      */
/* Name         :   ROAD_FTP_PRC.sql                                                                    */
/* Purpose      :   To extract the ROADSIDE member details from X_ROAD_FTP table that are not yet sent  */
/*                  to ROAD AMERICA and creates flat files on TRACFONE'S server                         */
/* Parameters   :   NONE                                                                                */
/* Platforms    :   Oracle 8.0.6 AND newer versions                                                     */
/* Author		:   Vanisri Adapa                                                                       */
/* Date         :   02/05/02                                                                            */
/* Revisions	:   Version  Date      Who              Purpose                                         */
/*                  -------  --------  -------          ----------------------------------------------- */
/*                  1.0      02/05/02  VAdapa           Initial revision                                */
/*                                                                                                      */
/*                  1.1      03/05/02  VAdapa           Modified to use the TOSS_UTIL_PKG to insert     */
/*                                                      errors into the ERROR_TABLE if any              */
/*                                                                                                      */
/*                  1.2      04/09/02  SL               Modified to fix data with "|" in it             */
/********************************************************************************************************/

AS
   CURSOR c_road_ftp
   IS
      SELECT a.ROWID, a.service_id, a.program_name,
             replace(a.first_name, '|','') first_name, -- replace '|' with ''  version 1.2
             replace(a.last_name,'|','') last_name,    -- version 1.2
             replace(a.address_1,'|','') address_1 ,   -- version 1.2
             replace(a.address_2,'|','') address_2 ,   -- version 1.2
             replace(a.city,'|','') city,              -- version 1.2
             replace(a.state,'|','') state,            -- version 1.2
             replace(a.zipcode,'|','') zipcode,        -- version 1.2
             replace(a.phone,'|','') phone,            -- version 1.2
             replace(a.e_mail,'|','') e_mail,          -- version 1.2
             a.info_reqd, a.trans_type, a.refund_percent,
             a.service_start_date, a.service_end_date, a.term,
             replace(a.dep1_first_name,'|','') dep1_first_name,  -- version 1.2
             replace(a.dep1_last_name,'|','')  dep1_last_name,   -- version 1.2
             replace(a.dep2_first_name,'|','') dep2_first_name,  -- version 1.2
             replace(a.dep2_last_name,'|','')  dep2_last_name,   -- version 1.2
             replace(a.dep3_first_name,'|','')  dep3_first_name, -- version 1.2
             replace(a.dep3_last_name,'|','')   dep3_last_name,  -- version 1.2
             replace(a.dep4_first_name,'|','')  dep4_first_name, -- version 1.2
             replace(a.dep4_last_name,'|','')  dep4_last_name,   -- version 1.2
             a.last_updated_by,
             a.last_update_date
        FROM x_road_ftp a
       WHERE a.ftp_create_status = 'NO';


   f_handle UTL_FILE.file_type;
   f_handle1 UTL_FILE.file_type;
   v_text VARCHAR2 (4000);
   v_member_id VARCHAR2 (20);
   v_cnt NUMBER := 0;
   v_action VARCHAR2 (4000);
   v_err_flag VARCHAR2 (1);
   v_utl_path VARCHAR2 (80);
   v_file_name VARCHAR2 (80);
BEGIN

   v_utl_path := '/f01/invfile';
   v_file_name := '24ra' || TO_CHAR (SYSDATE, 'mmddyy');


   FOR r_road_ftp IN c_road_ftp
   LOOP

      v_member_id := r_road_ftp.service_id;
      v_err_flag := 'N';

      v_action := 'Update X_ROAD_FTP';


      UPDATE x_road_ftp
         SET ftp_create_status = 'YES',
             ftp_create_date = SYSDATE,
             last_updated_by = 'ROAD_FTP_PRC',
             last_update_date = TRUNC (SYSDATE)
       WHERE ROWID = r_road_ftp.ROWID;


      IF SQL%ROWCOUNT = 1
      THEN
         BEGIN
            v_action := 'Open Detail FTP File';
            f_handle := UTL_FILE.fopen (v_utl_path, v_file_name || '.dtl', 'a');
            v_text := r_road_ftp.service_id ||
                      '|' ||
                      r_road_ftp.program_name ||
                      '|' ||
                      r_road_ftp.first_name ||
                      '|' ||
                      r_road_ftp.last_name ||
                      '|' ||
                      r_road_ftp.address_1 ||
                      '|' ||
                      r_road_ftp.address_2 ||
                      '|' ||
                      r_road_ftp.city ||
                      '|' ||
                      r_road_ftp.state ||
                      '|' ||
                      r_road_ftp.zipcode ||
                      '|' ||
                      r_road_ftp.phone ||
                      '|' ||
                      r_road_ftp.e_mail ||
                      '|' ||
                      r_road_ftp.info_reqd ||
                      '|' ||
                      r_road_ftp.trans_type ||
                      '|' ||
                      r_road_ftp.refund_percent ||
                      '|' ||
                      TO_CHAR (r_road_ftp.service_start_date, 'mm/dd/yyyy') ||
                      '|' ||
                      TO_CHAR (r_road_ftp.service_end_date, 'mm/dd/yyyy') ||
                      '|' ||
                      r_road_ftp.term ||
                      '|' ||
                      r_road_ftp.dep1_first_name ||
                      '|' ||
                      r_road_ftp.dep1_last_name ||
                      '|' ||
                      r_road_ftp.dep2_first_name ||
                      '|' ||
                      r_road_ftp.dep2_last_name ||
                      '|' ||
                      r_road_ftp.dep3_first_name ||
                      '|' ||
                      r_road_ftp.dep3_last_name ||
                      '|' ||
                      r_road_ftp.dep4_first_name ||
                      '|' ||
                      r_road_ftp.dep4_last_name ||
                      '|';

            v_action := 'Writing Details into FTP File';
            UTL_FILE.putf (f_handle, v_text);

            v_cnt := v_cnt + 1;

            v_action := 'Open Header FTP File';
            f_handle1 := UTL_FILE.fopen (
                            v_utl_path,
                            v_file_name ||
                            '.hdr',
                            'w'
                         );

            v_action := 'Writing Header Information';
            UTL_FILE.putf (
               f_handle1,
               TO_CHAR (SYSDATE, 'mm/dd/yyyy') || '|      ' || v_cnt || '|'
            );

         EXCEPTION
            WHEN UTL_FILE.invalid_path
            THEN
               toss_util_pkg.insert_error_tab_proc (
                  v_action,
                  v_member_id,
                  'ROAD_FTP_PRC',
                  'UTL_FILE Invalid Path'
               );

               v_err_flag := 'Y';

            WHEN UTL_FILE.invalid_mode
            THEN
               toss_util_pkg.insert_error_tab_proc (
                  v_action,
                  v_member_id,
                  'ROAD_FTP_PRC',
                  'UTL_FILE Invalid Mode'
               );

               v_err_flag := 'Y';

            WHEN UTL_FILE.invalid_operation
            THEN
               toss_util_pkg.insert_error_tab_proc (
                  v_action,
                  v_member_id,
                  'ROAD_FTP_PRC',
                  'UTL_FILE Invalid Operation'
               );

               v_err_flag := 'Y';

            WHEN UTL_FILE.invalid_filehandle
            THEN
               toss_util_pkg.insert_error_tab_proc (
                  v_action,
                  v_member_id,
                  'ROAD_FTP_PRC',
                  'UTL_FILE Invalid File Handle'
               );

               v_err_flag := 'Y';

            WHEN UTL_FILE.write_error
            THEN
               toss_util_pkg.insert_error_tab_proc (
                  v_action,
                  v_member_id,
                  'ROAD_FTP_PRC',
                  'UTL_FILE Write Error'
               );

               v_err_flag := 'Y';

            WHEN UTL_FILE.read_error
            THEN
               toss_util_pkg.insert_error_tab_proc (
                  v_action,
                  v_member_id,
                  'ROAD_FTP_PRC',
                  'UTL_FILE Read Error'
               );

               v_err_flag := 'Y';

            WHEN UTL_FILE.internal_error
            THEN
               toss_util_pkg.insert_error_tab_proc (
                  v_action,
                  v_member_id,
                  'ROAD_FTP_PRC',
                  'UTL_FILE Internal Error'
               );

               v_err_flag := 'Y';

            WHEN OTHERS
            THEN
               toss_util_pkg.insert_error_tab_proc (
                  v_action,
                  v_member_id,
                  'ROAD_FTP_PRC'
               );

               v_err_flag := 'Y';
         END;


         UTL_FILE.fclose (f_handle);
         UTL_FILE.fclose (f_handle1);


         IF v_err_flag = 'Y'
         THEN

            UPDATE x_road_ftp
               SET ftp_create_status = 'NO',
                   ftp_create_date = NULL,
                   last_updated_by = r_road_ftp.last_updated_by,
                   last_update_date = r_road_ftp.last_update_date
             WHERE ROWID = r_road_ftp.ROWID;
         END IF;   -- utl error flag check
      END IF;   -- update success check


      IF MOD (v_cnt, 1000) = 0
      THEN
         COMMIT;
      END IF;
   END LOOP;

   COMMIT;

   v_action := 'Open Header FTP File Final';
   f_handle1 := UTL_FILE.fopen (v_utl_path, v_file_name || '.hdr', 'w');

   v_action := 'Writing Header Information Final';
   UTL_FILE.putf (
      f_handle1,
      TO_CHAR (SYSDATE, 'mm/dd/yyyy') || '|      ' || v_cnt || '|'
   );

   UTL_FILE.fclose (f_handle1);

EXCEPTION
   WHEN OTHERS
   THEN
      toss_util_pkg.insert_error_tab_proc (v_action, NULL, 'ROAD_FTP_PRC');
END road_ftp_prc;
/