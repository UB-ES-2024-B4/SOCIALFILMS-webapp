<script setup lang="ts">
import 'primeicons/primeicons.css'

defineProps({
  image: {
    type: String,
    required: true
  },
	name: {
    type: String,
    required: true
  },
	rolOrCharacter: {
    type: String,
    required: true
  }
});

</script>

<template>
  <div class="flex items-center gap-5">
		<Image preview>
			<template #previewicon>
					<i class="pi pi-expand"></i>
			</template>
			<template #image>
					<img class="w-28 h-28 rounded-full object-cover" :src="image" alt="image" />
			</template>
			<template #preview="slotProps">
					<img :src="image" alt="preview" :style="slotProps.style" @click="slotProps.onClick" />
			</template>
		</Image>
		<div flex="flex flex-col">
			<h5 class="text-lg font-bold truncate">{{ name }}</h5>
			<h6 class="text-lg font-light text-gray-500 dark:text-gray-300 truncate">{{ rolOrCharacter }}</h6>
		</div>
	</div>
</template>