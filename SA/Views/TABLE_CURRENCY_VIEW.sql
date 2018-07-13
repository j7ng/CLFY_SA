CREATE OR REPLACE FORCE VIEW sa.table_currency_view (objid,country,s_country,code,is_default,currency_objid,"NAME",s_name,symbol,description,rate,base_ind,sub_scale) AS
select table_country.objid, table_country.name, table_country.S_name,
 table_country.code, table_country.is_default,
 table_currency.objid, table_currency.name, table_currency.S_name,
 table_currency.symbol, table_currency.description,
 table_currency.conv_rate, table_currency.base_ind,
 table_currency.sub_scale
 from table_country, table_currency
 where table_currency.objid (+) = table_country.country2currency
 ;