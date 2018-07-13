CREATE OR REPLACE PACKAGE sa.ARCHIVE_PKG
IS
/*************************************************************************************************************************************
  * $Revision: 1.17 $
  * $Author: spagidala $
  * $Date: 2018/05/17 19:46:47 $
  * $Log: archive_pkg.sql,v $
  * Revision 1.17  2018/05/17 19:46:47  spagidala
  * CR57903 - Added new procedure
  *
  * Revision 1.16  2018/05/02 14:48:56  smacha
  * Merged to Prod version.
  *
  * $Revision: 1.17 $
  * $Author: spagidala $
  * $Date: 2018/05/17 19:46:47 $
  * $Log: archive_pkg.sql,v $
  * Revision 1.17  2018/05/17 19:46:47  spagidala
  * CR57903 - Added new procedure
  *
  * Revision 1.15  2018/04/16 19:40:28  sinturi
  * New purge proc added
  *
  * Revision 1.14  2018/03/19 22:20:30  tpathare
  * New procedure archive_sui_inquiry_mismatches
  *
  * Revision 1.12  2018/03/07 14:47:19  skota
  * Merged the code
  *
  * Revision 1.11  2018/02/13 23:08:14  mshah
  * CR55240 - Enhance DP Logs data.
  *
  * Revision 1.10  2018/02/12 15:58:32  mshah
  * CR55240 - Enhance DP Logs data.
  *
  * Revision 1.7  2017/08/15 20:24:00  tpathare
  * New procedure archive_device_recovery_code
  *
  * Revision 1.4  2017/04/06 21:55:00  aganesan
  * CR47564 - archive_queue_event_log procedure signature modified
  *
  * Revision 1.3  2017/03/02 19:57:43  aganesan
  * CR47564 changes
  *
  * Revision 1.1  2016/11/17 18:11:54  abustos
  * Create new pkg to hold all archiving procedures
  *
  *************************************************************************************************************************************/

  -- Procedure used to delete records from rtc_process_log that are older than i_archive_from_days
  PROCEDURE  archive_rtc_process_log  ( i_archive_from_days     IN  NUMBER DEFAULT 30   ,
                                        o_response              OUT VARCHAR2            ,
                                        i_max_rows_limit        IN  NUMBER DEFAULT 1000 ,
                                        i_commit_every_rows     IN  NUMBER DEFAULT 5000 ,
                                        i_bulk_collection_limit IN  NUMBER DEFAULT 200  );

  PROCEDURE  archive_spr_reprocess_log ( i_archive_from_days     IN  NUMBER DEFAULT 7    ,
                                         i_max_rows_limit        IN  NUMBER DEFAULT 1000 ,
                                         i_commit_every_rows     IN  NUMBER DEFAULT 5000 ,
                                         i_bulk_collection_limit IN  NUMBER DEFAULT 200  ,
                                         o_response              OUT VARCHAR2            );

  PROCEDURE  archive_pcrf_transaction ( i_archive_from_days     IN  NUMBER DEFAULT 7    ,
                                        o_response              OUT VARCHAR2            ,
                                        i_max_rows_limit        IN  NUMBER DEFAULT 1000 ,
                                        i_commit_every_rows     IN  NUMBER DEFAULT 5000 ,
                                        i_bulk_collection_limit IN  NUMBER DEFAULT 200  );

  --Procedure used to archive the queue event log to BRM
  PROCEDURE  archive_queue_event_log ( i_archive_from_days     IN  NUMBER DEFAULT 60  ,
                                       i_max_rows_limit        IN  NUMBER DEFAULT 1000,
                                       i_commit_every_rows     IN  NUMBER DEFAULT 5000,
                                       i_bulk_collection_limit IN  NUMBER DEFAULT 200 ,
                                       o_response              OUT VARCHAR2
                                       );
  --CR48846 Procedure added to cleanup table x_device_recovery_code
  PROCEDURE archive_device_recovery_code( i_archive_from_days     IN  NUMBER DEFAULT 60  ,
                                          i_max_rows_limit        IN  NUMBER DEFAULT 1000,
                                          i_commit_every_rows     IN  NUMBER DEFAULT 5000,
                                          i_bulk_collection_limit IN  NUMBER DEFAULT 200 ,
                                          o_response              OUT VARCHAR2
                                        );


  --CR52654 Procedure added to purge table table_customer_comm_stg
  PROCEDURE archive_customer_comm_stg( i_archive_from_days     IN  NUMBER DEFAULT 7  ,
                                       i_max_rows_limit        IN  NUMBER DEFAULT 1000,
                                       i_commit_every_rows     IN  NUMBER DEFAULT 5000,
                                       i_bulk_collection_limit IN  NUMBER DEFAULT 200 ,
                                       o_response              OUT VARCHAR2
                                     );
  ---------------------------
  PROCEDURE archive_x_payment_log (
                                   i_archive_from_days     IN  NUMBER DEFAULT 30  ,
                                   i_max_rows_limit        IN  NUMBER DEFAULT 1000,
                                   i_commit_every_rows     IN  NUMBER DEFAULT 5000,
                                   i_bulk_collection_limit IN  NUMBER DEFAULT 200 ,
                                   o_response              OUT VARCHAR2
                                  );
  PROCEDURE archive_pageplus_event_stg ( i_archive_from_days     IN  NUMBER DEFAULT 7    ,
                                        o_response              OUT VARCHAR2            ,
                                        i_max_rows_limit        IN  NUMBER DEFAULT 1000 ,
                                        i_commit_every_rows     IN  NUMBER DEFAULT 5000 ,
                                        i_bulk_collection_limit IN  NUMBER DEFAULT 200  );

  --CR55008 Procedure added to cleanup table ig_sui_inquiry_mismatches
  PROCEDURE archive_sui_inquiry_mismatches( i_archive_from_days     IN  NUMBER DEFAULT 30  ,
                                            i_max_rows_limit        IN  NUMBER DEFAULT 1000,
                                            i_commit_every_rows     IN  NUMBER DEFAULT 5000,
                                            i_bulk_collection_limit IN  NUMBER DEFAULT 200 ,
                                            o_response              OUT VARCHAR2
                                          );

  --CR57166,Archive table x_imei_mismatch
  PROCEDURE archive_imei_mismatch ( i_archive_from_days     IN  NUMBER DEFAULT 60    ,
                                    o_response              OUT VARCHAR2            ,
                                    i_max_rows_limit        IN  NUMBER DEFAULT 1000 ,
                                    i_commit_every_rows     IN  NUMBER DEFAULT 5000 ,
                                    i_bulk_collection_limit IN  NUMBER DEFAULT 200
                                  );

  -- This procedure will delete the archied data dinamically with passing table details.
  PROCEDURE archive_purge_process ( i_table_name        IN    VARCHAR2,
                                    i_base_column_name  IN    VARCHAR2,
                                    i_archive_from_days IN    NUMBER,
                                    i_max_rows_limit    IN    NUMBER,
                                    o_response          OUT   VARCHAR2);
END ARCHIVE_PKG;
/