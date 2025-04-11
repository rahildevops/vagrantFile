# Make the HTTP PUT request to update the idm-admin-ui OAuth2Client configuration
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/agents/OAuth2Client/idm-admin-ui" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"_id":"idm-admin-ui","overrideOAuth2ClientConfig":{"issueRefreshToken":true,"validateScopePluginType":"PROVIDER","tokenEncryptionEnabled":false,"evaluateScopePluginType":"PROVIDER","oidcMayActScript":"[Empty]","oidcClaimsScript":"[Empty]","scopesPolicySet":"oauth2Scopes","accessTokenModificationPluginType":"PROVIDER","authorizeEndpointDataProviderClass":"org.forgerock.oauth2.core.plugins.registry.DefaultEndpointDataProvider","useForceAuthnForMaxAge":false,"oidcClaimsPluginType":"PROVIDER","providerOverridesEnabled":false,"authorizeEndpointDataProviderScript":"[Empty]","statelessTokensEnabled":false,"authorizeEndpointDataProviderPluginType":"PROVIDER","remoteConsentServiceId":null,"enableRemoteConsent":false,"validateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeValidator","usePolicyEngineForScope":false,"evaluateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeEvaluator","overrideableOIDCClaims":[],"accessTokenMayActScript":"[Empty]","evaluateScopeScript":"[Empty]","clientsCanSkipConsent":false,"accessTokenModificationScript":"[Empty]","issueRefreshTokenOnRefreshedToken":true,"validateScopeScript":"[Empty]"},"advancedOAuth2ClientConfig":{"logoUri":{"inherited":false,"value":[]},"subjectType":{"inherited":false,"value":"public"},"clientUri":{"inherited":false,"value":[]},"tokenExchangeAuthLevel":{"inherited":false,"value":0},"responseTypes":{"inherited":false,"value":["code","token","id_token","code token","token id_token","code id_token","code token id_token","device_code","device_code id_token"]},"mixUpMitigation":{"inherited":false,"value":false},"customProperties":{"inherited":false,"value":[]},"javascriptOrigins":{"inherited":false,"value":[]},"policyUri":{"inherited":false,"value":[]},"softwareVersion":{"inherited":false},"tosURI":{"inherited":false,"value":[]},"sectorIdentifierUri":{"inherited":false},"tokenEndpointAuthMethod":{"inherited":false,"value":"none"},"refreshTokenGracePeriod":{"inherited":false,"value":0},"isConsentImplied":{"inherited":false,"value":true},"softwareIdentity":{"inherited":false},"grantTypes":{"inherited":false,"value":["authorization_code","implicit"]},"require_pushed_authorization_requests":{"inherited":false,"value":false},"descriptions":{"inherited":false,"value":[]},"requestUris":{"inherited":false,"value":[]},"name":{"inherited":false,"value":[]},"contacts":{"inherited":false,"value":[]},"updateAccessToken":{"inherited":false}},"signEncOAuth2ClientConfig":{"tokenEndpointAuthSigningAlgorithm":{"inherited":false,"value":"RS256"},"idTokenEncryptionEnabled":{"inherited":false,"value":false},"tokenIntrospectionEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"requestParameterSignedAlg":{"inherited":false},"authorizationResponseSigningAlgorithm":{"inherited":false,"value":"RS256"},"clientJwtPublicKey":{"inherited":false},"idTokenPublicEncryptionKey":{"inherited":false},"mTLSSubjectDN":{"inherited":false},"jwkStoreCacheMissCacheTime":{"inherited":false,"value":60000},"jwkSet":{"inherited":false},"idTokenEncryptionMethod":{"inherited":false,"value":"A128CBC-HS256"},"jwksUri":{"inherited":false},"tokenIntrospectionEncryptedResponseAlg":{"inherited":false,"value":"RSA-OAEP-256"},"authorizationResponseEncryptionMethod":{"inherited":false},"userinfoResponseFormat":{"inherited":false,"value":"JSON"},"mTLSCertificateBoundAccessTokens":{"inherited":false,"value":false},"publicKeyLocation":{"inherited":false,"value":"jwks_uri"},"tokenIntrospectionResponseFormat":{"inherited":false,"value":"JSON"},"requestParameterEncryptedEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"userinfoSignedResponseAlg":{"inherited":false},"idTokenEncryptionAlgorithm":{"inherited":false,"value":"RSA-OAEP-256"},"requestParameterEncryptedAlg":{"inherited":false},"authorizationResponseEncryptionAlgorithm":{"inherited":false},"mTLSTrustedCert":{"inherited":false},"jwksCacheTimeout":{"inherited":false,"value":3600000},"userinfoEncryptedResponseAlg":{"inherited":false},"idTokenSignedResponseAlg":{"inherited":false,"value":"RS256"},"tokenIntrospectionSignedResponseAlg":{"inherited":false,"value":"RS256"},"userinfoEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"}},"coreOAuth2ClientConfig":{"clientType":{"value":"Public","inherited":false},"status":{"value":"Active","inherited":false},"redirectionUris":{"value":["http://openidm.example.com:8080/platform/appAuthHelperRedirect.html","http://openidm.example.com:8080/platform/sessionCheck.html","http://openidm.example.com:8080/admin/appAuthHelperRedirect.html","http://openidm.example.com:8080/admin/sessionCheck.html","http://admin.example.com:8082/appAuthHelperRedirect.html","http://admin.example.com:8082/sessionCheck.html","https://platform.example.com:9443/platform/appAuthHelperRedirect.html","https://platform.example.com:9443/platform/sessionCheck.html","https://platform.example.com:9443/admin/appAuthHelperRedirect.html","https://platform.example.com:9443/admin/sessionCheck.html","https://platform.example.com:9443/platform-ui/appAuthHelperRedirect.html","https://platform.example.com:9443/platform-ui/sessionCheck.html"],"inherited":false},"refreshTokenLifetime":{"value":0,"inherited":false},"agentgroup":"","accessTokenLifetime":{"value":0,"inherited":false},"authorizationCodeLifetime":{"value":0,"inherited":false},"secretLabelIdentifier":{"value":"","inherited":false},"loopbackInterfaceRedirection":{"value":false,"inherited":false},"scopes":{"value":["openid","fr:idm:*"],"inherited":false},"defaultScopes":{"value":[],"inherited":false},"clientName":{"value":[],"inherited":false}},"coreOpenIDClientConfig":{"claims":{"inherited":false,"value":[]},"backchannel_logout_uri":{"inherited":false},"defaultAcrValues":{"inherited":false,"value":[]},"jwtTokenLifetime":{"inherited":false,"value":0},"defaultMaxAgeEnabled":{"inherited":false,"value":false},"clientSessionUri":{"inherited":false},"defaultMaxAge":{"inherited":false,"value":600},"postLogoutRedirectUri":{"inherited":false,"value":[]},"backchannel_logout_session_required":{"inherited":false,"value":false}},"coreUmaClientConfig":{"claimsRedirectionUris":{"inherited":false,"value":[]}},"_type":{"_id":"OAuth2Client","name":"OAuth2 Clients","collection":true}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "OAuth2Client idm-admin-ui update request completed at $(date)" >> /vagrant/curl_request.log