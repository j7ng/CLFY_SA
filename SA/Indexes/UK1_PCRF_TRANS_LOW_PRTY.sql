CREATE UNIQUE INDEX sa.uk1_pcrf_trans_low_prty ON sa.x_pcrf_trans_low_prty("MIN",esn,order_type,pcrf_status_code,insert_timestamp);