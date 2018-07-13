CREATE OR REPLACE PROCEDURE sa."EDIT_CREDITCARD_PRC" (
   p_cc_objid IN VARCHAR2,
   p_customer_cc_number IN VARCHAR2,
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
   p_out_cc_objid OUT VARCHAR2,
   p_errno OUT VARCHAR2,
   p_errstr OUT VARCHAR2
)
AS
/*********************************************************************************************/
   /*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved               	       */
   /*                                                                               	       */
   /* NAME     :      EDIT_CREDITCARD_PRC  		                                               */
   /* PURPOSE  :   This procedure is called from the method ChangeCreditCard		             */
   /*      	of TFCreditCard Java. CBO logic rewritten in PL/SQL for    		                   */
   /*		Stabilization project   	  					                                               */
   /* FREQUENCY:                                                                    	       */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                	       */
   /*                                                                                        */
   /* REVISIONS:                                                                    	       */
   /* VERSION  DATE        WHO              PURPOSE                                          */
   /* -------  ---------- -----  		 ---------------------------------------------           */
   /*  1.0     11/25/03   Suganthi Uthaman  Initial  Revision 			                         */
   /*  1.1     12/20/00   Ashutosh Tripathi  Added for CR3190 			                         */
   /*  1.2     26/05/05   Mchinta            Added for CR4023                  			         */
   /*  1.2     06/13/06   ICanavan			 CR5297 - No changes, Just added the new version label
   /******************************************************************************************/
   v_cc_objid NUMBER;
   v_out_cc_objid NUMBER;
   v_org_objid NUMBER;
BEGIN
   p_out_cc_objid := '';
   p_errno := '100';
   p_errstr := 'FAILED';
   v_cc_objid := TO_NUMBER(p_cc_objid);
   IF( v_cc_objid IS NULL)
   THEN
      IF (p_customer_email IS NOT NULL)
      THEN
         UPDATE table_contact SET e_mail = TRIM(p_customer_email)
         WHERE objid = p_credit_card2contact;
      END IF;
      IF ( LENGTH(p_customer_phone) = 10)
      THEN
         UPDATE table_contact SET phone = p_customer_phone
         WHERE objid = p_credit_card2contact;
      END IF;
      SELECT seq('x_credit_card')
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
         x_credit_card2bus_org
      ) VALUES(
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
         v_org_objid -- CR3190 Start 12/20/2004
      );
      INSERT
      INTO mtm_contact46_x_credit_card3(
         MTM_credit_card2contact,
         MTM_contact2x_credit_card
      ) VALUES(
         v_out_cc_objid,
         p_credit_card2contact
      );
      p_out_cc_objid := TO_CHAR(v_out_cc_objid);
   ELSE
      IF (p_customer_email IS NOT NULL)
      THEN
         UPDATE table_contact SET e_mail = TRIM(p_customer_email)
         WHERE objid = p_credit_card2contact;
      END IF;
      IF ( LENGTH(p_customer_phone) = 10)
      THEN
         UPDATE table_contact SET phone = p_customer_phone
         WHERE objid = p_credit_card2contact;
      END IF;
      UPDATE table_x_credit_card SET x_customer_cc_number =
      p_customer_cc_number, x_customer_cc_expmo = p_customer_cc_expmo,
      x_customer_cc_expyr = p_customer_cc_expyr, x_cc_type = p_cc_type,
--      x_customer_cc_cv_number = p_customer_cc_cv_number,   CR4023
       x_customer_firstname = p_customer_firstname, x_customer_lastname = p_customer_lastname,
      x_customer_phone = p_customer_phone, x_customer_email = p_customer_email,
      x_changedate = SYSDATE, x_changedby = p_changedby
      WHERE objid = v_cc_objid ;
      p_out_cc_objid := p_cc_objid;
   END IF ;
   p_errno := 0;
   p_errstr := 'SUCCESS';
   COMMIT;
   EXCEPTION
   WHEN OTHERS
   THEN
      p_errstr := 'Failure:'||SUBSTR(SQLERRM, 1, 100);
      p_errno := SQLCODE;
      ROLLBACK;
      RETURN;
END EDIT_CREDITCARD_PRC;
/