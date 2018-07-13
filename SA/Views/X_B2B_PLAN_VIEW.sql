CREATE OR REPLACE FORCE VIEW sa.x_b2b_plan_view (bus_org,objid,x_program_name,x_type,x_csr_channel,x_web_channel,x_ivr_channel,x_retail_price) AS
select 'NET10' bus_org,pgmprm.objid, pgmprm.x_program_name,pgmprm.x_type,pgmprm.x_csr_channel,
PGMPRM.X_WEB_CHANNEL, PGMPRM.X_IVR_CHANNEL,PRICE.X_RETAIL_PRICE
FROM TABLE_BUS_ORG BUS,X_PROGRAM_PARAMETERS PGMPRM,TABLE_X_PRICING PRICE,
table_part_num pn
where 1=1
and pgmprm.prog_param2prtnum_monfee is not null
and price.x_pricing2part_num = pn.objid
and price.x_retail_price > 0
and price.x_end_date > trunc(sysdate)
and price.x_start_date <= trunc(sysdate)
and pn.objid = pgmprm.prog_param2prtnum_monfee
and bus.s_org_id ='NET10'
and bus.objid = pgmprm.prog_param2bus_org
and upper(x_program_name) not like '%LIFELINE%'
and nvl(x_prog_class,'NA') <> 'UNLIMITED'
and pgmprm.x_start_date <= sysdate
and pgmprm.x_end_date >= sysdate
and pgmprm.x_type = 'INDIVIDUAL'
union
select 'NTU' bus_org,pgmprm.objid, pgmprm.x_program_name,pgmprm.x_type,pgmprm.x_csr_channel,
PGMPRM.X_WEB_CHANNEL, PGMPRM.X_IVR_CHANNEL,PRICE.X_RETAIL_PRICE
FROM TABLE_BUS_ORG BUS,X_PROGRAM_PARAMETERS PGMPRM,TABLE_X_PRICING PRICE,
table_part_num pn
where 1=1
and pgmprm.prog_param2prtnum_monfee is not null
and price.x_pricing2part_num = pn.objid
and price.x_retail_price > 0
and price.x_end_date > trunc(sysdate)
and price.x_start_date <= trunc(sysdate)
and pn.objid = pgmprm.prog_param2prtnum_monfee
and bus.s_org_id ='NET10'
and bus.objid = pgmprm.prog_param2bus_org
and nvl(x_prog_class,'NA')= 'UNLIMITED'
and pgmprm.x_start_date <= sysdate
and pgmprm.x_end_date >= sysdate
and pgmprm.x_type = 'INDIVIDUAL'
union
select 'TRACFONE' bus_org,pgmprm.objid, pgmprm.x_program_name,pgmprm.x_type,pgmprm.x_csr_channel,
PGMPRM.X_WEB_CHANNEL, PGMPRM.X_IVR_CHANNEL,PRICE.X_RETAIL_PRICE
FROM TABLE_BUS_ORG BUS,X_PROGRAM_PARAMETERS PGMPRM,TABLE_X_PRICING PRICE,
table_part_num pn
where 1=1
and pgmprm.prog_param2prtnum_monfee is not null
and price.x_pricing2part_num = pn.objid
and price.x_retail_price > 0
and price.x_end_date > trunc(sysdate)
and price.x_start_date <= trunc(sysdate)
and pn.objid = pgmprm.prog_param2prtnum_monfee
and bus.s_org_id ='TRACFONE'
and bus.objid = pgmprm.prog_param2bus_org
and nvl(x_prog_class,'NA')<> 'LIFELINE'
and pgmprm.x_start_date <= sysdate
and pgmprm.x_end_date >= sysdate
and pgmprm.x_type = 'INDIVIDUAL'
union
select  'STRAIGHT_TALK' bus_org,pgmprm.objid, pgmprm.x_program_name,pgmprm.x_type,pgmprm.x_csr_channel,
PGMPRM.X_WEB_CHANNEL, PGMPRM.X_IVR_CHANNEL,PRICE.X_RETAIL_PRICE
FROM TABLE_BUS_ORG BUS,X_PROGRAM_PARAMETERS PGMPRM,TABLE_X_PRICING PRICE,
table_part_num pn
where 1=1
and pgmprm.prog_param2prtnum_monfee is not null
and price.x_pricing2part_num = pn.objid
and price.x_retail_price > 0
and price.x_end_date > trunc(sysdate)
and price.x_start_date <= trunc(sysdate)
and pn.objid = pgmprm.prog_param2prtnum_monfee
and bus.s_org_id ='STRAIGHT_TALK'
and bus.objid = pgmprm.prog_param2bus_org
and pgmprm.x_start_date <= sysdate
and pgmprm.x_end_date >= sysdate
and pgmprm.x_type = 'INDIVIDUAL'
and x_is_recurring = 1;