CREATE OR REPLACE TRIGGER sa."TRG_X_DEPENDENTS"
AFTER UPDATE
ON sa.TABLE_X_DEPENDENTS
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW  WHEN ( NEW.X_DEPENDENTS2CONTACT IS NOT NULL ) DECLARE
/*******************************************************************************
 * Trigger Name: TRG_X_DEPENDENTS
 *
 * Created By: SL
 * Creation Date: 02/22/02
 *
 * Description: For Roadside Application, the trigger will update/insert ftp
 *              record when any dependent information changes
 *
 *******************************************************************************/
      v_road_ftp_objid          number;
      v_service_id              varchar2(30);
      v_program_name            varchar2(80) := 'ROADSIDE';
      v_first_name              varchar2(30);
      v_last_name               varchar2(30);
      v_address_1               varchar2(200);
      v_address_2               varchar2(200);
      v_city                    varchar2(30);
      v_state                   varchar2(40);
      v_zipcode                 varchar2(20);
      v_phone                   varchar2(20);
      v_e_mail                  varchar2(80);
      v_info_reqd               varchar2(10);
      v_trans_type              varchar2(10) := 'U';
      v_activation_date         date;
      v_service_start_date      date;
      v_service_end_date        date;
      v_deactivation_date       date;
      v_deact_reason            varchar2(30);
      v_term                    number := 12;
      v_wholesale_cost          number;
      v_card_plan               varchar2(10);
      v_card_type               varchar2(20);
      v_wholesale_refund        number;
      v_customer_refund         number;
      v_refund_percent 	        number;
      v_ftp_create_status       varchar2(20) := 'NO';
      v_ftp_create_date         date;
      v_orafin_post             varchar2(20);
      v_dep1_first_name         varchar2(40);
      v_dep1_last_name          varchar2(40);
      v_dep2_first_name         varchar2(40);
      v_dep2_last_name          varchar2(40);
      v_dep3_first_name         varchar2(40);
      v_dep3_last_name          varchar2(40);
      v_dep4_first_name         varchar2(40);
      v_dep4_last_name          varchar2(40);
      v_dependent_count         number;
      v_promo_objid             number ;
      v_promo_code              varchar2(30);
      v_call_trans_objid        number;
      v_sourcesystem            varchar2(30);
      v_road_dealer_objid       number;
      v_road_dealer_id          varchar2(80);
      v_road_dealer_name        varchar2(80);
      v_road_part_num_objid     number;
      v_road_part_number        varchar2(30);
      v_road_part_description   varchar2(255);
      v_road_part_retailcost    number(8,2);
      v_user_objid              number;
      v_user_login_name         varchar2(30);
      v_user_first_name         varchar2(30);
      v_user_last_name          varchar2(30);
      v_smp                     varchar2(30);

      v_contact_objid           number;
      v_site_part_objid         number;
      v_prim_address_objid      number;
      v_mod_level_objid	        number;
      v_user                    varchar2(30) := user;
      v_step                    varchar2(100);

