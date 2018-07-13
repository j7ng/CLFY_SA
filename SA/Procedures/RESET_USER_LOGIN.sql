CREATE OR REPLACE procedure sa.reset_user_login is
   cursor tab
   is
   select objid, s_login_name --, 'alter user '||s_login_name||' identified by abc123 account unlock' v_stat_db
   from table_user, dba_users du
   where s_login_name=du.username;
cursor sqa
is 
select objid,s_login_name from table_user
where s_login_name in ('DDEZENDEGUI',
'GBARAHONA',
'HMARRERO',
'IBERMUDEZ',
'KPATEL',
'LCOTTIN',
'LUHERNANDEZ',
'NNUNEZ',
'PSALMON',
'SJEAN',
'UMANICKAM',
'VFERNANDEZ',
'WSOPKO',
'YCRUZ',
'YVALMOND');
BEGIN
      for r_tab in tab loop
        update sa.table_user  set
       status=1 ,  WEB_LAST_LOGIN=sysdate, WEB_PASSWD_CHG=sysdate, LAST_LOGIN=sysdate, PASSWD_CHG=sysdate
       where objid=r_tab.objid;
       commit;
        EXECUTE IMMEDIATE 'alter user '||r_tab.s_login_name||'  account unlock'  ;
       end loop;
       for l in sqa
       loop
                      update sa.table_user  set
       status=1 , cs_lic='1-JAN-1753', csde_lic='1-JAN-1753',
       cq_lic='1-JAN-1753', clfo_lic='1-JAN-1753',
    csfts_lic='1-JAN-1753', cq_lic_type=0,
    csftsde_lic='1-JAN-1753', cqfts_lic='1-JAN-1753',
    sfa_lic='1-JAN-1753', user2rc_config =268436363,
    ccn_lic='1-JAN-1753', locale=0,
        node_id=1,
     univ_lic='1-JAN-1753',dev=1,
     LAST_LOGIN=sysdate, PASSWD_CHG=sysdate , WEB_LAST_LOGIN=sysdate, WEB_PASSWD_CHG=sysdate,
      WEB_PASSWORD = 'Y2fEjdGT1W6nsLqtJbGUVeUp9e4='
       where objid=l.objid;
   delete from TABLE_X_PASSWORD_HIST where S_X_LOGIN_NAME =l.s_login_name;
       commit;
       end loop;
end;
/