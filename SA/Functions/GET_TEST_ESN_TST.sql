CREATE OR REPLACE function sa.get_test_esn_tst
                 (esn_part_number in varchar2)
                  return varchar2 is
cursor c1 is
select table_mod_level.objid,x_technology,X_PARAM_VALUE, upper(name) name
from table_part_num, table_mod_level,table_x_part_class_values, table_x_part_class_params,table_part_class pc
where part_number = esn_part_number
and part_info2part_num = table_part_num.objid
and value2part_class = part_num2part_class
and x_param_name = 'INITIAL_MOTRICITY_CONVERSION'
and value2class_param= table_x_part_class_params.objid
and part_num2part_class= pc.objid
and rownum < 2;
r1 c1%rowtype;
serial_no VARCHAR2(30);
piobjid number;
  new_hex_meid VARCHAR2(30) := NULL;
begin
   open c1;
   fetch c1 into r1;
   if c1%notfound then
      close c1;
      return 'Part not found';
   else
      close c1;
   end if;
   if r1.x_technology not in ('GSM','CDMA') then
      return 'Technology not valid';
   end if;
    if r1.x_technology = 'GSM' then
    SELECT to_char(GSM_SERIAL_NO)
    into serial_no
    FROM DUAL;
    if r1.name ='STAPI4C' or r1.name ='STAPI4SC' or r1.name ='STAPI5C'  then
        new_hex_meid :='9999'||substr(serial_no, -10);
        serial_no := TO_CHAR(hex2dec(new_hex_meid));
    end if;
  else
    SELECT to_char(CDMA_SERIAL_NO_SEQ.NEXTVAL)
    into serial_no
    FROM DUAL;
    if r1.name ='STAPI4C' or r1.name ='STAPI4SC' or r1.name ='STAPI5C'  then
        --serial_no :='9999'||substr(serial_no, -10);
        new_hex_meid :='9999'||substr(serial_no, -10);
        serial_no := TO_CHAR(hex2dec(new_hex_meid));
    end if;
   end if;
  select sa.seq('part_inst')
  into piobjid
  from dual;
    Insert into TABLE_PART_INST (OBJID,PART_GOOD_QTY,PART_BAD_QTY,PART_SERIAL_NO,PART_MOD,PART_BIN,LAST_PI_DATE,PI_TAG_NO,LAST_CYCLE_CT,NEXT_CYCLE_CT,LAST_MOD_TIME,LAST_TRANS_TIME,TRANSACTION_ID,DATE_IN_SERV,WARR_END_DATE,REPAIR_DATE,PART_STATUS,PICK_REQUEST,GOOD_RES_QTY,BAD_RES_QTY,DEV,X_INSERT_DATE,X_SEQUENCE,X_CREATION_DATE,X_PO_NUM,X_RED_CODE,X_DOMAIN,X_DEACTIVATION_FLAG,X_REACTIVATION_FLAG,X_COOL_END_DATE,
    X_PART_INST_STATUS,
    X_NPA,X_NXX,X_EXT,X_ORDER_NUMBER,PART_INST2INV_BIN,
    N_PART_INST2PART_MOD,
    FULFILL2DEMAND_DTL,PART_INST2X_PERS,PART_INST2X_NEW_PERS,PART_INST2CARRIER_MKT,CREATED_BY2USER,
    STATUS2X_CODE_TABLE,PART_TO_ESN2PART_INST,X_PART_INST2SITE_PART,X_LD_PROCESSED,DTL2PART_INST,
    ECO_NEW2PART_INST,HDR_IND,X_MSID,X_PART_INST2CONTACT,X_ICCID,X_CLEAR_TANK,X_PORT_IN,X_HEX_SERIAL_NO)
    values (piobjid,null,null,serial_no,null,null,to_timestamp('01-JAN-53','DD-MON-RR HH.MI.SSXFF AM'),
    null,to_timestamp('01-JAN-53','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('01-JAN-53','DD-MON-RR HH.MI.SSXFF AM'),
    to_timestamp('01-JAN-53','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('01-JAN-53','DD-MON-RR HH.MI.SSXFF AM'),null,
    to_timestamp('01-JAN-53','DD-MON-RR HH.MI.SSXFF AM'),null,to_timestamp('01-JAN-53','DD-MON-RR HH.MI.SSXFF AM'),'Active',null,null,null,null,to_timestamp('12-SEP-07','DD-MON-RR HH.MI.SSXFF AM'),0,
    to_timestamp('18-SEP-07','DD-MON-RR HH.MI.SSXFF AM'),null,null,'PHONES',null,0,null,
    '50', --status
    null,null,null,null,268486710,
    r1.objid, --mod_lebel
    null,null,null,null,268435857,
    986, --status
    null,null,null,null,null,null,null,null,null,0,null,new_hex_meid );
    Insert into TABLE_X_OTA_FEATURES (OBJID,DEV,X_REDEMPTION_MENU,X_HANDSET_LOCK,X_LOW_UNITS,X_OTA_FEATURES2PART_NUM,X_OTA_FEATURES2PART_INST,X_PSMS_DESTINATION_ADDR,X_ILD_ACCOUNT,X_ILD_CARR_STATUS,X_ILD_PROG_STATUS,X_ILD_COUNTER,X_CLOSE_COUNT,X_CURRENT_CONV_RATE,X_SPP_PIN_ON,X_BUY_AIRTIME_MENU,X_SPP_PROMO_CODE,CURRENT_CONFIG2X_DATA_CONFIG,NEW_CONFIG2X_DATA_CONFIG,X_DATA_CONFIG_PROG_COUNTER)
    values (sa.seq('x_ota_features'),null,'Y','Y','N',null,piobjid,'32275',null,'Inactive','Completed',null,0,r1.X_PARAM_VALUE,'Y','Y','Y',
   (select PART_NUM2X_DATA_CONFIG from table_part_num
                                   where part_number = esn_part_number
                                   and s_domain = 'PHONES'),
    null,null);
    commit;
insert into GW1.TEST_OTA_ESN       values(serial_no);
commit;
insert into sa.TEST_IGATE_ESN      values(serial_no,'H');
commit;
    return serial_no;
end;
/