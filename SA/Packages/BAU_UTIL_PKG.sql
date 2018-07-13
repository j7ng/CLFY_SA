CREATE OR REPLACE PACKAGE sa."BAU_UTIL_PKG" AS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: BAU_UTIL_PKG_SPC.sql,v $
  --$Revision: 1.6 $
  --$Author: akuthadi $
  --$Date: 2013/10/18 21:02:20 $
  --$ $Log: BAU_UTIL_PKG_SPC.sql,v $
  --$ Revision 1.6  2013/10/18 21:02:20  akuthadi
  --$ CR#24606 - Added new function get_account_association
  --$
  --$ Revision 1.5  2013/08/22 16:17:52  akuthadi
  --$ new function get_pin_part_class
  --$
  --$ Revision 1.4  2011/10/26 14:37:43  kacosta
  --$ CR17076 NET10 Runtime Promotion
  --$
  --$ Revision 1.2  2011/05/27 15:02:29  kacosta
  --$ CR15158 Added get_esn_brand functions
  --$
  --$ Revision 1.1  2011/04/04 17:07:42  kacosta
  --$ CR15687 ST Updates for My Account Access from WEB
  --$
  ---------------------------------------------------------------------------------------------
  --
  -- Global Package Variables
  --
  l_b_debug BOOLEAN := FALSE;
  --
  -- Public Functions
  --
  --********************************************************************************
  -- Function to retrieve a long column from a table
  --********************************************************************************
  --
  FUNCTION select_from_long_column
  (
    p_table_name  all_tables.table_name%TYPE
   ,p_column_name all_tab_columns.column_name%TYPE
   ,p_rowid       ROWID
  ) RETURN VARCHAR2;
  --
  --********************************************************************************
  -- Function to retrieve the brand of a ESN
  -- Function was created for CR15158
  --********************************************************************************
  --
  FUNCTION get_esn_brand(p_esn table_part_inst.part_serial_no%TYPE) RETURN VARCHAR2;
  --
  --********************************************************************************
  -- Function to retrieve the brand of a ESN
  -- Function was created for CR15158
  --********************************************************************************
  --
  FUNCTION get_esn_brand(p_esn_objid table_part_inst.objid%TYPE) RETURN VARCHAR2;
  --
  --
  --********************************************************************************
  -- Function to retrieve the brand objid of a ESN
  -- Function was created for CR17076
  --********************************************************************************
  --
  FUNCTION get_esn_brand_objid(p_esn table_part_inst.part_serial_no%TYPE) RETURN table_bus_org.objid%TYPE;
  --
  --********************************************************************************
  -- Function to check if a string is a number
  -- Procedure was created for CR15687
  --********************************************************************************
  --
  FUNCTION isnumber(p_char_value VARCHAR2) RETURN NUMBER;
  --
  --********************************************************************************
  -- Function to encrypt password
  -- Procedure was created for CR15687
  --********************************************************************************
  --
  FUNCTION encrypt_password(p_string_to_encrypt IN VARCHAR2) RETURN VARCHAR2;
  --
  --********************************************************************************
  -- Function to decrypt password
  -- Procedure was created for CR15687
  --********************************************************************************
  --
  FUNCTION decrypt_password(p_string_to_decrypt IN VARCHAR2) RETURN VARCHAR2;
  --
  -- Public Procedures
  --
  --********************************************************************************
  -- Procedure to correct active ESN with missing contact
  --********************************************************************************
  --
  PROCEDURE fix_null_active_esn_contact
  (
    p_error_code    OUT PLS_INTEGER
   ,p_error_message OUT VARCHAR2
  );
  --
  FUNCTION get_pin_part_class(in_pin  IN  table_part_inst.x_red_code%TYPE) RETURN table_part_class.NAME%TYPE;
  --
  FUNCTION get_account_association (in_web_user_objid IN NUMBER) RETURN VARCHAR2;
  --
END bau_util_pkg;
/