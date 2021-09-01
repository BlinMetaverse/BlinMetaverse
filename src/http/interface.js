import axios from './api'

export const postFn = data => {
  return axios({
    url: 'postUrl',
    method: 'post',
    data
  })
}
export const upload = params => {
  return axios({
    url: 'postUrl',
    method: 'post',
    params,
    header: { 'Content-Type': 'multipart/form-data' }
  })
}
export const getFn = params => {
  return axios({
    url: 'getUrl',
    method: 'get',
    params
  })
}

export const putFn = data => {
  return axios({
    url: `putFn/${data.id}`,
    method: 'put',
    data
  })
}
export const deleteFn = params => {
  return axios({
    url: `deleteUrl/${params.id}`,
    method: 'delete',
    params
  })
}

export const homeBanner = params => {
  return axios({
    url: '/user/banner',
    method: 'get',
    params
  })
}

export const homeRecommendCard = params => {
  return axios({
    url: '/user/cards',
    method: 'get',
    params
  })
}

export const cardCategory = params => {
  return axios({
    url: '/user/category',
    method: 'get',
    params
  })
}

export const cardList = params => {
  return axios({
    url: '/user/category_nft',
    method: 'get',
    params
  })
}

export const blindBoxList = params => {
  return axios({
    url: '/user/buy',
    method: 'get',
    params
  })
}

export const blindBoxAllList = params => {
  return axios({
    url: '/user/buy_all',
    method: 'get',
    params
  })
}

export const cardDetails = params => {
  return axios({
    url: '/user/cards_details',
    method: 'get',
    params
  })
}

export const queryHash = params => {
  return axios({
    url: '/user/hash',
    method: 'get',
    params
  })
}

export const queryBlindboxHash = params => {
  return axios({
    url: '/user/rand_cards',
    method: 'get',
    params
  })
}

export const openBlindBox = params => {
  return axios({
    url: '/user/open',
    method: 'get',
    params
  })
}
export const openBlindboxInfo = params => {
  return axios({
    url: '/user/open_box',
    method: 'get',
    params
  })
}
export const userCardList = params => {
  return axios({
    url: '/user/buy_user',
    method: 'get',
    params
  })
}
export const userBlindboxList = params => {
  return axios({
    url: '/user/buy_box_user',
    method: 'get',
    params
  })
}


export default {
  postFn,
  upload,
  getFn,
  putFn,
  deleteFn,
  homeBanner,
  homeRecommendCard,
  cardCategory,
  cardList,
  blindBoxList,
  blindBoxAllList,
  cardDetails,
  queryHash,
  queryBlindboxHash,
  openBlindBox,
  openBlindboxInfo,
  userCardList,
  userBlindboxList
}
