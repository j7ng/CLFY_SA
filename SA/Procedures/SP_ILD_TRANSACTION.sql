CREATE OR REPLACE PROCEDURE sa."SP_ILD_TRANSACTION"
(
  p_min     VARCHAR2
 ,p_action  VARCHAR2
 ,p_account VARCHAR2
 ,p_errnum  OUT VARCHAR2
 ,p_errstr  OUT VARCHAR2
) IS
  /*****************************************************************************************/
  /*    Copyright ) 2005 Tracfone  Wireless Inc. All rights reserved                    */
  /*                                                                                    */
  /* NAME:         sp_ild_transaction.sql                                               */
  /* PURPOSE:                                                                           */
  /* FREQUENCY:                                                                         */
  /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                     */
  /* REVISIONS:    VERSION  DATE        WHO               PURPOSE                       */
  /*               -------  ----------  ---------------   -------------------           */
  /*               1.0      07/28/05    NEG               Initial Revision              */
  /*               1.1      06/23/06    NEG               Do not activate if ILD Type=0 */
  /*               1.2      07/10/06    VA              CR4960F - Added "Hold" filter */
  /*          1.3       08/11/06    VA             CR5364 changes
  /*              1.4   03/19/07    NEG         CR5955 Cancel Status Update for Motricity*/
  /*          1.5       06/04/07    VA             CR5626 - Fixed the cursor (c_get_part) fetch
  /*       1.6       06/14/07    VA            Fix to process the pending records
  /**************************************************************************************/
  /*
  /* new pvcs structure NEW_PLSQL
  /* REV:   VERSION   DATE        WHO  PURPOSE                       */
  /*        -------   ----------  ---- -------------------           */
  /*        1.0       04/29/08    CL   Forced to use MIN index
  /*        1.1       08/31/09    NG   BRAND_SEP Separate the Brand and Source System
  /*                                   incorporate use of new table TABLE_BUS_ORG to retrieve
  /*                                   brand information that was previously identified by the fields
  /*                                   x_restricted_use and/or amigo from table_part_num

  /**************************************************************************************/
  /* new pvcs structure NEW_PLSQL
  /* REV:   VERSION   DATE        WHO  PURPOSE                                     */
  /*        -------   ----------  ---- -------------------                         */
  /*        1.1       05/28/10    LS   CR12686                                     */
  /*        1.3       11/17/10    VA   CR12369                                     */
  /*        1.4/1.5    4/03/12    CL   CR19853                                     */
  /*        1.6       07/23/12    IC  CR20451 | CR20854: Add TELCEL Brand          */
  /*        1.14      02/12/2013  YM  CR22487 Net10 Homephone                      */
  /*        1.15      02/22/2013  YM  CR22452 Simple Mobile                        */
  /*        1.16      04/05/2013  IC  CR23710 TELCEL Homephone                     */
  /***************************************************************************************/
  --
  --********************************************************************************
  --$RCSfile: SP_ILD_TRANSACTION.sql,v $
  --$Revision: 1.22 $
  --$Author: vmallela $
  --$Date: 2016/11/29 19:04:35 $
  --$ $Log: SP_ILD_TRANSACTION.sql,v $
  --$ Revision 1.22  2016/11/29 19:04:35  vmallela
  --$ T-NUmbers shouldnt be recorded in the table_x_ild_transaction table for API processing, so filtering the T-Numbers
  --$
  --$ Revision 1.20  2014/03/26 14:20:02  ymillan
  --$ CR27015
  --$
  --$ Revision 1.19  2014/03/14 19:34:04  ymillan
  --$ CR27015
  --$
  --$ Revision 1.18  2013/11/18 19:40:46  ymillan
  --$ CR26327
  --$
  --$ Revision 1.17  2013/09/26 16:08:47  ymillan
  --$ CR25632
  --$
  --$ Revision 1.16  2013/04/05 21:51:54  icanavan
  --$ TCHOME
  --$
  --$ Revision 1.15  2013/02/25 20:29:46  ymillan
  --$ CR22452  SIMPLE MOBILE + Net10 HP
  --$
  --$ Revision 1.13  2012/09/24 13:46:14  kacosta
  --$ CR21157 TF Pay As You Go ILD
  --$
  --$ Revision 1.12  2012/09/11 20:13:30  kacosta
  --$ CR21157 TF Pay As You Go ILD
  --$
  --$ Revision 1.11  2012/09/11 14:33:37  kacosta
  --$ CR21157 TF Pay As You Go ILD
  --$
  --$ Revision 1.10  2012/09/10 17:42:48  kacosta
  --$ CR21157 TF Pay As You Go ILD
  --$
  --$
  --********************************************************************************
  --   --Valid p_action:
  --ILD_CREATE,ILD_CREATE_SENT,ILD_CREATE_OK,_ILD_CREATE_FAIL
  --ILD_DEACT,ILD_DEACT_SENT,ILD_DEACT_OK,ILD_DEACT_FAIL

  --    CURSOR site_part_curs(
  --       c_min VARCHAR2
  --    )
  --    IS
  --    SELECT objid,
  --       x_min,
  --       x_service_id
  --    FROM table_site_part
  --    WHERE x_min = NVL(c_min, '0')
  --    ORDER BY part_status ASC, install_date DESC;
  CURSOR site_part_curs(c_min VARCHAR2) IS
    SELECT sp.objid
          ,sp.x_min
          ,sp.x_service_id
          ,pn.x_ild_type
      FROM table_site_part sp
          ,table_part_inst pi
          ,table_mod_level ml
          ,table_part_num  pn
     WHERE sp.x_min = NVL(c_min
                         ,'0')
       AND pi.part_serial_no = sp.x_service_id
       AND ml.objid = n_part_inst2part_mod
       AND pn.objid = ml.part_info2part_num
     ORDER BY sp.part_status  ASC
             ,sp.install_date DESC;

  -- CL 1.0 new pvcs structure force to use MIN index
  CURSOR ild_trans_curs
  (
    c_min    VARCHAR2
   ,c_action VARCHAR2
   ,c_status VARCHAR2
  ) IS
    SELECT *
      FROM table_x_ild_transaction
     WHERE x_min = NVL(c_min
                      ,'0')
          --CR21157 Start Kacosta 09/11/2012
          --AND x_ild_trans_type || '' = c_action
          --AND x_ild_status || '' = NVL(c_status
          --                            ,'');
       AND CASE
             WHEN UPPER(x_ild_trans_type) = 'ILD_CREATE' THEN
              'A'
             WHEN UPPER(x_ild_trans_type) = 'ILD_DEACT' THEN
              'D'
             ELSE
              UPPER(x_ild_trans_type)
           END = UPPER(c_action)
       AND UPPER(x_ild_status) = NVL(UPPER(c_status)
                                    ,'');
  --CR21157 End Kacosta 09/11/2012

  CURSOR ota_features_curs(c_esn VARCHAR2) IS
    SELECT *
      FROM table_x_ota_features
     WHERE x_ota_features2part_inst IN (SELECT objid
                                          FROM table_part_inst
                                         WHERE part_serial_no = c_esn);

  site_part_rec    site_part_curs%ROWTYPE;
  ild_trans_rec    ild_trans_curs%ROWTYPE;
  ota_features_rec ota_features_curs%ROWTYPE;
  ild_trans_type   VARCHAR2(20);
  ild_status       VARCHAR2(20);
  ild_prev_status  VARCHAR2(20);
  ILD_ACCOUNT      VARCHAR2(30);

  --CR5364
  --
  -- BRAND_SEP
  CURSOR c_get_part(ip_esn IN VARCHAR2) IS
    SELECT pn.part_number
          ,bo.org_id --PN.x_restricted_use
      FROM table_mod_level ml
          ,table_part_num  pn
          ,table_part_inst pi
          ,table_bus_org   bo
     WHERE pi.n_part_inst2part_mod + 0 = ml.objid
       AND ml.part_info2part_num = pn.objid
       AND part_serial_no IN (ip_esn)
       AND PN.PART_NUM2BUS_ORG = BO.OBJID;
 r_get_part     c_get_part%ROWTYPE;
 ild_product_id VARCHAR2(30);
  --CR5364
