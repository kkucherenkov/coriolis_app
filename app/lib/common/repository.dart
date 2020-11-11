mixin RepositoryListener<TEvent> {
  void onRepositoryEvent(TEvent event);
  void onRepositoryError(TEvent error);
}

abstract class BaseRepository<TEvent> {
  List<RepositoryListener> listeners = List();

  void addListener(RepositoryListener listener) {
    listeners.add(listener);
  }

  void removeListener(RepositoryListener listener) {
    listeners.remove(listener);
  }

  void publishEvent(TEvent event) {
    for (RepositoryListener listener in listeners) {
      listener.onRepositoryEvent(event);
    }
  }

  void publishError(TEvent event) {
    for (RepositoryListener listener in listeners) {
      listener.onRepositoryError(event);
    }
  }
}
