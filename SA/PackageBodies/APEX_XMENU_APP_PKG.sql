CREATE OR REPLACE package body sa.apex_xmenu_app_pkg is
--------------------------------------------------------------------------------
  procedure ins_menu_item (p_orderby      varchar2,
                           p_mkey         varchar2,
                           p_category     varchar2,
                           p_lang         varchar2,
                           p_desc         varchar2,
                           p_channel      varchar2,
                           p_manuf_pc     varchar2,
                           p_brand        varchar2)
  as
  begin
    delete x_menu_2 a
    where  a.mkey = p_mkey
       and a.category = p_category
       and a.lang = p_lang
       and a.channel = p_channel
       and a.manufpartclass = p_manuf_pc
       and a.brand_name = p_brand;

    insert into x_menu_2 (orderby,
                          mkey,
                          category,
                          lang,
                          description,
                          channel,
                          manufpartclass,
                          brand_name)
    values (p_orderby,
            p_mkey,
            p_category,
            p_lang,
            p_desc,
            p_channel,
            p_manuf_pc,
            p_brand);
  end;
--------------------------------------------------------------------------------
  procedure del_menu_item (p_orderby      varchar2,
                           p_mkey         varchar2,
                           p_category     varchar2,
                           p_lang         varchar2,
                           p_channel      varchar2,
                           p_manuf_pc     varchar2,
                           p_brand        varchar2)
  as
  begin
    delete x_menu_2
    where  orderby        = p_orderby
    and    mkey           = p_mkey
    and    category       = p_category
    and    lang           = p_lang
    and    channel        = p_channel
    and    manufpartclass = p_manuf_pc
    and    brand_name     = p_brand;
  end;
--------------------------------------------------------------------------------
  procedure upd_menu_item (p_orderby      varchar2,
                           p_mkey         varchar2,
                           p_category     varchar2,
                           p_lang         varchar2,
                           p_desc         varchar2,
                           p_channel      varchar2,
                           p_manuf_pc     varchar2,
                           p_brand        varchar2)
  as
  begin
    update x_menu_2
    set    description    = p_desc
    -- where  orderby        = p_orderby
    where  mkey           = p_mkey
    and    category       = p_category
    and    lang           = p_lang
    and    channel        = p_channel
    and    manufpartclass = p_manuf_pc
    and    brand_name     = p_brand;
  end;
