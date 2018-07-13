CREATE OR REPLACE PROCEDURE sa."POSA_ATT_OUTBOUND_PHONE_PRC"
AS
/*****************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved           */
/*                                                                           */
/* NAME:         SA.POSA_ATT_OUTBOUND_PHONE_PRC                              */
/* PURPOSE:                                                                  */
/* FREQUENCY:                                                                */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                            */
/* REVISIONS:                                                                */
/* VERSION  DATE        WHO               PURPOSE                            */
/* -------  ----------  -----------   ---------------------------------------*/
/* 1.0      04/30/02    Miguel Leon   Initial Revision                       */
/*                                                                           */
/* 1.1      08/22/02    Miguel Leon   Modifications to look into the tf_toss */
/*                                    interface archive table if the esn is  */
/*                                    not found in tf_toss_interface table.  */
/*                                    If esn is not found anywhere, an exp   */
/*                                    is raised and log in the error_table.  */
/*                                    Also omitted irrelavant card related   */
/*                                    logic like mutti swipes logging, etc.  */
/*                                    Also change coding style to reflect    */
/*                                    PL/SQL standards.                      */
/*                                    Also added RULE based hint on queries  */
/*                                    analized interface tables (OF).        */
/*                                    Replace updates by inserts to the inter*/
/*                                    face table.                            */
/*****************************************************************************/
   CURSOR posa_cur
   IS
      SELECT par.*, par.rowid
        FROM x_posa_phone par
       WHERE tf_extract_flag = 'N'
       ORDER BY tf_serial_num, toss_posa_date;


   CURSOR not_arch_cur (tf_serial_num_in IN VARCHAR2)
   IS
      SELECT   /*+ RULE */tf_serial_num
        FROM tf.tf_toss_interface_table@OFSPRDL3
       WHERE tf_serial_num = tf_serial_num_in;


   CURSOR arch_cur (tf_serial_num_in IN VARCHAR2)
   IS
      SELECT   /*+ RULE */tf_serial_num
        FROM tf.tf_toss_interface_archive@OFSPRDL3
       WHERE tf_serial_num = tf_serial_num_in;


   not_arch_rec                not_arch_cur%ROWTYPE;
   arch_rec                    arch_cur%ROWTYPE;
   sql_code                    NUMBER;
   sql_err                     VARCHAR2 (300);
   l_error_text                VARCHAR2 (1000);
   serial_number_not_found     EXCEPTION;
   l_serial_number             x_posa_phone.TF_SERIAL_NUM%TYPE := NULL;
   l_toss_posa_date            DATE                            := NULL;
   l_procedure_name   CONSTANT error_table.PROGRAM_NAME%TYPE
            := 'POSA_ATT_OUTBOUND_PHONE_PRC';
   l_recs_processed            NUMBER                          := 0;
   l_start_date                DATE                            := SYSDATE;
   l_is_archived               BOOLEAN                         := FALSE;
