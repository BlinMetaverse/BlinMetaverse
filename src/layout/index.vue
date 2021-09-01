<template>
  <div class="layout">
    <layout-header />
    <router-view />
    <com-loading />
    <com-star-animate />
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

<style lang="less" scoped>
.layout {
  background-color: #000;
  position: relative;
  z-index: 1;
  box-sizing: border-box;
}
</style>
