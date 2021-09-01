<template>
  <div class="com-nothing">
    <van-empty
      class="custom-image"
      image="https://img01.yzcdn.cn/vant/custom-empty-image.png"
      description="Not data"
    />
  </div>
</template>

<script>
export default {
  name: 'ComNothing'
}
</script>

<style lang="less">
.com-nothing {
  .custom-image .van-empty__image {
    width: 2.4rem /* 180/75 */;
    height: 2.4rem /* 180/75 */;
  }
}
</style>
