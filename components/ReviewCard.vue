<script setup lang="ts">
import "primeicons/primeicons.css";
import { onMounted } from "vue";
import type { Review, Film, Profile } from "~/types";
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
  if (!visibleReport.value) {
    visibleReport.value = true;
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
      message: 'Estàs segur que vols eliminar aquesta ressenya?',
      header: 'Eliminar ressenya',
      icon: 'pi pi-info-circle',
      position: position,
      rejectProps: {
          label: 'Cancel·lar',
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
            toast.add({ severity: 'error', summary: 'Error en eliminar', detail: 'No s\'ha pogut eliminar la ressenya', life: 3000 })
        } else {
            toast.add({ severity: 'success', summary: 'Eliminació exitosa', detail: 'La teva ressenya s\'ha eliminat correctament.', life: 3000 });
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
const visibleReport = ref(false)
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

const isProcessingReaction = ref(false);
const handleReaction = async (type: 'like' | 'dislike') => {
  if (isProcessingReaction.value) return;
  isProcessingReaction.value = true;

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
  } finally {
    isProcessingReaction.value = false;
  }
};

const handleReactionError = (errorCode: string) => {
  const errorMessages = {
    DELETE_REACTION_ERROR: {
      severity: 'error',
      summary: 'Error al eliminar la reacció',
      detail: 'No s\'ha pogut eliminar la reacció a la ressenya',
    },
    ADD_LIKE_ERROR: {
      severity: 'error',
      summary: 'Error al afegir like',
      detail: 'No s\'ha pogut afegir like a la ressenya',
    },
    ADD_DISLIKE_ERROR: {
      severity: 'error',
      summary: 'Error al afegir dislike',
      detail: 'No s\'ha pogut afegir dislike a la ressenya',
    },
  };

  const toastMessage = errorMessages[errorCode];
  if (toastMessage) {
    toast.add({ ...toastMessage, life: 3000 });
  } else {
    console.error("Error no identificat:", errorCode);
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
    toast.add({ severity: "error", summary: "Error", detail: "Has d'estar loguejat per deixar una ressenya.", life: 3000})
    visible.value = false;
    return;
  }

    const { data: reviewData, error: reviewError } = await supabase.rpc('update_review', {_review_id: props.review.id, _rating: rating.value, _comment: comment.value, _spoilers: checked.value })
    if (reviewError) {
        toast.add({ severity: 'error', summary: 'Error en actualitzar', detail: 'Assegura\'t de modificar la qualificació o escriure un comentari vàlid abans de guardar.', life: 3000 })
    } else {
        toast.add({ severity: 'success', summary: 'Actualització exitosa', detail: 'La teva ressenya s\'ha actualitzat correctament.', life: 3000 });
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
const reportOptionsCatalan = [
  { label: 'Contingut Ofensiu', value: '0'},
  { label: 'Spam', value: '1'},
  { label: 'Desinformació', value: '2' },
  { label: 'Altres', value: '3' },
];
const isLoadingReport = ref(false);

const submitReport = async () => {
  const user_id = user.value?.id;

  if (!user_id) {
    toast.add({ severity: "error", summary: "Error", detail: "Has d'estar loguejat per reportar una ressenya.", life: 3000})
    visible.value = false;
    return;
  }
    isLoadingReport.value = true;
    const reason = reportOptions.find((option) => option.value === actualReportReason.value)?.label;
    console.log(reason)
    const { data: reportData, error: reportError } = await supabase.rpc('add_report', {_review_id: props.review.id, _reason: reason, _other_reason: value_otros.value })
    if (reportError) {
        toast.add({ severity: 'error', summary: 'Error en reportar', detail: 'No s\'ha pogut enviar el report, intenta-ho més tard', life: 3000 })
        visibleReport.value = false
    } else {
        toast.add({ severity: 'success', summary: 'Reportatge exitós', detail: 'El teu report s\'ha enviat correctament.', life: 3000 });
        visibleReport.value = false
    }
    isLoadingReport.value = false;
}

const visibleDialogUsersReaction = ref(false);
const reationTypeModal = ref();
const usersReaction = ref<Profile[]>();

const showUsersReactions = async (type: 'like' | 'dislike') => {
  visibleDialogUsersReaction.value = true;
  reationTypeModal.value = type;

  try {
    let reactionFuction = type === 'like' ? 'get_users_liked_review' : 'get_users_disliked_review';
    const { data, error } = await supabase.rpc(reactionFuction, { _review_id: props.review.id }) as { data: Profile[]; error: any };;
    if (error) throw error;

    usersReaction.value = data || [];
  } catch (error) {
    console.error(error)
  }
}

const handleFollow = async (profile: Profile) => {
  if (profile.isProcessingFollow) return;
  profile.isProcessingFollow = true;

	try {
    let followFunction = profile.is_following ? 'unfollow_user' : 'follow_user';

    const { error } = (await supabase.rpc(
      followFunction,
      { _following_username: profile.username }
    ))
    if (error) throw error;

    profile.is_following = !profile.is_following;

	} catch (error) {
		console.error(error);
		let summary = "Oops, alguna cosa ha anat malament";
    let detail = "Hi ha hagut un problema al seguir a l'usuari.";

		switch (error.code) {
			case 'F0001':
				summary = "Ja estàs seguint a aquest usuari";
				detail = "Sembla que ja segueixes a l'usuari.";
				break;
			case 'F0002':
				summary = "Usuari no trobat";
				detail = "No s'ha trobat l'usuari que vols seguir.";
				break;
			case 'F0003':
				summary = "No et pots seguir a tu mateix";
				detail = "Aquesta acció no està permesa.";
				break;
			case 'F0004':
				summary = "No estàs seguint aquest usuari";
				detail = "Sembla que no segueixes a l'usuari.";
				break;
		}
		toast.add({
			severity: "error",
			summary,
			detail,
			life: 3000,
		});
	} finally {
    profile.isProcessingFollow = false;
  }
}

</script>

<template>
  <Toast />
  <ConfirmDialog group="positioned" v-model:visible="confirmVisible" />
  <Dialog v-model:visible="visible" modal header="Editar ressenya">
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

          <h3 class="mt-auto">Qualifica del 1 al 10 ({{ rating }})</h3>
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
          placeholder="Escriu el teu comentari..."
          class="mb-4 w-full"
        />
        <span class="absolute right-2 bottom-[-0.1rem] text-gray-500 text-sm">
          {{ numCharacters }} / 255
        </span>
      </div>
        <div v-if="user" class="flex justify-between">
          <Button label="Cancel·lar" severity="secondary" @click="visible=false" />
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

  <Dialog v-model:visible="visibleReport" modal class="w-[50rem]" :draggable="false">
    <template #header>
      <div class="flex flex-row items-start mt-3 ml-3">
        <div class="flex flex-col gap-2 items-start">
          <h1 class="text-3xl font-bold text-gray-800 dark:text-gray-100">Denunciar ressenya</h1>
          <p class="text-lg text-gray-600 dark:text-gray-300">No li direm res a <strong>{{ review.user ? review.user : "User not found" }}</strong></p>
        </div>
      </div>
    </template>
      <Tabs v-model:value="actualReportReason">
          <TabList>
            <Tab v-for="reportReason in reportOptionsCatalan" :key="reportReason.label" :value="reportReason.value"> {{ reportReason.label }}</Tab>
          </TabList>
          <TabPanels>
              <TabPanel value="0">
                <p class="text-gray-600 dark:text-gray-100">Està prohibit el contingut que promogui odi, violència, discriminació o assetjament cap a qualsevol individu o grup per raons d'ètina, gènere, orientació sexual, religió, nacionalitat, discapacitat, entre altres.</p><br/>
                <p class="text-gray-600 dark:text-gray-100">Exemples de contingut ofensiu inclouen:</p>

                <ul class="list-disc pl-6 text-gray-600 dark:text-gray-100">
                  <li>Llenguatge vulgar o amenaces.</li>
                  <li>Insults o comentaris despectius.</li>
                  <li>Contingut que inciti a la violència o discriminació.</li>
                </ul>
              </TabPanel>
              <TabPanel value="1">
                <p class="text-gray-600 dark:text-gray-100">Està prohibit enviar missatges no sol·licitats, promocions excessives o contingut irrelevant amb el únic objectiu d'obtenir beneficis personals o comercials.</p><br/>
                <p class="text-gray-600 dark:text-gray-100">Exemples de contingut ofensiu inclouen:</p>

                <ul class="list-disc pl-6 text-gray-600 dark:text-gray-100">
                  <li>Publicitat massiva no sol·licitada.</li>
                  <li>Enllaços repetits que no aporten valor.</li>
                  <li>Missatges amb fins de phishing o frau.</li>
                </ul>
              </TabPanel>
              <TabPanel value="2">
                <p class="text-gray-600 dark:text-gray-100">Està prohibit difondre informació falsa o enganyosa que pugui causar dany a la comunitat, com notícies inventades, teories conspiratives o dades errònies.</p><br/>
                <p class="text-gray-600 dark:text-gray-100">Exemples de contingut ofensiu inclouen:</p>

                <ul class="list-disc pl-6 text-gray-600 dark:text-gray-100">
                  <li>Difusió de notícies falses o enganyoses.</li>
                  <li>Propagació de teories conspiratives sense evidència.</li>
                  <li>Informació que pugui posar en perill la salut o seguretat de les persones.</li>
                </ul>
              </TabPanel>
              <TabPanel value="3">
                <p class="text-gray-600 dark:text-gray-100">La nostra prioritat és oferir un entorn segur i solidari. També fomentar interaccions autèntiques mantenint el contingut i les comptes enganyoses al marge de la nostra plataforma.</p><br/>
                <p class="text-gray-600 dark:text-gray-100">Si la teva denúncia no encaixa en les categories anteriors, si us plau explica'ns breument el motiu.</p><br/>

                <FloatLabel variant="in">
                  <Textarea maxlength="250" id="over_label" v-model="value_otros" rows="3" cols="30" class="resize-none w-full" />
                  <label for="in_label" class="text-gray-600 text-sm">Denúncia</label>
              </FloatLabel>
              </TabPanel>
          </TabPanels>
      </Tabs>
    <template #footer>
      <div class="flex gap-2 items-end">
        <Button label="Cancel·lar" severity="secondary" @click="visibleReport=false" />
        <Button label="Denunciar" :loading="isLoadingReport" @click="submitReport" />
      </div>
    </template>
  </Dialog>
  
  <Dialog v-model:visible="visibleDialogUsersReaction" modal :header="reationTypeModal === 'like' ? `M'agrades` : `No m'agrades`" :style="{ width: '22rem' }" :draggable="false">
    <div class="space-y-4">
      <div v-for="userReaction in usersReaction" class="flex items-center justify-between">
        <div class="flex items-center gap-1">
          <Avatar
            :label="review.user ? review.user[0] : 'T'"
            class="mr-2.5 cursor-pointer"
            size="large"
            shape="circle"
            @click="navigateTo(`/profile/${review.user}`)"
          />
          <div class="flex flex-col">
            <span class="font-semibold cursor-pointer leading-tight" @click="navigateTo(`/profile/${review.user}`)">{{ userReaction?.username }}</span>
            <span class="text-gray-500/80 leading-tight">{{ userReaction?.real_name + ' ' + userReaction?.last_name }}</span>
          </div>
        </div>
        <Button
          v-show="userReaction?.username !== user?.user_metadata.username"
          :label="userReaction?.is_following ? 'Seguint' : 'Seguir'"
          :icon="userReaction?.is_following ? 'pi pi-check' : 'pi pi-user-plus'"
          :severity="userReaction?.is_following ? 'secondary' : ''"
          :loading="userReaction?.isProcessingFollow"
          size="small"
          @click="handleFollow(userReaction)" 
        />
      </div>
    </div>
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
        class="inline-flex items-center gap-1 text-gray-800 dark:text-gray-400 cursor-pointer"
        @click="showUsersReactions('like')"
      >
        <Button
          severity="secondary"
          :icon="like ? 'pi pi-thumbs-up-fill' : 'pi pi-thumbs-up'"
          aria-label="Like"
          rounded
          :disabled="!user || isProcessingReaction"
          @click.stop="handleReaction('like')"
        />
        {{ review.likes == 0 ? "" : review.likes }}
      </span>
      <span
        class="inline-flex items-center gap-1 text-gray-800 dark:text-gray-400 cursor-pointer"
        @click.stop="showUsersReactions('dislike')"
      >
        <Button
          severity="secondary"
          :icon="dislike ? 'pi pi-thumbs-down-fill' : 'pi pi-thumbs-down'"
          aria-label="Dislike"
          rounded
          :disabled="!user || isProcessingReaction"
          @click.stop="handleReaction('dislike')"
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
