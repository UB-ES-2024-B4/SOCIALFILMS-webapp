<script setup lang="ts">
import "primeicons/primeicons.css";
import type { Film, Profile } from "~/types";
import { timeAgo } from "~/utils/timeFunctions";

defineProps({
  sender: {
    type: String,
    required: true,
  },
  receiver: {
    type: String,
    required: true,
  },
  film: {
    type: Object as PropType<Film | undefined>,
    required: false,
  },
});

</script>

<template>
  <div class="w-full flex items-start gap-3 py-3 px-4" :class="{ 'bg-violet-500/15 rounded-lg': true }">
    <img
			class="w-14 h-14 rounded-full object-cover border-[1.5px] border-gray-300"
			src="https://a.storyblok.com/f/191576/1200x800/a3640fdc4c/profile_picture_maker_before.webp"
			alt="image"
			/>

    <div class="inline-flex items-baseline sm:flex-col w-full pr-2">
			<!-- Notification message -->
      <span>
        <strong>{{ sender }}</strong> t'ha compartit la pel·lícula <strong>{{ receiver }}</strong>
      </span>
      <span class="text-gray-500 dark:text-gray-400">
        fa 10 minuts
			</span>
			
			<!-- Movie info -->
			<div class="w-full flex gap-4 border-[1.2px] rounded-lg mt-3 p-3 bg-white">
				<img
					class="w-24 rounded"
					src="https://image.tmdb.org/t/p/original/yh64qw9mgXBvlaWDi7Q9tpUBAvH.jpg"
					alt="image"
					/>
				<div class="w-full flex flex-col justify-between">
					<div class="w-full flex justify-between">
						<div class="pt-1 flex flex-col">
							<h3 class="text-lg font-semibold">Moana 2</h3>
							<span class="w-36 font-medium text-slate-500 dark:text-slate-400 text-sm truncate block">Animation • Adventure • Family • Comedy</span>
						</div>
						<div class="bg-slate-100 dark:bg-zinc-700 p-1 h-[31.5px]" style="border-radius: 30px">
							<div class="bg-white dark:bg-zinc-800 flex items-center gap-2 justify-center py-1 px-2" style="border-radius: 30px; box-shadow: 0px 1px 2px 0px rgba(0, 0, 0, 0.04), 0px 1px 2px 0px rgba(0, 0, 0, 0.06)">
								<span class="text-slate-900 dark:text-slate-200 font-medium text-sm">8.5</span>
								<i class="pi pi-star-fill text-yellow-500"></i>
							</div>
						</div>
					</div>
					<Button icon="pi pi-arrow-up-right" label="Veure pel·lícula" fluid @click="navigateTo(`/movies/${film?.id}`);"></Button>
				</div>
			</div>
    </div>
  </div>
</template>