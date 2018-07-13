CREATE OR REPLACE PACKAGE sa."TFSOA_BATCH_PROCESS_PKG" as
procedure TF_CREATE_BATCH_RECORDS (p_bus_org IN VARCHAR2 DEFAULT 'TRACFONE',
                                   in_priority IN VARCHAR2 DEFAULT 20, ---CR25625
                                   op_result out NUMBER,
                                   op_msg out VARCHAR2);

PROCEDURE get_tfsoa_batch_process_data (i_rownum                          IN  NUMBER DEFAULT 100        ,
                                        i_process_status                  IN  VARCHAR2 DEFAULT 'VNEW'   ,
                                        o_tfsoa_batch_process_data        OUT TFSOA_BATCH_PROCESS_tab   ,
                                        o_data_count                      OUT NUMBER                 );
END TFSOA_BATCH_PROCESS_PKG ;
/