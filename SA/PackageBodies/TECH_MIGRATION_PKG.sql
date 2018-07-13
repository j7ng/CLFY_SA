CREATE OR REPLACE package body sa.tech_migration_pkg as
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- ASIDE campaign_alerts AND create_campaign ALL OF THE OTHER OBJECTS INSIDE
-- THIS PACKAGE WERE DIRECTELY RELATED TO 2G MIGRATION WHICH ASIDE A FEW
-- STRAGGLER ESNS (AS OF 2/10/2017) THIS EFFOR HAS ALREADY BEEN CONSIDERED COMPLETE.
-- THE STRUCTURE USED FOR 2G MIGRATION IS NOT GENERIC ENOUGH TO USE
-- FOR NEW MIGRATIONS. SO THIS NEW STRUCTURE HAS BEEN BUILT FOR TMO 2BAND AND
-- OTHERS GOING FORWARD. ONCE THE 2G MIGRATION IS OFFICIALLY BEHIND US. WE WILL
-- REMOVE ALL RELATED OBJECTS.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure check_for_mig_case(ip_esn varchar2, op_c_id_number out varchar2, op_c_type out varchar2, op_c_title out varchar2, op_campaign_name out varchar2, op_offer_creation_date out varchar2)
  is
  begin
    for j in (
                select c.id_number,c.x_case_type case_type,c.title case_title,c.creation_time
                from table_case c
                where c.X_ESN = ip_esn
              )
    loop
      dbms_output.put_line('A CASE ('||j.id_number||') WAS FOUND FOR THIS CUSTOMER CREATED ON ==>'||j.creation_time||'<==');
      op_c_id_number := j.id_number;
      op_c_type := j.case_type;
      op_c_title := j.case_title;
      for i in (select campaign_name,case_type,case_title,creation_date,expiration_date
                from migration_campaign
                where case_type = j.case_type
                and case_title = j.case_title
                and to_date(j.creation_time,'DD-MON-YY') between creation_date and expiration_date
                )
      loop
        op_campaign_name := i.campaign_name;
        op_offer_creation_date := to_CHAR(i.creation_date,'MON/DD/YYYY');
        dbms_output.put_line('MIGRATION CAMPAIGN FOUND DURING THAT TIME FRAME ==>'||i.campaign_name||'<==');
      end loop;
    end loop;
  end check_for_mig_case;
--------------------------------------------------------------------------------
  procedure create_campaign(ip_CAMPAIGN_NAME varchar2,
                            ip_campaign_description varchar2,
                            ip_alert_title varchar2,
                            ip_script_id varchar2,
                            ip_channels_to_display varchar2,
                            ip_alert_severity varchar2,
                            ip_case_type varchar2,
                            ip_case_title varchar2,
                            ip_repl_part_number varchar2,
                            ip_related_phone_statuses varchar2,
                            ip_related_cr varchar2,
                            ip_requestor varchar2,
                            ip_campaign_expiration_date number,
                            op_error_msg out varchar2,
                            op_error_num out varchar2)
  is
    n1 number(1) := 0;
  begin
    op_error_msg := 'Campaign created successfully. ';
    op_error_num := 0;
    insert into migration_campaign
    (CAMPAIGN_NAME,OFFER_TITLE,IS_CAMPAIGN_ACTIVE,SCRIPT_ID,DESCRIPTION,DISPLAY_ALERT,ALERT_SEVERITY,CASE_TYPE,
     CASE_TITLE,PHONE_STATUS,APPROVED_CR_OR_TICKET,REQUESTED_BY,CREATION_DATE,EXPIRATION_DATE,DEFAULT_REPL_PN)
     values
     (upper(ip_CAMPAIGN_NAME),ip_alert_title,'Y',upper(ip_script_id),ip_campaign_description,upper(ip_channels_to_display),upper(ip_alert_severity),ip_case_type,
      ip_case_title,ip_related_phone_statuses,upper(ip_related_cr),upper(ip_requestor),sysdate,sysdate+ip_campaign_expiration_date,upper(ip_repl_part_number));

    if ip_case_type is not null and ip_case_title is not null then
      for i in (
                select h.X_Warehouse,h.is_balance_inq_required,h.x_case_type,h.x_title,
                      (select count(*)
                       from table_x_case_conf_int i
                       where i.conf_int2conf_hdr = h.objid) integration_config
                from table_x_case_conf_hdr h
                where h.x_case_type = ip_case_type
                and h.x_title = ip_case_title
                )
      loop
        if i.X_Warehouse != '1' then
          op_error_num := 1;
          op_error_msg := op_error_msg||'The case you chose is not a warehouse case. please fix.';
        end if;
        if i.is_balance_inq_required != '0' then
          op_error_msg := op_error_msg||'A balance inquiry is going to be forced in TAS during the creation of this case type and title.';
        end if;
        if i.integration_config = 0 then -- NEW CHECK FOR INTEGRATION CONFIGURATIONS.
          op_error_msg := op_error_msg||'There are no integration configurations of this case type and title. please fix.';
        end if;
        n1 := 1;
      end loop;
    end if;
    if n1 = 0 then
      op_error_msg := op_error_msg||'This case type and title was not found, if it is new please create it.';
    end if;
  exception
    when others then
      op_error_num :=2;
      op_error_msg := 'ERROR - '||sqlerrm;
  end create_campaign;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure campaign_alerts(esn            varchar2,
                            search_types   varchar2, -- NEW REQUIREMENT
                            step           number,
                            channel        varchar2,     -- Channel to display flash
                            title          out varchar2, -- Alert Title
                            CSR_TEXT       OUT VARCHAR2, -- Text to be used in WEBCSR
                            eng_text       out varchar2, -- Web Text English
                            SPA_TEXT       OUT VARCHAR2, -- Web Text Spanish
                            ivr_scr_id     out varchar2, -- IVR script ID
                            tts_english    OUT varchar2, -- Text to Speech English
                            tts_spanish    out varchar2, -- Text to Speech Spanish
                            HOT            OUT VARCHAR2, -- 0 Let customer continue, 1 Transfer
                            err            out varchar2, -- Error Number
                            op_msg         out varchar2, -- Additional Messages
                            OP_URL         OUT VARCHAR2,
                            op_url_text_en out varchar2,
                            op_url_text_es out varchar2,
                            op_sms_text    out varchar2,
                            op_bus_org     out varchar2,
                            op_case_action out varchar2,
                            op_case_type   out varchar2,
                            op_case_title  out varchar2,
                            op_case_hdr_objid  out varchar2,
                            op_case_repl_pn out varchar2,
                            OP_CAMPAIGN_MIGRATION out varchar2)
  is
    v_channels varchar2(1000);
    v_script_type varchar2(30);
    v_script_id  varchar2(30);
    v_case_cnt number;
    v_title_scpt varchar2(20);
    v_case_scpt varchar2(30);
    v_cancel_sql varchar2(4000) := 'select count(*)
                                     from (select   c.creation_time case_start_date,
                                                    pr.x_ship_date part_ship_date,
                                                    c.id_number,
                                                    pr.*
                                            from  table_x_part_request pr,
                                                  table_case c
                                            where pr.request2case = c.objid
                                            and c.x_esn  = :esn
                                            and pr.x_status in (''SHIPPED'',''PROCESSED'')
                                            and pr.x_tracking_no is not null
                                            and pr.x_part_serial_no is not null)
                                      where 1=1
                                      and part_ship_date>to_date(:alert_start_date,''MON/DD/YYYY'')';

    cursor offerbyesn(ip_esn varchar2)
    is
    select null partclass, null zipcode, SUBSTR(m.script_id,0,instr(m.script_id,'_')-1) script_type,substr(m.script_id,instr(m.script_id,'_')+1) script_id,m.script_id actual_script_id,upper(m.display_alert) display_alert,decode(m.alert_severity,'HOT','1','0') alert_severity,
                     (select org_id
                      from table_bus_org
                      where objid = GET_BRAND_OBJID(e.esn)) brand,
                      m.case_type,
                      m.case_title,
                      m.default_repl_pn,
                      M.PHONE_STATUS,
                      M.APPROVED_CR_OR_TICKET,
                      M.REQUESTED_BY,
                      M.CREATION_DATE,
                      M.EXPIRATION_DATE,
                      M.CAMPAIGN_NAME,
                      M.OFFER_TITLE,
                      m.BLOCK_FUNCTIONALITY
              from  migration_campaign_to_esn e,
                    migration_campaign m
              where 1=1
              and e.CAMPAIGN_NAME = m.CAMPAIGN_NAME
              and esn = ip_esn
              and m.IS_CAMPAIGN_ACTIVE = 'Y';
    offer_rec  offerbyesn%rowtype;


    cursor offerbypczip(ip_esn varchar2,ip_pc varchar2,ip_pc_zip varchar2)
    is
    select p.partclass,p.zipcode, SUBSTR(m.script_id,0,instr(m.script_id,'_')-1) script_type,substr(m.script_id,instr(m.script_id,'_')+1) script_id,m.script_id actual_script_id,upper(m.display_alert) display_alert,decode(m.alert_severity,'HOT','1','0') alert_severity,
                 (select org_id
                  from table_bus_org
                  where objid = GET_BRAND_OBJID(ip_esn)) brand,
                  m.case_type,
                  m.case_title,
                  m.default_repl_pn,
                  M.PHONE_STATUS,
                  M.APPROVED_CR_OR_TICKET,
                  M.REQUESTED_BY,
                  M.CREATION_DATE,
                  M.EXPIRATION_DATE,
                  M.CAMPAIGN_NAME,
                  m.OFFER_TITLE,
                  m.BLOCK_FUNCTIONALITY
    from  migration_campaign_to_pc p,
          migration_campaign m
    where 1=1
    and p.CAMPAIGN_NAME = m.CAMPAIGN_NAME
    and partclass = ip_pc
    and p.zipcode = ip_pc_zip
    and m.IS_CAMPAIGN_ACTIVE = 'Y';

    cursor is_channel_specified(ip_channels varchar2, ip_channel_passed varchar2)
    is
    select distinct *
                from  (with t as (select ip_channels channels  from dual)
                select replace(regexp_substr(channels,'[^,]+',1,lvl),'null','') channel
                from  (select channels, level lvl
                      from   t
                      connect by level <= length(channels) - length(replace(channels,',')) + 1)
                )
    where channel is not null
    and channel = ip_channel_passed;
    channel_rt is_channel_specified%rowtype;

    cursor getpc(ip_esn varchar2)
    is
    select p.name
    from table_mod_level m,
         table_part_num n,
         table_part_class p,
         table_part_inst i
    where m.part_info2part_num = n.objid
    and n.part_num2part_class = p.objid
    and i.n_part_inst2part_mod = m.objid
    and i.part_serial_no = ip_esn;
    pc_rt getpc%rowtype;

    cursor is_status_specified(ip_statuses varchar2, ip_status_passed varchar2)
    is
    select distinct *
              from  (with t as (select ip_statuses statuses  from dual)
              select replace(regexp_substr(statuses,'[^,]+',1,lvl),'null','') status
              from  (select statuses, level lvl
                    from   t
                    connect by level <= length(statuses) - length(replace(statuses,',')) + 1)
              )
    where status is not null
    and status = ip_status_passed;
    status_rt is_status_specified%rowtype;

    cursor sts(ip_esn varchar2)
    is
    select x_part_inst_status ps
    from table_part_inst
    where part_serial_no = ip_esn;
    sts_rt sts%rowtype;

    cursor case_sts(ip_esn varchar2,ip_case_type varchar2,ip_case_title varchar2)
    is
