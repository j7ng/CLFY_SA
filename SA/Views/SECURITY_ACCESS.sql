CREATE OR REPLACE FORCE VIEW sa.security_access (perm_objid,permission_name,class_objid,class_name,user_objid,user_name) AS
select p.objid perm_objid,
       p.permission_name,
       c.objid class_objid,
       c.class_name,
       u.objid user_objid,
       u.s_login_name user_name
from   x_crm_permissions p,
       x_crm_perms2priv_class mtm,
       table_privclass c,
       table_user u
where  1=1
and    p.objid = mtm.permission_objid
and    c.objid = mtm.priv_class_objid
and    c.objid = u.user_access2privclass;