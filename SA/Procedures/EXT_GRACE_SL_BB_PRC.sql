CREATE OR REPLACE PROCEDURE sa."EXT_GRACE_SL_BB_PRC" AS
  cursor expired_ll_curs is
    SELECT /*+ ORDERED */
           sp.*,
           (select u.objid
              from table_user u
            where u.s_login_name = 'SA') user_objid,
           (select pi.part_inst2carrier_mkt
             from table_part_inst pi
             where part_serial_no = sp.x_min) carrier_objid,
           (select s.objid
             from table_part_inst pi,
                  table_inv_bin ib,
                  table_site s
             where pi.part_serial_no = sp.x_service_id
               and ib.objid = pi.part_inst2inv_bin
               AND S.SITE_ID = IB.BIN_NAME) DEALER_OBJID,
           (select bo.org_id
             from table_part_inst pi,
                  table_mod_level ml,
                  table_part_num pn,
                  table_bus_org bo
            where pi.part_serial_no = sp.x_service_id
              and ml.objid = pi.n_part_inst2part_mod
              and pn.objid = ml.part_info2part_num
              and bo.objid = pn.part_num2bus_org) org_id
     FROM  X_PROGRAM_PARAMETERS PP
          ,X_PROGRAM_ENROLLED PE
          ,TABLE_SITE_PART SP
    WHERE PP.X_PROGRAM_NAME  LIKE  'Lifeline%BB%'
      AND PE.PGM_ENROLL2PGM_PARAMETER = PP.OBJID
      AND PE.X_ENROLLMENT_STATUS = 'ENROLLED'
      AND SP.PART_STATUS = 'Active'
      AND TRUNC(SP.X_EXPIRE_DT) <= TRUNC(SYSDATE)+1
      AND SP.X_SERVICE_ID = PE.X_ESN;

  cursor extensions_curs(c_esn in varchar2,
                         c_promo_objid in number) is
    select count(*) cnt
      from table_x_call_trans ct
    where (x_service_id in (select h.x_esn
                             from x_sl_hist h
                            where h.lid = (select cv.lid
                                             from x_sl_currentvals cv
                                            where cv.x_current_esn = c_esn )
           or x_service_id = c_esn ))
      and exists(select 1
                  from table_x_promo_hist ph
                where ph.PROMO_HIST2X_CALL_TRANS = ct.objid
                  and ph.PROMO_HIST2X_PROMOTION = c_promo_objid);
  extensions_rec extensions_curs%rowtype;
  cursor extension_promo_curs is
    select objid
      from table_x_promotion p
     where p.x_promo_code = 'SLNTGP30D';
  extension_promo_rec extension_promo_curs%rowtype;
  l_new_call_trans_objid number;

CURSOR Q_CARD_CURS (V_ESN IN VARCHAR2) IS
select count(*) cnt
from table_part_inst pi,
    table_parT_inst card
where pi.part_serial_no= v_esn
and card.x_domain='REDEMPTION CARDS'
AND CARD.X_PART_INST_STATUS='400'
and card.part_to_esn2part_inst = pi.objid;
q_card_rec q_card_curs%rowtype;

/**************************************************************************************************************

***************************************************************************************************************/
  l_extra_days number := 30;
  L_MAX_EXTENSIONS NUMBER := 1;
  l_step varchar2(100) := '0';
BEGIN
  --dbms_output.put_line ( 'begin' );
open extension_promo_curs;
FETCH EXTENSION_PROMO_CURS INTO EXTENSION_PROMO_REC;
 L_STEP := '1';
 --dbms_output.put_line ( 'after open extension ' );
IF EXTENSION_PROMO_CURS%NOTFOUND THEN
   -- dbms_output.put_line ( 'error not found extensions' );
    L_STEP := '2';
    INSERT INTO  ERROR_TABLE  (ERROR_TEXT, ERROR_DATE ,ACTION,  KEY,  PROGRAM_NAME)
                      VALUES(L_STEP,SYSDATE,'promo SLNTGP30D not exist','EXTENSION_PROMO_CURS%NOT', 'EXT_GRACE_SL_BB');
