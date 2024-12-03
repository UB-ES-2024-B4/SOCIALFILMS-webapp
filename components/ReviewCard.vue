<script setup lang="ts">
import "primeicons/primeicons.css";
import { onMounted } from "vue";
import type { Review, Film } from "~/types";
import { timeAgo } from "~/utils/timeFunctions";

const supabase = useSupabaseClient();
const user = useSupabaseUser();
const toast = useToast();
const confirm = useConfirm();

const props = defineProps({
  review: {
    type: Object as PropType<Review>,
    required: true,
  },
  film: {
    type: Object as PropType<Film | undefined>,
    required: true,
  },
  showFilm: {
    type: Boolean,
    default: false,
  },
});

const review = reactive<Review>({ ...props.review });

const openEditDialog = () => {
  if (!visible.value) {
    visible.value = true;
  }
};

const openReportDialog = () => {
  if (!visible_report.value) {
    visible_report.value = true;
  }
};

const menu = ref();
const authorItems = ref([
  {
    label: "Editar",
    icon: "pi pi-pencil",
    command: openEditDialog,
    disabled: props.review.editable === false,
  },
  { label: "Eliminar", icon: "pi pi-trash", command: () => { confirmPosition('bottomright')}},
]);

const nonAuthorItems = [{ label: "Denunciar", icon: "pi pi-flag",  command: openReportDialog}];

const toggleMenu = (event) => {
  menu.value.toggle(event);
};

const popoverFilm = ref();
const togglePopover = (event) => {
  popoverFilm.value.toggle(event);
};

const emit = defineEmits<{
  (event: 'delete-review', review_id: string): void;
}>();

const confirmPosition = async (position) => {
  if (!confirmVisible.value) {
    confirmVisible.value = true;
  }
  confirm.require({
      group: 'positioned',
      message: '¿Estás seguro de que deseas eliminar esta reseña?',
      header: 'Eliminar reseña',
      icon: 'pi pi-info-circle',
      position: position,
      rejectProps: {
          label: 'Cancelar',
          severity: 'secondary',
          outlined: true
      },
      acceptProps: {
          label: 'Eliminar',
          severity: 'danger'
      },
      accept: async () => {
        const { data: reviewData, error: reviewError } = await supabase.rpc('delete_review', {_review_id: props.review.id })
        if (reviewError) {
            toast.add({ severity: 'error', summary: 'Error al eliminar', detail: 'No se ha podido eliminar la reseña', life: 3000 })
        } else {
            toast.add({ severity: 'success', summary: 'Eliminación exitosa', detail: 'Tu reseña se ha eliminado correctamente.', life: 3000 });
            emit('delete-review', props.review.id);
            visible.value = false;
        }
        confirmVisible.value = false;
      },
      reject: () => {
          confirmVisible.value = false;
      }
    });
};

const spoiler = ref(true)
const isBlurred = ref(true)
const checked = ref(false)
const confirmVisible = ref(false);
const rating = ref(1)
const comment = ref('')
const numCharacters = computed(() => {
  return comment.value.length;
});

const visible = ref(false)
const visible_report = ref(false)
const like = ref();
const dislike = ref();

try {
  const { data: reaction, error: errorReaction } = await supabase.rpc('get_user_reaction_review', { _review_id: props.review.id });
  if (errorReaction) throw errorReaction; 
  if (reaction === 'like') like.value = true
  else if (reaction === 'dislike') dislike.value = true
} catch (error) {
  switch (error.code) {
    case 'P0001':
      like.value = false
      dislike.value = false
      break;
  }
}


const handleRemoveReaction = async () => {
  const { error } = await supabase.rpc('remove_reaction', { _review_id: props.review.id })
  if (error) throw new Error("DELETE_REACTION_ERROR");
}

const handleAddReaction = async (reactionType: string) => {
  const rpcFunction = reactionType === 'like' ? 'add_like' : 'add_dislike';
  const { error } = await supabase.rpc(rpcFunction, { _review_id: props.review.id });
  if (error) throw new Error(reactionType === 'like' ? "ADD_LIKE_ERROR" : "ADD_DISLIKE_ERROR");
};

