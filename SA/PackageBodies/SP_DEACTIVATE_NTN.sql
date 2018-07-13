CREATE OR REPLACE PACKAGE BODY sa."SP_DEACTIVATE_NTN" AS
/*******************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved             */
/*                                                                             */
/* NAME:         SP_DEACTIVATE_NTN (BODY)                                      */
/* PURPOSE:                                                                    */
/* FREQUENCY:                                                                  */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                              */
/*                                                                             */
/* REVISIONS:                                                                  */
/* VERSION  DATE        WHO          PURPOSE                                   */
/* -------  ---------- -----  ---------------------------------------------    */
/*  1.0                       Initial  Revision                                */
/*                                                                             */
/*  1.2     07/05/2002  SL    Add X_SUB_SOURCESYSTEM field for call trans      */
/*                            insert statement                                 */
/*  1.3     04/10/2003  SL    Clarify Upgrade - sequence                       */
/*  1.4     10/28/2004  GP    CR3318 Removed old deactivate_service logic to   */
/*                            use new sa.service_deactivation.DeactService pkg */
/*******************************************************************************/

PROCEDURE deactivate_ntn(str_esn IN  VARCHAR2,
                         str_out OUT VARCHAR2)
 IS
  v_user TABLE_USER.objid%TYPE;
  v_returnflag VARCHAR2(20);
  v_returnMsg  VARCHAR2(200);


  CURSOR sp_curs(esn IN VARCHAR2)
  IS
    SELECT sp.x_service_id,
           sp.x_min
      FROM TABLE_SITE_PART  sp
     WHERE sp.x_service_id = esn
       AND sp.part_status ||''= 'Active';


     sp_curs_rec sp_curs%ROWTYPE;

BEGIN
  dbms_transaction.use_rollback_segment('R07_BIG');

    -- Gets appsrv user objid
    SELECT objid INTO v_user
      FROM TABLE_USER
     WHERE login_name = 'appsrv';

    FOR sp_curs_rec IN sp_curs(str_esn) LOOP

          -- Call deactService pkg without creating action item
          sa.Service_deactivation.deactService
              ('NON TOPP LINE',
                v_user,
                sp_curs_rec.x_service_id,
                sp_curs_rec.x_min,
                'NON TOPP LINE',
                2,  --> flag bypasses creation of action item
                null,
                'true',
                v_returnflag,
                v_returnMsg
               );

         IF v_returnflag = 'true' THEN
           str_out := 'SUCCESS';
         ELSE
           str_out := 'FAIL';
         END IF;

    END LOOP;
END deactivate_ntn;

END Sp_deactivate_ntn;
/