CREATE OR REPLACE function sa.create_active_esn (
                         ip_carrier_id    IN     NUMBER,
                         ip_user          IN     VARCHAR2,
                         ip_esn           IN     VARCHAR2,
                         ip_zip           in     varchar2,
                         ip_sim     IN     VARCHAR2,
                         ip_sourcesystem IN VARCHAR2  ) return varchar2
IS
v_step VARCHAR2(100);
e_dummy_exceptions  EXCEPTION;
v_carrier_objid    NUMBER;
v_pers_objid       NUMBER;
v_line_objid       NUMBER;
v_account_objid    NUMBER;
v_code_objid       NUMBER;
v_mod_objid        NUMBER;
v_expire_days      NUMBER;
v_cooling_days     NUMBER;
v_user_objid       NUMBER;
v_exception_id     NUMBER;
v_expire_date      DATE ;
v_cooling_end_date DATE;
v_code_name        VARCHAR2(25);
v_code_number      VARCHAR2(20);
v_status_id        VARCHAR2(20);
v_description      VARCHAR2(100);
v_npa              VARCHAR2(3);
v_nxx              VARCHAR2(3);
v_ext              VARCHAR2(20);
v_esn_objid        number;
v_min_objid        number;
v_tech             VARCHAR2(10);
v_bus_org   varchar2(20);
p_sourcesystem varchar2(30) ;
p_action_type varchar2(10) :='1';
ip_ota_req_type varchar2(30);
ip_ota_type varchar2(30);
l_contact_objid number;
op_min      VARCHAR2(30);
op_line_objid        NUMBER;
op_call_trans_objid    number;
op_site_objid   number;
op_sitepart_objid  number;
 op_ota_trans_objid  number;
--
cursor verizon_curs is
  select * from x_verizon_zip_npanxx
   where zip = ip_zip
     and template = 'RSS';
verizon_rec verizon_curs%rowtype;
--
CURSOR c_carrier_check(c_tech in varchar2) IS
 SELECT
   b.objid,
   b.carrier2personality,
   b.x_mkt_submkt_name,
   c.x_line_expire_days,
   c.x_cooling_after_insert,
   p.x_parent_name
  FROM
   table_x_parent p,
   table_x_carrier_group cg,
   table_x_carrier b,
   table_x_carrier_rules c
  --CR4579 Commented Out: WHERE  b.carrier2rules = c.objid
  WHERE 1=1
   and p.objid = cg.X_CARRIER_GROUP2X_PARENT
   and cg.objid = b.CARRIER2CARRIER_GROUP
   and DECODE(c_tech,'GSM',b.carrier2rules_GSM,
                       'TDMA',b.carrier2rules_TDMA,
                       'CDMA',b.carrier2rules_CDMA,
                              b.carrier2rules) = c.objid
   and b.x_carrier_id = ip_carrier_id;
--
CURSOR c_user_objid IS
 SELECT objid
  FROM table_user
 WHERE S_login_name = UPPER(ip_user);
--
CURSOR c_get_mod_level is
 SELECT objid
  FROM table_mod_level
   WHERE part_info2part_num in (SELECT objid
                                FROM table_part_num
                                WHERE part_number = 'Lines');
--
--
CURSOR c_status_objid (c_status_id in varchar2) IS
 SELECT OBJID,X_CODE_NUMBER,X_CODE_NAME
  FROM table_x_code_table
   WHERE X_CODE_NUMBER = c_status_id;
--
CURSOR c_esn_objid (c_esn in varchar2) IS
SELECT a.*,c.x_technology, t.S_NAME
  FROM table_part_inst a, table_mod_level b, table_part_num c, table_bus_org t
   WHERE a.part_serial_no = c_esn
   and a.n_part_inst2part_mod = b.objid
   and b.part_info2part_num = c.objid
      and t.objid=c.PART_NUM2BUS_ORG;
--
r_carrier_check c_carrier_check%ROWTYPE;
r_status_objid  c_status_objid%ROWTYPE;
r_user_objid    c_user_objid%ROWTYPE;
r_esn_objid    c_esn_objid%ROWTYPE;
 l_sitepart_objid NUMBER;
    l_site_objid number;
    l_call_trans_objid number;
  l_ota_trans_objid number;
