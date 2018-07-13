CREATE OR REPLACE PACKAGE BODY sa.Full_fillment_Services_pkg
IS
l_err_num varchar2(50);
 /******************************************************************************************/
 /* CVS CHECK IN HISTORY */
 --$RCSfile: FULL_FILLMENT_SERVICES_pkb.sql,v $
 --$Revision: 1.66 $
 --$Author: sinturi $
 --$Date: 2017/11/13 21:50:45 $
 --$Log: FULL_FILLMENT_SERVICES_pkb.sql,v $
 --Revision 1.66  2017/11/13 21:50:45  sinturi
 --Merged with Prod code
 --
 --Revision 1.61  2017/07/17 14:54:23  smeganathan
 --Code changes for Automated return of SIM and SOFTPINs
 --
 --Revision 1.60  2017/06/26 16:30:51  smeganathan
 --Added not null validation in b2c procedure
 --
 --Revision 1.59  2017/05/24 15:54:09  smeganathan
 --Merged Amazon Discounted plans code with 5/23 prod release
 --
 --Revision 1.58  2017/05/10 14:55:49  vlaad
 --Added logic to update ESN nick name
 --
 --Revision 1.57  2017/04/24 18:36:39  smeganathan
 --added parameter i_consumer to b2c procedure
 --
 --Revision 1.56  2017/04/12 18:17:27  smeganathan
 --Added provision_service_plan_b2c
 --
 --Revision 1.55  2017/04/07 20:10:21  smeganathan
 --Added provision_service_plan_b2c
 --
 --Revision 1.48  2017/03/13 20:26:34  nmuthukkaruppan
 --CR47608 - Modified to update the AGENT_ID in X_BIZ_PURCH_HDR during fullfilment,.
 --
 --Revision 1.47 2016/12/05 16:36:49 pamistry
 --CR46176 - Added / at the end of the package and production merge with 12 05 2016 copy
 --
 --Revision 1.46 2016/12/02 22:00:32 pamistry
 --CR46176 - modify the PROVISION_SERVICE_PLAN procedure to move update and add exception handler. for the CR change
 --
 --Revision 1.45 2016/12/01 20:20:25 pamistry
 --CR46176 - Fix theReference to uninitialized collection from PROVISION_SERVICE_PLAN procedure
 --
 --Revision 1.43 2016/11/16 15:47:14 pamistry
 --CR46176 Marry the SIM with ESN if the value is passed in key value input.
 --
 --Revision 1.42 2016/09/27 18:40:11 ddudhankar
 --Updated deenrollifneeded
 --
 --Revision 1.36 2016/09/15 16:06:48 vnainar
 --CR43498 added exception block in queuepin2esn to handle dup_value on index error
 --
 --Revision 1.35 2016/09/08 19:59:24 vlaad
 --Added default data redemption limit for data club
 --
 --Revision 1.33 2016/08/04 15:01:55 vyegnamurthy
 --merged with prod for 42260
 --
 --Revision 1.30 2016/07/08 21:11:39 nmuthukkaruppan
 --CR39912 - ST Commerce - Changes
 --
 --Revision 1.29 2016/07/08 20:47:04 nmuthukkaruppan
 --CR39912 - ST commerce - Add Multiple PINS in Queue Changes
 --
 --Revision 1.19 2015/01/16 20:21:11 oarbab
 --cr31683 added rollbacks and removed code for cancelled cr 30187
 --
 --Revision 1.17 2014/09/22 14:32:57 ahabeeb
 --changed due to new column in call_trans
 --
 --Revision 1.16 2014/08/27 21:59:03 cpannala
 --CR30416
 --
 --Revision 1.15 2014/08/20 15:30:24 cpannala
 --CR30255 FF Action type required changes
 --
 --Revision 1.8 2014/04/02 15:07:52 cpannala
 --CR25490 smal bug fixes
 --
 --Revision 1.7 2014/03/18 19:54:31 akhan
 --re-written
 --Revision 1.2 2014/02/07 16:40:40 cpannala
 --CR25490
 --Revision 1.0 2014/01/24 2:51:07 CPannala
 --CR25490
 ---$Description: New package forB2B CR22623: To provision the benifits to the coustmer
 ---Planchange_Deenroll is interenal store procedure for deenroll the esn in current billing program-----
 -----------------
------------------------------------------------------------------------------------
Procedure validate_inputs(in_order_id           IN  x_biz_purch_hdr.c_orderid%TYPE,
                          In_Paymentsourceid    IN  NUMBER,
                          in_account_id         IN  VARCHAR2,
                          in_bus_org_id         IN  VARCHAR2,
                          in_organization_id    IN  table_site.x_commerce_id%TYPE, --CR47608
                          in_esn_tbl_count      IN  NUMBER,
                          op_org_objid          OUT NUMBER,
                          op_wu_objid           OUT NUMBER,
                          op_dealer_invbinobjid OUT NUMBER,
                          site_objid            OUT NUMBER,
                          out_err_num           OUT NUMBER,
                          out_err_msg           OUT VARCHAR2,
                          i_ship_loc_id         IN  table_site.x_ship_loc_id%TYPE  --CR47608
                          )
 is

   v_bus_org_id table_bus_org.s_org_id%type;


