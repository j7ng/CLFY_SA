CREATE OR REPLACE PROCEDURE sa."INBOUND_ILD_CARDS_PRC" as

/******************************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved               	  */
/*                                                                               	  */
/* NAME:         inbound_ild_cards_prc                                          	  */
/* PURPOSE:      This procedure inserts the encrpted ILD pins in the table_x_cc_ild_inv   */
/*		 from the TF_MACAW_INV_INTERFACE				          */
/* FREQUENCY:                                                                    	  */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                	  */
/*                                                                                        */
/* REVISIONS:                                                                    	  */
/* VERSION  DATE         WHO              PURPOSE                                         */
/* -------  ----------  -----  		 ---------------------------------------------    */
/*  1.0     07/25/03    Suganthi Uthaman  Initial  Revision			          */
/*  1.2     08/08/03 	Suganthi Uthaman  CR 1779--Change done to Include Macaw_id 	  */
/******************************************************************************************/

 v_recs_processed NUMBER := 0;
 partnum_objid NUMBER;
 encrpted_pin VARCHAR2(30);
 err_text VARCHAR2(1000);

CURSOR  mc_inv_cur IS
SELECT * FROM
TF_MACAW_INV_INTERFACE;

CURSOR get_domain_objid_cur  IS
SELECT objid
FROM table_prt_domain
WHERE name = 'ILD';

get_domain_objid_rec get_domain_objid_cur%ROWTYPE;

CURSOR part_exists_cur (c_ip_domain2 IN VARCHAR2,  c_ip_part_number IN VARCHAR2) IS
SELECT objid
FROM table_part_num
WHERE part_number = c_ip_part_number
AND part_num2domain = c_ip_domain2;

  part_exists_rec part_exists_cur%ROWTYPE;

CURSOR load_user_objid_cur IS
SELECT objid
FROM table_user
WHERE login_name = 'sa';

  load_user_objid_rec load_user_objid_cur%ROWTYPE;

CURSOR mod_level_cur (pn_objid IN NUMBER) IS
SELECT max(objid) objid
FROM table_mod_level
WHERE part_info2part_num =pn_objid
AND active = 'Active';

 mod_level_rec mod_level_cur%ROWTYPE;

CURSOR ild_inst_cur (PART_SERIAL_NO IN VARCHAR2,PIN_CODE IN VARCHAR2 )
IS
SELECT * FROM TABLE_X_ILD_INST
WHERE
 X_PART_SERIAL_NO = PART_SERIAL_NO
 AND X_RED_CODE = PIN_CODE;

