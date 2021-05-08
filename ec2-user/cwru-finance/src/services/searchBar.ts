export const getSearchResults= (data:any) => {
      let arr = [];
      try {
        arr = [];
        for (let i = 0; i < data["searchBarInfo"].length; i++) {
            const ticker = data["searchBarInfo"][i]["searchBarInfo"];
            const name = data["searchBarInfo"][i]["name"];
            const output = name + " (" + ticker + ")";
            arr.push(output)
        }
        console.log("HEY");
        console.log(arr);
        return arr;
      }
      catch (_err) {
        return arr;
      }
    }
export const getCompanyName = (data:any, ticker:any) => {
  let name = "";
  try {
    for (let searchInfo of data.searchBarInfo) {
      if (ticker === searchInfo.searchBarInfo) {
        return searchInfo.name;
      }
    }
  }
  catch (_err) {
    return name;
  }
  return name;
}