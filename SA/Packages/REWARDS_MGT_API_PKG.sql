CREATE OR REPLACE PACKAGE sa.REWARDS_MGT_API_PKG
  AS
 --$RCSfile: REWARDS_MGT_API_PKG.SQL,v $
 --$Revision: 1.25 $
 --$Author: skota $
 --$Date: 2016/12/13 21:33:53 $
 --$ $Log: REWARDS_MGT_API_PKG.SQL,v $
 --$ Revision 1.25  2016/12/13 21:33:53  skota
 --$ Added new procedure for earn points
 --$
 --$ Revision 1.24  2016/09/16 12:49:27  sethiraj
 --$ CR41473-LRP2-Added Modification History Template
 --$
 --$ Revision 1.23  2016/09/12 17:32:21  pamistry
 --$ CR41473 - Modify the object type typ_rec_benefits_hist to add transaction_type in it.
 --$


 --------------------------------------------------------------------------------------------
-- Author: snulu (Sujatha Nulu)
-- Date: 2015/10/01
-- <CR# 33098>
-- Loyalty Rewards Program is to build a capability to give rewards for certain customer Actions
-- and increase the Life Time value of the customer.
-- This program is precisely targeting the customers who fall under the umbrella of Straight Talk.
--------------------------------------------------------------------------------------------
  TYPE typ_rec_benefits_hist IS record(
    objid	                x_reward_benefit.objid%TYPE,
    x_trans_date	        x_reward_benefit_transaction.trans_date%TYPE,
    x_min	                x_reward_benefit_transaction.MIN%TYPE,
    x_esn	                x_reward_benefit_transaction.esn%TYPE,
    web_account_id        x_reward_benefit_transaction.web_account_id%TYPE,
    x_points_action	      x_reward_benefit_transaction.action%TYPE,
    x_benefit_value       x_reward_benefit_program.benefit_value%TYPE,
    amount                x_reward_benefit_transaction.amount%TYPE,
    points_action_reason	x_reward_benefit_transaction.action_reason%TYPE ,
    display_action_reason	x_reward_benefit_transaction.trans_desc%TYPE,
    action_notes          x_reward_benefit_transaction.action_notes%TYPE,
    transaction_status    x_reward_benefit_transaction.transaction_status%TYPE, -- CR41473 - LRP2 -- sethiraj - Added new column
    maturity_date         x_reward_benefit_transaction.maturity_date%TYPE,      -- CR41473 - LRP2 -- sethiraj - Added new column
    expiration_date       x_reward_benefit_transaction.expiration_date%TYPE,    -- CR41473 - LRP2 -- sethiraj - Added new column
    catalog_provider      x_reward_catalog.catalog_provider%TYPE,				        -- CR41473 - LRP2 -- sethiraj - Added new column
    transaction_type		  x_reward_benefit_transaction.trans_type%TYPE,         -- CR41473 - LRP2 -- PMistry - Added new column
    nick_name             table_x_contact_part_inst.x_esn_nick_name%TYPE
  );
  --
  TYPE tab_benefits_hist IS TABLE OF typ_rec_benefits_hist;
	-- CR41473 - LRP2 PMistry 08/24/2016
  TYPE typ_reward_catalog_obj IS record(
		objid									                x_reward_benefit_earning.objid%TYPE,
		program_name                       		x_reward_benefit_earning.program_name%TYPE,
		benefit_type_code                  		x_reward_benefit_earning.benefit_type_code%TYPE,
		transaction_type                   		x_reward_benefit_earning.transaction_type%TYPE,
		benefits_earned                    		x_reward_benefit_earning.benefits_earned%TYPE,
		start_date                         		x_reward_benefit_earning.start_date%TYPE,
		end_date                           		x_reward_benefit_earning.end_date%TYPE,
		category                           		x_reward_benefit_earning.category%TYPE,
		sub_category                       		x_reward_benefit_earning.sub_category%TYPE,
		individual_action_count            		x_reward_benefit_earning.individual_action_count%TYPE,
		max_usage                          		x_reward_benefit_earning.max_usage%TYPE,
		max_usage_freq_days                		x_reward_benefit_earning.max_usage_freq_days%TYPE,
		point_cooldown_days                		x_reward_benefit_earning.point_cooldown_days%TYPE,
		point_expiration_days              		x_reward_benefit_earning.point_expiration_days%TYPE,
		revenue_direction                  		x_reward_benefit_earning.revenue_direction%TYPE,
		transaction_revenue_direction      		x_reward_benefit_earning.transaction_revenue_direction%TYPE,
		transaction_description            		x_reward_benefit_earning.transaction_description%TYPE,
		catalog_id  							            x_reward_catalog.objid%TYPE,
		catalog_name                         	x_reward_catalog.catalog_name%TYPE,
		catalog_type                         	x_reward_catalog.catalog_type%TYPE,
		catalog_version                      	x_reward_catalog.catalog_version%TYPE,
		catalog_status                       	x_reward_catalog.catalog_status%TYPE,
		catalog_provider						x_reward_catalog.catalog_provider%TYPE
  );
	TYPE typ_reward_catalog_tbl IS TABLE OF typ_reward_catalog_obj;

  --
  PROCEDURE p_get_reward_benefits(
              in_key                    IN VARCHAR2 ,
              in_value                  IN VARCHAR2 ,
              in_program_name           IN VARCHAR2 ,                  --  "UPGRADE_PLANS"
              in_benefit_type_code      IN VARCHAR2 ,                  -- "REWARD_BENEFITS"
              out_reward_benefits_list  OUT sa.reward_benefits_table , -- CR33098 MODIFIED
              out_err_code              OUT NUMBER ,
              out_err_msg               OUT VARCHAR2 );

  PROCEDURE p_get_reward_points (
              in_event_type        IN VARCHAR2 ,
              in_program_name      IN VARCHAR2 ,
              in_benefit_type_code IN VARCHAR2 ,
              in_brand             IN VARCHAR2 ,
              in_service_plan_id   IN VARCHAR2 ,
              in_trans_type        IN VARCHAR2 ,
              out_points           OUT NUMBER ,
              out_err_code         OUT NUMBER ,
              out_err_msg          OUT VARCHAR2 );

  PROCEDURE p_get_reward_benefit_trans (
        in_esn                IN VARCHAR2,
        in_web_account_id     IN VARCHAR2,
        in_svc_plan_pin       IN NUMBER,
        in_brand              IN VARCHAR2,
        in_benefit_type_code  IN  VARCHAR2,
        in_trans_type         IN VARCHAR2,
        in_program_name       IN VARCHAR2,
        out_trans_detail      OUT typ_lrp_redem_trans,
        out_err_code          OUT NUMBER,
        out_err_msg           OUT VARCHAR2
);
FUNCTION F_GET_BENEFITS_HISTORY(
        in_key   IN VARCHAR2,
        in_value IN VARCHAR2,
        in_benefit_type_code  IN VARCHAR2 )
      RETURN tab_benefits_hist pipelined;

