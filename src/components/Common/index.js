const components = {}

function requireAll(r) {
  return r.keys().map(key => {
    const name = key
      .replace(/^\.\//, '')
      .replace(/.vue$/, '')
      .replace(/[a-zA-Z]+\//, '')
      .replace(/([A-Z])/g, '-$1')
      .replace(/-/, '')
      .toLowerCase()
    components[name] = r(key).default
  })
}

requireAll(require.context('./', true, /.vue$/))

const install = Vue => {
  Object.entries(components).forEach(([name, component]) => {
    Vue.component(name, component)
  })
}

export default { install }
