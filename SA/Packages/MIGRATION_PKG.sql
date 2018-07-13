CREATE OR REPLACE PACKAGE sa.migration_pkg AS
------------------------------------------------------------------------
--$RCSfile: migration_pkg.sql,v $
--$Revision: 1.38 $
--$Author: vnainar $
--$Date: 2017/04/12 21:16:17 $
--$ $Log: migration_pkg.sql,v $
--$ Revision 1.38  2017/04/12 21:16:17  vnainar
--$ CR49087 Interaction procedure added for bill extract
--$
--$ Revision 1.37  2017/04/07 18:49:54  smeganathan
--$ Added divisor and remainder for load_wfm_interaction
--$
--$ Revision 1.36  2017/04/06 22:23:35  vnainar
--$ CR47564 remainder and divisor added in load_wfm_premigration
--$
--$ Revision 1.35  2017/03/31 23:23:32  vnainar
--$ CR47564 added web contact changes
--$
--$ Revision 1.34  2017/03/30 21:18:27  vnainar
--$ CR47564d sim status parameter updated to 180
--$
--$ Revision 1.33  2017/03/30 16:27:10  vnainar
--$ CR47564 igtb_wfm_async_type moved to wfmmig schema
--$
--$ Revision 1.32  2017/03/22 22:28:32  nsurapaneni
--$ Added load_wfm_interaction
--$
--$ Revision 1.31  2017/03/20 19:07:11  smeganathan
--$ added procedures to load payment source details
--$
--$ Revision 1.30  2017/03/14 22:44:19  vnainar
--$ CR47564 process_wfm_async enhancements added
--$
--$ Revision 1.29  2017/03/13 20:38:04  vnainar
--$ CR47564 updated delta processing logic in wfm final migration and added new procedure to update sim status
--$
--$ Revision 1.28  2017/03/10 20:35:45  smeganathan
--$ added get_sim_legacy_flag function
--$
--$ Revision 1.27  2017/03/10 16:24:34  smeganathan
--$ CR47564 WFM added created wrapper procedure process_wfm_async to call process_wfm_async_full and changed wfm_customer_status field to wfm_bill_customer_status in x_wfm_customer_status_mapping table
--$
--$ Revision 1.26  2017/03/03 23:57:22  vnainar
--$ CR47564 sysdate enhancements added
--$
--$ Revision 1.25  2017/03/02 21:11:03  vnainar
--$ CR47564 new function get_legacy_flag added
--$
--$ Revision 1.24  2017/03/01 22:46:27  vnainar
--$ CR47564 default throttling policy updated
--$
--$ Revision 1.23  2017/02/28 21:56:35  vnainar
--$ process_wfm_async procedure signature datatype updated for min and sim
--$
--$ Revision 1.22  2017/02/23 21:34:02  vnainar
--$ CR47564  procedure process_wfm_async  updated with enhancements
--$
--$ Revision 1.21  2017/02/22 23:14:46  vnainar
--$ CR47564 process_wfm_async enhancements added
--$
--$ Revision 1.20  2017/02/21 23:05:43  vnainar
--$ CR47564 process_wfm_async enhancements added
--$
--$ Revision 1.19  2017/02/20 23:06:38  vnainar
--$ CR47564 async procedure updated
--$
--$ Revision 1.18  2017/02/15 23:12:28  vnainar
--$ CR47564 New WFM premigration procedures and async added
--$
--$ Revision 1.17  2017/01/26 22:22:37  vlaad
--$ Merged with Prod
--$
--$ Revision 1.12  2017/01/17 23:17:42  vlaad
--$ Update create_cash_balance_Tran and process_cash_balance signature
--$
--$ Revision 1.10  2017/01/13 23:12:37  vnainar
--$ CR46581 input variables added
--$
--$ Revision 1.9  2017/01/13 22:50:39  vnainar
--$ CR46581 cash balance procedure updated
--$
--$ Revision 1.8  2017/01/13 21:31:07  vnainar
--$ CR46581 new procedure added to process cash balance
--$
--$ Revision 1.7  2017/01/13 17:00:47  vnainar
--$ CR46581 new procdure added for cash balance
--$
--$ Revision 1.6  2017/01/10 21:59:20  vlaad
--$ Updated final migration procedure for throttling
--$
--$ Revision 1.4  2016/12/15 18:38:02  pamistry
--$ CR44729 - Modify the procedure name based on review comment
--$
--$ Revision 1.3  2016/12/14 23:25:44  vnainar
--$ CR44729 overloaded procedure added
--$
--$ Revision 1.2  2016/12/09 19:52:18  pamistry
--$ CR44729 Added Final migration procedure.
--$
--$ Revision 1.1  2016/11/30 22:11:54  vnainar
--$ CR44729 Migration pkg added
--$
--$
-------------------------------------------------------------------------
l_flag      VARCHAR2(50);

