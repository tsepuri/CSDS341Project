<template>
  <div class="home">
    <h1>{{ state.searchedTerm }}  <font-awesome-icon @click="favoriteToggle" class="star" :class="[state.favorited ? 'yellowStar' : 'greyStar']" icon="star" /></h1>
     
    <div v-if="state.goodSearch">
      <section class="sectionOne">
      <div class="leftSide">
     <h2>{{state.ticker}}</h2>
    <h2>${{leftGrid.currentPrice}} on {{state.currentDate}}</h2>
      <div class="gridVals">
    <div>
      Market Cap: ${{ leftGrid.marketCap }}
      <hr/>
    </div>
    <div>
        Price to Earnings: {{ leftGrid.p2E }}x
      <hr/>
    </div>
    <div>
      Price to Book: {{ leftGrid.p2B }}x
      <hr/>
    </div>
    <div>
      Price to Sales: {{ leftGrid.p2S }}x
      <hr/>
    </div>
    <div>
      20 SMA: ${{ leftGrid.sma20}} 
      <hr/>
    </div>
    <div>
      Beta: {{leftGrid.beta}}
      <hr/>
    </div>
    <div> 
      100 SMA: ${{leftGrid.sma100}}
      <hr/>
    </div>
    <div>
      EV/ EBIDTA: {{ leftGrid.ebidta }} 
      <hr/>
    </div>
    <div> 
      200 SMA: ${{leftGrid.sma200}}
      <hr/>
    </div>
    <div>
      52 Week Range: {{leftGrid.fiftyTwoWeek}}
      <hr/>
    </div>
    </div>
    <DatePicker @newDate="updateSummary"></DatePicker>
    <div v-if="state.wrongDate" class="red">Data not available for this day.</div>
    <div id="description">{{ state.description }}</div>
    </div>
    <div class ="chartSide">
    <div>
      <h3>Price and Volume</h3>
    <apexchart
      width="500"
      type="line"
      :options="state.chartOptions"
      :series="state.series"
      float: right
    ></apexchart>
    <apexchart
      class = "volumeChart"
      width="500"
      type="bar"
      :options="state.chartOptions2"
      :series="state.series2"
      height="50%"
      float: right
    ></apexchart>
    </div>
    <br>
    <Slider v-model="state.dateRange" :range="true" step="86400" :min="1420174800" :max="1609304400" />
    <h5>{{ parsedDateRange }}<button @click ="newGraph" class="button small-button">Change</button></h5>
    <br>
    <textarea @change="state.changed = true" v-model="state.note" class="textInput" placeholder="Add a note..."/> 
     <br>
     <button @click="submitNotes"  class="button small-button">Save</button>
    </div>
    </section>
    <button type="submit" class="button" :class="{active:state.current==='management'}" @click="management">Management Info</button>
    <button type="submit" class="button" :class="{active:state.current==='investors'}"  @click="institutional">Institutional Investors</button>
    <button type="submit" class="button" :class="{active:state.current==='insiders'}" @click="insider">Insider Traders</button>
    <button type="submit" class="button" :class="{active:state.current==='financials'}" @click="financial">Financials</button>
    <DataTable :value="state.tableData" sortMode="multiple">
        <Column @click="modalBox" v-for="col of state.columns" :field="col.field" :header="col.header" :key="col.field" :sortable="true" :showFilterMenu="true"></Column>
</DataTable>
  <Dialog header="Header" v-model:visible="state.displayResponsive" :breakpoints="{'960px': '75vw'}" :style="{width: '50vw'}">
            
            <template #footer>
                <Button label="No" icon="pi pi-times" @click="closeResponsive" class="p-button-text"/>
                <Button label="Yes" icon="pi pi-check" @click="closeResponsive" autofocus />
            </template>
</Dialog>

    </div>
    <div v-else>
      <ProgressSpinner/>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, reactive, ref, computed, onMounted } from 'vue';
