CREATE OR REPLACE FUNCTION sa."IG_BUCKET_FUNC" (
    p ig_bucket_pkg.refcur_t)
  RETURN ig_bucket_tab pipelined
IS
  row_cnt NUMBER    := 0;
  out_rec ig_bucket := ig_bucket(NULL,NULL,NULL,NULL,NULL,NULL,NULL ,NULL,NULL,NULL,NULL,NULL,NULL ,NULL,NULL,NULL,NULL,NULL,NULL ,NULL,NULL,NULL,NULL,NULL,NULL ,NULL,NULL,NULL,NULL,NULL,NULL ,NULL,NULL,NULL,NULL,NULL,NULL ,NULL,NULL,NULL,NULL,NULL,NULL ,NULL,NULL,NULL,NULL,NULL,NULL ,NULL,NULL,NULL,NULL,NULL,NULL ,NULL,NULL,NULL,NULL,NULL,NULL, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL,NULL,NULL,NULL);
  in_rec p%ROWTYPE;
BEGIN
  LOOP
    FETCH p INTO in_rec;
    EXIT
  WHEN p%NOTFOUND;
    row_cnt                            := row_cnt + 1;
    IF row_cnt                          = 1 THEN
      out_rec.bucket_0_id              := in_rec.bucket_id;
      out_rec.bucket_0_balance         := in_rec.bucket_balance;
      out_rec.bucket_0_value           := in_rec.bucket_value;
      out_rec.bucket_0_expiration_date := in_rec.expiration_date;
      out_rec.bucket_0_recharge_date   := in_rec.recharge_date;
      out_rec.bucket_0_direction       := in_rec.direction;
      out_rec.bucket_0_benefit_type    := in_rec.benefit_type;
      out_rec.bucket_0_bucket_type     := in_rec.bucket_type;
    elsif row_cnt                       =2 THEN
      out_rec.bucket_1_id              := in_rec.bucket_id;
      out_rec.bucket_1_balance         := in_rec.bucket_balance;
      out_rec.bucket_1_value           := in_rec.bucket_value;
      out_rec.bucket_1_expiration_date := in_rec.expiration_date;
      out_rec.bucket_1_recharge_date   := in_rec.recharge_date;
      out_rec.bucket_1_direction       := in_rec.direction;
      out_rec.bucket_1_benefit_type    := in_rec.benefit_type;
      out_rec.bucket_1_bucket_type     := in_rec.bucket_type;
    elsif row_cnt                       =3 THEN
      out_rec.bucket_2_id              := in_rec.bucket_id;
      out_rec.bucket_2_balance         := in_rec.bucket_balance;
      out_rec.bucket_2_value           := in_rec.bucket_value;
      out_rec.bucket_2_expiration_date := in_rec.expiration_date;
      out_rec.bucket_2_recharge_date   := in_rec.recharge_date;
      out_rec.bucket_2_direction       := in_rec.direction;
      out_rec.bucket_2_benefit_type    := in_rec.benefit_type;
      out_rec.bucket_2_bucket_type     := in_rec.bucket_type;
    elsif row_cnt                       =4 THEN
      out_rec.bucket_3_id              := in_rec.bucket_id;
      out_rec.bucket_3_balance         := in_rec.bucket_balance;
      out_rec.bucket_3_value           := in_rec.bucket_value;
      out_rec.bucket_3_expiration_date := in_rec.expiration_date;
      out_rec.bucket_3_recharge_date   := in_rec.recharge_date;
      out_rec.bucket_3_direction       := in_rec.direction;
      out_rec.bucket_3_benefit_type    := in_rec.benefit_type;
      out_rec.bucket_3_bucket_type     := in_rec.bucket_type;
    elsif row_cnt                       =5 THEN
      out_rec.bucket_4_id              := in_rec.bucket_id;
      out_rec.bucket_4_balance         := in_rec.bucket_balance;
      out_rec.bucket_4_value           := in_rec.bucket_value;
      out_rec.bucket_4_expiration_date := in_rec.expiration_date;
      out_rec.bucket_4_recharge_date   := in_rec.recharge_date;
      out_rec.bucket_4_direction       := in_rec.direction;
      out_rec.bucket_4_benefit_type    := in_rec.benefit_type;
      out_rec.bucket_4_bucket_type     := in_rec.bucket_type;
    elsif row_cnt                       =6 THEN
      out_rec.bucket_5_id              := in_rec.bucket_id;
      out_rec.bucket_5_balance         := in_rec.bucket_balance;
      out_rec.bucket_5_value           := in_rec.bucket_value;
      out_rec.bucket_5_expiration_date := in_rec.expiration_date;
      out_rec.bucket_5_recharge_date   := in_rec.recharge_date;
      out_rec.bucket_5_direction       := in_rec.direction;
      out_rec.bucket_5_benefit_type    := in_rec.benefit_type;
      out_rec.bucket_5_bucket_type     := in_rec.bucket_type;
    elsif row_cnt                       =7 THEN
      out_rec.bucket_6_id              := in_rec.bucket_id;
      out_rec.bucket_6_balance         := in_rec.bucket_balance;
      out_rec.bucket_6_value           := in_rec.bucket_value;
      out_rec.bucket_6_expiration_date := in_rec.expiration_date;
      out_rec.bucket_6_recharge_date   := in_rec.recharge_date;
      out_rec.bucket_6_direction       := in_rec.direction;
      out_rec.bucket_6_benefit_type    := in_rec.benefit_type;
      out_rec.bucket_6_bucket_type     := in_rec.bucket_type;
    elsif row_cnt                       =8 THEN
      out_rec.bucket_7_id              := in_rec.bucket_id;
      out_rec.bucket_7_balance         := in_rec.bucket_balance;
      out_rec.bucket_7_value           := in_rec.bucket_value;
      out_rec.bucket_7_expiration_date := in_rec.expiration_date;
      out_rec.bucket_7_recharge_date   := in_rec.recharge_date;
      out_rec.bucket_7_direction       := in_rec.direction;
      out_rec.bucket_7_benefit_type    := in_rec.benefit_type;
      out_rec.bucket_7_bucket_type     := in_rec.bucket_type;
    elsif row_cnt                       =9 THEN
      out_rec.bucket_8_id              := in_rec.bucket_id;
      out_rec.bucket_8_balance         := in_rec.bucket_balance;
      out_rec.bucket_8_value           := in_rec.bucket_value;
      out_rec.bucket_8_expiration_date := in_rec.expiration_date;
      out_rec.bucket_8_recharge_date   := in_rec.recharge_date;
      out_rec.bucket_8_direction       := in_rec.direction;
      out_rec.bucket_8_benefit_type    := in_rec.benefit_type;
      out_rec.bucket_8_bucket_type     := in_rec.bucket_type;
    elsif row_cnt                       =10 THEN
      out_rec.bucket_9_id              := in_rec.bucket_id;
      out_rec.bucket_9_balance         := in_rec.bucket_balance;
      out_rec.bucket_9_value           := in_rec.bucket_value;
      out_rec.bucket_9_expiration_date := in_rec.expiration_date;
      out_rec.bucket_9_recharge_date   := in_rec.recharge_date;
      out_rec.bucket_9_direction       := in_rec.direction;
      out_rec.bucket_9_benefit_type    := in_rec.benefit_type;
      out_rec.bucket_9_bucket_type     := in_rec.bucket_type;
    END IF;
  END LOOP;
  out_rec.REQUEST_BUCKET_COUNT := row_cnt;
  PIPE ROW(out_rec);
  CLOSE p;
  RETURN;
END;
/