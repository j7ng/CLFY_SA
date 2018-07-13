CREATE OR REPLACE PACKAGE sa."BILLING_LIFELINE_PKG"
IS
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   BILLING_LIFELINE_PKG.IS_LIFELINE_CUSTOMER                              */
/*                                                                                            */
/* Purpose      :   To return the enrollment status of Lifeline Custoemr                   */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 10g                                                                */
/*                                                                                            */
/* Author       :   Ramu                                                                      */
/*                                                                                            */
/* Date         :   06-15-2008                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0     06-15-2008  Ramu         Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
   FUNCTION is_lifeline_customer (p_esn IN VARCHAR2)
      RETURN NUMBER;

/*************************************************************************************************/
/*                                                                                            */
/* Name         :   BILLING_LIFELINE_PKG.DELIVER_RECURRING_MINUTES                            */
/*                                                                                            */
/* Purpose      :   To Deliver the recurring Minutes for Lifeline Customers                   */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 10g                                                                */
/*                                                                                            */
/* Author       :   Ramu                                                                      */
/*                                                                                            */
/* Date         :   06-15-2008                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0     06-15-2008  Ramu         Initial  Revision                                        */
/*                                                                                            */
/*                                                                                            */
/*************************************************************************************************/
 -- CR10881
   PROCEDURE deliver_recurring_minutes (
      --  ip_x_ota_trans_id IN NUMBER,
      op_result   OUT   VARCHAR2,                            -- Output Result
      op_msg      OUT   VARCHAR2                            -- Output Message
   );

   PROCEDURE deliver_recurring_minutes (
      ip_x_ota_trans_id   IN       NUMBER,
      future_days         IN       NUMBER,
      op_result           OUT      VARCHAR2,                 -- Output Result
      op_msg              OUT      VARCHAR2                 -- Output Message
   );
  PROCEDURE deliver_recurring_minutes (
      ip_x_ota_trans_id    IN       NUMBER,
      future_days          IN       NUMBER,
      i_daily_monthly_flag IN       VARCHAR2,        -- M for Monthly and D for Daily
      i_divisor            IN       NUMBER,
      i_remainder          IN       NUMBER,
      i_bulk_collect_limit IN       NUMBER,
      op_result            OUT      VARCHAR2,        -- Output Result
      op_msg               OUT      VARCHAR2         -- Output Message
   );
   PROCEDURE get_sw_cr_flag ( i_site_part_objid IN NUMBER         ,
                              i_esn             IN VARCHAR2       ,
                              o_sw_flag         OUT      VARCHAR2 ,
                              o_plan_type       OUT      VARCHAR2 ,
                              o_msg             OUT      VARCHAR2                 -- Output Message
                            ) ;

END billing_lifeline_pkg;        -- Package Specification BILLING_LIFELINE_PKG
/