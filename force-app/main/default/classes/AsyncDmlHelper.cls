public with sharing class AsyncDmlHelper implements Queueable {
    private List<sObject> listSObject;
    private Boolean allOrNone=true;// default true
    private String strOperation;//List<SObject> only allows insert, update or delete. upsert is allowed only for single record. 
    private Set<String> setOperations = new Set<String>{'insert','update', 'delete', 'upsert'};
    private Queueable chainedJob;
    private String strCallbackMethod;

    private Id jobId;
    private String strErrorMessage;
    private Database.SaveResult[] listSaveResult;
    private Database.UpsertResult[] listUpsertResult;
    private Database.DeleteResult[] listDeleteResult;
    /*
    * Description: Constructor to set AsyncDmlHelper variables.
    * @param listRecords: record to perform DML operation.
    * @param strOperation: DML operation.
    * @param isAllOrNone: DML option of all or none records.
    * @param strCallbackMethod: Fully qualified API Name of callback method. The callback class MUST implement Callable interface.
    * @param chainedJob: the chainedJob to be executed on completion of the current job.
    * @return n/a
    */
    public AsyncDmlHelper(List<sObject> listRecords, String strOperation, Boolean isAllOrNone, String strCallbackMethod, Queueable chainedJob){
        this.strOperation = this.setOperations.contains(strOperation.toLowerCase())?strOperation.toLowerCase():null;
        if(String.isNotBlank(this.strOperation)){
            this.listSObject = listRecords;
            this.allOrNone = isAllOrNone==null?true:isAllOrNone;
            this.strCallbackMethod = strCallbackMethod;
            this.chainedJob = chainedJob;
        }
    }
    /*
    * Description: execute method of Queueable interface.
    * @param context: QueueableContext type object
    * @return void
    */
    public void execute(QueueableContext context) {
        this.jobId = context.getJobId();
        try{
            if(this.listSObject!= null && !this.listSObject.isEmpty()){
                switch on this.strOperation {
                    when 'insert'{
                        this.listSaveResult = Database.insert(this.listSObject,this.allOrNone);
                    }
                    when 'update'{
                        this.listSaveResult = Database.update(this.listSObject,this.allOrNone);
                    }
                    when 'upsert'{
                        this.listUpsertResult = new List<Database.UpsertResult>();
                        listUpsertResult.add(Database.upsert(this.listSObject[0]));
                    }
                    when 'delete'{
                        this.listDeleteResult = Database.delete(this.listSObject,this.allOrNone);
                    }
                    when else {
                        throw new DmlException('Operation not allowed.');
                    }
                }
            }
            if(String.isNotBlank(this.strCallbackMethod)){
                invokeCallbackMethod('success', getResult());
            }
            if(this.chainedJob != null){
                System.enqueueJob(this.chainedJob);
            }
        }catch(Exception ex){
            if(String.isNotBlank(this.strCallbackMethod)){
                this.strErrorMessage = ex.getMessage();
                invokeCallbackMethod('failure', (List<Object>) this.listSObject);
            }else{
                throw new DmlException(ex.getMessage());
            }
        }
    }
    /*
    * Description: Method to invoke callback method.
    * @param strStatus: status of DML operation.
    * @param listResult: result of DML Operation. If successful, pass saveresult, else if failure pass input record list.
    * @return void
    */
    private void invokeCallbackMethod(String strStatus, List<Object> listResult){
        if(String.isBlank(this.strCallbackMethod)){return;}

        String strClassName = this.strCallbackMethod.split('\\.')[0],
            strMethodName = this.strCallbackMethod.split('\\.')[1];
        
        Callable extension = (Callable) Type.forName(strClassName).newInstance();
        extension.call(strMethodName, new Map<String,Object>{
            'jobId' => this.jobId
            , 'strStatus' => strStatus
            , 'strErrorMessage' => this.strErrorMessage
            , 'listResult' => listResult 
        });
    }
    /*
    * Description: Method to get the DML operation result.
    * @param void
    * @return listResult: The result according to DML operation
    */
    private List<Object> getResult(){
        List<Object> listResult = new List<Object>();
        if(this.listSaveResult != null){
            listResult.addAll(this.listSaveResult);
        }else if(this.listUpsertResult != null){
            listResult.addAll(this.listUpsertResult);
        }else if(this.listDeleteResult != null){
            listResult.addAll(this.listDeleteResult);
        }
        return listResult;
    }
}