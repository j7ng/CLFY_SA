CREATE OR REPLACE FORCE VIEW sa.st_money_card_legacy (job_data_id,x_request_type,x_request,ordinal) AS
SELECT /*+ ORDERED */
'201104130000000000' AS JOB_DATA_ID,
'MoneyCardLegacy' AS X_REQUEST_TYPE,
'<request><requestType>MoneyCardLegacy</requestType>'||
'<objid>'||cc.objid||'</objid>'||
'<x_cust_cc_num_key><![CDATA['|| cc.x_cust_cc_num_key||']]></x_cust_cc_num_key>'||
'<x_cust_cc_num_enc><![CDATA['|| cc.x_cust_cc_num_enc||']]></x_cust_cc_num_enc>'||
'<x_cert><![CDATA['|| c.x_cert||']]></x_cert>'||
'<x_key_algo><![CDATA['|| c.x_key_algo||']]></x_key_algo>'||
'<x_cc_algo><![CDATA['|| c.x_cc_algo||']]></x_cc_algo>'||
'</request>' AS X_REQUEST,
0 AS ORDINAL
FROM X_CERT c,
     TABLE_X_CREDIT_CARD cc
where 1=1
and cc.creditcard2cert = c.objid
and exists (select 1
              from table_bus_org bo
             where bo.s_org_id='STRAIGHT_TALK'
               and bo.objid = cc.x_credit_card2bus_org)
;