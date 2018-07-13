CREATE OR REPLACE PACKAGE BODY sa."SP_PURCHASE" IS
 /*****************************************************************************************************************************
 * Package Name: SA.sp_PURCHASE
 *
 * Created by: YM
 * Date: 10/07/2010
 *
 * History
 * --------------------------------------------------------------------------------------------------------------------------------------------------
 * 10/25/2010 YM CR11553 Initial Version
 * 04/20/2011 YM CR14282 Add logic for buy now
 * 05/05/2011 YM CR14282 Change date for sysdate and round(x,2)
 * 05/10/2011 YM CR16392 Change insert_purch_hdr flip tax_amount with x_combs_tax_amount
 *****************************************************************************************************************************/

PROCEDURE Insert_Purch_Det (IP_partnumbers IN VARCHAR2, /* (comma separated part number for each pin card redemptions all are validate) */
 Ip_PurchHdr_Objid IN VARCHAR2,
 Ip_Merch_Ref_Id IN VARCHAR2,
 Ip_SourceSystem IN VARCHAR2,
 Ip_Brand_Name IN VARCHAR2,
 Ip_Esn_Objid IN NUMBER,
 Ip_UserID IN VARCHAR2,
 Ip_Pincards IN varchar2, /* (comma separated pin card redemptions all have the same merch_ref_id) */
 Op_RedCards_PartInst_Objids OUT VARCHAR2, /*(comma separated unique part inst objids) */
 Op_PurchDtl_Objids OUT VARCHAR2, /* (comma separated unique objids) */
 Op_redcodes OUT varchar2, /* (coma separated unique card numbers ) */
 Op_TotalCount OUT NUMBER,
 op_result OUT NUMBER,
 Op_ErrorNum OUT VARCHAR2,
 Op_ErrorMsg OUT VARCHAR2 ) IS
 validate_pricing_exc EXCEPTION;
 validate_merchant_exc EXCEPTION;
 validate_mod_level_exc EXCEPTION;
 validate_ESN_exc EXCEPTION;
 validate_bin_exc EXCEPTION;
 validate_code_exc EXCEPTION;
 i NUMBER;
 k NUMBER;
 pcount NUMBER;
 v_new_pi_objid NUMBER;
 v_new_red_card NUMBER;
 v_new_purch_dtl NUMBER;
 v_price NUMBER;
 v_units NUMBER;
 v_days NUMBER;
 v_result NUMBER;
 L_VAR1 Table_part_inst.x_red_code%TYPE;
 L_VAR2 Table_X_CC_Red_Inv.x_red_card_number%TYPE;
 V_merch_ref_id Table_X_CC_Red_Inv.x_reserved_id%TYPE;
 L_STRING VARCHAR2(1000);
 L_STRING2 VARCHAR2(1000);
 L2_STRING VARCHAR2(1000);
 L3_STRING VARCHAR2(1000);
 V_pn table_part_num.part_number%TYPE;
 P_STATUS VARCHAR2(200);
 P_MSG VARCHAR2(200);
 --
 -- For this procedure execute successfull should be true:
 -- Numbers of part number inside IP_partnumbers (list of part number) equal
 -- Numbers of pin card in Ip_Merch_Ref_Id
 --
 -- structure for save partnumber input

 TYPE name_record1 is record ( pn table_part_num.part_number%TYPE,
 price table_x_pricing.x_retail_price%TYPE,
 units table_part_num.x_redeem_units%TYPE,
 days table_part_num.x_redeem_days%TYPE,
 mod_level table_mod_level.objid%TYPE );
 TYPE dim1 is table of name_record1 index by binary_integer;
 t_dim1 dim1;

 -- structure for save pin card of Table_X_CC_Red_Inv
 TYPE name_record2 is record ( pin Table_X_CC_Red_Inv.x_red_card_number%TYPE,
 X_SMP Table_X_CC_Red_Inv.X_SMP%TYPE,
 X_Merch Table_X_CC_Red_Inv.x_reserved_id%TYPE );

 TYPE dim2 is table of name_record2 index by binary_integer;
 t_dim2 dim2;

 -- structure for save objid of Table_x_Purch_dtl
 TYPE name_record3 is record ( ob_pudtl Table_x_Purch_dtl.objid%TYPE);
 TYPE dim3 is table of name_record3 index by binary_integer;
 t_dim3 dim3;


Cursor Mod_Cur(V1_Pn In Varchar2) Is
select m2.objid
from table_mod_level m2, table_part_num pn2
where 1=1
 AND pn2.part_number = V1_pn
 AND m2.part_info2part_num = pn2.objid
 order by m2.eff_date desc;

mod_rec mod_cur%rowtype;

cursor ESN_cur is
select objid, part_serial_no
from table_part_inst
where objid = Ip_Esn_Objid ;

esn_rec esn_cur%rowtype;


cursor CC_INV_CUR is
Select x_red_card_number,X_SMP
 from Table_X_CC_Red_Inv
where x_reserved_id = Ip_Merch_Ref_Id ;

