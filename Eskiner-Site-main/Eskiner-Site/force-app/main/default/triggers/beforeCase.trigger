trigger new_case_handling on Case (before insert) {
    System.debug('Entered execution procedure for new_case_handling trigger');
    for (Case receivedCase: Trigger.new) {
        Boolean contactCreated = false;
        if(receivedCase.AccountId == null && receivedCase.SuppliedEmail != null) {
            List<Account> unknownAccount = [SELECT Id FROM Account  WHERE Name = 'UNKNOWN ACCOUNT'];

            if(unknownAccount.size() != 0) {
                String fullEmail = String.valueOf(receivedCase.SuppliedEmail);
                String newUsername = 'NOTAVAILABLE';
                if(fullEmail.indexOf('@') != -1) {
                    newUsername = fullEmail.split('@').get(0);
                }
                Contact newContact = new Contact(
                    LastName = newUsername,
                    Email = receivedCase.SuppliedEmail,
                    AccountId = unknownAccount[0].Id);

                insert newContact;
                contactCreated = true;
                System.debug('Created contact ' + String.valueOf(receivedCase.SuppliedEmail) + ' on account ' + unknownAccount[0].Id );
            }
            else {
                System.debug('Unable to find UNKNOWN ACCOUNT to insert ' + String.valueOf(receivedCase.SuppliedEmail) + 'in' );
            }
            if(contactCreated) {
                List<Contact> createdContact = [SELECT Id FROM contact WHERE Email =:receivedCase.SuppliedEmail];
                if(createdContact.size() > 0){
                    receivedCase.contactId = createdContact[0].Id;
                    insert receivedCase;
                }
                else {
                    System.debug('Contact was created but query failed.');
                }
            }

        }
    }
}