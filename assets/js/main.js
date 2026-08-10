// Two behaviours, both optional: the page is fully usable without JavaScript.
document.addEventListener('DOMContentLoaded', () => {
  const header = document.getElementById('site-header');
  const hero = document.querySelector('.hero');

  if (header && hero) {
    const sentinel = new IntersectionObserver(
      ([entry]) => header.classList.toggle('is-stuck', !entry.isIntersecting),
      { rootMargin: '-80px 0px 0px 0px' }
    );
    sentinel.observe(hero);
  }

  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const revealables = document.querySelectorAll('.reveal');

  if (prefersReducedMotion) {
    revealables.forEach((element) => element.classList.add('is-visible'));
    return;
  }

  const reveal = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          reveal.unobserve(entry.target);
        }
      });
    },
    { rootMargin: '0px 0px -10% 0px' }
  );
  revealables.forEach((element) => reveal.observe(element));
});
