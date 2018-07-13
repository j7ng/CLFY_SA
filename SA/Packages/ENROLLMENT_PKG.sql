CREATE OR REPLACE PACKAGE sa."ENROLLMENT_PKG"
IS
/*******************************************************************************************************
  --$RCSfile: enrollment_pkg.sql,v $
  --$Revision: 1.9 $
  --$Author: skambhammettu $
  --$Date: 2017/10/06 20:14:18 $
  --$ $Log: enrollment_pkg.sql,v $
  --$ Revision 1.9  2017/10/06 20:14:18  skambhammettu
  --$ CR53217--additional parameter in get_discount_flag
  --$
  --$ Revision 1.7  2016/09/08 16:01:57  vlaad
  --$ Added dataclub flag
  --$
  --$ Revision 1.5  2015/01/28 22:36:42  gsaragadam
  --$ CR31683 Attaching latest Package Spec
  --$
  --$ Revision 1.4  2014/04/18 20:20:02  cpannala
  --$ CR25490 switch plan procedure added
  --$
  --$ Revision 1.2  2014/02/05 16:08:23  cpannala
  --$ CR25490 GETENROLLMENTDETAILS procedure addedd
  --$
  --$ Revision 1.1  2013/12/05 16:22:36 cpannala
  --$ CR22623 - B2B Initiative
  --$Description:
-----------------------------------------------------------------------------------------------------
*******************************************************************************************************/
PROCEDURE post_activation_enrollment(
    op_result OUT VARCHAR2,
    op_msg OUT VARCHAR2,
    P_ESN IN VARCHAR2);
  ----
PROCEDURE GETENROLLMENTDETAILS(
    IN_ESN IN VARCHAR2,
    OUT_PLAN_LIST OUT PLAN_LIST_TBL,
    OUT_ERR_NUM OUT NUMBER,
    OUT_ERR_MSG OUT VARCHAR2);
  ---
PROCEDURE DEENROLLFROMPLAN(
    IN_ESN           IN VARCHAR2 ,
    IN_PLANID        IN NUMBER ,
    in_deenroll_DATE IN DATE DEFAULT NULL ,
    IN_REASON        IN VARCHAR2 ,
    OP_ERR_NUM OUT NUMBER ,
    OP_ERR_MSG OUT VARCHAR2 );
 --
PROCEDURE switch_plan(
    in_esn              IN VARCHAR2,--table_part_inst.part_serial_no
    in_src_enrl_plan_id IN NUMBER,--x_program_parameters.objid
    io_dst_enrl_plan_id IN OUT NUMBER,--x_program_parameters.objid
    in_src_part_num     IN VARCHAR2, --x_ff_part_num_mapping.x_source_part_num
    io_dst_part_num     IN out VARCHAR2,--x_ff_part_num_mapping.x_source_part_num
    in_cycle_start_date IN OUT DATE,--x_program_parameters.x_next_charge_date
    out_err_num OUT NUMBER,
    out_err_msg OUT VARCHAR2);
---
-- Clearway Connected Products - Added new procedure for add on DATA card VL 07/26/2016
---
PROCEDURE add_dataclub_addon_card(
    in_esn              in varchar2,
    in_enrl_plan_id     in number,
    in_enrl_partnum     in varchar2,
    in_cycle_start_date in out date,
    in_isenrolled       in varchar2,
    in_autorefill_limit in number,
    out_err_num         out number,
    out_err_msg         out varchar2);

PROCEDURE get_discount_flag(
    i_esn             IN VARCHAR2,
    i_service_plan_id IN x_service_plan.OBJID%TYPE,
    i_part_num IN table_part_num.s_part_number%TYPE,
    o_discount_flag OUT VARCHAR2,
    o_is_family_plan OUT VARCHAR2,
    o_err_num OUT NUMBER,
    o_err_string OUT VARCHAR2);

END enrollment_pkg;
-- ANTHILL_TEST PLSQL/SA/Packages/enrollment_pkg.sql 	CR53217: 1.9
/