![cool logo](https://github.com/treetywz/GoSonic2D-Ultimate/blob/main/read_me/logo.png)
## About the project
A Sonic the Hedgehog framework forked from marimitoTH's [GoSonic2D](https://github.com/marmitoTH/GoSonic2D) that aims to add more features from the classic Sonic games. This framework uses Godot Engine v4.6 for development.

## Added features

* Player Improvements
  - Added ledge balancing animations.
  - Added pushing animations.
  - Added idle animations.
  * Snowboarding
    - It simply causes the player to constantly accelerate. Not exactly engine-accurate or anything.
  - Ability to lose rings upon taking damage.
  - Ability to die upon taking damage without any rings.
  - Ability to respawn after death, if the player has more lives.
  - Game Over occuring upon dying with no more lives.
  - Time Over occuring upon the timer reaching the ten minute mark.
  - Ability to perform a Spin Dash
  - Ability to perform a Super Peel Out
  - Ability to perform a Drop Dash
  * Ability to look up and down
    - Camera pans up and down accordingly.
  * Ability to transform into Super Sonic
    -  To transform you need 50 rings or more.
    -  For every second spent as Super Sonic, a ring is drained.
    -  Includes palette swapping utilizing shaders.
* Music Manager
  - Play all your music with `MusicManager.play_music("path/to/music.ogg")`.
* Mobile Touch Controls
* Camera Delay
  - Used to create a camera lag effect for certain moves (e.g. Spin Dash).
* Score Tallying
  - Uses the Sonic 3 System, along with Mania's Cool Bonus addition.
* Shield Additions
  - Added monitors that give shield powerups.
  - Added the bubble shield.
  - Added the lightning shield's ring attraction.
  - Added the lightning shield's particles.
* 100 Rings = 1-UP
* 999 Ring Cap
  - Can be uncapped by setting `cap_rings` to `false` in ScoreManager.
* Camera Death Zone
  - The bottom of the camera instantly kills the player.
* Loading screens

## Known issues

* The Music Manager may be unstable.
* Super Sonic's code may be unstable.
* The bubble shield's behavior is not entirely accurate to the games.
* There is likely an abundance of unused assets and code lingering between the files.

## MusicManager usage

All functions must be ran as ```MusicManager.replace_with_function()```

### ```play_music(music : AudioStream)```
Stops current track then plays the `AudioStream` provided.

### ```stop_music()```
Stops current track

### ```fade_out(speed : Int)```
Fades the current track out, speed will be how much db is subtracted per 0.1 seconds.

### ```fade_in(speed : Int)```
Fades the current track in, speed will be how much db is added per 0.1 seconds.

### ```extra_life_jingle()```
Plays the extra life jingle. (Mutes the current track then fades the music track back in after jingle.)

### ```reset_volume()```
Resets the volume to the stream_volume variable (adjustable in MusicManager)

### ```replay_music()```
Stops and starts the current track

### ```is_playing()```
Returns a bool if the track is playing anything.

## Credits/Special Thanks
* Thank you [Sonic Physics Guide](https://info.sonicretro.org/Sonic_Physics_Guide), for a well-documented guide on implementing most of these features.
* Credits to [ArtisIan](https://www.youtube.com/@ArtisIan) for the [Super Music](https://www.youtube.com/watch?v=erlsw2ISSl4).
* Credits to raphaklaus for the [fading shader](https://github.com/raphaklaus/sonic-palette-fade) used for fading transitions
* Credits to Dicode for the [loading screen script](https://www.youtube.com/watch?v=5aV_GSAE1kM)
