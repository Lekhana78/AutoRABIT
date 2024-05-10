import { LightningElement,api } from 'lwc';
import refreshSandbox from '@salesforce/apex/SandboxRefresh.refreshSandbox';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class SandboxRefreshQuickActionCompo extends LightningElement {
    @api recordId;
    result
    error
    @api async invoke() {
        let params ={
            "Orgid" : this.recordId
        };
        
            await refreshSandbox(params)
                .then( (result) => {    
                    this.result = result;
                    console.log('this.result==='+this.result);
                    if(this.result == 'Sandbox refresh initiated'){
                       this.showSuccessToast(this.result);
                    }
                    else{
                       this.showErrorToast(this.result);
                    }
                    this.error = undefined
                })
                .catch( (error) => {
                this.result = undefined;
                this.error = error;
                console.log(this.error);
            })
      }

      showSuccessToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: message,
                variant: 'success',
                mode: 'dismissable'
            })
           
        );
    }  

    showErrorToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error',
                mode: 'dismissable'
            })
        );
    }
}