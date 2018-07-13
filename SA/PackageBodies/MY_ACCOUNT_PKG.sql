CREATE OR REPLACE PACKAGE BODY sa."MY_ACCOUNT_PKG" as
function need_verification(p_esn in varchar2,p_xmin out varchar2 ) return varchar2 is
--Returns Y if need_verification and N if it doesn't.Returns N if already verified.
  ret number := 0;
begin
     begin
         select nvl(x_param_value,'N')
         into ret
         from table_x_parameters
         where x_param_name = 'PHONE_VERIFICATION_ON';
     exception
           when no_data_found then
            ret:= 'N';
     end;

     if  ret = 'Y' then
        -- Put all the conditions/queries to check if the phone needs verification
        -- in the block below
        begin
            select x_min
            into p_xmin
            from table_site_part sp,
                 table_part_inst pi
            where X_PART_INST2SITE_PART = sp.objid
            and part_serial_no = p_esn
            and x_part_inst_status = '52';
        exception
            when others then
              null;
        end;
    end if;
    return ret;
end;
function set_verified(p_esn in varchar2) return number is
--Returns 0 if successfully verified else 1
begin
  update table_x_contact_part_inst
  set x_verified = 'Y'
  where x_contact_part_inst2part_inst in
   (select pi.objid
    from table_part_inst pi
    where pi.part_serial_no = p_esn);
    if sql%rowcount = 0 then
        return 1;
    else
       return 0;
    end if;
exception
  when others then return 1;
end;
function unset_verified(p_esn in varchar2) return number is
begin
  update table_x_contact_part_inst
  set x_verified = 'N'
  where x_contact_part_inst2part_inst in
   (select pi.objid
    from table_part_inst pi
    where pi.part_serial_no = p_esn);
    if sql%rowcount = 0 then
       return 1;
    else
       return 0;
    end if;
exception
  when others then return 1;
end;
procedure get_account_info(p_restricted_use in number,
                           p_org_id in varchar2,
                           p_login_name in varchar2,
                           p_error out number,
                           result_set out sys_refcursor) is
tmp_x_min varchar2(30);
 tmp number;
begin
   for i in (select x_restricted_use,
                    part_serial_no,
                    conpi.x_verified,
                    nvl(sp.x_min,'T123') x_min,
                    pi.x_part_inst_status
             from table_part_inst pi,
                     table_x_contact_part_inst conpi,
                     table_bus_org bus,
                     table_web_user web,
                     table_site_part sp,
                     table_part_num pn,
                     table_mod_level ml
             where WEB.S_LOGIN_NAME = p_login_name
              AND pn.x_restricted_use = p_restricted_use
              AND bus.s_org_id = p_org_id
              AND PI.N_PART_INST2PART_MOD = ML.OBJID
              AND ML.PART_INFO2PART_NUM = PN.OBJID
              AND PI.OBJID(+) = CONPI.X_CONTACT_PART_INST2PART_INST
              AND PI.PART_SERIAL_NO = SP.X_SERVICE_ID
              AND CONPI.X_CONTACT_PART_INST2CONTACT(+) = WEB.WEB_USER2CONTACT
              AND WEB.WEB_USER2BUS_ORG = BUS.OBJID)

   loop
          if i.x_verified is null and i.x_part_inst_status = '52'
             and i.x_min not like 'T%' then
             if (need_verification(i.part_serial_no,tmp_x_min) = 'Y') then
                 p_error := unset_verified(i.part_serial_no);
             else
                 p_error := set_verified(i.part_serial_no);
             end if;
          end if;
   end loop;

   open result_set for SELECT
              WEB.OBJID,
              PI.PART_SERIAL_NO,
              CONPI.X_ESN_NICK_NAME,
              NVL(CONPI.X_IS_DEFAULT, 0),
              NVL(CONPI.X_TRANSFER_FLAG, 0),
              WEB.WEB_USER2CONTACT,
              PI.X_PART_INST2CONTACT,
              CODE.X_CODE_NAME,
              CODE.X_CODE_NUMBER,
              NVL(X_RESTRICTED_USE, 0),
              PI.X_PORT_IN,
              PC.NAME,
              CONPI.X_VERIFIED
            FROM
              TABLE_X_CODE_TABLE CODE,
              TABLE_PART_NUM PN,
              TABLE_MOD_LEVEL ML,
              TABLE_PART_INST PI,
              TABLE_X_CONTACT_PART_INST CONPI,
              TABLE_BUS_ORG BUS,
              TABLE_WEB_USER WEB,
              TABLE_PART_CLASS PC
            WHERE PN.X_RESTRICTED_USE = p_restricted_use
            AND PI.N_PART_INST2PART_MOD = ML.OBJID
            AND ML.PART_INFO2PART_NUM = PN.OBJID
            AND CODE.OBJID(+) = PI.STATUS2X_CODE_TABLE
            AND PI.OBJID(+) = CONPI.X_CONTACT_PART_INST2PART_INST
            AND WEB.WEB_USER2BUS_ORG = BUS.OBJID
            AND PN.PART_NUM2PART_CLASS = PC.OBJID
            AND BUS.S_ORG_ID = p_org_id
            AND CONPI.X_CONTACT_PART_INST2CONTACT(+) = WEB.WEB_USER2CONTACT
            AND WEB.S_LOGIN_NAME = p_login_name;


end;
end;
/