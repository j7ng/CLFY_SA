CREATE OR REPLACE PROCEDURE sa."SP_RPT_INVALID_REDEMPTION_PRC2"
AS
/******************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         Sp_Rpt_Invalid_Redemption_Prc2                                */
/* PURPOSE:      This procedure inserts the redemptions that took place where */
/*               the site_id was of 'MANF', 'DIST' ("invalid dealer") into the*/
/*               x_rpt_INVALID_redemption( CURSOR c_paid_free).               */
/*                                                                            */
/*                                                                            */
/*               This procedures only focus on physical cards.                */
/* FREQUENCY:    Every 24 hours                                               */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/*                                                                            */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO               PURPOSE                             */
/* -------  ----------  ---------------   -------------------                 */
/* 1.0      09/24/01    Miguel Leon        Initial Revision                   */
/* 1.1      10/19/01    Miguel Leon        Added new cursor c_paid_free2 with */
/*                                         related insertion statement into   */
/*                                         the x_rpt_redemption table.        */
/*                                         Also added statements to update    */
/*                                         the status '41'(table_part_inst)for*/
/*                                         cards that were inserted into x_rpt*/
/*                                         _redemption and finally update/flag*/
/*                                         the validated in the x_rpt_inv     */
/*                                         alid redemption table              */
/* 1.2      11/06/01    Miguel Leon        Included x_red_date into the c_paid*/
/*                                         free2 cursor that deals with 46s so*/
/*                                         that we now insert the x_red_date  */
/*                                         instead of the call_trans_date     */
/*                                         Move commits to take place at each */
/*                                         pass of the loops.                 */
/* 1.3      12/02/01   Miguel Leon         Commented out all the logic related*/
/*                                         to inserting '46's into the x_rpt_ */
/*                                         redemption table. 46 is not longer */
/*                                         an used status.Change the descript */
/*                                         on the header.                     */
/*1.4       07/18/02   VAdapa              Modified to insert sub_sourcesystem*/
/*                                         value based on call_trans          */
/*1.5       04/28/03    jBORJA             Modfication for clarify changes.   */
/*                                         All redeemed cards deleted from    */
/*                                         Part_inst                          */
/*1.6       12/10/03    Mleon              Include validation logic for       */
/*                                         redeeemed cards with valid dealer  */
/*1.7	    02/02/04	MNazir		   Added date flag to avoid FTS of    */
/*					   x_red_card			      */
/******************************************************************************/
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
                   TABLE_PART_NUM pn,
                   TABLE_MOD_LEVEL ml,
                   TABLE_SITE_PART sp,
                   TABLE_X_CALL_TRANS ct,
                   stg_x_red_card rc,
                   TABLE_INV_BIN ib,
                   TABLE_SITE ts
            WHERE rc.x_red_date >= SYSDATE-2
                AND pn.part_type IN ('PAID',  'FREE')
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
      SELECT ts.site_type,A.*
        FROM
             TABLE_SITE ts,
             TABLE_INV_BIN tib,
             stg_x_red_card A
       WHERE
             site_type||'' NOT IN ('DIST',  'MANF')
         AND ts.TYPE+0 = 3
         AND ts.site_id = tib.bin_name
         AND tib.objid = A.x_red_card2inv_bin
         AND x_smp = serial_number_in ;

         check_for_valid_daler_rec check_for_valid_daler_cur%ROWTYPE;


/****** Private variables ****************************************************/
l_procedure_name CONSTANT VARCHAR2(100) := 'rpt_invalid_redemption_prc';
l_serial_num VARCHAR2(30) ;

