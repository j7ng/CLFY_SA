CREATE OR REPLACE function sa.clean_Total_Wireless_device(tot_wireless_esn in varchar2)  return varchar2
is
   V_Esn Varchar2(30) := tot_wireless_esn;

BEGIN

  delete from x_service_order_stage where esn = v_esn;
delete from x_account_group_member where esn = v_esn;
commit;

return('ESN Removed: '||V_Esn);
END;
/