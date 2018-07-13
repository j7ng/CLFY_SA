CREATE OR REPLACE PACKAGE sa."COVERAGE_MAPS_PKG"

AS



PROCEDURE  GET_COVERAGE_MAPS          (
                                       i_zip 			    IN  VARCHAR2,
                                       i_brand   		    IN  VARCHAR2,
                                       i_device_type		IN  VARCHAR2,
                                       i_carrier		    IN  VARCHAR2,
                                       i_min            	IN  VARCHAR2,
                                       i_part_class    		IN  VARCHAR2,
									   i_part_num			IN	VARCHAR2,
                                       o_map_id	         	OUT VARCHAR2,
                                       o_result_code		OUT VARCHAR2,
                                       o_result_msg		   	OUT VARCHAR2
                                       );

PROCEDURE  GETPHONEMODELS     (
                                       i_zip 			    IN   VARCHAR2,
                                       i_brand   		    IN   VARCHAR2,
                                       o_part_class      	OUT  SYS_REFCURSOR,
                                       --o_part_class_desc 	OUT  SYS_REFCURSOR,
                                       o_result_code		OUT  VARCHAR2,
                                       o_result_msg		   	OUT  VARCHAR2
                                      );

  END  COVERAGE_MAPS_PKG;
/