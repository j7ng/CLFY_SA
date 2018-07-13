CREATE OR REPLACE PACKAGE BODY sa."APEX_CARRIER_APP_PKG"
is
  procedure export_scripts(ip_src_db  varchar2,
                           ip_action  varchar2, -- action: LABEL,CARRIER,SCRIPT
                           ip_id      varchar2, -- id:  label name, x_carrier_id or apex script objid
                           op_msg_out out varchar2)
  as
     ----------------------------------------------------------------------------
      sqlstmt               varchar2(3000);
      v_script_objid        number;
      v_carrier_objid       number := -1;
      v_scpt_out_msg        varchar2(100);
      v_carr_out_msg        varchar2(100);
      v_previous_scpt_objid number;
      v_cnt                 number := 0;
     ----------------------------------------------------------------------------
      type gen_rec_type is record(x_carrier_id table_x_carrier.x_carrier_id%type,
                                  x_mkt_submkt_name table_x_carrier.x_mkt_submkt_name%type,
                                  x_status table_x_carrier.x_status%type,
                                  x_script_id table_x_scr.x_script_id%type,
                                  x_script_type table_x_scr.x_script_type%type,
                                  x_sourcesystem table_x_scr.x_sourcesystem%type,
                                  x_ivr_id table_x_scr.x_ivr_id%type,
                                  x_description table_x_scr.x_description%type,
                                  x_language table_x_scr.x_language%type,
                                  x_technology table_x_scr.x_technology%type,
                                  x_script_text table_x_scr.x_script_text%type);
      gen_cursor   sys_refcursor;
      gen_rec      gen_rec_type;
      ----------------------------------------------------------------------------
      procedure clear_carr_mtm (p_carrier_objid number)
      as
      begin
        delete sa.mtm_x_carrier27_x_scr0
        where  carrier2x_scr = p_carrier_objid;
        --dbms_output.put_line('mtm cleared for carrier '||p_carrier_objid||' '||sql%rowcount);
      end clear_carr_mtm;
      ----------------------------------------------------------------------------
      procedure clear_script_mtm (p_script_objid number)
      as
      begin
        delete sa.mtm_x_carrier27_x_scr0
        where  x_scr2x_carrier = p_script_objid;
        --dbms_output.put_line('mtm cleared for script '||p_script_objid||' '||sql%rowcount);
      end clear_script_mtm;
      ----------------------------------------------------------------------------
      procedure create_mtm(p_carrier_objid number,
                           p_script_objid number)
      as
      begin
        insert into sa.mtm_x_carrier27_x_scr0 (carrier2x_scr,
                                            x_scr2x_carrier)
        values (p_carrier_objid,
                p_script_objid);
        --dbms_output.put_line('created mtm carrier: '||p_carrier_objid||' script: '||p_script_objid);
      end create_mtm;
      ----------------------------------------------------------------------------
      procedure process_script (p_script_id     number,
                                p_script_text   varchar2,
                                p_script_type   varchar2,
                                p_sourcesystem  varchar2,
                                p_ivr_id        varchar2,
                                p_description   varchar2,
                                p_language      varchar2,
                                p_technology    varchar2,
                                op_objid_out    out  number,
                                op_msg          out varchar2)
      as
        v_script_objid number;
        v_curr_text table_x_scr.x_script_text%type;
      begin
      -- UPDATE IF FOUND AND TEXT DOESN'T MATCH, IF NOT FOUND THEN CREATE THE SCRIPT
            select objid, x_script_text
            into   op_objid_out, v_curr_text
            from   sa.table_x_scr
            where  x_script_id = p_script_id
            and    x_script_type = p_script_type
            and    x_sourcesystem = p_sourcesystem
            and    x_language = p_language
            and    x_technology = p_technology
            and    rownum < 2
            order by objid desc;

            if p_script_text != v_curr_text then
              update sa.table_x_scr
              set    x_script_text = p_script_text
              where  objid = op_objid_out;
            end if;
            op_msg := 'GET SCPT OBJID '||op_objid_out;

      exception when no_data_found then
        insert into sa.table_x_scr (objid,
                                    x_script_id,
                                    x_script_text,
                                    x_script_type,
                                    x_sourcesystem,
                                    x_ivr_id,
                                    x_description,
                                    x_language,
                                    x_technology)
        values (seq('x_scr'),
                p_script_id,
                p_script_text,
                p_script_type,
                p_sourcesystem,
                p_ivr_id,
                p_description,
                p_language,
                p_technology) returning objid into op_objid_out;
        op_msg := 'NEW SCPT OBJID '||op_objid_out;
      end process_script;
      ----------------------------------------------------------------------------
      function get_carrier(p_carrier_id number)
      return number
      as
        v_carrier_objid number := -1;
      begin
        select objid
        into   v_carrier_objid
        from   sa.table_x_carrier
        where  x_carrier_id = p_carrier_id;
        return v_carrier_objid;
      exception when no_data_found then
        return null;
      end get_carrier;
      ----------------------------------------------------------------------------
      function get_scpt_objid(p_script_id number,
                              p_script_type varchar2,
                              p_sourcesystem varchar2,
                              p_language varchar2,
                              p_technology varchar2)
      return number
      as
        v_script_objid_2 number := -1;
      begin
        select objid
        into   v_script_objid_2
        from   sa.table_x_scr
        where  x_script_id    = p_script_id
        and    x_script_type  = p_script_type
        and    x_sourcesystem = p_sourcesystem
        and    x_language     = p_language
        and    x_technology   = p_technology
        and    rownum < 2
        order by objid desc;

        return v_script_objid_2;
      exception when no_data_found then
        return null;
      end get_scpt_objid;
      ----------------------------------------------------------------------------
      function get_query_by(p_request_sql varchar2, p_id varchar2, p_src_db varchar2)
      return varchar2
      as
        qrystr varchar2(3000);
      begin
        if p_request_sql = 'CARRIER' then
          qrystr :=            ' select x_carrier_id, '||chr(10);
          qrystr := qrystr || ' x_mkt_submkt_name, '||chr(10);
          qrystr := qrystr || ' x_status,  '||chr(10);
          qrystr := qrystr || ' x_script_id, '||chr(10);
          qrystr := qrystr || ' x_script_type, '||chr(10);
          qrystr := qrystr || ' x_sourcesystem, '||chr(10);
          qrystr := qrystr || ' x_ivr_id, '||chr(10);
          qrystr := qrystr || ' x_description, '||chr(10);
          qrystr := qrystr || ' x_language, '||chr(10);
          qrystr := qrystr || ' x_technology, '||chr(10);
          qrystr := qrystr || ' script_text  '||chr(10);
          qrystr := qrystr || ' from   (select x_carrier_id,  '||chr(10);
          qrystr := qrystr || '                x_mkt_submkt_name,  '||chr(10);
          qrystr := qrystr || '                x_status, '||chr(10);
          qrystr := qrystr || '                objid '||chr(10);
          qrystr := qrystr || '                from crm.carriers@'||p_src_db||') a  '||chr(10);
          qrystr := qrystr || ' left outer join '||chr(10);
          qrystr := qrystr || ' (select st.x_script_id,  '||chr(10);
          qrystr := qrystr || '         st.x_script_type,  '||chr(10);
          qrystr := qrystr || '         st.x_sourcesystem,  '||chr(10);
          qrystr := qrystr || '         st.x_ivr_id,  '||chr(10);
          qrystr := qrystr || '         st.x_description,  '||chr(10);
          qrystr := qrystr || '         st.x_language,  '||chr(10);
          qrystr := qrystr || '         st.x_technology, '||chr(10);
          qrystr := qrystr || '         sr.script_text, '||chr(10);
          qrystr := qrystr || '         sa.carrier_objid '||chr(10);
          qrystr := qrystr || ' from    crm.carrier_script_template@'||p_src_db||' st, '||chr(10);
          qrystr := qrystr || '         crm.carrier_script_assignment@'||p_src_db||' sa, '||chr(10);
          qrystr := qrystr || '         crm.carrier_script_revisions@'||p_src_db||' sr '||chr(10);
          qrystr := qrystr || ' where   st.objid = sr.st_id '||chr(10);
          qrystr := qrystr || ' and     sa.script_objid = st.objid '||chr(10);
          qrystr := qrystr || ' and     sr.rev_no = (select max(rev_no) '||chr(10);
          qrystr := qrystr || '                      from crm.carrier_script_revisions@'||p_src_db||' sr2  '||chr(10);
          qrystr := qrystr || '                      where sr2.st_id = sr.st_id)) b '||chr(10);
          qrystr := qrystr || ' on a.objid  = b.carrier_objid '||chr(10);
          qrystr := qrystr || ' where a.x_carrier_id = '''||p_id||''''||chr(10);
          qrystr := qrystr || ' order by x_script_id, x_carrier_id ';
        elsif p_request_sql = 'LABEL' then
          qrystr := ' select x_carrier_id, '||chr(10);
          qrystr := qrystr || ' x_mkt_submkt_name, '||chr(10);
          qrystr := qrystr || ' x_status, '||chr(10);
          qrystr := qrystr || ' x_script_id, '||chr(10);
          qrystr := qrystr || ' x_script_type, '||chr(10);
          qrystr := qrystr || ' x_sourcesystem, '||chr(10);
          qrystr := qrystr || ' x_ivr_id, '||chr(10);
          qrystr := qrystr || ' x_description, '||chr(10);
          qrystr := qrystr || ' x_language, '||chr(10);
          qrystr := qrystr || ' x_technology,'||chr(10);
          qrystr := qrystr || ' script_text '||chr(10);
          qrystr := qrystr || ' from   crm.carrier_script_template@'||p_src_db||' st, '||chr(10);
          qrystr := qrystr || ' crm.carrier_script_revisions@'||p_src_db||' sr, '||chr(10);
          qrystr := qrystr || ' crm.carrier_script_assignment@'||p_src_db||' sa, '||chr(10);
          qrystr := qrystr || ' crm.carriers@'||p_src_db||' carr '||chr(10);
          qrystr := qrystr || ' where  st.objid = sr.st_id '||chr(10);
          qrystr := qrystr || ' and    sa.script_objid(+) = st.objid '||chr(10);
          qrystr := qrystr || ' and    sa.carrier_objid = carr.objid(+) '||chr(10);
          qrystr := qrystr || ' and    (script_text not like ''%MISSING%'' or script_text not like ''%SCRIPT%'') '||chr(10);
          qrystr := qrystr || ' and    label = '''||p_id||''''||chr(10);
          qrystr := qrystr || ' order by x_script_id, x_carrier_id ';
        elsif p_request_sql = 'SCRIPT' then
          qrystr := ' select x_carrier_id, '||chr(10);
          qrystr := qrystr || ' x_mkt_submkt_name, '||chr(10);
          qrystr := qrystr || ' x_status, '||chr(10);
          qrystr := qrystr || ' x_script_id, '||chr(10);
          qrystr := qrystr || ' x_script_type, '||chr(10);
          qrystr := qrystr || ' x_sourcesystem, '||chr(10);
          qrystr := qrystr || ' x_ivr_id, '||chr(10);
          qrystr := qrystr || ' x_description, '||chr(10);
          qrystr := qrystr || ' x_language, '||chr(10);
          qrystr := qrystr || ' x_technology,'||chr(10);
          qrystr := qrystr || ' script_text '||chr(10);
          qrystr := qrystr || ' from   crm.carrier_script_template@'||p_src_db||' st, '||chr(10);
          qrystr := qrystr || ' crm.carrier_script_revisions@'||p_src_db||' sr, '||chr(10);
          qrystr := qrystr || ' crm.carrier_script_assignment@'||p_src_db||' sa, '||chr(10);
          qrystr := qrystr || ' crm.carriers@'||p_src_db||' carr '||chr(10);
          qrystr := qrystr || ' where  st.objid = sr.st_id '||chr(10);
          qrystr := qrystr || ' and    sa.script_objid(+) = st.objid '||chr(10);
          qrystr := qrystr || ' and    sa.carrier_objid = carr.objid(+) '||chr(10);
          qrystr := qrystr || ' and    (script_text not like ''%MISSING%'' or script_text not like ''%SCRIPT%'') '||chr(10);
          qrystr := qrystr || ' and    sr.rev_no = (select max(rev_no) '||chr(10);
          qrystr := qrystr || '                     from   crm.carrier_script_revisions@'||p_src_db||' sr2 '||chr(10);
          qrystr := qrystr || '                     where  sr2.st_id = sr.st_id) '||chr(10);
          qrystr := qrystr || ' and    st.objid = '''||p_id||''''||chr(10);
          qrystr := qrystr || ' order by x_script_id, x_carrier_id ';
        else
          qrystr := 'no rqst';
        end if;
        --dbms_output.put_line(qrystr);
        return qrystr;
      exception when others then
        dbms_output.put_line('get_query_by'||sqlerrm);
      end get_query_by;
      ----------------------------------------------------------------------------
      -- MAIN BODY
      ----------------------------------------------------------------------------
  begin
    sqlstmt := get_query_by(ip_action,ip_id,ip_src_db);
    -- dbms_output.put_line(sqlstmt);
    open gen_cursor for sqlstmt;
      loop
        fetch gen_cursor into gen_rec;
        exit when gen_cursor%notfound;
        v_cnt := v_cnt+1;
          -- REMOVE MTM ----------------------------------------------------------
          if ip_action = 'CARRIER' then
            -- REMOVE MTM BY CARRIER
            if (v_carrier_objid != get_carrier(gen_rec.x_carrier_id)) then
              v_carrier_objid := get_carrier(gen_rec.x_carrier_id);
              clear_carr_mtm(v_carrier_objid);
            end if;
          else
            -- REMOVE MTM BY SCRIPT ID
            v_carrier_objid := get_carrier(gen_rec.x_carrier_id);
            if (v_previous_scpt_objid is null) or (v_previous_scpt_objid != get_scpt_objid(gen_rec.x_script_id,
                                                                                           gen_rec.x_script_type,
                                                                                           gen_rec.x_sourcesystem,
                                                                                           gen_rec.x_language,
                                                                                           gen_rec.x_technology)) then
              clear_script_mtm(get_scpt_objid(gen_rec.x_script_id,
                                              gen_rec.x_script_type,
                                              gen_rec.x_sourcesystem,
                                              gen_rec.x_language,
                                              gen_rec.x_technology));
            end if;
          end if;

          if (gen_rec.x_script_id is not null) and (instr(gen_rec.x_script_text,'--- MISSING SCRIPT ') = 0) then
          -- CREATE/UPDATE SCRIPT ------------------------------------------------
            process_script (gen_rec.x_script_id,
                            gen_rec.x_script_text,
                            gen_rec.x_script_type,
                            gen_rec.x_sourcesystem,
                            gen_rec.x_ivr_id,
                            gen_rec.x_description,
                            gen_rec.x_language,
                            gen_rec.x_technology,
                            v_script_objid,
                            v_scpt_out_msg);
            if v_previous_scpt_objid is null then
                v_previous_scpt_objid := v_script_objid;
            elsif v_previous_scpt_objid != v_script_objid then
                v_previous_scpt_objid := v_script_objid;
            end if;

          -- CREATE MTM ----------------------------------------------------------
            if v_carrier_objid >0 then
              create_mtm(v_carrier_objid, v_script_objid);
            else
              op_msg_out := op_msg_out||' '||v_scpt_out_msg ||' no carrier associated to script ' || chr(10);
            end if;
          end if;

      end loop;
      op_msg_out := op_msg_out || 'Export by '||ip_action||' Success - Total: '||v_cnt;
  exception when others then
      op_msg_out := 'apex_export_carrier_scripts -'||sqlerrm;
  end export_scripts;
end apex_carrier_app_pkg;
/