BEGIN
/*******************Paid and Free Invalid Redemptions*************************/
/******************* Insertion into x_rpt_invalid_redemption *****************/
   FOR rec_paid_free IN c_paid_free
   LOOP

      BEGIN
         INSERT INTO sa.X_RPT_INVALID_REDEMPTION
                 SELECT DECODE (
                           cardst.NAME,
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
                        cardst.NAME,   --card dealer name
                        rec_paid_free.part_objid,   --card part number objid
                        rec_paid_free.part_number,   --card part number
                        rec_paid_free.description,   --card part description
                        esnst.objid,   --card dealer objid
                        esnst.site_id,   --card dealer id
                        esnst.NAME,   --card dealer name
                        esnpn.objid,   --card part number objid
                        esnpn.part_number,   --card part number
                        esnpn.description,   --card part description
                        rec_paid_free.site_part2x_plan,   --Click Plan objid
                        cellpi.part_inst2x_pers,   --Personality
                        esnpn.x_technology,   -- esn technology (new)(ML)
                        NVL (rec_paid_free.state_value, 'ANALOG'),   -- act technology (new) (ML)
                        DECODE (
                           cardst.NAME,
                           'TOPP CORPORATE ENTITLEMENT', cardst.NAME,
                           'TOPP TELECOM DISCOUN', cardst.NAME,
                           'TOPP P2G', cardst.NAME,
                           'VOIDED CARDS', cardst.NAME,
                           'TOPP SERVICE AND REPAIR', cardst.NAME,
                           'TOPP TELECOM SERVICE', cardst.NAME,
                           'TOPP TELECOM MARKETI', cardst.NAME,
                           'TOPP TELECOM NASCAR', cardst.NAME,
                           rec_paid_free.part_type
                        ),   --new promotion type
                        'N',   -- valid dealer id
                            NULL,   -- validated date
                                 cd.x_code_name   --sub_sourcesystem 07/18/02
                   FROM TABLE_CONTACT           cn,
                        TABLE_CONTACT_ROLE      cr,
                        TABLE_ADDRESS           custadd,
                        TABLE_SITE              custsite,
                        TABLE_EMPLOYEE          em,
                        TABLE_USER              us,
                        TABLE_ADDRESS           cgadd,
                        TABLE_X_CARRIER_GROUP   cg,
                        TABLE_ADDRESS           cmadd,
                        TABLE_X_ACCOUNT         ac,
                        TABLE_X_ACCOUNT_HIST    ah,
                        TABLE_X_CARRIER         ca,
                        TABLE_SITE              cardst,
                        TABLE_PART_NUM          esnpn,
                        TABLE_MOD_LEVEL         esnml,
                        TABLE_SITE              esnst,
                        TABLE_INV_ROLE          esnir,
                        TABLE_INV_BIN           esnib,
                        TABLE_PART_INST         cellpi,
                        TABLE_PART_INST         esnpi,
                        TABLE_X_CODE_TABLE cd
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
                    AND cd.x_code_number        = rec_paid_free.x_sub_sourcesystem
                    AND ROWNUM < 2;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            /** Expecting to hit duplicate values          **/
            /** Reason :redemptions might be invalid       **/
            /** for a long time ( dealer id might still be **/
            /** DIST and MANF type ) NOT UPDATED           **/
            NULL;
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
                     UPDATE stg_x_red_card
                        SET x_red_date = SYSDATE
                      WHERE x_smp = invalid_dealer_red_rec.card_smp; --update all trhe records not only compteted but failed ones


--Update the status of validated SMP in X_RPT_INVALID_REDEMPTION table - 12/03/01 VAdapa
                     UPDATE X_RPT_INVALID_REDEMPTION
                        SET valid_dealer = 'Y',
                            validated_date = SYSDATE
                      WHERE card_smp = invalid_dealer_red_rec.card_smp;

                      COMMIT;

       END IF;




       CLOSE check_for_valid_daler_cur;



   EXCEPTION
       WHEN OTHERS THEN
            Toss_Util_Pkg.Insert_Error_Tab_Proc (
               'Inner Block while validating dealer',
               l_serial_num,
               l_procedure_name
            );


   END;



END LOOP;

COMMIT;




EXCEPTION

   WHEN OTHERS
   THEN
            Toss_Util_Pkg.Insert_Error_Tab_Proc (
               'Main Block',
               l_serial_num,
               l_procedure_name
            );

      COMMIT;
END;
/