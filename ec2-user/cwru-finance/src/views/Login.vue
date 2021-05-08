<template>
    <div class="full">
  <div class="login">
    <form>
        <img src="../assets/cwruFinanceLogo.png">
        <br>
        <input id="username" v-model="state.username" placeholder="Username">
        <br>
        <input id="password" type="password" v-model="state.password" placeholder="Password">
        <br>
        <button class="button" type="submit" @click="checkLogin">Log in</button>
    </form>
    <div v-if="state.wrongInfo" id="wrong">
        <p>Wrong username or password try again</p>
    </div>
  </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, reactive, onMounted } from 'vue';
import router from '@/router';
import store from '@/store';
import { UserService } from '@/services';
export default defineComponent({
  name: 'Login',
  setup() {
      const state = reactive({
          wrongInfo: false,
          username: '',
          password: ''
      })
      const checkLogin = async () => {
          let loggedIn = await UserService.login(state.username, state.password);
          if (loggedIn) {
                store.commit('login', state.username);
                router.push('/'); 
          }
          else {
              state.wrongInfo = true;
          }
      }
      onMounted(() => {
          if (store.getters.isLoggedIn) {
              router.push('/');
          }
      });
      return { checkLogin, state };
  }
});
</script>
<style scoped>
    input {
        padding: 1rem;
        margin: 5px;
        font-size: 1.2rem;
    }
    #wrong {
        color: red;
    }
    img {
        width: 25%;
    }
    form {
        background-color: #327ba8;
        width: 100%;
        padding: 1rem;
        align-items: center;
        color: #fff;
    }
    .login {
        display: inline-block;
        
    }
    body{
        background-color: #ADD8E6;
    }
    
</style>
