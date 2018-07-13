CREATE OR REPLACE PACKAGE sa."PORT_PKG"

AS
   /********************************************************************************/
   /*    Copyright 2009 Tracfone  Wireless Inc. All rights reserved              */
   /*                                                                              */
   /* NAME:         port_pkg(PACKAGE SPECIFICATION)                                */
   /* PURPOSE:      CR12795                                                        */
   /* FREQUENCY:                                                                   */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                               */
   /* REVISIONS:                                                                   */
   /* VERSION  DATE     WHO        PURPOSE                                         */
   /* ------  ----     ------      --------------------------------------------    */
   /* 1.0    04/07/10  pmistry      Initial  Revision                              */
   /* 1.1    07/07/10  Skuthadi     new i/p sim                                    */
   /* 1.2    02/22/13  ICanavan     CR15434 Port Automation Enhancement Project    */
   /********************************************************************************/
  PROCEDURE complete_port
   ( p_min               IN VARCHAR2,
     p_esn               IN VARCHAR2,
     p_msid              IN VARCHAR2,
     p_sim               IN VARCHAR2,   -- Skuthadi
     p_carrier_id        IN NUMBER,     -- Added for TF/TN on 05/21/10 by pmistry.
     p_case_id           IN VARCHAR2,   -- Added for TF/TN on 05/21/10 by pmistry.
     p_sourcesystem      IN VARCHAR2,   -- Added for TF/TN on 05/21/10 by pmistry.
     p_brand             IN VARCHAR2,   -- Added for TF/TN on 05/21/10 by pmistry.
     p_port_type         IN VARCHAR2,   -- Skuthadi 'Internal or External'
     p_err_num           OUT NUMBER,
     p_err_string        OUT VARCHAR2,
     p_due_date          OUT DATE
    );
/* This procedure is created by Sushanth and added in to Port_pkg by Pmistry on 05/26/2010 */
  PROCEDURE    cancel_port_prc(p_srcesystem        IN VARCHAR2,
                               p_usrobjid          IN VARCHAR2,
                               p_esn               IN VARCHAR2,
                               p_min               IN VARCHAR2,
                               op_return           OUT VARCHAR2,
                               op_returnmsg        OUT VARCHAR2);


  /* -- CR15434 Port Automation Enhancement Project  */
  PROCEDURE getPortCarrierType_prc (
-- *********************************************************
-- Service  getPortCarrierType_Prc
-- Object type:  Procedure
-- Desc: Return all values of the input parameter
--       phone type from table X_PORT_CARRIERS
-- Input parameter:
-- Name IP_PHONE_TYPE Varchar2(30) Values (STREET_TYPE/DIRECTION)
-- Output:
-- Name  OP_CLARIFY_FORMATS SYS_REFCURSOR Components Value
-- How to call:   Getformats_prc ( ip_format_type )
-- *********************************************************
IP_PHONE_TYPE      in varchar2, -- Wireless or Landline
OP_PORT_CARRIERS   out sys_refcursor, -- Carrier Name + External or Internal
op_result          out number,
op_msg             out varchar2 ) ;
--CR39428 IVR External Ports
PROCEDURE check_port_coverage(i_esn                  IN  VARCHAR2 ,
                            i_sim                  IN  VARCHAR2 ,
                            i_brand                IN  VARCHAR2,
                            i_zip_code             IN  VARCHAR2 ,
                            i_source               IN  VARCHAR2 ,
                            o_assign_carr_prnt_id  OUT VARCHAR2 ,
                            o_assign_carr_objid    OUT NUMBER   ,
                            o_assign_carr_id       OUT VARCHAR2 ,
                            o_assign_carr_name     OUT VARCHAR2 ,
                            o_contact_objid        OUT NUMBER   ,
                            o_eligible_flag        OUT VARCHAR2 ,
                            o_elig_failure_reason  OUT VARCHAR2 ,
                            o_err_code             OUT NUMBER   ,
                            o_err_msg              OUT VARCHAR2
                            );

PROCEDURE  ivr_port_close_tkt_prc(i_esn             IN  VARCHAR2,
                                  o_trans_tkt_num   OUT VARCHAR2,
                                  o_err_code        OUT NUMBER  ,
                                  o_err_msg         OUT VARCHAR2
                                  );

PROCEDURE pageplus_port_in_case (i_esn                  in  VARCHAR2 ,
                                 i_min                  in  VARCHAR2 ,
                                 i_iccid                in  VARCHAR2 ,
                                 i_port_in_date         in  DATE     ,
                                 i_port_in_carrier_from in  VARCHAR2 ,
                                 i_rate_plan            in  VARCHAR2 ,
                                 o_error_code           out NUMBER   ,
                                 o_error_message        out VARCHAR2
                                 );

END port_pkg;
/