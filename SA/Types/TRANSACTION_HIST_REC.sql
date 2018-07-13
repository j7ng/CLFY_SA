CREATE OR REPLACE Type sa.Transaction_Hist_Rec
AS
OBJECT
(
    Call_Trans_Objid                  NUMBER,
    Part_number                       VARCHAR2(30),
    Date_Time                         DATE,
    Action_Text                       VARCHAR2(250),
    X_Min                             VARCHAR2(30),
    X_Esn_Nick_Name                   VARCHAR2(100),
    Service_Plan_Id                   NUMBER,
    Service_Plan_Description1         VARCHAR2(4000),
    Service_Plan_Description2         VARCHAR2(4000),
    Service_Plan_Description3         VARCHAR2(4000),
    Service_Plan_Description4         VARCHAR2(4000),
    Group_ID                          NUMBER,
    Group_Name                        VARCHAR2(200),
    service_plan_short_description    VARCHAR2(4000)  --CR47564 WFM Changes
);
/