CC_INV_REC CC_INV_CUR%rowtype;


cursor CC_INV_ID_CUR(v_pin in varchar2) is
Select x_reserved_id, X_SMP
 from Table_X_CC_Red_Inv
where x_red_card_number = v_pin;

CC_INV_ID_REC CC_INV_ID_CUR%rowtype;

cursor INV_BIN_CUR is
SELECT table_inv_bin.objid
FROM table_inv_bin, table_inv_role, table_inv_locatn, table_site
WHERE table_inv_role.inv_role2site = table_site.objid
AND table_inv_role.inv_role2inv_locatn = table_inv_locatn.objid
AND table_inv_bin.inv_bin2inv_locatn = table_inv_locatn.objid
AND table_site.site_id = '7882';

INV_BIN_REC INV_BIN_CUR%rowtype;

cursor code_CUR is
select objid
from table_x_code_table
where x_code_number = '40';

code_REC code_CUR%rowtype;

lv_generate_red_card  varchar2(10) := 'YES'; --CR30286

BEGIN
 i := 1;
 k := 1;
 op_result := 0;
 Op_ErrorNum :='0';
 Op_ErrorMsg := '';
 L_STRING := IP_partnumbers; -- ini with group of part number
 L_STRING2 := IP_Pincards; -- ini with group of pin card
 pcount := 0;
 v_new_pi_objid := 0;
 v_new_red_card :=0;
 v_new_purch_dtl := 0;
 v_price := 0;
 v_units := 0;
 v_days := 0;
 v_result := 0;

 IF Ip_Merch_Ref_Id is NULL THEN

 LOOP
 L_VAR2 := NVL(SUBSTR(L_STRING2,1,INSTR(L_STRING2,',',1)-1),L_STRING2);
 L_STRING2 := TRIM(SUBSTR(L_STRING2,length(L_VAR2)+2,length(L_STRING2)));

 open cc_inv_id_cur(L_VAR2);
 fetch cc_inv_id_cur into cc_inv_id_rec;

 if cc_inv_id_cur%notfound then
 close cc_inv_id_cur;
 Op_ErrorMsg := 'not exist merchant_id for this pin card'||L_VAR2;
 raise validate_merchant_exc;
 end if;

 DBMS_OUTPUT.PUT_LINE('PIN CARD : '||L_VAR2);
 t_dim2(i).pin := L_VAR2;
 t_dim2(i).X_SMP := cc_inv_ID_rec.X_SMP;
 t_dim2(i).X_merch := cc_inv_ID_rec.x_reserved_id;
 DBMS_OUTPUT.PUT_LINE('Pin Card: '||t_dim2(i).pin);

 i:=i+1;
 commit;
 EXIT WHEN L_STRING2 is null;
 END LOOP;

 ELSE
 FOR cc_inv_rec IN cc_inv_cur
 LOOP

 t_dim2(i).pin := cc_inv_rec.x_red_card_number;
 t_dim2(i).X_SMP := cc_inv_rec.X_SMP;
 t_dim2(i).X_merch := Ip_Merch_Ref_Id;
 DBMS_OUTPUT.PUT_LINE('Pin Card: '||t_dim2(i).pin);

 i:=i+1;
 End Loop;
 If i = 1 Then
 Op_Errornum := 0;
 Op_Errormsg := 'No records for this merchant';
 Return;
 end if;
 END IF;

 open inv_bin_cur;
 fetch inv_bin_cur into inv_bin_rec;

 if inv_bin_cur%notfound then
 close inv_bin_cur;
 Op_ErrorMsg := 'not exist inv_bin value. ';
 raise validate_bin_exc;
 end if;

 open code_cur;
 fetch code_cur into code_rec;

 if code_cur%notfound then
 close code_cur;
 Op_ErrorMsg := 'not exist code_table value.';
 raise validate_code_exc;
 end if;

 op_RedCards_PartInst_Objids :='';
 Op_PurchDtl_Objids :='';
 Op_redcodes :='';
 i:= 1;

 LOOP
 L_VAR1 := NVL(SUBSTR(L_STRING,1,INSTR(L_STRING,',',1)-1),L_STRING);
 L_STRING := TRIM(SUBSTR(L_STRING,length(L_VAR1)+2,length(L_STRING)));

 DBMS_OUTPUT.PUT_LINE('Part Number: '||L_VAR1);

 t_dim1(i).pn := L_VAR1;
 pcount := pcount + 1;
