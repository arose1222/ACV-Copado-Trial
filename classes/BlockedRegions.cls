public class BlockedRegions {

	public String api_version;
	public List<String> data;

	
	public static BlockedRegions parse(String json) {
		return (BlockedRegions) System.JSON.deserialize(json, BlockedRegions.class);
	}
}