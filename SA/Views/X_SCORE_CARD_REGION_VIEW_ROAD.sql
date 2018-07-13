CREATE OR REPLACE FORCE VIEW sa.x_score_card_region_view_road (score_date,score_name,"ACTIVE",account_open,account_renew,cancellation,account_open_cost,account_renew_cost,cancellation_cost,posa_swipe) AS
select
       score_date score_date,
       score_name,
       sum(decode(sch.score_code,'ACTIVE',score_count,0))       ACTIVE,
       sum(decode(sch.score_code,'ACCOUNT OPEN',score_count,0))   Account_Open,
       sum(decode(sch.score_code,'ACCOUNT Renew',score_count,0))   Account_Renew,
       sum(decode(sch.score_code,'ACCOUNT CANCEL',score_count,0)) Cancellation,
       sum(decode(sch.score_code,'ACCOUNT OPEN COST',score_count,0)) Account_open_cost,
       sum(decode(sch.score_code,'ACCOUNT RENEW COST',score_count,0)) Account_Renew_cost,
       sum(decode(sch.score_code,'ACCOUNT CANCEL COST',score_count,0)) Cancellation_cost,
       sum(decode(sch.score_code,'POSA SWIPE COUNT',score_count,0)) POSA_SWIPE
from x_score_card_history_ROAD sch
  where score_type = 'REGION'
group by score_date,
         score_name;