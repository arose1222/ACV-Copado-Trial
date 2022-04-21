public class AccountSummary {
    
    public class Data {
        public Link links;
        public Integer accountTotal;
        public Integer id;
        public Integer owner;
        public Integer totalTransactions;
    }
    public class Link {
        public TransactionObj transactions;
    }
    public class TransactionObj {
        public String href;
        public List<String> methods;
    }

	public Integer api_version;
	public Data data;
	
	public static AccountSummary parse(String json) {
		return (AccountSummary) System.JSON.deserialize(json, AccountSummary.class);
	}
}