CREATE OR REPLACE PROCEDURE sa."INSERT_PROG_DISC_HIST_PRC" (
 ip_ESN IN VARCHAR2,
 ip_PROMO IN VARCHAR2,
 op_result OUT NUMBER -- 0=SUCCESS,1=FAILURE
)
IS
/************************************************************************************************/
 /* Copyright ) 2010 Tracfone Wireless Inc. All rights reserved 	*/
 /* 			 	*/
 /* NAME: SA.insert_prog_disc_hist_prc 	*/
 /* PURPOSE: 	*/
 /* FREQUENCY: 			*/
 /* PLATFORMS: 					*/
 /* REVISIONS: VERSION DATE WHO PURPOSE 	*/
 /* ------- ---------- --------------- -------------------           			*/
   /*               1.0      07/01/10    YM               Initial Revision              		*/
   /*               1.1-2      08/05/10    YM               get hdr from   table_x_purch_dtl               */
   /**********************************************************************************************/
   CURSOR get_enrolled_info_cur
   IS
      SELECT pg.pgm_enroll2prog_hdr,
                       pg.x_esn,
                       pg.pgm_enroll2x_promotion,
                       pg.objid,
                       pg.pgm_enroll2web_user
          FROM x_program_enrolled pg
       WHERE x_esn = ip_esn;

   v_disc_amount number;
   v_objid_promo number;
   v_count_disc  number;
   get_enrolled_info_rec           get_enrolled_info_cur%ROWTYPE;
   v_procedure_name   CONSTANT VARCHAR2 (200)         := 'insert_prog_disc_hist_prc';
   v_objid_dtl    number;
   v_hdr        number;
   l_result      number;      --CR49229

   e_notfound                  EXCEPTION;
BEGIN
   OPEN get_enrolled_info_cur;

   FETCH get_enrolled_info_cur
    INTO get_enrolled_info_rec;

   IF get_enrolled_info_cur%NOTFOUND
   THEN
        DBMS_OUTPUT.PUT_LINE('not enrolled');
        op_result := 1;
      RAISE e_notfound;

      CLOSE get_enrolled_info_cur;
   ELSE

      select x_discount_amount, objid
       into v_disc_amount, v_objid_promo
       from table_x_promotion
       where x_promo_code = ip_promo;

-- START CR49229
       enroll_promo_pkg.get_discount_amount(ip_ESN,
                             v_objid_promo,
                             null,
                             v_disc_amount,
                             l_result);

-- END CR49229


       select max(x_purch_dtl2x_purch_hdr)
            into   v_hdr
      from table_x_purch_dtl
       where x_purch_dtl2x_purch_hdr  in ( select objid from  table_x_purch_hdr where x_esn = ip_esn)
       and x_units = 400
       order by x_purch_dtl2x_purch_hdr;


      select count(*)
          into v_count_disc
      from x_program_discount_hist pg, table_x_promotion p
      where pg.pgm_discount2pgm_enrolled in (select objid from  x_program_enrolled where x_esn = ip_esn)
      and pg.pgm_discount2x_promo = p.objid and p.x_promo_code = ip_promo;

        if v_count_disc = 0 then
        INSERT
               INTO x_program_discount_hist(
                  objid,
                  x_discount_amount,
                  pgm_discount2x_promo,
                  pgm_discount2pgm_enrolled,
                  pgm_discount2prog_hdr,
                  pgm_discount2web_user
               )  VALUES(
                  billing_seq ('X_PROGRAM_DISCOUNT_HIST'),
                  v_disc_amount,
                  v_objid_promo,
                  get_enrolled_info_rec.objid,
                  v_hdr,
                  get_enrolled_info_rec.pgm_enroll2web_user
               );
         else
         op_result := 1; -- exist into table x_program_discount_hist
         end if;

  END IF;
      COMMIT;
   IF get_enrolled_info_cur%ISOPEN
   THEN
      CLOSE get_enrolled_info_cur;
   END IF;
      op_result := 0;
EXCEPTION
   WHEN e_notfound
   THEN
      IF get_enrolled_info_cur%ISOPEN
      THEN
         CLOSE get_enrolled_info_cur;
      END IF;
       DBMS_OUTPUT.PUT_LINE('not enrolled ESN return 1 ');
          op_result := 1;
      toss_util_pkg.insert_error_tab_proc ('Failed inserting discount',
                                           ip_ESN,
                                           v_procedure_name,
                                           'Enroll not found'
                                          );
   WHEN OTHERS
   THEN
      IF get_enrolled_info_cur%ISOPEN
      THEN
         CLOSE get_enrolled_info_cur;
      END IF;
      DBMS_OUTPUT.PUT_LINE('when others return 1 ');
      op_result := 1;
      toss_util_pkg.insert_error_tab_proc ('Failed inserting discount',
                                           ip_ESN,
                                           v_procedure_name,
                                           SUBSTR (SQLERRM, 1, 200)
                                          );
END;
/