--    select id_number,CASE_STATE2CONDITION
--    from table_case
--    where x_esn = ip_esn
--    and x_case_type = ip_case_type
--    and title = ip_case_title;
    select c.id_number, upper(cc.title) title, (SELECT S_TITLE FROM TABLE_GBST_ELM WHERE OBJID = C.CASESTS2GBST_ELM) STATUS
    from table_case c,
         table_condition cc
    where 1=1
    and c.CASE_STATE2CONDITION = cc.objid
    and c.x_esn = ip_esn
    and c.x_case_type = ip_case_type
    and c.title = ip_case_title;

    case_sts_rt case_sts%rowtype;


    cursor offer_urls(ip_offer_name varchar2,ip_channel varchar2)
    is
    select *
    from migration_campaign_urls
    where CAMPAIGN_NAME = ip_offer_name
    and DISPLAY_URL = ip_channel;
    offer_urls_rt offer_urls%rowtype;

    cursor get_case_objid(ip_case_type varchar2,ip_case_title varchar2)
    is
    select * from table_x_case_conf_hdr
    where x_case_type = ip_case_type
    and x_title = ip_case_title;
    get_case_objid_rt get_case_objid%rowtype;

    -- RETURN SCRIPT FUNCTION
    -- a = migration_status - was script type
    -- b = was script id
    -- c = language
    -- d = sourcesystem
    -- e = brand
    -- f = case id
    -- g = campaign name
    v_title varchar2(80);
    procedure r(a varchar2,b varchar2,c varchar2,d varchar2,e varchar2,f varchar2,g varchar2,h out varchar2)
    --return varchar2
    is
      txt varchar2(4000);
      v_url sa.migration_campaign_urls.campaign_url%type;
    begin
