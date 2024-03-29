public with sharing class AsyncDmlExtension implements Callable{
    public Object call(String action, Map<String,Object> args) {
        switch on action {
            when  'asyncCallback'{
                return this.asyncCallback((Id)args.get('jobId')
                                                , (String)args.get('strStatus')
                                                , (String)args.get('strErrorMessage')
                                                , (Integer)args.get('intExecutionCount')
                                                , (List<Object>)args.get('listResult'));
            }
            when  'asyncCallbackRetry'{
                return this.asyncCallbackRetry((Id)args.get('jobId')
                                                , (String)args.get('strStatus')
                                                , (String)args.get('strErrorMessage')
                                                , (Integer)args.get('intExecutionCount')
                                                , (List<Object>)args.get('listResult'));
            }
            when else {
                throw new DmlException('Method not implemented');
            }
        }
    }
    String asyncCallback(Id jobId, String strStatus, String strErrorMessage,Integer intExecutionCount, List<Object> listResult){
        System.debug(System.LoggingLevel.INFO,'jobId: '+ jobId);
        System.debug(System.LoggingLevel.INFO,'strStatus: '+ strStatus);
        System.debug(System.LoggingLevel.INFO,'strErrorMessage: '+ strErrorMessage);
        System.debug(System.LoggingLevel.INFO,'intExecutionCount: '+ intExecutionCount);
        System.debug(System.LoggingLevel.INFO,'listResult: '+ listResult);
        Database.insert(
            new Task(
                Subject = strStatus,
                OwnerId = UserInfo.getUserId(),
                Description = 'JobId: ' + String.valueOf(jobId)
            )
        );
        return null;
    }
    String asyncCallbackRetry(Id jobId, String strStatus, String strErrorMessage,Integer intExecutionCount, List<Object> listResult){
        System.debug(System.LoggingLevel.INFO,'jobId: '+ jobId);
        System.debug(System.LoggingLevel.INFO,'strStatus: '+ strStatus);
        System.debug(System.LoggingLevel.INFO,'strErrorMessage: '+ strErrorMessage);
        System.debug(System.LoggingLevel.INFO,'intExecutionCount: '+ intExecutionCount);
        System.debug(System.LoggingLevel.INFO,'listResult: '+ listResult);
        Integer MAX_RETRY = 3;
        List<SObject> listRecords = new List<SObject>();
        for(Object obj : listResult){
            listRecords.add((SObject)obj);
        }
        if(intExecutionCount<MAX_RETRY){
            Dml.deleteAsync(listRecords)
                .callback('AsyncDmlExtension.asyncCallbackRetry')
                .executionCount(intExecutionCount+1)
                .submit();
        }else{
            Database.insert(
                new Task(
                    Subject = strStatus,
                    OwnerId = UserInfo.getUserId(),
                    Description = 'JobId: ' + String.valueOf(jobId)
                )
            );
        }
        return null;
    }
}