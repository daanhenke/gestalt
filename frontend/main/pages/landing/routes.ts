import type {RouteRecordRaw} from "vue-router";

import LandingLayout from "./LandingLayout.vue";
import Login from "./steps/Login.vue";

const routes: RouteRecordRaw[] = [
  {
    path: '/landing',
    component: LandingLayout,
    children: [
      {
        path: '/1',
        component: Login,
      }
    ]
  }
]

export default routes;
