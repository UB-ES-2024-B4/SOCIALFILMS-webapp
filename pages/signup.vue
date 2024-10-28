<script setup lang="ts">
import 'primeicons/primeicons.css'
import { authErrorCodes } from '~/utils/authErrors'

definePageMeta({
  layout: 'empty',
})

const supabase = useSupabaseClient()

const credentials = reactive({
	username: '',
  email: '',
	passwordToConfirm: '',
  password: ''
})

const credentialsStatus = reactive({
  failedAuth: false,
  emailExists: false,
  usernameExists: false,
  emailNotValid: false,
  passwordWeak: false
})

const signUpLoading = ref(false)
const modalInfo = ref(false)

const handleSignUp = async () => {
  Object.keys(credentialsStatus).forEach(key => {
    credentialsStatus[key] = false;
  });

  try {
    signUpLoading.value = true

    // const { data: dataUsername } = await supabase
    //   .from('auth.users')
    //   .select('id')
    //   .eq('raw_user_meta_data->>username', credentials.username);

    // const { data: dataEmail } = await supabase
    //   .from('auth.users')
    //   .select('id')
    //   .eq('email', credentials.email);
    
    // console.log(dataUsername)
    // console.log(dataEmail)
    
    // if (dataUsername!.length > 0) credentialsStatus.usernameExists = true
    // if (dataEmail!.length > 0) credentialsStatus.emailExists = true
    // if (credentialsStatus.emailExists || credentialsStatus.usernameExists) return;

    const { data, error } = await supabase.auth.signUp({
      email: credentials.email,
      password: credentials.password,
			options: {
				data: {
					username: credentials.username
				}
			}
    })
    if (error) throw error
		modalInfo.value = true
  } catch (error) {
    console.log(error)
    console.log(error.code)

    credentialsStatus.failedAuth = true
    switch (error.code) {
      case authErrorCodes.ValidationFailed:
        credentialsStatus.emailNotValid = true
        break

      case authErrorCodes.WeakPassword:
        credentialsStatus.passwordWeak = true
        break
    }
  } finally {
    signUpLoading.value = false
  }
}

const isDifferentPassword = computed(() => {
	if (!credentials.password || !credentials.passwordToConfirm){
		return false
	}
	return credentials.password !== credentials.passwordToConfirm
})

const isNotFilled = computed(() => {
  return !credentials.username || !credentials.email || !credentials.password || !credentials.passwordToConfirm || isDifferentPassword.value
})

</script>

<template>
	<Dialog v-model:visible="modalInfo" modal header="Registre completat" :style="{ width: '25rem' }" position="bottom" :draggable="false">
    <div class="flex gap-4 items-start mb-6">
			<i class="pi pi-exclamation-circle mt-1" style="font-size: 2rem; color: #708090"></i>
			<span class="text-gray-500 dark:text-gray-300 block">
				Si us plau, revisa el teu email per a confirmar el teu compte i finalitzar el procés de registre.
			</span>
    </div>
    <div class="flex justify-end gap-2">
        <Button type="button" label="Acceptar" @click="modalInfo = false; navigateTo('/login')"></Button>
    </div>
	</Dialog>
  <div class="h-screen w-screen flex items-center justify-center bg-neutral-50 dark:bg-neutral-950">
    <div class="flex flex-col justify-center p-10 rounded-xl shadow-2xl lg:w-4/12 sm:w-7/12 bg-white dark:bg-black dark:shadow-gray-800">
      <h1 class="font-medium text-3xl mb-1">Crear nou compte</h1>
      <h2 class="text-sm mb-5">Hola, benvingut/da👋</h2>
      <form class="flex flex-col gap-y-3" @submit.prevent="handleSignUp">
        <div class="flex flex-col">
          <InputGroup>
            <InputGroupAddon>
                <i class="pi pi-user"></i>
            </InputGroupAddon>
            <FloatLabel variant="on">
              <InputText id="on_label_username" v-model="credentials.username" :invalid="credentialsStatus.failedAuth || credentialsStatus.usernameExists"/>
              <label for="on_label_username">Nom d'usuari</label>
            </FloatLabel>
          </InputGroup>
          <transition name="p-message" mode="out-in">
            <Message class="mt-1.5" v-if="credentialsStatus.usernameExists" severity="error" icon="pi pi-times-circle">L'usuari ya existeix</Message>
          </transition>
        </div>
				
        <div class="flex flex-col">
          <InputGroup>
            <InputGroupAddon>
                <i class="pi pi-envelope"></i>
            </InputGroupAddon>
            <FloatLabel variant="on">
              <InputText id="on_label_email" v-model="credentials.email" :invalid="credentialsStatus.failedAuth || credentialsStatus.emailExists"/>
              <label for="on_label_email">Correu electrònic</label>
            </FloatLabel>
          </InputGroup>
          <transition name="p-message" mode="out-in">
            <Message class="mt-1.5" v-if="credentialsStatus.emailExists" severity="error" icon="pi pi-times-circle">El correu electrònic ya existeix</Message>
          </transition>
          <transition name="p-message" mode="out-in">
            <Message class="mt-1.5" v-if="credentialsStatus.emailNotValid" severity="error" icon="pi pi-times-circle">El correu electrònic no és vàlid</Message>
          </transition>
        </div>
				<div class="flex flex-col">
          <InputGroup>
            <InputGroupAddon>
                <i class="pi pi-key"></i>
            </InputGroupAddon>
            <FloatLabel variant="on">
              <Password id="on_label_password" v-model="credentials.passwordToConfirm" :invalid="credentialsStatus.failedAuth" toggleMask>
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
						<Message class="mt-1.5" v-if="credentialsStatus.passwordWeak" severity="error" icon="pi pi-times-circle">La contrasenya no és vàlida</Message>
					</transition>
        </div>
				<div class="flex flex-col">
					<InputGroup>
						<InputGroupAddon>
								<i class="pi pi-key"></i>
						</InputGroupAddon>
						<FloatLabel variant="on">
							<Password id="on_label_confirm_password" v-model="credentials.password" :invalid="isDifferentPassword || credentialsStatus.failedAuth" :feedback="false" toggleMask />
							<label for="on_label_confirm_password">Confirmar contrasenya</label>
						</FloatLabel>
					</InputGroup>
					<transition name="p-message" mode="out-in">
						<Message class="mt-1.5" v-if="isDifferentPassword" severity="error" icon="pi pi-times-circle">Les contrasenyes no coinxideixen</Message>
					</transition>
				</div>	
				<Button type="submit" label="Registrar-me" :loading="signUpLoading" :disabled="isNotFilled" class="mt-2"/>
      </form>
    </div>
  </div>
</template>