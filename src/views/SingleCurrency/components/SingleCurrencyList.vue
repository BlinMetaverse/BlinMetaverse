<template>
  <div class="single-currency-list">
    <div v-for="(item, index) in itemList" :key="index" class="currency-item">
      <div class="currency-top">
        <p class="earn-title">
          {{ $t("singleCurrency.pledge") }} {{ item[0] }}
        </p>
        <div class="currency-img">
          <img
            :src="imgSite + '/uploads/' + item[0] + '.png'"
            class="main-img"
          />
        </div>
      </div>
      <div class="currency-info">
        <template v-if="poolLoading">
          <div class="loading-box" />
          <div class="loading-box2" />
        </template>
        <template v-else>
          <template
            v-if="stakeList[index][3].toNumber() !== 0 || poolStatus === 0"
          >
            <div class="cell">
              <div class="cell-left">
                {{ $t("singleCurrency.receive") }}
                {{ $t("singleCurrency.blindBox") }}
              </div>
            </div>
            <div class="blindbox-cell cell">
              <div class="cell-left">{{ stakeList[index][3] }}</div>
              <div class="cell-right">
                <div
                  class="obtain-btn com-submit-btn"
                  @click="handleReceiveBlindbox(index)"
                >
                  <span>
                    {{ $t("singleCurrency.harvest") }}
                  </span>
                </div>
              </div>
            </div>
          </template>
          <template v-if="poolStatus !== 0">
            <div class="cell">
              <div class="cell-left">
                {{ $t("singleCurrency.receive") }} BLIN
              </div>
            </div>
            <div class="blindbox-cell cell">
              <div class="cell-left">
                {{ $bn.formatUnits(stakeList[index][2], coinZeroNum.blin) }}
              </div>
              <div class="cell-right">
                <div
                  class="com-submit-btn obtain-btn"
                  @click="handleReceiveBlin(index)"
                >
                  <span>
                    {{ $t("singleCurrency.harvest") }}
                  </span>
                </div>
              </div>
            </div>
          </template>
          <template v-if="stakeList[index][0].toString().length > 1">
            <div class="cell">
              <div class="cell-left">{{ $t("singleCurrency.pledgeNum") }}</div>
              <div class="cell-right annualized">
                {{ $bn.formatUnits(stakeList[index][0], itemPoolZero[index]) }}
                {{ item[0] }}
              </div>
            </div>
          </template>
        </template>

        <div class="cell">
          <template v-if="!poolLoading">
            <div
              v-if="stakeList[index][0].toString().length > 1"
              class="enable-btn com-submit-btn"
              @click="handleRedeemPool(index)"
            >
              <span>
                {{ $t("singleCurrency.redeem") }}
              </span>
            </div>
          </template>
          <div
            class="enable-btn com-submit-btn"
            @click="handleShowAmountPopup(index, item)"
          >
            <span>
              {{ $t("singleCurrency.pledge") }}
            </span>
          </div>
        </div>
        <div class="cell pledge-cell">
          <div class="cell-left">{{ $t("singleCurrency.networkPledge") }}</div>
          <div class="cell-right">
            {{ $bn.formatUnits(item[7], itemPoolZero[index]) }} {{ item[0] }}
          </div>
        </div>
      </div>
    </div>
    <van-popup
      v-model="pricePopupShow"
      closeable
      round
      :style="{ width: '80%' }"
    >
      <div v-if="popupParams.coin" class="popup-wrap">
        <div class="popup-title">{{ $t("singleCurrency.pledgeNum") }}</div>
        <div class="popup-info">
          <div class="balance-wrap cell">
            <div class="cell-left">{{ $t("singleCurrency.balance") }}:</div>
            <div class="cell-right">
              {{
                $bn.formatUnits(
                  popupParams.balance,
                  itemPoolZero[popupParams.index]
                )
              }}
              {{ popupParams.coin }}
            </div>
          </div>
          <div class="input-wrap">
            <input
              v-model="popupParams.amounts"
              :placeholder="$t('singleCurrency.maskInput')"
              type="text"
              @keyup="
                popupParams.amounts = popupParams.amounts.replace(
                  /^\D*(\d*(?:\.\d{0,100})?).*$/g,
                  '$1'
                )
              "
            />
            <div
              class="pledge-all"
              @click="
                popupParams.amounts = $bn.formatUnits(
                  popupParams.balance,
                  itemPoolZero[popupParams.index]
                )
              "
            >
              {{ $t("singleCurrency.pledgeAll") }}
            </div>
          </div>
          <div class="com-submit-btn" @click="handleStakePool">
            <span>
              {{ $t("singleCurrency.confirm") }}
            </span>
          </div>
        </div>
      </div>
    </van-popup>
  </div>
</template>

