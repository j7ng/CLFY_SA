CREATE OR REPLACE FUNCTION sa."ADFCRM_RET_B2B_INFO" (ip_site_objid varchar2, ip_x_cust_id varchar2, ip_web_addr_email varchar2, ip_esn varchar2)
return adfcrm_esn_structure is

  esn_tab  sa.adfcrm_esn_structure := sa.adfcrm_esn_structure();

--  ip_site_objid varchar2(30) := null;
--  ip_x_cust_id varchar2(30) := '1132360259'; -- 1132360256,1132360258,1132360259
--  ip_web_addr_email varchar2(30) := null; --'org_hugo_test_b2b@test.com';

  site_objid         table_site.objid%type;
  sd_cust_id         table_contact.x_cust_id%type;
  sd_site_id         table_site.site_id%type;
  sd_name            table_site.name%type;
  sd_s_name          table_site.s_name%type;
  sd_type            table_site.type%type;
  sd_site_type       table_site.site_type%type;
  sd_child_site2site  table_site.child_site2site%type;

  d_cust_id         table_contact.x_cust_id%type;
  d_site_id         table_site.site_id%type;
  d_name            table_site.name%type;
  d_s_name          table_site.s_name%type;
  d_type            table_site.type%type;
  d_site_type       table_site.site_type%type;
  d_child_site2site  table_site.child_site2site%type;

  o_cust_id         table_contact.x_cust_id%type;
  o_site_id         table_site.site_id%type;
  o_name            table_site.name%type;
  o_s_name          table_site.s_name%type;
  o_type            table_site.type%type;
  o_site_type       table_site.site_type%type;
  o_child_site2site  table_site.child_site2site%type;

  v_x_cust_id varchar2(30);
begin

  if ip_site_objid is null and
     ip_x_cust_id is null and
     ip_web_addr_email is null
  then
    -- GET CUST ID FROM THE ESN
    begin
      select c.x_cust_id
      into   v_x_cust_id
      from   sa.table_part_inst pi,
             sa.table_x_contact_part_inst cpi,
             sa.table_contact c
      where  pi.objid = cpi.x_contact_part_inst2part_inst
      and    c.objid = cpi.x_contact_part_inst2contact
      and    pi.part_serial_no = ip_esn;
    exception
      when others then
        return null;
    end;
  else
    v_x_cust_id := ip_x_cust_id;
  end if;

  -- COLLECT INFO
  for i in (select c.x_cust_id,
                   s.objid,
                   s.site_id,
                   s.name,
                   s.s_name,
                   s.type,
                   s.site_type,
                   s.child_site2site --,s.cust_primaddr2address,s.cust_shipaddr2address,s.cust_billaddr2address,s.primary2bus_org,s.x_fin_cust_id,s.x_commerce_id,s.x_ship_loc_id
            from   table_contact c,
                   table_contact_role cr,
                   table_site s
            where  1=1
            and    s.objid        = cr.contact_role2site
            and    c.objid        = cr.contact_role2contact
            and   (s.objid        = ip_site_objid
            or     c.x_cust_id    = v_x_cust_id
            or    upper(c.e_mail) = ip_web_addr_email))
  loop

    if i.site_type = 'SDIV' then
      site_objid          := i.objid;
      sd_cust_id          := i.x_cust_id;
      sd_site_id          := i.site_id;
      sd_name             := i.name;
      sd_s_name           := i.s_name;
      sd_type             := i.type;
      sd_site_type        := i.site_type;
      sd_child_site2site  := i.child_site2site;
    elsif i.site_type = 'DIV' then
      site_objid          := i.objid;
      d_cust_id          := i.x_cust_id;
      d_site_id          := i.site_id;
      d_name             := i.name;
      d_s_name           := i.s_name;
      d_type             := i.type;
      d_site_type        := i.site_type;
      d_child_site2site  := i.child_site2site;
    else
      site_objid          := i.objid;
      o_cust_id          := i.x_cust_id;
      o_site_id          := i.site_id;
      o_name             := i.name;
      o_s_name           := i.s_name;
      o_type             := i.type;
      o_site_type        := i.site_type;
      o_child_site2site  := i.child_site2site;

    end if;
  end loop;

  -- GET DIVISION INFO IF PHONE IS SUB DIVISION
  if d_site_type is null and sd_child_site2site is not null then
    for i in (select c.x_cust_id,
                     s.site_id,
                     s.name,
                     s.s_name,
                     s.type,
                     s.site_type,
                     s.child_site2site --,s.cust_primaddr2address,s.cust_shipaddr2address,s.cust_billaddr2address,s.primary2bus_org,s.x_fin_cust_id,s.x_commerce_id,s.x_ship_loc_id
              from   table_contact c,
                     table_contact_role cr,
                     table_site s
              where  1=1
              and    s.objid        = cr.contact_role2site
              and    c.objid        = cr.contact_role2contact
              and    s.objid        = sd_child_site2site)
    loop
      d_cust_id          := i.x_cust_id;
      d_site_id          := i.site_id;
      d_name             := i.name;
      d_s_name           := i.s_name;
      d_type             := i.type;
      d_site_type        := i.site_type;
      d_child_site2site  := i.child_site2site;
    end loop;
  end if;

