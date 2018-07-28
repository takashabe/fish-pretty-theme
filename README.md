# fish-pretty-theme

pretty prompt for fish shell

![sample](https://user-images.githubusercontent.com/681508/41527807-3b640666-7323-11e8-9ede-c73cf0b2f9e0.png)

## Features

- Pretty fish icon
- Show environments
    - git status
    - kubernetes context

## Install

[Fisherman](https://github.com/fisherman/fisherman):

```fish
fisher takashabe/fish-pretty-theme
```

Manually

Download and move to your config directory:

```fish
git clone https://github.com/takashabe/fish-pretty-theme
mv fish-pretty-theme/fish_prompt.fish ~/.config/fish/functions/
```

#### NOTE:

If using iTerm2 + High Sierra, occurring display bug with Emoji.

refs: https://gitlab.com/gnachman/iterm2/issues/6130
