CREATE OR REPLACE PACKAGE BODY sa."TFSOA_PYMT_LOGGING_PKG" As

--Realtime
Procedure Tf_Pymt_Real_Time (P_Pymthdr_Objid    In Number,
                             p_pymt_res_type_rt IN OUT TF_PYMT_RESPONSE_TYPE) AS
Begin
    TFSOA_PYMT_REAL_TIME_PRC(p_pymthdr_OBJID,p_pymt_res_type_rt);
End Tf_Pymt_Real_Time ;

--APPS
Procedure Tf_Pymt_Apps (P_Pymthdr_Objid     In Number,
                        P_Pymt_Res_Type_App In Out Tf_Pymt_Response_Type )As
Begin
   TFSOA_PYMENT_APP_PRC(p_pymthdr_objid, P_Pymt_Res_Type_App);
END;

--Batch Payment
Procedure Tf_Pymt_Batch_Process (P_Pymthdr_Objid    In Number,
                                 P_Pymthdr_Batchid  In Number,
                                 P_Pymt_Res_Type_Bp In Out Tf_Pymt_Response_Type) As
Begin

    Tfsoa_Pymt_Batch_Process_Prc(P_Pymthdr_Objid,P_Pymt_Res_Type_Bp);


    --If the response was 100 success and the resposne was sucesful updated in the hdr proccess the success record
    If ( (P_Pymt_Res_Type_Bp.Ics_Rcode = 100 or P_Pymt_Res_Type_Bp.Ics_Rcode = 1) And P_Pymt_Res_Type_Bp.Error_Code = 0) Then


       sa.billing_payment_recon_pkg.Payment_Hdr_Success(P_Pymthdr_Batchid,P_Pymthdr_Objid,P_Pymt_Res_Type_Bp.Error_Code, P_Pymt_Res_Type_Bp.ERROR_DESC); --new signature for SOA

    /* uncomment next lines once we have test ach_recon support in SIT
      IF (P_Pymt_Res_type_BP.ACH_TRANS.DEBIT_REQUEST_ID IS NOT NULL) THEN
           Sa.billing_payment_recon_pkg.soa_ach_recon(P_Pymthdr_Objid,P_Pymt_Res_Type_Bp.Error_Code, P_Pymt_Res_Type_Bp.ERROR_DESC); --new signature for SOA
      END IF;
    */

    End If;

END TF_PYMT_BATCH_PROCESS;


Procedure Tf_Pymt_Logging_Process (P_Pymthdr_Objid    In Number,
                                   P_Pymthdr_Batchid  In Number Default Null,
                                   P_Pymt_APP         In Varchar2 Default Null,
                                   P_Pymt_Res_Type_Bp In Out Tf_Pymt_Response_Type)As
v_procedure VARCHAR2(50) := 'NO_Proccess_Matches';
Begin

   If P_Pymthdr_Batchid Is Null And P_Pymt_App Is Null Then
      v_procedure := 'Tf_Pymt_Real_Time';
      Tf_Pymt_Real_Time(P_Pymthdr_Objid,P_Pymt_Res_Type_Bp);
   Elsif P_Pymt_App Is Not Null And P_Pymthdr_Batchid Is Null Then
      v_procedure :=  'Tf_Pymt_Apps';
      Tf_Pymt_Apps(P_Pymthdr_Objid, P_Pymt_Res_Type_Bp);
   Elsif P_Pymthdr_Batchid Is Not Null And  P_Pymt_App Is Null Then

      v_procedure := 'Tf_Pymt_Batch_Process';
       Tf_Pymt_Batch_Process(P_Pymthdr_Objid, P_Pymthdr_Batchid, P_Pymt_Res_Type_Bp);
   Else
    -- Raise_Application_Error(-20011, 'There is not signature that matches, please review the parameters...');
    P_Pymt_Res_Type_Bp.Error_Code := '-20011';
    P_Pymt_Res_Type_Bp.Error_DESC := 'There is not signature that matches, please review the parameters...';

   END IF;

 /*
   If (P_Pymt_Res_Type_Bp.Error_Code != 0) Then
      Raise_Application_Error(-20010, V_Procedure|| '- Err_Code: '||P_Pymt_Res_Type_Bp.Error_Code||
                              ', ERR_DESC: '||P_Pymt_Res_Type_Bp.Error_Desc);
  End If; */
End;

/* Overload of TF_PYMT_CS_XREF_PROCESS for backwards compatibility */
procedure TF_PYMT_CS_XREF_PROCESS (CS_AUTH_AUTH_RESPONSE IN VARCHAR2,
                                   cs_process_type       IN VARCHAR2 DEFAULT NULL,
                                   OUT_AUTH_RCODE        OUT  VARCHAR2,
                                   OUT_AUTH_RFLAG        OUT  VARCHAR2,
                                   OUT_AUTH_RMSG         OUT  VARCHAR2,
                                   OUT_ICS_RCODE         OUT  VARCHAR2,
                                   OUT_ICS_RFLAG         OUT  VARCHAR2,
                                   OUT_ICS_RMSG          OUT  VARCHAR2) AS
