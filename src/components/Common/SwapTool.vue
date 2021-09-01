<template>
  <div class="swap-tool">
    <div class="swap-tool-hd">
      <h3 class="tool-title">{{ title }}</h3>
      <div class="tool-item-wrap">
        <div class="tool-item" @click="$emit('toleranceClick')">
          <img src="../../assets/images/settings_icon.png" alt="">
        </div>
        <div class="tool-item">
          <img
            src="../../assets/images/time_icon.png"
            alt=""
          >
        </div>
      </div>
    </div>
    <div class="swap-tool-bd">{{ desc }}</div>
    <slot />
  </div>
</template>

<script>
export default {
  name: 'SwapTool',
  props: {
    title: {
      type: String,
      default: ''
    },
    desc: {
      type: String,
      default: ''
    }
  }
}
</script>

<style lang="less" scoped>
.swap-tool {
  // background-color: #37363b;
  border-radius: 0.26666666666666666rem;
  padding: 0.5333333333333333rem 0.5333333333333333rem;
  .swap-tool-hd {
    display: flex;
    align-items: center;
    align-content: center;
    justify-content: space-between;
    .tool-title {
      font-size: 0.48rem;
      color: #fff;
      line-height: 0.6666666666666666rem;
      font-weight: 500;
    }
    .tool-item-wrap {
      display: flex;
      align-items: center;
      align-content: center;
      .tool-item {
        img {
          display: block;
          width: .453333rem /* 34/75 */;
        }
        margin-left: 0.533333rem /* 40/75 */;
      }
    }
  }
  .swap-tool-bd {
    // margin-top: 0.32rem;
    font-size: 0.37333333333333335rem;
    color: #bac0c8;
    line-height: 0.5333333333333333rem;
  }
}
</style>