ild_inst_rec ild_inst_cur%ROWTYPE;

 --PRAGMA EXCEPTION_INIT(Partnotfound,  -2049);

 Partnotfound EXCEPTION;


 BEGIN

 FOR mc_inv_rec in mc_inv_cur LOOP

   v_recs_processed := v_recs_processed + 1;

 -- Start : for a new record
 IF  mc_inv_rec.TF_EXTRACT_FLAG = 'NEW' THEN

  OPEN get_domain_objid_cur ;
  FETCH get_domain_objid_cur INTO get_domain_objid_rec;
  CLOSE get_domain_objid_cur;

 -- Checking if the part num exists in TOSS.
  OPEN part_exists_cur (get_domain_objid_rec.objid ,mc_inv_rec.M_PART_NUMBER);
  FETCH part_exists_cur  into part_exists_rec ;


  OPEN mod_level_cur (part_exists_rec.objid);
  FETCH mod_level_cur INTO mod_level_rec;
  CLOSE mod_level_cur;

  OPEN load_user_objid_cur;
  FETCH load_user_objid_cur INTO load_user_objid_rec.objid;
  CLOSE load_user_objid_cur;

 IF part_exists_cur%FOUND THEN

 CLOSE part_exists_cur;

  BEGIN

  -- calls the encrpt function with PIN and part_serial_no as password to get the encrpted value of PIN.
 encrpted_pin := system.encrpt_ild_fun( mc_inv_rec.M_PIN_CODE , mc_inv_rec.M_PART_SERIAL_NO );

 INSERT INTO TABLE_X_CC_ILD_INV
 ( 	OBJID      ,
	X_RESERVED_STMP,
	X_RED_CODE      ,
	X_PART_SERIAL_NO ,
	X_CREATION_DATE   ,
	X_RESERVED_FLAG   ,
	X_RESERVED_ID   ,
	X_DOMAIN        ,
	X_LAST_UPDATE   ,
	CREATED_BY2USER ,
	CC_ILD_INV2MOD_LEVEL,
	CC_ILD_INV2INV_BIN   ,
	LAST_UPDATED2USER   ,
	X_PO_NUM           ,
	X_MACAW_ID
    )
 values
         (
 	SEQ('x_cc_ild_inv')	,
 	NULL				,
 	encrpted_pin		,
 	mc_inv_rec.M_PART_SERIAL_NO	,
 	sysdate ,--mc_inv_rec.M_CREATION_DATE	,
 	0, --NULL
 	NULL			,
 	'ILD'			,
 	sysdate ,
 	load_user_objid_rec.objid       ,
 	mod_level_rec.objid	,
 	NULL ,--X_ILD_INST2INV_BIN	,
 	load_user_objid_rec.objid       ,
 	mc_inv_rec.TF_PO_NUM ,
 	mc_inv_rec.MACAW_ID
 	);

  DELETE FROM   TF_MACAW_INV_INTERFACE
  WHERE OBJID = mc_inv_rec.OBJID ;


  EXCEPTION WHEN OTHERS THEN
    err_text := 'Failure >>'||SUBSTR(SQLERRM,1,100);

  INSERT INTO  X_ILD_ERROR
  (ERROR_TEXT  ,
  ERROR_DATE   ,
  ACTION       ,
  SERIAL_NO    ,
  PROGRAM_NAME )
  VALUES
  (err_text,
   SYSDATE,
   'INSERT TO TABLE_X_CC_ILD_INV' ,
   mc_inv_rec.M_PART_SERIAL_NO ,
   'INBOUND_ILD_CARDS_PRC'
   );

  CLOSE part_exists_cur;

  END;

 ELSE
  BEGIN

   CLOSE part_exists_cur;

   DELETE FROM   TF_MACAW_INV_INTERFACE
   WHERE OBJID = mc_inv_rec.OBJID ;

   Raise Partnotfound;


   EXCEPTION WHEN Partnotfound THEN

   err_text := 'Failure >>'||SUBSTR(SQLERRM,1,100);

   INSERT INTO  X_ILD_ERROR
  (ERROR_TEXT  ,
  ERROR_DATE   ,
  ACTION       ,
  SERIAL_NO    ,
  PROGRAM_NAME )
  VALUES
   (err_text||'Part Number Not Found',
    SYSDATE,
   'INSERT TO TABLE_X_CC_ILD_INV' ,
    mc_inv_rec.M_PART_SERIAL_NO ,
   'INBOUND_ILD_CARDS_PRC'
   );

  END;

 END IF;
END IF;
 --END: for a new record.

