CREATE OR REPLACE FORCE VIEW sa.table_busorg_quote_v (objid,"ID",s_id,amount,title,s_title,start_date,issue_dt,end_date,status,bus_objid,struct_type) AS
select table_contract.objid, table_contract.id, table_contract.S_id,
 table_contract.total_net, table_contract.title, table_contract.S_title,
 table_contract.q_start_date, table_contract.q_issue_dt,
 table_contract.q_end_date, table_contract.status,
 table_contract.sell_to2bus_org, table_contract.struct_type
 from table_contract
 where table_contract.sell_to2bus_org IS NOT NULL
 ;
COMMENT ON TABLE sa.table_busorg_quote_v IS 'Displays quotes for a bus_org. Used by form Quotes (8525), Account Edit (8521) and Opportunities (8526)';
COMMENT ON COLUMN sa.table_busorg_quote_v.objid IS 'internal record number of the quote';
COMMENT ON COLUMN sa.table_busorg_quote_v."ID" IS 'Contract ID number';
COMMENT ON COLUMN sa.table_busorg_quote_v.amount IS 'Total net price for the quote';
COMMENT ON COLUMN sa.table_busorg_quote_v.title IS 'Title of the quote';
COMMENT ON COLUMN sa.table_busorg_quote_v.start_date IS 'The start date for the quote. This is the date the offer becomes effective';
COMMENT ON COLUMN sa.table_busorg_quote_v.issue_dt IS 'The date the quote was issued to the prospect';
COMMENT ON COLUMN sa.table_busorg_quote_v.end_date IS 'The end date for the quote. This is the last date the offer is effective';
COMMENT ON COLUMN sa.table_busorg_quote_v.status IS 'Status of the quote from a user-defined pop-up list';
COMMENT ON COLUMN sa.table_busorg_quote_v.bus_objid IS 'Business organization internal record number';
COMMENT ON COLUMN sa.table_busorg_quote_v.struct_type IS 'Type of contract/quote structure of the object; i.e., 0=service contract, 1=sales item';