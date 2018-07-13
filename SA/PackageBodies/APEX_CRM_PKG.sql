CREATE OR REPLACE PACKAGE BODY sa."APEX_CRM_PKG" AS
--------------------------------------------------------------------------------------------
--$RCSfile: APEX_CRM_PKG_BODY.sql,v $
--$Revision: 1.66 $
--$Author: nguada $
--$Date: 2017/11/03 18:07:32 $
--$ $Log: APEX_CRM_PKG_BODY.sql,v $
--$ Revision 1.66  2017/11/03 18:07:32  nguada
--$ CR54247
--$
--$ Revision 1.65  2017/08/14 14:40:36  oimana
--$ CR51768 - Remove call to TABLE_TIME_BOMB from entire process.
--$
--$ Revision 1.64  2017/06/15 21:05:33  mmunoz
--$ CR50846 611611 Survey integration, excluding SURVEY OFFER from recent interaction
--$
--$ Revision 1.63  2017/06/02 19:30:33  nguada
--$ REL862_TAS
--$
--$ Revision 1.62  2017/01/18 18:35:32  nguada
--$ WFM_TAS_01
--$
--$ Revision 1.61  2016/10/25 15:39:13  amishra
--$ CR44443
--$
--$ Revision 1.60  2016/10/25 15:05:59  amishra
--$ Making changes to improcve the performance for query that fetches recent interactions
--$
--$ Revision 1.59  2016/09/30 17:27:53  amishra
--$ CR44443 - Reverted back cahnges. Now re-applying changes on top of 1.54 , ignoring other later revs
--$
--$ Revision 1.54  2015/05/06 20:12:17  hcampano
--$ CR33549 - Access Type Change for Project Armor
--$
--$ Revision 1.53  2015/03/03 21:19:40  mmunoz
--$ CR32818 using x_sl_currentvals instead of x_sl_hist
--$
--$ Revision 1.52  2015/01/06 15:25:57  mmunoz
--$ get_cntct_rslt_tas overloaded to add Lifeline ID and do not break other branches
--$
--$ Revision 1.51  2014/12/02 16:15:24  hcampano
--$ TAS_2014_10C - Fixed Recent Interactions
--$
--$ Revision 1.50  2014/10/16 13:05:17  hcampano
--$ TAS_2014_10A, TAS_2014_10B
--$
--$ Revision 1.49  2014/10/16 12:24:57  nguada
--$ change on email search criteria
--$
--$ Revision 1.48  2014/07/29 14:39:46  hcampano
--$ CR29054 - Fix broken StraightTalk unsubscribe. (TAS affected objects changes) TAS_2014_06
--$
--$ Revision 1.47  2014/01/03 16:12:39  hcampano
--$ Added New Auth_user func returning varchar2
--$
--$ Revision 1.46  2013/12/30 16:01:38  hcampano
--$ Added site_type column to get_cntct_rslt_tas function
--$
--$ Revision 1.45  2013/11/18 20:19:38  nguada
--$ CR26679  New search criteria added. address zipcode
--$
--$ Revision 1.44  2013/09/24 16:02:20  hcampano
--$ Commiting Natalio changes.
--$
--$ Revision 1.43  2013/03/13 15:36:32  mmunoz
--$ CR19663 : Added validation when org_flow is 3, ESN should have relation with a account
--$
--------------------------------------------------------------------------------------------
FUNCTION bo_cal( ip_inp IN VARCHAR2)
RETURN VARCHAR2 IS
  a NUMBER;
  retval VARCHAR2(50);
BEGIN
     BEGIN
       a := to_number(ip_inp);
       SELECT  to_char(TRUNC(next_day(sysdate,'SUN')-7) +
               ip_inp/(60*60*24),'DAY HH24:MI:SS')
       INTO retval
       FROM dual;
     EXCEPTION
     WHEN OTHERS THEN
       -- dbms_output.put_line(ip_inp);
       SELECT to_char(round((TO_DATE(to_char(
              next_day(TRUNC(next_day(TRUNC(sysdate-7),'SUN')-1),
              substr(ip_inp,1,instr(ip_inp,' '))),'DD-MON-YYYY')
              ||substr(ip_inp,instr(ip_inp,' ')+1),'DD-Mon-YYYY HH24:MI:SS')
              - next_day(TRUNC(sysdate-7),'SUNDAY'))*86400,0))
       INTO retval
       FROM dual;
     END;
RETURN retval;
END bo_cal;

 FUNCTION apex_esn_min_hist
(
  ip_request IN VARCHAR2,
  ip_esn IN VARCHAR2,
  ip_min IN VARCHAR2,
  ip_trans_type IN VARCHAR2,
  ip_days IN VARCHAR2,
  ip_msid IN VARCHAR2,
  ip_red_card IN VARCHAR2,
  ip_line_trans_type IN VARCHAR2
) RETURN VARCHAR2 AS

  sqlstr VARCHAR2(1000);