-- START : for a invoice record
 IF  mc_inv_rec.TF_EXTRACT_FLAG = 'INVOICE' AND mc_inv_rec.M_INVOICE_ID IS NOT NULL THEN
 BEGIN

 UPDATE TABLE_X_ILD_INST
 SET X_INVOICE_ID =  mc_inv_rec.M_INVOICE_ID ,
     X_INVOICE_DATE = mc_inv_rec.M_INVOICE_DATE
 WHERE
 X_PART_SERIAL_NO = mc_inv_rec.M_PART_SERIAL_NO;
 --X_RED_CODE = mc_inv_rec.M_PIN_CODE;


 OPEN  ild_inst_cur(mc_inv_rec.M_PART_SERIAL_NO,mc_inv_rec.M_PIN_CODE);
 FETCH ild_inst_cur INTO ild_inst_rec;
 CLOSE ild_inst_cur;

 INSERT INTO TABLE_X_ILD_HIST
 (  	OBJID ,
 	X_PART_SERIAL_NO ,
 	X_CREATION_DATE  ,
 	X_PO_NUM         ,
 	X_PART_INST_STATUS,
 	X_CHANGE_DATE    ,
 	X_CHANGE_REASON  ,
 	X_DOMAIN        ,
 	X_PURCHASE_TIME ,
 	X_ORDER_NUMBER  ,
 	X_MACAW_ID    ,
 	X_INVOICE_ID  ,
 	X_INVOICE_DATE,
 	X_RED_CODE    ,
 	ILD_HIST2X_CODE_TABLE,
 	ILD_HIST2INV_BIN,
 	ILD_HIST2MOD_LEVEL,
 	ILD_HIST2ILD_INST ,
 	ILD_HIST2USER ,
 	ILD_HIST2CONTACT    )
 VALUES
 (  seq('x_ild_hist'),
    ild_inst_rec.X_PART_SERIAL_NO,
    ild_inst_rec.X_CREATION_DATE ,
    ild_inst_rec.X_PO_NUM,
    ild_inst_rec.X_PART_INST_STATUS,
    sysdate,
    'UPDATE FROM MACAW',
    ild_inst_rec.X_DOMAIN,
    ild_inst_rec.X_PURCHASE_TIME,
    ild_inst_rec.X_ORDER_NUMBER,
    ild_inst_rec.X_MACAW_ID,
    ild_inst_rec.X_INVOICE_ID,
    ild_inst_rec.X_INVOICE_DATE,
    ild_inst_rec.X_RED_CODE,
    ild_inst_rec.ILD_STATUS2CODE_TABLE,
    ild_inst_rec.ILD_INST2INV_BIN,
    ild_inst_rec.ILD_INST2PART_MOD,
    ild_inst_rec.OBJID,
    load_user_objid_rec.objid,
    ild_inst_rec.ILD_INST2CONTACT
    );


 DELETE FROM   TF_MACAW_INV_INTERFACE
  WHERE OBJID = mc_inv_rec.OBJID ;

 EXCEPTION WHEN OTHERS THEN
 err_text := 'Failure >>'||SUBSTR(SQLERRM,1,100);
    INSERT INTO  X_ILD_ERROR
  (ERROR_TEXT  ,
  ERROR_DATE   ,
  ACTION       ,
  SERIAL_NO    ,
  PROGRAM_NAME )
  VALUES
   (err_text,
    SYSDATE,
   'INSERT TO TABLE_X_LD_INST' ,
    mc_inv_rec.M_PART_SERIAL_NO ,
   'INBOUND_ILD_CARDS_PRC'
   );
 END;
 END IF;
 -- END : for a invoice record

 -- START : for a UPDATE record
 IF  mc_inv_rec.TF_EXTRACT_FLAG = 'UPDATE' THEN
  BEGIN

  OPEN load_user_objid_cur;
  FETCH load_user_objid_cur INTO load_user_objid_rec;
  CLOSE load_user_objid_cur;

  OPEN get_domain_objid_cur ;
  FETCH get_domain_objid_cur INTO get_domain_objid_rec;
  CLOSE get_domain_objid_cur;

  Open part_exists_cur (get_domain_objid_rec.objid ,mc_inv_rec.M_PART_NUMBER);
  fetch part_exists_cur  into part_exists_rec ;
  close part_exists_cur;

  OPEN mod_level_cur (part_exists_rec.objid);
  FETCH mod_level_cur INTO mod_level_rec;
  CLOSE mod_level_cur;

  UPDATE TABLE_X_CC_ILD_INV SET
  CC_ILD_INV2MOD_LEVEL = mod_level_rec.objid,
  LAST_UPDATED2USER    =  load_user_objid_rec.objid,
  X_LAST_UPDATE        = SYSDATE,
  X_PO_NUM             = mc_inv_rec.TF_PO_NUM
  WHERE
  X_PART_SERIAL_NO = mc_inv_rec.M_PART_SERIAL_NO;
  --X_RED_CODE = mc_inv_rec.M_PIN_CODE;



  DELETE FROM   TF_MACAW_INV_INTERFACE
  WHERE OBJID = mc_inv_rec.OBJID ;

  EXCEPTION WHEN OTHERS THEN
  err_text := 'Failure >>'||SUBSTR(SQLERRM,1,100);
    INSERT INTO  X_ILD_ERROR
  (ERROR_TEXT  ,
  ERROR_DATE   ,
  ACTION       ,
  SERIAL_NO    ,
  PROGRAM_NAME )
   VALUES
   (err_text,
    SYSDATE,
   'INSERT TO TABLE_X_CC_ILD_INV' ,
    mc_inv_rec.M_PART_SERIAL_NO ,
   'INBOUND_ILD_CARDS_PRC'
   );

  END;

 END IF;
-- END : for a UPDATE record

END LOOP;

COMMIT;

END inbound_ild_cards_prc;

/