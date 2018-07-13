CREATE OR REPLACE PACKAGE sa."ENQUEUE_TRANSACTIONS_PKG"
IS
--New stored procedure to enqueue transactions
PROCEDURE enqueue_transaction(i_esn               IN VARCHAR2 ,
                              i_ig_order_type     IN VARCHAR2 ,
                              i_ig_transaction_id IN NUMBER   ,
                              o_response          OUT VARCHAR2
                              );
--New stored procedure to update x_event_gateway table based on the given event objid
PROCEDURE update_event(i_event_objid            IN  NUMBER  ,
                       i_request                IN  XMLTYPE ,
                       i_response               IN  XMLTYPE ,
                       i_http_code              IN  NUMBER  ,
                       i_retry_count            IN  NUMBER  ,
                       i_queue_event_log_status IN  VARCHAR2,
                       o_response               OUT VARCHAR2
                       );
--New stored procedure to enqueue deactivation transactions
PROCEDURE enqueue_deactivation(i_esn               IN  VARCHAR2,
                               i_min               IN  VARCHAR2,
                               i_deactreason       IN  VARCHAR2,
			       i_sourcesystem      IN  VARCHAR2,
			       i_action_item_id    IN  VARCHAR2,
                               o_response          OUT VARCHAR2
                               );
--New stored procedure to enqueue migration
PROCEDURE enqueue_migration(i_esn               IN VARCHAR2 ,
                            i_min               IN VARCHAR2 ,
			    i_web_user_objid    IN NUMBER   ,
			    i_bus_org_id        IN VARCHAR2 ,
			    i_sourcesystem      IN VARCHAR2 ,
			    i_ct_objid          IN NUMBER   ,
			    i_ct_action_type    IN VARCHAR2 ,
			    i_ct_action_text    IN VARCHAR2 ,
			    i_ct_reason         IN VARCHAR2 ,
                            i_ig_order_type     IN VARCHAR2 ,
                            i_ig_transaction_id IN NUMBER   ,
			    i_event_name        IN VARCHAR2 ,
                            o_response          OUT VARCHAR2
                            );
--New stored procedure to re-enqueue transactions
PROCEDURE reenqueue_transactions ( i_max_rows_limit     IN    NUMBER  DEFAULT 10000,
                                   i_commit_every_rows  IN    NUMBER  DEFAULT 5000,
                                   i_max_retries        IN    NUMBER  DEFAULT 3,
                                   o_err_num            OUT   VARCHAR2,
                                   o_err_msg            OUT   VARCHAR2 );

--New stored procedure to handle refurbish transactions for TAS
PROCEDURE enqueue_refurbish_transaction(i_esn      IN  VARCHAR2,
                                        o_response OUT VARCHAR2
                                       );

-- Proc to queue LifeLine enrollments to BRM -- mdave 06/03/2017
PROCEDURE enqueue_lifeline_enrollments(i_esn               IN  VARCHAR2,
                                       i_min               IN  VARCHAR2,
                                       i_enrollment_status IN  VARCHAR2,
                                       o_response          OUT VARCHAR2
                                       );
--CR48260_MultiLine Discount on SM - New proc to enquue Affiliated partner
PROCEDURE sp_notify_affpart_discount_BRM   (i_web_user_objid       IN    NUMBER   ,
                                            i_login_name           IN    VARCHAR2 ,
                                            i_bus_org_id           IN    VARCHAR2 ,
                                            i_web_user2contact	   IN	 NUMBER   ,
                                            o_response             OUT   VARCHAR2);
--CR48260_MultiLine Discount on SM - New generic proc to enqueue transaction
PROCEDURE enqueue_generic_transaction (i_source_type         IN  VARCHAR2,
                                       i_source_tbl          IN  VARCHAR2,
                                       i_source_status       IN  VARCHAR2,
                                       i_esn                 IN  VARCHAR2 DEFAULT NULL,
                                       i_min                 IN  VARCHAR2 DEFAULT NULL,
                                       i_bus_org_id          IN  VARCHAR2,
                                       i_event_name          IN  VARCHAR2,
                                       i_nameval             IN  sa.q_nameval_tab,
                                       i_step                IN  VARCHAR2,
                                       i_action_type         IN  VARCHAR2,
                                       i_action_text         IN  VARCHAR2,
                                       o_response            OUT VARCHAR2
                                       );
END enqueue_transactions_pkg;
/