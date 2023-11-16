public with sharing class AsyncDmlHelper implements Queueable {
        private List<sObject> listSObject;
        private Boolean allOrNone=true;
        private String strOperation;
        private Set<String> setOperations= new Set<String>{'insert','update', 'delete', 'upsert'};
        private String strChainedJob;
        private String strCallbackMethod;
        private Integer intExecutionCount;
    
        private Id jobId;
        private String strErrorMessage;
        private Database.SaveResult[] listSaveResult;
        private Database.UpsertResult[] listUpsertResult;
        private Database.DeleteResult[] listDeleteResult;
    
        /*
        * @param listRecords: record to perform DML operation.
        * @return AsyncDmlHelper: updated AsyncDmlHelper object with records to perfrorm DML operation
        */
        public AsyncDmlHelper records(List<sObject> listRecords){
            this.listSObject = listRecords;
            return this;
        }
        /*
        * @param strOperation: DML operation.
        * @return AsyncDmlHelper: updated AsyncDmlHelper object with DML operation option
        */
        public AsyncDmlHelper operation(String strOperation){
            this.strOperation = this.setOperations.contains(strOperation.toLowerCase())?strOperation.toLowerCase():null;
            return this;
        }
        /*
        * @param isAllOrNone: DML option of all or none records.
        * @return AsyncDmlHelper: updated AsyncDmlHelper object with AllOrNone option
        */
        public AsyncDmlHelper isAllOrNone(Boolean isAllOrNone){
            this.allOrNone = isAllOrNone==null?true:isAllOrNone;
            return this;
        }
        /*
        * @param strCallbackMethod: Fully qualified API Name of callback method. The callback class MUST implement Callable interface.
        * @return AsyncDmlHelper: updated AsyncDmlHelper object with callback method details
        */
        public AsyncDmlHelper callback(String strCallbackMethod){
            this.strCallbackMethod = strCallbackMethod;
            return this;
        }
        /*
        * @param chainedJob: the chainedJob to be executed on completion of the current job.
        * @return AsyncDmlHelper: updated AsyncDmlHelper object with chained job details
        */
        public AsyncDmlHelper chainedJob(Queueable chainedJob){
            this.strChainedJob = JSON.serialize(chainedJob);
            return this;
        }
        /*
        * @param intExecutionCount: number of times this job is retried.
        * @return AsyncDmlHelper: updated AsyncDmlHelper object with job execution count details
        */
        public AsyncDmlHelper executionCount(Integer intExecutionCount){
            this.intExecutionCount = intExecutionCount;
            return this;
        }
        /*
        * @param void
        * @return Id: job Id of enqueued job
        */
        public Id submit(){
            return System.enqueueJob(this);
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
                if(String.isNotBlank(this.strChainedJob)
                    && !Test.isRunningTest()){
                    System.enqueueJob(
                        (AsyncDmlHelper)JSON.deserialize(
                            this.strChainedJob, AsyncDmlHelper.class));
                }
            }catch(Exception ex){
                if(String.isNotBlank(this.strCallbackMethod)){
                    System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
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
            extension.call(strMethodName, new Map<String,Object>
                {
                    'jobId' => this.jobId
                    , 'strStatus' => strStatus
                    , 'strErrorMessage' => this.strErrorMessage
                    , 'listResult' => listResult 
                    , 'intExecutionCount' => this.intExecutionCount==null?1:this.intExecutionCount
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