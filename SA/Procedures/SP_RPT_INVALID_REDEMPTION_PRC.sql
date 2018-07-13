CREATE OR REPLACE PROCEDURE sa."SP_RPT_INVALID_REDEMPTION_PRC"
AS
 ---------------------------------------------------------------------------------------------
--$RCSfile: SP_RPT_INVALID_REDEMPTION_PRC.sql,v $
--$Revision: 1.2 $
--$Author: ddesilva $
--$Date: 2017/03/22 19:47:39 $
--$Log: SP_RPT_INVALID_REDEMPTION_PRC.sql,v $
--Revision 1.2  2017/03/22 19:47:39  ddesilva
--CR48761
--
---------------------------------------------------------------------------------------------

   CURSOR c_paid_free
   IS
      SELECT   --rc.x_red_units             units,
             --rc.x_access_days               x_access ,
            ts.objid           card_retailer_site,
             pn.x_redeem_units  units,
             pn.x_redeem_days x_access,
             pn.part_number,
             pn.objid part_objid,
             pn.description,
             pn.part_type,
             sp.state_value,   --new
             sp.install_date,   --activation date
             sp.x_zipcode,
             sp.site_part2site,
             SP.site_part2x_plan,
             rc.objid,
             rc.x_red_code,
             rc.x_smp,
             ct.objid call_trans_objid,
             CT.x_sourcesystem,
             ct.x_sub_sourcesystem,
             ct.call_trans2site_part,
             ct.x_service_id,
             ct.x_min,
             ct.x_transact_date,
             ct.x_call_trans2user,
             ib.inv_bin2inv_locatn
           FROM
                   table_part_num pn,
                   table_mod_level ml,
                   table_site_part sp,
                   table_x_call_trans ct,
                   table_x_red_card rc,
                   table_inv_bin ib,
                   table_site ts
            WHERE rc.x_red_date >= sysdate-2
                AND pn.part_type IN ('PAID', 'MPPAID', 'FREE')
                AND
                pn.objid = ml.part_info2part_num
                AND
                ml.objid = rc.x_red_card2part_mod
                AND
                sp.objid = ct.call_trans2site_part --new  (ML)
                AND
                ct.objid  = rc.red_card2call_trans --new (ML)
                AND
                rc.x_result || '' = 'Completed'
                AND
                rc.x_red_card2inv_bin = ib.objid
                AND
                ib.bin_name = ts.site_id
                AND
                site_type IN ('DIST',  'MANF')
                AND ts.TYPE = 3;



CURSOR invalid_dealer_red_cur
IS
SELECT * FROM X_RPT_INVALID_REDEMPTION
WHERE
VALID_DEALER = 'N';


CURSOR check_for_valid_daler_cur ( serial_number_in IN VARCHAR2)
IS
      SELECT ts.site_type,a.*
        FROM
             table_site ts,
             table_inv_bin tib,
             table_x_red_card a
       WHERE
             site_type||'' NOT IN ('DIST',  'MANF')
         AND ts.TYPE+0 = 3
         AND ts.site_id = tib.bin_name
         and tib.objid = a.x_red_card2inv_bin
         and x_smp = serial_number_in ;

         check_for_valid_daler_rec check_for_valid_daler_cur%ROWTYPE;


/****** Private variables ****************************************************/
l_procedure_name CONSTANT VARCHAR2(100) := 'rpt_invalid_redemption_prc';
l_serial_num VARCHAR2(30) ;

l_start_date                 DATE                               := SYSDATE;
l_recs_processed             NUMBER                             := 0;

