import api from './apiService'
export const StockService = {
  async onLoad (ticker: string, username: string, date:string) {
    
    const result:any = await api.get('/', {
        params: {
            get:"onLoad", ticker, date, username
        }
    })
    return result;
  },
  async newSummaryStats (ticker: string, date:string) {
      const result:any = await api.get('/', {
        params: {
            get: "updateSummaryStats", ticker, date
        }
    })
    return result;
  },
  async executiveModalBox (name: string) {
      const result:any = await api.get('/executiveModalBox', {
        params: {
            name
        }
    })
    return result;
  },
  async institutionModalBox (company: string) {
      const result:any = await api.get('/institutionModalBox', {
        params: {
            company
        }
    })
    return result;
  }
}