/*
 open pricing_cur(L_VAR1);
 fetch pricing_cur into pricing_rec;

 if pricing_cur%notfound then
 close pricing_cur;
 Op_ErrorMsg := 'pricing not found: '||L_VAR1;
 raise validate_pricing_exc;
 end if;*/
 sa.sp_metadata.getprice_tot(L_VAR1,Ip_SourceSystem,v_price,v_units,v_days,v_result);

       /* CR30286 (CR29021) Safelink e911 changes starts  */
      lv_generate_red_card := 'YES';
      declare

        cursor cur_enrollment (in_esn in varchar2, in_part_number in varchar2) is
          select
            pe.objid                     as pe_objid,
            sub.zip                      as prog_zipcode,
            pe.pgm_enroll2pgm_parameter  as prog_objid
          from x_program_enrolled pe,
            x_sl_currentvals val,
            x_sl_subs sub,
            x_program_parameters pp,
            mtm_program_safelink mtm
          where 1=1
          and pe.x_esn = in_esn
          and val.x_current_esn = pe.x_esn
          and sub.lid = val.lid
          and pe.x_enrollment_status = 'ENROLLED'
          and pp.objid = pe.pgm_enroll2pgm_parameter
          and pp.x_prog_class = 'LIFELINE'
          and mtm.program_param_objid = pp.objid
          and mtm.program_provision_flag = '3'
          and sysdate between mtm.start_date and mtm.end_date
          and mtm.part_num_objid in (
                  select objid
                  from table_part_num
                  where 1=1
                  and part_number = in_part_number
                                    and domain = 'REDEMPTION CARDS'
                  )
          ;

        rec_enrollment    cur_enrollment%rowtype;

      begin
          open esn_cur;
          fetch esn_cur into esn_rec;
          close esn_cur;

          if esn_rec.part_serial_no is not null then
            open cur_enrollment(esn_rec.part_serial_no, L_VAR1);
            fetch cur_enrollment into rec_enrollment;
            close cur_enrollment ;

            if rec_enrollment.pe_objid is not null
              and rec_enrollment.prog_zipcode is not null then
              --calculate purchase amount for this part number
              --since safelink e911 amount is based on zipcode,
              --So, use existing function to get the price
              v_price := sa.sp_taxes.computee911surcharge2(rec_enrollment.prog_zipcode);
              v_units := 0;
              v_days  := 0;

              v_result := 0 ;

              --mark a flag to avoid insert in table_x_red_card
              --in case of e911 part purchase, there should be no entry in table_x_red_card, table_aprt_inst
              lv_generate_red_card := 'NO';
            end if;

          end if;

      exception
          when others then
              null;
      end;
      /* CR29021 Safelink e911 changes ends */

 if v_result = 0 then
 t_dim1(i).price:=v_price;
 t_dim1(i).units:=v_units;
 t_dim1(i).days:=v_days;
 DBMS_OUTPUT.PUT_LINE('pricing: '||to_char(t_dim1(i).price));
 DBMS_OUTPUT.PUT_LINE('units: '||to_char(t_dim1(i).units));
 else
 Op_ErrorMsg := 'pricing not found: '||L_VAR1;
 raise validate_pricing_exc;
 end if;
 open mod_cur(L_VAR1);
 fetch mod_cur into mod_rec;

 if mod_cur%notfound then
 close mod_cur;
 Op_ErrorMsg := 'mod level not found: '||L_VAR1;
 raise validate_mod_level_exc;
 end if;
 t_dim1(i).mod_level:=mod_rec.objid;
 DBMS_OUTPUT.PUT_LINE('objid mod level: '||to_char(t_dim1(i).mod_level));
 close mod_cur;

 if nvl(lv_generate_red_card,'YES') = 'YES' then -- CR30286

 open esn_cur;
 fetch esn_cur into esn_rec;

 if esn_cur%notfound then
 close esn_cur;
 Op_ErrorMsg := 'esn is not found with objid : '||to_char(Ip_Esn_Objid);
 raise validate_esn_exc;
 end if;

 DBMS_OUTPUT.PUT_LINE('esn: '||esn_rec.part_serial_no);

 SELECT sa.seq('part_inst')
 INTO v_new_pi_objid
 FROM dual;

 /* insert into table_part_inst */
 insert into table_part_inst (objid,
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
 part_inst2inv_bin,
 created_by2user,
 status2x_code_table,
 n_part_inst2part_mod,
 part_to_esn2part_inst)
 VALUES ( v_new_pi_objid,
 TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss'),
 TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
 TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
 TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss'),
 TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
 TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
 TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
 TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
 TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss'),
 'Active',
 0,
 0,
 SYSDATE,
 SYSDATE,
 'REDEMPTION CARDS',
 0,
 0,
 t_dim2(i).pin,
 t_dim2(i).X_SMP,
 '40',
 inv_bin_rec.objid,
 Ip_UserId,
 code_rec.objid,
 t_dim1(i).mod_level,
 Ip_Esn_Objid) ;
 close esn_cur;

 if pcount = 1 then
 Op_RedCards_PartInst_Objids:= v_new_pi_objid;
 DBMS_OUTPUT.PUT_LINE('objid part inst : '||to_char(v_new_pi_objid));
 else
 DBMS_OUTPUT.PUT_LINE('objid part inst : '||to_char(v_new_pi_objid));
 Op_RedCards_PartInst_Objids := Op_RedCards_PartInst_Objids||','||v_new_pi_objid;
 end if;

 SELECT sa.seq('x_red_card')
 INTO v_new_red_card
 FROM dual;


 /* insert into table_x_red_card */
 insert into table_x_red_card (objid,
 x_red_code,
 x_red_units,
 x_smp,
 x_access_days,
 x_red_date,
 x_result)
 values (v_new_red_card,
 t_dim2(i).pin,
 t_dim1(i).units,
 t_dim2(i).X_SMP,
 t_dim1(i).days,
 SYSDATE,
 'Failed');

 end if; -- CR30286 end of IF

 SELECT sa.seq('x_purch_dtl')
 INTO v_new_purch_dtl
 FROM dual;
 DBMS_OUTPUT.PUT_LINE('objid x_red_card : '||to_char(v_new_red_card));

 /* insert into table_x_purch_dtl */
 Insert into table_x_purch_dtl (
 objid,
 x_red_card_number,
 x_smp,
 x_price,
 x_units,
 x_purch_dtl2x_purch_hdr,
 x_purch_dtl2redcard,
 x_purch_dtl2mod_level )
 values (v_new_purch_dtl,
 t_dim2(i).pin,
 t_dim2(i).X_SMP,
 t_dim1(i).price,
 t_dim1(i).units,
 Ip_PurchHdr_Objid,
 v_new_pi_objid,
 t_dim1(i).mod_level);
 if pcount = 1 then
 Op_redcodes := t_dim2(i).pin;
 DBMS_OUTPUT.PUT_LINE('objid purch dtl : '||to_char(v_new_purch_dtl));
 Op_PurchDtl_Objids:= v_new_purch_dtl;
 else
 Op_redcodes := Op_redcodes||','||t_dim2(i).pin;
 DBMS_OUTPUT.PUT_LINE('objid purch dtl : '||to_char(v_new_purch_dtl));
 Op_PurchDtl_Objids:= Op_PurchDtl_Objids||','||v_new_purch_dtl;
 End If;
