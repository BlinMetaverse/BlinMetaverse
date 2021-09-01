<template>
  <div class="swap-header">
    <router-link to="/swap">兑换</router-link>
  </div>
</template>

<script>
export default {
  name: 'SwapHeader'
}
</script>

<style lang="less" scoped>
.swap-header {
  display: flex;
  align-items: center;
  align-content: center;
  justify-content: space-evenly;
  a {
    font-size: 0.42666666666666664rem;
    padding: 0.64rem 0.8rem;
    text-align: center;
    color: rgba(0, 0, 0, 0.5);
    &.router-link-exact-active {
      position: relative;
      color: #000;
      font-weight: bold;
      &::after {
        content: '';
        position: absolute;
        width: 1.333333rem /* 100/75 */;
        height: .066667rem /* 5/75 */;
        background-color: rgba(31, 199, 212, 0.2);
        bottom: .333333rem /* 25/75 */;
        left: 50%;
        transform: translateX(-50%);
      }
    }
  }
}
</style>
