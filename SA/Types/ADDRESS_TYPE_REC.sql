CREATE OR REPLACE TYPE sa."ADDRESS_TYPE_REC" force Is Object
                 (Address_1 Varchar2(200),--- table_address.address%TYPE,
                  Address_2  Varchar2(200) ,--table_address.address_2%TYPE,
                  City       Varchar2(30)  ,--table_address.city%TYPE,
                 State      Varchar2(60)  ,--table_address.state%TYPE,
                  Country    Varchar2(300)  ,--Table_Country.S_Name%Type,
                  zipcode    VARCHAR2(60),-- table_address.zipcode%TYPE);
                  ---FUNCTIONS-----
                  map member function equals return raw,
                  constructor function address_type_rec return self as result,
                  member function write2db(out_address_objid out number) return boolean,
                  member function is_null return boolean,
                  member function print return varchar2 );
/
CREATE OR REPLACE TYPE BODY sa."ADDRESS_TYPE_REC" as
member function is_null return boolean is
begin
  if self.address_1 is null
     and self.address_2 is null
     and self.city is null
     and self.state is null
     and self.country is null
     and self.zipcode is null then
    return true;
  else
    return false;
  end if;
end;
member function write2db(out_address_objid out number) return boolean is
v_country_objid number;
v_state_objid number;
begin
    begin
      select objid
      into out_address_objid
      from table_address
      where s_address = upper(self.address_1)
      and s_city = upper(self.city)
      and s_state = upper(self.state)
      --CR47564 changes start
      and UPPER(NVL(address_2,'X')) = UPPER(NVL(self.address_2, 'X'))
      and NVL(zipcode, 'X') = NVL(self.zipcode, 'X');
      --CR47564 changes end;
      return true;
    exception
      when others then null;
    end;
    sp_seq('address', out_address_objid);
    begin
      SELECT objid
      into v_country_objid
      FROM table_country
      WHERE(s_name = UPPER(self.country)
      OR x_postal_code = UPPER(self.country));
    exception
      when others then
       v_country_objid := null;
    end;
    begin
      SELECT objid
      into v_state_objid
      FROM table_state_prov
      WHERE s_name   = UPPER(self.state)
      AND state_prov2country = v_country_objid;
    exception
      when others then
        v_state_objid := null;
    end;
    INSERT INTO table_address
    ( objid ,
      address ,
      s_address ,
      city ,
      s_city ,
      state ,
      s_state ,
      zipcode ,
      address_2 ,
      dev ,
      address2time_zone ,
      address2country ,
      address2state_prov ,
      update_stamp
    )
    VALUES
    ( out_address_objid ,
      self.address_1 ,
      UPPER(self.address_1) ,
      self.city ,
      UPPER(self.city) ,
      self.state ,
      UPPER(self.state) ,
      self.zipcode ,
      self.address_2 ,
      NULL ,
      NULL ,
      v_country_objid ,
      v_state_objid ,
      SYSDATE );
  return true;
exception
   when others then
    return false;
end;
map member function equals return raw is
begin
  return dbms_crypto.hash(
           utl_raw.cast_to_raw(nvl(self.address_1,'***')||
                                        nvl(self.address_2,'***')||
                                         nvl(self.city,'***')||
                                         nvl(self.city,'***')||
                                         nvl(self.state,'***')||
                                         nvl(self.country,'***')||
                                         nvl(self.zipcode,'***')
                                       )
                                  , 1);
end equals;
constructor function address_type_rec return self as result is
begin
return;
end address_type_rec;
member function  print return varchar2 is
begin
  return ('address_type_rec(address_1 =>'''||self.address_1||''','||
          'address_2 =>'''||self.address_2||''','||
          'city =>'''||self.city||''','||
          'state =>'''||self.state||''','||
          'zipcode =>'''||self.zipcode||''')');
end print;
end;
/