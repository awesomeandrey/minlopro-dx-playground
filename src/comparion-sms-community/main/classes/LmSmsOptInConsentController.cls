/**
 * This Apex controller is invoked on behalf of Digital Experience Site guest user.
 * 'without sharing' modifier is intentionally used here to allow controlled access to records
 * to capture & process SMS Opt-In consents sent via emails.
 */
public without sharing class LmSmsOptInConsentController {
    @AuraEnabled
    public static OptInConsentResult validateAndCaptureOptInConsent(Id accountId, String codeToVerify) {
        LmSmsEmailService emailService = new LmSmsEmailService();
        try {
            // Verify MAC code;
            // if (!emailService.verifyCode(Blob.valueOf(accountId), codeToVerify)) {
            //                throw new IllegalArgumentException('Verification Error: Code Does Not Match!');
            //            }

            String newAccountNumber = System.now().toString().right(7);
            update new Account(Id = accountId, AccountNumber = newAccountNumber);

            /**
             * TODO - to be implemented as a separate ticket/work item:
             * - find Account by ID
             * - update SMS opt-in status & perform DML
             * - handle additional exceptional scenarios
             */
            return new OptInConsentResult(true, 'The SMS opt-in consent was successfully captured.');
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class OptInConsentResult {
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String message;

        public OptInConsentResult() {
            this.success = false;
            this.message = 'unknown';
        }

        public OptInConsentResult(Boolean success, String message) {
            this();
            this.success = success;
            this.message = message;
        }
    }
}
