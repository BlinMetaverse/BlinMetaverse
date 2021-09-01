const state = {
  isConnected: false,
  installed: false,
  address: '',
  chainId: ''
}

const mutations = {
  SET_ALL(state, info) {
    state.isConnected = info.isConnected
    state.address = info.address
    state.chainId = info.chainId
    state.installed = info.installed
  },
  SET_SPECIFY_ITEM(state, info) {
    for (const key in info) {
      state[key] = info[key]
    }
  }
}

const actions = {
  setAll({ commit }, info) {
    commit('SET_ALL', info)
  },
  setSpecifyItem({ commit }, info) {
    commit('SET_SPECIFY_ITEM', info)
  }
}

export default {
  namespaced: true,
  state,
  mutations,
  actions
}
