CREATE OR REPLACE PACKAGE sa.APEX_LUTS_PKG
AS
--------------------------------------------------------------------------------------------
--$RCSfile: APEX_LUTS_PKG.sql,v $
--$Revision: 1.5 $
--$Author: mmunoz $
--$Date: 2012/08/30 13:58:02 $
--$ $Log: APEX_LUTS_PKG.sql,v $
--$ Revision 1.5  2012/08/30 13:58:02  mmunoz
--$ CR21806: Functionality for airtime cards was moved to APEX_TOSS_UTIL_PKG
--$
--------------------------------------------------------------------------------------------
  /* TODO enter package declarations (types, exceptions, methods etc) here */
FUNCTION SPLIT(
    p_in_string VARCHAR2,
    p_delim     VARCHAR2)
  RETURN integer_varray;

Function Zero_Zone(
    Ip_State     In Varchar2,
    Ip_Line_Type In varchar2)
    Return zero_zone_array;

function master_inv( Ip_State In Varchar2,
                     Ip_Carr_List in varchar2,
                     print_totals in number default 0 )
 return sa.master_inv_array;
--------------------------------------------------------------------
END APEX_LUTS_PKG;
/