begin
--out_err_num  := 0;
  IF IN_ACCOUNT_ID  IS NULL OR in_bus_org_id IS NULL THEN
    out_err_num     := -1;
    l_err_num := '1001';
    out_err_msg := 'Login Name Nnd Bus Org Required';
    UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => l_err_num,
                                   IP_KEY => IN_ACCOUNT_ID,
                                   IP_PROGRAM_NAME => 'SA.Full_Fillment_Services_pkg.validate_inputs',
                                   ip_error_text => out_err_msg);
    return;
  ELSIF IN_ORGANIZATION_ID IS NULL AND i_ship_loc_id IS NULL THEN --CR47608 One of these two needs to be passed
    out_err_num         := -1;
    l_err_num := '1002';
    out_err_msg :=  'Organization ID OR Ship Loc ID is Required';  --CR47608
    UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => l_err_num,
                                   IP_KEY => NVL(IN_ORGANIZATION_ID,i_ship_loc_id),--CR47608
                                   IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.validate_inputs',
                                   ip_error_text => out_err_msg);
     return;
  ELSIF IN_ORDER_ID IS NULL THEN
    out_err_num         := -1;
    l_err_num := '1003';
    out_err_msg :=  'Order ID Required';
    UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => l_err_num,
                                   IP_KEY => NVL(IN_ORGANIZATION_ID,i_ship_loc_id),--CR47608
                                   IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.validate_inputs',
                                   ip_error_text => out_err_msg);
    return;
  ELSIF (in_esn_tbl_count = 0) THEN
    out_err_num               := -1;
     l_err_num := '1004';
    out_err_msg := 'Input List Of ESN And Part Number Values Required.';
    UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => l_err_num,
                                   IP_KEY => NVL(IN_ORGANIZATION_ID,i_ship_loc_id),--CR47608
                                   IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.validate_inputs',
                                   ip_error_text => out_err_msg);
     return;
  END IF;
  --if ( out_err_num = 0 ) then
     begin
       select bo.objid,
              wu.objid
        into  op_org_objid,
              op_wu_objid
       from table_bus_org bo,
            table_web_user wu
       where wu.s_login_name = upper(in_account_id)
       and wu.web_user2bus_org = bo.objid
       and bo.s_org_id = upper(in_bus_org_id);
     exception
        when others then

        --
        -- CR52025 Added logic to check if biz purch hdr bus org is passed  TFPHONEUPG
        --
           begin

           select table_bus_org.org_id
             into v_bus_org_id
             from x_biz_purch_hdr,table_web_user,table_bus_org
            where prog_hdr2web_user = table_web_user.objid
              and table_web_user.web_user2bus_org = table_bus_org.objid
              and x_payment_type='SETTLEMENT'
              and x_biz_purch_hdr.x_status = 'SUCCESS'
              and c_orderid = in_order_id;


           select bo.objid,
                  wu.objid
            into  op_org_objid,
                  op_wu_objid
           from table_bus_org bo,
                table_web_user wu
           where wu.s_login_name = upper(in_account_id)
           and wu.web_user2bus_org = bo.objid
           and bo.s_org_id = upper(v_bus_org_id);




          exception
          when others then
           null;
          end;


        --
        -- CR52025 End Added logic to check if biz purch hdr bus org is passed  TFPHONEUPG
        --
          op_org_objid := -1;
          op_wu_objid := -1;
          out_err_num := -1;
          l_err_num := '1005';
          out_err_msg := 'Brand/Login Name Are Invalid';
          UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => l_err_num,
                                   IP_KEY => in_account_id,
                                   IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.validate_inputs',
                                   ip_error_text => out_err_msg);
          Return;
     end;
     -- CR47608
     -- if in_organization_id is passed, it means it was passed by commerce
     -- which will map to x_commerce_id of table_site
     IF in_organization_id IS NOT NULL THEN
       BEGIN
         SELECT ib.objid,
                ts.objid
         INTO   op_dealer_invbinobjid,
                site_objid
         FROM   table_site ts,
                table_inv_bin ib,
                x_site_web_accounts xsa,
                table_web_user wu
         WHERE  xsa.site_web_acct2web_user = wu.objid
         AND    xsa.site_web_acct2site     = ts.objid
         AND    ts.site_id                 = ib.bin_name
         AND    ts.x_commerce_id           = in_organization_id
         AND    wu.objid                   = op_wu_objid;

       EXCEPTION
       WHEN OTHERS
       THEN
         op_dealer_invbinobjid := -1;
         out_err_num           := -1;
         l_err_num             := '2016';
         out_err_msg           := 'in_organization_id is Invalid';
         util_pkg.insert_error_tab_proc( ip_action       => l_err_num,
                                         ip_key          => in_organization_id,
                                         ip_program_name => 'Full_Fillment_Services_pkg.validate_inputs',
                                         ip_error_text   => out_err_msg
                                        );
         RETURN;
       END;
     ELSE -- IF in_organization_id IS NOT NULL THEN
     -- if i_ship_loc_id is passed, then do a look up on ship loc id
       BEGIN
          SELECT ib.objid,
                 ts.objid
          INTO   op_dealer_invbinobjid,
                 site_objid
          FROM   table_site ts,
                 table_inv_bin ib,
                 x_site_web_accounts xsa,
                 table_web_user wu
          WHERE  xsa.site_web_acct2web_user = wu.objid
          AND    xsa.site_web_acct2site     = ts.objid
          AND    ts.site_id                 = ib.bin_name
          AND    ts.x_ship_loc_id           = i_ship_loc_id --333 or
          AND    wu.objid                   = op_wu_objid;           --584696631
       EXCEPTION
       WHEN OTHERS
       THEN
         op_dealer_invbinobjid := -1;
         out_err_num           := -1;
         l_err_num             := '1006';
         out_err_msg           := 'Ship Loc ID Invalid';
         UTIL_PKG.INSERT_ERROR_TAB_PROC( ip_action       => l_err_num,
                                         ip_key          => i_ship_loc_id,
                                         ip_program_name => 'Full_Fillment_Services_pkg.validate_inputs',
                                         ip_error_text   => out_err_msg);
         RETURN;
       END;
   END IF;-- IF in_organization_id IS NOT NULL THEN
  out_err_num := 0;
  out_err_msg := 'Success';
end validate_inputs;
----------------------------------------------------------------------------------
 PROCEDURE queuePin2ESn_validation(
 in_esn IN table_part_inst.part_serial_no%type,
 out_err_num OUT NUMBER,
 out_err_msg OUT VARCHAR2)
IS
 CURSOR ESN_cur
 IS
 SELECT esn.part_serial_no esn,
 esn.x_part_inst_status esn_status,
      lin.x_part_inst_status card_status,
      lin.x_domain,
      lin.x_red_code Pin,
      lin.x_ext
    FROM table_part_inst esn,
      table_part_inst lin
    WHERE 1                       = 1
    AND lin.part_to_esn2part_inst = esn.objid
    AND lin.X_PART_INST_STATUS    = '400'
    AND lin.X_DOMAIN              = 'REDEMPTION CARDS'
    AND esn.part_serial_no        = in_esn;
  esn_rec esn_cur%rowtype;
BEGIN
  OPEN ESN_cur;
  FETCH ESN_cur INTO esn_rec;
  IF esn_cur%found THEN
    out_err_num := -1;
    l_err_num := '1007';
    out_err_msg := 'Already Pin In Queue';
    CLOSE esn_cur;
    UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => l_err_num,
                                   IP_KEY => in_esn||' - '||esn_rec.Pin,
                                   IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.queuePin2ESn_validation',
                                   ip_error_text => out_err_msg);
    return;
  END IF;
  CLOSE esn_cur;
  out_err_num := 0;
  out_err_msg := 'Success';
 END queuePin2ESn_validation ;
------------------------------------------------------------------------------------
 procedure queue_pin2esn( p_soft_pin in varchar2,
                         p_smp in varchar2,
                             p_invbin_objid number,
                         p_site_objid number,
                         p_user_objid number,
                         p_ml_objid   number,
                         p_esn in varchar2,
                         p_esn_status in varchar2,
                             p_esn_objid number,
                         p_bus_org_id varchar2,
                         out_err_num out number,
                         out_err_msg out varchar2) is
------------------------------------------------------------------------------------
  v_call_trans_objid number;