-- close pricing_cur;
 i:=i+1;
 commit;
 EXIT WHEN L_STRING is null;
 END LOOP;

 close inv_bin_cur;
 close code_cur;

 op_TotalCount := pcount;
--CR42260 Do not delete the entries in table_x_cc_red_inv for APP purchase flow START
 /**** delete Table_CC_RED_INV ***/
 /*FOR k IN 1..pcount LOOP

 --
 v_merch_ref_id := t_dim2(k).x_merch;

 -- Reuse the same merchant reference id for Brand X Groups (Added by Juda Pena)
     IF NVL(brand_x_pkg.get_shared_group_flag ( ip_bus_org_id => ip_brand_name) , 'N') = 'Y' THEN
 -- Delete reserve id by merchant ref id and pin for brand x project (account groups)
 DELETE table_x_cc_red_inv
 WHERE x_reserved_id = v_merch_ref_id
 AND x_red_card_number = t_dim2(k).pin;
 ELSE
 -- Delete reserve id by merchant ref id (BAU)
 if nvl(lv_generate_red_card,'YES') = 'YES' then
 DELETE table_x_cc_red_inv
 WHERE x_reserved_id = v_merch_ref_id;
 END IF;
 end if;
 --
 COMMIT;
 END LOOP;

FOR k IN 1..pcount LOOP
 dbms_output.put_line(t_dim1(k).pn);
 COMMIT;
END LOOP;*/--CR42260 Do not delete the entries in table_x_cc_red_inv for APP purchase flow END

 Op_ErrorMsg:= 'successful';
