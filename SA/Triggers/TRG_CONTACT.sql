CREATE OR REPLACE TRIGGER sa."TRG_CONTACT"
AFTER UPDATE OF ADDRESS_1,ADDRESS_2,CITY,E_MAIL,FIRST_NAME,LAST_NAME,PHONE,STATE,ZIPCODE
ON sa.TABLE_CONTACT
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
  DISABLE WHEN (
 UPPER(RTRIM(LTRIM(NEW.FIRST_NAME))) <>UPPER(RTRIM(LTRIM(OLD.FIRST_NAME)))
 OR UPPER(RTRIM(LTRIM(NEW.LAST_NAME))) <> UPPER(RTRIM(LTRIM(OLD.LAST_NAME)))
 OR NVL(UPPER(RTRIM(LTRIM(NEW.ADDRESS_1))),'00') <> NVL(UPPER(RTRIM(LTRIM(OLD.ADDRESS_1))),'00')
 OR NVL(UPPER(RTRIM(LTRIM(NEW.ADDRESS_2))),'00') <> NVL(UPPER(RTRIM(LTRIM(OLD.ADDRESS_2))),'00')
 OR NVL(UPPER(RTRIM(LTRIM(NEW.PHONE))),'00') <> NVL(UPPER(RTRIM(LTRIM(OLD.PHONE))),'00')
 OR NVL(UPPER(RTRIM(LTRIM(NEW.E_MAIL))),'00') <> NVL(UPPER(RTRIM(LTRIM(OLD.E_MAIL))),'00')
 OR NVL(UPPER(RTRIM(LTRIM(NEW.CITY))),'00') <> NVL(UPPER(RTRIM(LTRIM(OLD.CITY))),'00')
 OR NVL(UPPER(RTRIM(LTRIM(NEW.STATE))),'00') <> NVL(UPPER(RTRIM(LTRIM(OLD.STATE))),'00')
 OR NVL(UPPER(RTRIM(LTRIM(NEW.ZIPCODE))),'00') <> NVL(UPPER(RTRIM(LTRIM(OLD.ZIPCODE))),'00')
 ) DECLARE
/*******************************************************************************
 * Trigger Name: TRG_CONTACT
 *
 * Created By: SL
 * Creation Date: 02/22/02
 *
 * Description: For Roadside Application, the trigger will insert/update ftp
 *              record when contact information changes.
 *
 * History
 * When                Who                    Description
 * ===========================================================================
 * 04/18/02            SL                     Fix null address in x_road_ftp
 *                                            Add when condition to trigger to
 *                                            prevent unnessary trigger firing
 *******************************************************************************/
    v_road_ftp_objid           number;
    v_service_id               varchar2(30);
    v_smp                      varchar2(30);
    v_program_name             varchar2(80) := 'ROADSIDE';
    v_first_name               varchar2(30);
    v_last_name                varchar2(30);
    v_address_1                varchar2(200);
    v_address_2                varchar2(200);
    v_city                     varchar2(30);
    v_state                    varchar2(40);
    v_zipcode                  varchar2(20);
    v_phone                    varchar2(20);
    v_e_mail                   varchar2(80);
    v_info_reqd                varchar2(10);
    v_trans_type               varchar2(10);
    v_activation_date          date;
    v_service_start_date       date;
    v_service_end_date         date;
    v_deactivation_date        date;
    v_deact_reason             varchar2(30);
    v_term                     number := 12;
    v_wholesale_cost           number;
    v_card_plan                varchar2(10);
    v_card_type                varchar2(20);
    v_wholesale_refund         number;
    v_customer_refund          number;
    v_refund_percent           number;
    v_ftp_create_status        varchar2(20) := 'NO';
    v_ftp_create_date          date;
    v_orafin_post              varchar2(20);
    v_dep1_first_name          varchar2(40);
    v_dep1_last_name           varchar2(40);
    v_dep2_first_name          varchar2(40);
    v_dep2_last_name           varchar2(40);
    v_dep3_first_name          varchar2(40);
    v_dep3_last_name           varchar2(40);
    v_dep4_first_name          varchar2(40);
    v_dep4_last_name           varchar2(40);
    v_dependent_count          number;
    v_promo_objid              number ;
    v_promo_code               varchar2(30);
    v_call_trans_objid         number;
    v_sourcesystem             varchar2(30);
    v_road_dealer_objid        number;
    v_road_dealer_id           varchar2(80);
    v_road_dealer_name         varchar2(80);
    v_road_part_num_objid      number;
    v_road_part_number         varchar2(30);
    v_road_part_description    varchar2(255);
    v_road_part_retailcost     number(8,2);
    v_user_objid               number;
    v_user_login_name          varchar2(30);
    v_user_first_name          varchar2(30);
    v_user_last_name           varchar2(30);

    v_contact_objid            number;
    v_site_part_objid          number;
    v_prim_address_objid       number;
    v_mod_level_objid          number;
    v_step                     varchar2(100);
    v_ftp_no_sent_objid        number;
    v_action                   varchar2(10);

 CURSOR c_contact_site_part IS
    SELECT sp.x_service_id, sp.objid sp_objid, sp.install_date,
           sp.x_expire_dt, sp.service_end_dt, sp.x_deact_reason,
           sp.site_part2site, sp.site_part2part_info, sp.machine_id,
           s.objid site_objid, s.site_id,
           s.name, s.cust_primaddr2address
    FROM table_site_part sp
         , table_site s
         , table_contact_role cr
    WHERE 1=1
    AND  sp.part_status ||'' = 'Active'
    AND  UPPER(sp.instance_name) = 'ROADSIDE'
    AND  s.objid = sp.site_part2site
    AND  cr.contact_role2site = s.objid
    AND  cr.contact_role2contact = v_contact_objid;

