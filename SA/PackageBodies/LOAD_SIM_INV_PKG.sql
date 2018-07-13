CREATE OR REPLACE PACKAGE BODY sa."LOAD_SIM_INV_PKG"
IS
 --********************************************************************************
 --$RCSfile: LOAD_SIM_INV_PKG.sql,v $
 --$Revision: 1.3 $
 --$Author: skota $
 --$Date: 2015/09/16 19:45:25 $
 --$ $Log: LOAD_SIM_INV_PKG.sql,v $
 --$ Revision 1.3  2015/09/16 19:45:25  skota
 --$ Added header comments for revision
 --$
 --$ Added header comments for revision
 --$ Revision 1.2  2015/08/28 12:18:46  skota
 --$ New procedure added for UPDATE IMSI value in TABLE SIM INV
 --$ CR37514 changes.
 --********************************************************************************
--/**************************************************************************/
/* Name         :   SA.LOAD_SIM_INV_PKG
/* Purpose      :   ICCID FILE LOAD PROCESS into Staging table From
/*                  Clarify Client
/* Author       :  Gerald Pintado
/* Date         :  04/15/2004
/* Revisions    :
/* Version  Date       Who       Purpose
/* -------  --------   -------   --------------------------
/* 1.0      04/15/2003 Gpintado  Initial revision
/* 1.1      09/01/2004 Gpintado  CR3171 Optimized pkg for faster performance
/**************************************************************************/
--/**************************************************************************/
/*
/* Name:     GET_TRANS_ID
/* Description : Uses the ID to insert into staging
/**************************************************************************/

PROCEDURE GET_TRANS_ID(IP_DUMMY IN VARCHAR2,OP_TRANS_ID OUT NUMBER)
IS
BEGIN

  SP_SEQ('X_SIM_INV',OP_TRANS_ID);

END;


/**************************************************************************/
/*
/* Name:     SA.LOAD_SIM_STG
/* Description : ICCID FILE LOAD FOR EACH RECORD FROM CLARIFY CLIENT
/**************************************************************************/

PROCEDURE LOAD_SIM_STG(
     IP_SIM_SERIAL_NUM IN VARCHAR2,
     IP_SIM_PO_NUM     IN VARCHAR2,
     IP_PART_NUM       IN VARCHAR2,
     IP_MANUF_SITE_ID  IN VARCHAR2,
     IP_MANUF_NAME     IN VARCHAR2,
     IP_PIN1           IN VARCHAR2,
     IP_PIN2           IN VARCHAR2,
     IP_PUK1           IN VARCHAR2,
     IP_PUK2           IN VARCHAR2,
     IP_TRANS_ID       IN NUMBER,
     IP_QTY            IN NUMBER,
     IP_USEROBJID      IN NUMBER,
     OP_RESULT        OUT NUMBER,
     OP_MSG           OUT VARCHAR2
   )
IS

BEGIN


 INSERT INTO X_SIM_INV_STG
     (
        TRANS_ID,
        SIM_SERIAL_NUM,
        SIM_PO_NUM,
        PART_NUM,
        MANUF_SITE_ID,
        MANUF_NAME,
        PIN1,
        PIN2,
        PUK1,
        PUK2,
        QTY,
        USEROBJID
      )
     VALUES
     (IP_TRANS_ID,
      IP_SIM_SERIAL_NUM,
      IP_SIM_PO_NUM,
      IP_PART_NUM,
      IP_MANUF_SITE_ID,
      IP_MANUF_NAME,
      IP_PIN1,
      IP_PIN2,
      IP_PUK1,
      IP_PUK2,
      IP_QTY,
      IP_USEROBJID
     );
     COMMIT;

  /** Call Procedure to load **/
  LOAD_SIM_INV(IP_TRANS_ID,OP_RESULT,OP_MSG);

EXCEPTION
WHEN OTHERS THEN
 NULL;
END;


/**************************************************************************/
/*
/* Name:     SA.LOAD_SIM_INV
/* Description : ICCID FILE LOAD PROCESS into TOSS
/**************************************************************************/