import Slider from 'primevue/slider';
import ProgressSpinner from 'primevue/progressspinner';
import { default as dayjs } from 'dayjs';
import router from '@/router';
import store from '@/store';
import * as cols from '@/types/tableColumns.ts';
import * as charts from '@/types/chartOptions.ts';
import { getSearchResults, getCompanyName } from '@/services/searchBar.ts'
import { getUserInfo } from '@/services/userInfo.ts'
import DatePicker from '@/components/DatePicker.vue';
import { StockService, populateLeftGrid, UserService, trimTwoDecimal } from '@/services';
export default defineComponent({
  name: 'Home',
  props: ["ticker"],
  setup(props) {
    const state = reactive({
      reloaded: false,
      current: 'management',
      searchedTerm: props.ticker,
      dateRange: [dayjs('2015-01-02').unix(), dayjs('2020-12-30').unix()],
      dateRangeNow: [dayjs('2015-01-02').unix(), dayjs('2020-12-30').unix()],
      chartOptions: charts.chartOptions([]),
      chartOptions2: charts.chartOptions2([]),
      series: [
        {
          name: "Average price (USD)",
          data: [30, 40, 35, 50, 49, 60, 70],
        },
      ],
      series2: [
        {
          name: "Volume (Num. of shares)",
          data: [30, 40, 35, 50, 49, 60, 70],
        },
      ],
      columns: [{
        header: '',
        field: ''
      }],
      price_and_volume: [{
        "date": 0,
        "volume": 0,
        "price_and_volume": 0
      }],
      insiders: [],
      financials: [],
      institutional: [],
      managers : [],
      badSearch: false, 
      goodSearch: false,
      currentPrice : '',
      ticker: props.ticker,
      favorited: false,
      description: '',
      tableData: [],
      currentDate: '12/30/2020',
      wrongDate: false,
      displayResponsive: false,
      changed: false,
      note: ''
      
    });
   state.columns = cols.managerColumns;
    const modalBox = () => {
      state.displayResponsive = true;
    }
    const closeResponsive = () => {
      state.displayResponsive = false;
    }
    const newGraph = () => {
      state.series[0].data = [];
      state.series2[0].data = [];
      let newCategories = [];
      for (let price of state.price_and_volume) {
            if (dayjs(price.date).unix() < state.dateRange[0]) {
              continue;
            }
            else if (dayjs(price.date).unix() > state.dateRange[1]) {
              break;
            }
            state.series[0].data.push(price.price_and_volume);
            state.series2[0].data.push(price.volume);
            newCategories.push(price.date);
     }
     state.dateRangeNow = state.dateRange;
     state.chartOptions = charts.chartOptions(newCategories);
     state.chartOptions2 = charts.chartOptions2(newCategories);
    }
     
    const initialDateRange = computed(() => (`${dayjs.unix(state.dateRangeNow[0]).format("MM/DD/YYYY")} to ${dayjs.unix(state.dateRangeNow[1]).format("MM/DD/YYYY")}`));
    const parsedDateRange = computed(() => (`${dayjs.unix(state.dateRange[0]).format("MM/DD/YYYY")} to ${dayjs.unix(state.dateRange[1]).format("MM/DD/YYYY")}`));
    const favoriteToggle = async() => {
      state.favorited = !state.favorited;
      let favoriteToggle = await UserService.favorite(store.getters.username, props.ticker);
      console.log(favoriteToggle);
    }
    const submitNotes = async() => {
      let notesUpdated = await UserService.updateNotes(store.getters.username, props.ticker, state.note);
      console.log(notesUpdated);
    }
    const management = () => {
      state.current = "management";
      state.columns = cols.managerColumns;
      state.tableData = state.managers;
    }
    const institutional = () => {
      state.current = "investors";
      state.columns = cols.institutionalColumns;
      state.tableData = state.institutional;
    }
    const insider = () => {
      state.current = "insiders";
      state.columns = cols.insiderColumns;
      state.tableData = state.insiders;
    }
    const financial = () => {
      state.current = "financials";
      state.columns = cols.financialColumns;
      state.tableData = state.financials;
    }
    router.afterEach((to, from) => {
          if (to !== from && to.fullPath.includes("company")) {
            router.go(0);
          }
      });
    const updateSummary = async (date:string) => {
      state.wrongDate = false;
      let result = await StockService.newSummaryStats(props.ticker, date);
      try {
      leftGrid = populateLeftGrid(leftGrid, result);
      state.currentDate = dayjs(date).format("MM/DD/YYYY");
      }
      catch (err) {
        state.wrongDate = true;
      }
    }
    const trim = (assets:any) => {
      for (let asset of assets) {
        for (const [key, value] of Object.entries(asset)) {
        asset[key] = trimTwoDecimal(value);
      }
      }
     return assets;
    }
    const cleanInsiderData = (insiders:any) => {
      for (let insider of insiders) {
        insider.acquisition_disposition = insider.acquisition_disposition === "1" ? "D" : "A";
      }
      return insiders;
    }
    let leftGrid:any = {};
    onMounted(async() => {
          let result = await StockService.onLoad(props.ticker, "Tarun", "2020-12-30");  
          state.description = result.description[0].description;
          state.goodSearch = true;
          if (result.user_info.length > 0) {
           state.note = result.user_info[0].user_info;
           state.favorited = result.user_info[0].is_favorited === "1";
          }
          if (store.getters.searchBarInfo.length === 0) {
            let searchResults = getSearchResults(result);
            store.commit('setSearchBarInfo', searchResults);
          }
          state.searchedTerm = getCompanyName(result, props.ticker);
          let favorites = getUserInfo(result);
          store.commit('setFavorites', favorites);
          leftGrid = populateLeftGrid(leftGrid, result);
          state.managers = result.name;
          state.institutional = result.asset_manager;
          state.financials = trim(result.total_assets);
          state.insiders = cleanInsiderData(result.reporting_owner);
          state.tableData = state.managers;
          state.series[0].data = [];
          state.series2[0].data = [];
          let newCategories = [];
          state.price_and_volume = result.price_and_volume;
          for (let price of result.price_and_volume) {
            state.series[0].data.push(price.price_and_volume);
            state.series2[0].data.push(price.volume);
            newCategories.push(price.date);
          }
          state.chartOptions2 = charts.chartOptions2(newCategories);
          state.chartOptions = charts.chartOptions(newCategories);
        });
    return { state, management, institutional, insider, financial, leftGrid, parsedDateRange, initialDateRange, favoriteToggle, updateSummary, newGraph, modalBox, closeResponsive, submitNotes };
  },
  components: {
    DatePicker, Slider, ProgressSpinner
  },
});
</script>
<style scoped type="text/css">
  .sectionOne {
    margin: 2rem;
    padding: 2rem;
    display: grid;
    grid-column: auto;
    grid-template-columns: 1fr 1fr;
    column-gap: 4rem;
  }
  .gridVals {
    display: grid;
    align-items: center;
    grid-template-columns: 1fr 1fr;
  }
  .rightSide {
    margin-top: 3rem;
  }
  #description {
    background-color: #f4f4f4;
    max-width: 100%;
    padding: 1rem;
    margin: 0.5rem;
    
  }
  .active {
    background-color: #599eab;
  }
  .p-slider-horizontal, .p-inputtext {
    width: 14rem;
    margin: auto;
}
.p-slider-vertical {
     height: 14rem;
     margin: auto;
}
font-awesome-icon {
  width: 5rem;
}
.star {
  cursor: pointer;
}
.yellowStar {
  color: gold;
}
.greyStar {
  color: #f0f0f0;
}
  
.volumeChart {
    margin-top: -120px;
}
.red {
  color: red;
}
.textInput {
  font-family: Helvetica;
  height: 10%;
  width: 80%;
  margin-right: 10%;
}
.small-button {
    font-size: 0.9rem;
    padding: 0.5rem 1rem;
}
</style>
