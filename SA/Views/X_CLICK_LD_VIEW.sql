CREATE OR REPLACE FORCE VIEW sa.x_click_ld_view (active_on,click_plan1,click_plan1_5,cnt) AS
select ACTIVE_ON,
       sum(click_plan1) click_plan1,
       sum(click_plan1_5) click_plan1_5,
       sum(cnt) cnt
 from x_click_ld
group by active_on
;