--      do('a ==>'||a);
--      do('b ==>'||b);
--      do('c ==>'||c);
--      do('d ==>'||d);
--      do('e ==>'||e);
--      do('f ==>'||f);
--      do('g ==>'||g);
--      do('h ==>'||h);
      if g is not null then
        for i in (
                  select message_title,message_text
                  from migration_campaign_msgs
                  WHERE 1=1
                  and CAMPAIGN_NAME = g
                  and migration_status like '%'||nvl(a,'DEFAULT')||'%'
                  and display_in_channels like '%'||d||'%'
                  and language like '%'||c||'%'
                  and DISPLAY_IN_BRANDS like '%'||e||'%'
                  )
        loop
          v_title := i.message_title;
          txt := i.message_text;
        end loop;
        if txt is null or txt = '' then
          for j in (
                    select message_title,message_text
                    from migration_campaign_msgs
                    WHERE 1=1
                    and CAMPAIGN_NAME = g
                    and migration_status like '%'||nvl(a,'DEFAULT')||'%'
                    and display_in_channels like '%'||d||'%'
                    and language like '%'||c||'%'
                    and DISPLAY_IN_BRANDS like '%'||'GENERIC'||'%'
                    )
          loop
            v_title := j.message_title;
            txt := j.message_text;
          end loop;
        end if;

        if f is not null then
          txt := replace(txt,'[case_id]',f);
        end if;

        -- GET THE BRAND URL IF IT'S PASSED
        if instr(txt,'[url]') >0 then
          begin
            select campaign_url
            into v_url
            from (
                  select 1 ob, campaign_url
                  from migration_campaign_urls
                  where CAMPAIGN_NAME = g
                  and replace(display_url,'_','') like replace(e,'_','')||d||'%TEXT'
                  union
                  select 2 ob, campaign_url
                  from migration_campaign_urls
                  where CAMPAIGN_NAME = g
                  and replace(display_url,'_','') like replace(e,'_','')||'%TEXT'
                  )
            where rownum <2
            order by ob;

          exception
            when others then
              null;
          end;
        end if;
      end if;

      h := nvl(substr(replace(txt,'[url]',v_url),0,4000),'MISSING - SCRIPT (a:'||a||') (b:'||b||') (c:'||c||') (d:'||d||') (e:'||e||') (f:'||f||') (g:'||g||')');

    end r;

    procedure do(i_one varchar2,i_two varchar2)
    is
    begin
      dbms_output.put_line(i_one||i_two);
    end do;
  begin
    -- START HERE --------------------------------------------------------------
      op_case_action := 'DO_NOTHING';
      op_msg := 'No Alert Found';
      err           := '0';

      -- GET OFFER BY ESN
      open offerbyesn(esn);
      loop
      fetch offerbyesn INTO offer_rec;
      exit when offerbyesn%notfound;
      end loop;
      close offerbyesn;

      if offer_rec.CAMPAIGN_NAME is null then
      -- IF AN OFFER WAS NOT FOUND CONTINUE TO SEE IF THERE IS ONE BY ALTERNATIVE SEARCH

        if search_types is not null then -- SEARCH_TYPES VAL SHOULD BE PASSED LIKE THIS 'ZIPCODE:33183,MIN:3053583015,'
          -- ADD CODE HERE IF YOU WANT TO ADD DIFFERENT SEARCH TYPES
          for i in (select  substr(fv,0,instr(fv,':')-1) search_type, substr(fv,instr(fv,':')+1) search_val
                          from  (with t as (select (SELECT search_types FEATURE_VALUE FROM DUAL
                                         ) fv  from dual)
                          select replace(regexp_substr(fv,'[^,]+',1,lvl),'null','') fv
                          from  (select fv, level lvl
                                from   t
                                connect by level <= length(fv) - length(replace(fv,',')) + 1)
                          )
                    where fv is not null
                    and substr(fv,0,instr(fv,':')-1) = 'ZIPCODE') -- FOR NOW THE REQUIREMENT WAS TO ONLY USE ZIPCODE, BUT, REMOVE THIS LINE TO OPEN UP
          loop

            -- IF THIS EXTENDS, THEN IF ELSE HERE TO ADD OTHER SEARCH TYPES
            open getpc(esn);
            loop
            fetch getpc into pc_rt;
            exit when getpc%notfound;
            end loop;
            close getpc;

            if pc_rt.name is null then
              do('NO PART CLASS ==>','EXIT');
            end if;

            do('GET THE ACTIVATION ZIP CODE OF THE PHONE','');
            do('zipcode=============',i.search_val||','||pc_rt.name);

            open offerbypczip(esn,pc_rt.name,i.search_val);
            loop
            fetch offerbypczip INTO offer_rec;
            exit when offerbypczip%notfound;
            end loop;
            close offerbypczip;

            -- END HERE SEARCH TYPES
          end loop;
        end if;
      end if;

      OP_CAMPAIGN_MIGRATION := offer_rec.CAMPAIGN_NAME;
      do('MIGRATION_CAMPAIGN:    '||offer_rec.CAMPAIGN_NAME,'');
      do('APPROVED_CR_OR_TICKET: '||offer_rec.APPROVED_CR_OR_TICKET,'');
      do('REQUESTED_BY:          '||offer_rec.REQUESTED_BY,'');
      do('CREATION_DATE:         '||offer_rec.CREATION_DATE,'');
      do('EXPIRATION_DATE:       '||offer_rec.EXPIRATION_DATE,'');
      do('CASE CONFIGURED:       ',offer_rec.case_type||', '||offer_rec.case_title||' - DEFAULT PN: '||offer_rec.default_repl_pn);
      do('STATUSES CONFIGURED:   ',offer_rec.PHONE_STATUS);
      do('CHANNELS CONFIGURED:   ',offer_rec.display_alert);
      do('SCRIPT ID CONFIGURED:  ',offer_rec.actual_script_id);
      do('PARTCLASS CONFIGURED:  ',nvl(offer_rec.partclass,'ALERT CONFIGURATION TO ESN'));

      -- AN CURRENT OFFER IS FOUND
      if sysdate>offer_rec.EXPIRATION_DATE then
        return;
      end if;

      -- DETERMINE SEVERITY
      HOT := offer_rec.alert_severity;

      -- DETERMINE CASE TYPE + TITLE AND CASE STATUS
      if offer_rec.case_type is not null and offer_rec.case_title is not null then
          op_case_type := offer_rec.case_type;
          op_case_title := offer_rec.case_title;

          if 1=1 then
            open case_sts(esn,offer_rec.case_type,offer_rec.case_title);
            loop
            fetch case_sts into case_sts_rt;
            exit when case_sts%notfound;
            end loop;
            close case_sts;
            if case_sts_rt.id_number is not null then
              -- CHECK CASE STATUS FOR OUTPUT SCRIPT
              HOT := 0;
              if case_sts_rt.status not like '%CLOSED%' then
                v_title_scpt := 'CASE';
                v_case_scpt := 'CASE_OPEN'; -- WAS CASE (NO LONGER USING SCRIPT ID)

                -- IF IT'S NOT A CLOSED CASE AND IT'S CHECK FOR SHIP CONFIRM
                execute immediate v_cancel_sql into v_case_cnt using esn, to_CHAR(offer_rec.CREATION_DATE,'MON/DD/YYYY');

                v_title_scpt := case_sts_rt.status;
                v_case_scpt := case_sts_rt.status;
                -- CHECK FOR BAD ADDRESS
                if case_sts_rt.status like '%BADADDRESS%' or case_sts_rt.status like '%BAD ADDRESS%' then
                  v_title_scpt := 'BAD ADDRESS';
                  v_case_scpt := case_sts_rt.status; -- WAS CASE (NO LONGER USING SCRIPT ID)
                end if;

              else
                v_title_scpt := 'CASE';
                v_case_scpt := 'CASE_CLOSED'; -- WAS CASE (NO LONGER USING SCRIPT ID)
              end if;

              --do('FOUND v_case_cnt',v_case_cnt);
              if v_case_cnt > 0 and (v_title_scpt not like '%BADADDRESS%' and case_sts_rt.status not like '%BAD ADDRESS%')
              then
                HOT := 0;
                v_title_scpt := 'SHIP CONFIRM';
                v_case_scpt := 'SHIP_CONFIRM'; -- WAS SC (NO LONGER USING SCRIPT ID)
                op_case_action := 'MIGRATION_COMPLETE';
              end if;

              do('DISPLAY STATUS SCRIPT: ',v_case_scpt);
            else
              open get_case_objid(offer_rec.case_type,offer_rec.case_title);
              loop
              fetch get_case_objid into get_case_objid_rt;
              exit when get_case_objid%notfound;
              end loop;
              close get_case_objid;
              op_case_hdr_objid := get_case_objid_rt.objid;
              op_case_repl_pn := OFFER_REC.default_repl_pn;
              op_case_action := 'CREATE_CASE';
            end if;
            do('CASE FOUND:            ',case_sts_rt.id_number);
            if case_sts_rt.id_number is not null then
              op_case_action := 'CASE_IN_PROGRESS';
            end if;
          end if;
      end if;

      if offer_rec.PHONE_STATUS is not null then
        open sts(esn);
        loop
        fetch sts into sts_rt;
        exit when sts%notfound;
        end loop;
        close sts;

        open is_status_specified(offer_rec.PHONE_STATUS,sts_rt.ps);
        loop
        fetch is_status_specified into status_rt;
        exit when is_status_specified%notfound;
        end loop;
        close is_status_specified;
      end if;

      if status_rt.status is null then
        do('NO CONFIG EXISTS FOR STATUS ==>','END PROC');
        return;
      end if;

      open is_channel_specified(offer_rec.display_alert,channel);
      loop
      fetch is_channel_specified into channel_rt;
      exit when is_channel_specified%notfound;
      end loop;
      close is_channel_specified;

      do(chr(10)||'PHONE INFO'||chr(10)||'==============','');
      do('ZIPCODE ==>',offer_rec.zipcode);
      do('ALERT SEVERITY ==>',offer_rec.alert_severity);
      do('BRAND ==>',offer_rec.brand);
      do('CHANNEL ==>',channel_rt.channel);
      do('PHONE STATUS ==>',status_rt.status);
      do('PHONE PART CLASS ==>',pc_rt.name); -- WEIRD THAT THIS DOES NOT SHOW
      do('TYPE OF SCRIPT TO DISPLAY ==>',nvl(v_case_scpt,'DEFAULT'));
      do('CASE STATUS ==>',case_sts_rt.status||chr(10));
