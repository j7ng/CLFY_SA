CREATE OR REPLACE PACKAGE sa."CREATE_CASE_CLARIFY_PKG" AS
/*****************************************************************
  * Package Name: CREATE_CASE_CLARIFY_PKG
  * Purpose     : To create, dispatch and close a case
  *
  * Platform    : Oracle 8.0.6 and newer versions.
  * Created by  : Natalio Guada
  * Date        : 11/03/2005
  *
  * History
  * REVISIONS    VERSION  DATE          WHO            PURPOSE
  * -------------------------------------------------------------
  *              1.0      11/03/2005   NGuada      Initial Revision (CR4513)
  *              1.1      11/03/2005   VAdapa      Added header information
  *              1.2      11/04/2005   VAdapa      Removed the extra '/''
  *              1.3      11/10/05     VAdapa      Added extra input parameter (stock type)
  *              1.4      05/27/06     Nguada      Added extra input parameter (reason)
  *              1.5      05/27/06     Nguada      Added extra input parameter (problem_source)
  *              1.6      08/08/06     VAdapa      CR5391A - Added 3 new parameters to SP_CREATE_CASE procedure
  *                                       and a new procedure has been added sp_create_case_phone_log
  *                                    (copy of sp_create_case) for overloading purposes
  *              1.7      0817/06     VAdapa      Label Change from CR5391A to CR5523
  ************************************************************************/
--
   PROCEDURE sp_create_case (
      p_esn                 IN       VARCHAR2,
      p_contact_objid       IN       NUMBER,
      p_queue_name          IN       VARCHAR2,                  -- Queue Name
      p_type                IN       VARCHAR2,
      p_title               IN       VARCHAR2,
      p_history             IN       VARCHAR2,
      p_status              IN       VARCHAR2,
      -- Starting Status of the Case: Pending, BadAddress
      p_repl_part           IN       VARCHAR2,
      p_replacement_units   IN       NUMBER,
      p_case2task           IN       NUMBER,
      p_case_type_lvl2      IN       VARCHAR2,   -- Company (Tracfone, Net10)
      p_issue               IN       VARCHAR2,
      p_inbound             IN       VARCHAR2,
      p_outbound            IN       VARCHAR2,
      p_signal              IN       VARCHAR2,
      p_scan                IN       VARCHAR2,
      p_promo_code          IN       VARCHAR2,
      p_master_sid          IN       VARCHAR2,
      p_prl_soc             IN       VARCHAR2,
      p_time_tank           IN       VARCHAR2,
      p_tt_units            IN       NUMBER,
      p_fraud_id            IN       VARCHAR2,
      p_wrong_esn           IN       VARCHAR2,
      p_ttest_seq           IN       NUMBER,
      p_sys_seq             IN       NUMBER,
      p_channel             IN       VARCHAR2,
      -- Equivalent To Source System (IVR,WEBCSR,ETC)
      p_phone_due_date      IN       DATE,
      p_sys_phone_date      IN       DATE,
      p_super_login         IN       VARCHAR2,
      p_cust_units_claim    IN       NUMBER,
      p_fraud_units         IN       NUMBER,
      p_vm_password         IN       VARCHAR2,
      p_courier             IN       VARCHAR2,
      p_stock_type          IN       VARCHAR2,                          --1.3
      p_reason              IN       VARCHAR2,                          --1.4
      p_problem_source      IN       VARCHAR2,                          --1.5
      p_case_id             OUT      VARCHAR2
   );
--
   PROCEDURE sp_create_case_phone_log (
      p_esn                 IN       VARCHAR2,
      p_contact_objid       IN       NUMBER,
      p_queue_name          IN       VARCHAR2,                  -- Queue Name
      p_type                IN       VARCHAR2,
      p_title               IN       VARCHAR2,
      p_history             IN       VARCHAR2,
      p_status              IN       VARCHAR2,
      -- Starting Status of the Case: Pending, BadAddress
      p_repl_part           IN       VARCHAR2,
      p_replacement_units   IN       NUMBER,
      p_case2task           IN       NUMBER,
      p_case_type_lvl2      IN       VARCHAR2,   -- Company (Tracfone, Net10)
      p_issue               IN       VARCHAR2,
      p_inbound             IN       VARCHAR2,
      p_outbound            IN       VARCHAR2,
      p_signal              IN       VARCHAR2,
      p_scan                IN       VARCHAR2,
      p_promo_code          IN       VARCHAR2,
      p_master_sid          IN       VARCHAR2,
      p_prl_soc             IN       VARCHAR2,
      p_time_tank           IN       VARCHAR2,
      p_tt_units            IN       NUMBER,
      p_fraud_id            IN       VARCHAR2,
      p_wrong_esn           IN       VARCHAR2,
      p_ttest_seq           IN       NUMBER,
      p_sys_seq             IN       NUMBER,
      p_channel             IN       VARCHAR2,
      -- Equivalent To Source System (IVR,WEBCSR,ETC)
      p_phone_due_date      IN       DATE,
      p_sys_phone_date      IN       DATE,
      p_super_login         IN       VARCHAR2,
      p_cust_units_claim    IN       NUMBER,
      p_fraud_units         IN       NUMBER,
      p_vm_password         IN       VARCHAR2,
      p_courier             IN       VARCHAR2,
      p_stock_type          IN       VARCHAR2,                          --1.3
      p_reason              IN       VARCHAR2,                          --1.4
      p_problem_source      IN       VARCHAR2,                          --1.5
      p_resultdesc          IN       VARCHAR2,                       --CR5523
      p_sim                 IN       VARCHAR2,                       --CR5523
      p_notes               IN       VARCHAR2,                       --CR5523
      p_case_id             OUT      VARCHAR2
   );
--
   PROCEDURE sp_dispatch_case (
      p_case_objid   IN       NUMBER,
      p_queue_name   IN       VARCHAR2,
      p_dummy_out    OUT      NUMBER
   );
--
   PROCEDURE sp_close_case (
      p_case_id                 VARCHAR2,
      p_user_login_name         VARCHAR2,
      p_source                  VARCHAR2,
      p_resolution_code         VARCHAR2,
      p_status            OUT   VARCHAR2,
      p_msg               OUT   VARCHAR2
   );
--
END create_case_clarify_pkg;
/