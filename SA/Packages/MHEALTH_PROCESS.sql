CREATE OR REPLACE PACKAGE sa.MHEALTH_PROCESS AS
--------------------------------------------------------------------------------------------
--$RCSfile: MHEALTH_PROCESS_PKG.sql,v $
--$Revision: 1.1 $
--$Author: mmunoz $
--$Date: 2012/05/03 20:25:23 $
--$ $Log: MHEALTH_PROCESS_PKG.sql,v $
--$ Revision 1.1  2012/05/03 20:25:23  mmunoz
--$ CR20202
--$
--------------------------------------------------------------------------------------------
    PROCEDURE GET_CUST_FREE_DIAL (
        ip_esn      IN  sa.table_part_inst.part_serial_no%type,
        op_phone    OUT sa.table_site.phone%type
    );

    PROCEDURE GET_CUST_FAVORED_SMS (
        IP_ESN      IN  sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE,
        op_plan_id  OUT sa.table_x_click_plan.objid%type
    );
END;
/