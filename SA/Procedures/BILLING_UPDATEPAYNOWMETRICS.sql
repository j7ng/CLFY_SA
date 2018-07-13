CREATE OR REPLACE PROCEDURE sa."BILLING_UPDATEPAYNOWMETRICS"
   (
        p_enroll_objid IN NUMBER,
        op_err          OUT NUMBER,
        op_msg          OUT VARCHAR2
    )
   IS
/*
    This function is used to update a PayNow metrics against a given rule that executed it.
*/
    l_rule_name     varchar2(255);
    l_rule_desc     varchar2(255);
    l_count         NUMBER;

BEGIN
    select x_reason
      into l_rule_name
     from  x_program_enrolled
     where objid = p_enroll_objid;

     --- Parse string to have Rule Name and Rule Description.
     l_rule_desc := substr(l_rule_name,instr(l_rule_name,';')+1);
     l_rule_name := substr(l_rule_name, 1, instr(l_rule_name,';')-1 );

     dbms_output.put_line( l_rule_name || '----------------' || l_rule_desc);



     --- Check if the reason already exists in the metrics table.
     select count(*)
     into   l_count
     from   x_metrics_rule_engine_call
     where  X_RULE_CATEGORY = 'PayNow Rules'
      and   X_RULE_SET_NAME = l_rule_name
      and   x_rule_set_desc = l_rule_desc
      and   rownum < 2;

     ----------- Row exists in the table. Insert a new record. ------------------------------
     if ( l_count > 0 ) then
        insert into x_metrics_rule_engine_call (
                objid,
                x_call_date,
                x_rule_category,
                x_rule_set_name,
                X_RULE_SET_DESC,
                x_paynow_exec_flag
            )
         values
            (
                BILLING_SEQ('X_METRICS_RULE_ENGINE_CALL'),
                sysdate,
                'PayNow Rules',
                l_rule_name,
                l_rule_desc,
                1
            );
         commit;
    end if;

     op_err := 0;   --Success
     op_msg := 'Success';

     ----------------------------------------------------------------------------------------
EXCEPTION
    WHEN OTHERS THEN
        op_err  := -100;
        op_msg  := SQLERRM;
END; -- Procedure billing_runtimepromo
/