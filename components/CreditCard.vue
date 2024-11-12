<script setup lang="ts">
import 'primeicons/primeicons.css'

defineProps({
  image: {
    type: [String, null],
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
  <div class="flex items-center gap-5 py-2 w-full">
		<div class="flex-shrink-0">
      <Image v-if="image" preview>
        <template #previewicon>
          <i class="pi pi-expand"></i>
        </template>
        <template #image>
          <img class="w-24 h-24 rounded-full object-cover" :src="'https://image.tmdb.org/t/p/w100_and_h100_face'+image" alt="image" />
        </template>
        <template #preview="slotProps">
          <img :src="'https://image.tmdb.org/t/p/original'+image" alt="preview" :style="slotProps.style" @click="slotProps.onClick" />
        </template>
      </Image>
      <img v-else 
        src="https://www.themoviedb.org/assets/2/v4/glyphicons/basic/glyphicons-basic-4-user-grey-d8fe957375e70239d6abdd549fd7568c89281b2179b5f4470e2e12895792dfa5.svg"
        class="w-24 h-24 rounded-full object-cover bg-gray-200"
        alt="No image" />
    </div>

		<div flex="flex flex-col flex-1 max-w-full">
			<h5 class="text-lg font-bold whitespace-normal break-words">{{ name }}</h5>
			<h6 class="text-lg font-light text-gray-500 dark:text-gray-300 whitespace-normal break-words">{{ rolOrCharacter }}</h6>
		</div>
	</div>
</template>