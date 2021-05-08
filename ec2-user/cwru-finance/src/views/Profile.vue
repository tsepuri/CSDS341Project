<template>
    <div class="profile">
        <div>
            <h2>Companies favorited</h2>
            <ul>
                <li v-for="favorite in state.favorites" :key="favorite">
                    <router-link :to="'/company/'+favorite">{{favorite}}</router-link>
                </li>
            </ul>
        </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, reactive, onMounted } from 'vue';
import router from '@/router';
import store from '@/store';
import { UserService } from '@/services';
export default defineComponent({
  name: 'Profile',
  setup() {
      const state = reactive({
          username: store.getters.username,
          favorites: ["NKE", "AAPL"],
          notes: ["NKE", "GOOG"]
      })
      onMounted(() => {
          state.favorites = store.getters.favorited;
      });
      return {  state };
  }
});
</script>
<style scoped>
   .profile {
       display: inline-block;
   }
   ul {
       list-style: none;
   }
   li {
       padding: 1rem;
       margin: 0.5rem;
   }
   a {
       text-decoration: none;
       background-color: #f4f4f4;
       padding: 0.5rem 1rem;
       color: #000;
   }
   a:hover {
       background-color: #f9f9f9;
   }
</style>
