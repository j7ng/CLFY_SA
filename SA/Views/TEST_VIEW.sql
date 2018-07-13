CREATE OR REPLACE FORCE VIEW sa.test_view (col1) AS
select
'a' col1 from dual
union
select 'b' col1 from dual
;