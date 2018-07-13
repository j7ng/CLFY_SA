CREATE OR REPLACE PACKAGE BODY sa.DBA_UTIL_PKG AS
Procedure Delete_PartClass( pcname in varchar2) is
  cursor pc is
    select * from table_part_class@read_rtrp
    where name =pcname;
     pcrec pc%rowtype;
     devpcobj number;
     prodpc number;
begin
         open pc;
         fetch pc into pcrec;
                select objid into devpcobj
                from table_part_class pc
                where upper(pc.name)=upper(trim(pcname));
        if devpcobj <> pcrec.objid then    ---chk if objid in dev and prod are not  the same

         select count(*) into prodpc from table_part_class   ---chk if objid from prod is being used
          where objid = pcrec.objid;
               if prodpc =0 then
                dbms_output.put_line('THE Part class objid from prod does not exist in dev');
               else
                dbms_output.put_line('THE Part class table is out of Sync please check manually');
               end if;
           else
             Insert_Part_class_hist(pcname);
              delete from table_part_class
                where objid =devpcobj;

               delete from table_x_part_class_values pcv
                where pcv.value2part_class=devpcobj;

          update table_part_num
            set part_num2part_class =pcrec.objid
            where part_num2part_class=devpcobj;
          commit;
         end if;
       close pc;
end;
procedure Insert_Part_class_hist(pcname in varchar2) is

  vuser varchar2(50);
  cursor a is
    select * from table_part_class where  upper(name) =upper(trim(pcname));
    r a%rowtype;
    cursor b is
    select * from table_x_part_class_values pcv where pcv.value2part_class=r.objid;

begin
      select sys_context('USERENV','OS_USER') into vuser
       from dba_users where username = upper(user);

  open a;
  fetch a into r;
     if a%found then

      insert into DBAUTL_TABLE_PART_CLASS_HIST
      ( OBJID, NAME, DESCRIPTION, DEV, X_MODEL_NUMBER, X_PSMS_INQUIRY, DELETE_DT, DELETE_BY)
     values
      ( r. OBJID, r.NAME, r.DESCRIPTION, r.DEV, r.X_MODEL_NUMBER, r.X_PSMS_INQUIRY, sysdate, vuser) ;
     commit;
     FOR BREC IN B LOOP
     INSERT INTO DBAUTL_PART_CLS_VALUE_HIST
     ( OBJID, DEV, X_PARAM_VALUE, VALUE2CLASS_PARAM, VALUE2PART_CLASS, DELETE_DT, DELETE_BY)
     VALUES
     (BREC.OBJID, BREC.DEV, BREC.X_PARAM_VALUE, BREC.VALUE2CLASS_PARAM, BREC.VALUE2PART_CLASS,sysdate, vuser);
      END LOOP;
     COMMIT;
      --CLOSE B;
   else
     dbms_output.put_line('cannot find the part class in dev');
    end if;

    close a;
end;

Procedure Delete_PartNum(p_num in varchar2) is
    pnobj number;
   prdobj number;

cursor pnd is
   select objid --into pnobj
       from table_part_num
       where s_part_number =upper(trim(p_num));
     pn_rec pnd%rowtype  ;
       reccount number;
    begin
             open pnd;
         fetch pnd into pn_rec;
         if pnd%found then
          Insert_Part_num_hist(p_num);
          delete from table_part_num
           where objid =pn_rec.objid;

          delete from table_mod_level
            where part_info2part_num =pn_rec.objid;

          delete from sa.table_x_click_plan
            where  click_plan2part_num =pn_rec.objid;

          delete   from  sa.mtm_part_num14_x_frequency0
          where PART_NUM2X_FREQUENCY =pn_rec.objid;
         else
           dbms_output.put_line('the part number not in dev check if the prod objid is being used');
        end if;

        select objid into prdobj from table_part_num@read_rtrp
        where s_part_number =upper(trim(p_num));

      select count(*) into reccount from table_part_num where objid = prdobj;

     if  reccount > 0 then
       delete from table_part_num
       where objid =prdobj;

       delete from table_mod_level
       where part_info2part_num =prdobj;

       delete from sa.table_x_click_plan
       where  click_plan2part_num =prdobj;

       delete   from  sa.mtm_part_num14_x_frequency0
       where PART_NUM2X_FREQUENCY=prdobj;
    else
          dbms_output.put_line('the Prod objid is  not used in dev ');
   end if;

commit;
end;
procedure Insert_Part_num_hist(p_num in varchar2) is

  vuser varchar2(50);

  cursor a is
    select * from table_part_num where  s_part_number =upper(trim(p_num));
    r a%rowtype;

    cursor modl is ---m
    select * from table_mod_level
            where part_info2part_num =r.objid;

    cursor click is
    select * from sa.table_x_click_plan
            where  click_plan2part_num =r.objid;

       cursor frequency is
       select * from sa.mtm_part_num14_x_frequency0
          where PART_NUM2X_FREQUENCY=r.objid;

begin
   select sys_context('USERENV','OS_USER') into vuser
   from dba_users where username = upper(user);
  open a;
  fetch a into r;
  if a%found then

      insert into DBAUTL_TABLE_PART_NUM_HIST
      (OBJID, NOTES, DESCRIPTION, S_DESCRIPTION, DOMAIN, S_DOMAIN, PART_NUMBER, S_PART_NUMBER,
 MODEL_NUM, S_MODEL_NUM, ACTIVE, STD_WARRANTY, WARR_START_KEY, UNIT_MEASURE, SN_TRACK,
 FAMILY, LINE, REPAIR_TYPE, PART_TYPE, WEIGHT, DIMENSION, DOM_SERIALNO, DOM_UNIQUESN,
 DOM_CATALOGS, DOM_BOMS, DOM_AT_SITE, DOM_AT_PARTS, DOM_AT_DOMAIN, DOM_PT_USED_BOM,
 DOM_PT_USED_DOM, DOM_PT_USED_WARN, INCL_DOMAIN, IS_SPPT_PROG, PROG_TYPE, DOM_LITERATURE,
 P_STANDALONE, P_AS_PARENT, P_AS_CHILD, DOM_IS_SERVICE, DEV, STRUCT_TYPE, X_MANUFACTURER,
 X_RETAILCOST, X_REDEEM_DAYS, X_REDEEM_UNITS, X_DLL, X_PROGRAMMABLE_FLAG, X_CARD_TYPE, X_PURCH_QTY,
 X_PURCH_CARD, X_TECHNOLOGY, X_UPC, X_WEB_DESCRIPTION, X_DISPLAY_SEQ, X_WEB_CARD_DESC, X_CARD_PLAN,
 X_WHOLESALE_PRICE, X_SP_WEB_CARD_DESC, X_PRODUCT_CODE, X_SOURCESYSTEM, X_RESTRICTED_USE, X_CARDLESS_BUNDLE,
 PART_NUM2PART_CLASS, PART_NUM2DOMAIN, PART_NUM2SITE, X_EXCH_DIGITAL2PART_NUM, PART_NUM2DEFAULT_PRELOAD,
 PART_NUM2X_PROMOTION, X_EXTD_WARRANTY, X_OTA_ALLOWED, X_OTA_DLL, X_ILD_TYPE, X_DATA_CAPABLE,
 X_CONVERSION, X_MEID_PHONE, PART_NUM2X_DATA_CONFIG, PART_NUM2BUS_ORG, DEVICE_LOCK_STATE,DELETE_BY,DELETE_DT )

  values
   ( r.OBJID, r.NOTES, r.DESCRIPTION, r.S_DESCRIPTION, r.DOMAIN, r.S_DOMAIN, r.PART_NUMBER, r.S_PART_NUMBER,
 r.MODEL_NUM, r.S_MODEL_NUM, r.ACTIVE, r.STD_WARRANTY, r.WARR_START_KEY, r.UNIT_MEASURE, r.SN_TRACK,
 r.FAMILY, r.LINE, r.REPAIR_TYPE, r.PART_TYPE, r.WEIGHT, r.DIMENSION, r.DOM_SERIALNO, r.DOM_UNIQUESN,
 r.DOM_CATALOGS, r.DOM_BOMS,r.DOM_AT_SITE, r.DOM_AT_PARTS, r.DOM_AT_DOMAIN, r.DOM_PT_USED_BOM,
 r.DOM_PT_USED_DOM, r.DOM_PT_USED_WARN, r.INCL_DOMAIN, r.IS_SPPT_PROG, r.PROG_TYPE, r.DOM_LITERATURE,
 r.P_STANDALONE, r.P_AS_PARENT, r.P_AS_CHILD, r.DOM_IS_SERVICE, r.DEV, r.STRUCT_TYPE, r.X_MANUFACTURER,
 r.X_RETAILCOST, r.X_REDEEM_DAYS, r.X_REDEEM_UNITS, r.X_DLL, r.X_PROGRAMMABLE_FLAG, r.X_CARD_TYPE, r.X_PURCH_QTY,
 r.X_PURCH_CARD, r.X_TECHNOLOGY, r.X_UPC, r.X_WEB_DESCRIPTION, r.X_DISPLAY_SEQ, r.X_WEB_CARD_DESC, r.X_CARD_PLAN,
 r.X_WHOLESALE_PRICE, r.X_SP_WEB_CARD_DESC, r.X_PRODUCT_CODE, r.X_SOURCESYSTEM, r.X_RESTRICTED_USE, r.X_CARDLESS_BUNDLE,
 r.PART_NUM2PART_CLASS, r.PART_NUM2DOMAIN, r.PART_NUM2SITE, r.X_EXCH_DIGITAL2PART_NUM, r.PART_NUM2DEFAULT_PRELOAD,
 r.PART_NUM2X_PROMOTION, r.X_EXTD_WARRANTY, r.X_OTA_ALLOWED, r.X_OTA_DLL, r.X_ILD_TYPE, r.X_DATA_CAPABLE,
 r.X_CONVERSION, r.X_MEID_PHONE, r.PART_NUM2X_DATA_CONFIG, r.PART_NUM2BUS_ORG, r.DEVICE_LOCK_STATE,vuser,sysdate) ;

      commit;

      for m in modl  loop
              insert into DBAUTL_table_mod_level_hist
              (OBJID, MOD_LEVEL, S_MOD_LEVEL, ACTIVE, REPLACES_DATE, EFF_DATE, END_DATE, DEV, PART_INFO2PART_NUM,
              PART_INFO2LOG_INFO, PART_INFO2PART_STATS, REPLACEDPN2MOD_LEVEL, X_TIMETANK, PART_INFO2INV_CTRL,
              CONFIG_TYPE, DELETE_DT, DELETE_BY)
              values( m.OBJID,m.MOD_LEVEL,m.S_MOD_LEVEL,m.ACTIVE, m.REPLACES_DATE, m.EFF_DATE, m.END_DATE, m.DEV,
                    m.PART_INFO2PART_NUM, m.PART_INFO2LOG_INFO, m.PART_INFO2PART_STATS, m.REPLACEDPN2MOD_LEVEL,
                m.X_TIMETANK, m.PART_INFO2INV_CTRL, m.CONFIG_TYPE, sysdate,  vuser);
     end loop;
 commit;

 for c in click loop
             insert into DBAUTL_table_x_click_plan_hist
             (OBJID, X_PLAN_ID, X_CLICK_LOCAL,X_CLICK_LD,X_CLICK_RL,X_CLICK_RLD,X_GRACE_PERIOD,X_IS_DEFAULT,X_STATUS,
            CLICK_PLAN2DEALER,CLICK_PLAN2CARRIER,X_CLICK_HOME_INTL,X_CLICK_IN_SMS,X_CLICK_OUT_SMS,X_CLICK_ROAM_INTL,
            X_CLICK_TYPE,X_GRACE_PERIOD_IN,X_HOME_INBOUND,X_ROAM_INBOUND,CLICK_PLAN2PART_NUM,X_BROWSING_RATE,
            X_BUS_ORG,X_MMS_INBOUND,X_MMS_OUTBOUND,X_TECHNOLOGY,X_CLICK_ILD,DELETE_DT,DELETE_BY)
              values
              ( c.OBJID, c.X_PLAN_ID, c.X_CLICK_LOCAL,c.X_CLICK_LD,c.X_CLICK_RL,c.X_CLICK_RLD,c.X_GRACE_PERIOD,
            c.X_IS_DEFAULT,c.X_STATUS,c.CLICK_PLAN2DEALER,c.CLICK_PLAN2CARRIER,c.X_CLICK_HOME_INTL,
            c.X_CLICK_IN_SMS,c.X_CLICK_OUT_SMS,c.X_CLICK_ROAM_INTL,c.X_CLICK_TYPE,c.X_GRACE_PERIOD_IN,
            c.X_HOME_INBOUND,c.X_ROAM_INBOUND,c.CLICK_PLAN2PART_NUM,c.X_BROWSING_RATE,
            c.X_BUS_ORG,c.X_MMS_INBOUND,c.X_MMS_OUTBOUND,c.X_TECHNOLOGY,c.X_CLICK_ILD,
            sysdate,vuser) ;
    end loop;
 commit;
 for f in frequency loop
                 insert into DBAUTL_mtm_part_num_freq_hist
                 (PART_NUM2X_FREQUENCY,X_FREQUENCY2PART_NUM,DELETE_DT,DELETE_BY)
                 values(f.PART_NUM2X_FREQUENCY,f.X_FREQUENCY2PART_NUM,sysdate,vuser);
  end loop;
 commit;

   else
     dbms_output.put_line('cannot find the part num in dev');
    end if;
    close a;
end;
Procedure delete_site(v_dealer in varchar2) is
     ch_obj number;

