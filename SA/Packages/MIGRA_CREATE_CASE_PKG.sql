CREATE OR REPLACE PACKAGE sa."MIGRA_CREATE_CASE_PKG" AS
/************************************************************************
*
* Purpose: Migration with Intellitrack - Opens cases
*
*************************************************************************/
--
PROCEDURE sp_create_case (
      p_esn                IN       VARCHAR2,
      p_queue_name         IN       VARCHAR2,
      p_type               IN       VARCHAR2,
      p_title              IN       VARCHAR2,
      p_firstname          IN       VARCHAR2,
      p_lastname           IN       VARCHAR2,
      p_address            IN       VARCHAR2,
      p_city               IN       VARCHAR2,
      p_state              IN       VARCHAR2,
      p_zip                IN       VARCHAR2,
      p_tracking           IN       VARCHAR2,
      p_case_objid        OUT       NUMBER,
      p_case_id           OUT       VARCHAR2
   );
--
PROCEDURE sp_dispatch_case (
      p_case_objid   IN       NUMBER,
      p_queue_name   IN       VARCHAR2,
      p_dummy_out    OUT      NUMBER
   );
--
END migra_create_case_pkg;
/