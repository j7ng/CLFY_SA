CREATE OR REPLACE PACKAGE BODY sa."LOW_BALANCE_OFFER_PKG"
IS

/********************************************************************************/
/* Copyright (r) 2009 Tracfone Wireless Inc. All rights reserved                */
/*                                                                              */
/* Name         :   LOW_BALANCE_OFFER_PKG                                       */
/* Purpose      :   Validates and Logs Low Balance Offers and Presentations     */
/* Parameters   :                                                               */
/* Platforms    :   Oracle 8.0.6 AND newer versions                             */
/* Author       :   Ingrid Canavan                                              */
/* Date         :   08/13/2009                                                  */
/* Revisions    :                                                               */
/*                                                                              */
/* Version  Date        Who     Purpose                                         */
/* -------  --------    ------- --------------------------------------          */
/*  1.0	    08/13/09  ICanavan 	New package                                                         */
/*  1.1     04/09/10  ICanavan	PROCEDURE PRESENTED_OFFER add output trans id                       */
/*                              PROCEDURE GET_LB_QUAL_OFFER change output message to the handset    */
/*  1.2     04/27/10  ICanavan  modified to remove older X_QUAL_ESNS and use FIRMWARE               */
/*                                                                                                  */
--#$Workfile: $
--$Revision: 1.5 $
--$Author: icanavan $
--$Modtime:  $
--$ $Log: SA.LOW_BALANCE_OFFER_PKB.sql,v $
--$ Revision 1.5  2010/04/30 20:10:37  icanavan
--$ added an order by clause to the media validation
--$
--$ Revision 1.4  2010/04/29 17:15:33  icanavan
--$ Remove error code 205
--$
--$ Revision 1.3  2010/04/27 19:37:32  icanavan
--$ ADDED FIRMWARE
--$
--$ Revision 1.2  2010/04/12 13:55:53  icanavan
--$ replace with changes from 4/9 after restore from backup
--$
--$ Revision 1.1  2010/03/30 18:07:17  skuthadi
--$ Pkg Body Validate ESNs,Offers,Media
--$
/********************************************************************************/

