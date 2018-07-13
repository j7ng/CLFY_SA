CREATE OR REPLACE TRIGGER sa."EXPRESS_CONSENT_TRG"
BEFORE INSERT OR UPDATE
ON sa.X_EXPRESS_CONSENT
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE

-----cr12241
     cursor get_contact is
    select *
      from sa.TABLE_CONTACT tc
     where tc.X_CUST_ID = :NEW.X_CUST_ID;
  contactrec  get_contact%rowtype;

   cursor SLESN is
     SELECT 1 FROM X_PROGRAM_PARAMETERS PP,
        X_PROGRAM_ENROLLED PE
        WHERE PE.X_ESN=:NEW.ESN
        AND PE.X_ENROLLMENT_STATUS='ENROLLED'
        AND PP.X_PROG_CLASS='LIFELINE'
        AND PE.PGM_ENROLL2PGM_PARAMETER = PP.OBJID;
        SLREC   SLESN%rowtype;

     cursor prim_addr_curs(c_contact_objid in number) is
    select s.CUST_PRIMADDR2ADDRESS
      from table_site s,
           table_contact_role cr
       where 1=1
       and s.objid = cr.CONTACT_ROLE2SITE
       and cr.CONTACT_ROLE2CONTACT = c_contact_objid;

       prim_addr_rec prim_addr_curs%rowtype;
     ---CR12241
  begin

       :new.first_name := upper(:new.first_name);
       :new.last_name := upper(:new.last_name);

   if nvl(:new.source,'x') <> 'CLARIFY' then

     if :new.prerecorded_consent = 0 then
         update sa.table_x_contact_add_info
         set x_prerecorded_consent=0
         where add_info2contact in (select objid from sa.table_contact
                                  where table_contact.phone = :new.phone_number);
       end if;
      if :new.prerecorded_consent = 1 then
          update sa.table_x_contact_add_info
          set x_prerecorded_consent=1
         where add_info2contact in (select objid from sa.table_contact
                            where table_contact.phone = :new.phone_number);
        ---CR12667
             /* and table_contact.s_first_name = :new.first_name
             and table_contact.s_last_name = :new.last_name);*/ ---CR12667
       end if;

  ---CR12241
      if ( :new.x_cust_id is null)  or (:NEW.ESN is null )THEN
        return;
      end if;
       open get_contact;
         fetch get_contact into contactrec;
         if get_contact%notfound then
             close get_contact;
             return;
          end if;
     close get_contact;

      open SLesn;
          fetch SLesn into SLrec;
             if SLesn%found then
               UPDATE sa.TABLE_CONTACT TC
                SET TC.PHONE = nvl(ltrim(rtrim(:NEW.PHONE_NUMBER)),PHONE),
                    TC.E_MAIL  = nvl(ltrim(rtrim(:NEW.EMAIL)),E_MAIL)
                 WHERE tc.X_CUST_ID = :new.x_cust_id;
               close SLesn;
              return;
         else  --------not a life line


 ----update contact_table
   if :new.ADDRESS_1 is not null or :new.ADDRESS_2 is not null then
          if  (:NEW.CITY  is  not null) and (:NEW.STATE is not null) and
          (:NEW.ZIPCODE is not null)
          then
              DBMS_OUTPUT.PUT_LINE('Updating Address and Contact Tables ');
              UPDATE sa.TABLE_CONTACT TC
              SET TC.ADDRESS_1 = :NEW.ADDRESS_1,
                    TC.ADDRESS_2 = :NEW.ADDRESS_2,
                    TC.CITY = :NEW.CITY,
                    TC.STATE = :NEW.STATE,
                    TC.ZIPCODE = :NEW.ZIPCODE,
                    TC.PHONE = nvl(ltrim(rtrim(:NEW.PHONE_NUMBER)),PHONE),
                    TC.E_MAIL  = nvl(ltrim(rtrim(:NEW.EMAIL)),E_MAIL)
              WHERE tc.X_CUST_ID = :new.x_cust_id;
 ---UPDATE ADDRESS TABLE
              open prim_addr_curs(contactrec.objid);
              fetch prim_addr_curs into prim_addr_rec;
              if prim_addr_curs%found and
                      prim_addr_rec.CUST_PRIMADDR2ADDRESS is not null then
                      UPDATE TABLE_ADDRESS ADDR
                      SET addr.ADDRESS= :NEW.ADDRESS_1,
                              S_ADDRESS =:NEW.ADDRESS_1 ,
                                CITY = :NEW.CITY,
                                S_CITY = :NEW.CITY,
                                STATE = :NEW.STATE,
                                S_STATE =:NEW.STATE,
                                ZIPCODE =:NEW.ZIPCODE,
                                 ADDRESS_2= :NEW.ADDRESS_2
                      where addr.objid= prim_addr_rec.CUST_PRIMADDR2ADDRESS;
              end if;
              close prim_addr_curs;

          else
              DBMS_OUTPUT.PUT_LINE('Not a complete address update phone and email only');
              UPDATE sa.TABLE_CONTACT TC
              SET TC.PHONE = nvl(ltrim(rtrim(:NEW.PHONE_NUMBER)),PHONE),
                  TC.E_MAIL  = nvl(ltrim(rtrim(:NEW.EMAIL)),E_MAIL)
              WHERE tc.X_CUST_ID = :new.x_cust_id;
          end if;
  else

      DBMS_OUTPUT.PUT_LINE('Both the Address fields are blank ');
  end if;
end if;

end if;
 ----CR12241
END;
/