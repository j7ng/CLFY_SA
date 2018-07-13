CREATE OR REPLACE PROCEDURE sa."SP_CHG_ESN" (p_esn varchar2,
                                        p_status OUT varchar2,
                                        p_msg OUT varchar2)
is
/******************************************************************************
* Package Body: SP_CHG_ESN
*
* History             Author             Reason
* -------------------------------------------------------------
* 1 09/18/01                            Initail version
* 2 03/17/03          SL                Clarify Upgrade - refurbish phone
* 3 04/10/03          SL                Clarify Upgrade - sequence
*********************************************************************************/
 v_replace_esn table_site_part.X_SERVICE_ID%TYPE;
 cursor c_ph is
  select * from table_part_inst
  where part_serial_no     = p_esn
  and x_domain ||'' = 'PHONES';
 cursor c_sp is
  select * from table_site_part
  where x_service_id = p_esn
  and part_status = 'Active';
 c_ph_rec c_ph%rowtype;
 c_sp_rec c_sp%rowtype;
begin
 if length(rtrim(ltrim(p_esn))) > 0 then
   v_replace_esn := p_esn||'R';
   -- check esn inventory
   open c_ph;
   fetch c_ph into c_ph_rec;
   if c_ph%notfound then
    p_status := 'F';
	p_msg := 'Esn is not in inventory.';
	return;
   else
    if c_ph_rec.x_part_inst_status = '50' then
	  p_status := 'F';
	  p_msg := 'Esn '||p_esn||' is New and should not be reset.';
	  return;
	end if;
   end if;
   close c_ph;
   open c_sp;
   fetch c_sp into c_sp_rec;
   if c_sp%found then
    p_status := 'F';
	p_msg := 'Esn is still active.';
	return;
   end if;
   update table_part_inst
   set x_part_inst_Status = '50',
     status2x_code_table = 986,
     x_reactivation_flag = 0,
     warr_end_date = null
   where x_domain = 'PHONES'
   and part_serial_no  = p_esn;
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
					seq('x_pi_hist'),
					c_ph_rec.status2x_code_table,
					sysdate,
					'RESET FOR EXCHANGE',
					c_ph_rec.x_cool_end_date,
					c_ph_rec.x_creation_date,
					c_ph_rec.x_deactivation_flag,
					c_ph_rec.x_domain,
					c_ph_rec.x_ext,
					c_ph_rec.x_insert_date,
					c_ph_rec.x_npa,
					c_ph_rec.x_nxx,
					NULL,
					NULL,
					NULL,
					c_ph_rec.part_bin,
					c_ph_rec.X_PART_INST_STATUS,
					c_ph_rec.part_mod,
					c_ph_rec.part_serial_no,
					c_ph_rec.part_status,
					c_ph_rec.part_inst2carrier_mkt,
					c_ph_rec.part_inst2inv_bin,
					c_ph_rec.objid,
					c_ph_rec.n_part_inst2part_mod,
					c_ph_rec.created_by2user,
					c_ph_rec.part_inst2x_new_pers,
					c_ph_rec.part_inst2x_pers,
					c_ph_rec.x_po_num,
					c_ph_rec.x_reactivation_flag,
					c_ph_rec.x_red_code,
					c_ph_rec.x_sequence,
					c_ph_rec.warr_end_date,
					c_ph_rec.dev,
					c_ph_rec.fulfill2demand_dtl,
					c_ph_rec.part_to_esn2part_inst,
					c_ph_rec.bad_res_qty,
					c_ph_rec.date_in_serv,
					c_ph_rec.good_res_qty,
					c_ph_rec.last_cycle_ct,
					c_ph_rec.last_mod_time,
					c_ph_rec.last_pi_date,
					c_ph_rec.last_trans_time,
					c_ph_rec.next_cycle_ct,
					c_ph_rec.x_order_number,
					c_ph_rec.part_bad_qty,
					c_ph_rec.part_good_qty,
					c_ph_rec.pi_tag_no,
					c_ph_rec.pick_request,
					c_ph_rec.repair_date,
					c_ph_rec.transaction_id);
  /* 03/17/03 Clairfy Upgrade
   update table_site_part
   set x_service_id = v_replace_esn
   where x_service_id = p_esn;
   update table_x_call_trans
   set x_service_id = v_replace_esn
   where x_service_id = p_esn; */

   update table_site_part
   set x_refurb_flag = 1
   where x_service_id = p_esn;
   -- 03/17/03

 end if;
 commit;
 p_status := 'S';
 p_msg := 'ESN '||p_esn||' is reset to New.';
exception
 when others then
   rollback;
   p_status := 'F';
   p_msg := substr(sqlerrm,1,250);
end;
/