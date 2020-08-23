public with sharing class AsyncDml{
    private static AsyncDmlHelper asyncDmlJob;
    /*
    * Details of input parameters.
    * @param listRecordsToInsert: list of records to insert.
    * @param isAllOrNone: DML option to specify if all or none records should be processed.
    * @param strCallbackMethod: Fully qualified API Name of callback method. The callback class MUST implement Callable interface.
    * @param chainedJob: the chainedJob to be executed on completion of the current job.
    * @return Id: jobId of enqueued job
    */
    public static Id insertList(List<sObject> listRecordsToInsert, Boolean isAllOrNone, String strCallbackMethod, Queueable chainedJob){
        asyncDmlJob = new AsyncDmlHelper(listRecordsToInsert, 'insert',isAllOrNone, strCallbackMethod, chainedJob);
        return System.enqueueJob(asyncDmlJob);
    }
    /*
    * Details of input parameters.
    * @param llistRecordsToUpdate: list of records to update.
    * @param isAllOrNone: DML option to specify if all or none records should be processed.
    * @param strCallbackMethod: Fully qualified API Name of callback method. The callback class MUST implement Callable interface.
    * @param chainedJob: the chainedJob to be executed on completion of the current job.
    * @return Id: jobId of enqueued job
    */
    public static Id updateList(List<sObject> listRecordsToUpdate, Boolean isAllOrNone, String strCallbackMethod, Queueable chainedJob){
        asyncDmlJob = new AsyncDmlHelper(listRecordsToUpdate, 'update',isAllOrNone, strCallbackMethod, chainedJob);
        return System.enqueueJob(asyncDmlJob);
    }
    /*
    * Details of input parameters.
    * @param listRecordsToDelete: list of records to delete.
    * @param isAllOrNone: DML option to specify if all or none records should be processed.
    * @param strCallbackMethod: Fully qualified API Name of callback method. The callback class MUST implement Callable interface.
    * @param chainedJob: the chainedJob to be executed on completion of the current job.
    * @return Id: jobId of enqueued job
    */
    public static Id deleteList(List<sObject> listRecordsToDelete, Boolean isAllOrNone, String strCallbackMethod, Queueable chainedJob){
        asyncDmlJob = new AsyncDmlHelper(listRecordsToDelete, 'delete', isAllOrNone, strCallbackMethod, chainedJob);
        return System.enqueueJob(asyncDmlJob);
    }
    /*
    * Details of input parameters.
    * @param listRecordsToInsert: list of records to insert.
    * @param isAllOrNone: DML option to specify if all or none records should be processed.
    * @param strCallbackMethod: Fully qualified API Name of callback method. The callback class MUST implement Callable interface.
    * @return Id: jobId of enqueued job
    */
    public static Id insertList(List<sObject> listRecordsToInsert, Boolean isAllOrNone, String strCallbackMethod){
        return insertList(listRecordsToInsert, isAllOrNone, strCallbackMethod, null);
    }
    /*
    * Details of input parameters.
    * @param llistRecordsToUpdate: list of records to update.
    * @param isAllOrNone: DML option to specify if all or none records should be processed.
    * @param strCallbackMethod: Fully qualified API Name of callback method. The callback class MUST implement Callable interface.
    * @return Id: jobId of enqueued job
    */
    public static Id updateList(List<sObject> listRecordsToUpdate, Boolean isAllOrNone, String strCallbackMethod){
        return updateList(listRecordsToUpdate, isAllOrNone, strCallbackMethod, null);
    }
    /*
    * Details of input parameters.
    * @param listRecordsToDelete: list of records to delete.
    * @param isAllOrNone: DML option to specify if all or none records should be processed.
    * @param strCallbackMethod: Fully qualified API Name of callback method. The callback class MUST implement Callable interface.
    * @return Id: jobId of enqueued job
    */
    public static Id deleteList(List<sObject> listRecordsToDelete, Boolean isAllOrNone, String strCallbackMethod){
        return deleteList(listRecordsToDelete, isAllOrNone, strCallbackMethod, null);
    }
    /*
    * Details of input parameters.
    * @param listRecordsToInsert: list of records to insert.
    * @param isAllOrNone: DML option to specify if all or none records should be processed.
    * @return Id: jobId of enqueued job
    */
    public static Id insertList(List<sObject> listRecordsToInsert, Boolean isAllOrNone){
        return insertList(listRecordsToInsert, isAllOrNone, null, null);
    }
    /*
    * Details of input parameters.
    * @param llistRecordsToUpdate: list of records to update.
    * @param isAllOrNone: DML option to specify if all or none records should be processed.
    * @return Id: jobId of enqueued job
    */
    public static Id updateList(List<sObject> listRecordsToUpdate, Boolean isAllOrNone){
        return updateList(listRecordsToUpdate, isAllOrNone, null, null);
    }
    /*
    * Details of input parameters.
    * @param listRecordsToDelete: list of records to delete.
    * @param isAllOrNone: DML option to specify if all or none records should be processed.
    * @return Id: jobId of enqueued job
    */
    public static Id deleteList(List<sObject> listRecordsToDelete, Boolean isAllOrNone){
        return deleteList(listRecordsToDelete, isAllOrNone, null, null);
    }
    /*
    * @param listRecordsToInsert: list to insert.
    * @return Id: jobId of enqueued job
    */
    public static Id insertList(List<sObject> listRecordsToInsert){
        return insertList(listRecordsToInsert, null, null, null);
    }
    /*
    * @param listRecordsToUpdate: list to update.
    * @return Id: jobId of enqueued job
    */
    public static Id updateList(List<sObject> listRecordsToUpdate){
        return updateList(listRecordsToUpdate, null, null, null);
    }
    /*
    * @param listRecordsToDelete: list to delete.
    * @return Id: jobId of enqueued job
    */
    public static Id deleteList(List<sObject> listRecordsToDelete){
        return deleteList(listRecordsToDelete, null, null, null);
    }
    /*
    * @param recordToInsert: record to insert.
    * @return Id: jobId of enqueued job
    */
    public static Id insertRecord(sObject recordToInsert){
        return insertList(new List<sObject>{recordToInsert}, null, null, null);
    }
    /*
    * @param recordToUpdate: record to update.
    * @return Id: jobId of enqueued job
    */
    public static Id updateRecord(sObject recordToUpdate){
        return updateList(new List<sObject>{recordToUpdate}, null, null, null);
    }
    /*
    * @param recordToDelete: record to delete.
    * @return Id: jobId of enqueued job
    */
    public static Id deleteRecord(sObject recordToDelete){
        return deleteList(new List<sObject>{recordToDelete}, null, null, null);
    }
    /*
    * @param recordToUpsert: record to upsert.
    * @return Id: jobId of enqueued job
    */
    public static Id upsertRecord(sObject recordToUpsert){
        asyncDmlJob = new AsyncDmlHelper(new List<SObject>{recordToUpsert}, 'upsert',null, null, null);
        return System.enqueueJob(asyncDmlJob);
    }
}