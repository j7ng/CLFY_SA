CREATE OR REPLACE PACKAGE BODY sa."LTE_SERVICE_PKG" AS
FUNCTION IS_LTE_4G_SIM_REM(P_ESN IN VARCHAR2) RETURN NUMBER AS
-- return 0 if ESN is LTE Spring CDMA with SIM removable CR22799
-- return 1 if ESN is not LTE Spring CDMA with SIM removable CR22799
-- return 2 other errors
CURSOR LTE_4G_CUR IS
 select pn.PART_NUMBER
from table_part_class pc, table_bus_org bo, table_part_num pn, pc_params_view vw, table_part_inst pi, table_mod_level ml
where pn.part_num2bus_org=bo.objid
and pn.pArt_num2part_class=pc.objid
AND PC.NAME=VW.PART_CLASS
AND VW.PARAM_NAME = 'CDMA LTE SIM' --'DLL' --YM 07/13/2013
AND VW.PARAM_VALUE = 'REMOVABLE' --'-8' --YM 07/13/2013
AND PI.N_PART_INST2PART_MOD=ML.OBJID
AND ML.PART_INFO2PART_NUM=PN.OBJID
And pi.part_serial_no = p_esn ;
LTE_4G_REC LTE_4G_CUR%ROWTYPE ;
op_msg varchar2(400);
BEGIN
 OPEN LTE_4G_cur ;
 FETCH LTE_4G_CUR
 INTO LTE_4G_rec;
 IF LTE_4G_cur%FOUND THEN
 CLOSE LTE_4G_CUR;
 RETURN 0;
 END IF;
 CLOSE LTE_4G_CUR;
 RETURN 1;
EXCEPTION
 WHEN OTHERS THEN
 OP_MSG := TO_CHAR(SQLCODE)||SQLERRM;
 sa.ota_util_pkg.err_log(p_action => 'when others'
 ,p_error_date => SYSDATE
 ,P_KEY => P_ESN
 ,P_PROGRAM_NAME => 'SA.LTE_SERVICE_PKG.IS_LTE_4G_SIM_REM'
 ,P_ERROR_TEXT => OP_MSG);
 RETURN 2;
END IS_LTE_4G_SIM_REM;


FUNCTION IS_ESN_LTE_CDMA(P_ESN IN VARCHAR2) RETURN NUMBER AS
-- return 1 if ESN is LTE Spring CDMA with SIM removable CR22799
-- return 0 if ESN is not LTE Spring CDMA with SIM removable CR22799
-- return 2 other errors
CURSOR LTE_4G_CUR IS
 select pn.PART_NUMBER
from   table_part_class pc, table_bus_org bo, table_part_num pn, pc_params_view vw, table_part_inst pi, table_mod_level ml
where pn.part_num2bus_org=bo.objid
and   pn.pArt_num2part_class=pc.objid
AND   PC.NAME=VW.PART_CLASS
AND   VW.PARAM_NAME  = 'CDMA LTE SIM' --'DLL'   --YM 07/13/2013
AND   VW.PARAM_VALUE = 'REMOVABLE' --'-8'    --YM 07/13/2013
AND PI.N_PART_INST2PART_MOD=ML.OBJID
AND ML.PART_INFO2PART_NUM=PN.OBJID
And pi.part_serial_no = p_esn ;
LTE_4G_REC LTE_4G_CUR%ROWTYPE ;
op_msg varchar2(400);
BEGIN
    OPEN LTE_4G_cur ;
    FETCH LTE_4G_CUR
    INTO LTE_4G_rec;
    IF LTE_4G_cur%FOUND THEN
      CLOSE LTE_4G_CUR;
      RETURN 1;
    END IF;
     CLOSE LTE_4G_CUR;
     RETURN 0;
EXCEPTION
    WHEN OTHERS THEN
      OP_MSG  := TO_CHAR(SQLCODE)||SQLERRM;
      sa.ota_util_pkg.err_log(p_action       => 'when others'
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  P_ESN
                          ,P_PROGRAM_NAME => 'LTE_SERVICE_PKG.IS_LTE_4G_SIM_REM'
                          ,P_ERROR_TEXT   => OP_MSG);
      RETURN 2;
END IS_ESN_LTE_CDMA;


