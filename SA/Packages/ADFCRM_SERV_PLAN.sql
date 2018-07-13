CREATE OR REPLACE PACKAGE sa."ADFCRM_SERV_PLAN" AS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_SERV_PLAN_PKG.sql,v $
--$Revision: 1.4 $
--$Author: pkapaganty $
--$Date: 2018/01/11 22:42:08 $
--$ $Log: ADFCRM_SERV_PLAN_PKG.sql,v $
--$ Revision 1.4  2018/01/11 22:42:08  pkapaganty
--$ CR50452 Net 10 Remove Service for Refunds SmartPhone
--$
--$ Revision 1.3  2014/11/13 17:29:56  mmunoz
--$ added function getServPlanGroupType
--$
--$ Revision 1.2  2014/11/12 17:23:51  mmunoz
--$ Added procedure getservplangrouptype
--$
--$ Revision 1.1  2014/09/15 14:40:27  mmunoz
--$ TAS_2014_09 To Improve performance.
--$
--------------------------------------------------------------------------------------------
/***** EXTERNAL TYPES USED IN THIS PACKAGES
TYPE sa.varcharArray IS VARRAY(1000) OF VARCHAR2(100);

TYPE SA.VARCHAR_REC IS OBJECT (
    KEYNAME   VARCHAR2(100),
    KEYVALUE  VARCHAR2(4000)
    );

TYPE sa.varcharRecList is VARRAY(1000) OF varchar_rec;
******************************************************************/
TYPE this_varchar_rec is RECORD (
    keyName   VARCHAR2(100),
    keyValue  VARCHAR2(4000)
    );

TYPE varcharRecTable is TABLE OF this_varchar_rec;

/*****************  GET ALL OR A LIST OF SERVICE PLAN FEATURES ********************/
FUNCTION  getfeatures(
   ip_esn IN VARCHAR2,
   ip_plan_objid IN varchar2,
   ip_pin_pclass in varchar2,
   ip_array in sa.varcharArray,
   ip_language in varchar2
)
RETURN sa.varcharRecList;

/*****************  GET SERVICE PLAN GROUP TYPE ********************/
PROCEDURE getServPlanGroupType(
   ip_plan_objid IN varchar2,
   op_sp_mkt_name out varchar2,
   op_feat_sp_group out varchar2,
   op_plan_group out varchar2
);

/*****************  GET SERVICE PLAN GROUP TYPE ********************/
function getServPlanGroupType(
   ip_plan_objid  varchar2
) return varchar2;

FUNCTION getCurrentServPlanGrpIDByESN( in_esn VARCHAR2)
  RETURN VARCHAR2;

END ADFCRM_SERV_PLAN;
/