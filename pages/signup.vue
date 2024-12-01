<script setup lang="ts">
import "primeicons/primeicons.css";
import { authErrorCodes } from "~/utils/authErrors";
import { countries } from "~/types";
import { Button } from "primevue";

definePageMeta({
  layout: "empty",
});

const supabase = useSupabaseClient();

const credentials = reactive({
  username: "",
  email: "",
  passwordToConfirm: "",
  password: "",
});

const additionalInfo = reactive({
  name: "",
  surname: "",
  birthDate: null,
  country: "",
  bio: "",
});

const credentialsStatus = reactive({
  failedAuth: false,
  emailExists: false,
  usernameExists: false,
  emailNotValid: false,
  passwordWeak: false,
});

const additionalInfoStatus = reactive({
  failedCreateProfile: false,
});

const signUpLoading = ref(false);
const modalInfo = ref(false);

const handleSignUp = async (activateCallback: (step: string) => void) => {
  Object.keys(credentialsStatus).forEach((key) => {
    credentialsStatus[key] = false;
  });

  try {
    signUpLoading.value = true;

    const { data, error } = await supabase.auth.signUp({
      email: credentials.email,
      password: credentials.password,
      options: {
        data: {
          username: credentials.username,
        },
      },
    });
    if (error) throw error;

    const { error: errorProfile } = (await supabase.rpc("update_profile", {
      _username: credentials.username,
      _bio: additionalInfo.bio,
      _birth_date: additionalInfo.birthDate,
      _country: additionalInfo.country,
      _real_name: additionalInfo.name,
      _last_name: additionalInfo.surname,
    }))

    if (errorProfile) throw new Error("Profile create error: ", errorProfile.message);
    modalInfo.value = true;

  } catch (error) {
    console.log(error);
    console.log(error.code);

    switch (error.code) {
      case authErrorCodes.UserAlreadyExists:
        credentialsStatus.emailExists = true;
        activateCallback("1");
        break;

      case authErrorCodes.ValidationFailed:
        credentialsStatus.emailNotValid = true;
        activateCallback("1");
        break;

      case authErrorCodes.WeakPassword:
        credentialsStatus.passwordWeak = true;
        activateCallback("1");
        break;
      
      default:
        if (error.message.includes('Profile create')) {
          additionalInfoStatus.failedCreateProfile = true;
        }
        else {
          credentialsStatus.failedAuth = true;
          activateCallback("1");
        }
        break;
    }
  } finally {
    signUpLoading.value = false;
  }
};

const isDifferentPassword = computed(() => {
  if (!credentials.password || !credentials.passwordToConfirm) {
    return false;
  }
  return credentials.password !== credentials.passwordToConfirm;
});

const isNotFilled = computed(() => {
  return (
    !credentials.username ||
    !credentials.email ||
    !credentials.password ||
    !credentials.passwordToConfirm ||
    isDifferentPassword.value
  );
});
</script>

