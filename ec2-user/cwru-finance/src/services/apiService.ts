import axios from 'axios'
const api = axios.create({
  baseURL: 'https://databases.money/Api',
  headers: {
    withCredentials: false
  }
});
api.interceptors.response.use(
  res => {
    console.log(res);
    /*
    if("Error" in res.data){
      throw new Error(res.data);
    }
    */
    return res.data;
  }
)
export default api;