CREATE OR REPLACE package body sa.adfcrm_ticker_pkg
as
--------------------------------------------------------------------------------
  procedure adfcrm_refresh_ticker
  is
    v_script_text varchar2(4000) := '<p class ="c2">OPERATIONS</p>';
    v_class varchar2(20) :='';
  begin
    -- THIS IS TO REFRESH THE LEGACY
    -- TICKER AND NETTICKER IN TABLE_X_SCR
    -- ONCE WEB CSR IS MIGRATED TO THE
    -- NEW VIEW WE CAN DISCARD THIS PROCEDURE
    for i in (select to_char(create_date,'MM.DD.YY')||' - ' create_date,substr(created_by,0,2) created_by,script_text,decode(font_wt,'y','b1',null)||decode(font_clr,'black',' c1','blue',' c2',null) fw,script_objid,display_ticker
              from (select * from adfcrm_ticker_history order by create_date desc,objid desc)
              where display_ticker = 1
              order by create_date desc,objid desc)
    loop
      if i.fw is not null then
        v_class := '<p class="'||i.fw||'">';
      else
        v_class := '<p>';
      end if;

      if length(v_script_text||v_class||i.script_text||' '||i.create_date||i.created_by||'</p>'||chr(10)) >= 4000 then
        dbms_output.put_line('STOPPING AT: '||length(v_script_text));
        goto next_step;
      end if;

      v_script_text := v_script_text||v_class||i.script_text||' '||i.create_date||i.created_by||'</p>'||chr(10);

    end loop;

    <<next_step>>
    dbms_output.put_line('end len of script: '||length(v_script_text));
    dbms_output.put_line(v_script_text);

    update table_x_scr
    set x_script_text = v_script_text
    where x_script_type in ('TICKER','NETTICKER')
    and    x_sourcesystem = 'WEBCSR';

    commit;

    dbms_output.put_line('UPDATED TICKER INFORMATION - SUCCESS');

  end adfcrm_refresh_ticker;
--------------------------------------------------------------------------------
  procedure ins_tick(ipv_date varchar2,ipv_login_name varchar2,scp_text varchar2,ipv_font_clr varchar2,ipv_font_wt varchar2)
  -- ipv_font_clr - black or blue
  -- v_font_wt - y or n (yes or no)
  as
  begin
    -- NO LONGER GOING BY NETICKER OR TICKER OBJID HISTORY WILL NOW BE TREATED AS A HISTORY FOR ALL
    insert into adfcrm_ticker_history
      (objid,create_date,created_by,script_text,script_objid,font_clr,font_wt,display_ticker)
    values
      (adfcrm_ticker_history_seq.nextval,to_date(ipv_date,'MM.DD.YYYY'),upper(ipv_login_name),scp_text,null,lower(ipv_font_clr),lower(ipv_font_wt),1);

    commit;

  end ins_tick;
--------------------------------------------------------------------------------
  function adfcrm_add_ticker(ipv_objid varchar2,
                             ipv_script_text varchar2,
                             ipv_font_clr varchar2,
                             ipv_font_wt varchar2,
                             v_login_name varchar2)
  return varchar2
  is
    v_script_text varchar2(4000) := '';
    v_class varchar2(20) :='';
    v_objid number := ipv_objid;
  begin

    -- NO LONGER REFERENCING TO NETICKER OR TICKER OBJID IS NULL - HISTORY WILL NOW BE TREATED AS ONE
    ins_tick(to_char(sysdate,'MM.DD.YYYY'),v_login_name,ipv_script_text,ipv_font_clr,ipv_font_wt);

    --adfcrm_refresh_ticker;

    return 'ADDED TICKER INFORMATION - SUCCESS';

  exception
     when others then
        return 'UPDATED TICKER INFORMATION - FAILED - ' || sqlerrm;

  end adfcrm_add_ticker;
--------------------------------------------------------------------------------
  function adfcrm_show_hide_ticker(ipv_tkr_hist_obj varchar2, ipv_show_or_hide varchar2,ipv_login_name varchar2)
  return varchar2
  is
    v_objid number:= '268448348';
    v_script_text varchar2(4000) := '';
    v_class varchar2(20) :='';
  begin

    update adfcrm_ticker_history
    set display_ticker = decode(ipv_show_or_hide,'HIDE',0,1)
    where objid = ipv_tkr_hist_obj;

    commit;

    --adfcrm_refresh_ticker;

    if ipv_show_or_hide = 'HIDE' then
      return 'HIDING TICKER INFORMATION - SUCCESS';
    else
      return 'SHOWING TICKER INFORMATION - SUCCESS';
    end if;

  end adfcrm_show_hide_ticker;
--------------------------------------------------------------------------------
  function repost_ticker(ipv_tkr_hist_obj varchar2,ipv_login_name varchar2)
  return varchar2
  is
  begin
    update adfcrm_ticker_history
    set display_ticker = 0
    where objid = ipv_tkr_hist_obj;

    for i in (select * from adfcrm_ticker_history where objid = ipv_tkr_hist_obj)
    loop
      ins_tick(to_char(sysdate,'MM.DD.YYYY'),ipv_login_name,i.script_text,i.font_clr,i.font_wt);
    end loop;

    return 'REPOSTED TICKER INFORMATION - SUCCESS';
  exception
    when others then
      return 'REPOSTED TICKER INFORMATION - ERROR '||sqlerrm;
  end repost_ticker;
--------------------------------------------------------------------------------
end adfcrm_ticker_pkg;
/