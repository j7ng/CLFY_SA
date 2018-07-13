CREATE OR REPLACE FORCE VIEW sa.carrlistbyzip (new_rank,zip,carrier,carrier_id,technology,min_dll_exch,max_dll_exch,sim_profile) AS
select distinct new_rank,
 zip,
 case
 WHEN x_parent_name like '%SPRINT%' then 'SPRINT'
 WHEN x_parent_name like 'T-MO%' then  'T-MOBILE'
 WHEN x_parent_name like 'AT%T%' then  'AT&T'
 WHEN x_parent_name like '%VERIZON%' then 'VERIZON WIRELESS'
 ELSE x_parent_name
 END   CARRIER,
 carrier_id,
 technology,a.min_dll_exch,a.max_dll_exch,sim_profile--,s_org_id brand
from table_x_carrier car,
     table_x_carrier_group cg,
--     table_x_carrier_features cf,
--     table_bus_org bo,
     table_x_parent p,
     (  SELECT zip, nvl(nvl(b.cdma_tech,b.gsm_tech),b.tdma_tech) technology ,
                b.carrier_id,a.sim_profile,a.min_dll_exch,a.max_dll_exch,
                min(to_number(cp.new_rank)) new_rank
        FROM carrierpref cp,
             npanxx2carrierzones b,
             (SELECT DISTINCT a.zip,
                     a.ZONE,
                     a.st,
                     s.sim_profile,
                     a.county,
                     s.min_dll_exch,
                     s.max_dll_exch,
                     s.rank
              FROM carrierzones a, carriersimpref s
              WHERE 1=1
              and a.CARRIER_NAME=s.CARRIER_NAME
              and max_dll_exch is not null
              order by s.rank asc) a
        WHERE 1=1
        AND cp.st = b.state
        and cp.carrier_id = b.carrier_ID
        and cp.county = a.county
        and a.sim_profile = decode('',null,a.sim_profile,'')
        AND b.ZONE = a.ZONE
        AND b.state = a.st
        group by zip, b.carrier_id,a.sim_profile,a.min_dll_exch,a.max_dll_exch,b.cdma_tech,b.gsm_tech,b.tdma_tech) a
where regexp_replace(technology,'.*NULL.*',null) is not null
and a.carrier_id = car.x_carrier_id
and car.CARRIER2CARRIER_GROUP = cg.objid
and cg.x_carrier_group2x_parent = p.objid
--and cf.X_FEATURE2X_CARRIER = car.objid
--and cf.X_FEATURES2BUS_ORG = bo.objid
--and cf.x_technology  = technology
order by new_rank;