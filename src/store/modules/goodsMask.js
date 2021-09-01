const state = {
  show: false,
  info: {}
}

const mutations = {
  SET_MASK_INFO(state, obj) {
    state.show = obj.show
    state.info = obj.info
  }
}

const actions = {
  setMaskInfo({ commit }, obj) {
    commit('SET_MASK_INFO', obj)
  }
}

export default {
  namespaced: true,
  state,
  mutations,
  actions
}