COMMIT;
 EXCEPTION
 WHEN validate_merchant_exc
 THEN
 Op_ErrorNum := SQLCODE;
 Op_ErrorMsg := Op_ErrorMsg || SUBSTR (SQLERRM, 1, 100);
 INSERT
 INTO x_program_error_log(
 x_source,
 x_error_code,
 x_error_msg,
 x_date,
 x_description,
 x_severity
 ) VALUES(
 'SA.SP_purchase.insert_pur_dtl',
 Op_ErrorNum,
 Op_ErrorMsg,
 SYSDATE,
 'SP_purchase.insert_pur_dtl merchant_id not found',
 2 -- MEDIUM
 );
 COMMIT;
 WHEN validate_pricing_exc
 THEN
 Op_ErrorNum := SQLCODE;
 Op_ErrorMsg := Op_ErrorMsg || SUBSTR (SQLERRM, 1, 100);
 INSERT
 INTO x_program_error_log(
 x_source,
 x_error_code,
 x_error_msg,
 x_date,
 x_description,
 x_severity
 ) VALUES(
 'SP_purchase.insert_pur_dtl',
 Op_ErrorNum,
 Op_ErrorMsg,
 sysdate,
            --'SP_purchase.insert_pur_dtl pricing not found'
            --CR30286 (CR29021)logs added
            substr(
            'SP_purchase.insert_pur_dtl pricing not found..input parameters =>'
            || 'IP_partnumbers='    || ip_partnumbers
            || ', Ip_Esn_Objid='    || ip_esn_objid
            || ', Ip_Brand_Name='   || ip_brand_name
            || ', Ip_SourceSystem=' || ip_sourcesystem
            || ', Ip_Pincards='     || ip_pincards
            , 1, 254),
 2 -- MEDIUM
 );
 COMMIT;
 WHEN validate_bin_exc
 THEN
 Op_ErrorNum := SQLCODE;
 Op_ErrorMsg := Op_ErrorMsg || SUBSTR (SQLERRM, 1, 100);
 INSERT
 INTO x_program_error_log(
 x_source,
 x_error_code,
 x_error_msg,
 x_date,
 x_description,
 x_severity
 ) VALUES(
 'SP_purchase.insert_pur_dtl',
 Op_ErrorNum,
 Op_ErrorMsg,
 SYSDATE,
 'SP_purchase.insert_pur_dtl inv_bin not found',
 2 -- MEDIUM
 );
 COMMIT;
 WHEN validate_mod_level_exc
 THEN
 Op_ErrorNum := SQLCODE;
 Op_ErrorMsg := Op_ErrorMsg || SUBSTR (SQLERRM, 1, 100);
 INSERT
 INTO x_program_error_log(
 x_source,
 x_error_code,
 x_error_msg,
 x_date,
 x_description,
 x_severity
 ) VALUES(
 'SP_purchase.insert_pur_dtl',
 Op_ErrorNum,
 Op_ErrorMsg,
 SYSDATE,
 'SP_purchase.insert_pur_dtl mod_level not found',
 2 -- MEDIUM
 );
 COMMIT;
 WHEN validate_esn_exc
 THEN
 Op_ErrorNum := SQLCODE;
 Op_ErrorMsg := Op_ErrorMsg || SUBSTR (SQLERRM, 1, 100);
 INSERT
 INTO x_program_error_log(
 x_source,
 x_error_code,
 x_error_msg,
 x_date,
 x_description,
 x_severity
 ) VALUES(
 'SP_purchase.insert_pur_dtl',
 Op_ErrorNum,
 Op_ErrorMsg,
 SYSDATE,
 'SP_purchase.insert_pur_dtl esn not found',
 2 -- MEDIUM
 );
 COMMIT;
 WHEN OTHERS
 THEN
 Op_ErrorNum := SQLCODE;
 Op_ErrorMsg := Op_ErrorMsg|| SUBSTR (SQLERRM, 1, 100);
 INSERT
 INTO x_program_error_log(
 x_source,
 x_error_code,
 x_error_msg,
 x_date,
 x_description,
 x_severity
 ) VALUES(
 'SP_PURCHASE.insert_purch_det',
 Op_ErrorNum,
 Op_ErrorMsg,
 SYSDATE,
 'SP_PURCHASE.insert_purch_det',
 2 -- MEDIUM
 );
END; --insert_purch_det


