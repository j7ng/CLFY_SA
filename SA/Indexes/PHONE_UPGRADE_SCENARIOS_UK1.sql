CREATE UNIQUE INDEX sa.phone_upgrade_scenarios_uk1 ON sa.phone_upgrade_scenarios(brand,from_phone_short_parent,from_phone_device_type,to_phone_short_parent,to_phone_device_type,billing_plan,channel);