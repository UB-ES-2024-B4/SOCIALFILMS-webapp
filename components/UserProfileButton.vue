<script setup lang="ts">
import "primeicons/primeicons.css";
import { useToast } from "primevue/usetoast";
import ReviewCard from "~/components/ReviewCard.vue";
import type { Review, Profile } from "~/types";
import { countries } from "~/types";

const toast = useToast();
const supabase = useSupabaseClient();
const user = useSupabaseUser();
const username = ref(user.value?.user_metadata.username)
const email = ref(user.value?.email)
const current_password = ref()
const new_password = ref()
const invalidCurrentPassword = ref(false)
const invalidNewPassword = ref(false)

const visibleDialogProfileSettings = ref(false);
const photoUploaded = ref('https://primefaces.org/cdn/primevue/images/avatar/amyelsner.png');

const profile = ref<Profile>();
const profileUpdated = ref<Profile>();

try {
	const { data: dataProfile, error: errorProfile } = (await supabase.rpc(
		"get_profile_by_id",
		{ _user_id: user.value?.id }
	)) as { data: Profile; error: any };

	if (errorProfile) throw errorProfile;

	profile.value = dataProfile;
  profile.value.birth_date = new Date(profile.value.birth_date);
  profileUpdated.value = { ...profile.value };
} catch (error) {
	console.error("Error loading profile:", error);
}

const onUploadPhoto = (event) => {
    const file = event.files[0];
    const reader = new FileReader();

    reader.onload = async (e) => {
      photoUploaded.value = e.target.result;
    };
    console.log(photoUploaded)

    toast.add({ severity: 'info', summary: 'Foto de perfil cambiada', detail: 'Foto de perfil cambiada con éxito', life: 3000 });
};

const menu = ref();
const toggle = (event) => {
  menu.value.toggle(event);
};

const items = ref([
  {
    label: "Perfil",
    items: [
      {
        label: "Configuració",
        icon: "pi pi-cog",
        command: () => { visibleDialogProfileSettings.value = true },
      },
      {
        label: "Tancar sessió",
        icon: "pi pi-sign-out",
        command: async () => {
          try {
            const { error } = await supabase.auth.signOut();
            if (error) throw error;
            toast.add({
              severity: "success",
              summary: "Sessió tancada",
              detail: "S'ha tancat la sessió amb exit",
              life: 3000,
            });
          } catch (error) {
            toast.add({
              severity: "error",
              summary: "Sessió no tancada",
              detail: "No s'ha tancat la sessió amb exit",
              life: 3000,
            });
          }
        },
      },
    ],
  },
]);

const activeTab = ref('account');
const menuItemsDialogProfileSettings = ref([
  {
    label: "Cuenta",
    icon: "pi pi-cog",
    value: "account",
  },
  {
    label: "Perfil",
    icon: "pi pi-user-edit",
    value: "profile",
  },
  {
    label: "Reviews",
    icon: "pi pi-comments",
    value: "reviews",
  },
]);
const setActiveTab = (tab: string) => { 
  activeTab.value = tab;
  if (activeTab.value === "reviews") loadReviewsAndMovies()
};
const isActive = (tab: string) => computed(() => activeTab.value === tab);

const reviewsWithMovies = ref<Review[]>([]);
const isLoadingReviews = ref(false);

const loadReviewsAndMovies = async () => {
  try {
    isLoadingReviews.value = true;

    const { data: dataReviews, error: errorReviews } = (await supabase.rpc(
      "get_reviews",
      { _user_id: user.value?.id }
    )) as { data: Review[]; error: any };

    if (errorReviews) throw errorReviews;

    const reviews =
      dataReviews?.map((review) => ({
        ...review,
        created_at: new Date(review.created_at),
      })) || [];

    const moviesPromises = reviews.map(async (review) => {
      const { data: movieData, error: movieError } = await supabase.rpc(
        "find_movie_by_id",
        { movie_id: review.movie_id }
      );
      if (movieError) throw movieError;

      return {
        ...review,
        film: movieData,
      };
    });

    reviewsWithMovies.value = await Promise.all(moviesPromises);
    console.log(reviewsWithMovies)
  } catch (error) {
    console.error("Error loading reviews or movies:", error);
  } finally {
    isLoadingReviews.value = false;
  }
};

