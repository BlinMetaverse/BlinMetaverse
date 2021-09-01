
import web3Api from './web3Api'
const install = Vue => {
  Vue.prototype.$w = {}
  for (const key in web3Api) {
    Vue.prototype.$w[key] = web3Api[key]
  }
}

export default {
  install
}