PROCEDURE LOAD_SIM_INV(IP_TRANS_ID  IN  NUMBER,
                       OP_RESULT   OUT  NUMBER,
                       OP_MSG      OUT  VARCHAR2)
IS

   v_action                   VARCHAR2(50) := ' ';
   v_err_text                 VARCHAR2(4000);
   v_dealer_status            VARCHAR2(20);
   v_serial_num               VARCHAR2(50);
   v_revision                 VARCHAR2(10);
   v_part_inst2part_mod       NUMBER;
   v_part_inst2part_mod_2     NUMBER;
   v_part_inst_seq            NUMBER;
   v_site_id                  VARCHAR2(80);
   v_out_action               VARCHAR2(50);
   v_procedure_name           VARCHAR2(80) := 'LOAD_SIM_INV_PKG.LOAD_SIM_INV';
   v_recs_processed           NUMBER := 0;
   v_start_date               DATE   := SYSDATE;
   v_mnc                      VARCHAR2(6) := NULL;
   v_rowid                    VARCHAR2(30);
   no_site_id_exp             EXCEPTION;
   distributed_trans_time_out EXCEPTION;
   record_locked              EXCEPTION;
   v_failed_records           NUMBER := 0;
   v_success_records          NUMBER := 0;

   table_x_default_rec   table_x_default_preload%ROWTYPE;


--
   PRAGMA EXCEPTION_INIT(distributed_trans_time_out, -2049);
   PRAGMA EXCEPTION_INIT(record_locked, -54);
--

/* Cursor to extract PHONES/CARDS data from TF_TOSS_INTERFACE_TABLE via database link*/
   CURSOR c_inv_inbound
   IS

       SELECT A.ROWID, PART_NUM,SIM_SERIAL_NUM,
              MANUF_SITE_ID,MANUF_NAME, SIM_PO_NUM,
              PIN1,PIN2,PUK1,PUK2,QTY,USEROBJID
         FROM
              sa.X_SIM_INV_STG A

        WHERE TRANS_ID = IP_TRANS_ID
      AND EXISTS (SELECT 1
                      FROM tf.tf_of_item_v@ofsprd iv
                   WHERE part_number = PART_NUM
                     AND clfy_domain = 'SIM CARDS'
                     AND part_assignment = 'PARENT');


/* Cursor to get the part domain object id */
   CURSOR c_get_domain_objid (c_ip_domain IN VARCHAR2)
   IS
      SELECT objid
        FROM table_prt_domain
       WHERE name = c_ip_domain;

   r_get_domain_objid       c_get_domain_objid%ROWTYPE;


/* Cursor to get the part number object id */
   CURSOR c_part_exists (c_ip_domain2 IN VARCHAR2,  c_ip_part_number IN VARCHAR2)
   IS
      SELECT objid,x_technology
        FROM table_part_num
       WHERE part_number = c_ip_part_number
         AND part_num2domain = c_ip_domain2;

   r_part_exists            c_part_exists%ROWTYPE;


/* Cursor to get bin object id */
   CURSOR c_load_inv_bin_objid (c_ip_customer_id IN VARCHAR2)
   IS
      SELECT objid
        FROM table_inv_bin
       WHERE bin_name = c_ip_customer_id;

   r_load_inv_bin_objid     c_load_inv_bin_objid%ROWTYPE;


/* Cursor to get code object id */
/* added POSA PHONES            */
   CURSOR c_load_code_table (c_ip_domain4 IN VARCHAR2)
   IS
      SELECT objid
        FROM table_x_code_table
       WHERE x_code_number = DECODE (
                   c_ip_domain4,
                   'SIM', '253',
                   'POSA SIM', '253'
                );

   r_load_code_table        c_load_code_table%ROWTYPE;