TYPE billdateextract_tbl IS TABLE OF x_wfm_acct_migration_bill_stg%ROWTYPE; --type for bill data extract
--billdateextract                      billdateextractlist;

PROCEDURE ins_part_inst ( i_part_inst_type IN OUT part_inst_type,
                          o_response       OUT    VARCHAR2);

PROCEDURE ins_site_part ( i_site_part_type IN OUT site_part_type,
                          o_response       OUT    VARCHAR2) ;

PROCEDURE ins_pi_hist ( i_pi_hist_type IN OUT pi_hist_type,
                          o_response   OUT    VARCHAR2)	;

PROCEDURE ins_web_user( i_web_user_type IN OUT web_user_type,
                        o_response      OUT    VARCHAR2);

PROCEDURE ins_contact_part_inst( i_contact_part_inst_type IN OUT contact_part_inst_type,
                                 o_response               OUT    VARCHAR2) ;

PROCEDURE ins_service_plan_site_part( i_service_plan_site_part_type IN OUT service_plan_site_part_type,
                                      o_response                    OUT    VARCHAR2);

PROCEDURE ins_service_plan_hist( i_service_plan_hist_type IN OUT service_plan_hist_type,
                                 o_response               OUT    VARCHAR2);

PROCEDURE ins_program_enrolled ( i_program_enrolled_type IN OUT program_enrolled_type,
                                 o_response              OUT    VARCHAR2);

PROCEDURE ins_program_purch_hdr ( i_program_purch_hdr_type IN OUT program_purch_hdr_type,
                                  i_esn                    IN     VARCHAR2,
                                  o_response               OUT    VARCHAR2);


PROCEDURE ins_program_purch_dtl ( i_program_purch_dtl_type IN OUT program_purch_dtl_type,
                                 o_response                OUT    VARCHAR2);

PROCEDURE ins_program_trans ( i_program_trans_type IN OUT program_trans_type,
                              o_response           OUT    VARCHAR2);

PROCEDURE ins_interaction ( i_contact_objid  IN number,
                            i_reason_1       IN varchar2,
                            i_reason_2       IN varchar2,
                            i_notes          IN  VARCHAR2     ,
                            i_rslt           IN  VARCHAR2     ,
                            i_user           IN  VARCHAR2     ,
                            i_esn            IN  VARCHAR2     ,
                            i_create_date    IN  DATE DEFAULT SYSDATE ,
                            i_start_date     IN  DATE         ,
                            i_end_date       IN  DATE         ,
                            o_interact_objid OUT NUMBER        , --added for CR47564 WFM
                            o_response       OUT VARCHAR2) ;

PROCEDURE create_cash_balance_trans (i_esn                           IN  VARCHAR2, --
                                     i_min                           IN  VARCHAR2, -- ATLEAST ONE OF THESE (ESN/MIN) SHOULD ALWAYS BE PASSED
                                     i_action_type                   IN  VARCHAR2 DEFAULT '401', -- CALL_TRANS ACTION TYPE  FOR THIS TRANSACTION
                                     i_action_text                   IN  VARCHAR2 DEFAULT 'QUEUED', --CALL_TRANS  ACTION TEXT
                                     i_source_system                 IN  VARCHAR2, -- SOURCE SYSTEM  FOR THIS TRANSACTION, MANDATORY PARAMETER
                                     i_extend_service_days           IN  VARCHAR2 DEFAULT 'N',
                                     i_order_type                    IN  VARCHAR2 DEFAULT 'Cash Balance', -- ORDER TYPEFOR THISTRANSACTION, MANDATORY PARAMETER
                                     i_ig_order_type                 IN  VARCHAR2 DEFAULT 'DBT', -- IG ORDER TYPE FOR THIS TRANSACTION, MANDATORY PARAMETER
                                     i_intl_bucket_id                IN  VARCHAR2 DEFAULT 'WALLETPB',
                                     i_intl_bucket_value             IN  VARCHAR2, -- INTL BUCKET VALUE
                                     i_intl_bucket_expiration_date   IN  DATE,     -- MANDATORY IF ILD_BUCKET VLAUE IS PASSED
                                     i_data_bucket_id                IN  VARCHAR2 DEFAULT 'WADADJTH4',
                                     i_data_bucket_value             IN  VARCHAR2, -- DATA BUCKET VALUE. ONE OF ILD OR DATA BUCKET MUST BE PASSED
                                     i_data_bucket_expiration_date   IN  DATE,     -- MANDATORY IF DATA_BUCKET VLAUE IS PASSED
                                     o_err_num                       OUT NUMBER,   -- ERROR NUMBER. WILL BE SENT AS "0" FOR SUCCESS
                                     o_err_msg                       OUT VARCHAR2,  -- ERROR MESSGAE. WILL BE SENT AS "SUCCESS" FOR SUCCESSFUL PROCESSING
                                     i_update_expiration_date_flag  IN VARCHAR2 DEFAULT 'Y'
                                     );

