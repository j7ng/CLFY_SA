CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_SERV_PLAN" AS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_SERV_PLAN_PKB.sql,v $
--$Revision: 1.11 $
--$Author: pkapaganty $
--$Date: 2018/01/11 22:42:08 $
--$ $Log: ADFCRM_SERV_PLAN_PKB.sql,v $
--$ Revision 1.11  2018/01/11 22:42:08  pkapaganty
--$ CR50452 Net 10 Remove Service for Refunds SmartPhone
--$
--$ Revision 1.10  2017/05/11 20:35:14  epaiva
--$ CR47593 Multiple Redemptions
--$
--$
--$ Revision 2.0 2017/05/11  epaiva
--$ CR47593 added condition for VOICE_ONLY in getServPlanInfo
--$
--$ Revision 1.9  2015/04/20 16:19:09  mmunoz
--$ CR32572 Added check for feature SMS in cursor getServPlanInfo
--$
--$ Revision 1.8  2014/11/13 17:33:37  mmunoz
--$ added function getServPlanGroupType
--$
--$ Revision 1.7  2014/11/12 17:25:06  mmunoz
--$ Added procedure getservplangrouptype
--$
--$ Revision 1.6  2014/10/24 15:42:07  mmunoz
--$ CR30527
--$
--------------------------------------------------------------------------------------------

cursor getServPlanInfo (serv_plan_objid in number) is
		select sp_objid, sp_mkt_name,
			fea_value SERVICE_PLAN_GROUP,
			case
			when fea_value = 'PAY_GO' then 'PAYGO'
			when fea_value = 'SL DATA' then 'UNLIMITED'
			when fea_value = 'SL VOICE ONLY' then 'UNLIMITED'
			when fea_value like '%UNLIMITED%' then 'UNLIMITED'
			when fea_value like 'VOICE_ONLY' and
				 nvl(sa.adfcrm_get_serv_plan_value(sp_objid,'VOICE'),'0') in ('0','NA','Unlimited')  and
				 nvl(sa.adfcrm_get_serv_plan_value(sp_objid,'SMS'),'0') in ('0','NA','Unlimited')
				 then 'UNLIMITED'
			when fea_value like '%ONLY%' and
				 nvl(sa.adfcrm_get_serv_plan_value(sp_objid,'VOICE'),'0') in ('0','NA','Unlimited') and
				 nvl(sa.adfcrm_get_serv_plan_value(sp_objid,'DATA'),'0') in ('0','NA') and
				 nvl(sa.adfcrm_get_serv_plan_value(sp_objid,'SMS'),'0') in ('0','NA','Unlimited')
				 then 'UNLIMITED'
			else 'LIMITED'
			end  plan_group
		from sa.adfcrm_serv_plan_feat_matview
		where fea_name = 'SERVICE_PLAN_GROUP'
		and  sp_objid = serv_plan_objid
		ORDER BY sp_objid;

FUNCTION  getfeatures(
   ip_esn IN VARCHAR2,
   ip_plan_objid IN varchar2,
   ip_pin_pclass in varchar2,
   ip_array in sa.varcharArray,
   ip_language in varchar2
)
   RETURN sa.varcharRecList
is
   cursor get_esn_serv_plan (ip_esn in varchar2) is
      select xspsp.x_service_plan_id service_plan_id
      from  sa.table_site_part          sp
           ,sa.x_service_plan_site_part xspsp
      where sp.x_service_id =  ip_esn
      and   sp.part_status in ('Active','CarrierPending')
      and  xspsp.table_site_part_id (+) = sp.objid
      order by sp.install_date desc;
   get_esn_serv_plan_rec get_esn_serv_plan%rowtype;

   cursor get_esn_info(ip_esn varchar2) is
      select pi.part_serial_no esn,
             pn.part_num2part_class part_class_id
      from  table_part_inst pi,
            table_mod_level ml,
            table_part_num pn
      where pi.part_serial_no = ip_esn
      and   pi.x_domain = 'PHONES'
      and   ml.objid = pi.n_part_inst2part_mod
      and   pn.objid = ml.part_info2part_num;
   get_esn_info_rec    get_esn_info%rowtype;

   cursor get_pin_serv_plan_comp(ip_pin_class_name varchar2, ip_esn_class_objid varchar2) is
      select spc_pin.sp_objid service_plan_id, spc_pin.part_class_name
      from sa.adfcrm_serv_plan_class_matview spc_pin,
           sa.adfcrm_serv_plan_feat_matview spf_pin,
           sa.adfcrm_serv_plan_class_matview spc_esn,
           sa.adfcrm_serv_plan_feat_matview spf_esn
      where spc_pin.part_class_name =ip_pin_class_name
      and spf_pin.sp_objid = spc_pin.sp_objid
      and spf_pin.fea_name = 'SERVICE_PLAN_PURCHASE'
      and spc_esn.part_class_objid = ip_esn_class_objid
      and spc_pin.sp_objid = spc_esn.sp_objid
      and spf_esn.sp_objid = spc_esn.sp_objid
      and spf_esn.fea_name = 'SERVICE_PLAN_PURCHASE';

   cursor get_serv_plan(ip_class_name varchar2) is
      select spc.sp_objid service_plan_id, spc.part_class_name
      from sa.adfcrm_serv_plan_class_matview spc,
           sa.adfcrm_serv_plan_feat_matview spf
      where spc.part_class_name =ip_class_name
      and spf.sp_objid = spc.sp_objid
      and spf.fea_name = 'SERVICE_PLAN_PURCHASE';

   get_serv_plan_rec get_serv_plan%rowtype;

   stmt varchar2(4000);
   arrayValues varchar2(4000);
   v_plan_objid varchar2(100);
   vcnt number;
   featureRec  sa.varchar_rec;
   featureList sa.varcharRecList;
   featuresTab varcharRecTable;
