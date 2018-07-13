CREATE OR REPLACE TYPE sa.part_num_det_ty AS OBJECT (ip_airtime_partnum      VARCHAR2(50),
                                                  ip_fulfillment_type     VARCHAR2(20), -- now/later/autorefill
                                                  op_partnum_service_days NUMBER,
                                                  op_service_plan_id      NUMBER,
                                                  op_plan_name            VARCHAR2(200));
/