<template>
  <Dialog
    v-model:visible="modalInfo"
    modal
    header="Registre completat"
    :style="{ width: '22rem' }"
    position="bottom"
    :draggable="false"
  >
    <div class="flex gap-4 items-center mb-6">
      <i class="pi pi-check-circle" style="font-size: 2rem; color: #708090"></i>
      <span class="text-gray-500 dark:text-gray-300 block">
        T'has registrat amb exit!
      </span>
    </div>
    <div class="flex justify-end gap-2">
      <Button
        type="button"
        label="Acceptar"
        @click="
          modalInfo = false;
          navigateTo('/');
        "
      ></Button>
    </div>
  </Dialog>
  <div
    class="h-screen w-screen flex items-center justify-center bg-neutral-50 dark:bg-neutral-950"
  >
    <div
      class="flex flex-col justify-center p-10 rounded-xl shadow-2xl sm:w-11/12 md:w-[425px] bg-white dark:bg-black dark:shadow-gray-800"
    >
      <h1 class="font-semibold text-3xl mb-1">Crear nou compte</h1>
      <h2 class="mb-3">Hola, benvingut/da👋</h2>
      <Stepper value="1" linear>
        <StepList>
          <Step value="1">Registre</Step>
          <Step value="2">Informació addicional</Step>
        </StepList>
        <StepPanels>
          <!-- Paso 1: Formulario de registro -->
          <StepPanel v-slot="{ activateCallback }" value="1">
            <div class="flex flex-col gap-y-3">
              <div class="flex flex-col">
                <InputGroup>
                  <InputGroupAddon>
                    <i class="pi pi-user"></i>
                  </InputGroupAddon>
                  <FloatLabel variant="on">
                    <InputText
                      id="on_label_username"
                      v-model="credentials.username"
                      :invalid="
                        credentialsStatus.failedAuth ||
                        credentialsStatus.usernameExists
                      "
                    />
                    <label for="on_label_username">Nom d'usuari</label>
                  </FloatLabel>
                </InputGroup>
                <transition name="p-message" mode="out-in">
                  <Message
                    class="mt-1.5"
                    v-if="credentialsStatus.usernameExists"
                    severity="error"
                    icon="pi pi-times-circle"
                    >L'usuari ya existeix</Message
                  >
                </transition>
              </div>

              <div class="flex flex-col">
                <InputGroup>
                  <InputGroupAddon>
                    <i class="pi pi-envelope"></i>
                  </InputGroupAddon>
                  <FloatLabel variant="on">
                    <InputText
                      id="on_label_email"
                      v-model="credentials.email"
                      :invalid="
                        credentialsStatus.failedAuth || credentialsStatus.emailExists
                      "
                    />
                    <label for="on_label_email">Correu electrònic</label>
                  </FloatLabel>
                </InputGroup>
                <transition name="p-message" mode="out-in">
                  <Message
                    class="mt-1.5"
                    v-if="credentialsStatus.emailExists"
                    severity="error"
                    icon="pi pi-times-circle"
                    >El correu electrònic ya existeix</Message
                  >
                </transition>
                <transition name="p-message" mode="out-in">
                  <Message
                    class="mt-1.5"
                    v-if="credentialsStatus.emailNotValid"
                    severity="error"
                    icon="pi pi-times-circle"
                    >El correu electrònic no és vàlid</Message
                  >
                </transition>
              </div>
              <div class="flex flex-col">
                <InputGroup>
                  <InputGroupAddon>
                    <i class="pi pi-key"></i>
                  </InputGroupAddon>
                  <FloatLabel variant="on">
                    <Password
                      id="on_label_password"
                      v-model="credentials.passwordToConfirm"
                      :invalid="credentialsStatus.failedAuth"
                      toggleMask
                    >
                      <template #footer>
                        <Divider />
                        <ul class="pl-2 ml-2 my-0 list-disc leading-normal">
                          <li>Com a mínim una minúscula</li>
                          <li>Com a mínim una majúscula</li>
                          <li>Com a mínim un número</li>
                          <li>Com a mínim un símbol</li>
                          <li>Mínim 6 caràcters</li>
                        </ul>
                      </template>
                    </Password>
                    <label for="on_label_password">Contrasenya</label>
                  </FloatLabel>
                </InputGroup>
                <transition name="p-message" mode="out-in">
                  <Message
                    class="mt-1.5"
                    v-if="credentialsStatus.passwordWeak"
                    severity="error"
                    icon="pi pi-times-circle"
                    >La contrasenya no és vàlida</Message
                  >
                </transition>
              </div>
              <div class="flex flex-col">
                <InputGroup>
                  <InputGroupAddon>
                    <i class="pi pi-key"></i>
                  </InputGroupAddon>
                  <FloatLabel variant="on">
                    <Password
                      id="on_label_confirm_password"
                      v-model="credentials.password"
                      :invalid="isDifferentPassword || credentialsStatus.failedAuth"
                      :feedback="false"
                      toggleMask
                    />
                    <label for="on_label_confirm_password"
                      >Confirmar contrasenya</label
                    >
                  </FloatLabel>
                </InputGroup>
                <transition name="p-message" mode="out-in">
                  <Message
                    class="mt-1.5"
                    v-if="isDifferentPassword"
                    severity="error"
                    icon="pi pi-times-circle"
                    >Les contrasenyes no coinxideixen</Message
                  >
                </transition>
              </div>
              <div class="flex pt-3 justify-end">
                <Button label="Next" icon="pi pi-arrow-right" @click="activateCallback('2')" />
              </div>
            </div>
          </StepPanel>
          <!-- Paso 2: Información adicional -->
          <StepPanel v-slot="{ activateCallback }" value="2">
            <div class="flex flex-col gap-y-3">
              <div class="flex gap-3">
                <FloatLabel variant="on">
                  <InputText
                    id="on_label_name"
                    v-model="additionalInfo.name"
                    :invalid="additionalInfoStatus.failedCreateProfile"
                    fluid
                    />
                  <label for="on_label_name">Nom</label>
                </FloatLabel>
                <FloatLabel variant="on">
                  <InputText
                    id="on_label_surname"
                    v-model="additionalInfo.surname"
                    :invalid="additionalInfoStatus.failedCreateProfile"
                    fluid
                  />
                  <label for="on_label_surname">Cognoms</label>
                </FloatLabel>
              </div>
              <div class="flex gap-3">
                <FloatLabel variant="on">
                  <DatePicker 
                    class="flex-1" 
                    v-model="additionalInfo.birthDate"
                    :invalid="additionalInfoStatus.failedCreateProfile" />
                  <label for="on_label_age">Data de naixement</label>
                </FloatLabel>
                <FloatLabel variant="on">
                  <Select 
                    class="w-[11.8rem]"
                    v-model="additionalInfo.country" 
                    :invalid="additionalInfoStatus.failedCreateProfile"
                    :options="countries" 
                    optionLabel="name" 
                    optionValue="name" />
                  <label for="on_label_country">País</label>
                </FloatLabel>
              </div>
              <div class="flex flex-col">
                <FloatLabel variant="on">
                  <Textarea
                    id="on_label_bio"
                    v-model="additionalInfo.bio"
                    :invalid="additionalInfoStatus.failedCreateProfile"
                    rows="3"
                    fluid
                  />
                  <label for="on_label_bio">Biografia</label>
                </FloatLabel>
              </div>
              <div class="flex pt-3 justify-between">
                <Button
                  label="Enrere"
                  severity="secondary"
                  icon="pi pi-arrow-left"
                  @click="activateCallback('1')"
                />
                <Button
                  label="Completar registre"
                  icon="pi pi-check"
                  @click="handleSignUp(activateCallback)"
                />
              </div>
            </div>
          </StepPanel>
        </StepPanels>
      </Stepper>
        
      <div class="flex flex-col">
        <span
          class="inline-flex items-center justify-center text-gray-500 dark:text-gray-300"
        >
          Ja estàs registrat?
          <Button
            as="router-link"
            label="Inicia sessió"
            icon="pi pi-arrow-up-right"
            iconPos="right"
            to="/login"
            link
          />
        </span>
      </div>
    </div>
  </div>
</template>
