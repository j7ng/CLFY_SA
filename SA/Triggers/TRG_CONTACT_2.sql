CREATE OR REPLACE TRIGGER sa."TRG_CONTACT_2"
AFTER INSERT OR UPDATE OR DELETE ON sa.TABLE_CONTACT FOR EACH ROW
DECLARE
  web_user_objid        NUMBER;
  contact_objid         NUMBER;
  action                VARCHAR2(1);
  c                     customer_type := customer_type(); -- CR46581
  l_err_code            VARCHAR2(1000);
  l_err_msg             VARCHAR2(4000);
  l_min_contact_pin     VARCHAR2(1000); -- CR47564
  l_mins                VARCHAR2(1000); -- CR47564
BEGIN
  -- Do not fire trigger if global variable is turned off
  IF NOT sa.globals_pkg.g_run_my_trigger THEN
    RETURN;
  END IF;
  -- End Go Smart changes
  FOR i IN (SELECT objid,password,s_login_name,web_user2contact cont_objid,WEB_USER2BUS_ORG,
                  (SELECT name FROM table_bus_org WHERE objid=web_user2bus_org) brand
           FROM   table_web_user
           WHERE  WEB_USER2CONTACT = nvl(:new.objid,:old.objid))
  LOOP
    if inserting then
     action := 'I';
    elsif updating then
     action := 'U';
    elsif deleting then
     action := 'D';
    end if;
    --CR53621 Changes
    IF Account_Maintenance_pkg.get_account_status(i_login_name=> i.s_login_name,i_bus_org_objid => i.WEB_USER2BUS_ORG ) =  'DUMMY_ACCOUNT'
    THEN
        CONTINUE ;
    END IF;
    -- CR47564 changes starts..
    contact_pkg.p_get_min_security_pin(i_web_user_objid      =>  i.objid,
                                       i_web_user2bus_org    =>  i.WEB_USER2BUS_ORG,
                                       i_action              =>  action,
                                       o_min_contact_pin     =>  l_min_contact_pin,
                                       o_mins                =>  l_mins,
                                       o_err_code            =>  l_err_code,
                                       o_err_msg             =>  l_err_msg);

    -- CR47564 changes ends
    -- CR46581 Go_smart changes starts..
    c.web_contact_objid       := i.cont_objid;
    c.sub_brand               := c.get_sub_brand;
    -- CR46581 Go_smart changes ends
    merge into tdi.ccduser a
    using ( select max(rowid) MRID from tdi.ccduser where clfy_wu_objid = i.objid)
    on (clfy_wu_objid = i.objid
       --and nvl(who,'TC') <> 'TC'
       and a.rowid = MRID)
    when matched then
    update set
      firstname               = decode(:new.first_name,null,:old.first_name,:new.first_name),
      lastname                = decode(:new.last_name,null,:old.last_name,:new.last_name),
      clfy_con_objid          = i.cont_objid,
      email                   = i.s_login_name,
      brand                   = i.brand,
      password                = i.password,
      socialmedia_link_tokens = contact_pkg.fn_get_social_media_links(i.objid),
      org_name                = c.sub_brand,        -- CR46581
      CLFY_CONTACT_PIN        = l_min_contact_pin,   -- CR47564
      mobiles                 = l_mins               -- CR47564
    when not matched then
    insert(IBMSNAP_COMMITSEQ,
          IBMSNAP_INTENTSEQ,
          IBMSNAP_OPERATION,
          IBMSNAP_LOGMARKER,
          CLFY_WU_OBJID,
          CLFY_CON_OBJID,
          CLFY_CONTACT_PIN ,  -- CR47564
          MOBILES,            -- CR47564
          WHO,
          FIRSTNAME,
          LASTNAME,
          EMAIL,
          PASSWORD,
          BRAND,
          org_name, -- CR46581
          socialmedia_link_tokens
          )
    values(LPAD(TO_CHAR(tdi.SGENERATOR001.NEXTVAL),20,'0'),
          LPAD(TO_CHAR(tdi.SGENERATOR002.NEXTVAL),20,'0'),
          action,
          SYSDATE,
          i.objid,
          i.cont_objid,
          l_min_contact_pin,  -- CR47564
          l_mins,             -- CR47564
          'TC',
          decode(:new.first_name,null,:old.first_name,:new.first_name),
          decode(:new.last_name,null,:old.last_name,:new.last_name),
          i.s_login_name,
          i.password,
          i.brand,
          c.sub_brand,  -- CR46581
          contact_pkg.fn_get_social_media_links(i.objid)
          );

  end loop;
end;
/