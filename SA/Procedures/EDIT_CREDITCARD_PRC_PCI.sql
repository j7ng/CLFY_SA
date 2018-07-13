CREATE OR REPLACE PROCEDURE sa."EDIT_CREDITCARD_PRC_PCI" (
   p_cc_objid IN VARCHAR2,
   p_customer_cc_number IN VARCHAR2,
   --This is the Hashed CC Value
   p_customer_cc_expmo IN VARCHAR2,
   p_customer_cc_expyr IN VARCHAR2,
   p_cc_type IN VARCHAR2,
   p_customer_cc_cv_number IN VARCHAR2,
   p_customer_firstname IN VARCHAR2,
   p_customer_lastname IN VARCHAR2,
   p_customer_phone IN VARCHAR2,
   p_customer_email IN VARCHAR2,
   p_changedby IN VARCHAR2,
   p_credit_card2contact IN NUMBER,
   p_card_status IN VARCHAR2,
   p_bus_org IN VARCHAR2, --CR3190
   --PCI Project
   p_customer_cc_enc_number IN VARCHAR2,
   p_customer_key_enc_number IN VARCHAR2,
   p_customer_cc_enc_algorithm IN VARCHAR2,
   p_customer_key_enc_algorithm IN VARCHAR2,
   p_customer_cc_enc_cert IN VARCHAR2,
   --End PCI Project
   p_out_cc_objid OUT VARCHAR2,
   p_errno OUT VARCHAR2,
   p_errstr OUT VARCHAR2
)
AS
/*********************************************************************************************/
   /*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved                           */
   /*                                                                                           */
   /* NAME     :      EDIT_CREDITCARD_PRC_PCI                                                   */
   /* PURPOSE  :   This procedure is called from the method ChangeCreditCard                    */
   /*       of TFCreditCard Java. CBO logic rewritten in PL/SQL for PCI project                 */
   /* FREQUENCY:                                                                                */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                            */
   /*                                                                                           */
   /* REVISIONS:                                                                                */
   --New pl/sql structure
   /* VERSION  DATE        WHO              PURPOSE                                             */
   /* -------  ---------- -----         ---------------------------------------------           */
   /*  1.0     02/24/09   CLindner       PCI changes                                             */

   v_cc_objid NUMBER;
   v_out_cc_objid NUMBER;
   v_org_objid NUMBER;
   v_out_cert_objid NUMBER;
   -- PCI Code
--cwl 4/11/13
   cursor cc_curs is
     select objid
       from table_x_credit_card
      where X_CUSTOMER_CC_NUMBER=p_customer_cc_number
--cwl 4/14/13
        and x_credit_card2bus_org=(SELECT objid FROM table_bus_org WHERE s_org_id = p_bus_org);
--cwl 4/14/13
   cursor mm_curs(c_cc_objid in number,
                  c_credit_card2contact in number) is
     select *
       from mtm_contact46_x_credit_card3
      where mtm_credit_card2contact = c_cc_objid
        and mtm_contact2x_credit_card = c_credit_card2contact;
   mm_rec mm_curs%rowtype;
--cwl 4/11/13
   CURSOR cert_curs   IS
     SELECT objid
       FROM x_cert
      WHERE x_cc_algo = p_customer_cc_enc_algorithm
        AND x_key_algo = p_customer_key_enc_algorithm
        AND x_cert = p_customer_cc_enc_cert;
   cert_rec cert_curs%ROWTYPE;
BEGIN
   p_out_cc_objid := '';
   p_errno := '100';
   p_errstr := 'FAILED';
--cwl 4/11/13
   if p_cc_objid is not null then
    v_cc_objid := TO_NUMBER (p_cc_objid);
   else
     open cc_curs;
       fetch cc_curs into v_cc_objid;
       if v_cc_objid is not null then
         v_out_cc_objid := v_cc_objid;
       end if;
     close cc_curs;
   end if;
