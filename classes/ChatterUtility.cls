public class ChatterUtility {

    public static void mentionTextRecordPost(Id recordId, String postText) {
        mentionTextRecordPost(null, recordId, postText);
    }


    public static void mentionTextRecordPost(Id userToMentionId, Id recordId, String postText) {
        mentionTextRecordPost(userToMentionId, recordId, postText, null, null);
    }

    // makes a simple chatter text post to the specified user from the running user
    public static void mentionTextRecordPost(Id userToMentionId, Id recordId, String postText, String linkUrl, String linkName) {
        ConnectAPI.FeedItemInput feedItemInput = new ConnectAPI.FeedItemInput();
        ConnectAPI.MentionSegmentInput mentionSegmentInput = new ConnectAPI.MentionSegmentInput();
        ConnectAPI.MessageBodyInput messageBodyInput = new ConnectAPI.MessageBodyInput();
        ConnectAPI.TextSegmentInput textSegmentInput = new ConnectAPI.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectAPI.MessageSegmentInput>();

        if (userToMentionId != null) {
            mentionSegmentInput.id = userToMentionId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
        }

        if (linkUrl != null) {
            ConnectApi.LinkCapabilityInput linkInput = new ConnectApi.LinkCapabilityInput();
            linkInput.url = linkUrl;
            linkInput.urlName = linkName;

            ConnectApi.FeedElementCapabilitiesInput feedElementInput = new ConnectApi.FeedElementCapabilitiesInput();
            feedElementInput.link = linkInput;

            feedItemInput.capabilities = feedElementInput;
        }

        textSegmentInput.text = postText;
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectAPI.FeedElementType.FeedItem;
        feedItemInput.subjectId = recordId;

        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    }

    public static void mentionTextRecordPostBatch(List<chatterWrapper> messageList){
        List<ConnectAPI.BatchInput> batchList = new List<ConnectAPI.BatchInput>();

        for(chatterWrapper cw :messageList){
            ConnectAPI.FeedItemInput input = new ConnectAPI.FeedItemInput();
            input.subjectId = cw.recordId;

            ConnectAPI.MessageBodyInput body = new ConnectAPI.MessageBodyInput();
            body.messageSegments = new List<ConnectAPI.MessageSegmentInput>();

            ConnectAPI.TextSegmentInput textSegment = new ConnectAPI.TextSegmentInput();
            textSegment.text = cw.postText;
            body.messageSegments.add(textSegment);

            if (cw.userToMentionId != null) {
                ConnectAPI.MentionSegmentInput mentionSegmentInput = new ConnectAPI.MentionSegmentInput();
                mentionSegmentInput.id = cw.userToMentionId;
                body.messageSegments.add(mentionSegmentInput);
            }

            if (cw.linkInput != null) {
                ConnectApi.LinkCapabilityInput linkInput = new ConnectApi.LinkCapabilityInput();
                linkInput.url = cw.linkInput;
                linkInput.urlName = cw.linkName;

                ConnectApi.FeedElementCapabilitiesInput feedInput = new ConnectApi.FeedElementCapabilitiesInput();
                feedInput.link = linkInput;

                input.capabilities = feedInput;
            }

            input.body = body;
            ConnectAPI.BatchInput batchInput = new ConnectAPI.BatchInput(input);
            batchList.add(batchInput);
        }

        if (batchList.size() > 0) {
            ConnectAPI.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(),batchList);
        }
    }

    public class chatterWrapper{
        Id userToMentionId {get; set;}
        Id recordId        {get; set;}
        String postText    {get; set;}
        String linkInput   {get; set;}
        String linkName    {get; set;}

        public chatterWrapper() {}

        public chatterWrapper(Id recordId, String postText){
            this.recordId = recordId;
            this.postText = postText;
        }

        public chatterWrapper(Id recordId, String postText, Id userToMentionId){
            this.recordId = recordId;
            this.postText = postText;
            this.userToMentionId = userToMentionId;
        }

        public chatterWrapper(Id recordId, String postText, Id userToMentionId, String linkInput, String linkName) {
            this.recordId = recordId;
            this.postText = postText;
            this.userToMentionId = userToMentionId;
            this.linkInput = linkInput;
            this.linkName = linkName;
        }
    }
}