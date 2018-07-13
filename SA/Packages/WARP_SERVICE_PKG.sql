CREATE OR REPLACE PACKAGE sa.warp_service_pkg
/*******************************************************************************************************
  * --$RCSfile: warp_service_pkg.sql,v $
  --$Revision: 1.4 $
  --$Author: mgovindarajan $
  --$Date: 2016/09/19 21:59:16 $
  --$ $Log: warp_service_pkg.sql,v $
  --$ Revision 1.4  2016/09/19 21:59:16  mgovindarajan
  --$ CR44390  - Corrected Error Codes changed and changed parameter access specifier
  --$
  --$ Revision 1.3  2016/09/16 23:12:50  vnainar
  --$ CR44390 added new procedure
  --$
  --$ Revision 1.2  2016/07/26 21:53:52  vnainar
  --$ CR43088 p_deact_service modified and 2 procedures removed
  --$
  --$ Revision 1.1  2016/07/07 22:02:02  smeganathan
  --$ CR43088 new package for warp
  --$
  --$ Revision 1.1  2016/07/07  18:17:25  smeganathan
  --$ New package for WARP
  *
  * -----------------------------------------------------------------------------------------------------
*********************************************************************************************************/
AS
PROCEDURE p_get_phone_type
(
ip_esn		IN  VARCHAR2,
op_phone_type	OUT VARCHAR2,
op_error_code   OUT NUMBER,
op_error_msg	OUT VARCHAR2
);
PROCEDURE p_get_web_user_attributes
(
ip_login_name	        IN  VARCHAR2,
ip_bus_org_id           IN  VARCHAR2,
op_web_user_objid	OUT NUMBER,
op_error_code           OUT NUMBER,
op_error_msg	        OUT VARCHAR2
);
PROCEDURE p_deact_service
(
ip_sourcesystem   IN  VARCHAR2,
ip_esn            IN  VARCHAR2,
ip_web_user_objid IN  NUMBER,
ip_deactreason    IN  VARCHAR2,
op_error_code     OUT VARCHAR2,
op_error_msg      OUT VARCHAR2
);
PROCEDURE p_validate_esn_service_plan  (i_esn               IN  VARCHAR2 ,
                                        i_service_plan_id   IN OUT  VARCHAR2 ,
					o_billing_pgm_objid   OUT  VARCHAR2 ,
                                        o_error_code        OUT VARCHAR2 ,
                                        o_error_msg         OUT VARCHAR2 );
END warp_service_pkg;
/