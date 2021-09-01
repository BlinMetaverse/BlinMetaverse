import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'

import './styles/index.less'

import 'amfe-flexible/index.min.js'

import './permission'

import i18n from '@/utils/i18n/index'

const { utils } = require('ethers')
Vue.prototype.$bn = utils

import 'vant/lib/index.css'
import Vant from 'vant'
Vue.use(Vant)

import api from './http'
Vue.use(api)

import CommonComponents from './components/Common'
Vue.use(CommonComponents)

import VueAwesomeSwiper from 'vue-awesome-swiper'
import 'swiper/css/swiper.css'
Vue.use(VueAwesomeSwiper)

Vue.config.productionTip = false
Vue.prototype.imgSite = 'https://dev.admindapp.blin.pro'

import web3Init from './utils/web3/web3Init'
Vue.use(web3Init)

import contract from './utils/contract/index'
Vue.use(contract)

Vue.prototype.priceNum = 1000000000000000000
Vue.prototype.coinZeroNum = {
  bnb: '18',
  blin: '8'
}

Vue.prototype.$requestUrl = 'https://dev.api.blin.pro'

new Vue({
  router,
  store,
  i18n,
  render: h => h(App)
}).$mount('#app')