<script>
export default {
  name: "SingleCurrencyList",
  props: {
    itemList: {
      type: Array,
      default() {
        return [];
      },
    },
    itemIdList: {
      type: Array,
      default() {
        return [];
      },
    },
    stakeList: {
      type: Array,
      default() {
        return [];
      },
    },
    itemPoolZero: {
      type: Array,
      default() {
        return [];
      },
    },
    poolStatus: {
      type: [Number, String],
      default: "",
    },
    poolLoading: {
      type: Boolean,
      default: true,
    },
  },
  data() {
    return {
      pricePopupShow: false,
      popupParams: {
        balance: "",
        coin: "",
        amounts: "",
        index: "",
      },
    };
  },
  methods: {
    async handleStakePool() {
      const { balance, coin, amounts, index } = this.popupParams;
      if (!amounts) {
        return;
      }
      const price = this.$bn.parseUnits(amounts, this.itemPoolZero[index]);
      if (price.gt(balance)) {
        this.$toast(this.$t("singleCurrency.stakeTips1"));
        return;
      }
      if (Number(price) === 0) {
        this.$toast(this.$t("singleCurrency.stakeTips2"));
        return;
      }
      const params = [this.itemIdList[index]];
      if (coin === "BNB") {
        params.push(0);
        params.push({ value: price });
      } else {
        params.push(price);
      }
      await this.$contract.singleCurrency.stake(params);
      this.pricePopupShow = false;
      this.popupParams.balance = "";
      this.popupParams.coin = "";
      this.popupParams.index = "";
      this.popupParams.amounts = "";
      this.$toast(this.$t("singleCurrency.pledgeSuccess"));
      this.$emit("updateList");
    },
    async handleShowAmountPopup(index, item) {
      const address = await this.$w.getCurrentAccount();
      const price = this.$bn.parseUnits("1");
      let userAllowanceRes = 0;
      if (item[0] === "BNB") {
        const address = await this.$w.getCurrentAccount();
        const res = await this.$contract.walletBalance(address[0]);
        userAllowanceRes = this.$bn.parseUnits(res, this.itemPoolZero[index]);
      } else {
        const allowanceRes = await this.$contract.allowance(
          address[0],
          item[1],
          this.$contract.contractInfo.singleCurrency.contractAddress
        );
        price.gt(allowanceRes) &&
          (await this.$contract.approve(
            item[1],
            this.$contract.contractInfo.singleCurrency.contractAddress,
            this.$bn.parseUnits("10000000000", this.itemPoolZero[index])
          ));
        userAllowanceRes = await this.$contract.balanceOf(address[0], item[1]);
      }
      this.popupParams.balance = userAllowanceRes;
      this.popupParams.coin = item[0];
      this.popupParams.index = index;
      this.pricePopupShow = true;
    },
    async handleRedeemPool(index) {
      if (this.stakeList[index][3].toString() > 0) {
        this.$toast(this.$t("singleCurrency.redeemTips"));
        return;
      }
      await this.$contract.singleCurrency.redeem([this.itemIdList[index]]);
      this.$toast(this.$t("singleCurrency.redeemSuccess"));
      this.$emit("updateList");
    },
    async handleReceiveBlindbox(index) {
      if (this.stakeList[index][0].toString() < 1) {
        return;
      }
      const receiveNum = this.stakeList[index][3].toString();
      if (receiveNum < 1) {
        return;
      }

      await this.$contract.singleCurrency.claimBoxes([
        this.itemIdList[index],
        this.stakeList[index][3],
      ]);
      this.$toast(this.$t("singleCurrency.receivedSuccess"));
      this.$emit("updateList");
    },
    async handleReceiveBlin(index) {
      const receiveNum = this.stakeList[index][2].toNumber();
      if (receiveNum <= 0) {
        return;
      }
      await this.$contract.singleCurrency.reward([this.itemIdList[index]]);
      this.$toast(this.$t("singleCurrency.receivedSuccess"));
      this.$emit("updateList");
    },
  },
};
</script>

