CREATE OR REPLACE FUNCTION sa."GET_SUB_BRAND" (ip_esn varchar2)
  return varchar2
  is
    v_sub_brand varchar2(30);
    v_dummy_var varchar2(4000);
  begin
    sa.phone_pkg.get_sub_brand(i_esn => ip_esn,o_sub_brand => v_sub_brand,o_errnum => v_dummy_var,o_errstr => v_dummy_var);
    return v_sub_brand;
  end get_sub_brand;
/