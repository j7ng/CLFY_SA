CREATE OR REPLACE FUNCTION sa.get_test_pin_10 (pin_part_number in varchar2)
                  return varchar2 is
pin_number varchar2(30);
p_pin number;
cursor c2 (pin_part_number varchar2) is
select nvl(max(ml.objid),0) objid
from sa.table_mod_level ml, sa.table_part_num pn
where pn.part_number = pin_part_number
and pn.objid = ml.part_info2part_num;
r2 c2%rowtype;
begin
open c2(pin_part_number);
fetch c2 into r2;
if r2.objid>0
then
      select  SEQU_TEST_PIN_10.nextval into p_pin from dual;
          pin_number := to_char(p_pin);
  insert into TABLE_PART_INST(
  OBJID                  ,
  PART_GOOD_QTY          ,
  PART_BAD_QTY           ,
  PART_SERIAL_NO         ,
  PART_MOD               ,
  PART_BIN               ,
  LAST_PI_DATE           ,
  PI_TAG_NO              ,
  LAST_CYCLE_CT          ,
  NEXT_CYCLE_CT          ,
  LAST_MOD_TIME          ,
  LAST_TRANS_TIME        ,
  TRANSACTION_ID         ,
  DATE_IN_SERV           ,
  WARR_END_DATE          ,
  REPAIR_DATE            ,
  PART_STATUS            ,
  PICK_REQUEST           ,
  GOOD_RES_QTY           ,
  BAD_RES_QTY            ,
  DEV                    ,
  X_INSERT_DATE          ,
  X_SEQUENCE             ,
  X_CREATION_DATE        ,
  X_PO_NUM               ,
  X_RED_CODE             ,
  X_DOMAIN               ,
  X_DEACTIVATION_FLAG    ,
  X_REACTIVATION_FLAG    ,
  X_COOL_END_DATE        ,
  X_PART_INST_STATUS     ,
  X_NPA                  ,
  X_NXX                  ,
  X_EXT                  ,
  X_ORDER_NUMBER         ,
  PART_INST2INV_BIN      ,
  N_PART_INST2PART_MOD   ,
  FULFILL2DEMAND_DTL     ,
  PART_INST2X_PERS       ,
  PART_INST2X_NEW_PERS   ,
  PART_INST2CARRIER_MKT  ,
  CREATED_BY2USER        ,
  STATUS2X_CODE_TABLE    ,
  PART_TO_ESN2PART_INST  ,
  X_PART_INST2SITE_PART  ,
  X_LD_PROCESSED         ,
  DTL2PART_INST          ,
  ECO_NEW2PART_INST      ,
  HDR_IND                ,
  X_MSID                 ,
  X_PART_INST2CONTACT    ,
  X_ICCID                ,
  X_CLEAR_TANK           ,
  X_PORT_IN              ,
  X_HEX_SERIAL_NO        )
  VALUES( SEQ('part_inst'),
          null,
           null,
          substr(pin_number,3),
           null,
           null,
         to_date( 'jan/1/1753'   , 'mon/dd/yyyy')        ,
          null,
          to_date( 'jan/1/1753'   , 'mon/dd/yyyy')        ,
        to_date( 'jan/1/1753'   , 'mon/dd/yyyy')        ,
        to_date( 'jan/1/1753'   , 'mon/dd/yyyy')        ,
          to_date( 'jan/1/1753'   , 'mon/dd/yyyy')        ,
             null,
           to_date( 'jan/1/1753'   , 'mon/dd/yyyy')        ,
           null,
         to_date( 'jan/1/1753'   , 'mon/dd/yyyy')        ,
          'Active',
           null,
           null,
           null,
           null,
          to_date( 'jan/1/2005'   , 'mon/dd/yyyy')        ,
          0,
          to_date( 'jan/1/2005'   , 'mon/dd/yyyy')        ,
          '42123448/0334',
          pin_number,
          'REDEMPTION CARDS',
           null,
           null,
           null,
          '42',
           null,
           null,
           null,
          '20066465',
          ( select ib.objid from    Table_Inv_Bin Ib, Table_Site S
              WHERE Ib.Bin_Name = S.Site_Id and s.TYPE=3 and s_name ='WALMART.COM'),
          r2.objid,
           null,
           null,
           null,
           null,
          268435857,
          984,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null     )   ;
       commit;
       return pin_number;
else
 dbms_output.put_line('Part number: '||pin_part_number||' does not exist!');
 return 0;
end if;
close c2;
end;
/