import { LightningElement, track, wire } from 'lwc';
import getSandboxName from '@salesforce/apex/SandboxRefreshController.getSandboxName';
import updateUsers from '@salesforce/apex/GetUsersFromSandboxApiCls.updateUsers';
import allotPermSet from '@salesforce/apex/GetUsersFromSandboxApiCls.allotPermSet';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import resetPassword from '@salesforce/apex/GetUsersFromSandboxApiCls.resetPassword';
import validateUser from '@salesforce/apex/GetUsersFromSandboxApiCls.validateUser';

const Usercolumns = [
 
    { label: 'Username', fieldName: 'Username', type: 'text'},
    { label: 'Email', fieldName: 'Email', type: 'text'},

];

export default class UserUtilityCompo extends LightningElement {
    valueAct
    showUpadteUserBtn = false
    showAssignPsetBtn = false
    showPasswordReset = false
    showNoteOnPassword = false
    showPopupforAdd = false
    usercolumns = Usercolumns;
    usernamesStr;
    userData =[];

    get optionsAct() {
        return [
            { label: 'Update User Email', value: 'updateUser' },
            { label: 'Assign Permission Set', value: 'permissionSet' },
            { label: 'Password Reset', value: 'passwordReset' },
        ];
    }

    selectedHandler(event) {
        this.valueAct = event.detail.value;
        console.log('this.valueAct ==' + this.valueAct);
        if (this.valueAct == 'updateUser') {
            this.showUpadteUserBtn = true
            this.showAssignPsetBtn = false
            this.showPasswordReset = false
            this.showNoteOnPassword = false
        }
        if (this.valueAct == 'permissionSet') {
            this.showUpadteUserBtn = false
            this.showAssignPsetBtn = true
            this.showPasswordReset = false
            this.showNoteOnPassword = false
        }
        if (this.valueAct == 'passwordReset') {
            this.showUpadteUserBtn = false
            this.showAssignPsetBtn = false
            this.showPasswordReset = true
            this.showNoteOnPassword = true
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
    selectedValuehandler(event) {
        this.Value = event.detail.value;
        console.log('this.Value==' + this.Value);
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
        console.log('this.csvHeaders==' + this.csvHeaders);

        // Clean rows 

       /* if (this.valueAct == 'updateUser') {
            this.csvRows = [];
            this.csvRows = lines.slice(1).map((line, index) => {
                const data = line.split(',').map(cell => this.cleanCsvValue(cell));
                return { id: index, data };
            });
        }*/

        
        if (this.valueAct == 'updateUser') {
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

                if (this.valueAct == 'permissionSet') {
                    this.csvRows = [];
                    this.csvDisplayContent = ''; // Ensure this is initialized
                
                    lines.slice(1).forEach((line, index) => {
                        let firstCommaIndex = line.indexOf(',');
                        let beforeFirstComma = line.substring(0, firstCommaIndex).trim();
                        let afterFirstComma = line.substring(firstCommaIndex + 1).trim();
                
                        // Only process non-empty rows
                        if (beforeFirstComma && afterFirstComma) {
                            // Clean and reformat the second column data
                            afterFirstComma = this.cleanCsvValue(afterFirstComma).replace(/,/g, ', ');
                
                            // Construct row object
                            let row = {
                                id: index,
                                data: [beforeFirstComma, afterFirstComma]
                            };
                
                            this.csvRows.push(row);
                            this.csvDisplayContent += beforeFirstComma + ',' + afterFirstComma + '\n'; // Add each row
                        }
                    });
                }

                if (this.valueAct == 'passwordReset') {
                    this.csvRows = [];
                    this.csvRows = lines.slice(1).map((line, index) => {
                        const data = line.split(',').map(cell => this.cleanCsvValue(cell));
                        return data;
                    }).filter(data => data.some(cell => cell.trim() !== '')) // Filter out empty rows
                      .map((data, index) => {
                        // Re-map the filtered data with ids
                        return { id: index, data };
                    });
                }
                
          console.log('this.csvRows==' + JSON.stringify(this.csvRows));
    }

    userEmailMapStr;
    userPermSetMapStr;
    showSpinnerFlag = false

    updateUserBtnHandler() {
        let userEmailMap = {};
        this.csvRows.forEach(row => {
            // Assuming the username is in the first column and the email is in the second
            const username = row.data[0];
            const email = row.data[1];
            userEmailMap[username] = email;
        });

        // Convert userEmailMap object to string for Apex call
        this.userEmailMapStr = JSON.stringify(userEmailMap);

        console.log('userEmailMapStr==' + this.userEmailMapStr);

        // Call the Apex method
        this.callUpdateUsersApexMethod(this.Value, this.userEmailMapStr);
    }


    callUpdateUsersApexMethod(orgName, userEmailMapStr) {
        if (this.Value != null && this.file != null && this.csvHeaders[0] == 'Username' && this.csvHeaders[1] == 'Email' && this.csvHeaders.length === 2) {
            this.showSpinnerFlag = true
            updateUsers({ orgName: orgName, userEmailMapJson: userEmailMapStr })
                .then(result => {
                    console.log('Update Users Result:', result);
                    if (result == 'success') {
                        this.showSpinnerFlag = false
                        this.showSuccessToast();
                        this.Value = ''
                        this.valueAct = ''
                        this.file = null;
                        this.fileName = '';
                        this.csvHeaders = [];
                        this.csvRows = [];
                        this.showUpadteUserBtn = false
                    } else {
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
        else {
            this.showErrorToastInputs();
        }
    }

    assignPerSetBtnHandler() {
        console.log('csvHeader[0]=='+this.csvHeaders[0])
        console.log('csvHeader[1]=='+this.csvHeaders[1])
        if (this.Value != null && this.file != null && this.csvHeaders[0] == 'Username' && this.csvHeaders[1] == 'Permission Set' && this.csvHeaders.length === 2) {
            console.log('i m ')
            let userPermSetMap = {};
            this.csvRows.forEach(row => {
                const username = row.data[0];
                const perSet = row.data[1];
                userPermSetMap[username] = perSet;
            });

            // Convert userEmailMap object to string for Apex call
            this.userPermSetMapStr = JSON.stringify(userPermSetMap);

            console.log('userPermSetMapStr==' + this.userPermSetMapStr);
            this.showSpinnerFlag = true
            allotPermSet({ orgName: this.Value, userPermMapJson: this.userPermSetMapStr })
                .then(result => {
                    console.log('Update Users Result:', result);
                    if (result == 'success') {
                        this.showSpinnerFlag = false
                        this.showSuccessToast();
                        this.Value = ''
                        this.valueAct = ''
                        this.file = null;
                        this.fileName = '';
                        this.csvHeaders = [];
                        this.csvRows = [];
                        this.showAssignPsetBtn = false
                    } else {
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
        else {
            this.showErrorToastInputs();
        }
    }

    showErrorToastInputs() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Select all the required inputs or check the header names.',
                variant: 'Error',
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

    passwordResetBtnHandler() {
        if (this.Value != null && this.file != null && this.csvHeaders[0] == 'Username'  && this.csvHeaders.length === 1) {
            let usernameList = this.csvRows.map(row => row.data[0]); // Collects usernames into an array

            // Stringify the usernameList array for the Apex call
            this.usernamesStr = JSON.stringify(usernameList);

            this.showSpinnerFlag = true
            resetPassword({ orgName: this.Value, usernmList: this.usernamesStr })
                .then(result => {
                    console.log('Update Users Result:', result);
                    this.showSpinnerFlag = false
                    this.showSuccessToast();
                    this.showPopupforAdd = false;
                    this.Value = ''
                    this.valueAct = ''
                    this.file = null;
                    this.fileName = '';
                    this.csvHeaders = [];
                    this.csvRows = [];
                    this.showPasswordReset = false
                })
                .catch(error => {
                    this.error = error
                    this.showSpinnerFlag = false;
                    const errorMessage = error.body ? error.body.message : "Unknown error";
                    this.showErrorToast("Error updating users: " + errorMessage);
                });
        }
        else{
            this.showErrorToastInputs();
        }
    }
    
   /* async userValidateHandler() {
        // Handle potential missing values
        if (this.Value === null || this.file === null && this.csvHeaders[0] !== 'Username'  && this.csvHeaders.length !== 1) {
          console.log('Ia m ') 
          this.showErrorToastInputs();
          return; 
        }
        else{
        console.log('Ia m  333 ') 
        this.showPopupforAdd = true;
      
        let usernameList = {};
        this.csvRows.forEach(row => {
          // Assuming the username is in the first column
          const username = row.data[0];
          usernameList[username] = username;
        });
      
        // Stringify the usernameList for the Apex call
        this.usernamesStr = JSON.stringify(usernameList);
        console.log('RAMa', JSON.stringify(this.usernamesStr), typeof(this.usernamesStr));
      
        try {
          const result = await validateUser({ orgName: this.Value, userEmailMapJson: this.usernamesStr });
          this.userData = result;
        } catch (error) {
          console.error('Error updating users:', error);
          this.showSpinnerFlag = false; // Assuming this flag indicates a loading spinner
        } 
    }
      }*/

      userValidateHandler() {
        if (this.Value != null && this.file != null && this.csvHeaders[0] == 'Username'  && this.csvHeaders.length === 1) {
            let usernameList = {};
            this.csvRows.forEach(row => {
                // Assuming the username is in the first column
                const username = row.data[0];
                usernameList[username] = username;
            });
    
            // Stringify the usernameList for the Apex call
            this.usernamesStr = JSON.stringify(usernameList);
            console.log('RAMa', JSON.stringify(this.usernamesStr), typeof(this.usernamesStr));
    
            validateUser({ orgName: this.Value, userEmailMapJson: this.usernamesStr })
                .then(result => {
                    this.userData = result;
                    this.showPopupforAdd = true;
                })
                .catch(error => {
                    this.error = error
                    this.showSpinnerFlag = false;
                    const errorMessage = error.body ? error.body.message : "Unknown error";
                    this.showErrorToast("Error Retreiving users: " + errorMessage);
                });
        }
         else {
            this.showErrorToastInputs();
        }
    }
      
    hideModalBox() {
        this.showPopupforAdd = false;
    }
}