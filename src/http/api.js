import axios from 'axios'
import config from './config.js'
import qs from 'qs' 
import { Toast } from 'vant'

export default function $axios(options) {
  return new Promise((resolve, reject) => {
    const instance = axios.create({
      baseURL: config.baseURL,
      transformResponse: [function(data) { }]
    })

    instance.interceptors.request.use(
      config => {
        if (config.header) {
          const configHeader = config.header
          for (const key in configHeader) {
            config.headers[key] = configHeader[key]
          }
        }

        if (config.method.toLocaleLowerCase() === 'post' || config.method.toLocaleLowerCase() === 'put' || config.method.toLocaleLowerCase() === 'delete') {
          config.data = qs.stringify(config.data)
        }

        return config
      },
      error => {
        return Promise.reject(error)
      }
    )

    // response 
    instance.interceptors.response.use(
      response => {
        let data = response.data === undefined ? response.request.responseText : response.data
        data = JSON.parse(data)
        switch (data.code) {
          case 200:
            return data
          default:
            Toast(data.msg + '~')
            reject()
            break
        }
      },
      err => {
        return Promise.reject(err)
      }
    )

    instance(options)
      .then((res) => {
        resolve(res)
        return false
      })
      .catch((error) => {
        reject(error)
      })
  })
}