/* Cursor to check if the serial number exists in table_x_sim_inv */
   CURSOR c_check_part_inst (c_ip_serial_number   IN   VARCHAR2)
   IS
     SELECT a.*,b.x_code_name,b.x_code_number
       FROM table_x_sim_inv a, table_x_code_table b
      WHERE x_sim_serial_no = c_ip_serial_number
        AND x_sim_status2x_code_table = b.objid;

   r_check_part_inst        c_check_part_inst%ROWTYPE;


/* Cursor to get part number object id associated with the revision of the part number */
   CURSOR c_load_mod_level_objid (c_ip_part_number IN VARCHAR2,
                                  c_ip_revision    IN VARCHAR2,
                                  c_ip_domain      IN VARCHAR2)
   IS
      SELECT a.objid
        FROM table_mod_level a, table_part_num b
       WHERE a.mod_level = c_ip_revision
         AND a.part_info2part_num = b.objid
         AND a.active = 'Active'   --Digital
         AND b.part_number = c_ip_part_number
         AND b.domain = c_ip_domain;


   r_load_mod_level_objid   c_load_mod_level_objid%ROWTYPE;


   processed_counter     NUMBER := 0;
   inner_counter         NUMBER := 0;
   r_seq_part_script_val NUMBER;
   r_seq_part_num_val    NUMBER;
   r_seq_mod_level_val   NUMBER;

