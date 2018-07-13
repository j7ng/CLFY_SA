CREATE OR REPLACE PACKAGE sa."NAP_SERVICE_PKG" as
  cursor carrier_curs(c_dealer_id in varchar2,
                      c_x_part_inst_status in varchar2,
                      c_zip in varchar2,
	              c_phone_frequency in varchar2,
	              c_phone_frequency2 in varchar2,
	              c_technology in varchar2,
		      c_sim_part_number in varchar2,
		      c_esn_part_number in varchar2,
	              c_data_capable in varchar2,
		      c_meid_phone in varchar2,
		      c_non_ppe in number,
		      c_unlimited_plan in varchar2,
                      c_bus_org_objid in number,
		      c_dll in number,
                      c_data_speed in number,
		      c_phone_gen in varchar2
	) is
    select * from (
    SELECT /*+ ORDERED */
           ca.objid,
           ca.x_carrier_id,
           ca.x_mkt_submkt_name,
	         ca.x_react_technology,
	         ca.x_act_technology,
           NVL(ca.x_data_service, 0) x_data_service,
           p.x_parent_name,
           p.x_parent_id,
           NVL(p.x_meid_carrier, 0) x_meid_carrier,
           (select (case when cf.X_SWITCH_BASE_RATE is not null then
                           1
                         else
                           0
                         end)  sr
              from table_x_carrier_features cf
             where cf.X_FEATURE2X_CARRIER = ca.objid
               and rownum <2) non_ppe,
           (case when nvl(p.X_NO_INVENTORY,0) = 0
                      and nvl(p.X_NEXT_AVAILABLE,0) = 0
                      and not exists(SELECT 1
                                       FROM sa.x_next_avail_carrier nac
                                      WHERE nac.x_carrier_id = ca.x_carrier_id) then
                   0
                 else
                   1
                 end ) no_inventory_carrier,
           c.x_dealer_id,
           (select bo.org_id
              from table_bus_org bo,
	           table_x_carrier_features cf
             where bo.objid =cf.X_FEATURES2BUS_ORG
	             and cf.X_FEATURE2X_CARRIER = ca.objid
               and cf.x_technology = c_technology
               and cf.X_FEATURES2BUS_ORG = c_bus_org_objid
               and rownum < 2) org_id,
           (select cf.x_data
              from table_x_carrier_features cf
             where 1=1
	             and cf.X_FEATURE2X_CARRIER = ca.objid
               and cf.x_technology = c_technology
               and cf.X_FEATURES2BUS_ORG = c_bus_org_objid
               and cf.x_data = c_data_speed
               and rownum < 2) data_speed,
           (select min(f.x_frequency)||':'||max(f.x_frequency)
              FROM table_x_frequency f,
                   mtm_x_frequency2_x_pref_tech1 f2pt,
                   table_x_pref_tech pt
             WHERE f.objid = f2pt.x_frequency2x_pref_tech
               AND f2pt.x_pref_tech2x_frequency = pt.objid
               AND pt.x_pref_tech2x_carrier = ca.objid) frequency,
           tab1.new_rank,
           tab1.sim_profile,
           tab1.min_dll_exch,
           tab1.max_dll_exch,
           --CR32498_SIM Warranty Exchange Enhancements added below
           sa.is_shippable(tab1.sim_profile) as shippable,
           --CR32498 Ends
           (SELECT count(*)
              FROM table_x_not_certify_models cm,
                   table_part_num pn
             WHERE 1 = 1
               AND cm.X_PARENT_ID = p.x_parent_id
               AND cm.X_PART_CLASS_OBJID = pn.PART_NUM2PART_CLASS
               AND pn.PART_NUMBER = c_esn_part_number
               and rownum <2) not_certified,
           (select cr.x_allow_2g_react
              from table_x_carrier_rules cr
             where cr.objid = decode(c_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                  'GSM' , nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES), ca.CARRIER2RULES)) x_allow_2g_react,
           (select cr.x_allow_2g_act
              from table_x_carrier_rules cr
             where cr.objid = decode(c_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                  'GSM' , nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES), ca.CARRIER2RULES)) x_allow_2g_act,
	   rank() over(partition by ca.objid order by decode(c.x_dealer_id,'DEFAULT',2,1),to_number(tab1.new_rank)) rnk
      FROM
           (SELECT min(to_number(cp.new_rank)) new_rank, b.carrier_id,a.sim_profile,a.min_dll_exch,a.max_dll_exch
              FROM carrierpref cp,
	                 npanxx2carrierzones b,
	     	           (SELECT DISTINCT a.ZONE,
                                    a.st,
                                    s.sim_profile,
                                    a.county,
                                    s.min_dll_exch,
                                    s.max_dll_exch,
				                            s.rank
                               FROM carrierzones a, carriersimpref s
                              WHERE a.zip = c_zip
                                and a.CARRIER_NAME=s.CARRIER_NAME
                                and c_dll between s.MIN_DLL_EXCH and s.MAX_DLL_EXCH
                              order by s.rank asc) a
             WHERE 1=1
               AND cp.st = b.state
               and cp.carrier_id = b.carrier_ID
	             and cp.county = a.county
               AND (   b.cdma_tech = c_technology
                    OR b.gsm_tech  = c_technology )
               and a.sim_profile = decode(c_sim_part_number,null,a.sim_profile,c_sim_part_number)
               AND b.ZONE = a.ZONE
               AND b.state = a.st
             group by b.carrier_id,a.sim_profile,a.min_dll_exch,a.max_dll_exch) tab1,
           table_x_carrierdealer c,
           table_x_carrier ca,
           table_x_carrier_group cg,
           table_x_parent p
     WHERE 1=1
       and not exists (SELECT 1
                         FROM table_x_not_certify_models cm,
                              table_part_num pn
                        WHERE 1 = 1
                          AND cm.X_PARENT_ID = p.x_parent_id
                          AND cm.X_PART_CLASS_OBJID = pn.PART_NUM2PART_CLASS
                          AND pn.PART_NUMBER = c_esn_part_number)
       and exists (select cf.X_FEATURES2BUS_ORG
                     from table_x_carrier_features cf
                    where cf.X_FEATURE2X_CARRIER = ca.objid
                      and cf.x_technology        = c_technology
                      and cf.X_FEATURES2BUS_ORG  = c_bus_org_objid
                      and cf.x_data              = c_data_speed
                      and decode(cf.X_SWITCH_BASE_RATE,null,c_non_ppe,1) = c_non_ppe
	                 union
                   select cf.X_FEATURES2BUS_ORG
                     from table_x_carrier_features cf
                    where cf.X_FEATURE2X_CARRIER in( SELECT c2.objid
                                                       FROM table_x_carrier_group cg2,
					                                          		    table_x_carrier c2
                                                      WHERE cg2.x_carrier_group2x_parent = p.objid
                                                        AND c2.carrier2carrier_group = cg2.objid)
                      and cf.x_technology        = c_technology
                      and cf.X_FEATURES2BUS_ORG  = (select bo.objid
                                                      from table_bus_org bo
                                                     where bo.org_id = 'NET10'
                                                       and bo.objid  = c_bus_org_objid)
                      and cf.x_data              = c_data_speed
                      and decode(cf.X_SWITCH_BASE_RATE,null,c_non_ppe,1) = c_non_ppe )
       AND nvl(c.x_dealer_id,'1') || '' in( nvl(c_dealer_id,'2'),'DEFAULT')
       and c.x_dealer_id = (case when c_dealer_id = '24920' then
	                     '24920'
		            else
			      decode(c.x_dealer_id,'24920','00',c.x_dealer_id)
		            end)
       AND c.x_carrier_id = tab1.carrier_id
       AND ca.x_status || '' = 'ACTIVE'
       AND ca.x_carrier_id = tab1.carrier_id
       AND cg.objid = ca.CARRIER2CARRIER_GROUP
       and p.objid = cg.X_CARRIER_GROUP2X_PARENT
       and exists(select 1
                    FROM table_x_frequency f,
                         mtm_x_frequency2_x_pref_tech1 f2pt,
                         table_x_pref_tech pt
                   WHERE f.objid = f2pt.x_frequency2x_pref_tech
                     AND f.x_frequency + 0 in (c_phone_frequency,c_phone_frequency2)
                     AND f2pt.x_pref_tech2x_frequency = pt.objid
                     AND pt.x_pref_tech2x_carrier = ca.objid)
       and 1 = (case when NVL(p.x_meid_carrier, 0) != 1 and c_meid_phone = 1 then
                       0
                     else
                       1
                     end)