BEGIN

   FOR posa_rec IN posa_cur
   LOOP
      /* Added for logging purposes */
      l_serial_number := posa_rec.tf_serial_num;
      l_recs_processed := l_recs_processed + 1;


      BEGIN   /* of Inner Block with exception handler */

         OPEN not_arch_cur (posa_rec.tf_serial_num);
         FETCH not_arch_cur INTO not_arch_rec;

         /** check to see if the serial_number is in tf_toss_interface table*/
         IF not_arch_cur%FOUND THEN
            /* it is not archived */
            l_is_archived := FALSE;
         /** try to find the serial_number (esn)  on the archived table  */
         /** tf_toss_interface_archive.                                  */

         ELSE
            OPEN arch_cur (posa_rec.tf_serial_num);
            FETCH arch_cur INTO arch_rec;


            IF arch_cur%FOUND THEN
               /* it is  archived */
               l_is_archived := TRUE;
            ELSE
               /*** raise exception esn_not found ***/
               RAISE serial_number_not_found;
            END IF;   /* of c_arch%FOUND */
         END IF;   /* of not_arch_cur%FOUND */

         /* if is a swipe comes in then update the record with */
         /* the toss_posa_date as requested by Phoenix changes*/
         /* request form (Oct 25,2001)                        */
         IF posa_rec.toss_posa_code = '50' THEN
            l_toss_posa_date := posa_rec.toss_posa_date;
         ELSE
            /* if is an deact (59) then reset to NULL */
            l_toss_posa_date := NULL;
         END IF;


         IF NOT (l_is_archived) THEN
            /* update  non archived table */

            UPDATE tf.tf_toss_interface_table@OFSPRDL3
               SET toss_posa_code = posa_rec.toss_posa_code,
                   toss_posa_date = l_toss_posa_date,
                   last_update_date = sysdate,
                   last_updated_by = l_procedure_name,
                   toss_att_location = posa_rec.toss_att_location,
                   toss_att_customer = posa_rec.toss_att_customer
             WHERE posa_rec.tf_part_num_parent = tf_part_num_parent
               AND posa_rec.tf_serial_num = tf_serial_num;
         ELSE
            /* update archived table */
            UPDATE tf.tf_toss_interface_archive@OFSPRDL3
               SET toss_posa_code = posa_rec.toss_posa_code,
                   toss_posa_date = l_toss_posa_date,
                   last_update_date = sysdate,
                   last_updated_by = l_procedure_name,
                   toss_att_location = posa_rec.toss_att_location,
                   toss_att_customer = posa_rec.toss_att_customer
             WHERE posa_rec.tf_part_num_parent = tf_part_num_parent
               AND posa_rec.tf_serial_num = tf_serial_num;
         END IF;

         /* After updating the interface table, update the
            extract_flag and extract_date in TOSS side. */
         UPDATE x_posa_phone
            SET tf_extract_flag = 'Y',
                tf_extract_date = sysdate
          WHERE rowid = posa_rec.rowid;

      EXCEPTION

         WHEN serial_number_not_found THEN
            /* Cleaning up */
            IF not_arch_cur%ISOPEN THEN
               CLOSE not_arch_cur;
            END IF;


            IF arch_cur%ISOPEN THEN
               CLOSE arch_cur;
            END IF;

            /* logging errors */
            Toss_Util_Pkg.insert_error_tab_proc (
               'Exception serial_number_not_found(arch or not arch) ',
               NVL (l_serial_number, 'NOT DEFINED'),
               l_procedure_name
            );
            COMMIT;

         WHEN OTHERS THEN
            /* Cleaning up */
            IF not_arch_cur%ISOPEN THEN
               CLOSE not_arch_cur;
            END IF;


            IF arch_cur%ISOPEN THEN
               CLOSE arch_cur;
            END IF;

            /* logging errors */
            Toss_Util_Pkg.insert_error_tab_proc (
               'Exception caught by when others (inner)',
               NVL (l_serial_number, 'NOT DEFINED'),
               l_procedure_name
            );
            COMMIT;
      END;   /* of Inner Block with exception handler */

      /* RESET TO NULL AFTER EACH LOOP */
      l_serial_number := NULL;
      l_toss_posa_date := NULL;
      l_is_archived := FALSE;

      /* Cleaning up */
      IF not_arch_cur%ISOPEN THEN
         CLOSE not_arch_cur;
      END IF;


      IF arch_cur%ISOPEN THEN
         CLOSE arch_cur;
      END IF;

      COMMIT;
   END LOOP;

   COMMIT;


   IF Toss_Util_Pkg.insert_interface_jobs_fun (
         l_procedure_name,
         l_start_date,
         SYSDATE,
         l_recs_processed,
         'SUCCESS',
         l_procedure_name
      ) THEN
      COMMIT;
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK;
      Toss_Util_Pkg.insert_error_tab_proc (
         'Exception caught by when others (outer)',
         NVL (l_serial_number, 'NOT DEFINED'),
         l_procedure_name
      );
      COMMIT;


      IF Toss_Util_Pkg.insert_interface_jobs_fun (
            l_procedure_name,
            l_start_date,
            SYSDATE,
            l_recs_processed,
            'FAILED',
            l_procedure_name
         ) THEN
         COMMIT;
      END IF;
END;
/