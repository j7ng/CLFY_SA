CREATE OR REPLACE PACKAGE sa.pcrf_queue_data_pkg is

/*************************************************************************************************************************************
  * $Revision: 1.2 $
  * $Author: skota $
  * $Date: 2017/01/25 20:17:24 $
  * $Log: PCRF_QUEUE_DATA_PKG.sql,v $
  * Revision 1.2  2017/01/25 20:17:24  skota
  * Modified for DB2PCRF
  *
  * Revision 1.1  2016/10/21 21:28:49  skota
  * CR45527 db2pcrf Low Priority Performance Improvement
  *
  * Revision 1.1  2016/10/21 14:57:45  skota
  * CR45527 db2pcrf Low Priority Performance Improvement
  *
  *************************************************************************************************************************************/

--pcrf low  priority
PROCEDURE sp_low_priority_pcrf_data (i_rownum           IN  NUMBER DEFAULT 100       ,
                                     i_pcrf_status_code IN  VARCHAR2 DEFAULT 'Q'     ,
                                     o_pcrf_data        OUT pcrf_trans_low_prty_tab  ,
                                     o_data_count       OUT NUMBER                   );

--pcrf
PROCEDURE sp_pcrf_data (i_rownum            IN  NUMBER DEFAULT 100     ,
                        i_pcrf_status_code  IN  VARCHAR2 DEFAULT 'Q'   ,
						i_pcrf_order_type   IN  VARCHAR2               ,
                        o_pcrf_data         OUT pcrf_transaction_tab   ,
                        o_data_count        OUT NUMBER                 );

end pcrf_queue_data_pkg;
/