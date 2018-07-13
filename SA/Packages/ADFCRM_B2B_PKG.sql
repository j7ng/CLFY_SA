CREATE OR REPLACE PACKAGE sa."ADFCRM_B2B_PKG"
as
  function isb2bacct (ipv_type varchar2,
                      ipv_value varchar2)
  return varchar2;
end adfcrm_b2b_pkg;
/