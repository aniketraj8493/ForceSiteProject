public class ChatterComponentController {
    public String id {get; set;}
    @testVisible String msg;
    
    public ChatterComponentController(){
        
    }
    public void setMsg(String m){
        if(msg != m)
            msg=m;
    }
    public string getMsg(){
        return msg;
    }
    public Pagereference post(){
        String communityId = null;
        String feedElementId = '0D50b00005KV2uTCAT';
       
        ConnectApi.CommentInput commentInput = new ConnectApi.CommentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        textSegmentInput.text = msg;
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        mentionSegmentInput.id = '0050b000004RFh7';
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        commentInput.body = messageBodyInput;
        
        try{
                ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postCommentToFeedElement(communityId, feedElementId, commentInput, null);
             apexpages.addMessage(new ApexPages.message(apexpages.Severity.CONFIRM, 'Successfully Post'));
        }catch(Exception e){
            apexpages.addMessage(new ApexPages.message(apexpages.Severity.ERROR, 'Somthing is wrong'));
        }
        return null;
    }
    
}