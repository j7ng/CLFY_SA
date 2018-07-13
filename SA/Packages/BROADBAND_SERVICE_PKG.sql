CREATE OR REPLACE PACKAGE sa.BROADBAND_SERVICE_PKG AS
PROCEDURE VALIDATE_VENDOR
            ( P_VENDOR_ID                   IN      	VARCHAR2,
              P_VENDOR_NAME                IN      	VARCHAR2,
              p_is_successful                     out   	number);

PROCEDURE MONEYTRANSFER
        (P_REQUEST_TYPE                   IN      	VARCHAR2,
           P_MIN                         	IN      	VARCHAR2,
           P_PAYCODE                        IN      	NUMBER,
           P_DENOMINATION                   IN        NUMBER,
           P_REFER                          IN        VARCHAR2,
           P_FIRST_NAME_S                   IN       VARCHAR2,
           P_LASTNAME_S                     IN       VARCHAR2,
           P_ADDRESS_S                      IN       VARCHAR2,
           P_CITY_S                         IN        VARCHAR2,
           P_STATE_S                        IN         VARCHAR2,
           P_COUNTRY_S                      IN        VARCHAR2,
           P_ZIP_S                          IN        VARCHAR2,
           P_PHONE_S                        IN         VARCHAR2,
           P_ERROR_CODE                  		OUT   	  NUMBER,
           P_ERROR_MSG                   		OUT     	VARCHAR2,
           P_MG_VALID                       OUT       VARCHAR2,
           P_MG_RESPONSE_CODE               OUT       VARCHAR2,
           P_MG_ERROR_MSG                   OUT       VARCHAR2,
           P_TF_REF_NO                      OUT       VARCHAR2);

PROCEDURE VALIDATE_DENOCODE
          (P_PAYCODE                      IN      	VARCHAR2,
           P_DENOMINATION                 IN      	NUMBER,
           P_RECEIVE_CODE                 IN        VARCHAR2,
           P_ERROR_CODE                  	OUT     	NUMBER,
           p_error_msg                   	OUT     	Varchar2);

PROCEDURE CREATE_ACCOUNT
          (P_LID                          IN      	VARCHAR2,
           P_CONTACT_OBJID                IN      	number,
           P_NEW_CONTACT_OBJID            OUT       NUMBER,
           P_ERROR_CODE                  	OUT     	NUMBER,
           P_ERROR_MSG                   	OUT     	VARCHAR2);

PROCEDURE  ADD_ESN_TO_MYACCOUNT
          (P_ESN                          IN      	VARCHAR2,
           P_CONTACT                      IN        number,
           P_ERROR_CODE                  	OUT     	NUMBER,
           P_ERROR_MSG                   	OUT     	VARCHAR2);

PROCEDURE  BB_ENROLLMENT
           (P_esn                        IN      	VARCHAR2,
            P_PROGRAM_NAME               IN      	VARCHAR2,
            p_contact                    in       number,
            P_ERROR_CODE                 OUT     	NUMBER,
            P_ERROR_MSG                  OUT     	VARCHAR2);

PROCEDURE  CREATE_TICKET
           (P_MIN                        IN      	VARCHAR2,
            P_ESN                        IN      	VARCHAR2,
            p_contact_objid              IN       number,
            P_PHONE_PART                 IN       VARCHAR2,
            P_CARD_PART                  IN       VARCHAR2,
            P_NEW_CONTACT_OBJID          IN       NUMBER, -- Ramu 05/07/2013
            p_case_ID                    out      NUMBER,
            P_ERROR_CODE                 OUT     	NUMBER,
            P_ERROR_MSG                  OUT     	VARCHAR2);

PROCEDURE  INITIAL_BB
           (P_LID                        IN      	 VARCHAR2,
            P_ESN                        IN      	 VARCHAR2,
            P_MIN                        IN        varchar2,
            P_PHONE_PART                 IN        VARCHAR2,
            P_CARD_PART                  IN        VARCHAR2,
            P_CONTACT_OBJID              IN        NUMBER,
            P_CASE_ID                    OUT       NUMBER,
            P_ERROR_CODE                OUT NUMBER,
            P_ERROR_MSG             out varchar2);

PROCEDURE REFILL_BB
          (P_ESN                  IN  VARCHAR2,
           P_PART_NUM_PIN           IN VARCHAR2,
           P_SOURCESYSTEM           IN  VARCHAR2, ---default WEB
           P_AMOUNT                 IN  NUMBER,
           p_X_SMP                  out varchar2,
           P_ERROR_CODE             OUT NUMBER,
           p_error_message          out varchar2);

PROCEDURE BB_RECURRING
           (P_ESN                        IN          VARCHAR2,
            P_PROGRAM_NAME               IN          varchar2,
            P_ERROR_CODE                 OUT         NUMBER,
            P_ERROR_MSG                  OUT         VARCHAR2);
--CR39488
 PROCEDURE sp_get_pin_info(
             ip_tf_mg_ref IN  VARCHAR2,
             ip_min       IN  VARCHAR2,
             op_red_pin   OUT NUMBER,
             op_zip       OUT VARCHAR2,
             op_esn       OUT VARCHAR2,
             op_iccid     OUT VARCHAR2,
	     op_contact_objid OUT NUMBER,
             op_err_num   OUT NUMBER,
             op_err_msg   OUT VARCHAR2 );

END BROADBAND_SERVICE_PKG;
/