--      if offer_rec.actual_script_id is null then
--        do('NO CONFIG EXISTS - END PROC',null);
--        return;
--      end if;

      if channel_rt.channel is null then
        do('NO CONFIG EXISTS FOR CHANNEL - ',channel);
        return;
      end if;

      if offer_rec.BLOCK_FUNCTIONALITY like '%HOT%' then
        HOT := 1;
      end if;

      if channel_rt.channel = 'TAS' then
         r(v_case_scpt,offer_rec.script_id,'ENGLISH',channel_rt.channel,offer_rec.brand,case_sts_rt.id_number,offer_rec.CAMPAIGN_NAME,CSR_TEXT);
      end if;
      if channel_rt.channel = 'WEB' then
         r(v_case_scpt,offer_rec.script_id,'ENGLISH',channel_rt.channel,offer_rec.brand,case_sts_rt.id_number,offer_rec.CAMPAIGN_NAME,eng_text);
         r(v_case_scpt,offer_rec.script_id,'SPANISH',channel_rt.channel,offer_rec.brand,case_sts_rt.id_number,offer_rec.CAMPAIGN_NAME,SPA_TEXT);
      end if;
      if channel_rt.channel = 'IVR' then
        r(v_case_scpt,offer_rec.script_id,'ENGLISH',channel_rt.channel,offer_rec.brand,case_sts_rt.id_number,offer_rec.CAMPAIGN_NAME,ivr_scr_id);
        tts_english := '.';
        tts_spanish := '.';
      end if;
      if channel_rt.channel = 'SMS' then
         r(v_case_scpt,offer_rec.script_id,'ENGLISH','HANDSET',offer_rec.brand,case_sts_rt.id_number,offer_rec.CAMPAIGN_NAME,op_sms_text);
      end if;

      if v_title_scpt is not null then
        title := offer_rec.OFFER_TITLE||' ('||v_title_scpt||')';
        title := v_title||' ('||v_title_scpt||')'; -- NEW
      else
        title := offer_rec.OFFER_TITLE;
        title := v_title; -- NEW
      end if;

      if CSR_TEXT is not null or
        eng_text is not null or
        SPA_TEXT is not null or
        ivr_scr_id is not null or
        op_sms_text is not null then
        op_msg := 'Alert Found';
      end if;

      for offer_urls_rt in offer_urls(ip_offer_name =>offer_rec.CAMPAIGN_NAME,ip_channel =>channel)
      loop
        if offer_urls_rt.DISPLAY_URL = 'TAS' then
          OP_URL := offer_urls_rt.CAMPAIGN_URL;
        elsif offer_urls_rt.DISPLAY_URL = 'WEB' then
          op_url_text_en := offer_urls_rt.CAMPAIGN_URL;
          op_url_text_es := offer_urls_rt.CAMPAIGN_URL;
        elsif offer_urls_rt.DISPLAY_URL = 'IVR' then
          OP_URL := offer_urls_rt.CAMPAIGN_URL;
        end if;
      end loop;

  end campaign_alerts;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  function get_bp_url (ip_esn varchar2, ip_zip_code varchar2,ip_brand varchar2, ip_language varchar2, ip_carrier varchar2, ip_min varchar2, ip_part_class varchar2)
  return varchar2
  is
    v_1 varchar2(2000);
    v_ppe varchar2(30);
  begin
    for i in (
              select null brand_short,
                     (select x_param_value
                      from table_x_parameters
                      where x_param_name = decode(ip_brand,
                                                  'TRACFONE','TM_BP_URL_TF',
                                                  'NET10','TM_BP_URL_NT',
                                                  'SIMPLE_MOBILE','TM_BP_URL_SM',
                                                  'SAFELINK','TM_BP_URL_SL',
                                                  'STRAIGHT_TALK','TM_BP_URL_ST',
                                                  null
                                                  )) domain,
                    (select replace(x_param_value,'&pro=esn','&pro='||ip_esn)
                      from table_x_parameters
                      where x_param_name = decode('TRACFONE',
                                                  'TRACFONE','TM_BP_POST_URL_TF',
                                                  'NET10','TM_BP_POST_URL_NT',
                                                  'STRAIGHT_TALK','TM_BP_POST_URL_ST',
                                                  'SIMPLE_MOBILE','TM_BP_POST_URL_SM',
                                                  'SAFELINK','TM_BP_POST_URL_SL',
                                                  null
                                                  )) post_url,
                     zip.zip2 zip,
                     zip.locale locale,
                     '&productFamily=' product_family, -- DOES NOT COME FROM TABLE
                     zip.sitetype site_type,
                     zip.market /*||bp.bp_code*/ market, -- AFTER TEEBU'S EMAIL 3.22.2016
                     zip.gotophonelist go_to_phone_list
              from mapinfo.eg_zip2tech zip, mapinfo.eg_bptech bp
              where 1=1
              and zip.zip = ip_zip_code
              and bp.service = decode(ip_brand,'TRACFONE','TR','NET10','NT10','STRAIGHT_TALK','ST','SIMPLE_MOBILE','SIMPLE','SAFELINK','TR',ip_brand)
              and zip.language = decode(upper(ip_language),'ENG','EN','ENGLISH','EN','SPANISH','ES','SPA','SP','SPA','SP','EN')
              and zip.techkey = bp.techkey
              and zip.service = bp.service
              )
    loop
      v_1 := v_1||i.domain||i.post_url;
      if i.zip is not null then
        -- APPEND THE ZIP VARIABLE
        v_1 := v_1||i.zip;
      end if;
      if i.locale is not null then
        -- APPEND THE LOCALE
        v_1 := v_1||i.locale;
      end if;
  --    if v_product_family is not null then
  --      -- APPEND THE PRODUCT FAMILY
  --    end if;
      if i.site_type is not null then
        --APPEND THE SITE TYPE
        v_1 := v_1||i.site_type;
      end if;
      if i.market is not null then
        -- APPEND THE MARKET
        -- AFTER TEEBU'S EMAIL 3.22.2016
        if ip_carrier IN ('ATT','TMO') then
          v_1 := v_1||i.market||ip_carrier||'PROG';
        else
          v_1 := v_1||i.market;
        end if;
      end if;
  --    if v_gotophonelist is not null then
  --      -- APPEND TRUE
  --    end if;
  --    -- APPEND v_aid REGARDLESS IF NULL OR NOT
  --    if v_city is not null then
  --      -- APPEND CITY
  --    else
  --      -- APPEND NULL AS A STRING city=null
  --    end if;
    end loop;

    -- COMMENTED OUT THIS PORTION BELONGING TO CR42760 -  2G Migration - BrightPoint Store New Tab
    -- THIS WILL BE GOING OUT IN JUNE SO KEEPING THE CODE IN THE PROC
    if ip_min is not null then
      v_1 := v_1||'&min='||ip_min;
    end if;
    if ip_part_class is not null then
      select decode(get_param_by_name_fun(ip_part_class_name => ip_part_class,ip_parameter => 'NON_PPE'),'0','YES','1','NO','NOT_FOUND') is_ppe
      into v_ppe
      from dual;
      v_1 := v_1||'&is_ppe='||v_ppe;
    end if;

    return v_1;
  --tf - v_1||'&city=null&state=null'
  --sl - v_1||'&city=null&state=null'
  --nt - v_1||''
  --st - v_1||'&city=MIAMI&state=null'

  end get_bp_url;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  function get_esn (ip_short_serial varchar2, ip_min varchar2)
  return varchar2
  is
    ret_esn varchar2(30);
    n_esn_obj number;
  begin
    if ip_min is not null then
      select part_to_esn2part_inst
      into n_esn_obj
      from table_part_inst
      where 1=1
      and   x_domain = 'LINES'
      and   part_serial_no = ip_min;

      select part_serial_no
      into ret_esn
      from table_part_inst
      where x_domain = 'PHONES'
      and objid = n_esn_obj;

      if instr(ret_esn,ip_short_serial)>0 then
        return ret_esn;
      else
        return 'ESN_NOT_FOUND';
      end if;

    else
      return ip_short_serial;
    end if;
    return ret_esn;
  exception
    when others then
      return ip_short_serial;
  end get_esn;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
    procedure get_device_info(p_esn varchar2,
                              p_min varchar2,
                              op_code_number out varchar2,
                              op_phone_gen out varchar2,
                              op_brand out varchar2,
                              op_queue_name out varchar2,
                              op_part_class out varchar2,
                              op_zipcode out varchar2)
    is
      v_x_part_inst2site_part sa.table_part_inst.x_part_inst2site_part%type;
      v_min varchar2(30) := p_min; -- '6019511581'
    begin
      select i.x_part_inst_status,
             get_param_by_name_fun(ip_part_class_name => pc.name, ip_parameter => 'PHONE_GEN') phone_gen,
             get_param_by_name_fun(ip_part_class_name => pc.name, ip_parameter => 'BUS_ORG') brand,
             pc.name,
             x_part_inst2site_part
      into   op_code_number,op_phone_gen,op_brand,op_part_class,v_x_part_inst2site_part
      from   table_part_class pc,
             table_part_num pn,
             table_mod_level m,
             table_part_inst i
      where 1=1
      and   i.x_domain = 'PHONES'
      and   pc.objid = pn.part_num2part_class
      and   pn.objid = m.part_info2part_num
      and   m.objid  = i.n_part_inst2part_mod
      and   i.part_serial_no =  p_esn;

      begin
        select  x_zipcode
        into    op_zipcode
        from    table_site_part
        where   objid = v_x_part_inst2site_part;
      exception
        when others then
          dbms_output.put_line('get_device_info - exception while obtaining the zipcode');
      end;

      begin
        if v_min is null then
          dbms_output.put_line('MIN IS NULL...');
          select decode(prog_type,4,'ATT',5,'T-MOBILE',7,'CLARO',8,'SPRINT',9,'VERIZON','NA') x_queue_name
          into   op_queue_name
          from   carriersimpref,
                 table_part_num
          where  sim_profile in (select table_part_num.part_number
          from   table_part_inst, table_x_sim_inv, table_mod_level, table_part_num
          where  part_serial_no = p_esn
          and    x_domain = 'PHONES'
          and    x_iccid = table_x_sim_inv.x_sim_serial_no
          and    table_x_sim_inv.x_sim_inv2part_mod=table_mod_level.objid
          and    table_mod_level.part_info2part_num=table_part_num.objid)
          and table_part_num.part_number =sim_profile
          and rownum < 2;
      else
        dbms_output.put_line('MIN IS FOUND...');
        -- THE ESN / MIN RELATIONSHIP IS CHECKED IN ELIGIBILITY VALIDATIONS
        select p.x_queue_name
        into   op_queue_name
        from   table_x_parent p,
               table_x_carrier_group g,
               table_x_carrier c
        where  p.objid = g.x_carrier_group2x_parent
        and    g.objid = c.carrier2carrier_group
        and    c.x_carrier_id = (select car.x_carrier_id
                                 from   table_x_carrier car,
                                        table_part_inst mp
                                 where  car.objid = mp.part_inst2carrier_mkt
                                 and    mp.part_serial_no = v_min);
      end if;
      exception
        when others then
          dbms_output.put_line('get_device_info - exception while obtaining the min');
          op_queue_name := 'ALL';
      end;

