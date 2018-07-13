CREATE OR REPLACE FORCE VIEW sa.portal_view (web_user_objid,contact_objid,firstname,lastname,email,"PASSWORD",brand) AS
select /*+ORDERED */ wu.objid web_user_objid,
       c.objid contact_objid,
       c.first_name firstname,
       c.last_name lastname,
       c.e_mail email,
       wu.password,
       bo.org_id brand
from table_bus_org bo,table_web_user wu,table_contact c
where wu.WEB_USER2CONTACT = c.objid
and  WEB_USER2BUS_ORG  = bo.objid
and bo.type = 'IT'
and bo.org_id = 'STRAIGHT_TALK';