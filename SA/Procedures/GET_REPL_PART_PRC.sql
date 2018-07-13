CREATE OR REPLACE PROCEDURE sa."GET_REPL_PART_PRC" (
   p_zip IN VARCHAR2,
   p_esn IN VARCHAR2,
   p_curr_carrier IN NUMBER, --0 or null for external ports
   p_out_msg OUT VARCHAR2,
   p_pref_parent OUT VARCHAR2,
   p_repl_part OUT VARCHAR2,
   p_repl_tech OUT VARCHAR2,
   p_repl_sim OUT VARCHAR2,
   p_pref_carrier OUT VARCHAR2
)
as
  CURSOR c_old_esn_info IS
    SELECT pn.objid part_number_objid,
           pn.x_technology,
           pn.part_number,
           pn.part_num2part_class part_class_objid,
           NVL(pn.x_data_capable, 0) x_data_capable,
           pn.x_dll
      FROM table_part_inst pi,
           table_mod_level ml,
           table_part_num pn
     WHERE pn.objid = ml.part_info2part_num
       AND ml.objid = pi.n_part_inst2part_mod
       AND pi.part_serial_no = p_esn;
  c_old_esn_info_rec c_old_esn_info%ROWTYPE;

  CURSOR get_refurb_cnt IS
    SELECT nvl(x_refurb_flag,0) x_refurb_flag
      FROM table_site_part sp_a
     WHERE sp_a.x_service_id = p_esn
       AND sp_a.x_refurb_flag = 1;
  get_refurb_cnt_rec get_refurb_cnt%ROWTYPE;

  CURSOR c_repl_part(c_part_class_objid in number,
                     c_refurb_flag in number) IS
    SELECT exch.x_new_part_num,
           exch.x_used_part_num,
           DECODE(c_refurb_flag, 1, exch.x_used_part_num, exch.x_new_part_num) part_number,
           exch.x_days_for_used_part,
           exch.x_priority,
           pn.x_technology
      FROM table_x_class_exch_options exch,
           table_part_num pn
     WHERE 1 = 1
       AND exch.x_exch_type = 'WAREHOUSE'
       AND exch.source2part_class = c_part_class_objid
       and pn.part_number = DECODE(c_refurb_flag, 1, exch.x_used_part_num, exch.x_new_part_num)
   ORDER BY exch.x_priority ASC;
   cursor parent_curs is
     select case when p.x_parent_name like 'CING%' then
                   'ATT'
                 when p.x_parent_name like 'AT%' then
                   'ATT'
                 when p.x_parent_name like 'T_M%' then
                   'TMO'
                 when p.x_parent_name like '%SPRINT%' then
                   'SPR'
                 when p.x_parent_name like '%VERIZON%' then
                   'VER'
                 else
                   p.x_parent_name
                 end parent_name
       FROM table_x_parent p,
            table_x_carrier_group cg,
            TABLE_X_CARRIER c
      where 1=1
        and c.x_carrier_id = p_curr_carrier
        AND cg.objid = c.carrier2carrier_group
	and p.objid =cg.x_carrier_group2x_parent ;
   parent_rec parent_curs%rowtype;
BEGIN
  OPEN c_old_esn_info;
    FETCH c_old_esn_info INTO c_old_esn_info_rec;
    IF c_old_esn_info%NOTFOUND THEN
      p_out_msg := 'Esn Not Found';
      CLOSE c_old_esn_info;
      RETURN;
    END IF;
  CLOSE c_old_esn_info;
  DBMS_OUTPUT.put_line('c_old_esn_info_rec.x_data_capable:'||   c_old_esn_info_rec.x_data_capable);
  DBMS_OUTPUT.put_line('c_old_esn_info_rec.part_number_objid:'||   c_old_esn_info_rec.part_number_objid);
