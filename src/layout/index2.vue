<template>
  <div class="layout">
    <layout-header />
    <router-view />
    <com-loading />
  </div>
</template>

<script>
import LayoutHeader from './components/LayoutHeader'
export default {
  name: 'Layout',
  components: {
    LayoutHeader
  }
}
</script>
