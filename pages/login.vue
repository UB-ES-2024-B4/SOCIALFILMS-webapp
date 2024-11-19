<script setup lang="ts">
import "primeicons/primeicons.css";
import { authErrorCodes } from "~/utils/authErrors";
import { useToast } from "primevue/usetoast";

definePageMeta({
  layout: "empty",
});

const supabase = useSupabaseClient();
const toast = useToast();

const credentials = reactive({
  email: "",
  password: "",
  rememberme: false,
});

const credentialsStatus = reactive({
  failedAuth: false,
  invalidCredentials: false,
  emailNotConfirmed: false,
});

const signInLoading = ref(false);

const handleLogin = async () => {
  try {
    signInLoading.value = true;
    const { data, error } = await supabase.auth.signInWithPassword({
      email: credentials.email,
      password: credentials.password,
    });
    if (error) throw error;
    navigateTo("/");
  } catch (error) {
    credentialsStatus.failedAuth = true;

    switch (error.code) {
      case authErrorCodes.InvalidCredentials:
        credentialsStatus.invalidCredentials = true;
        break;

      case authErrorCodes.EmailNotConfirmed:
        toast.add({
          severity: "warn",
          summary: "Email no confirmat",
          detail:
            "Si us plau, confirma el teu email per accedir al teu compte.",
          life: 6500,
        });
        break;
    }
  } finally {
    signInLoading.value = false;
  }
};

const isNotFilled = computed(() => {
  return !credentials.email || !credentials.password;
});
</script>

<template>
  <Toast />
  <div
    class="h-screen w-screen flex items-center justify-center bg-neutral-50 dark:bg-neutral-950"
  >
    <div
      class="flex flex-col justify-center p-10 rounded-xl shadow-2xl sm:w-11/12 md:w-[425px] bg-white dark:bg-black dark:shadow-gray-800"
    >
      <h1 class="font-semibold text-3xl mb-1">Inicia sessió</h1>
      <h2 class="mb-5">Hola, benvingut/da de nou👋</h2>
      <form class="flex flex-col gap-y-3" @submit.prevent="handleLogin">
        <InputGroup>
          <InputGroupAddon>
            <i class="pi pi-envelope"></i>
          </InputGroupAddon>
          <FloatLabel variant="on">
            <InputText
              id="on_label_email"
              v-model="credentials.email"
              :invalid="credentialsStatus.failedAuth"
            />
            <label for="on_label_email">Correu electrònic</label>
          </FloatLabel>
        </InputGroup>

        <div class="flex flex-col">
          <InputGroup>
            <InputGroupAddon>
              <i class="pi pi-key"></i>
            </InputGroupAddon>
            <FloatLabel variant="on">
              <Password
                id="on_label_password"
                v-model="credentials.password"
                :invalid="credentialsStatus.failedAuth"
                :feedback="false"
                toggleMask
              />
              <label for="on_label_password">Contrasenya</label>
            </FloatLabel>
          </InputGroup>

          <transition name="p-message" mode="out-in">
            <Message
              class="mt-1.5"
              v-if="credentialsStatus.invalidCredentials"
              severity="error"
              icon="pi pi-times-circle"
              >Credencials invàlides</Message
            >
          </transition>
        </div>

        <div class="flex items-center justify-between mb-2">
          <div class="flex items-center">
            <Checkbox
              id="rememberme"
              v-model="credentials.rememberme"
              :binary="true"
              class="mr-2"
            />
            <label for="rememberme">Recorda'm</label>
          </div>
          <a class="font-medium no-underline text-right cursor-pointer"
            >Contrasenya oblidada?</a
          >
        </div>

        <div class="flex flex-col gap-3">
          <div class="flex items-center justify-between gap-2">
            <Button
              as="router-link"
              label="Tornar a l'inici"
              icon="pi pi-arrow-circle-left"
              to="/"
              severity="secondary"
              outlined
            />
            <Button
              type="submit"
              label="Inicia sessió"
              :loading="signInLoading"
              :disabled="isNotFilled"
              class="flex-grow"
            />
          </div>
          <span
            class="inline-flex items-center justify-center text-gray-500 dark:text-gray-300"
          >
            No estàs registrat?
            <Button
              as="router-link"
              label="Crear un compte"
              icon="pi pi-arrow-up-right"
              iconPos="right"
              to="/signup"
              link
            />
          </span>
        </div>
      </form>
    </div>
  </div>
</template>
