import { LightningElement,api } from 'lwc';
import auth from '@salesforce/apex/AuthorizationCodeFlowSandbox.auth';

export default class AuthSandboxCompo extends LightningElement {

    @api recordId;
    url
    result
    error
    @api async invoke() {
        let params ={
            "orgId" : this.recordId
        };
       
        await auth(params)
                        .then( (result) => {    
                            this.url = result;
                            window.open(this.url);
                            this.error = undefined
                            console.log(this.result );
                            
                        })
                        .catch( (error) => {
                        this.result = undefined;
                        this.error = error;
                        console.log(this.error);
                    })
        }

}