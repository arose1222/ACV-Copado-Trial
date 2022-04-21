({
    getCeilingPrice: function (floor_ceiling_price) {
        if(floor_ceiling_price == null) {
            return "Unavailable"
        }
        return this.formatCurrency(floor_ceiling_price.ceiling_price);
    },
    getFloorPrice: function(floor_ceiling_price) {
        if(floor_ceiling_price == null) {
            return "Unavailable"
        }
        return this.formatCurrency(floor_ceiling_price.floor_price);
    },    
    formatCurrency: function(amount) {
        try {
          const thousands = ","  
          const amountString = amount.toString();
          const thousandsIndex = (amountString.length > 3) ? amountString.length % 3 : 0;  
          return (thousandsIndex ? amountString.substr(0, thousandsIndex) + thousands : '') + 
                  amountString.substr(thousandsIndex).replace(/(\d{3})(?=\d)/g, "$1" + thousands);
        } catch (e) {
          console.log(e)
        }
    },
    logErrors: function(errors) {
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.log("Error message: " + errors[0].message);
            }
        } else {
            console.log("Unknown error");
        }
    }
})