const handleSubmitAccountUpdated = async () => {
  try {
    let usernameChanged = username.value !== user.value?.user_metadata.username;
    console.log(username.value, user.value?.user_metadata.username, usernameChanged)
    if (usernameChanged || email.value !== user.value?.email){
      const { error } = await supabase.auth.updateUser({
        email: email.value,
        data: { username: username.value },
      });

      if (error) {
        toast.add({
          severity: "error",
          summary: "Error al actualizar cuenta",
          detail: `No se pudo actualizar tu cuenta: ${error.message}`,
          life: 5000,
        });
        throw new Error(`Error updating user: ${error.message}`);
      }

      if (email.value !== user.value?.email) {
        toast.add({
          severity: "warn",
          summary: "Cambio de email pendiente",
          detail: "Hemos enviado un enlace de confirmación a tu nuevo email. Por favor, revisa tu bandeja de entrada y sigue las instrucciones para completar el cambio.",
          life: 20000,
        });
      }
      if (usernameChanged){
        toast.add({
          severity: "success",
          summary: "Nombre de usuario actualizado",
          detail: "Se ha actualizado tu nombre de usuario con éxito",
          life: 3000,
        });
      }
    }

    if (current_password.value && new_password.value) {
      const { data: dataUpdatePassword, error: errorUpdatePassword } = await supabase.rpc("change_password", { 
          current_plain_password: current_password.value,
          new_plain_password: new_password.value,
          current_id: user.value.id,
        });

      if (errorUpdatePassword) {
        let summary = "Error al cambiar contraseña";
        let detail = "Hubo un problema al actualizar tu contraseña.";

        switch (errorUpdatePassword.code) {
          case 'P0001':
            summary = "Contraseña actual incorrecta";
            detail = "Has introducido una contraseña actual incorrecta.";
            invalidCurrentPassword.value = true;
            break;
          case 'P0002':
            summary = "Error al actualizar contraseña";
            detail = "No se ha podido actualizar a la contraseña nueva, prueba más tarde.";
            invalidNewPassword.value = true;
            break;
          case 'P0003':
            summary = "Contraseña débil";
            detail = "La contraseña debe tener al menos 6 caracteres, una mayúscula, una minúscula, un número y un símbolo.";
            invalidNewPassword.value = true;
            break;
        }
        toast.add({
          severity: "error",
          summary,
          detail,
          life: 5000,
        });
        throw new Error(`Error updating password: ${errorUpdatePassword.message}`);
      }
      toast.add({
        severity: "success",
        summary: "Contraseña actualizada",
        detail: "Se ha actualizado tu contraseña con éxito",
        life: 3000,
      });
    }
    
    visibleDialogProfileSettings.value = false;

  } catch (error) {
    if (error.message.includes('updating user')) {
      console.error('Error in updateUser:', error.message);

    } else if (error.message.includes('updating password')) {
      console.error('Error in updatePassword RPC:', error.message);
    }
  }
};

const handleSubmitProfileUpdated = async () => {
  try {
    if (JSON.stringify(profile.value) !== JSON.stringify(profileUpdated.value)) {
      const { error } = (await supabase.rpc("update_profile", {
        _username: user.value?.user_metadata.username,
        _bio: profileUpdated.value?.bio,
        _birth_date: profileUpdated.value?.birth_date,
        _country: profileUpdated.value?.country,
        _real_name: profileUpdated.value?.real_name,
        _last_name: profileUpdated.value?.last_name,
      }))

      if (error) {
        toast.add({
          severity: "error",
          summary: "Error al actualizar perfil",
          detail: `No se pudo actualizar tu perfil: ${error.message}`,
          life: 5000,
        });
        throw new Error(`Error updating profile: ${error.message}`);
      }

      toast.add({
        severity: "success",
        summary: "Perfil actualizado",
        detail: "Se ha actualizado tu perfil con éxito",
        life: 3000,
      });
      profile.value = { ...profileUpdated.value };
    }
    visibleDialogProfileSettings.value = false;
  } catch (error) {
    console.error(error.message);
  }
};

const shareProfile = () => {
	const currentURL = window.location.href;
	navigator.clipboard.writeText(currentURL)
			.then(() => {
					toast.add({
							severity: "success",
							summary: "Enlace copiado",
							detail: "El enlace se ha copiado al portapapeles.",
							life: 3000,
					});
					console.log("Enlace copiado al portapapeles");
			})
			.catch((err) => {
					toast.add({
							severity: "error",
							summary: "Error al copiar",
							detail: "No se pudo copiar el enlace. Intenta nuevamente.",
							life: 3000,
					});
					console.error("Error al copiar el enlace: ", err);
			});
};

