CREATE OR REPLACE PACKAGE sa."IGATE_IN3" AS
  ---------------------------------------------------------------------------------------------
  --$RCSfile: IGATE_IN3.sql,v $
  --$Revision: 1.5 $
  --$Author: tpathare $
  --$Date: 2017/11/13 19:21:57 $
  --$ $Log: IGATE_IN3.sql,v $
  --$ Revision 1.5  2017/11/13 19:21:57  tpathare
  --$ New procedure rta_lite added for minimal processing of specific order types.
  --$
  --$ Revision 1.4  2012/01/18 15:47:58  kacosta
  --$ CR18553 IGATE_IN3 Create Sim Exchange
  --$
  --$ Revision 1.3  2011/11/17 15:37:26  pmistry
  --$ Added parameter to run IGATE_IN3 in parallel.
  --$
  ---------------------------------------------------------------------------------------------

  /*================================================================================================================
  | -----------------  ----------  --------  ----------------------------------------------------------------------
  | REVISIONS VERSION  DATE        WHO       PURPOSE
  | -----------------  ----------  --------  ----------------------------------------------------------------------
  | 1.2                12/13/2010  kacosta   CR14297 NET10 CDMA Act_React Rate Plan Check
  |                                          Added debug boolean variable to help with debugging
  ================================================================================================================*/
  -- CR14297 Start kacosta 12/14/2010
  -- Global Package Variables
  --
  l_b_debug BOOLEAN := FALSE;
  -- CR14297 Start kacosta 12/14/2010
  --
  --CR18553 Start KACOSTA 1/17/2011
  --*******************************************************************************
  -- Procedure to create SIM exchange cases for IG_TRANSACTIONS
  --*******************************************************************************
  --
  PROCEDURE sp_ig_create_sim_exchange_case
  (
    p_error_code    OUT INTEGER
   ,p_error_message OUT VARCHAR2
  );
  --CR18553 End KACOSTA 1/17/2011
  --
  procedure rta_in(p_div in number default 1,p_rem in number default 0);

  --CR54061 - New procedure to process order types that do not require complete IN3 processing
  PROCEDURE rta_lite(p_div IN NUMBER DEFAULT 1, p_rem IN NUMBER DEFAULT 0);

END igate_in3;
/