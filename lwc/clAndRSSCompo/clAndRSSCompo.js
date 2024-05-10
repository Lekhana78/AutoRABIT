import { LightningElement,track,wire } from 'lwc';
import getSandboxName from '@salesforce/apex/SandboxRefreshController.getSandboxName';
import upsertMetadataCL from '@salesforce/apex/CreateCLRSSClass.upsertMetadataCL';
import upsertMetadataRSS from '@salesforce/apex/CreateCLRSSClass.upsertMetadataRSS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent' ;

export default class ClAndRSSCompo extends LightningElement {
    valueAct
    showCustomLabelBtn = false
    showRSSBtn = false
    showSpinnerFlag = false

    get optionsAct() {
        return [
            { label: 'Custom Label', value: 'customLabel' },
            { label: 'Remote Site Setting', value: 'remoteSiteSetting' },
        ];
    }

    selectedHandler(event) {
        this.valueAct = event.detail.value;
        console.log('this.valueAct =='+this.valueAct); 
        if(this.valueAct == 'customLabel'){
            this.showCustomLabelBtn = true
            this.showRSSBtn = false
        }
        if(this.valueAct == 'remoteSiteSetting'){
            this.showCustomLabelBtn = false
            this.showRSSBtn = true
        }
    }

    @track Options = []; 
    @track Value;
    @track nameIdMapping = [];
    result 
    error

    @wire(getSandboxName)
    wiredGetSandbox({ error, data }) {
        if (data) {
            this.Options = data.map(sandbox => {
                // Update the mapping with name as key and ID as value
                this.nameIdMapping[sandbox.Name] = sandbox.Id;
                return { label: sandbox.Name, value: sandbox.Name };
            });
            console.log('Sandbox Data:', data);
        } else if (error) {
            console.error('Error fetching sandbox names:', error);
            this.Options = []; // Reset options in case of error
        }
    }
  selectedValuehandler(event){
            this.Value = event.detail.value;
            console.log('this.Value=='+this.Value);
    }

    @track fileName = ''; // Property to hold the file name
    @track csvHeaders = [];
    @track csvRows = [];
    @track csvDisplayContent = ''; // Property to hold the displayable CSV content
    file
    handleFileChange(event) {
        const fileList = event.target.files;
        this.file = fileList;

        if (fileList.length > 0) {
            this.fileName = fileList[0].name; // Update the file name
    
            const reader = new FileReader();
            reader.onload = (e) => {
                const csvContent = e.target.result;
                this.parseCsv(csvContent);
            };
            reader.readAsText(fileList[0]); // Read the first file
        } else {
            this.fileName = ''; // Reset if no file is selected
            this.csvHeaders = [];
            this.csvRows = [];
        }
    }

    cleanCsvValue(value) {
        // Trim whitespace and then remove double quotes at the start and end if they exist
        return value.trim().replace(/^"|"$/g, '');
    }
    
    parseCsv(csvContent) {
        const lines = csvContent.split(/\r\n|\n/);
        
        // Clean headers
        this.csvHeaders = lines[0].split(',').map(header => this.cleanCsvValue(header));
        this.csvDisplayContent = this.csvHeaders.join(',') + '\n'; // Start with headers
        console.log('this.csvHeaders=='+this.csvHeaders);
        
        // Clean rows 
        this.csvRows = [];
        this.csvRows = lines.slice(1) // Skip the header
            .map(line => {
                // Split line into cells and clean each cell
                const data = line.split(',').map(cell => this.cleanCsvValue(cell));
                return data;
            })
            .filter(data => data.some(cell => cell.trim() !== '')) // Filter out empty rows
            .map((data, index) => {
                // Map remaining rows to objects with id and data
                return { id: index, data };
            });
       
    }
    
    customLabelMapStr;
    userPermSetMapStr;

    createCustomLabelHandler() {
        if(this.Value != null && this.file != null && this.csvHeaders[0] == 'Name' && this.csvHeaders[1] == 'Short Description' && this.csvHeaders[2] == 'Language' && this.csvHeaders[3] == 'Value' && this.csvHeaders[4] == 'Categories' && this.csvHeaders.length === 5){
        let customLabelMap = [];
        this.csvRows.forEach(row => {
            // Assuming the username is in the first column and the email is in the second
            const fullName = row.data[0];
            const shortDescription = row.data[1];
            const language = row.data[2];
            const value = row.data[3];
            const categories = row.data[4];
            
            customLabelMap.push({
                fullName: fullName,
                shortDescription: shortDescription,
                language: language,
                value: value,
                categories: categories
            });
        });
        // Convert customLabelMap object to string for Apex call
         this.customLabelMapStr = JSON.stringify(customLabelMap);
        this.upsertCustLabel(this.Value, this.customLabelMapStr);
    }
    else{
        this.showErrorToastInputs();
    }

    }


    upsertCustLabel(orgName, customLabelMapStr) {
        this.showSpinnerFlag = true
        upsertMetadataCL({ orgName: orgName, cljson: customLabelMapStr })
            .then(result => {
                console.log('', result);
                if(result == 'success'){
                    this.showSpinnerFlag = false
                    this.showSuccessToast();
                    this.Value = ''
                    this.valueAct = ''
                    this.file = null
                    this.fileName = ''; // Reset if no file is selected
                    this.csvHeaders = [];
                    this.csvRows = [];
                    this.showCustomLabelBtn = false
                }else{
                    this.showSpinnerFlag = false
                    this.showErrorToast("Operation failed: " + result);
                }
            })
            .catch(error => {
                this.error = error
                this.showSpinnerFlag = false;
                const errorMessage = error.body ? error.body.message : "Unknown error";
                this.showErrorToast("Error updating users: " + errorMessage);
            });
    }

    createRSSHandler(){
        if(this.Value != null && this.file != null && this.csvHeaders[0] == 'Name' && this.csvHeaders[1] == 'Url' && this.csvHeaders.length === 2){
        let rssSetMap = {};
        this.csvRows.forEach(row => {
            const name = row.data[0];
            const url = row.data[1];
            rssSetMap[name] = url;
        });

       console.log('rssSetMap == '+rssSetMap)
       console.log('rssSetMap string == '+JSON.stringify(rssSetMap))
       this.showSpinnerFlag = true
        upsertMetadataRSS({ orgName: this.Value, rssMap: rssSetMap })
        .then(result => {
            console.log('Update Users Result:', result);
            if(result == 'success'){
                this.showSpinnerFlag = false
                this.showSuccessToast();
                this.Value = ''
                this.valueAct = ''
                this.file = null
                this.fileName = ''; // Reset if no file is selected
                this.csvHeaders = [];
                this.csvRows = [];
                this.showRSSBtn = false
            }else{
                this.showSpinnerFlag = false
                this.showErrorToast("Operation failed: " + result);
            }
        })
        .catch(error => {
            this.error = error
            this.showSpinnerFlag = false;
            const errorMessage = error.body ? error.body.message : "Unknown error";
            this.showErrorToast("Error updating users: " + errorMessage);
        });
    }else{
        this.showErrorToastInputs();
    }
    }

    showErrorToastInputs() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Select all the required inputs or check the header names.',
                variant:'Error',
                mode: 'dismissable'
            })
        );
    }

    showSuccessToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Success',
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
                variant:'Error',
                mode: 'dismissable'
            })
        );
        }
}