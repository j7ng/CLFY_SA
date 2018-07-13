CREATE OR REPLACE TYPE sa."ORG_TYPE_REC" IS Object (
    Org_Name           Varchar2(80), --- TABLE_SITE.S_NAME%type,
    Org_Type           Varchar2(4) , --- table_site.type%TYPE,  --b2b
    Cust_Id            VARCHAR2(40),  --table_site.x_fin_cust_id%TYPE,
    Cust_Acct_Number   VARCHAR2(20), ---x_posa_flag_dealer.acct#%TYPE,
    Commerce_Id        VARCHAR2(150) ,--  table_site.x_commerce_id%TYPE,
    Parent_Commerce_Id VARCHAR2(150) ,-- table_site.x_commerce_id%TYPE,
    Ship_Loc_Id        NUMBER ,       --   table_site.x_ship_loc_id%TYPE,
    PARENT_SHIP_LOC_ID NUMBER ,       --  TABLE_SITE.X_SHIP_LOC_ID%TYPE,
    Is_Posa            VARCHAR2(150), -- ASK? data size?
    Tax_Id             VARCHAR2(40) , --   x_business_accounts.sales_tax_id%TYPE  DEFAULT NULL,
    duns               NUMBER ,
    Bill_To address_type_rec,
    Ship_To address_type_rec,
    ------------  FUNCTIONS ------------
    member function orgexists(op_site_objid out number) return boolean,
    member function createorg(ip_parent_site_objid number,
                          ip_site_type in varchar2,
                          ip_billaddr_objid in number,
                          ip_shipaddr_objid in number,
                          op_org_objid out number,
                          err_loc out varchar2,
                          err_num out number,
                          err_msg out varchar2) return boolean,
    member function updateOrg(ip_site_type varchar2,
                          ip_site_id varchar2,
                          ip_parent_objid number,
                          ip_upd_inv_tbls boolean,
                          err_num out number,
                          err_msg out varchar2)return boolean,
    member function deleteorg(in_commerce_id in varchar2, err_num out number,err_msg out varchar2)return boolean,
    constructor function org_type_rec return self as result
)
/
CREATE OR REPLACE TYPE BODY sa."ORG_TYPE_REC" is
member function orgexists(op_site_objid out number) return boolean is
begin
   select objid
   into op_site_objid
   from table_site
   where 1=1
   -- and x_fin_cust_id = self.cust_id
   and x_commerce_id   = self.commerce_id;
   --and x_ship_loc_id   = self.ship_loc_id;

   return true;
exception
  when no_data_found then
    return false;
  when others then
    op_site_objid := -1;
    return false;
end;
member function createorg(ip_parent_site_objid number,
                          ip_site_type in varchar2,
                          ip_billaddr_objid in number,
                          ip_shipaddr_objid in number,
                          op_org_objid out number,
                          err_loc out varchar2,
                          err_num out number,
                          err_msg out varchar2) return boolean is
  v_site_id table_site.site_id%type;
  v_site_objid table_site.objid%type;
  v_invloc_objid table_inv_locatn.objid%type;
  v_invrole_objid table_inv_role.objid%type;
  v_invbin_objid table_inv_bin.objid%type;

    function insert_inv_bin(ip_site_id varchar2, ip_invloc_objid number,
                      op_invbin_objid out number,err_num out number,
                      err_msg out varchar2) return boolean is
    begin
        dbms_output.put_line('Inserting -'||op_invbin_objid||' '||ip_site_id);
        INSERT INTO table_inv_bin
          ( objid,
            active,
            bin_name,
            location_name,
            inv_bin2inv_locatn)
          VALUES
          ( sequ_inv_bin.nextval,
            1,
            ip_site_id,
            ip_site_id,
            ip_invloc_objid)returning objid into op_invbin_objid;
        return true;
    exception
        when others then
        err_num := sqlcode;
        err_MSG := sqlerrm;
        return false;
    end;
    function insert_inv_role(ip_site_objid number,ip_invloc_objid in number,
                             op_invrole_Objid out number,err_num out number,
                             err_msg out varchar2) return boolean is
    begin

        dbms_output.put_line('Inserting -'||op_invrole_objid||' '||ip_site_objid);
        INSERT INTO table_inv_role
          ( objid,
            active,
            focus_type,
            inv_role2site,
            inv_role2inv_locatn,
            role_name)
          VALUES
          ( sequ_inv_role.nextval,
            1,
            228,
            ip_site_objid,
            ip_invloc_objid,
            'Located at') returning objid into op_invrole_objid;
        return true;
    exception
      when others then
        err_num := sqlcode;
        err_MSG := sqlerrm;
        return false;
    end;
    function insert_inv_location(ip_site_id in varchar2,
                            ip_site_objid in number,
                            op_invloc_objid out number,
                            err_num out number,
                            err_msg out varchar2) return boolean
    is
    begin
         INSERT INTO table_inv_locatn
          ( objid,
            active,
            location_type,
            location_name,
            inv_locatn2site)
          VALUES
          ( sequ_inv_locatn.nextval,
            1,
            'Inventory Location',
            ip_site_id,
            ip_site_objid) returning objid into op_invloc_objid;
        return true;
    exception
     when others then
        err_num := sqlcode;
        err_MSG := sqlerrm;
        return false;
    end;
    function insert_site(ip_parent_site_objid IN number,
                         ip_site_type in varchar2,
                         ip_billaddr_objid in number,
                         ip_shipaddr_objid in number,
                         op_site_id out varchar2,
                         op_site_objid out number,
                         err_num out number,
                         err_msg out varchar2 ) return boolean is
    begin
       INSERT INTO table_site
          ( objid,
            site_id,
            name,
            s_name,
            type,
            is_default,
            appl_type,
            site_type,
            status,
            dev,
            child_site2site,
            cust_primaddr2address,
            cust_billaddr2address,
            cust_shipaddr2address,
            x_smp_optional,
            update_stamp,
            x_fin_cust_id,
            x_commerce_id,
            x_ship_loc_id)
          VALUES (
            sa.sequ_site.NEXTVAL,
            ip_site_type||seq_site_id.NEXTVAL,
            self.org_name,
            UPPER(self.org_name),
            3,
            NULL,
            self.org_type, -- B2B
            ip_site_type,
            0,
            NULL,
            ip_parent_site_objid,
            ip_shipaddr_objid,
            ip_billaddr_objid,
            ip_shipaddr_objid,
            1,
            SYSDATE,
            self.cust_id,
            self.commerce_id,
            self.ship_loc_id
          ) returning objid,site_id into op_site_objid,op_site_id;
       return true;
    exception
      when others then
        err_num := sqlcode;
        err_MSG := sqlerrm;
       return false;
    end;