--  -- GET ORGANIZATION INFO IF PHONE IS DIVISION
  if o_site_type is null and d_child_site2site is not null then
    for i in (select c.x_cust_id,
                     s.site_id,
                     s.name,
                     s.s_name,
                     s.type,
                     s.site_type,
                     s.child_site2site --,s.cust_primaddr2address,s.cust_shipaddr2address,s.cust_billaddr2address,s.primary2bus_org,s.x_fin_cust_id,s.x_commerce_id,s.x_ship_loc_id
              from   table_contact c,
                     table_contact_role cr,
                     table_site s
              where  1=1
              and    s.objid        = cr.contact_role2site
              and    c.objid        = cr.contact_role2contact
              and    s.objid        = d_child_site2site)
    loop
      o_cust_id          := i.x_cust_id;
      o_site_id          := i.site_id;
      o_name             := i.name;
      o_s_name           := i.s_name;
      o_type             := i.type;
      o_site_type        := i.site_type;
      o_child_site2site  := i.child_site2site;
    end loop;
  end if;

  dbms_output.put_line('SITE OBJID: '||site_objid);

  if sd_site_id is not null then
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(sd_site_type||'_X_CUST_ID',sd_cust_id);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(sd_site_type||'_SITE_ID',sd_site_id);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(sd_site_type||'_NAME',sd_name);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(sd_site_type||'_S_NAME',sd_s_name);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(sd_site_type||'_TYPE',sd_type);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(sd_site_type||'_SITE_TYPE',sd_site_type);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(sd_site_type||'_PARENT_OBJID',sd_child_site2site);
  end if;

  if d_site_id is not null then
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(d_site_type||'_X_CUST_ID',d_cust_id);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(d_site_type||'_SITE_ID',d_site_id);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(d_site_type||'_NAME',d_name);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(d_site_type||'_S_NAME',d_s_name);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(d_site_type||'_TYPE',d_type);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(d_site_type||'_SITE_TYPE',d_site_type);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(d_site_type||'_PARENT_OBJID',d_child_site2site);
  end if;

  if o_site_id is not null then
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(o_site_type||'_X_CUST_ID',o_cust_id);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(o_site_type||'_SITE_ID',o_site_id);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(o_site_type||'_NAME',o_name);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(o_site_type||'_S_NAME',o_s_name);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(o_site_type||'_TYPE',o_type);
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(o_site_type||'_SITE_TYPE',o_site_type);
  end if;

  return esn_tab;

end adfcrm_ret_b2b_info;
/