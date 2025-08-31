import {createRouter as _createRouter, createWebHistory, type RouteRecordRaw} from 'vue-router'

import splash from './splash/routes'
import landing from './landing/routes'


export const routes: RouteRecordRaw[] = [
  ...splash,
  ...landing,
]

export const createRouter = () => _createRouter({
  history: createWebHistory(),
  routes
})
