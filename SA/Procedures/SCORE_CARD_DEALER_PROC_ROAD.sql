CREATE OR REPLACE PROCEDURE sa."SCORE_CARD_DEALER_PROC_ROAD" (p_date in date default sysdate-1) as
/*$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
<Version>1.1</Version>
<FILENAME>SA.SCORE_CARD_DEALER_PROC_road</FILENAME>
<AUTHOR>jborja</AUTHOR>
<SUMMARY>populate history tables for roadside score card with dealer info</SUMMARY>

<DEPENDENCIES>x_road_ftp</DEPENDENCIES>

<EXCEPTIONS></EXCEPTIONS>

<PARAMETERS>Date in is the date to be analyzed</PARAMETERS>

<Category>ROADSIDE</Category>

MODIFICATION HISTORY
DATE                BY                  DESCRIPTION
_______________________________________________________________________________
2/18/2002           JBORJA              TEMPLATE CREATION
3/11/2002           jborja              Stored Procedure Compiled
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*/



begin
    delete from x_score_card_history_ROAD
     where score_type ='DEALER'
       and score_date = trunc(p_date)
       and score_code != 'ACTIVE';
    insert into x_score_card_history_ROAD
    select
            trunc(a.activation_date)    score_date,
            'DEALER'                    score_type,
            'ACCOUNT OPEN'              score_code,
            a.ROAD_DEALER_NAME          Score_name,
            count(distinct service_id)                    score_count
       from sa.x_road_ftp a
      where a.activation_date >= trunc(p_date)
        and a.activation_date <  trunc(p_date + 1)
        and a.trans_type||''       = 'N'
      group by trunc(a.activation_date),
               a.trans_type,
               a.ROAD_DEALER_NAME
  union

  select
            trunc(a.activation_date)        score_date,
            'DEALER'                        score_type,
            'ACCOUNT RENEW'                 score_code,
            a.ROAD_DEALER_NAME              score_name,
            count(distinct service_id)                        score_count
       from sa.x_road_ftp a
      where a.activation_date >= trunc(p_date)
        and a.activation_date <  trunc(p_date + 1)
        and a.trans_type||''       = 'R'
      group by trunc(a.activation_date),
               a.trans_type,
               a.ROAD_DEALER_NAME
  union

    select
            trunc(a.deactivation_date)      score_date,
            'DEALER'                        score_type,
            'ACCOUNT CANCEL'                score_code,
            a.ROAD_DEALER_NAME              score_name,
            count(distinct service_id)                        score_count
       from sa.x_road_ftp a
      where a.deactivation_date >= trunc(p_date)
        and a.deactivation_date  < trunc(p_date + 1)
        and a.trans_type||''       = 'C'
      group by trunc(a.deactivation_date),

               a.trans_type,
               a.ROAD_DEALER_NAME
  union
select
        trunc(a.activation_date)                    score_date,
         'DEALER'                                   score_type,
        'ACCOUNT OPEN COST'                         score_code,
        a.ROAD_DEALER_NAME                          score_name,
        sum(nvl(ROAD_PART_RETAILCOST,0))            score_count
   from x_road_ftp a
  where a.activation_date >= trunc(p_date)
    and a.activation_date <  trunc(p_date + 1)
    AND upper(A.TRANS_TYPE) = 'N'
  group by trunc(a.activation_date),
           A.TRANS_TYPE,
          a.ROAD_DEALER_NAME

  union
select
        trunc(a.activation_date)                    score_date,
         'DEALER'                                   score_type,
        'ACCOUNT RENEW COST'                        score_code,
        a.ROAD_DEALER_NAME                        score_name,
        sum(nvl(ROAD_PART_RETAILCOST,0))  score_count
   from x_road_ftp a
  where a.activation_date >= trunc(p_date)
    and a.activation_date <  trunc(p_date + 1)
    AND upper(A.TRANS_TYPE) = 'R'
  group by trunc(a.activation_date),
           A.TRANS_TYPE,
          a.ROAD_DEALER_NAME

  union
select
        trunc(a.deactivation_date)                 score_date,
        'DEALER'                                 score_type,
        'ACCOUNT CANCEL COST' score_code,
        a.ROAD_DEALER_NAME                        score_name,
        sum(nvl( CUSTOMER_REFUND,0))  score_count
   from x_road_ftp a
  where a.deactivation_date >= trunc(p_date)
    and a.deactivation_date <  trunc(p_date + 1)
    AND upper(A.TRANS_TYPE) = 'C'
  group by trunc(a.deactivation_date),
           A.TRANS_TYPE,
           a.ROAD_DEALER_NAME
 union
select trunc(toss_posa_date)                score_date,
        'DEALER'                            score_type,
        'POSA SWIPE COUNT'               score_code,
        st.name,
        sum(decode(TOSS_POSA_ACTION,'SWIPE',1,0)) - sum(decode(TOSS_POSA_ACTION,'UNSWIPE',1,0)) score_count
from table_site st,
     x_posa_road a
where
    st.site_id = a.TOSS_SITE_ID
    and a.toss_posa_date >= trunc(p_date)
    and a.toss_posa_date <  trunc(p_date + 1)
   -- and toss_posa_action = 'SWIPE'
group by trunc(toss_posa_date),
    st.name,
    st.site_id;

end;
/