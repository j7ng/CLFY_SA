CREATE OR REPLACE PROCEDURE sa."P_GET_SERVICE_REWARD_INFO"
(
in_brand                 IN VARCHAR2,
in_source_system         IN VARCHAR2,
in_reward_program_name    IN VARCHAR2,
in_serivce_plan_objid    IN NUMBER DEFAULT NULL,
out_sp_record            OUT REWARD_SERVICE_INFO_TBL,
out_err_code             out NUMBER,
out_err_msg              out VARCHAR2
) AS

input_validation_failed   EXCEPTION;
service_info REWARD_SERVICE_INFO_TBL;
V_OBJID sa.X_Reward_Benefit_Program.OBJID%type;


CURSOR cur_fetch_svc_null(V_OBJID NUMBER ) IS
SELECT
      OBJID ,
      SERVICE_PLAN_OBJID,
      REWARD_PROGRAM_OBJID,
      REWARD_POINT,
      START_DATE,
      END_DATE,
      BRAND,
      SOURCE_SYSTEM,
      LAST_UPDATED_DATE

FROM mtm_sp_reward_program mtm1
WHERE  mtm1.brand = in_brand
AND   mtm1.source_system =in_source_system
AND  mtm1.reward_program_objid =V_OBJID
AND sysdate between mtm1.start_date and mtm1.end_date
AND mtm1.last_updated_date =(SELECT MAX(mtm2.last_updated_date)
                             FROM  mtm_sp_reward_program mtm2
                             WHERE mtm1.service_plan_objid   = mtm2.service_plan_objid
   			  	             AND   mtm1.reward_program_objid = mtm2.reward_program_objid
				             and sysdate between mtm2.start_date and mtm2.end_date );

CURSOR cur_fetch_svc_NN(V_OBJID NUMBER) IS
SELECT
      OBJID ,
      SERVICE_PLAN_OBJID,
      REWARD_PROGRAM_OBJID,
      REWARD_POINT,
      START_DATE,
      END_DATE,
      BRAND,
      SOURCE_SYSTEM,
      LAST_UPDATED_DATE
FROM mtm_sp_reward_program mtm1

WHERE  mtm1.brand = in_brand
AND   mtm1.source_system =in_source_system
AND  mtm1.reward_program_objid =V_OBJID
AND mtm1.service_plan_objid =in_serivce_plan_objid
AND sysdate between mtm1.start_date and mtm1.end_date
AND mtm1.last_updated_date =(SELECT MAX(mtm2.last_updated_date)
                              FROM  mtm_sp_reward_program mtm2
                              WHERE mtm1.service_plan_objid = mtm2.service_plan_objid
				              AND   mtm1.reward_program_objid = mtm2.reward_program_objid
				              and sysdate between mtm2.start_date and mtm2.end_date );
BEGIN

 out_err_code                         := 0;
 out_err_msg                          := 'SUCCESS';

  begin
  select OBJID INTO V_OBJID
  from sa.X_Reward_Benefit_Program
  where PROGRAM_NAME = in_reward_program_name;

  EXCEPTION
  WHEN others THEN
        out_err_code      := -100;
        out_err_msg       :='Error_code: '||out_err_code||' Error_msg: '||sqlerrm ||' - '||dbms_utility.format_error_backtrace;
  end;




IF in_brand IS NULL or in_source_system IS NULL or V_OBJID IS NULL
THEN
out_err_code :=-100;
out_err_msg :='Mandatory Input Brand/Source System/Reward program Id is not passed';
Raise input_validation_failed;

END IF;

service_info := REWARD_SERVICE_INFO_TBL();
IF in_serivce_plan_objid IS NULL THEN

FOR R1 in cur_fetch_svc_null(v_objid) LOOP
service_info.EXTEND(1);
service_info(service_info.COUNT) :=REWARD_SERVICE_INFO_OBJ( R1.OBJID   ,
                                                            R1.SERVICE_PLAN_OBJID  ,
                                                            R1.REWARD_PROGRAM_OBJID,
                                                            R1.REWARD_POINT   ,
                                                            R1.START_DATE      ,
                                                            R1.END_DATE         ,
                                                            R1.BRAND             ,
                                                            R1.SOURCE_SYSTEM      ,
                                                            R1.LAST_UPDATED_DATE   );
END LOOP;

out_sp_record := service_info;

ELSE
service_info := REWARD_SERVICE_INFO_TBL();
 FOR R2 in cur_fetch_svc_NN(v_objid) LOOP
service_info.EXTEND(1);
service_info(service_info.COUNT) :=REWARD_SERVICE_INFO_OBJ(R2.OBJID   ,
                                                            R2.SERVICE_PLAN_OBJID  ,
                                                            R2.REWARD_PROGRAM_OBJID,
                                                            R2.REWARD_POINT   ,
                                                            R2.START_DATE      ,
                                                            R2.END_DATE         ,
                                                            R2.BRAND             ,
                                                            R2.SOURCE_SYSTEM      ,
                                                            R2.LAST_UPDATED_DATE   );
END LOOP;

out_sp_record := service_info;
END IF;

EXCEPTION
WHEN input_validation_failed THEN
 out_err_msg:='Error_code: '||out_err_code||' Error_msg: '||out_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;

    ota_util_pkg.err_log (p_action      => 'CALLING P_GET_SERVICE_REWARD_INFO',
                         p_error_date     => SYSDATE,
                         p_key            => V_OBJID,
                         p_program_name   => 'P_GET_SERVICE_REWARD_INFO',
                         p_error_text     => out_err_msg);
    WHEN others THEN
      out_err_code      := -99;
      out_err_msg       :='Error_code: '||out_err_code||' Error_msg: '||sqlerrm ||' - '||dbms_utility.format_error_backtrace;


   ota_util_pkg.err_log (p_action      => 'CALLING p_get_service_reward_info',
                         p_error_date     => SYSDATE,
                         p_key            => V_OBJID,
                         p_program_name   => 'p_get_service_reward_info',
                         p_error_text     => out_err_msg);

END p_get_service_reward_info;
/