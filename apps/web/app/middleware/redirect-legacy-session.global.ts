/**
 * Phase 8 Stream A — legacy redirect for the GM client.
 *
 * Until Stream B, the path /app/sessions/* is a leftover from before the
 * GM was relocated to /app/game-sessions/*. We 301 the old URL so GM
 * bookmarks still work. This middleware is REMOVED at the start of
 * Stream B, when /app/sessions/* lights up for the player client.
 */
export default defineNuxtRouteMiddleware((to) => {
  const match = /^\/app\/sessions(\/.*)?$/.exec(to.path);
  if (!match) return;
  const tail = match[1] ?? '';
  return navigateTo(`/app/game-sessions${tail}`, { redirectCode: 301 });
});