BEGIN
  p_errnum    := '0';
  p_errstr    := '';
  ild_account := LTRIM(p_account);
  ild_account := RTRIM(ild_account);

  IF p_action = 'ILD_CREATE_OK'
     AND (ild_account IS NULL OR ild_account = '') THEN
    p_errnum := 'ILD_ERR_03';
    p_errstr := 'ILD Account is required as parameter for ILD_CREATE_OK';
    RETURN;
  END IF;

  OPEN site_part_curs(p_min);

  FETCH site_part_curs
    INTO site_part_rec;

  IF site_part_curs%NOTFOUND
     OR NVL(site_part_rec.x_ild_type
           ,0) = 0 THEN
    p_errnum := 'ILD_ERR_01';
    p_errstr := 'Min not found or is not active or does not have ILD type';

    CLOSE site_part_curs;

    RETURN;
  END IF;

  p_errstr := site_part_rec.x_service_id;

  CLOSE site_part_curs;

  OPEN ota_features_curs(site_part_rec.x_service_id);

  FETCH ota_features_curs
    INTO ota_features_rec;

  IF ota_features_curs%NOTFOUND THEN
    p_errnum := 'ILD_ERR_04';
    p_errstr := 'OTA Features record not found';

    CLOSE ota_features_curs;

    RETURN;
  END IF;

  CLOSE ota_features_curs;

  IF p_action <> 'ILD_CREATE_OK' THEN
    --Use account on file
    ild_account := NVL(ota_features_rec.x_ild_account
                      ,'');
  END IF;

  IF p_action NOT IN ('ILD_CREATE'
                     ,'ILD_CREATE_SENT'
                     ,'ILD_CREATE_OK'
                     ,'ILD_CREATE_FAIL'
                     ,'ILD_DEACT'
                     ,'ILD_DEACT_SENT'
                     ,'ILD_DEACT_OK'
                     ,'ILD_DEACT_FAIL') THEN
    p_errnum := 'ILD_ERR_02';
    p_errstr := 'Action not valid';
    RETURN;
  END IF;

  IF p_action IN ('ILD_CREATE'
                 ,'ILD_CREATE_SENT'
                 ,'ILD_CREATE_OK'
                 ,'ILD_CREATE_FAIL') THEN
    --CR21157 Start Kacosta 09/11/2012
    --ild_trans_type := 'ILD_CREATE';
    ild_trans_type := 'A';
    --CR21157 End Kacosta 09/11/2012
  ELSE
    --CR21157 Start Kacosta 09/11/2012
    --ild_trans_type := 'ILD_DEACT';
    ild_trans_type := 'D';
    --CR21157 End Kacosta 09/11/2012
  END IF;

  IF p_action IN ('ILD_CREATE'
                 ,'ILD_DEACT') THEN
    --CR21157 Start Kacosta 09/11/2012
    --ild_status      := 'Pending';
    --ild_prev_status := 'Pending';
    ild_status      := 'PENDING';
    ild_prev_status := 'PENDING';
    --CR21157 End Kacosta 09/11/2012
  END IF;

  IF p_action IN ('ILD_CREATE_OK'
                 ,'ILD_DEACT_OK') THEN
    ild_status      := 'Completed';
    ild_prev_status := 'Processed';
  END IF;

  IF p_action IN ('ILD_CREATE_SENT'
                 ,'ILD_DEACT_SENT') THEN
    ild_status := 'Processed';
    --CR21157 Start Kacosta 09/11/2012
    --ild_prev_status := 'Pending';
    ild_prev_status := 'PENDING';
    --CR21157 End Kacosta 09/11/2012
  END IF;

  IF p_action IN ('ILD_CREATE_FAIL'
                 ,'ILD_DEACT_FAIL') THEN
    ild_status      := 'Failed';
    ild_prev_status := 'Processed';
  END IF;

  OPEN ild_trans_curs(p_min
                     ,ild_trans_type
                     ,ild_prev_status);

  FETCH ild_trans_curs
    INTO ild_trans_rec;

  IF ild_trans_curs%NOTFOUND THEN
    CLOSE ild_trans_curs;

    UPDATE table_x_ild_transaction
       SET x_ild_status  = 'Canceled'
          ,x_last_update = SYSDATE
          ,x_ild_account = ild_account
     WHERE x_min = p_min
          --cwl 4/3/12 CR19853
          -- CR20451 | CR20854: Add TELCEL Brand   added TC_ILD_U
          --CR21157 Start Kacosta 09/10/2012
          --AND x_product_id not in ('NT_ILD_U','ST_ILD_U', 'TC_ILD_U','STH_ILD_U' )
       AND X_PRODUCT_ID NOT IN (select x_ild_product
                                  from sa.TABLE_X_ILD_PRODUCT)  ---CR27015
       AND x_ild_status NOT IN ('Completed'
                               ,'Failed'
                               ,'Hold')
          ------CR12686
          --AND NVL (x_target_system, '0') <> 'motricity';
       AND NVL(x_target_system
              ,'0') NOT IN ('motricity'
                           ,'comverse');
    -------CR12686
    OPEN c_get_part(site_part_rec.x_service_id);

    --CR5626
    FETCH c_get_part
      INTO r_get_part;

    IF c_get_part%FOUND THEN
      --BRAND_SEP
      --IF r_get_part.x_restricted_use = '3'
      -- CR20451 | CR20854: Add TELCEL Brand  ADDED ELSIF FOR THE TELCEL
      IF r_get_part.org_id = 'NET10'
      --BRAND_SEP
       THEN
        --CR21157 Start kacosta 09/10/2012
        --ild_product_id := '10009';
        ild_product_id := 'NT_PILD_P';
        --CR21157 End kacosta 09/10/2012
      ELSIF R_GET_PART.ORG_ID = 'TELCEL' THEN

         ILD_PRODUCT_ID := sa.DEVICE_UTIL_PKG.GET_ILD_PRD(SITE_PART_REC.X_SERVICE_ID);
        IF ILD_PRODUCT_ID  = 'NOT_EXIST' THEN
         -- default ILD product for Telcel Unlimited
         ILD_PRODUCT_ID := sa.DEVICE_UTIL_PKG.GET_ILD_PRD_DEF('TELCEL'); --'TC_ILD_U';
        END IF;

      ------------
      --CR25632
       ----------
      ELSIF R_GET_PART.ORG_ID = 'SIMPLE_MOBILE' THEN  --CR22452
        ild_product_id := sa.DEVICE_UTIL_PKG.GET_ILD_PRD_DEF('SIMPLE_MOBILE');--'SM_ILD_U';
      ELSE
        --CR21157 Start kacosta 09/10/2012
        --ild_product_id := '10024';
        ild_product_id := sa.DEVICE_UTIL_PKG.GET_ILD_PRD_DEF('TRACFONE');--'TF_PILD_P';
        --CR21157 End kacosta 09/10/2012
        --Rev 1.6
        INSERT INTO table_x_psms_outbox
          (objid
          ,x_seq
          ,x_esn
          ,x_command
          ,x_status
          ,x_creation_date
          ,x_ild_type)
          SELECT sa.seq('x_psms_outbox')
                ,x_seq
                ,site_part_rec.x_service_id
                ,x_command
                ,'Pending'
                ,SYSDATE
                ,x_ild_type
            FROM table_x_psms_template
           WHERE x_ild_type = 4;
        --Rev 1.6
      END IF;
    ELSE
      ild_product_id := NULL;
    END IF;

    CLOSE c_get_part; --CR5626

