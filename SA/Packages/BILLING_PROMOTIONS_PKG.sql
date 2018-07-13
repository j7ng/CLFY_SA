CREATE OR REPLACE PACKAGE sa."BILLING_PROMOTIONS_PKG"
  IS

/*************************************************************************************************/
/*                                                                                               */
/* Name         :   BILLING_PROMOTIONS_PKG.BILLING_NT100_RNTIME_ELIGIBLE                         */
/*                                                                                               */
/* Purpose      :   To return the Eligibility status of NT 100 100 100 Delivery                  */
/*                                                                                               */
/*                                                                                               */
/* Platforms    :   Oracle 9i                                                                    */
/*                                                                                               */
/* Author       :   Ramu                                                                         */
/*                                                                                               */
/* Date         :   09-11-2007                                                                   */
/* REVISIONS:                                                                                    */
/* VERSION  DATE        WHO          PURPOSE                                                     */
/* -------  ----------  -----        --------------------------------------------                */
/*  1.0     09-11-2007  Ramu         Initial  Revision (CR6586)                                  */
/*  1.2     08-16-2011  kacosta    CR16038 NET10_AAA_PLANS  CR16275 TF_AAA-NEW PLANS            */
/*                                 Created get_esn_dealer_program_promo function			     	*/
/* 1.6		03-27-2017   mdave     CR48383 (3X removal TracFone) Changes to block triple benefits */
/*									for TF smartphones released after 4/4/17. 				     */
/*************************************************************************************************/
  FUNCTION BILLING_NT100_RNTIME_ELIGIBLE
     ( p_esn                IN VARCHAR2
     )
     RETURN  NUMBER;

/*************************************************************************************************/
/*                                                                                               */
/* Name         :   BILLING_PROMOTIONS_PKG.BILLING_NT100_RNTIME_PROMO                            */
/*                                                                                               */
/* Purpose      :   To Deliver the promotion Minutes if Eligibile in  NT 100 100 100             */
/*                                                                                               */
/*                                                                                               */
/* Platforms    :   Oracle 9i                                                                    */
/*                                                                                               */
/* Author       :   Ramu                                                                         */
/*                                                                                               */
/* Date         :   09-11-2007                                                                   */
/* REVISIONS:                                                                                    */
/* VERSION  DATE        WHO          PURPOSE                                                     */
/* -------  ----------  -----        --------------------------------------------                */
/*  1.0     09-11-2007  Ramu         Initial  Revision (CR6586)                                  */
/*                                                                                               */
/*                                                                                               */
/*************************************************************************************************/
  PROCEDURE    BILLING_NT100_RNTIME_PROMO (
    p_esn           IN       VARCHAR2, -- ESN
    p_objid         IN       NUMBER, -- Call Trans objid
    op_units        OUT      NUMBER, -- Runtime Units
    op_msg          OUT      VARCHAR2, -- Output Message
    op_status       OUT      VARCHAR2 -- Output Status S = Success, F = Failed
                                           -- N = Not Eligible
    );
  --
  --*********************************************************************************
  -- Function to retreive ESN dealer promo based on program
  --*********************************************************************************
  --
  FUNCTION get_esn_dealer_program_promo
  (
    p_esn                      table_part_inst.part_serial_no%TYPE
   ,p_promo_type               table_x_promotion.x_promo_type%TYPE
   ,p_source_system            table_x_promotion.x_source_system%TYPE
   ,p_program_parameters_objid x_program_parameters.objid%TYPE
   ,p_debug                    BOOLEAN DEFAULT FALSE
  ) RETURN table_x_promotion.x_promo_code%TYPE;
  --


  --*********************************************************************************
  -- /* Procedure to get converted units for a Service Plan */
  --*********************************************************************************
  PROCEDURE get_benefits_by_units (
        in_total_units      IN     NUMBER,
        in_total_days       IN     NUMBER,
        in_service_plan     IN     x_service_plan.objid%TYPE,
        out_voice_units         OUT NUMBER,
        out_days_units          OUT NUMBER,
        out_text_units          OUT NUMBER,
        out_data_units          OUT NUMBER,
        out_errorcode           OUT VARCHAR2,
        out_errormsg            OUT VARCHAR2,
		in_esn 			    IN sa.TABLE_PART_INST.PART_SERIAL_NO%type default null --CR48383 mdave 03272017
		);


PROCEDURE get_benefits_by_program (
	in_esn			IN  table_part_inst.part_serial_no%TYPE,
        in_bill_prog_objid	IN  x_program_parameters.objid%type,
        out_voice_units         OUT NUMBER,
        out_days_units          OUT NUMBER,
        out_text_units          OUT NUMBER,
        out_data_units          OUT NUMBER,
        out_errorcode           OUT VARCHAR2,
        out_errormsg            OUT VARCHAR2);


END; -- Package Specification BILLING_PROMOTIONS_PKG
/