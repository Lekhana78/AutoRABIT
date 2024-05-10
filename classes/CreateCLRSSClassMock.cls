@isTest
global class CreateCLRSSClassMock implements WebServiceMock {

    public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
            ) {

         if (request instanceof MetadataService.upsertMetadata_element) {
            response.put('response_x', upsertResponse(request));
        }
    }

    // Implements couple of requests
    private MetadataService.IReadResponseElement readResponse(Object request) {

        MetadataService.readMetadata_element r = (MetadataService.readMetadata_element) request;

        if (r.type_x == 'RemoteSiteSetting') {

            MetadataService.ReadRemoteSiteSettingResult result = new MetadataService.ReadRemoteSiteSettingResult();
            result.records = new MetadataService.RemoteSiteSetting[] {
                
            };

            MetadataService.readRemoteSiteSettingResponse_element responseElement = new MetadataService.readRemoteSiteSettingResponse_element();
            responseElement.result = result;

            return responseElement;

        } else if (r.type_x == 'CustomLabel') {

            MetadataService.ReadCustomLabelResult result = new MetadataService.ReadCustomLabelResult();
            result.records = new MetadataService.CustomLabel[] {
            };

            MetadataService.readCustomLabelResponse_element responseElement = new MetadataService.readCustomLabelResponse_element();
            responseElement.result = result;

            return responseElement;

        }
        
        
        else {

            System.assert(false, 'Unexpected read type ' + r.type_x);
            return null;
        }
    }

    public static MetadataService.RemoteSiteSetting createContactEmailField() {

        MetadataService.RemoteSiteSetting rss = new MetadataService.RemoteSiteSetting();
        rss.fullName = 'RRSS';
        rss.isActive = true;
        rss.url = 'https://test.salesforce.com';
        rss.disableProtocolSecurity = false;
        return rss;
    }


    // Does nothing except return success
    private MetadataService.updateMetadataResponse_element updateResponse(Object request) {

        MetadataService.SaveResult result = new MetadataService.SaveResult();
        result.success = true;

        MetadataService.updateMetadataResponse_element responseElement = new MetadataService.updateMetadataResponse_element();
        responseElement.result = new MetadataService.SaveResult[] {result};

        return responseElement;
    }

    // Does nothing except return success
    private MetadataService.upsertMetadataResponse_element upsertResponse(Object request) {

        MetadataService.UpsertResult result = new MetadataService.UpsertResult();
        result.success = true;

        MetadataService.upsertMetadataResponse_element responseElement = new MetadataService.upsertMetadataResponse_element();
        responseElement.result = new MetadataService.UpsertResult[] {result};

        return responseElement;
    }
}