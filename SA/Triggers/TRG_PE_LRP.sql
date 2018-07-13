CREATE OR REPLACE TRIGGER sa."TRG_PE_LRP" AFTER
   INSERT OR UPDATE
    ON sa.x_program_enrolled REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
DECLARE
  --
  out_err_code       NUMBER;
  out_err_msg        VARCHAR2(2000);
  l_action_type      VARCHAR2(20);
  l_brand            VARCHAR2(100);
  l_min              VARCHAR2(100);

--
BEGIN

 -- Go Smart changes
 -- Do not fire trigger if global variable is turned off
  if not sa.globals_pkg.g_run_my_trigger then
    return;
  end if;
-- End Go Smart changes
  --
  IF  :NEW.x_esn     IS NOT NULL
  AND ((:NEW.x_enrollment_status   IN ('ENROLLED')                       AND    :NEW.x_next_charge_date   IS NOT NULL)
      OR (:NEW.x_enrollment_status   IN ('DEENROLLED','READYTOREENROLL') ))
  THEN
    BEGIN
    SELECT  bo.name
    INTO l_brand
    FROM x_program_parameters pp,
         table_bus_org bo
    WHERE bo.objid                  = pp.prog_param2bus_org
    AND   pp.objid                  = :NEW.pgm_enroll2pgm_parameter
    AND   pp.x_prog_class           = 'SWITCHBASE';
    EXCEPTION
    WHEN OTHERS THEN
      l_brand :=  '';
    END;
    --
    BEGIN
    SELECT tsp.x_min
    INTO   l_min
    from   table_site_part tsp
    where  tsp.x_service_id =  :NEW.x_esn
    and    tsp.part_status = 'Active';
    EXCEPTION
    WHEN OTHERS THEN
      l_min :=  '';
    END;
    --
    IF  l_brand                  = ('STRAIGHT_TALK')
    AND :NEW.x_enrollment_status IN ('ENROLLED')
    THEN
      sa.REWARDS_MGT_UTIL_PKG.p_enroll_cust_in_program( in_brand           =>  l_brand,
                                                        in_web_account_id  => :NEW.pgm_enroll2web_user ,
                                                        x_subscriber_id    => NULL ,
                                                        x_min              => l_min ,
                                                        x_esn              => :NEW.x_esn ,
                                                        in_program_name    => 'LOYALTY_PROGRAM' ,
                                                        in_benefit_type    => 'LOYALTY_POINTS' ,
                                                        in_enrollment_type => 'AUTO_REFILL' ,
                                                        in_enroll_channel  =>  null,  -- CR41665 added
                                                        in_enroll_min      =>  null,      -- CR41665 added
                                                        out_err_code       => out_err_code ,
                                                        out_err_msg        => out_err_msg);
      --
    ELSIF l_brand                  = 'STRAIGHT_TALK'
    AND :NEW.x_enrollment_status IN ('DEENROLLED','READYTOREENROLL')
    THEN
      --
      sa.REWARDS_MGT_UTIL_PKG.p_deenroll_esn_from_program( in_brand           => l_brand,
                                                           in_web_account_id  => :NEW.pgm_enroll2web_user ,
                                                           x_subscriber_id    => NULL ,
                                                           x_min              => l_min ,
                                                           x_esn              => :NEW.x_esn ,
                                                           in_program_name    => 'LOYALTY_PROGRAM' ,
                                                           in_benefit_type    => 'LOYALTY_POINTS' ,
                                                           in_enrollment_type => 'AUTO_REFILL' ,
                                                           out_err_code       => out_err_code ,
                                                           out_err_msg        => out_err_msg);
      --
    END IF;
  --
  END IF;
  --
END;
/