FUNCTION PN_SIM_LTE_4G(P_DLL IN VARCHAR2, p_carrier_id in varchar2 ) RETURN VARCHAR2 AS
-- return part num SIM into CARRIER if ESN is LTE Spring CDMA with SIM removable CR22799
-- return null if ESN is not LTE Spring CDMA with SIM removable CR22799
-- return 1 other errors
CURSOR LTE_4G_CUR IS
--CR 46355 - modified below SQL to consider shippable flag and Rank
SELECT a.sim_profile,sa.is_shippable(a.sim_profile) shippable, a.rank
FROM  (
  select /*+ ORDERED */  DISTINCT s.sim_profile,s.rank
  from  npanxx2carrierzones b,
        carrierzones a,
        carriersimpref s ,
        CARRIERPREF CP
where  to_number(b.carrier_id) = P_CARRIER_ID --122795
   AND b.ZONE = a.ZONE
   AND b.state = a.st
   AND A.CARRIER_NAME=S.CARRIER_NAME
   and P_DLL between s.MIN_DLL_EXCH and s.MAX_DLL_EXCH
   and cp.county = a.county
   AND cp.st = b.state
   AND CP.CARRIER_ID = B.CARRIER_ID
   --and rownum < 2
    ) a
ORDER BY sa.is_shippable(a.sim_profile) DESC, a.rank;

LTE_4G_REC LTE_4G_CUR%ROWTYPE ;
op_msg varchar2(400);
BEGIN
    OPEN LTE_4G_cur ;
    FETCH LTE_4G_CUR
    INTO LTE_4G_rec;
    IF LTE_4G_cur%FOUND THEN
      CLOSE LTE_4G_CUR;
      RETURN LTE_4G_REC.sim_profile;
    END IF;
     CLOSE LTE_4G_CUR;
     RETURN null;
EXCEPTION
    WHEN OTHERS THEN
      OP_MSG  := TO_CHAR(SQLCODE)||SQLERRM;
      sa.ota_util_pkg.err_log(p_action       => 'when others'
                          ,P_ERROR_DATE   => SYSDATE
                          ,P_KEY          =>  P_dll
                          ,P_PROGRAM_NAME => 'LTE_SERVICE_PKG.DLL_LTE_4G'
                          ,P_ERROR_TEXT   => OP_MSG);
      RETURN '1';
END PN_SIM_LTE_4G;

FUNCTION DLL_LTE_4G(P_ESN IN VARCHAR2) RETURN varchar2 AS
-- return ddl if ESN is LTE Spring CDMA with SIM removable CR22799
-- return null if ESN is not LTE Spring CDMA with SIM removable CR22799
-- return 1 other errors
CURSOR LTE_4G_CUR IS
select  VW.param_value  dll
from   table_part_class pc, table_bus_org bo, table_part_num pn, pc_params_view vw, table_part_inst pi, table_mod_level ml
where pn.part_num2bus_org=bo.objid
and   pn.pArt_num2part_class=pc.objid
AND   PC.NAME=VW.PART_CLASS
AND   VW.PARAM_NAME='DLL'
and pi.n_part_inst2part_mod=ml.objid
AND ML.PART_INFO2PART_NUM=PN.OBJID
And pi.part_serial_no = p_esn ;
LTE_4G_REC LTE_4G_CUR%ROWTYPE ;
op_msg varchar2(400);
BEGIN
    OPEN LTE_4G_cur ;
    FETCH LTE_4G_CUR
    INTO LTE_4G_rec;
    IF LTE_4G_cur%FOUND THEN
      CLOSE LTE_4G_CUR;
      RETURN LTE_4G_REC.dll;
    END IF;
     CLOSE LTE_4G_CUR;
     RETURN null;
EXCEPTION
    WHEN OTHERS THEN
      OP_MSG  := TO_CHAR(SQLCODE)||SQLERRM;
      sa.ota_util_pkg.err_log(p_action       => 'when others'
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  P_ESN
                          ,P_PROGRAM_NAME => 'LTE_SERVICE_PKG.DLL_LTE_4G'
                          ,P_ERROR_TEXT   => OP_MSG);
      RETURN '1';
END DLL_LTE_4G;

FUNCTION IS_LTE_4G_INACTIVE(P_ESN IN VARCHAR2) RETURN NUMBER AS
-- 3.VERIFY ESN IS INACTIVE
-- return 0 if ESN 'PHONE IS NOT ACTIVE/INACTIVE';
-- return 1 if ESN 'PHONE IS ACTIVE';
-- return 2 other errors
CURSOR LTE_4G_CUR IS
    SELECT *
    FROM TABLE_PART_INST
    WHERE X_PART_INST_STATUS = '52'
    AND PART_SERIAL_NO = P_ESN
    and x_domain = 'PHONES';
