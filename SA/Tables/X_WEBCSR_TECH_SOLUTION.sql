CREATE TABLE sa.x_webcsr_tech_solution (
  x_esn VARCHAR2(30 BYTE),
  x_solving_agent VARCHAR2(20 BYTE),
  x_date_solution DATE,
  x_date_problem DATE,
  x_solution VARCHAR2(200 BYTE),
  x_counter NUMBER,
  x_previous_agents VARCHAR2(200 BYTE)
);
ALTER TABLE sa.x_webcsr_tech_solution ADD SUPPLEMENTAL LOG GROUP dmtsora2038280327_0 (x_counter, x_date_problem, x_date_solution, x_esn, x_previous_agents, x_solution, x_solving_agent) ALWAYS;