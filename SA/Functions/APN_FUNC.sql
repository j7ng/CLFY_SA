CREATE OR REPLACE FUNCTION sa.apn_func(p_rate_plan in varchar2,
                                    p_org_id in varchar2) RETURN sa.x_apn_Type IS
  apn_Tab  sa.x_apn_Type := sa.x_apn_Type();
  cursor c1 is
    select dtc.column_name
      from all_tab_columns dtc
     where dtc.table_name = 'X_APN';
    l_val varchar2(300);
BEGIN
  BEGIN
    for c1_rec in c1 LOOP
      l_val := null;
      EXECUTE IMMEDIATE 'select '||c1_rec.column_name||' from sa.x_apn where upper(rate_plan) = upper('''||p_rate_plan||''') and upper(org_id) = upper('''||p_org_id||''')'
      into l_val;
      apn_Tab.Extend;
      apn_Tab(apn_Tab.Last) := x_apn_Row_Type(c1_rec.column_name, l_val);
    END LOOP;
    --CR38213 when no data found
  EXCEPTION
   WHEN OTHERS THEN
      apn_Tab.Extend;
      apn_Tab(apn_Tab.Last) := x_apn_Row_Type(NULL, NULL);
  END;  --CR38213 end
  RETURN apn_Tab;
END;
/