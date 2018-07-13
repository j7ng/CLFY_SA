CREATE OR REPLACE PACKAGE sa.process_order_pkg
AS
PROCEDURE process_order_insert( op_process_order_type IN OUT PROCESS_ORDER_TYPE,
                                o_err_code OUT VARCHAR2,
                                o_err_msg OUT VARCHAR2);

PROCEDURE process_order_update( op_process_order_type IN OUT PROCESS_ORDER_TYPE,
                                o_err_code OUT VARCHAR2,
                                o_err_msg OUT VARCHAR2);

PROCEDURE process_order_retrieve( op_process_order_type IN OUT PROCESS_ORDER_TYPE,
                                o_err_code OUT VARCHAR2,
                                o_err_msg OUT VARCHAR2);

PROCEDURE process_order_retrieve( op_process_order_type_tab IN OUT process_order_type_tab,
                                o_err_code OUT VARCHAR2,
                                o_err_msg OUT VARCHAR2);
END process_order_pkg;
/