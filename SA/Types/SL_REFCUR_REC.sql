CREATE OR REPLACE TYPE sa."SL_REFCUR_REC" FORCE AS OBJECT
(
	PART_NUMBER				VARCHAR2(30),
	pn_desc 				VARCHAR2(255),
	x_retail_price			NUMBER,
	sp_objid				NUMBER(22),
    plan_type       VARCHAR2(50),
	service_plan_group VARCHAR2(50),
	mkt_name				VARCHAR2(50),
	sp_desc					VARCHAR2(250),
	customer_price			NUMBER,
	ivr_plan_id				NUMBER(22),
	webcsr_display_name		VARCHAR2(50),
	x_sp2program_param      NUMBER(22),
	x_program_name         	VARCHAR2(40),
	CYCLE_START_DATE		date,
	CYCLE_END_DATE			date,
	QUANTITY				number,
	COVERAGE_SCRIPT			varchar2(50),
	SHORT_SCRIPT			varchar2(50),
	TRANS_SCRIPT			varchar2(50),
	SCRIPT_TYPE				varchar2(50),
	sl_program_flag 		NUMBER(22),
	enroll_state_full_name	VARCHAR2(80)
)
/