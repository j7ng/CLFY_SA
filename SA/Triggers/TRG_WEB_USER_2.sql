CREATE OR REPLACE TRIGGER sa."TRG_WEB_USER_2"
after insert or update or delete ON sa.TABLE_WEB_USER
for each row
declare
  web_user_objid        number;
  v_social_media_links  tdi.ccduser.socialmedia_link_tokens%type;
  action                varchar2(1);
  c   customer_type := customer_type(); -- CR46581
  l_err_code            VARCHAR2(1000);
  l_err_msg             VARCHAR2(4000);
  l_min_contact_pin     VARCHAR2(1000); -- CR47564
  l_mins                VARCHAR2(1000); -- CR47564
  l_org_id              VARCHAR2(50)  ;
  --
  function get_social_media_links(p_wu_objid in number) return varchar2 is
  ret_str varchar2(200);
  begin
     for i in ( select X_SOCIAL_MEDIA_UID,x_status from x_sme_2mobileuser
                where X_SME_MOBILEUSER2WEBUSER = p_wu_objid)
     loop
             if i.x_status = 1 then
               ret_str := ret_str||'|'||i.X_SOCIAL_MEDIA_UID||' facebook';
             end if;
     end loop;
  return substr(ret_str,2);
  end;
  --
begin
-- Go Smart changes
  -- Do not fire trigger if global variable is turned off
  if not sa.globals_pkg.g_run_my_trigger then
    return;
  end if;
  -- End Go Smart changes

  if inserting then
   action := 'I';
  elsif updating then
   action := 'U';
  elsif deleting then
   action := 'D';
  end if;

 --CR48260_MultiLine Discount on SM - call sp_notify_affpart_discount_BRM
  IF UPPER(NVL(:NEW.login_name,'X') ) <> UPPER(NVL(:OLD.login_name,'X')) THEN
  BEGIN
    SELECT  org_id INTO l_org_id
      FROM  table_bus_org
	 WHERE objid = nvl(:new.WEB_USER2BUS_ORG,:old.WEB_USER2BUS_ORG);

    enqueue_transactions_pkg.sp_notify_affpart_discount_BRM
             (i_web_user_objid    => nvl(:new.objid,:old.objid)                       ,
              i_login_name        => NVL(:NEW.login_name,:OLD.login_name)             ,
              i_bus_org_id        => l_org_id                                         ,
              i_web_user2contact  => nvl(:new.WEB_USER2CONTACT,:old.WEB_USER2CONTACT) ,
              o_response          => l_err_msg);

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF;

   --CR53621 Changes
    IF Account_Maintenance_pkg.get_account_status(i_login_name=> NVL(:NEW.s_login_name,:OLD.s_login_name),i_bus_org_objid => nvl(:new.WEB_USER2BUS_ORG,:old.WEB_USER2BUS_ORG)  ) =  'DUMMY_ACCOUNT'
    THEN

      RETURN ;

    END IF;

  -- CR47564 changes starts..
  contact_pkg.p_get_min_security_pin (i_web_user_objid      =>  nvl(:new.objid,:old.objid),
                                      i_web_user2bus_org    =>  nvl(:new.WEB_USER2BUS_ORG,:old.WEB_USER2BUS_ORG),
                                      i_web_contact         =>  nvl(:new.WEB_USER2CONTACT,:old.WEB_USER2CONTACT),
                                      i_action              =>  action,
                                      o_min_contact_pin     =>  l_min_contact_pin,
                                      o_mins                =>  l_mins,
                                      o_err_code            =>  l_err_code,
                                      o_err_msg             =>  l_err_msg);

  --
  -- CR47564 changes ends
  v_social_media_links := get_social_media_links(nvl(:new.objid,:old.objid));
  -- CR46581 Go_smart changes starts..
  c.web_contact_objid       := nvl(:new.WEB_USER2CONTACT,:old.WEB_USER2CONTACT);
  c.sub_brand               := c.get_sub_brand;
  -- CR46581 Go_smart changes ends
  merge into tdi.ccduser a
  using (select max(rowid) MRID from tdi.ccduser where clfy_wu_objid =:new.objid)
  on (clfy_wu_objid = :new.objid
     and a.rowid = MRID
     and nvl(who,'WU') <> 'WU')
  when matched then
  update set
    brand                   = (select name from table_bus_org
                               where objid = nvl(:new.WEB_USER2BUS_ORG,:old.WEB_USER2BUS_ORG)),
    email                   = decode(:new.s_login_name,null,:old.s_login_name,:new.s_login_name),
    password                = decode(:new.password,null,:old.password,:new.password),
    clfy_con_objid          = decode(:new.WEB_USER2CONTACT,null,
                                     :old.WEB_USER2CONTACT,:new.WEB_USER2CONTACT),
    socialmedia_link_tokens = v_social_media_links,
    org_name                = c.sub_brand,  -- CR46581
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
        PASSWORD,
        BRAND,
        firstname,
        lastname,
        email,
        org_name, -- CR46581
        socialmedia_link_tokens)
  values(LPAD(TO_CHAR(tdi.SGENERATOR001.NEXTVAL),20,'0'),
        LPAD(TO_CHAR(tdi.SGENERATOR002.NEXTVAL),20,'0'),
        action,
        SYSDATE,
        nvl(:new.objid,:old.objid),
        nvl(:new.WEB_USER2CONTACT,:old.WEB_USER2CONTACT),
        l_min_contact_pin,  -- CR47564
        l_mins,             -- CR47564
        'WU',
        decode(:new.password,null,:old.password,:new.password),
        (select name from table_bus_org
         where objid = nvl(:new.WEB_USER2BUS_ORG,:old.WEB_USER2BUS_ORG)),
        (select first_name from table_contact
         where objid = nvl(:new.WEB_USER2CONTACT,:old.WEB_USER2CONTACT)),
        (select last_name from table_contact
         where objid = nvl(:new.WEB_USER2CONTACT,:old.WEB_USER2CONTACT)),
        decode(:new.s_login_name,null,:old.s_login_name,:new.s_login_name),
        c.sub_brand,  -- CR46581
        v_social_media_links);
  --

end;
/