PROCEDURE process_cash_balance ( i_action_type                   IN  VARCHAR2 DEFAULT '6',
                                 i_action_text                   IN  VARCHAR2 DEFAULT 'REDEMPTION',
                                 i_source_system                 IN  VARCHAR2 DEFAULT 'BATCH',
                                 i_extend_service_days           IN  VARCHAR2 DEFAULT 'N',
                                 i_order_type                    IN  VARCHAR2 DEFAULT 'Cash Balance',
                                 i_ig_order_type                 IN  VARCHAR2 DEFAULT 'DBT',
                                 i_intl_bucket_id                IN  VARCHAR2 DEFAULT 'WALLETPB',
                                 i_data_bucket_id                IN  VARCHAR2 DEFAULT 'WADADJTH4',
                                 o_response                      OUT  VARCHAR2,
                                 i_dataset_limit                 IN NUMBER DEFAULT 1000);

-- migrate GoSmart customers into Clarify
PROCEDURE load_gosmart_premigration ( o_response                  OUT VARCHAR2             ,
                                      i_max_rows_limit            IN  NUMBER DEFAULT 50000 ,
                                      i_commit_every_rows         IN  NUMBER DEFAULT 5000  ,
                                      i_bulk_collection_limit     IN  NUMBER DEFAULT 200   ,
                                      i_carrier_id                IN  VARCHAR2 DEFAULT '1113385',
                                      i_brand                     IN  VARCHAR2 DEFAULT 'SIMPLE_MOBILE',
                                      i_phone_part_inst_status    IN  VARCHAR2 DEFAULT '160',
                                      i_line_part_inst_status     IN  VARCHAR2 DEFAULT '120',
                                      i_sim_status                IN  VARCHAR2 DEFAULT '253',
                                      i_site_part_status          IN  VARCHAR2 DEFAULT 'NotMigrated',
                                      i_source_system             IN  VARCHAR2 DEFAULT 'BATCH',
                                      i_enrollment_status         IN  VARCHAR2 DEFAULT 'READYTOREENROLL',
                                      i_pph_request_type          IN  VARCHAR2 DEFAULT 'GOSMART_PURCH',
                                      i_pph_request_source        IN  VARCHAR2 DEFAULT 'GOSMART',
                                      i_user                      IN  VARCHAR2 DEFAULT 'OPERATIONS',
                                      i_pph_payment_type          IN  VARCHAR2 DEFAULT 'GOSMART_ENROLLMENT'  );

--new overlaoded procedure with min
PROCEDURE load_gosmart_premigration ( o_response                  OUT VARCHAR2             ,
                                      i_max_rows_limit            IN  NUMBER DEFAULT 50000 ,
                                      i_commit_every_rows         IN  NUMBER DEFAULT 5000  ,
                                      i_bulk_collection_limit     IN  NUMBER DEFAULT 200   ,
                                      i_carrier_id                IN  VARCHAR2 DEFAULT '1113385',
                                      i_brand                     IN  VARCHAR2 DEFAULT 'SIMPLE_MOBILE',
                                      i_min                       IN  VARCHAR2 ,
                                      i_phone_part_inst_status    IN  VARCHAR2 DEFAULT '160',
                                      i_line_part_inst_status     IN  VARCHAR2 DEFAULT '120',
                                      i_sim_status                IN  VARCHAR2 DEFAULT '253',
                                      i_site_part_status          IN  VARCHAR2 DEFAULT 'NotMigrated',
                                      i_source_system             IN  VARCHAR2 DEFAULT 'BATCH',
                                      i_enrollment_status         IN  VARCHAR2 DEFAULT 'READYTOREENROLL',
                                      i_pph_request_type          IN  VARCHAR2 DEFAULT 'GOSMART_PURCH',
                                      i_pph_request_source        IN  VARCHAR2 DEFAULT 'GOSMART',
                                      i_user                      IN  VARCHAR2 DEFAULT 'OPERATIONS',
                                      i_pph_payment_type          IN  VARCHAR2 DEFAULT 'GOSMART_ENROLLMENT' );

