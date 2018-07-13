CREATE OR REPLACE PACKAGE BODY sa."NAP_SERVICE_PKG" AS
/***************************************************************************************************************
    * Package Name: NAP_SERVICE_PKG
    * Description: This package contains universal queries that all procedure and functions
    *    to use when marring phones with carriers
    *
    * Created by: CL
    * Date:  02/18/2013
    *
    * History
    * -------------------------------------------------------------------------------------------------------------------------------------
    * 02/18/2012         CL                 Initial Version                           	 CR19663
    *******************************************************************************************************************/
  procedure get_list(
  p_zip             in varchar2,
  p_esn             in varchar2,
  p_esn_part_number in varchar2,
  p_sim             in varchar2,
  p_sim_part_number in varchar2,
  p_site_part_objid in number
) is
  cnt number;
  cursor mtm_ordertype_curs(c_trgt in varchar2,
                            c_srce in varchar2) is
  select *
    from MTM_PARENT2PARENT_ORDERTYPE
   where trgt_parent_id = c_trgt
     and srce_parent_id = c_srce;
  mtm_ordertype_rec mtm_ordertype_curs%rowtype;

  cursor zone_info_curs(c_carrier_id            in number,
	                c_old_carrier_id        in number,
                        c_parent_id             in number,
                        c_old_parent_id         in number,
			c_parent_name           in varchar2,
			c_old_parent_name       in varchar2,
			c_new_zip               in varchar2,
                        c_old_zip               in varchar2)
                    is
    select
           (case when c_carrier_id = c_old_carrier_id then
                    1
                 else
                    0
            end) same_carrier,
           (CASE WHEN c_parent_name = 'CINGULAR' AND c_old_parent_name = 'CINGULAR'
                  and exists ( SELECT mkt, rc_number
                                 FROM sa.x_cingular_mrkt_info
                                WHERE zip = c_old_zip INTERSECT
                               SELECT mkt, rc_number
                                 FROM sa.x_cingular_mrkt_info
                                WHERE zip = c_new_zip) then
                   1
                 WHEN c_parent_name like '%SPRINT%' and c_old_parent_name like '%SPRINT%' then
                   1
                 WHEN c_parent_name like '%VERIZON%' and c_old_parent_name like '%VERIZON%' then
                   1
                 WHEN c_parent_name like 'T-MO%' and c_old_parent_name like 'T-MO%' then
                   1
                 WHEN c_parent_id = c_old_parent_id
                  and exists ( SELECT b.state, b.zone
                                FROM npanxx2carrierzones b,carrierzones a
                               WHERE 1 = 1
                                 AND b.carrier_id = c_carrier_id
                                 AND b.state = a.st
                                 AND b.zone = a.zone
                                 AND a.zip = c_new_zip
                              INTERSECT
                              SELECT b.state, b.zone
                                FROM npanxx2carrierzones b, carrierzones a
                               WHERE 1 = 1
                                 AND b.carrier_id = c_old_carrier_id
                                 AND b.state = a.st
                                 AND b.zone = a.zone
                                 AND a.zip = c_old_zip) then
                   1
                 ELSE
                   0
            END ) same_zone,
           (CASE WHEN c_parent_id = c_old_parent_id THEN
                   1
                 ELSE
                   0
            END ) same_parent
      from dual;
  zone_info_rec zone_info_curs%rowtype;
  cursor site_part_curs is
   select sp.objid site_part_objid,
          sp.x_zipcode,
          sp.x_service_id,
          (select s.site_id
             from table_part_inst pi2,
	          table_inv_bin ib,
                  table_site s
            where s.site_id = ib.bin_name
              AND ib.objid = pi2.part_inst2inv_bin
              and pi2.part_serial_no = sp.x_service_id
              and pi2.x_domain = 'PHONES') dealer_id,
          p.x_parent_name,
          p.x_parent_id,
          ca.x_carrier_id,
          ca.objid carrier_objid
     from
	  table_site_part sp,
          table_part_inst pi,
          table_x_carrier ca,
          table_x_carrier_group cg,
          table_x_parent p
    where 1=1
      and sp.objid = p_site_part_objid
      and pi.part_serial_no = sp.x_min
      and ca.objid = pi.part_inst2carrier_mkt
      AND cg.objid = ca.CARRIER2CARRIER_GROUP
      and p.objid  = cg.X_CARRIER_GROUP2X_PARENT;
  site_part_rec site_part_curs%rowtype;
  cursor esn_curs is
    select (select s.site_id
              from table_inv_bin ib,
                   table_site s
             where s.site_id = ib.bin_name
               AND ib.objid = pi.part_inst2inv_bin) dealer_id,
           pi.part_serial_no esn,
           pi.x_part_inst_status,
           pi.objid esn_objid,
           pi.X_ICCID,
           (select count(*)
              from table_part_inst pi_min
             where pi_min.part_to_esn2part_inst = pi.objid
               and pi_min.x_part_inst_status = '37'
               and rownum <2) reserved_line,
           (select count(*)
              from table_part_inst pi_min
             where pi_min.part_to_esn2part_inst = pi.objid
               and pi_min.x_part_inst_status = '39'
               and rownum <2) reserved_used_line,
           (SELECT count(*)
              FROM table_site_part sp_a
             WHERE sp_a.x_service_id = pi.part_serial_no
               AND sp_a.x_refurb_flag = 1
               and rownum <2) x_refurb_flag,
           (select count(*)
              from table_site_part sp
             where sp.x_service_id = pi.part_serial_no
               and sp.part_status = 'Active'
               and rownum <2) is_active,
           (select count(*)
              from table_site_part sp
             where sp.x_service_id = pi.part_serial_no
               and sp.part_status = 'CarrierPending'
               and rownum <2) carrier_pending,
           (SELECT pn2.part_number
              FROM table_x_sim_inv sim,
	           table_mod_level ml,
		   table_part_num pn2
             WHERE 1 = 1
               AND ml.part_info2part_num = pn2.objid
               AND sim.x_sim_inv2part_mod = ml.objid
               AND sim.x_sim_serial_no = p_sim) alt_sim_part_number,
           (SELECT sim.x_sim_inv_status
              FROM table_x_sim_inv sim, table_mod_level ml, table_part_num pn
             WHERE 1 = 1
               AND sim.x_sim_inv2part_mod = ml.objid
               AND ml.part_info2part_num = pn.objid
               AND sim.x_sim_serial_no = pi.x_iccid) sim_part_status,
           (SELECT sim.x_sim_inv_status
              FROM table_x_sim_inv sim, table_mod_level ml, table_part_num pn
             WHERE 1 = 1
               AND sim.x_sim_inv2part_mod = ml.objid
               AND ml.part_info2part_num = pn.objid
               AND sim.x_sim_serial_no = p_sim) alt_sim_part_status,
           (SELECT pn2.part_number
              FROM table_x_sim_inv sim, table_mod_level ml, table_part_num pn2
             WHERE 1 = 1
               AND sim.x_sim_inv2part_mod = ml.objid
               AND ml.part_info2part_num = pn2.objid
               AND sim.x_sim_serial_no = pi.X_ICCID) sim_part_number,
           ml.part_info2part_num part_num_objid,
	   (select s_part_number
              from table_part_num
            where objid = ml.part_info2part_num) esn_part_number
      from
           table_part_inst pi,
           table_mod_level ml
     where 1=1
       AND ml.objid = pi.n_part_inst2part_mod
       AND pi.part_serial_no = p_esn;
  esn_rec esn_curs%rowtype;
  cursor esn_part_num_curs is
    select objid,
           part_number,
           (SELECT pn2.part_number
              FROM table_x_sim_inv sim,
	           table_mod_level ml,
		   table_part_num pn2
             WHERE 1 = 1
               AND ml.part_info2part_num = pn2.objid
               AND sim.x_sim_inv2part_mod = ml.objid
               AND sim.x_sim_serial_no = p_sim) alt_sim_part_number
      from table_part_num
     where S_PART_NUMBER = upper(p_esn_part_number)
       and s_domain = 'PHONES';
  esn_part_num_rec esn_part_num_curs%rowtype;
  cursor esn_part_num_info_curs(p_part_num_objid in number) is
    SELECT /*+ ORDERED */
           pn.part_number esn_part_number,
           pn.x_technology,
	   pn.x_dll,
           NVL(pn.x_meid_phone, 0) x_meid_phone,
           NVL(pn.x_data_capable, 0) x_data_capable,
           nvl((select v.x_param_value
                  from table_x_part_class_values v,
                       table_x_part_class_params n
                 where 1=1
                   and v.value2part_class     = pn.part_num2part_class
                   and v.value2class_param    = n.objid
                   and n.x_param_name         = 'PHONE_GEN'
                   and rownum <2),'2G') phone_gen,
           (select count(*) sr
              from table_x_part_class_values v,
                   table_x_part_class_params n
             where 1=1
               and v.value2part_class     = pn.part_num2part_class
               and v.value2class_param    = n.objid
               and n.x_param_name         = 'UNLIMITED_PLAN'
               and v.x_param_value        = 'NTU'
               and rownum <2) unlimited_plan,
           nvl((select v.x_param_value
                  from table_x_part_class_values v,
                       table_x_part_class_params n
                 where 1=1
                   and v.value2part_class     = pn.part_num2part_class
                   and v.value2class_param    = n.objid
                   and n.x_param_name         = 'DATA_SPEED'
                   and rownum <2),NVL(pn.x_data_capable, 0)) data_speed,
           (select count(*) sr
              from table_x_part_class_values v,
                   table_x_part_class_params n
             where 1=1
               and v.value2part_class     = pn.part_num2part_class
               and v.value2class_param    = n.objid
               and n.x_param_name         = 'NON_PPE'
               and v.x_param_value       in ('0','1')
               and rownum <2) non_ppe,
           (SELECT MAX (DECODE (f.x_frequency, 800, 800, 0)) phone_frequency
              FROM sa.table_x_frequency f,
                   sa.mtm_part_num14_x_frequency0 pf
             WHERE pf.x_frequency2part_num = f.objid
               AND pn.objid = pf.part_num2x_frequency) phone_frequency,
           (SELECT MAX (DECODE (f.x_frequency, 1900, 1900, 0)) phone_frequency2
              FROM sa.table_x_frequency f,
                   sa.mtm_part_num14_x_frequency0 pf
             WHERE pf.x_frequency2part_num = f.objid
               AND pn.objid = pf.part_num2x_frequency) phone_frequency2,
           pn.PART_NUM2BUS_ORG bus_org_objid,
	   (select bo.org_id
              from table_bus_org bo
            where bo.objid = pn.part_num2bus_org) org_id,
           pn.PART_NUM2PART_CLASS
      FROM
           table_part_num pn
     WHERE 1=1
       and pn.objid = p_part_num_objid;
  cursor sim_exists_curs is
    SELECT pn2.part_number
      FROM table_x_sim_inv sim,
           table_mod_level ml,
           table_part_num pn2
     WHERE 1 = 1
       AND ml.part_info2part_num = pn2.objid
       AND sim.x_sim_inv2part_mod = ml.objid
       AND sim.x_sim_serial_no = p_sim;
  sim_exists_rec sim_exists_curs%rowtype;
  cursor sim_exists2_curs is
    SELECT pn2.part_number
      FROM table_part_num pn2
     WHERE 1 = 1
       AND pn2.part_number = p_sim_part_number;
  sim_exists2_rec sim_exists2_curs%rowtype;
  cursor port_curs(c_old_carrier_objid in number,
                   c_new_carrier_objid in number) is
    select
           (CASE WHEN c_old_carrier_objid = c_new_carrier_objid
                  AND p2.x_status = 'ACTIVE' THEN
                   1
                 WHEN p2.x_block_port_in = 0 THEN
                   1
                 WHEN p1.x_auto_port_out = 1
                  AND p2.x_block_port_in = 1
                  AND p2.x_auto_port_in = 1 THEN
                   1
                 WHEN p1.x_auto_port_out = 2
                  AND p2.x_block_port_in = 1
                  AND p2.x_auto_port_in = 2 THEN
                   1
                 ELSE
                   0
                 END) port1,
           (CASE WHEN p1.x_auto_port_out = 0
                  and p2.x_block_port_in = 0
                  AND p2.x_auto_port_in IN (0, 1, 2) THEN
                   1
                 when p1.x_auto_port_out = 1
                  and p2.x_block_port_in = 0
                  AND p2.x_auto_port_in IN (0, 2) THEN
                   1
                 when p1.x_auto_port_out = 2
                  and p2.x_block_port_in = 0
                  AND p2.x_auto_port_in IN (0, 1) THEN
                   1
                 ELSE
                   0
                 END) port2
      from
           (select NVL (p.x_auto_port_out, 0) x_auto_port_out
              FROM table_x_parent p,
                   table_x_carrier_group cg,
                   TABLE_X_CARRIER c
             where 1=1
               and c.objid = c_old_carrier_objid
               AND cg.objid = c.carrier2carrier_group
               and p.objid = cg.x_carrier_group2x_parent
               and rownum <2) p1,
           (select c.x_status,
                   p.x_block_port_in,
                   p.x_auto_port_in
              FROM table_x_parent p,
                   table_x_carrier_group cg,
                   TABLE_X_CARRIER c
             where 1=1
               and c.objid = c_new_carrier_objid
               AND cg.objid = c.carrier2carrier_group
               and p.objid = cg.x_carrier_group2x_parent
               and rownum <2) p2;
  port_rec port_curs%rowtype;
  l_esn_part_number_objid number;
  l_sim_part_number varchar2(30);
  begin
	big_tab := big_tab_clear;
  if p_sim is not null then
    open sim_exists_curs;
      fetch sim_exists_curs into sim_exists_rec;
      if sim_exists_curs%notfound then
        dbms_output.put_line('p_sim does not exist continue as blank------------------------------------------------');
        dbms_output.put_line('p_sim does not exist continue as blank------------------------------------------------');
        dbms_output.put_line('p_sim:'||p_sim);
      end if;
    close sim_exists_curs;
  elsif p_sim_part_number is not null then
    open sim_exists2_curs;
      fetch sim_exists2_curs into sim_exists2_rec;
      if sim_exists2_curs%notfound then
        dbms_output.put_line('p_sim_part_number does not exist---------------------------');
        dbms_output.put_line('p_sim_part_number does not exist---------------------------');
        dbms_output.put_line('p_sim_part_number:'||p_sim_part_number);
      end if;
    close sim_exists2_curs;
  end if;
  if p_site_part_objid is not null then
    open site_part_curs;
      fetch site_part_curs into site_part_rec;
      if site_part_curs%notfound then
        dbms_output.put_line('site_part does not exists continue with p_site_part_objid as NULL');
      else
        dbms_output.put_line('site_part_rec.x_zipcode:'||site_part_rec.x_zipcode);
        dbms_output.put_line('site_part_rec.x_parent_name:'||site_part_rec.x_parent_name);
        dbms_output.put_line('site_part_rec.x_parent_id:'||site_part_rec.x_parent_id);
        dbms_output.put_line('site_part_rec.x_carrier_id:'||site_part_rec.x_carrier_id);
        dbms_output.put_line('site_part_rec.carrier_objid:'||site_part_rec.carrier_objid);
        dbms_output.put_line('site_part_rec.x_service_id:'||site_part_rec.x_service_id);
        dbms_output.put_line('site_part_rec.dealer_id:'||site_part_rec.dealer_id);
      end if;
    close site_part_curs;
  end if;
  if p_esn is not null then
    open esn_curs;
      fetch esn_curs into esn_rec;
      if esn_curs%notfound then
        close esn_curs;
        dbms_output.put_line('esn is not valid');
        return;
      end if;
      dbms_output.put_line('esn info-------------------------------------------------------------------');
      dbms_output.put_line('esn info-------------------------------------------------------------------');
      dbms_output.put_line('esn_rec.esn:'||esn_rec.esn);
      dbms_output.put_line('esn_rec.is_active:'||esn_rec.is_active);
      dbms_output.put_line('esn_rec.carrier_pending:'||esn_rec.carrier_pending);
      dbms_output.put_line('esn_rec.x_part_inst_status:'||esn_rec.x_part_inst_status);
      dbms_output.put_line('esn_rec.X_ICCID:'||esn_rec.X_ICCID);
      dbms_output.put_line('esn_rec.dealer_id:'||esn_rec.dealer_id);
      dbms_output.put_line('esn_rec.part_num_objid:'||esn_rec.part_num_objid);
      dbms_output.put_line('esn_rec.esn_part_number:'||esn_rec.esn_part_number);
      dbms_output.put_line('esn_rec.reserved_line:'||esn_rec.reserved_line);
      dbms_output.put_line('esn_rec.reserved_used_line:'||esn_rec.reserved_used_line);
      dbms_output.put_line('esn_rec.alt_sim_part_number:'||esn_rec.alt_sim_part_number);
      dbms_output.put_line('esn_rec.alt_sim_part_status:'||esn_rec.alt_sim_part_status);
      l_esn_part_number_objid := esn_rec.part_num_objid;
      l_sim_part_number := nvl(esn_rec.alt_sim_part_number,p_sim_part_number);
    close esn_curs;
  elsif p_esn_part_number is not null then
    open esn_part_num_curs;
      fetch esn_part_num_curs into esn_part_num_rec;
      if esn_part_num_curs%notfound then
        close esn_part_num_curs;
        dbms_output.put_line('part_number is not valid');
        return;
      end if;
      dbms_output.put_line('part number objid-------------------------------------------------------------------');
      dbms_output.put_line('part number objid-------------------------------------------------------------------');
      dbms_output.put_line('esn_part_num_rec.objid:'||esn_part_num_rec.objid);
      dbms_output.put_line('esn_part_num_rec.part_number:'||esn_part_num_rec.part_number);
      dbms_output.put_line('esn_part_num_rec.alt_sim_part_number:'||esn_part_num_rec.alt_sim_part_number);
      l_esn_part_number_objid := esn_part_num_rec.objid;
      l_sim_part_number := nvl(esn_part_num_rec.alt_sim_part_number,p_sim_part_number);
    close esn_part_num_curs;
  else
    dbms_output.put_line('p_esn and p_esn_part_number are both null');
    return;
  end if;
  dbms_output.put_line('p_zip:'||p_zip);
  for esn_part_num_info_rec in esn_part_num_info_curs(l_esn_part_number_objid) loop
    dbms_output.put_line('esn part num info-------------------------------------------------------------------');
    dbms_output.put_line('esn part num info-------------------------------------------------------------------');
    dbms_output.put_line('esn_part_num_info_rec.part_num2part_class:'||esn_part_num_info_rec.part_num2part_class);
    dbms_output.put_line('esn_part_num_info_rec.x_dll:'||esn_part_num_info_rec.x_dll);
    dbms_output.put_line('esn_part_num_info_rec.phone_frequency:'||esn_part_num_info_rec.phone_frequency);
    dbms_output.put_line('esn_part_num_info_rec.phone_frequency2:'||esn_part_num_info_rec.phone_frequency2);
    dbms_output.put_line('esn_part_num_info_rec.x_technology:'||esn_part_num_info_rec.x_technology);
    dbms_output.put_line('esn_part_num_info_rec.non_ppe:'||esn_part_num_info_rec.non_ppe);
    dbms_output.put_line('esn_part_num_info_rec.x_meid_phone:'||esn_part_num_info_rec.x_meid_phone);
    dbms_output.put_line('esn_part_num_info_rec.x_data_capable:'||esn_part_num_info_rec.x_data_capable);
    dbms_output.put_line('esn_part_num_info_rec.data_speed:'||esn_part_num_info_rec.data_speed);
    dbms_output.put_line('esn_part_num_info_rec.bus_org_objid:'||esn_part_num_info_rec.bus_org_objid);
    dbms_output.put_line('esn_part_num_info_rec.org_id:'||esn_part_num_info_rec.org_id);
    dbms_output.put_line('esn_part_num_info_rec.unlimited_plan:'||esn_part_num_info_rec.unlimited_plan);
    dbms_output.put_line('esn_part_num_info_rec.phone_gen:'||esn_part_num_info_rec.phone_gen);
    for carrier_rec in carrier_curs(esn_rec.dealer_id,
	                            esn_rec.x_part_inst_status,
                                    p_zip,
                                    esn_part_num_info_rec.phone_frequency,
                                    esn_part_num_info_rec.phone_frequency2,
                                    esn_part_num_info_rec.x_technology,
                                    l_sim_part_number,
                                    esn_part_num_info_rec.esn_part_number,
                                    esn_part_num_info_rec.x_data_capable,
                                    esn_part_num_info_rec.x_meid_phone,
                                    esn_part_num_info_rec.non_ppe,
                                    esn_part_num_info_rec.unlimited_plan,
                                    esn_part_num_info_rec.bus_org_objid,
                                    esn_part_num_info_rec.x_dll ,
                                    esn_part_num_info_rec.data_speed,
				    esn_part_num_info_rec.phone_gen
			) loop
      dbms_output.put_line('carrier info-------------------------------------------------------------------');
      dbms_output.put_line('carrier info-------------------------------------------------------------------');
      dbms_output.put_line('carrier_rec.x_carrier_id:'||carrier_rec.x_carrier_id);
      dbms_output.put_line('carrier_rec.objid:'||carrier_rec.objid);
      dbms_output.put_line('carrier_rec.x_parent_name:'||carrier_rec.x_parent_name);
      dbms_output.put_line('carrier_rec.x_parent_id:'||carrier_rec.x_parent_id);
      dbms_output.put_line('carrier_rec.no_inventory_carrier:'||carrier_rec.no_inventory_carrier);
      dbms_output.put_line('carrier_rec.x_react_technology:'||carrier_rec.x_react_technology);
      dbms_output.put_line('carrier_rec.x_act_techonlogy:'||carrier_rec.x_act_technology);
      dbms_output.put_line('carrier_rec.x_data_service:'||carrier_rec.x_data_service);
      dbms_output.put_line('carrier_rec.data_speed:'||carrier_rec.data_speed);
      dbms_output.put_line('carrier_rec.x_meid_carrier:'||carrier_rec.x_meid_carrier);
      dbms_output.put_line('carrier_rec.non_ppe:'||carrier_rec.non_ppe);
      dbms_output.put_line('carrier_rec.x_dealer_id:'||carrier_rec.x_dealer_id);
      dbms_output.put_line('carrier_rec.new_rank:'||carrier_rec.new_rank);
      dbms_output.put_line('carrier_rec.org_id:'||carrier_rec.org_id);
      dbms_output.put_line('carrier_rec.sim_profile:'||carrier_rec.sim_profile);
      dbms_output.put_line('carrier_rec.min_dll_exch:'||carrier_rec.min_dll_exch);
      dbms_output.put_line('carrier_rec.max_dll_exch:'||carrier_rec.max_dll_exch);
      dbms_output.put_line('carrier_rec.frequency:'||carrier_rec.frequency);
      dbms_output.put_line('carrier_rec.not_certified:'||carrier_rec.not_certified);
      dbms_output.put_line('carrier_rec.rnk:'||carrier_rec.rnk);
      dbms_output.put_line('carrier_rec.x_allow_2g_act:'||carrier_rec.x_allow_2g_act);
      dbms_output.put_line('carrier_rec.x_allow_2g_react:'||carrier_rec.x_allow_2g_react);
      dbms_output.put_line('carrier_rec.new_rank:'||carrier_rec.new_rank);
