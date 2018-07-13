CREATE OR REPLACE PROCEDURE sa."IVR_UPURCH_WRAPPER" (io_esn               IN OUT  VARCHAR2,
                                               io_min               IN OUT  VARCHAR2,
                                               o_phone_technology   OUT     VARCHAR2,
                                               o_esn_brand          OUT     VARCHAR2,
                                               o_promptid           OUT     VARCHAR2, --leave this
                                               o_esn_status         OUT     VARCHAR2,
                                               o_esn_sub_status     OUT     VARCHAR2,
                                               o_num_of_ccards      OUT     NUMBER,   -- Not there
                                               o_part_class         OUT     VARCHAR2,
                                               o_enrl_autref_flag   OUT     VARCHAR2,
                                               o_my_acc_login       OUT     VARCHAR2, --If NULL Create a My Account Id
                                               o_flash_id           OUT     VARCHAR2,
                                               o_dev_type           OUT     VARCHAR2,
                                               o_esn_eligible       OUT     VARCHAR2,
                                               o_valid_result       OUT     VARCHAR2,
                                               o_esn_issue          OUT     VARCHAR2,
                                               o_is_promo_eligible  OUT     VARCHAR2,
                                               o_errnum             OUT     VARCHAR2,
                                               o_errstr             OUT     VARCHAR2)
IS
--
  l_esn_plan_grp                VARCHAR2(200);
  l_web_user_objid              VARCHAR2(200);
  l_part_number                 VARCHAR2(200);  -- phone part num
  l_num_pin_queued              NUMBER;
  l_last_redm_plan_part_num     VARCHAR2(200);
  l_last_redm_plan_pc           VARCHAR2(200);
  l_enrl_dbl_min_promo_flag     VARCHAR2(200);
  l_enrl_trpl_min_promo_flag    VARCHAR2(200);
  l_enrl_hpp_flag               VARCHAR2(200);
  l_is_hpp_eligible             VARCHAR2(200);
  l_enrl_hpp_price              NUMBER(12,2);
  l_enrl_ild_flag               VARCHAR2(200);
  l_sim_number                  VARCHAR2(200);
  l_zipcode                     VARCHAR2(200);
  l_flash_txt                   VARCHAR2(5000);
  l_service_end_date            VARCHAR2(200);
  l_forecast_end_date           VARCHAR2(200);
  l_base_plan                   VARCHAR2(300);
  l_curr_splanid                NUMBER;
  l_splan_type                  VARCHAR2(200);
  l_curr_splan_name             VARCHAR2(200);
  l_enrl_objid                  NUMBER;
  l_is_safelink                 VARCHAR2(200);
  l_contact_objid               VARCHAR2(200);
--
BEGIN
  --
  phone_pkg.Getesnattributes( io_esn                      =>	io_esn,
                              io_min                      =>	io_min,
                              o_esn_brand                 =>	o_esn_brand,
                              o_esn_status                =>	o_esn_status,
                              o_esn_sub_status            =>	o_esn_sub_status,
                              o_esn_plan_grp              =>	l_esn_plan_grp,
                              o_my_acc_login              =>	o_my_acc_login,
                              o_web_user_objid            =>	l_web_user_objid,
                              o_part_class                =>	o_part_class,
                              o_part_num                  =>	l_part_number,
                              o_num_pin_queued            =>	l_num_pin_queued,
                              o_last_redm_plan_part_num   =>	l_last_redm_plan_part_num,
                              o_last_redm_plan_pc         =>	l_last_redm_plan_pc,
                              o_enrl_autref_flag          =>	o_enrl_autref_flag,
                              o_enrl_objid                =>	l_enrl_objid,
                              o_enrl_dbl_min_promo_flag   =>	l_enrl_dbl_min_promo_flag,
                              o_enrl_trpl_min_promo_flag  =>	l_enrl_trpl_min_promo_flag,
                              o_enrl_hpp_flag             =>	l_enrl_hpp_flag,
                              o_is_hpp_eligible           =>	l_is_hpp_eligible,
                              o_enrl_hpp_price            =>	l_enrl_hpp_price,
                              o_enrl_ild_flag             =>	l_enrl_ild_flag,
                              o_phone_technology          =>	o_phone_technology,
                              o_sim_number                =>	l_sim_number,
                              o_zipcode                   =>	l_zipcode,
                              o_dev_type                  =>	o_dev_type,
                              o_flash_id                  =>	o_flash_id,
                              o_flash_txt                 =>	l_flash_txt,
                              o_service_end_date          =>	l_service_end_date,
                              o_forecast_end_date         =>  l_forecast_end_date,
                              o_base_plan                 =>	l_base_plan ,
                              o_curr_splanid              =>	l_curr_splanid,
                              o_splan_type                =>	l_splan_type,
                              o_curr_splan_name           =>	l_curr_splan_name,
                              o_is_promo_eligible         =>	o_is_promo_eligible,
                              o_is_safelink               =>  l_is_safelink,
                              o_contact_objid             =>  l_contact_objid,
                              o_errnum                    =>	o_errnum,
                              o_errstr                    =>  o_errstr);
  --
  phone_pkg.get_esn_eligible  (i_esn              =>	io_esn,
                               i_min              =>	io_min,
                               o_esn_eligible     =>	o_esn_eligible,
                               o_valid_result     =>	o_valid_result,
                               o_esn_issue        =>	o_esn_issue,
                               o_errnum           =>	o_errnum,
                               o_errstr           =>	o_errstr);

  --Return as NOT ELIGIBLE if ESN is enrolled in any Safelink program.
  IF NVL(l_is_safelink,'N') = 'Y' THEN
     o_esn_eligible := '0'; --NOT_ELIGIBLE
  END IF;
  --
  --Retrieve number of credit cards associated for given ESN.
       SELECT COUNT(cc.x_customer_cc_number)
       INTO   o_num_of_ccards
       FROM   table_x_credit_card cc,
              x_payment_source    ps
       WHERE  x_card_status              = 'ACTIVE'
       AND    cc.objid                   = ps.pymt_src2x_credit_card
       AND    ps.pymt_src2web_user       = l_web_user_objid;

EXCEPTION
  WHEN OTHERS THEN
    o_errnum  :=  99;
    o_errstr  :=  'Error in when others of ivr_purch_wrapper' || SUBSTR(SQLERRM,1,100);
END ivr_upurch_wrapper;
/