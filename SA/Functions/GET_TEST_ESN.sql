CREATE OR REPLACE FUNCTION sa.GET_TEST_ESN
                 (esn_part_number in varchar2)
                  return varchar2 is
cursor c is
   SELECT name from v$database;
   v_name c%rowtype;
cursor c1 is
select table_mod_level.objid,table_part_num.x_technology,table_x_part_class_values.X_PARAM_VALUE, upper(pc.name) name, bo.ORG_ID   ---CR26885
from table_part_num, table_mod_level,table_x_part_class_values, table_x_part_class_params,table_part_class pc, table_bus_org bo ---CR26885
where part_number = esn_part_number
and part_info2part_num = table_part_num.objid
and value2part_class = part_num2part_class
and x_param_name = 'INITIAL_MOTRICITY_CONVERSION'
and value2class_param= table_x_part_class_params.objid
and part_num2part_class= pc.objid
and part_num2bus_org = bo.objid
and rownum < 2;
cursor c2  is
 select 1
from   table_part_class pc,  table_part_num pn, pc_params_view vw
where  pn.pArt_num2part_class=pc.objid
AND   PC.NAME=VW.PART_CLASS
AND   VW.PARAM_NAME  = 'CDMA LTE SIM' --'DLL'   --YM 07/13/2013
AND   VW.PARAM_VALUE = 'REMOVABLE' --'-8'    --YM 07/13/2013
and  pn.part_number = esn_part_number;
--check if part number is POSA
cursor c3 is
      SELECT posa_type
        FROM sa.tf_of_item_v_phone_inv a
       WHERE a.part_number =esn_part_number;
--check if IVR PC. THEY START WITH 103,104, 105
cursor c4  is
 select distinct name,part_number
from   table_part_class pc,  table_part_num pn
where  pn.pArt_num2part_class=pc.objid
and name in ('NT256PBYOPAPN','NTBYOCNRS','NTBYOPC4','NTBYOPC4BMB','NTBYOPC4M',
'NTBYOPC4N','NTBYOPT5','NTBYOPT5BMB','NTBYOPVZ','SMBYOPT5','SMBYOPT5D','NTBYOPC7D','NTBYOPC7N','STBYOPC7D','STBYOPC7N',
'ST256PBYOPAPN','ST256PBYOPD','ST256PBYOPN','STAPBYOPC','STBYOCNL',
'STBYOCNRS','STBYOPC4','STBYOPC4BMB','STBYOPC4M','STBYOPC4N','STBYOPT5',
'STBYOPT5BMB','STBYOPT5M','STBYOPT5N','STBYOPVZ','STBYOTC4D','STBYOTC4N')
and  pn.part_number = esn_part_number;
r1 c1%rowtype;
r2 c2%rowtype;
r3 c3%rowtype;
r4 c4%rowtype;
serial_no VARCHAR2(30);
piobjid number;
  new_hex_meid VARCHAR2(30) := NULL;
   l_x_ild_plus table_x_ota_features.x_ild_plus%TYPE;  --CR26885/CR27015
function is_cdma_apple (p_pn varchar2) return boolean
as
cursor c5 is
select distinct name,part_number
from   table_part_class pc,  table_part_num pn
where  pn.pArt_num2part_class=pc.objid
and  X_MANUFACTUREr = 'APPLE'
and S_DOMAIN       ='PHONES'
and name IN ('STAPI4C','STAPI4SC','STAPI5C','GPAPI5SC',
'GPAPI5SG',
'GPAPI6C',
'GPAPI6G',
'GPAPI6PC',
'GPAPI6PG',
'GPAPI7C',
'GPAPISEC',
'SMAPI6SPG',
'SMAPI7G',
'SMAPISEG',
'STAPI5SGM',
'STAPI6SC',
'STAPI6SG',
'STAPI6SPC',
'STAPI6SPG',
'STAPI7G',
'STAPISEG',
'GPAPI8PCG',
'GPAPI8CG',
'GPAPI7PC',
'GPAPIXCG','TFAPISEC',
'GPAPI6SC',
'NTAPI6C',
'NTAPI6G',
'NTAPI6SC',
'NTAPI6SG',
'NTAPI7C',
'NTAPI7G',
'NTAPI8C',
'NTAPI8G'
)
and  pn.part_number = p_pn;
r5 c5%rowtype;
begin
open c5;
fetch c5 into r5;
 IF c5%FOUND  THEN
 RETURN TRUE;
 ELSE
 RETURN FALSE;
 END IF;
 CLOSE c5;
