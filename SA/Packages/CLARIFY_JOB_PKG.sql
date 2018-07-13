CREATE OR REPLACE PACKAGE sa."CLARIFY_JOB_PKG" as
/************************************************************************************************
PURPOSE:  Manage the table jobs, used for backend activations of warehouse exchanges

---------------------------------------------------------------------------------------------
--$RCSfile: CLARIFY_JOB_PKG.sql,v $
--$Revision: 1.5 $
--$Author: jarza $
--$Date: 2015/01/06 16:15:42 $
--$ $Log: CLARIFY_JOB_PKG.sql,v $
--$ Revision 1.5  2015/01/06 16:15:42  jarza
--$ CR30528 - Added a new parameter to 2 procedures
--$
--$ Revision 1.4  2011/11/21 15:45:23  nguada
--$ CR15757 Adding old esn parameter
--$
--$ Revision 1.3  2011/11/07 18:56:41  akhan
--$ adding parameter back
--$
--$ Revision 1.2  2011/11/07 17:15:18  akhan
--$ Fix parameter in create_job and add CVS header
--$

|************************************************************************************************/

  procedure create_job (
     ip_title in varchar2,
     ip_case_objid in number,
     Ip_User_Objid In Number,
     ip_old_esn in varchar2,
     Ip_Esn In Varchar2,
     Ip_Min In Varchar2,
     Ip_Program_Objid In Number,
     Ip_Web_User_Objid In Number,
     ip_contact_objid in number,
     Ip_Zip In Varchar2,
     ip_iccid in varchar2,
     op_job_objid out number,
     op_error_no out varchar2,
     op_error_str out varchar2);

  procedure change_status (
     ip_job_objid number,
     ip_job_status varchar2,
     ip_comment varchar2,
     IP_IDN_USER_CHANGE_LAST     IN sa.TABLE_JOB.X_IDN_USER_CHANGE_LAST%TYPE,
     op_error_no out varchar2,
     op_error_str out varchar2);

  procedure close_job (
     ip_job_objid      IN number,
     IP_IDN_USER_CHANGE_LAST     IN sa.TABLE_JOB.X_IDN_USER_CHANGE_LAST%TYPE,
     op_error_no out varchar2,
     op_error_str out varchar2);

END CLARIFY_JOB_PKG;
/