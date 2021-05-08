export const populateLeftGrid = (leftGrid:any, result:any) => {
    leftGrid.beta = trimmedInsideElement(result, "beta");
    leftGrid.sma20 = trimmedInsideElement(result, "moving_avg_20");
    leftGrid.ebidta = trimmedInsideElement(result, "ebitda");
    leftGrid.sma200 = trimmedInsideElement(result, "moving_avg_200");
    leftGrid.sma100 = trimmedInsideElement(result, "moving_avg_100");
    leftGrid.marketCap = trimmedInsideElement(result, "marketcap");
    leftGrid.p2E = trimmedInsideElement(result, "price_to_earnings");
    leftGrid.p2S = trimmedInsideElement(result, "price_to_sales");
    leftGrid.p2B = trimmedInsideElement(result, "price_to_book");
    leftGrid.currentPrice = trimmedInsideElement(result, "adjustedPrice");
    leftGrid.fiftyTwoWeek = "$" + trimmedInsideElement(result, "min_52_week")+ "-$" + trimmedInsideElement(result, "max_52_week");
    return leftGrid;
}
const trimmedInsideElement = (data:any, element:string) => {
  return (trimTwoDecimal(data[element][0][element]));
}
export const  trimTwoDecimal= (val:any) => {
      
      try {
        let index = val.indexOf(".");
        if (index != -1) {
          index = index + 3;
          val = val.substring(0,index);
          console.log(val);
        }
        return val;
      }
      catch (_err) {
        return val;
      }
    }
const trimFourDecimal = (val:string) => {
      try {
        let index = val.indexOf(".");
        index = index + 3;
        val = val.substring(0,index);
        console.log(val);
        return val;
      }
      catch (_err) {
        return val;
      }
    }