const handleReaction = async (type: string) => {
  try {
    if (type === 'like') {
      if (like.value){
        await handleRemoveReaction();
        review.likes -= 1;
      }
      else {
        await handleAddReaction('like');
 
        if (dislike.value) {
          dislike.value = false;
          review.dislikes -= 1;
        }
        review.likes += 1;
      }
      like.value = !like.value;
    }
    else {
      if (dislike.value){
        await handleRemoveReaction();
        review.dislikes -= 1;
      }
      else {
        await handleAddReaction('dislike');

        if (like.value) {
          like.value = false;
          review.likes -= 1;
        }
        review.dislikes += 1;
      }
      dislike.value = !dislike.value;
    } 
  } catch (error) {
    handleReactionError(error.message);
  }
};

const handleReactionError = (errorCode: string) => {
  const errorMessages = {
    DELETE_REACTION_ERROR: {
      severity: 'error',
      summary: 'Error al eliminar la reacción',
      detail: 'No se ha podido eliminar la reacción a la reseña',
    },
    ADD_LIKE_ERROR: {
      severity: 'error',
      summary: 'Error al añadir like',
      detail: 'No se ha podido añadir like a la reseña',
    },
    ADD_DISLIKE_ERROR: {
      severity: 'error',
      summary: 'Error al añadir dislike',
      detail: 'No se ha podido añadir dislike a la reseña',
    },
  };

  const toastMessage = errorMessages[errorCode];
  if (toastMessage) {
    toast.add({ ...toastMessage, life: 3000 });
  } else {
    console.error("Error no identificado:", errorCode);
  }
};

onMounted(() => {
    comment.value = props.review.comment ?? ''
    rating.value = props.review.rating ?? 1
    checked.value = props.review.spoilers ?? false
    spoiler.value = props.review.spoilers ?? true

});

const selectRating = (star: number) => {
  rating.value = star;
};

const submitReview = async () => {
  const user_id = user.value?.id;

  if (!user_id) {
    toast.add({ severity: "error", summary: "Error", detail: "Debes estar logueado para dejar una reseña.", life: 3000})
    visible.value = false;
    return;
  }

    const { data: reviewData, error: reviewError } = await supabase.rpc('update_review', {_review_id: props.review.id, _rating: rating.value, _comment: comment.value, _spoilers: checked.value })
    if (reviewError) {
        toast.add({ severity: 'error', summary: 'Error al actualizar', detail: 'Asegúrate de modificar la calificación o escribir un comentario válido antes de guardar.', life: 3000 })
    } else {
        toast.add({ severity: 'success', summary: 'Actualización exitosa', detail: 'Tu reseña se ha actualizado correctamente.', life: 3000 });
        visible.value = false;
        props.review.comment = comment.value ?? ''
        props.review.rating = rating.value
        spoiler.value = checked.value
    }
}

const actualReportReason = ref('0');
const value_otros = ref(null);
const reportOptions = [
  { label: 'Contenido Ofensivo', value: '0'},
  { label: 'Spam', value: '1'},
  { label: 'Desinformación', value: '2' },
  { label: 'Otros', value: '3' },
];
const isLoadingReport = ref(false);

const submitReport = async () => {
  const user_id = user.value?.id;

  if (!user_id) {
    toast.add({ severity: "error", summary: "Error", detail: "Debes estar logueado para reportar una reseña.", life: 3000})
    visible.value = false;
    return;
  }
    isLoadingReport.value = true;
    const reason = reportOptions.find((option) => option.value === actualReportReason.value)?.label;
    console.log(reason)
    const { data: reportData, error: reportError } = await supabase.rpc('add_report', {_review_id: props.review.id, _reason: reason, _other_reason: value_otros.value })
    if (reportError) {
        toast.add({ severity: 'error', summary: 'Error al reportar', detail: 'No sé ha podido enviar el reporte, intentalo más tarde', life: 3000 })
        visible_report.value = false
    } else {
        toast.add({ severity: 'success', summary: 'Reporte exitoso', detail: 'Tu reporte se ha enviado correctamente.', life: 3000 });
        visible_report.value = false
    }
    isLoadingReport.value = false;
}
</script>

