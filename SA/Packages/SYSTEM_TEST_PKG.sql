CREATE OR REPLACE PACKAGE sa.System_Test_Pkg
AS
  	   PROCEDURE  clear_data_esn(ip_esn IN VARCHAR2, op_result OUT VARCHAR2, op_msg OUT VARCHAR2);
	   PROCEDURE  clear_data_esn_list(ip_esn_list IN VARCHAR2, op_result OUT VARCHAR2, op_msg OUT VARCHAR2);
END System_Test_Pkg;
/