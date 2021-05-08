export const getUserInfo= (data:any) => {
      let arr = [];
      try {
        for (var i = 0; i < data["favorited"].length; i++) {
            let favorited = data["favorited"][i]["favorited"];
            let output = favorited;
            arr.push(output)
        }
        return arr;
      }
      catch (_err) {
        return arr;
      }
    }