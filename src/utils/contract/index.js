
import contract from './contract'
const install = Vue => {
  Vue.prototype.$contract = {}
  for (const key in contract) {
    Vue.prototype.$contract[key] = contract[key]
  }
}
window.contract = contract
export default {
  install
}

