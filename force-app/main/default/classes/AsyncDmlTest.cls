@isTest
public class AsyncDmlTest {
    @TestSetup
    static void asyncTestData(){
        List<Account> listAccountToInsert = new List<Account>();
        for(Integer i =0;i<10;i++){
            listAccountToInsert.add(
                new Account(
                    name = 'TestAsync'+String.valueOf(i)
                )
            );
        }
        Database.insert(listAccountToInsert);
    }
    @IsTest
    static void testInsertList_positive(){
        List<Account> listAccount = new List<Account>();
        for(Integer i =0;i<10;i++){
            listAccount.add(
                new Account(
                    name = 'AsyncInsert'+String.valueOf(i)
                )
            );
        }
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1][0]){
            Dml.insertAsync(listAccount)
                .submit();
        }
        Test.stopTest();
        Assert.areEqual(10, [SELECT COUNT() FROM Account WHERE Name LIKE 'AsyncInsert%'], '10 accounts should have been inserted.');
    }
    @IsTest
    static void testInsertList_negative(){
        List<Account> listAccount = new List<Account>();
        for(Integer i =0;i<10;i++){
            listAccount.add(
                new Account(
                    name = 'AsyncInsert'+String.valueOf(i)
                )
            );
        }
        //set the name as null, so that list insert fails
        listAccount[0].name=null;
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1][0]){
            Dml.insertAsync(listAccount)
                .callback('AsyncDmlExtension.asyncCallback')
                .submit();
        }
        Test.stopTest();
        Assert.areEqual(0, [SELECT COUNT() FROM Account WHERE Name LIKE 'AsyncInsert%'], 'No accounts should have been inserted.');
        Assert.areEqual(1, [SELECT COUNT() FROM Task WHERE OwnerId = :UserInfo.getUserId()], '1 Task should have been created for the current user');
    }
    @IsTest
    static void testInsertListAllorNone_positive(){
        List<Account> listAccount = new List<Account>();
        for(Integer i =0;i<10;i++){
            listAccount.add(
                new Account(
                    name = 'AsyncInsertAll'+String.valueOf(i)
                )
            );
        }
        //set the name as null, so that record insert fails.
        //only 1 record will fail, rest will be inserted successfully due to allOrNone=false.
        listAccount[0].name=null;
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1][0]){
            Dml.insertAsync(listAccount)
                .isAllOrNone(false)
                .callback('AsyncDmlExtension.asyncCallback')
                .submit();
        }
        Test.stopTest();
        Assert.areEqual(9, [SELECT COUNT() FROM Account WHERE Name LIKE 'AsyncInsertAll%'], '9 accounts should have been insert. 1 should fail.');
        Assert.areEqual(1, [SELECT COUNT() FROM Task WHERE OwnerId = :UserInfo.getUserId()], '1 Task should have been created for the current user');
    }
    @IsTest
    static void testUpdateList_positive(){
        List<Account> listAccountToUpdate = [SELECT Id, Name FROM Account WHERE Name LIKE 'TestAsync%'];
        for(Account accountRecord: listAccountToUpdate){
            accountRecord.Name = 'AsyncUpdate'+ String.valueOf(listAccountToUpdate.indexOf(accountRecord));
        }
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1][0]){
            Dml.updateAsync(listAccountToUpdate)
                .submit();
        }
        Test.stopTest();
        Assert.areEqual(listAccountToUpdate.size(), [SELECT COUNT() FROM Account WHERE Name LIKE 'AsyncUpdate%'], '10 accounts should have been updated.');
    }
    @IsTest
    static void testUpdateList_negative(){
        List<Account> listAccountToUpdate = [SELECT Id, Name FROM Account WHERE Name LIKE 'TestAsync%'];
        for(Account accountRecord: listAccountToUpdate){
            accountRecord.Name = null;
        }
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1][0]){
            Dml.updateAsync(listAccountToUpdate)
                .callback('AsyncDmlExtension.asyncCallback')
                .submit();
        }
        Test.stopTest();
        Assert.areEqual(10, [SELECT COUNT() FROM Account WHERE Name LIKE 'TestAsync%'], 'None of 10 accounts should have been updated.');
        Assert.areEqual(1, [SELECT COUNT() FROM Task WHERE OwnerId = :UserInfo.getUserId()], '1 Task should have been created for the current user');
    }
    @IsTest
    static void testDeleteList_positive(){
        List<Account> listAccountToDelete = [SELECT Id, Name FROM Account WHERE Name LIKE 'TestAsync%'];
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1][0]){
            Dml.deleteAsync(listAccountToDelete)
            .submit();
        }
        Test.stopTest();
        Assert.areEqual(0, [SELECT COUNT() FROM Account WHERE Name LIKE 'TestAsync%'], 'All accounts should have been deleted.');
    }
    @IsTest
    static void testInsertRecord_positive(){
        Account accountToInsert = new Account(
            name = 'AsyncInsert'+'2'
        );
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1][0]){
            Dml.insertAsync(accountToInsert)
                .submit();
        }
        Test.stopTest();
        Assert.areEqual(1, [SELECT COUNT() FROM Account WHERE Name LIKE 'AsyncInsert%'], '1 account should have been inserted.');
    }
    @IsTest
    static void testUpsertRecord_positive(){
        Account accountToUpdate = [SELECT Id, Name FROM Account WHERE Name LIKE 'TestAsync%' LIMIT 1];
        accountToUpdate.Name = 'AsyncUpsert'+'1';
        Account accountToInsert = new Account(
            name = 'AsyncUpsert'+'2'
        );
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1][0]){
            Dml.upsertAsync(accountToUpdate)
                .submit();
            Dml.upsertAsync(accountToInsert)
                .submit();
        }
        Test.stopTest();
        Assert.areEqual(2, [SELECT COUNT() FROM Account WHERE Name LIKE 'AsyncUpsert%'], '2 accounts should have been upserted.');
    }
    @IsTest
    static void testUpdateRecord_positive(){
        Account accountToUpdate = new Account(
            Id = [SELECT Id FROM Account WHERE Name LIKE 'TestAsync%' LIMIT 1].Id
            , Name = 'AsyncUpdate'+'1');
        List<Contact> listContactToInsert = new List<Contact>{
            new Contact(
              AccountId = accountToUpdate.Id
              , FirstName = 'Firstname1'
              , LastName='Lastname1'
            )
          };
        AsyncDmlHelper contactInsertJob = Dml.insertAsync(listContactToInsert);
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1][0]){
            Dml.updateAsync(accountToUpdate)
                .submit();
        }
        Test.stopTest();
        Assert.areEqual(1, [SELECT COUNT() FROM Account WHERE Name LIKE 'AsyncUpdate%'], '1 accounts should have been updated.');
    }
    @IsTest
    static void testDeleteRecord_positive(){
        Account accountToDelete = [SELECT Id, Name FROM Account WHERE Name LIKE 'TestAsync%' LIMIT 1];
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1][0]){
            Dml.deleteAsync(accountToDelete)
                .submit();
        }
        Test.stopTest();
        Assert.areEqual(0, [SELECT COUNT() FROM Account WHERE Id = :accountToDelete.Id], '1 account should have been deleted.');
    }
    @IsTest
    static void testRetryCallback(){
        String strClassName = 'AsyncDmlExtension'
            , strMethodName = 'asyncCallbackRetry';
        Test.startTest();
        Callable extension = (Callable) Type.forName(strClassName).newInstance();
            extension.call(strMethodName, new Map<String,Object>
                {
                    'jobId' => [SELECT Id FROM Account LIMIT 1].Id
                    , 'strStatus' => 'failure'
                    , 'strErrorMessage' => 'dummy error message'
                    , 'listResult' => [SELECT Id FROM Account] 
                    , 'intExecutionCount' => 2
                });
        Test.stopTest();
        Assert.areEqual(0, [SELECT COUNT() FROM Account], 'All accounts should be deleted');
        Assert.areEqual(1, [SELECT COUNT() FROM Task WHERE OwnerId = :UserInfo.getUserId()], '1 Task should have been created for the current user');
    }
    @IsTest
    static void testChainedJob_negative(){
        Account accountToUpdate = new Account(
            Id = [SELECT Id FROM Account WHERE Name LIKE 'TestAsync%' LIMIT 1].Id
            , Name = 'AsyncUpdate'+'1');
        List<Contact> listContactToInsert = new List<Contact>{
            new Contact(
              AccountId = accountToUpdate.Id
              , FirstName = 'Firstname1'
              , LastName='Lastname1'
            )
          };
        AsyncDmlHelper contactInsertJob = Dml.insertAsync(listContactToInsert);
        Test.startTest();
            Dml.updateAsync(accountToUpdate)
                .chainedJob(contactInsertJob)
                .submit();
        Test.stopTest();
        Assert.areEqual(1, [SELECT COUNT() FROM Account WHERE Name LIKE 'AsyncUpdate%'], '1 accounts should have been updated.');
        Assert.areEqual(0, [SELECT COUNT() FROM Contact WHERE Firstname ='Firstname1'], '0 contact should have been inserted as chaining is not allowed in Test methods.');
    }
}