procedure load_gosmart_final_migration (o_response                  OUT VARCHAR2             ,
                                        i_max_rows_limit            IN  NUMBER DEFAULT 50000 ,
                                        i_commit_every_rows         IN  NUMBER DEFAULT 5000,
                                        i_bulk_collection_limit     IN  NUMBER DEFAULT 300,
                                        i_skip_premigration         IN  VARCHAR2 DEFAULT 'N',
                                        i_carrier_id                IN  VARCHAR2 DEFAULT '1113385',
                                        i_brand                     IN  VARCHAR2 DEFAULT 'SIMPLE_MOBILE',
                                        i_phone_part_inst_status    IN  VARCHAR2 DEFAULT '160',
                                        i_line_part_inst_status     IN  VARCHAR2 DEFAULT '120',
                                        i_sim_status                IN  VARCHAR2 DEFAULT '253',
                                        i_site_part_status          IN  VARCHAR2 DEFAULT 'NotMigrated',
                                        i_source_system             IN  VARCHAR2 DEFAULT 'BATCH',
                                        i_enrollment_status         IN  VARCHAR2 DEFAULT 'READYTOREENROLL',
                                        i_pph_request_type          IN  VARCHAR2 DEFAULT 'GOSMART_PURCH',
                                        i_pph_request_source        IN  VARCHAR2 DEFAULT 'GOSMART',
                                        i_user                      IN  VARCHAR2 DEFAULT 'OPERATIONS',
                                        i_pph_payment_type          IN  VARCHAR2 DEFAULT 'GOSMART_ENROLLMENT',
                                        i_policy_name               IN  VARCHAR2 DEFAULT 'policy54'
                                         );
--CR47564 MOVED THIS FROM CUSTOMER TYPE TO HERE

FUNCTION get_migration_flag ( i_min IN VARCHAR2 ) RETURN VARCHAR2;

--WFM clean up procedure
PROCEDURE cleanup_wfm_migration( i_esn               IN VARCHAR2  DEFAULT NULL ,
                                 i_min               IN VARCHAR2               ,
                                 i_sim               IN VARCHAR2  DEFAULT NULL ,
                                 i_stg_objid         IN NUMBER    DEFAULT NULL ,
                                 i_migration_status  IN VARCHAR2,
                                 i_migration_type    IN VARCHAR2,
                                 o_response          OUT VARCHAR2);

--WFM pre migration procedure
PROCEDURE load_wfm_premigration ( o_response                OUT VARCHAR2,
                                  i_max_rows_limit          IN  NUMBER DEFAULT 10000,
                                  i_commit_every_rows       IN  NUMBER DEFAULT 5000,
                                  i_bulk_collection_limit   IN  NUMBER DEFAULT 1000,
                                  i_divisor                 IN  NUMBER DEFAULT  1,
                                  i_remainder               IN  NUMBER DEFAULT  0,
                                  i_carrier_id              IN  VARCHAR2 DEFAULT '180260',
                                  i_brand                   IN  VARCHAR2 DEFAULT 'WFM',
                                  i_phone_part_inst_status  IN  VARCHAR2 DEFAULT '160',
                                  i_line_part_inst_status   IN  VARCHAR2 DEFAULT '120',
                                  i_sim_status              IN  VARCHAR2 DEFAULT '180',
                                  i_site_part_status        IN  VARCHAR2 DEFAULT 'NotMigrated',
                                  i_source_system           IN  VARCHAR2 DEFAULT 'BATCH',
                                  i_user                    IN  VARCHAR2 DEFAULT 'OPERATIONS' );

