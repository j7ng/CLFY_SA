CREATE OR REPLACE PROCEDURE sa."GET_ILD_CARD_INFO_PRC"
(p_merchant_id   IN VARCHAR2,
 p_code_objid    IN NUMBER ,
 p_bin_objid     IN NUMBER ,
 p_contact_objid IN NUMBER ,
 p_user_objid IN NUMBER ,
 p_ani1       IN VARCHAR2 DEFAULT NULL ,
 p_ani2       IN VARCHAR2 DEFAULT NULL,
 p_ani3	      IN VARCHAR2 DEFAULT NULL,
 p_ani4       IN VARCHAR2 DEFAULT NULL,
 p_ani5       IN VARCHAR2 DEFAULT NULL ,
 p_ild_pin OUT VARCHAR2,
 p_partserial_no OUT VARCHAR2,
 p_status  OUT VARCHAR2)

as

/******************************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved               	  */
/*                                                                               	  */
/* NAME:         get_ild_card_info_prc                                          	  */
/* PURPOSE:      To retrieve the cards associated with the merchant id                    */
/*		 from table_x_cc_ild_inv						  */
/* FREQUENCY:                                                                    	  */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                	  */
/*                                                                                        */
/* REVISIONS:                                                                    	  */
/* VERSION  DATE        WHO              PURPOSE                                          */
/* -------  ---------- -----  		 ---------------------------------------------    */
/*  1.0     07/25/03   Suganthi Uthaman  Initial  Revision   				  */
/*  1.1     08/08/03   Suganthi Uthaman  CR 1779 --modified to populate the user objid    */
/******************************************************************************************/


        CURSOR all_inv_cur(merchant_id IN VARCHAR2) IS
        SELECT * FROM table_x_cc_ild_inv
        where X_RESERVED_ID = Merchant_id
        AND X_RESERVED_FLAG = 1;

	pin_count NUMBER;
  	n NUMBER :=0;
        ild_inst_objid NUMBER;

 	TYPE ild_pin_rec IS RECORD ( red_code varchar2(30),
 	                             part_serial_no varchar2(30)
                         );

 	TYPE ILD_PIN_T  IS  TABLE OF ILD_pin_rec
  	INDEX BY BINARY_INTEGER;
        ILD_PIN ILD_PIN_T    ;

  BEGIN

  FOR all_inv_rec in all_inv_cur(p_merchant_id) LOOP

  BEGIN

   SELECT SEQ('x_ild_inst') INTO ild_inst_objid FROM DUAL;

   INSERT INTO TABLE_X_ILD_INST
   (
    OBJID ,
    X_PART_SERIAL_NO       ,
    X_CREATION_DATE        ,
    X_PO_NUM               ,
    X_RED_CODE             ,
    X_DOMAIN               ,
    X_PART_INST_STATUS     ,
    X_ORDER_NUMBER         ,
    X_PURCHASE_TIME        ,
    X_LAST_UPDATE          ,
    X_MACAW_ID             ,
    ILD_INST2PART_MOD      ,
    ILD_STATUS2CODE_TABLE  ,
    ILD_INST2INV_BIN       ,
    ILD_INST2CONTACT      ,
    CREATED_BY2USER ,
    LAST_UPDATE_BY2USER ,
    X_TF_ANI1      ,
    X_TF_ANI2      ,
    X_TF_ANI3      ,
    X_TF_ANI4      ,
    X_TF_ANI5
     )
    VALUES
    (
    ild_inst_objid , --SEQ('x_ild_inst'),
    all_inv_rec.X_PART_SERIAL_NO ,
    SYSDATE , --all_inv_rec.X_CREATION_DATE ,
    all_inv_rec.X_PO_NUM ,
    all_inv_rec.X_RED_CODE ,
    all_inv_rec.X_DOMAIN    ,
    '41',
    NULL,
    SYSDATE ,
    SYSDATE,
    NVL(all_inv_rec.X_MACAW_ID,null),
    all_inv_rec.CC_ILD_INV2MOD_LEVEL ,
    p_code_objid ,
    p_bin_objid ,
    p_contact_objid,
    p_user_objid,
    p_user_objid,
    p_ani1,
    p_ani2,
    p_ani3,
    p_ani4,
    p_ani5 );

	INSERT INTO TABLE_X_ILD_HIST
	( OBJID         ,
	X_PART_SERIAL_NO ,
	X_CREATION_DATE   ,
	X_PO_NUM          ,
	X_PART_INST_STATUS,
	X_CHANGE_DATE    ,
	X_CHANGE_REASON  ,
	X_DOMAIN        ,
	X_PURCHASE_TIME ,
	X_MACAW_ID     ,
	X_RED_CODE     ,
	ILD_HIST2X_CODE_TABLE  ,
	ILD_HIST2INV_BIN ,
	ILD_HIST2MOD_LEVEL,
	ILD_HIST2ILD_INST ,
	ILD_HIST2USER ,
	ILD_HIST2CONTACT
	)
	VALUES
	(
	 SEQ('x_ild_hist'),
	 all_inv_rec.X_PART_SERIAL_NO ,
    	 SYSDATE ,--all_inv_rec.X_CREATION_DATE ,
         all_inv_rec.X_PO_NUM ,
         '41',
         sysdate ,
         'ILD PURCHASE',
         'ILD',
         sysdate,
         NVL(all_inv_rec.X_MACAW_ID,null),
         all_inv_rec.X_RED_CODE ,
         p_code_objid ,
         p_bin_objid ,
         all_inv_rec.CC_ILD_INV2MOD_LEVEL ,
         ild_inst_objid,
         p_user_objid,
         p_contact_objid
         );



 	ILD_PIN(n).red_code:= system.decrpt_ild_fun(all_inv_rec.x_red_code , all_inv_rec.x_part_serial_no);
 	ILD_PIN(n).part_serial_no := all_inv_rec.x_part_serial_no;
	n := n+1;



    DELETE FROM TABLE_X_CC_ILD_INV WHERE
    OBJID = all_inv_rec.OBJID;

    EXCEPTION WHEN OTHERS THEN
    P_STATUS := 'F';
    ROLLBACK;
    RETURN;
    END;

  END LOOP;

  pin_count := n ;
  p_ild_pin := '';
  p_partserial_no:='';

  for j in  0..pin_count-1 LOOP

  p_ild_pin := ILD_PIN(j).red_code||'^'||p_ild_pin;
  p_ild_pin := TRIM(p_ild_pin);

  p_partserial_no := ILD_PIN(j).part_serial_no||'^'||p_partserial_no;
  p_partserial_no := TRIM(p_partserial_no);

  --dbms_output.put_line('p_ild_pin is :'||p_ild_pin);

  END LOOP;

 COMMIT;
 P_STATUS := 'S';

EXCEPTION WHEN OTHERS THEN
    P_STATUS := 'F';
    ROLLBACK;
    RETURN;

END  get_ild_card_info_prc;

/