cursor ts_site is
  select * from table_site where
   s_name=upper(trim(v_dealer))
   and  TYPE =3;
  mast_rec  ts_site%rowtype;

  cursor chld_site(masobj  number) is
   select * from table_site where child_site2site=masobj;

   cursor cont_role is
     select objid,contact_role2contact,contact_role2site from
       table_contact_role
       where contact_role2site=ch_obj;
      c_rec  cont_role%rowtype;

    cursor prod_site is
     select * from table_site@read_rtrp
      where s_name=upper(trim(v_dealer))
      and TYPE =3;
  prod_rec     prod_site%rowtype;

   SiteIn_Prod  number; SiteIn_Dev number;
  begin

   open ts_site ;
      fetch ts_site into mast_rec;
      SiteIn_Dev :=mast_rec.objid;
    for chld_rec in chld_site(mast_rec.objid) loop
      ch_obj := chld_rec.objid;
       open cont_role;
       fetch cont_role into c_rec;

       delete from table_contact where objid =c_rec.contact_role2contact;
       delete from table_site where objid =c_rec.contact_role2site;
       delete from table_contact_role where objid =c_rec.objid;
      -- delete from table_site where objid =ch_obj;
       commit;
       close cont_role;
      end loop;
       -- delete from table_site where objid =mast_rec.objid;

        delete from  x_posa_flag_dealer  where site_id =mast_rec.site_id;
        delete from  table_inv_bin   where bin_name=mast_rec.site_id;
        delete from table_inv_locatn  where inv_locatn2site=mast_rec.objid;
        delete from  table_inv_role where  inv_role2site=mast_rec.objid;
        delete from table_site where objid =mast_rec.objid;
        delete from table_site where child_site2site =mast_rec.objid;
         close ts_site;

---check if a record exits for prodobjid
      open prod_site;
      fetch prod_site into prod_rec;
         SiteIn_Prod :=prod_rec.objid;
      delete from  x_posa_flag_dealer  where site_id =prod_rec.site_id;
      delete from  table_inv_bin where bin_name=prod_rec.site_id;
      delete from  table_inv_locatn where inv_locatn2site=prod_rec.objid;
      delete from  table_inv_role where inv_role2site=prod_rec.objid;
      delete from  table_site where objid =prod_rec.objid;
      close prod_site;


end;


Procedure Add_New_site(vname in varchar2) is
  cursor ts_rtrp is
  select * from table_site@read_rtrp
  where s_name= upper(trim(vname))
  and TYPE =3;
  tsrec ts_rtrp%rowtype;
  recno number;
  sf_name varchar2(100);
  site_name varchar2(100);
  begin
   site_name := upper(vname);
    sf_name := substr(site_name,0,25)||'%';
    Delete_Site(vname);
    open ts_rtrp;
    fetch ts_rtrp into tsrec;
    if ts_rtrp%found then
       select count(*) into recno from table_site
       where objid =tsrec.objid
       and S_NAME = tsrec.S_NAME;
       if recno = 0 then
insert into table_site (select * from table_site@read_rtrp
                                     where objid = tsrec.objid);

                   insert into table_site(select * from  table_site@read_rtrp
                                     where  child_site2site=tsrec.objid);

        --insert into   x_posa_flag_dealer (select * from x_posa_flag_dealer@read_rtrp
                 --                                   where site_id =tsrec.site_id);
         insert into table_inv_bin(select * from table_inv_bin@read_rtrp
                                            where bin_name=tsrec.site_id);
        insert into table_inv_locatn(select * from table_inv_locatn@read_rtrp
                                            where inv_locatn2site=tsrec.objid);
        insert into table_inv_role (select * from  table_inv_role@read_rtrp
                                                where inv_role2site=tsrec.objid);
        commit;
           dbms_output.put_line('inserted the site: '  || tsrec.S_NAME );
        else
           dbms_output.put_line('The Site exists please delete and then execute this script again');
        end if;
      else
        dbms_output.put_line('The Site cannot be found in RTRP');
    end if;
    close ts_rtrp;

    Add_contact_site(vname);
end;
Procedure Add_contact_site(pname in varchar2) is

MAster_siteObj number ;
tc_exist number;
conract_roleexist number;
cursor get_master is

select * from table_site where  s_name=upper(trim(pname));
master_rec  get_master%rowtype;

cursor csite is
  select * from table_site where child_site2site =Master_siteObj;
cursor tcr (child_siteobj number)is
select r.* from table_contact_role@read_rtrp r
where contact_role2site =child_siteobj;
Reccont_role tcr%rowtype;

begin
    open get_master;
    fetch get_master into master_rec;
      if get_master%notfound then
          dbms_output.put_line('Cannot find master site Please insert master first');
      else
      Master_siteObj :=master_rec.objid;
    close get_master;
    end if;
   for rec1 in csite loop
    dbms_output.put_line(rec1.objid);
      open tcr(rec1.objid);
       fetch tcr into reccont_role;
        dbms_output.put_line('Contact_role record objid');
        dbms_output.put_line(Reccont_role.objid);
        select  count(*) into  conract_roleexist from table_contact_role where objid =Reccont_role.objid;
        if conract_roleexist >0 then
         dbms_output.put_line('contact role record exist please delete and execute it again');
       else
        insert into table_contact_role(select * from table_contact_role@read_rtrp where objid =Reccont_role.objid);
        commit;
        end if;
        select count(*) into tc_exist from table_contact where objid =(select contact_role2contact
                                                                   from table_contact_role@read_rtrp where objid=Reccont_role.objid);
        if tc_exist >0 then
         dbms_output.put_line('contact  record exist please delete and execute it again');
       else
        insert into table_contact (select * from table_contact@read_rtrp where objid =(select contact_role2contact
                                                                   from table_contact_role@read_rtrp where objid=Reccont_role.objid));
       commit;
       end if;
       close tcr;
     end loop;
  end;
Procedure Add_Part_Class( PClass in varchar2) is
cursor rpc is
    select * from table_part_class@read_rtrp
    where upper((name)) =upper(trim(PClass));
     pcrec rpc%rowtype;
     nc number;
 begin

      open rpc;
      fetch rpc into pcrec;
      if  rpc%notfound then
       dbms_output.put_line('Part class not existing in RTRP');
        else
           select count(*) into nc from table_part_class
            where  upper((name)) =upper(trim(PClass))
             or objid = pcrec.objid;
          if nc > 0 then
                DBA_UTIL_PKG.Delete_PartClass( PClass);
                delete from table_part_class where objid =pcrec.objid;
                commit;
         end if;
            insert into table_part_class
            values pcrec;
            commit;
   --part_class_params
           insert into table_x_part_class_params( select * from table_x_part_class_params@read_rtrp
                                                     minus
                                                     select * from table_x_part_class_params);
   ---Partclass values
             insert into table_x_part_class_values v
                    (select * from table_x_part_class_values@read_rtrp pcv
                     where pcv.value2part_class=pcrec.objid);
             commit;
       end if;
  close rpc;
end;
Procedure Add_Part_num(vnum in varchar2) as
type rc1 is ref cursor return table_part_num%rowtype;
devcur  rc1;
Prodcur rc1;
 devrec   devcur%rowtype;
 prodrec  Prodcur%rowtype;

 devpnobj number;
 devpcobj number;
 Prodpnobj number;
 Prodcobj number;

   Pclass_name varchar2(30);
   Dclass_name varchar2(30);
   pnum varchar2(30);
  begin
     pnum := upper(trim(vnum));
    open devcur for   select * from table_part_num pn  where s_part_number=pnum ;
      fetch devcur into devrec ;
      if devcur%notfound then
            dbms_output.put_line('The part number not in dev let us move it from Prod');
      else
                    devpnobj := devrec.objid;
                    devpcobj := devrec.part_num2part_class;
                     select pc.name into Dclass_name
                        from table_part_class  pc
                        where objid =devpcobj ;
        close devcur;
    --   dbms_output.put_line(' the part exists let us delete existing record');
     -- dbms_output.put_line('DevPnObj :  ' ||devpnobj);
     -- dbms_output.put_line('Dev Part class name :  ' || Dclass_name);
      DBA_UTIL_PKG.Delete_PartNum(pnum);
      DBA_UTIL_PKG.Delete_PartClass( Dclass_name);
      --Delete_PartNum(pnum);
     end if;
       open Prodcur for   select *  from table_part_num@read_rtrp  pnprd  where s_part_number=pnum ;

                 fetch Prodcur into prodrec ;
                   if
                      Prodcur%notfound then
                               dbms_output.put_line('The part number not in Production Notify the requestors');
                 else

                     Prodpnobj := prodrec.objid;
                     Prodcobj := prodrec.part_num2part_class;

                   select pc.name into Pclass_name
                   from table_part_class@read_rtrp pc
                   where objid =Prodcobj;

                        dbms_output.put_line('ProPnObj :  ' ||Prodpnobj);
                        dbms_output.put_line('Production Part class name :  ' || Pclass_name);
                        DBA_UTIL_PKG.Delete_PartNum(pnum);
                        DBA_UTIL_PKG.Add_Part_Class( Pclass_name);
                 --       dbms_output.put_line('Part class inserted ' ||Pclass_name);
               end if;
         close Prodcur;

--insert mod level
                    INSERT INTO TABLE_MOD_LEVEL
                     (SELECT * FROM TABLE_MOD_LEVEL@READ_RTRP
                          WHERE PART_INFO2PART_NUM=PRODPNOBJ);

  ---insert the record in table_part_num

          INSERT INTO sa.TABLE_PART_NUM(
         SELECT * FROM sa.TABLE_PART_NUM@READ_RTRP WHERE OBJID =PRODPNOBJ);

   ---Insert  click plan
             INSERT INTO sa.table_x_click_plan(select * from sa.table_x_click_plan@read_rtrp where
                                                              click_plan2part_num=Prodpnobj);
 --frequency
            INSERT INTO MTM_PART_NUM14_X_FREQUENCY0
                (SELECT * FROM  MTM_PART_NUM14_X_FREQUENCY0@READ_RTRP
                        WHERE PART_NUM2X_FREQUENCY=PRODPNOBJ);
      commit;
           ADD_PRICING(pnum);
           dbms_output.put_line('Part number inserted  ' ||Prodpnobj);
end;
procedure insert_program_hist( pgname in varchar2) is
  vuser varchar2(50);

  cursor a is
    select * from x_program_parameters where
    upper((x_program_name)) = upper(trim(pgname));
    r a%rowtype;

    cursor esn is
      SELECT * FROM  x_mtm_permitted_esnstatus
      where PROGRAM_PARAM_OBJID=r.objid;

      cursor pg_tec is
     SELECT *  from x_mtm_program_technology
     where  PROGRAM_PARAM_OBJID =r.objid;

    cursor paymt is
     SELECT * FROM   x_mtm_restricted_pymtmode where PROGRAM_PARAM_OBJID =r.objid;

     cursor prghs is
     SELECT * from x_mtm_program_handset where PROGRAM_PARAM_OBJID =r.objid;

     cursor batch_type is
      SELECT * from mtm_batch_process_type where X_PRGM_OBJID =r.objid;


