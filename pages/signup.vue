<script setup lang="ts">
import 'primeicons/primeicons.css'

definePageMeta({
  layout: 'empty',
})

const supabase = useSupabaseClient()

const credentials = reactive({
	username: '',
  email: '',
	passwordToConfirm: '',
  password: '',
  rememberme: false,
  failedAuth: false
})

const signUpLoading = ref(false)
const modalInfo = ref(false)

const handleSignUp = async () => {
  try {
    signUpLoading.value = true
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
    credentials.failedAuth = true
  } finally {
    signUpLoading.value = false
  }
}

const redirectToLogin = () => {
  navigateTo('/login');
  window.close();
}

const isDifferentPassword = computed(() => {
	if (!credentials.password || !credentials.passwordToConfirm){
		return false
	}
	return credentials.password !== credentials.passwordToConfirm
})

const isNotFilled = computed(() => {
  return (!credentials.username || !credentials.email || !credentials.password || !credentials.passwordToConfirm) && !isDifferentPassword.value
})

</script>

<template>
	<Dialog v-model:visible="modalInfo" modal header="Registre completat" :style="{ width: '25rem' }" position="bottom" :draggable="false">
    <div class="flex gap-4 items-start mb-6">
			<i class="pi pi-exclamation-circle mt-1" style="font-size: 2rem; color: #708090"></i>
			<span class="text-gray-500 dark:text-surface-400 block">
				Si us plau, revisa el teu email per a confirmar el teu compte i finalitzar el procés de registre.
			</span>
    </div>
    <div class="flex justify-end gap-2">
        <Button type="button" label="Acceptar" @click="modalInfo = false; redirectToLogin()"></Button>
    </div>
	</Dialog>
  <div class="h-screen w-screen flex items-center justify-center bg-neutral-50 dark:bg-neutral-950">
    <div class="flex flex-col justify-center p-10 rounded-xl shadow-2xl bg-white w-4/12">
      <h1 class="font-medium text-3xl mb-1">Crear nou compte</h1>
      <h2 class="text-sm mb-5">Hola, benvingut/da👋</h2>
      <form class="flex flex-col gap-y-3" @submit.prevent="handleSignUp">
        <InputGroup>
          <InputGroupAddon>
              <i class="pi pi-user"></i>
          </InputGroupAddon>
          <FloatLabel variant="on">
            <InputText id="on_label_username" v-model="credentials.username" :invalid="credentials.failedAuth"/>
            <label for="on_label_username">Nom d'usuari</label>
          </FloatLabel>
        </InputGroup>
				
				<InputGroup>
          <InputGroupAddon>
              <i class="pi pi-envelope"></i>
          </InputGroupAddon>
          <FloatLabel variant="on">
            <InputText id="on_label_email" v-model="credentials.email" :invalid="credentials.failedAuth"/>
            <label for="on_label_email">Correu electrònic</label>
          </FloatLabel>
        </InputGroup>

        <InputGroup>
          <InputGroupAddon>
              <i class="pi pi-key"></i>
          </InputGroupAddon>
          <FloatLabel variant="on">
						<Password id="on_label_password" v-model="credentials.passwordToConfirm" :invalid="credentials.failedAuth" toggleMask>
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
				<div class="flex flex-col gap-1">
					<InputGroup>
						<InputGroupAddon>
								<i class="pi pi-key"></i>
						</InputGroupAddon>
						<FloatLabel variant="on">
							<Password id="on_label_confirm_password" v-model="credentials.password" :invalid="isDifferentPassword" :feedback="false" toggleMask />
							<label for="on_label_confirm_password">Confirmar contrasenya</label>
						</FloatLabel>
					</InputGroup>
					<transition name="p-message" mode="out-in" class="flex flex-col">
						<Message v-if="isDifferentPassword" closable severity="error" icon="pi pi-times-circle">Les contrasenyes no coinxideixen</Message>
					</transition>
				</div>	
				<Button type="submit" label="Registrar-me" :loading="signUpLoading" :disabled="isNotFilled" class="mt-2"/>
      </form>
    </div>
  </div>
</template>