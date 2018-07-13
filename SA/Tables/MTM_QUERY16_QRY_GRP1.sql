CREATE TABLE sa.mtm_query16_qry_grp1 (
  query2qry_grp NUMBER(*,0) NOT NULL,
  qry_grp2query NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_query16_qry_grp1 ADD SUPPLEMENTAL LOG GROUP dmtsora613331120_0 (qry_grp2query, query2qry_grp) ALWAYS;