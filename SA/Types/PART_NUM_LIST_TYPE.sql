CREATE OR REPLACE TYPE sa.part_num_list_type AS OBJECT
/*************************************************************************************************************************************
--$RCSfile: PART_NUM_LIST_TYPE.sql,v $
--$ $Log: PART_NUM_LIST_TYPE.sql,v $
--$ Revision 1.1  2017/09/19 18:47:32  sgangineni
--$ CR48260 (SM MLD) - PART_NUM_LIST_TYPE initial version
--$
--$
*
* CR48260 - PART_NUM_LIST_TYPE.
*
*************************************************************************************************************************************/

(
source_part_num               VARCHAR2(100),
source_part_part_class        VARCHAR2(100),
target_part_num               VARCHAR2(100),
target_part_class              VARCHAR2(100)
);
/