<style lang="less" scoped>
.single-currency-list {
  margin-top: 0.8rem /* 60/75 */;
  padding: 0 0.666667rem /* 50/75 */ 0.133333rem /* 10/75 */;
  .currency-item {
    margin-bottom: 0.533333rem /* 40/75 */;
    box-sizing: border-box;
    border-radius: 0.4rem /* 30/75 */;
    padding: 0.4rem /* 30/75 */;
    background-color: rgba(0, 0, 0, 0.5);
    border: 0.026667rem /* 2/75 */ solid #666;
    .currency-top {
      position: relative;
      padding: 0.666667rem /* 50/75 */ 0.4rem /* 30/75 */;
      border-radius: 0.266667rem /* 20/75 */;
      // background: linear-gradient(90deg, #e6e1ff, #e0f4ff 77.81%);
      background-color: #37363b;
      // box-shadow: 0px 0.133333rem /* 10/75 */ 0.16rem /* 12/75 */
      //   rgb(160, 160, 160);
      line-height: 1.1;
      .earn-title {
        font-size: 0.48rem /* 36/75 */;
        color: #fff;
        font-weight: bold;
      }
      .pledge-title {
        color: #7f71f0;
        margin-top: 0.266667rem /* 20/75 */;
        font-size: 0.373333rem /* 28/75 */;
      }
      .currency-img {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        right: 0.4rem /* 30/75 */;
        width: 1.066667rem /* 80/75 */;
        height: 1.066667rem /* 80/75 */;
        border-radius: 50%;
        overflow: hidden;
        > img {
          display: block;
          width: 100%;
          height: 100%;
        }
      }
    }
    .currency-info {
      .cell {
        padding-top: 0.333333rem /* 25/75 */;
        color: #777e91;
        font-size: 0.3733333333rem;
        line-height: 1.1;
        .cell-left {
        }
        .cell-right {
          &.annualized {
            font-size: 0.506667rem /* 38/75 */;
            font-weight: bold;
            color: #777e91;
          }
        }
        &.blindbox-cell {
          .cell-left {
            font-size: 0.453333rem /* 34/75 */;
            color: #777e91;
            font-weight: bold;
          }
          .cell-right {
            .obtain-btn {
              text-align: center;
              width: 2.666667rem /* 200/75 */;
              // padding: 0.133333rem /* 10/75 */ 0;
              // border-radius: 0.4rem /* 30/75 */;
              // background-color: #333;
              // box-shadow: 0px 0.133333rem /* 10/75 */ 0.16rem /* 12/75 */
              //   rgb(160, 160, 160);
              font-weight: bold;
              font-size: 0.426667rem /* 32/75 */;
              // border-radius: 0.133333rem /* 10/75 */;
              span {
                // border-radius: 0.133333rem /* 10/75 */;
              }
            }
          }
        }
        &.pledge-cell {
          padding-top: 0.533333rem /* 40/75 */;
          .cell-right {
            color: #777e91;
            font-weight: bold;
          }
        }
        &.view-cell {
          padding-top: 0.4rem /* 30/75 */;
          .cell-right {
            img {
              height: 0.533333rem /* 40/75 */;
            }
          }
        }
      }
      .flex-right {
        margin-top: 0.533333rem /* 40/75 */;
        display: flex;
        justify-content: left;
      }
      .enable-btn {
        margin-left: auto;
        line-height: 1;
        width: 2.666667rem /* 200/75 */;
        // padding: 0.133333rem /* 10/75 */ 0;
        // line-height: 1.066667rem /* 80/75 */;
        // background-color: #000;
        // border: 1px solid #000;
        color: #fff;
        background-color: #0f7289;
        // background-color: #333;
        // box-shadow: 0px 0.133333rem /* 10/75 */ 0.16rem /* 12/75 */
        //   rgb(160, 160, 160);
        text-align: center;
        font-weight: bold;
        // font-size: 0.533333rem /* 40/75 */;
        font-size: 0.426667rem /* 32/75 */;
        // border-radius: 0.533333rem /* 40/75 */;
        // border-radius: 0.24rem /* 18/75 */;
        // border-radius: 0.133333rem /* 10/75 */;
        span {
          // border-radius: 0.133333rem /* 10/75 */;
        }
      }
    }
    .loading-box {
      margin-top: 0.533333rem /* 40/75 */;
      width: 40%;
      height: 0.666667rem /* 50/75 */;
      background-color: #37363b;
    }
    .loading-box2 {
      margin-top: 0.4rem /* 30/75 */;
      width: 20%;
      height: 0.666667rem /* 50/75 */;
      background-color: #37363b;
    }
  }
  .popup-wrap {
    background-color: #37363b;
    width: 100%;
    color: #fff;
    .popup-title {
      border-bottom: 1px solid #999;
      line-height: 1.466667rem /* 110/75 */;
      text-align: center;
      font-size: 0.533333rem /* 40/75 */;
    }
    .popup-info {
      padding: 0.4rem /* 30/75 */;
      .balance-wrap {
        font-size: 0.4rem /* 30/75 */;
      }
      .input-wrap {
        position: relative;
        margin-top: 0.4rem /* 30/75 */;
        border: 1px solid #999;
        border-radius: 0.133333rem /* 10/75 */;
        box-sizing: border-box;
        overflow: hidden;
        input {
          height: 0.933333rem /* 70/75 */;
          font-size: 0.346667rem /* 26/75 */;
          padding: 0 1.866667rem /* 140/75 */ 0 0.266667rem /* 20/75 */;
          border-color: #999;
          box-sizing: border-box;
          width: 100%;
          display: block;
          background-color: transparent;
          color: #fff;
        }
        .pledge-all {
          position: absolute;
          cursor: pointer;
          right: 0.266667rem /* 20/75 */;
          top: 50%;
          transform: translateY(-50%);
          font-size: 0.32rem /* 24/75 */;
          color: #fff;
        }
      }
      .com-submit-btn {
        margin-top: 1.066667rem /* 80/75 */;
        line-height: 1.066667rem /* 80/75 */;
      }
    }
  }
}
</style>
