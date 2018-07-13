CREATE OR REPLACE PROCEDURE sa."SP_AUTOPAY_TEST_RECS"
/**************************************************************************************************/
/* Name         :   SP_AUTOPAY_TEST_RECS
/* Type         :   Procedure
/* Purpose      :   To return all records in table_x_group2esn that are associated to
/*                  x_promo_code: '80020' or '51777' or '50974' OR '55281' and qualify them for units.
/* Parameters   :   Input  - No input  params
/*                  Output - No output params
/* Author       :   Gerald Pintado
/* Date         :   06/12/2003
/* Revisions    :   Version  Date       Who             Purpose
/*                  -------  --------   -------         -----------------------
/*                  1.0      06/12/2003 Gpintado        Initial revision
/*                  1.2      09/22/2003 Gpintado        Added Promo Code: 51777
/*                  1.3      10/10/2003 Gpintado        Added validation to qualify ESNs
/*                                                      when payment_date > enroll_date
/*                  1.4      11/18/2003 Vadapa          CR2196 (Insert monthly units into pending)
/*                                                      Add promos:      50974
/*                                                      Add blast_id:    50
/*                  1.5      11/21/2003 Gpintado        Changed TotalDays logic
/*                  1.6      12/15/2003 Gpintado        Changed TotalDays logic to sysdate - max(payment_date)
/*                  1.7      01/13/2004 Gpintado        CR2416 Added logic to check for prior Reversal record
/*                                                      and add a 2 day delay from date_received to current date
/*                                                      to qualify for units.
/*                  1.8      03/09/2004 Gpintado        CR2575 New Logic to check for qualified payments
/*                                                      before reversal.
/*                  1.9      04/01/2004 Gpintado        CR2676 (Add promo with 60 bonus units)
/*                                                      Added Promo Code: 55281
/*                                                      Add blast_id: 70
/**************************************************************************************************/

IS

   CURSOR c_getpendingrecs
   IS
     SELECT c.part_serial_no,
            a.x_start_date enroll_date,
            b.x_promo_code
       FROM table_x_group2esn a,
            table_x_promotion b,
            table_part_inst c
      WHERE a.groupesn2x_promotion = b.objid
        AND b.x_promo_code IN ('80020',  '51777', '50974','55281')
        AND a.groupesn2part_inst = c.objid
        AND a.objid = (SELECT MAX(d.objid)
                         FROM table_x_group2esn d, table_x_promotion e
                        WHERE d.groupesn2part_inst = c.objid
                          AND d.groupesn2x_promotion = e.objid
                          AND e.x_promo_code IN ('80020', '51777', '50974','55281'));


---------------------------------------------------------
   CURSOR c_receive_ftp (c_esn VARCHAR2)
   IS
      SELECT a.ROWID, a.*
        FROM sa.x_receive_ftp_auto a
       WHERE program_type = 3
         AND pay_type_ind = 'PAY'
         AND qualified_date IS NULL
         AND date_received < SYSDATE-1  /* 1 Day Delay to qualify for units */
         AND rec_seq_no = (SELECT MAX (rec_seq_no)
                             FROM sa.x_receive_ftp_auto
                            WHERE esn = c_esn);

---------------------------------------------------------
    CURSOR c_receive_ftp_days (c_esn VARCHAR2,c_EnrollDate date)
   IS
       SELECT NVL(SYSDATE - MAX(date_received),0) totaldays
         FROM sa.x_receive_ftp_auto
        WHERE esn = c_esn
          AND trunc(date_received) >= trunc(c_EnrollDate)
          AND qualified_date IS NOT NULL
          AND rev_flag IS NULL;


   r_receive_ftp_days c_receive_ftp_days%ROWTYPE;
---------------------------------------------------------
   CURSOR c_autopay_details (c_esn VARCHAR2)
   IS
      SELECT x_enroll_date
        FROM sa.table_x_autopay_details
       WHERE x_esn = c_esn
         AND x_program_type = 3
         AND x_status = 'A';


   r_autopay_details c_autopay_details%ROWTYPE;
---------------------------------------------------------
--CR2196
   CURSOR c_pend_promo (c_promo_code in varchar2)
   IS
      SELECT objid, x_revenue_type
        FROM table_x_promotion
       WHERE x_promo_code = c_promo_code -- 'REDAPAYDM'
         AND SYSDATE BETWEEN x_start_date AND x_end_date;


   r_pend_promo c_pend_promo%ROWTYPE;

---------------------------------------------------------

   CURSOR c_active_sp (c_ip_esn IN VARCHAR2)
   IS
      SELECT objid
        FROM table_site_part
       WHERE x_service_id = c_ip_esn
         AND part_status || '' = 'Active';


   r_active_sp   c_active_sp%ROWTYPE;
--End CR2196
---------------------------------------------------------

  CURSOR c_get2nd_to_last_rec(c_esn in VARCHAR2, c_rec_seq_no in NUMBER)
  IS
     SELECT a.rowid,a.*
       FROM sa.x_receive_ftp_auto a
      WHERE esn = c_esn
        AND rec_seq_no = (SELECT max(rec_seq_no)
                            FROM sa.x_receive_ftp_auto
                           WHERE esn = c_esn AND rec_seq_no <> c_rec_seq_no);

     r_get2nd_to_last_rec   c_get2nd_to_last_rec%ROWTYPE;
---------------------------------------------------------
--CR2575
  CURSOR c_Chk_RevCard(c_esn in VARCHAR2, c_rec_seq_no in NUMBER)
  IS
     SELECT *
       FROM sa.x_receive_ftp_auto
      WHERE rec_seq_no = (SELECT max(rec_seq_no)
                            FROM sa.x_receive_ftp_auto a
                           WHERE esn = c_esn
                             AND rec_seq_no < c_rec_seq_no);

     r_Chk_RevCard   c_Chk_RevCard%ROWTYPE;