BEGIN

      v_step := 'copying contact objid to global';
      v_contact_objid := :new.x_dependents2contact;

      -- get contact info
      v_step := 'getting contact info';

      BEGIN
         SELECT c.first_name, c.last_name, c.phone, c.e_mail, c.objid
         INTO v_first_name, v_last_name, v_phone,v_e_mail , v_contact_objid
         FROM table_contact c
         WHERE c.objid = v_contact_objid;
      EXCEPTION
        WHEN others THEN
         RETURN;
      END;

      -- get site part, site, primary address
      v_step := 'getting site part, site, primary address';

      BEGIN
        SELECT  x_service_id,install_date, x_expire_dt,service_end_dt,
                x_deact_reason,site_part2part_info, machine_id,
                s.cust_primaddr2address
        INTO v_service_id,v_activation_date,v_service_end_date,v_deactivation_date,
             v_deact_reason,v_mod_level_objid, v_smp,v_prim_address_objid
        FROM table_site_part sp,table_site s, table_contact_role cr
        WHERE 1=1
        AND   sp.part_status ||'' = 'Active'
        AND   sp.instance_name = 'ROADSIDE'
        AND   s.objid =  sp.site_part2site
        AND   cr.contact_role2site = s.objid
        AND   cr.contact_role2contact = v_contact_objid;
      EXCEPTION
        WHEN others THEN
         RETURN; --03/28/02
      END;

      v_service_start_date := sysdate + 3;

      v_step := 'getting dealer info';
      BEGIN
        SELECT  s.objid,s.name, s.site_id
        INTO v_road_dealer_objid, v_road_dealer_name,v_road_dealer_id
        FROM table_site s, table_inv_locatn il, table_inv_bin ib,
             table_x_road_inst ri
        WHERE  1=1
        AND  il.inv_locatn2site = s.objid
        AND  ib.inv_bin2inv_locatn = il.objid
        AND  ri.road_inst2inv_bin = ib.objid
        AND  ri.x_red_code = v_service_id;
      EXCEPTION
        WHEN others THEN
          NULL;
      END;

      -- check if unsent record exists fro contact
      BEGIN
        SELECT objid INTO v_road_ftp_objid
        FROM x_road_ftp rf
        WHERE rf.service_id = v_service_id
        AND   rf.ftp_create_status = 'NO';
      EXCEPTION
       WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20002,'Memeber '||v_service_id||' has more than one unsent record. '||
                                'Please contact your system adminstrator.');
       WHEN OTHERS THEN
        NULL;
      END;

      IF v_road_ftp_objid IS NULL THEN
        -- get address info
        v_step := 'getting address info';

        IF v_prim_address_objid IS NOT NULL THEN
         BEGIN
          SELECT address, address_2,city, state, zipcode
          INTO  v_address_1, v_address_2, v_city, v_state, v_zipcode
          FROM  table_address
          WHERE objid = v_prim_address_objid;
         EXCEPTION
          WHEN OTHERS THEN
           NULL;
         END;
        END IF;

        -- get call trans info
        v_step := 'getting call trans info.';
        BEGIN
           SELECT ct.objid,x_sourcesystem
           INTO  v_call_trans_objid, v_sourcesystem
           FROM table_x_call_trans ct
           WHERE ct.objid = ( SELECT MAX(objid)
                                FROM table_x_call_trans ct2
                                WHERE ct2.x_service_id = v_service_id);
        EXCEPTION
           WHEN OTHERS THEN
            NULL;
        END;

        -- get part number info
        v_step := 'getting part number info.';
        BEGIN
            SELECT pn.objid, pn.part_number, pn.description, pn.x_retailcost,
                   pn.x_card_type, pn.x_card_plan, to_number(pn.x_wholesale_price)
            INTO v_road_part_num_objid, v_road_part_number, v_road_part_description,
                 v_road_part_retailcost, v_card_type, v_card_plan, v_wholesale_cost
            FROM table_part_num pn, table_mod_level ml
            WHERE ml.part_info2part_num = pn.objid
            AND  ml.objid = v_mod_level_objid;
         EXCEPTION
           WHEN others THEN
             NULL;
         END;

        -- get user, employee info
        v_step := 'getting user, employee info.';
        BEGIN
          SELECT u.objid, u.login_name, e.first_name, e.last_name
          INTO  v_user_objid, v_user_login_name, v_user_first_name, v_user_last_name
          FROM table_employee e, table_user u
          WHERE u.objid = e.employee2user
          AND u.s_login_name = upper(v_user);
        EXCEPTION
          WHEN OTHERS THEN
           NULL;
        END;

        -- Insert new row into table_x_road_ftp
        v_step := 'getting seq_x_road_ftp.nextval+power(2,28)';
        select seq_x_road_ftp.nextval + power(2,28)
        into v_road_ftp_objid
        from dual;

        IF v_trans_type = 'N' THEN
           v_orafin_post := 'NO';
        ELSE
           v_orafin_post := 'NA';
        END IF;

        v_step := 'inserting into table_x_road_ftp';

          INSERT INTO x_road_ftp
          (
            OBJID                       ,
            SERVICE_ID                  ,
            PART_SERIAL_NO              ,
            PROGRAM_NAME                ,
            FIRST_NAME                  ,
            LAST_NAME                   ,
            ADDRESS_1                   ,
            ADDRESS_2                   ,
            CITY                        ,
            STATE                       ,
            ZIPCODE                     ,
            PHONE                       ,
            E_MAIL                      ,
            INFO_REQD                   ,
            TRANS_TYPE                  ,
            ACTIVATION_DATE             ,
            SERVICE_START_DATE          ,
            SERVICE_END_DATE            ,
            DEACTIVATION_DATE           ,
            DEACT_REASON                ,
            TERM                        ,
            WHOLESALE_COST              ,
            CARD_PLAN                   ,
            CARD_TYPE                   ,
            WHOLESALE_REFUND            ,
            CUSTOMER_REFUND             ,
            REFUND_PERCENT              ,
            FTP_CREATE_STATUS           ,
            FTP_CREATE_DATE             ,
            ORAFIN_POST                 ,
            DEP1_FIRST_NAME             ,
            DEP1_LAST_NAME              ,
            DEP2_FIRST_NAME             ,
            DEP2_LAST_NAME              ,
            DEP3_FIRST_NAME             ,
            DEP3_LAST_NAME              ,
            DEP4_FIRST_NAME             ,
            DEP4_LAST_NAME              ,
            DEPENDENT_COUNT             ,
            PROMO_OBJID                 ,
            PROMO_CODE                  ,
            CALL_TRANS_OBJID            ,
            SOURCESYSTEM                ,
            ROAD_DEALER_OBJID           ,
            ROAD_DEALER_ID              ,
            ROAD_DEALER_NAME            ,
            ROAD_PART_NUM_OBJID         ,
            ROAD_PART_NUMBER            ,
            ROAD_PART_DESCRIPTION       ,
            ROAD_PART_RETAILCOST        ,
            USER_OBJID                  ,
            USER_LOGIN_NAME             ,
            USER_FIRST_NAME             ,
            USER_LAST_NAME              ,
            LAST_UPDATE_DATE            ,
            LAST_UPDATED_BY
          ) VALUES
          (
            v_road_ftp_objid            ,
            v_service_id                ,
            v_smp                       ,
            v_program_name              ,
            v_first_name                ,
            v_last_name                 ,
            v_address_1                 ,
            v_address_2                 ,
            v_city                      ,
            v_state                     ,
            v_zipcode                   ,
            v_phone                     ,
            v_e_mail                    ,
            v_info_reqd                 ,
            v_trans_type                ,
            v_activation_date           ,
            v_service_start_date        ,
            v_service_end_date          ,
            v_deactivation_date         ,
            v_deact_reason              ,
            v_term                      ,
            v_wholesale_cost            ,
            v_card_plan                 ,
            v_card_type                 ,
            v_wholesale_refund          ,
            v_customer_refund           ,
            v_refund_percent            ,
            v_ftp_create_status         ,
            v_ftp_create_date           ,
            v_orafin_post               ,
            v_dep1_first_name           ,
            v_dep1_last_name            ,
            v_dep2_first_name           ,
            v_dep2_last_name            ,
            v_dep3_first_name           ,
            v_dep3_last_name            ,
            v_dep4_first_name           ,
            v_dep4_last_name            ,
            v_dependent_count           ,
            v_promo_objid               ,
            v_promo_code                ,
            v_call_trans_objid          ,
            v_sourcesystem              ,
            v_road_dealer_objid	        ,
            v_road_dealer_id            ,
            v_road_dealer_name          ,
            v_road_part_num_objid       ,
            v_road_part_number          ,
            v_road_part_description     ,
            v_road_part_retailcost      ,
            v_user_objid                ,
            v_user_login_name           ,
            v_user_first_name           ,
            v_user_last_name            ,
            sysdate                     ,
            user
          );

          sp_trg_global.v_rec_tab(nvl(sp_trg_global.v_index,0)).service_id := v_service_id;
          sp_trg_global.v_rec_tab(nvl(sp_trg_global.v_index,0)).contact_objid := v_contact_objid;
          sp_trg_global.v_rec_tab(nvl(sp_trg_global.v_index,0)).road_ftp_objid := v_road_ftp_objid;
          sp_trg_global.v_index := nvl(sp_trg_global.v_index,0) + 1;
          -- end of no unsent record exists
        ELSE
          -- There is an unsent record
          v_step := 'updating x_road_ftp';
          UPDATE x_road_ftp
          SET first_name = v_first_name
              ,last_name = v_last_name
              ,phone = v_phone
              ,e_mail = v_e_mail
              ,last_update_date = sysdate
              ,last_updated_by = user
          WHERE objid = v_road_ftp_objid;
          sp_trg_global.v_rec_tab(nvl(sp_trg_global.v_index,0)).service_id := v_service_id;
          sp_trg_global.v_rec_tab(nvl(sp_trg_global.v_index,0)).contact_objid := v_contact_objid;
          sp_trg_global.v_rec_tab(nvl(sp_trg_global.v_index,0)).road_ftp_objid := v_road_ftp_objid;
          sp_trg_global.v_index := nvl(sp_trg_global.v_index,0) + 1;
        END IF;

EXCEPTION
  WHEN OTHERS THEN
   RAISE_APPLICATION_ERROR(-20001,'Error occured when '||v_step||' '||sqlerrm);
END;
/