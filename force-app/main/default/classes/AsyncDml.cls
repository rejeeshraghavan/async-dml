public with sharing class AsyncDml{
    private static AsyncDmlHelper asyncDmlJob;
    /*
    * Details of input parameters.
    * @param listRecordsTo<DML Operation>: list of records to perform DML operation.
    * @param recordTo<DML Operation>: record to perform DML operation.
    * @param isAllOrNone: DML option to specify if all or none records should be processed.
    * @param strCallbackMethod: Fully qualified API Name of callback method. The callback class MUST implement Callable interface.
    * @param chainedJob: the chainedJob to be executed on completion of the current job.
    * @return Id: jobId of enqueued job
    */
    public static Id insertList(List<sObject> listRecordsToInsert, Boolean isAllOrNone, String strCallbackMethod, Queueable chainedJob){
        asyncDmlJob = new AsyncDmlHelper(listRecordsToInsert, 'insert',isAllOrNone, strCallbackMethod, chainedJob);
        return System.enqueueJob(asyncDmlJob);
    }
    public static Id updateList(List<sObject> listRecordsToUpdate, Boolean isAllOrNone, String strCallbackMethod, Queueable chainedJob){
        asyncDmlJob = new AsyncDmlHelper(listRecordsToUpdate, 'update',isAllOrNone, strCallbackMethod, chainedJob);
        return System.enqueueJob(asyncDmlJob);
    }
    public static Id deleteList(List<sObject> listRecordsToDelete, Boolean isAllOrNone, String strCallbackMethod, Queueable chainedJob){
        asyncDmlJob = new AsyncDmlHelper(listRecordsToDelete, 'delete', isAllOrNone, strCallbackMethod, chainedJob);
        return System.enqueueJob(asyncDmlJob);
    }
    public static Id insertList(List<sObject> listRecordsToInsert, Boolean isAllOrNone, String strCallbackMethod){
        return insertList(listRecordsToInsert, isAllOrNone, strCallbackMethod, null);
    }
    public static Id updateList(List<sObject> listRecordsToUpdate, Boolean isAllOrNone, String strCallbackMethod){
        return updateList(listRecordsToUpdate, isAllOrNone, strCallbackMethod, null);
    }
    public static Id deleteList(List<sObject> listRecordsToDelete, Boolean isAllOrNone, String strCallbackMethod){
        return deleteList(listRecordsToDelete, isAllOrNone, strCallbackMethod, null);
    }
    public static Id insertList(List<sObject> listRecordsToInsert, Boolean isAllOrNone){
        return insertList(listRecordsToInsert, null, null, null);
    }
    public static Id updateList(List<sObject> listRecordsToUpdate, Boolean isAllOrNone){
        return updateList(listRecordsToUpdate, null, null, null);
    }
    public static Id deleteList(List<sObject> listRecordsToDelete, Boolean isAllOrNone){
        return deleteList(listRecordsToDelete, null, null, null);
    }
    public static Id insertList(List<sObject> listRecordsToInsert){
        return insertList(listRecordsToInsert, null);
    }
    public static Id updateList(List<sObject> listRecordsToUpdate){
        return updateList(listRecordsToUpdate, null);
    }
    public static Id deleteList(List<sObject> listRecordsToDelete){
        return deleteList(listRecordsToDelete, null);
    }
    public static Id insertRecord(sObject recordToInsert){
        return insertList(new List<sObject>{recordToInsert});
    }
    public static Id updateRecord(sObject recordToUpdate){
        return updateList(new List<sObject>{recordToUpdate});
    }
    public static Id deleteRecord(sObject recordToDelete){
        return deleteList(new List<sObject>{recordToDelete});
    }
    public static Id upsertRecord(sObject recordToUpsert){
        asyncDmlJob = new AsyncDmlHelper(new List<SObject>{recordToUpsert}, 'upsert',null, null, null);
        return System.enqueueJob(asyncDmlJob);
    }
}