BEGIN
   BEGIN
   --CR16523
    TF_PYMT_CS_XREF_PROCESS(
          NULL,
          CS_AUTH_AUTH_RESPONSE,cs_process_type,
          OUT_AUTH_RCODE,
          OUT_AUTH_RFLAG,
          OUT_AUTH_RMSG,
          OUT_ICS_RCODE,
          OUT_ICS_RFLAG,
          OUT_ICS_RMSG);
  END;
END TF_PYMT_CS_XREF_PROCESS;

--CR16523 new procedure
procedure TF_PYMT_CS_XREF_PROCESS (CS_AUTH_AUTH_RESPONSE IN VARCHAR2,
                                   CS_AUTH_RCODE IN VARCHAR2,  -- added to correct mapping problems 05/17 RM
                                   cs_process_type       IN VARCHAR2 DEFAULT NULL,
                                   OUT_AUTH_RCODE        OUT  VARCHAR2,
                                   OUT_AUTH_RFLAG        OUT  VARCHAR2,
                                   OUT_AUTH_RMSG         OUT  VARCHAR2,
                                   OUT_ICS_RCODE         OUT  VARCHAR2,
                                   OUT_ICS_RFLAG         OUT  VARCHAR2,
                                   OUT_ICS_RMSG          OUT  VARCHAR2) AS
BEGIN
   BEGIN

   /* Added logic to use AUTH_RCODE when AUTH_AUTH_RCODE is missing - 05/17 RM   CR16523*/
   IF CS_AUTH_AUTH_RESPONSE IS NULL OR LENGTH(CS_AUTH_AUTH_RESPONSE) = 0 THEN
        SELECT DECODE(CS_AUTH_RCODE,100,DECODE(cs_process_type,'BP',100,1),CS_AUTH_RCODE),
               AUTH_RFLAG,
               AUTH_RMSG,
               DECODE(CS_AUTH_RCODE,100,DECODE(cs_process_type,'BP',100,1),CS_AUTH_RCODE),
               ICS_RFLAG,
               ICS_RMSG
          INTO OUT_AUTH_RCODE,
               OUT_AUTH_RFLAG,
               OUT_AUTH_RMSG,
               OUT_ICS_RCODE,
               OUT_ICS_RFLAG,
               OUT_ICS_RMSG
          FROM TFSOA_XREF
          WHERE AUTH_AUTH_RESPONSE = (select min(AUTH_AUTH_RESPONSE) from TFSOA_XREF where AUTH_AUTH_RESPONSE IN (CS_AUTH_RCODE,'999'))  -- update on 5/17
          AND PROCESS_TYPE = DECODE(CS_AUTH_RCODE, '100',DECODE(cs_process_type, NULL, 'ALL','BP','BP','ALL'),'ALL');
   ELSE
        SELECT AUTH_RCODE,
               AUTH_RFLAG,
               AUTH_RMSG,
               ICS_RCODE,
               ICS_RFLAG,
               ICS_RMSG
          INTO OUT_AUTH_RCODE,
               OUT_AUTH_RFLAG,
               OUT_AUTH_RMSG,
               OUT_ICS_RCODE,
               OUT_ICS_RFLAG,
               OUT_ICS_RMSG
          FROM TFSOA_XREF
          WHERE AUTH_AUTH_RESPONSE = (select min(AUTH_AUTH_RESPONSE) from TFSOA_XREF where AUTH_AUTH_RESPONSE IN (CS_AUTH_AUTH_RESPONSE,'999'))  -- update on 3/29
          AND PROCESS_TYPE = DECODE(CS_AUTH_AUTH_RESPONSE, '100',DECODE(cs_process_type, NULL, 'ALL','BP','BP','ALL'),'ALL');
   END IF;
     /*    AND PROCESS_TYPE = DECODE(cs_process_type, NULL, 'ALL','BP','BP','ALL'); */
   EXCEPTION
     WHEN OTHERS THEN
       OUT_AUTH_RCODE   := CS_AUTH_RCODE;
       OUT_AUTH_RFLAG   := NULL;
       OUT_AUTH_RMSG    := NULL;
       OUT_ICS_RCODE    := CS_AUTH_RCODE;
       OUT_ICS_RFLAG    := NULL;
       OUT_ICS_RMSG     := 'UNKNOWN ERROR CODE';

   END;
END TF_PYMT_CS_XREF_PROCESS;
END TFSOA_PYMT_LOGGING_PKG;
/