/***********************************************************************************************************
elliot this is your new section
***********************************************************************************************************/
       and 1=(case when c_phone_gen = '2G' then
                       (select count(*)
                         from table_x_carrier_rules cr
                        where (   (    cr.objid = decode(c_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                                       'GSM' , nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES), ca.CARRIER2RULES)
                                   and cr.x_allow_2g_react = '2G'
                                   and NVL(c_x_part_inst_status ,'50') not in ('50','150'))
                               or (    cr.objid = decode(c_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                                        'GSM' , nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES), ca.CARRIER2RULES)
                                   and cr.x_allow_2g_act = '2G'
                                   and NVL(c_x_part_inst_status,'50') in ('50','150')))
                          and rownum < 2)
                     else
                       1
                     end)
/***********************************************************************************************************
elliot this is your new section
***********************************************************************************************************/

       and 1 = (case when nvl(c_x_part_inst_status,'X') in ('50','150') and nvl(upper(ca.x_act_technology),'YES') = 'YES' then
	               1
                     when nvl(c_x_part_inst_status,'X') not in ('50','150') and nvl(upper(ca.x_react_technology),'YES') = 'YES' then
                       1
                     when c_x_part_inst_status is null then
                       1
		     else
                       0
                     end)
       and p.x_parent_id = (case when c_unlimited_plan = 1 then
	                     '74'
		            else
			      decode(p.x_parent_id,'74','00',p.x_parent_id)
		            end))
     where rnk = 1
     order by decode(substr(sim_profile,1,2),'TF',1,2),decode(x_dealer_id,'DEFAULT',2,1),to_number(new_rank);
  type big_rec is record(carrier_info carrier_Curs%rowtype,
                         phone_part_number varchar2(30),
			 same_carrier number,
			 same_zone number,
	                 same_parent number,
                         port1 number,
                         port2 number);
  type big_type is table of big_rec;
  big_tab big_type := big_type();
  big_tab_clear big_type := big_type();
  procedure get_list(
  p_zip             in varchar2,
  p_esn             in varchar2,
  p_esn_part_number in varchar2,
  p_sim             in varchar2,
  p_sim_part_number in varchar2,
  p_site_part_objid in number
);
  procedure coverage_check(
  p_zip             in varchar2,
  p_esn             in varchar2,
  p_outcode         out varchar2);


  PROCEDURE esn_sim_validation_prc( i_esn                 IN VARCHAR2,
                                    i_language            IN VARCHAR2 DEFAULT 'English',
                                    i_sim                 IN VARCHAR2,
                                    i_source              IN VARCHAR2,
                                    o_sim_profile         OUT VARCHAR2,
                                    o_msg                 OUT VARCHAR2
                                  );

  FUNCTION is_esn_sim_compatible ( i_esn          IN    VARCHAR2,
                                   i_esn_part_num IN    VARCHAR2,
                                   i_sim          IN    VARCHAR2,
                                   i_sim_part_num IN    VARCHAR2
                                 )
  RETURN VARCHAR2;
END NAP_SERVICE_PKG;
/