BEGIN

  IF ip_request = 'ACTIVATION_DEACTIVATION' THEN

    IF ip_esn IS NULL AND ip_min IS NULL THEN
      sqlstr:= 'select ''Please enter a search criteria''  message from dual';
    ELSE
      sqlstr := 'select action_text transaction_type,TO_CHAR(date_time, ''MM/DD/YYYY HH:MI:SS PM'') trans_date, contact_x_cust_id customer, agent ,carrier, market,
      esn, x_iccid sim, x_min min,x_technology technology,dealer,result
      from table_x_act_deact_hist  WHERE  1=1 ';
      IF ip_esn IS NOT NULL THEN
          sqlstr:=sqlstr|| ' and x_service_id like '''||ip_esn||'%''';
      END IF;
      IF ip_min IS NOT NULL THEN
         sqlstr:=sqlstr||' and x_min like '''||ip_min||'%''';
      END IF;
      IF ip_days <> 'ALL' THEN
         sqlstr:=sqlstr||' and date_time >= sysdate - '||ip_days;
      END IF;
      IF ip_trans_type <> 'ALL' THEN
         sqlstr:=sqlstr|| 'and action_type = '''||ip_trans_type||'''';
      END IF;
      sqlstr:=sqlstr|| '  order by date_time desc ';
    END IF;
  ELSIF ip_request = 'LINE_HISTORY' THEN

    IF ip_msid IS NULL AND ip_min IS NULL THEN
      sqlstr:= 'select ''Please enter a search criteria''  message from dual';
    ELSE

    sqlstr := 'select  x_min min,x_msid msid, x_change_reason transaction_type,TO_CHAR(x_change_date, ''MM/DD/YYYY HH:MI:SS PM'') change_date,
    agent, x_carrier_name carrier ,x_mkt_submkt_name market
    from table_x_line_hist_view where 1=1 ';

    IF ip_min IS NOT NULL THEN
      sqlstr := sqlstr || ' and x_min = '''||ip_min||'''';
    END IF;
    IF ip_msid IS NOT NULL THEN
      sqlstr := sqlstr || ' and x_msid = '''||ip_msid||'''';
    END IF;
    IF ip_line_trans_type <> 'ALL' THEN
       sqlstr := sqlstr || ' and x_change_reason = '''||UPPER(ip_line_trans_type)||'''';
    END IF;
    IF ip_days <> 'ALL' THEN
       sqlstr := sqlstr || ' and x_change_date >= sysdate - '||ip_days;
    END IF;
      sqlstr := sqlstr || ' order by x_change_date desc ';
    END IF;
  ELSIF ip_request = 'REDEMPTION' THEN

    IF ip_esn IS NULL AND ip_min IS NULL AND ip_red_card IS NULL THEN
       sqlstr:= 'select ''Please enter a search criteria''  message from dual';
    ELSE
       sqlstr:='select action_text,TO_CHAR(date_time, ''MM/DD/YYYY HH:MI:SS PM'') red_date,contact_x_cust_id customer,
       agent,carrier,market,esn,x_min min,x_technology tech,dealer,red_code,units,result
       from  table_x_redemp_hist  where 1 = 1  ';

       IF ip_esn IS NOT NULL THEN

          sqlstr := sqlstr || ' and x_service_id = '''||ip_esn||'''';
       END IF;

       IF ip_min IS NOT NULL THEN

          sqlstr := sqlstr || ' and x_min = '''||ip_min||'''';
       END IF;

       IF ip_red_card IS NOT NULL THEN
          sqlstr := sqlstr || ' and ( red_code = '''||ip_red_card||''' or smp = '''||ip_red_card||''')   ';
       END IF;

       IF ip_days <> 'ALL' THEN

          sqlstr := sqlstr || ' and date_time  >= sysdate - '||ip_days;
       END IF;
       sqlstr := sqlstr || ' order by date_time desc ';
    END IF;

  ELSIF ip_request = 'PHONE_HISTORY' THEN

    IF ip_esn IS NULL THEN
       sqlstr:= 'select ''Please enter a search criteria''  message from dual';
    ELSE
       sqlstr:= 'select x_esn esn,x_change_reason trans_type,TO_CHAR(x_change_date, ''MM/DD/YYYY HH:MI:SS PM'') change_date,
                 agent,site_id dealer_id  from table_x_phone_hist where 1=1 ';
       IF ip_esn IS NOT NULL THEN
          sqlstr := sqlstr || ' and x_esn = '''||ip_esn||'''';
       END IF;
       IF ip_days <> 'ALL' THEN
          sqlstr := sqlstr || ' and x_change_date  >= sysdate - '||ip_days;
       END IF;
       sqlstr := sqlstr || ' order by x_change_date desc ';
    END IF;

  ELSIF ip_request = 'PROMOTION_HISTORY' THEN

    NULL;

    IF ip_esn IS NULL AND ip_min IS NULL THEN
      sqlstr:= 'select ''Please enter a search criteria''  message from dual';
    ELSE
      sqlstr:= ' select  action_text trans_type,TO_CHAR(date_time, ''MM/DD/YYYY HH:MI:SS PM'') promo_date,contact_x_cust_id cust_id,agent,carrier,market,esn,
      x_min min,x_technology tech,dealer,x_promo_code promo_code,x_promo_type promo_type,
      x_units promo_units,result  from table_x_promo_hist_view where 1=1 ';

       IF ip_esn IS NOT NULL THEN
          sqlstr := sqlstr || ' and x_service_id = '''||ip_esn||'''';
       END IF;

       IF ip_min IS NOT NULL THEN
          sqlstr := sqlstr || ' and x_min = '''||ip_min||'''';
       END IF;

       IF ip_days <> 'ALL' THEN
          sqlstr := sqlstr || ' and date_time  >= sysdate - '||ip_days;
       END IF;
       sqlstr := sqlstr || ' order by date_time desc ';
   END IF;
 END IF;
RETURN sqlstr;

END apex_esn_min_hist;


--------------------------------------------------------------------------------
-- FUNCTION TO RETURN GLOBAL VARS
--------------------------------------------------------------------------------
FUNCTION ret_var(var_name IN VARCHAR2) RETURN VARCHAR2 IS
   server_name VARCHAR2(50) := 'devdb.tracfone.com';
   apex_ext VARCHAR2(50) := '/pls/apex';
   apex_port VARCHAR2(50);
BEGIN
   IF UPPER(var_name) = 'SERVER_NAME' THEN
      RETURN (server_name);
   ELSIF  UPPER(var_name) = 'APEX_EXT' THEN
      RETURN (apex_ext);
   ELSIF  UPPER(var_name) = 'APEX_PORT' THEN
      SELECT dbms_xdb.gethttpport
      INTO apex_port
      FROM dual;
      RETURN(apex_port);
   ELSE
       RETURN ( NULL);
   END IF;
END;
--------------------------------------------------------------------------------
-- FUNCTION AUTHORIZE USER
--------------------------------------------------------------------------------
  FUNCTION auth_user(ipv_user_name VARCHAR2,
                     ipv_perm_name VARCHAR2) RETURN BOOLEAN
  AS
    auth_check NUMBER := 0;
    leave_now BOOLEAN;
 perm_count NUMBER:=0;

  BEGIN
    SELECT COUNT(*)
    INTO   auth_check
    FROM   security_access
    WHERE  user_name = TRIM(UPPER(ipv_user_name))
    AND    permission_name LIKE TRIM(UPPER(ipv_perm_name));

    IF auth_check > 0 THEN
      RETURN TRUE;
    ELSE
      SELECT COUNT('1') INTO perm_count
   FROM sa.x_crm_permissions
   WHERE permission_name LIKE TRIM(UPPER(ipv_perm_name));

   IF perm_count = 0 THEN

  INSERT INTO sa.x_crm_permissions(objid,permission_name,permission_desc)
  VALUES (sa.x_crm_permissions_seq.NEXTVAL,TRIM(UPPER(ipv_perm_name)),TRIM(UPPER(ipv_perm_name)));
  COMMIT;

   END IF;

   RETURN FALSE;


    END IF;
 EXCEPTION WHEN OTHERS THEN RETURN FALSE;

  END;

-- OVERLOADED FUNC
  FUNCTION auth_user(ipv_user_name VARCHAR2,
                     ipv_perm VARCHAR2,
                     ipv_perm_str CLOB) RETURN BOOLEAN
  AS
    v_perm VARCHAR2(30);
    auth_check NUMBER := 0;
    leave_now BOOLEAN;
  BEGIN
  v_perm := REPLACE(TRANSLATE(ipv_perm,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','12FDSAM67L3KJP4OWE9RT80VN'),'_','');
  IF instr(ipv_perm_str,v_perm)>0 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;

-- FUNC RETURNING VARCHAR
  FUNCTION auth_user_v(ipv_user_name VARCHAR2,
                       ipv_perm_name VARCHAR2) RETURN VARCHAR
  AS
    auth_check NUMBER := 0;
    leave_now BOOLEAN;
  BEGIN
    SELECT COUNT(*)
    INTO   auth_check
    FROM   security_access
    WHERE  user_name = TRIM(UPPER(ipv_user_name))
    AND    permission_name LIKE TRIM(UPPER(ipv_perm_name));

    IF auth_check > 0 THEN
      RETURN 'TRUE';
    ELSE
      RETURN 'FALSE';
    END IF;
  END;
--------------------------------------------------------------------------------
-- FUNCTION TO SHOW SUB MENUS
--------------------------------------------------------------------------------
  FUNCTION ret_menu (p_app_id NUMBER,
                      p_app_page_id NUMBER,
                      p_menu_grp_name VARCHAR2 DEFAULT NULL,
                      p_app_user VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
  AS

    v_menu_name VARCHAR2(255);
    v_link      VARCHAR2(4000);
    v_out_msg   VARCHAR2(4000);

    stmt        VARCHAR2(4000);
    st_cur      SYS_REFCURSOR;
    p_id        apex_application_pages.page_id%TYPE;
    p_name      apex_application_pages.page_name%TYPE;
    p_title     apex_application_pages.page_title%TYPE;
    p_scheme    apex_application_pages.authorization_scheme%TYPE;
    p_scheme_id apex_application_pages.authorization_scheme_id%TYPE;

    FUNCTION ret_menu_name (ip_menu_grp_name VARCHAR2,
                            ip_app_id NUMBER DEFAULT NULL,
                            ip_app_page_id NUMBER DEFAULT NULL)
    RETURN VARCHAR2
    AS
      op_menu_name VARCHAR2(255);
    BEGIN

      IF ip_menu_grp_name IS NULL THEN
        SELECT nvl(b.page_group,'NOT_FOUND')
        INTO   op_menu_name
        FROM   apex_application_pages b
        WHERE  b.application_id = p_app_id
        AND    b.page_id = p_app_page_id;
      ELSE
        SELECT DISTINCT nvl(b.page_group,'NOT_FOUND')
        INTO   op_menu_name
        FROM   apex_application_pages b
        WHERE  b.page_group = p_menu_grp_name;
      END IF;

      RETURN op_menu_name;

    EXCEPTION WHEN OTHERS THEN
      RETURN 'NOT_FOUND';
    END ret_menu_name;
  --------------------------------------------------------------------------------
  -- MAIN BODY
  --------------------------------------------------------------------------------
  BEGIN

    v_menu_name := ret_menu_name (p_menu_grp_name,p_app_id,p_app_page_id);

    -- START BUILDING THE QUERY
    stmt :=         ' select b.page_id, '||CHR(10);
    stmt := stmt || '        b.page_name, '||CHR(10);
    stmt := stmt || '        b.page_title, '||CHR(10);
    stmt := stmt || '        b.authorization_scheme, '||CHR(10);
    stmt := stmt || '        b.authorization_scheme_id '||CHR(10);
    stmt := stmt || ' from   apex_application_page_groups a,  '||CHR(10);
    stmt := stmt || '        apex_application_pages b '||CHR(10);
    stmt := stmt || ' where  b.page_group = a.page_group_name  '||CHR(10);
    stmt := stmt || ' and    b.application_id = a.application_id  '||CHR(10);
    stmt := stmt || ' and    b.application_id = '''||p_app_id||''' '||CHR(10); -- I DON'T SEE WHY WE CAN'T HAVE THIS FOR BOTH
    stmt := stmt || ' and    a.page_group_name = '''||v_menu_name||''''||CHR(10);
    stmt := stmt || ' order by b.page_name  ';
     dbms_output.put_line(stmt);

    v_out_msg := '<ul>'||CHR(10);

    IF v_menu_name != 'NOT_FOUND' THEN

      OPEN st_cur FOR stmt;
      LOOP
        FETCH st_cur
        INTO p_id, p_name, p_title, p_scheme, p_scheme_id;
        EXIT WHEN st_cur %notfound;

        v_link := '<li>';

        -- IF THIS IS NULL IT'S A REGULAR SUB MENU
        -- ELSE IT'S A SUB MENU THAT LOADS INTO AN IFRAME
        IF p_menu_grp_name IS NULL THEN
          v_link := v_link || '<a href="/apex/f?p='||p_app_id||':'||p_id||':'||V('APP_SESSION')||':::::"'||'>';
        ELSE
          v_link := v_link || '<a href="javascript:load_page(''load_page'','''||p_app_id||''','''||p_id||''','''||p_title||''');">';
        END IF;

        -- IF THE PAGE ID MATCHES THE ID FROM THE PAGE BOLD THE LINK
        IF p_app_page_id = p_id THEN
          v_link := v_link || '<b>'||p_title||'</b>';
        ELSE
          v_link := v_link || p_title;
        END IF;

        v_link := v_link || '</a>';
        v_link := v_link || '</li>'||CHR(10);

        -- IF THERE IS NO AUTHORIZATION SCHEME APPLIED TO THE PAGE SHOW THE LINK
        -- IF AN AUTHORIZATION SCHEME EXISTS AND THE USER HAS AUTHO, SHOW THE LINK
        -- IF THERE IS AN AUTHORIZATION SCHEME AND THE USER
        IF p_scheme_id IS NULL THEN
          v_out_msg := v_out_msg || v_link;
        ELSIF p_scheme_id IS NOT NULL AND
              apex_crm_pkg.auth_user(p_app_user,p_scheme) THEN
          v_out_msg := v_out_msg || v_link;
        END IF;

      END LOOP;
      CLOSE st_cur;

    END IF;

    v_out_msg := v_out_msg || '</ul>';

    IF REPLACE(REPLACE(REPLACE(v_out_msg,'<ul>',''),'</ul>',''),CHR(10),'') IS NULL THEN
      v_out_msg := 'NOT_FOUND';
    END IF;

    RETURN v_out_msg;

  END ret_menu;
--------------------------------------------------------------------------------
-- FUNCTION HAS TICK
--------------------------------------------------------------------------------
  FUNCTION has_tick(ipv_text VARCHAR2)
  RETURN VARCHAR2
  AS
    v_text VARCHAR2(100);
    -----------------------------------------
    -- MAIN BODY
    -----------------------------------------
    -- ADD EXTRA TICK
    -----------------------------------------
  BEGIN
    IF instr(ipv_text,'''') > 0 THEN
      v_text := REPLACE(ipv_text,'''','''''');
    ELSE
      v_text := ipv_text;
    END IF;
    RETURN v_text;
  END has_tick;

--------------------------------------------------------------------------------
-- GET CONTACT RESULT PROCEDURE
--------------------------------------------------------------------------------
  PROCEDURE get_cntct_rslt (ipv_f_name VARCHAR2,
                            ipv_l_name VARCHAR2,
                            ipn_phone VARCHAR2,
                            ipv_esn   VARCHAR2,
                            ipn_cust_id VARCHAR2,
                            ipv_email VARCHAR2,
                            ipv_interact_id VARCHAR2,
                            p_recordset OUT SYS_REFCURSOR)
AS
BEGIN

  get_cntct_rslt_tas(
    ipv_f_name => ipv_f_name,
    ipv_l_name => ipv_l_name,
    ipn_phone => ipn_phone,
    ipv_esn => ipv_esn,
    ipn_cust_id => ipn_cust_id,
    ipv_email => ipv_email,
    ipv_interact_id => ipv_interact_id,
    ipv_min => NULL,
    ipv_sim => NULL,
    ipv_address => NULL,
    ipv_zipcode => NULL,
    ipv_lid => NULL,
    p_recordset => p_recordset
  );

END get_cntct_rslt;

--------------Overloaded to add Lifeline ID and do not break other branches-----------------------
  PROCEDURE get_cntct_rslt_tas (ipv_f_name VARCHAR2,
                            ipv_l_name VARCHAR2,
                            ipn_phone VARCHAR2,
                            ipv_esn   VARCHAR2,
                            ipn_cust_id VARCHAR2,
                            ipv_email VARCHAR2,
                            ipv_interact_id VARCHAR2,
                            ipv_min VARCHAR2,
                            ipv_sim VARCHAR2,
                            ipv_address VARCHAR2,
                            ipv_zipcode VARCHAR2,
                            p_recordset OUT SYS_REFCURSOR)
  AS
  BEGIN
        get_cntct_rslt_tas (ipv_f_name ,
                            ipv_l_name ,
                            ipn_phone ,
                            ipv_esn   ,
                            ipn_cust_id ,
                            ipv_email ,
                            ipv_interact_id ,
                            ipv_min ,
                            ipv_sim ,
                            ipv_address ,
                            ipv_zipcode ,
       NULL, --Ipv_lid,
       NULL, --Ipv_web_user_objid,
                            p_recordset);
  END;

  PROCEDURE get_cntct_rslt_tas (ipv_f_name VARCHAR2,
                            ipv_l_name VARCHAR2,
                            ipn_phone VARCHAR2,
                            ipv_esn   VARCHAR2,
                            ipn_cust_id VARCHAR2,
                            ipv_email VARCHAR2,
                            ipv_interact_id VARCHAR2,
                            ipv_min VARCHAR2,
                            ipv_sim VARCHAR2,
                            ipv_address VARCHAR2,
                            ipv_zipcode VARCHAR2,
       ipv_lid VARCHAR2,
                            p_recordset OUT SYS_REFCURSOR)
  AS
  BEGIN
        get_cntct_rslt_tas (ipv_f_name ,
                            ipv_l_name ,
                            ipn_phone ,
                            ipv_esn   ,
                            ipn_cust_id ,
                            ipv_email ,
                            ipv_interact_id ,
                            ipv_min ,
                            ipv_sim ,
                            ipv_address ,
                            ipv_zipcode ,
       ipv_lid,
       NULL, --Ipv_web_user_objid,
                            p_recordset);
  END;

  PROCEDURE get_cntct_rslt_tas (ipv_f_name VARCHAR2,
                            ipv_l_name VARCHAR2,
                            ipn_phone VARCHAR2,
                            ipv_esn   VARCHAR2,
                            ipn_cust_id VARCHAR2,
                            ipv_email VARCHAR2,
                            ipv_interact_id VARCHAR2,
                            ipv_min VARCHAR2,
                            ipv_sim VARCHAR2,
                            ipv_address VARCHAR2,
                            ipv_zipcode VARCHAR2,
                            ipv_lid VARCHAR2,
       ipv_web_user_objid VARCHAR2,
                            p_recordset OUT SYS_REFCURSOR)
  AS
    stmt VARCHAR2(4000);
    v_f_name VARCHAR2(100);
    v_l_name VARCHAR2(100);
    v_orphan VARCHAR2(10):='false';
    v_org_flow NUMBER:=0;
    v_acc_count NUMBER:=0;
    v_esn_objid NUMBER;
    -----------------------------------------
    -- MAIN BODY
    -----------------------------------------
    -- SEARCH FOR CONTACTS PROC
    -- FIRST NAME AND LAST NAME ARE REQUIRED
    -- ALL OTHER FIELDS ARE OPTIONAL
    -----------------------------------------


    --
    CURSOR esn_cur IS
    SELECT org_flow,pi.objid
    FROM table_part_inst pi,
         table_mod_level ml,
         table_part_num pn,
         table_bus_org bo
    WHERE pi.part_serial_no = ipv_esn
    AND pi.x_domain = 'PHONES'
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num = pn.objid
    AND pn.part_num2bus_org = bo.objid;

    esn_rec esn_cur%rowtype;


  BEGIN

    IF ipv_esn IS NOT NULL THEN
      OPEN esn_cur;
      FETCH esn_cur INTO esn_rec;
      IF esn_cur%found THEN
        v_org_flow := esn_rec.org_flow;
        v_esn_objid := esn_rec.objid;
        IF v_org_flow = 3 THEN  -- Account is Required for these brands
            SELECT COUNT(*)
            INTO v_acc_count
            FROM table_x_contact_part_inst
            WHERE x_contact_part_inst2part_inst = v_esn_objid;
            IF v_acc_count = 0 THEN
               v_orphan:='true';  -- ESN is missing relation to account, sugest account creation
            END IF;
        END IF;
      END IF;
      CLOSE esn_cur;
    END IF;


      stmt := ' select c.objid con_objid, '||CHR(10);
      stmt := stmt || '        c.x_cust_id cust_id, '||CHR(10);
      stmt := stmt || '        c.first_name f_name, '||CHR(10);
      stmt := stmt || '        c.last_name l_name, '||CHR(10);
      stmt := stmt || '        c.phone, '||CHR(10);
      stmt := stmt || '        a.address, '||CHR(10);
      stmt := stmt || '        a.city, '||CHR(10);
      stmt := stmt || '        a.state st, '||CHR(10);
      stmt := stmt || '        a.zipcode zip, '||CHR(10);
      stmt := stmt || '        c.fax_number fax, '||CHR(10);
      stmt := stmt || '        c.e_mail email, '||CHR(10);
      stmt := stmt || '        s.site_type, '||CHR(10);
      stmt := stmt || '        (select lid '||CHR(10);
--      stmt := stmt || '         from sa.table_part_inst pi, sa.x_sl_hist slh '||chr(10);
      stmt := stmt || '         from sa.table_part_inst pi, sa.x_sl_currentvals slh '||CHR(10);
      stmt := stmt || '         where pi.x_part_inst2contact = c.objid '||CHR(10);
      stmt := stmt || '         and   slh.x_current_esn =  pi.part_serial_no '||CHR(10);
      stmt := stmt || '         and   rownum < 2) lid '||CHR(10);
      stmt := stmt || ' from   table_contact c, '||CHR(10);
      stmt := stmt || '        table_contact_role cr, '||CHR(10);
      stmt := stmt || '        table_address a, '||CHR(10);
      stmt := stmt || '        table_site s '||CHR(10);
      stmt := stmt || ' where  1=1 '||CHR(10);
      stmt := stmt || ' and    rownum < 50 '||CHR(10);
      stmt := stmt || ' and    a.objid        = s.cust_primaddr2address '||CHR(10);
      stmt := stmt || ' and    s.objid        = cr.contact_role2site '||CHR(10);
      stmt := stmt || ' and    c.objid        = cr.contact_role2contact '||CHR(10);

    IF ipv_esn IS NOT NULL THEN
      stmt := stmt || ' and    c.objid in (select x_part_inst2contact con_objid '||CHR(10);
      stmt := stmt || '        from table_part_inst '||CHR(10);
      stmt := stmt || '        where  '''||v_orphan||''' = ''false'' and part_serial_no = '''||ipv_esn||''' and x_domain = ''PHONES'''||CHR(10);
      stmt := stmt || '        union  '||CHR(10);
      stmt := stmt || '        Select CON_OBJID From Table_Site_Part,Table_Rol_Contct '||CHR(10);
      stmt := stmt || '        where '''||v_orphan||''' = ''false'' and Loc_Objid = Table_Site_Part.Site_Part2site '||CHR(10);
      stmt := stmt || '        and table_site_part.x_service_id = '''||ipv_esn||''')'||CHR(10);

    ELSIF ipv_sim IS NOT NULL THEN
      stmt := stmt || ' and    c.objid in (select x_part_inst2contact con_objid '||CHR(10);
      stmt := stmt || '        from table_part_inst '||CHR(10);
      stmt := stmt || '        where  x_iccid = '''||ipv_sim||''' and x_domain = ''PHONES'') '||CHR(10);

    ELSIF ipn_cust_id IS NOT NULL THEN
      stmt := stmt || ' and    c.x_cust_id = '''||ipn_cust_id||''''||CHR(10);

 ELSIF ipv_web_user_objid IS NOT NULL THEN

      stmt := stmt || '    and  c.objid in ( '||CHR(10);
      stmt := stmt || '    select wu.web_user2contact con_objid '||CHR(10);
      stmt := stmt || '    from   table_web_user wu  '||CHR(10);
      stmt := stmt || '    where  1=1 '||CHR(10);
      stmt := stmt || '    and    wu.objid = '||ipv_web_user_objid||') '||CHR(10);

    ELSIF ipv_email IS NOT NULL THEN

      stmt := stmt || '    and  c.objid in ( '||CHR(10);
      stmt := stmt || '    select wu.web_user2contact con_objid '||CHR(10);
      stmt := stmt || '    from   table_web_user wu  '||CHR(10);
      stmt := stmt || '    where  1=1 '||CHR(10);
      stmt := stmt || '    and    wu.s_login_name = upper('''||ipv_email||''') '||CHR(10);
      stmt := stmt || '    union  '||CHR(10);
      stmt := stmt || '    select objid con_objid from table_contact where upper(e_mail) = upper('''||ipv_email||''')) '||CHR(10);

    ELSIF ipv_interact_id IS NOT NULL THEN

      stmt := stmt || ' and    c.objid in (select interact2contact '||CHR(10);
      stmt := stmt || '        from table_interact '||CHR(10);
      stmt := stmt || '        where  interact_id = '''||ipv_interact_id||''')'||CHR(10);

    ELSIF ipv_min IS NOT NULL THEN
      stmt := stmt || ' and    c.objid in (select piesn.x_part_inst2contact con_objid '||CHR(10);
      stmt := stmt || '        from table_part_inst piesn, table_part_inst pimin '||CHR(10);
      stmt := stmt || '        where  pimin.part_serial_no = '''||ipv_min||''' and pimin.x_domain = ''LINES'''||CHR(10);
      stmt := stmt || '        and  pimin.part_to_esn2part_inst = piesn.objid and piesn.x_domain = ''PHONES''  '||CHR(10);
      stmt := stmt || '        union  '||CHR(10);
      stmt := stmt || '        Select CON_OBJID From Table_Site_Part,Table_Rol_Contct '||CHR(10);
      stmt := stmt || '        where Loc_Objid = Table_Site_Part.Site_Part2site '||CHR(10);
      stmt := stmt || '        and table_site_part.x_min = '''||ipv_min||''')'||CHR(10);

    ELSIF ipv_lid IS NOT NULL THEN
-- disregard sl_subs2table_contact could be empty
--      Stmt := Stmt || ' and    c.objid in (select sl_subs2table_contact con_objid '||Chr(10);
--      Stmt := Stmt || '                    from x_sl_subs where lid = '||Ipv_lid||')'||Chr(10);
--      Stmt := Stmt || ' and    c.objid in (select pi.x_part_inst2contact con_objid '||Chr(10);
--      Stmt := Stmt || '                    from sa.x_sl_hist slh, sa.table_part_inst pi '||Chr(10);
--      Stmt := Stmt || '                    where lid = '||Ipv_lid ||Chr(10);
--      Stmt := Stmt || '                    and   pi.part_serial_no = slh.x_esn) '||Chr(10);
-- disregard x_current_esn could be empty
      stmt := stmt || ' and    c.objid in (select pi.x_part_inst2contact con_objid '||CHR(10);
      stmt := stmt || '                    from sa.x_sl_currentvals slcv, sa.table_part_inst pi '||CHR(10);
      stmt := stmt || '                    where lid = '||ipv_lid ||CHR(10);
      stmt := stmt || '                    and   pi.part_serial_no = slcv.x_current_esn) '||CHR(10);

    ELSIF (ipv_f_name IS NOT NULL AND
           ipv_l_name IS NOT NULL) OR
           (ipn_phone IS NOT NULL) THEN

      v_f_name := has_tick(ipv_f_name);
      v_l_name := has_tick(ipv_l_name);

      stmt := stmt || ' and    c.objid in (select con_objid  '||CHR(10);
      stmt := stmt || '                    from   ( '||CHR(10);
      stmt := stmt || '                            select c.objid con_objid '||CHR(10);
      stmt := stmt || '                            from   table_contact c '||CHR(10);
      stmt := stmt || '                            where  1=1 '||CHR(10);

      IF ipn_phone IS NOT NULL THEN
      stmt := stmt || '                            and    c.phone         = nvl('''||ipn_phone||''',''-1'') '||CHR(10);
      END IF;

      IF ipv_f_name IS NOT NULL AND
         ipv_l_name IS NOT NULL THEN

         stmt := stmt || '                            and    c.s_first_name like nvl(upper('''||v_f_name||''')||''%'',''-2'')  '||CHR(10);
         stmt := stmt || '                            and    c.s_last_name  = nvl(upper('''||v_l_name||'''),''-2'')  '||CHR(10);

      END IF;

      stmt := stmt || '                            )) '||CHR(10);

    ELSIF (ipv_address IS NOT NULL) THEN
         stmt := stmt || '                            and    a.s_address = nvl(upper('''||ipv_address||'''),''-2'')  '||CHR(10);
         IF  ipv_zipcode IS NOT NULL THEN
            stmt := stmt || '                            and    a.zipcode  = nvl(upper('''||ipv_zipcode||'''),''-2'')  '||CHR(10);
         END IF;
    ELSE
      stmt := 'select ''-1'' con_objid, '' '' cust_id, ''a first name is required'' f_name, ''a last name is required'' l_name, '' '' phone, '' '' address, '' '' city, '' '' state, '' '' zipcode, '' '' fax_number, '' '' e_mail, '' '' site_type, null lid from dual';
    END IF;

    -- FOR DEBUGGING
     dbms_output.put_line(stmt);

    OPEN p_recordset FOR stmt;

  END get_cntct_rslt_tas;
--------------------------------------------------------------------------------
-- CLEAR PARENT FLAG
--------------------------------------------------------------------------------
  PROCEDURE clr_parent_flag(ipv_parent VARCHAR2)
  AS
    n_par_has_child NUMBER;
  ------------------------------------------------------------------------------
  -- MAIN BODY
  ------------------------------------------------------------------------------
  BEGIN
    SELECT COUNT(*)
    INTO   n_par_has_child
    FROM   table_case
    WHERE  case_victim2case = (SELECT objid
                               FROM   table_case
                               WHERE  id_number = ipv_parent);

    IF n_par_has_child = 0 THEN
      UPDATE table_case
      SET    is_supercase     = 0,
             case_victim2case = NULL
      WHERE  id_number = ipv_parent;
    END IF;

    COMMIT;

  END clr_parent_flag;
--------------------------------------------------------------------------------
-- CLEAR PARENT CASE FROM CHILD
--------------------------------------------------------------------------------
  PROCEDURE clr_parent_case_from_child(ipv_child   VARCHAR2,
                                       ipv_parent  VARCHAR2 DEFAULT NULL,
                                       opv_out_msg OUT VARCHAR2)
  AS
    v_par_id_number table_case.id_number%TYPE;
  ------------------------------------------------------------------------------
  -- MAIN BODY
  ------------------------------------------------------------------------------
  BEGIN

    IF ipv_parent IS NULL THEN
      BEGIN
        SELECT P.id_number
        INTO   v_par_id_number
        FROM   table_case C,
               table_case P
        WHERE  1=1
        AND    C.case_victim2case = P.objid
        AND    C.id_number = ipv_child;
      EXCEPTION
        WHEN OTHERS THEN
          v_par_id_number := NULL;
      END;
    ELSE
       v_par_id_number := ipv_parent;
    END IF;

    -- UPDATE THE CHILD
    UPDATE table_case
    SET    is_supercase     = 0,
           case_victim2case = NULL
    WHERE  id_number = ipv_child;
    COMMIT;

    -- RESET THE PARENT FLAG
    IF v_par_id_number IS NOT NULL THEN
      clr_parent_flag(v_par_id_number);
    END IF;

    opv_out_msg := 'CASE '||ipv_child||' NO LONGER HAS A PARENT';
  END clr_parent_case_from_child;

--------------------------------------------------------------------------------
-- SET PARENT CASE
--------------------------------------------------------------------------------
  PROCEDURE set_parent_case(ipv_parent  VARCHAR2,
                            ipv_child   VARCHAR2,
                            opv_out_msg OUT VARCHAR2)
  AS
    n_cnt                   NUMBER;
    n_par_cnt               NUMBER;
    n_par_objid             NUMBER;
    n_chld_cnt              NUMBER;
    n_chld_objid            NUMBER;
    n_is_child_a_par        NUMBER;
    n_par_case_victim2case  NUMBER;
    n_chld_old_parent       NUMBER;
    v_old_parent_id         table_case.id_number%TYPE;
  ------------------------------------------------------------------------------
  -- MAIN BODY
  ------------------------------------------------------------------------------
  BEGIN
    -- HOW PARENT CHILD RELATIONSHIP WORKS
    -- PARENT CASE HAS FLAG SET TO 1
    -- CHILD CASE HAS FLAG SET TO 0 OR NULL AND
    -- THE CASE_VICTIM2CASE COLUMN REFERENCES THE PARENT

    -- PARENT CANNOT BE CHILD
    IF ipv_parent = ipv_child THEN
        opv_out_msg := 'PARENT CANNOT BE CHILD CANNOT CONTINUE ';
        GOTO end_proc;
    END IF;

    -- REQUESTED PARENT CANNOT BE A CHILD
    -- AND IF SUPERCASE IS ZERO OR NULL
    -- WELL HAVE TO CHANGE IT TO 1
    BEGIN
      SELECT nvl(is_supercase,0) is_supercase, -- count(*)
             objid,
             case_victim2case
      INTO   n_par_cnt,
             n_par_objid,
             n_par_case_victim2case
      FROM   table_case
      WHERE  1=1
      AND    id_number = ipv_parent;

      IF n_par_case_victim2case IS NOT NULL THEN
        opv_out_msg := 'PARENT IS CHILD CANNOT CONTINUE ';
        GOTO end_proc;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        opv_out_msg := 'PARENT ERROR - '||sqlerrm;
        GOTO end_proc;
    END;

    -- REQUESTED CHILD CANNOT BE A PARENT
    -- AND IS_SUPERCASE MUST BE ZERO OR NULL
    -- IT DOESN'T MATTER IF THE CHILD CASE
    -- WAS PREVIOUSLY ATTACHED TO ANOTHER
    -- PARENT WE CAN REASSIGN IT A NEW PARENT
    BEGIN
      SELECT nvl(is_supercase,0) is_supercase, -- count(*)
             objid,
             case_victim2case
      INTO   n_chld_cnt,
             n_chld_objid,
             n_chld_old_parent
      FROM   table_case
      WHERE  1=1
      AND    id_number = ipv_child;

    EXCEPTION
      WHEN OTHERS THEN
        opv_out_msg := 'CHILD ERROR - '||sqlerrm;
        GOTO end_proc;
    END;

    -- CHECKING CHILD IN FACT ISN'T A PARENT
    -- IF THIS RETURNS ZERO THE PARENT FLAG
    -- HAS NO SIGNIFICANCE
    SELECT COUNT(*)
    INTO   n_is_child_a_par
    FROM   table_case
    WHERE  case_victim2case = n_chld_objid;

     IF n_is_child_a_par > 0 THEN
      opv_out_msg := 'CHILD IS PARENT CANNOT CONTINUE';
      GOTO end_proc;
    END IF;

    IF n_chld_old_parent != n_par_objid THEN
      SELECT id_number
      INTO   v_old_parent_id
      FROM   table_case
      WHERE  objid = n_chld_old_parent;
      opv_out_msg := 'CHILD ('||ipv_child||') PARENT REASSIGNED FROM ('||v_old_parent_id||') TO ('||ipv_parent||')';
    END IF;

    -- UPDATE THE PARENT
    UPDATE table_case
    SET    is_supercase = 1
    WHERE  id_number = ipv_parent;

    -- UPDATE THE CHILD
    UPDATE table_case
    SET    is_supercase     = 0,
           case_victim2case = n_par_objid
    WHERE  id_number = ipv_child;

  <<end_proc>>
   COMMIT;

    IF opv_out_msg IS NULL THEN
      opv_out_msg := 'SUCCESSFULLY ASSIGNED PARENT ('||ipv_parent||') TO ('||ipv_child||')';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      opv_out_msg := 'SET_PARENT_CASE PROC - '||sqlerrm;
  END set_parent_case;
--------------------------------------------------------------------------------

FUNCTION  apex_validate_user
          (p_username IN VARCHAR2,
           p_password IN VARCHAR2)
RETURN BOOLEAN  IS
   CURSOR c1 IS
   SELECT u.* FROM table_user u, table_privclass pc
   WHERE u.s_login_name = UPPER(p_username)
   AND u.web_password = sa.encryptpassword(p_password)
   AND u.status = 1
   AND u.user_access2privclass=pc.objid
   AND pc.access_type IN (0,5);

   r1 c1%rowtype;

   v_result BOOLEAN;
BEGIN

   v_result:=FALSE;

   OPEN c1;
   FETCH c1 INTO r1;
   IF c1%found THEN
         UPDATE sa.table_user
         SET web_last_login = sysdate
         WHERE objid = r1.objid;
         COMMIT;
         v_result:=TRUE;
   END IF;
   CLOSE c1;

   RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    RETURN v_result;

END apex_validate_user;


FUNCTION apex_case_query
(
  ip_query_objid IN NUMBER
) RETURN VARCHAR2 AS

  sqlstr VARCHAR2(1000);

  CURSOR c1 IS
  SELECT * FROM table_query
  WHERE objid = ip_query_objid;

  r1 c1%rowtype;

BEGIN

  OPEN c1;
  FETCH c1 INTO r1;
  IF c1%found THEN

sqlstr:='select id_number,owner,condition,status,type,title,x_carrier_id carrier_id,x_carrier_name carrier_name, x_esn esn,
x_min min,first_name,last_name,to_char(creation_time,''mm/dd/yyyy hh:mi:ss pm'') creation_time,x_activation_zip zip, x_retailer_name retailer_name,X_PHONE_MODEL model
from table_qry_case_view
where elm_objid in ('||r1.x_apex_sql_statement||')';
  ELSE
     sqlstr:='select sysdate from dual';

  END IF;
  CLOSE c1;

RETURN sqlstr;

END apex_case_query;

FUNCTION apex_console_queue_query (ip_queue_objid IN NUMBER,
                                   ip_queue_type IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 AS
  sqlstr VARCHAR2(1000);
  r_lmt  NUMBER := 250;
  q_flag NUMBER;
  v_allow_case NUMBER;
BEGIN
  -- IF IT'S A WIPBIN
  IF ip_queue_type = 'WIPBIN' THEN
    GOTO get_wipbin_str;
  END IF;

  -- SHOW MORE RESULTS IF IT'S A WAREHOUSE CASE
  BEGIN
    SELECT to_number(sort_by),
           allow_case
    INTO   q_flag,
           v_allow_case
    FROM   table_queue
    WHERE objid = ip_queue_objid;
  EXCEPTION
    WHEN OTHERS THEN
      q_flag := 0;
  END;

  IF nvl(q_flag,0) = 1 THEN
    r_lmt := 1000;  -- big queue
  ELSE
    r_lmt := 250;  -- small queue
  END IF;

  <<get_wipbin_str>>
  sqlstr :=  'select * from ( ';
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  IF ip_queue_type = 'WIPBIN' THEN
  sqlstr:= sqlstr ||       ' select id_number, '||
                           '''<a href="./f?p='||'&APP_ID.'||':'||'30'||':'||'&APP_SESSION.'||'::NO::P30_CASE_ID,P30_BACK:''||id_number||'',2">Open Case</a>'' link, '||
                           '         null task_link, '||
                           '         title, '||
                           '         age, '||
                           '         carrier_id, '||
                           '         carrier_name , '||
                           '         esn, '||
                           '         condition, '||
                           '         status, '||
                           '         priority, '||
                           '         severity, '||
                           '         creation_time '||
                           ' from   apex_wipbin_view '||
                           ' where  w_objid = '||ip_queue_objid;

  ELSIF nvl(v_allow_case,0)=1 THEN
  sqlstr:= sqlstr ||       ' select id_number, '||
                           '''<a href="./f?p='||'&APP_ID.'||':'||'30'||':'||'&APP_SESSION.'||'::NO::P30_CASE_ID,P30_BACK:''||id_number||'',2">Open Case</a>'' link, '||
                           '         title, '||
                           '         age, '||
                           '         carrier_id, '||
                           '         carrier_name , '||
                           '         esn, '||
                           '         condition, '||
                           '         status, '||
                           '         priority, '||
                           '         severity, '||
                           '         creation_time '||
                           ' from   apex_case_view '||
                           ' where  q_objid = '||ip_queue_objid||
                           ' and rownum <= '||r_lmt;

  ELSE
  sqlstr:= sqlstr ||       ' select id_number, '||
                           '''<a href="./f?p='||'&APP_ID.'||':'||'44'||':'||'&APP_SESSION.'||'::NO::P44_TASK_ID,P44_BACK:''||id_number||'',2">Open Task</a>'' link, '||
                           '        title, '||
                           '        age, '||
                           '        carrier_id, '||
                           '        carrier_name , '||
                           '        esn, '||
                           '        condition, '||
                           '        status, '||
                           '        priority, '||
                           '        severity, '||
                           '        creation_time '||
                           ' from   apex_task_view '||
                           ' where  q_objid = '||ip_queue_objid||
                           ' and rownum <= '||r_lmt;
  END IF;
  sqlstr := sqlstr || ' )  ';
  RETURN sqlstr;

END apex_console_queue_query;


FUNCTION apex_action_item_source
(
  ip_carrier_name IN VARCHAR2,
  ip_carrier_market IN VARCHAR2,
  ip_status IN VARCHAR2,
  ip_condition IN VARCHAR2,
  ip_order_type IN VARCHAR2,
  ip_action_item_id IN VARCHAR2,
  ip_queue_objid IN VARCHAR2,
  ip_esn IN VARCHAR2,
  ip_create_date IN NUMBER ,
  ip_check_results IN NUMBER,
  ip_trans_method IN VARCHAR2
) RETURN VARCHAR2 AS

  sqlstr VARCHAR2(1000);
  checkstr VARCHAR2(20);
  v_condition VARCHAR2(30);

BEGIN

IF ip_check_results=1 THEN
  checkstr:='CHECKED';
ELSE
  checkstr:='UNCHECKED';
END IF;

-- REPLACING OLD APEX ITEM CHECKBOX W/HTML CODE
-- sqlstr:='select apex_item.checkbox(1,task_objid,'''||checkstr||''') "SELECT", '||
-- EX: <input type="checkbox" name="f01" value="1025472322" checked="CHECKED">
sqlstr:=' select ''<input type="checkbox" name="f01" value="''||task_objid||''" '||checkstr||'>'' "SELECT", '||
' task_objid, task_id, to_char(task_create_date,''mm/dd/yyyy hh:mi:ss PM'') task_create_date,
contact_first first_name, contact_last last_name, condition, curr_queue, owner, status, order_type, carrier_mkt, esn,
current_method curr_method, x_min min  from table_x_monitor_view_2 WHERE 1=1 ';


  IF ip_carrier_name IS NOT NULL THEN
   sqlstr:=sqlstr || ' and carrier_name = '''||ip_carrier_name||'''';
  END IF;

  IF ip_carrier_market IS NOT NULL THEN
   sqlstr:=sqlstr || ' and carrier_mkt = '''||ip_carrier_market||'''';
  END IF;

  IF nvl(ip_status,'All') <> 'All' THEN
   sqlstr:=sqlstr || ' and s_status = '''||UPPER(ip_status)||'''';
  END IF;
  v_condition := UPPER(ip_condition);
  IF nvl(v_condition,'ALL') <> 'ALL' THEN
   sqlstr:=sqlstr || ' and s_condition like '''||v_condition||'%''';
  END IF;
  IF nvl(ip_order_type,'All') <> 'All' THEN
   sqlstr:=sqlstr || ' and order_type = '''||ip_order_type||'''';
  END IF;
  IF ip_action_item_id IS NOT NULL THEN
  sqlstr:=sqlstr || ' and task_id = '''||ip_action_item_id||'''';
  END IF;
  IF  ip_queue_objid IS NOT NULL  THEN
     IF ip_queue_objid <> '0' THEN
        sqlstr:=sqlstr ||  ' and QUEUE_OBJID = '||ip_queue_objid;
     END IF;
  END IF;
  IF  nvl(ip_trans_method,'All') <> 'All'  THEN
     sqlstr:=sqlstr ||  ' and TRANSMISSION_METHOD = '''||ip_trans_method||'''';
  END IF;

  IF ip_esn IS NOT NULL THEN
 sqlstr:=sqlstr ||  ' and esn = '''||ip_esn||'''';
  END IF;

 sqlstr:=sqlstr || ' and task_create_date >= trunc(sysdate) - nvl(to_number('||ip_create_date||'),1)';
 RETURN sqlstr;
END apex_action_item_source;

   PROCEDURE accept_case_to_wipbin(
      p_case_objid IN NUMBER,
      p_user_objid IN NUMBER,
      p_wipbin_objid IN NUMBER,
      p_error_no OUT VARCHAR2,
      p_error_str OUT VARCHAR2
   )
   IS
      CURSOR case_curs
      IS
      SELECT *
      FROM table_case
      WHERE objid = p_case_objid;
      case_rec case_curs%rowtype;
      CURSOR wipbin_curs
      IS
      SELECT objid default_wipbin,title
      FROM table_wipbin
      WHERE wipbin_owner2user = p_user_objid
      AND objid = p_wipbin_objid;

      wipbin_rec wipbin_curs%rowtype;
      CURSOR queue_curs(
         c_objid IN NUMBER
      )
      IS
      SELECT *
      FROM table_queue
      WHERE objid = c_objid;
      queue_rec queue_curs%rowtype;
   BEGIN
      p_error_no   := '0';
      p_error_str  := 'SUCCESS';
      OPEN case_curs;
      FETCH case_curs
      INTO case_rec;
      CLOSE case_curs;

      OPEN wipbin_curs;
      FETCH wipbin_curs
      INTO wipbin_rec;
      CLOSE wipbin_curs;

      OPEN queue_curs(case_rec.case_currq2queue);
      FETCH queue_curs
      INTO queue_rec;
      CLOSE queue_curs;

      UPDATE table_condition SET condition = 2, wipbin_time = sysdate, title =
      'Open', s_title = 'OPEN'
      WHERE objid = case_rec.case_state2condition;
      COMMIT;

      INSERT
      INTO table_act_entry(
         objid,
         act_code,
         entry_time,
         addnl_info,
         proxy,
         removed,
         focus_type,
         focus_lowid,
         entry_name2gbst_elm,
         act_entry2case,
         act_entry2user
      )       VALUES(
         sa.seq('act_entry'),
         100,
         sysdate,
         'from Queue '||queue_rec.title||' to WIP '||wipbin_rec.title,
         NULL,
         0,
         0,
         0,
         268435622,
         p_case_objid,
         p_user_objid
      );
      COMMIT;

      UPDATE table_case SET case_currq2queue = NULL, case_wip2wipbin =
      wipbin_rec.default_wipbin, case_owner2user = p_user_objid
      WHERE objid = p_case_objid;
      COMMIT;

      EXCEPTION
      WHEN OTHERS
      THEN
         p_error_no  := SQLCODE;
         p_error_str   := sqlerrm;
   END;

----------------------------------------------------------------------------------------------------
-- PROCEDURE sp_apex_close_action_item was moved from package IGATE to package: APEX_CRM_PKG
----------------------------------------------------------------------------------------------------

PROCEDURE sp_apex_close_action_item (
      p_task_objid   IN       NUMBER,
      p_status       IN       NUMBER,
      p_user         IN       VARCHAR2,
      p_dummy_out    OUT      NUMBER
   )
   IS
   CURSOR gbst_elm_curs (c_objid IN NUMBER, c_title IN VARCHAR2)
   IS
      SELECT *
        FROM table_gbst_elm
       WHERE gbst_elm2gbst_lst = c_objid AND title LIKE c_title;
--
   CURSOR gbst_lst_curs (c_title IN VARCHAR2)
   IS
      SELECT *
        FROM table_gbst_lst
       WHERE title LIKE c_title;
--
   CURSOR employee_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM table_employee
       WHERE employee2user = c_objid;
--
   CURSOR queue2_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM table_queue
       WHERE objid = c_objid;
--
   CURSOR task_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM table_task
       WHERE objid = c_objid;
--
   CURSOR condition_curs (c_objid IN NUMBER)
   IS
      SELECT *
        FROM table_condition
       WHERE objid = c_objid;
--
      gbst_elm_title     VARCHAR2 (100);
      gbst_elm_rec       gbst_elm_curs%rowtype;
      gbst_elm2_rec      gbst_elm_curs%rowtype;
      gbst_lst_rec       gbst_lst_curs%rowtype;
      gbst_lst2_rec      gbst_lst_curs%rowtype;
      --user2_rec          user2_curs%ROWTYPE;
      --current_user_rec   current_user_curs%ROWTYPE;
      task_rec           task_curs%rowtype;
      condition_rec      condition_curs%rowtype;
      employee_rec       employee_curs%rowtype;
      queue2_rec         queue2_curs%rowtype;
      act_entry_objid    NUMBER;
      cnt                NUMBER                       := 0;
      -- OTA flag:
      c_ota_type         table_task.x_ota_type%TYPE;

      CURSOR cur_empl_user IS
      SELECT u.objid user_objid,E.objid employee_objid
      FROM table_user u,table_employee E
      WHERE E.employee2user=u.objid
      AND u.s_login_name = p_user;

      rec_empl_user cur_empl_user%rowtype;

      -- Fail OTA transaction when IGATE transaction fails with status 3 (Failed - NTN)
      PROCEDURE fail_ota_trans (p_x_task2x_call_trans IN NUMBER)
      IS
-- ------------------------------------ --
-- "NTN" stands for Non Tracfone Number --
-- ------------------------------------ --
         CURSOR x_code_hist_cur
         IS
            SELECT   x_sequence
                FROM table_x_code_hist
               WHERE code_hist2call_trans = p_x_task2x_call_trans
            ORDER BY objid ASC;

         x_code_hist_rec    x_code_hist_cur%rowtype;

         CURSOR x_call_trans_cur
         IS
            SELECT x_service_id, x_min, ROWID
              FROM table_x_call_trans
             WHERE objid = p_x_task2x_call_trans;

         x_call_trans_rec   x_call_trans_cur%rowtype;
      BEGIN
         -- 1) fail ota trans
         UPDATE table_x_ota_transaction
            SET x_status = 'Failed - NTN'
          WHERE x_ota_trans2x_call_trans = p_x_task2x_call_trans
            AND x_action_type = '1';                             -- activation

         -- 2) fail code hist
         OPEN x_code_hist_cur;

         FETCH x_code_hist_cur
          INTO x_code_hist_rec;

         IF x_code_hist_cur%found
         THEN
            UPDATE table_x_code_hist
               SET x_code_accepted = 'Failed NTN'
             WHERE code_hist2call_trans = p_x_task2x_call_trans;
         END IF;

         CLOSE x_code_hist_cur;

         -- 3) fail call trans
         OPEN x_call_trans_cur;

         FETCH x_call_trans_cur
          INTO x_call_trans_rec;

         IF x_call_trans_cur%found
         THEN
            UPDATE table_x_call_trans
               SET x_result = 'Failed',
                   x_reason = 'Failed - NTN'
             WHERE ROWID = x_call_trans_rec.ROWID;
         END IF;

         CLOSE x_call_trans_cur;

         -- 4) put the old sequence to ESN
         UPDATE table_part_inst
            SET x_sequence = x_code_hist_rec.x_sequence
          WHERE part_serial_no = x_call_trans_rec.x_service_id
            AND x_domain = 'PHONES';

         -- 5) update MIN as NTN so it will not be picked up again for any ESN
         UPDATE table_part_inst
            SET x_part_inst_status = '60'                               -- NTN
                                         ,
                last_trans_time = sysdate,
                status2x_code_table = (SELECT objid
                                         FROM table_x_code_table
                                        WHERE x_code_number = '60')
          WHERE part_serial_no = x_call_trans_rec.x_min AND x_domain = 'LINES';
      -- COMMIT is executed at the end of main procedure - sp_close_action_item
      END fail_ota_trans;
--
   BEGIN
      p_dummy_out := 1;

      SELECT decode (p_status,
                     0, 'Succeeded',
                     1, 'Failed - Closed',
                     2, 'Failed - Retail ESN',
                     3, 'Failed - NTN'
                    )
        INTO gbst_elm_title
        FROM dual;

      -- set OTA flag:
      IF gbst_elm_title = 'Succeeded'
      THEN
         c_ota_type := ota_util_pkg.ota_success;
      ELSE
         c_ota_type := ota_util_pkg.ota_failed;
      END IF;

--
      cnt := cnt + 1;                                                      --1
      dbms_output.put_line ('sp_Close_Action_Item:' || cnt);

--
     OPEN cur_empl_user;
     FETCH cur_empl_user INTO rec_empl_user;
     CLOSE cur_empl_user;

      --OPEN current_user_curs;

      --FETCH current_user_curs
      -- INTO current_user_rec;

      --IF current_user_curs%NOTFOUND
      --THEN
      --   current_user_rec.USER := 'appsrv';            -- changed from appsvr
      --END IF;

      --CLOSE current_user_curs;

--
      cnt := cnt + 1;                                                      --2
      dbms_output.put_line ('sp_Close_Action_Item:' || cnt);

--
      OPEN task_curs (p_task_objid);

      FETCH task_curs
       INTO task_rec;

      IF task_curs%notfound
      THEN
         p_dummy_out := 2;                                    --no task found

         CLOSE task_curs;

         RETURN;
      END IF;

      CLOSE task_curs;

      -- handle Failed - NTN transactions for OTA:
      IF p_status = 3 AND task_rec.x_ota_type IS NOT NULL
      THEN
         fail_ota_trans (task_rec.x_task2x_call_trans);
      END IF;

--
      cnt := cnt + 1;                                                      --3
      dbms_output.put_line (   'sp_Close_Action_Item:'
                            || cnt
                            || ' task_rec.task_state2condition:'
                            || task_rec.task_state2condition
                           );

--
      OPEN condition_curs (task_rec.task_state2condition);

      FETCH condition_curs
       INTO condition_rec;

      IF condition_curs%notfound
      THEN
         p_dummy_out := 3;                              -- no condition found

         CLOSE condition_curs;

         RETURN;
      ELSE
         IF condition_rec.title = 'Closed Action Item'
         THEN
            CLOSE condition_curs;

            RETURN;
         END IF;
      END IF;

      CLOSE condition_curs;

--
      cnt := cnt + 1;                                                      --4
      dbms_output.put_line ('sp_Close_Action_Item:' || cnt);

--
      --OPEN user2_curs (current_user_rec.USER);

      --FETCH user2_curs
      -- INTO user2_rec;

      --IF user2_curs%NOTFOUND
      --THEN
      --   CLOSE user2_curs;

      --   RETURN;
      --END IF;

      --CLOSE user2_curs;

--
      cnt := cnt + 1;                                                      --5
      dbms_output.put_line (   'sp_Close_Action_Item:'
                            || cnt
                            || ' task_rec.task_currq2queue:'
                            || task_rec.task_currq2queue
                           );
--
--    open queue2_curs(task_rec.task_currq2queue);
--      fetch queue2_curs into queue2_rec;
--      if queue2_curs%notfound then
--        return;
--      end if;
--    close queue2_curs;
--
      cnt := cnt + 1;                                                      --6
      dbms_output.put_line ('sp_Close_Action_Item:' || cnt);

--
      OPEN gbst_lst_curs ('Closed Action Item');

      FETCH gbst_lst_curs
       INTO gbst_lst_rec;

      IF gbst_lst_curs%notfound
      THEN
         p_dummy_out := 4;                                --no gbst_lst found

         CLOSE gbst_lst_curs;

         RETURN;
      END IF;

      CLOSE gbst_lst_curs;

--
      cnt := cnt + 1;                                                      --7
      dbms_output.put_line (   'sp_Close_Action_Item:'
                            || cnt
                            || 'gbst_lst_rec.objid,gbst_elm_title:'
                            || gbst_lst_rec.objid
                            || ':'
                            || gbst_elm_title
                           );

--
      OPEN gbst_elm_curs (gbst_lst_rec.objid, gbst_elm_title);

      FETCH gbst_elm_curs
       INTO gbst_elm_rec;

      IF gbst_elm_curs%notfound
      THEN
         p_dummy_out := 5;                                --no gbst_elm found

         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--
      cnt := cnt + 1;                                                      --8
      dbms_output.put_line ('gbst_elm_rec.objid:' || gbst_elm_rec.objid);
      dbms_output.put_line ('gbst_elm_rec.title:' || gbst_elm_rec.title);
      dbms_output.put_line ('sp_Close_Action_Item:' || cnt);

--
      OPEN gbst_lst_curs ('Activity Name');

      FETCH gbst_lst_curs
       INTO gbst_lst2_rec;

      IF gbst_lst_curs%notfound
      THEN
         CLOSE gbst_lst_curs;

         RETURN;
      END IF;

      CLOSE gbst_lst_curs;

--
      cnt := cnt + 1;                                                      --9
      dbms_output.put_line (   'sp_Close_Action_Item:'
                            || cnt
                            || ' gbst_lst_rec.objid:'
                            || gbst_lst_rec.objid
                           );

--
      OPEN gbst_elm_curs (gbst_lst2_rec.objid, 'Close Action Item');

      FETCH gbst_elm_curs
       INTO gbst_elm2_rec;

      IF gbst_elm_curs%notfound
      THEN
         CLOSE gbst_elm_curs;

         RETURN;
      END IF;

      CLOSE gbst_elm_curs;

--
      cnt := cnt + 1;                                                     --10
      dbms_output.put_line ('sp_Close_Action_Item:' || cnt);

--
      --OPEN employee_curs (user2_rec.objid);

      --FETCH employee_curs
      -- INTO employee_rec;

      --IF employee_curs%NOTFOUND
      --THEN
      --   p_dummy_out := 6;                         --no employee record found

      --   CLOSE employee_curs;

      --   RETURN;
      --END IF;

      --CLOSE employee_curs;

--
      cnt := cnt + 1;                                                     --11
      dbms_output.put_line ('sp_Close_Action_Item:' || cnt);

--
      UPDATE table_condition
         SET condition = 8192,
             wipbin_time = sysdate,
             title = 'Closed Action Item',
             s_title = 'CLOSED ACTION ITEM',
             sequence_num = 0
       WHERE objid = condition_rec.objid;

--
      cnt := cnt + 1;                                                     --12
      dbms_output.put_line ('sp_Close_Action_Item:' || cnt);
--
      dbms_output.put_line ('gbst_elm_rec.objid:' || gbst_elm_rec.objid);
      dbms_output.put_line ('gbst_elm_rec.title:' || gbst_elm_rec.title);

      UPDATE table_task
         SET comp_date = sysdate,
             active = 1,
             task_sts2gbst_elm = gbst_elm_rec.objid,
             task_wip2wipbin = NULL,
             task_currq2queue = NULL,
             -- set OTA type
             x_ota_type = c_ota_type
       WHERE objid = task_rec.objid;

      -- OTA x_status update
      -- UPDATE table_x_ota_transaction SET x_status to value 'OTA SEND'
      -- Java program will be looking for this value in this table every 30 seconds
      -- to send activation PSMS message to the phone over the air
      IF c_ota_type = ota_util_pkg.ota_success THEN
         -- We want to make sure to update our OTA transaction
         -- only if it is not completed yet
         -- If IGATE process was too late and didn't finish on time
         -- but in the mean time customer called and our transaction was completed by the
         -- WEBSCR or IVR we don't want to update that traqnsaction here
         UPDATE table_x_ota_transaction
            SET x_status = ota_util_pkg.ota_send
          WHERE x_ota_trans2x_call_trans = task_rec.x_task2x_call_trans
            AND UPPER (x_status) <> 'COMPLETED';
      END IF;

--
      cnt := cnt + 1;                                                     --13
      dbms_output.put_line ('sp_Close_Action_Item:' || cnt);

--
      -- 04/10/03 select seq_act_entry.nextval +(power(2,28))
      SELECT seq ('act_entry')
        INTO act_entry_objid
        FROM dual;

--
      cnt := cnt + 1;                                                     --14
      dbms_output.put_line ('sp_Close_Action_Item:' || cnt);

--
      INSERT INTO table_act_entry
                  (objid, act_code, entry_time,
                   addnl_info, removed, focus_type, focus_lowid,
                   act_entry2task, act_entry2user, entry_name2gbst_elm
                  )
           VALUES (act_entry_objid, 332871994, sysdate,
                   'Closed at ' || sysdate, 0, 5080, task_rec.objid,
                   task_rec.objid, rec_empl_user.user_objid, gbst_elm_rec.objid
                  );

/* --CR51768 suppressing the use of table sa.table_time_bomb.
      INSERT INTO table_time_bomb (objid,
                                   escalate_time,
                                   end_time,
                                   focus_lowid,
                                   focus_type,
                                   time_period,
                                   flags,
                                   left_repeat,
                                   cmit_creator2employee)
                           VALUES (seq ('time_bomb'),
                                   TO_DATE ('01/01/1753', 'dd/mm/yyyy'),
                                   sysdate,
                                   task_rec.objid,
                                   5080,
                                   act_entry_objid,
                                   333053954,
                                   0,
                                   rec_empl_user.employee_objid);
*/

      COMMIT;

   END sp_apex_close_action_item;
--------------------------------------------------------------------------------
  FUNCTION get_cntct_rslt_tas (ipv_f_name VARCHAR2,
                            ipv_l_name VARCHAR2,
                            ipn_phone VARCHAR2,
                            ipv_esn   VARCHAR2,
                            ipn_cust_id VARCHAR2,
                            ipv_email VARCHAR2,
                            ipv_interact_id VARCHAR2,
                            ipv_min VARCHAR2,
                            ipv_sim VARCHAR2,
                            ipv_address VARCHAR2,
                            ipv_zipcode VARCHAR2)
  RETURN tab_cntct_rslt_ty PIPELINED IS
   rc SYS_REFCURSOR;
   I NUMBER := 0;
BEGIN
    get_cntct_rslt_tas(ipv_f_name,
                   ipv_l_name,
                   ipn_phone,
                   ipv_esn,
                   ipn_cust_id,
                   ipv_email,
                   ipv_interact_id,
                   ipv_min,
                   ipv_sim,
                   ipv_address,
                   ipv_zipcode,
       NULL,
                   rc);

  LOOP
    FETCH rc INTO cntct_reslt;
    EXIT WHEN rc%notfound;
    PIPE ROW(cntct_reslt);
  END LOOP;
  END;
--------------Overloaded to add Lifeline ID and do not break other branches-----------------------
  FUNCTION get_cntct_rslt_tas (ipv_f_name VARCHAR2,
                            ipv_l_name VARCHAR2,
                            ipn_phone VARCHAR2,
                            ipv_esn   VARCHAR2,
                            ipn_cust_id VARCHAR2,
                            ipv_email VARCHAR2,
                            ipv_interact_id VARCHAR2,
                            ipv_min VARCHAR2,
                            ipv_sim VARCHAR2,
                            ipv_address VARCHAR2,
                            ipv_zipcode VARCHAR2,
                            ipv_lid VARCHAR2)
  RETURN tab_cntct_rslt_ty PIPELINED IS
--------------------------------------------------------------------------------
   rc SYS_REFCURSOR;
   I NUMBER := 0;
BEGIN
    get_cntct_rslt_tas(ipv_f_name,
                   ipv_l_name,
                   ipn_phone,
                   ipv_esn,
                   ipn_cust_id,
                   ipv_email,
                   ipv_interact_id,
                   ipv_min,
                   ipv_sim,
                   ipv_address,
                   ipv_zipcode,
                   ipv_lid,
                   rc);

  LOOP
    FETCH rc INTO cntct_reslt;
    EXIT WHEN rc%notfound;
    PIPE ROW(cntct_reslt);
  END LOOP;
END;
--------------------------------------------------------------------------------
  FUNCTION get_cntct_rslt (ipv_f_name VARCHAR2,
                            ipv_l_name VARCHAR2,
                            ipn_phone VARCHAR2,
                            ipv_esn   VARCHAR2,
                            ipn_cust_id VARCHAR2,
                            ipv_email VARCHAR2,
                            ipv_interact_id VARCHAR2)
  RETURN tab_cntct_rslt_ty PIPELINED IS
--------------------------------------------------------------------------------
   rc SYS_REFCURSOR;
   I NUMBER := 0;
BEGIN
    get_cntct_rslt(ipv_f_name,
                   ipv_l_name,
                   ipn_phone,
                   ipv_esn,
                   ipn_cust_id,
                   ipv_email,
                   ipv_interact_id,
                   rc);

  LOOP
    FETCH rc INTO cntct_reslt;
    EXIT WHEN rc%notfound;
    PIPE ROW(cntct_reslt);
  END LOOP;
END;
--------------------------------------------------------------------------------
PROCEDURE PASSWORD_VERIFY_FUNCTION(
      username  IN   VARCHAR2,
      PASSWORD  IN   VARCHAR2,
      op_result OUT BOOLEAN,
      op_message OUT VARCHAR2)

  IS
    N          BOOLEAN;
    M          INTEGER;
    isdigit    NUMBER;
    ischar     NUMBER;
    ispunct    BOOLEAN;
    digitarray VARCHAR2(20);
    punctarray VARCHAR2(25);
    chararray  VARCHAR2(52);
    npwdlength NUMBER:=8;
    v_encrypted_password VARCHAR2(30);

    CURSOR latest_passwords_cur IS
    SELECT *     FROM table_x_password_hist
    WHERE s_x_login_name = UPPER(username)
    AND ROWNUM <=5
    ORDER BY x_password_chg DESC;

  BEGIN

    op_result:=FALSE;
    op_message:='';

    SELECT encryptpassword(PASSWORD)
    INTO v_encrypted_password
    FROM dual;

    digitarray:= '0123456789';
    chararray := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    punctarray:='!"#$%&()``*+,-/:;<=>?_';
    -- Check if the password is same as the username
    IF nls_lower(PASSWORD) = nls_lower(username) THEN
      op_message:= 'New Password same as or similar to user';
      RETURN;
    END IF;
    -- Check for the minimum length of the password
    IF LENGTH(PASSWORD) < npwdlength THEN
      op_message:= 'Password length less than ' || npwdlength;
      RETURN;
    END IF;
    -- Check if the password is too simple. A dictionary of words may be
    -- maintained and a check may be made so as not to allow the words
    -- that are too simple for the password.
    IF nls_lower(PASSWORD)   IN ('welcome', 'database', 'account', 'user', 'password', 'oracle', 'computer', 'abcd') THEN
      op_message:=  'New Password too simple';
      RETURN;
    END IF;
    -- Check if the password contains at least one letter, one digit and one
    -- punctuation mark.
    -- 1. Check for the digit
    isdigit:=0;
    M      := LENGTH(PASSWORD);
    FOR I  IN 1..10
    LOOP
      FOR j IN 1..M
      LOOP
        IF substr(PASSWORD,j,1) = substr(digitarray,I,1) THEN
          isdigit := isdigit+1;
          IF isdigit= 3 THEN
             GOTO findchar;
          END IF;
        END IF;
      END LOOP;
    END LOOP;
    IF isdigit < 3 THEN
      op_message:= 'New Password should contain at least 3 digits, 3 characters and one special character';
      RETURN;
    END IF;
    -- 2. Check for the character
    <<findchar>> ischar:=0;
    FOR I IN 1..LENGTH(chararray)
    LOOP
      FOR j IN 1..M
      LOOP
        IF substr(PASSWORD,j,1) = substr(chararray,I,1) THEN
          ischar := ischar+1;
          IF ischar = 3 THEN
             GOTO findpunct;
          END IF;
        END IF;
      END LOOP;
    END LOOP;
    IF ischar < 3 THEN
      op_message:= 'New Password should contain at least 3 digits, 3 character and one special character';
      RETURN;
    END IF;
    -- 3. Check for the punctuation
           <<findpunct>> ispunct:=FALSE;
    FOR I IN 1..LENGTH(punctarray)
    LOOP
      FOR j IN 1..M
      LOOP
        IF substr(PASSWORD,j,1) = substr(punctarray,I,1) THEN
          ispunct              :=TRUE;
          GOTO endsearch;
        END IF;
      END LOOP;
    END LOOP;
    IF ispunct = FALSE THEN
      op_message:=  'New Password should contain at least 3 digits, 3 characters and one special character';
      RETURN;
    END IF;
    <<endsearch>>
    -- Check if the password differs from the previous 5 password

    IF username IS NOT NULL THEN
        FOR latest_passwords_rec  IN latest_passwords_cur
        LOOP
          IF v_encrypted_password = latest_passwords_rec.x_password_hist THEN
             op_message:= 'New Password must not repeat one of the last five passwords';
             RETURN;
          END IF;
        END LOOP;
    END IF;
    -- Everything is fine; return TRUE ;
    op_result:=TRUE;

  END;

FUNCTION refresh_case_notes (c_objid NUMBER)
RETURN rcn_arr
PIPELINED
AS
  c_notes CLOB;
  v_break VARCHAR2(10) := '<br />';
BEGIN
    FOR I IN (SELECT *
              FROM   (SELECT /*+ FIRST_ROWS(250) */
                             el.s_title,
                             '**** '||el.s_title||'  '||to_char(nvl(L.creation_time,E.entry_time),'MM/DD/YYYY HH:MI:SS PM')||' '||nvl(u.login_name,'N/A') case_hist_entry,
                             decode(L.action_type,NULL,'',' Action Type: '||L.action_type||CHR(10)) action_type,
                             nvl(L.creation_time,E.entry_time) edate,
                             L.DESCRIPTION,
                             sc.notes,
                             E.addnl_info,
                             E.objid ae_objid,
                             cc.summary
                      FROM   table_notes_log L,
                             table_act_entry E,
                             table_user u,
                             table_gbst_elm el,
                             table_status_chg sc,
                             table_close_case cc
                      WHERE  1=1
                      AND    cc.close_case2act_entry(+) = E.objid
                      AND    sc.status_chg2act_entry(+) = E.objid
                      AND    L.objid(+) = E.act_entry2notes_log
                      AND    u.objid(+) = E.act_entry2user
                      AND    el.objid = E.entry_name2gbst_elm
                      AND    el.s_title IN ('NOTES','CHG STATUS','FORWARD','CASE CLOSE')
                      AND    E.act_entry2case = c_objid
                      AND    nvl(E.entry_time,sysdate) =  decode(el.s_title,'CASE CLOSE',(SELECT MAX(e2.entry_time)
                                                                                          FROM    table_act_entry e2
                                                                                          WHERE   E.entry_name2gbst_elm = e2.entry_name2gbst_elm
                                                                                          AND     E.act_entry2case = e2.act_entry2case),nvl(E.entry_time,sysdate))
                      )
              ORDER BY edate ASC)
    LOOP
      c_notes := c_notes ||I.case_hist_entry||I.action_type;
      IF I.s_title = 'CHG STATUS' THEN
      c_notes := c_notes ||v_break||I.notes;
      ELSIF I.s_title = 'CASE CLOSE' THEN
      c_notes := c_notes ||v_break||I.summary;
      ELSE
      c_notes := c_notes ||I.DESCRIPTION;
      END IF;
      c_notes := REPLACE(c_notes,CHR(10),v_break)||v_break||v_break||v_break;
      PIPE ROW(c_notes);
      c_notes := NULL;
    END LOOP;

    RETURN;
END refresh_case_notes;
--------------------------------------------------------------------------------
FUNCTION refresh_case_notes_2 (case_id VARCHAR2)
RETURN rcn_arr
PIPELINED
AS
  c_notes CLOB;
  v_break VARCHAR2(10) := '<br />';
BEGIN
    FOR I IN (SELECT *
              FROM   (SELECT /*+ FIRST_ROWS(250) */
                             el.s_title,
                             '**** '||el.s_title||'  '||to_char(nvl(L.creation_time,E.entry_time),'MM/DD/YYYY HH:MI:SS PM')||' '||nvl(u.login_name,'N/A') case_hist_entry,
                             decode(L.action_type,NULL,'',' Action Type: '||L.action_type||CHR(10)) action_type,
                             nvl(L.creation_time,E.entry_time) edate,
                             L.DESCRIPTION,
                             sc.notes,
                             E.addnl_info,
                             E.objid ae_objid,
                             cc.summary
                      FROM   table_case C,
                             table_notes_log L,
                             table_act_entry E,
                             table_user u,
                             table_gbst_elm el,
                             table_status_chg sc,
                             table_close_case cc
                      WHERE  1=1
                      AND    C.id_number = case_id
                      AND    cc.close_case2act_entry(+) = E.objid
                      AND    sc.status_chg2act_entry(+) = E.objid
                      AND    L.objid(+) = E.act_entry2notes_log
                      AND    u.objid(+) = E.act_entry2user
                      AND    el.objid = E.entry_name2gbst_elm
                      AND    el.s_title IN ('NOTES','CHG STATUS','FORWARD','CASE CLOSE')
                      AND    E.act_entry2case = C.objid
                      AND    nvl(E.entry_time,sysdate) =  decode(el.s_title,'CASE CLOSE',(SELECT MAX(e2.entry_time)
                                                                                          FROM    table_act_entry e2
                                                                                          WHERE   E.entry_name2gbst_elm = e2.entry_name2gbst_elm
                                                                                          AND     E.act_entry2case = e2.act_entry2case),nvl(E.entry_time,sysdate))
                      )
              ORDER BY edate ASC)
    LOOP
      c_notes := c_notes ||I.case_hist_entry||I.action_type;
      IF I.s_title = 'CHG STATUS' THEN
      c_notes := c_notes ||v_break||I.notes;
      ELSIF I.s_title = 'CASE CLOSE' THEN
      c_notes := c_notes ||v_break||I.summary;
      ELSE
      c_notes := c_notes ||I.DESCRIPTION;
      END IF;
      c_notes := REPLACE(c_notes,CHR(10),v_break)||v_break||v_break||v_break;
      PIPE ROW(c_notes);
      c_notes := NULL;
    END LOOP;

    RETURN;
END refresh_case_notes_2;


--------------------------------------------------------------------------------
  PROCEDURE case_maintenance(ip_carrier_name VARCHAR2,
                             ip_condition VARCHAR2,
                             ip_case_id VARCHAR2,
                             ip_case_type VARCHAR2,
                             ip_title VARCHAR2,
                             ip_queue VARCHAR2,
                             ip_esn VARCHAR2,
                             ip_min VARCHAR2,
                             ip_iccid VARCHAR2,
                             ip_date_from VARCHAR2,
                             ip_date_to VARCHAR2,
                             ip_check_results NUMBER,
                             ip_app_id NUMBER,
                             ip_pg_id NUMBER,
                             ip_app_session NUMBER,
                             ip_recordset OUT SYS_REFCURSOR)
  IS
    sqlstr VARCHAR2(1000);
    ck_box VARCHAR2(10) := 'unchecked';
    v_rownum NUMBER := 501;
  BEGIN

    IF ip_check_results=1 THEN
     ck_box := 'checked';
    END IF;

    sqlstr:= ' select ''<input type="checkbox" '||ck_box||' value="''||id_number||''" name="f01">'' "select_link"';
    sqlstr:=sqlstr||',''<a href="f?p='||ip_app_id||':30:'||ip_app_session||'::NO::P30_CASE_ID,P30_BACK:''||id_number||'','||ip_pg_id||'">''||id_number||''</a>'' "case_link"';
    sqlstr:=sqlstr||',id_number,case_type,title,carrier_mkt_name,esn,phone_model,min,condition,status,case_objid
                 from case_maint_mv
                 where 1=1 ';
    sqlstr:=sqlstr || ' and creation_time between to_date('''||ip_date_from||''',''mm/dd/yyyy'')';
    sqlstr:=sqlstr || ' and to_date('''||ip_date_to||''',''mm/dd/yyyy'')';

    IF ip_case_type IS NOT NULL THEN
      sqlstr:=sqlstr || ' and case_type = '''||ip_case_type||'''';
    END IF;

    IF ip_title IS NOT NULL THEN
      sqlstr:=sqlstr || ' and s_title = '''||UPPER(ip_title)||'''';
    END IF;

    IF nvl(UPPER(ip_condition),'ALL') = 'ALL' THEN
     sqlstr:=sqlstr || ' and s_condition <> ''CLOSED''';
    ELSE
     sqlstr:=sqlstr || ' and s_condition = '''||UPPER(ip_condition)||'''';
    END IF;

    IF ip_carrier_name IS NOT NULL THEN
      sqlstr:=sqlstr || ' and carrier_mkt_name = '''||ip_carrier_name||'''';
    END IF;

    IF ip_case_id IS NOT NULL THEN
      sqlstr:=sqlstr || ' and id_number = '''||ip_case_id||'''';
    END IF;

    IF ip_esn IS NOT NULL THEN
      sqlstr:=sqlstr ||  ' and esn = '''||ip_esn||'''';
    END IF;

    IF ip_min IS NOT NULL THEN
      sqlstr:=sqlstr ||  ' and min = '''||ip_min||'''';
    END IF;

    IF ip_iccid IS NOT NULL THEN
      sqlstr:=sqlstr ||  ' and x_iccid = '''||ip_iccid||'''';
    END IF;

    sqlstr:=sqlstr ||  ' and rownum < '''||v_rownum||'''';

    -- dbms_output.put_line(sqlstr);

    OPEN ip_recordset FOR sqlstr;

  END case_maintenance;
--------------------------------------------------------------------------------
  FUNCTION case_maintenance(ip_carrier_name VARCHAR2,
                            ip_condition VARCHAR2,
                            ip_case_id VARCHAR2,
                            ip_case_type VARCHAR2,
                            ip_title VARCHAR2,
                            ip_queue VARCHAR2,
                            ip_esn VARCHAR2,
                            ip_min VARCHAR2,
                            ip_iccid VARCHAR2,
                            ip_date_from VARCHAR2,
                            ip_date_to VARCHAR2,
                            ip_check_results NUMBER,
                            ip_app_id NUMBER,
                            ip_pg_id NUMBER,
                            ip_app_session NUMBER)

  RETURN case_maintenance_tab
  PIPELINED
  IS
    rc SYS_REFCURSOR;
  BEGIN
    case_maintenance(ip_carrier_name,
                     ip_condition,
                     ip_case_id,
                     ip_case_type,
                     ip_title,
                     ip_queue,
                     ip_esn,
                     ip_min,
                     ip_iccid,
                     ip_date_from,
                     ip_date_to,
                     ip_check_results,
                     ip_app_id,
                     ip_pg_id,
                     ip_app_session,
                     rc);
    LOOP
      FETCH rc INTO case_maintenance_rslt;
      EXIT WHEN rc%notfound;
      PIPE ROW(case_maintenance_rslt);
    END LOOP;
  END case_maintenance;
--------------------------------------------------------------------------------
  PROCEDURE close_bulk_cases (ip_carrier_name VARCHAR2,
                              ip_condition VARCHAR2,
                              ip_case_id VARCHAR2,
                              ip_case_type VARCHAR2,
                              ip_title VARCHAR2,
                              ip_queue VARCHAR2,
                              ip_esn VARCHAR2,
                              ip_min VARCHAR2,
                              ip_iccid VARCHAR2,
                              ip_date_from VARCHAR2,
                              ip_date_to VARCHAR2,
                              ip_reason VARCHAR2,
                              ip_user VARCHAR2,
                              ip_user_objid NUMBER,
                              op_msg OUT VARCHAR2)
  IS
     v_case_closed_cnt NUMBER := 0;
     v_condition       VARCHAR2(80);
     v_msg             VARCHAR2(200);
     v_status          VARCHAR2(100);
     v_error_no        VARCHAR2(200);
     v_error_str       VARCHAR2(200);
  BEGIN
    -- THE VIEW ACTION_ITEM_MAINTENANCE CONTROLS AT MOST (500)
    -- VIEWABLE ACT ITEMS AT A TIME. THIS MEANS WE CAN ONLY CLOSE
    -- THAT MANY EACH CALL
    FOR I IN (SELECT case_objid,
                     id_number,
                     case_type,
                     title,
                     carrier_mkt_name,
                     esn,
                     phone_model,
                     MIN,
                     condition,
                     status
              FROM   TABLE(apex_crm_pkg.case_maintenance(
                                          ip_carrier_name,
                                          ip_condition,
                                          ip_case_id,
                                          ip_case_type,
                                          ip_title,
                                          ip_queue,
                                          ip_esn,
                                          ip_min,
                                          ip_iccid,
                                          ip_date_from,
                                          ip_date_to,
                                          NULL, --ip_check_results number,
                                          NULL, --ip_app_id number,
                                          NULL, --ip_pg_id number,
                                          NULL --ip_app_session number
                                          ))
              )
    LOOP
      -- MATERIALIZED VIEW MAY NOT HAVE CURRENT CONDITION STATE
      -- IF CASE IS NOT CLOSED THEN PROCEED
        sa.igate.sp_close_case (p_case_id => I.id_number,
                                p_user_login_name => ip_user,
                                p_source => 'APEX Case Maintenance',
                                p_resolution_code => NULL,
                                p_status => v_status,
                                p_msg => v_msg);
      -- LOG THE NOTES
        sa.clarify_case_pkg.log_notes(p_case_objid => I.case_objid,
                                      p_user_objid => ip_user_objid,
                                      p_notes => ip_reason,
                                      p_action_type => 'Close',
                                      p_error_no => v_error_no,
                                      p_error_str => v_error_str);

         v_case_closed_cnt := v_case_closed_cnt+1;
    END LOOP;

    op_msg := to_char(v_case_closed_cnt)||' Cases closed ';

  END close_bulk_cases;
--------------------------------------------------------------------------------
  PROCEDURE action_item_maintenance(ip_carrier_name VARCHAR2,
                                    ip_carrier_mkt VARCHAR2,
                                    ip_order_type VARCHAR2,
                                    ip_trans_method VARCHAR2,
                                    ip_status VARCHAR2,
                                    ip_condition VARCHAR2,
                                    ip_esn VARCHAR2,
                                    ip_queue VARCHAR2,
                                    ip_task_id VARCHAR2,
                                    ip_date_from NUMBER,
                                    ip_check_results NUMBER,
                                    ip_app_id NUMBER,
                                    ip_pg_id NUMBER,
                                    ip_app_session NUMBER,
                                    ip_calling_from_apex NUMBER,
                                    ip_recordset OUT SYS_REFCURSOR)
  IS
    sqlstr VARCHAR2(4000);
    ckd_box VARCHAR2(150);
    v_rownum NUMBER := 501;
  BEGIN

    IF ip_carrier_name IS NULL AND
       ip_carrier_mkt IS  NULL AND
       ip_esn IS NULL AND
       (UPPER(ip_queue) = 'ALL' OR ip_queue IS NULL) AND
       ip_task_id IS NULL AND
       (UPPER(ip_trans_method) = 'ALL' OR ip_trans_method IS NULL) AND
       (UPPER(ip_order_type) = 'ALL' OR ip_order_type IS NULL) AND
       (UPPER(ip_status) = 'ALL' OR ip_status IS NULL)
       THEN
      sqlstr:= ' select null,null,null,null,null,null,null,null,null,'||
               'null,null,null,null,null,null,null from dual where rownum <1';
    ELSIF ip_date_from > 9 AND (ip_esn IS NULL AND ip_task_id IS NULL) THEN
      sqlstr:= ' select null,null,null,null,null,null,null,null,null,'||
               'null,null,null,null,null,null,null from dual where rownum <1';
    ELSE
      IF ip_calling_from_apex = 1 THEN
        IF ip_check_results=1 THEN
           ckd_box:= 'checked';
        ELSE
           ckd_box:= 'unchecked';
        END IF;
        sqlstr:=' select ''<input type="checkbox"  '||ckd_box||' value="''||t_objid||''" name="f01">'' "select_link",';
        sqlstr:=sqlstr ||'''<a href="f?p='||ip_app_id||':44:'||ip_app_session||'::NO::P44_TASK_ID,P44_BACK:''||t_id||'','||ip_pg_id||'">''||t_id||''</a>'' "task_link", ';
      ELSE
        sqlstr:= 'select t_objid "task_objid", null "task_link",';
      END IF;
      sqlstr:=sqlstr ||  '            t_id, ';
      sqlstr:=sqlstr ||  '            start_date, ';
      sqlstr:=sqlstr ||  '            f_name, ';
      sqlstr:=sqlstr ||  '            l_name, ';
      sqlstr:=sqlstr ||  '            condition, ';
      sqlstr:=sqlstr ||  '            queue, ';
      sqlstr:=sqlstr ||  '            owner, ';
      sqlstr:=sqlstr ||  '            status, ';
      sqlstr:=sqlstr ||  '            x_order_type, ';
      sqlstr:=sqlstr ||  '            carr_name, ';
      sqlstr:=sqlstr ||  '            carr_mkt, ';
      sqlstr:=sqlstr ||  '            x_esn, ';
      sqlstr:=sqlstr ||  '            current_method, ';
      sqlstr:=sqlstr ||  '            x_min ';
      IF ip_esn IS NOT NULL OR ip_task_id IS NOT NULL THEN
      sqlstr:=sqlstr ||  '     from   action_item_view';
      ELSE
      sqlstr:=sqlstr ||  '     from   action_item_mv';
      END IF;
      sqlstr:=sqlstr ||  '     where  1=1  ';
      -- PENDING CHANGE COMMENTED FOR NOW
      IF (ip_esn IS NULL AND ip_task_id IS NULL) THEN
        IF ip_date_from IS NOT NULL THEN
          sqlstr:=sqlstr || ' and    start_date between sysdate-'||ip_date_from||' and sysdate';
        END IF;
      END IF;
      IF ip_carrier_name IS NOT NULL THEN
        sqlstr:=sqlstr || ' and    carr_name = '''||ip_carrier_name||'''';
      END IF;
      IF ip_carrier_mkt IS NOT NULL AND UPPER(ip_carrier_mkt) != 'ALL' THEN
        sqlstr:=sqlstr || ' and    carr_mkt = '''||ip_carrier_mkt||'''';
      END IF;
      IF ip_esn IS NOT NULL THEN
        sqlstr:=sqlstr || ' and    x_esn = '''||ip_esn||'''';
      END IF;
      IF ip_task_id IS NOT NULL THEN
        sqlstr:=sqlstr || ' and    t_id = '''||ip_task_id||'''';
      END IF;
      IF UPPER(ip_order_type) != 'ALL' THEN
        sqlstr:=sqlstr || ' and    x_order_type = '''||ip_order_type||'''';
      END IF;
      IF UPPER(ip_status) != 'ALL' THEN
        sqlstr:=sqlstr || ' and    s_status = upper('''||ip_status||''')';
      END IF;
      IF UPPER(ip_queue) != 'ALL' THEN
        sqlstr:=sqlstr || ' and    s_queue like upper('''||ip_queue||'%'')';
      END IF;
      IF UPPER(ip_trans_method) != 'ALL' THEN
        sqlstr:=sqlstr || ' and    current_method = '''||ip_trans_method||'''';
      END IF;
      IF UPPER(ip_condition) != 'ALL' THEN
        sqlstr:=sqlstr || ' and    s_condition like upper('''||ip_condition||'%'')';
      END IF;
      IF ip_esn IS NULL AND ip_task_id IS NULL THEN
        sqlstr:=sqlstr ||  ' and rownum < '||v_rownum;
      END IF;
    END IF;

    --dbms_output.put_line(sqlstr);

    OPEN ip_recordset FOR sqlstr;

  END action_item_maintenance;
--------------------------------------------------------------------------------
  FUNCTION action_item_maintenance(ip_carrier_name VARCHAR2,
                                   ip_carrier_mkt VARCHAR2,
                                   ip_order_type VARCHAR2,
                                   ip_trans_method VARCHAR2,
                                   ip_status VARCHAR2,
                                   ip_condition VARCHAR2,
                                   ip_esn VARCHAR2,
                                   ip_queue VARCHAR2,
                                   ip_task_id VARCHAR2,
                                   ip_date_from NUMBER,
                                   ip_check_results NUMBER,
                                   ip_app_id NUMBER,
                                   ip_pg_id NUMBER,
                                   ip_app_session NUMBER,
                                   ip_calling_from_apex NUMBER)

  RETURN action_item_maintenance_tab
  PIPELINED
  IS
    rc SYS_REFCURSOR;
  BEGIN
    action_item_maintenance(ip_carrier_name,
                            ip_carrier_mkt,
                            ip_order_type,
                            ip_trans_method,
                            ip_status,
                            ip_condition,
                            ip_esn,
                            ip_queue,
                            ip_task_id,
                            ip_date_from,
                            ip_check_results,
                            ip_app_id,
                            ip_pg_id,
                            ip_app_session,
                            ip_calling_from_apex,
                            rc);
    LOOP
      FETCH rc INTO action_item_maintenance_rslt;
      EXIT WHEN rc%notfound;
      PIPE ROW(action_item_maintenance_rslt);
    END LOOP;
  END action_item_maintenance;
--------------------------------------------------------------------------------
  PROCEDURE close_bulk_action_items (ip_carrier_name VARCHAR2,
                                     ip_carrier_mkt VARCHAR2,
                                     ip_order_type VARCHAR2,
                                     ip_trans_method VARCHAR2,
                                     ip_status VARCHAR2,
                                     ip_condition VARCHAR2,
                                     ip_esn VARCHAR2,
                                     ip_queue VARCHAR2,
                                     ip_task_id VARCHAR2,
                                     ip_date_from NUMBER,
                                     ip_user VARCHAR2,
                                     op_msg OUT VARCHAR2)
  IS
     v_task_closed_cnt  NUMBER := 0;
     v_task_cases_closed_cnt  NUMBER := 0;
     v_dummy    VARCHAR2(200);
     v_dummy2   VARCHAR2(200);
     v_condition VARCHAR2(80);

    CURSOR task_cases (t_objid NUMBER)
    IS
      SELECT id_number
      FROM   table_case,
             table_x_call_trans,
             table_task
      WHERE  1=1
      AND    x_task2x_call_trans = table_x_call_trans.objid
      AND    table_case.x_esn = table_x_call_trans.x_service_id
      AND    table_case.x_min = table_x_call_trans.x_min
      AND    table_task.objid = t_objid;

  BEGIN
    -- THE VIEW ACTION_ITEM_MAINTENANCE CONTROLS AT MOST (500)
    -- VIEWABLE ACT ITEMS AT A TIME. THIS MEANS WE CAN ONLY CLOSE
    -- THAT MANY EACH CALL
    FOR I IN (SELECT select_link t_objid,
                     task_id,
                     start_date,
                     f_name,
                     l_name,
                     condition,
                     QUEUE,
                     OWNER,
                     status,
                     order_type,
                     carrier_name,
                     carrier_mkt,
                     esn,
                     current_method,
                     MIN
              FROM TABLE(apex_crm_pkg.action_item_maintenance(ip_carrier_name,
                                                              ip_carrier_mkt,
                                                              ip_order_type,
                                                              ip_trans_method,
                                                              ip_status,
                                                              ip_condition,
                                                              ip_esn,
                                                              ip_queue,
                                                              ip_task_id,
                                                              ip_date_from,
                                                              NULL, --ip_check_results,
                                                              NULL, --ip_app_id,
                                                              NULL, --ip_pg_id,
                                                              NULL, --ip_app_session,
                                                              0))
              )
    LOOP
      -- MATERIALIZED VIEW MAY NOT HAVE CURRENT CONDITION STATE
      -- IF TASK IS NOT CLOSED THEN PROCEED
      SELECT C.s_title
      INTO   v_condition
      FROM   table_task T,
             table_condition C
      WHERE  T.task_state2condition = C.objid
      AND    T.objid = I.t_objid;

      IF v_condition NOT LIKE 'CLOSED%' THEN
        sa.apex_crm_pkg.sp_apex_close_action_item(I.t_objid,0,ip_user,v_dummy);

        -- CHECK CASES AGAINST THE TASK
        FOR task_cases_rec IN task_cases(I.t_objid)
        LOOP
          sa.igate.sp_close_case (p_case_id => task_cases_rec.id_number,
                                  p_user_login_name => ip_user,
                                  p_source => 'Action Item Maintenance',
                                  p_resolution_code => NULL,
                                  p_status => v_dummy,
                                  p_msg => v_dummy2);

          v_task_cases_closed_cnt := v_task_cases_closed_cnt+1;
        END LOOP;
        v_task_closed_cnt := v_task_closed_cnt+1;
      END IF;

    END LOOP;

    op_msg := to_char(v_task_closed_cnt)||' Action Items have been closed, '||' Associated Cases closed '||to_char(v_task_cases_closed_cnt);

  END close_bulk_action_items;
--------------------------------------------------------------------------------
FUNCTION recent_interactions(ip_c_objid NUMBER,
            ip_serial_no VARCHAR2)
  RETURN recent_interactions_tab
  PIPELINED
  IS
    rc SYS_REFCURSOR;
    sqlstmt CLOB;
    j  rirec;
  BEGIN
    -- COLLECT ALL INTERACTIONS FROM THE CONTACT OBJID
    -- IF THE ESN IS PROVIDED, THEN DO ADDITIONAL SEARCH
      sqlstmt := sqlstmt||' select a.objid, ';
      sqlstmt := sqlstmt||'        create_date, ';
      sqlstmt := sqlstmt||'        a.x_service_type, ';
      sqlstmt := sqlstmt||'        a.inserted_by, ';
      sqlstmt := sqlstmt||'        a.reason_1, ';
      sqlstmt := sqlstmt||'        a.reason_2, ';
      sqlstmt := sqlstmt||'        a.reason_3, ';
      sqlstmt := sqlstmt||'        a.result, ';
      sqlstmt := sqlstmt||'        a.interact_id, ';
      sqlstmt := sqlstmt||'        t.notes notes, ';
      sqlstmt := sqlstmt||'        a.serial_no  ';
      sqlstmt := sqlstmt||' from   ( ';

    IF ip_c_objid IS NOT NULL THEN
      sqlstmt := sqlstmt||'         select i.objid,i.create_date,i.x_service_type,i.inserted_by, ';
      sqlstmt := sqlstmt||'                i.reason_1,i.reason_2,i.reason_3,i.result,i.interact_id,i.serial_no ';
      sqlstmt := sqlstmt||'         from   table_interact i  ';
      sqlstmt := sqlstmt||'         where  1=1  ';
      sqlstmt := sqlstmt||'         and    i.s_reason_1 !=  ''SURVEY OFFER'''; --CR50846 611611 Survey integration
      sqlstmt := sqlstmt||'         and    i.interact2contact = '||ip_c_objid;
      sqlstmt := sqlstmt||'         and    i.serial_no is null ';
    END IF;

    IF  ip_c_objid IS NOT NULL AND ip_serial_no IS NOT NULL THEN
       sqlstmt := sqlstmt||'         union ';
    END IF;

    IF ip_serial_no IS NOT NULL THEN
       sqlstmt := sqlstmt||'         select i.objid,i.create_date,i.x_service_type,i.inserted_by, ';
       sqlstmt := sqlstmt||'                i.reason_1,i.reason_2,i.reason_3,i.result,i.interact_id,i.serial_no ';
       sqlstmt := sqlstmt||'         from   table_interact i,  ';
       sqlstmt := sqlstmt||'                table_part_inst pi  ';
       sqlstmt := sqlstmt||'         where  1=1  ';
       sqlstmt := sqlstmt||'         and    i.s_reason_1 !=  ''SURVEY OFFER'''; --CR50846 611611 Survey integration
       IF  ip_c_objid IS NOT NULL THEN
          sqlstmt := sqlstmt||'         and    i.interact2contact = '||ip_c_objid;
          sqlstmt := sqlstmt||'         and    pi.x_part_inst2contact = '||ip_c_objid;
       END IF;
    sqlstmt := sqlstmt||'         and    i.serial_no = pi.part_serial_no';
       sqlstmt := sqlstmt||'         and    pi.part_serial_no = '''||ip_serial_no|| '''';

     END IF;

    IF  ip_c_objid IS NOT NULL OR ip_serial_no IS NOT NULL THEN
      sqlstmt := sqlstmt||'         ) a, ';
      sqlstmt := sqlstmt||'         table_interact_txt t ';
      sqlstmt := sqlstmt||' where   1=1 ';
      sqlstmt := sqlstmt||' and    t.interact_txt2interact (+) = a.objid ';
      sqlstmt := sqlstmt||' order by create_date desc ';
   END IF;


   IF ip_c_objid IS NULL AND ip_serial_no IS NULL THEN
      sqlstmt := ' select null objid, ';
      sqlstmt := sqlstmt||'        null create_date, ';
      sqlstmt := sqlstmt||'        null x_service_type, ';
      sqlstmt := sqlstmt||'        null inserted_by, ';
      sqlstmt := sqlstmt||'        null reason_1, ';
      sqlstmt := sqlstmt||'        null reason_2, ';
      sqlstmt := sqlstmt||'        null reason_3, ';
      sqlstmt := sqlstmt||'        null result, ';
      sqlstmt := sqlstmt||'        null interact_id, ';
      sqlstmt := sqlstmt||'        null notes, ';
      sqlstmt := sqlstmt||'        null serial_no  ';
      sqlstmt := sqlstmt||' from   dual ';
      sqlstmt := sqlstmt||' where rownum <1 ';
    END IF;


      OPEN rc FOR sqlstmt;
      LOOP
         FETCH rc INTO j; -- recent_interactions_rslt;
         EXIT WHEN rc%notfound;
         recent_interactions_rslt.i_objid := j.i_objid;
         recent_interactions_rslt.create_date := j.create_date;
         recent_interactions_rslt.x_service_type := j.x_service_type;
         recent_interactions_rslt.inserted_by := j.inserted_by;
         recent_interactions_rslt.reason := j.reason;
         recent_interactions_rslt.detail := j.detail;
         recent_interactions_rslt.channel := j.channel;
         recent_interactions_rslt.interact_result := j.interact_result;
         recent_interactions_rslt.interact_id := j.interact_id;
         recent_interactions_rslt.notes := j.notes;
         recent_interactions_rslt.esn := j.esn;
        PIPE ROW(recent_interactions_rslt);
      END LOOP;
      CLOSE rc;
  END recent_interactions;
--------------------------------------------------------------------------------
END apex_crm_pkg;
/