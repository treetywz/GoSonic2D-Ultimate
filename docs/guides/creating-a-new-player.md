# Creating a New Player

This guide will explain how to create a simple duplicate of the exisitng `sonic.tscn` object, along with
changing its spritesheet. It's pretty simple and straightforward!

## Duplicating the Player Scene

First, you'll need to duplicate `sonic.tscn` itself.

![](player_images/duplicate.png)

This is done simply by right-clicking on `sonic.tscn` (found at `res://objects/players`) and clicking **Duplicate** or
pressing `Ctrl + D` *(Windows)*.

For this guide, I have named my new player scene `newsonic.tscn`. You can name it however you'd like.

## Changing the Player Sprite

Changing the player sprite may be a confusing, but I assure you, it's nothing special.

To start, we would need a spritesheet that follows the same format as the pre-exisiting Sonic
spritesheet (a **10 x 11** tiled grid made up of **64px x 64px** tiles; this can be changed, but for simplicity's sake,
this guide will not cover how to do that).

**If you already have one, you can skip to the next section.**

To keep things simple, you can overlay your sprites on the provided Sonic spritesheet using any program of your choice.

![](player_images/redsonic.png)

For the guide, I've made a modified version of the Sonic spritesheet, changing his signature blue to instead, a red that matches
the color of his shoes.

To stay organized, you can save this `.png` file of your spritesheet into `res://sprites/players`.

### Replacing the Blue Blur

Now, you can go back into your duplicated player scene and your first instinct may be to change the `texture` property
of the player's `Skin` node. However, while changes may reflect in the editor, it will not work in-game.

This is because the player's sprite is overidden by the texture given in the `sonic_texture` property, located
in the player's root node.

To properly change the player's sprite, click on the topmost node, which, by default, is named `Sonic`:

![](player_images/clicksonic.png)

Then, on the right-hand side, you'll see the `Player` scene's properties:

![](player_images/playerproper.png)

For this guide, the only thing we will need to touch is `sonic_texture`. You can simply drag and drop
your spritesheet from earlier into `sonic_texture`, and you're pretty much done!

![](player_images/dragsonic.png)


## Putting New Sonic on the Scene

To replace the player scene of the `Zone`, you can check out [the guide on how to set up zones](creating-a-zone.md#putting-sonic-on-the-runway), as
all you really need to do is instead of dragging and dropping `sonic.tscn`, you drag and drop
your new duplicated player scene.

After doing so, upon starting my game, I can now see that Sonic has turned red as expected!

![](player_images/redsonic2.png)

!!! info
	Since the current system and code regarding the `player_id` is not well-optimized for **use**, it will be revamped heavily. As such,
	changing the player icons, UI text, signpost, etc. will not be covered in this guide until that
	revamp is done.
	