BEGIN
   v_contact_objid := :new.objid;
   FOR c_contact_site_part_rec in c_contact_site_part LOOP
       -- copying contact info
       v_step := 'copying contact info into vars';
       v_first_name := :new.first_name;
       v_last_name  := :new.last_name;
       v_phone := :new.phone;
       v_e_mail := :new.e_mail;
       v_service_id := c_contact_site_part_rec.x_service_id;

       -- getting site, site_part info
       v_step := 'getting site, site_part info';
       v_smp  := c_contact_site_part_rec.machine_id;
       v_activation_date := c_contact_site_part_rec.install_date;
       v_service_start_date := sysdate + 3;
       v_service_end_date := c_contact_site_part_rec.x_expire_dt;
       v_deactivation_date := c_contact_site_part_rec.service_end_dt;
       v_deact_reason := c_contact_site_part_rec.x_deact_reason;
       v_mod_level_objid := c_contact_site_part_rec.site_part2part_info;
       v_prim_address_objid := c_contact_site_part_rec.cust_primaddr2address;

       --04/18/02
       IF v_prim_address_objid IS NOT NULL THEN
            -- get user, employee info
            v_step := 'getting address info.';
            BEGIN
               SELECT address, address_2,city, state, zipcode
               INTO  v_address_1, v_address_2, v_city, v_state, v_zipcode
               FROM  table_address
               WHERE objid = v_prim_address_objid;
            EXCEPTION
              WHEN others THEN
               NULL;
            END;
       END IF;

       -- check if unsent record exists fro contact
       v_step := 'checking unsent ftp record';
       BEGIN
         SELECT objid,trans_type INTO v_ftp_no_sent_objid,v_trans_type
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

       IF v_ftp_no_sent_objid is null THEN

          -- get dealer info
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
            WHEN others THEN
             RETURN;
          END;

          -- get part number info
          v_step := 'getting part number info.';
          BEGIN
              SELECT pn.objid, pn.part_number, pn.description, pn.x_retailcost,
                     pn.x_card_type, pn.x_card_plan, pn.x_wholesale_price
              INTO v_road_part_num_objid, v_road_part_number, v_road_part_description,
                   v_road_part_retailcost, v_card_type, v_card_plan, v_wholesale_cost
              FROM table_part_num pn, table_mod_level ml
              WHERE ml.part_info2part_num = pn.objid
              AND  ml.objid = v_mod_level_objid;
          EXCEPTION
            WHEN others THEN
              RETURN;
          END;

          -- get user, employee info
          v_step := 'getting user, employee info.';
          BEGIN
            SELECT u.objid, u.login_name, e.first_name, e.last_name
            INTO  v_user_objid, v_user_login_name, v_user_first_name, v_user_last_name
            FROM table_employee e, table_user u
            WHERE u.objid = e.employee2user
            AND u.s_login_name = upper(user);
          EXCEPTION
            WHEN others THEN
             NULL;
          END;

          -- get dependent info
          v_dependent_count := 0;
          v_step := 'getting dependent info.';
          FOR c_depent_rec IN (SELECT x_first_name, x_last_name FROM table_x_dependents
                               WHERE x_dependents2contact = v_contact_objid ) LOOP
            v_dependent_count := v_dependent_count + 1;
            IF v_dependent_count = 1 THEN
              v_dep1_first_name := c_depent_rec.x_first_name;
              v_dep1_last_name := c_depent_rec.x_last_name;
            ELSIF v_dependent_count = 2 THEN
              v_dep2_first_name := c_depent_rec.x_first_name;
              v_dep2_last_name := c_depent_rec.x_last_name;
            ELSIF v_dependent_count = 3 THEN
              v_dep3_first_name := c_depent_rec.x_first_name;
              v_dep3_last_name := c_depent_rec.x_last_name;
            ELSIF v_dependent_count = 4 THEN
              v_dep4_first_name := c_depent_rec.x_first_name;
              v_dep4_last_name := c_depent_rec.x_last_name;
            END IF;
          END LOOP;

          v_trans_type := 'U';
          IF v_trans_type = 'N' THEN
              v_orafin_post := 'NO';
          ELSE
              v_orafin_post := 'NA';
          END IF;
          --
          -- Insert new row into table_x_road_ftp
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
               seq_x_road_ftp.nextval + power(2,28),
               v_service_id 		,
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
       ELSE
            -- UPDATE if unsent record exist
            v_step := 'update table_x_road_ftp';
            UPDATE x_road_ftp
            SET ADDRESS_1  =   v_address_1   ,
	        ADDRESS_2  =   v_address_2  ,
	        CITY       =   v_city   ,
	        STATE      =   v_state   ,
	        ZIPCODE    =   v_zipcode   ,
	        PHONE      =   v_phone  ,
	        E_MAIL     =   v_e_mail ,
	        LAST_UPDATE_DATE = sysdate,
	        LAST_UPDATED_BY = user
            WHERE objid =  v_ftp_no_sent_objid;
       END IF;

   END LOOP;
EXCEPTION
  WHEN OTHERS THEN
   RAISE_APPLICATION_ERROR(-20001,'Error occured when '||v_step||' '||sqlerrm);
END;
/