BEGIN

      FOR r_inv_inbound IN c_inv_inbound
      LOOP

         v_recs_processed := v_recs_processed + 1;

         BEGIN
            v_serial_num           := r_inv_inbound.SIM_SERIAL_NUM;
            v_rowid                := r_inv_inbound.ROWID;
            v_site_id              := null;
            v_dealer_status        := null;
            v_part_inst2part_mod_2 := null;

            IF r_inv_inbound.MANUF_SITE_ID IS NOT NULL THEN
               v_site_id := r_inv_inbound.MANUF_SITE_ID;
            END IF;


            IF v_site_id IS NOT NULL THEN

                /* combined new field part_subtype */
                  v_revision := r_inv_inbound.PART_NUM;

               v_dealer_status := '253'  ;
               v_action := ' ';


               /* Get the domain object id */
               OPEN c_get_domain_objid ('SIM CARDS');
               FETCH c_get_domain_objid INTO r_get_domain_objid;
               CLOSE c_get_domain_objid;

              /* Get the part sequence number */
               OPEN c_part_exists (
                  r_get_domain_objid.objid,
                  r_inv_inbound.PART_NUM
               );
               FETCH c_part_exists INTO r_part_exists;
               CLOSE c_part_exists;

               v_mnc := r_part_exists.x_technology;


               OPEN c_load_mod_level_objid (
                  r_inv_inbound.PART_NUM,
                  v_revision,
                  'SIM CARDS'
               );
               FETCH c_load_mod_level_objid INTO v_part_inst2part_mod_2;
               CLOSE c_load_mod_level_objid;

               OPEN c_load_inv_bin_objid (v_site_id);
               FETCH c_load_inv_bin_objid INTO r_load_inv_bin_objid;
               CLOSE c_load_inv_bin_objid;




                  IF v_dealer_status = '253' THEN
                     OPEN c_load_code_table ('SIM');
                     FETCH c_load_code_table INTO r_load_code_table;
                     CLOSE c_load_code_table;
                  END IF;



               OPEN c_check_part_inst (r_inv_inbound.SIM_SERIAL_NUM);
               FETCH c_check_part_inst INTO r_check_part_inst;

               v_part_inst2part_mod := v_part_inst2part_mod_2;


               IF c_check_part_inst%NOTFOUND THEN

                  v_action := 'Insert into table_x_sim_inv';
                  OP_RESULT  := 0;
                  OP_MSG := 'Successful Insert';

                  sp_seq('X_SIM_INV',v_part_inst_seq);

                   /** SIM_INSERT **/
                   INSERT INTO table_x_sim_inv
                              (objid,
                               x_sim_serial_no,
                               X_SIM_INV_STATUS,
                               X_SIM_PO_NUMBER,
                               X_CREATED_BY2USER,
                               X_SIM_INV2PART_MOD,
                               X_SIM_INV2INV_BIN,
                               X_INV_INSERT_DATE,
                               X_SIM_STATUS2X_CODE_TABLE,
                               X_SIM_MNC,
                               X_PIN1,
                               X_PIN2,
                               X_PUK1,
                               X_PUK2,
                               X_QTY)
                       VALUES
                            (v_part_inst_seq,
                             r_inv_inbound.SIM_SERIAL_NUM,
                             v_dealer_status,
                             r_inv_inbound.SIM_PO_NUM,
                             r_inv_inbound.USEROBJID,
                             v_part_inst2part_mod,
                             r_load_inv_bin_objid.objid,
                             v_start_date,
                             r_load_code_table.objid,
                             v_mnc,
                             r_inv_inbound.PIN1,
                             r_inv_inbound.PIN2,
                             r_inv_inbound.PUK1,
                             r_inv_inbound.PUK2,
                             r_inv_inbound.QTY);

               ELSIF r_check_part_inst.x_sim_inv_status = '253' THEN

                        v_action := 'Update table_x_sim_inv ';
                        OP_RESULT := 1;
                        OP_MSG    := 'Successful Update';


                        UPDATE table_x_sim_inv
                           SET X_SIM_INV_STATUS   = v_dealer_status,
                               X_SIM_PO_NUMBER    = r_inv_inbound.SIM_PO_NUM,
                               X_CREATED_BY2USER  = r_inv_inbound.USEROBJID,
                               X_LAST_UPDATE_DATE = v_start_date,
                               X_SIM_INV2PART_MOD = v_part_inst2part_mod,
                               X_SIM_INV2INV_BIN  = r_load_inv_bin_objid.objid,
                               X_SIM_MNC          = v_mnc,
                               X_PIN1             = r_inv_inbound.PIN1,
                               X_PIN2             = r_inv_inbound.PIN2,
                               X_PUK1             = r_inv_inbound.PUK1,
                               X_PUK2             = r_inv_inbound.PUK2,
                               X_QTY              = r_inv_inbound.QTY,
                               X_SIM_STATUS2X_CODE_TABLE= r_load_code_table.objid
                         WHERE X_SIM_SERIAL_NO = r_inv_inbound.SIM_SERIAL_NUM;

                         v_action := 'Update tf_toss_interface_table 2';
               ELSE
                 OP_RESULT := 2;
                 OP_MSG := 'No action: ' || r_check_part_inst.x_code_name;

               END IF;   /* end of part id check */

               CLOSE c_check_part_inst;

               COMMIT;


            ELSE

               RAISE no_site_id_exp;
            END IF;   /* end of site_id existence check */

            /********************************************************/
            /** Delete Record, Complete Process Has Been Performed **/
            /********************************************************/
            DELETE sa.X_SIM_INV_STG
             WHERE rowid = r_inv_inbound.rowid;

             COMMIT;

         EXCEPTION

               WHEN no_site_id_exp THEN
             TOSS_UTIL_PKG.insert_error_tab_proc (
                v_out_action || ' NO SITE ID',
                    v_serial_num,
                    v_procedure_name,
                'Inner Block Error '
                    );
                  /* Deletes failed record */
                  DELETE sa.X_SIM_INV_STG
                   WHERE rowid = V_ROWID;
                  COMMIT;
                  v_failed_records := v_failed_records + 1;
                  OP_RESULT := 2;
                  OP_MSG    := ':No SiteID';

           WHEN distributed_trans_time_out   THEN
                 TOSS_UTIL_PKG.insert_error_tab_proc (
                 v_out_action ||  ' Caught distributed_trans_time_out',
                    v_serial_num,
                    v_procedure_name,
                'Inner Block Error '
                    );
                  /* Deletes failed record */
                  DELETE sa.X_SIM_INV_STG
                   WHERE rowid = V_ROWID;
                  COMMIT;
                  v_failed_records := v_failed_records + 1;
                  OP_RESULT := 2;
                  OP_MSG    := ':Time out';

           WHEN record_locked  THEN
             TOSS_UTIL_PKG.insert_error_tab_proc (
            v_out_action ||  ' Caught distributed_trans_time_out',
                    v_serial_num,
                    v_procedure_name,
                'Inner Block Error '
                    );
                 /* Deletes failed record */
                 DELETE sa.X_SIM_INV_STG
                   WHERE rowid = V_ROWID;
                  COMMIT;
                  v_failed_records := v_failed_records + 1;
                  OP_RESULT := 2;
                  OP_MSG    := ':Record Locked';


               WHEN OTHERS THEN
                 v_err_text := sqlerrm;
                 TOSS_UTIL_PKG.insert_error_tab_proc (
                    'Inner Block Error -When others',
                    v_serial_num,
                    v_procedure_name
                    );
                 /* Deletes failed record */
                 DELETE sa.X_SIM_INV_STG
                   WHERE rowid = V_ROWID;
                  COMMIT;
                 v_failed_records := v_failed_records + 1;
                 OP_RESULT := 2;
                 OP_MSG    := ':Oracle Error- ' || sqlcode;

         END;

         /** cleaning up **/

         IF c_get_domain_objid%ISOPEN THEN
            CLOSE c_get_domain_objid;
         END IF;


         IF c_part_exists%ISOPEN THEN
            CLOSE c_part_exists;
         END IF;


         IF c_load_mod_level_objid%ISOPEN THEN
            CLOSE c_load_mod_level_objid;
         END IF;


         IF c_load_inv_bin_objid%ISOPEN THEN
            CLOSE c_load_inv_bin_objid;
         END IF;


         IF c_load_code_table%ISOPEN THEN
            CLOSE c_load_code_table;
         END IF;


         IF c_check_part_inst%ISOPEN THEN
            CLOSE c_check_part_inst;
         END IF;

         COMMIT;
         /* Reset v_mnc */
         v_mnc := NULL;

      END LOOP;   /* end of r_inv_inbound loop */

   COMMIT;



  IF toss_util_pkg.insert_interface_jobs_fun (
         v_procedure_name,
         v_start_date,
         SYSDATE,
         v_recs_processed,
         'SUCCESS',
         v_procedure_name
      )
   THEN
      COMMIT;
   END IF;

   DBMS_OUTPUT.PUT_LINE('Failed  Records: ' ||v_failed_records);
   DBMS_OUTPUT.PUT_LINE('Success Records: ' ||v_success_records);

