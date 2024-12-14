# The title of your game #

## Summary ##

**A paragraph-length pitch for your game.**

## Project Resources

[Web-playable version of your game.](https://itch.io/)  
[Trailor](https://youtube.com)  
[Press Kit](https://dopresskit.com/)  
[Proposal: make your own copy of the linked doc.](https://docs.google.com/document/d/1qwWCpMwKJGOLQ-rRJt8G8zisCa2XHFhv6zSWars0eWM/edit?usp=sharing)  

## Gameplay Explanation ##

**In this section, explain how the game should be played. Treat this as a manual within a game. Explaining the button mappings and the most optimal gameplay strategy is encouraged.**


**Add it here if you did work that should be factored into your grade but does not fit easily into the proscribed roles! Please include links to resources and descriptions of game-related material that does not fit into roles here.**

# External Code, Ideas, and Structure #

If your project contains code that: 1) your team did not write, and 2) does not fit cleanly into a role, please document it in this section. Please include the author of the code, where to find the code, and note which scripts, folders, or other files that comprise the external contribution. Additionally, include the license for the external code that permits you to use it. You do not need to include the license for code provided by the instruction team.

If you used tutorials or other intellectual guidance to create aspects of your project, include reference to that information as well.

# Main Roles #

Your goal is to relate the work of your role and sub-role in terms of the content of the course. Please look at the role sections below for specific instructions for each role.

Below is a template for you to highlight items of your work. These provide the evidence needed for your work to be evaluated. Try to have at least four such descriptions. They will be assessed on the quality of the underlying system and how they are linked to course content. 

*Short Description* - Long description of your work item that includes how it is relevant to topics discussed in class. [link to evidence in your repository](https://github.com/dr-jam/ECS189L/edit/project-description/ProjectDocumentTemplate.md)

Here is an example:  
*Procedural Terrain* - The game's background consists of procedurally generated terrain produced with Perlin noise. The game can modify this terrain at run-time via a call to its script methods. The intent is to allow the player to modify the terrain. This system is based on the component design pattern and the procedural content generation portions of the course. [The PCG terrain generation script](https://github.com/dr-jam/CameraControlExercise/blob/513b927e87fc686fe627bf7d4ff6ff841cf34e9f/Obscura/Assets/Scripts/TerrainGenerator.cs#L6).

You should replay any **bold text** with your relevant information. Liberally use the template when necessary and appropriate.

## Producer

**Describe the steps you took in your role as producer. Typical items include group scheduling mechanisms, links to meeting notes, descriptions of team logistics problems with their resolution, project organization tools (e.g., timelines, dependency/task tracking, Gantt charts, etc.), and repository management methodology.**

## User Interface and Input

**Describe your user interface and how it relates to gameplay. This can be done via the template.**
**Describe the default input configuration.**

**Add an entry for each platform or input style your project supports.**

## Combat/Movement/Camera - Qixiang Fan

When designing combat scenes, I tried to balance the two-player control and the gameplay experience. I create two [input_mapping](/data/input_mappings) scripts to manage 2 player control. 




https://github.com/user-attachments/assets/73ba99bc-4d00-43b2-b63e-dde833e5793a


My [movement system](/scenes/player/player.gd) allows two people to control two ships to move and fire projectiles to cause damage. I created a split-screen display mode, using separate viewports and cameras for each player to ensure that the experience of any player is not affected by the limitations of the shared camera. This design also solves the challenge of playing two players simultaneously on a single screen. I also set up two control systems and keyboard bindings. Player 1 controls ship 1 through wasd and uses the space key to fire projectiles. Player 2 controls ship2 with the arrow key and uses the enter key to fire projectiles. In order to achieve the goal of combat on the same PC, I created two viewports with two cameras loaded separately, and the two split-screen viewports share the same 2D map. The camera will follow the two players separately.



https://github.com/user-attachments/assets/7bb3eae8-5ff3-43a9-9b55-2857cb8c1f52


Because in the battle, the players can only use one mouse, and the general usage scenario is mainly on the PC without a game controller to control the direction of the bullet, so I designed the [projectile system](/scenes/projectile/projectile.gd) to fire forward. Although the attack mode is not very flexible, it also turns the battle into a game that focuses on positioning and timing. This also increases usability, and all operations use keyboard bindings to ensure that two players can play the game on a single PC at the same time, even without additional devices such as game controllers.
For the damage system, players can change the health and projectile damage at any time by editing external variables to get a different gaming experience. Players can choose a fast-paced, high-risk gameplay or a longer, more strategic battle style according to their preferences. For example, the health that will be shattered in one or two shootings, in this case, the combat becomes a game mainly about dodging attacks and finding the right opportunity to kill the opponent with one blow, while increasing health or reducing damage can also get a more lasting battle. And because of the difference in damage and health, players also need to consider the size of the ship, the damaged area, and the choice of modules that can fire projectiles when designing their own spaceships. This also makes this game require you to decide your own battle strategy from the beginning when designing your own spaceship and make trade-offs based on body size and weapons. I think this design strategy is also a kind of fun to play. It also adds extra strategy and playability to the game.

## Animation and Visuals

**List your assets, including their sources and licenses.**

**Describe how your work intersects with game feel, graphic design, and world-building. Include your visual style guide if one exists.**

## Game Logic

**Document the game states and game data you managed and the design patterns you used to complete your task.**

# Sub-Roles

## Audio - Qixiang Fan

**List your assets, including their sources and licenses.**
Sound effect:
- [Module selection Click](https://opengameart.org/content/16-button-clicks) - Free for non commercial use
- [Menu Selection Click](https://opengameart.org/content/menu-selection-click) - Free for non commercial use
- [Imapct](https://opengameart.org/content/2-high-quality-explosions) - Free for non commercial use
- [Projectile](https://opengameart.org/content/4-projectile-launches) - Free for non commercial use
- [Gun Sound Effects](https://opengameart.org/content/space-laser) - Free for non commercial use
  
The background music comes from an anime OST I like so much:
- [BGM](https://www.bilibili.com/video/BV1YB4y1P7Ra?spm_id_from=333.788.videopod.episodes&vd_source=3c66c0fe189e749594e5c140af965073&p=3)

**Describe the implementation of your audio system.**
The sound effects in the game are generated according to different scenarios:

- [Click ship module](https://github.com/qxfan/com/blob/381386e821b9f867842a200f75f5f56e826e001b/scripts/ship_design_scene/ship_blueprint_designer.gd#L265C1-L270C65): When the player selects a ship module in the design interface
- [Click ship-building function](https://github.com/qxfan/com/blob/381386e821b9f867842a200f75f5f56e826e001b/scripts/ship_design_scene/ship_blueprint_designer.gd#L271C1-L273C79) When the player selects the ship-building function in the design interface
- [Projectile](/scenes/player/player.gd) When the player fires a projectile
- [Damage received](/scenes/player/player.gd) When the player receives damage

The background music needs to be played continuously between the design and combat scenes. To manage the sound effects and BGM, I created an [audio_manage](/autoloads/audio_manager.gd) script to manage the sound effects and background music.

**Document the sound style.** 
Sound style is very important for our game. Since our game is set in space, the sound styles I choose for combat are all from sci-fi sound effects. These sci-fi sounds are louder, so I chose softer soundtrack background music so that the sound effects will not be covered by the background music or too many sound effects at the same time, which will reduce the player's gaming experience.

## Gameplay Testing

**Add a link to the full results of your gameplay tests.**

**Summarize the key findings from your gameplay tests.**

## Narrative Design

**Document how the narrative is present in the game via assets, gameplay systems, and gameplay.** 

## Press Kit and Trailer

**Include links to your presskit materials and trailer.**

**Describe how you showcased your work. How did you choose what to show in the trailer? Why did you choose your screenshots?**

## Game Feel and Polish

**Document what you added to and how you tweaked your game to improve its game feel.**