ELSE
    --dbms_output.put_line ( 'found extensions');
    -- found promo for extended days SL bb
    l_step := '3';
  FOR EXPIRED_LL_REC IN EXPIRED_LL_CURS LOOP
       --dbms_output.put_line ( 'inside the loop ');
      OPEN Q_CARD_CURS(EXPIRED_LL_REC.X_SERVICE_ID);
      FETCH Q_CARD_CURS INTO Q_CARD_REC;
      -- DBMS_OUTPUT.PUT_LINE ( 'after open queue card cursor with ESN'||EXPIRED_LL_REC.X_SERVICE_ID);
      -- DBMS_OUTPUT.PUT_LINE ( 'cards in queue '||Q_CARD_REC.CNT);
    --  IF Q_CARD_CURS%NOTFOUND THEN
      IF Q_CARD_REC.CNT =0 THEN
       --dbms_output.put_line ( 'before extensions' );
      open extensions_curs(expired_ll_rec.x_service_id,extension_promo_rec.objid);
      FETCH EXTENSIONS_CURS INTO EXTENSIONS_REC;
        -- dbms_output.put_line ( 'before check extensions_rec.cnt < l_max_extensions' );
       l_step := '4';
      IF EXTENSIONS_REC.CNT < L_MAX_EXTENSIONS THEN
        -- dbms_output.put_line ( 'before insert' );
        insert into table_x_call_trans(OBJID,
                                       CALL_TRANS2SITE_PART,
                                       X_ACTION_TYPE      ,
                                       X_CALL_TRANS2CARRIER,
                                       X_CALL_TRANS2DEALER ,
                                       X_CALL_TRANS2USER  ,
                                       X_LINE_STATUS     ,
                                       X_MIN            ,
                                       X_SERVICE_ID    ,
                                       X_SOURCESYSTEM ,
                                       X_TRANSACT_DATE,
                                       X_TOTAL_UNITS  ,
                                       X_ACTION_TEXT ,
                                       X_REASON     ,
                                       X_RESULT    ,
                                       X_SUB_SOURCESYSTEM ,
                                       X_ICCID           ,
                                       X_OTA_REQ_TYPE   ,
                                       X_OTA_TYPE      ,
                                       X_CALL_TRANS2X_OTA_CODE_HIST ,
                                       X_NEW_DUE_DATE             ,
                                       UPDATE_STAMP              )
                                values(
                                       seq('x_call_trans'),
                                       EXPIRED_LL_REC.OBJID,
                                       '6',   -- 8 CR24535
                                       expired_ll_rec.carrier_objid,
                                       expired_ll_rec.dealer_objid,
                                       expired_ll_rec.user_objid,
                                       null,
                                       expired_ll_rec.x_min,
                                       expired_ll_rec.x_service_id,
                                       'BATCH',
                                       sysdate,
                                       0,
                                       'REDSWEEPALL', --'CUST SERVICE', CR24535
                                       'extend pilot life line program',
                                       'Completed'                ,
                                       expired_ll_rec.org_id,
                                       expired_ll_rec.x_iccid,
                                       null,
                                       null,
                                       null,
                                       (expired_ll_rec.x_expire_dt + l_extra_days),
                                       sysdate)
                                returning OBJID into l_new_call_trans_objid;
        insert into table_x_promo_hist(OBJID,
                                       PROMO_HIST2X_CALL_TRANS,
                                       PROMO_HIST2X_PROMOTION,
                                       GRANTED_FROM2X_CALL_TRANS,
                                       UPDATE_STAMP  )
                                values(seq('x_promo_hist'),
                                       l_new_call_trans_objid,
                                       extension_promo_rec.objid,
                                       NULL,
                                       SYSDATE);
        UPDATE TABLE_SITE_PART SP
           SET SP.X_EXPIRE_DT = (SP.X_EXPIRE_DT + L_EXTRA_DAYS),
               sp.warranty_date = (SP.X_EXPIRE_DT + l_extra_days)
         WHERE SP.OBJID = EXPIRED_LL_REC.OBJID;

        UPDATE TABLE_PART_INST PI
           set pi.warr_end_date = (pi.warr_end_date + l_extra_days)
         WHERE PI.PART_SERIAL_NO = EXPIRED_LL_REC.X_SERVICE_ID;

      ELSE
        l_step := '5';
         --extensions_rec.cnt > l_max_extensions
         INSERT INTO  ERROR_TABLE  (ERROR_TEXT, ERROR_DATE ,ACTION,  KEY,  PROGRAM_NAME)
                      VALUES(l_step,SYSDATE,'extensions_rec.cnt > l_max_extensions',EXPIRED_LL_REC.X_SERVICE_ID, 'EXT_GRACE_SL_BB');
      end if;
    CLOSE EXTENSIONS_CURS;
  --  ELSE
    --   dbms_output.put_line ( 'found card in queue');
    END IF;
    CLOSE Q_CARD_CURS;

  END LOOP;
  commit;
END if;
close EXTENSION_PROMO_CURS;
EXCEPTION
  WHEN OTHERS THEN
  L_STEP := L_STEP||':'||SQLCODE||':'||SQLERRM;
  INSERT INTO  ERROR_TABLE  (ERROR_TEXT, ERROR_DATE,ACTION,  KEY,  PROGRAM_NAME)
                      VALUES(L_STEP,SYSDATE,'when others errors ext_grace_sl_bb','', 'EXT_GRACE_SL_BB');
END;
/