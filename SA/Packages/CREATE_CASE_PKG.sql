CREATE OR REPLACE PACKAGE sa."CREATE_CASE_PKG" AS
/**************************************************************************/
/*
/* Purpose: CR3970 - Opens and Closes cases for the 1100 Advanced Exchange
/*
/**************************************************************************/
--
   PROCEDURE sp_create_case (
      p_esn          IN       VARCHAR2,
      p_repl_esn     IN       VARCHAR2,
      p_queue_name   IN       VARCHAR2,
      p_type         IN       VARCHAR2,
      p_title        IN       VARCHAR2,
      p_repl_part    IN       VARCHAR2,
      p_firstname    IN       VARCHAR2,
      p_lastname     IN       VARCHAR2,
      p_address      IN       VARCHAR2,
      p_city         IN       VARCHAR2,
      p_state        IN       VARCHAR2,
      p_zip          IN       VARCHAR2,
      p_tracking     IN       VARCHAR2,
      p_case_objid   OUT      NUMBER,
      p_case_id      OUT      VARCHAR2
   );
--
   PROCEDURE sp_dispatch_case (
      p_case_objid   IN       NUMBER,
      p_queue_name   IN       VARCHAR2,
      p_dummy_out    OUT      NUMBER
   );
--
   PROCEDURE sp_close_case (
      p_case_id           IN    VARCHAR2,
      p_user_login_name   IN    VARCHAR2,
      p_source            IN    VARCHAR2,
      p_resolution_code   IN    VARCHAR2,
      p_status            OUT   VARCHAR2,
      p_msg               OUT   VARCHAR2
   );
--
END create_case_pkg;
/