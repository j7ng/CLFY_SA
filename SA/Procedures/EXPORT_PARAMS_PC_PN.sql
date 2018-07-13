CREATE OR REPLACE PROCEDURE sa."EXPORT_PARAMS_PC_PN" (p_part_class  varchar2,
                                                 p_apex_src    varchar2,
                                                 p_out_msg out varchar2) --CR13581
  as
  pc_objid number;
  apex_cur sys_refcursor;
  apex_cur_stmt varchar2(300) := 'select class_name, param_name, param_value '||
                                 ' from crm.part_class_params_view@' || p_apex_src ||
                                 ' where class_name in (''' || p_part_class || ''')';

  type apex_rec_ty is record (class_name  table_part_class.name%type,
                              param_name  table_x_part_class_params.x_param_name%type,
                              param_value table_x_part_class_values.x_param_value%type);
  apex_rec apex_rec_ty;

  cursor part_num_cur(pc_objid number) is
    select objid,
           part_number
    from   table_part_num
    where  part_num2part_class = pc_objid;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  ins_rslt varchar2(300);

  v_freq_1                    number := 0; --CR13581
  v_freq_2                    number := 0; --CR13581
  freq1 boolean;
  freq2 boolean;

  v_cnt number := 0;

  v_data_capable              number;--CR13581
  v_dll                       number;--CR13581
  v_technology                varchar2(20);--CR13581
  v_extd_warranty             number;--CR13581
  v_ild_type                  number;--CR13581
  v_conversion                number;--CR13581
  v_manufacturer              varchar2(20);--CR13581
  v_meid_phone                number;--CR13581
  v_ota_allowed               varchar2(10);--CR13581
  v_part_num2default_preload  number;--CR13581
  v_part_num2x_data_config    number;--CR13581
  v_restricted_use            number;--CR13581
  v_bus_org                   number;--CR13581
  v_update_pn                 varchar2(3000);--CR13581

--------------------------------------------------------------------------------
--PROC: SET PARAMETER BY NAME --------------------------------------------------
--------------------------------------------------------------------------------
    procedure set_param_by_name( pc_name     in varchar2,
                                 param_name  in varchar2,
                                 param_value in varchar2,
                                 out_msg     out varchar2)
    as
        pc_objid      number;
        param_objid   number;
        value_objid   number;
        current_value varchar2(300);

    begin
    --------------------------------------------------------
    -- SET PARAMETER BY NAME (MAIN)
    --------------------------------------------------------
      -- GET THE PC OBJID
      begin
          select objid into pc_objid
          from table_part_class
          where name = pc_name;
      exception
         when no_data_found then
            out_msg := 'No part class';
            return;
      end;
      -- GET THE PARAMETER OBJID OR CREATE IT IF NOT FOUND
      begin
          select objid into param_objid
          from table_x_part_class_params
          where x_param_name = param_name;
      exception
         when no_data_found then
            insert into table_x_part_class_params
              (objid, x_param_name)
            values
              (sa.seq('x_part_class_params'), param_name) returning objid into param_objid;
      end;

      -- IF THE PARAMETER VALUE IS NOT THE SAME UPDATE OR CREATE IT IF NOT FOUND
      begin
            select objid, x_param_value
            into value_objid,current_value
            from table_x_part_class_values
            where value2class_param = param_objid
            and value2part_class = pc_objid;
            if (current_value <> param_value ) then
               update table_x_part_class_values
               set x_param_value = param_value
               where objid = value_objid;
            end if;
      exception
         when no_data_found then
              insert into table_x_part_class_values (objid,dev,x_param_value, value2class_param, value2part_class)
              values (sa.seq('x_part_class_values'),0,param_value,param_objid, pc_objid)
              returning objid into value_objid;
      end;
        out_msg := 'Success'; --pc_objid||' '||param_objid||' '||param_value;
    end set_param_by_name;

begin  --CR13581
--------------------------------------------------------------------------------
-- EXPORT PARAMS PC PN MAIN ----------------------------------------------------
--------------------------------------------------------------------------------
  -- GET THE PC OBJID
   begin
      select objid
      into   pc_objid
      from   table_part_class
      where  name = p_part_class;
   exception
      when others then
         p_out_msg := p_part_class || ' - ' || 'export_params_pc_pn: ' || ' pc not found failed - ' || sqlerrm; --CR13581
         return;
  end;

  -- PURGE PART CLASS PARAMETERS AND VALUES
  delete table_x_part_class_values
  where value2part_class = pc_objid;

  begin
  ------------------------------------------------------------------------------
  -- INSERT PART CLASS PARAMETERS AND VALUES
  ------------------------------------------------------------------------------
    open apex_cur for apex_cur_stmt;
    loop
      fetch apex_cur into apex_rec;
      exit when apex_cur%notfound;
      -- SET THE PARAMETER
      set_param_by_name(apex_rec.class_name,
                        apex_rec.param_name,
                        apex_rec.param_value,
                        ins_rslt);

      -- COLLECT THE PARAMETER NAMES
      -- SET THE VARIBALES FOR THE PART NUMBER TABLE
      --CR13581
      if apex_rec.param_name = 'DATA_CAPABLE' then
          v_data_capable := apex_rec.param_value;
          v_update_pn := v_update_pn || apex_rec.param_name;
      elsif apex_rec.param_name = 'DLL' then
          v_dll := apex_rec.param_value;
          v_update_pn := v_update_pn || apex_rec.param_name;
      elsif apex_rec.param_name = 'TECHNOLOGY' then
          v_technology := apex_rec.param_value;
          v_update_pn := v_update_pn || apex_rec.param_name;
      elsif apex_rec.param_name = 'EXTD_WARRANTY' then
          v_extd_warranty := apex_rec.param_value;
          v_update_pn := v_update_pn || apex_rec.param_name;
      elsif apex_rec.param_name = 'ILD_TYPE' then
          v_ild_type := apex_rec.param_value;
          v_update_pn := v_update_pn || apex_rec.param_name;
      elsif apex_rec.param_name = 'INITIAL_MOTRICITY_CONVERSION' then
          v_conversion := apex_rec.param_value;
          v_update_pn := v_update_pn || apex_rec.param_name;
      elsif apex_rec.param_name = 'MANUFACTURER' then
          v_manufacturer := apex_rec.param_value;
          v_update_pn := v_update_pn || apex_rec.param_name;
      elsif apex_rec.param_name = 'MEID_PHONE' then
          v_meid_phone := apex_rec.param_value;
          v_update_pn := v_update_pn || apex_rec.param_name;
      elsif apex_rec.param_name = 'OTA_ALLOWED' then
          v_ota_allowed := apex_rec.param_value;
          v_update_pn := v_update_pn || apex_rec.param_name;
      elsif apex_rec.param_name = 'PRELOADED_DATA_CONFIG' then
          v_part_num2x_data_config := apex_rec.param_value;
          v_update_pn := v_update_pn || apex_rec.param_name;
      elsif apex_rec.param_name = 'RESTRICTED_USE' then
          v_restricted_use := apex_rec.param_value;
          v_update_pn := v_update_pn || apex_rec.param_name;
      elsif apex_rec.param_name = 'PRELOADED_CLICK_ID' then
          v_part_num2default_preload := apex_rec.param_value;
          v_update_pn := v_update_pn || apex_rec.param_name;
      elsif apex_rec.param_name = 'BUS_ORG' then
          select objid
          into   v_bus_org
          from   table_bus_org
          where  org_id = get_param_by_name_fun(p_part_class, apex_rec.param_name);
          v_update_pn := v_update_pn || apex_rec.param_name;
      elsif apex_rec.param_name = 'FREQUENCY_1' then
          v_freq_1 := 1;
      elsif apex_rec.param_name = 'FREQUENCY_2' then
          v_freq_2 := 1;
      end if;
--CR13581
    end loop;
--CR13581
    exception when others then
      p_out_msg := p_part_class || ' - ' || 'export_params_pc_pn: pc_prms failed - ' || sqlerrm;
      return;
  end;

  begin  --CR13581
  ------------------------------------------------------------------------------
  -- UPDATE PART NUMBERS PARAMETER VALUES
  ------------------------------------------------------------------------------
  for pn_rec in part_num_cur(pc_objid)
    loop
      v_cnt := v_cnt + 1;
      if v_update_pn is not null then
        begin
        -- FUNCTIONALITY IF IT FINDS THE PARAMETER IT WILL DO THE INIT INSERT OR
        -- IT WILL UPDATE, BUT, IT WILL NEVER INSERT A NULL VALUE
        --CR13581  new decode
        update table_part_num
          set  x_data_capable           = decode(instr(v_update_pn, 'DATA_CAPABLE'),0,x_data_capable,v_data_capable),
               x_dll                    = decode(instr(v_update_pn,'DLL'),0,x_dll,v_dll),
               x_technology             = decode(instr(v_update_pn,'TECHNOLOGY'),0,x_technology,v_technology),
               x_extd_warranty          = decode(instr(v_update_pn,'EXTD_WARRANTY'),0,x_extd_warranty,v_extd_warranty),
               x_ild_type               = decode(instr(v_update_pn,'ILD_TYPE'),0,x_ild_type,v_ild_type),
               x_conversion             = decode(instr(v_update_pn,'INITIAL_MOTRICITY_CONVERSION'),0,x_conversion,v_conversion),
               x_manufacturer           = decode(instr(v_update_pn,'MANUFACTURER'),0,x_manufacturer,v_manufacturer),
               x_meid_phone             = decode(instr(v_update_pn,'MEID_PHONE'),0,x_meid_phone,v_meid_phone),
               x_ota_allowed            = decode(instr(v_update_pn,'OTA_ALLOWED'),0,x_ota_allowed,v_ota_allowed),
               part_num2default_preload = decode(instr(v_update_pn,'PRELOADED_CLICK_ID'),0,part_num2default_preload,v_part_num2default_preload),
               part_num2x_data_config   = decode(instr(v_update_pn,'PRELOADED_DATA_CONFIG'),0,part_num2x_data_config,v_part_num2x_data_config),
               x_restricted_use         = decode(instr(v_update_pn,'RESTRICTED_USE'),0,x_restricted_use,v_restricted_use),
               part_num2bus_org         = decode(instr(v_update_pn,'BUS_ORG'),0,part_num2bus_org,v_bus_org)
         where objid = pn_rec.objid;

--CR13581
        exception when others then
           p_out_msg := p_part_class || ' - ' || 'export_params_pc_pn: pn_prms failed - table_part_num - ' || sqlerrm;
        end;

        -- FREQUENCY PARAM IS NOT MEANT TO BE REMOVED ONCE ASSIGNED A VALUE
       --CR13581
         if v_freq_1 > 0 then
           begin
               freq1:= add_freq_func(pn_rec.part_number,get_param_by_name_fun (p_part_class,'FREQUENCY_1'));
           exception when others then
           p_out_msg := p_part_class || ' - ' || 'export_params_pc_pn: pn_prms failed - freq1 - ' || sqlerrm;
           end;
         end if;
        --CR13581
         if v_freq_2 > 0 then
           begin
               freq2:= add_freq_func(pn_rec.part_number,get_param_by_name_fun (p_part_class,'FREQUENCY_2'));
           exception when others then
           p_out_msg := p_part_class || ' - ' || 'export_params_pc_pn: pn_prms failed - freq2 - ' || sqlerrm;
           end;
         end if;

      end if;
    end loop;
  exception when others then --CR13581
    p_out_msg := p_part_class || ' - ' || 'export_params_pc_pn: pn_prms failed - ' || sqlerrm;
    return;
  end;

  if p_out_msg is null then
    p_out_msg := p_part_class || ' - ' || 'Parameters Export successful';
  end if;
end;
/