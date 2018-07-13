CREATE OR REPLACE PROCEDURE sa."BILLING_CANENROLL" (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   billing_canenroll                                                   */
/*                                                                                            */
/* Purpose      :   Validation for ESN enrollment                                    */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*  1.1                 RVurimi      CR7326 changes                                           */
/*                                                                                            */
/*************************************************************************************************/
   p_web_user            IN       NUMBER,                       -- Web User Id
   p_esn                 IN       VARCHAR2,
   -- ESN Number attempting the enrollment
   p_program_to_enroll   IN       NUMBER,  -- program objid in which to enroll
   o_err_num             OUT      NUMBER,
   op_err_msg            OUT      VARCHAR2
)
IS
BEGIN
   /* Error Codes:
         7501            : 'Your previous enrollment is still pending. You cannot enroll into the new program'
         7502            : 'You are already enrolled into this program'
         7503            : 'This is not a permitted group configuration. It is a "combine with self" and "Group"'
         7504            : 'This program cannot be combined with any other program'
         7505            : 'This program cannot be combined with any other program in the list'
         7506            : 'Primary phone for the group is not in valid "Enrolled" status'
         7507            : 'Max number of addtional phones reached. Cannot Enroll
         7508            : 'Additional phone not in the enrollment window'
         7509            : 'Max number of combinable with self reached. Cannot Enroll'
         7510            : This additional phone cannot be enrolled at this time.  The customer may call to enroll 3 days before or 3 days after their next payment.
         7511            : 'This ESN is still receiving benefits. Cannot enroll'
         7512            :  This ESN is not enrolled in any ValuePlan/ Autopay. Cannot Enroll
         7513            :  This ESN is not enrolled in Unlimited Plan. Cannot Enroll
         7514            :  This ESN is still receiving NET10 Unlimited plan benefits. Cannot Enroll
            1            : 'Primary phone for the group is not available. Add this phone as primary'
            1            : 'OK to enroll as primary (first enrollment)'
            2            : 'OK to enroll as primary (second enrollment)'
            3            : 'Primary phone for the group is "Enrolled" status. Add this phone as secondary. This is after the cycle date'
            4            : 'Primary phone for the group is "Enrolled" status. Add this phone as secondary. This is before the cycle date'
     */
   -- Just call the can enroll proceedure.
   o_err_num := canenroll (p_web_user, p_esn, p_program_to_enroll, 1);

   IF (o_err_num = 7501)
   THEN
      op_err_msg :=
         'Your previous enrollment is still pending. You cannot enroll into the new program';
   ELSIF (o_err_num = 7502)
   THEN
      op_err_msg := 'You are already enrolled into this program';
   ELSIF (o_err_num = 7503)
   THEN
      op_err_msg :=
         'This is not a permitted group configuration. It is a "combine with self" and "Group"';
   ELSIF (o_err_num = 7504)
   THEN
      op_err_msg := 'This program cannot be combined with any other program';
   ELSIF (o_err_num = 7505)
   THEN
      op_err_msg :=
         'This program cannot be combined with any other program in the list';
   ELSIF (o_err_num = 7506)
   THEN
      op_err_msg :=
              'Primary phone for the group is not in valid "Enrolled" status';
   ELSIF (o_err_num = 7507)
   THEN
      op_err_msg := 'Max number of addtional phones reached. Cannot Enroll';
   ELSIF (o_err_num = 7508)
   THEN
      op_err_msg := 'Additional phone not in the enrollment window';
   ELSIF (o_err_num = 7509)
   THEN
      op_err_msg :=
                 'Max. number of combinable with self reached. Cannot Enroll';
   ELSIF (o_err_num = 7510)
   THEN
      op_err_msg :=
         'Unable to determine the program enrollment parameter for additional phone enrollment';
   ELSIF (o_err_num = 7511)
   THEN
      op_err_msg :=
         'This ESN is still receiving benefits of previous enrollment. Cannot Enroll';
   ELSIF (o_err_num = 7512)
   THEN
      op_err_msg :=
                'This ESN is not enrolled in any Monthly plan. Cannot Enroll';
   ELSIF (o_err_num = 7513)
   THEN
      op_err_msg :=
                  'This ESN is not enrolled in Unlimited plan. Cannot Enroll';
   ELSIF (o_err_num = 7514)
   THEN
      op_err_msg :=
         'This ESN is still receiving Unlimited plan benefits. Cannot Enroll';
   ELSIF (o_err_num = 1)
   THEN
      op_err_msg := 'OK to enroll as primary (first enrollment)';
   ELSIF (o_err_num = 2)
   THEN
      op_err_msg :=
         'OK to enroll as primary (second enrollment). Program is combinable with self.';
   ELSIF (o_err_num = 3)
   THEN
      op_err_msg :=
         'Primary phone for the group is "Enrolled" status. Add this phone as secondary. This is after the cycle date';
   ELSIF (o_err_num = 1)
   THEN
      op_err_msg :=
         'Primary phone for the group is "Enrolled" status. Add this phone as secondary. This is before the cycle date';
   ELSE
      op_err_msg := 'Unknown database error has occurred';
   END IF;
-- Put in the values into the output variables.
EXCEPTION
   WHEN OTHERS
   THEN
      o_err_num := -100;
      op_err_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
END billing_canenroll;                                   -- Function CANENROLL
/