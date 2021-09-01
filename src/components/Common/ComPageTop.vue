<template>
  <div class="com-page-top">
    <h2
      class="com-page-title"
      :style="{
        color,
      }"
    >
      {{ title }}
    </h2>
    <p
      v-if="desc"
      class="com-page-desc"
      :style="{
        color,
      }"
    >{{ desc }}</p>
  </div>
</template>

<script>
export default {
  name: 'ComPageTop',
  props: {
    title: {
      type: String,
      default: ''
    },
    desc: {
      type: String,
      default: ''
    },
    color: {
      type: String,
      default: '#fff'
    }
  }
}
</script>

<style lang="less" scoped>
.com-page-top {
  padding: 0 .666667rem /* 50/75 */;
  .com-page-title {
    font-size: 0.8033333333rem;
    font-weight: 700;
    line-height: 1.0666666667rem;
    padding-top: 0.4266666667rem;
  }
  .com-page-desc {
    line-height: 0.7466666667rem;
    padding-top: 0.2133333333rem;
    font-size: 0.3733333333rem;
    white-space: pre-wrap;
  }
}
</style>

