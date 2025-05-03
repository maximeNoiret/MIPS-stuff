Just a repo to store what I've done in MIPS32 assembly for fun.
Probably shouldn't use it, probably sucks, certainly was fun to make tho

Right now, I'm planning on re-writing entirely how arrays work.
Instead of having three different args (pointer and length and capacity),
it'll only have one (pointer) and the length and capacity will be stored "in" the array.

Basically:
\[BASE + 0\]    = length
\[BASE + 1\]    = capacity
\[BASE + 2...\] = data
