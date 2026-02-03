# Zones

In 2D Sonic games, a level or stage is often referred to as a zone.
It is usually divided into multiple acts, and in games such as Sonic the Hedgehog 3, Sonic Mania, and Sonic Superstars,
they feature seamless transitions from act to act.

However, in the context of GoSonic2DU, a `Zone` is a class that is inherited by the root node of every level.

## Features

A `Zone` is essentially the backbone of all operations going on in a single level.

It handles:

- Player initialization and spawning
- Camera setup and limits
- Act progression and transitions
- Level Music
- Title card display
- Cutscenes

If this framework was a high school class, the `Zone` is that one person
everyone always goes to for advice. Unlike real life, it does not have any
feelings, so do not be afraid to rely on it.

## Zone Properties
Just taking a glance at the many properties this thing has to offer, you may notice
most properties have straightforward names, describing what function they serve.

![Zone Properties](zones_images/zoneproperties.png)

Let's take a look at every single one, section by section.

### Zone Info

| Property | Type | Description |
|----------|------|-------------|
| `zone_name` | String | This is the display name that will be shown in the title card (e.g., "Green Hill"). You do not need to add "Zone," as it will do that for you automatically. |
| `amount_of_acts` | int | This variable determines how many acts this zone will have. For example, most of the 2D Sonic games have two acts, so for that, you would set it to `2`. |
| `next_scene` | String | Here, you put in the path to the next scene that proceeds this zone. This will be the scene that will be loaded after the player finishes the zone. As a default, it is set to `res://scenes/title.tscn`. |
| `scripted_intro` | bool | This turns on the scripted intro feature of a `Zone`. Essentially, instead of proceeding with the normal zone intro, it skips it, and runs the function `custom_intro()` instead. *(This is explained in better detail in the Cutscenes section.)* |

### Resources

| Property | Type | Description |
|----------|------|-------------|
| `player_resource` | Resource | In here, you would typically insert `sonic.tscn`, or whatever player object you want the `Zone` to load. |

### Audio

| Property | Type | Description |
|----------|------|-------------|
| `zone_music` | AudioStream | This determines what `AudioStream` is requested to `MusicManager` when the function `_zone_music()` is called. |
| `victory_music` | AudioStream | This determines what music is played before the score tally upon finishing an act through a sign post. |

### Level Settings

| Property | Type | Description |
|----------|------|-------------|
| `starting_player_state` | String | This dropdown menu allows you to pick and choose which state the player starts in. It's set to `Regular` as a default, but you could make the player start in the `Dead` state for all I care. |

### Camera Limits

| Property | Type | Description |
|----------|------|-------------|
| `acts` | Array[CameraLimits] | This array is to be filled with `CameraLimits`, a resource that contains information on where the camera (and player) is bound to during a specific act. Index 0 is for the first act, index 1 is for the second, and so on. |
| `show_act` | int | This variable determines what act's boundaries are visually shown in the editor. This requires a `LimitsVisualizer` to be placed in your scene. |