begin --createorg Main/main/MAIN
   --dbms_output.put_line('Insert table_site');
   if not  insert_site(ip_parent_site_objid, ip_site_type, ip_billaddr_objid,
                      ip_shipaddr_objid,v_site_id, v_site_objid, err_num,err_msg) then
       err_loc := 'Inserting site';
       return false;
   end if;
   op_org_objid := v_site_objid;
   --dbms_output.put_line('Insert table_inv_location');
   if not  insert_inv_location(v_site_ID, v_site_objid,v_invloc_objid,err_num,err_msg) then
       err_loc := 'Inserting inv_location';
       return false;
   end if;
   ----dbms_output.put_line('Insert table_inv_role');
   if not  insert_inv_role(v_site_objid,v_invloc_objid,v_invrole_objid,err_num,err_msg) then
       err_loc := 'Inserting role';
       return false ;
   end if;
   --dbms_output.put_line('Insert table_inv_bin');
   if not  insert_inv_bin(v_site_id,v_invloc_objid,v_invbin_objid,err_num,err_msg) then
       err_loc := 'Inserting inv_bin';
       return false ;
   end if;
   --dbms_output.put_line('returning from create');
   return true;
exception
  when others then
      err_loc := 'createorg Main';
      err_num := sqlcode;
      err_msg := sqlerrm;
   return false;
end;

member function updateOrg( ip_site_type varchar2,
                           ip_site_id varchar2 ,
                           ip_parent_objid number,
                           ip_upd_inv_tbls boolean,
                           err_num out number,
                           err_msg out varchar2)
return boolean is
v_org_site_objid number;
v_billaddr_objid number := 0;
v_shipaddr_objid number:= 0;
dummy_bool boolean;

old_site_id table_site.site_id%type;
begin
  if not self.orgexists(v_org_site_objid) then
    err_msg := 'Organization does not exist';
    return false;
  end if;
  begin
     select site_id
     into  old_site_id
     from table_site
     where objid = v_org_site_objid;
  exception
  when others then
    return false;
  end;

   if not self.bill_to.is_null then
        dummy_bool := self.bill_to.write2db(v_billaddr_objid);
   end if;
   if not self.ship_to.is_null then
        dummy_bool := self.ship_to.write2db(v_shipaddr_objid);
   end if;

  UPDATE table_site
  SET NAME          = NVL(self.org_name, NAME),
    s_name          = NVL(UPPER(self.org_name), s_name),
    site_type       = NVL(ip_site_type, site_type),
    site_id         = NVL(ip_site_id, site_id),
    child_site2site = NVL(ip_parent_objid, child_site2site),
    appl_type       = NVL(self.org_type, appl_type),
    x_fin_cust_id   = NVL(self.cust_id, x_fin_cust_id),
    x_commerce_id   = NVL(self.commerce_id, x_commerce_id),
    x_ship_loc_id   = NVL(self.ship_loc_id, x_ship_loc_id),
    cust_billaddr2address = decode(v_billaddr_Objid,0,cust_billaddr2address,v_billaddr_Objid),
    cust_shipaddr2address = decode(v_shipaddr_objid,0,cust_shipaddr2address,v_shipaddr_objid)
  WHERE objid = v_org_site_objid;

  if (sql%rowcount > 0 and ip_upd_inv_tbls ) then
      UPDATE table_inv_bin
      SET bin_name      = ip_site_id,
        location_name   = ip_site_id
      WHERE bin_name    = old_site_id
      AND location_name = old_site_id;
    --
    -- No site_id in table_inv_role
    --
      UPDATE table_inv_locatn
      SET location_name     = ip_site_id
      WHERE inv_locatn2site = v_org_site_objid
      AND location_name     = old_site_id;
  end if;
   return true;
exception
  when others then
   err_num := sqlcode;
   err_msg := sqlerrm;
end;
member function deleteorg(in_commerce_id in varchar2, err_num out number,err_msg out varchar2)return boolean is
v_org_site_objid number;
begin
if not self.orgexists(v_org_site_objid) then
    err_msg := 'Organization does not exist';
    return false;
end if;
  update x_site_web_accounts
  set site_web_acct2web_user =  null
  where site_web_acct2site = v_org_site_objid;
return true;
exception
when others then
   err_num := sqlcode;
   err_msg := sqlerrm;
  return false;
end;
constructor function org_type_rec return self as result is
begin
  return;
end;
end; --
/