--WFM final migration procedure for async
PROCEDURE load_wfm_final_migration ( o_response                OUT VARCHAR2,
                                     i_max_rows_limit          IN  NUMBER DEFAULT 10000,
                                     i_commit_every_rows       IN  NUMBER DEFAULT 5000,
                                     i_bulk_collection_limit   IN  NUMBER DEFAULT 1000,
                                     i_carrier_id              IN  VARCHAR2 DEFAULT '180260',
                                     i_brand                   IN  VARCHAR2 DEFAULT 'WFM',
                                     i_min                     IN  VARCHAR2,
                                     i_sim                     IN  VARCHAR2 DEFAULT NULL,
                                     i_esn                     IN  VARCHAR2 DEFAULT NULL,
                                     i_customer_status         IN  VARCHAR2 DEFAULT NULL,
                                     i_phone_part_inst_status  IN  VARCHAR2 DEFAULT '160',
                                     i_line_part_inst_status   IN  VARCHAR2 DEFAULT '120',
                                     i_sim_status              IN  VARCHAR2 DEFAULT '180',
                                     i_site_part_status        IN  VARCHAR2 DEFAULT 'NotMigrated',
                                     i_source_system           IN  VARCHAR2 DEFAULT 'BATCH',
                                     i_user                    IN  VARCHAR2 DEFAULT 'OPERATIONS' ) ;

--WFM final migration overloaded procedure for async with billdateextract as table type
PROCEDURE load_wfm_final_migration ( o_response                OUT VARCHAR2,
                                     i_max_rows_limit          IN  NUMBER DEFAULT 10000,
                                     i_commit_every_rows       IN  NUMBER DEFAULT 5000,
                                     i_bulk_collection_limit   IN  NUMBER DEFAULT 1000,
                                     i_carrier_id              IN  VARCHAR2 DEFAULT '180260',
                                     i_brand                   IN  VARCHAR2 DEFAULT 'WFM',
                                     i_min                     IN  VARCHAR2,
                                     i_sim                     IN  VARCHAR2 DEFAULT NULL,
                                     i_esn                     IN  VARCHAR2 DEFAULT NULL,
                                     i_customer_status         IN  VARCHAR2 DEFAULT NULL,
                                     i_billdateextract_tbl     IN  billdateextract_tbl	,
                                     i_phone_part_inst_status  IN  VARCHAR2 DEFAULT '160',
                                     i_line_part_inst_status   IN  VARCHAR2 DEFAULT '120',
                                     i_sim_status              IN  VARCHAR2 DEFAULT '180',
                                     i_site_part_status        IN  VARCHAR2 DEFAULT 'NotMigrated',
                                     i_source_system           IN  VARCHAR2 DEFAULT 'BATCH',
                                     i_user                    IN  VARCHAR2 DEFAULT 'OPERATIONS' ) ;
--WFM async procedure
PROCEDURE process_wfm_async_full (  i_esn                          IN   VARCHAR2                      ,
                                    i_min                          IN   VARCHAR2                      ,
                                    i_sim                          IN   VARCHAR2                      ,
                                    i_customer_status              IN   VARCHAR2                      ,
                                    i_order_type                   IN   VARCHAR2 DEFAULT 'Data Migration Handler'        ,
                                    i_action_type                  IN   VARCHAR2 DEFAULT '1'          ,
                                    i_action_text                  IN   VARCHAR2 DEFAULT 'Activation' ,
                                    i_igtb_wfm_async_tab           IN   igtb_wfm_async_tab         ,
                                    i_policy_name                  IN   VARCHAR2 DEFAULT 'policy70'   , -- THIS IS A PLACEHOLDER
                                    i_source_system                IN   VARCHAR2 DEFAULT 'BATCH'      ,
                                    i_skip_migration               IN   VARCHAR2 DEFAULT 'N'          ,
                                    i_skip_async                   IN   VARCHAR2 DEFAULT 'N'  , --if passed as 'Y' insert log and update bill_stg status and return
                                    i_reprocess_flag               IN   VARCHAR2 DEFAULT 'N'  ,--Y/N, Y--override migration status and skip group failed reprocess
                                    i_call_trans_result            IN   VARCHAR2 DEFAULT 'Migrated'   ,
                                    i_cc_algorithm                 IN   VARCHAR2 DEFAULT 'http://www.w3.org/2001/04/xmlenc#aes256-cbc',
                                    i_key_algorithm                IN   VARCHAR2 DEFAULT 'http://www.w3.org/2001/04/xmlenc#rsa-1_5',
                                    i_cert                         IN   VARCHAR2 DEFAULT 'gw-ccn-encrypt-cert-koz-20070717',
                                    o_response                     OUT  VARCHAR2                      ) ;