begin
  sp_seq('x_call_trans',v_call_trans_objid);

   insert into table_part_inst
    ( objid,
      last_pi_date,
      last_cycle_ct,
      next_cycle_ct,
      last_mod_time,
      last_trans_time,
      date_in_serv,
      repair_date,
      warr_end_date,
      x_cool_end_date,
      part_status,
      hdr_ind,
      x_sequence,
      x_insert_date,
      x_creation_date,
      x_domain,
      x_deactivation_flag,
      x_reactivation_flag,
      x_red_code,
      part_serial_no,
      x_part_inst_status,
      status2x_code_table,
      part_inst2inv_bin,
      created_by2user,
      n_part_inst2part_mod,
      part_to_esn2part_inst,
      x_ext
    )
   values (sa.sequ_part_inst.nextval,                              --OBJID,
       sysdate,                                                 --LAST_PI_DATE,
       to_date('01-JAN-1753','DD-MON-YYYY'),                    --LAST_CYCLE_CT,
       to_date('01-JAN-1753','DD-MON-YYYY'),                    --NEXT_CYCLE_CT,
       sysdate,                                                 --LAST_MOD_TIME,
       sysdate,                                                 --LAST_TRANS_TIME,
       to_date('01-JAN-1753','DD-MON-YYYY'),                    --DATE_IN_SERV,
       to_date('01-JAN-2053','DD-MON-YYYY'),                    --REPAIR_DATE,
       to_date('01-JAN-2053','DD-MON-YYYY'),                     --WARR_END_DATE,
       to_date('01-JAN-2053','DD-MON-YYYY'),                    --X_COOL_END_DATE,
       'Active',                                                --PART_STATUS,
       0,                                                       --HDR_IND,
       0,                                                       --X_SEQUENCE,
       sysdate,                                                 --X_INSERT_DATE,
       sysdate,                                                 --X_CREATION_DATE,
       'REDEMPTION CARDS',                                      --X_DOMAIN,
       0,                                                       --X_DEACTIVATION_FLAG,
       0,                                                       --X_REACTIVATION_FLAG,
       p_soft_pin,                                              --X_RED_CODE,
       p_smp,                                                   --PART_SERIAL_NO,
       '400',                                                   --X_PART_INST_STATUS,
       (SELECT objid FROM table_x_code_table WHERE x_code_number ='400'),--STATUS2X_CODE_TABLE,
       p_invbin_objid,                                          --PART_INST2INV_BIN,
       p_user_objid,                                            --CREATED_BY2USER,
       p_ml_objid,                                              --N_PART_INST2PART_MOD,
       p_esn_objid,                                             --PART_TO_ESN2PART_INST,
       (SELECT nvl(MAX(TO_NUMBER(x_ext)),0) + 1
      FROM table_part_inst
      WHERE part_to_esn2part_inst = p_esn_objid
      AND x_domain                = 'REDEMPTION CARDS'));         --X_EXT,
    begin
     --DBMS_OUTPUT.PUT_LINE('ESn_status' || p_esn_status);
     --DBMS_OUTPUT.PUT_LINE('v_call_trans_objid' || v_call_trans_objid);
      if  p_esn_status in ('52') then
        convert_bo_to_sql_pkg.sp_create_call_trans(
                         p_esn,              --ip_esn
                         '401',              --ip_action_type
                         'WEB',              --IP_SOURCESYSTEM
                         p_bus_org_id,       --IP_BRAND_NAME,
                         p_soft_pin,         --ip_reason
                         'Completed',        --IP_RESULT
                         NULL,               --ip_ota_req_type,
                         '402',              --IP_OTA_TYPE,      -- CR15847 PM ST Steaking
                         0,                  --ip_total_units
                         v_call_trans_objid ,
                         out_err_num ,
                         out_err_msg);
         else
          if out_err_num <> 0 or p_esn_status in ('50','51','54','150') then
           -- DBMS_OUTPUT.PUT_LINE('ESn_status' || p_esn_status);
           --DBMS_OUTPUT.PUT_LINE('v_call_trans_objid' || v_call_trans_objid);
	   BEGIN --added to avoid unique constraint (SA.IND_CALL_TRANS) violated error and insert call trans with split second difference
            INSERT INTO TABLE_X_CALL_TRANS
                            (
                              OBJID,
                              CALL_TRANS2SITE_PART,
                              X_ACTION_TYPE,
                              X_CALL_TRANS2CARRIER,
                              X_CALL_TRANS2DEALER,
                              X_CALL_TRANS2USER,
                              X_LINE_STATUS,
                              X_MIN,
                              X_SERVICE_ID,
                              X_SOURCESYSTEM,
                              X_TRANSACT_DATE,
                              X_TOTAL_UNITS,
                              X_ACTION_TEXT,
                              X_REASON,
                              X_RESULT,
                              X_SUB_SOURCESYSTEM,
                              X_ICCID,
                              X_OTA_REQ_TYPE,
                              X_OTA_TYPE,
                              X_CALL_TRANS2X_OTA_CODE_HIST,
                              X_NEW_DUE_DATE,
                              UPDATE_STAMP
                            )
                            VALUES
                            (
                              v_call_trans_objid,
                              NULL, -- sitepart objid
                              '401',
                              NULL,       -- carrier OBJID
                              P_SITE_OBJID, -- table_site OBJID
                              268435556,  --SA OBJID, can be hardcoded
                              NULL,
                              NULL, -- MIN
                              p_esn,
                              'WEB',
                              sysdate,
                              0,
                              'QUEUED',
                              p_soft_pin,
                              'Completed',
                              DECODE(UPPER(p_bus_org_id) ,'ENGLISH' ,'200' ,'SPANISH' ,'201' ,p_bus_org_id),
                              NULL, -- ICCID
                              NULL,
                              '402',
                              NULL,
                              NULL,
                              sysdate
                            );
	   EXCEPTION
  	      WHEN DUP_VAL_ON_INDEX  THEN
	                     INSERT INTO TABLE_X_CALL_TRANS
                            (
                              OBJID,
                              CALL_TRANS2SITE_PART,
                              X_ACTION_TYPE,
                              X_CALL_TRANS2CARRIER,
                              X_CALL_TRANS2DEALER,
                              X_CALL_TRANS2USER,
                              X_LINE_STATUS,
                              X_MIN,
                              X_SERVICE_ID,
                              X_SOURCESYSTEM,
                              X_TRANSACT_DATE,
                              X_TOTAL_UNITS,
                              X_ACTION_TEXT,
                              X_REASON,
                              X_RESULT,
                              X_SUB_SOURCESYSTEM,
                              X_ICCID,
                              X_OTA_REQ_TYPE,
                              X_OTA_TYPE,
                              X_CALL_TRANS2X_OTA_CODE_HIST,
                              X_NEW_DUE_DATE,
                              UPDATE_STAMP
                            )
                            VALUES
                            (
                              v_call_trans_objid,
                              NULL, -- sitepart objid
                              '401',
                              NULL,       -- carrier OBJID
                              P_SITE_OBJID, -- table_site OBJID
                              268435556,  --SA OBJID, can be hardcoded
                              NULL,
                              NULL, -- MIN
                              p_esn,
                              'WEB',
                              sysdate + 1/86400,
                              0,
                              'QUEUED',
                              p_soft_pin,
                              'Completed',
                              DECODE(UPPER(p_bus_org_id) ,'ENGLISH' ,'200' ,'SPANISH' ,'201' ,p_bus_org_id),
                              NULL, -- ICCID
                              NULL,
                              '402',
                              NULL,
                              NULL,
                              sysdate
                            );
           END;

          end if;
        end if;
    end;
  exception
  when others then
  out_err_num := sqlcode;
  l_err_num := '1008';
  out_err_msg := 'Error In queue_pin2esn'||substr(sqlerrm,1,200);
  UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => l_err_num || TO_CHAR(OUT_ERR_NUM),
                                 IP_KEY => p_esn || p_soft_pin,
                                 IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.queue_pin2esn',
                                 ip_error_text => out_err_msg);
 end queue_pin2esn;