IF p_min NOT LIKE 'T%' THEN -- CR44905 -- T-NUmbers shouldnt be recorded in the table_x_ild_transaction table for API processing, so filtering the T-Numbers
    INSERT INTO sa.table_x_ild_transaction
										(objid
										,x_min
										,x_esn
										,x_transact_date
										,x_ild_trans_type
										,x_ild_status
										,ild_trans2site_part
										,x_ild_account
										,x_product_id --CR5364
										)
										VALUES
										(sa.seq('x_ild_transaction')
										,p_min
										,site_part_rec.x_service_id
										,SYSDATE
										,ild_trans_type
										,ild_status
										,site_part_rec.objid
										,ild_account
										,ild_product_id --CR5364
										);
END IF;
   ELSE
    CLOSE ild_trans_curs;

    UPDATE table_x_ild_transaction
       SET x_ild_status  = ild_status
          ,x_ild_account = ild_account
          ,x_last_update = SYSDATE
     WHERE objid = ild_trans_rec.objid
          --cwl 4/3/12 CR19853
          -- CR20451 | CR20854: Add TELCEL Brand
          -- and x_product_id not in ('NT_ILD_U','ST_ILD_U');
          --CR21157 Start Kacosta 09/10/2012
          --and x_product_id not in ('NT_ILD_U','ST_ILD_U', 'TC_ILD_U','STH_ILD_U' );
       AND x_product_id NOT IN (select x_ILD_PRODUCT
                                  from sa.TABLE_X_ILD_PRODUCT);  --CR27015
    --CR21157 End Kacosta 09/10/2012
  END IF;

  --CR21157 Start Kacosta 09/11/2012
  --IF p_action = 'ILD_CREATE_OK' THEN
  IF p_action IN ('ILD_CREATE'
                 ,'ILD_CREATE_SENT'
                 ,'ILD_CREATE_OK') THEN
    --CR21157 End Kacosta 09/11/2012
    UPDATE table_x_ota_features
       SET x_ild_carr_status = 'Active'
          ,x_ild_prog_status = 'Completed'
          ,x_ild_account     = p_account
     WHERE x_ota_features2part_inst IN (SELECT objid
                                          FROM table_part_inst
                                         WHERE part_serial_no = site_part_rec.x_service_id);
  END IF;

  IF p_action = 'ILD_CREATE_FAIL' THEN
    UPDATE table_x_ota_features
       SET x_ild_prog_status = 'Completed'
     WHERE x_ota_features2part_inst IN (SELECT objid
                                          FROM table_part_inst
                                         WHERE part_serial_no = site_part_rec.x_service_id);
  END IF;

  IF p_action = 'ILD_DEACT_OK' THEN
    --CR12369
    IF ota_features_rec.x_ild_prog_status = 'Changing' THEN
      UPDATE table_x_ota_features
         SET x_ild_carr_status = 'Inactive'
            ,x_ild_prog_status = 'Completed'
            ,x_ild_account     = NULL
       WHERE x_ota_features2part_inst IN (SELECT objid
                                            FROM table_part_inst
                                           WHERE part_serial_no = site_part_rec.x_service_id);
    ELSE

      UPDATE table_x_ota_features
         SET x_ild_carr_status = 'Inactive'
            ,x_ild_account     = NULL
       WHERE x_ota_features2part_inst IN (SELECT objid
                                            FROM table_part_inst
                                           WHERE part_serial_no = site_part_rec.x_service_id);
    END IF; --CR12369
  END IF;

  COMMIT;
EXCEPTION
  WHEN others THEN
    ROLLBACK;

    IF site_part_curs%ISOPEN THEN
      CLOSE site_part_curs;
    END IF;

    IF ild_trans_curs%ISOPEN THEN
      CLOSE ild_trans_curs;
    END IF;

    IF ota_features_curs%ISOPEN THEN
      CLOSE ota_features_curs;
    END IF;
END;
/