LTE_4G_REC LTE_4G_CUR%ROWTYPE ;
op_msg varchar2(400);
BEGIN
    OPEN LTE_4G_cur ;
    FETCH LTE_4G_CUR
    INTO LTE_4G_REC;
    IF LTE_4G_CUR%NOTFOUND THEN
      CLOSE LTE_4G_CUR;  --'PHONE IS NOT ACTIVE';
      RETURN 0;
    END IF;
     CLOSE LTE_4G_CUR; ---'PHONE IS ACTIVE';
     RETURN 1;
EXCEPTION
    WHEN OTHERS THEN
      OP_MSG  := TO_CHAR(SQLCODE)||SQLERRM;
      sa.ota_util_pkg.err_log(p_action       => 'when others'
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  P_ESN
                          ,P_PROGRAM_NAME => 'LTE_SERVICE_PKG.IS_LTE_4G_SIM_REM'
                          ,P_ERROR_TEXT   => OP_MSG);
      RETURN 2;
END IS_LTE_4G_INACTIVE;

PROCEDURE IS_LTE_COMPATIBLE (P_X_ICCID IN VARCHAR2, P_ESN IN VARCHAR2, P_ERROR_CODE OUT NUMBER) AS
-- P_ERROR_CODE 0 if X_ICCID and P_ESN are for LTE 4G SIM Removable Compatible
-- P_ERROR_CODE 1  not found part class for ESN
-- P_ERROR_CODE 2 -- not found PN SIM
-- P_ERROR_CODE 3 not compatible SIM and ESN
-- P_ERROR_CODE 4 others

CURSOR LTEPN_SIM_CUR IS
SELECT  SI.X_SIM_SERIAL_NO, SI.X_SIM_INV_STATUS, pn.part_number  ---- part number for SIM LTE     'TF128LSIMS8M'
  FROM  TABLE_X_SIM_INV SI, TABLE_MOD_LEVEL ML,
        table_part_num pn
 WHERE  SI.X_SIM_INV2PART_MOD = ML.OBJID
 AND    ML.PART_INFO2PART_NUM = PN.OBJID
 AND    SI.X_SIM_SERIAL_NO = P_X_ICCID;
LTEPN_SIM_REC LTEPN_SIM_CUR%ROWTYPE ;

CURSOR LTEPC_ESN_CUR IS
  SELECT PN.PART_NUMBER, PC.NAME PART_CLASS   ---- part class for ESN  LTE
  FROM table_part_inst pi, table_mod_level ml, table_part_num pn, table_part_class pc
 WHERE  pi.n_part_inst2part_mod = ml.objid
   AND ML.PART_INFO2PART_NUM = PN.OBJID
   and pc.objid = pn.part_num2part_class
   AND PART_SERIAL_NO = P_ESN;
LTEPC_ESN_REC LTEPC_ESN_CUR %ROWTYPE ;

CURSOR is_compatible_cur ( P_PN_SIM varchar2, P_PC_PHONE varchar2 ) is
  select carrier_name x_parent_name
  FROM CARRIERSIMPREF S
 where  s.sim_profile = P_PN_SIM  --like 'TF128PSIMS8M'
intersect
(
select p.x_parent_name
   from table_x_parent p
   where upper(p.x_status) = 'ACTIVE'
minus
SELECT p.x_parent_name
  FROM table_x_not_certify_models cm,
       table_part_class pc,
       table_x_parent p
WHERE 1 = 1
   AND p.x_parent_id = cm.X_PARENT_ID
   AND CM.X_PART_CLASS_OBJID = PC.OBJID
   AND PC.NAME = P_PC_PHONE  --'STLGL25L'
);
IS_COMPATIBLE_REC IS_COMPATIBLE_CUR %ROWTYPE ;

