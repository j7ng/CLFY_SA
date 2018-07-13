CREATE OR REPLACE PACKAGE sa."BAU_MAINTENANCE_PKG" IS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: BAU_MAINTENANCE_PKG.sql,v $
  --$Revision: 1.3 $
  --$Author: kacosta $
  --$Date: 2012/07/12 15:42:27 $
  --$ $Log: BAU_MAINTENANCE_PKG.sql,v $
  --$ Revision 1.3  2012/07/12 15:42:27  kacosta
  --$ CR21179 Deactivation Issue/CR21077 Error 119 Active Service Not Found
  --$
  --$ Revision 1.2  2012/06/25 14:27:13  kacosta
  --$ CR21179 Deactivation Issue
  --$
  --$ Revision 1.1  2012/06/15 19:16:46  kacosta
  --$ CR21077 Error 119 Active Service Not Found
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  -- Global Package Variables
  --
  l_b_debug BOOLEAN := FALSE;
  --
  -- Procedures
  --
  --********************************************************************************
  -- Procedure to fix site part for esn
  --********************************************************************************
  --
  PROCEDURE fix_site_part_for_esn
  (
    p_esn           IN sa.table_part_inst.part_serial_no%TYPE
   ,p_error_code    OUT PLS_INTEGER
   ,p_error_message OUT VARCHAR2
  );
  --
  --CR21179 Start kacosta 06/20/2012
  --********************************************************************************
  -- Procedure to fix site part with due dates of 1/1/1753 for an esn
  --********************************************************************************
  --
  PROCEDURE fix_esn_1753_due_dates
  (
    p_esn           IN table_site_part.x_service_id%TYPE
   ,p_error_code    OUT PLS_INTEGER
   ,p_error_message OUT VARCHAR2
  );
  --********************************************************************************
  -- Procedure to site part with due dates of 1/1/1753
  --********************************************************************************
  --
  PROCEDURE fix_1753_due_dates
  (
    p_bus_org_id    IN table_bus_org.org_id%TYPE DEFAULT NULL
   ,p_mod_divisor   IN NUMBER DEFAULT 1
   ,p_mod_remainder IN NUMBER DEFAULT 0
   ,p_error_code    OUT PLS_INTEGER
   ,p_error_message OUT VARCHAR2
  );
  --CR21179 End kacosta 06/20/2012
--
END bau_maintenance_pkg;
/