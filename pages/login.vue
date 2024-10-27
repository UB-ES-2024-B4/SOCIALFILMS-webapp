<script setup lang="ts">
import 'primeicons/primeicons.css'

definePageMeta({
  layout: 'empty',
})

const supabase = useSupabaseClient()

const credentials = reactive({
  email: '',
  password: '',
  rememberme: false,
  failedAuth: false
})

const signInLoading = ref(false);

const handleLogin = async () => {
  try {
    signInLoading.value = true
    const { data, error } = await supabase.auth.signInWithPassword({
      email: credentials.email,
      password: credentials.password
    })
    if (error) throw error
    navigateTo("/")
  } catch (error) {
    credentials.failedAuth = true
  } finally {
    signInLoading.value = false
  }
}

const isNotFilled = computed(() => {
  return !credentials.email || !credentials.password
})

</script>

<template>
  <div class="h-screen w-screen flex items-center justify-center bg-neutral-50 dark:bg-neutral-950">
    <div class="flex flex-col justify-center p-10 rounded-xl shadow-2xl bg-white w-4/12">
      <h1 class="font-medium text-3xl mb-1">Inicia sessió</h1>
      <h2 class="text-sm mb-5">Hola, benvingut/da de nou👋</h2>
      <form class="flex flex-col gap-y-3" @submit.prevent="handleLogin">
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
            <Password id="on_label_password" v-model="credentials.password" :invalid="credentials.failedAuth" :feedback="false" toggleMask />
            <label for="on_label_password">Contrasenya</label>
          </FloatLabel>
        </InputGroup>

        <div class="flex items-center justify-between mb-2">
            <div class="flex items-center">
                <Checkbox id="rememberme" v-model="credentials.rememberme" :binary="true" class="mr-2" />
                <label for="rememberme">Recorda'm</label>
            </div>
            <a class="font-medium no-underline ml-2 text-primary text-right cursor-pointer">Contrasenya oblidada?</a>
        </div>

        <div class="flex flex-col gap-3">
          <div class="flex items-center justify-between gap-2">
            <Button as="router-link" label="Tornar a l'inici" icon="pi pi-arrow-circle-left" to="/" severity="secondary" outlined />
            <Button type="submit" label="Inicia sessió" :loading="signInLoading" :disabled="isNotFilled" class="flex-grow" />
          </div>
          <div class="flex items-center justify-center">
            <span class="text-sm text-gray-500">No estàs registrat?</span>
            <Button as="router-link" size="small" label="Crear un compte" icon="pi pi-arrow-up-right" iconPos="right" to="/signup" target="_blank" link />
          </div>
        </div>
      </form>
    </div>
  </div>
</template>