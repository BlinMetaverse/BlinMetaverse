<template>
  <div class="layout-header">
    <div class="menu-btn">
      <div class="online-dot" />
      <div :class="['nav-open-btn']">
        <div class="nav-menu-line" />
        <div class="nav-menu-line" />
        <div class="nav-menu-line" />
      </div>
    </div>
    <router-link to="/" class="logo">
      <img src="../../assets/images/blin_white_logo.png" />
    </router-link>
    <div class="header-right">
      <div
        v-if="!wallet.isConnected"
        class="connect-btn com-submit-btn"
        @click="handleConnectWallet"
      >
        <span>{{ $t("common.connect") }}</span>
        <!-- handlePlusXing(wallet.address, 3, 5) -->
      </div>
      <template v-else>
        <div class="connected-btn">
          <!-- <van-popover
            v-model="showPopover"
            trigger="click"
            :actions="actions"
            placement="bottom-end"
            @select="handleWallteSelect"
          >
            <template #reference>
              <div class="connect-btn-wrap">
                <div class="connect-btn com-submit-btn">
                  <span>{{ handlePlusXing(wallet.address, 3, 5) }}</span>
                </div>
              </div>
            </template>
          </van-popover> -->
          <div class="connect-btn-wrap">
            <div class="connect-btn com-submit-btn">
              <span>{{ handlePlusXing(wallet.address, 3, 5) }}</span>
            </div>
          </div>
        </div>
      </template>
      <div class="lang-wrap">
        <van-popover
          v-model="showPopover2"
          trigger="click"
          :actions="language"
          placement="bottom-end"
          @select="handleLanguageSelect"
        >
          <template #reference>
            <div class="lang">
              {{ langName }}
            </div>
          </template>
        </van-popover>
      </div>
    </div>
    <!-- <div :class="['nav-menu-mask', isShowMenu ? 'active' : '']">
      <div class="mask" @click="isShowMenu = false" />
      <div class="nav-menu-mask-scroll">
        <div v-if="wallet.isConnected" class="user-operate">
          <p class="address">{{ handlePlusXing(wallet.address) }}</p>
          <div class="operate-wrap">
            <div class="operate-item" @click="handleCopyAddress">
              <img src="../../assets/images/copy_icon.png">
            </div>
            <a
              :href="`https://bscscan.com/address/${wallet.address}`"
              class="operate-item"
            >
              <img src="../../assets/images/share_icon.png">
            </a>
            <div class="operate-item" @click="handleCloseConnect">
              <img src="../../assets/images/shut_icon.png">
            </div>
          </div>
        </div>
        <div class="user-linker">
          <van-collapse v-model="activeName" :border="false" accordion>
            <template v-for="(item, index) of linkList">
              <van-collapse-item v-if="item.child" :key="index" :name="index">
                <template #title>
                  <div class="cell-link-item">
                    <img :src="item.iconUrl" class="link-item-icon">
                    {{ $t(`common.${item.name}`) }}
                  </div>
                </template>
                <div class="coll-content">
                  <div
                    v-for="(cItem, cIndex) of item.child"
                    :key="index + '-' + cIndex"
                    :class="[
                      'coll-item',
                      currentPage === cItem.toLink ? 'active' : '',
                    ]"
                    @click="handleGoToLink(cItem.toLink, item.href)"
                  >
                    {{ $t(`common.${cItem.name}`) }}
                  </div>
                </div>
              </van-collapse-item>
              <div
                v-else
                :key="index"
                :class="[
                  'link-item',
                  currentPage === item.toLink ? 'active' : '',
                ]"
                @click="handleGoToLink(item.toLink, item.href)"
              >
                <img
                  v-if="item.iconUrl"
                  :src="item.iconUrl"
                  class="link-item-icon"
                >
                {{ $t(`common.${item.name}`) }}
              </div>
            </template>
          </van-collapse>
        </div>
        <div class="version">Version：v1.0（Public Beta)</div>
      </div>
    </div> -->
  </div>
</template>

