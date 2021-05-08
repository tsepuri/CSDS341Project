import api from './apiService'
export const UserService = {
  async login (username:string, password:string):Promise<boolean> {
    const params = new URLSearchParams();
    params.append('username', username);
    params.append('password', password);
    const result:any = await api.post('/?post=signIn', params);
    console.log(result);
    return result;
  },
  // Security issues for all the below ones, would need API key in full implementation
  async updateNotes (username: string, ticker: string, note:string):Promise<any> {
     const params = new URLSearchParams();
    params.append('username', username);
    params.append('ticker', ticker);
    params.append('note', note);
    const result:any = await api.post(`/?post=updateNotes`, params);
    return result;
  },
  
  async favorite (username: string, ticker: string):Promise<any> {
    const params = new URLSearchParams();
    params.append('username', username);
    params.append('ticker', ticker);
    const result:any = await api.post('/?post=favorite', params);
  }
}