FUNCTION INSERT_LINE_REC(ip_objid IN VARCHAR2,
                         ip_min IN VARCHAR2,
                         ip_npa IN VARCHAR2,
                         ip_nxx IN VARCHAR2,
                         ip_ext IN VARCHAR2,
                         ip_file_name    IN VARCHAR2,
                         ip_expire_date  IN DATE,
                         ip_cooling_end_date IN DATE,
                         ip_code_number   IN VARCHAR2,
                         ip_mod_objid     IN NUMBER,
                         ip_pers_objid    IN NUMBER,
                         ip_carrier_objid IN NUMBER,
                         ip_code_objid    IN NUMBER,
                         ip_user_objid    IN NUMBER,
                         ip_esn_objid     IN NUMBER) RETURN BOOLEAN
IS
Begin
 INSERT INTO table_part_inst (
         objid,
         part_good_qty,
         part_bad_qty,
         part_serial_no,
         last_pi_date,
         last_cycle_ct,
         next_cycle_ct,
         last_mod_time,
         last_trans_time,
         date_in_serv,
         warr_end_date,
         repair_date,
         part_status,
         good_res_qty,
         bad_res_qty,
         x_insert_date,
         x_sequence,
         x_creation_date,
         x_domain,
         x_deactivation_flag,
         x_reactivation_flag,
         x_cool_end_date,
         x_part_inst_status,
         x_npa,
         x_nxx,
         x_ext,
         x_order_number,
         n_part_inst2part_mod,
         part_inst2x_pers,
         part_inst2carrier_mkt,
         created_by2user,
         status2x_code_table,
         part_to_esn2part_inst,
         hdr_ind,
         x_msid,
         X_CLEAR_TANK,
         X_PORT_IN)
       VALUES (
         ip_objid,
         1,
         0,
         ip_min,
         TO_DATE('01/01/1753','MM/DD/YYYY'),
         TO_DATE('01/01/1753','MM/DD/YYYY'),
         TO_DATE('01/01/1753','MM/DD/YYYY'),
         TO_DATE('01/01/1753','MM/DD/YYYY'),
         TO_DATE('01/01/1753','MM/DD/YYYY'),
         TO_DATE('01/01/1753','MM/DD/YYYY'),
         ip_expire_date,
         TO_DATE('01/01/1753','MM/DD/YYYY'),
         'Active',
         0,
         0,
         SYSDATE,
         0,
         SYSDATE,
         'LINES',
         0,
         0,
         ip_cooling_end_date,
         ip_code_number,
         ip_npa,
         ip_nxx,
         ip_ext,
         ip_file_name,
         ip_mod_objid,
         ip_pers_objid,
         ip_carrier_objid,
         ip_user_objid,
         ip_code_objid,
         ip_esn_objid,
         0,
         ip_min,
         0,
         0);
         update table_part_inst
         set part_inst2x_pers = ip_pers_objid, x_sequence=1,
         X_PART_INST_STATUS='52', STATUS2X_CODE_TABLE=(select objid from table_x_code_table where X_CODE_NUMBER='52')
         where objid = ip_esn_objid;
  IF SQL%RowCount = 1 THEN
    COMMIT;
    RETURN TRUE;
  ELSE
    ROLLBACK;
    RETURN FALSE;
  END IF;
EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  RETURN FALSE;
END INSERT_LINE_REC;
 procedure create_ota_trans
  (
      p_call_trans_objid      IN   NUMBER      -- objid of TABLE_X_CALL_TRANS
                                         ,
      p_psms_counter          IN   NUMBER -- PSMS sequence number (x_counter)
                                         ,
      p_mode                  IN   VARCHAR2                     -- WEB, BATCH
                                           ,
      p_resent_date           IN   DATE            -- the value might be NULL
                                       -- ota acknowledgment parameters
   ,
      p_ota_number_of_codes   IN   NUMBER
                                         --     number of codes sent to the phone
                                             -- DLL message
   ,
      p_psms_text             IN   VARCHAR2              -- PSMS message text
                                           -- ota trans and trans detail optional params
   ,
      p_ota_trans_reason      IN   VARCHAR2 DEFAULT NULL,
      p_mobile365_id          IN   VARCHAR2 DEFAULT NULL,  -- OTA Enhancements
	  p_denomination 		  IN   VARCHAR2 DEFAULT NULL ,
      p_ota_trans_objid out number  -- Buy Now
   )
   IS
      CURSOR get_call_trans_data_cur (p_ct_objid IN NUMBER)
      IS
         SELECT ct.x_service_id esn, ct.x_min MIN, ct.x_result status,
                ct.x_ota_type ota_type, ct.x_action_type action_type,
                ct.x_ota_req_type ota_req_type, ca.x_carrier_id carrier_id
           FROM table_x_call_trans ct, table_x_carrier ca
          WHERE ct.x_call_trans2carrier = ca.objid AND ct.objid = p_ct_objid;
      get_call_trans_data_rec   get_call_trans_data_cur%ROWTYPE;
      n_ota_trans_dtl_objid     NUMBER;
      n_ota_trans_objid         NUMBER;
      n_ota_ackn_objid          NUMBER;
      d_sent_date               DATE;
      d_received_date           DATE;
   BEGIN
      OPEN get_call_trans_data_cur (p_call_trans_objid);
      FETCH get_call_trans_data_cur
       INTO get_call_trans_data_rec;
      CLOSE get_call_trans_data_cur;
      -- generate objid number for ota trans table
      n_ota_trans_objid := seq ('x_ota_transaction');
      INSERT INTO table_x_ota_transaction
                  (objid, x_transaction_date,
                   x_status,
                   x_esn, x_min,
                   x_action_type, x_mode,
                   x_counter, x_reason,
                   x_carrier_code, x_ota_trans2x_ota_mrkt_info,
                   x_ota_trans2x_call_trans,
                   x_mobile365_id, -- OTA Enhancements
				   x_ota_trans2x_denomination -- BUY NOW
                  )
           VALUES (n_ota_trans_objid, SYSDATE,
                   get_call_trans_data_rec.status,
                   get_call_trans_data_rec.esn, get_call_trans_data_rec.MIN,
                   get_call_trans_data_rec.action_type, p_mode,
                   p_psms_counter, p_ota_trans_reason,
                   get_call_trans_data_rec.carrier_id, NULL,
                   p_call_trans_objid,
                   p_mobile365_id, --O TA Enhancements
				   p_denomination -- BUY NOW
                  );
      p_ota_trans_objid  :=  n_ota_trans_objid ;
      -- generate objid number for ota trans detail table
      n_ota_trans_dtl_objid := seq ('x_ota_trans_dtl');
      -- assign sysdate to all transactions, except ota activation
      IF get_call_trans_data_rec.action_type <> ota_util_pkg.activation
      THEN
         d_sent_date := SYSDATE;
      END IF;
      INSERT INTO table_x_ota_trans_dtl
                  (objid, x_psms_text,
                   x_action_type, x_sent_date,
                   x_received_date, x_resent_date,
                   x_ota_message_direction, x_ota_trans_dtl2x_ota_trans
                  )
           VALUES (n_ota_trans_dtl_objid, p_psms_text,
                   get_call_trans_data_rec.ota_type
                                                   -- it was ACTION_TYPE before
      ,            d_sent_date,
                   d_received_date
                                  -- NULL for Activation and SYSDATE for Redemption
      ,            p_resent_date,
                   get_call_trans_data_rec.ota_req_type
                                                       -- it was OTA_TYPE before
      ,            n_ota_trans_objid
                  );
      -- generate objid number for table_x_ota_ack
      n_ota_ackn_objid := seq ('x_ota_ack');
      INSERT INTO table_x_ota_ack
                  -- populating only 3 columns:
      (            objid, x_ota_number_of_codes,
                   x_ota_ack2x_ota_trans_dtl
                                            -- not passing values for the following columns:
      ,            x_ota_error_code,
                   x_ota_error_message, x_ota_codes_accepted, x_units,
                   x_phone_sequence, x_psms_ack_msg
                  )
           VALUES (n_ota_ackn_objid, p_ota_number_of_codes,
                   n_ota_trans_dtl_objid, NULL,
                   NULL, NULL, NULL,
                   NULL, NULL
                  );
   END create_ota_trans;
--
BEGIN
--
  --select sa.seq('part_inst') into v_min_objid from dual;
  select sa.SEQU_min.nextval into v_min_objid from dual;
--
  op_min :=  v_min_objid;
  v_npa := SUBSTR(op_min,1,3);
  v_nxx := SUBSTR(op_min,4,3);
  v_ext := SUBSTR(op_min,-7,4);
   -- op_min :=v_npa||v_nxx||v_ext;
  v_tech := '';