begin
      select sys_context('USERENV','OS_USER') into vuser
       from dba_users where username = upper(user);

  open a;
  fetch a into r;
     if a%found then

      insert into DBAUTL_X_PROGRAM_PARAMTS_HIST
      ( OBJID,X_PROGRAM_NAME,X_PROGRAM_DESC,X_TYPE,X_CSR_CHANNEL,X_IVR_CHANNEL,X_WEB_CHANNEL,
X_COMBINE_SELF,X_COMBINE_OTHER,X_START_DATE,X_END_DATE,X_GRP_ESN_COUNT,X_IS_RECURRING,
X_BENEFIT_DAYS,X_HANDSET_VALUE,X_CARRMKT_VALUE,X_CARRPARENT_VALUE,X_ACH_GRACE_PERIOD,X_ADD_PH_WINDOW,
X_MIN_UNIT_RATE_MINUTES,X_MIN_UNIT_RATE_CENTS,X_GRACE_PERIOD_WEBCSR,X_DELAY_ENROLL_ACH_FLAG,
X_DE_ENROLL_CUTOFF_CODE,X_DELIVERY_FRQ_CODE,X_FIRST_DELIVERY_DATE_CODE,X_INCL_SERVICE_DAYS,
X_STACK_AT_ENROLL,X_STACK_DUR_ENROLL,X_VOL_DEENRO_SER_DAYS_LESS,X_DEENROLL_ADD_SER_DAYS,X_BENEFIT_CUTOFF_CODE,
X_SER_DAYS_FLOAT_ACH,X_SER_DAYS_FLOAT_NONACH,X_PAYNOW_GRACE_PERIOD_ACH,X_PAYNOW_GRACE_PERIOD_NON,X_SALES_TAX_FLAG,
X_SALES_TAX_CHARGE_CUST,X_ADDITIONAL_TAX1,X_ADDITIONAL_TAX2,X_CHARGE_FRQ_CODE,X_BILL_CYL_SHIFT_DAYS,X_PAYMENT_METHOD_CODE,
X_LOW_BALANCE_UNITS,X_LOW_BALANCE_DOLLARS,X_PROMO_INCL_MIN_AT,X_PROMO_INCL_MIN_OP,X_PROMO_INCL_MIN_WE,
X_INCL_DATA_UNITS,X_INCL_DATA_DOLLORS,X_PROMO_INCR_MIN_AT,X_PROMO_INCR_MIN_OP,X_PROMO_INCR_MIN_WE,X_INCR_DATA_UNITS,
X_INCR_DATA_DOLLORS,X_ADD_FUNDS_MIN,X_ADD_FUNDS_MAX,X_ADD_FUNDS_INCR,X_PROMO_INCL_GRPMIN_AT,X_PROMO_INCL_GRPMIN_OP,
X_PROMO_INCL_GRPMIN_WE,X_INCL_DATA_GRPUNITS,X_INCL_DATA_GRPDOLLORS,X_PROMO_INCR_GRPMIN_AT,X_PROMO_INCR_GRPMIN_OP,
X_PROMO_INCR_GRPMIN_WE,X_INCR_DATA_GRPUNITS,X_INCR_DATA_GRPDOLLORS,X_ADD_GRP_FUNDS_MIN,X_ADD_GRP_FUNDS_MAX,
X_ADD_GRP_FUNDS_INCR,X_INCR_MINUTES_DLV_DAYS,X_INCR_MINUTES_DLV_CYL,X_INCR_GRP_MINUTES_DLV_DAYS,X_INCR_GRP_MINUTES_DLV_CYL,
PROG_PARAM2PRTNUM_ENRLFEE,PROG_PARAM2PRTNUM_MONFEE,PROG_PARAM2PRTNUM_GRPENRLFEE,PROG_PARAM2PRTNUM_GRPMONFEE,
PROG_PARAM2BUS_ORG,X_PROG_CLASS,X_E911_TAX_FLAG,X_E911_TAX_CHARGE_CUST,X_BILL_ENGINE_FLAG,X_RULES_ENGINE_FLAG,
X_NOTIFY_ENGINE_FLAG,X_OFF_CHANNEL,X_ICS_APPLICATIONS,X_MEMBERSHIP_VALUE,X_PROMO_GROUP_VALUE,X_RETAILER_VALUE,
X_SMS_RATE,X_ILD,X_SWEEP_AND_ADD_FLAG,X_FREE_DIAL2SITE,X_PRG_SCRIPT_ID,X_PRG_DESC_SCRIPT_ID,DELETE_DT,DELETE_BY)
     values
      ( r.OBJID,r.X_PROGRAM_NAME,r.X_PROGRAM_DESC,r.X_TYPE,r.X_CSR_CHANNEL,r.X_IVR_CHANNEL,r.X_WEB_CHANNEL,r.X_COMBINE_SELF,
r.X_COMBINE_OTHER,r.X_START_DATE,r.X_END_DATE,r.X_GRP_ESN_COUNT,r.X_IS_RECURRING,r.X_BENEFIT_DAYS,r.X_HANDSET_VALUE,
r.X_CARRMKT_VALUE,r.X_CARRPARENT_VALUE,r.X_ACH_GRACE_PERIOD,r.X_ADD_PH_WINDOW,r.X_MIN_UNIT_RATE_MINUTES,r.X_MIN_UNIT_RATE_CENTS,
r.X_GRACE_PERIOD_WEBCSR,r.X_DELAY_ENROLL_ACH_FLAG,r.X_DE_ENROLL_CUTOFF_CODE,r.X_DELIVERY_FRQ_CODE,r.X_FIRST_DELIVERY_DATE_CODE,
r.X_INCL_SERVICE_DAYS,r.X_STACK_AT_ENROLL,r.X_STACK_DUR_ENROLL,r.X_VOL_DEENRO_SER_DAYS_LESS,r.X_DEENROLL_ADD_SER_DAYS,
r.X_BENEFIT_CUTOFF_CODE,r.X_SER_DAYS_FLOAT_ACH,r.X_SER_DAYS_FLOAT_NONACH,r.X_PAYNOW_GRACE_PERIOD_ACH,r.X_PAYNOW_GRACE_PERIOD_NON,
r.X_SALES_TAX_FLAG,r.X_SALES_TAX_CHARGE_CUST,r.X_ADDITIONAL_TAX1,r.X_ADDITIONAL_TAX2,r.X_CHARGE_FRQ_CODE,r.X_BILL_CYL_SHIFT_DAYS,
r.X_PAYMENT_METHOD_CODE,r.X_LOW_BALANCE_UNITS,r.X_LOW_BALANCE_DOLLARS,r.X_PROMO_INCL_MIN_AT,r.X_PROMO_INCL_MIN_OP,
r.X_PROMO_INCL_MIN_WE,r.X_INCL_DATA_UNITS,r.X_INCL_DATA_DOLLORS,r.X_PROMO_INCR_MIN_AT,r.X_PROMO_INCR_MIN_OP,
r.X_PROMO_INCR_MIN_WE,r.X_INCR_DATA_UNITS,r.X_INCR_DATA_DOLLORS,r.X_ADD_FUNDS_MIN,r.X_ADD_FUNDS_MAX,r.X_ADD_FUNDS_INCR,
r.X_PROMO_INCL_GRPMIN_AT,r.X_PROMO_INCL_GRPMIN_OP,r.X_PROMO_INCL_GRPMIN_WE,r.X_INCL_DATA_GRPUNITS,r.X_INCL_DATA_GRPDOLLORS,
r.X_PROMO_INCR_GRPMIN_AT,r.X_PROMO_INCR_GRPMIN_OP,r.X_PROMO_INCR_GRPMIN_WE,r.X_INCR_DATA_GRPUNITS,r.X_INCR_DATA_GRPDOLLORS,
r.X_ADD_GRP_FUNDS_MIN,r.X_ADD_GRP_FUNDS_MAX,r.X_ADD_GRP_FUNDS_INCR,r.X_INCR_MINUTES_DLV_DAYS,r.X_INCR_MINUTES_DLV_CYL,r.X_INCR_GRP_MINUTES_DLV_DAYS,
r.X_INCR_GRP_MINUTES_DLV_CYL,r.PROG_PARAM2PRTNUM_ENRLFEE,r.PROG_PARAM2PRTNUM_MONFEE,r.PROG_PARAM2PRTNUM_GRPENRLFEE,
r.PROG_PARAM2PRTNUM_GRPMONFEE,r.PROG_PARAM2BUS_ORG,r.X_PROG_CLASS,r.X_E911_TAX_FLAG,r.X_E911_TAX_CHARGE_CUST,r.X_BILL_ENGINE_FLAG,
r.X_RULES_ENGINE_FLAG,r.X_NOTIFY_ENGINE_FLAG,r.X_OFF_CHANNEL,r.X_ICS_APPLICATIONS,r.X_MEMBERSHIP_VALUE,r.X_PROMO_GROUP_VALUE,
r.X_RETAILER_VALUE,r.X_SMS_RATE,r.X_ILD,r.X_SWEEP_AND_ADD_FLAG,r.X_FREE_DIAL2SITE,r.X_PRG_SCRIPT_ID,r.X_PRG_DESC_SCRIPT_ID,
 sysdate, vuser) ;
     commit;
   for esnrec in esn loop
    insert into DBAUTL_MTM_PERM_ESNSTUS_HIST
             (PROGRAM_PARAM_OBJID,ESN_STATUS_OBJID,DELETE_DT,DELETE_BY)
    values (esnrec.PROGRAM_PARAM_OBJID,esnrec.ESN_STATUS_OBJID, sysdate, vuser);
   end loop;
   commit;

   for techrec in pg_tec loop
   insert into DBAUTL_MTM_prog_tech_hist
           ( PROGRAM_PARAM_OBJID, X_TECHNOLOGY, DELETE_DT, DELETE_BY)
   values( techrec.PROGRAM_PARAM_OBJID, techrec.X_TECHNOLOGY, sysdate, vuser);

   end loop;
   commit;

   for pmtrec  in  paymt loop
   insert into DBAUTL_MTM_rstrct_pmtmode_hist
                  (X_PAYMENT_TYPE,PROGRAM_PARAM_OBJID,DELETE_DT, DELETE_BY)
          values(pmtrec.X_PAYMENT_TYPE,pmtrec.PROGRAM_PARAM_OBJID,sysdate, vuser);
    end loop;
    commit;

    for pghsrec in prghs loop
      insert into  DBAUTL_MTM_prg_handset_hist(PROGRAM_PARAM_OBJID,PART_CLASS_OBJID,DELETE_DT, DELETE_BY)
      values(pghsrec.PROGRAM_PARAM_OBJID ,pghsrec.PART_CLASS_OBJID,sysdate, vuser);
    end loop;
    commit;

    for brec in batch_type loop
            insert into DBAUTL_MTM_bat_type_hist
            (X_PRGM_OBJID,X_PROCESS_TYPE,X_PRIORITY,DELETE_DT, DELETE_BY)
            values
            (brec.X_PRGM_OBJID,brec.X_PROCESS_TYPE,brec.X_PRIORITY,sysdate, vuser);
         end loop;
      commit;
   else
     dbms_output.put_line('cannot find the Program in dev');
    end if;

    close a;
end;

Procedure Delete_BILLING_PROG(pgname in varchar2) as
   prodobj  number;
   pgobj  number;
   cursor devpg is
      select objid   from  sa.x_program_parameters
         where upper((x_program_name)) =upper(trim(pgname));
     devrec  devpg%rowtype;

   cursor prod_prog is
    select objid  from sa.x_program_parameters
     where objid =prodobj;
     progrec prod_prog%rowtype;

begin
    insert_program_hist( pgname );
    select objid into prodobj  from sa.x_program_parameters@read_rtrp
    where upper((x_program_name)) =upper(trim(pgname));

     open devpg;
     fetch devpg into devrec;
     if devpg%notfound then

   -- if pgobj is null then
     dbms_output.put_line('The program not yet in dev');
    else
        pgobj := devrec.objid;
       delete from x_mtm_permitted_esnstatus
          where program_param_objid in (pgobj );
      delete from x_mtm_program_technology
           where program_param_objid   in (pgobj);
     delete from x_mtm_restricted_pymtmode
          where program_param_objid  in (pgobj );
     delete from x_mtm_program_handset
          where program_param_objid  in (pgobj );

        delete from mtm_batch_process_type
        where x_prgm_objid  in (pgobj );

     delete from x_program_parameters
        where objid  in (pgobj);
    end if;

    open prod_prog;
    fetch prod_prog into progrec;
    if prod_prog% found then

    delete from x_mtm_permitted_esnstatus
    where program_param_objid in (prodobj);


    delete from x_mtm_program_technology
     where program_param_objid   in (prodobj);

  delete from x_mtm_restricted_pymtmode
  where program_param_objid  in (prodobj);

    delete from x_mtm_program_handset
    where program_param_objid  in (prodobj);

        delete from mtm_batch_process_type
        where x_prgm_objid  in (prodobj);
        
       delete from X_MTM_PROGRAM_COMBINE
        where PROGRAM_PARAM_OBJID  in (prodobj);
        
 delete from x_program_parameters
 where objid  in (prodobj);

commit;
   else
      dbms_output.put_line('the prod objid is not being used');
end if;
end;

Procedure Add_Billing_Prog(pgname in varchar2) is
 cursor a is
   select  *
      from sa.x_program_parameters@read_rtrp
      where  upper((x_program_name)) =upper(trim(pgname));
     rec1  a%rowtype;

     prgc number;
begin
   DBMS_OUTPUT.PUT_LINE('Inserting Billing program');
     open a;
     fetch a into rec1;
       if a%found then
       ---If the billing program available in Prod then refresh it from prod
      select count(*) into prgc
      from sa.x_program_parameters
       where  upper((x_program_name)) =upper(trim(pgname));
      --where x_program_name =pgname;

      if prgc >0 then
        Delete_BILLING_PROG(pgname);
       end if;
       insert into x_program_parameters
            values  rec1;
       commit;

    insert into X_MTM_PERMITTED_ESNSTATUS
       select * from X_MTM_PERMITTED_ESNSTATUS@read_rtrp
       where  PROGRAM_PARAM_OBJID =rec1.objid;
   commit;

    insert into X_MTM_PROGRAM_COMBINE
       select * from sa.X_MTM_PROGRAM_COMBINE@read_rtrp
       where  PROGRAM_PARAM_OBJID =rec1.objid;
   commit;

      
  insert into X_MTM_PROGRAM_TECHNOLOGY
      select * from X_MTM_PROGRAM_TECHNOLOGY@read_rtrp
      where  PROGRAM_PARAM_OBJID =rec1.objid;
commit;

      insert into X_MTM_RESTRICTED_PYMTMODE
      select * from X_MTM_RESTRICTED_PYMTMODE@read_rtrp
       where  PROGRAM_PARAM_OBJID =rec1.objid;
commit;

  insert into X_MTM_PROGRAM_HANDSET
     select * from X_MTM_PROGRAM_HANDSET@read_rtrp
     where  PROGRAM_PARAM_OBJID =rec1.objid;
commit;

   insert into MTM_BATCH_PROCESS_TYPE
         select * from MTM_BATCH_PROCESS_TYPE@read_rtrp
         where  X_PRGM_OBJID =rec1.objid;
commit;


     if  rec1.X_FREE_DIAL2SITE is not null then
       get_site_name(rec1.X_FREE_DIAL2SITE);
       dbms_output.put_line('Appropriate Site checked and refreshed ');
     close a;
    end if;
  else
      DBMS_OUTPUT.PUT_LINE('The Program  '|| pgname || '  '||'Not in RTRP ');
    end if;
    Add_Billing_Part_Nums(pgname);
end;

Procedure Add_Billing_Part_Nums(pgname varchar2) is
      cursor a is
     select  PROG_PARAM2PRTNUM_ENRLFEE, PROG_PARAM2PRTNUM_MONFEE
      from sa.x_program_parameters
      where upper((x_program_name)) =upper(trim(pgname));

     a_rec a%rowtype;
       enr_obj  number;
       enr_pn  varchar2(30);
       mon_obj number;
       mon_pn varchar2(30);
       enr_count number;
       mon_count number;
       IS_pn_inserted  boolean := false;
    begin
      open a;
        fetch a into a_rec;
        enr_obj := a_rec.PROG_PARAM2PRTNUM_ENRLFEE;
        mon_obj :=a_rec.PROG_PARAM2PRTNUM_MONFEE;
        DBMS_output.put_line('PROG_PARAM2PRTNUM_ENRLFEE   : ' ||enr_obj);
        DBMS_output.put_line('PROG_PARAM2PRTNUM_MONFEE : '||mon_obj);
        if (enr_obj is null )or (mon_obj is null ) then
          DBMS_output.put_line('No need to check part numbers the program does not need any ');
        else
            select count(*) into  enr_count
               from sa.table_part_num where objid =enr_obj ;
                if enr_count=0 then
                     DBMS_output.put_line(' Enrollment part numbers not in  dev copy from prod ');
                        select part_number into enr_pn
                          from sa.table_part_num@read_rtrp where objid =enr_obj;
                                DBA_UTIL_PKG.Add_Part_num(enr_pn);
                             DBMS_output.put_line(' Inserted the enrollment part number into dev');
                else
                     DBMS_output.put_line(' Found the Enrollment part numbers in dev');
                 end if;

          select count(*) into  mon_count
             from sa.table_part_num where objid = mon_obj;
              if mon_count=0 then
                    DBMS_output.put_line(' Monthly part number Not in  dev copy from prod');
                    select part_number into mon_pn
                          from sa.table_part_num@read_rtrp where objid =mon_obj;
                    DBA_UTIL_PKG.Add_Part_num(mon_pn);
                    DBMS_output.put_line(' Inserted the Monthly part number into dev');
                else
                DBMS_output.put_line(' Found the related Monthly part number in dev');
            end if;
      end if;
 end;
 Procedure get_site_name(siteobj in number) is

dealer  varchar2(100);
begin
  select s_name into   dealer from table_site@read_rtrp
  where objid =siteobj;
  dbms_output.put_line('The site to look for is : ' ||dealer );
    Add_New_site(dealer);
  end;
PROCEDURE ADD_PRICING(pn in  varchar2) is
pn_objid number;

cursor pr is
    select * from table_x_pricing@read_rtrp
     where x_pricing2part_num = pn_objid;
   lrec  pr%rowtype;
   tot_rows number;
  probj_exists number;
   v_pricing_seq number;