<template>
  <Toast />
  <ConfirmDialog group="positioned" v-model:visible="confirmVisible" />
  <Dialog v-model:visible="visible" modal header="Editar reseña">
    <div class="flex flex-col mt-4 space-y-4">
      <div class="flex space-x-8">
        <div class="flex flex-col">
          <h2
            class="font-bold whitespace-nowrap text-2xl text-gray-800 dark:text-gray-100 leading-tight"
          >
            {{ film?.title }}
          </h2>

          <div class="flex items-center space-x-1.5 mt-3">
            <span
              :class="
                film?.adult
                  ? 'tag_dialog bg-red-500/20 border border-red-500 whitespace-nowrap text-red-500 dark:bg-red-500/20 dark:border-red-400 dark:text-red-400'
                  : 'tag_dialog bg-green-500/20 border border-green-500 whitespace-nowrap text-green-500 dark:bg-green-500/20 dark:border-green-400 dark:text-green-400'
              "
            >
              {{ film?.adult ? "R" : "PG-13" }}
            </span>
            <span
              class="tag_dialog border border-gray-400 whitespace-nowrap text-gray-800 dark:text-gray-200"
            >
              <i class="pi pi-calendar mr-1.5 text-[0.8rem]"></i>
              {{ film?.release_date }}
            </span>
            <span
              class="tag_dialog border border-gray-400 text-gray-800 dark:text-gray-200"
            >
              <i
                class="pi pi-star-fill text-yellow-400 dark:text-yellow-400 mr-1.5 text-[0.8rem]"
              ></i>
              {{ film?.vote_average.toFixed(1) }}
            </span>
          </div>

          <h3 class="mt-auto">Califica del 1 al 10 ({{ rating }})</h3>
          <div class="flex mb-4 items-center space-x-2">
            <span
              v-for="star in 10"
              :key="star"
              @mouseover="selectRating(star)"
              class="cursor-pointer text-2xl transition-transform duration-200 transform"
              :class="{ 'scale-125': star === rating }"
            >
              <i
                :class="[
                  'pi',
                  star <= rating ? 'pi-star-fill text-yellow-400' : 'pi-star',
                ]"
              ></i>
            </span>
          </div>
        </div>
        <img
          :src="'https://image.tmdb.org/t/p/original' + film?.poster_path"
          :alt="`${film?.title} poster`"
          class="w-2/3 h-72 object-cover rounded-lg"
        />
      </div>
      <div class="relative mb-4">
        <Textarea
          autoResize
          v-model="comment"
          rows="4"
          cols="20"
          maxlength="255"
          placeholder="Escribe tu comentario..."
          class="mb-4 w-full"
        />
        <span class="absolute right-2 bottom-[-0.1rem] text-gray-500 text-sm">
          {{ numCharacters }} / 255
        </span>
      </div>
        <div v-if="user" class="flex justify-between">
          <Button label="Cancelar" severity="secondary" @click="visible=false" />
          <div class="flex items-center gap-7">
            <div class="relative flex items-center justify-center">
              <span class="absolute top-[-1.3rem] text-sm">Spoiler</span>
              <ToggleSwitch v-model="checked"/>
            </div>
            <Button label="Publicar" @click="submitReview" />
          </div>
        </div>
    </div>
  </Dialog>

  <Dialog v-model:visible="visible_report" modal class="w-[50rem]" :draggable="false">
    <template #header>
      <div class="flex flex-row items-start mt-3 ml-3">
        <div class="flex flex-col gap-2 items-start">
          <h1 class="text-3xl font-bold text-gray-800 dark:text-gray-100">Reportar reseña</h1>
          <p class="text-lg text-gray-600 dark:text-gray-300">No le diremos nada a <strong>{{ review.user ? review.user : "User not found" }}</strong></p>
        </div>
      </div>
    </template>
      <Tabs v-model:value="actualReportReason">
          <TabList>
            <Tab v-for="reportReason in reportOptions" :key="reportReason.label" :value="reportReason.value"> {{ reportReason.label }}</Tab>
          </TabList>
          <TabPanels>
              <TabPanel value="0">
                <p class="text-gray-600 dark:text-gray-100">Está prohibido el contenido que promueva odio, violencia, discriminación o acoso hacia cualquier individuo o grupo por razones de étnia, género, orientación sexual, religión, nacionalidad, discapacidad, entre otros.</p><br/>
                <p class="text-gray-600 dark:text-gray-100">Ejemplos de contenido ofensivo incluyen:</p>

                <ul class="list-disc pl-6 text-gray-600 dark:text-gray-100">
                  <li>Lenguaje vulgar o amenazas.</li>
                  <li>Insultos o comentarios despectivos.</li>
                  <li>Contenido que incite a la violencia o discriminación.</li>
                </ul>
              </TabPanel>
              <TabPanel value="1">
                <p class="text-gray-600 dark:text-gray-100">Está prohibido enviar mensajes no solicitados, promociones excesivas o contenido irrelevante con el único fin de obtener beneficios personales o comerciales.</p><br/>
                <p class="text-gray-600 dark:text-gray-100">Ejemplos de contenido ofensivo incluyen:</p>

                <ul class="list-disc pl-6 text-gray-600 dark:text-gray-100">
                  <li>Publicidad masiva no solicitada.</li>
                  <li>Enlaces repetidos que no aportan valor.</li>
                  <li>Mensajes con fines de phishing o fraude.</li>
                </ul>
              </TabPanel>
              <TabPanel value="2">
                <p class="text-gray-600 dark:text-gray-100">Está prohibido difundir información falsa o engañosa que pueda causar daño a la comunidad, como noticias inventadas, teorías conspirativas o datos erróneos.</p><br/>
                <p class="text-gray-600 dark:text-gray-100">Ejemplos de contenido ofensivo incluyen:</p>

                <ul class="list-disc pl-6 text-gray-600 dark:text-gray-100">
                  <li>Difusión de noticias falsas o engañosas.</li>
                  <li>Propagación de teorías conspirativas sin evidencia.</li>
                  <li>Información que pueda poner en peligro la salud o seguridad de las personas.</li>
                </ul>
              </TabPanel>
              <TabPanel value="3">
                <p class="text-gray-600 dark:text-gray-100">Nuestra prioridad es ofrecer un entorno seguro y solidario. También fomentar interacciones auténticas manteniendo el contenido y las cuentas engañosas al margen de nuestra plataforma.</p><br/>
                <p class="text-gray-600 dark:text-gray-100">Si tu denuncia no encaja en las categorías anteriores, por favor explícanos brevemente el motivo.</p><br/>

                <FloatLabel variant="in">
                  <Textarea maxlength="250" id="over_label" v-model="value_otros" rows="3" cols="30" class="resize-none w-full" />
                  <label for="in_label" class="text-gray-600 text-sm">Denuncia</label>
              </FloatLabel>
              </TabPanel>
          </TabPanels>
      </Tabs>
    <template #footer>
      <div class="flex gap-2 items-end">
        <Button label="Cancelar" severity="secondary" @click="visible=false" />
        <Button label="Denunciar" :loading="isLoadingReport" @click="submitReport" />
      </div>
    </template>
  </Dialog>

  <div
    class="w-full flex flex-col p-6 gap-3 border-[1.5px] border-gray-400 rounded-xl shadow-sm hover:shadow-lg transition-all duration-500 hover:border-violet-400 bg-white/80 dark:bg-black/60 dark:border-gray-500/70"
  >
    <div class="flex items-center justify-between">
      <div class="flex items-center" >
        <Avatar
          :label="review.user ? review.user[0] : 'T'"
          class="mr-2.5 cursor-pointer"
          size="large"
          shape="circle"
          @click="navigateTo(`/profile/${review.user}`)"
        />
        <div class="inline-flex items-baseline sm:flex-col">
          <h1 class="text-2xl font-bold cursor-pointer" @click="navigateTo(`/profile/${review.user}`)">
            {{ review.user ? review.user : "User not found" }}
          </h1>
          <h2 class="ml-1.5 text-gray-500 dark:text-gray-400">
            {{ timeAgo(review.created_at) }}
          </h2>
        </div>
      </div>
      <div class="flex items-center gap-2">
        <div
          class="bg-slate-100 dark:bg-zinc-700 p-1.5"
          style="border-radius: 30px"
        >
          <div
            class="bg-white dark:bg-zinc-800 flex items-center gap-2 justify-center py-1 px-2"
            style="
              border-radius: 30px;
              box-shadow: 0px 1px 2px 0px rgba(0, 0, 0, 0.04),
                0px 1px 2px 0px rgba(0, 0, 0, 0.06);
            "
          >
            <span class="text-slate-900 dark:text-slate-200 font-medium">{{
              review.rating
            }}</span>
            <i class="pi pi-star-fill text-yellow-500"></i>
          </div>
        </div>
        <Button
          v-if="showFilm"
          v-tooltip.right="'Info película'"
          type="button"
          severity="secondary"
          rounded
          @click="togglePopover"
        >
          <template #icon>
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
              <path stroke-linecap="round" stroke-linejoin="round" d="M3.375 19.5h17.25m-17.25 0a1.125 1.125 0 0 1-1.125-1.125M3.375 19.5h1.5C5.496 19.5 6 18.996 6 18.375m-3.75 0V5.625m0 12.75v-1.5c0-.621.504-1.125 1.125-1.125m18.375 2.625V5.625m0 12.75c0 .621-.504 1.125-1.125 1.125m1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125m0 3.75h-1.5A1.125 1.125 0 0 1 18 18.375M20.625 4.5H3.375m17.25 0c.621 0 1.125.504 1.125 1.125M20.625 4.5h-1.5C18.504 4.5 18 5.004 18 5.625m3.75 0v1.5c0 .621-.504 1.125-1.125 1.125M3.375 4.5c-.621 0-1.125.504-1.125 1.125M3.375 4.5h1.5C5.496 4.5 6 5.004 6 5.625m-3.75 0v1.5c0 .621.504 1.125 1.125 1.125m0 0h1.5m-1.5 0c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125m1.5-3.75C5.496 8.25 6 7.746 6 7.125v-1.5M4.875 8.25C5.496 8.25 6 8.754 6 9.375v1.5m0-5.25v5.25m0-5.25C6 5.004 6.504 4.5 7.125 4.5h9.75c.621 0 1.125.504 1.125 1.125m1.125 2.625h1.5m-1.5 0A1.125 1.125 0 0 1 18 7.125v-1.5m1.125 2.625c-.621 0-1.125.504-1.125 1.125v1.5m2.625-2.625c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125M18 5.625v5.25M7.125 12h9.75m-9.75 0A1.125 1.125 0 0 1 6 10.875M7.125 12C6.504 12 6 12.504 6 13.125m0-2.25C6 11.496 5.496 12 4.875 12M18 10.875c0 .621-.504 1.125-1.125 1.125M18 10.875c0 .621.504 1.125 1.125 1.125m-2.25 0c.621 0 1.125.504 1.125 1.125m-12 5.25v-5.25m0 5.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125m-12 0v-1.5c0-.621-.504-1.125-1.125-1.125M18 18.375v-5.25m0 5.25v-1.5c0-.621.504-1.125 1.125-1.125M18 13.125v1.5c0 .621.504 1.125 1.125 1.125M18 13.125c0-.621.504-1.125 1.125-1.125M6 13.125v1.5c0 .621-.504 1.125-1.125 1.125M6 13.125C6 12.504 5.496 12 4.875 12m-1.5 0h1.5m-1.5 0c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125M19.125 12h1.5m0 0c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125m-17.25 0h1.5m14.25 0h1.5" />
            </svg>
          </template>
        </Button>
        <Popover ref="popoverFilm">
          <div class="rounded flex flex-col w-44 sm:w-56">
            <img class="rounded mx-auto" :src="'https://image.tmdb.org/t/p/original' + film?.poster_path" :alt="`${film?.title} poster`" />
            <div class="pt-4">
              <div class="flex flex-row justify-between items-start gap-2 mb-4">
                <div class="w-44 sm:w-2/3">
                  <span class="font-medium text-slate-500 dark:text-slate-400 text-sm truncate block">{{ film?.genres?.map((genre) => genre.name).join(" • ") }}</span>
                  <div class="text-lg font-semibold mt-1">{{ film?.title }}</div>
                </div>
                <div class="bg-slate-100 dark:bg-zinc-700 p-1" style="border-radius: 30px">
                  <div class="bg-white dark:bg-zinc-800 flex items-center gap-2 justify-center py-1 px-2" style="border-radius: 30px; box-shadow: 0px 1px 2px 0px rgba(0, 0, 0, 0.04), 0px 1px 2px 0px rgba(0, 0, 0, 0.06)">
                    <span class="text-slate-900 dark:text-slate-200 font-medium text-sm">{{ film?.vote_average }}</span>
                    <i class="pi pi-star-fill text-yellow-500"></i>
                  </div>
                </div>
              </div>
              <div class="flex gap-2">
                <Button icon="pi pi-arrow-up-right" label="Ver película" fluid @click="navigateTo(`/movies/${film?.id}`);"></Button>
              </div>
            </div>
          </div>
        </Popover>
        <Button
          type="button"
          severity="secondary"
          icon="pi pi-ellipsis-v"
          @click="toggleMenu"
          rounded
        />
        <Menu
          ref="menu"
          :model="user?.id == review.user_id ? authorItems : nonAuthorItems"
          :popup="true"
        />
      </div>

    </div>
    
    <div class="flex flex-col items-start relative">
      <p 
        v-if="spoiler && isBlurred"
        class="absolute top-0 left-0 w-full text-lg font-medium z-10 transition-all duration-500">
        ⚠️ Esta review contiene spoilers!
      </p>
      <p :class="[ 'text-lg transition-all duration-500 relative', spoiler && isBlurred ? 'blur-md' : '' ]">
        {{ review.comment }}
      </p>
      <Button 
          v-if="spoiler"
          class="mt-3"
          :icon="(!isBlurred && spoiler) ? 'pi pi-eye-slash' : 'pi pi-eye'"
          @click="isBlurred = !isBlurred"
          rounded
          variant="outlined"
          :label="(!isBlurred && spoiler) ? 'Ocultar' : 'Mostrar'"
      />
    </div>
    <div class="flex gap-3 mt-1">
      <span
        class="inline-flex items-center gap-1 text-gray-800 dark:text-gray-400"
      >
        <Button
          severity="secondary"
          :icon="like ? 'pi pi-thumbs-up-fill' : 'pi pi-thumbs-up'"
          aria-label="Like"
          rounded
          :disabled="!user"
          @click="handleReaction('like')"
        />
        {{ review.likes == 0 ? "" : review.likes }}
      </span>
      <span
        class="inline-flex items-center gap-1 text-gray-800 dark:text-gray-400"
      >
        <Button
          severity="secondary"
          :icon="dislike ? 'pi pi-thumbs-down-fill' : 'pi pi-thumbs-down'"
          aria-label="Dislike"
          rounded
          :disabled="!user"
          @click="handleReaction('dislike')"
        />
        {{ review.dislikes == 0 ? "" : review.dislikes }}
      </span>
    </div>
  </div>
</template>

<style scoped>
.tag_dialog {
  padding: 0.2rem 0.5rem;
  font-size: 0.8rem;
  font-weight: 400;
  border-radius: 9999px;
  display: inline-flex;
  align-items: center;
  backdrop-filter: blur(8px);
}
</style>
