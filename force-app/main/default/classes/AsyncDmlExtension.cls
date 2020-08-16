public with sharing class AsyncDmlExtension implements Callable{
    public Object call(String action, Map<String,Object> args) {
        switch on action {
            when  'asyncDmlExtension'{
                return this.callbackMethod((Id)args.get('jobId')
                                                , (String)args.get('strStatus')
                                                , (String)args.get('strErrorMessage')
                                                , (List<Object>)args.get('listResult'));
            }
            when else {
                throw new DmlException('Method not implemented');
            }
        }
    }
    String callbackMethod(Id jobId, String strStatus, String strErrorMessage,List<Object> listResult){
        System.debug(System.LoggingLevel.INFO,'jobId: '+ jobId);
        System.debug(System.LoggingLevel.INFO,'strStatus: '+ strStatus);
        System.debug(System.LoggingLevel.INFO,'strErrorMessage: '+ strErrorMessage);
        System.debug(System.LoggingLevel.INFO,'listResult: '+ listResult);
        return null;
    }
}