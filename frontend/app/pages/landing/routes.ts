import type {RouteRecordRaw} from "vue-router";
import LandingLayout from "@app/app/pages/landing/LandingLayout.vue";

const routes: RouteRecordRaw[] = [
  {
    path: '/landing',
    component: LandingLayout,
    children: [
      {
        path: '/1'
      }
    ]
  }
]

export default routes;