PROCEDURE Insert_Purch_Hdr ( ip_x_rqst_source         IN VARCHAR2,
 ip_x_rqst_type             IN VARCHAR2,
 ip_x_rqst_date             IN DATE,
 ip_x_ics_applications         IN VARCHAR2,
 ip_x_merchant_id         IN VARCHAR2,
 ip_x_merchant_ref_number     IN VARCHAR2,
 ip_x_offer_num             IN VARCHAR2,
 ip_x_quantity             IN NUMBER,
 ip_x_ignore_bad_cv         IN VARCHAR2,
 ip_x_ignore_avs         IN VARCHAR2,
 ip_x_disable_avs         IN VARCHAR2,
 ip_x_customer_hostname         IN VARCHAR2,
 ip_x_customer_ipaddress         IN VARCHAR2,
 ip_x_auth_code         IN VARCHAR2,
 ip_x_ics_rcode             IN NUMBER,
 ip_x_ics_rflag             IN VARCHAR2,
 ip_x_ics_rmsg             IN VARCHAR2,
 ip_x_request_id         IN VARCHAR2,
 ip_x_auth_avs             IN VARCHAR2,
 ip_x_auth_response         IN VARCHAR2,
 ip_x_auth_time             IN VARCHAR2,
 ip_x_auth_rcode         IN NUMBER,
 ip_x_auth_rflag             IN VARCHAR2,
 ip_x_auth_rmsg         IN VARCHAR2,
 ip_x_score_factors         IN VARCHAR2,
 ip_x_score_host_severity         IN VARCHAR2,
 ip_x_score_rcode         IN NUMBER,
 ip_x_score_rflag         IN VARCHAR2,
 ip_x_score_rmsg         IN VARCHAR2,
 ip_x_score_result         IN NUMBER,
 ip_x_score_time_local         IN VARCHAR2,
 ip_x_bill_request_time         IN VARCHAR2,
 ip_x_bill_rcode             IN NUMBER,
 ip_x_bill_rflag             IN VARCHAR2,
 ip_x_bill_rmsg             IN VARCHAR2,
 ip_x_bill_trans_ref_no         IN VARCHAR2,
 ip_x_customer_cc_number     IN VARCHAR2,
 ip_x_customer_cc_expmo     IN VARCHAR2,
 ip_x_customer_cc_expyr         IN VARCHAR2,
 ip_x_customer_firstname         IN VARCHAR2,
 ip_x_customer_lastname         IN VARCHAR2,
 ip_x_customer_phone         IN VARCHAR2,
 ip_x_customer_email         IN VARCHAR2,
 ip_x_bill_address1         IN VARCHAR2,
 ip_x_bill_address2         IN VARCHAR2,
 ip_x_bill_city             IN VARCHAR2,
 ip_x_bill_state             IN VARCHAR2,
 ip_x_bill_zip             IN VARCHAR2,
 ip_x_bill_country         IN VARCHAR2,
 ip_x_esn             IN VARCHAR2,
 ip_x_cc_lastfour         IN VARCHAR2,
 ip_x_amount             IN NUMBER,
 ip_x_tax_amount         IN NUMBER,
 ip_x_e911_amount         IN NUMBER,
 ip_x_usf_amount IN NUMBER ,
 ip_x_rcrf_amount IN NUMBER ,
 ip_x_combs_amount IN NUMBER ,
 ip_x_discount_amount IN NUMBER,
 ip_x_shipping_cost IN NUMBER ,
 ip_x_auth_amount         IN NUMBER,
 ip_x_bill_amount         IN NUMBER,
 ip_x_purch_hdr2contact     IN NUMBER,
 ip_x_purch_hdr2user         IN NUMBER,
 ip_x_purch_hdr2esn         IN NUMBER,
 ip_x_purch_hdr2bank_acct     IN NUMBER,
 ip_x_purch_hdr2creditcard     IN NUMBER,
 Op_PurchHdr_objid         OUT NUMBER,
 Op_ErrorNum         OUT VARCHAR2,
 Op_ErrorMsg         OUT VARCHAR2 ) IS

 --
 -- CR16842 Start kacosta 03/09/2012
 CURSOR get_login_name_curs (c_n_user_objid table_user.objid%TYPE) IS
 SELECT tbu.login_name
 FROM table_user tbu
 WHERE tbu.objid = c_n_user_objid;
 --
 get_login_name_rec get_login_name_curs%ROWTYPE;
 -- CR16842 End kacosta 03/09/2012
 --
 ID_NUMBER NUMBER;

