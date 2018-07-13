CREATE OR REPLACE FORCE VIEW sa.adfcrm_ticker (ticker_msg) AS
select '<p style="color:'||decode(font_clr,'black','#000000','blue','#336699',font_clr)||'">'||decode(font_wt,'y','<b>',null)||script_text||' - '||to_char(create_date,'MM.DD.YY')||' - '||substr(created_by,0,2)||decode(font_wt,'y','</b>',null)||'</p>' ticker_msg
from   adfcrm_ticker_history
where  display_ticker = 1
order by create_date desc,objid desc;