------------------------------------------------------------------------------------
PROCEDURE gen_softpin(
    p_consumer  IN VARCHAR2 DEFAULT NULL,--CR42260
    out_soft_pin out varchar2,
    out_smp out number,
    op_err_code out number,
    op_err_msg  out varchar2 )
is
------------------------------------------------------------------------------------
  p_status            varchar2(200);
  p_msg               varchar2(200);
  l_reserve_id     number;
BEGIN
  l_reserve_id  := sa.sequ_x_merch_ref_id.NEXTVAL;
  --sa.sp_reserve_app_card( l_reserve_id,1, 'REDEMPTION CARDS', P_STATUS, P_MSG);
  sa.sp_reserve_app_card( p_reserve_id => l_reserve_id,
                          p_total      => 1,
                          p_domain     =>'REDEMPTION CARDS',
						  p_consumer   => p_consumer,--CR42260
                          p_status     =>P_STATUS,
                          p_msg        =>P_MSG); --CR42660

  IF p_msg          != 'Completed' THEN
    op_err_code    := 4;
    l_err_num := '1009';
    op_err_msg := 'SP_RESERVE_APP_CARD'||':'||p_status||':'||p_msg;
    UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => '1009',
                               IP_KEY => out_soft_pin,
                               IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.gen_softpin',
                               ip_error_text => op_err_msg);
    RETURN;
  END IF;
  ---
BEGIN
    SELECT x_red_card_number,x_smp
    into  out_soft_pin,
          out_smp
    FROM table_x_cc_red_inv
    WHERE x_reserved_id = l_reserve_id;
    op_err_code := 0;
    op_err_msg  := 'Success';
EXCEPTION
  when others then
  out_soft_pin := -1;
  out_smp := -1;
  op_err_code := 5;
  l_err_num := '1010';
  op_err_msg := 'PIN CODE NOT FOUND';
  UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => l_err_num,
                               IP_KEY => out_soft_pin,
                               IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.gen_softpin',
                               ip_error_text => op_err_msg);
  return;
END;
END gen_softpin;
------------------------------------------------------------------------------------
function found_esn(esn in varchar2,
                   op_esn_objid out number,
                   op_sim        out varchar2, -- CR51737
                   op_esn_status out varchar2,
                   esn_part_num out varchar2,
                   op_err_code out number,
                   op_err_msg out varchar2)
return boolean is
------------------------------------------------------------------------------------
begin
  SELECT pi.objid, pi.x_iccid ,pi.x_part_inst_status, pn.part_number
  into op_esn_objid,op_sim,op_esn_status,esn_part_num
  FROM table_part_num pn,
    table_mod_level ml,
    table_part_inst pi,
    table_bus_org bo
  WHERE 1                     = 1
  AND ml.part_info2part_num   = pn.objid
  AND Pi.N_Part_Inst2part_Mod = Ml.Objid
  AND Pi.Part_Serial_No       = ESN
  AND Pn.Part_Num2bus_Org     = Bo.Objid;
 return true;
exception
 when others then
  op_err_code := -1;
  l_err_num  := '1011';
  op_err_msg := 'ESN Not Found';
  UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => l_err_num,
                               IP_KEY => esn,
                               IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.found_esn',
                               ip_error_text => op_err_msg);
   return false;
end found_esn;
------------------------------------------------------------------------------------
function found_part_number(partnum in varchar2,
                           op_ml_objid out number,
                           op_pp_objid out number,
                           op_prgm_part out varchar2,
                           op_err_code out number,
                           op_err_msg out varchar2)
return boolean is
------------------------------------------------------------------------------------
begin
    select x_ff_objid,
           ml.objid,
           ff.x_target_part_num2
    into  op_pp_objid,
          op_ml_objid,
          op_prgm_part
    from x_ff_part_num_mapping ff,
         table_part_num pn,
         table_mod_level ml
    where ff.x_source_part_num = pn.part_number
    and pn.objid = ml.part_info2part_num
    and ff.x_target_part_num1 is not null
    and ff.x_target_part_num2 is not null
    and pn.part_number = partnum;
  return true;
exception
  when others then
  op_err_code := -1;
  l_err_num  := '1012';
  op_err_msg := 'Part Number Not Found';
  UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => l_err_num ,
                               IP_KEY => partnum,
                               IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.found_part_number',
                               ip_error_text => op_err_msg);
   return false;
end found_part_number;
------------------------------------------------------------------------------------
function get_expdate(p_esn in varchar2) return date is
------------------------------------------------------------------------------------
cur_exp date;
forecast_exp date;
begin

    select nvl(max(x_expire_dt),sysdate)
    into cur_exp
    from table_site_part sp
    where sp.part_status = 'Active'
    and  sp.x_service_id = p_esn;

    SELECT cur_exp + NVL(SUM(x_redeem_days),0)
    into forecast_exp
    FROM table_part_inst pi_esn,
      table_part_inst pi_qc,
      table_mod_level ml,
      table_part_num pn
    WHERE 1                         =1
    AND pi_esn.part_serial_no       = p_esn
    AND pi_esn.x_domain             = 'PHONES'
    AND pi_qc.part_to_esn2part_inst = pi_esn.objid
    AND pi_qc.x_part_inst_status    = '400'
    AND ml.objid                    = pi_qc.n_part_inst2part_mod
    AND PN.OBJID                    = ML.PART_INFO2PART_NUM;

 return forecast_exp;
end;
------------------------------------------------------------------------------------
function get_next_charge_date(ip_esn in varchar2, ip_objid in number) return date is
------------------------------------------------------------------------------------
l_next_charge_date date;
begin
    begin
      SELECT pe.X_NEXT_CHARGE_DATE
         INTO  l_next_charge_date
           FROM X_Program_Enrolled pe,
           x_ff_part_num_mapping ff
          WHERE 1                 =1
          AND  pe.PGM_ENROLL2PGM_PARAMETER = ff.x_ff_objid
          AND pe.x_esn               = ip_esn--'100000000013382865'
          AND pe.x_enrollment_status in( 'ENROLLED')
          and pe.PGM_ENROLL2PGM_PARAMETER = ip_objid;
          Exception
          when others then
            return null;
    end;
    return l_next_charge_date;
end;
------------------------------------------------------------------------------------
procedure deenroll_if_needed(ip_esn in varchar2,
                             ip_cycle_start_date date,
                             ip_pp_objid in number) is