--------------------------------------------------------------------------------------
--find new sim section
--------------------------------------------------------------------------------------
  sa.nap_SERVICE_pkg.get_list(p_zip,
                              p_esn,
                              null,
                              null,
                              null,
                              null);
  if nap_SERVICE_pkg.big_tab.count >0 then
    if p_curr_carrier is not null then
      open parent_curs;
        fetch parent_curs into parent_rec;
      close parent_curs;
      OPEN get_refurb_cnt;
        FETCH get_refurb_cnt INTO get_refurb_cnt_rec;
        IF get_refurb_cnt%notfound THEN
          get_refurb_cnt_rec.x_refurb_flag := 0;
        END IF;
      CLOSE get_refurb_cnt;
      dbms_output.put_line('parent_rec.parent_name:'||parent_rec.parent_name);
      for i in nap_SERVICE_pkg.big_tab.first..nap_SERVICE_pkg.big_tab.last loop
        if     parent_rec.parent_name = case when nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_name like 'CING%' then
                                               'ATT'
                                             when nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_name like 'AT%' then
                                               'ATT'
                                             when nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_name like 'T_M%' then
                                               'TMO'
                                             when nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_name like '%SPRINT%' then
                                               'SPR'
                                             when nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_name like '%VERIZON%' then
                                               'VER'
                                             else
                                               nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_name
                                             end
           and nvl(nap_SERVICE_pkg.big_tab(i).carrier_info.sim_profile,'NA') != 'NA'
           -- CR32498 Begin
           AND nap_SERVICE_pkg.big_tab(i).carrier_info.shippable = 'Y'
           -- CR32498 End
           then
          p_out_msg := 'SIM Exchange';
          p_repl_part := NULL;
          p_repl_tech := c_old_esn_info_rec.x_technology;
          p_repl_sim := nap_SERVICE_pkg.big_tab(i).carrier_info.sim_profile;
          p_pref_carrier := nap_SERVICE_pkg.big_tab(i).carrier_info.x_carrier_id;
          p_pref_parent := nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_id;
          return;
        end if;
      end loop;
      FOR c_repl_part_rec IN c_repl_part (c_old_esn_info_rec.part_class_objid,get_refurb_cnt_rec.x_refurb_flag) loop
        dbms_output.put_line('c_repl_part_rec.part_number:'||c_repl_part_rec.part_number);
        dbms_output.put_line('parent_rec.parent_name:'||parent_rec.parent_name);

        sa.nap_SERVICE_pkg.get_list(p_zip,
                                    null,
                                    c_repl_part_rec.part_number,
                                    null,
                                    null,
                                    null);
        if nap_SERVICE_pkg.big_tab.count >0 then
          if p_curr_carrier is not null then
            for i in nap_SERVICE_pkg.big_tab.first..nap_SERVICE_pkg.big_tab.last loop
              if parent_rec.parent_name = case when nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_name like 'CING%' then
                                                 'ATT'
                                               when nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_name like 'AT%' then
                                                 'ATT'
                                               when nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_name like 'T_M%' then
                                                 'TMO'
                                               when nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_name like '%SPRINT%' then
                                                 'SPR'
                                               when nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_name like '%VERIZON%' then
                                                 'VER'
                                               else
                                                 nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_name
                                               end then
                p_out_msg := 'Replacement Part Found';
                p_repl_part := c_repl_part_rec.part_number;
                p_repl_tech := c_repl_part_rec.x_technology;
                p_repl_sim := nap_SERVICE_pkg.big_tab(i).carrier_info.sim_profile;
                p_pref_carrier := nap_SERVICE_pkg.big_tab(i).carrier_info.x_carrier_id;
                p_pref_parent := nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_id;
                return;
              end if;
            end loop;
          end if;
        end if;
      end loop;
    end if;
  end if;
  sa.nap_SERVICE_pkg.get_list(p_zip,
                              p_esn,
                              null,
                              null,
                              null,
                              null);
  if nap_SERVICE_pkg.big_tab.count >0 then
    p_out_msg := 'SIM Exchange';
    p_repl_part := NULL;
    p_repl_tech := c_old_esn_info_rec.x_technology;
    p_repl_sim := nap_SERVICE_pkg.big_tab(1).carrier_info.sim_profile;
    p_pref_carrier := nap_SERVICE_pkg.big_tab(1).carrier_info.x_carrier_id;
    p_pref_parent := nap_SERVICE_pkg.big_tab(1).carrier_info.x_parent_id;
    --CR32498 Begin - if any shppable sim, return that otherwise the first one from the list
    FOR i IN nap_SERVICE_pkg.big_tab.FIRST..nap_SERVICE_pkg.big_tab.LAST
    LOOP
      IF nap_SERVICE_pkg.big_tab(i).carrier_info.shippable = 'Y' THEN
          p_out_msg := 'SIM Exchange';
          p_repl_part := NULL;
          p_repl_tech := c_old_esn_info_rec.x_technology;
          p_repl_sim := nap_SERVICE_pkg.big_tab(i).carrier_info.sim_profile;
          p_pref_carrier := nap_SERVICE_pkg.big_tab(i).carrier_info.x_carrier_id;
          p_pref_parent := nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_id;
          RETURN;
      END IF;
    END LOOP;
    --CR32498 Ends
    return;
  end if;
--------------------------------------------------------------------------------------
--find new phone section
--------------------------------------------------------------------------------------
  OPEN get_refurb_cnt;
    FETCH get_refurb_cnt INTO get_refurb_cnt_rec;
    IF get_refurb_cnt%notfound THEN
      get_refurb_cnt_rec.x_refurb_flag := 0;
    END IF;
  CLOSE get_refurb_cnt;
  DBMS_OUTPUT.put_line('get_refurb_cnt_rec.x_refurb_flag:'||get_refurb_cnt_rec.x_refurb_flag   );
  FOR c_repl_part_rec IN c_repl_part (c_old_esn_info_rec.part_class_objid,get_refurb_cnt_rec.x_refurb_flag) loop
    sa.nap_SERVICE_pkg.get_list(p_zip,
                                null,
                                c_repl_part_rec.part_number,
                                null,
                                null,
                                null);
    if nap_SERVICE_pkg.big_tab.count >0 then
      if p_curr_carrier is not null then
        for i in nap_SERVICE_pkg.big_tab.first..nap_SERVICE_pkg.big_tab.last loop
          if p_curr_carrier = nap_SERVICE_pkg.big_tab(i).carrier_info.x_carrier_id  then
            p_out_msg := 'Replacement Part Found';
            p_repl_part := c_repl_part_rec.part_number;
            p_repl_tech := c_repl_part_rec.x_technology;
            p_repl_sim := nap_SERVICE_pkg.big_tab(i).carrier_info.sim_profile;
            p_pref_carrier := nap_SERVICE_pkg.big_tab(i).carrier_info.x_carrier_id;
            p_pref_parent := nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_id;
            return;
          end if;
        end loop;
      end if;
      p_out_msg := 'Replacement Part Found';
      p_repl_part := c_repl_part_rec.part_number;
      p_repl_tech := c_repl_part_rec.x_technology;
      p_repl_sim := nap_SERVICE_pkg.big_tab(1).carrier_info.sim_profile;
      p_pref_carrier := nap_SERVICE_pkg.big_tab(1).carrier_info.x_carrier_id;
      p_pref_parent := nap_SERVICE_pkg.big_tab(1).carrier_info.x_parent_id;
      return;
    end if;
  end loop;
  p_out_msg := 'NO Replacement Found';
END get_repl_part_prc;
/