BEGIN
/*******************Paid and Free Invalid Redemptions*************************/
-- BRAND_SEP
/******************* Insertion into x_rpt_invalid_redemption *****************/

   FOR rec_paid_free IN c_paid_free
   LOOP

      BEGIN
      l_serial_num := rec_paid_free.x_service_id;

         INSERT INTO sa.x_rpt_invalid_redemption
                 SELECT DECODE (
                           cardst.name,
                           'TOPP CORPORATE ENTITLEMENT', 'FREE',
                           'TOPP TELECOM DISCOUN', 'FREE',
                           'TOPP P2G', 'FREE',
                           'VOIDED CARDS', 'FREE',
                           'TOPP SERVICE AND REPAIR', 'FREE',
                           'TOPP TELECOM SERVICE', 'FREE',
                           'TOPP TELECOM MARKETI', 'FREE',
                           'TOPP TELECOM NASCAR', 'FREE',
                           rec_paid_free.part_type
                        ),   --Paid or Free,
                        NULL,   --Promo objid
                        NULL,   --Promo code
                        rec_paid_free.x_service_id,   --esn
                        esnpi.x_po_num,   --esn po number
                        rec_paid_free.x_min,   --cellnum
                        NVL (ac.x_acct_num, 'N/A'),   --cellnum account number
                        cellpi.x_insert_date,   --cellnum insert date
                        rec_paid_free.x_transact_date,   --redemption date
                        rec_paid_free.x_smp,   --card smp
                        rec_paid_free.x_red_code,   --card redemption number
                        rec_paid_free.units,   --card units
                        rec_paid_free.x_access,   --card access
                        rec_paid_free.install_date,   --activation date
                        rec_paid_free.x_zipcode,   --activation zipcode
                        rec_paid_free.call_trans_objid,   --call trans objid
                        rec_paid_free.x_sourcesystem,   --sourcesystem
                        ca.objid,   --carrier objid
                        ca.x_carrier_id,   --carrier id
                        ca.x_mkt_submkt_name,   --carrier name
                        ca.x_carrier2address,   --carrier address objid
                        cmadd.address,   --carrier address
                        cmadd.address_2,   --carrier address 2
                        cmadd.city,
                        cmadd.state, cmadd.zipcode, cg.objid,   --carrier group objid
                        cg.x_carrier_group_id,   --carrier group id
                        cg.x_carrier_name,
                        cg.x_group2address,   --carrier group address objid
                        cgadd.address,   --carrier group address
                        cgadd.address_2,   --carrier group address 2
                        cgadd.city, cgadd.state,
                        cgadd.zipcode, rec_paid_free.x_call_trans2user,   --csr objid
                        us.login_name,   --csr login name
                        em.first_name,   --csr first name
                        em.last_name,   --csr last name
                        cn.first_name,   --customer first name
                        cn.last_name,   --customer last name
                        custadd.address,   --customer address
                        custadd.address_2,   --customer address 2
                        custadd.city,
                        custadd.state, custadd.zipcode, cn.phone,   --customer home phone
                        cardst.objid,   --card dealer objid
                        cardst.site_id,   --card dealer id
                        cardst.name,   --card dealer name
                        rec_paid_free.part_objid,   --card part number objid
                        rec_paid_free.part_number,   --card part number
                        rec_paid_free.description,   --card part description
                        esnst.objid,   --card dealer objid
                        esnst.site_id,   --card dealer id
                        esnst.name,   --card dealer name
                        esnpn.objid,   --card part number objid
                        esnpn.part_number,   --card part number
                        esnpn.description,   --card part description
                        rec_paid_free.site_part2x_plan,   --Click Plan objid
                        cellpi.part_inst2x_pers,   --Personality
                        esnpn.x_technology,   -- esn technology (new)(ML)
                        NVL (rec_paid_free.state_value, 'ANALOG'),   -- act technology (new) (ML)
                        DECODE (
                           cardst.name,
                           'TOPP CORPORATE ENTITLEMENT', cardst.name,
                           'TOPP TELECOM DISCOUN', cardst.name,
                           'TOPP P2G', cardst.name,
                           'VOIDED CARDS', cardst.name,
                           'TOPP SERVICE AND REPAIR', cardst.name,
                           'TOPP TELECOM SERVICE', cardst.name,
                           'TOPP TELECOM MARKETI', cardst.name,
                           'TOPP TELECOM NASCAR', cardst.name,
                           rec_paid_free.part_type
                        ),   --new promotion type
                        'N',   -- valid dealer id
                           NULL,   -- validated date
                           rec_paid_free.x_sub_sourcesystem --BRAND_SEP
                   FROM table_contact           cn,
                        table_contact_role      cr,
                        table_address           custadd,
                        table_site              custsite,
                        table_employee          em,
                        table_user              us,
                        table_address           cgadd,
                        table_x_carrier_group   cg,
                        table_address           cmadd,
                        table_x_account         ac,
                        table_x_account_hist    ah,
                        table_x_carrier         ca,
                        table_site              cardst,
                        table_part_num          esnpn,
                        table_mod_level         esnml,
                        table_site              esnst,
                        table_inv_role          esnir,
                        table_inv_bin           esnib,
                        table_part_inst         cellpi,
                        table_part_inst         esnpi
                  WHERE cmadd.objid             = ca.x_carrier2address
                    AND cgadd.objid             = cg.x_group2address
                    AND custadd.objid           = custsite.cust_primaddr2address
                    AND ac.objid (+)            = ah.account_hist2x_account
                    AND ah.account_hist2part_inst (+) = cellpi.objid
                    AND ah.x_end_date (+)       = TO_DATE ('17530101', 'yyyymmdd')
                    AND cn.objid                = cr.contact_role2contact
                    AND custsite.objid          = cr.contact_role2site
                    AND custsite.objid          = rec_paid_free.site_part2site
                    AND em.employee2user        = us.objid
                    AND us.objid                = rec_paid_free.x_call_trans2user
                    AND cg.objid                = ca.carrier2carrier_group
                    AND ca.objid                = cellpi.part_inst2carrier_mkt
                    AND esnpn.objid             = esnml.part_info2part_num
                    AND esnml.objid             = esnpi.n_part_inst2part_mod
                    AND esnst.objid             = esnir.inv_role2site
                    AND esnir.inv_role2inv_locatn = esnib.inv_bin2inv_locatn
                    AND esnib.objid             = esnpi.part_inst2inv_bin
                    AND cardst.objid            = rec_paid_free.card_retailer_site
                    AND cellpi.part_serial_no   = rec_paid_free.x_min
                    AND cellpi.x_domain         = 'LINES'
                    AND esnpi.part_serial_no    = rec_paid_free.x_service_id
                    AND esnpi.x_domain          = 'PHONES'
                    AND ROWNUM < 2;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            /** Expecting to hit duplicate values          **/
            /** Reason :redemptions might be invalid       **/
            /** for a long time ( dealer id might still be **/
            /** DIST and MANF type ) NOT UPDATED           **/
            NULL;
        WHEN OTHERS THEN
          /** Should handle any other errors instead of letting it the whole procedure fail **/
          toss_util_pkg.insert_error_tab_proc (
               'Inner Block while inserting redemption values',
               l_serial_num,
               l_procedure_name
            );

      END;

      COMMIT;
   END LOOP;