------------------------------------------------------------------------------------
/*l_enroll_objid number;
l_wu_objid number;
l_sp_objid number;
l_next_charge_date date;
l_pp_objid number*/
begin
    --CR43498
      for i in ( SELECT objid                    l_enroll_objid,
                        Pgm_Enroll2web_User      l_wu_objid,
                        pgm_enroll2site_part     l_sp_objid,
                        X_NEXT_CHARGE_DATE       l_next_charge_date,
                        Pgm_Enroll2pgm_Parameter l_pp_objid
                 FROM   X_Program_Enrolled
                 WHERE  1            =1
                 AND    x_esn               = Ip_Esn
                 AND    x_enrollment_status in( 'ENROLLED')
                 AND    EXISTS
                   (SELECT 1
                   FROM x_program_parameters pp
                   where PP.OBJID = PGM_ENROLL2PGM_PARAMETER
                   AND upper(x_program_name) LIKE '%B2B'
        ) )loop
   -- if ( l_pp_objid = ip_pp_objid ) then
    --   return;  -- new plan and old plan are the same, so no change reqd.
   -- end if;
    UPDATE x_program_enrolled
    SET x_enrollment_status = 'READYTOREENROLL',
        X_NEXT_CHARGE_DATE  = null--decode(trunc(ip_cycle_start_date),trunc(sysdate), NULL,ip_cycle_start_date)
    WHERE OBJID  = i.l_enroll_objid;

  INSERT INTO x_program_trans
    ( objid,
      x_enrollment_status,
      x_enroll_status_reason,
      x_trans_date,
      x_action_text,
      x_action_type,
      x_reason,
      x_sourcesystem,
      x_esn,
      x_update_user,
      pgm_tran2pgm_entrolled,
      pgm_trans2web_user,
      pgm_trans2site_part)
  VALUES
    ( billing_seq ('x_program_trans'),
      'ENROLLED',    --CHECK
      'DeEnrollment Scheduled',
      SYSDATE,
      'Plan Change DeEnrollment',
      'DE_ENROLL',
      'B2B Customer Plan Change DeEnrollment',
      'System',
      Ip_Esn,
      'operations',
      i.l_enroll_objid,
      i.l_wu_objid,
      i.l_sp_objid);

  INSERT INTO x_billing_log
    ( objid,
      x_log_category,
      x_log_title,
      x_log_date,
      x_details,
      x_nickname,
      x_esn,
      x_originator,
      x_contact_first_name,
      x_contact_last_name,
      x_agent_name,
      x_sourcesystem,
      billing_log2web_user)
    VALUES
    ( billing_seq ('X_BILLING_LOG'),
      'Program',
      'Program De-enrolled',
      SYSDATE,
      'B2B Customer Plan Change DeEnrollment',
      billing_getnickname (Ip_Esn),
      Ip_Esn,
      'System',
      'N/A',
      'N/A',
      'System',
      'System',
      i.l_wu_objid);
  end loop;
exception
  when others then
  l_err_num  := '1013' ;
 UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => l_err_num,
                               IP_KEY => ip_esn,
                               IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.deenroll_if_needed',
                               ip_error_text => 'Fulfillment Plan Change');
end deenroll_if_needed;
------------------------------------------------------------------------------------
PROCEDURE PROVISION_SERVICE_PLAN(
    in_order_id         IN  x_biz_purch_hdr.c_orderid%TYPE,
    in_account_id       IN  table_web_user.login_name%TYPE,
    in_bus_org_id       IN  table_bus_org.org_id%TYPE,
    in_organization_id  IN  table_site.x_commerce_id%TYPE, -- Organization ID as passed commerce --CR47608
    in_paymentsourceid  IN  x_payment_source.objid%Type,
    io_esn_part_num     IN  OUT esn_part_num_tbl,
    out_err_num         OUT NUMBER,
    out_err_message     OUT VARCHAR2,
    p_consumer          IN  VARCHAR2 DEFAULT NULL,--CR42260
    i_ship_loc_id       IN  table_site.x_ship_loc_id%TYPE -- Organization ID as passed by OFS   --CR47608
    )
IS
pragma autonomous_transaction;
------------------------------------------------------------------------------------
  missing_inp_excp exception;
  v_org_objid number;
  v_wu_objid number;
  v_dlr_invbin_objid number;
  v_soft_pin varchar2(50);
  v_ml_objid number;
  v_pp_objid number;
  v_esn_objid number;
  v_esn_status varchar2(10);
  v_sim       varchar2(50); -- CR51737
  v_esn_part_num varchar2(50);
  v_prgm_part varchar2(250);
  v_smp number;
  v_enroll_status varchar2(30):= 'ENROLLMENTPENDING';
  v_cycle_start_date date;
  v_keys_tbl keys_tbl := Keys_Tbl();
  --l_out_msg varchar2(300);
  v_site_objid number;
  l_is_lineitem_errored  varchar2(1);
  l_is_header_errored    varchar2(1);
  --v_esn_part_num  Esn_Part_Num_Tbl:= Esn_Part_Num_Tbl();
  c_program_name         varchar2(200);
  typ_key_obj       Keys_tbl := keys_tbl();
  --CR47608
  v_esn_nickname       table_x_contact_part_inst.x_esn_nick_name%TYPE;
