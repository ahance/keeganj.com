+++
title = "Hello Zola"
description = "Rewriting my site to be javascript-free in Zola, the Rust-based static site generator"
date = 2021-03-27
+++

It seems most engineers spend more time tinkering with how their blog works than writing content for it. Sadly, I'm no exception. "Shiny new technology syndrome" gripped me yet again when I read about [Zola](https://www.getzola.org/) on Hacker News, yet another static site generator. 

Wait, wait, don't go. This one's written in _**Rust**_.

It strictly adheres to the idea of containing it's functionality within a single executable. It's written and maintained by an [opinionated author](https://github.com/getzola/zola/blob/master/README.md). As every SSG seems to claim nowadays, it's fast. Unlike most of them, Zola is actually, blazingly fast.

The main benefit to me is that it's not written in javascript. As much as I love javascript and it's expansive ecosystem, I'm trying my best to reduce my dependency on it. Not every site that displays content needs to be interactive after all, and I believe there's value in seeing a site that does more than just get all greens on a Google Lighthouse test. I want to be able to write sites that can display their content _instantly_, and the easiest way to do that is to take a break from my old friend JS.

I don't know Rust. It's not that I don't want to know it, but moreso that I haven't gotten a good reason to learn it yet. Even though I graduated with a degree in Computer Engineering and had my later classes in low level languages and circuits, I haven't touched hardware since I left school. The market has kept me in fullstack web development since graduation. Despite that, I would _love_ to have a reason to learn a low level language again. 

Like every programmer and his dog I've made my way through at at least a few tutorials from the [Rust book](https://doc.rust-lang.org/stable/book/). Zola seemed like a nice way to eventually give myself a reason to ford past the chapter on [References and Borrowing](https://doc.rust-lang.org/stable/book/ch04-02-references-and-borrowing.html). In the meantime I hoped that not knowing how the internals of the generator worked would keep me from tinkering with it and focus on my site's content.

So, in and effort to reduce my time spent tinkering, I spent a few hours tinkering to rewrite my site with Zola. Here's what's different:

- I wrote the theme from scratch. I'm not a designer by trade, but over the past year I've been trying to learn more ways to express my engineering ideologies through visual design. That's a flowery way of saying I wrote all the CSS for this one and didn't use a theme. If you use [Monokai](https://monokai.pro/) in your editor you'll recognize most of the colors here.
- There's no JS. It's all just HTML and CSS. While most of the code I write is in JS or Typescript, I think there's value in being able to write useful websites without it.
- There's a dark mode. Not going to lie, I did this one mostly for myself so I could write and edit posts at night.
- It's printable. All posts should translate nicely to page if you're like me and like to occasionally print content to read and notate without the distractions of the modern desktop environment.
- It's [open source](https://github.com/keeganj/keeganj.com). In addition to providing the source code for how this site is written, I believe there's value in showing the revision history of my work on a bigger code repository that will probably outlive this one.
- It's wicked fast. There's no javascript to spin up the page. No frontend tricks like link preloading to make it faster. No webpack config to sate or wait on 5 minute builds for. Just generated HTML and CSS you could run on your smart toaster.

I won't describe it in much more detail than this because, frankly, it's liable to change. Looking at my [Hello World](@/posts/hello-world.md) post (which to my shame is only 2 posts before this one), quite a lot has changed. I'm prone to tinkering.

Unlike most of my attempts at unique design, I'm happy with this one. With luck it will encourage more blog posts in the near future.
