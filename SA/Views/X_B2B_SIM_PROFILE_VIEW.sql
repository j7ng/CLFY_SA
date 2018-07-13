CREATE OR REPLACE FORCE VIEW sa.x_b2b_sim_profile_view (pref_sim_profile,pref_zip) AS
select sim_profile pref_sim_profile,zip pref_zip
from carrierpref a,carrierzones b
where a.carrier_id = b.carrier_id
and a.st = b.st
and a.county = b.county
and sim_profile is not null
order by new_rank;