op_msg varchar2(400);
BEGIN
    P_ERROR_CODE := 0;
    OPEN LTEPN_SIM_CUR;
    FETCH LTEPN_SIM_CUR
    INTO LTEPN_SIM_REC;
    IF LTEPN_SIM_CUR%FOUND THEN

      OPEN LTEPC_ESN_CUR ;
      FETCH LTEPC_ESN_CUR
      INTO LTEPC_ESN_REC;
      IF LTEPC_ESN_CUR%FOUND THEN

       OPEN is_compatible_cur(LTEPN_SIM_REC.part_number , LTEPC_ESN_REC.part_class) ;
       FETCH IS_COMPATIBLE_CUR
       INTO IS_COMPATIBLE_REC;
       IF IS_COMPATIBLE_CUR%NOTFOUND THEN
          P_ERROR_CODE := 3;
          sa.ota_util_pkg.err_log(p_action       => 'Not found compatibility between ESN and SIM '
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  P_ESN
                          ,P_PROGRAM_NAME => 'LTE_SERVICE_PKG.IS_LTE_COMPATIBLE'
                          ,P_ERROR_TEXT   => OP_MSG);
       END IF;
       close IS_COMPATIBLE_CUR;
      ELSE
       P_ERROR_CODE := 1;
       OP_MSG  := TO_CHAR(SQLCODE)||SQLERRM;
       sa.ota_util_pkg.err_log(p_action       => 'Not found part class for ESN '
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  P_ESN
                          ,P_PROGRAM_NAME => 'LTE_SERVICE_PKG.IS_LTE_COMPATIBLE'
                          ,p_error_text   => op_msg);

      END IF ;
      close LTEPC_ESN_CUR;
    ELSE
       P_ERROR_CODE := 2;
       sa.ota_util_pkg.err_log(p_action       => 'Not found part number SIM '
                          ,P_ERROR_DATE   => SYSDATE
                          ,P_KEY          =>  P_X_ICCID
                          ,P_PROGRAM_NAME => 'LTE_SERVICE_PKG.IS_LTE_COMPATIBLE'
                          ,P_ERROR_TEXT   => OP_MSG);
    END IF;
     close LTEPN_SIM_CUR;
EXCEPTION
    WHEN OTHERS THEN
      P_ERROR_CODE := 4;
      OP_MSG  := TO_CHAR(SQLCODE)||SQLERRM;
      sa.ota_util_pkg.err_log(p_action       => 'when others'
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  P_ESN
                          ,P_PROGRAM_NAME => 'LTE_SERVICE_PKG.IS_LTE_COMPATIBLE'
                          ,P_ERROR_TEXT   => OP_MSG);
END IS_LTE_COMPATIBLE;

PROCEDURE IS_LTE_MARRIAGE (P_ESN         IN VARCHAR2,
                         P_SIM_STATUS OUT VARCHAR2,
                         P_X_ICCID    OUT VARCHAR2,
                         P_ESN_STATUS OUT VARCHAR2,
                         P_ERROR_CODE OUT NUMBER) AS
/* return 0 ESN is Married
/* return 1 ESN is not married
/* return 2 other errors */
CURSOR LTE_marriage_cur
IS
SELECT SIM.X_SIM_INV_STATUS  SIM_STATUS,
       SIM.X_SIM_SERIAL_NO   X_iCCID,
       PI.X_PART_INST_STATUS ESN_STATUS
  FROM   TABLE_PART_INST PI, TABLE_X_SIM_INV SIM
 WHERE  PI.X_ICCID = SIM.X_SIM_SERIAL_NO
   AND  PI.PART_SERIAL_NO = P_ESN ;
LTE_MARRiAGE_REC LTE_MARRiAGE_CUR%ROWTYPE ;

op_msg varchar2(400);
BEGIN
      P_SIM_STATUS  := NULL;
      P_X_ICCID     :=  0;
      P_ESN_STATUS  := NULL;
      OP_MSG := NULL;

    OPEN  LTE_MARRIAGE_CUR ;
    FETCH LTE_MARRIAGE_CUR
    INTO  LTE_marriage_rec;
    IF LTE_MARRIAGE_CUR%FOUND THEN
      P_SIM_STATUS  :=  LTE_MARRIAGE_REC.SIM_STATUS;
      P_X_ICCID     :=  LTE_MARRIAGE_REC.X_ICCID;
      P_ESN_STATUS  :=  LTE_MARRIAGE_REC.ESN_STATUS;
      P_ERROR_CODE  :=  0;
    ELSE
      P_ERROR_CODE  :=  1;
    END IF;
    CLOSE LTE_MARRiAGE_CUR;
EXCEPTION
    WHEN OTHERS THEN
      op_msg  := to_char(SQLCODE)||SQLERRM;
      sa.ota_util_pkg.err_log(p_action       => 'OTHERS errors'
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  P_ESN
                          ,P_PROGRAM_NAME => 'LTE_SERVICE_PKG.IS_LTE_MARRAGE'
                          ,P_ERROR_TEXT   => OP_MSG);
       P_ERROR_CODE :=2;
