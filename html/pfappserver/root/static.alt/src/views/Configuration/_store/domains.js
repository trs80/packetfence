/**
* "$_domains" store module
*/
import Vue from 'vue'
import store from '@/store' // required for 'pfqueue'
import api from '../_api'

const types = {
  LOADING: 'loading',
  DELETING: 'deleting',
  SUCCESS: 'success',
  ERROR: 'error'
}

// Default values
const state = {
  cache: {}, // items details
  joins: {}, // domain join details
  message: '',
  itemStatus: ''
}

const getters = {
  isWaiting: state => [types.LOADING, types.DELETING].includes(state.itemStatus),
  isLoading: state => state.itemStatus === types.LOADING
}

const actions = {
  all: () => {
    const params = {
      sort: 'id',
      fields: ['id', 'workgroup', 'ntlm_cache'].join(',')
    }
    return api.domains(params).then(response => {
      return response.items
    })
  },
  options: ({ commit }, id) => {
    commit('ITEM_REQUEST')
    if (id) {
      return api.domainOptions(id).then(response => {
        commit('ITEM_SUCCESS')
        return response
      }).catch((err) => {
        commit('ITEM_ERROR', err.response)
        throw err
      })
    } else {
      return api.domainsOptions().then(response => {
        commit('ITEM_SUCCESS')
        return response
      }).catch((err) => {
        commit('ITEM_ERROR', err.response)
        throw err
      })
    }
  },
  getDomain: ({ state, commit }, id) => {
    if (state.cache[id]) {
      return Promise.resolve(state.cache[id]).then(cache => JSON.parse(JSON.stringify(cache)))
    }
    commit('ITEM_REQUEST')
    return api.domain(id).then(item => {
      commit('ITEM_REPLACED', item)
      return JSON.parse(JSON.stringify(item))
    }).catch((err) => {
      commit('ITEM_ERROR', err.response)
      throw err
    })
  },
  createDomain: ({ commit }, data) => {
    commit('ITEM_REQUEST')
    return api.createDomain(data).then(response => {
      commit('ITEM_REPLACED', data)
      return response
    }).catch(err => {
      commit('ITEM_ERROR', err.response)
      throw err
    })
  },
  updateDomain: ({ commit }, data) => {
    commit('ITEM_REQUEST')
    return api.updateDomain(data).then(response => {
      commit('ITEM_REPLACED', data)
      return response
    }).catch(err => {
      commit('ITEM_ERROR', err.response)
      throw err
    })
  },
  deleteDomain: ({ commit }, data) => {
    commit('ITEM_REQUEST', types.DELETING)
    return api.deleteDomain(data).then(response => {
      commit('ITEM_DESTROYED', data)
      return response
    }).catch(err => {
      commit('ITEM_ERROR', err.response)
      throw err
    })
  },
  testDomain: ({ commit }, id) => {
    if (id in state.joins) {
      return Promise.resolve(state.joins[id])
    }
    commit('TEST_REQUEST', id)
    return api.testDomain(id).then(response => {
      commit('TEST_SUCCESS', id)
      return state.joins[id]
    }).catch(err => {
      commit('TEST_ERROR', id)
      return state.joins[id]
    })
  },
  joinDomain: ({ commit }, data) => {
    return api.joinDomain(data).then(response => {
      return store.dispatch('pfqueue/pollTaskStatus', response.task_id).then(response => {
        // TODO
        console.log('DONE', response)
      })
    }).catch(err => {
      throw err
    })
  },
  rejoinDomain: ({ commit }, id) => {
    commit('ITEM_REQUEST', id)
    return api.rejoinDomain({ id }).then(response => {
      commit('REJOIN_SUCCESS', id)
      return response
    }).catch(err => {
      commit('ITEM_ERROR', err.response)
      throw err
    })
  },
  unjoinDomain: ({ commit }, id) => {
    commit('ITEM_REQUEST', id)
    return api.unjoinDomain({ id }).then(response => {
      commit('UNJOIN_SUCCESS', id)
      return response
    }).catch(err => {
      commit('ITEM_ERROR', err.response)
      throw err
    })
  }
}

const mutations = {
  ITEM_REQUEST: (state, type) => {
    state.itemStatus = type || types.LOADING
    state.message = ''
  },
  ITEM_REPLACED: (state, data) => {
    state.itemStatus = types.SUCCESS
    Vue.set(state.cache, data.id, JSON.parse(JSON.stringify(data)))
    Vue.set(state.joins, data.id, {})
  },
  ITEM_DESTROYED: (state, id) => {
    state.itemStatus = types.SUCCESS
    Vue.set(state.cache, id, null)
    Vue.delete(state.joins, id)
  },
  ITEM_ERROR: (state, response) => {
    state.itemStatus = types.ERROR
    if (response && response.data) {
      state.message = response.data.message
    }
  },
  ITEM_SUCCESS: (state) => {
    state.itemStatus = types.SUCCESS
  },
  TEST_REQUEST: (state, id) => {
    if (!(id in state.joins)) {
      Vue.set(state.joins, id, {})
    }
    Vue.set(state.joins[id], 'status', null)
  },
  TEST_SUCCESS: (state, id) => {
    Vue.set(state.joins[id], 'status', true)
  },
  TEST_ERROR: (state, id) => {
    Vue.set(state.joins[id], 'status', false)
  }
}

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
