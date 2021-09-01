<template>
  <div class="single-currency-rules">
    <van-collapse v-model="rulesActive" :border="false" accordion>
      <van-collapse-item
        :title="`${$t('singleCurrency.rulesTitle')} (${$t('singleCurrency.viewAll')})`"
        size="0.3733333333rem"
        :border="false"
        name="1"
      >
        <div class="rules-content">
          <p>{{ $t("singleCurrency.rulesDesc") }}</p>
          <div class="rules-table">
            <div class="rules-tr">
              <div class="rules-th">{{ $t("singleCurrency.rulesCoin") }}</div>
              <div class="rules-th">
                {{ $t("singleCurrency.rulesCoinNum") }}
              </div>
            </div>
            <div v-for="(item, index) of coinList" :key="index" class="rules-tr">
              <div class="rules-td">{{ coinList[index] }}</div>
              <div class="rules-td">{{ coinNumList[index] }}</div>
            </div>
          </div>
        </div>
      </van-collapse-item>
    </van-collapse>
  </div>
</template>

<script>
export default {
  name: 'SingleCurrencyRules',
  data() {
    return {
      rulesActive: '',
      coinList: [
        'BNB',
        'USDT',
        'CAKE',
        'BAKE',
        'AXS',
        'CHR',
        'ALICE',
        'DOGE',
        'DEGO',
        'SKILL',
        'PMON'
      ],
      coinNumList: [0.5, 200, 10, 100, 5, 1000, 20, 1000, 20, 5, 20]
    }
  }
}
</script>

<style lang="less" scoped>
.single-currency-rules {
  & /deep/ .van-collapse-item {
    border: none;
    .van-cell {
      background-color: transparent;
      padding-left: 0.666667rem /* 50/75 */;
      padding-right: 0.666667rem /* 50/75 */;
    }
    .van-cell__title {
      color: #777e91;
    }
    .van-collapse-item__content {
      padding: 0 0.666667rem /* 50/75 */;
      background-color: transparent;
    }
  }
  .rules-content {
    color: #777e91;
    .rules-table {
      margin-top: 0.266667rem /* 20/75 */;
      border: 1px solid #777e91;
      line-height: 1.2;
      font-size: 0.3733333333rem;
      .rules-tr {
        border-bottom: 1px solid #777e91;
        display: flex;
        align-items: center;
        align-content: center;
        text-align: center;
        height: 0.933333rem /* 70/75 */;
        &:last-child {
          border: none;
        }
      }
      .rules-th,
      .rules-td {
        height: 0.933333rem /* 70/75 */;
        line-height: 0.933333rem /* 70/75 */;
        flex: 1;
        border-right: 1px solid #777e91;
        &:last-child {
          border: none;
        }
      }
    }
  }
}
</style>
