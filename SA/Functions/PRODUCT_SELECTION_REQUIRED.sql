CREATE OR REPLACE FUNCTION sa.PRODUCT_SELECTION_REQUIRED (
   P_ESN                 IN VARCHAR2,
   P_NEW_SERV_PLAN_OBJID IN NUMBER)
   RETURN NUMBER --(0=No, 1=Yes)
IS
/***********************************************************************************************/
/* Copyright (r) 2011 Tracfone Wireless Inc. All rights reserved                               */
/*                                                                                             */
/* Name         :   PRODUCT_SELECTION_REQUIRED                                                            */
/* Purpose      :   Determines is product selection is required                                */
/* Parameters   :                                                                              */
/* Platforms    :   Oracle 8.0.6 AND newer versions                                            */
/* Author       :   Natalio Guada                                                              */
/* Date         :   02/03/2011                                                                 */
/* Revisions    :                                                                              */
/*                                                                                             */
/* Rev      Date        Who         Purpose                                                    */
/* -------  ----------- ----------  ---------------------------------------------              */
/* 1.1      02/03/2011  NGuada      Initial                                                    */
/* 1.2      02/07/2011  NGuada      Initial                                                    */
/***********************************************************************************************/

cursor cur_new_plan is --New Plan Product Selection Parameter.
SELECT spfvdef2.value_name PROPERTY_VALUE , spfvdef2.display_name PROPERTY_DISPLAY
FROM
  X_SERVICEPLANFEATUREVALUE_DEF spfvdef,
  X_SERVICEPLANFEATURE_VALUE spfv,
  X_SERVICE_PLAN_FEATURE spf,
  X_SERVICEPLANFEATUREVALUE_DEF spfvdef2,
  X_SERVICE_PLAN SP
WHERE sp.objid = P_NEW_SERV_PLAN_OBJID
  AND spf.sp_feature2service_plan = sp.objid
  AND spf.sp_feature2rest_value_def = spfvdef.objid
  AND spf.objid = spfv.spf_value2spf
  AND SPFVDEF2.OBJID = SPFV.VALUE_REF
  and spfvdef.value_name = 'PRODUCT_SELECTION';

REC_NEW_PLAN cur_new_plan%rowtype;

--Second PROD_TF replace with  PROD_NT for NET
cursor cur_old_plan is -- Old Plan Product Selection Parameter
select decode(x_code_type,'PROD_TF','0','PROD_NT','1','PROD_ST_UL','2','PROD_ST_MT','4','NA') PROPERTY_VALUE

from table_x_code_hist ch,
     table_x_call_trans ct
where ct.objid = ch.code_hist2call_trans
and x_service_id= p_esn
and x_code_type like 'PROD_%'
and x_code_accepted ='YES'
order by x_gen_code desc;

REC_OLD_PLAN CUR_OLD_PLAN%ROWTYPE;
PRO_SEL_REQ number:=0;
BEGIN

  OPEN CUR_NEW_PLAN;
  FETCH CUR_NEW_PLAN INTO REC_NEW_PLAN;
  IF CUR_NEW_PLAN%FOUND THEN
     OPEN CUR_OLD_PLAN;
     FETCH CUR_OLD_PLAN INTO REC_OLD_PLAN;
     IF CUR_OLD_PLAN%FOUND THEN
        IF REC_OLD_PLAN.PROPERTY_VALUE <> REC_NEW_PLAN.PROPERTY_VALUE THEN
           PRO_SEL_REQ:=1;
        end if;
     else
       PRO_SEL_REQ:=1;
     END IF;
     close cur_old_plan;
  else
     PRO_SEL_REQ:=1;
  END IF;
  CLOSE CUR_NEW_PLAN;
  RETURN PRO_SEL_REQ;
END;
/