------------------------------------------------------------------
v_step := 'Get ESN objid';
------------------------------------------------------------------
  OPEN c_esn_objid (ip_esn);
    FETCH c_esn_objid INTO r_esn_objid;
    v_esn_objid  := r_esn_objid.objid;
    v_tech       := r_esn_objid.x_technology;
    v_bus_org   := r_esn_objid.s_name;
  CLOSE c_esn_objid;
  p_sourcesystem:= upper(ip_sourcesystem );
  IF  v_bus_org ='TRACFONE' and p_sourcesystem= 'WEB' 
  then 
    l_site_objid:=1 ; 
    l_contact_objid := 1;
    --web
   elsif v_bus_org ='TRACFONE' and p_sourcesystem= 'WEBCSR' 
   then 
    l_site_objid:=3 ; 
     l_contact_objid := 3;
   elsif v_bus_org ='NET10' and p_sourcesystem= 'WEB' 
   then 
    l_site_objid:=5 ;  l_contact_objid := 5;
   elsif v_bus_org ='NET10' and p_sourcesystem= 'WEBCSR' 
   then 
    l_site_objid:=4;   l_contact_objid :=4 ;
    elsif v_bus_org ='STRAIGHT_TALK' and p_sourcesystem= 'WEBCSR' 
   then 
    l_site_objid:=6;    l_contact_objid := 6;
     elsif v_bus_org ='STRAIGHT_TALK' and p_sourcesystem= 'WEB' 
   then 
    l_site_objid:=7;  l_contact_objid := 7;
    end if;
  OPEN c_carrier_check(v_tech);
    FETCH c_carrier_check INTO r_carrier_check;
   IF c_carrier_check%FOUND THEN
      CLOSE c_carrier_check;
      v_carrier_objid := r_carrier_check.objid;
      v_pers_objid    := r_carrier_check.carrier2personality;
      v_expire_days   := r_carrier_check.x_line_expire_days;
      v_cooling_days  := r_carrier_check.x_cooling_after_insert;
      FOR r_get_mod_level IN c_get_mod_level LOOP
        v_mod_objid := r_get_mod_level.objid;
      END LOOP;
      -- v_expire_date:= SYSDATE + nvl(v_expire_days, 30);
        SELECT DECODE(v_expire_days,NULL,
                                   TO_DATE('01/01/1753','MM/DD/YYYY'),0,
                                   TO_DATE('01/01/1753','MM/DD/YYYY'),
                                   SYSDATE + v_expire_days) INTO v_expire_date
                                   FROM DUAL;                    
      SELECT DECODE(v_cooling_days,NULL,
                                   TO_DATE('01/01/1753','MM/DD/YYYY'),0,
                                   TO_DATE('01/01/1753','MM/DD/YYYY'),
                                   SYSDATE + v_cooling_days * 1/86400) INTO v_cooling_end_date
                                   FROM DUAL;
    END IF;
  OPEN c_user_objid;
    FETCH c_user_objid INTO v_user_objid;
close c_user_objid;
----------------------------------------
v_step := 'Getting status info';
----------------------------------------
  v_status_id := '13';
  OPEN c_status_objid (v_status_id);
    FETCH c_status_objid INTO r_status_objid;
    v_code_number := r_status_objid.x_code_number;
    v_code_objid  := r_status_objid.objid;
  CLOSE c_status_objid;
------------------------------------------------------------------
v_step := 'Checking min status to determine an update or insert';
------------------------------------------------------------------
  IF NOT INSERT_LINE_REC (v_min_objid,
                         op_min,
                         v_npa,
                         v_nxx,
                         v_ext,
                         '',
                         v_expire_date,
                         v_cooling_end_date,
                         v_code_number,
                         v_mod_objid,
                         v_pers_objid,
                         v_carrier_objid,
                         v_code_objid,
                         v_user_objid,
                         v_esn_objid) THEN
         v_exception_id := 112;
    RAISE e_dummy_exceptions;
  END IF;
-------------------------------------------------------
v_step := 'Inserting account hist and pi_hist record';
-------------------------------------------------------
  IF v_line_objid IS NULL THEN
    SELECT objid INTO op_line_objid
      FROM table_part_inst
     WHERE x_domain = 'LINES'
       AND part_serial_no = op_min;
  END IF;
/**
  IF NOT WRITE_TO_PI_HIST (v_line_objid,'LINE_BATCH') THEN
    v_exception_id := 114;
    RAISE e_dummy_exceptions;
  END IF;
  **/
