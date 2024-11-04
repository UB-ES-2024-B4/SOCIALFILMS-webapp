<script setup lang="ts">
import 'primeicons/primeicons.css'
import { useToast } from "primevue/usetoast";

// Toast
const toast = useToast();

// State
const visible = ref(false);
const rating = ref(0);
const comment = ref('');
const successMessage = ref('');

// Select rating
const selectRating = (star: number) => {
    rating.value = star;
};

// Submit review
const submitReview = () => {
    if (rating.value > 0) {
        toast.add({ severity: 'success', summary: 'Éxito', detail: 'La review ha sido publicada correctamente.', life: 3000 });
        // visible.value = false
        
        // Reset form after 10 minutes
        // setTimeout(() => {
        //     resetForm();
        // }, 10 * 60 * 1000);
    } else {
        toast.add({ severity: 'error', summary: 'Error', detail: 'Por favor, selecciona una calificación y escribe un comentario.', life: 3000 })
    }
};

// Reset form
const resetForm = () => {
    rating.value = 0;
    comment.value = '';
    successMessage.value = '';
};
</script>

<template>
    <div>
        <Button label="Dejar una Reseña" @click="visible = true" />
        <Dialog v-model:visible="visible" modal header="Escribir Reseña">
            <div class="flex flex-col">
                <h3 class="mb-2">Califica del 1 al 10</h3>
                <div class="flex mb-6 ">
                    <span
                        v-for="star in 10"
                        :key="star"
                        @click="selectRating(star)"
                        class="cursor-pointer text-2xl mx-2"
                    >
                        <i :class="['pi', star <= rating ? 'pi-star-fill' : 'pi-star']"></i>
                    </span>
                </div>
                <Textarea
                    v-model="comment"
                    rows="3"
                    maxlength="255"
                    placeholder="Escribe tu comentario..."
                    class="mb-4"
                />
                <div class="flex justify-between">
                    <Button label="Publicar" severity="success" @click="submitReview" />
                </div>
            </div>
         </Dialog>
    </div>
</template>