EXCEPTION

    WHEN distributed_trans_time_out   THEN

         TOSS_UTIL_PKG.insert_error_tab_proc (
               v_out_action,
                   v_serial_num,
                   v_procedure_name,
               ' Caught distributed_trans_time_out');
         COMMIT;


         IF toss_util_pkg.insert_interface_jobs_fun (
                  v_procedure_name,
                  v_start_date,
                  SYSDATE,
                  v_recs_processed,
                  'FAILED',
                  v_procedure_name
                )
         THEN
         /* Delete all records under passed in IP_TRANS_ID */
           DELETE sa.X_SIM_INV_STG
            WHERE TRANS_ID = IP_TRANS_ID;
           COMMIT;
         END IF;
         OP_RESULT := 2;
         OP_MSG := ':Time Out';
         DBMS_OUTPUT.PUT_LINE('Error Occured - Caught distributed_trans_time_out');
         DBMS_OUTPUT.PUT_LINE('Failed  Records: ' ||v_failed_records);
         DBMS_OUTPUT.PUT_LINE('Success Records: ' ||v_success_records);


    WHEN record_locked  THEN

         TOSS_UTIL_PKG.insert_error_tab_proc (
            v_out_action,
                v_serial_num,
                v_procedure_name,
            ' Caught record_locked');

         IF toss_util_pkg.insert_interface_jobs_fun (
                  v_procedure_name,
                  v_start_date,
                  SYSDATE,
                  v_recs_processed,
                  'FAILED',
                  v_procedure_name
               )
         THEN
         /* Delete all records under passed in IP_TRANS_ID */
           DELETE sa.X_SIM_INV_STG
            WHERE TRANS_ID = IP_TRANS_ID;
           COMMIT;
         END IF;
         OP_RESULT := 2;
         OP_MSG := ':Record Locked';
         DBMS_OUTPUT.PUT_LINE('Error Occured - Caught record_locked');
         DBMS_OUTPUT.PUT_LINE('Failed  Records: ' ||v_failed_records);
         DBMS_OUTPUT.PUT_LINE('Success Records: ' ||v_success_records);



    WHEN OTHERS THEN

      v_err_text := sqlerrm;

      TOSS_UTIL_PKG.insert_error_tab_proc (
            v_out_action,
                v_serial_num,
                v_procedure_name);

      IF toss_util_pkg.insert_interface_jobs_fun (
             v_procedure_name,
             v_start_date,
             SYSDATE,
             v_recs_processed,
             'FAILED',
             v_procedure_name
        )
      THEN
        /* Delete all records under passed in IP_TRANS_ID */
        DELETE sa.X_SIM_INV_STG
         WHERE TRANS_ID = IP_TRANS_ID;
        COMMIT;
      END IF;
      OP_RESULT := 2;
      OP_MSG := 'Oracle Error- '|| sqlcode;
      DBMS_OUTPUT.PUT_LINE('Error Occured - '|| substr(v_err_text,1,100));
      DBMS_OUTPUT.PUT_LINE('Failed  Records: ' ||v_failed_records);
      DBMS_OUTPUT.PUT_LINE('Success Records: ' ||v_success_records);


