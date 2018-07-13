CREATE OR REPLACE PACKAGE sa."SL_INVOICING" AS
--------------------------------------------------------------------------------------------
--$RCSfile: SL_INVOICING_PKG.sql,v $
--$Revision: 1.2 $
--$Author: mmunoz $
--$Date: 2012/03/28 19:18:45 $
--$ $Log: SL_INVOICING_PKG.sql,v $
--$ Revision 1.2  2012/03/28 19:18:45  mmunoz
--$ Added procedure get_first_last_name
--$
--$ Revision 1.1  2011/12/19 19:44:59  mmunoz
--$ Safelink Invoicing
--$
--------------------------------------------------------------------------------------------
	PROCEDURE get_first_last_name (
	    ip_lid        in  number,
	    ip_Full_Name  in  varchar2,
	    op_first_name out varchar2,
	    op_last_name  out varchar2
	);

	PROCEDURE POPULATE_X_SL_INVOICE(
		p_rowsinserted out number,
		p_batchdate out date
	);

END SL_INVOICING;
/