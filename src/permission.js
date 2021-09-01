import router from './router'
import store from './store'

router.beforeEach((to, from, next) => {
  if (!store.getters.wallet.installed) {
    const timeId = setInterval(() => {
      if (store.getters.wallet.installed) {
        next()
        clearInterval(timeId)
      }
    }, 100)
  } else {
    next()
  }
})

router.afterEach(() => {})
