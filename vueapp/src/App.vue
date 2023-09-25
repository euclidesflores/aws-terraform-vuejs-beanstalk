<script setup lang="ts">
import Main from './components/Main.vue'
</script>

<template>
  <div>
    <a href="https://terraform.io" target="_blank">
      <img src="/tf.svg"  class="logo" alt="Terraform logo" />
    </a>
    <a href="https://vitejs.dev" target="_blank">
      <img src="/vite.svg" class="logo" alt="Vite logo" />
    </a>
    <a href="https://vuejs.org/" target="_blank">
      <img src="./assets/vue.svg" class="logo vue" alt="Vue logo" />
    </a>
    <a href="https://aws.amazon.com/elasticbeanstalk/" target="_blank">
      <img src="/aws.svg"  class="logo" alt="AWS Elastic Beanstalk logo" />
    </a>    
  </div>
  <Main msg="Terraform + Vite + Vue + AWS Elastic Beanstalk CI/CD tutorial" />
</template>

<style scoped>
.logo {
  height: 6em;
  padding: 1.5em;
  will-change: filter;
  transition: filter 300ms;
}
.logo:hover {
  filter: drop-shadow(0 0 2em #646cffaa);
}
.logo.vue:hover {
  filter: drop-shadow(0 0 2em #42b883aa);
}
</style>
