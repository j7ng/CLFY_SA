CREATE OR REPLACE PROCEDURE sa.TFSOA_PYMENT_APP_PRC (p_pymthdr_objid in number,p_pymt_res_type_rt IN OUT TF_PYMT_RESPONSE_TYPE ) AS
Cursor c_xref (p_AUTH_RESPONSE varchar2) is
    select * from TFSOA_XREF where AUTH_AUTH_RESPONSE=p_AUTH_RESPONSE;

l_xref c_xref%rowtype;
Begin
    p_pymt_res_type_rt.Error_Code := 0;
    if p_pymt_res_type_rt.AUTH_AUTH_RESPONSE is not null
    then
        open c_xref(p_pymt_res_type_rt.AUTH_AUTH_RESPONSE);
        fetch c_xref into l_xref;
        if c_xref%found
        Then
            p_pymt_res_type_rt.auth_rcode        := l_xref.auth_rcode       ;
            p_pymt_res_type_rt.auth_rflag        := l_xref.auth_rflag       ;
            p_pymt_res_type_rt.auth_rmsg         := l_xref.auth_rmsg        ;
            p_pymt_res_type_rt.ics_rcode         := l_xref.ics_rcode        ;
            p_pymt_res_type_rt.ics_rflag         := l_xref.ics_rflag        ;
            p_pymt_res_type_rt.ics_rmsg          := l_xref.ics_rmsg         ;
        end if;
        close c_xref;
    end if;

   Update table_x_purch_hdr
     set X_RQST_DATE=sysdate,
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
       --  X_STATUS            = pymtHeader.X_STATUS,
         X_Auth_Amount       = P_Pymt_Res_Type_Rt.Auth_Auth_Amount,
         X_Bill_Amount       = P_Pymt_Res_Type_Rt.Bill_Bill_Amount,
         X_PURCH_HDR2X_RMSG_CODES = (SELECT OBJID
                                   FROM TABLE_X_PURCH_CODES
                                   WHERE x_app= 'CyberSource'
                                     and  x_code_type = 'rflag'
                                     And X_Code_Value =  P_Pymt_Res_Type_Rt.Ics_Rflag
                                     And X_Language = 'English')
       Where Objid = P_Pymthdr_Objid;

Exception
   When No_Data_Found  Then
        -- raise_application_error (-20004, '-TFSOA_PYMENT_APP_PRC: No data Found');
         P_Pymt_Res_Type_Rt.Error_Code := -20004;
         P_Pymt_Res_Type_Rt.ERROR_DESC := Sqlcode ||'-TFSOA_PYMENT_APP_PRC: No data Found';
   When Others  Then
         P_Pymt_Res_Type_Rt.Error_Code := -900;
         P_Pymt_Res_Type_Rt.ERROR_DESC := Sqlcode ||'-TFSOA_PYMENT_APP_PRC: '|| Substr (Sqlerrm, 1, 170);
END  TFSOA_PYMENT_APP_PRC;
/