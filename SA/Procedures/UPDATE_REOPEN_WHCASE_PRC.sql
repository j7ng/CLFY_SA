CREATE OR REPLACE PROCEDURE sa."UPDATE_REOPEN_WHCASE_PRC" (
   strcaseid      IN       VARCHAR2,
   struserobjid   IN       VARCHAR2,
   p_error_no     OUT      VARCHAR2,
   p_error_str    OUT      VARCHAR2
)
AS
/********************************************************************************************/
   /*    Copyright   2004 Tracfone  Wireless Inc. All rights reserved                          */
   /* NAME     :       UPDATE_REOPEN_WH_CASE_PRC                                               */
   /* PURPOSE  :       This procedure is called from clarify to update all the warehouse cases */
   /*                  which have been returned back to warehouse due to bad address.          */
   /* FREQUENCY:                                                                               */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                           */
   /*                                                                                          */
   /* REVISIONS:                                                                               */
   /* VERSION  DATE        WHO                 PURPOSE                                         */
   /* -------  ---------- -----                ---------------------------------------------   */
   /*  1.0     09/07/04   Muralidhar Chinta    Initial  Revision                               */
   /*  1.1      10/19/04   Mohanarao PVN        CR3203 Will also be dispatched to"Bad Address"  */
   /*                                          Queue                                           */
   /*  1.2 / 1.3        ----------             Match the production version                    */
   /*  1.4     04/04/05   Ritu Gandhi          CR3373 - Case Mod on Web                        */
   /*                                          Assign a resolution to the case when  it is closed*/
   /*  1.5                                     Removed the "ampersand" symbol from the comments*/
   /*  1.6 *1.7  08/11/05   Nataluio Guada       CR4389 - bug on update x_replacement ESN      */
   /*  1.8     01/25/06   Fernando Lasa        CR4881 - Remove CLOSED condition check          */
   /*  1.9     02/01/06    VAdapa            Correct CR# in the comments                     */
   /*                                        CR4878 changes                                  */
   /*  1.10    05/01/06    Nguada              CR5174                                          */
   /*  1.11/1.12    09/13/06    Icanavan            CR5041 Added commit statement after create case */
   /*  1.13    09/20/06    NGUADA              REfactoring CSR Improvements   CR5569                 */
   /*  1.14    10/31/06    Gpintado          CR5569 - Corrected if p_error condition           */
   /********************************************************************************************/

   --Get case objid from case_id
   CURSOR whcase_c
   IS
      SELECT objid
        FROM table_case wc
       WHERE id_number = strcaseid;

   rec_whcase_c   whcase_c%ROWTYPE;
BEGIN
   p_error_no := '0';
   p_error_str := '';

   OPEN whcase_c;

   FETCH whcase_c
    INTO rec_whcase_c;

   IF whcase_c%FOUND
   THEN
      clarify_case_pkg.reopen_case (rec_whcase_c.objid,
                                    struserobjid,
                                    p_error_no,
                                    p_error_str
                                   );

      IF p_error_no = '0'
      THEN
         clarify_case_pkg.update_status (rec_whcase_c.objid,
                                         struserobjid,
                                         'BadAddress',
                                         '',
                                         p_error_no,
                                         p_error_str
                                        );
      END IF;
   ELSE
      p_error_no := '1';
      p_error_str := 'Case not found';
   END IF;
END update_reopen_whcase_prc;
/