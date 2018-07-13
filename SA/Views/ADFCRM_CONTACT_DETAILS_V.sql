CREATE OR REPLACE FORCE VIEW sa.adfcrm_contact_details_v (cust_id,f_name,l_name,x_middle_initial,phone,objid,address,address_2,city,st,country,zip,fax,email,contact_objid) AS
SELECT c.x_cust_id cust_id,
    c.first_name f_name,
    c.last_name l_name,
    c.x_middle_initial,
    c.phone,
    a.objid,
    a.address,
    a.address_2,
    c.city,
    a.state st,
    c.country,
    a.zipcode zip,
    c.fax_number fax,
    c.e_mail email,
    c.objid AS contact_OBJID
  FROM table_contact c,
    table_contact_role cr,
    table_address a,
    table_site s
  WHERE 1     =1
  AND a.objid = s.cust_primaddr2address
  AND s.objid = cr.contact_role2site
  AND c.objid = cr.contact_role2contact
    --    and    c.objid        = 274812630; 
;