CREATE OR REPLACE PACKAGE sa."CARRIER_IS_SWB_RATE_PLAN"
AS

  -- Global Package Variables
  --
  -- l_b_debug BOOLEAN := FALSE;
  --
  -- Public Stored Procedures
  --
--*******************************************************************************************************************
-- Procedure will retrieve the LAST rate plan SENT to the carrier and if the Carrier is Switch Base Or Not for an ESN
--*******************************************************************************************************************
--
PROCEDURE sp_swb_carr_rate_plan (IP_ESN                     IN   VARCHAR2,
                                 OP_LAST_RATE_PLAN_SENT     OUT  TABLE_X_CARRIER_FEATURES.X_RATE_PLAN%TYPE,
                                 OP_IS_SWB_CARR             OUT  VARCHAR2,
                                 OP_ERROR_CODE              OUT  INTEGER,
                                 OP_ERROR_MESSAGE           OUT  VARCHAR2
                                 );
--

--*******************************************************************************************************************
-- Over Loaded Procedure
--*******************************************************************************************************************
--*******************************************************************************************************************
-- Procedure will retrieve the FUTURE/BEST rate plan and if the Carrier is Switch Base Or Not for an ESN
--*******************************************************************************************************************
--
PROCEDURE sp_swb_carr_rate_plan (IP_ESN                     IN   VARCHAR2,
                                 IP_SERVICE_PLAN_ID         IN   NUMBER   DEFAULT NULL,
                                 OP_RATE_PLAN               OUT  TABLE_X_CARRIER_FEATURES.X_RATE_PLAN%TYPE,
                                 OP_IS_SWB_CARR             OUT  VARCHAR2,
                                 OP_ERROR_CODE              OUT  INTEGER,
                                 OP_ERROR_MESSAGE           OUT  VARCHAR2
                                 );

g_carrier_feature_objid NUMBER := NULL; -- CRC87016

--
-- CRC87016 new procedureto get carrier feature id
PROCEDURE get_carrier_feature_id ( i_esn                IN  VARCHAR2            ,
                                   i_service_plan_id    IN  NUMBER DEFAULT NULL ,
                                   o_carrier_feature_id OUT NUMBER              ,
                                   o_response           OUT VARCHAR2            );

END;
/