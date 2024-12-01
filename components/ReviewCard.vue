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
    type: Object as PropType<Film>,
    required: true,
  },
});

const review = reactive<Review>({ ...props.review });

const openEditDialog = () => {
  if (!visible.value) {
    visible.value = true;
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

const nonAuthorItems = [{ label: "Denunciar", icon: "pi pi-flag" }];

const toggle = (event) => {
  menu.value.toggle(event);
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
const visible = ref(false)
const confirmVisible = ref(false);
const rating = ref(1)
const comment = ref('')
const numCharacters = computed(() => {
  return comment.value.length;
});

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
            {{ film.title }}
          </h2>

          <div class="flex items-center space-x-1.5 mt-3">
            <span
              :class="
                film.adult
                  ? 'tag_dialog bg-red-500/20 border border-red-500 whitespace-nowrap text-red-500 dark:bg-red-500/20 dark:border-red-400 dark:text-red-400'
                  : 'tag_dialog bg-green-500/20 border border-green-500 whitespace-nowrap text-green-500 dark:bg-green-500/20 dark:border-green-400 dark:text-green-400'
              "
            >
              {{ film.adult ? "R" : "PG-13" }}
            </span>
            <span
              class="tag_dialog border border-gray-400 whitespace-nowrap text-gray-800 dark:text-gray-200"
            >
              <i class="pi pi-calendar mr-1.5 text-[0.8rem]"></i>
              {{ film.release_date }}
            </span>
            <span
              class="tag_dialog border border-gray-400 text-gray-800 dark:text-gray-200"
            >
              <i
                class="pi pi-star-fill text-yellow-400 dark:text-yellow-400 mr-1.5 text-[0.8rem]"
              ></i>
              {{ film.vote_average.toFixed(1) }}
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
          :src="'https://image.tmdb.org/t/p/original' + film.poster_path"
          :alt="`${film.title} poster`"
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

  <div
    class="w-full flex flex-col p-6 gap-3 border-[1.5px] border-gray-400 rounded-xl shadow-sm hover:shadow-lg transition-all duration-500 hover:border-violet-400 bg-white/80 dark:bg-black/60 dark:border-gray-500/70"
  >
    <div class="flex items-center justify-between">
      <div class="flex items-center">
        <Avatar
          :label="review.user ? review.user[0] : 'T'"
          class="mr-2.5"
          size="large"
          shape="circle"
        />
        <div class="inline-flex items-baseline sm:flex-col">
          <h1 class="text-2xl font-bold">
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
            class="bg-slate-50 dark:bg-zinc-800 flex items-center gap-2 justify-center py-1 px-2"
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
          type="button"
          severity="secondary"
          icon="pi pi-ellipsis-v"
          @click="toggle"
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

    <div class="flex gap-3 mt-2">
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
