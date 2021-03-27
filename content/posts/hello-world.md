+++
title = "Hello World"
aliases = ["/articles/hello-world"]
date = 2019-02-24
+++

```js
setInterval(() => {
    const post = getBlogPost();
    blog.write(post);
}, 1000);

function getBlogPost() {
    // TODO
}
```

Welcome to my blog! Not entirely sure what this should be about yet, but I had a free Sunday afternoon and figured it was about time I put together a site.

I doubt that I'll be making any major posts to this site any time soon, but to kick things off I thought it may be helpful to discuss how the site was made in thanks to the excellent open source tools I used.

- [**Hexo**](https://hexo.io/) - Excellent blogging framework that uses a node js stack. It's not the simplest program out there, but I'm familiar with the tech stack and can customize it just deeply enough to make it my own.
- [**Cactus**](https://github.com/probberechts/hexo-theme-cactus) - Hexo theme with a few color options. I simplified some of the layouts and changed some colors, but what remains is mostly faithful to the original design. Thanks to [Pieter Robberechts](https://github.com/probberechts) for the excellent design.
- [**Github Pages**](https://pages.github.com/) - Simple and free static site hosting straight from Github. Hexo has the ability to deploy the rendered site via git, and Github is more than willing to accept pushes to deploy.
- [**hexo-generator-search**](https://www.npmjs.com/package/hexo-generator-search) - A local search generator for hexo that makes instant searches work on a static site. Props for the smooth integration with Cactus.