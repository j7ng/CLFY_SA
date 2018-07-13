CREATE OR REPLACE FUNCTION sa."ADFCRM_AWOP_SP_COMPAT_CHECK"
(
  IP_PART_CLASS IN VARCHAR2  --TARGET ESN PART CLASS
, IP_SP_OBJID IN VARCHAR2    --REFERNCE ESN SERVICE PLAN
) RETURN VARCHAR2 AS --Compatible Service Plan Objid Or ERROR Message

CURSOR C1 IS
select distinct sp_objid,sp_mkt_name,sp.ivr_plan_id
from adfcrm_serv_plan_class_matview mv,x_service_plan sp
where mv.sp_objid = sp.objid
and mv.part_class_name = IP_PART_CLASS
and sp.ivr_plan_id in (select sp2.ivr_plan_id
                       from  x_service_plan sp2
                       where sp2.objid= IP_SP_OBJID);

R1 C1%ROWTYPE;
v_return_sp_objid varchar2(30):='NA';

BEGIN

   open c1;
   fetch c1 into r1;
   if c1%found then
      close c1;
      for r2 in c1 loop
         if r2.sp_objid = ip_sp_objid then
            v_return_sp_objid:=ip_sp_objid;
         end if;
      end loop;
      if v_return_sp_objid<>'NA' then
         return v_return_sp_objid;
      else
         return r1.sp_objid;
      end if;
   else
      close c1;
      return 'ERROR: Service Plan not Compatible';
   end if;

exception
  when others then
    return 'ERROR: '||sqlerrm;

end adfcrm_awop_sp_compat_check;
/