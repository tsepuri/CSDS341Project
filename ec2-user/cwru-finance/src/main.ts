import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import store from './store';
import '@/assets/css/main.css';
import VueApexCharts from "vue3-apexcharts";
import PrimeVue from 'primevue/config';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import 'primevue/resources/themes/saga-blue/theme.css';      //theme
import 'primevue/resources/primevue.min.css';                //core css
import 'primeicons/primeicons.css';
import { library } from '@fortawesome/fontawesome-svg-core';
import { 
    faStar
} from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";

library.add(faStar);
createApp(App).use(router).use(store).use(VueApexCharts).use(PrimeVue).component('DataTable', DataTable)
.component('Column', Column).component("font-awesome-icon", FontAwesomeIcon).mount('#app')
