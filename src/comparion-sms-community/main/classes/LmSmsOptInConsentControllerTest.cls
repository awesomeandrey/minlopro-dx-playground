@IsTest
private class LmSmsOptInConsentControllerTest {
    @IsTest
    static void testValidateAndCaptureOptInConsent_InvalidCode() {
        Exception caughtException = null;
        try {
            LmSmsOptInConsentController.validateAndCaptureOptInConsent(UserInfo.getUserId(), 'invalid_mac_code');
        } catch (Exception ex) {
            caughtException = ex;
        }
        Assert.isNotNull(caughtException, 'Exception should have been caught.');
        Assert.areEqual(AuraHandledException.class.getName(), caughtException.getTypeName());
    }
}
