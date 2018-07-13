CREATE OR REPLACE PROCEDURE sa."POST_ACTIVATION_ENROLLMENT" (
   /*************************************************************************************************/
   /*                                                                                          	 */
   /* Name         :   post_activation_enrollment                      								 */
   /*                                                                                          	 */
   /* Purpose      :   									 */
   /*                                                                                          	 */
   /*                                                                                          	 */
   /* Platforms    :   Oracle 9i                                                    				 */
   /*                                                                                          	 */
   /* Author       :                                                               	  			 */
   /*                                                                                          	 */
   /* REVISIONS:                                                         							 */
   /* VERSION  DATE        WHO          PURPOSE                                  					 */
   /* -------  ---------- 	-----  		 --------------------------------------------   			 */
   /*  1.0       07/10/09     CLindner/RVurimi                		 Initial  Revision                               			 */
   /* 1.1        08/03/09      Andres/Vani                              Modified to check for the right status/date
   /*************************************************************************************************/
   op_result OUT VARCHAR2, -- Output Result
   op_msg OUT VARCHAR2 -- Output Message
)
IS
P_ESN varchar2(50);
-----------------------------------------------------------------------------------------------
   -- Cursor Declarations
   -- Cursor # 1
   -- Fetch all Enrollment Pending Cases that are created in last 24 hours
   -----------------------------------------------------------------------------------------------
  /* CURSOR enroll_pending_cases_cur
   IS
   SELECT /*+ ORDERED */
   /*   a.x_esn,
      a.s_title,
      a.objid,
      a.x_case_type,
      b.x_value,
      sp.objid sp_objid,
      sp.x_service_id,
      purch.objid purch_objid,
      purch.x_status,
      enroll.x_enrollment_status,
      enroll.objid enroll_objid
   FROM sa.table_case a, sa.table_x_case_detail b, sa.table_site_part sp, sa.x_program_enrolled
   enroll, sa.x_program_purch_dtl dtl, sa.x_program_purch_hdr purch
   WHERE 1 = 1
   AND purch.x_ics_rcode || '' = '1'
   AND purch.x_payment_type||'' = 'ENROLLMENT'
   AND purch.objid = dtl.pgm_purch_dtl2prog_hdr
   AND dtl.pgm_purch_dtl2pgm_enrolled = enroll.objid
   --AND enroll.x_enrollment_status||'' = 'ACTIVATION_PENDING'  --1.1
   AND enroll.x_enrollment_status||'' = 'ENROLLMENTPENDING' --1.1
   AND enroll.x_esn = a.x_esn
   AND sp.x_service_id = a.x_esn
   AND sp.part_status || '' = 'Active'
   AND b.x_name = 'VALUE_PLAN'
   AND b.detail2case = a.objid
   AND a.creation_time >= TRUNC (SYSDATE) - 30
   AND a.s_title||'' = 'ENROLLMENT PENDING'
   AND a.x_case_type||'' = 'Value Plan';*/--CPannala
-----------------------------------------------------------------------------------------------
-- End of Cursors
-----------------------------------------------------------------------------------------------
BEGIN

   -- DBMS_OUTPUT.PUT_LINE('BEGINNING...');
 /* FOR rec1 IN enroll_pending_cases_cur
   LOOP

      -- 1. Update the Site Part OBJID and Enrollment Status on x_program_enrolled
      UPDATE sa.x_program_enrolled SET x_enrollment_status = 'ENROLLED',
      pgm_enroll2site_part = rec1.sp_objid, x_next_charge_date = TRUNC(SYSDATE)
      + 30 --1.1
      WHERE objid = rec1.enroll_objid;
      -- 2. Update the Site Part OBJID on x_program_trans
      UPDATE sa.x_program_trans SET pgm_trans2site_part = rec1.sp_objid
      WHERE pgm_tran2pgm_entrolled = rec1.enroll_objid;
      -- 3. Update the Purchase date to SYSDATE on x_program_purch_hdr
      -- This is needed since BI is pulling the enrollment details based on this date
      UPDATE sa.x_program_purch_hdr SET x_rqst_date = SYSDATE
      WHERE objid = rec1.purch_objid;
      COMMIT;
   END LOOP;
   op_result := '0';
   op_msg := 'Success';
   EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Error ' || TO_CHAR (SQLCODE) || ': ' || SQLERRM);
      op_result := SQLCODE;
      op_msg := SQLERRM;*/ --CPannala

   sa.ENROLLMENT_PKG.POST_ACTIVATION_ENROLLMENT(
				    OP_RESULT => OP_RESULT,
				    OP_MSG => OP_MSG,
				    P_ESN => P_ESN
				  );

END post_activation_enrollment;
/