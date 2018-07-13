CREATE OR REPLACE PROCEDURE sa."SET_COUNTER"
(ip_esn       in       varchar2,
 ip_sequence  in       number,
 ip_agent     in       varchar2,
 ip_reason    in       varchar2)

is

cursor cur_ph is
select * from table_part_inst
where part_serial_no     = ip_esn
  and upper(x_domain)    = 'PHONES';

CURSOR c_user_objid (c_agent in varchar2) IS
 SELECT objid
  FROM table_user
   WHERE S_login_name = UPPER(c_agent);


v_user_objid    NUMBER;
v_sequence	    table_part_inst.x_sequence%type;
rec_ph          cur_ph%rowtype;
r_user_objid    c_user_objid%ROWTYPE;

begin

 OPEN c_user_objid (ip_agent);
 FETCH c_user_objid INTO r_user_objid;

 IF c_user_objid%NOTFOUND THEN
    CLOSE c_user_objid;
    OPEN c_user_objid ('TOSSUTILITY');
    FETCH c_user_objid INTO r_user_objid;

    IF c_user_objid%NOTFOUND THEN
       v_user_objid := NULL;
    END IF;
 END IF;

 CLOSE c_user_objid;

 v_user_objid := r_user_objid.objid;

select part_serial_no
into v_sequence
from table_part_inst
where lower(x_domain) = 'phones'
  and part_serial_no  = ip_esn;

IF v_sequence is null then
 dbms_output.put_line('Esn not found');
Else

 update table_part_inst
 set x_sequence        = ip_sequence
 where lower(x_domain) = 'phones'
   and part_serial_no  = ip_esn;


 open cur_ph;
 fetch cur_ph into rec_ph;
 close cur_ph;

 --write to pi_hist table
 INSERT INTO table_x_pi_hist (
          				OBJID,
					STATUS_HIST2X_CODE_TABLE,
					X_CHANGE_DATE,
					X_CHANGE_REASON,
					X_COOL_END_DATE,
					X_CREATION_DATE,
					X_DEACTIVATION_FLAG,
					X_DOMAIN,
					X_EXT,
					X_INSERT_DATE,
					X_NPA,
					X_NXX,
					X_OLD_EXT,
					X_OLD_NPA,
					X_OLD_NXX,
					X_PART_BIN,
					X_PART_INST_STATUS,
					X_PART_MOD,
					X_PART_SERIAL_NO,
					X_PART_STATUS,
					X_PI_HIST2CARRIER_MKT,
					X_PI_HIST2INV_BIN,
					X_PI_HIST2PART_INST,
					X_PI_HIST2PART_MOD,
					X_PI_HIST2USER,
					X_PI_HIST2X_NEW_PERS,
					X_PI_HIST2X_PERS,
					X_PO_NUM,
					X_REACTIVATION_FLAG,
					X_RED_CODE,
					X_SEQUENCE,
					X_WARR_END_DATE,
					DEV,
					FULFILL_HIST2DEMAND_DTL,
					PART_TO_ESN_HIST2PART_INST,
					X_BAD_RES_QTY,
					X_DATE_IN_SERV,
					X_GOOD_RES_QTY,
					X_LAST_CYCLE_CT,
					X_LAST_MOD_TIME,
					X_LAST_PI_DATE,
					X_LAST_TRANS_TIME,
					X_NEXT_CYCLE_CT,
					X_ORDER_NUMBER,
					X_PART_BAD_QTY,
					X_PART_GOOD_QTY,
					X_PI_TAG_NO,
					X_PICK_REQUEST,
					X_REPAIR_DATE,
					X_TRANSACTION_ID)
				VALUES (
					-- 04/10/03 SEQ_X_PI_HIST.NEXTVAL + power(2,28),
					sa.seq('x_pi_hist'),
					rec_ph.status2x_code_table,
					sysdate,
					ip_reason,
					rec_ph.x_cool_end_date,
					rec_ph.x_creation_date,
					rec_ph.x_deactivation_flag,
					rec_ph.x_domain,
					rec_ph.x_ext,
					rec_ph.x_insert_date,
					rec_ph.x_npa,
					rec_ph.x_nxx,
					NULL,
					NULL,
					NULL,
					rec_ph.part_bin,
					rec_ph.X_PART_INST_STATUS,
					rec_ph.part_mod,
					rec_ph.part_serial_no,
					rec_ph.part_status,
					rec_ph.part_inst2carrier_mkt,
					rec_ph.part_inst2inv_bin,
					rec_ph.objid,
					rec_ph.n_part_inst2part_mod,
					DECODE(v_user_objid,NULL,rec_ph.created_by2user,v_user_objid),
					rec_ph.part_inst2x_new_pers,
					rec_ph.part_inst2x_pers,
					rec_ph.x_po_num,
					rec_ph.x_reactivation_flag,
					rec_ph.x_red_code,
					rec_ph.x_sequence,
					rec_ph.warr_end_date,
					rec_ph.dev,
					rec_ph.fulfill2demand_dtl,
					rec_ph.part_to_esn2part_inst,
					rec_ph.bad_res_qty,
					rec_ph.date_in_serv,
					rec_ph.good_res_qty,
					rec_ph.last_cycle_ct,
					rec_ph.last_mod_time,
					rec_ph.last_pi_date,
					rec_ph.last_trans_time,
					rec_ph.next_cycle_ct,
					rec_ph.x_order_number,
					rec_ph.part_bad_qty,
					rec_ph.part_good_qty,
					rec_ph.pi_tag_no,
					rec_ph.pick_request,
					rec_ph.repair_date,
					rec_ph.transaction_id);
 commit;



end if;


end set_counter;
/