/*** NOW TRY TO VALIDATE DEALER ****/

FOR invalid_dealer_red_rec IN invalid_dealer_red_cur LOOP

   BEGIN
       OPEN  check_for_valid_daler_cur(invalid_dealer_red_rec.card_smp);
       FETCH check_for_valid_daler_cur INTO check_for_valid_daler_rec  ;

       IF check_for_valid_daler_cur%FOUND
       THEN
                     UPDATE table_x_red_card
                        SET x_red_date = sysdate
                      WHERE x_smp = invalid_dealer_red_rec.card_smp; --update all trhe records not only compteted but failed ones


--Update the status of validated SMP in X_RPT_INVALID_REDEMPTION table - 12/03/01 VAdapa
                     UPDATE x_rpt_invalid_redemption
                        SET valid_dealer = 'Y',
                            validated_date = sysdate
                      WHERE card_smp = invalid_dealer_red_rec.card_smp;

                      COMMIT;
		    l_recs_processed := l_recs_processed+1;
       END IF;




       CLOSE check_for_valid_daler_cur;



   EXCEPTION
       WHEN OTHERS THEN
            toss_util_pkg.insert_error_tab_proc (
               'Inner Block while validating dealer',
               l_serial_num,
               l_procedure_name
            );


   END;



END LOOP;

IF toss_util_pkg.insert_interface_jobs_fun (l_procedure_name,
                                               l_start_date,
                                               SYSDATE,
                                               l_recs_processed,
                                               'SUCCESS',
                                               l_procedure_name
                                              )
THEN
      COMMIT;
END IF;


END;
/