BEGIN
   --
   validate_inputs(IN_ORDER_ID,
                 In_Paymentsourceid,
                 in_account_id,
                 in_bus_org_id,
                 in_organization_id,
                 io_esn_part_num.count,
                 v_org_objid,
                 v_wu_objid,
                 v_dlr_invbin_objid,
                 v_site_objid,
                 out_err_num ,
                 out_err_Message,
                 i_ship_loc_id) ;--CR47608
  if  out_err_num    <> 0 then
    -- l_out_msg:= out_err_Message;
    raise missing_inp_excp;
  end if;


  l_is_header_errored  := 'N';

  FOR i IN 1..io_esn_part_num.last
  LOOP
    -- CR46176 Start Marry the SIM with ESN if the value is passed in key value input.
    --CR47608 SETTING VARIABLE TO NULL
    v_esn_nickname := NULL;
    begin
        if io_esn_part_num(i).in_key_obj.count > 0 then
          -- Get the sim value from the key value list if passed.
          FOR j IN io_esn_part_num(i).in_key_obj.FIRST..io_esn_part_num(i).in_key_obj.LAST
          LOOP
            IF io_esn_part_num(i).in_key_obj(j).Key_Type = 'SIM' THEN
              UPDATE table_part_inst
              SET x_iccid          = io_esn_part_num(i).in_key_obj(j).Key_Value
              WHERE part_serial_no = io_esn_part_num(i).esn;

              DBMS_OUTPUT.PUT_LINE('Key_Type = SIM' );
            --  EXIT;        --CR47608
            --Added for CR47608 -- To store the Agent ID
            ELSIF io_esn_part_num(i).in_key_obj(j).Key_Type = 'AGENT_ID'
            THEN
              UPDATE x_biz_purch_hdr
              SET    agent_id  = io_esn_part_num(i).in_key_obj(j).Key_Value
              WHERE  c_orderid  = in_order_id;

            DBMS_OUTPUT.PUT_LINE('IN_ORDER_ID = ' || IN_ORDER_ID);
            DBMS_OUTPUT.PUT_LINE('Key_Type = AGENT_ID' );
            DBMS_OUTPUT.PUT_LINE('Key_Value = ' || io_esn_part_num(i).in_key_obj(j).Key_Value);
            --Added for CR47608 -- To UPDATE ESN NICK NAME
            ELSIF io_esn_part_num(i).in_key_obj(j).Key_Type = 'NICKNAME' AND io_esn_part_num(i).in_key_obj(j).Key_Value IS NOT NULL
            THEN
              v_esn_nickname := io_esn_part_num(i).in_key_obj(j).Key_Value;
             DBMS_OUTPUT.PUT_LINE('Key_Type = NICKNAME' );
             DBMS_OUTPUT.PUT_LINE('Key_Value = ' || io_esn_part_num(i).in_key_obj(j).Key_Value);
            END IF;
          END LOOP;
        end if;
    exception when others then
      null;
    end;
    -- CR46176 End

    l_is_lineitem_errored := 'N';
    io_esn_part_num(i).in_key_obj := keys_tbl();

   if not found_esn(io_esn_part_num(i).esn,v_esn_objid,v_sim,v_esn_status,v_esn_part_num,Out_Err_Num,out_err_Message) -- CR51737 added v_sim
       or not found_part_number(io_esn_part_num(i).APP_PART_NUM,v_ml_objid,v_pp_objid,v_prgm_part,Out_Err_Num,out_err_Message) then
       io_esn_part_num(i).in_key_obj.extend;
       io_esn_part_num(i).in_key_obj(io_esn_part_num(i).in_key_obj.last) := keys_obj('Esn Failed',out_err_message, 'Failed');
       UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => '1014: ' || TO_CHAR(Out_Err_Num),
                               IP_KEY => io_esn_part_num(i).esn || ' : Esn/Part Number Not Found',
                               IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN',
                               ip_error_text => out_err_Message);
       l_is_lineitem_errored := 	'Y';
       l_is_header_errored  := 'Y';
       continue;
    end if;

    if v_esn_status not in ('50','51','52','54','150') then
       io_esn_part_num(i).in_key_obj.extend;
       io_esn_part_num(i).in_key_obj(io_esn_part_num(i).in_key_obj.last)  := keys_obj('Esn Status','Invalid for Fulfillment -'||v_esn_status, 'Failed');
       UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => '1015: ' || TO_CHAR(Out_Err_Num),
                               IP_KEY => io_esn_part_num(i).esn || ' : Esn Status Invalid for Fulfillment -'||v_esn_status,
                               IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN',
                               ip_error_text => out_err_Message);
      l_is_lineitem_errored := 	'Y';
      l_is_header_errored  := 'Y';
	  continue;
    else
 --CR39912 - ST Commerce - Allow Multiple PINs in Queue
      /*  queuePin2ESn_validation(io_esn_part_num(i).esn,-- IN table_part_inst.part_serial_no%type,
                                out_err_num ,--OUT NUMBER,
                                out_err_message);--OUT VARCHAR2)
        if ( out_err_message not in ('Success')) then
           io_esn_part_num(i).in_key_obj.extend;
           io_esn_part_num(i).in_key_obj(io_esn_part_num(i).in_key_obj.last) := keys_obj('queuePin2ESn_validation',out_err_message, 'Failed');
           UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION =>'1016: ' || TO_CHAR(Out_Err_Num),
                                 IP_KEY =>  io_esn_part_num(i).esn || ' : ESN Already Has Pin In Queue',
                                 IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.queuePin2ESn_validation',
                                 ip_error_text => out_err_Message);
		   continue;
        end if;*/


        account_services_pkg.addEsntoAccount(io_esn_part_num(i).esn,
                                             in_account_id, --in_login_name   IN table_web_user.login_name%TYPE ,
                                             in_bus_org_id, --IN_ORG_id       IN VARCHAR2, --brand
                                             null,          --in_sourceSystem IN VARCHAR2,
                                             Out_Err_Num,
                                             out_err_Message);
        if ( out_err_message not in ('Success','ESN Already Attached To The Same Account')) then
           io_esn_part_num(i).in_key_obj.extend;
           io_esn_part_num(i).in_key_obj(io_esn_part_num(i).in_key_obj.last) := keys_obj('AddEsnToAccount',out_err_message, 'Failed');
           UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => '1019: ' || TO_CHAR(Out_Err_Num),
                               IP_KEY => IN_ACCOUNT_ID || ' : AddEsnToAccount Failed',
                               IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN',
                               ip_error_text => out_err_Message);
		   l_is_lineitem_errored := 	'Y';
           l_is_header_errored  := 'Y';
           continue;
        end if;

        --CR47608 UPDATING ESN NICK NAME IF PASSED
        IF v_esn_nickname IS NOT NULL
        THEN
        BEGIN
          UPDATE table_x_contact_part_inst Cpi
          SET    x_esn_nick_name = v_esn_nickname
          WHERE  x_contact_part_inst2part_inst = v_esn_objid;
        EXCEPTION
          WHEN OTHERS
          THEN
          -- IGNORE THE ERROR
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
        END;
        END IF;

        --gen_softpin(v_soft_pin,v_smp,out_err_num,out_err_message);
		gen_softpin(p_consumer ,--CR42260,
					v_soft_pin,
					v_smp,
					out_err_num,
					out_err_message);

        if ( out_err_message not in ('Success')) then
           io_esn_part_num(i).in_key_obj.extend;
           io_esn_part_num(i).in_key_obj(io_esn_part_num(i).in_key_obj.last) := keys_obj('gen_softpin',out_err_message, 'Failed');
           UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => '1020: ' || TO_CHAR(Out_Err_Num),
                               IP_KEY => IN_ACCOUNT_ID || ' : gen_softpin Failed',
                               IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN',
                               ip_error_text => out_err_Message);
           l_is_lineitem_errored := 	'Y';
           l_is_header_errored  := 'Y';
		   continue;
        end if;

 ------- FROM THIS POINT WE should not skip without recording the pin
        v_keys_tbl.delete;
        --  DBMS_OUTPUT.PUT_LINE('ESn_status' || v_esn_status);
        queue_pin2esn( v_soft_pin ,
                       v_smp,
                       v_dlr_invbin_objid,
                       v_site_objid,
                       null,--      p_user_objid,
                       v_ml_objid,
                       io_esn_part_num(I).esn,
                       v_esn_status,
                       v_esn_objid,
                       in_bus_org_id,
                       out_err_num,
                       out_err_message );
        if ( out_err_message not in ('Successful')) then
           io_esn_part_num(i).in_key_obj.extend;
           io_esn_part_num(i).in_key_obj(io_esn_part_num(i).in_key_obj.last) := keys_obj('QueuePin2Esn',out_err_message, 'Failed');
           UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => '1021: ' || TO_CHAR(Out_Err_Num),
                               IP_KEY => IN_ACCOUNT_ID || ' : QueuePin2Esn Failed',
                               IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN',
                               ip_error_text => out_err_Message);

		     l_is_lineitem_errored := 	'Y';
         l_is_header_errored  := 'Y';
        end if;

        if (io_esn_part_num(i).action_type = 'FULFILL_LATER' and
          v_esn_status in ('50','51','54','150')) THEN
            v_cycle_start_date := '';
        elsif(io_esn_part_num(i).action_type = 'FULFILL_NOW'
            and v_esn_status = '52') then
           -- Planchange_Deenroll;
            v_cycle_start_date := sysdate;
            v_enroll_status := '';
        else
            v_cycle_start_date := get_next_charge_date(io_esn_part_num(i).esn,v_pp_objid);
        end if;

          begin
			--CR39912 - ST Commerce - Allow Multiple PINs in Queue Changes
            if(io_esn_part_num(i).action_type = 'FULFILL_NOW' and v_esn_status = '52') then
               deenroll_if_needed(io_esn_part_num(I).esn,v_cycle_start_date,v_pp_objid);
            end if;
            DBMS_OUTPUT.PUT_LINE(v_pp_objid);
             billing_inserts_pkg.inserts_billing_proc(io_esn_part_num(I).esn,
                                                   v_pp_objid,
                                                   v_wu_objid,
                                                   in_paymentsourceid,
                                                   v_cycle_start_date,
                                                   'WEB',
                                                   out_err_num,
                                                   out_err_message,
                                                   v_enroll_status);
    --CR39912 - ST Commerce - To fix the Linelevel errors
              if ( out_err_message not in ('Inserts are Successful')) then
                io_esn_part_num(i).in_key_obj.extend;
                io_esn_part_num(i).in_key_obj(io_esn_part_num(i).in_key_obj.last) := keys_obj('PLANCHANGE/ENROLLMENT',out_err_message, 'Failed');
                UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => '1022: ' || TO_CHAR(Out_Err_Num),
                         IP_KEY => IN_ACCOUNT_ID || ' : Planchange/Enrollment Failed',
                         IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN' ,
                         ip_error_text => out_err_Message);
                l_is_lineitem_errored :=  'Y';
                l_is_header_errored  := 'Y';
              end if;
   --- CR 43498 - Data Club START
   -- UPDATE X_PROGRAM_ENROLLED WITH THE VALUES PASSED FOR IS_ENROLLED FLAG AND AUTO REFILL LIMIT
   -----
              begin
               select x_program_name
               into c_program_name
               from x_program_parameters
               where  objid    = v_pp_objid;
             exception
              when others then
               UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => '1025: ' || TO_CHAR(sqlerrm),
                  IP_KEY => IN_ACCOUNT_ID || ' : Planchange/Enrollment Failed',
                  IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN' ,
                  ip_error_text => sqlerrm);
                return;
             end;

          IF c_program_name  like '%Data Club Plan%B2B' and upper( io_esn_part_num(i).is_enrolled) = 'Y' THEN
            update x_program_enrolled
            set --x_enrollment_status   = decode(upper( io_esn_part_num(i).is_enrolled),'Y','ENROLLED',x_enrollment_status),
                auto_refill_max_limit = nvl(io_esn_part_num(i).autorefill_max_limit,999),
                auto_refill_counter   = 0
            where
                x_esn                    = io_esn_part_num(I).esn
            and Pgm_Enroll2pgm_Parameter = v_pp_objid
            and x_enrollment_status      in ('ENROLLMENTPENDING','ENROLLED');

            if sql%rowcount > 1 then
               v_keys_tbl.extend;
               v_keys_tbl(v_keys_tbl.last) := keys_obj('DUPLICATE ESN FOUND:- ',io_esn_part_num(I).esn, 'Failed');

               UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => '1024: ' || TO_CHAR(Out_Err_Num),
                    IP_KEY => IN_ACCOUNT_ID || ' : Planchange/Enrollment Failed',
                    IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN' ,
                    ip_error_text => out_err_Message);
            end if;
            if sql%rowcount = 0 then
               v_keys_tbl.extend;
               v_keys_tbl(v_keys_tbl.last) := keys_obj('No ESN TO update:- ',io_esn_part_num(I).esn, 'Failed');
               out_err_Message := 'No records to update';
               UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => '1025: ' || TO_CHAR(v_pp_objid),
                    IP_KEY => IN_ACCOUNT_ID || ' : Planchange/Enrollment Failed',
                    IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN' ,
                    ip_error_text => out_err_Message);
            end if;
          end if;
   --- CR 43498 - Data Club END
           exception
             when others then
              io_esn_part_num(i).in_key_obj.extend;
              io_esn_part_num(i).in_key_obj(io_esn_part_num(i).in_key_obj.last) := keys_obj('PLANCHANGE/ENROLLMENT',SUBSTR (SQLERRM, 1, 300), 'Failed');
             UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => '1022: ' || TO_CHAR(Out_Err_Num),
                                 IP_KEY => IN_ACCOUNT_ID || ' : Planchange/Enrollment Failed',
                                 IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN' ,
                                 ip_error_text => out_err_Message);
              l_is_lineitem_errored :=  'Y';
              l_is_header_errored  := 'Y';
           end;

       IF l_is_lineitem_errored = 'N' THEN
        v_keys_tbl.extend;
        v_keys_tbl(v_keys_tbl.last) := keys_obj('PIN', V_Soft_Pin, 'Success');
        v_keys_tbl.extend;
        v_keys_tbl(v_keys_tbl.last) := keys_obj('Forecast_date',
                  get_expdate(io_esn_part_num(i).esn) ,
                  'Success');
        io_esn_part_num(i).in_key_obj := v_keys_tbl;
        io_esn_part_num(i).Confirmationid := v_smp;
       END IF;
    end if;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('l_is_lineitem_errored ' || l_is_lineitem_errored);
  DBMS_OUTPUT.PUT_LINE('l_is_header_errored ' || l_is_header_errored);
  DBMS_OUTPUT.PUT_LINE('out_err_Message ' || out_err_Message);

