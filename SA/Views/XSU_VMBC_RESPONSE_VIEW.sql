CREATE OR REPLACE FORCE VIEW sa.xsu_vmbc_response_view ("responseTo","requestId","lid","enrollRequest","errorCode","errorMsg","activateDate","phoneEsn","phoneNumber","trackingNumber","ticketNumber",batchdate) AS
SELECT RESPONSETO "responseTo",
          REQUESTID "requestId",
          LID "lid",
          ENROLLREQUEST "enrollRequest",
          ERRORCODE "errorCode",
          ERRORMSG "errorMsg",
          ACTIVATEDATE "activateDate",
          PHONEESN "phoneEsn",
          PHONENUMBER "phoneNumber",
          TRACKINGNUMBER "trackingNumber",
          TICKETNUMBER "ticketNumber",
          BATCHDATE BATCHDATE
     FROM sa.XSU_VMBC_RESPONSE
	 WHERE (data_source = 'VMBC'	OR data_source IS NULL)	--CR38122
	 ;