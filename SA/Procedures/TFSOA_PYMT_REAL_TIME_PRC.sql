CREATE OR REPLACE PROCEDURE sa."TFSOA_PYMT_REAL_TIME_PRC" (p_pymthdr_objid in number,p_pymt_res_type_rt IN OUT TF_PYMT_RESPONSE_TYPE ) AS
Begin
    p_pymt_res_type_rt.Error_Code := 0;


   UPDATE X_PROGRAM_PURCH_HDR
   SET   X_RQST_DATE=sysdate,
         X_AVS= p_pymt_res_type_rt.AVS,
         X_AUTH_REQUEST_ID   = p_pymt_res_type_rt.AUTH_REQUEST_ID,
         X_AUTH_CODE         = p_pymt_res_type_rt.AUTH_AUTH_CODE,
         X_ICS_RCODE         = p_pymt_res_type_rt.ICS_RCODE,
         X_ICS_RFLAG         = p_pymt_res_type_rt.ICS_RFLAG,
         X_ICS_RMSG          = p_pymt_res_type_rt.ICS_RMSG,
         X_REQUEST_ID        = p_pymt_res_type_rt.REQUEST_ID,
         X_AUTH_AVS          = p_pymt_res_type_rt.AUTH_AUTH_AVS,
         X_AUTH_RESPONSE     = p_pymt_res_type_rt.AUTH_AUTH_RESPONSE,
         X_AUTH_TIME         = p_pymt_res_type_rt.AUTH_AUTH_TIME,
         X_AUTH_RCODE        = p_pymt_res_type_rt.AUTH_RCODE,
         X_AUTH_RFLAG        = p_pymt_res_type_rt.AUTH_RFLAG,
         X_AUTH_RMSG         = p_pymt_res_type_rt.AUTH_RMSG,
         X_BILL_REQUEST_TIME = p_pymt_res_type_rt.BILL_BILL_REQUEST_TIME,
         X_BILL_RCODE        = p_pymt_res_type_rt.BILL_RCODE,
         X_BILL_RMSG         = p_pymt_res_type_rt.BILL_RMSG,
         X_BILL_RFLAG        = p_pymt_res_type_rt.BILL_RFLAG,
         X_BILL_TRANS_REF_NO = p_pymt_res_type_rt.BILL_TRANS_REF_NO,
         --X_STATUS            = pymtHeader.X_STATUS,
         X_AUTH_AMOUNT       = p_pymt_res_type_rt.AUTH_AUTH_AMOUNT,
         X_BILL_AMOUNT       = p_pymt_res_type_rt.BILL_BILL_AMOUNT,
         PURCH_HDR2RMSG_CODES = (SELECT OBJID
                                   FROM TABLE_X_PURCH_CODES
                                   WHERE x_app= 'CyberSource'
                                     and  x_code_type = 'rflag'
                                     and x_code_value =  p_pymt_res_type_rt.ICS_RFLAG
                                     and x_language = 'English')
   WHERE OBJID = p_pymthdr_objid;

   UPDATE  X_CC_PROG_TRANS
   SET  X_AUTH_CV_RESULT      = p_pymt_res_type_rt.AUTH_CV_RESULT ,
        X_SCORE_FACTORS       = p_pymt_res_type_rt.SCORE_FACTORS,
        X_SCORE_HOST_SEVERITY = p_pymt_res_type_rt.SCORE_HOST_SEVERITY,
        X_SCORE_RCODE         = p_pymt_res_type_rt.SCORE_RCODE,
        X_SCORE_RFLAG         = p_pymt_res_type_rt.SCORE_RFLAG,
        X_SCORE_RMSG          =  p_pymt_res_type_rt.SCORE_RMSG,
        X_Score_Result        =  P_Pymt_Res_Type_Rt.Score_Score_Result,
        X_SCORE_TIME_LOCAL    =  p_pymt_res_type_rt.SCORE_TIME_LOCAL
 Where  X_Cc_Trans2x_Purch_Hdr = P_Pymthdr_Objid;

Exception
   When No_Data_Found  Then
      --   raise_application_error (-20004, '-TFSOA_PYMT_REAL_TIME_PRC: No data Found');
           P_Pymt_Res_Type_Rt.Error_Code := -20004;
         P_Pymt_Res_Type_Rt.ERROR_DESC := Sqlcode ||'-TFSOA_PYMT_REAL_TIME_PRC: No data Found';

   When Others  Then
         P_Pymt_Res_Type_Rt.Error_Code := -900;
         P_Pymt_Res_Type_Rt.ERROR_DESC := Sqlcode ||'-TFSOA_PYMT_REAL_TIME_PRC: '|| Substr (Sqlerrm, 1, 170);

END TFSOA_PYMT_REAL_TIME_PRC;
/