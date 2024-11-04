<script setup lang="ts">
import 'primeicons/primeicons.css'
import type { Review } from '~/types';
import { timeAgo } from '~/utils/timeAgo';

defineProps({
  review: {
    type: Object as PropType<Review>,
    required: true
  },
});

const isAuthor = ref(true)
const like = ref(false)

const menu = ref()
const authorItems = ref([
    { label: 'Editar', icon: 'pi pi-pencil' },
    { label: 'Eliminar', icon: 'pi pi-trash' }
])

const nonAuthorItems = [
    { label: 'Denunciar', icon: 'pi pi-flag' }
]

const toggle = (event) => {
  menu.value.toggle(event);
};

</script>

<template>
  <div class="w-full flex flex-col p-6 gap-3 border rounded-xl shadow-sm hover:shadow-lg transition-all duration-500 hover:border-violet-300 dark:bg-black dark:border-gray-500/70">
    <div class="flex items-center justify-between">
      <div class="flex items-center">
        <Avatar :label="review.author[0]" class="mr-2.5" size="large" shape="circle" />
        <div class="inline-flex items-baseline sm:flex-col">
          <h1 class="text-2xl font-bold">{{ review.author }}</h1>
          <h2 class="ml-1.5 text-gray-500 dark:text-gray-400">{{ timeAgo(review.datetime) }}</h2>
        </div>
      </div>
      <div class="flex gap-2">
        <Chip :label="review.rating" icon="pi pi-star-fill" />
        <Button type="button" severity="secondary" icon="pi pi-ellipsis-v" @click="toggle" rounded />
        <Menu ref="menu" :model="isAuthor ? authorItems : nonAuthorItems" :popup="true" />
      </div>

    </div>
    <p class="text-lg">{{ review.content }}</p>
    <div class="flex gap-3 mt-2">
      <span class="inline-flex items-center gap-1 text-gray-800 dark:text-gray-400">
        <Button severity="secondary" :icon="like ? 'pi pi-thumbs-up-fill' : 'pi pi-thumbs-up'" aria-label="Like" rounded @click="like=true"/>
        200
      </span>
      <Button severity="secondary" :icon="like ? 'pi pi-thumbs-down' : 'pi pi-thumbs-down-fill'" aria-label="Dislike" rounded @click="like=false"/>
    </div>
  </div>
</template>