-- End CR2575

---------------------------------------------------------

 v_continue number := 1;  /* 0=false, 1=true */

 v_promo_code varchar2(20);

 v_blast_id number;

BEGIN



   FOR r_getpendingrecs IN c_getpendingrecs
   LOOP

       IF r_getpendingrecs.x_promo_code in ('80020','51777','50974') THEN
          v_promo_code := 'REDAPAYDM';
          v_blast_id   := 50;
       ELSIF r_getpendingrecs.x_promo_code = '55281' THEN
          v_promo_code := 'REDAPAYDM1';
          v_blast_id   := 70;
       END IF;


       --CR2196
       OPEN c_pend_promo(v_promo_code);
       FETCH c_pend_promo INTO r_pend_promo;
       CLOSE c_pend_promo;
       --End CR2196

      FOR r_receive_ftp IN c_receive_ftp (r_getpendingrecs.part_serial_no)
      LOOP

       /* New Logic to check for Reversals */

         OPEN c_get2nd_to_last_rec (r_receive_ftp.esn,
                                    r_receive_ftp.rec_seq_no);
         FETCH c_get2nd_to_last_rec INTO r_get2nd_to_last_rec;

         v_continue := 1;

         IF c_get2nd_to_last_rec%FOUND
         THEN  /* Check to see if second to last rec is of type 'REV' */
            IF (r_get2nd_to_last_rec.pay_type_ind = 'REV') and
                (TRUNC (r_get2nd_to_last_rec.date_received) >=
                 TRUNC (r_getpendingrecs.enroll_date))
            THEN
               /* Check to see if there is a payment before 'REV' */
               OPEN c_Chk_RevCard (r_receive_ftp.esn,
                                   r_get2nd_to_last_rec.rec_seq_no);
               FETCH c_Chk_RevCard INTO r_Chk_RevCard;

               IF c_Chk_RevCard%FOUND
               THEN /* Check to see if payment rec was qualified */
                  IF (r_Chk_RevCard.pay_type_ind = 'PAY') AND
                     (r_Chk_RevCard.qualified_date is not null) and
                     (TRUNC (r_Chk_RevCard.date_received) >=
                      TRUNC (r_getpendingrecs.enroll_date))
                  THEN /* If qualified, update last payment and do not continue on */
                    UPDATE sa.x_receive_ftp_auto
                       SET rev_flag = '1',
                           qualified_date = SYSDATE
                     WHERE ROWID = r_receive_ftp.ROWID;
                     commit;
                     v_continue := 0;
                  END IF;
               END IF;
            END IF;
         END IF;

         IF v_continue = 1
         THEN

       /* End of New Logic to check for Reversals */

           IF TRUNC (r_receive_ftp.date_received) >=
                 TRUNC (r_getpendingrecs.enroll_date)
           THEN

              OPEN c_receive_ftp_days (r_getpendingrecs.part_serial_no,
                                       r_getpendingrecs.enroll_date);
              FETCH c_receive_ftp_days INTO r_receive_ftp_days;
              CLOSE c_receive_ftp_days;


              IF    (r_receive_ftp_days.totaldays = 0)
                 OR (r_receive_ftp_days.totaldays > 19)
              THEN

                 OPEN c_autopay_details (r_getpendingrecs.part_serial_no);
                 FETCH c_autopay_details INTO r_autopay_details;


                 IF c_autopay_details%FOUND
                 THEN
--CR2196
                    OPEN c_active_sp (r_getpendingrecs.part_serial_no);
                    FETCH c_active_sp INTO r_active_sp;


                    IF c_active_sp%FOUND
                    THEN
                       INSERT INTO table_x_pending_redemption
                                   (
                                                  objid,
                                                  pend_red2x_promotion,
                                                  x_pend_red2site_part,
                                                  x_pend_type
                                   )
                            VALUES(
                               sa.seq ('x_pending_redemption'),
                               r_pend_promo.objid,
                               r_active_sp.objid,
                               r_pend_promo.x_revenue_type
                            );
--End CR2196
                       UPDATE sa.x_receive_ftp_auto
                          SET qualified_date = SYSDATE
                        WHERE ROWID = r_receive_ftp.ROWID;


                       INSERT INTO x_raf_replies
                                   (
                                     blast_id,
                                     friend_esn,
                                     customer_esn,
                                     register_date,
                                     reply_date,
                                     friend_min,
                                     friend_email,
                                     units_sent,
                                     card_objid_customer,
                                     card_objid_friend,
                                     card_smp_customer,
                                     card_smp_friend
                                   )
                            VALUES(
                               v_blast_id,
                               NULL,
                               r_getpendingrecs.part_serial_no,
                               SYSDATE,
                               NULL,
                               NULL,
                               NULL,
                               'N',
                               0,
                               0,
                               NULL,
                               NULL
                            );

                       COMMIT;
                    END IF;

                    CLOSE c_active_sp;
                 END IF;

                 CLOSE c_autopay_details;
              END IF;
           END IF;
         END IF;
         IF c_Chk_RevCard%ISOPEN THEN CLOSE c_Chk_RevCard; END IF;
         IF c_get2nd_to_last_rec%ISOPEN THEN CLOSE c_get2nd_to_last_rec; END IF;
      END LOOP;
   END LOOP;

EXCEPTION

   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (SQLERRM || ': Contact System Administrator');
      raise_application_error (
         -20001,
         SQLERRM || ': Contact System Administrator'
      );
END sp_autopay_test_recs;
/