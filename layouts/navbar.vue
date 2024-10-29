<script setup lang="ts">
import 'primeicons/primeicons.css'
import { useToast } from "primevue/usetoast";

const toast = useToast();
const supabase = useSupabaseClient()

const searchQuery = ref('');

const userOptions = [
    {
        label: 'Tancar sessió',
        icon: 'pi pi-sign-out',
        command: async () => {
            try {
                const { error } = await supabase.auth.signOut()
                if (error) throw error
                toast.add({ severity: 'success', summary: 'Sessió tancada', detail: "S'ha tancat la sessió amb exit" , life: 3000 });
            } catch (error) {
                toast.add({ severity: 'error', summary: 'Sessió no tancada', detail: "No s'ha tancat la sessió amb exit" , life: 3000 });
                
            }
        }
    }
];

const user = useSupabaseUser()

</script>


<template>
    <div>
        <Toolbar class="w-full flex justify-between items-center p-10">
            <template #start>
                <img src="../public/logo1.png" alt="Logo" class="h-20 w-auto" />
            </template>

            <template #center>
                <div class="flex items-center justify-center flex-grow">
                    <IconField>
                        <InputText placeholder="Search" />
                        <InputIcon>
                            <i class="pi pi-search"></i>
                        </InputIcon>
                    </IconField>
                </div>
            </template>

            <template #end> 
                <div class="flex items-center gap-3">
                    <Button v-if="!user" label="Login" icon="pi pi-user" @click='navigateTo("/login")'/>
                    <SplitButton v-if="user" label="Compte" :model="userOptions"></SplitButton>
                    <Avatar v-if="user" icon="pi pi-user" class="mr-2" size="large" />
                </div>
            </template>
        </Toolbar>
        <slot />
    </div>
</template>