-- insert table_site_part
 l_sitepart_objid := seq('site_part');
 select objid into  l_site_objid from table_site where s_name ='WALMART.COM';
    INSERT INTO table_site_part
      (objid
      ,x_min
      ,serial_no
      ,x_service_id
      ,part_status
      ,install_date
      ,site_objid
      ,dir_site_objid
      ,warranty_date
      ,x_pin
      ,x_zipcode
      ,state_value
      ,instance_name
      ,x_msid
      ,site_part2site
      ,all_site_part2site
      ,site_part2part_info
      ,x_iccid,
      X_EXPIRE_DT)
    VALUES
      (l_sitepart_objid
      ,op_min
      ,ip_esn
      ,ip_esn
      ,'Active'
      ,SYSDATE
      ,l_site_objid 
      ,l_site_objid 
      ,v_expire_date +30
      ,null
      ,ip_zip
      ,r_esn_objid.x_technology
      ,'Wireless'
      ,op_min
      ,l_site_objid 
      ,l_site_objid 
      ,r_esn_objid.n_part_inst2part_mod
      ,ip_sim,v_expire_date+30);
 -- update sim status
 update table_x_sim_inv set X_SIM_INV_STATUS='254' , X_LAST_UPDATE_DATE=sysdate where x_sim_serial_no =ip_sim;
 commit;
 update table_part_inst set LAST_TRANS_TIME=sysdate, WARR_END_DATE=trunc(v_expire_date),X_PART_INST2SITE_PART =l_sitepart_objid, 
 x_iccid=ip_sim, X_PART_INST2CONTACT=l_contact_objid where part_serial_no=ip_esn;
 commit;
op_site_objid         :=l_site_objid;
                         op_sitepart_objid:=l_sitepart_objid;
select seq('x_call_trans') into l_call_trans_objid from dual;      
open c_status_objid (p_action_type);
fetch c_status_objid  into r_status_objid;
close c_status_objid ;           
if  v_bus_org='TRACFONE' then
	  ip_ota_req_type :='MT';
	  ip_ota_type :='264';
elsif       v_bus_org='STRAIGHTTALK' then
ip_ota_req_type := null;
	  ip_ota_type :=null;
end if;      
INSERT
   INTO table_x_call_trans(
      objid,
      call_trans2site_part,
      x_action_type,
      x_call_trans2carrier,
      x_call_trans2dealer,
      x_call_trans2user,
      x_min,
      x_service_id,
      x_sourcesystem,
      x_transact_date,
      x_total_units,
      x_action_text,
      x_reason,
      x_result,
      x_sub_sourcesystem,
      x_iccid, -- 07/07/2004 GP
	  x_ota_req_type,
	  x_ota_type
   )VALUES(
      l_call_trans_objid,
      l_sitepart_objid,
      p_action_type,
      v_carrier_objid,
      l_site_objid,
      v_user_objid,
      op_min,
      ip_esn,
      p_sourcesystem,
      SYSDATE,
      NULL,
      r_status_objid.X_CODE_NAME,
      null,
      'Completed',
      v_bus_org,
      ip_sim,
	  ip_ota_req_type,
	  ip_ota_type
   );
   COMMIT;                         
 op_call_trans_objid      :=   l_call_trans_objid;  
   create_ota_trans (
      l_call_trans_objid,                                         
      1,
      p_sourcesystem   ,
       Null,
       1,
     '/ //TF 58043054006030073017032251815802530574826799009199440073000' ,
     null,
      NULL,  -- OTA Enhancements
	  NULL ,  -- Buy Now
      l_ota_trans_objid
   );
   commit;
     op_ota_trans_objid :=l_ota_trans_objid;
     if v_bus_org ='STRAIGHT_TALK' 
     then
      insert into  X_SERVICE_PLAN_SITE_PART (TABLE_SITE_PART_ID,  X_SERVICE_PLAN_ID ,  X_SWITCH_BASE_RATE,X_NEW_SERVICE_PLAN_ID , X_LAST_MODIFIED_DATE  )         
      values(l_sitepart_objid, 1, '0.1',null, sysdate);
      insert into X_SWITCHBASED_TRANSACTION   (OBJID ,X_SB_TRANS2X_CALL_TRANS,STATUS,X_TYPE,X_VALUE, EXP_DATE,RSID  )      
      values(SEQU_X_SB_TRANSACTION.NEXTVAL,l_call_trans_objid,'Completed','AP','0.01', trunc(sysdate)+30,'5050');
      INSERT INTO TABLE_X_CONTACT_PART_INST(OBJID,X_CONTACT_PART_INST2CONTACT,X_CONTACT_PART_INST2PART_INST,X_ESN_NICK_NAME ,X_IS_DEFAULT ,X_TRANSFER_FLAG ,X_VERIFIED)
      VALUES (SEQU_X_CONTACT_PART_INST.nextval,l_contact_objid ,v_esn_objid , 'MY PHONE',1,null,null);
      commit;
     end if;
 return op_min;    
end ; 
/