CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_B2B_PKG"
as
  --------------------------------------------------------------------------------
  function isb2bacct (ipv_type varchar2,
                      ipv_value varchar2)
  return varchar2
  as
    v_out_msg varchar2(30) := 'FALSE';
    v_brand varchar2(30) := '';
    n_err_num number;
    v_err_msg varchar2(30);
    n_is_b2b_rslt number;
    killswich_exists number;
    sqlstmt varchar2(300) := 'begin :a := sa.B2B_PKG.IS_B2B(ip_type => :b, ip_value => :c, ip_brand => :d, op_err_num => :e, op_err_msg => :f); end;';
    f boolean := false;
    procedure dbug_msg(flag boolean, msg varchar2)
    as
    begin
      if flag then
        dbms_output.put_line(msg);
      end if;
    end;
  begin

    select count(*)
    into   killswich_exists
    from   table_x_parameters
    where  x_param_name = 'ADFCRM_B2B_KILLSWITCH';

    dbug_msg(f,'sqlstmt '||sqlstmt);

    if killswich_exists > 0 then
      -- THE BRAND BEING PASSED IS ALWAYS NULL
      -- WE WILL PASS THE X_CUST_ID OR THE ESN WHICH
      -- THE BRAND IS NOT REQUIRED.

      execute immediate sqlstmt using out n_is_b2b_rslt, in ipv_type, in ipv_value, in v_brand, out n_err_num, out v_err_msg;

      dbug_msg(f,'n_err_num ('||n_err_num||')');
      dbug_msg(f,'v_err_msg ('||v_err_msg||')');
      dbug_msg(f,'b2b_rslt 1 = true, 0 = false ('||n_is_b2b_rslt||')');

    else
      dbug_msg(f,'KILLSWITCH IS OFF - NOT CHECKING B2B');
      return v_out_msg;
    end if;

    if n_is_b2b_rslt = 1 then
      v_out_msg := 'TRUE';
    end if;

    return v_out_msg;
  exception
    when others then
      dbug_msg(f,'ISSUE OBTAINING B2B INFORMATION - TREATING AS NON B2B');
      return v_out_msg;
  end isb2bacct;
  --------------------------------------------------------------------------------
end adfcrm_b2b_pkg;
/