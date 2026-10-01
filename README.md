# Pong

A simple Pong game written in **Odin** using **SDL3**.

This is a small learning project focused on practicing game programming and building reusable pieces for a future game framework. 

Two folders are included: `with-engine` and `without-engine`

`without-engine` was the first iteration

`with-engine` were follow up iterations that added better collision physics and integration with the Sleipnir (personal game engine) engine

## Running

You'll need [Odin](https://odin-lang.org/) installed.

Run directly:

```bash
odin run .
# or
odin run . -collection:sleipnir="C:/Code projects/odin/sleipnir"
```

Build an executable:

```bash
odin build . -out:pong.exe
```

Then run `pong.exe`.

Have fun! 🏓