<script>
import { copy, plusXing } from "../../utils/index";
import { mapGetters } from "vuex";
export default {
  name: "SiteHeader",
  data() {
    return {
      isShowMenu: false,
      showPopover: false,
      showPopover2: false,
      linkList: [],
      activeName: "",
      langName: "",
      currentPage: "",
    };
  },
  computed: {
    ...mapGetters(["wallet"]),
  },
  watch: {
    $route: {
      handler(to) {
        this.currentPage = to.path;
      },
      deep: true,
      immediate: true,
    },
  },
  created() {
    this.currentPage = this.$route.path;

    const lang = this.language.filter(
      (item) => item.key === this.$i18n.locale
    )[0];
    this.langName = lang.name;
  },
  methods: {
    handleConnectWallet() {
      this.$w.connectWallet().then((res) => {
        this.wallet.isConnected = this.$w.getConnectStatus();
      });
    },
    handleCloseConnect() {
      this.wallet.isConnected = this.$w.closeConnect();
      this.isShowMenu = false;
    },
    handleCopyAddress() {
      copy(this.wallet.address);
      this.$toast(this.$t("common.copySuccess"));
    },
    handleNavMenuSwitch() {
      this.isShowMenu = !this.isShowMenu;
    },
    handleGoToLink(to, href) {
      if (href) {
        window.location.href = href;
        return;
      }
      this.isShowMenu = false;
      if (this.$route.path === to) {
        return;
      }
      this.$router.push(to);
    },
    handleLanguageSelect({ key }) {
      const lang = this.language.filter((item) => item.key === key)[0];
      this.langName = lang.name;
      this.$i18n.locale = key;
      localStorage.setItem("lang", key);
    },
    handleWallteSelect(e) {
      this.isShowMenu = false;
      switch (e.id) {
        case 1:
          this.$router.push("/userCard");
          break;
        case 2:
          this.$router.push("/userBlindbox");
          break;
      }
    },
    handlePlusXing(address, start = 9, end = 4) {
      return plusXing(address, start, end);
    },
  },
};
</script>

<style lang="less">
.layout-header {
  .van-collapse {
    .van-collapse-item--border::after {
      display: none;
    }
    .van-collapse-item__title:active {
      background-color: transparent;
    }
    .van-collapse-item__title::after {
      display: none;
    }
  }
}
</style>

