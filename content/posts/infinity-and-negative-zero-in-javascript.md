+++
title = "Infinity and negative zero in Javascript"
description = "Infinity and negative zero in Javascript"
date = 2021-07-27
+++

```js
> 1 / 0
Infinity

> 0 * -1
-0
```

Yesterday I learned about the concepts of the global constant `Infinity` and the existince of `-0` in Javascript. Despite working with the language for most of my career, it still finds ways to suprise me.

## Infinity

[`Infinity`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Infinity) is a globally defined constant in the [ECMAScript 5 specification](https://262.ecma-international.org/5.1/#sec-4.3.22). It's nice to have a mathmatical guarentee of largeness, rather than having to use [`Number.MAX_SAFE_INTEGER`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/MAX_SAFE_INTEGER) and account for any edge cases. It's also handy to have around to represent the outcome of what would otherwise be mathmatical party crashers in other languages, like dividing by zero.

```js
> 1 / 0
Infinity

> Infinity > Number.MAX_SAFE_INTEGER
true

> 0 / 0
NaN

> Infinity * 0
NaN
```

`Infinity` also has it's mirror, `-Infinity` (Or [`Number.NEGATIVE_INFINITY`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/NEGATIVE_INFINITY) if you'd rather not trust the negative sign next to a constant). Handy when you're doing comparisons in the negative direction.

```js
> -1 / 0
-Infinity

> -Infinity < Number.MIN_SAFE_INTEGER
true
```

Treating `Infinity` as a number will solve some problems, but could cause others depending on how you use it. `Infinity / Infinity` is labeled as `NaN`, which while [arguably true in a mathmatical sense](https://math.stackexchange.com/questions/181304/what-is-infinity-divided-by-infinity) doesn't really hold if Infinity is a number. If you divided `Number.MAX_SAFE_INTEGER` by itself after all, you'd still get `1`.

```js
> Infinity / 0
Infinity

> Infinity / Infinity
NaN
```

Stringifying `Infinity` can be a sensitive endeavor. String interpolation yields `"Infinity"`, while JSON stringifying strangely yields `"null"`. Pay attention to how your results are serialized.

```js
> JSON.stringify(Infinity)
"null"

> `${Infinity}`
"Infinity"
```

## Negative zero

While its [arguable whether negative zero exists as a mathmatical concept](https://math.stackexchange.com/questions/667577/does-negative-zero-exist), it most definitely exists in Javascript. You can obtain negative zero through any multiplication or division operation with zero that would yield a negative with any other number, and remove it by repeating the operation.

```js
> 0 * -1
-0

> 0 / -1
-0

> -0 / -1
0
```

Unlike infinity, the negative aspect of `-0` won't usually survive stringification.

```js
> JSON.stringify(-0);
"0"

> `${-0}`
"0"
```

While I'm having a tough time replicating it, I have seen `-0` preserved in rendered html in a React application. If you happen to know of other situations where `-0` can be stringified, I'd be interested to hear.

`-0` has the odd property of being _strictly_ equal to (positive) `0`. This makes it the only non-identity strictly equal relationship that I know about in JS. It can also make it hard to detect if you want to account for it in an edge case.

```js
> 0 === -0
true

> -0 * -1 === 0
true

> 0 * -1 === 0
true
```

If you do want to test for `-0`, you can use division to yield either `Infinity` or `-Infinity`.

```js
> 1 / 0 === Infinity
true

> 1 / -0 === Infinity
false

> 1 / -0 === -Infinity
true
```

Next time a number mysteriously becomes negative in your algorithm, be sure to check the zeros.
