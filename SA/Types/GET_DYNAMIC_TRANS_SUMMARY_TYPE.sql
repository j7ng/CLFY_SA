CREATE OR REPLACE TYPE sa.get_dynamic_trans_summary_type  AS OBJECT
					(source_system               	VARCHAR2(10),
					 brand                       	VARCHAR2(20),
					 language                    	VARCHAR2(10),
					 esn                         	VARCHAR2(30),
					 transaction_type            	VARCHAR2(20),
					 retention_type              	VARCHAR2(30),
					 program_id                  	NUMBER,
					 acc_num_name_reg_name       	VARCHAR2(50),
					 acc_num_name_10_dollar_name 	VARCHAR2(50),
					 reactivation_flag           	VARCHAR2(100),
					 service_days						NUMBER,
					 confirmation_message        	VARCHAR2(2000),
					 transaction_script          	VARCHAR2(2000),
					 serv_end_date               	DATE,
					 next_refill_date            	DATE,
					 acc_num_name_reg            	VARCHAR2(2000),
					 acc_num_name_10_dollar      	VARCHAR2(2000),
					 cards_in_reserve            	NUMBER,
					 more_info                   	VARCHAR2(2000),
					 device_name                 	VARCHAR2(30),
					 group_id                    	NUMBER,
					 group_name                  	VARCHAR2(50),
					 err_code							VARCHAR2(100),
					 err_msg								VARCHAR2(4000),
					-- Constructor used to initialize the entire type
					constructor function get_dynamic_trans_summary_type  return self as result
					);
/
CREATE OR REPLACE TYPE BODY sa."GET_DYNAMIC_TRANS_SUMMARY_TYPE" is
CONSTRUCTOR FUNCTION get_dynamic_trans_summary_type  RETURN SELF AS RESULT IS
BEGIN
	RETURN;
END;
END;
/