--      dbms_output.put_line('op_phone_gen ==>'||op_phone_gen);
--      dbms_output.put_line('op_brand ==>'||op_brand);
--      dbms_output.put_line('op_queue_name ==>'||op_queue_name);
--      dbms_output.put_line('v_min ==>'||v_min);

    exception
      when others then
        null;
    end get_device_info;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
    function flash_action (ip_esn varchar2,
                           ip_status varchar2,
                           ip_carrier varchar2,
                           ip_part_class varchar2)
    return varchar2
    is
      v_hot           table_alert.hot%type;
      v_action_result table_alert.type%type;
    begin
      begin
        select a.hot,a.type
        into   v_hot,v_action_result
        from   table_alert a,
               esn_to_alert m
        where  a.title like '2G Migration Alert Text%'
        and    a.objid = m.alert_objid
        and    m.x_esn = ip_esn
        and rownum < 2;
      exception
        when others then
          null;
      end;

      if v_hot = '0' or v_hot is null then
        for i in (select a.hot,a.type
                  from   table_alert a,
                         table_x_alert_by_carrier m,
                         alert_by_carrier_to_pc c2p
                  where  a.title like '2G Migration Alert Text%'
                  and    a.objid = m.alert_objid
                  and    m.alert_objid = c2p.carrier_alert_objid
                  and    m.case_status = 'NO_CASE'
                  and    m.status = ip_status
                  and   (m.carrier = ip_carrier
                  or     m.carrier = 'ALL')
                  and   (c2p.part_class = ip_part_class
                  or     c2p.part_class = 'ALL')
                  )
        loop
          if v_hot != '1' or v_hot is null then
            if i.hot > v_hot or v_hot is null then
              v_hot := i.hot;
              v_action_result := i.type;
--              dbms_output.put_line('VALUES CHANGING ');
            end if;
          end if;
        end loop;
      end if;

      return v_action_result;

    exception
      when others then
        --dbms_output.put_line('ERROR ==>'||sqlerrm);
        return null;
    end flash_action;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
    function is_beyond_eco_repair(ip_code_number varchar2)
    return varchar2
    is
      v_unrepairable table_x_code_table.x_code_number%type;
    begin
      select x_code_number
      into   v_unrepairable
      from table_x_code_table
      where x_code_name = 'UNREPAIRABLE'
      and   x_code_type like 'PS';

      if ip_code_number = v_unrepairable then
        return 'DO_NOT_CONTINUE';
      end if;

      return 'CONTINUE';
    exception
      when others then
        return 'CONTINUE';
    end is_beyond_eco_repair;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  function determine_units (ip_units_to_transfer varchar2)
  return varchar2
  is
    ret_units varchar2(300)  := 'NO_SERVICE_TRANSFER||NO_SERVICE_TRANSFER';
  begin
    -- 1. ATTEMPT FIRST TO GET UNITS FROM OTA TABLES
    -- ip_call_trans_objid IS NO LONGER REQUIRED BECAUSE THE OBJID IS USELESS IN THE PREVIOUS
    -- RESIDING QUERY. NOW REMOVED
    -- IT'S AN OBJID THAT IS REQUIRED TO BE FED TO ANOTHER CBO SERVICE
      if ip_units_to_transfer is null then
        ret_units := '0';
      else
        ret_units := ip_units_to_transfer;
      end if;

    return ret_units;
  exception
    when others then
      return ret_units;
  end determine_units;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--  function ret_script(ip_channel varchar2, ip_brand varchar2, ip_lang varchar2)
--  return varchar2
--  is
--    OP_SCRIPT_TEXT VARCHAR2(4000);
--    OP_DUMP VARCHAR2(2000);
--    OP_PUBLISH_DATE DATE;
--    OP_SM_LINK VARCHAR2(200);
--  begin
--    SCRIPTS_PKG.GET_SCRIPT_PRC(
--      IP_SOURCESYSTEM => ip_channel,
--      ip_brand_name => ip_brand,
--      IP_SCRIPT_TYPE => 'TEC',
--      IP_SCRIPT_ID => '123',
--      IP_LANGUAGE => ip_lang,
--      IP_CARRIER_ID => NULL,
--      IP_PART_CLASS => NULL,
--      op_objid => OP_DUMP,
--      OP_DESCRIPTION => OP_DUMP,
--      OP_SCRIPT_TEXT => OP_SCRIPT_TEXT,
--      OP_PUBLISH_BY => OP_DUMP,
--      OP_PUBLISH_DATE => OP_PUBLISH_DATE,
--      OP_SM_LINK => OP_DUMP
--    );
--    dbms_output.put_line('OP_SCRIPT_TEXT = ' || op_script_text);
--    return op_script_text;
--  end ret_script;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  function has_a_warehouse_case(ip_esn varchar2,ip_flash_start_date date default null)
  return varchar2
  is
    v_has_case boolean := false;
    v_2g_migration_start_date table_alert.start_date%type; -- THIS IS A DATE FORMAT
  begin
    -- CASE DATE HAS TO BE WHEN 2G MIGRATION FLASH STARTED
    -- TODO: PENDING CHECK AGAINST ALL WAREHOUSE TYPE, QUERY BELOW MAY CHANGE
    -- GOING TO USE THE DATE THE PROJECT FIRST RELEASED on 3/3/2016
    v_2g_migration_start_date := to_date('03/03/2016','MM/DD/YYYY');

    for i in (select id_number,x_case_type,title,creation_time from table_case where 1=1 and  x_esn = ip_esn and  x_case_type = 'Warehouse' and  title = 'Goodwill Replacement' union
              select id_number,x_case_type,title,creation_time from table_case where 1=1 and  x_esn = ip_esn and  x_case_type = 'Warehouse' and  title = 'System Error Replacement' union
              select id_number,x_case_type,title,creation_time from table_case where 1=1 and  x_esn = ip_esn and  x_case_type = 'Warehouse' and  title = '2G Migration' union
              select id_number,x_case_type,title,creation_time from table_case where 1=1 and  x_esn = ip_esn and  x_case_type = 'Warranty' and  title = 'Goodwill Replacement' union
              select id_number,x_case_type,title,creation_time from table_case where 1=1 and  x_esn = ip_esn and  x_case_type = 'Warranty' and  title = 'Defective Phone' union
              select id_number,x_case_type,title,creation_time from table_case where 1=1 and  x_esn = ip_esn and  x_case_type = 'Warranty' and  title = 'Defective Phone' union
              select id_number,x_case_type,title,creation_time from table_case where 1=1 and  x_esn = ip_esn and  x_case_type = 'Technology Exchange' and  title = 'Digital Exchange' union
              select id_number,x_case_type,title,creation_time from table_case where 1=1 and  x_esn = ip_esn and  x_case_type = 'Technology Exchange' and  title = 'Special Project Tech Exchange')
      loop
        dbms_output.put_line(i.id_number||':'||i.x_case_type||':'||i.title||':'||i.creation_time);
        --if trunc(i.creation_time) <= trunc(v_2g_migration_start_date) then
        if trunc(i.creation_time) between trunc(v_2g_migration_start_date) and sysdate then
          dbms_output.put_line('CASE ALREADY EXISTS');
          return i.id_number;
        else
          dbms_output.put_line('CREATE THE CASE');
        end if;
      end loop;

    return null;

  exception
    when others then
      null;
  end has_a_warehouse_case;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  function offer_already_redeemed(ip_esn varchar2)
  return boolean
  is
  begin
    -- THIS IS A PLACE HOLDER, THIS LOGIC IS STILL PENDING.
    return false;
  end offer_already_redeemed;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure eligibility_validations(p_min varchar2, p_esn varchar2, op_rslt out boolean, op_err_msg out varchar2, op_err_num out varchar2, op_brand out varchar2, op_zipcode out varchar2, op_code_number out varchar2, op_phone_gen out varchar2, op_queue_name out varchar2, op_part_class out varchar2
  )
  is
    is_a_company_line number := 0;
    line_and_phone_linked number := 0;
    v_sp_status table_site_part.part_status%type;
    expired_time number;
    v_ticket_id table_case.id_number%type;
    v_brand  table_bus_org.org_id%type;
    offer_already_redeemed boolean := false;
    v_zipcode table_site_part.x_zipcode%type;
  begin

    -- ESN provided is a 2G handset,  (Status <> BER - Beyond Economic Repair)
    -- Get Brand
    sa.tech_migration_pkg.get_device_info(p_esn => p_esn,
                                      p_min => p_min,
                                      op_code_number => op_code_number,
                                      op_phone_gen => op_phone_gen,
                                      op_brand => op_brand,
                                      op_queue_name => op_queue_name,
                                      op_part_class => op_part_class,
                                      op_zipcode => op_zipcode);

    if op_brand = 'NOT FOUND' then
      op_rslt := false;
      op_err_num := '1';
      op_err_msg := 'UNABLE TO DETERMINE BRAND.';
      return;
    end if;

    if op_phone_gen != '2G' then
      op_rslt := false;
      op_err_num := '5';
      op_err_msg := 'DEVICE IS NOT 2G';
      return;
    end if;

