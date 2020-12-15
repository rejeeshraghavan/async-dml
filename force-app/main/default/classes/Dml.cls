public with sharing class Dml {
    private static AsyncDmlHelper asyncDmlJob= new AsyncDmlHelper();
    private static String INSERT_OP='insert',
                            UPDATE_OP='update',
                            DELETE_OP='delete',
                            UPSERT_OP='upsert';
    /*
    * @param listRecordsToInsert: list to insert.
    * @return AsyncDmlHelper: updated AsyncDmlHelper object with insert operation option for a list of records
    */
    public static AsyncDmlHelper insertAsync(List<SObject> listRecordsToInsert){
        asyncDmlJob.records(listRecordsToInsert);
        asyncDmlJob.operation(INSERT_OP);
        return asyncDmlJob;
    }
    /*
    * @param recordToInsert: record to insert.
    * @return AsyncDmlHelper: updated AsyncDmlHelper object with insert operation option for an individual record
    */
    public static AsyncDmlHelper insertAsync(sObject recordToInsert){
        return insertAsync(new List<SObject>{recordToInsert});
    }
    /*
    * @param listRecordsToUpdate: list to update.
    * @return AsyncDmlHelper: updated AsyncDmlHelper object with update operation option for a list of records
    */
    public static AsyncDmlHelper updateAsync(List<SObject> listRecordsToUpdate){
        asyncDmlJob.records(listRecordsToUpdate);
        asyncDmlJob.operation(UPDATE_OP);
        return asyncDmlJob;
    }
    /*
    * @param recordToUpdate: record to update.
    * @return AsyncDmlHelper: updated AsyncDmlHelper object with update operation option for an individual record
    */
    public static AsyncDmlHelper updateAsync(sObject recordToUpdate){
        return updateAsync(new List<SObject>{recordToUpdate});
    }
    /*
    * @param listRecordsToDelete: list to delete.
    * @return AsyncDmlHelper: updated AsyncDmlHelper object with delete operation option for a list of records
    */
    public static AsyncDmlHelper deleteAsync(List<SObject> listRecordsToDelete){
        asyncDmlJob.records(listRecordsToDelete);
        asyncDmlJob.operation(DELETE_OP);
        return asyncDmlJob;
    }
    /*
    * @param recordToDelete: record to delete.
    * @return AsyncDmlHelper: updated AsyncDmlHelper object with delete operation option for an individual record
    */
    public static AsyncDmlHelper deleteAsync(sObject recordToDelete){
        return deleteAsync(new List<SObject>{recordToDelete});
    }
    /*
    * @param recordToUpsert: record to upsert.
    * @return AsyncDmlHelper: updated AsyncDmlHelper object with upsert operation options
    */
    public static AsyncDmlHelper upsertAsync(sObject recordToUpsert){
        asyncDmlJob.records(new List<SObject>{recordToUpsert});
        asyncDmlJob.operation(UPSERT_OP);
        return asyncDmlJob;
    }
}