const isNotFilledAccount = computed(() => {
  return (
    !username.value ||
    !email.value
  );
});

const isNotFilledProfile = computed(() => {
  return (
    !profileUpdated.value?.real_name ||
    !profileUpdated.value.last_name ||
    !profileUpdated.value.birth_date ||
    !profileUpdated.value.country ||
    !profileUpdated.value.bio
  );
});

</script>

<template>
  <div
    class="flex items-center justify-center gap-2 bg-neutral-400/40 p-2 rounded-full shadow-sm w-max"
  >
    <img
      src="https://a.storyblok.com/f/191576/1200x800/a3640fdc4c/profile_picture_maker_before.webp"
      alt="Profile"
      class="w-10 h-10 rounded-full object-cover"
    />
    <div class="text-left">
      <p class="text-white text-sm font-semibold">{{ profile?.real_name + ' ' + profile?.last_name }}</p>
      <p class="text-gray-300 text-xs">{{ '@' + user?.user_metadata.username }}</p>
    </div>
    <Button
      icon="pi pi-chevron-down"
      variant="text"
      severity="secondary"
      rounded
      @click="toggle"
      :pt="{
        icon: { class: 'text-white' },
      }"
    />
    <Menu ref="menu" id="overlay_menu" :model="items" :popup="true" />

    <Dialog 
      v-model:visible="visibleDialogProfileSettings" 
      modal 
      header="Profile Settings"
      class="w-[60rem]"
      :draggable="false" >
      <template #container>
        <div class="flex">
          <!-- Lateral Menu -->
          <div class="w-48 min-h-96 border-r dark:border-r-zinc-700">
            <Button class="m-5" size="large" icon="pi pi-times" severity="secondary" variant="text" rounded @click="visibleDialogProfileSettings = false" />
            <div class="pt-[78px] flex flex-col">
              <button
                  v-for="item in menuItemsDialogProfileSettings"
                  :key="item.label"
                  @click="setActiveTab(item.value)"
                  :class="[
                    'flex items-center gap-3.5 font-medium py-4 px-6',
                    isActive(item.value).value
                      ? 'font-semibold bg-violet-400/10 border-r-2 border-violet-400'
                      : 'hover:bg-violet-400/10',
                  ]"
                >
                  <i :class="[item.icon, 'text-gray-400']"></i>
                  {{ item.label }}
              </button>
            </div>
          </div>
          <div class="flex-1 flex-col">
            <!-- Header -->
            <div class="flex justify-between items-start mx-10">
              <div class="relative flex flex-col">
                <img
                  src="https://a.storyblok.com/f/191576/1200x800/a3640fdc4c/profile_picture_maker_before.webp"
                  alt="Profile"
                  class="w-28 h-28 rounded-full border-4 border-white shadow-lg object-cover -mt-12 mb-5"
                />
                <h1 class="font-bold text-2xl">{{ user?.user_metadata.username }}</h1>
                <h2 class="text-gray-400 text-lg">{{ user?.email }}</h2>
              </div>

              <div class="flex justify-center items-center gap-4 mt-6">
                <Button label="Compartir perfil" variant="outlined" icon="pi pi-send" severity="contrast" @click="shareProfile" />
                <Button label="Ver perfil" variant="outlined" severity="contrast" @click="visibleDialogProfileSettings = false; navigateTo('/profile/'+user?.user_metadata.username);" />
              </div>
            </div>
            
            <!-- Account -->
            <form v-if="activeTab === 'account'" @submit.prevent="handleSubmitAccountUpdated" class="flex flex-col mt-2 mx-10">
              <Divider />
              <div class="flex items-start justify-between my-1">
                <h2 class="font-semibold">Nombre de usuario</h2>
                <IconField>
                  <InputIcon class="pi pi-at" />
                  <InputText class="w-[27rem]" v-model="username" placeholder="Nombre de usuario" />
                </IconField>
              </div>
              <Divider />
              <div class="flex items-start justify-between my-1">
                <h2 class="font-semibold">Correo electrónico</h2>
                <IconField>
                  <InputIcon class="pi pi-envelope" />
                  <InputText class="w-[27rem]" v-model="email" placeholder="Correo electrónico" />
                </IconField>
              </div>
              <Divider />
              <div class="flex items-start justify-between my-1">
                <h2 class="font-semibold">Contraseña</h2>
                <div class="flex items-center gap-4 w-[27rem]">
                  <FloatLabel variant="on">
                    <Password fluid id="current_password" v-model="current_password" :feedback="false" :invalid="invalidCurrentPassword" toggleMask />
                    <label for="current_password">Contraseña actual</label>
                  </FloatLabel>
                  <FloatLabel variant="on">
                    <Password fluid id="new_password"v-model="new_password" :feedback="false" :invalid="invalidNewPassword" toggleMask />
                    <label for="new_password">Nueva contraseña</label>
                  </FloatLabel>
                </div>
              </div>
              <Divider />
              <!-- <div class="flex items-start justify-between my-1">
                <h2 class="font-semibold">Foto de perfil</h2>
                <div class="flex items-center justify-between w-[27rem]">
                  <img
                    :src="photoUploaded"
                    alt="New Photo Profile"
                    class="w-20 h-20 rounded-full border-[1.5px] border-gray-300 shadow-sm object-cover"
                  />
                  <div class="flex justify-center items-center gap-4">
                    <FileUpload 
                      ref="profilephotoupload"
                      mode="basic"
                      accept="image/*" 
                      customUpload
                      :maxFileSize="1000000" 
                      @select="onUploadPhoto"
                      auto
                      chooseLabel="Cambiar foto"
                      chooseIcon="pi pi-upload"
                      :chooseButtonProps="{ severity: 'info' }" 
                    />
                    <Button label="Eliminar foto" variant="outlined" severity="danger" />
                  </div>
                </div>
              </div>
              <Divider /> -->
              <div class="flex justify-end items-center mt-2 mb-6">
                <div class="flex justify-center items-center gap-4">
                  <Button label="Cancelar" variant="outlined" severity="secondary" @click="visibleDialogProfileSettings = false" />
                  <Button type="submit" label="Guardar cambios" :disabled="isNotFilledAccount" />
                </div>
              </div>
            </form>
            <!-- Profile -->
            <form v-if="activeTab === 'profile'" 
              @submit.prevent="handleSubmitProfileUpdated" 
              class="flex flex-col mt-2 mx-10"
            >
              <div class="overflow-y-auto" style="max-height: calc(100vh - 350px);">
                <Divider />
                <div class="flex items-start justify-between my-1">
                  <h2 class="font-semibold">Nombre y apellidos</h2>
                  <div class="flex items-center gap-4 w-[27rem]">
                    <InputText fluid v-model="profileUpdated.real_name" />
                    <InputText fluid v-model="profileUpdated.last_name" />
                  </div>
                </div>
                <Divider />
                <div class="flex items-start justify-between my-1">
                  <h2 class="font-semibold">Fecha de nacimiento</h2>
                  <DatePicker 
                    v-model="profileUpdated.birth_date" 
                    class="w-[27rem]" />
                </div>
                <Divider />
                <div class="flex items-start justify-between my-1">
                  <h2 class="font-semibold">País</h2>
                  <Select 
                    class="w-[27rem]"
                    v-model="profileUpdated.country"
                    :options="countries" 
                    optionLabel="name" 
                    optionValue="name" />
                </div>
                <Divider />
                <div class="flex items-start justify-between my-1">
                  <h2 class="font-semibold">Biografía</h2>
                  <Textarea
                    class="w-[27rem]"
                    v-model="profileUpdated.bio"
                    rows="3" />
                </div>
              </div>
              <Divider />
              <div class="flex justify-end items-center mt-2 mb-6">
                <div class="flex justify-center items-center gap-4">
                  <Button label="Cancelar" variant="outlined" severity="secondary" @click="visibleDialogProfileSettings = false" />
                  <Button type="submit" label="Guardar cambios" :disabled="isNotFilledProfile" />
                </div>
              </div>
            </form>
            <!-- Reviews -->
            <div v-if="activeTab === 'reviews'">
              <div
                v-if="!isLoadingReviews"
                class="flex flex-col gap-4 my-5 pb-5 mx-10 overflow-hidden hover:overflow-y-auto"
                style="max-height: calc(100vh - 300px);"
              >
                <ReviewCard
                  v-for="(review, index) in reviewsWithMovies"
                  :review="review"
                  :key="index"
                  :film="review.film"
                  :showFilm="true"
                >
                </ReviewCard>
              </div>
              <div v-else class="flex h-[300px] items-center">
                <ProgressSpinner />
              </div>
            </div>
          </div>
        </div>
      </template>
    </Dialog>
    <Toast />
  </div>
</template>
