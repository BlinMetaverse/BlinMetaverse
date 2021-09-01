<template>
  <div class="single-currency">
    <com-page-top :title="$t('singleCurrency.title')" color="#fff" desc="" />
    <single-currency-rules />
    <template v-if="loaded">
      <single-currency-list
        :item-list="poolList"
        :stake-list="stakeList"
        :item-id-list="poolIdList"
        :item-pool-zero="poolCoinZero"
        :pool-status="poolStatus"
        :pool-loading="poolLoading"
        @updateList="handleInitLoadAllData"
      />
    </template>
    <canvas id="animateBg" class="animate-bg" />
  </div>
</template>

<script>
import "@/assets/js/three.min.js";
const THREE = window.THREE;
window.ethers = require("ethers");
import SingleCurrencyList from "./components/SingleCurrencyList.vue";
import SingleCurrencyRules from "./components/SingleCurrencyRules.vue";
export default {
  name: "SingleCurrency",
  components: {
    SingleCurrencyRules,
    SingleCurrencyList,
  },
  data() {
    return {
      poolList: [],
      poolIdList: [],
      poolCoinZero: [],
      stakeList: [],
      timeId: null,
      loaded: false,
      poolStatus: -1,
      poolLoading: true,
    };
  },
  destroyed() {
    clearInterval(this.timeId);
  },
  mounted() {
    this.handleInitBgAnimate();
    this.handleGetPoolStatus();
    this.handleInitLoadAllData();
  },
  methods: {
    async handleGetPoolIdList() {
      const res = await this.$contract.singleCurrency.getPoolIndexes();
      this.poolIdList = res.filter((item) => item.toNumber() !== 0);
      this.handleGetPoolsInfoList();
    },
    async handleGetPoolsInfoList() {
      if (!this.poolIdList.length) {
        return;
      }
      let res = await this.$contract.singleCurrency.getPools([this.poolIdList]);
      if (this.poolStatus === 0) {
        res = res.filter((item) => item[4].gt("0"));
      }
      this.poolList = res;
      if (!this.poolCoinZero.length) {
        for (let o = 0; o < res.length; o++) {
          if (o === 0) {
            this.poolCoinZero.push("18");
            continue;
          }
          const coinAddress = res[o][1];
          try {
            const zeroNum = await this.$contract.decimals(coinAddress);
            this.poolCoinZero.push(zeroNum.toString());
          } catch (error) {
            this.poolCoinZero.push("10");
          }
        }
      }
      const stakeList = [];
      const address = await this.$w.getCurrentAccount();
      for (let i = 0; i < this.poolIdList.length; i++) {
        const res1 = await this.$contract.singleCurrency.getUser([
          this.poolIdList[i],
          address[0],
        ]);
        stakeList.push(res1);
      }
      this.poolLoading = false;
      this.stakeList = stakeList;
    },
    handleTimeLoadData() {
      this.timeId && clearInterval(this.timeId);
      this.timeId = setInterval(() => {
        console.log("updateSuccess");
        this.handleGetPoolsInfoList();
      }, 5000);
    },
    handleInitLoadAllData() {
      this.handleGetPoolIdList();
      this.handleTimeLoadData();
    },
    async handleGetPoolStatus() {
      const res = await this.$contract.singleCurrency.normal();
      this.poolStatus = res[0].toNumber();
      this.loaded = true;
    },
    handleInitBgAnimate() {
      let rot = 0;
      const canvas = document.getElementById("animateBg");
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
      const renderer = new THREE.WebGLRenderer({
        canvas: canvas,
        alpha: true,
      });

      const scene = new THREE.Scene();

      scene.fog = new THREE.Fog(0xaaaaaa, 50, 2000);

      const camera = new THREE.PerspectiveCamera(70, 1000);

      const geometry = new THREE.Geometry();

      for (let i = 0; i < 10000; i++) {
        const star = new THREE.Vector3();
        star.x = THREE.Math.randFloatSpread(2000);
        star.y = THREE.Math.randFloatSpread(2000);
        star.z = THREE.Math.randFloatSpread(2000);

        geometry.vertices.push(star);
      }

      const material = new THREE.PointsMaterial({
        color: 0xffffff,
      });
      const starField = new THREE.Points(geometry, material);
      scene.add(starField);
      function render() {
        rot += 0.1;
        const radian = (rot * Math.PI) / 180;
        camera.position.x = 1000 * Math.sin(radian);
        camera.position.z = 1000 * Math.cos(radian);
        camera.lookAt(new THREE.Vector3(0, 0, 0));

        renderer.render(scene, camera);

        requestAnimationFrame(render);
      }
      render();
      window.addEventListener("resize", onResize);
      function onResize() {
        const width = window.innerWidth;
        const height = window.innerHeight;
        renderer.setPixelRatio(window.devicePixelRatio);
        renderer.setSize(width, height);

        camera.aspect = width / height;
        camera.updateProjectionMatrix();
      }
      onResize();
    },
  },
};
</script>

<style lang="less" scoped>
.single-currency {
  background-color: #000;
  min-height: 100vh;
  position: relative;
  z-index: 1;
  .animate-bg {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    width: 100%;
    height: 100vh;
    z-index: -1;
  }
}
</style>
