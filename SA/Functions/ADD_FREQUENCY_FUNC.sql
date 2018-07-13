CREATE OR REPLACE FUNCTION sa."ADD_FREQUENCY_FUNC" (
   ip_part_number   IN   VARCHAR2
)
   RETURN BOOLEAN
IS

cursor c1 is
select objid
from sa.table_part_num
where part_number = ip_part_number
and objid not in (select PART_NUM2X_FREQUENCY
                  from sa.MTM_PART_NUM14_X_FREQUENCY0);

begin

for r1 in c1 loop

insert into sa.MTM_PART_NUM14_X_FREQUENCY0 mtm
(mtm.PART_NUM2X_FREQUENCY,mtm.X_FREQUENCY2PART_NUM)
values (r1.objid,268435459);

insert into sa.MTM_PART_NUM14_X_FREQUENCY0 mtm
(mtm.PART_NUM2X_FREQUENCY,mtm.X_FREQUENCY2PART_NUM)
values (r1.objid,268435460);

commit;

end loop;

return true;

end;
/