END IS_LTE_MARRiAGE;


PROCEDURE LTE_MARRiAGE(P_ESN        IN VARCHAR2,
                       P_X_ICCID    IN VARCHAR2,
                       P_ERROR_CODE OUT NUMBER) AS
/*  P_ERROR_CODE = 0 succesfull married ESN and SIM */
/*  P_ERROR_CODE = 1 ESN is not in table_SITE_PART  */
/*  P_ERROR_CODE = 2 when others   */
/*CURSOR ESN_ACT_cur
IS
SELECT   SP.PART_STATUS
  FROM   TABLE_SITE_PART SP
 WHERE  SP.X_SERVICE_ID  = P_ESN;
ESN_ACT_rec ESN_ACT_cur%ROWTYPE ;   */

CURSOR ESN_ACT_cur
IS
SELECT   Pi.X_PART_INST_STATUS   -- NEG 07/08/2013 PART_STATUS REPLACED BY X_PART_INST_STATUS
  FROM   TABLE_PART_INST PI
 WHERE  pi.part_serial_no = P_ESN;
ESN_ACT_rec ESN_ACT_cur%ROWTYPE ;


OP_MSG varchar2(400);
BEGIN

    P_ERROR_CODE  :=  0;
    op_msg := null;
    OPEN  ESN_ACT_cur ;
    FETCH ESN_ACT_CUR
    INTO  ESN_ACT_rec;

    IF ESN_ACT_CUR%FOUND THEN
     --IF  ESN_ACT_REC.PART_STATUS = 'Active' THEN   -- REMOVED NEG 07/08/2013
     IF ESN_ACT_REC.X_PART_INST_STATUS = '52' THEN   -- ADDED NEG 07/08/2013
           UPDATE TABLE_X_SIM_INV
           SET X_SIM_INV_STATUS = '254'
           where X_SIM_SERIAL_NO =  P_X_ICCID;
     ELSE
           UPDATE TABLE_X_SIM_INV
           SET X_SIM_INV_STATUS = '253'
           where X_SIM_SERIAL_NO = P_X_ICCID; --p_esn;
     END IF;

           UPDATE TABLE_PART_INST
           SET X_ICCID = P_X_ICCID
           where PART_SERIAL_NO = p_esn;
    ELSE
        P_ERROR_CODE :=1;
        OP_MSG  := TO_CHAR(SQLCODE)||SQLERRM;
        sa.ota_util_pkg.err_log(p_action       => 'ESN_ACT_CUR not found Error code: 1'
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  P_ESN
                          ,P_PROGRAM_NAME => 'LTE_SERVICE_PKG.LTE_MARRiAGE'
                          ,P_ERROR_TEXT   => OP_MSG);

    END IF;
    CLOSE ESN_ACT_cur;
EXCEPTION
    WHEN OTHERS THEN
        OP_MSG  := TO_CHAR(SQLCODE)||SQLERRM;
        P_ERROR_CODE :=2;
        sa.ota_util_pkg.err_log(p_action       => 'OTHERS errors Error code 2'
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  P_ESN
                          ,P_PROGRAM_NAME => 'LTE_SERVICE_PKG.LTE_MARRiAGE'
                          ,p_error_text   => op_msg);

END LTE_MARRiAGE;

FUNCTION IS_LTE_SINGLE (P_X_ICCID IN VARCHAR2) RETURN NUMBER AS
-- return 0 if it is X_ICCID is not married with any ESN SINGLE
-- return 1 if is married
-- return 2 when other errors
CURSOR LTE_SIM_CUR IS
SELECT  pi.part_status
  FROM  TABLE_PART_INST pi
 WHERE  pi.x_iccid=  P_X_ICCID;
LTE_SIM_REC LTE_SIM_CUR%ROWTYPE ;

BEGIN
    OPEN LTE_SIM_CUR;
    FETCH LTE_SIM_CUR
      INTO LTE_SIM_REC;
    IF LTE_SIM_CUR%notFOUND THEN
      CLOSE LTE_SIM_CUR;
      RETURN 0;
    END IF;
    CLOSE LTE_SIM_CUR;
    RETURN 1;
EXCEPTION
    WHEN OTHERS THEN
      RETURN 2;
END IS_LTE_SINGLE;

END LTE_SERVICE_PKG;
/