--------------------------------------------------------------------------------
  procedure rollback_x_menu_change_log (p_src_link varchar2,
                                        p_del_rowid varchar2)

  as
  v_sql varchar2(3000);
  begin

  -- BUILD INSERT
  v_sql :=          ' delete crm.x_menu_change_log@'|| p_src_link ||chr(10);
  v_sql := v_sql || ' where  rowid = '''||p_del_rowid||'''';

  -- DO INSERT
  -- dbms_output.put_line(v_sql);
  execute immediate v_sql;

  exception when others then
    dbms_output.put_line(v_sql);
  end;
--------------------------------------------------------------------------------
  procedure write_x_menu_change_log (p_action       varchar2,
                                     p_orderby      varchar2,
                                     p_mkey         varchar2,
                                     p_category     varchar2,
                                     p_lang         varchar2,
                                     p_new_desc     varchar2,
                                     p_old_desc     varchar2,
                                     p_channel      varchar2,
                                     p_manuf_pc     varchar2,
                                     p_brand        varchar2,
                                     p_src_link     varchar2,
                                     p_dest_link    varchar2,
                                     p_user_name    varchar2,
                                     p_export_label varchar2,
                                     p_export_no    number)

  as
  v_sql       varchar2(3000);
  v_new_desc  varchar2(300);
  v_old_desc  varchar2(300);
  begin
  -- CLEAN UP ANY ISSUES WITH SINGLE QUOTATIONS
  v_new_desc := replace(p_new_desc,'''','''''');
  v_old_desc := replace(p_old_desc,'''','''''');

  -- BUILD INSERT
  v_sql :=          ' insert into crm.x_menu_change_log@'|| p_src_link;
  v_sql := v_sql || '   (action, orderby, mkey, category, lang, new_description, old_description, channel, manufpartclass, brand_name, export_from, export_to, export_date, exported_by, export_label, export_no) ';
  v_sql := v_sql || ' values ';
  v_sql := v_sql || '   (''' ||p_action||''','||p_orderby||','''||p_mkey||''','''||p_category||''','''||p_lang||''','''||v_new_desc||''','''||v_old_desc||''','''||p_channel||''','''||p_manuf_pc||''','''||p_brand||''','''||p_src_link||''','''||trim(p_dest_link)||''','''||sysdate||''','''||p_user_name||''','''||p_export_label||''','''||p_export_no||''')';

  -- DO INSERT
  execute immediate v_sql;

  end;
--------------------------------------------------------------------------------
  procedure export_rollback_xmenu(p_src_link     in varchar2,
                                  p_dest_link    in varchar2,
                                  p_branch_label in varchar2,
                                  p_user_name    in varchar2,
                                  p_xprt_or_rlbk in varchar2,
                                  op_out_msg    out varchar2)
  as
--------------------------------------------------------------------------------
    gen_refcur      sys_refcursor;  -- (being used by import/export)
    sqlstmt         varchar2(3000); -- (being used by import/export)
    v_result        varchar2(30);   -- (being used by import/export)

    v_export_no     number;

    -- XMENU COLUMNS
    v_orderby       number;         -- (being used by import/export)
    v_mkey          varchar2(100);  -- (being used by import/export)
    v_category      varchar2(100);  -- (being used by import/export)
    v_lang          varchar2(50);   -- (being used by import/export)
    v_new_desc      varchar2(300);  -- (being used by import)
    v_old_desc      varchar2(300);  -- (being used by import/export)
    v_channel       varchar2(30);   -- (being used by import/export)
    v_manuf_pc      varchar2(30);   -- (being used by import/export)
    v_brand         varchar2(30);   -- (being used by import/export)

    v_del_rowid     varchar2(30);   -- (being used by export)

    -- IMP/EXP COUNTERS
    v_branch_exists number := 0;    -- (being used by export)
    v_cnt_1 number := 0;            -- (being used by import/export)
    v_cnt_2 number := 0;            -- (being used by import/export)
    v_cnt_3 number := 0;            -- (being used by import/export)

    v_out_msg varchar2(3000);
--------------------------------------------------------------------------------
  function apex_x_menu_comparison(p_src_link     in varchar2,
                                  p_dest_link    in varchar2,
                                  p_branch_label in varchar2,
                                  p_user_name    in varchar2)
  return varchar2 as
    v_linkage  varchar2(300);
    v_sql      varchar2(3000);
    v_vfy_lnk number;
  begin

    begin
      v_linkage := p_src_link;
      v_sql := 'select 1 from dual@' || v_linkage;
      execute immediate v_sql into v_vfy_lnk;

      v_linkage := p_dest_link;
      v_sql := 'select 1 from dual@' || v_linkage;
      execute immediate v_sql into v_vfy_lnk;

    exception when others then
      v_vfy_lnk := 0;
    end;

    if v_vfy_lnk = 1 then

      v_sql :=   ' select decode(a.orderby,null,''REMOVE'',decode(b.orderby,null,''NEW_ADD'',''CHANGE'')) result, ' || chr(10);
      v_sql := v_sql || ' nvl(a.orderby,b.orderby) orderby, ' || chr(10);
      v_sql := v_sql || ' nvl(a.mkey,b.mkey) mkey, ' || chr(10);
      v_sql := v_sql || ' nvl(a.category,b.category) category, ' || chr(10);
      v_sql := v_sql || ' nvl(a.lang,b.lang) lang, ' || chr(10);
      v_sql := v_sql || ' a.description new_description, ' || chr(10);
      v_sql := v_sql || ' b.description old_description, ' || chr(10);
      v_sql := v_sql || ' nvl(a.channel,b.channel) channel, ' || chr(10);
      v_sql := v_sql || ' nvl(a.manufpartclass,b.manufpartclass) manufpartclass, ' || chr(10);
      v_sql := v_sql || ' nvl(a.brand_name,b.brand_name) brand_name ' || chr(10);

      v_sql := v_sql || ' from ' || chr(10);
      v_sql := v_sql || ' (select * from crm.x_menu_export_view@'|| p_src_link;
      v_sql := v_sql || ' where description not like ''NOT_CREATED_FOR_%'' and export_label = ''' ||p_branch_label|| ''') a ' || chr(10);
      v_sql := v_sql || ' full outer join ' || chr(10);
      v_sql := v_sql || ' (select * from sa.x_menu_2@'|| p_dest_link || ') b ' || chr(10);
      v_sql := v_sql || ' on a.orderby = b.orderby ' || chr(10);
      v_sql := v_sql || ' and  a.mkey = b.mkey ' || chr(10);
      v_sql := v_sql || ' and  a.category = b.category ' || chr(10);
      v_sql := v_sql || ' and  a.lang = b.lang ' || chr(10);
      v_sql := v_sql || ' and  a.channel = b.channel ' || chr(10);
      v_sql := v_sql || ' and  a.manufpartclass = b.manufpartclass ' || chr(10);
      v_sql := v_sql || ' and  a.brand_name = b.brand_name ' || chr(10);
      v_sql := v_sql || ' where (a.orderby is null or b.orderby is null) ' || chr(10);
      v_sql := v_sql || ' or   a.description != b.description ' || chr(10);

      return (v_sql);
    else
      return('select ''db_link ' || v_linkage || ' is not working'' db_link from dual');
    end if;
  end;
--------------------------------------------------------------------------------
    function rollback_x_menu_qry(p_dest_link    in varchar2,
                                 p_branch_label in varchar2,
                                 p_export_no    in number)
    return varchar2 as
      v_linkage  varchar2(300);
      v_sql      varchar2(3000);
      v_vfy_lnk number;
    begin

      begin

        v_linkage := p_dest_link;
        v_sql := 'select 1 from dual@' || v_linkage;
        execute immediate v_sql into v_vfy_lnk;

      exception when others then
        v_vfy_lnk := 0;
      end;

      if v_vfy_lnk = 1 then

        v_sql :=          ' select rowid,' || chr(10);
        v_sql := v_sql || ' action, orderby, mkey, category, lang, new_description, old_description, channel, manufpartclass, brand_name ' || chr(10);
        v_sql := v_sql || ' from   crm.x_menu_change_log@' || p_src_link || chr(10);
        v_sql := v_sql || ' where  export_no = '''|| p_export_no || ''''|| chr(10);
        --v_sql := v_sql || ' where  export_label = '''|| p_branch_label || ''''|| chr(10);
        v_sql := v_sql || ' and    export_to = ''' || p_dest_link || '''';

        return (v_sql);
      else
        return('select ''db_link ' || v_linkage || ' is not working'' db_link from dual');
      end if;
    end;
--------------------------------------------------------------------------------
  procedure query_actions(p_xprt_or_rlbk varchar2,
                          p_del_rowid    varchar2,
                          p_action       varchar2,
                          p_orderby      varchar2,
                          p_mkey         varchar2,
                          p_category     varchar2,
                          p_lang         varchar2,
                          p_new_desc     varchar2,
                          p_old_desc     varchar2,
                          p_channel      varchar2,
                          p_manuf_pc     varchar2,
                          p_brand        varchar2,
                          p_src_link     varchar2,
                          p_dest_link    varchar2,
                          p_user_name    varchar2,
                          p_export_label varchar2,
                          p_export_no    number)

  as
  begin
    ----------------------------------------------------------------------------
    if p_xprt_or_rlbk = 'rollback' then

        if p_action = 'CHANGE' then
          apex_xmenu_app_pkg.upd_menu_item(p_orderby,p_mkey,p_category,p_lang,p_old_desc,p_channel,p_manuf_pc,p_brand);
        elsif
        p_action = 'NEW_ADD' then
          apex_xmenu_app_pkg.del_menu_item(p_orderby,p_mkey,p_category,p_lang,p_channel,p_manuf_pc,p_brand);
        elsif
        p_action = 'REMOVE' then
          apex_xmenu_app_pkg.ins_menu_item(p_orderby,p_mkey,p_category,p_lang,p_old_desc,p_channel,p_manuf_pc,p_brand);
        end if;
        -- REMOVE THE LOG AFTER THE CHANGE
        apex_xmenu_app_pkg.rollback_x_menu_change_log(p_src_link,p_del_rowid);
    else
        -- WRITE THE LOG BEFORE THE CHANGE
        apex_xmenu_app_pkg.write_x_menu_change_log(p_action,p_orderby,p_mkey,p_category,p_lang,p_new_desc,p_old_desc,p_channel,p_manuf_pc,p_brand,p_src_link,p_dest_link,p_user_name,p_export_label,p_export_no);

        if p_action = 'CHANGE' then
          apex_xmenu_app_pkg.upd_menu_item(p_orderby,p_mkey,p_category,p_lang,p_new_desc,p_channel,p_manuf_pc,p_brand);
        elsif
        p_action = 'NEW_ADD' then
          apex_xmenu_app_pkg.ins_menu_item(p_orderby,p_mkey,p_category,p_lang,p_new_desc,p_channel,p_manuf_pc,p_brand);
        elsif
        p_action = 'REMOVE' then
          apex_xmenu_app_pkg.del_menu_item(p_orderby,p_mkey,p_category,p_lang,p_channel,p_manuf_pc,p_brand);
        end if;
    end if;
  ------------------------------------------------------------------------------
  end;
--------------------------------------------------------------------------------
begin
  if p_xprt_or_rlbk = 'rollback' then
    -- CHECK FOR LAST EXPORT
    sqlstmt := 'select nvl(max(export_no),0) from crm.x_menu_change_log@';
    sqlstmt := sqlstmt || p_src_link;
    sqlstmt := sqlstmt || ' where export_to = ''' || p_dest_link || '''';
    --sqlstmt := sqlstmt || ' and export_label = '''|| p_branch_label || '''';

    execute immediate sqlstmt into v_export_no;

    sqlstmt := rollback_x_menu_qry(p_dest_link,p_branch_label,v_export_no);

    open gen_refcur for sqlstmt;
    loop
        fetch gen_refcur into v_del_rowid, v_result, v_orderby, v_mkey, v_category, v_lang, v_new_desc, v_old_desc, v_channel, v_manuf_pc, v_brand;
        exit when gen_refcur%NOTFOUND;
        if v_result = 'CHANGE' then
          v_cnt_1 := v_cnt_1+1;
        elsif v_result = 'NEW_ADD' then
          v_cnt_2 := v_cnt_2+1;
        elsif v_result = 'REMOVE' then
          v_cnt_3 := v_cnt_3+1;
        end if;
        query_actions(p_xprt_or_rlbk, v_del_rowid, v_result, v_orderby, v_mkey, v_category, v_lang, v_new_desc, v_old_desc, v_channel, v_manuf_pc, v_brand, p_src_link, p_dest_link, p_user_name, p_branch_label, null);
    end loop;
    close gen_refcur;
  else
    -- CHECK FOR LAST EXPORT
    sqlstmt := 'select nvl(max(export_no),0)+1 from crm.x_menu_change_log@';
    sqlstmt := sqlstmt ||p_src_link;
    execute immediate sqlstmt into v_export_no;

    sqlstmt := 'select count(*) from crm.x_menu_local_revisions@' || p_src_link || ' where export_label = ''' || p_branch_label || '''';
    execute immediate sqlstmt into v_branch_exists;

    if v_branch_exists > 0 then

        sqlstmt := apex_x_menu_comparison(p_src_link,p_dest_link,p_branch_label,p_user_name);

        open gen_refcur for sqlstmt;
        loop
            fetch gen_refcur into v_result, v_orderby, v_mkey, v_category, v_lang, v_new_desc, v_old_desc, v_channel, v_manuf_pc, v_brand;
            exit when gen_refcur%NOTFOUND;
            if v_result = 'CHANGE' then
              v_cnt_1 := v_cnt_1+1;
            elsif v_result = 'NEW_ADD' then
              v_cnt_2 := v_cnt_2+1;
            elsif v_result = 'REMOVE' then
              v_cnt_3 := v_cnt_3+1;
            end if;
            query_actions(p_xprt_or_rlbk, null, v_result, v_orderby, v_mkey, v_category, v_lang, v_new_desc, v_old_desc, v_channel, v_manuf_pc, v_brand, p_src_link, p_dest_link, p_user_name, p_branch_label, v_export_no);
        end loop;
        close gen_refcur;
    else
        v_out_msg := 'NO BRANCH EXISTS'|| chr(10);
    end if;

  end if;

    -- VERIFY COUNTS
    v_out_msg  := v_out_msg || 'ACTION: '|| upper(p_xprt_or_rlbk) ||chr(10);
    v_out_msg  := v_out_msg || ' - CHANGE:' ||v_cnt_1||chr(10);
    v_out_msg  := v_out_msg || ' - NEW_ADD:'||v_cnt_2||chr(10);
    v_out_msg  := v_out_msg || ' - REMOVE:' ||v_cnt_3||chr(10);
    op_out_msg := v_out_msg;

exception when others then
   op_out_msg  := 'oops - ' || sqlerrm;
end export_rollback_xmenu;
--------------------------------------------------------------------------------
end apex_xmenu_app_pkg;
/