CREATE OR REPLACE PACKAGE sa."BILLING_LIFELINE_ACTION_PKG"
IS
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   BILLING_LIFELINE_ACTION_PKG.VALIDATE_ACTION                               */
/*                                                                                            */
/* Purpose      :   To validate the action type                                      */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 10g                                                                */
/*                                                                                            */
/* Author       :   Ramu                                                                      */
/*                                                                                            */
/* Date         :   06-25-2008                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0     06-25-2008  Ramu         Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
   FUNCTION validate_action (p_action_type IN VARCHAR2)
      RETURN NUMBER;

/*************************************************************************************************/
/*                                                                                            */
/* Name         :   BILLING_LIFELINE_ACTION_PKG.PROCESS_PENDING_ACTIONS                          */
/*                                                                                               */
/* Purpose      :   To process all the pending actions                                  */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 10g                                                                */
/*                                                                                            */
/* Author       :   Ramu                                                                      */
/*                                                                                            */
/* Date         :   06-25-2008                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0     06-25-2008  Ramu         Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
   PROCEDURE process_pending_actions (
      op_result   OUT   VARCHAR2,                            -- Output Result
      op_msg      OUT   VARCHAR2                            -- Output Message
   );

/*************************************************************************************************/
/*                                                                                            */
/* Name         :   BILLING_LIFELINE_ACTION_PKG.PROCESS_LIFELINE_ENROLLMENT                      */
/*                                                                                               */
/* Purpose      :   To process all the pending Enrollments                              */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 10g                                                                */
/*                                                                                            */
/* Author       :   Ramu                                                                      */
/*                                                                                            */
/* Date         :   06-25-2008                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0     06-25-2008  Ramu         Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
   PROCEDURE process_lifeline_enrollment (
      lifeline_action_objid   IN       NUMBER,
      re_enroll_flag          IN       NUMBER,
      op_result               OUT      VARCHAR2,             -- Output Result
      op_msg                  OUT      VARCHAR2             -- Output Message
   );

/*************************************************************************************************/
/*                                                                                            */
/* Name         :   BILLING_LIFELINE_ACTION_PKG.PROCESS_LIFELINE_DEENROLLMENT                    */
/*                                                                                               */
/* Purpose      :   To process all the pending DeEnrollments                            */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 10g                                                                */
/*                                                                                            */
/* Author       :   Ramu                                                                      */
/*                                                                                            */
/* Date         :   06-25-2008                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0     06-25-2008  Ramu         Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
   PROCEDURE process_lifeline_deenrollment (
      lifeline_action_objid   IN       NUMBER,
      op_result               OUT      VARCHAR2,             -- Output Result
      op_msg                  OUT      VARCHAR2             -- Output Message
   );

/*************************************************************************************************/
/*                                                                                            */
/* Name         :   BILLING_LIFELINE_ACTION_PKG.PROCESS_LIFELINE_DEREGISTER                      */
/*                                                                                               */
/* Purpose      :   To process all the pending DeRegistrations                          */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 10g                                                                */
/*                                                                                            */
/* Author       :   Ramu                                                                      */
/*                                                                                            */
/* Date         :   06-25-2008                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0     06-25-2008  Ramu         Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
   PROCEDURE process_lifeline_deregister (
      lifeline_action_objid   IN       NUMBER,
      op_result               OUT      VARCHAR2,             -- Output Result
      op_msg                  OUT      VARCHAR2             -- Output Message
   );

/*************************************************************************************************/
/*                                                                                            */
/* Name         :   BILLING_LIFELINE_ACTION_PKG.PROCESS_LIFELINE_REMOVE_ESN                      */
/*                                                                                               */
/* Purpose      :   To process all the pending Remove ESNs                              */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 10g                                                                */
/*                                                                                            */
/* Author       :   Ramu                                                                      */
/*                                                                                            */
/* Date         :   06-25-2008                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0     06-25-2008  Ramu         Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
   PROCEDURE process_lifeline_remove_esn (
      lifeline_action_objid   IN       NUMBER,
      op_result               OUT      VARCHAR2,             -- Output Result
      op_msg                  OUT      VARCHAR2             -- Output Message
   );

/*************************************************************************************************/
/*                                                                                            */
/* Name         :   BILLING_LIFELINE_ACTION_PKG.PROCESS_LIFELINE_UPGRADE                         */
/*                                                                                               */
/* Purpose      :   To process all the pending upgrades                                 */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 10g                                                                */
/*                                                                                            */
/* Author       :   Ramu                                                                      */
/*                                                                                            */
/* Date         :   06-25-2008                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0     06-25-2008  Ramu         Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
   PROCEDURE process_lifeline_upgrade (
      lifeline_action_objid   IN       NUMBER,
      op_result               OUT      VARCHAR2,             -- Output Result
      op_msg                  OUT      VARCHAR2             -- Output Message
   );

/*************************************************************************************************/
/*                                                                                            */
/* Name         :   BILLING_LIFELINE_ACTION_PKG.PROCESS_LIFELINE_DEACTIVATION                    */
/*                                                                                               */
/* Purpose      :   To process all the pending deactivations                            */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 10g                                                                */
/*                                                                                            */
/* Author       :   Ramu                                                                      */
/*                                                                                            */
/* Date         :   06-25-2008                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0     06-25-2008  Ramu         Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
   PROCEDURE process_lifeline_deactivation (
      lifeline_action_objid   IN       NUMBER,
      op_result               OUT      VARCHAR2,             -- Output Result
      op_msg                  OUT      VARCHAR2             -- Output Message
   );

/*************************************************************************************************/
/*                                                                                            */
/* Name         :   BILLING_LIFELINE_ACTION_PKG.PROCESS_LIFELINE_RETURNS                         */
/*                                                                                               */
/* Purpose      :   To process all the pending Returns                                  */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 10g                                                                */
/*                                                                                            */
/* Author       :   Ramu                                                                      */
/*                                                                                            */
/* Date         :   06-25-2008                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0     06-25-2008  Ramu         Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
   PROCEDURE process_lifeline_returns (
      lifeline_action_objid   IN       NUMBER,
      op_result               OUT      VARCHAR2,             -- Output Result
      op_msg                  OUT      VARCHAR2             -- Output Message
   );
END billing_lifeline_action_pkg;
                          -- Package Specification BILLING_LIFELINE_ACTION_PKG
/