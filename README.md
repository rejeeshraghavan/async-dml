# Asynchronous Salesforce DML

This apex library allows asynchronous execution of dml for internal object, using queueable interface with features like callback method options.
Salesforce apex provides out-of-the-box asynchronous DML ability only for external objects. This library helps achieve asynchronous DML operations for standard & custom objects with ease.
Also, asynchronous mode has increased governor limits, as below:- 

| Description | Synchronous Limit | Asynchronous Limit |
| --- | --- | --- |
| Total number of SOQL queries issued | 100 | 200 |
| Total heap size | 6MB | 12MB |
| Maximum CPU time on the Salesforce servers | 10,000 milliseconds | 60,000 milliseconds |


## Features

- Perform asynchronous dml operation with ease.
  - e.g., Dml.insertAsync(accountRecord).submit(); or Dml.updateAsync(listAccount).submit();
- Uses reliable Queueable interface. So, its not limited to primitive datatype as @future methods.
- Allows callback methods to be invoked after dml execution.
- Allows chaining of queueable jobs.
- Allows to setup retry mechanism.

## Installation

  TODO: Add installation button

## Usage

### Optional setup methods
  Below are the optional methods for each operation:-
    
  - `isAllOrNone` - To specify whether the operation allows partial success. Default is true.
    
  - `callback` - Fully qualified API Name of callback method. The callback class MUST implement Callable interface.
      - callbackMethod - returns the following parameters:-
        - `jobId` - Queueable jobId of the current job.
        - `strStatus` - Status of job, 'success' or 'failure'.
        - `strErrorMessage` - Error message, if any. In case of success, this parameter will be null.
        - `intExecutionCount` - Current execution count. This can be used for retry mechanism(Check `AsyncDmlExtension` class for example).
        - `listResult` - If 'success' it returns Database.SaveResult[] or Database.DeleteResult[] or Database.UpsertResult[]. In case of 'failure' it returns the input list.
    
  - `chainedJob` - The chainedJob to be executed on completion of the current job.

### Dummy Data preparation
  ```java
  List<Account> listAccountToInsert = new List<Account>();
    listAccountToInsert.add(
      new Account( name = 'Dummy')
    );

  Account accountToUpsert = new Account(
    name='Chained Dummy'
  );
  ```

### Insert List
  ```java
  //this will simply insert the list of accounts as a queueable job
  Dml.insertAsync(listAccountToInsert).submit();
  ```

### Insert list with allOrNone
  ```java
  //this will simply insert the list of accounts as a queueable job.
  Dml.insertAsync(listAccountToInsert)
    .isAllOrNone(false)
    .submit();
  ```

### Insert list with callbackMethod
  ```java
  //this will simply insert the list of accounts as a queueable job.
  //After the DML operation AsyncDmlExtension.callbackMethod() method is invoked.
  Dml.insertAsync(listAccountToInsert)
    .callback('AsyncDmlExtension.callbackMethod')
    .submit();
  ```

###### NOTE
  - callback method can be any method in a class which implements `Callable interface`. Check `AsyncDmlExtension` class for example.

### Insert list with chained queueable job
  ```java
  //create a queueable job to be chained
  AsyncDmlHelper chainedJob = Dml.upsertAsync(accountToUpsert);
  
  //this will insert the list of Accounts, & once the insert is finished
  //it will enqueue the upsert operation.
  Dml.insertAsync(listAccountToInsert)
    .chainedJob(chainedJob);
  ```
###### NOTE
  - chaining queueable methods comes handy when dealing with high volume of records.
  
### CONSIDERATIONS

- `insert`, `delete` & `update` operations are allowed for either List or an individual record
- `upsert` operation is supported ONLY for an individual record.
