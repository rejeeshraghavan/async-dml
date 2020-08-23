public with sharing class AsyncDmlExtension implements Callable{
    public Object call(String action, Map<String,Object> args) {
        switch on action {
            when  'asyncCallback'{
                return this.asyncCallback((Id)args.get('jobId')
                                                , (String)args.get('strStatus')
                                                , (String)args.get('strErrorMessage')
                                                , (List<SObject>)args.get('listResult'));
            }
            when else {
                throw new DmlException('Method not implemented');
            }
        }
    }
    String asyncCallback(Id jobId, String strStatus, String strErrorMessage,List<SObject> listResult){
        System.debug(System.LoggingLevel.INFO,'jobId: '+ jobId);
        System.debug(System.LoggingLevel.INFO,'strStatus: '+ strStatus);
        System.debug(System.LoggingLevel.INFO,'strErrorMessage: '+ strErrorMessage);
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
}