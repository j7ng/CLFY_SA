CREATE OR REPLACE PACKAGE sa."PROCESS_DMFL_OFFER_PKG"
AS
/*****************************************************************
  * Package Name: process_dmfl_offer (HEADER)
  * Purpose     : To manage the new offer for Double minutes clients
  * Platform    : Oracle 10.2.0.3.0 and newer versions
  * Created by  : Vani Adapa
  * Date        : 06/01/2009
  *
  * Frequency   : All days
  * History
  * REVISIONS    VERSION  DATE        WHO            PURPOSE
  * --------------------------------------------------------------
  *              1.0      06/1/09 VAdapa     Initial Revision
  *                 1.1-2    07/2/09 Icanavan   Remove case creation
  *
  ************************************************************************/
   PROCEDURE main (
      p_esn                IN       VARCHAR2,
      p_cards              IN       VARCHAR2,
      p_offer_units        IN       NUMBER,
      p_offer_days         IN       NUMBER,
      p_sourcesystem       IN       VARCHAR2,
      p_sub_sourcesystem   IN       VARCHAR2,
      p_case_objid         IN       NUMBER,
      p_errorcode          OUT      VARCHAR2,
      p_errormessage       OUT      VARCHAR2
   );
END process_dmfl_offer_pkg;
/