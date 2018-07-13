CREATE OR REPLACE FUNCTION sa."ADD_CLICK_PLAN_FUNC" (
   ip_part_number   IN   VARCHAR2,
   ip_plan_id     IN   VARCHAR2
)
   RETURN BOOLEAN
IS

cursor c1 is
select pn.OBJID
from table_part_num pn
where pn.part_number = ip_part_number
and pn.domain = 'PHONES';

r1 c1%rowtype;

cursor c2 is
select * from table_x_click_plan where x_plan_id = to_number(ip_plan_id);

r2 c2%rowtype;


cursor c3 is
select pn.objid
from table_part_num pn, table_x_click_plan cp
where part_number = ip_part_number
and domain = 'PHONES'
and cp.click_plan2part_num = pn.objid;

r3 c3%rowtype;


pobjid number;
cobjid number;
click_type varchar2(30);

begin

pobjid :=0;
cobjid  :=0;

open c1;
fetch c1 into r1;
if c1%found then
   pobjid := r1.objid;
end if;
close c1;
if pobjid = 0 then
   return false;
end if;

open c2;
fetch c2 into r2;
if c2%found then
   click_type := r2.x_click_type;
   cobjid := r2.objid;

end if;
close c2;

if cobjid = 0 then
   return false;
end if;

open c3;
fetch c3 into r3;
if c3%notfound then

    if click_type not like '%DEFAULT%' then

           INSERT INTO sa.TABLE_X_CLICK_PLAN ( TABLE_X_CLICK_PLAN.OBJID, TABLE_X_CLICK_PLAN.X_PLAN_ID, TABLE_X_CLICK_PLAN.X_CLICK_LOCAL, TABLE_X_CLICK_PLAN.X_CLICK_LD, TABLE_X_CLICK_PLAN.X_CLICK_RL, TABLE_X_CLICK_PLAN.X_CLICK_RLD, TABLE_X_CLICK_PLAN.X_GRACE_PERIOD, TABLE_X_CLICK_PLAN.X_IS_DEFAULT, TABLE_X_CLICK_PLAN.X_STATUS, TABLE_X_CLICK_PLAN.CLICK_PLAN2DEALER, TABLE_X_CLICK_PLAN.CLICK_PLAN2CARRIER, TABLE_X_CLICK_PLAN.X_CLICK_HOME_INTL, TABLE_X_CLICK_PLAN.X_CLICK_IN_SMS, TABLE_X_CLICK_PLAN.X_CLICK_OUT_SMS, TABLE_X_CLICK_PLAN.X_CLICK_ROAM_INTL, TABLE_X_CLICK_PLAN.X_CLICK_TYPE, TABLE_X_CLICK_PLAN.X_GRACE_PERIOD_IN, TABLE_X_CLICK_PLAN.X_HOME_INBOUND, TABLE_X_CLICK_PLAN.X_ROAM_INBOUND, TABLE_X_CLICK_PLAN.CLICK_PLAN2PART_NUM, TABLE_X_CLICK_PLAN.X_BROWSING_RATE, TABLE_X_CLICK_PLAN.X_BUS_ORG, TABLE_X_CLICK_PLAN.X_MMS_INBOUND, TABLE_X_CLICK_PLAN.X_MMS_OUTBOUND, TABLE_X_CLICK_PLAN.X_TECHNOLOGY )
VALUES (sa.seq('x_click_plan'),
       (select max(x_plan_id)+1 from table_x_click_plan),
       r2.X_CLICK_LOCAL, r2.X_CLICK_LD, r2.X_CLICK_RL, r2.X_CLICK_RLD, r2.X_GRACE_PERIOD, r2.X_IS_DEFAULT, r2.X_STATUS, r2.CLICK_PLAN2DEALER, r2.CLICK_PLAN2CARRIER, r2.X_CLICK_HOME_INTL, r2.X_CLICK_IN_SMS, r2.X_CLICK_OUT_SMS, r2.X_CLICK_ROAM_INTL, null, r2.X_GRACE_PERIOD_IN, r2.X_HOME_INBOUND, r2.X_ROAM_INBOUND, pobjid, r2.X_BROWSING_RATE, r2.X_BUS_ORG, r2.X_MMS_INBOUND, r2.X_MMS_OUTBOUND, r2.X_TECHNOLOGY) ;
    commit;

    end if;
end if;
close c3;
return true;

end;
/