--CR39912 - ST Commerce - To fix the Linelevel errors
--if out_err_Message is null then
  if  l_is_header_errored = 'N' then
    Out_Err_Num := 0;
    out_err_Message := 'Success';
  elsif l_is_header_errored = 'Y' then
    Out_Err_Num := -1;
    out_err_Message := 'Failed';
  end if;

 Commit;
exception
  when missing_inp_excp then
  ROLLBACK; -- CR31683
  UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => '1023: ' || TO_CHAR(Out_Err_Num),
                               IP_KEY => IN_ACCOUNT_ID,
                               IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN',
                               ip_error_text => out_err_Message);
 -- CR31683x
 when others then
 ROLLBACK; -- CR3168
  Out_Err_Num  := SQLCODE;
  out_err_Message := SUBSTR (SQLERRM, 1, 300);
 UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => l_err_num,
                               IP_KEY => NULL,
                               IP_PROGRAM_NAME => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN',
                               ip_error_text => out_err_Message);
 END PROVISION_SERVICE_PLAN;
 --
--  CR48480 changes starts...
--  Procedure to generate soft pin and queue it to ESN
--  this procedure is called for B2C mixed (tangible and intangible) orders
--
PROCEDURE provision_service_plan_b2c( i_bus_org_id          IN  VARCHAR2,
                                      i_consumer            IN  VARCHAR2  DEFAULT NULL,
                                      i_order_id            IN  VARCHAR2,   -- CR51737
                                      io_esn_part_num       IN OUT Esn_Part_Num_Tbl,
                                      o_err_msg             OUT VARCHAR2,
                                      o_err_code            OUT VARCHAR2)
