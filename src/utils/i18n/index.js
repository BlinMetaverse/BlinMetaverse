import Vue from 'vue'
import VueI18n from 'vue-i18n'

Vue.use(VueI18n)

const currentLang = localStorage.getItem('lang') ? localStorage.getItem('lang') : 'en'
const i18n = new VueI18n({
  locale: currentLang,
  messages: {
    'zh-cn': require('@/assets/lang/zh-cn.js'),
    'en': require('@/assets/lang/en.js')
  }
})

export default i18n
