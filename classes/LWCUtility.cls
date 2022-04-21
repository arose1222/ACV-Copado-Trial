public class LWCUtility {
    
    public class Picklist{
        public string label {get;set;}
        public string value {get;set;}

        /**
         * picklist Initalize picklist object without lable and value
         * @return   null
         */
        public picklist(){
            this.label = '';
            this.value = '';
        }

        /**
         * picklist Initalize picklist object with lable and value
         * @param  label string that is to be displayed to the end user
         * @param  value string that is to be used by the backend
         * @return       void
         */ 
        public picklist(string label, string value){
            this.label = label;
            this.value = value;
        }
    }
}