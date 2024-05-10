public class UserWrapper {

	public class Attributes {
		public String type;
		public String url;
	}

	public class Records {
		public Attributes attributes;
		public String Id;
		public String Name;
		public String Username;
		public String Email;
	}

	public Integer totalSize;
	public Boolean done;
	public List<Records> records;
}