END;

--********************************************************************************
-- Procedure TO UPDATE IMSI value in TABLE_X_SIM_INV
-- Procedure was created for CR35154
--********************************************************************************
-- CR35154 Update IMSI starts
PROCEDURE SP_UPD_IMSI_SIM_INV
  ( ip_transaction_id IN  GW1.IG_TRANSACTION.transaction_id%TYPE)
 IS
CURSOR CUR_ICCID_TRANS IS
SELECT ICCID,IMSI FROM GW1.IG_TRANSACTION
 WHERE STATUS = 'W'
   AND ORDER_TYPE IN ('A','E','PIR','EPIR')
   AND NEW_IMSI_FLAG = 'Y'
   AND TRANSACTION_ID = IP_TRANSACTION_ID;

 REC_ICCID_TRANS CUR_ICCID_TRANS%ROWTYPE;
 v_err_text                 VARCHAR2(4000);
 v_procedure_name           VARCHAR2(80) := 'LOAD_SIM_INV_PKG.SP_UPD_IMSI_SIM_INV';
 v_serial_num               VARCHAR2(50);
BEGIN
  OPEN CUR_ICCID_TRANS;
   FETCH CUR_ICCID_TRANS INTO REC_ICCID_TRANS;
      IF   CUR_ICCID_TRANS%FOUND THEN
        IF  REC_ICCID_TRANS.IMSI IS NOT NULL AND REC_ICCID_TRANS.ICCID IS NOT NULL THEN
           --Updating imsi value into table_x_sim_inv
            UPDATE  sa.TABLE_X_SIM_INV
               SET  IG_IMSI = REC_ICCID_TRANS.imsi
             WHERE  X_SIM_SERIAL_NO = REC_ICCID_TRANS.ICCID;
               COMMIT;
         END IF;
    END IF;
   EXCEPTION
     WHEN OTHERS THEN
            --For Tracking errors
       v_err_text   := sqlerrm;
       v_serial_num := REC_ICCID_TRANS.ICCID;
         TOSS_UTIL_PKG.insert_error_tab_proc (
            'Error while updating imsi value',
            v_serial_num,
            v_procedure_name
            );
END SP_UPD_IMSI_SIM_INV;
-- CR35154 Update IMSI  end

END LOAD_SIM_INV_PKG;
/