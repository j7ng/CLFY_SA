CREATE OR REPLACE PACKAGE sa."BILLING_JOB_PKG"
IS
   PROCEDURE suspend_wait_period_job(
      /*************************************************************************************************/
      /*                                                                                               */
      /* Name         :   suspend_wait_period_job                                                          */
      /*                                                                                               */
      /* Purpose      :   Suspend waite period job                                                     */
      /*                                                                                               */
      /*                                                                                               */
      /* Platforms    :   Oracle 9i                                                                     */
      /*                                                                                               */
      /* Author       :   RSI                                                                               */
      /*                                                                                               */
      /* Date         :   01-19-2006                                                                     */
      /* REVISIONS:                                                                                      */
      /* VERSION  DATE        WHO          PURPOSE                                                       */
      /* -------  ----------     -----           --------------------------------------------                */
      /*  1.0                                Initial  Revision                                            */
      /*                                                                                               */
      /*                                                                                               */
      /*************************************************************************************************/
      op_result OUT NUMBER,
      op_msg OUT VARCHAR2
   );
   PROCEDURE ready_to_re_enroll_job(
      /*************************************************************************************************/
      /*                                                                                               */
      /* Name         :   ready_to_re_enroll_job                                                          */
      /*                                                                                               */
      /* Purpose      :   Ready to re-enroll job                                                         */
      /*                                                                                               */
      /*                                                                                               */
      /* Platforms    :   Oracle 9i                                                                     */
      /*                                                                                               */
      /* Author       :   RSI                                                                               */
      /*                                                                                               */
      /* Date         :   01-19-2006                                                                     */
      /* REVISIONS:                                                                                      */
      /* VERSION  DATE        WHO          PURPOSE                                                       */
      /* -------  ----------     -----           --------------------------------------------                */
      /*  1.0                                Initial  Revision                                            */
      /*                                                                                               */
      /*                                                                                               */
      /*************************************************************************************************/
      op_result OUT NUMBER,
      op_msg OUT VARCHAR2
   );
   PROCEDURE recurring_payment(
      /*************************************************************************************************/
      /*                                                                                               */
      /* Name         :   recurring_payment                                                              */
      /*                                                                                               */
      /* Purpose      :   Recurring payment job                                                        */
      /*                                                                                               */
      /*                                                                                               */
      /* Platforms    :   Oracle 9i                                                                     */
      /*                                                                                               */
      /* Author       :   RSI                                                                               */
      /*                                                                                               */
      /* Date         :   01-19-2006                                                                     */
      /* REVISIONS:                                                                                      */
      /* VERSION  DATE        WHO          PURPOSE                                                       */
      /* -------  ----------     -----           --------------------------------------------                */
      /*  1.0                                Initial  Revision                                            */
      /*                                                                                               */
      /*                                                                                               */
      /*************************************************************************************************/
      p_bus_org IN VARCHAR2
      DEFAULT 'TRACFONE',
      in_priority IN  VARCHAR2 DEFAULT NULL, ---CR25625
      op_result OUT NUMBER,
      op_msg OUT VARCHAR2
   );
   PROCEDURE de_enroll_job(
      /*************************************************************************************************/
      /*                                                                                               */
      /* Name         :   de_enroll_job                                                                  */
      /*                                                                                               */
      /* Purpose      :   De-enroll job                                                                */
      /*                                                                                               */
      /*                                                                                               */
      /* Platforms    :   Oracle 9i                                                                     */
      /*                                                                                               */
      /* Author       :   RSI                                                                               */
      /*                                                                                               */
      /* Date         :   01-19-2006                                                                     */
      /* REVISIONS:                                                                                      */
      /* VERSION  DATE        WHO          PURPOSE                                                       */
      /* -------  ----------     -----           --------------------------------------------                */
      /*  1.0                                Initial  Revision                                            */
      /*                                                                                               */
      /*                                                                                               */
      /*************************************************************************************************/
      op_result OUT NUMBER,
      op_msg OUT VARCHAR2
   );
   PROCEDURE minutes_delivery_job(
      /*************************************************************************************************/
      /*                                                                                               */
      /* Name         :   minutes_delivery_job                                                          */
      /*                                                                                               */
      /* Purpose      :   Minutes delivery job                                                         */
      /*                                                                                               */
      /*                                                                                               */
      /* Platforms    :   Oracle 9i                                                                     */
      /*                                                                                               */
      /* Author       :   RSI                                                                               */
      /*                                                                                               */
      /* Date         :   01-19-2006                                                                     */
      /* REVISIONS:                                                                                      */
      /* VERSION  DATE        WHO          PURPOSE                                                       */
      /* -------  ----------     -----           --------------------------------------------                */
      /*  1.0                                Initial  Revision                                            */
      /*                                                                                               */
      /*                                                                                               */
      /*************************************************************************************************/
      op_result OUT NUMBER,
      op_msg OUT VARCHAR2
   );
   FUNCTION set_new_exp_date(
      /*************************************************************************************************/
      /*                                                                                               */
      /* Name         :   set_new_exp_date                                                              */
      /*                                                                                               */
      /* Purpose      :   Set new expery date                                                             */
      /*                                                                                               */
      /*                                                                                               */
      /* Platforms    :   Oracle 9i                                                                     */
      /*                                                                                               */
      /* Author       :   RSI                                                                               */
      /*                                                                                               */
      /* Date         :   01-19-2006                                                                     */
      /* REVISIONS:                                                                                      */
      /* VERSION  DATE        WHO          PURPOSE                                                       */
      /* -------  ----------     -----           --------------------------------------------                */
      /*  1.0                                Initial  Revision                                            */
      /*                                                                                               */
      /*                                                                                               */
      /*************************************************************************************************/
      p_esn IN VARCHAR2,
      p_enroll_objid IN NUMBER
   )
   RETURN BOOLEAN;
   FUNCTION get_next_cycle_date(
      /*************************************************************************************************/
      /*                                                                                               */
      /* Name         :   get_next_cycle_date                                                              */
      /*                                                                                               */
      /* Purpose      :   Get next cycle date                                                             */
      /*                                                                                               */
      /*                                                                                               */
      /* Platforms    :   Oracle 9i                                                                     */
      /*                                                                                               */
      /* Author       :   RSI                                                                               */
      /*                                                                                               */
      /* Date         :   01-19-2006                                                                     */
      /* REVISIONS:                                                                                      */
      /* VERSION  DATE        WHO          PURPOSE                                                       */
      /* -------  ----------     -----           --------------------------------------------                */
      /*  1.0                                Initial  Revision                                            */
      /*                                                                                               */
      /*                                                                                               */
      /*************************************************************************************************/
      p_prog_param_objid IN NUMBER,
      p_current_cycle_date IN DATE
   )
   RETURN DATE;

   FUNCTION ispaymentprocessingpending(
      /*************************************************************************************************/
      /*                                                                                               */
      /* Name         :   ispaymentprocessingpending                                                     */
      /*                                                                                               */
      /* Purpose      :   Validate payment processing                                                  */
      /*                                                                                               */
      /*                                                                                               */
      /* Platforms    :   Oracle 9i                                                                     */
      /*                                                                                               */
      /* Author       :   RSI                                                                               */
      /*                                                                                               */
      /* Date         :   01-19-2006                                                                     */
      /* REVISIONS:                                                                                      */
      /* VERSION  DATE        WHO          PURPOSE                                                       */
      /* -------  ----------     -----           --------------------------------------------                */
      /*  1.0                                Initial  Revision                                            */
      /*                                                                                               */
      /*                                                                                               */
      /*************************************************************************************************/
      p_objid IN x_program_enrolled.objid%TYPE
   )
   RETURN NUMBER;
   FUNCTION getPaymentType(
      /*************************************************************************************************/
      /*                                                                                               */
      /* Name         :   getPaymentType                                                                  */
      /*                                                                                               */
      /* Purpose      :   Gets the type of payment being attempted ( Recurring, Deactivation, LowBal     */
      /*                                                                                               */
      /*                                                                                               */
      /* Platforms    :   Oracle 9i                                                                     */
      /*                                                                                               */
      /* Author       :   RSI                                                                               */
      /*                                                                                               */
      /* Date         :   01-19-2006                                                                     */
      /* REVISIONS:                                                                                      */
      /* VERSION  DATE        WHO          PURPOSE                                                       */
      /* -------  ----------     -----           --------------------------------------------                */
      /*  1.0                                Initial  Revision                                            */
      /*                                                                                               */
      /*                                                                                               */
      /*************************************************************************************************/
      p_objid IN x_program_parameters.objid%TYPE
   )
   RETURN VARCHAR2;
   PROCEDURE upgrade_job(
      /*************************************************************************************************/
      /*                                                                                               */
      /* Name         :   upgrade_job                                                                      */
      /*                                                                                               */
      /* Purpose      :   upgrade_job                                                                  */
      /*                                                                                               */
      /*                                                                                               */
      /* Platforms    :   Oracle 9i                                                                     */
      /*                                                                                               */
      /* Author       :   RSI                                                                               */
      /*                                                                                               */
      /* Date         :   01-19-2006                                                                     */
      /* REVISIONS:                                                                                      */
      /* VERSION  DATE        WHO          PURPOSE                                                       */
      /* -------  ----------     -----           --------------------------------------------                */
      /*  1.0                                Initial  Revision                                            */
      /*                                                                                               */
      /*                                                                                               */
      /*************************************************************************************************/
      op_result OUT NUMBER,
      op_msg OUT VARCHAR2
   );
   PROCEDURE processZeroDollarProgram(
      /*************************************************************************************************/
      /*                                                                                               */
      /* Name         :   processZeroDollarProgram                                                      */
      /*                                                                                               */
      /* Purpose      :   This procedure short-circuits data submission to payment systems when the    */
      /*                    program is 0$ in cost                                                      */
      /*                                                                                               */
      /*                                                                                               */
      /* Platforms    :   Oracle 9i                                                                     */
      /*                                                                                               */
      /* Author       :   RSI                                                                               */
      /*                                                                                               */
      /* Date         :   01-19-2006                                                                     */
      /* REVISIONS:                                                                                      */
      /* VERSION  DATE        WHO          PURPOSE                                                       */
      /* -------  ----------     -----           --------------------------------------------                */
      /*  1.0     08-Aug-06   RSI            Initial  Revision                                            */
      /*                                                                                               */
      /*                                                                                               */
      /*************************************************************************************************/
      p_objid IN NUMBER
   );

   FUNCTION is_SB_esn(
      p_enrol_pgm_objid IN NUMBER,
      p_esn IN VARCHAR2
   )
   /*************************************************************************************************/
   /*                                                                                               */
   /* Name         :   is_SB_esn                                                                      */
   /*                                                                                               */
   /* Purpose      :   To find if esn is enrolled in SB */
   /*                                                                                               */
   /*                                                                                               */
   /* Platforms    :   Oracle 9i                                                                     */
   /*                                                                                               */
   /* Author       :   TF IT DEV                                                                               */
   /*                                                                                               */
   /* Date         :   05-22-2009                                                                     */
   /* REVISIONS:                                                                                      */
   /* VERSION  DATE        WHO          PURPOSE                                                       */
   /* -------  ----------     -----           --------------------------------------------                */
   /*  1.0                                Initial  Revision                                            */
   /*                                                                                               */
   /*                                                                                               */
   /*************************************************************************************************/
   RETURN NUMBER;


  /* CR29489 changes starts ; new procedure created to break relationship between real-esn and pseudo esn  */
  procedure p_brk_esn_relations_hppbyop (ip_rundate in date);
  /* CR29489 changes ends */

END billing_job_pkg;
/