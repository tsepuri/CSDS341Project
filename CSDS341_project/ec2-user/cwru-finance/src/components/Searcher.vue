<template>
    <div class="searchbar-container">
        <AutoComplete :inputClass="searchbar" class="searchbar" @keyup.enter = "message" v-model="state.selectedCompany" :suggestions="state.filteredCompanies" @complete="searchCompany($event)" placeholder="Search for a company" />
    </div>
</template>
<script lang="ts">
import store from '@/store';
import AutoComplete from 'primevue/autocomplete';
import {FilterService,FilterMatchMode} from 'primevue/api';
import { defineComponent, reactive, onMounted, ref } from 'vue'
export default defineComponent({
    name:'Searcher',
    setup(_, { emit }) {
        /*
        onMounted(() => {
            companies = store.getters.searchBarInfo;
            console.log(companies);
        })
        */
        const state = reactive({
            term: '',
            companies: store.getters.searchBarInfo,
            selectedCompany: "",
            filteredCompanies: [""]
        })
    console.log(state.companies);
    const searchCompany= (event:any) => {
            setTimeout(() => {
                if (state.companies.length === 0) {
                    state.companies = store.getters.searchBarInfo;
                }
                console.log(state.companies);
                if (!event.query.trim().length) {
                    state.filteredCompanies = [...state.companies];
                }
                else {
                    state.filteredCompanies = state.companies.filter((company:any) => {
                        return company.toLowerCase().includes(event.query.toLowerCase());
                    });
                }
            }, 500);
        };
    const message = () => {
        if (state.companies.includes(state.selectedCompany)) {
            emit('searched', state.selectedCompany.substring(state.selectedCompany.indexOf("(")+1, state.selectedCompany.indexOf(")")))
        }
        
    };
    return { 
      message, state, searchCompany
    } 
    },
    components: {
        AutoComplete
    }
})
</script>
<style>

    .p-inputtext {
        padding: 0.5rem !important;
        min-width: 30vw;
    }
</style>