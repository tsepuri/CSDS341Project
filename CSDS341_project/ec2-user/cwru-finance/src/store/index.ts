import Vue from 'vue';
import { createStore } from 'vuex'
// import { postService } from "@/services";
export default createStore({
  state: {
      user: localStorage.getItem('user-token') || '',
      searchBarInfo: [],
      favorited: []
  },
  mutations: {
      logout(state) {
          state.user = '';
          localStorage.removeItem('user-token');
      },
      login(state, username) {
          localStorage.setItem('user-token', username);
          state.user = username;
      },
      setFavorites(state, favorites) {
        state.favorited = favorites;
      },
      setSearchBarInfo(state, searchBarInfo) {
        state.searchBarInfo = searchBarInfo;
      }
  },
  getters: {
      isLoggedIn: state => state.user != '',
      username: state => state.user,
      searchBarInfo: state => state.searchBarInfo,
      favorited: state => state.favorited
  }
})
