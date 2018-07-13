CREATE OR REPLACE PROCEDURE sa."SP_UPDATE_DEALER_INFO" (ip_esn      IN  VARCHAR2,
                                                      ip_email    IN  VARCHAR2,
                                                      op_err_msg  OUT VARCHAR2,
                                                      op_err_code OUT NUMBER)
IS
 CURSOR inv_bin_lction_cur (c_site_id IN NUMBER)
     IS
        SELECT ib.objid, s.site_id, s.name
          FROM sa.table_site s,
               sa.table_inv_bin ib,
               sa.table_inv_locatn il
         WHERE s.objid = il.inv_locatn2site
           AND il.objid = ib.inv_bin2inv_locatn
           AND s.objid = c_site_id;--1428197792;

  inv_bin_lction_rec inv_bin_lction_cur%ROWTYPE;

 CURSOR dealer_info_cur
     IS
        SELECT s.objid, s.name dealer_name
        FROM   sa.table_web_user wu,
               sa.table_x_contact_part_inst cpi,
               sa.table_part_inst pi,
               sa.x_site_web_accounts swa ,
               sa.table_site s
        WHERE  wu.login_name                     = ip_email--'sit125org02@yopmail.com'
          AND  wu.web_user2contact               = cpi.x_contact_part_inst2contact
          AND  cpi.x_contact_part_inst2part_inst = pi.objid
          AND  wu.objid                          = swa.site_web_acct2web_user
          AND  swa.site_web_acct2site            = s.objid
          AND  pi.part_serial_no                 = ip_esn;--'100000000013537277';

  dealer_info_rec dealer_info_cur%ROWTYPE;

BEGIN

   IF ip_esn IS NULL OR ip_email IS NULL THEN
      op_err_msg  := 'ESN AND  EMAIL ARE MANDATORY';
      op_err_code := 1;
      RETURN;
   END IF;

   OPEN dealer_info_cur;
    FETCH dealer_info_cur INTO dealer_info_rec;
     IF dealer_info_cur%FOUND THEN
       OPEN inv_bin_lction_cur (dealer_info_rec.objid);
        FETCH inv_bin_lction_cur INTO inv_bin_lction_rec;
         IF inv_bin_lction_cur%FOUND THEN

              UPDATE table_part_inst
                 SET part_inst2inv_bin = inv_bin_lction_rec.objid--268944542
               WHERE Part_Serial_No    = ip_esn;--'100000000013537277';

              COMMIT;
         ELSE
            op_err_msg  := 'INVENTORY INFO NOT FOUND';
            op_err_code := 2;
            CLOSE inv_bin_lction_cur;
            CLOSE dealer_info_cur;
            RETURN;
        END IF;
      CLOSE inv_bin_lction_cur;
     ELSE
         op_err_msg  := 'DEALER INFO NOT FOUND';
         op_err_code := 3;
         CLOSE dealer_info_cur;
         RETURN;
    END IF;
   CLOSE dealer_info_cur;
    op_err_msg  := 'SUCCESS';
    op_err_code := 0;

EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_lINE (SQLERRM);
      op_err_msg  := 'FAILED';
      op_err_code := 1;

END SP_UPDATE_DEALER_INFO;
/