begin
   v_pricing_seq := SEQU_X_PRICING.nextval;
  select objid  into pn_objid from table_part_num@read_rtrp
  where s_part_number =upper(trim(pn));

   dbms_output.put_line('PNOBJ  '  || pn_objid);
     delete_pricing(pn_objid);
      dbms_output.put_line('deleted_rows');
       for lrec in pr loop
       ----check if objid already exists
               select count(*) into probj_exists
                    from table_x_pricing
                    where objid=lrec.objid;

                  if probj_exists = 0   then
                        insert into table_x_pricing
                        values   lrec;

                 else  ---this objid exist get sequence instead
                     insert into table_x_pricing
                            (OBJID,X_START_DATE,X_END_DATE,X_WEB_LINK,X_WEB_DESCRIPTION,X_RETAIL_PRICE,X_TYPE,
                             X_PRICING2PART_NUM,X_FIN_PRICELINE_ID,X_SP_WEB_DESCRIPTION,X_CARD_TYPE,X_SPECIAL_TYPE,
                            X_BRAND_NAME,X_CHANNEL)
                    values
                            (v_pricing_seq,    lrec.X_START_DATE,   lrec.X_END_DATE,    lrec.X_WEB_LINK,    lrec.X_WEB_DESCRIPTION,
                             lrec.X_RETAIL_PRICE,    lrec.X_TYPE,    lrec.X_PRICING2PART_NUM,    lrec.X_FIN_PRICELINE_ID,
                             lrec.X_SP_WEB_DESCRIPTION,    lrec.X_CARD_TYPE,    lrec.X_SPECIAL_TYPE,    lrec.X_BRAND_NAME,
                             lrec.X_CHANNEL);
                  end if;
                 probj_exists :=0;
               commit;
              tot_rows := pr%rowcount;
            end loop;
        commit;
       if tot_rows>0 then
            dbms_output.put_line('Inserted : ' || tot_rows || 'rows from prod');
        else
            dbms_output.put_line('No pricing in rtrp for : ' || pn_objid)  ;
       end if;
   end;
 Procedure delete_pricing(pnobj number) as

   vuser varchar2(50);

   cursor dpr is
   select pr.* from table_x_pricing pr
   where X_PRICING2PART_NUM =pnobj;

   begin
   select sys_context('USERENV','OS_USER') into vuser
   from dba_users where username = upper(user);
  for drec in dpr loop
       if dpr%rowcount >0 then
           dbms_output.put_line('Yes pricing is  set ');
            insert into DBAUTL_Table_X_Pric_hist
                (OBJID,X_START_DATE,X_END_DATE,X_WEB_LINK,X_WEB_DESCRIPTION,X_RETAIL_PRICE,X_TYPE,
                 X_PRICING2PART_NUM,X_FIN_PRICELINE_ID,X_SP_WEB_DESCRIPTION,X_CARD_TYPE,X_SPECIAL_TYPE,
                X_BRAND_NAME,X_CHANNEL,DELETE_DT,DELETE_BY)
     values
            (drec.OBJID,    drec.X_START_DATE,    drec.X_END_DATE,    drec.X_WEB_LINK,    drec.X_WEB_DESCRIPTION,
             drec.X_RETAIL_PRICE,    drec.X_TYPE,    drec.X_PRICING2PART_NUM,    drec.X_FIN_PRICELINE_ID,
             drec.X_SP_WEB_DESCRIPTION,    drec.X_CARD_TYPE,    drec.X_SPECIAL_TYPE,    drec.X_BRAND_NAME,
             drec.X_CHANNEL,sysdate, vuser);

            else
            dbms_output.put_line('No pricing set ');
           end if;
      end loop;

       commit;
       delete  from table_x_pricing pr
        where X_PRICING2PART_NUM =pnobj;
        commit;
     end;
--PROCEDURE Get_Script_info(scid in varchar2, sctp in varchar2, plang in varchar2 , ptech in varchar2,Brand_nm  in varchar2,
--psrcsys varchar2) is
PROCEDURE Check_Script(scid in varchar2, sctp in varchar2, plang in varchar2 , ptech in varchar2,Brand_nm  in varchar2,
psrcsys varchar2) is

devmax date;prodmax date;RETNUM number;

p_BRAND   Number;
cursor  brandC is
   select objid
   from table_bus_org
   where s_org_id=upper(Brand_nm);

   crec brandC%rowtype;

PROCEDURE CREATE_conclause(lv_sc_id in varchar2,lv_sc_type in varchar2,LV_LANG in varchar2,
                                  LV_BRAND in number,lv_tech in varchar2, lv_src in varchar2 ,Mpub_date in  date,
                                  Cond_clause out varchar2,Cond_dt_clause out varchar2) is

sc_type_clause varchar2(500);
sc_id_clause varchar2(500);
SC_LANG_CLAUSE varchar2(500);
SC_BRND_CLAUSE VARCHAR2(500);
sc_tech_clause varchar2(200);

src_clause varchar2(300);
Mpub_dt_clause  varchar2(300) ;