begin
  featureList := sa.varcharRecList();
  v_plan_objid := ip_plan_objid;

  if nvl(ip_plan_objid,0) = 0
  then
     if nvl(ip_esn,'empty') = 'empty' and nvl(ip_pin_pclass,'empty') != 'empty'
     then
        --get service plan from pin part class
         open get_serv_plan(ip_pin_pclass);
         fetch get_serv_plan into get_serv_plan_rec;
         if get_serv_plan%found
         then
           v_plan_objid := get_serv_plan_rec.service_plan_id;
         else
           close get_serv_plan;
           return featurelist;
         end if;
         close get_serv_plan;
     else
         if nvl(ip_pin_pclass,'empty') = 'empty'
         then
            --get service plan from  esn
             open get_esn_serv_plan(ip_esn);
             fetch get_esn_serv_plan into get_esn_serv_plan_rec;
             if get_esn_serv_plan%found
             then
               v_plan_objid := get_esn_serv_plan_rec.service_plan_id;
             else
               close get_esn_serv_plan;
               return featurelist;
             end if;
             close get_esn_serv_plan;
        else
             open get_esn_info(ip_esn);
             fetch get_esn_info into get_esn_info_rec;
             close get_esn_info;
             --get service plan from esn and pin compatibility
             open get_pin_serv_plan_comp(ip_pin_pclass,get_esn_info_rec.part_class_id);
             fetch get_pin_serv_plan_comp into get_serv_plan_rec;
             if get_pin_serv_plan_comp%found
             then
               v_plan_objid := get_serv_plan_rec.service_plan_id;
             else
               close get_pin_serv_plan_comp;
               return featurelist;
             end if;
             close get_pin_serv_plan_comp;
        end if;
     end if;
  end if;

  if v_plan_objid is not null
  then
      stmt := 'select fea_name, fea_value '||
              'from sa.adfcrm_serv_plan_feat_matview '||
              'where sp_objid = '||v_plan_objid||' ';

      arrayvalues := '';
      if ip_array is not null
      then

      for i in 1..ip_array.count loop
        --dbms_output.put_line('index= '||i);
        if i = 1 and ip_array.count = 1
        then
            arrayValues := '('''||ip_array(i)||''')';
        else
            if i = 1 then
                arrayValues := '('''||ip_array(i)||'''';
              --dbms_output.put_line('arrayvalues= '||arrayvalues);
              elsif i = ip_array.count then
                   arrayValues := arrayValues||','''||ip_array(i)||''')';
                 --dbms_output.put_line('arrayvalues= '||arrayvalues);
                else
                   arrayValues := arrayValues||','''||ip_array(i)||'''';
               --dbms_output.put_line('arrayvalues= '||arrayvalues);
              end if;
        end if;
        --dbms_output.put_line('values '||arrayValues);
      end loop;
      end if;

      if arrayValues is not null
      then
         stmt := stmt ||
                 'and fea_name in '||arrayValues;
      end if;

      featurestab := varcharrectable();
      dbms_output.put_line('===============================================================================');
      dbms_output.put_line(stmt);
      dbms_output.put_line('===============================================================================');
      execute immediate stmt
          bulk collect into featurestab;
      vcnt := featurestab.count;
      if vcnt > 0
      then
          for i in 1..featurestab.last loop
              featurelist.extend(1);
              featurelist(i) := sa.VARCHAR_REC(featurestab(i).keyname,featurestab(i).keyvalue);
          --dbms_output.put_line(' My element is ='|| featureList(i).KeyName || ', ' ||featureList(i).KeyValue);
          end loop;
      end if;
      vcnt := vcnt + 1;
      featurelist.extend(1);
      featurelist(vcnt) := sa.VARCHAR_REC('SP_OBJID',v_plan_objid);
      vcnt := vcnt + 1;
      featurelist.extend(1);
      featurelist(vcnt) := sa.VARCHAR_REC('SHORT_DESCRIPTION',sa.adfcrm_scripts.get_plan_description(v_plan_objid,ip_language,'TAS'));
	  for rec in (select sp.objid, sp.mkt_name, sp.webcsr_display_name, sp.description, sp.ivr_plan_id, sp.customer_price
                  from sa.x_service_plan sp
                  where objid = v_plan_objid)
      loop
          vcnt := vcnt + 1;
          featurelist.extend(1);
          featurelist(vcnt) := sa.VARCHAR_REC('SP_MKT_NAME',rec.mkt_name);
          vcnt := vcnt + 1;
          featurelist.extend(1);
          featurelist(vcnt) := sa.VARCHAR_REC('SP_WEBCSR_DISPLAY_NAME',rec.webcsr_display_name);
          vcnt := vcnt + 1;
          featurelist.extend(1);
          featurelist(vcnt) := sa.VARCHAR_REC('SP_DESCRIPTION',rec.description);
          vcnt := vcnt + 1;
          featurelist.extend(1);
          featurelist(vcnt) := sa.VARCHAR_REC('SP_IVR_PLAN_ID',rec.ivr_plan_id);
          vcnt := vcnt + 1;
          featurelist.extend(1);
          featurelist(vcnt) := sa.VARCHAR_REC('SP_CUSTOMER_PRICE',rec.customer_price);
      end loop;
  elsif v_plan_objid is null then
          featurelist.extend(1);
          featurelist(1) := sa.VARCHAR_REC('SP_OBJID','');
          featurelist.extend(1);
          featurelist(2) := sa.VARCHAR_REC('SHORT_DESCRIPTION','');
  end if;

  return featurelist;
END getfeatures;

/*****************  GET SERVICE PLAN GROUP TYPE ********************/
procedure getservplangrouptype(
   ip_plan_objid IN varchar2,
   op_sp_mkt_name out varchar2,
   op_feat_sp_group out varchar2,
   op_plan_group out varchar2
) is
	getServPlan_rec  getServPlanInfo%rowtype;
BEGIN
op_sp_mkt_name := '';
op_feat_sp_group := '';
op_plan_group := '';

open getServPlanInfo(to_number(ip_plan_objid));
fetch getServPlanInfo into getServPlan_rec;
close getServPlanInfo;
op_sp_mkt_name := getServPlan_rec.sp_mkt_name;
op_feat_sp_group := getServPlan_rec.SERVICE_PLAN_GROUP;
op_plan_group := getServPlan_rec.plan_group;

END getServPlanGroupType;

function getServPlanGroupType(
   ip_plan_objid  varchar2
) return varchar2 is
	getServPlan_rec  getServPlanInfo%rowtype;
begin
	open getServPlanInfo(to_number(ip_plan_objid));
	fetch getServPlanInfo into getServPlan_rec;
	close getServPlanInfo;

	return getServPlan_rec.plan_group;
end getServPlanGroupType;

FUNCTION getCurrentServPlanGrpIDByESN( in_esn VARCHAR2)
  RETURN VARCHAR2
IS
  CURSOR esn_plan_group (p_esn IN VARCHAR2)
  IS
    SELECT NVL(sa.adfcrm_serv_plan.getServPlanGroupType(spsp.x_service_plan_id),'PAY_GO') plan_group,
      spsp.x_service_plan_id service_plan_id
    FROM sa.table_part_inst pi,
      sa.x_service_plan_site_part spsp
    WHERE pi.part_serial_no     = p_esn
    AND pi.x_domain             = 'PHONES'
    AND spsp.table_site_part_id = pi.x_part_inst2site_part
    ORDER BY spsp.x_last_modified_date DESC;

  esn_plan_group_rec esn_plan_group%rowtype;
  service_plan_id   VARCHAR2(20) := NULL;

BEGIN

  OPEN esn_plan_group(in_esn);
  FETCH esn_plan_group INTO esn_plan_group_rec;
  IF esn_plan_group%found THEN
    service_plan_id := esn_plan_group_rec.service_plan_id;
  END IF;
  CLOSE esn_plan_group;

  RETURN service_plan_id;

END getCurrentServPlanGrpIDByESN;

end;
/