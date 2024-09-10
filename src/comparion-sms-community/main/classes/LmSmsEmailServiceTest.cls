@IsTest
private class LmSmsEmailServiceTest {
    @IsTest
    static void testGenerateAndVerifyCode() {
        LmSmsEmailService service = new LmSmsEmailService();
        Blob content = Blob.valueOf('TestContent1');
        String code = service.generateCode(content);
        Assert.isNotNull(code);
        Assert.areNotEqual(content.toString(), code);
        Assert.isTrue(service.verifyCode(content, code));
        Assert.isFalse(service.verifyCode(Blob.valueOf('TestContent2'), code));
    }

    @IsTest
    static void testResolveOptInConsentLink() {
        LmSmsEmailService service = new LmSmsEmailService();
        List<Network> allNetworks = [SELECT Id, Name, UrlPathPrefix FROM Network WHERE Name = :service.EXPERIENCE_SITE_NAME];
        Assert.isFalse(allNetworks.isEmpty(), 'Digital Experience Site was not found.');
        Network siteNetwork = allNetworks[0];
        Url optInLink = new Url(service.resolveOptInConsentLink()); // If no exception is thrown, it's a valid URL;
        Assert.isTrue(optInLink.toExternalForm().contains(siteNetwork.UrlPathPrefix));
        Assert.isTrue(optInLink.toExternalForm().endsWith(service.EXPERIENCE_SITE_PAGE_SUFFIX));
    }
}