--      if site_part_rec.site_part_objid is not null then
        big_tab.extend;
        cnt := big_tab.count;
        dbms_output.put_line('cnt:'||cnt);
        big_tab(cnt).carrier_info := carrier_rec;
      	big_tab(cnt).phone_part_number := esn_part_num_info_rec.esn_part_number;
/*
        open mtm_ordertype_curs(carrier_rec.x_parent_id, site_part_rec.x_parent_id);
          fetch  mtm_ordertype_curs into mtm_ordertype_rec;
          if mtm_ordertype_curs%found then
            dbms_output.put_line('ESN EXCHANGE');
          end if;
        close mtm_ordertype_curs;
            open zone_info_curs(carrier_rec.x_carrier_id,
  	                        site_part_rec.x_carrier_id,
                            carrier_rec.x_parent_id,
                            site_part_rec.x_parent_id,
                            carrier_rec.x_parent_name,
                            site_part_rec.x_parent_name,
                            p_zip,
                            site_part_rec.x_zipcode);
              fetch zone_info_curs into big_tab(cnt).same_carrier,big_tab(cnt).same_zone,big_tab(cnt).same_parent;
              dbms_output.put_line('same carrier:'||big_tab(cnt).same_carrier);
              dbms_output.put_line('same zone:'||big_tab(cnt).same_zone);
              dbms_output.put_line('same parent:'||big_tab(cnt).same_parent);
            close zone_info_curs;

            open port_curs(site_part_rec.carrier_objid,
                       carrier_rec.objid);
      	      fetch port_curs into big_tab(cnt).port1,big_tab(cnt).port2;
              dbms_output.put_line('port1:'||big_tab(cnt).port1);
              dbms_output.put_line('port2:'||big_tab(cnt).port2);
              if big_tab(cnt).port1 = 1 and big_tab(cnt).port2 = 1 then
                dbms_output.put_line('MANUAL PORT');
              elsif big_tab(cnt).port1 = 1 and big_tab(cnt).port2 = 0 then
                dbms_output.put_line('AUTO PORT');
              else
                dbms_output.put_line('PORT NOT ALLOWED');
                big_tab.delete(cnt);
              end if;
            close port_curs;
*/
 --         end if;
    end loop;
  end loop;
  if big_tab.count>0 then
    for i in big_tab.first .. big_tab.last loop
      dbms_output.put_line(big_tab(i).carrier_info.x_parent_name);
      dbms_output.put_line(big_tab(i).carrier_info.sim_profile);
      dbms_output.put_line(big_tab(i).same_carrier);
      dbms_output.put_line(big_tab(i).same_zone);
      dbms_output.put_line(big_tab(i).same_parent);
    end loop;
  end if;
  END;
  procedure coverage_check(
  p_zip             in varchar2,
  p_esn             in varchar2,
  p_outcode         out varchar2) is
  begin
    nap_SERVICE_pkg.get_list(
        p_zip,
        p_esn,
        null,
        null,
        null,
        null);
    if nap_SERVICE_pkg.big_tab.count>0 then
      dbms_output.put_line('has coverage');
      p_outcode := 'YES';
    else
      dbms_output.put_line('does not has coverage');
      p_outcode := 'NO';
    end if;
  exception when others then
    p_outcode := 'NO';
  end;

  --CR56825 changes start
  PROCEDURE esn_sim_validation_prc( i_esn                 IN VARCHAR2,
                                    i_language            IN VARCHAR2 DEFAULT 'English',
                                    i_sim                 IN VARCHAR2,
                                    i_source              IN VARCHAR2,
                                    o_sim_profile         OUT VARCHAR2,
                                    o_msg                 OUT VARCHAR2
                                  )
  IS
    c_esn_sim_compatible  VARCHAR2(2000);
    l_language varchar2(50);
    err_msg varchar2(200);

    CURSOR technology_curs ( c_esn VARCHAR2 )
    IS
     SELECT pn.*,
            pi.x_part_inst_status
       FROM table_part_num pn,
            table_mod_level ml,
            table_part_inst pi
      WHERE 1 = 1
        AND pn.objid = ml.part_info2part_num
        AND ml.objid = pi.n_part_inst2part_mod
        AND pi.part_serial_no = c_esn;
    technology_rec technology_curs%ROWTYPE;

    CURSOR valid_cdma_lte_curs
    IS
      SELECT (SELECT count(*)
                FROM table_part_inst pi
               WHERE pi.x_iccid = si.x_sim_serial_no
                 AND pi.x_part_inst_status = '52'
                 AND pi.part_serial_no != i_esn) others_active,
              si.x_sim_inv_status
        FROM  sa.table_x_sim_inv si
       WHERE  si.x_sim_serial_no = i_sim
         AND  si.x_sim_inv_status not in ('252','255','250');
    valid_cdma_lte_rec valid_cdma_lte_curs%ROWTYPE;

    FUNCTION gsm_is_iccid_valid4react_fun RETURN VARCHAR2
    IS
      CURSOR c_gsm_grace_time( c_carrier_objid IN NUMBER )
      IS
        SELECT cr.x_gsm_grace_period
          FROM table_x_carrier_rules cr, table_x_carrier c
         WHERE cr.objid = c.CARRIER2RULES_gsm
           AND c.objid = c_carrier_objid;
      c_gsm_grace_time_rec c_gsm_grace_time%ROWTYPE;

      CURSOR last_deact_date_curs_by_sim
      IS
        SELECT sp.service_end_dt last_deact_date,
               sp.install_date,
               sp.x_zipcode,
               (SELECT pi_min.part_inst2carrier_mkt
                  FROM table_part_inst pi_min
                 WHERE pi_min.part_serial_no = sp.x_min
                   AND pi_min.x_domain         = 'LINES'
               ) carrier_objid
          FROM table_part_inst pi,
               table_site_part sp
         WHERE 1  =  1
           AND pi.x_iccid      = i_sim
           AND sp.x_service_id = pi.part_serial_no
           AND sp.x_iccid      = i_sim
           AND sp.part_status IN ('Active','Inactive','CarrierPending')
        ORDER BY sp.install_date;

      CURSOR last_deact_date_cur_by_esn_sim
      IS
        SELECT sp.service_end_dt last_deact_date,
               sp.install_date,
               sp.x_zipcode,
               (SELECT pi_min.part_inst2carrier_mkt
                  FROM table_part_inst pi_min
                 WHERE pi_min.part_serial_no = sp.x_min
                   AND pi_min.x_domain         = 'LINES'
               ) carrier_objid
          FROM table_site_part sp
         WHERE 1             =1
           AND sp.x_service_id = i_esn
           AND sp.x_iccid      = i_sim
           AND sp.part_status IN ('Active','Inactive','CarrierPending')
         ORDER BY install_date DESC;

      CURSOR last_deact_date_curs_by_esn
      IS
        SELECT sp.service_end_dt last_deact_date,
               sp.install_date,
               sp.x_zipcode,
               (SELECT pi_min.part_inst2carrier_mkt
                  FROM table_part_inst pi_min
                 WHERE pi_min.part_serial_no = sp.x_min
                   AND pi_min.x_domain         = 'LINES'
               ) carrier_objid
          FROM table_site_part sp
         WHERE 1             =1
           AND sp.x_service_id = i_esn
           AND sp.part_status IN ('Active','Inactive','CarrierPending')
         ORDER BY install_date DESC;
      last_deact_date_rec last_deact_date_curs_by_esn%ROWTYPE;

      CURSOR sim_curs
      IS
        SELECT si.X_SIM_SERIAL_NO,
               si.X_SIM_INV_STATUS,
               pn.part_number
          FROM sa.table_x_sim_inv si,
               table_mod_level ml,
               table_part_num pn
         WHERE si.X_SIM_SERIAL_NO = i_sim
           AND ml.objid             = si.x_sim_inv2part_mod
           AND pn.objid             = ml.part_info2part_num;
      sim_rec sim_curs%ROWTYPE;

      CURSOR esn_sim_curs
      IS
        SELECT pn.x_technology,
               pn.x_dll,
               pi.x_iccid sim,
               pn.part_number
          FROM table_part_inst pi,
               table_mod_level ml,
               table_part_num pn
         WHERE pi.part_serial_no = i_esn
           AND pi.x_domain         = 'PHONES'
           AND ml.objid            = pi.n_part_inst2part_mod
           AND pn.objid            = ml.part_info2part_num;
      esn_sim_rec esn_sim_curs%ROWTYPE;
    --begin of gsm_is_iccid_valid4react_fun
    BEGIN
      DBMS_OUTPUT.put_line('4react func');

      OPEN sim_curs;
      FETCH sim_curs INTO sim_rec;

      IF sim_curs%NOTFOUND
      THEN
        CLOSE sim_curs;
        RETURN 'SIM Exchange-ICCID profile not valid';
      END IF;

      dbms_output.put_line('sim_rec.x_sim_inv_status:'||sim_rec.x_sim_inv_status);
      CLOSE sim_curs;

      OPEN esn_sim_curs;
      FETCH esn_sim_curs INTO esn_sim_rec;

      IF esn_sim_curs%NOTFOUND
      THEN
        DBMS_OUTPUT.put_line('esn_sim_curs%notfound');
        CLOSE esn_sim_curs;
        RETURN 'SIM Exchange-ICCID profile not valid';
      ELSE
        DBMS_OUTPUT.put_line('esn_sim_rec.sim:'||esn_sim_rec.sim);
        DBMS_OUTPUT.put_line('i_sim:'||i_sim);
        CLOSE esn_sim_curs;
      END IF;

      OPEN last_deact_date_cur_by_esn_sim;
      FETCH last_deact_date_cur_by_esn_sim INTO last_deact_date_rec;

      IF last_deact_date_cur_by_esn_sim%NOTFOUND
      THEN
        OPEN last_deact_date_curs_by_sim;
        FETCH last_deact_date_curs_by_sim INTO last_deact_date_rec;

        IF last_deact_date_curs_by_sim%NOTFOUND
        THEN
          OPEN last_deact_date_curs_by_esn;
          FETCH last_deact_date_curs_by_esn INTO last_deact_date_rec;

          IF last_deact_date_curs_by_esn%NOTFOUND
          THEN
            CLOSE last_deact_date_curs_by_esn;
            CLOSE last_deact_date_cur_by_esn_sim;
            CLOSE last_deact_date_curs_by_sim;
            RETURN 'SIM Exchange-ICCID profile not valid';
          END IF;

          CLOSE last_deact_date_curs_by_esn;
        END IF;
        CLOSE last_deact_date_curs_by_sim;
      END IF;
      CLOSE last_deact_date_cur_by_esn_sim;

      OPEN c_gsm_grace_time (last_deact_date_rec.carrier_objid);
      FETCH c_gsm_grace_time INTO c_gsm_grace_time_rec;

      DBMS_OUTPUT.put_line('(SYSDATE - last_deact_date_rec.last_deact_date):'||(SYSDATE - last_deact_date_rec.last_deact_date));
      DBMS_OUTPUT.put_line('c_gsm_grace_time_rec.x_gsm_grace_period:'||c_gsm_grace_time_rec.x_gsm_grace_period);

      IF c_gsm_grace_time%FOUND
        AND (SYSDATE - last_deact_date_rec.last_deact_date) > c_gsm_grace_time_rec.x_gsm_grace_period
      THEN
        DBMS_OUTPUT.put_line('sim expired');
        CLOSE c_gsm_grace_time;
        RETURN 'SIM Exchange-ICCID Expired';
      END IF;

      CLOSE c_gsm_grace_time;
      RETURN NULL;
    END gsm_is_iccid_valid4react_fun;

    FUNCTION gsm_is_a_react_fun
    RETURN BOOLEAN
    IS
      CURSOR c_is_new
      IS
        SELECT 'X' col1
        FROM table_part_inst
        WHERE part_serial_no = i_esn
        AND x_domain = 'PHONES'
        AND x_part_inst_status || '' IN ('50', '150');
      c_is_new_rec c_is_new%ROWTYPE;

      l_return_value BOOLEAN := FALSE;
    --Begin of gsm_is_a_react_fun
    BEGIN
      OPEN c_is_new;
      FETCH c_is_new INTO c_is_new_rec;

      IF c_is_new%FOUND
      THEN
         l_return_value := FALSE;
      ELSE
         l_return_value := TRUE;
      END IF;

      CLOSE c_is_new;
      RETURN l_return_value;
    END gsm_is_a_react_fun;

    FUNCTION gsm_is_valid_iccid_fun RETURN VARCHAR2
    IS
      CURSOR c_sim_status
      IS
        SELECT pn.part_number,
               sim.x_sim_mnc,
               sim.x_sim_inv_status
          FROM table_x_sim_inv sim,
               table_mod_level ml,
               table_part_num pn
         WHERE 1 = 1
           AND sim.x_sim_inv2part_mod = ml.objid
           AND ml.part_info2part_num = pn.objid
           AND sim.x_sim_serial_no = i_sim;
      c_sim_status_rec c_sim_status%ROWTYPE;

      CURSOR c_is_sim_married
      IS
        SELECT part_serial_no
          FROM table_part_inst
         WHERE x_iccid = i_sim
           and part_serial_no = i_esn;
      c_is_sim_married_rec c_is_sim_married%ROWTYPE;

      l_sim_mnc_cnt NUMBER := 0;
    --Begin of gsm_is_valid_iccid_fun
    BEGIN
      OPEN c_sim_status;
      FETCH c_sim_status  INTO c_sim_status_rec;

      IF c_sim_status%NOTFOUND
      THEN
        CLOSE c_sim_status;
        RETURN 'SIM Exchange-ICCID profile not valid';
      END IF;

      CLOSE c_sim_status;

      o_sim_profile := c_sim_status_rec.part_number;

      IF c_sim_status_rec.x_sim_inv_status IN ('251', '253')
      THEN
        NULL;
      ELSIF c_sim_status_rec.x_sim_inv_status ='254'
      THEN
        OPEN c_is_sim_married;
        FETCH c_is_sim_married INTO c_is_sim_married_rec;

        IF c_is_sim_married%NOTFOUND
        THEN
             DBMS_OUTPUT.put_line('c_is_sim_married%NOTFOUND' );
             CLOSE c_is_sim_married;
             RETURN 'SIM Exchange-ICCID is already attached to an IMEI';
        END IF;
        CLOSE c_is_sim_married;
      ELSE
        DBMS_OUTPUT.put_line('BAD SIM STATUS:'|| c_sim_status_rec.x_sim_inv_status);
        RETURN 'SIM Exchange-ICCID status is invalid';
      END IF;

      RETURN 'SUCCESS';
    END gsm_is_valid_iccid_fun;

    FUNCTION check_line_locks_fun
    RETURN BOOLEAN
    IS
      CURSOR c_cell_num
      IS
        SELECT lines.objid,
               lines.part_serial_no,
               lineparent.x_parent_name line_parent_name,
               lines.x_part_inst_status line_status,
               lines.x_port_in,
               lines.part_inst2carrier_mkt,
               NVL(lineparent.x_no_msid, 0) x_no_msid
          FROM table_part_inst lines,
               table_part_inst phones,
               table_x_parent lineparent,
               table_x_carrier_group linegroup,
               table_x_carrier linecarrier
         WHERE lines.x_domain                   = 'LINES'
           AND lines.part_to_esn2part_inst        = phones.objid
           AND lines.part_inst2carrier_mkt        = linecarrier.objid
           AND linecarrier.carrier2carrier_group  = linegroup.objid
           AND linegroup.x_carrier_group2x_parent = lineparent.objid
           AND lines.x_part_inst_status          IN ('37', '39', '73', '110')
           AND phones.x_domain                    = 'PHONES'
           AND phones.part_serial_no              = i_esn;
      c_cell_num_rec c_cell_num%ROWTYPE;

      -- Begin of check_line_locks_fun
    BEGIN
      OPEN c_cell_num;
      FETCH c_cell_num INTO c_cell_num_rec;

      IF    c_cell_num%FOUND
        AND (c_cell_num_rec.line_status != '110' OR c_cell_num_rec.x_no_msid != 1)
      THEN
         CLOSE c_cell_num;
         RETURN TRUE;
      ELSE
        CLOSE c_cell_num;
        RETURN FALSE;
      END IF;
    END check_line_locks_fun;

  --Begin of esn_sim_validation_prc
  BEGIN
    IF UPPER(NVL(i_language,'X')) <> 'SPANISH'
    THEN
      l_language := 'English';
    END IF;

    --Check ESN and SIM part number compatibility
    c_esn_sim_compatible := NAP_SERVICE_PKG.is_esn_sim_compatible ( i_esn          => i_esn,
                                                                    i_esn_part_num => NULL,
                                                                    i_sim          => i_sim,
                                                                    i_sim_part_num => NULL
                                                                  );
    IF c_esn_sim_compatible <> 'Y'
    THEN
      o_msg := c_esn_sim_compatible;
      RETURN;
    END IF;

    sa.Clean_Tnumber_Prc(i_esn, err_msg, o_msg);

    --Fetch phone technology details
    OPEN technology_curs (i_esn);
    FETCH technology_curs INTO technology_rec;

    IF technology_curs%NOTFOUND
    THEN
      CLOSE technology_curs;
      o_msg := 'Given ESN not found';
      RETURN;
    END IF;
    CLOSE technology_curs;

    IF technology_rec.x_technology <> 'GSM'
    THEN
      --Check if CDMA device
      IF sa.LTE_SERVICE_PKG.is_esn_lte_cdma (i_esn)=1
      THEN
        IF i_sim IS NULL
        THEN
          o_msg := 'SIM Exchange-ICCID profile not valid';
          RETURN;
        ELSE
          --Check if SIM is valid and not attached to other ESNs
          OPEN valid_cdma_lte_curs;
          FETCH valid_cdma_lte_curs INTO valid_cdma_lte_rec;

          IF valid_cdma_lte_curs%NOTFOUND
          THEN
            o_msg := 'SIM Exchange-ICCID status is invalid';
            CLOSE valid_cdma_lte_curs;
            RETURN;
          ELSIF valid_cdma_lte_rec.others_active > 0
          THEN
            o_msg := 'SIM Exchange-ICCID is already attached to an IMEI';
            CLOSE valid_cdma_lte_curs;
            RETURN;
          END IF;
          CLOSE valid_cdma_lte_curs;
        END IF;
      END IF;

      --Check if line lock exist i.e MIN already exist for the given ESN
      IF check_line_locks_fun
      THEN
        DBMS_OUTPUT.put_line('check_line_locks_fun:TRUE');

        IF l_language = 'English'
        THEN
          o_msg := 'F Choice: MIN already attached to ESN.  Please verify.';
        ELSE
          o_msg := 'Seleccion F: MIN ya esta adjunto al ESN. Por Favor verifique';
        END IF;

        RETURN;
      END IF;
    ELSE --technology_rec.x_technology <> 'GSM'
      o_msg := NULL;

      --Validate the SIM
      o_msg := gsm_is_valid_iccid_fun;

      IF o_msg <> 'SUCCESS'
      THEN
        RETURN;
      END IF;

      IF check_line_locks_fun
      THEN
        IF l_language = 'English'
        THEN
          o_msg := 'F Choice: MIN already attached to ESN.  Please verify.';
        ELSE
          o_msg :=
          'Seleccion F: MIN ya esta adjunto al ESN. Por Favor verifique';
        END IF;
        RETURN;
      END IF;

      IF gsm_is_a_react_fun THEN

        o_msg := gsm_is_iccid_valid4react_fun;

        IF o_msg IS NOT NULL
        THEN
          RETURN;
        ELSE
          IF l_language = 'English' THEN
            o_msg := 'F Choice: MIN already attached to ESN.  Please verify.';
          ELSE
            o_msg := 'Seleccion F: MIN ya esta adjunto al ESN. Por Favor verifique';
          END IF;
          RETURN;
        END IF;
      END IF; --gsm_is_a_react_fun
    END IF; --technology_rec.x_technology <> 'GSM'

    o_msg := 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      o_msg := SUBSTR(SQLERRM, 1, 2000);
  END esn_sim_validation_prc;

  FUNCTION is_esn_sim_compatible ( i_esn          IN    VARCHAR2,
                                   i_esn_part_num IN    VARCHAR2,
                                   i_sim          IN    VARCHAR2,
                                   i_sim_part_num IN    VARCHAR2
                                 )
  RETURN VARCHAR2
  IS
    c_esn_part_no   VARCHAR2(100);
    c_sim_part_no   VARCHAR2(100);
    c_is_compatible VARCHAR2(1);
  BEGIN
    IF i_esn_part_num IS NOT NULL
    THEN
      c_esn_part_no := i_esn_part_num;
    ELSE
      IF i_esn IS NOT NULL
      THEN
        BEGIN
          SELECT pn.part_number
            INTO c_esn_part_no
            FROM table_part_num pn,
                 table_mod_level ml,
                 table_part_inst pi
           WHERE pi.part_serial_no = i_esn
             AND pi.x_domain = 'PHONES'
             AND pi.n_part_inst2part_mod = ml.objid
             AND ml.part_info2part_num = pn.objid
             AND pn.domain = 'PHONES';
        EXCEPTION
          WHEN OTHERS THEN
            RETURN 'CANNOT FIND PART NUMBER FOR GIVEN ESN';
        END;
      ELSE
        RETURN 'BOTH ESN AND ESN PART NUMBER CANNOT BE NULL';
      END IF;
    END IF;

    IF i_sim_part_num IS NOT NULL
    THEN
      c_sim_part_no := i_sim_part_num;
    ELSE
      IF i_sim IS NOT NULL
      THEN
        BEGIN
          SELECT pn.part_number
            INTO c_sim_part_no
            FROM table_part_num pn,
                 table_mod_level ml,
                 table_x_sim_inv sim
           WHERE sim.x_sim_serial_no = i_sim
             AND sim.x_sim_inv2part_mod = ml.objid
             AND ml.part_info2part_num = pn.objid
             AND pn.domain = 'SIM CARDS';
        EXCEPTION
          WHEN OTHERS THEN
            RETURN 'CANNOT FIND PART NUMBER FOR GIVEN SIM';
        END;
      ELSE
        RETURN 'BOTH SIM AND SIM PART NUMBER CANNOT BE NULL';
      END IF;
    END IF;

    BEGIN
      SELECT 'Y'
        INTO c_is_compatible
        FROM carriersimpref sim,
             table_part_num pn
       WHERE pn.part_number = c_esn_part_no
         AND pn.domain = 'PHONES'
         AND pn.x_dll BETWEEN sim.MIN_DLL_EXCH AND sim.MAX_DLL_EXCH
         AND sim.sim_profile = c_sim_part_no
         AND rownum = 1;
      RETURN c_is_compatible;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 'N';
    END;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN SUBSTR(SQLERRM, 1, 2000);
  END is_esn_sim_compatible;
  --CR56825 changes end
END NAP_SERVICE_PKG;
/