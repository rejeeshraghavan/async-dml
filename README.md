# Asynchronous Salesforce DML

Salesforce, as of API v49.0, provides asynchronous DML ability only for external objects. This library allows execution of dml for internal object, using queueable interface with features like callback method options.

## Features

- Perform asynchronous dml operation just like a standard dml operation.
  - e.g., AsyncDml.insert(accountRecord); or AsyncDml.update(listAccount);
- Uses reliable Queueable interface. So, its not limited to primitive datatypes as @future methods.
- Allows callback methods to be invoked after dml execution.
- Allows chaining of queueable jobs.

## Installation

  TODO:
  Click on the button below to deploy the component to the org

  [![Deploy](https://deploy-to-sfdx.com/dist/assets/images/DeployToSFDX.svg)](https://deploy-to-sfdx.com)

## Usage

  Below are the optional parameters for each operation:-
    #### 
    
    `isAllOrNone`: To specifiy whether the operation allows partial success. Default is true.

    #### 
    
    `strCallbackMethod`: Fully qualified API Name of callback method. The callback class MUST implement Callable interface.
      - callbackMethod returns the following parameters:-
        - `jobId`: Queueable jobId of the current job.
        - `strStatus`: status of job, 'success' or 'failure'.
        - `strErrorMessage`: Error message, if any. In case of success, this parameter will be null.
        - `listResult`: If 'success' it returns Database.SaveResult[] or Database.DeleteResult[] or Database.UpsertResult[]. In case of 'failure' it returns the input list.

    #### 
    
    `chainedJob`: The chainedJob to be executed on completion of the current job.

### Dummy Data preparation

  List<Account> listAccountToInsert = new List<Account>();
    listAccountToInsert.add(
      new Account( name = 'Dummy')
    );

  Account accountToUpsert = new Account(
    name='Chained Dummy'
  );

### Insert List
  AsyncDml.insertList(listAccountToInsert);//this will simply insert the list of accounts as a queueable job

### Insert list with allOrNone
  AsyncDml.insertList(listAccountToInsert, false );//this will simply insert the list of accounts as a queueable job.

### Insert list with callbackMethod
  AsyncDml.insertList(listAccountToInsert, null, 'AsyncDmlExtension.callbackMethod');//this will simply insert the list of accounts as a queueable job. After the DML operation AsyncDmlExtension.callbackMethod() method is invoked.

###### NOTE

    callback mehtod can be any method in a class which implements `Callable interface`. Check `AsyncDmlExtension` class for example.

### Insert list with chained queueable job

  AsyncDmlHelper chainedJob = new AsyncDmlHelper(new List<Sobject>{accountToUpsert}, 'upsert', null, null, null);
  AsyncDml.insertList(listAccountToInsert, null, null, chainedJob);//this will insert the list of Accounts, & once the insert is finished, it will enqueue the upsert operation.

### NOTE

  `insert`, `delete` & `update` operations are allowed for either List or an individual record
  `upsert` operation is supported ONLY for an individual record.

