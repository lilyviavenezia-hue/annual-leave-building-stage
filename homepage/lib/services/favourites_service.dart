/// Stores suggestion favourites by category and stable model id.
///
/// The in-memory implementation keeps UI state in sync today; a backend can
/// replace this service without changing the cards or detail page.
class SuggestionFavoritesService {
  static final Map<String, bool> _favorites = {};

  bool? isFavorite(String key) => _favorites[key];

  void setFavorite(String key, bool isFavorite) {
    _favorites[key] = isFavorite;
  }
}
