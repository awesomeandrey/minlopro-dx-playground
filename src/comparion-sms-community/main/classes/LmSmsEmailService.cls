public inherited sharing class LmSmsEmailService {
    @TestVisible
    private final String EXPERIENCE_SITE_NAME = 'Comparion CRM'; // Digital Experience Site API name;
    @TestVisible
    private final String EXPERIENCE_SITE_PAGE_SUFFIX = 'sms-opt-in-consent'; // Custom page URL suffix that captures & processes opt-in requests;

    /**
     * @description Generates a HMAC SHA-256 based code for the given content using a private key. The generated code is in hexadecimal format.
     * @param content The Blob content (e.g. Account ID) for which the HMAC code needs to be generated.
     * @return A String representing the generated HMAC code in hexadecimal format.
     */
    public String generateCode(Blob content) {
        final String PRIVATE_KEY = 'salesforce_rocks!'; // TODO - to embed into secret & configure SFDX replacement;
        Blob mac = Crypto.generateMac('hmacSHA256', content, Blob.valueOf(PRIVATE_KEY));
        return EncodingUtil.convertToHex(mac);
    }

    /**
     * @description Verifies the provided code by generating an HMAC SHA-256 code for the given content and comparing it with the provided code.
     * @param content The Blob content for which the HMAC code needs to be verified.
     * @param codeToCheck The HMAC code that needs to be verified against the generated code.
     * @return A Boolean value indicating whether the provided code matches the generated HMAC code.
     */
    public Boolean verifyCode(Blob content, String codeToCheck) {
        String computedSignature = this.generateCode(content);
        return codeToCheck.equals(computedSignature);
    }

    /**
     * @description Generates a URL for an opt-in consent page within a specific Experience Cloud site. The method constructs the URL based on the site name and a predefined page path.
     * @return A String representing the full URL to the opt-in confirmation page within the specified Experience Cloud site.
     */
    public String resolveOptInConsentLink() {
        Network siteNetwork = [SELECT Id, UrlPathPrefix FROM Network WHERE Name = :this.EXPERIENCE_SITE_NAME LIMIT 1];
        String siteBaseUrl = Network.getLoginUrl(siteNetwork.Id).removeEnd('/login');
        return String.format('{0}/{1}', new List<String>{ siteBaseUrl, this.EXPERIENCE_SITE_PAGE_SUFFIX });
    }
}