-- CR41473 - LRP2 - sethiraj - Added procedure which returns reward benefit earnings
--
FUNCTION f_get_reward_catalog(
          in_catalog_provider  IN x_reward_catalog.catalog_provider%TYPE DEFAULT NULL,
          in_catalog_type      IN x_reward_catalog.catalog_type%TYPE DEFAULT NULL,
          in_benefit_type_code IN x_reward_benefit_earning.benefit_type_code%TYPE DEFAULT NULL,
          in_program_name      IN x_reward_benefit_earning.program_name%TYPE DEFAULT NULL,
          in_transaction_type  IN x_reward_benefit_earning.transaction_type%TYPE DEFAULT NULL)
		RETURN  typ_reward_catalog_tbl  pipelined;

--
PROCEDURE get_reward_catalog(
          in_catalog_provider  IN x_reward_catalog.catalog_provider%TYPE DEFAULT NULL,
          in_catalog_type      IN x_reward_catalog.catalog_type%TYPE DEFAULT NULL,
          in_benefit_type_code IN x_reward_benefit_earning.benefit_type_code%TYPE DEFAULT NULL,
          in_program_name      IN x_reward_benefit_earning.program_name%TYPE DEFAULT NULL,
          in_transaction_type  IN x_reward_benefit_earning.transaction_type%TYPE DEFAULT NULL,
          out_reward_catelog   OUT SYS_REFCURSOR,
          out_err_code         OUT NUMBER,
          out_err_msg          OUT VARCHAR2);

PROCEDURE get_reward_transactions(
          IN_WEB_ACCOUNT_ID IN VARCHAR2,
          IN_BRAND IN VARCHAR2,
          out_reward_transaction   OUT SYS_REFCURSOR,
          out_err_code         OUT NUMBER,
          out_err_msg          OUT VARCHAR2);

PROCEDURE P_GET_REWARD_EARN_POINT
(   i_esn         			 IN VARCHAR2,
    i_pin				     IN VARCHAR2,
    out_ern_point            out NUMBER,
    out_err_code             out NUMBER,
    out_err_msg              out VARCHAR2
) ;

  END rewards_mgt_api_pkg;
/