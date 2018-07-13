CREATE OR REPLACE function sa.adfcrm_recover_service_plan (ip_esn in varchar2) return varchar2 is

cursor active_site_part_cur is
select objid,install_date
from table_site_part
where x_service_id = ip_esn
and part_status = 'Active';

active_site_part_rec active_site_part_cur%rowtype;

cursor serv_plan_cur_1 (asp_objid number) is
select X_SERVICE_PLAN_ID
from X_Service_Plan_Site_Part
where Table_Site_Part_Id = asp_objid;

serv_plan_rec_1   serv_plan_cur_1%rowtype;

cursor serv_plan_cur_2 (asp_install_date date) is
select * from X_Service_Plan_Site_Part
where Table_Site_Part_Id in (select objid from table_site_part
                             where x_service_id = ip_esn
                             and part_status = 'Obsolete'
                             and install_date >= asp_install_date - 10/(24*60*60)
                             and install_date <= asp_install_date + 10/(24*60*60) );

serv_plan_rec_2   serv_plan_cur_2%rowtype;

begin

if ip_esn is not null then
   open active_site_part_cur;
   fetch active_site_part_cur into active_site_part_rec;
   if active_site_part_cur%found then

   open serv_plan_cur_1(active_site_part_rec.objid);
   fetch serv_plan_cur_1 into serv_plan_rec_1;
   if serv_plan_cur_1%notfound then
      open serv_plan_cur_2 (active_site_part_rec.install_date) ;
      fetch serv_plan_cur_2 into serv_plan_rec_2;
      if serv_plan_cur_2%found then
          update X_Service_Plan_Site_Part
          set table_site_part_id = active_site_part_rec.objid
          where table_site_part_id = serv_plan_rec_2.table_site_part_id;
          commit;
      end if;
      close serv_plan_cur_2;
   end if;
   close serv_plan_cur_1;
   end if;
   close active_site_part_cur;

end if;

return 'Processed';

end  adfcrm_recover_service_plan;
/