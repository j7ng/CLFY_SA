CREATE OR REPLACE function sa.qPinToEsn( ip_esn in varchar2,
                        ip_pin in varchar2,
                        op_err_msg out varchar2) return number
is
 pragma autonomous_transaction;
  esn_pi_objid number;
  pin_pi_objid number;
  pin_status number;
  pin_attached_to  number;

  NEWPIN constant  varchar2(2) :=  '42';
  NEW_RESERVED_PIN_STATUS VARCHAR2(2) := '40'; --CR48260
  ATTACHED constant varchar2(3):= '400';
begin
  begin
    select pi.objid
    into esn_pi_objid
    from table_part_inst pi
    where part_serial_no = ip_esn;
  exception
    when others then
     op_err_msg := 'ESN Rec not found';
     return 1;
  end;
  begin
     select pi.objid,
            part_to_esn2part_inst,
            x_part_inst_status
     into pin_pi_objid,
          pin_attached_to,
          pin_status
     from table_part_inst pi
     where x_red_code = ip_pin;
  exception
   when others then
     op_err_msg := 'PIN Rec not found';
     return 1;
  end;

  --CR48260 start
  --if pin_status <> NEWPIN then
  if pin_status NOT IN  (NEWPIN, NEW_RESERVED_PIN_STATUS) then
  --CR48260 end
    if pin_status = ATTACHED and pin_attached_to  = esn_pi_objid then
       op_err_msg := 'Pin already attached to this ESN';
       return 0;
    else
       op_err_msg := 'Pin cannot be attached-Not in proper Status';
       return 1;
    end if;
  end if;

  update sa.table_part_inst
  set part_to_esn2part_inst = esn_pi_objid,
      x_part_inst_status = ATTACHED,
      x_ext = (SELECT TO_NUMBER(nvl(max(x_ext),'0')) + 1
               FROM table_part_inst
               WHERE part_to_esn2part_inst = esn_pi_objid
               AND x_domain = 'REDEMPTION CARDS')
  where objid  = pin_pi_objid;

  commit;
  return 0;

exception
   when others then
    return 1;
end;
/