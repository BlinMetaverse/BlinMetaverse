const state = {
  show: false,
  text: ''
}

const mutations = {
  SET_LOADING(state, info) {
    state.show = info.show
    state.text = info.text
  }
}

const actions = {
  setLoading({ commit }, info) {
    commit('SET_LOADING', info)
  }
}

export default {
  namespaced: true,
  state,
  mutations,
  actions
}
