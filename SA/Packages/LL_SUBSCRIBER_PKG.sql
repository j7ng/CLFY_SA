CREATE OR REPLACE PACKAGE sa.ll_subscriber_pkg
IS
 /*******************************************************************************************************
 --$RCSfile: LL_SUBSCRIBER_PKG.sql,v $
 --$ $Log: LL_SUBSCRIBER_PKG.sql,v $
 --$ Revision 1.11  2017/11/10 16:19:22  sgangineni
 --$ CR54704 - Added function IS_LIFELINE_ENROLLED
 --$
 --$ Revision 1.10  2017/07/14 01:08:03  sgangineni
 --$ CR49915 - Added new param deenroll_reason to the deenroll_ll_subscriber
 --$
 --$ Revision 1.9  2017/07/11 19:14:53  sgangineni
 --$ CR49915 - Added new procedure PROCESS_ENROLLMENTS
 --$
 --$ Revision 1.8  2017/07/07 22:57:25  mdave
 --$ CR49915 - Merged with latest version
 --$
 --$ Revision 1.6  2017/07/06 18:43:33  mdave
 --$ CR49915 ll_minc_transaction changes
 --$
 --$ Revision 1.5  2017/06/30 21:20:01  sgangineni
 --$ CR49915 - Added new procedure PROCESS_LL_TRANSFER
 --$
 --$
 * Description: This package includes the below procedures
 * get_ll_subscriber_details
 *
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/
 PROCEDURE GET_LL_SUBSCRIBER_DETAILS ( i_min                           IN    VARCHAR2,
                                       i_esn                           IN    VARCHAR2,
                                       o_esn                           OUT   VARCHAR2,
                                       o_min                           OUT   VARCHAR2,
                                       o_is_eligible_for_enrollment    OUT   VARCHAR2,
                                       o_service_plan_id               OUT   NUMBER,
                                       o_service_plan_description      OUT   VARCHAR2,
                                       o_ll_service_type               OUT   VARCHAR2,
                                       o_tribal_ll_service_type        OUT   VARCHAR2,
                                       o_app_part_number               OUT   VARCHAR2,
                                       o_app_part_class                OUT   VARCHAR2,
                                       o_error_num                     OUT   VARCHAR2,
                                       o_error_msg                     OUT   VARCHAR2
                                     );

  PROCEDURE ENROLL_LL_SUBSCRIBER ( ll_subscriber_rec       IN OUT  sa.ll_subscriber_type,
                                   o_ll_sub_id             OUT     NUMBER,
                                   o_esn_part_inst_objid   OUT     NUMBER,
                                   o_app_part_number       OUT     VARCHAR2,
                                   o_app_part_class        OUT     VARCHAR2,
                                   o_Error_Num             OUT     VARCHAR2,
                                   o_Error_Msg             OUT     VARCHAR2
                                 );

  PROCEDURE DEENROLL_LL_SUBSCRIBER ( i_min                 IN      VARCHAR2,
                                     i_esn                 IN      VARCHAR2,
                                     i_source_system       IN      VARCHAR2 DEFAULT 'VMBC',
                                     i_deenroll_reason     IN      VARCHAR2 DEFAULT NULL,
                                     o_Error_Num           OUT     VARCHAR2,
                                     o_Error_Msg           OUT     VARCHAR2
                                   );

  PROCEDURE CALCULATE_LL_DISCOUNT ( i_min                      IN    VARCHAR2,
                                    i_service_plan_id          IN    NUMBER,
                                    i_app_part_number          IN    VARCHAR2,
                                    i_app_part_class           IN    VARCHAR2,
                                    i_service_days             IN    NUMBER,
                                    o_discount_description     OUT   VARCHAR2,
                                    o_discount_amount          OUT   VARCHAR2,
                                    o_error_num                OUT   VARCHAR2,
                                    o_error_msg                OUT   VARCHAR2
                                  );

  PROCEDURE LL_REDEMPTION_TRANSACTION( i_ct_objid  	  	IN  VARCHAR2,
                                       i_esn         IN  VARCHAR2,
                                       i_min         IN  VARCHAR2,
                                       o_error_num   OUT VARCHAR2,
                                       o_error_msg   OUT VARCHAR2
                                     );

  PROCEDURE LL_MINC_TRANSACTION( i_ig_transaction_id	 IN NUMBER,
                                 o_error_num    		OUT VARCHAR2,
                                 o_error_msg    	 	OUT VARCHAR2
                               );

	PROCEDURE LL_ESN_CHANGE_TRANSACTION( i_ig_transaction_id IN  NUMBER,
									     o_error_num 		OUT VARCHAR2,
									     o_error_msg  		OUT VARCHAR2
                                     );

  PROCEDURE PROCESS_LL_TRANSFER ( i_old_min       IN    VARCHAR2,
                                  i_old_esn       IN    VARCHAR2,
                                  i_lid           IN    VARCHAR2,
                                  i_source_system IN    VARCHAR2,
                                  i_agent_name    IN    VARCHAR2,
                                  i_new_min       IN    VARCHAR2,
                                  i_new_esn       IN    VARCHAR2,
                                  o_error_num     OUT   VARCHAR2,
                                  o_error_msg     OUT   VARCHAR2
                                  );

  PROCEDURE PROCESS_DEENROLLMENTS ( i_max_row_limit      IN    NUMBER DEFAULT 5000 ,
                                    i_commit_every_rows  IN    NUMBER DEFAULT 1000 ,
                                    o_response           OUT   VARCHAR2
                                  );

  PROCEDURE PROCESS_ENROLLMENTS ( i_lid                IN    VARCHAR2,
                                  i_job_data_id        IN    VARCHAR2,
                                  o_error_num          OUT   VARCHAR2,
                                  o_error_msg          OUT   VARCHAR2
                                );

  FUNCTION IS_LIFELINE_ENROLLED ( i_esn  IN   VARCHAR2,
                                  i_min  IN   VARCHAR2
                                ) RETURN  VARCHAR2;
END LL_SUBSCRIBER_PKG;
/