IS
--
  n_esn_objid             NUMBER;
  c_esn_status            VARCHAR2(10);
  c_esn_part_num          VARCHAR2(50);
  c_smp                   VARCHAR2(50);
  c_soft_pin              VARCHAR2(50);
  c_sim                   VARCHAR2(50); -- CR51737
  c_is_lineitem_errored   VARCHAR2(1)   :=  'N';
  c_is_header_errored     VARCHAR2(1)   :=  'N';
  l_keys_tbl              keys_tbl := Keys_Tbl();
--
BEGIN
--
  -- Input Validation
  -- CR51737 starts..
  IF i_order_id   IS NULL
  THEN
    o_err_code  := 100;
    o_err_msg   := 'ORDER ID CANNOT BE NULL';
    RETURN;
  END IF;
  -- CR51737 Ends.
  --
  IF io_esn_part_num is NULL
  THEN
    o_err_code  := 101;
    o_err_msg   := 'INPUT LINE ITEM IS NULL';
    RETURN;
  END IF;
  --
  FOR i IN 1..io_esn_part_num.LAST
  LOOP
    io_esn_part_num(i).in_key_obj := keys_tbl();
    -- check whether ESN is in Database
    IF NOT found_esn( esn             =>    io_esn_part_num(i).esn,
                      op_esn_objid    =>    n_esn_objid,
                      op_sim          =>    c_sim,  -- CR51737
                      op_esn_status   =>    c_esn_status,
                      esn_part_num    =>    c_esn_part_num,
                      op_err_code     =>    o_err_code,
                      op_err_msg      =>    o_err_msg)      OR
       io_esn_part_num(i).app_part_num IS NULL
    THEN
      io_esn_part_num(i).in_key_obj.extend;
      io_esn_part_num(i).in_key_obj(io_esn_part_num(i).in_key_obj.last) := keys_obj('Esn Failed',o_err_msg, 'FAILED');
      util_pkg.insert_error_tab_proc( ip_action       => '1014: ' || TO_CHAR(o_err_code),
                                      ip_key          => io_esn_part_num(i).esn || ' : Esn/Part Number Not Found',
                                      ip_program_name => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN_B2C',
                                      ip_error_text   => o_err_msg);
      c_is_lineitem_errored := 	'Y';
      c_is_header_errored   :=  'Y';
      CONTINUE;
    END IF;
    --
    -- Check for ESN status
    IF c_esn_status NOT IN ('50','51','52','54','150')
    THEN
      --
      io_esn_part_num(i).in_key_obj.extend;
      io_esn_part_num(i).in_key_obj(io_esn_part_num(i).in_key_obj.last)  := keys_obj('Esn Status','Invalid for Fulfillment -'||c_esn_status, 'Failed');
      util_pkg.insert_error_tab_proc(ip_action        => '1015: ' || TO_CHAR(o_err_code),
                                     ip_key           => io_esn_part_num(i).esn || ' : Esn Status Invalid for Fulfillment -'||c_esn_status,
                                     ip_program_name  => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN_B2C',
                                     ip_error_text    => o_err_msg);
      c_is_lineitem_errored := 	'Y';
      c_is_header_errored  := 'Y';
      CONTINUE;
      --
    ELSE
      --
      -- Get the reserved softpin
      red_card.p_get_reserved_softpin ( i_esn             =>    io_esn_part_num(i).esn,
                                        i_pin_part_num    =>    io_esn_part_num(i).app_part_num,
                                        i_inv_bin_objid   =>    0,
                                        o_soft_pin        =>    c_soft_pin,
                                        o_smp_number      =>    c_smp,
                                        o_err_str         =>    o_err_msg,
                                        o_err_num         =>    o_err_code,
                                        i_consumer        =>    i_consumer);
      --
      IF ( o_err_msg not in ('SUCCESS'))
      THEN
        io_esn_part_num(i).in_key_obj.extend;
        io_esn_part_num(i).in_key_obj(io_esn_part_num(i).in_key_obj.last) := keys_obj('gen_softpin',o_err_msg, 'Failed');
        util_pkg.insert_error_tab_proc(  ip_action        => '1020: ' || TO_CHAR(o_err_code),
                                         ip_key           => io_esn_part_num(i).esn || ' : p_get_reserved_softpin Failed',
                                         ip_program_name  => 'Full_Fillment_Services_pkg.PROVISION_SERVICE_PLAN_B2C',
                                         ip_error_text    => o_err_msg);
        c_is_lineitem_errored := 	'Y';
        c_is_header_errored   :=  'Y';
        CONTINUE;
      END IF;
      --
      IF o_err_code = 0 AND o_err_msg = 'SUCCESS' AND c_soft_pin IS NOT NULL
      THEN
        -- Update the PIN status to RESERVED QUEUED and attach it to ESN
        UPDATE  table_part_inst
        SET     x_part_inst_status    = '400',  -- RESERVED QUEUED
                status2x_code_table   = ( SELECT  objid
                                          FROM    table_x_code_table
                                          WHERE   x_code_number = '400'),
                part_to_esn2part_inst = ( SELECT  objid
                                          FROM    table_part_inst
                                          WHERE   part_serial_no  = io_esn_part_num(i).esn
                                          AND     x_domain        = 'PHONES')
        WHERE   x_red_code  =   c_soft_pin
        AND     x_domain    =   'REDEMPTION CARDS';
        --
        -- CR51737 changes starts..
        INSERT INTO x_biz_order_fulfill_dtl
                ( order_id,
                  esn,
                  sim,
                  smp,
                  app_part_number
                )
        VALUES  ( i_order_id,
                  io_esn_part_num(i).esn,
                  c_sim,
                  c_smp,
                  io_esn_part_num(i).app_part_num
                );
        --  update the SMP in x_biz_order_dtl to handle returns better
        UPDATE  x_biz_order_dtl
        SET     x_item_value         =  c_smp
        WHERE   x_ecom_order_number  =  i_order_id
        AND     x_item_part          =  io_esn_part_num(i).app_part_num
        AND     x_item_value         IS NOT NULL
        AND     ROWNUM               =  1;
        -- CR51737 changes ends.
        --
      END IF;
      --
      IF c_is_lineitem_errored = 'N'
      THEN
        l_keys_tbl.extend;
        l_keys_tbl(l_keys_tbl.last) := keys_obj('PIN', c_soft_pin, 'SUCCESS');
        io_esn_part_num(i).in_key_obj     := l_keys_tbl;
        io_esn_part_num(i).Confirmationid := c_smp;
      END IF;
      --
    END IF;
    --
  END LOOP;
  --
  IF  c_is_header_errored = 'N'
  THEN
    o_err_code  := 0;
    o_err_msg   := 'SUCCESS';
  ELSIF c_is_header_errored = 'Y'
  THEN
    o_err_code  := 99;
    o_err_msg   := 'FAILED';
  END IF;
--
EXCEPTION
WHEN OTHERS THEN
  o_err_code    :=  SQLCODE;
  o_err_msg     :=  SUBSTR (SQLERRM, 1, 300);
END  provision_service_plan_b2c;
--
-- CR48480 changes ends.
END FULL_FILLMENT_SERVICES_pkg;
/