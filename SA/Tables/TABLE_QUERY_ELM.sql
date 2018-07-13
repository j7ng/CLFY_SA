CREATE TABLE sa.table_query_elm (
  objid NUMBER,
  path_name VARCHAR2(255 BYTE),
  field_name VARCHAR2(80 BYTE),
  oper_id NUMBER,
  oper_name VARCHAR2(25 BYTE),
  field_value VARCHAR2(255 BYTE),
  prompt_ind NUMBER,
  prompt_ind_st VARCHAR2(20 BYTE),
  dev NUMBER,
  query_elm2query NUMBER(*,0),
  query_elm2filterset NUMBER(*,0),
  query_elm2web_filter NUMBER,
  addnl_info VARCHAR2(255 BYTE),
  query_elm2xfilterset NUMBER
);
ALTER TABLE sa.table_query_elm ADD SUPPLEMENTAL LOG GROUP dmtsora603294348_0 (addnl_info, dev, field_name, field_value, objid, oper_id, oper_name, path_name, prompt_ind, prompt_ind_st, query_elm2filterset, query_elm2query, query_elm2web_filter, query_elm2xfilterset) ALWAYS;