<style lang="less" scoped>
.layout-header {
  position: sticky;
  top: 0;
  left: 0;
  z-index: 99;
  display: flex;
  align-items: center;
  align-content: center;
  justify-content: space-between;
  padding: 0 0 0 0.64rem;
  background-color: #000;
  height: 1.6rem /* 120/75 */;
  .menu-btn {
    display: flex;
    align-items: center;
    align-content: center;
    // .online-dot {
    //   margin-right: 0.4rem /* 30/75 */;
    //   display: inline-block;
    //   width: 0.1333333333rem;
    //   height: 0.1333333333rem;
    //   border-radius: 50%;
    //   background: linear-gradient(180deg, #30d891, #19d284);
    //   box-shadow: 0 0.1066666667rem 0.1066666667rem rgb(41 215 142 / 20%);
    // }
    .nav-open-btn {
      .nav-menu-line {
        width: 0.586667rem /* 44/75 */;
        height: 0.053333rem /* 4/75 */;
        background-color: #fff;
        transition: all 0.2s ease-in-out;
        border-radius: 0.133333rem /* 10/75 */;
        &:nth-child(2) {
          width: 0.506667rem /* 38/75 */;
          margin: 0.133333rem /* 10/75 */ 0;
        }
      }
      &.active {
        .nav-menu-line {
          &:nth-child(1) {
            transform: rotate(45deg)
              translate(0.2rem /* 15/75 */, 0.133333rem /* 10/75 */);
          }
          &:nth-child(2) {
            opacity: 0;
          }
          &:nth-child(3) {
            transform: rotate(-45deg)
              translate(0.12rem /* 9/75 */, -0.066667rem /* -5/75 */);
          }
        }
      }
    }
  }
  .logo {
    position: absolute;
    left: 1.866667rem /* 140/75 */;
    top: 50%;
    transform: translateY(-50%);
    img {
      width: 1.333333rem /* 100/75 */;
    }
  }
  .header-right {
    display: flex;
    align-items: center;
    align-content: center;
    > .connect-btn {
      padding: 0;

      span {
        border: 0.026667rem /* 2/75 */ solid #fff;
        padding: 0 0.266667rem /* 20/75 */;
        white-space: nowrap;
        width: 100%;
        height: 100%;
      }
    }
    .connected-btn {
      display: flex;
    }
    .connect-btn-wrap {
      display: flex;
      align-items: center;
      align-content: center;
      height: 1.6rem /* 120/75 */;
      .connect-btn {
        height: 0.746667rem /* 56/75 */;
        border-radius: 0.48rem;
        font-size: 0.3666666667rem;
        text-align: center;
        font-weight: 400;
        white-space: nowrap;
        border: 0.026667rem /* 2/75 */ solid #fff;
        padding: 0;
        span {
          min-width: 1.733333rem /* 130/75 */;
          padding: 0 0.3266666667rem;
          width: 100%;
          height: 100%;
        }
      }
    }
    .lang-wrap {
      margin-left: 0.533333rem /* 40/75 */;
      .lang {
        padding-right: 0.533333rem /* 40/75 */;
        font-size: 0.4rem /* 30/75 */;
        color: #fff;
        height: 1.6rem /* 120/75 */;
        line-height: 1.6rem;
      }
    }
  }
  .nav-menu-mask {
    .mask {
      content: "";
      position: absolute;
      width: 100%;
      height: 100%;
      background-color: rgba(0, 0, 0, 0.4);
      left: 100%;
      top: 0;
      right: 0;
      bottom: 0;
      opacity: 0;
      display: none;
      transition: all 0.3s;
    }
    position: fixed;
    left: -100%;
    bottom: 0;
    bottom: 0;
    width: 70%;
    height: calc(100vh - 1.6rem /* 120/75 */);
    background-color: #000;
    z-index: 98;
    box-sizing: border-box;
    // padding: 0 0.533333rem /* 40/75 */;
    transition: all 0.3s;
    &.active {
      left: 0;
      .mask {
        display: block;
        opacity: 1;
      }
    }
    .nav-menu-mask-scroll {
      box-sizing: border-box;
      padding-bottom: 1.066667rem /* 80/75 */;
      height: 100%;
      border-top: 1px solid #777;
    }
    .user-operate {
      display: flex;
      padding: 0.266667rem /* 20/75 */;
      border-bottom: 1px solid #777;
      .address {
        padding: 0.106667rem /* 8/75 */ 0.266667rem /* 20/75 */;
        border: 1px solid #eee;
        color: #eee;
        border-radius: 0.4rem /* 30/75 */;
        font-size: 0.4rem /* 30/75 */;
      }
      .operate-wrap {
        margin-left: 0.266667rem /* 20/75 */;
        flex: 1;
        display: flex;
        align-items: center;
        align-content: center;
        justify-content: space-between;
        .operate-item {
          width: 0.666667rem /* 50/75 */;
          height: 0.666667rem /* 50/75 */;
          display: flex;
          align-content: center;
          align-items: center;
          justify-content: center;
          > img {
            display: block;
            width: 70%;
            height: 70%;
          }
        }
      }
    }
    .user-linker {
      height: calc(100% - 1.333333rem /* 100/75 */);
      overflow-y: auto;
      &::-webkit-scrollbar {
        display: none;
      }
      & /deep/ .van-collapse-item {
        .van-cell {
          background-color: transparent;
        }
        .van-collapse-item__content {
          padding-top: 0.266667rem /* 20/75 */;
          padding-bottom: 0.266667rem /* 20/75 */;
          background-color: transparent;
          color: #fff;
        }
      }
      .cell-link-item {
        padding-left: 1.2rem /* 90/75 */;
        position: relative;
        font-size: 0.426667rem /* 32/75 */;
        color: #fff;
        .link-item-icon {
          position: absolute;
          top: 50%;
          transform: translateY(-50%);
          left: 0;
          width: 0.746667rem /* 56/75 */;
          height: 0.746667rem /* 56/75 */;
        }
      }
      .coll-content {
        .coll-item {
          &:first-child {
            margin-top: 0;
          }
          margin-top: 0.333333rem /* 25/75 */;
          padding-left: 1.2rem /* 90/75 */;
          font-size: 0.383333rem;
          color: #fff;
          &.active {
            color: #4381ec;
          }
        }
      }
      .link-item {
        // border-bottom: .026667rem /* 2/75 */ solid #ddd;
        line-height: 1;
        padding: 0.4rem /* 30/75 */ 0.36rem /* 27/75 */ 0.4rem /* 30/75 */
          1.6rem /* 120/75 */;
        display: block;
        position: relative;
        font-size: 0.426667rem /* 32/75 */;
        color: #fff;
        &:first-child {
          .link-item-icon {
            left: 0.453333rem /* 34/75 */;
          }
        }
        &.active {
          color: #4381ec;
        }
        .link-item-icon {
          position: absolute;
          top: 50%;
          transform: translateY(-50%);
          left: 0.36rem /* 27/75 */;
          width: 0.746667rem /* 56/75 */;
          height: 0.746667rem /* 56/75 */;
        }
      }
    }
    .version {
      text-align: center;
      width: 100%;
      font-size: 0.4rem /* 30/75 */;
      left: 50%;
      transform: translateX(-50%);
      position: absolute;
      bottom: 0.266667rem /* 20/75 */;
      color: #fff;
    }
  }
}
</style>