--    dbms_output.put_line('v_phone_gen            ==> '||v_phone_gen);
--    dbms_output.put_line('op_brand                ==> '||op_brand);

    if sa.tech_migration_pkg.is_beyond_eco_repair(ip_code_number => op_code_number) = 'DO_NOT_CONTINUE' then
      op_rslt := false;
      op_err_num := '2';
      op_err_msg := 'DEVICE IS BEYOND ECONOMIC REPAIR';
      return;
    end if;

    -- Line in Inventory
    -- Line linked to esn or partial esn provided (last 4)
    if p_min is not null then

      select count(*)
      into is_a_company_line
      from table_part_inst
      where 1=1
      and   x_domain = 'LINES'
      and   part_serial_no = p_min;

      if is_a_company_line <=0 then
        op_rslt := false;
        op_err_num := '2';
        op_err_msg := 'PHONE NUMBER NOT FROM A CUSTOMER';
        return;
      end if;

      select count(*) cnt
      into line_and_phone_linked
      from table_part_inst
      where 1=1
      and   part_serial_no = p_min
      and   x_domain = 'LINES'
      and   part_to_esn2part_inst in (select objid
                                      from table_part_inst
                                      where part_serial_no = p_esn);
      --dbms_output.put_line('line_and_phone_match  ==> '||line_and_phone_linked);
      if line_and_phone_linked <=0 then
        op_rslt := false;
        op_err_num := '3';
        op_err_msg := 'THE LAST FOUR OF SERIAL NUMBER DON''T MATCH THE SERIAL NUMBER OF THE PHONE NUMBER ENTERED.';
        return;
      end if;
    end if;

    -- No previous cases exists.
    -- Get ticket if Available
    v_ticket_id := has_a_warehouse_case(ip_esn => p_esn);
--    dbms_output.put_line('v_ticket_id            ==> '||v_ticket_id);
    if v_ticket_id is not null then
        op_rslt := false;
        op_err_num := '4';
        op_err_msg := 'CASE ALREADY EXISTS';
        return;
    end if;

    if offer_already_redeemed then
        op_rslt := false;
        op_err_num := '6';
        op_err_msg := 'OFFER ALREADY REDEEMED';
        return;
    end if;

    op_rslt := true;
    op_err_num := '0';
    op_err_msg := 'SUCCESS';

  exception
    when others then
      op_rslt := false;
      op_err_num := '-1';
      op_err_msg := 'FAIL - '||sqlerrm;
  end eligibility_validations;


  procedure eligibility_validations(p_min varchar2, p_esn varchar2, op_rslt out boolean, op_err_msg out varchar2, op_err_num out varchar2)
  is
    v_brand varchar2(50);
    v_zipcode varchar2(10);
    v_code_number varchar2(50);
    v_phone_gen varchar2(50);
    v_queue_name varchar2(50);
    v_part_class varchar2(50);
  begin
    eligibility_validations(p_min => p_min, p_esn => p_esn, op_rslt => op_rslt, op_err_msg => op_err_msg, op_err_num => op_err_num, op_brand => v_brand, op_zipcode => v_zipcode, op_code_number => v_code_number, op_phone_gen => v_phone_gen, op_queue_name => v_queue_name, op_part_class => v_part_class);
  end;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure verify_elegibility( p_source_system  in   varchar2,
                                p_login_name     in   varchar2,
                                p_language       in   varchar2,
                                p_esn            in   varchar2,  --Full or Last 4
                                p_min            in   varchar2,
                                p_zipcode        out varchar2,
                                p_result         out varchar2, -- (UPGRADE,PURCHASE,UPG_PURCH,NOT_ELEGIBLE)
                                p_purchase_link  out varchar2, --(If applicable)
                                p_ticket_id      out varchar2,  --(If already created)
                                p_brand          out varchar2,
                                p_err_code       out varchar2,
                                p_err_msg        out varchar2)
  as
    line_and_phone_linked number := 0;
    v_phone_gen varchar2(30);
    --v_is_beyond_eco_repair varchar2(30);
    v_x_part_inst_status table_site_part.part_status%type;
    expired_time number;
    v_esn sa.table_part_inst.part_serial_no%type;

    b_validations_passed boolean := false;
    v_queue_name table_x_parent.x_queue_name%type; -- varchar2(50);
    v_part_class table_part_class.name%type; -- varchar2(40);
    v_code_number varchar2(30);

  begin
