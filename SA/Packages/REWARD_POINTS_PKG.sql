CREATE OR REPLACE PACKAGE sa.REWARD_POINTS_PKG
IS
/*
12-NOV-2014
CR31431 - NET10 / SIMPLE MOBILE UPGRADE PLANS PROJECT
Vkashmire
*/

 procedure p_generate_reward_point_trans (
 in_rundate in date,
 in_min in varchar2 default null,
 in_esn in varchar2 default null,
 out_err_code out integer,
 out_err_msg out varchar2
 );
 /*
 PROCEDURE P_GENERATE_REWARD_POINT_TRANS
 This procedure will simply read table_x_call_trans
 Check whether points are to be issues for the action type
 And insert record in table_x_point_trans with appropriate points
 for X_ACTION_TYPE in 1,3,6
 */

 procedure p_get_reward_points (
 in_key in varchar2,
 in_value in varchar2,
 in_point_category in varchar2 default 'REWARD_POINTS',
 out_total_points out number,
 out_subscriber_id out varchar2,
 out_err_code out integer,
 out_err_msg out varchar2
 );
 /*
 P_GET_REWARD_POINTS
 This procedure will accept input as MIN or ESN and will provide output as total points available
 in_key = can be ESN or MIN
 in_value = value of esn or min
 out_points = total points available
 */

 procedure p_compensate_reward_points (
 in_key in varchar2,
 in_value in varchar2,
 in_points in number,
 in_points_category in varchar2 default 'REWARD_POINTS',
 in_points_action in varchar2,
 in_user_objid in number,
 in_compensate_reason in varchar2,
 out_total_points out number,
 inout_transaction_id in out number,
 out_err_code out integer,
 out_err_msg out varchar2
 );
 /*
 P_COMPENSATE_REWARD_POINTS
 This procedure will update the reward points for input MIN
 and provides output as total points available
 */

/*27-APR-2015 CR32367
 Vedanarayanan S
 Overloading the compensate reward points procedure to add additional input
 parameter "service plan objid"
*/
 procedure p_compensate_reward_points (
 in_key in varchar2,
 in_value in varchar2,
 in_points in number,
 in_points_category in varchar2 default 'REWARD_POINTS',
 in_points_action in varchar2,
 in_user_objid in number,
 in_compensate_reason in varchar2,
 in_service_plan_objid in number,
 out_total_points out number,
 inout_transaction_id in out number,
 out_err_code out integer,
 out_err_msg out varchar2
 );

 procedure p_update_reward_points_job (
 in_rundate in date,
 out_err_code out integer,
 out_err_msg out varchar2
 );
 /*
 p_update_reward_points_job
 This procedure will calculate reward points for each esn and update the total reward points
 This will also check for inactive min / esn for X days and wipes out the reward points as applicable
 */

 procedure p_calculate_points (
 in_min in varchar2 default null,
 out_err_code out integer,
 out_err_msg out varchar2
 ) ;

 procedure p_refund_points (
 in_rundate in date,
 out_err_code out integer,
 out_err_msg out varchar2
 );
 /*
 procedure p_refund_points : this procedure processes the refund transactions of last 60 days
 when customer asks for refund of any redemption through which he has got any reward points
 then during refund we should return the money to customer.
 and return the points to tracfone (subtract points from customers MIN account)
 */

 procedure p_get_points_for_purch_trans (
 in_purch_objid in number,
 out_purch_type out varchar2,
 out_points out number,
 out_points_category out varchar2,
 out_err_code out integer,
 out_err_msg out varchar2
 );
 /*
 procedure: p_get_points_for_purch_trans
 This procedure accepts transaction objid
 and returns how many points were earned during that transaction
 */

 procedure p_check_point_account (
 in_min in varchar2,
 in_esn in varchar2,
 out_account_objid out number,
 out_account_bus_org out number
 );
 /*
 procedure: p_check_point_account
 check if ACTIVE point_account is exists for input MIN or not
 if not exists then creates a account with ACTIVE status
 then output the account objid
 */

 function f_get_purch_objid (in_red_card_objid in number)
 return number;

 /*VS:062915:CR35343:Adding in_esn as input to get the correct plan information*/
 procedure p_get_points_n_plan (
 in_esn in varchar2,
 in_call_trans_objid in number,
 in_call_trans_actiontype in varchar2,
 in_call_trans_reason in varchar2,
 out_points_earned out number,
 out_points_plan out number,
 out_purch_objid out number,
 out_purch_table_name out varchar2
 );
 /*
 procedure: p_get_points_n_plan
 this procedure accepts the call_trans.objid and finds out the corresponding
 purchase transaction record and service plan
 and outputs the purch-txn objid with any reward points that it can earn
 */

 type typ_rec_points_hist is record(
 objid	 table_x_point_trans.objid%type,
 x_trans_date	 table_x_point_trans.x_trans_date%type,
 x_min	 table_x_point_trans.x_min%type,
 x_esn	 table_x_point_trans.x_esn%type,
 x_points_category	table_x_point_trans.x_points_category%type,
 x_points	 table_x_point_trans.x_points%type,
 x_points_action	 table_x_point_trans.x_points_action%type,
 points_action_reason	 table_x_point_trans.points_action_reason%type, --CR32367 vs:0512/2015
 display_action_reason	 table_x_point_trans.points_action_reason%type --CR32367 vs:0512/2015
 );

 type tab_points_hist is table of typ_rec_points_hist;


 function f_get_points_history (
 in_key in varchar2,
 in_value in varchar2
 ) return tab_points_hist pipelined ;



 procedure p_get_reward_points (
 in_key in varchar2,
 in_value in varchar2,
 in_point_category in varchar2 default 'REWARD_POINTS',
 out_total_points out number,
 out_amount out number,
 out_err_code out integer,
 out_err_msg out varchar2
 );

 procedure p_compensate_reward_points (
 in_key in varchar2,
 in_value in varchar2,
 in_points in number,
 in_points_category in varchar2 default 'REWARD_POINTS',
 in_points_action in varchar2,
 in_user_objid in number,
 in_compensate_reason in varchar2,
 out_total_points out number,
 out_amount out number,
 inout_transaction_id in out number,
 out_err_code out integer,
 out_err_msg out varchar2
 );

 procedure p_get_reward_summary (
 in_key in varchar2,
 in_value in varchar2,
 in_point_category in varchar2 default 'REWARD_POINTS',
 out_total_points out number,
 out_subscriber_id out varchar2,
 out_reward_total out number,
 out_err_code out integer,
 out_err_msg out varchar2
 );

procedure p_compensate_bonus_points (
 in_key in varchar2,
 in_value in varchar2,
 in_points in number,
 in_points_category in varchar2 default 'BONUS_POINTS',
 in_points_action in varchar2,
 in_user_objid in number,
 in_compensate_reason in varchar2,
 in_service_plan_objid in number,
 in_bonus_objid in number,
 out_total_points out number,
 inout_transaction_id in out number,
 out_err_code out integer,
 out_err_msg out varchar2
 );

procedure p_insert_bonus_points ;
end  reward_points_pkg;
/