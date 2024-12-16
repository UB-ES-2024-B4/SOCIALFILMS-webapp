export function useUserMovieRelation(
    movie_id: number,
    externalWatchLater?: Ref<boolean>,
    externalFavorite?: Ref<boolean>
) {
  const supabase = useSupabaseClient();

  const isLoading = ref(false);
  const watchLater = externalWatchLater || ref(false);
  const favorite = externalFavorite || ref(false);

  const handleUserMovieRelation = async (relation_type: "favorite" | "watch_later") => {
    isLoading.value = true;
    try {
      let rpcFunction = "add_user_movie";

      if (relation_type === "watch_later") {
        rpcFunction = watchLater.value ? "delete_user_movie" : "add_user_movie";
      } else if (relation_type === "favorite") {
        rpcFunction = favorite.value ? "delete_user_movie" : "add_user_movie";
      }

      const { error } = await supabase.rpc(rpcFunction, {
        _movie_id: movie_id,
        _relation_type: relation_type,
      });

      if (error) throw error;

      if (relation_type === "watch_later") {
        watchLater.value = !watchLater.value;
      } else if (relation_type === "favorite") {
        favorite.value = !favorite.value;
      }
    } catch (e) {
      console.error(`Error handling relation '${relation_type}':`, e);
    } finally {
      isLoading.value = false;
    }
  };

  return {
    isLoading,
    watchLater,
    favorite,
    handleUserMovieRelation,
  };
}