END is_cdma_apple;
begin
    l_x_ild_plus     := null; --CR26885/CR27015
   open c1;
   fetch c1 into r1;
   if c1%notfound then
      close c1;
      return 'Part not found';
   else
      close c1;
   end if;
    ---CR26885  Mex international CR27015
   if r1.x_technology  like  'GSM%' and r1.ORG_ID = 'TELCEL' and sa.GET_PARAM_BY_NAME_FUN(r1.name,'NON_PPE') = '0' then
        l_x_ild_plus := 'Y';
   END IF;
   if r1.x_technology  not like  'GSM%'  and  r1.x_technology not  like  'CDMA%'  then
      return 'Technology not valid';
   end if;
    if r1.x_technology  like  'GSM%'  then
    SELECT to_char(GSM_SERIAL_NO)
    into serial_no
    FROM DUAL;
  else
         open c2;
       fetch c2 into r2;
       if c2%notfound then
         SELECT to_char(CDMA_SERIAL_NO_SEQ.NEXTVAL)
         into serial_no
             FROM DUAL;
       else
          SELECT to_char(GSM_SERIAL_NO)
         into serial_no
            FROM DUAL;
       end if;
       close c2;
   end if;
    open c4;
       fetch c4 into r4;
       if c4%found then
          serial_no:='103'||substr(serial_no, -12);
          if r4.name in ('NTBYOPC4M','STBYOPC4BMB','NTBYOPC7D','NTBYOPC7N','STBYOPC7D','STBYOPC7N') then
          serial_no:='104'||substr(serial_no, -12);
          end if;
          if r4.name in ('NTBYOPC4BMB','STBYOPC4M') then
          serial_no:='105'||substr(serial_no, -12);
          end if;
       end if;
       close c4;
       -- check part class for hex
      if is_cdma_apple( esn_part_number)=TRUE then
        new_hex_meid :='9999'||substr(serial_no, -10);
        serial_no := TO_CHAR(hex2dec(new_hex_meid));
    end if;
    IF r1.name ='GPAPI5SC'  THEN
    new_hex_meid:=serial_no;
    END IF;
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
Insert into TABLE_X_OTA_FEATURES (OBJID,DEV,X_REDEMPTION_MENU,X_HANDSET_LOCK,X_LOW_UNITS,X_OTA_FEATURES2PART_NUM,X_OTA_FEATURES2PART_INST,X_PSMS_DESTINATION_ADDR,X_ILD_ACCOUNT,X_ILD_CARR_STATUS,X_ILD_PROG_STATUS,X_ILD_COUNTER,X_CLOSE_COUNT,X_CURRENT_CONV_RATE,X_SPP_PIN_ON,X_BUY_AIRTIME_MENU,X_SPP_PROMO_CODE,CURRENT_CONFIG2X_DATA_CONFIG,NEW_CONFIG2X_DATA_CONFIG,X_DATA_CONFIG_PROG_COUNTER,X_ILD_PLUS) --CR26885/CR27015
    values (sa.seq('x_ota_features'),null,'Y','Y','N',null,piobjid,'99999',null,'Inactive','Completed',null,0,r1.X_PARAM_VALUE,'Y','Y','Y',null,null,null, l_x_ild_plus);   --CR26885/ CR27015
    commit;
 open c3;
  fetch c3 into  r3;
 if c3%notfound then
         dbms_output.put_line(esn_part_number||' NOT IN sa.tf_of_item_v_phone_inv in RTRP');
else
          if r3.posa_type='POSA' then
         insert into sa.x_posa_phone ( OBJID                   ,
TF_PART_NUM_PARENT  ,
TF_SERIAL_NUM       ,
TOSS_POSA_CODE      ,
TOSS_POSA_DATE      ,
TF_EXTRACT_FLAG     ,
TOSS_SITE_ID        ,
TOSS_POSA_ACTION               ,
SOURCESYSTEM,
remote_trans_id    ) values ( SEQ_X_POSA_PHONE.nextval    ,       --OBJID
esn_part_number, --TF_PART_NUM_PARENT  ,
serial_no, --TF_SERIAL_NUM       ,
'50',--TOSS_POSA_CODE      ,
sysdate , --TOSS_POSA_DATE      ,
'N', --TF_EXTRACT_FLAG     ,
'5360', --TOSS_SITE_ID   walmart     ,
'SWIPE',--TOSS_POSA_ACTION       ,
'POSA' ,--SOURCESYSTEM  ,
 '9999' --remote_trans_id
 );
 --update date bin to warlmart 5360 for phone
 -- select * from sa.table_inv_bin where bin_name='5360' and location_name='5360'
 update TABLE_PART_INST set PART_INST2INV_BIN=( select objid from sa.table_inv_bin where bin_name='5360' and location_name='5360')   where part_serial_no=serial_no;
 commit;
          end if;
end if;
close c3;
   open c;
  fetch c into  v_name;
insert into GW1.TEST_OTA_ESN       values(serial_no);
insert into sa.TEST_IGATE_ESN      values(serial_no,'C');
commit;
close c;
   return serial_no;
end;
/