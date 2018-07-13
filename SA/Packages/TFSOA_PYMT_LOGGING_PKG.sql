CREATE OR REPLACE PACKAGE sa."TFSOA_PYMT_LOGGING_PKG" as
Procedure Tf_Pymt_Logging_Process (P_Pymthdr_Objid    In Number,
                                   P_Pymthdr_Batchid  In Number Default Null,
                                   P_Pymt_App         In Varchar2 Default Null,
                                   P_Pymt_Res_Type_Bp In Out Tf_Pymt_Response_Type );

procedure TF_PYMT_CS_XREF_PROCESS (CS_AUTH_AUTH_RESPONSE In VARCHAR2,
                                   cs_process_type       IN VARCHAR2 DEFAULT NULL,
                                   OUT_AUTH_RCODE        OUT  VARCHAR2,
                                   OUT_AUTH_RFLAG        OUT  VARCHAR2,
                                   OUT_AUTH_RMSG         OUT  VARCHAR2,
                                   OUT_ICS_RCODE         OUT  VARCHAR2,
                                   OUT_ICS_RFLAG         OUT  VARCHAR2,
                                   OUT_ICS_RMSG          OUT  VARCHAR2);
--CR16523 new procedure
procedure TF_PYMT_CS_XREF_PROCESS (CS_AUTH_AUTH_RESPONSE In VARCHAR2,
                                   CS_AUTH_RCODE IN VARCHAR2,
                                   cs_process_type       IN VARCHAR2 DEFAULT NULL,
                                   OUT_AUTH_RCODE        OUT  VARCHAR2,
                                   OUT_AUTH_RFLAG        OUT  VARCHAR2,
                                   OUT_AUTH_RMSG         OUT  VARCHAR2,
                                   OUT_ICS_RCODE         OUT  VARCHAR2,
                                   OUT_ICS_RFLAG         OUT  VARCHAR2,
                                   OUT_ICS_RMSG          OUT  VARCHAR2);
END TFSOA_PYMT_LOGGING_PKG ;
/