CREATE OR REPLACE FORCE VIEW sa.x_act_esn_carrier_view (active_on,click_plan2,click_plan3,click_plan4,click_plan9_9,cnt) AS
select ACTIVE_ON,
       sum(CLICK_PLAN2)   CLICK_PLAN2,
       sum(CLICK_PLAN3)   CLICK_PLAN3,
       sum(CLICK_PLAN4)   CLICK_PLAN4,
       sum(CLICK_PLAN9_9) CLICK_PLAN9_9,
       sum(cnt)           cnt
 from x_act_esn_carrier
group by active_on
;