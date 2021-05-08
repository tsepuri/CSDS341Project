<template>
  <div>
  <div id="nav">
      <div>
        <img @click="homePage" src="../assets/cwruFinanceLogo.png">
    <div class = "leftSide">
    
    <li><a><router-link to="/about">About</router-link></a></li>
    <li><Searcher @searched="onSearch"/></li>
    </div>
    <div class="rightSide">
    <a @click="toggleDropdown" class="usernameButton">{{ state.username }}</a>
    <ul class="dropdown" v-if="state.droppedDown">
      <li><a><router-link to="/profile">Profile</router-link></a></li>
      <li><a @click="logout">Log out</a></li>
    </ul>
    </div>
    </div>
  </div>
 
  </div>
</template>

<script lang="ts">
import { defineComponent, reactive } from 'vue';
import Searcher from '@/components/Searcher.vue';
import store from '@/store';
import router from '@/router';
export default defineComponent({
  name: 'Navbar',
  props: {
    username: String,
  },
  setup(props) {
    const state = reactive({
      username: props.username,
      droppedDown: false
    });
    const logout = () => {
      store.commit('logout');
      router.push('/login');
    }
    const homePage = () => {
      router.push('/');
    }
    const toggleDropdown = () => {state.droppedDown = !state.droppedDown;};
    const onSearch = (term:any) => {
      router.push({ name: 'companies', params: { ticker: term }});
    }
    router.beforeEach((to, from) => {
          state.droppedDown = false;
    });
    return { state, toggleDropdown, logout, onSearch, homePage };
  },
    components: {
        Searcher
    }
});
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

.leftSide {
  float: left;
  align-items: center;
  margin-left: 0;
  padding: 1rem;
  margin-top: 0.5rem;
}
.leftSide li {
  display: inline-block;

}
.rightSide {
  float: right;
  padding: 1rem;
  margin-right: 1rem;
  margin-top: 1rem;
}

#nav {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  margin: 0;
  text-decoration: none;
  background-color: #ADD8E6;
  width: 100%;
  height: 15%;
  align-items: center;
}

#nav a {
  font-weight: bold;
  color: #fff;
  cursor: pointer;
  text-decoration: none;
  padding: 0.5rem;
}

#nav a:hover{
   background-color: #599eab;
    transition: 200ms;
    transition-timing-function: ease-in;
}
.dropdown {
  z-index: 4;
  text-decoration: none;
  list-style-type: none;
  padding: 0.6rem;
  background-color: #ADD8E6;
  width: 100%;
}

.dropdown li {
  padding: 0.5rem;
}
#nav a.router-link-exact-active {
  color: #2c3e50;
}
img {
   width: 160px;
   margin: auto;
   padding: 0.5rem;
   margin-top: 0.7rem;
   cursor: pointer;
   float: left;
}

</style>
