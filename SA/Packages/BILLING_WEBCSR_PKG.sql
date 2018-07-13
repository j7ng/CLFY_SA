CREATE OR REPLACE PACKAGE sa."BILLING_WEBCSR_PKG"
AS
   PROCEDURE transfer_esn_to_diff_act (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   transfer_esn_to_diff_act                                      */
/*                                                                                            */
/* Purpose      :   Transfer ESN to different account                                */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*  1.1                                                                                          */
/*  1.2/1.3            Ramu           CR7326                                                  */
/*************************************************************************************************/
      p_esn           IN       x_program_enrolled.x_esn%TYPE,
      p_web_s_objid   IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_web_t_objid   IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_user          IN       VARCHAR2,
      op_result       OUT      NUMBER,
      op_msg          OUT      VARCHAR2
   );

   PROCEDURE move_cycle_date (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   move_cycle_date                                               */
/*                                                                                            */
/* Purpose      :   Move or shift billing cycle date                                 */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_enrolled_objid   IN       x_program_enrolled.objid%TYPE,
      p_cycle_days       IN       NUMBER,
      p_user             IN       VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE extent_grace_period (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   extent_grace_period                                              */
/*                                                                                            */
/* Purpose      :   Extent grace period                                              */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_enrolled_objid   IN       x_program_enrolled.objid%TYPE,
      p_grace_days       IN       NUMBER,
      p_user             IN       VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE has_grace_period_changed (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   has_grace_period_changed                                      */
/*                                                                                            */
/* Purpose      :   Validate grace period change                                     */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_web_user_objid   IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE remove_cooling_period (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   remove_cooling_period                                            */
/*                                                                                            */
/* Purpose      :   Remove cooling period                                         */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_enrolled_objid   IN       x_program_enrolled.objid%TYPE,
      p_user             IN       VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE transfer_esn_diff_act_online (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   transfer_esn_diff_act_online                                     */
/*                                                                                            */
/* Purpose      :   Transfer ESN to different account online                            */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_web_s_objid      IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_web_t_objid      IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_enroll_s_objid   IN       x_program_enrolled.objid%TYPE,
      p_grace_period     IN       NUMBER,
      p_user             IN       VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE transfer_esn_out (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   transfer_esn_out                                              */
/*                                                                                            */
/* Purpose      :   Transfer ESN out                                              */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_web_s_objid      IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_web_t_objid      IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_enroll_s_objid   IN       x_program_enrolled.objid%TYPE,
      p_grace_period     IN       NUMBER,
      p_user             IN       VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE transfer_esn_in (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   transfer_esn_in                                               */
/*                                                                                            */
/* Purpose      :   Transfer ESN in                                               */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_web_s_objid      IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_web_t_objid      IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_enroll_s_objid   IN       x_program_enrolled.objid%TYPE,
      p_user             IN       VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE transfer_esn_same_acc (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   transfer_esn_same_acc                                         */
/*                                                                                            */
/* Purpose      :   Transfer ESN to same account                                     */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_enroll_s_objid   IN       x_program_enrolled.objid%TYPE,
      p_enroll_t_objid   IN       x_program_enrolled.objid%TYPE,
      p_user             IN       VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE penalty_remove (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   penalty_remove                                                */
/*                                                                                            */
/* Purpose      :   Remove penalty                                                */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_penality_objid   IN       NUMBER,
      p_user             IN       VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE transfer_out_esn_pgms (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   transfer_out_esn_pgms                                         */
/*                                                                                            */
/* Purpose      :   Transfer ESN out for Program                                     */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_web_s_objid      IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_esn              IN       x_program_enrolled.x_esn%TYPE,
      p_enroll_s_objid   IN       x_program_enrolled.objid%TYPE,
      --List of enrolled programs that need to be transferred.
      p_grace_period     IN       NUMBER,
      p_user             IN       VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE transfer_prog_to_diff_act (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   transfer_prog_to_diff_act                                        */
/*                                                                                            */
/* Purpose      :   Transfer Program to different account                               */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_enroll_objid   IN       x_program_enrolled.objid%TYPE,
      p_web_s_objid    IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_web_t_objid    IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_user           IN       VARCHAR2,
      op_result        OUT      NUMBER,
      op_msg           OUT      VARCHAR2
   );

   /* Transfers a list of enrollments to a new ESN */
   PROCEDURE transfer_progs_to_diff_esn (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   transfer_progs_to_diff_esn                                       */
/*                                                                                            */
/* Purpose      :   Transfer Programs to different ESN                                  */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_enroll_s_objid   IN       VARCHAR2,
      -- ',' separated list of objids for transfer
      p_esn              IN       x_program_enrolled.x_esn%TYPE,
      -- ESN to which to transfer to.
      p_user             IN       VARCHAR2,
      -- WEBCSR User Initiating the transfer
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   /* -- Procedure to transfer out esn from the account. Transfer receipient not known */
   PROCEDURE transfer_out_esn (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   transfer_out_esn                                              */
/*                                                                                            */
/* Purpose      :   Transfer out ESN                                              */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_web_user_objid   IN       NUMBER,
      p_esn              IN       x_program_enrolled.x_esn%TYPE,
      p_wait_period      IN       NUMBER,
      -- By Default, we will wait indefinitely, till the new user transfers in.
      p_user             IN       VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE transfer_prog_to_diff_esn (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   transfer_prog_to_diff_esn                                              */
/*                                                                                            */
/* Purpose      :   Transfer Program to different ESN                                   */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_enroll_s_objid   IN       x_program_enrolled.objid%TYPE,
      -- Enrollment that needs transferring.
      p_esn              IN       x_program_enrolled.x_esn%TYPE,
      -- ESN to which to transfer to.
      p_user             IN       VARCHAR2,
      -- WEBCSR User Initiating the transfer
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

/*************************************************************************************************/
/*                                                                                            */
/* Name         :   validate_funding_source                                             */
/*                                                                                            */
/* Purpose      :   To validate the funding source compatibility for the programs to be          */
/*                    transferred.                                                      */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
   PROCEDURE validate_funding_source (
      p_web_user_objid    IN       NUMBER,
      -- WebUser ID to whom the programs will be transferred
      p_enroll_list       IN       VARCHAR2,   -- List of current enrollments
      op_result           OUT      NUMBER,
      op_msg              OUT      VARCHAR2,
      op_permitted_list   OUT      VARCHAR2
   -- Permitted valid funding sources, in case of failure.
   );

/*************************************************************************************************/
/*                                                                                            */
/* Name         :   transfer_esn_prog_to_diff_esn                                             */
/*                                                                                            */
/* Purpose      :   To transfer all the programs associated with one ESN                         */
/*                  to another ESN within the same account. This is typically used for Upgrade   */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
  PROCEDURE transfer_esn_prog_to_diff_esn
  (
    p_web_objid IN table_web_user.objid%TYPE
   , -- WebUser ObjID
    p_s_esn     IN x_program_enrolled.x_esn%TYPE
   ,
    -- ESN from which programs need to be transferred.
    p_t_esn IN x_program_enrolled.x_esn%TYPE
   ,
    -- ESN to which the programs need to be transferred to.
    p_user    IN VARCHAR2
   , -- WEBCSR user initiating the transfer
    p_pe_objid           OUT x_program_enrolled.objid%TYPE
   ,
    p_from_pgm_objid     OUT x_program_parameters.objid%TYPE
   ,
    op_result OUT NUMBER
   ,OP_MSG    OUT varchar2
   , in_hpp_transfer_flg  IN  varchar2 default null   /* CR22313 HPP PHASE-2 22-Aug-2014 ; warranty transfer allowed in certain cases  */
  );

/*************************************************************************************************/
/*                                                                                            */
/* Name         :   transfer_in_esn                                                           */
/*                                                                                            */
/* Purpose      :   Transfer in programs when the ESN is added into MyAccount                    */
/*                                                                                               */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   03-22-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
   PROCEDURE transfer_in_esn (
      p_web_user_objid   IN       NUMBER,
      p_esn              IN       x_program_enrolled.x_esn%TYPE,
      p_user             IN       VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   FUNCTION validate_upgrade_account (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   validate_upgrade_account                                                        */
/*                                                                                            */
/* Purpose      :   Used for validation of the account to ensure old and new ESNs belong to same
                    account                                                                      */
/*                                                                                               */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   03-22-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_s_esn                  VARCHAR2,
      p_t_esn                  VARCHAR2,
      bcreatemyaccount         NUMBER := 0,
      p_web_objid        OUT   NUMBER
   )
      RETURN NUMBER;

   PROCEDURE remove_enrollment_pending (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   remove_enrollment_pending                                                       */
/*                                                                                            */
/* Purpose      :   Used to remove the pending for enrollments                                   */
/*                                                                                               */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   03-22-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
      p_enrolled_objid   IN       x_program_enrolled.objid%TYPE,
      p_user             IN       VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

--ST_BUNDLE1
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   transfer_esn_prog_to_diff_prog                                             */
/*                                                                                            */
/* Purpose      :   To transfer all the ESN programs to a differentprogram  */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   TF                                                                       */
/*                                                                                            */
/* Date         :   09-10-2009                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
   PROCEDURE transfer_esn_prog_to_diff_prog (
      p_s_enrlobjid   IN       x_program_enrolled.objid%TYPE,
      -- source enrolled record
      p_t_pgmobjid    IN       x_program_parameters.objid%TYPE,
      -- target program
      p_user          IN       VARCHAR2,
      -- WEBCSR user initiating the transfer
      op_result       OUT      NUMBER,
      op_msg          OUT      VARCHAR2
   );
--ST_BUNDLE1
END billing_webcsr_pkg;
/