BEGIN

 Op_ErrorNum := '0';
 Op_ErrorMsg := '';

 SELECT sa.SEQU_X_PURCH_HDR.NEXTVAL
 INTO ID_NUMBER
 FROM DUAL;
 --
 -- CR16842 Start kacosta 03/09/2012
 IF get_login_name_curs%ISOPEN THEN
 --
 CLOSE get_login_name_curs;
 --
 END IF;
 --
 OPEN get_login_name_curs(c_n_user_objid => ip_x_purch_hdr2user);
 FETCH get_login_name_curs INTO get_login_name_rec;
 CLOSE get_login_name_curs;
 -- CR16842 End kacosta 03/09/2012
 --

 insert into sa.Table_X_Purch_Hdr (OBJID,
 x_rqst_source,
 x_rqst_type ,
 x_rqst_date ,
 x_ics_applications ,
 x_merchant_id ,
 x_merchant_ref_number ,
 x_offer_num ,
 x_quantity ,
 x_ignore_bad_cv ,
 x_ignore_avs ,
 x_disable_avs  ,
                                                 x_customer_hostname,
                                                 x_customer_ipaddress,
                                                 x_auth_code ,
                                                 x_ics_rcode ,
                                                 x_ics_rflag ,
                                                 x_ics_rmsg ,
                                                 x_request_id ,
                                                 x_auth_avs ,
                                                 x_auth_response ,
                                                 x_auth_time ,
                                                 x_auth_rcode ,
                                                 x_auth_rflag ,
                                                 x_auth_rmsg ,
                                                 x_score_factors  ,
                                                 x_score_host_severity  ,
                                                 x_score_rcode   ,
                                                 x_score_rflag    ,
                                                 x_score_rmsg   ,
                                                 x_score_result  ,
                                                 x_score_time_local  ,
                                                 x_bill_request_time  ,
                                                 x_bill_rcode   ,
                                                 x_bill_rflag  ,
                                                 x_bill_rmsg   ,
                                                 x_bill_trans_ref_no  ,
                                                 x_customer_cc_number    ,
                                                 x_customer_cc_expmo   ,
                                                 x_customer_cc_expyr ,
                                                 x_customer_firstname  ,
                                                 x_customer_lastname   ,
                                                 x_customer_phone   ,
                                                 x_customer_email  ,
                                                 x_bill_address1   ,
                                                 x_bill_address2 ,
                                                 x_bill_city  ,
                                                 x_bill_state   ,
                                                 x_bill_zip   ,
                                                 x_bill_country  ,
                                                 x_esn  ,
                                                 x_cc_lastfour ,
                                                 x_amount   ,
                                                 x_tax_amount  ,
                                                 x_e911_amount  ,
                                                 x_usf_taxamount   ,
                                                 x_rcrf_tax_amount    ,
                                                 x_discount_amount ,
                                                 x_auth_amount  ,
                                                 x_bill_amount   ,
                                                 x_purch_hdr2contact   ,
                                                 x_purch_hdr2user ,
                                                 x_purch_hdr2esn  ,
                                                 x_purch_hdr2bank_acct   ,
                                                 x_purch_hdr2creditcard  ,
                                                 X_MERCHANT_PRODUCT_SKU   ,
                                                 X_PRODUCT_NAME   ,
                                                 X_PRODUCT_CODE  ,
                                                 X_USER_PO   ,
                                                 X_AVS   ,
                                                 X_AUTH_REQUEST_ID  ,
                                                 X_AUTH_TYPE ,
                                                 X_AUTH_CV_RESULT,
                                                 X_CUSTOMER_CC_CV_NUMBER ,
                                                 X_BANK_NUM,
                                                 X_CUSTOMER_ACCT,
                                                 X_ROUTING,
                                                 X_ABA_TRANSIT,
                                                 X_BANK_NAME,
                                                 X_STATUS,
                                                 X_USER,
                                                 X_PURCH_HDR2X_RMSG_CODES,
                                                 X_PURCH_HDR2CR_PURCH,
                                                 X_CREDIT_CODE,
                                                 X_CREDIT_REASON,
                                                 X_SHIPPING_COST,
                                                 X_TOTAL_TAX) values
                                                    (ID_NUMBER,
                                                    ip_x_rqst_source ,
                                                ip_x_rqst_type   ,
                                                SYSDATE,
                                                ip_x_ics_applications  ,
                                                ip_x_merchant_id ,
                                                ip_x_merchant_ref_number ,
                                                ip_x_offer_num  ,
                                                ip_x_quantity      ,
                                                ip_x_ignore_bad_cv  ,
                                                ip_x_ignore_avs  ,
                                                ip_x_disable_avs  ,
                                                ip_x_customer_hostname  ,
                                                ip_x_customer_ipaddress,
                                                ip_x_auth_code,
                                                ip_x_ics_rcode  ,
                                                ip_x_ics_rflag  ,
                                                ip_x_ics_rmsg  ,
                                                ip_x_request_id  ,
                                                ip_x_auth_avs  ,
                                                ip_x_auth_response  ,
                                                ip_x_auth_time  ,
                                                ip_x_auth_rcode  ,
                                                ip_x_auth_rflag  ,
                                                ip_x_auth_rmsg  ,
                                                ip_x_score_factors  ,
                                                ip_x_score_host_severity ,
                                                ip_x_score_rcode  ,
                                                ip_x_score_rflag  ,
                                                ip_x_score_rmsg  ,
                                                ip_x_score_result  ,
                                                ip_x_score_time_local  ,
                                                ip_x_bill_request_time      ,
                                                ip_x_bill_rcode  ,
                                                ip_x_bill_rflag  ,
                                                ip_x_bill_rmsg  ,
                                                ip_x_bill_trans_ref_no,
                                                ip_x_customer_cc_number  ,
                                                ip_x_customer_cc_expmo  ,
                                                ip_x_customer_cc_expyr  ,
                                                ip_x_customer_firstname  ,
                                                ip_x_customer_lastname  ,
                                                ip_x_customer_phone  ,
                                                ip_x_customer_email  ,
                                                ip_x_bill_address1  ,
                                                ip_x_bill_address2  ,
                                                ip_x_bill_city      ,
                                                ip_x_bill_state  ,
                                                ip_x_bill_zip      ,
                                                ip_x_bill_country  ,
                                                ip_x_esn  ,
                                                ip_x_cc_lastfour  ,
                                                ip_x_amount      ,
                                                round(ip_x_combs_amount,2),    --CR16392
                                                round(ip_x_e911_amount,2)  ,
                                                round(ip_x_usf_amount ,2)    ,
                                                round(ip_x_rcrf_amount,2)  ,
                                                round(ip_x_discount_amount,2) ,
                                                ip_x_auth_amount  ,
                                                ip_x_bill_amount   ,
                                                ip_x_purch_hdr2contact  ,
                                                ip_x_purch_hdr2user  ,
                                                ip_x_purch_hdr2esn  ,
                                                ip_x_purch_hdr2bank_acct ,
                                                ip_x_purch_hdr2creditcard,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                -- CR16842 Start kacosta 03/09/2012
                                                --NULL,
                                                get_login_name_rec.login_name,
                                                -- CR16842 End kacosta 03/09/2012
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                ip_x_shipping_cost,
                                                round(ip_x_tax_amount,2));   --CR16392
    COMMIT;

    Op_PurchHdr_objid := ID_NUMBER ;

end;

