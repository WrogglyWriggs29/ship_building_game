## **Squishy Shooters**

## Basic Game Information

### Project Resources

**Initial Plan:**  
[https://docs.google.com/document/d/1gh0JiFi8XdOLrk2RTWnkMNiu0LnVpCPqKzEZdIWUy9E/edit?tab=t.0\#heading=h.i3tv2mxf7h7z](https://docs.google.com/document/d/1gh0JiFi8XdOLrk2RTWnkMNiu0LnVpCPqKzEZdIWUy9E/edit?tab=t.0#heading=h.i3tv2mxf7h7z)   
**Progress Report**: [https://docs.google.com/document/d/1ykR4eWkXBu2gq9-\_zVIGGPoT24LsIhbJf\_svYaUdKJI/edit?tab=t.0](https://docs.google.com/document/d/1ykR4eWkXBu2gq9-_zVIGGPoT24LsIhbJf_svYaUdKJI/edit?tab=t.0)   
**Trailer:**

**Press Kit:**  
[https://press-kit-iota.vercel.app/](https://press-kit-iota.vercel.app/) 

### Summary

Squishy Shooters is a 2-D multiplayer ship battle game, featuring custom soft-body physics and a highly customizable ship design system. Ships squish and bounce, but will break apart under enough force, allowing players to attack each other within an arena filled with obstacles. Battle your friends, and you can save the most effective ships for your next match.

### Gameplay Explanation

The starting menu of the game allows the player to select between the ship editor, combat, and a tutorial. 

Combat in the game requires both players to have functional ships \- consisting of structural components, thrusters, and guns. All of these components are handled in the ship design menu, in which the players can place parts onto a grid, configure direction and position, and bind keys. Once ships are designed, they can be saved and used for actual combat. 

The battleground requires both players to select a ship from a menu of both premade and player-made ship designs, after which both players enter a shared-screen arena. When one player’s ship is destroyed, the round ends, allowing players to go back to the drawing board and fight again. 

### Game Mechanics and Logic

#### Ship Design

The ship design menu consists of a few important components: 

- A canvas, made up of grids for modules to be placed upon.   
- Structural components.  
- Factory components, ie guns, thrusters.  
- Keybinds, to assign one or more keys to various components.   
- Save and Load menus for ship designs.   
- A test button, which takes the player into an empty testing environment filled with planets and meteors. 

Players can go between the test arena and the editor using the escape key, allowing them to really hone in on the minutia of the working design.

## Roles

#### Producer (Sam Herring)

I first created a GitHub repository and invited all of our team members to it in order to track our progress. Furthermore, I created a discord group chat for our team to communicate with one another about progress on their parts. I created a when2meet.com in order to organize team meetings and group calls so we could further catch up on how everything is going and in order to meet specific deadlines. In order to help my team start off, I created a diagram showcasing how some things are supposed to connect to one another along with some of the godot objects they could use.

#### Movement / Physics (Sam Herring)

At the core of the game is the soft-body physics sim, which makes use of very little built-in Godot resources, and essentially was made from scratch by Sam Herring. It handles collisions, inter-module connections and forces, and determines the threshold for how much force can break the ship apart. 

#### Game Logic (Calvin Yee), (Sam Herring), (Andrew Tran)

Calvin: Built the serialization for the ship designs in the ship design menu, for transforming the underlying blueprint classes and subclasses to json format. Added the sprites made by Isabel to the ship, with dynamic reaction to input, and implemented projectile velocity/force interactions with the soft-body modules. Finalized combat scene mechanics and our final scene tree setup. 

Sam: Created the grids and collision interactions for the modules and soft bodies. Built the underlying module structure and subclasses that the ship-design menu leverages to place and modify components. Created scene manager autoload for transition logic. Created a “dragger” to apply custom forces to the soft body both for demonstration and debugging purposes (main highlight of the in-class demo). Created the grid and mesh visible as the outline of the ship, which highlights itself when colliding with another grid. Responsible for all of the underlying collision and force interactions throughout the game, including custom mesh interactions for the ships and thruster movement. General programming throughout almost every area of the project. 

Andrew: Built the factory system allowing ships to manage inventories and deliver materials, such as thrusters and other items through a conveyor belt like system. This allowed for module to module interactions. This includes having to account for when the ship breaks apart ensuring that the conveyors function correctly even when the grid disconnects and breaks. 

#### Camera (Harshana Somas)

Implemented a camera model that takes the average of all the ship modules and locks to the position. Updated to a camera that smoothly tracks the target object with a leash and speed constraint. Camera Model takes into account the positiion of both the ships and zooms out based to have the viewport accomodate both ships.

#### User Interface (Calvin Yee), (Harshana Somas), (Sam Herring)

Calvin: Implemented a Save and Load system (serialization) for ship blueprints. Implemented functionality to add and set up guns on blueprints. Set up the main intro menu using Isabel’s assets (for background and title text) for transition to the various gameplay pathways. 

Harshana: Created dropdown menus for players to select which blueprints to save and load, allowing for custom filenames and paths.

Sam: Created majority of the features on the blueprint menu including factory, structural components, and selection of modules. Created the test button which formed the basis of our early game development and became a key feature in the ship design part of the game. 

#### Assets (Isabel Shic), (Danielle Chang)

Danielle: Creating the design of the character which is seen helping the player throughout the tutorial. 

Isabel: Created the gist of the UI elements and graphics seen throughout the menu screen and throughout the game. This includes the title scene fonts, background, and other various things. Also made the textures/sprites for the ship and the ship items.

#### Map (Zhoulei He)

Created an outer space like themed map to fit the theme of the game. This includes things like the planets and asteroids which can be collided with. 

#### Combat  (Sam Herring), (Calvin Yee), (Harshana Somas), (Qixiang Fan)

Early into the game development process, Qixiang solo-developed a 2-player demo scene that allowed for split screen control, shared keybindings, and dynamic camera updates \- all components which we wanted to implement in the final version of the combat. Due to some limitations with the ship complexity, our final iteration was unable to capture all of these elements, specifically the split-screen mechanic, and we opted for a slightly easier shared-screen combat system with a single dynamic camera. In other areas, such as the combat and movement, we applied a much more complex system of mechanics via forces acting on the soft-body sim as opposed to a flat damage-health interaction.

Harshana: Created dynamic camera updates to help the scene be centered between the ships and keep both on-screen. 

Calvin/Sam: Wrote the final script for our combat scene, with Sam utilizing Harshana’s file-selection modules to allow both players to select their ships before entering battle. Leveraged existing mechanics from our testing scene to implement a basic combat area. 

Qixiang:   
When designing combat scenes, I tried to balance the two-player control and the gameplay experience. I create two \[input\_mapping\](/data/input\_mappings) scripts to manage 2 player control.   
https://github.com/user-attachments/assets/73ba99bc-4d00-43b2-b63e-dde833e5793a  
My \[movement system\](/scenes/player/player.gd) allows two people to control two ships to move and fire projectiles to cause damage. I created a split-screen display mode, using separate viewports and cameras for each player to ensure that the experience of any player is not affected by the limitations of the shared camera. This design also solves the challenge of playing two players simultaneously on a single screen. I also set up two control systems and keyboard bindings. Player 1 controls ship 1 through wasd and uses the space key to fire projectiles. Player 2 controls ship2 with the arrow key and uses the enter key to fire projectiles. In order to achieve the goal of combat on the same PC, I created two viewports with two cameras loaded separately, and the two split-screen viewports share the same 2D map. The camera will follow the two players separately.  
https://github.com/user-attachments/assets/7bb3eae8-5ff3-43a9-9b55-2857cb8c1f52  
Because in the battle, the players can only use one mouse, and the general usage scenario is mainly on the PC without a game controller to control the direction of the bullet, so I designed the \[projectile system\](/scenes/projectile/projectile.gd) to fire forward. Although the attack mode is not very flexible, it also turns the battle into a game that focuses on positioning and timing. This also increases usability, and all operations use keyboard bindings to ensure that two players can play the game on a single PC at the same time, even without additional devices such as game controllers.  
For the damage system, players can change the health and projectile damage at any time by editing external variables to get a different gaming experience. Players can choose a fast-paced, high-risk gameplay or a longer, more strategic battle style according to their preferences. For example, the health that will be shattered in one or two shootings, in this case, the combat becomes a game mainly about dodging attacks and finding the right opportunity to kill the opponent with one blow, while increasing health or reducing damage can also get a more lasting battle. And because of the difference in damage and health, players also need to consider the size of the ship, the damaged area, and the choice of modules that can fire projectiles when designing their own spaceships. This also makes this game require you to decide your own battle strategy from the beginning when designing your own spaceship and make trade-offs based on body size and weapons. I think this design strategy is also a kind of fun to play. It also adds extra strategy and playability to the game.

#### Audio (Qixiang Fan)

\*\*List your assets, including their sources and licenses.\*\*  
Sound effect:  
\- \[Module selection Click\](https://opengameart.org/content/16-button-clicks) \- Free for non commercial use  
\- \[Menu Selection Click\](https://opengameart.org/content/menu-selection-click) \- Free for non commercial use  
\- \[Imapct\](https://opengameart.org/content/2-high-quality-explosions) \- Free for non commercial use  
\- \[Projectile\](https://opengameart.org/content/4-projectile-launches) \- Free for non commercial use  
\- \[Gun Sound Effects\](https://opengameart.org/content/space-laser) \- Free for non commercial use  
    
The background music comes from an anime OST I like so much:  
\- \[BGM\](https://www.bilibili.com/video/BV1YB4y1P7Ra?spm\_id\_from=333.788.videopod.episodes\&vd\_source=3c66c0fe189e749594e5c140af965073\&p=3)

\*\*Describe the implementation of your audio system.\*\*  
The sound effects in the game are generated according to different scenarios:

\- \[Click ship module\](https://github.com/qxfan/com/blob/381386e821b9f867842a200f75f5f56e826e001b/scripts/ship\_design\_scene/ship\_blueprint\_designer.gd\#L265C1-L270C65): When the player selects a ship module in the design interface  
\- \[Click ship-building function\](https://github.com/qxfan/com/blob/381386e821b9f867842a200f75f5f56e826e001b/scripts/ship\_design\_scene/ship\_blueprint\_designer.gd\#L271C1-L273C79) When the player selects the ship-building function in the design interface  
\- \[Projectile\](/scenes/player/player.gd) When the player fires a projectile  
\- \[Damage received\](/scenes/player/player.gd) When the player receives damage

The background music needs to be played continuously between the design and combat scenes. To manage the sound effects and BGM, I created an \[audio\_manage\](/autoloads/audio\_manager.gd) script to manage the sound effects and background music.

\*\*Document the sound style.\*\*   
Sound style is very important for our game. Since our game is set in space, the sound styles I choose for combat are all from sci-fi sound effects. These sci-fi sounds are louder, so I chose softer soundtrack background music so that the sound effects will not be covered by the background music or too many sound effects at the same time, which will reduce the player's gaming experience.

#### Trailer / PressKit (Harshana Somas)
The trailer was created using Davinci Resolve. The presskit was created using static html files.

## Further Improvements and Fixes

#### Optimization

For the purpose of building larger ship systems and more complex force-interactions, Sam Herring ambitiously undertook a series of optimizations within his soft-body physics engine. We’d like to be able to generate more realistic and functional interactions to fully leverage the capabilities of the sim, but this is definitely something the team would need time to develop. 

#### Factory Simulation

The initial ideas for the game included a series of factory parts, of which many components are implemented in our game \- unused. We wanted to have more module complexity, with different modules passing resources between each other, and having those connections and pathways be susceptible to damage from the opponent. Furthermore, we wanted to do extensive styling and texture for these various components, with different structural parameters for different types of module. Within our assets, we even have images from Isabelle for the storage and conveyor belt modules, but unfortunately they were unable to be used. 

#### Theme

An interesting idea proposed by Sam at the beginning of the quarter was to style each different module based on different anatomical structures, and have the ships almost be alive, with veins or nerves denoting factory pathways, and bones or muscle denoting armor, etc. This was a really cool idea that we hope to implement after the quarter ends or sometime in the near future. 
