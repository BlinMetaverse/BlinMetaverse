<template>
  <canvas id="animateBg" class="animate-bg" />
</template>

<script>
import '@/assets/js/three.min.js'
const THREE = window.THREE
export default {
  name: 'ComStarAnimate',
  mounted() {
    this.handleInitBgAnimate()
  },
  methods: {
    handleInitBgAnimate() {
      let rot = 0 // 角度
      const canvas = document.getElementById('animateBg')
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight
      const renderer = new THREE.WebGLRenderer({
        canvas: canvas,
        alpha: true
      })

      const scene = new THREE.Scene()

      scene.fog = new THREE.Fog(0xaaaaaa, 50, 2000)

      const camera = new THREE.PerspectiveCamera(70, 1000)

      const geometry = new THREE.Geometry()

      for (let i = 0; i < 10000; i++) {
        const star = new THREE.Vector3()
        star.x = THREE.Math.randFloatSpread(2000)
        star.y = THREE.Math.randFloatSpread(2000)
        star.z = THREE.Math.randFloatSpread(2000)

        geometry.vertices.push(star)
      }

      const material = new THREE.PointsMaterial({
        color: 0xffffff
      })
      const starField = new THREE.Points(geometry, material)
      scene.add(starField)
      function render() {
        rot += 0.1
        const radian = (rot * Math.PI) / 180
        camera.position.x = 1000 * Math.sin(radian)
        camera.position.z = 1000 * Math.cos(radian)
        camera.lookAt(new THREE.Vector3(0, 0, 0))

        renderer.render(scene, camera)

        requestAnimationFrame(render)
      }
      render()
      window.addEventListener('resize', onResize)
      function onResize() {
        const width = window.innerWidth
        const height = window.innerHeight
        renderer.setPixelRatio(window.devicePixelRatio)
        renderer.setSize(width, height)

        camera.aspect = width / height
        camera.updateProjectionMatrix()
      }
      onResize()
    }
  }
}
</script>

<style lang="less" scoped>
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
</style>
