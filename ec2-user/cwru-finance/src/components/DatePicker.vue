<template>
    <div class="searchbar-container">
        <select v-model="state.currentMonth">
        <option
          v-for='i in months'
          :key='i'
          :value='i'
            >
          {{ i }}
        </option>
      </select>
        <select v-model="state.currentDay">
        <option
          v-for='i in daysInMonth'
          :key='i'
          :value='i'>
          {{ i }}
        </option>
      </select>
      <select v-model="state.currentYear">
        <option
          v-for='i in (endingYear - startingYear)'
          :key='i+startingYear'
          :value='i+startingYear'>
          {{ i + startingYear }}
        </option>
      </select>
        <button type="submit" class="button" @click="dateChosen">Select</button>
    </div>
</template>
<script>
import { defineComponent, reactive, computed } from 'vue'
 import * as dayjs from 'dayjs'
export default defineComponent({
    name:'DatePicker',
    props: {
        startingDate: Date,
        endingDate: Date,
        currentDate: Date
    },
    setup(props, { emit }) {
    const state = reactive({
      currentMonth: 'December',
      currentDay: 30,
      currentYear: 2020,
      
    })
    const startingYear = 2015;
    const endingYear = 2020;
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    const dateChosen = () => {
      emit('newDate', dayjs().month(months.indexOf(state.currentMonth)).date(state.currentDay).year(state.currentYear).format('YYYY-MM-DD'));
    }
    const daysInMonth = computed(() => dayjs().month(months.indexOf(state.currentMonth)).daysInMonth());
    // const message = () => {emit('searched', new Date(state.))};
    return { 
      state, months, dateChosen, startingYear, endingYear, daysInMonth
    };
    }
})
</script>
<style scoped>
    select {
      padding: 1rem;
      margin: 0.2rem 0.5rem;
      font-size: 1rem;
    }
    option {
      padding: 1rem;
    }
</style>