begin


      IF   lv_sc_id IS NULL THEN
            sc_id_clause :=null ;
      else
            sc_id_clause :=' and  x_script_id = ''' || lv_sc_id || '''';
      end if;

      if lv_sc_type is null then
             sc_type_clause := null ;
      else
              sc_type_clause  := ' and x_script_type like  ''%' || lv_sc_type|| '%''';
      end if;

       if  LV_LANG  is null then
             SC_LANG_CLAUSE :=null ;
      else
             SC_LANG_CLAUSE := ' AND x_language =  ''' || LV_LANG || '''';
      end if;
      if rtrim(lv_tech)  is null then
             sc_tech_clause :=' ';
      else
             sc_tech_clause :=' and x_technology =  ''' ||  lv_tech || '''';
      end if;
        --dbms_output.put_line('Mpub_date:  '||Mpub_date);
       if Mpub_date is null then
             Mpub_dt_clause :=null ;
         else
             Mpub_dt_clause := ' and x_published_date > :edate ';
       end if;

     if LV_BRAND is null then
          SC_BRND_CLAUSE :=null ;
     else
            SC_BRND_CLAUSE := ' and SCRIPT2BUS_ORG=  ' || LV_BRAND ||' ' ;
     END IF;

      if lv_src is null then
          src_clause :=null ;
        else
            src_clause := ' and x_sourcesystem= ''' || lv_src || '''';
      END IF;
          Cond_clause := sc_type_clause|| sc_id_clause||SC_LANG_CLAUSE||sc_tech_clause||SC_BRND_CLAUSE|| src_clause;
          Cond_dt_clause :=Cond_clause|| Mpub_dt_clause ;

  --dbms_output.put_line('Cond_clause WITH DATE : '||Cond_dt_clause);
END ;   --CREATE_conclause


PROCEDURE CHK_LATEST(scid in varchar2, sctp in varchar2, plang in varchar2 , ptech in varchar2,pbrand number,
                                      psrcsys varchar2,devmax out date,prodmax out date,RETNUM  out NUMBER)  is

sqlstmt1 varchar2(2000);
sqlstmt2 varchar2(2000);
Cond_clause varchar2(1500);
Cond_dt_clause varchar2(1500);
Mpub_date date;
begin

sqlstmt1   :='select max(x_published_date)
                 FROM table_x_scripts
                WHERE 1=1 ' ;

sqlstmt2 :='select max(x_published_date)
                 FROM table_x_scripts@read_rtrp
                WHERE 1=1 ';

      CREATE_conclause(scid,sctp,plang,pbrand,ptech, psrcsys ,Mpub_date ,Cond_clause ,Cond_dt_clause );
          sqlstmt1  := sqlstmt1||Cond_clause;
          --   dbms_output.put_line('sqlstmt1 : ' ||sqlstmt1);
          sqlstmt2 :=sqlstmt2||Cond_clause;
           --    dbms_output.put_line('sqlstmt2 : ' ||sqlstmt2);
       execute immediate sqlstmt1 into devmax ;
       execute immediate sqlstmt2 into prodmax ;
   if  devmax > prodmax then
       retnum :=0 ;
    elsif
         prodmax = devmax then
           retnum :=0 ;
        else
              retnum :=1 ;
  end if;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
     DBMS_output.put_line( 'No data from chk_latest Procedure for the search criteria ');
    when others  then
        raise_application_error( -20011,'Unknown Exception in chk_latest Procedure');
end;  ---CHK_LATEST


PROCEDURE CREATE_SQLSTMTS_bydate(lv_sc_id in varchar2,lv_sc_type in varchar2,LV_LANG in varchar2,
                                  LV_BRAND in number,lv_tech in varchar2, lv_src in varchar2 ,
                                  Mpub_date in  date,sqlstmt1  out varchar2,sqlstmt2 out varchar2) is

Cond_clause varchar2(1500);
Cond_dt_clause varchar2(1500);
begin

sqlstmt1   :=' SELECT *
                 FROM table_x_scripts
                WHERE 1=1 ' ;

sqlstmt2 :='SELECT *
                 FROM table_x_scripts@read_rtrp
                WHERE 1=1 ';


     CREATE_conclause(lv_sc_id,lv_sc_type,LV_LANG,LV_BRAND,lv_tech, lv_src ,Mpub_date ,Cond_clause ,Cond_dt_clause );

          sqlstmt1  := sqlstmt1||Cond_dt_clause;
          sqlstmt2 :=sqlstmt2||Cond_dt_clause;

         --   DBMS_output.put_line( 'sqlstmt1 ' ||sqlstmt1);
         --   DBMS_output.put_line( 'sqlstmt2 ' ||sqlstmt2);
  EXCEPTION

 when NO_DATA_FOUND

 then  DBMS_output.put_line( 'No data from CREATE_SQLSTMTS Procedure ');

 when others

 then raise_application_error( -20011,'Unknown Exception in CREATE_SQLSTMTS Procedure');
END ;  --CREATE_SQLSTMTS_bydate


PROCEDURE Insert_Scripts_PBdate(p_sc_type in varchar2,p_sc_id in varchar2,p_LANG in varchar2,
    p_tech in varchar2,Brand_nm in number,p_srcsys in varchar2) is

 TYPE tbl_scripts IS TABLE OF TABLE_X_SCRIPTS%ROWTYPE;
  My_Scripts   tbl_scripts;

  sqlstmt1   varchar2 (2000);
  sqlstmt2  varchar2 (2000);
  sqlstmt3 varchar2(3000);

  rn number :=0;
  dmax date := null;
  pmax date := null;
  p_BRAND number;


begin

  chk_latest(p_sc_id,p_sc_type,p_LANG ,p_tech, p_BRAND, p_srcsys ,dmax,pmax,rn);
        dbms_output.put_line('Latest published date in DEV :  '||dmax);
        dbms_output.put_line('Latest published date in Prod  :  '||pmax);

     if  trunc(dmax )is null or trunc( pmax) is null then
          dbms_output.put_line('No dates to compare latest exiting ');
      else
        IF RN =1 THEN
            -- dbms_output.put_line( 'RN :' ||rn);
             dbms_output.put_line('THE SCRIPTS IN DEV ARE NOT LATEST ');
             delete from script_notindev;
             commit;
             CREATE_SQLSTMTS_bydate(p_sc_id,p_sc_type,p_LANG,  p_BRAND,p_tech, p_srcsys ,dmax ,sqlstmt1  ,sqlstmt2 );
           sqlstmt3 := (sqlstmt2 ||'   minus  '||sqlstmt1);

  EXECUTE IMMEDIATE sqlstmt3 BULK COLLECT INTO My_Scripts using dmax,dmax;

  IF My_Scripts.count =0 THEN
    DBMS_OUTPUT.PUT_LINE('NO Scripts found  : DEV  ');
  else
      FOR i IN 1..my_scripts.COUNT  LOOP
         insert into script_notindev(  objid,
                     X_SCRIPT_ID,
                     X_SCRIPT_TYPE,
                     X_SOURCESYSTEM,
                     X_DESCRIPTION,
                     X_LANGUAGE,
                     X_TECHNOLOGY,
                     X_SCRIPT_TEXT,
                     X_PUBLISHED_DATE,
                     X_PUBLISHED_BY,
                     X_SCRIPT_MANAGER_LINK,
                     SCRIPT2BUS_ORG)
       values ( my_scripts(i).objid,
                     my_scripts(i).X_SCRIPT_ID,
                     my_scripts(i).X_SCRIPT_TYPE,
                     my_scripts(i).X_SOURCESYSTEM,
                     my_scripts(i).X_DESCRIPTION,
                     my_scripts(i).X_LANGUAGE,
                     my_scripts(i).X_TECHNOLOGY,
                     my_scripts(i).X_SCRIPT_TEXT,
                     my_scripts(i).X_PUBLISHED_DATE,
                     my_scripts(i).X_PUBLISHED_BY,
                     my_scripts(i).X_SCRIPT_MANAGER_LINK,
                     my_scripts(i).SCRIPT2BUS_ORG);
            commit;
        end loop;
    end if;
ELSE
   dbms_output.put_line('THE SCRIPTS IN DEV ARE LATEST  NO NEED TO INSERT IN SCRIPT_NOTINDEV ');
END IF;

  end if;
end;    --Insert_Scripts_PBdate
PROCEDURE  find_Total_missng (lv_sc_id in varchar2,lv_sc_type in varchar2,LV_LANG in varchar2,
                                  LV_BRAND in number,lv_tech in varchar2, lv_src in varchar2 ) is

   TYPE Missing_scripts IS TABLE OF sa.Temp_script_comp%ROWTYPE;
   MyR   Missing_scripts;

grp_clause  varchar2(300) ;
Cond_clause varchar2(1500);
Cond_dt_clause varchar2(1500);
sqlst1 varchar2(3000);
sqlst2 varchar2(3000);
sqlst3 varchar2(3000);
rtrp_count number;
dev_count number;
    diff_count number;
    sqlstmt4 varchar2(3000);
    sqlstmt5 varchar2(3000);


Mpub_date date;
vuser varchar2(50);
dbname varchar2(30);
begin
  select sys_context('USERENV','DB_NAME') into dbname     from dual;

sqlst1   :=' select count(*) tot_sc ,x_script_id,X_script_type,x_technology,script2bus_org,x_language,max(x_published_date)
                 FROM table_x_scripts
                WHERE 1=1 ' ;
sqlst2 :=' select count(*) tot_sc , x_script_id,X_script_type,x_technology,script2bus_org,x_language,max(x_published_date)
                 FROM table_x_scripts@read_rtrp
                WHERE 1=1 ' ;
 grp_clause   :='group by  x_script_id, X_script_type, X_TECHNOLOGY,script2bus_org,x_language '    ;

     sqlstmt4 :='select count(*)  FROM table_x_scripts@read_rtrp WHERE 1=1  ';

      sqlstmt5 := 'select count(*)      FROM table_x_scripts     WHERE 1=1  ';


      CREATE_conclause( lv_sc_id ,lv_sc_type ,LV_LANG ,LV_BRAND ,lv_tech , lv_src  ,Mpub_date ,Cond_clause ,Cond_dt_clause );

        sqlst1  := sqlst1||Cond_clause||grp_clause;
        sqlst2 :=sqlst2||Cond_clause||grp_clause;
        sqlst3 := (sqlst2 ||'   minus  '||sqlst1);

      -- sqlstmt4 := sqlstmt4 ||Cond_clause||grp_clause;
      -- sqlstmt5 := sqlstmt5|| Cond_clause||grp_clause;
      sqlstmt4 := sqlstmt4 ||Cond_clause;
      sqlstmt5 := sqlstmt5|| Cond_clause;

       select sys_context('USERENV','OS_USER') into vuser
        from dba_users where username = upper(user);
   --  dbms_output.put_line('Missing scripts  sqlstmt4' || sqlstmt4);
   --  dbms_output.put_line('Missing scripts  sqlstmt5' || sqlstmt5);

    ---dbms_output.put_line(' temp_script_comp Query to check all   :    '||sqlst3);
   delete from Temp_script_comp;
   commit;
      EXECUTE IMMEDIATE  sqlstmt4  into rtrp_count ;
      EXECUTE IMMEDIATE  sqlstmt5 into dev_count ;

        dbms_output.put_line(' Number of scripts seached :  ' );
        dbms_output.put_line('  RTRP :  ' || rtrp_count);
        dbms_output.put_line(' SIT '||dbname||':'  || dev_count);
   if rtrp_count > dev_count then
       diff_count := rtrp_count - dev_count;
       dbms_output.put_line(' Number of scripts seached :  ' );
       dbms_output.put_line('  RTRP :  ' || rtrp_count);
       dbms_output.put_line(' SIT '||dbname||':'  || dev_count);
       dbms_output.put_line(  diff_count   || '  :  Missing in '|| dbname );

  EXECUTE IMMEDIATE sqlst3 BULK COLLECT INTO MyR ;
--dbms_output.put_line('sqlst3 = ' || sqlst3);
  IF MyR.count =0 THEN
    DBMS_OUTPUT.PUT_LINE('NO difference in scripts after checking all   :   ');
   else
         FOR i IN 1..MyR.COUNT  LOOP
            insert into Temp_script_comp (Total_rtrp ,x_script_id ,x_script_type , x_technology ,script2bus_org ,x_language,max_pub_date )
            values(MyR(i).Total_rtrp, MyR(i).x_script_id, MyR(i).X_script_type, MyR(i).x_technology,
                MyR(i).script2bus_org,MyR(i).x_language,myR(i).max_pub_date);
          commit;
       end loop;
          update Temp_script_comp
             set checked_by=vuser,
              Time_ckd = sysdate ;
         commit;
          -- dbms_output.put_line(' Total of missingscrips in: from RTRP into Temp_script_comp');
  end if;
 else  --if dev has more or equal
   -- diff_count  := dev_count -   rtrp_count;
 --  if diff_count > 0 then
  -- dbms_output.put_line(' More scripts in DEV ');
  --else
   -- dbms_output.put_line(' Equal scripts in DEV and RTRP '  );
   --end if;
   null;
    end if;
 EXCEPTION

 when NO_DATA_FOUND

 then  DBMS_output.put_line( 'No data from find_Total_missng Procedure ');

 when others

 then raise_application_error( -20011,'Unknown Exception in find_Total_missng Procedure');

END ;  ----find_Total_missng

 PROCEDURE CREATE_SQLSTMTS(lv_sc_id in varchar2,lv_sc_type in varchar2,LV_LANG in varchar2,
                                  LV_BRAND in number,lv_tech in varchar2, lv_src in varchar2 ,
                                  --Mpub_date date,
                                  sqlstmt1  out varchar2,sqlstmt2 out varchar2) is

Cond_clause varchar2(1500);
Cond_dt_clause varchar2(1500);
Mpub_date  date;
begin

sqlstmt1   :=' SELECT *
                 FROM table_x_scripts
                WHERE 1=1 ' ;

sqlstmt2 :='SELECT *
                 FROM table_x_scripts@read_rtrp
                WHERE 1=1 ';

     CREATE_conclause(lv_sc_id,lv_sc_type,LV_LANG,LV_BRAND,lv_tech, lv_src ,Mpub_date ,Cond_clause ,Cond_dt_clause );

          sqlstmt1  := sqlstmt1||Cond_clause;
          sqlstmt2 :=sqlstmt2||Cond_clause;

          --   DBMS_output.put_line( 'sqlstmt1 ' ||sqlstmt1);
           --  DBMS_output.put_line( 'sqlstmt2 ' ||sqlstmt2);
 EXCEPTION

 when NO_DATA_FOUND

 then  DBMS_output.put_line( 'No data from CREATE_SQLSTMTS Procedure ');

 when others

 then raise_application_error( -20011,'Unknown Exception in CREATE_SQLSTMTS Procedure');
END ;  --CREATE_SQLSTMTS

PROCEDURE Get_scripts_NotInDev(p_sc_type in varchar2,p_sc_id in varchar2,p_LANG in varchar2,
p_tech in varchar2,LV_BRAND in number,p_srcsys in varchar2)  is

TYPE tbl_scripts IS TABLE OF TABLE_X_SCRIPTS%ROWTYPE;
  My_Scripts   tbl_scripts;

  sqlstmt1   varchar2 (2000);
  sqlstmt2  varchar2 (2000);
  sqlstmt3 varchar2(3000);
   vuser  varchar2(50);
 dbname varchar2(30);
begin
     select sys_context('USERENV','DB_NAME') into dbname     from dual;
     select sys_context('USERENV','OS_USER') into vuser
       from dba_users where username = upper(user);

     --dbms_output.put_line('Checking for any Deletes or overwrites !!!!  ');

      CREATE_SQLSTMTS(p_sc_id,p_sc_type,p_LANG,  LV_BRAND ,p_tech, p_srcsys ,sqlstmt1  ,sqlstmt2 );

    sqlstmt3 := (sqlstmt2 ||'   minus  '||sqlstmt1);
    delete from script_notindev;
             commit;

  EXECUTE IMMEDIATE sqlstmt3 BULK COLLECT INTO My_Scripts;

  IF My_Scripts.count =0 THEN
    DBMS_OUTPUT.PUT_LINE('NO Scripts missing  :   ');
  else
     DBMS_OUTPUT.PUT_LINE('There is  '|| My_scripts.count || ' Overwritten/Deleted  script');
      FOR i IN 1..my_scripts.COUNT  LOOP
         insert into script_notindev(  objid,
                     X_SCRIPT_ID,
                     X_SCRIPT_TYPE,
                     X_SOURCESYSTEM,
                     X_DESCRIPTION,
                     X_LANGUAGE,
                     X_TECHNOLOGY,
                     X_SCRIPT_TEXT,
                     X_PUBLISHED_DATE,
                     X_PUBLISHED_BY,
                     X_SCRIPT_MANAGER_LINK,
                     SCRIPT2BUS_ORG)
       values (   my_scripts(i).objid,
                     my_scripts(i).X_SCRIPT_ID,
                     my_scripts(i).X_SCRIPT_TYPE,
                     my_scripts(i).X_SOURCESYSTEM,
                     my_scripts(i).X_DESCRIPTION,
                     my_scripts(i).X_LANGUAGE,
                     my_scripts(i).X_TECHNOLOGY,
                     my_scripts(i).X_SCRIPT_TEXT,
                     my_scripts(i).X_PUBLISHED_DATE,
                     my_scripts(i).X_PUBLISHED_BY,
                     my_scripts(i).X_SCRIPT_MANAGER_LINK,
                     my_scripts(i).SCRIPT2BUS_ORG);
            commit;
        end loop;
        update script_notindev
         set checked_by=vuser,
              Time_ckd = sysdate ;
         commit;
        --DBMS_OUTPUT.PUT_LINE('Check sa.script_notindev  in :  '|| dbname);

    end if;

end;--Get_scripts_NotInDev

begin

  open   brandC;
    fetch brandC into crec;
      if brandc%found then
    p_BRAND :=crec.objid;
   end if;
    close brandc;
        Insert_Scripts_PBdate(sctp,scid ,plang,ptech,p_BRAND,psrcsys);
       find_Total_missng (scid ,sctp,plang,p_BRAND,ptech,psrcsys ) ;
       Get_scripts_NotInDev(sctp,scid,plang,ptech,p_BRAND,psrcsys);
       DBMS_OUTPUT.PUT_LINE('*********************************************************************************');
       DBMS_OUTPUT.PUT_LINE(' To insert the  missing scripts execute procedure  SA.DBA_UTIL.INSERT_MISSING_SCRIPTS()    ');
      DBMS_OUTPUT.PUT_LINE('*********************************************************************************');
end;---get_Script_info

Procedure INSERT_MISSING_SCRIPTS as
  cursor a is
    select * from SCRIPT_NOTINDEV;
    tcs number :=0;
    dbname varchar2(30);
   max_date date;
begin
    select sys_context('USERENV','DB_NAME') into dbname     from dual;
      --dbms_output.put_line('TCS is :  ' || tcs);
    for r in a loop
           select count(*) into tcs from TABLE_X_SCRIPTS
           where objid =r.objid;

            if tcs > 0  then
                  ---check pubdate field in dev newer
                   select max(X_PUBLISHED_DATE) into max_date
                    from TABLE_X_SCRIPTS
                    where X_SCRIPT_ID = r.X_SCRIPT_ID
                    and   X_SCRIPT_TYPE =r.X_SCRIPT_TYPE
                    and   X_SOURCESYSTEM =r.X_SOURCESYSTEM
                    and   X_LANGUAGE =r.X_LANGUAGE
                    and X_TECHNOLOGY=r.X_TECHNOLOGY
                    and SCRIPT2BUS_ORG=r.SCRIPT2BUS_ORG;

                   if max_date < r. X_PUBLISHED_DATE
                     then
                         update TABLE_X_SCRIPTS
                          set X_SCRIPT_TEXT =r.X_SCRIPT_TEXT
                          where X_PUBLISHED_DATE <r.X_PUBLISHED_DATE
                              and X_SCRIPT_ID = r.X_SCRIPT_ID
                              and   X_SCRIPT_TYPE =r.X_SCRIPT_TYPE
                              and   X_SOURCESYSTEM =r.X_SOURCESYSTEM
                              and   X_LANGUAGE =r.X_LANGUAGE
                              and X_TECHNOLOGY=r.X_TECHNOLOGY
                              and  SCRIPT2BUS_ORG=r.SCRIPT2BUS_ORG;
                              dbms_output.put_line('Updated the text for script_id  ' || r.X_SCRIPT_ID||'_'||r.X_SCRIPT_TYPE || '  '|| r.SCRIPT2BUS_ORG);
                    else
                        insert into TABLE_X_SCRIPTS (  objid,
                                     X_SCRIPT_ID,
                                     X_SCRIPT_TYPE,
                                     X_SOURCESYSTEM,
                                     X_DESCRIPTION,
                                     X_LANGUAGE,
                                     X_TECHNOLOGY,
                                     X_SCRIPT_TEXT,
                                     X_PUBLISHED_DATE,
                                     X_PUBLISHED_BY,
                                     X_SCRIPT_MANAGER_LINK,
                                     SCRIPT2BUS_ORG)

                            values( SEQU_X_SCRIPTS.nextval ,
                                     r.X_SCRIPT_ID,
                                     r.X_SCRIPT_TYPE,
                                     r.X_SOURCESYSTEM,
                                     r.X_DESCRIPTION,
                                     r.X_LANGUAGE,
                                     r.X_TECHNOLOGY,
                                     r.X_SCRIPT_TEXT,
                                     r.X_PUBLISHED_DATE,
                                     r.X_PUBLISHED_BY,
                                     r.X_SCRIPT_MANAGER_LINK,
                                     r.SCRIPT2BUS_ORG);
                                  dbms_output.put_line('Inserted the missing scripts with next sequence  for brand  '||': '|| r.SCRIPT2BUS_ORG );
                    end if;
                else  ---if no objid matching
                     insert into TABLE_X_SCRIPTS (  objid,
                                     X_SCRIPT_ID,
                                     X_SCRIPT_TYPE,
                                     X_SOURCESYSTEM,
                                     X_DESCRIPTION,
                                     X_LANGUAGE,
                                     X_TECHNOLOGY,
                                     X_SCRIPT_TEXT,
                                     X_PUBLISHED_DATE,
                                     X_PUBLISHED_BY,
                                     X_SCRIPT_MANAGER_LINK,
                                     SCRIPT2BUS_ORG)
                            values( r.objid,
                                     r.X_SCRIPT_ID,
                                     r.X_SCRIPT_TYPE,
                                     r.X_SOURCESYSTEM,
                                     r.X_DESCRIPTION,
                                     r.X_LANGUAGE,
                                     r.X_TECHNOLOGY,
                                     r.X_SCRIPT_TEXT,
                                     r.X_PUBLISHED_DATE,
                                     r.X_PUBLISHED_BY,
                                     r.X_SCRIPT_MANAGER_LINK,
                                     r.SCRIPT2BUS_ORG);
                                dbms_output.put_line('Inserted the missing scripts with prod objid  for brand  '||' : '|| r.SCRIPT2BUS_ORG );
                       end if;
                    COMMIT;
                   tcs :=0;
               end loop;
             commit;
           dbms_output.put_line('Scripts uptodate in   ' ||dbname );
           delete from  SCRIPT_NOTINDEV;  ----Once updated the table is purged.
           commit;
    end;
-----user management
Procedure  update_Priv_class(ip_Priv_class in varchar2,Ip_Login_Name  In  Varchar2) as

Prev_cls_objid number;
userobj  number;
cursor prev_class is
select  Objid  --into Prev_cls_objid
  from  TABLE_PRIVCLASS
  where upper(s_class_name) = upper(ip_Priv_class);
  p prev_class%rowtype;



  cursor get_user is
  SELECT  objid
  from   TABLE_USER
   where S_LOGIN_NAME =( UPPER(Ip_Login_Name));
    u get_user%rowtype;
begin

         open get_user;
             fetch get_user into u ;
         if get_user%notfound then

           dbms_output.put_line('user not found');

         else
                userobj := u.objid;
               open prev_class;
               fetch prev_class into p;

               if prev_class%found then
                   Prev_cls_objid := p.objid;
                     UPDATE  TABLE_USER
                        SET     USER_ACCESS2PRIVCLASS = Prev_cls_objid -- Previlege Objid
                        WHERE   OBJID = userobj -- User objid
                        AND ROWNUM < 2;
                        dbms_output.put_line('Privilege  : '||ip_Priv_class ||'  set  for   '||Ip_Login_Name );
                 else
                     dbms_output.put_line('Privilege not found');

               end if;
            close prev_class;
      --  end if;
   close get_user;
   end if;
   dbms_output.put_line('User obj' || userobj);

COMMIT;
end; --update_Priv_class
Procedure update_sec_grp(Ip_Sec_Grp_Name  In  varchar2,Ip_Login_Name  In  Varchar2) as

        cursor get_user is
          SELECT  objid
          from   TABLE_USER
           where S_LOGIN_NAME =( UPPER(Ip_Login_Name));
            u get_user%rowtype;
        cursor sec_grp is
         select objid  --into sec_grp_objid
        from TABLE_X_SEC_GRP
        where upper(x_grp_name)= upper(Ip_Sec_Grp_Name);
        s sec_grp%rowtype;

        sec_grp_objid number;
        userobj  number;
begin
  open get_user;
    fetch get_user into u;
    if get_user%found then
            userobj  := u.objid;
        open sec_grp;
         fetch sec_grp into s;
             if sec_grp%found then
                sec_grp_objid := s.objid;

                UPDATE  MTM_USER125_X_SEC_GRP1
                SET     X_SEC_GRP2USER = sec_grp_objid-- SEC_group_objid
                WHERE  USER2X_SEC_GRP = userobj  -- USER_OBJID
                    AND ROWNUM < 2;
                COMMIT;
                 dbms_output.put_line('Update Security group');
             else
               dbms_output.put_line('Security group not found');
           end if;
          close sec_grp;
        else
        dbms_output.put_line('user not found');
      end if;
    close get_user;

end;---update_sec_grp
Procedure Create_User_Tas (
Ip_Priviledge_Class In Varchar2,
Ip_Sec_Grp_Name  In  varchar2,
Ip_Login_Name  In  Varchar2,
Ip_First_Name  In Varchar2,
Ip_Last_Name  In Varchar2,
Ip_Employee_Id  In  Varchar2,
Ip_Email In Varchar2,
OP_MESSAGE out varchar2) AS


--DEFAULTS NO NEED TO CHANGE--
IP_DEFAULT_ENCODED_PASSWORD VARCHAR2(30):='[ScBhozpV1nkzzNPrE/';
IP_ADMIN_USER_OBJID NUMBER:=268435556;  --objid user attempting the creation of the account 'sa'
Ip_Site_Objid Number:=268435456;   --Default SITE OBJID
Ip_Group Varchar2(30):='Call Center';
Found_Rec Number;

V_Employee_Objid Number;
V_USER_OBJID number;
V_Wipbin_Objid Number;
V_Time_Bomb_Objid Number;
V_SEC_GRP_OBJID number;

cursor c1 is
Select * From Table_Privclass
Where  S_Class_Name = Upper(Ip_Priviledge_Class );

r1 c1%rowtype;

cursor c2 is
select * from table_x_sec_grp
where x_grp_name = Ip_Sec_Grp_Name;

R2 C2%Rowtype;
Sql_Stmt Varchar2(300);

BEGIN

Select Count(*)
Into Found_Rec
From TABLE_User
Where S_LOGIN_NAME = upper(Ip_Login_Name);

If Found_Rec>0 Then
   Op_Message:='User already exists';
   Return;
end if;

Open C1;
Fetch C1 Into R1;
If C1%Notfound Then
   Close C1;
   Op_Message :=  'Invalid Privilege Class -- '||Ip_Priviledge_Class ;
   Return;
Else
   Close C1;
end if;

Open c2;
fetch c2 into r2;
if c2%notfound then
   close c2;
   Op_Message := 'Invalid Security Group -- '||Ip_Sec_Grp_Name;
   return;
else
   V_SEC_GRP_OBJID:=r2.objid;
   close c2;
end if;


Select count(*)
Into Found_Rec
From Table_Privclass,Table_User
Where User_Access2privclass = Table_Privclass.Objid
And S_Login_Name In (Select User From Dual)
And Class_Name = 'System Administrator';

If Found_Rec=0 Then
   Op_Message:='Not a System Administrator, cannot create users';
   Return;
End If;


SELECT sa.seq('employee') into V_EMPLOYEE_OBJID FROM dual;
SELECT sa.seq('user') into V_USER_OBJID FROM dual;
Select sa.Seq('wipbin') Into V_Wipbin_Objid From Dual;
SELECT sa.seq('time_bomb') into V_TIME_BOMB_OBJID FROM dual;

--Insert new wipbin
--
insert into table_wipbin (objid,title, S_title,description,ranking_rule,icon_id,dialog_id,wipbin_owner2user)
values(V_Wipbin_Objid,'default','DEFAULT','','',0,375, V_USER_OBJID);

--
--insert new user
--
insert into table_user (objid,login_name, S_login_name,password,agent_id,status,equip_id,
CS_Lic,CSDE_Lic,CQ_Lic,passwd_chg,last_login,CLFO_Lic,cs_lic_type,cq_lic_type,
CSFTS_Lic,CSFTSDE_Lic,CQFTS_Lic,web_login,S_web_login,web_password,submitter_ind,
SFA_LIC,CCN_LIC,UNIV_LIC,NODE_ID,LOCALE,WIRELESS_EMAIL,ALT_LOGIN_NAME,
S_alt_login_name,user_default2wipbin,user_access2privclass,offline2privclass,USER2RC_CONFIG,dev, WEB_LAST_LOGIN, WEB_PASSWD_CHG)
 values(V_USER_OBJID,IP_LOGIN_NAME,upper(IP_LOGIN_NAME),
IP_DEFAULT_ENCODED_PASSWORD,'',1,'', TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
 TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
SYSDATE, SYSDATE,
 TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
0,0, TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),'','','Y2fEjdGT1W6nsLqtJbGUVeUp9e4=',0,
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
To_Date( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),'1',
0,'','','', V_WIPBIN_OBJID, r1.objid, 268435758,268436363,1,SYSDATE, SYSDATE);


--insert new employee
--
insert into table_employee (objid,first_name, S_first_name,last_name, S_last_name,mail_stop,phone,alt_phone,fax,beeper,e_mail,labor_rate,field_eng,acting_supvr,available,avail_note,
employee_no,normal_biz_high,normal_biz_mid,normal_biz_low,after_biz_high,after_biz_mid,after_biz_low,work_group,
wg_strt_date,site_strt_date,voice_mail_box,local_login,local_password,allow_proxy,printer,on_call_hw,on_call_sw,
case_threshold,title,salutation,x_q_maint,x_error_code_maint,x_select_trans_prof,x_update_set,x_order_types,
x_dashboard,x_allow_script,x_allow_roadside,employee2user,supp_person_off2site,emp_supvr2employee)
 values
(V_EMPLOYEE_OBJID,IP_FIRST_NAME,upper(IP_FIRST_NAME),
IP_LAST_NAME,upper(IP_LAST_NAME),
'','','','','',IP_EMAIL,0.000000,0,0,1,'',IP_EMPLOYEE_ID,'','','',IP_EMAIL,
IP_EMAIL,IP_EMAIL,IP_GROUP, TO_DATE( '1/1/1753 00:00:00' , 'MM/DD/YYYY HH24:MI:SS'),
 TO_DATE( '1/1/1753 00:00:00' , 'MM/DD/YYYY HH24:MI:SS'),
'','','',0,'',0,0,0,'','',0,0,0,0,0,0,0,0, V_USER_OBJID, IP_SITE_OBJID, 0);
--
-- insert new time_bomb (could be removed)
--

insert into table_time_bomb (
objid,title,escalate_time,end_time,focus_lowid,focus_type,suppl_info,time_period,flags,left_repeat,
report_title,property_set,users,creation_time) values(
V_TIME_BOMB_OBJID,
IP_LOGIN_NAME, TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),0,0,'',0,65540,0,'','','',sysdate);
--
-- Find Security Group OBJID
--

Insert Into Mtm_User125_X_Sec_Grp1
    (User2x_Sec_Grp, X_Sec_Grp2user)
    Values (V_User_Objid,V_Sec_Grp_Objid);

Commit;

op_message:='TAS User Created -- '||Ip_Login_Name ||'|| Password abc123';

End; ---create user TAS
PROCEDURE RESET_USER_TAS (v_login varchar2) AS

   v_stat varchar2(100) := null ;
   cursor tab
   is
   select objid,s_login_name
   from sa.table_user
   where  s_LOGIN_NAME = TRIM(UPPER(v_login));

   r_tab tab%ROWTYPE;

BEGIN
    -- v_login := trim(upper(login_name));
      OPEN tab;
      FETCH tab INTO r_tab;
      IF tab%FOUND THEN
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
       where objid=r_tab.objid;

   delete from sa.TABLE_X_PASSWORD_HIST where S_X_LOGIN_NAME =r_tab.s_login_name;
       commit;

       DBMS_OUTPUT.put_line('******************************');
       DBMS_OUTPUT.put_line('TAS User '||v_login||' Updated');
    else
       DBMS_OUTPUT.put_line('******************************');
       DBMS_OUTPUT.put_line('TAS '||v_login||' Not Found');
       END IF;
       close tab;

end;
Procedure Create_User_db (
P_Uname In Varchar2,
OP_MESSAGE out varchar2)
AS
  Uname VARCHAR2(50) := upper(P_Uname);
  v_statement  varchar2(1000);

 cursor c (p_name varchar2) is
 select 1 from dba_users where username=upper(p_name);
 l c%rowtype;

begin
  open c(Uname);
  fetch c into l;
  if c%notfound then
       v_statement := 'CREATE user '||Uname||'  identified by "Abc123**" default tablespace users ACCOUNT UNLOCK PROFILE default';
--     dbms_output.put_line (v_statement);
   EXECUTE IMMEDIATE v_statement ;
   op_message:='DB User Created -- '||Uname ||'|| Password Abc123**';
  else
      op_message:='DB User exists unlock the user ';

   end if;


  v_statement := 'grant CONNECT,RESOURCE,ROLE_SA_SELECT, ROLE_SQA_UPDATE,ROLE_TF_SELECT,ROLE_SQA_TESTER, CREATE SESSION , UNLIMITED TABLESPACE to '||uname;
   EXECUTE IMMEDIATE v_statement ;

 close c;

End; ---end Create_User_db
 Procedure Reset_User_db (
P_Uname In Varchar2,
OP_MESSAGE out varchar2)
AS
  Uname VARCHAR2(50) := upper(P_Uname);
  v_statement  varchar2(1000);

 cursor c (p_name varchar2) is
 select 1 from dba_users where username=upper(p_name);
 l c%rowtype;

begin
  open c(Uname);
  fetch c into l;
  if c%notfound then

   op_message:='DB User not found create the user -- '||Uname ;
  else
   v_statement := 'alter USER  '||Uname||' IDENTIFIED BY "Abc123**" account unlock profile default';
  EXECUTE IMMEDIATE v_statement ;
     op_message:='DB User Altered -- '||Uname ||'|| Password Abc123**';
   end if;
     --v_statement := 'grant CONNECT,RESOURCE,ROLE_SA_SELECT, ROLE_SQA_UPDATE,ROLE_TF_SELECT,ROLE_SQA_TESTER, CREATE SESSION , UNLIMITED TABLESPACE to '||uname;
   EXECUTE IMMEDIATE v_statement ;

 close c;

End;  ---Reset_User_db

Procedure Create_user_B2C_b2b(
Ip_Priviledge_Class In Varchar2,
Ip_Sec_Grp_Name  In  varchar2,
Ip_Login_Name  In  Varchar2,
Ip_First_Name  In Varchar2,
Ip_Last_Name  In Varchar2,
Ip_Employee_Id  In  Varchar2,
ip_role  in varchar2,
Ip_Email In Varchar2,
OP_MESSAGE out varchar2)
AS


--DEFAULTS NO NEED TO CHANGE--
IP_DEFAULT_ENCODED_PASSWORD VARCHAR2(30):='[ScBhozpV1nkzzNPrE/';
IP_ADMIN_USER_OBJID NUMBER:=268435556;  --objid user attempting the creation of the account 'sa'
Ip_Site_Objid Number:=268435456;   --Default SITE OBJID
Ip_Group Varchar2(30):='Call Center';
Found_Rec Number;

V_Employee_Objid Number;
V_USER_OBJID number;
V_Wipbin_Objid Number;
V_Time_Bomb_Objid Number;
V_SEC_GRP_OBJID number;

cursor c1 is
Select * From Table_Privclass
Where  S_Class_Name = Upper(Ip_Priviledge_Class );

r1 c1%rowtype;

cursor c2 is
select * from table_x_sec_grp
where x_grp_name = Ip_Sec_Grp_Name;

R2 C2%Rowtype;
Sql_Stmt Varchar2(300);
bobjid number;
cursor user_ext(uobj number) is

     select * from table_user_extn
     where TABLE_USER_OBJID =uobj
--      and  AGENT_ROLE =ip_role
      and  COMMENTS=upper(Ip_Login_Name);

    rec_userext    user_ext%rowtype;

BEGIN

Select Count(*)
Into Found_Rec
From TABLE_User
Where S_LOGIN_NAME = upper(Ip_Login_Name);

If Found_Rec>0 Then
        select   objid into bobjid  From TABLE_User where S_LOGIN_NAME = upper(Ip_Login_Name);
        open user_ext(bobjid) ;
           fetch user_ext into rec_userext;
          if user_ext%notfound then
            Insert into table_user_extn (TABLE_USER_OBJID,AGENT_ROLE,SD_TKT,COMMENTS)
             values (bobjid, ip_ROLE, '999999', Ip_Login_Name);
           commit;
              Op_Message:='Added role '||ip_role||' for existing TAS user '||Ip_Login_Name;
          else
              update table_user_extn set AGENT_ROLE =ip_role where TABLE_USER_OBJID =bobjid and  COMMENTS=upper(Ip_Login_Name);
              commit;
              Op_Message:='Role of existing B2B/B2C user '||Ip_Login_Name||' updated from '||rec_userext.AGENT_ROLE||' to '||ip_role;
        end if;

else


Open C1;
Fetch C1 Into R1;
If C1%Notfound Then
   Close C1;
   Op_Message :=  'Invalid Privilege Class -- '||Ip_Priviledge_Class ;
   Return;
Else
   Close C1;
end if;

Open c2;
fetch c2 into r2;
if c2%notfound then
   close c2;
   Op_Message := 'Invalid Security Group -- '||Ip_Sec_Grp_Name;
   return;
else
   V_SEC_GRP_OBJID:=r2.objid;
   close c2;
end if;


Select count(*)
Into Found_Rec
From Table_Privclass,Table_User
Where User_Access2privclass = Table_Privclass.Objid
And S_Login_Name In (Select User From Dual)
And Class_Name = 'System Administrator';

If Found_Rec=0 Then
   Op_Message:='Not a System Administrator, cannot create users';
   Return;
End If;


SELECT sa.seq('employee') into V_EMPLOYEE_OBJID FROM dual;
SELECT sa.seq('user') into V_USER_OBJID FROM dual;
Select sa.Seq('wipbin') Into V_Wipbin_Objid From Dual;
SELECT sa.seq('time_bomb') into V_TIME_BOMB_OBJID FROM dual;

--Insert new wipbin
--
insert into table_wipbin (objid,title, S_title,description,ranking_rule,icon_id,dialog_id,wipbin_owner2user)
values(V_Wipbin_Objid,'default','DEFAULT','','',0,375, V_USER_OBJID);

--
--insert new user
--
insert into table_user (objid,login_name, S_login_name,password,agent_id,status,equip_id,
CS_Lic,CSDE_Lic,CQ_Lic,passwd_chg,last_login,CLFO_Lic,cs_lic_type,cq_lic_type,
CSFTS_Lic,CSFTSDE_Lic,CQFTS_Lic,web_login,S_web_login,web_password,submitter_ind,
SFA_LIC,CCN_LIC,UNIV_LIC,NODE_ID,LOCALE,WIRELESS_EMAIL,ALT_LOGIN_NAME,
S_alt_login_name,user_default2wipbin,user_access2privclass,offline2privclass,USER2RC_CONFIG,dev, WEB_LAST_LOGIN, WEB_PASSWD_CHG)
 values(V_USER_OBJID,IP_LOGIN_NAME,upper(IP_LOGIN_NAME),
IP_DEFAULT_ENCODED_PASSWORD,'',1,'', TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
 TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
SYSDATE, SYSDATE,
 TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
0,0, TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),'','','Y2fEjdGT1W6nsLqtJbGUVeUp9e4=',0,
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
To_Date( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),'1',
0,'','','', V_WIPBIN_OBJID, r1.objid, 268435758,268436363,1,SYSDATE, SYSDATE);


--insert new employee
--
insert into table_employee (objid,first_name, S_first_name,last_name, S_last_name,mail_stop,phone,alt_phone,fax,beeper,e_mail,labor_rate,field_eng,acting_supvr,available,avail_note,
employee_no,normal_biz_high,normal_biz_mid,normal_biz_low,after_biz_high,after_biz_mid,after_biz_low,work_group,
wg_strt_date,site_strt_date,voice_mail_box,local_login,local_password,allow_proxy,printer,on_call_hw,on_call_sw,
case_threshold,title,salutation,x_q_maint,x_error_code_maint,x_select_trans_prof,x_update_set,x_order_types,
x_dashboard,x_allow_script,x_allow_roadside,employee2user,supp_person_off2site,emp_supvr2employee)
 values
(V_EMPLOYEE_OBJID,IP_FIRST_NAME,upper(IP_FIRST_NAME),
IP_LAST_NAME,upper(IP_LAST_NAME),
'','','','','',IP_EMAIL,0.000000,0,0,1,'',IP_EMPLOYEE_ID,'','','',IP_EMAIL,
IP_EMAIL,IP_EMAIL,IP_GROUP, TO_DATE( '1/1/1753 00:00:00' , 'MM/DD/YYYY HH24:MI:SS'),
 TO_DATE( '1/1/1753 00:00:00' , 'MM/DD/YYYY HH24:MI:SS'),
'','','',0,'',0,0,0,'','',0,0,0,0,0,0,0,0, V_USER_OBJID, IP_SITE_OBJID, 0);
--
-- insert new time_bomb (could be removed)
--

insert into table_time_bomb (
objid,title,escalate_time,end_time,focus_lowid,focus_type,suppl_info,time_period,flags,left_repeat,
report_title,property_set,users,creation_time) values(
V_TIME_BOMB_OBJID,
IP_LOGIN_NAME, TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),0,0,'',0,65540,0,'','','',sysdate);
--
-- Find Security Group OBJID
--

Insert Into Mtm_User125_X_Sec_Grp1
    (User2x_Sec_Grp, X_Sec_Grp2user)
    Values (V_User_Objid,V_Sec_Grp_Objid);

Commit;

Insert into table_user_extn (TABLE_USER_OBJID,AGENT_ROLE,SD_TKT,COMMENTS)
values (V_USER_OBJID,ip_ROLE,'999999',IP_LOGIN_NAME);
commit;
op_message:='B2C/B2B User Created -- '||Ip_Login_Name ||'|| Password abc123';

end if;
End;  ---end of create_user_b2b_b2c

 Procedure create_user_apex (
Ip_Priviledge_Class In Varchar2,
Ip_Sec_Grp_Name  In  varchar2,
Ip_Login_Name  In  Varchar2,
Ip_First_Name  In Varchar2,
Ip_Last_Name  In Varchar2,
Ip_Employee_Id  In  Varchar2,
Ip_Email In Varchar2,
OP_MESSAGE out varchar2)
AS


--DEFAULTS NO NEED TO CHANGE--
IP_DEFAULT_ENCODED_PASSWORD VARCHAR2(30):='[ScBhozpV1nkzzNPrE/';
IP_ADMIN_USER_OBJID NUMBER:=268435556;  --objid user attempting the creation of the account 'sa'
Ip_Site_Objid Number:=268435456;   --Default SITE OBJID
Ip_Group Varchar2(30):='Call Center';
Found_Rec Number;

V_Employee_Objid Number;
V_USER_OBJID number;
V_Wipbin_Objid Number;
V_Time_Bomb_Objid Number;
V_SEC_GRP_OBJID number;

cursor c1 is
Select * From Table_Privclass
Where  S_Class_Name = Upper(Ip_Priviledge_Class );

r1 c1%rowtype;

cursor c2 is
select * from table_x_sec_grp
where x_grp_name = Ip_Sec_Grp_Name;

R2 C2%Rowtype;
Sql_Stmt Varchar2(300);

BEGIN

Select Count(*)
Into Found_Rec
From TABLE_User
Where S_LOGIN_NAME = upper(Ip_Login_Name);

If Found_Rec>0 Then
   Op_Message:='User already exists';
   Return;
end if;

Open C1;
Fetch C1 Into R1;
If C1%Notfound Then
   Close C1;
   Op_Message :=  'Invalid Privilege Class -- '||Ip_Priviledge_Class ;
   Return;
Else
   Close C1;
end if;

Open c2;
fetch c2 into r2;
if c2%notfound then
   close c2;
   Op_Message := 'Invalid Security Group -- '||Ip_Sec_Grp_Name;
   return;
else
   V_SEC_GRP_OBJID:=r2.objid;
   close c2;
end if;


Select count(*)
Into Found_Rec
From Table_Privclass,Table_User
Where User_Access2privclass = Table_Privclass.Objid
And S_Login_Name In (Select User From Dual)
And Class_Name = 'System Administrator';

If Found_Rec=0 Then
   Op_Message:='Not a System Administrator, cannot create users';
   Return;
End If;


SELECT sa.seq('employee') into V_EMPLOYEE_OBJID FROM dual;
SELECT sa.seq('user') into V_USER_OBJID FROM dual;
Select sa.Seq('wipbin') Into V_Wipbin_Objid From Dual;
SELECT sa.seq('time_bomb') into V_TIME_BOMB_OBJID FROM dual;

--Insert new wipbin
--
insert into table_wipbin (objid,title, S_title,description,ranking_rule,icon_id,dialog_id,wipbin_owner2user)
values(V_Wipbin_Objid,'default','DEFAULT','','',0,375, V_USER_OBJID);

--
--insert new user
--
insert into table_user (objid,login_name, S_login_name,password,agent_id,status,equip_id,
CS_Lic,CSDE_Lic,CQ_Lic,passwd_chg,last_login,CLFO_Lic,cs_lic_type,cq_lic_type,
CSFTS_Lic,CSFTSDE_Lic,CQFTS_Lic,web_login,S_web_login,web_password,submitter_ind,
SFA_LIC,CCN_LIC,UNIV_LIC,NODE_ID,LOCALE,WIRELESS_EMAIL,ALT_LOGIN_NAME,
S_alt_login_name,user_default2wipbin,user_access2privclass,offline2privclass,USER2RC_CONFIG,dev, WEB_LAST_LOGIN, WEB_PASSWD_CHG)
 values(V_USER_OBJID,IP_LOGIN_NAME,upper(IP_LOGIN_NAME),
IP_DEFAULT_ENCODED_PASSWORD,'',1,'', TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
 TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
SYSDATE, SYSDATE,
 TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
0,0, TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),'','','Y2fEjdGT1W6nsLqtJbGUVeUp9e4=',0,
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
To_Date( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),'1',
0,'','','', V_WIPBIN_OBJID, r1.objid, 268435758,268436363,1,SYSDATE, SYSDATE);


--insert new employee
--
insert into table_employee (objid,first_name, S_first_name,last_name, S_last_name,mail_stop,phone,alt_phone,fax,beeper,e_mail,labor_rate,field_eng,acting_supvr,available,avail_note,
employee_no,normal_biz_high,normal_biz_mid,normal_biz_low,after_biz_high,after_biz_mid,after_biz_low,work_group,
wg_strt_date,site_strt_date,voice_mail_box,local_login,local_password,allow_proxy,printer,on_call_hw,on_call_sw,
case_threshold,title,salutation,x_q_maint,x_error_code_maint,x_select_trans_prof,x_update_set,x_order_types,
x_dashboard,x_allow_script,x_allow_roadside,employee2user,supp_person_off2site,emp_supvr2employee)
 values
(V_EMPLOYEE_OBJID,IP_FIRST_NAME,upper(IP_FIRST_NAME),
IP_LAST_NAME,upper(IP_LAST_NAME),
'','','','','',IP_EMAIL,0.000000,0,0,1,'',IP_EMPLOYEE_ID,'','','',IP_EMAIL,
IP_EMAIL,IP_EMAIL,IP_GROUP, TO_DATE( '1/1/1753 00:00:00' , 'MM/DD/YYYY HH24:MI:SS'),
 TO_DATE( '1/1/1753 00:00:00' , 'MM/DD/YYYY HH24:MI:SS'),
'','','',0,'',0,0,0,'','',0,0,0,0,0,0,0,0, V_USER_OBJID, IP_SITE_OBJID, 0);
--
-- insert new time_bomb (could be removed)
--

insert into table_time_bomb (
objid,title,escalate_time,end_time,focus_lowid,focus_type,suppl_info,time_period,flags,left_repeat,
report_title,property_set,users,creation_time) values(
V_TIME_BOMB_OBJID,
IP_LOGIN_NAME, TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),0,0,'',0,65540,0,'','','',sysdate);
--
-- Find Security Group OBJID
--

Insert Into Mtm_User125_X_Sec_Grp1
    (User2x_Sec_Grp, X_Sec_Grp2user)
    Values (V_User_Objid,V_Sec_Grp_Objid);

Commit;

op_message:='WEBCSR User Created -- '||Ip_Login_Name ||'|| Password abc123';

End ;---end of  create_user_apex
PROCEDURE RESET_USER_APEX (v_login varchar2) AS


   cursor tab
   is
   select objid,s_login_name
   from sa.table_user
   where  s_LOGIN_NAME = TRIM(UPPER(v_login));

   r_tab tab%ROWTYPE;

BEGIN
      OPEN tab;
      FETCH tab INTO r_tab;
      IF tab%FOUND THEN
        update sa.table_user
        set
                LAST_LOGIN=sysdate,
                PASSWD_CHG=sysdate ,
                WEB_LAST_LOGIN=sysdate,
                WEB_PASSWD_CHG=sysdate,
                WEB_PASSWORD = 'Y2fEjdGT1W6nsLqtJbGUVeUp9e4='
           where s_LOGIN_NAME = TRIM(UPPER(v_login));

       DBMS_OUTPUT.put_line('Apex User '||v_login||' Updated');
    else
       DBMS_OUTPUT.put_line('******************************');
       DBMS_OUTPUT.put_line('Apex User '||v_login||' Not Found');
       END IF;
       close tab;

end;
Procedure Create_User_udp(
P_Fname In Varchar2,
p_lastname in varchar2,
p_email in varchar2,
p_role in varchar2,
OP_MESSAGE out varchar2)

AS
  v_employee_no varchar2(20);
  v_password varchar2(10);
  v_message varchar2(100);

begin

  sa.create_modify_smob_user(
      p_email
     ,'sa@mtsint.com'
     ,upper(p_role)
     ,P_Fname
     ,p_lastname
     ,'THE KID SHOP INTERAC'
     ,''
     ,''
     ,null
     ,''
     ,''
     ,''
     ,null
     ,null
     ,null
     ,v_employee_no
     ,v_password
     ,v_message
    ,'' );

    op_message:='Success';

commit;

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
       where s_login_name=upper(p_email);

       if p_role='MASTER_AGENT' THEN
        update table_employee set supp_person_off2site=(select site_objid from  SMOB_USERS_V where role='MASTER_AGENT'  and staTus='ACTIVE' AND epay_last_update is not null and nvl(site_objid,0)>0 and rownum<2)
                    where  OBJID = (select e.objid from TABLE_EMPLOYEE E, TABLE_USER U
                            where U.OBJID = E.EMPLOYEE2USER
                            and U.s_login_name=upper(p_email));
         UPDATE x_dealer_commissions SET prov_cust_status ='NEW',
          prov_cust_last_update =SYSDATE - 100 WHERE signup_id=p_email;
       commit;
       END IF;

        if p_role='DEALER' THEN
         UPDATE x_dealer_commissions SET prov_cust_status ='NEW',
          prov_cust_last_update =SYSDATE - 100 WHERE signup_id=p_email;
       commit;
       END IF;
         if p_role='RETAILER' THEN
        update table_employee set supp_person_off2site=(select objid from table_site where type=3 and s_name = 'WALMART.COM')
              where  OBJID = (select e.objid from TABLE_EMPLOYEE E, TABLE_USER U
                            where U.OBJID = E.EMPLOYEE2USER
                            and U.s_login_name=upper(p_email) );
       commit;
       END IF;

              if p_role='REP' THEN
         UPDATE x_dealer_commissions SET prov_cust_status ='NEW',
          prov_cust_last_update =SYSDATE - 100 WHERE signup_id=p_email;
       commit;
       END IF;
 commit;
  end;

Procedure Void_batch  is

CURSOR C_BATCH_ID IS
   SELECT X_BATCH_ID
      FROM X_PROGRAM_BATCH
     WHERE  BATCH_STATUS NOT IN('PROCESSED','Marked_FAILED_BY_DBAE')
   AND    BATCH_SUB_DATE > SYSDATE-2;

REC_BATCH C_BATCH_ID%ROWTYPE;

    V_BAT_ID NUMBER;
    PESN VARCHAR2(100);
    RECCOUNT NUMBER;

    CURSOR PURCH (BATCHID  NUMBER) IS
    SELECT PD.OBJID, PD.X_ESN
    FROM X_PROGRAM_PURCH_DTL PD,X_PROGRAM_PURCH_HDR PR
    WHERE  PD.PGM_PURCH_DTL2PROG_HDR = PR.OBJID
    AND PR.PROG_HDR2PROG_BATCH=BATCHID
    AND PR.X_PAYMENT_TYPE = 'RECURRING'
    AND PR.X_STATUS <>'PROCESSED';

    purch_rec purch%rowtype;

    CURSOR SP(VESN VARCHAR2) IS
      SELECT OBJID,X_EXPIRE_DT
      FROM TABLE_SITE_PART
      WHERE X_SERVICE_ID =VESN
      AND PART_STATUS     = 'ACTIVE'
        AND X_EXPIRE_DT > SYSDATE;

   SPREC   SP%ROWTYPE;
    no_inpd number;
 BEGIN
              FOR REC_BATCH IN C_BATCH_ID LOOP
                   V_BAT_ID:=REC_BATCH.X_BATCH_ID;
             OPEN PURCH(V_BAT_ID);
                 no_inpd :=purch%ROWCOUNT;
            close PURCH;

             for purch_rec in purch(V_BAT_ID) loop

                    DELETE FROM X_PROGRAM_PURCH_DTL
                        WHERE OBJID = PURCH_REC.OBJID;
                    commit;
       ---------    UPDATE site_part if expire date is in future
                           OPEN SP(PURCH_REC.X_ESN);
                                FETCH SP INTO SPREC;
                                   IF SP%FOUND THEN
                                        UPDATE TABLE_SITE_PART
                                            SET X_EXPIRE_DT = SYSDATE -2
                                            WHERE X_SERVICE_ID= PURCH_REC.X_ESN
                                            AND PART_STATUS     = 'Active'
                                            AND X_EXPIRE_DT > SYSDATE
                                            AND OBJID=SPREC.OBJID;
                                     COMMIT;
                                    END IF;
                            CLOSE SP;
                    END LOOP;

            DELETE FROM X_PROGRAM_PURCH_HDR HD
              WHERE  PROG_HDR2PROG_BATCH = V_BAT_ID
               AND HD.X_PAYMENT_TYPE = 'RECURRING'
               AND HD.X_STATUS <>'PROCESSED';
            COMMIT;

                 UPDATE X_PROGRAM_BATCH
                     SET BATCH_STATUS =  'Marked_FAILED_BY_DBAE'
                     WHERE X_BATCH_ID=V_BAT_ID;
                 COMMIT;

        end loop;

          if c_batch_id%isopen then
                 close c_batch_id;
            end if;
end;  --end void batch
Procedure Void_batch_Ndays(numday number)  is

CURSOR C_BATCH_ID IS
   SELECT X_BATCH_ID
      FROM X_PROGRAM_BATCH
     WHERE  BATCH_STATUS NOT IN('PROCESSED','Marked_FAILED_BY_DBAE')
   AND    BATCH_SUB_DATE > SYSDATE-numday;

REC_BATCH C_BATCH_ID%ROWTYPE;

    V_BAT_ID NUMBER;
    PESN VARCHAR2(100);
    RECCOUNT NUMBER;

    CURSOR PURCH (BATCHID  NUMBER) IS
    SELECT PD.OBJID, PD.X_ESN
    FROM X_PROGRAM_PURCH_DTL PD,X_PROGRAM_PURCH_HDR PR
    WHERE  PD.PGM_PURCH_DTL2PROG_HDR = PR.OBJID
    AND PR.PROG_HDR2PROG_BATCH=BATCHID
    AND PR.X_PAYMENT_TYPE = 'RECURRING'
    AND PR.X_STATUS <>'PROCESSED';

    purch_rec purch%rowtype;

    CURSOR SP(VESN VARCHAR2) IS
      SELECT OBJID,X_EXPIRE_DT
      FROM TABLE_SITE_PART
      WHERE X_SERVICE_ID =VESN
      AND PART_STATUS     = 'ACTIVE'
        AND X_EXPIRE_DT > SYSDATE;

   SPREC   SP%ROWTYPE;
    no_inpd number;
 BEGIN
              FOR REC_BATCH IN C_BATCH_ID LOOP
                   V_BAT_ID:=REC_BATCH.X_BATCH_ID;
             OPEN PURCH(V_BAT_ID);
                 no_inpd :=purch%ROWCOUNT;
            close PURCH;

             for purch_rec in purch(V_BAT_ID) loop

                    DELETE FROM X_PROGRAM_PURCH_DTL
                        WHERE OBJID = PURCH_REC.OBJID;
                    commit;
       ---------    UPDATE site_part if expire date is in future
                           OPEN SP(PURCH_REC.X_ESN);
                                FETCH SP INTO SPREC;
                                   IF SP%FOUND THEN
                                        UPDATE TABLE_SITE_PART
                                            SET X_EXPIRE_DT = SYSDATE -2
                                            WHERE X_SERVICE_ID= PURCH_REC.X_ESN
                                            AND PART_STATUS     = 'Active'
                                            AND X_EXPIRE_DT > SYSDATE
                                            AND OBJID=SPREC.OBJID;
                                     COMMIT;
                                    END IF;
                            CLOSE SP;
                    END LOOP;

            DELETE FROM X_PROGRAM_PURCH_HDR HD
              WHERE  PROG_HDR2PROG_BATCH = V_BAT_ID
               AND HD.X_PAYMENT_TYPE = 'RECURRING'
               AND HD.X_STATUS <>'PROCESSED';
            COMMIT;

                 UPDATE X_PROGRAM_BATCH
                     SET BATCH_STATUS =  'Marked_FAILED_BY_DBAE'
                     WHERE X_BATCH_ID=V_BAT_ID;
                 COMMIT;

        end loop;

          if c_batch_id%isopen then
                 close c_batch_id;
            end if;
end;  ---end Void_batch_Ndays
procedure Delete_Promo(prom_obj number) is
begin
            DELETE FROM TABLE_X_PROMOTION
            where  objid =prom_obj;
            commit;

            DELETE FROM TABLE_X_PROMOTION_MTM
           where x_promo_mtm2x_promotion =prom_obj;
           commit;

           DELETE FROM X_enroll_promo_extra
            where Promo_objid =prom_obj ;


            DELETE FROM x_enroll_promo_rule
          where PROMO_OBJID=prom_obj ;
    end;

Procedure Add_Promo(v_promo_code varchar2) as
grp_name varchar2(30);
cursor cur_promo is
    select *
    from table_x_promotion@read_rtrp
    where x_promo_code =v_promo_code;
    prec cur_promo%rowtype;
             prom_obj number;
    locl_obj number;
   cursor promo_grp (prog_obj number) is
     SELECT pg.*
FROM table_x_promotion_mtm@read_rtrp ,
     table_x_promotion@read_rtrp  xp,
     table_x_promotion_group@read_rtrp  pg
WHERE X_PROMO_MTM2X_PROMO_GROUP = pg.objid
  AND X_PROMO_MTM2X_PROMOTION   = xp.objid
  AND X_PROMO_CODE  =v_promo_code;

     grpRec promo_grp%rowtype;

pp_cnt number;
lp_cnt number;
 begin
         open cur_promo;
         fetch cur_promo into prec;
    prom_obj:=prec.objid;

    select  count(*) into lp_cnt  from table_x_promotion
    where x_promo_code =v_promo_code;
            if lp_cnt>0 then
                select  nvl(objid,0) into locl_obj  from table_x_promotion
               where x_promo_code =v_promo_code;
                sa.DBA_UTIL_PKG.Delete_Promo(locl_obj);
                end if;
                sa.DBA_UTIL_PKG.Delete_Promo(prec.objid);
                dbms_output.put_line('inserting promo '||v_promo_code);


            insert into TABLE_X_PROMOTION
            ( OBJID, X_PROMO_CODE, X_PROMO_TYPE, X_DOLLAR_RETAIL_COST,
                     X_START_DATE, X_END_DATE, X_UNITS, X_ACCESS_DAYS, X_IS_DEFAULT, X_SQL_STATEMENT,
                     X_REVENUE_TYPE, X_DEFAULT_TYPE, X_REDEEMABLE, X_PROMO_TECHNOLOGY, X_SPANISH_PROMO_TEXT,
                     X_USAGE, X_DISCOUNT_AMOUNT, X_DISCOUNT_PERCENT, X_SOURCE_SYSTEM, X_TRANSACTION_TYPE,
                     X_ZIP_REQUIRED, X_PROMO_DESC, X_AMIGO_ALLOWED, X_PROGRAM_TYPE, X_SHIP_START_DATE,
                     X_SHIP_END_DATE, X_REFURBISHED_ALLOWED, X_SPANISH_SHORT_TEXT, X_ENGLISH_SHORT_TEXT,
                     X_ALLOW_STACKING, X_UNITS_FILTER, X_ACCESS_DAYS_FILTER, X_PROMO_CODE_FILTER, X_GROUP_NAME_FILTER,
                     PROMOTION2BUS_ORG)
                values( prec.OBJID,  prec.X_PROMO_CODE, prec.X_PROMO_TYPE, prec.X_DOLLAR_RETAIL_COST, prec.X_START_DATE,
                 prec.X_END_DATE, prec.X_UNITS, prec.X_ACCESS_DAYS, prec.X_IS_DEFAULT, prec.X_SQL_STATEMENT,
                 prec.X_REVENUE_TYPE,  prec.X_DEFAULT_TYPE, prec.X_REDEEMABLE,  prec.X_PROMO_TECHNOLOGY,
                 prec.X_SPANISH_PROMO_TEXT, prec.X_USAGE, prec. X_DISCOUNT_AMOUNT, prec.X_DISCOUNT_PERCENT,
                 prec.X_SOURCE_SYSTEM, prec.X_TRANSACTION_TYPE, prec.X_ZIP_REQUIRED, prec.X_PROMO_DESC,
                 prec.X_AMIGO_ALLOWED, prec.X_PROGRAM_TYPE, prec.X_SHIP_START_DATE, prec.X_SHIP_END_DATE,
                 prec.X_REFURBISHED_ALLOWED,  prec.X_SPANISH_SHORT_TEXT, prec.X_ENGLISH_SHORT_TEXT,
                 prec.X_ALLOW_STACKING,  prec.X_UNITS_FILTER, prec.X_ACCESS_DAYS_FILTER, prec.X_PROMO_CODE_FILTER, prec.X_GROUP_NAME_FILTER,
                  prec.PROMOTION2BUS_ORG);
               commit;
                    update table_x_promotion
                    set  X_PROMOTION_TEXT = prec.X_PROMOTION_TEXT
                    where x_promo_code= v_promo_code;
                    commit;
      
    
                select count(*)  into pp_cnt  from sa.X_MTM_PART_NUM2PROG_PARAMETERS@read_rtrp
            where  x_promo_code = v_promo_code;
            if pp_cnt >0 then
                    delete   from sa.X_MTM_PART_NUM2PROG_PARAMETERS where x_promo_code=v_promo_code;
                     insert into  X_MTM_PART_NUM2PROG_PARAMETERS
            select * from sa.X_MTM_PART_NUM2PROG_PARAMETERS@read_rtrp
            where  x_promo_code = v_promo_code;
               commit;

end if;

       insert into  TABLE_X_PROMOTION_MTM
          select * from TABLE_X_PROMOTION_MTM@read_rtrp
        where x_promo_mtm2x_promotion =prec.objid;
        commit;
            insert into  X_enroll_promo_extra
            select * from X_enroll_promo_extra@read_rtrp
            where Promo_objid =prec.objid ;
            commit;

         insert into x_enroll_promo_rule
            select * from x_enroll_promo_rule@read_rtrp
            where PROMO_OBJID =prec.objid;
            commit;


                  open promo_grp(prec.objid);
                  fetch promo_grp into grpRec;
                 if promo_grp%found then
                                DELETE FROM TABLE_X_PROMOTION_GROUP
                                WHERE  GROUP_NAME = grpRec.GROUP_NAME
                                OR objid=grpRec.objid;
                               commit;
                        --grpRec
                            insert into table_x_promotion_group(objid, group_name, group_desc, x_start_date, X_END_DATE,PROMO_GROUP2X_PROMO,
                                    X_MAX_COUNT,X_CURRENT_COUNT,X_MULTIPLIER,X_STACK_MULTIPLIER)
                            values ( grpRec.objid, grpRec.group_name, grpRec.group_desc, grpRec.x_start_date,grpRec.X_END_DATE,grpRec.PROMO_GROUP2X_PROMO,
                            grpRec.X_MAX_COUNT,grpRec.X_CURRENT_COUNT,grpRec.X_MULTIPLIER,grpRec.X_STACK_MULTIPLIER);
                          commit;
                             update table_x_promotion_group
                             set  X_FLASH_TEXT=grpRec.X_FLASH_TEXT
                                WHERE  GROUP_NAME =grpRec.GROUP_NAME;
                            commit;
   end if;
                    close promo_grp;
 close cur_promo;
   end;

end;  ---end of package
/