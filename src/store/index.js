import Vue from 'vue'
import Vuex from 'vuex'
import app from './modules/app'
import loading from './modules/loading'
import goodsMask from './modules/goodsMask'
import wallet from './modules/wallet'
import getters from './getters'

Vue.use(Vuex)

const store = new Vuex.Store({
  modules: {
    app,
    loading,
    goodsMask,
    wallet
  },
  getters
})

export default store