--
--  WFM async procedure with mandatory parameters only
-- This procedure will internally call process_wfm_async_full
PROCEDURE process_wfm_async ( i_esn                          IN   VARCHAR2                      ,
                              i_min                          IN   VARCHAR2                      ,
                              i_sim                          IN   VARCHAR2                      ,
                              i_customer_status              IN   VARCHAR2                      ,
                              i_igtb_wfm_async_tab           IN   igtb_wfm_async_tab         ,
                              o_response                     OUT  VARCHAR2                      ) ;
--
FUNCTION get_sim_legacy_flag(i_sim IN VARCHAR2)  RETURN VARCHAR2 ;
FUNCTION get_customer_type_attributes ( i_esn IN VARCHAR2 ) RETURN customer_type;
--FUNCTION get_esn_legacy_flag(i_esn IN VARCHAR2)  RETURN VARCHAR2 ;
PROCEDURE update_wfm_sim_status(o_response              OUT VARCHAR2,
                                i_bulk_collection_limit IN NUMBER DEFAULT 500 );
--
--  WFM async procedure with mandatory parameters only for final migration
-- This procedure will internally call reprocess_wfm_async_full
PROCEDURE reprocess_wfm_async ( i_esn                          IN   VARCHAR2                ,
                                i_min                          IN   VARCHAR2                ,
                                i_sim                          IN   VARCHAR2                ,
                                i_customer_status              IN   VARCHAR2                ,
                                i_igtb_wfm_async_tab           IN   igtb_wfm_async_tab   ,
                                o_response                     OUT  VARCHAR2                );
--
PROCEDURE reprocess_wfm_async_full (  i_esn                          IN   VARCHAR2                      ,
                                      i_min                          IN   NUMBER                        ,
                                      i_sim                          IN   NUMBER                        ,
                                      i_customer_status              IN   VARCHAR2                      ,
                                      i_order_type                   IN   VARCHAR2 DEFAULT 'Data Migration Handler'        ,
                                      i_action_type                  IN   VARCHAR2 DEFAULT '1'          ,
                                      i_action_text                  IN   VARCHAR2 DEFAULT 'Activation' ,
                                      i_igtb_wfm_async_tab           IN   igtb_wfm_async_tab ,
                                      i_policy_name                  IN   VARCHAR2 DEFAULT 'policy54'   , -- THIS IS A PLACEHOLDER
                                      i_source_system                IN   VARCHAR2 DEFAULT 'BATCH'      ,
                                      i_skip_migration               IN   VARCHAR2 DEFAULT 'N'          ,--flag to skip migration in case of rerun
                                      i_skip_async                   IN   VARCHAR2 DEFAULT 'N'    ,--if passed as 'Y' insert log and update bill_stg status nd return
                                      i_reprocess_flag               IN   VARCHAR2 DEFAULT 'N',--Y/N Y--override migration status and skip group failed reprocess
                                      i_call_trans_result            IN   VARCHAR2 DEFAULT 'Migrated'   ,
                                      o_response                     OUT  VARCHAR2                      );
--
-- Procedure to load credit card data
PROCEDURE load_wfm_cc_data  (i_max_row_limit      IN    NUMBER DEFAULT 1000,
                             i_commit_every_rows  IN    NUMBER DEFAULT 5000,
                             o_response           OUT   VARCHAR2
                            );
--
--  Procedure to load ach details
PROCEDURE load_wfm_ach_data (i_max_row_limit      IN    NUMBER DEFAULT 1000,
                             i_commit_every_rows  IN    NUMBER DEFAULT 5000,
                             o_response           OUT   VARCHAR2
                            );

  -- WFM CR47564 Changes
PROCEDURE load_wfm_interaction( i_max_row_limit      IN  NUMBER DEFAULT 1000,
                                i_commit_every_rows  IN  NUMBER DEFAULT 5000,
                                i_divisor            IN  NUMBER DEFAULT  1,
                                i_remainder          IN  NUMBER DEFAULT  0,
                                o_response           OUT VARCHAR2);

PROCEDURE load_wfm_bill_interaction( i_max_row_limit      IN  NUMBER DEFAULT 1000,
                                     i_commit_every_rows  IN  NUMBER DEFAULT 5000,
                                     i_divisor            IN  NUMBER DEFAULT  1,
                                     i_remainder          IN  NUMBER DEFAULT  0,
                                     o_response           OUT VARCHAR2);
--
END migration_pkg;
/