--        dbms_output.put_line('p_source_system        ==> '||p_source_system);
--        dbms_output.put_line('p_login_name           ==> '||p_login_name);
--        dbms_output.put_line('p_language             ==> '||p_language);
--        dbms_output.put_line('p_esn                  ==> '||p_esn); --Full or Last 4
--        dbms_output.put_line('p_min                  ==> '||p_min);

    if p_min is null then
      -- THE IDEA IS TO MOVE PEOPLE WHO ARE ALREADY ACTIVE. THEY SHOULD NOT BE COMING THIS FAR W/NO MIN
      p_err_code := '8';
      p_err_msg := 'THE MIN IS REQUIRED IN ORDER TO CONTINUE';
      return;
    end if;

    v_esn := get_esn(ip_short_serial => p_esn, ip_min => p_min);

    eligibility_validations(p_min => p_min, p_esn => v_esn, op_rslt => b_validations_passed, op_err_msg => p_err_msg, op_err_num => p_err_code, op_brand => p_brand, op_zipcode => p_zipcode, op_code_number => v_code_number, op_phone_gen => v_phone_gen, op_queue_name => v_queue_name, op_part_class => v_part_class);

    dbms_output.put_line('p_err_code ==>'||p_err_code);
    dbms_output.put_line('p_err_msg ==>'||p_err_msg);

    if b_validations_passed then
      p_result := flash_action (ip_esn => v_esn, ip_status => v_code_number, ip_carrier => v_queue_name, ip_part_class => v_part_class);

      if p_result is null then
        p_brand := null;
        p_result := 'NOT_ELEGIBLE';
        p_err_code := '5';
        p_err_msg  := 'DEVICE IS NOT 2G';-- THIS MESSAGE IS NOT NECESSARILY TRUE. BECAUSE THE ERROR CODE IS MAPPED TO THREE CONDITIONS (2G, GSM, AT&T)
        return;
      end if;

      p_purchase_link := get_bp_url (ip_esn => v_esn, ip_zip_code =>p_zipcode,ip_brand =>p_brand, ip_language =>p_language, ip_carrier => v_queue_name, ip_min => p_min, ip_part_class => v_part_class);
    else
      p_result := 'NOT_ELEGIBLE';
      p_purchase_link := null;
    end if;

  exception
    when no_data_found then
      p_err_code := '7';
      p_err_msg := 'ESN NOT FOUND';
    when others then
      p_err_code := '-2';
      p_err_msg := 'FAIL - '||sqlerrm;
  end verify_elegibility;

  procedure create_request (p_source_system  in varchar2 DEFAULT 'TAS',
                            p_login_name     in varchar2 DEFAULT 'CBO',
                            p_language       in   varchar2,
                            p_esn            in   varchar2,
                            p_min            in   varchar2,
                            p_first_name in varchar2,
                            p_last_name in varchar2,
                            p_address_1 in varchar2,
                            p_address_2 in varchar2,
                            p_city in varchar2,
                            p_state in varchar2,
                            p_zipcode in varchar2,
                            p_email in varchar2,
                            p_contact_phone in varchar2,
                            p_units_to_transfer in varchar2,
                            p_call_trans_objid in varchar2,  -- OBJID OTA Balance Inquiry (THIS IS NOW A DEAD INPUT AS OF 4/6/2016. BECAUSE THE OBJID THE CBO RETURNS IS NOT MEANT FOR A DB LOOK UP. IT'S TO PASS THROUGH TO ANOTHER CBO BALANCE CALL)
                            p_ticket_id out varchar2,
                            p_err_code out varchar2,
                            p_err_msg  out varchar2)
  as
    new_case_id_format    varchar2 (100) := null;

    -- added for verify eligiblity
    op_zipcode varchar2(2000);
    op_result varchar2(2000);
    op_purchase_link varchar2(2000);
    op_ticket_id varchar2(2000);
    op_brand varchar2(2000);

    --	added for Get Replacement
    v_case_conf_objid varchar2(30);
    v_case_type       varchar2(30) := upper('WAREHOUSE');
    v_title           varchar2(100) := upper('2G Migration');
    v_repl_logic      varchar2(300) := '';
    v_part_number     varchar2(3000);
    v_sim_profile     varchar2(3000);
    v_sim_suffix      varchar2(3000);
    v_x_part_inst2contact sa.table_part_inst.x_part_inst2contact%type;
    v_op_case_objid   sa.table_case.objid%type;
    -- added for Contact Creation
    v_u_objid sa.table_user.objid%type;
    v_p_repl_units number;
    v_case_detail  sa.table_x_case_detail.x_value%type;
    -- added for Case Dispatch
    v_queue sa.table_queue.title%type;
    v_ticket_id table_case.id_number%type;
  begin

    v_ticket_id := has_a_warehouse_case(ip_esn => p_esn);
    dbms_output.put_line('v_ticket_id            ==> '||v_ticket_id);
    if v_ticket_id is not null then
        p_err_code := '4';
        p_err_msg := 'CASE ALREADY EXISTS';
        return;
    end if;

    --	VERIFY_ELEGIBILITY
    verify_elegibility(p_source_system  => p_source_system,
                       p_login_name     => p_login_name,
                       p_language       => p_language,
                       p_esn            => p_esn, --Full or Last 4
                       p_min            => p_min,
                       p_zipcode        => op_zipcode, -- no need for this value, it's passed in the signature p_zipcode
                       p_result         => op_result, -- (UPGRADE,PURCHASE,UPG_PURCH,NOT_ELEGIBLE)
                       p_purchase_link  => op_purchase_link, --(If applicable)
                       p_ticket_id      => op_ticket_id, --(If already created)
                       p_brand          => op_brand,
                       p_err_code       => p_err_code,
                       p_err_msg        => p_err_msg);

    if op_result = 'NOT_ELEGIBLE' then
      p_err_code := '1';
      p_err_msg := 'ESN Not Eligible';
      return;
    end if;

--    dbms_output.put_line('verify_elegibility     ==> ');
--    dbms_output.put_line('p_result               ==> '||op_result);
--    dbms_output.put_line('p_purchase_link        ==> '||op_purchase_link);
--    dbms_output.put_line('p_ticket_id            ==> '||op_ticket_id);
--    dbms_output.put_line('p_brand                ==> '||op_brand);
--    dbms_output.put_line('p_err_code             ==> '||p_err_code);
--    dbms_output.put_line('p_err_msg              ==> '||p_err_msg);
--    dbms_output.put_line('verify_elegibility     ==> ');

    --	Get Replacement
    op_zipcode := p_zipcode;

    select objid,x_case_type,x_title,x_repl_logic
    into   v_case_conf_objid,v_case_type,v_title,v_repl_logic
    from   table_x_case_conf_hdr
    where s_x_case_type = v_case_type
    and s_x_title = v_title;

    sa.adfcrm_case.get_repl_part_number(
              ip_case_conf_objid => v_case_conf_objid,
              ip_case_type       => v_case_type,
              ip_title           => v_title,
              ip_esn             => p_esn,
              ip_sim             => null, -- I DOUBT 2G HAS GSM, BUT, VERIFY ANYWAY
              ip_repl_logic      => v_repl_logic,
              ip_zipcode         => op_zipcode,  -- IN / OUT VARIABLE
              op_part_number     => v_part_number,
              op_sim_profile     => v_sim_profile,
              op_sim_suffix      => v_sim_suffix);

    dbms_output.put_line('sa.adfcrm_case.get_repl_part_number =========================> ');
    dbms_output.put_line('v_case_conf_objid      ==> '||v_case_conf_objid);
    dbms_output.put_line('v_case_type            ==> '||v_case_type);
    dbms_output.put_line('v_title                ==> '||v_title);
    dbms_output.put_line('v_repl_logic           ==> '||v_repl_logic);
    dbms_output.put_line('op_zipcode             ==> '||op_zipcode);
    dbms_output.put_line('op_part_number         ==> '||v_part_number);
    dbms_output.put_line('op_sim_profile         ==> '||v_sim_profile);
    dbms_output.put_line('op_sim_suffix          ==> '||v_sim_suffix);


    -- Get the User Info
    begin
      select objid
      into  v_u_objid
      from table_user
      where s_login_name = p_login_name;
    exception
      when others then
        null;
    end;

    -- Get the Contact Info
    begin
      select x_part_inst2contact
      into v_x_part_inst2contact
      from table_part_inst
      where part_serial_no = p_esn;
    exception
      when others then
        null; -- create the contact        v_x_part_inst2contact

        CONTACT_PKG.CREATECONTACT_PRC(
          P_ESN => P_ESN,
          P_FIRST_NAME => p_first_name,
          P_LAST_NAME => p_last_name,
          P_MIDDLE_NAME => null,
          P_PHONE => p_contact_phone,
          P_ADD1 => p_address_1,
          P_ADD2 => p_address_2,
          P_FAX => null,
          P_CITY => p_city,
          P_ST => p_state,
          P_ZIP => p_zipcode,
          P_EMAIL => p_email,
          P_EMAIL_STATUS => null,
          P_ROADSIDE_STATUS => null,
          P_NO_NAME_FLAG => null,
          P_NO_PHONE_FLAG => null,
          P_NO_ADDRESS_FLAG => null,
          P_SOURCESYSTEM => p_source_system,
          P_BRAND_NAME => op_brand,
          P_DO_NOT_EMAIL => null,
          P_DO_NOT_PHONE => null,
          P_DO_NOT_MAIL => null,
          P_DO_NOT_SMS => null,
          P_SSN => null,
          P_DOB => null,
          P_DO_NOT_MOBILE_ADS => null,
          p_contact_objid => v_x_part_inst2contact,
          p_err_code => p_err_code,
          p_err_msg => p_err_msg
        );

        dbms_output.put_line('CREATECONTACT_PRC ERR CODE ==> '||p_err_code||' <==');
        dbms_output.put_line('CREATECONTACT_PRC ERR NUM  ==> '||p_err_msg||' <==');
        dbms_output.put_line('CREATECONTACT_PRC C OBJID  ==> '||v_x_part_inst2contact||' <==');
    end;

    dbms_output.put_line('CONTACT OBJID  ==> '||v_x_part_inst2contact||' <==');
    begin
      if op_brand in ('STRAIGHT_TALK','SIMPLE_MOBILE') then -- PER NATALIO AFTER MEETING W/YOSE ALWAYS DO NO_SERVICE_TRANSFER FOR ST AND SM - 2/9/16
        v_case_detail := 'NO_SERVICE_TRANSFER||NO_SERVICE_TRANSFER';
      else
        v_case_detail := determine_units (ip_units_to_transfer => p_units_to_transfer);
      end if;
        v_p_repl_units := v_case_detail; -- IF DETERMINE UNITS BRINGS BACK A NUMBER, IT WILL FILL THIS VARIABLE
        v_case_detail := null; -- IF DETERMINE UNITS BRINGS BACK A NUMBER, CLEAN THIS VARIABLE
        -- IF V_CASE_DETAIL RETURNS VARCHAR, IT WILL EXCEPTION AND RETURN THE CASE DETAIL TO THE CREATE CASE PROC. THIS IS THE CORRECT BEHAVIOUR.
        -- IF DETERMINE_UNITS COMES BACK 0, THEN IT'S A NO_SERVICE_TRANSFER
        -- SINCE THIS IS ONLY TRACFONE THAT WE ARE SERVICING (NT10 NOT IN SCOPE) THEN IT'S EITHER AN AUTOMATIC NO_SERVICE_TRANSFER OR GET THE BALANCE.
        -- TRACFONE DOES NOT HAVE SERVICE PLANS AT THE MOMENT.
        if v_p_repl_units = 0 then
          v_case_detail := 'NO_SERVICE_TRANSFER||NO_SERVICE_TRANSFER';
        end if;
    exception
      when others then
        null;
    end;

    dbms_output.put_line('REPL UNITS ==> '||v_p_repl_units||' <==');
    -- UNITS TO TRANSFER IS NOT INSERTED ON THE WEB, BUT, IT IS IN TAS
    -- ADDING THIS TO THE CASE DETAIL
    if v_p_repl_units > 0 then
      v_case_detail := 'UNITS_TO_TRANSFER||'||v_p_repl_units;
    end if;
    --	Create Case
    sa.clarify_case_pkg.create_case(P_TITLE => v_title,
                                    p_case_type => v_case_type,
                                    p_status => 'Pending',
                                    p_priority => 'High', --Options are Low,Medium,High, or Urgent
                                    p_issue => v_title,
                                    p_source => v_title, -- maps to case_type_lvl3
                                    P_POINT_CONTACT => p_source_system, --customer_code
                                    P_CREATION_TIME => sysdate,
                                    P_TASK_OBJID => null,
                                    p_contact_objid => v_x_part_inst2contact,
                                    P_USER_OBJID => v_u_objid,
                                    P_ESN => p_esn,
                                    P_PHONE_NUM => p_contact_phone,
                                    P_FIRST_NAME => p_first_name,
                                    P_LAST_NAME => p_last_name,
                                    P_E_MAIL => p_email,
                                    P_DELIVERY_TYPE => null,
                                    P_ADDRESS => p_address_1||'||'||p_address_2,
                                    P_CITY => p_city,
                                    p_state => p_state,
                                    p_zipcode => p_zipcode,
                                    P_REPL_UNITS => v_p_repl_units,
                                    p_fraud_objid => null,
                                    p_case_detail => v_case_detail,
                                    P_PART_REQUEST => v_part_number||v_sim_suffix, --v_part_req,
                                    P_ID_NUMBER => p_ticket_id,
                                    P_CASE_OBJID => v_op_case_objid,
                                    P_ERROR_NO => p_err_code,
                                    P_ERROR_STR => p_err_msg);

    dbms_output.put_line('REPL PART NUMBER   = ' || v_part_number);
    dbms_output.put_line('SIM PROFILE        = ' || v_sim_profile);
    dbms_output.put_line('SIM SUFFIX         = ' || v_sim_suffix);
    dbms_output.put_line('CASE OBJID         = ' || v_op_case_objid);
    dbms_output.put_line('CASE ID            = ' || p_ticket_id);
    dbms_output.put_line('p_err_code       = ' || p_err_code);
    dbms_output.put_line('OP_ERROR_MSG       = ' || p_err_msg);

    begin
      select table_queue.title
      into   v_queue
      from table_x_case_dispatch_conf
            ,table_x_case_conf_hdr
            ,table_queue
       where dispatch2conf_hdr = table_x_case_conf_hdr.objid
       and table_x_case_dispatch_conf.priority2gbst_elm=-1
       and table_x_case_dispatch_conf.status2gbst_elm=-1
       and table_x_case_conf_hdr.objid = v_case_conf_objid
       and table_queue.objid = table_x_case_dispatch_conf.dispatch2queue;
    exception
    when others then
      dbms_output.put_line('QUEUE IS EMPTY       = ' || v_queue|| ' - '||sqlerrm);
      p_err_code := '-100000';
    end;

    begin
	   p_err_msg := sa.TECH_MIGRATION_PKG.add_case_dtl_records (p_case_id => p_ticket_id);
	 exception
	 	when others then
	 		null;
	end;

    if p_err_code != '-100000' then
      --	Dispatch Case
      sa.clarify_case_pkg.dispatch_case (p_case_objid => v_op_case_objid,
                                         p_user_objid => v_u_objid,
                                         p_queue_name => v_queue,
                                         p_error_no => p_err_code,
                                         p_error_str => p_err_msg);

      dbms_output.put_line('p_err_code       = ' || p_err_code);
      dbms_output.put_line('OP_ERROR_MSG       = ' || p_err_msg);

      --	Return Info.
      p_err_code := '0';
      p_err_msg := 'SUCCESS';
    end if;
  exception
    when others then
      p_err_code := '-2';
      p_err_msg := sqlerrm;
  END CREATE_REQUEST;


  function add_case_dtl_records (p_case_id in varchar2) return varchar2
  as
    cursor c1 is
    select table_case.objid,table_x_case_conf_dtl.x_field_name
    from sa.table_x_case_conf_hdr,sa.table_x_case_conf_dtl,sa.table_x_mtm_case_hdr_dtl,sa.table_case
    where mtm_conf2conf_dtl=table_x_case_conf_dtl.objid
    and mtm_conf2conf_hdr=table_x_case_conf_hdr.objid
    and table_x_case_conf_hdr.x_case_type =table_case.x_case_type
    and table_x_case_conf_hdr.x_title =table_case.title
    and table_case.id_number = p_case_id
    and not exists (select d2.objid from sa.table_x_case_detail d2 where d2.detail2case=table_case.objid
                    and d2.x_name = table_x_case_conf_dtl.x_field_name);

    v_value varchar2(30);

    function get_install_date(p_case_id varchar2)
    return varchar2
    as
      install_date date;
      n_is_refurb number;
      part_serial_no varchar2(30);

    begin
      select x_esn
      into part_serial_no
      from table_case
      where id_number = p_case_id;

      select count(1)
      into   n_is_refurb
      from   table_site_part sp_a
      where  sp_a.x_service_id = part_serial_no
      and    sp_a.x_refurb_flag = 1;

      if n_is_refurb = 0 then
        select min(install_date)
        into   install_date
        from   sa.table_site_part
        where  x_service_id = part_serial_no
        and    part_status || '' in ('Active','Inactive');
      else
        select min(install_date)
        into   install_date
        from   table_site_part sp_b
        where  sp_b.x_service_id = part_serial_no
        and    sp_b.part_status || '' in ('Active','Inactive')
        and    nvl(sp_b.x_refurb_flag,0) <> 1;
      end if;

      return to_char(install_date,'mm/dd/yyyy');
    exception
      when others then
        return null;
    end get_install_date;

  begin


     for r1 in c1 loop

        if r1.x_field_name= 'ACTIVATION_DATE' then
           v_value := get_install_date(p_case_id);
        else
           v_value := null;
        end if;

        insert into sa.table_x_case_detail (objid,x_name,x_value,detail2case)
        values (sa.seq('x_case_detail'),r1.x_field_name,v_value,r1.objid);

        commit;

     end loop;

     return 'COMPLETED';

  exception
     when others then return sqlerrm;

  end add_case_dtl_records;

END TECH_MIGRATION_PKG;
/