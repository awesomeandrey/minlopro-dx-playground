public with sharing class AuthProviderPluginsPlayground {
    private final static String API_VERSION = '58.0';

    /**
     * Authentication is handled by custom Auth. Provider plugins.
     */
    public void runAll() {
        this.runClientCredentialsFlow();
        this.runWedServerWithPkceFlow();
        this.runJwtFlow();
    }

    public void runClientCredentialsFlow() {
        this.run('OAuth 2.0 Client Credentials Flow', 'SalesforceRestApi');
    }

    public void runWedServerWithPkceFlow() {
        this.run('OAuth 2.0 Web Server With PKCE Flow', 'SalesforceRestApi2');
    }

    public void runJwtFlow() {
        this.run('OAuth 2.0 JWT Bearer Flow', 'SalesforceRestApi3');
    }

    private void run(String oauthFlowToTest, String namedCredentialApiName) {
        Integer currentCalloutsConsumed = Limits.getCallouts();
        try {
            // Prepare HTTP request;
            HttpRequest req = new HttpRequest();
            String encodedQuery = EncodingUtil.urlEncode('SELECT Id, Name, InstanceName FROM Organization', 'UTF-8');
            String endpoint = String.format(
                'callout:{0}/services/data/v{1}/query?q={2}',
                Lists.of(namedCredentialApiName, API_VERSION, encodedQuery)
            );
            req.setMethod('GET');
            req.setEndpoint(endpoint);
            // Invoke callout and parse response;
            HttpResponse resp = new Http().send(req);
            Logger.debug('{0} ({1}) > HTTP Status = {2}', Lists.of(namedCredentialApiName, oauthFlowToTest, resp.getStatus()));
            Assert.areEqual(200, resp.getStatusCode());
            OrganizationsPayload responsePayload = (OrganizationsPayload) JSON.deserialize(
                resp.getBody(),
                OrganizationsPayload.class
            );
            Assert.areEqual(1, responsePayload.totalSize);
            Assert.areEqual(1, responsePayload.records.size());
            Assert.isFalse(String.isBlank(responsePayload.records[0].Name));
        } catch (Exception ex) {
            Logger.error(oauthFlowToTest + ': FAILED');
        } finally {
            Logger.debug('Consumed {0} HTTP callout(s).', Lists.of((Limits.getCallouts() - currentCalloutsConsumed).toString()));
        }
    }

    public class OrganizationsPayload {
        public Integer totalSize;
        public Boolean done;
        public List<Organization> records;
    }
}
