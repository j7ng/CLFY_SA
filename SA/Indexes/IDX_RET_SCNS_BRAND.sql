CREATE UNIQUE INDEX sa.idx_ret_scns_brand ON sa.x_retention_scenarios(x_src_service_plan_grp,x_dest_service_plan_grp,x_ret_scn2bus_org);