PROCEDURE GET_LB_QUAL_OFFER
    (P_ESN           IN  VARCHAR2,
     P_MSG_STR       OUT VARCHAR2,
     P_MSG_NUM       OUT VARCHAR2,
     P_MEDIA_CONTENT OUT VARCHAR2,  -- P_QUAL_OFFER
     P_MEDIA_OBJID   OUT NUMBER,
     P_OFFER_OBJID   OUT NUMBER)

     IS
      P_X_TYPE        VARCHAR2(20) ;
      V_X_ESN         VARCHAR2(30) ;
      V_X_QUAL_OFFER  VARCHAR2(30) ;
      V_X_INSERT_DATE DATE ;

      --------------- MAIN CURSOR --------------
      CURSOR FIND_OFFER (P_ESN IN VARCHAR2, P_X_TYPE IN VARCHAR2) IS
      SELECT
        x_media_code, x_type, x_channel, x_media_content, x_version,
        med.x_start_date med_x_start_date,
        med.x_end_date med_x_end_date,
        off.x_start_date off_x_start_date,
        off.x_end_date off_x_end_date,
        x_offer, x_offer_desc, med.objid med_objid, off.objid off_objid
       FROM X_LB_MEDIA_LIBRARY MED, X_LB_OFFER OFF, MTM_X_MEDIA2X_OFFER MTM, X_LB_QUAL_ESNS ESN
      WHERE mtm.x_media2x_offer = off.objid
      AND mtm.x_offer2x_media = med.objid
      AND esn.x_qual_offer = off.x_offer
      AND (SYSDATE BETWEEN med.x_start_date AND med.x_end_date)
      AND (SYSDATE BETWEEN off.x_start_date AND off.x_end_date)
      AND esn.x_esn = p_esn
      AND med.x_type = p_x_type
      order by med.x_end_date desc;

      r_FIND_OFFER FIND_OFFER%ROWTYPE;

      CURSOR FIND_FIRMWARE (P_ESN IN VARCHAR2) IS
      SELECT distinct pcv.x_param_value
      FROM  table_part_num pn, table_part_class pc, table_x_part_class_params pcp,
      table_x_part_class_values pcv, table_part_inst pi, table_mod_level ml
      WHERE 1=1
      AND pcp.x_param_name = 'FIRMWARE' AND pc.objid = pcv.value2part_class
      AND pcp.objid = pcv.value2class_param AND pc.objid = pn.part_num2part_class
      AND pn.domain = 'PHONES' AND pn.part_num2part_class= pc.objid
      AND ml.part_info2part_num=pn.objid AND pi.n_part_inst2part_mod=ml.objid
      AND pi.part_serial_no = p_esn ;

      r_FIND_FIRMWARE FIND_FIRMWARE%ROWTYPE;

      CURSOR VALIDATE_FIRMWARE (P_ESN IN VARCHAR2) IS
      SELECT
        med.x_type
      FROM X_LB_MEDIA_LIBRARY MED,
           X_LB_OFFER OFF,
           MTM_X_MEDIA2X_OFFER MTM,
           X_LB_QUAL_ESNS ESN
      WHERE mtm.x_media2x_offer= off.objid
      AND mtm.x_offer2x_media= med.objid
      AND esn.x_qual_offer = off.x_offer
      AND (SYSDATE BETWEEN med.x_start_date AND med.x_end_date)
      AND (SYSDATE BETWEEN off.x_start_date AND off.x_end_date)
      AND esn.x_esn = p_esn
      AND med.x_type = p_x_type ;

      r_VALIDATE_FIRMWARE VALIDATE_FIRMWARE%ROWTYPE;

      CURSOR VALIDATE_OFFER_DATES (P_ESN IN VARCHAR2) IS
      SELECT * FROM x_lb_qual_esns esn, x_lb_offer off
      WHERE esn.x_qual_offer= off.x_offer
      AND off.x_start_date <= SYSDATE AND off.x_end_date >= SYSDATE
      AND esn.x_esn = p_esn ;

      r_VALIDATE_OFFER_DATES VALIDATE_OFFER_DATES%ROWTYPE;

      CURSOR VALIDATE_MEDIA_DATES (P_ESN IN VARCHAR2) IS
      SELECT MED.X_START_DATE, MED.X_END_DATE
      FROM x_lb_qual_esns esn, x_lb_offer off, x_lb_media_library med, mtm_x_media2x_offer mtm
      WHERE esn.x_qual_offer= off.x_offer
      AND mtm.x_media2x_offer= off.objid
      AND mtm.x_offer2x_media= med.objid
      AND med.x_start_date <= SYSDATE AND med.x_end_date >= SYSDATE
      AND esn.x_esn = p_esn ;

      r_VALIDATE_MEDIA_DATES VALIDATE_MEDIA_DATES%ROWTYPE;

      CURSOR VALIDATE_ESN (P_ESN IN VARCHAR2) IS
      SELECT * FROM x_lb_qual_esns esn
      WHERE esn.x_esn = p_esn ;

      r_VALIDATE_ESN VALIDATE_ESN%ROWTYPE;

  BEGIN
     BEGIN
       SELECT x_esn,x_qual_offer,x_insert_date
         INTO V_X_ESN, V_X_QUAL_OFFER,V_X_INSERT_DATE
         FROM x_lb_qual_esns
        WHERE x_esn= P_ESN
          AND x_insert_date IN
             (SELECT MAX(x_insert_date)
                FROM x_lb_qual_esns
               WHERE x_esn= P_ESN ) ;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
       DBMS_OUTPUT.put_line('ESN NOT FOUND IN X_LB_QUAL_ESNS');
       RETURN ;
     END;

     if V_X_ESN is not null
     then
       -- added this to maintain table size
       delete from x_lb_qual_esns  where X_ESN = V_X_ESN and X_INSERT_DATE < V_X_INSERT_DATE ;
       commit ;
     end if ;

     DBMS_OUTPUT.put_line('step 0 VALIDATE_ESN');
     OPEN VALIDATE_ESN (P_ESN) ;
     FETCH VALIDATE_ESN INTO R_VALIDATE_ESN ;
     IF VALIDATE_ESN%NOTFOUND THEN
           p_msg_num := '200';
           p_msg_str := sa.Get_Code_Fun('LOW_BALANCE_OFFER_PKG',p_msg_num,'ENGLISH') ;
           P_MEDIA_CONTENT := 'NOT VALID' ;  -- P_QUAL_OFFER :='NOT VALID' ;
           DBMS_OUTPUT.put_line('STEP 0 FAILURE ' ||p_msg_num || p_msg_str);
           CLOSE VALIDATE_ESN ;
           RETURN ;
     END IF ;
     CLOSE VALIDATE_ESN ;

     DBMS_OUTPUT.put_line('step 1 CHECK OFFER DATES');
      OPEN VALIDATE_OFFER_DATES (P_ESN) ;
      FETCH VALIDATE_OFFER_DATES INTO R_VALIDATE_OFFER_DATES ;

         IF VALIDATE_OFFER_DATES%NOTFOUND THEN
            P_MSG_num := '201';
            p_msg_str := sa.Get_Code_Fun('LOW_BALANCE_OFFER_PKG',p_msg_num,'ENGLISH') ;
            P_MEDIA_CONTENT := 'NOT VALID' ;  --P_QUAL_OFFER :='NOT VALID' ;
            DBMS_OUTPUT.put_line('STEP 1 FAILURE ' ||p_msg_num || p_msg_str);
            CLOSE VALIDATE_OFFER_DATES ;
            RETURN;
         END IF;
      CLOSE VALIDATE_OFFER_DATES ;

     DBMS_OUTPUT.put_line('step 2 CHECK MEDIA DATES');
      OPEN VALIDATE_MEDIA_DATES (P_ESN) ;
      FETCH VALIDATE_MEDIA_DATES INTO R_VALIDATE_MEDIA_DATES ;
           IF VALIDATE_MEDIA_DATES%NOTFOUND THEN
            P_MSG_num := '202';
            p_msg_str := sa.Get_Code_Fun('LOW_BALANCE_OFFER_PKG',p_msg_num,'ENGLISH') ;
            P_MEDIA_CONTENT := 'NOT VALID' ;  --  P_QUAL_OFFER :='NOT VALID' ;
            DBMS_OUTPUT.put_line('STEP 2 FAILURE ' ||p_msg_num || p_msg_str);
            CLOSE VALIDATE_MEDIA_DATES ;
            RETURN;
         END IF;
      CLOSE VALIDATE_MEDIA_DATES ;

     DBMS_OUTPUT.put_line('step 3 FIND FIRMWARE');
      OPEN FIND_FIRMWARE (P_ESN) ;
      FETCH FIND_FIRMWARE INTO R_FIND_FIRMWARE ;
       IF FIND_FIRMWARE%NOTFOUND THEN
           p_x_type := 'N' ;  -- Not found so we default to 2.0
        END IF;
      CLOSE FIND_FIRMWARE ;
        IF R_FIND_FIRMWARE.x_param_value='2.0' THEN
           P_X_TYPE :='N' ;
        ELSE
          P_X_TYPE :='D' ;
        END IF;

     DBMS_OUTPUT.put_line('step 4 CHECK OFFER AND FIRMWARE');
      OPEN VALIDATE_FIRMWARE (P_ESN) ;
      FETCH VALIDATE_FIRMWARE INTO R_VALIDATE_FIRMWARE ;
        IF VALIDATE_FIRMWARE%NOTFOUND OR r_VALIDATE_FIRMWARE.x_type <> p_x_type THEN
          P_msg_num := '203';
          p_msg_str := sa.Get_Code_Fun('LOW_BALANCE_OFFER_PKG',p_msg_num,'ENGLISH') ;
          P_MEDIA_CONTENT := 'NOT VALID' ;  --P_QUAL_OFFER :='NOT VALID' ;
          DBMS_OUTPUT.put_line('STEP 4 FAILURE ' ||p_msg_num || p_msg_str);
          CLOSE VALIDATE_FIRMWARE ;
          RETURN ;
        END IF ;
      CLOSE VALIDATE_FIRMWARE ;

     DBMS_OUTPUT.put_line('step 5 FIND FINAL OFFER');
      OPEN FIND_OFFER (P_ESN, P_X_TYPE) ;
      FETCH FIND_OFFER INTO R_FIND_OFFER ;
        IF FIND_OFFER%NOTFOUND THEN
          P_MSG_num := '204';
          p_msg_str := sa.Get_Code_Fun('LOW_BALANCE_OFFER_PKG',p_msg_num,'ENGLISH') ;
          P_MEDIA_CONTENT := 'NOT VALID' ;  --P_QUAL_OFFER :='NOT VALID';
          DBMS_OUTPUT.put_line('STEP 5 FAILURE ' ||p_msg_num || p_msg_str);
          CLOSE FIND_OFFER;
          RETURN;
        END IF;
      CLOSE FIND_OFFER;
        IF (p_msg_num IS NULL) THEN
            p_msg_num := '0';
        END IF;
        IF (p_msg_str IS NULL) THEN
            p_msg_str := 'Success';
        END IF ;

        IF P_MEDIA_CONTENT IS NULL THEN
            P_MEDIA_CONTENT := r_FIND_OFFER.x_media_content ;
        END IF ;
        IF P_MEDIA_OBJID IS NULL THEN
          P_MEDIA_OBJID :=r_FIND_OFFER.med_objid ;
        END IF ;
        IF P_OFFER_OBJID IS NULL THEN
          P_OFFER_OBJID :=r_FIND_OFFER.off_objid ;
        END IF ;

  END GET_LB_QUAL_OFFER ;

 PROCEDURE PRESENTED_OFFER
    (ip_ESN            IN VARCHAR2,
     ip_QUAL_OFFER     IN VARCHAR2,
     ip_X_PRES_CHANNEL IN VARCHAR2,
     ip_MEDIA_OBJID    IN NUMBER,
     ip_OFFER_OBJID    IN NUMBER,
     ip_X_PRES_STATUS  IN VARCHAR2,
     ip_CLFY_CODE      IN VARCHAR2,
     ip_CLFY_MESSAGE   IN VARCHAR2,
     op_X_TRANS_ID     OUT VARCHAR2)

   IS

      V_ID VARCHAR2(200) ;
      STMT VARCHAR2(1000) ;

  BEGIN
    ---
    STMT := 'SELECT ''S''||TO_CHAR(SA.SEQU_LB_TRANS_ID.NEXTVAL) FROM DUAL '; --INTO V_ID' ;
    EXECUTE IMMEDIATE STMT into v_id;
    DBMS_OUTPUT.PUT_LINE('V_ID='||V_ID) ;
    ---
    DBMS_OUTPUT.put_line('INSERTING THE PRESENTED OFFERS INTO X_LB_PRESENTED_OFFER') ;

    INSERT INTO X_LB_PRESENTED_OFFER
      (X_ESN,X_PRES_OFFER,X_PRES_MEDIA,X_PRES_STATUS,X_PRES_CHANNEL,X_PRES_DATE,X_PRES_TRANS_ID,CLFY_CODE,CLFY_MESSAGE)
     VALUES
        (ip_esn,ip_offer_objid,ip_media_objid,ip_x_pres_status,ip_x_pres_channel,SYSDATE,v_id,ip_CLFY_CODE,ip_CLFY_MESSAGE) ;
         --  decode(ip_x_pres_channel,'SMS','S'||(to_char(SEQU_LB_TRANS_ID.NEXTVAL)),'S'||(to_char(SEQU_LB_TRANS_ID.NEXTVAL)))) ;
         DBMS_OUTPUT.put_line('INSERTING FINISHED') ;
         op_X_TRANS_ID := v_id ;
       COMMIT;

  END PRESENTED_OFFER ;

END LOW_BALANCE_OFFER_PKG;
/