--cwl 4/11/13
   OPEN cert_curs;
     FETCH cert_curs INTO cert_rec;
     IF cert_curs%NOTFOUND THEN
      INSERT INTO x_cert(
         objid,
         x_cert,
         x_key_algo,
         x_cc_algo
      )       VALUES(
         seq_x_cert.NEXTVAL,
         p_customer_cc_enc_cert,
         p_customer_key_enc_algorithm,
         p_customer_cc_enc_algorithm
      );
     END IF;
   CLOSE cert_curs;
   --Retrieve objid from X_Cert
   SELECT objid
     INTO v_out_cert_objid
     FROM x_cert
    WHERE x_cc_algo = p_customer_cc_enc_algorithm
      AND x_key_algo = p_customer_key_enc_algorithm
      AND x_cert = p_customer_cc_enc_cert; -- PCI Code
   IF (v_cc_objid   IS   NULL)   THEN
     IF (p_customer_email      IS      NOT NULL)      THEN
        UPDATE table_contact SET e_mail = TRIM (p_customer_email)
         WHERE objid = p_credit_card2contact;
     END IF;
     IF (LENGTH (p_customer_phone) = 10)   THEN
        UPDATE table_contact SET phone = p_customer_phone
         WHERE objid = p_credit_card2contact;
    END IF;
    SELECT seq ('x_credit_card')
      INTO v_out_cc_objid
      FROM DUAL;
    SELECT objid
      INTO v_org_objid
      FROM table_bus_org
     WHERE s_org_id = p_bus_org; -- CR3190
    INSERT
      INTO table_x_credit_card(
         objid,
         x_card_status,
         x_cc_type,
         x_changedby,
         x_credit_card2contact,
         --         x_customer_cc_cv_number,                       CR4023
         x_customer_cc_expmo,
         x_customer_cc_expyr,
         x_customer_cc_number,
         x_customer_email,
         x_customer_firstname,
         x_customer_lastname,
         x_customer_phone,
         x_max_purch_amt,
         x_max_purch_amt_per_month,
         x_max_trans_per_month,
         x_original_insert_date,
         x_credit_card2bus_org,
         --PCI
         x_cust_cc_num_key,
         x_cust_cc_num_enc,
         creditcard2cert
         --END PCI
      )       VALUES(
         v_out_cc_objid,
         p_card_status,
         p_cc_type,
         p_changedby,
         p_credit_card2contact,
         --         p_customer_cc_cv_number,                      CR4023
         p_customer_cc_expmo,
         p_customer_cc_expyr,
         p_customer_cc_number,
         p_customer_email,
         p_customer_firstname,
         p_customer_lastname,
         p_customer_phone,
         0,
         0,
         0,
         SYSDATE,
         v_org_objid,  -- CR3190 Start 12/20/2004
         --PCI
         p_customer_key_enc_number,
         p_customer_cc_enc_number,
         v_out_cert_objid
         --End PCI
      );
      INSERT
      INTO mtm_contact46_x_credit_card3(
         mtm_credit_card2contact,
         mtm_contact2x_credit_card
      )       VALUES(
         v_out_cc_objid,
         p_credit_card2contact
      );
      p_out_cc_objid := TO_CHAR (v_out_cc_objid);
   ELSE
   dbms_output.put_line('cc in system');
      IF (p_customer_email IS NOT NULL) THEN
         UPDATE table_contact SET e_mail = TRIM (p_customer_email)
         WHERE objid = p_credit_card2contact;
      END IF;
      IF (LENGTH (p_customer_phone) = 10)    THEN
         UPDATE table_contact SET phone = p_customer_phone
         WHERE objid = p_credit_card2contact;
      END IF;
      UPDATE table_x_credit_card
         SET x_customer_cc_number =      p_customer_cc_number,
             x_customer_cc_expmo = p_customer_cc_expmo,
             x_customer_cc_expyr = p_customer_cc_expyr,
             x_cc_type = p_cc_type,
      --      x_customer_cc_cv_number = p_customer_cc_cv_number,   CR4023
             x_customer_firstname = p_customer_firstname,
             x_customer_lastname =          p_customer_lastname,
             x_customer_phone = p_customer_phone,
             x_customer_email = p_customer_email,
             x_changedate = SYSDATE,
             x_changedby  = p_changedby,
      --PCI
             x_cust_cc_num_key = p_customer_key_enc_number,
             x_cust_cc_num_enc =  p_customer_cc_enc_number,
             creditcard2cert = v_out_cert_objid
      --End PCI
      WHERE objid = v_cc_objid;
      p_out_cc_objid := v_cc_objid;
--cwl 4/11/13
      if v_out_cc_objid is not null and p_credit_card2contact is not null then
      open mm_curs(v_out_cc_objid,p_credit_card2contact);
        fetch mm_curs into mm_rec;
        if mm_curs%notfound then
        dbms_output.put_line('contact not associated to credit card and bus org');
        dbms_output.put_line('v_out_cc_objid:'||v_out_cc_objid);
        dbms_output.put_line('p_credit_card2contact:'||p_credit_card2contact);
          INSERT INTO mtm_contact46_x_credit_card3(mtm_credit_card2contact,
                                                   mtm_contact2x_credit_card)
                                            VALUES(v_out_cc_objid,
                                                   p_credit_card2contact);
        end if;
      close mm_curs;
      end if;
--cwl 4/11/13
   END IF;
   p_errno := 0;
   p_errstr := 'SUCCESS';
   COMMIT;
   EXCEPTION
   WHEN OTHERS
   THEN
      p_errstr := 'Failure:' || SUBSTR (SQLERRM, 1, 100);
      p_errno := SQLCODE;
      ROLLBACK;
      RETURN;
END EDIT_CREDITCARD_PRC_PCI;
/