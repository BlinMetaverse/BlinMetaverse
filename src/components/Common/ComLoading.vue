<template>
  <div v-show="loading.show" class="com-loading">
    <div class="sk-folding-cube">
      <div class="sk-cube sk-cube-1" />
      <div class="sk-cube sk-cube-2" />
      <div class="sk-cube sk-cube-4" />
      <div class="sk-cube sk-cube-3" />
    </div>
    <div class="loaading-text">
      {{ loading.text }}
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
export default {
  name: 'ComLoading',
  computed: {
    ...mapGetters([
      'loading'
    ])
  }
}
</script>

<style lang="less" scoped>
.com-loading {
  position: fixed;
  width: 100%;
  height: 100vh;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  z-index: 9999;
  display: flex;
  align-items: center;
  align-content: center;
  justify-content: center;
  flex-wrap: wrap;
  background-color: rgba(0, 0, 0, 0.5);
  @keyframes sk-folding-cube-angle {
    0%,
    10% {
      -webkit-transform: perspective(140px) rotateX(-180deg);
      transform: perspective(140px) rotateX(-180deg);
      opacity: 0;
    }
    25%,
    75% {
      -webkit-transform: perspective(140px) rotateX(0deg);
      transform: perspective(140px) rotateX(0deg);
      opacity: 1;
    }
    90%,
    100% {
      -webkit-transform: perspective(140px) rotateY(180deg);
      transform: perspective(140px) rotateY(180deg);
      opacity: 0;
    }
  }
  .sk-folding-cube {
    width: 3em;
    height: 3em;
    position: relative;
    margin: auto;
    -webkit-transform: rotateZ(45deg);
    transform: rotateZ(45deg);
  }
  .sk-folding-cube .sk-cube {
    float: left;
    width: 50%;
    height: 50%;
    position: relative;
    -webkit-transform: scale(1.1);
    transform: scale(1.1);
  }
  .sk-folding-cube .sk-cube:before {
    content: "";
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: #06a7f2;
    -webkit-animation: sk-folding-cube-angle 2.4s infinite linear both;
    animation: sk-folding-cube-angle 2.4s infinite linear both;
    -webkit-transform-origin: 100% 100%;
    transform-origin: 100% 100%;
  }
  .sk-folding-cube .sk-cube-2 {
    -webkit-transform: scale(1.1) rotateZ(90deg);
    transform: scale(1.1) rotateZ(90deg);
  }
  .sk-folding-cube .sk-cube-3 {
    -webkit-transform: scale(1.1) rotateZ(180deg);
    transform: scale(1.1) rotateZ(180deg);
  }
  .sk-folding-cube .sk-cube-4 {
    -webkit-transform: scale(1.1) rotateZ(270deg);
    transform: scale(1.1) rotateZ(270deg);
  }
  .sk-folding-cube .sk-cube-2:before {
    -webkit-animation-delay: 0.3s;
    animation-delay: 0.3s;
  }
  .sk-folding-cube .sk-cube-3:before {
    -webkit-animation-delay: 0.6s;
    animation-delay: 0.6s;
  }
  .sk-folding-cube .sk-cube-4:before {
    -webkit-animation-delay: 0.9s;
    animation-delay: 0.9s;
  }
  .loaading-text {
    margin-top: 1.066667rem /* 80/75 */;
    width: 100%;
    font-size: .506667rem /* 38/75 */;
    text-align: center;
    color: #fafafa;
  }
}
</style>