PROCEDURE Update_Purch_Hdr (ip_x_purch_hdr_objid          IN Number,
                            ip_x_auth_request_id          IN  VARCHAR2,
                            ip_x_auth_code                     IN VARCHAR2 ,
                            ip_x_ics_rcode                     IN    NUMBER,
                            ip_x_ics_rflag                     IN  VARCHAR2 ,
                            ip_x_ics_rmsg                     IN  VARCHAR2 ,
                            ip_x_request_id                   IN VARCHAR2 ,
                            ip_x_auth_amount                   IN    NUMBER ,
                            ip_x_auth_avs                     IN       VARCHAR2 ,
                            ip_x_auth_response                 IN  VARCHAR2 ,
                            ip_x_auth_time                     IN VARCHAR2 ,
                            ip_x_auth_rcode                   IN NUMBER,
                            ip_x_auth_rflag                   IN  VARCHAR2 ,
                            ip_x_auth_rmsg                     IN  VARCHAR2 ,
                            ip_x_auth_cv_result           IN VARCHAR2,
                            ip_x_score_factors                 IN   VARCHAR2 ,
                            ip_x_score_host_severity         IN VARCHAR2 ,
                            ip_x_score_rcode                   IN NUMBER,
                            ip_x_score_rflag                   IN VARCHAR2 ,
                            ip_x_score_rmsg                   IN  VARCHAR2 ,
                            ip_x_score_result                 IN NUMBER,
                            ip_x_score_time_local             IN  VARCHAR2 ,
                            ip_x_bill_amount                   IN NUMBER ,
                            ip_x_bill_request_time             IN  VARCHAR2 ,
                            ip_x_bill_rcode                   IN   NUMBER,
                            ip_x_bill_rflag                   IN  VARCHAR2 ,
                            ip_x_bill_rmsg                     IN VARCHAR2 ,
                            ip_x_bill_trans_ref_no             IN  VARCHAR2 ,
                            ip_x_purch_hdr2x_rmsg_codes   IN NUMBER,
                            ip_x_rqst_source                 IN   VARCHAR2 ,
                            ip_x_rqst_type                    IN VARCHAR2 ,
                            ip_x_rqst_date                    IN     DATE,
                            ip_x_user                     IN VARCHAR2,
                            Op_ErrorNum                   OUT VARCHAR2,
                            Op_ErrorMsg                   OUT  VARCHAR2  ) IS

BEGIN

  Op_ErrorNum := '0';
  Op_ErrorMsg := '';

               Update sa.Table_X_Purch_Hdr
                  set x_auth_avs                   =     ip_x_auth_avs,
                      x_auth_request_id            =   ip_x_auth_request_id,
                      x_auth_code                    =   ip_x_auth_code,
                      x_ics_rcode                  =   ip_x_ics_rcode,
                      x_ics_rflag                  =   ip_x_ics_rflag,
                      x_ics_rmsg                   =   ip_x_ics_rmsg,
                      x_request_id                 =   ip_x_request_id,
                      x_auth_amount                =   ip_x_auth_amount,
                      x_auth_response              =   ip_x_auth_response,
                      x_auth_time                  =   ip_x_auth_time,
                      x_auth_rcode                 =   ip_x_auth_rcode,
                      x_auth_rflag                 =   ip_x_auth_rflag,
                      x_auth_rmsg                  =   ip_x_auth_rmsg,
                      x_auth_cv_result             =   ip_x_auth_cv_result,
                      x_score_factors              =   ip_x_score_factors,
                      x_score_host_severity        =   ip_x_score_host_severity,
                      x_score_rcode                =   ip_x_score_rcode,
                      x_score_rflag                =   ip_x_score_rflag,
                      x_score_rmsg                 =   ip_x_score_rmsg,
                      x_score_result               =   ip_x_score_result,
                      x_score_time_local           =   ip_x_score_time_local,
                      x_bill_amount                =   ip_x_bill_amount,
                      x_bill_request_time          =   ip_x_bill_request_time,
                      x_bill_rcode                 =   ip_x_bill_rcode,
                      x_bill_rflag                 =   ip_x_bill_rflag,
                      x_bill_rmsg                  =   ip_x_bill_rmsg,
                      x_bill_trans_ref_no          =   ip_x_bill_trans_ref_no,
                      x_purch_hdr2x_rmsg_codes     =   ip_x_purch_hdr2x_rmsg_codes,
                      x_rqst_source                =   ip_x_rqst_source,
                      x_rqst_type                  =   ip_x_rqst_type,
                      x_rqst_date                  =   SYSDATE
                    where  objid = ip_x_purch_hdr_objid;
    COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         op_ErrorNum :=  SQLCODE;
         op_ErrorMsg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
         INSERT
         INTO x_program_error_log(
            x_source,
            x_error_code,
            x_error_msg,
            x_date,
            x_description,
            x_severity
         )         VALUES(
            'SP_PURCHASE.update_purch_hdr',
            op_ErrorNum,
            op_ErrorMsg,
            SYSDATE,
            'SP_PURCHASE.update_purch_hdr',
            2 -- MEDIUM
         );
END; --update_purch_hdr

END SP_PURCHASE;
-- End Package Body SP_PURCHASE
/