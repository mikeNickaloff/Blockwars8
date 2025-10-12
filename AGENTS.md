# General Guidelines for agents adding to this project

This is a Qt6.10 C++ (although written almost entirely in QML aka QtQuick)
This game is a dueling match-3 game where the player has the bottom grid, and the opponent has the top grid.
The two grids are separated when it comes to the match-3 logic. The bottom grid has blocks that rise up from below, while the top grid has
blocks which drop down from above. Blocks fill into the open spaces above them for the bototm grid and fill into open (empty) spaces beneath
for the top grid. 

The blocks do not fill in all the time. They should only fill in at key moments during the game play in a very specific maner under specific
conditions. All fill in actions should be animated and with a slight delay applied to each block that increases for every block that fills in when
the proper conditions are met and the fill in action is triggered for that grid. 

Here's the detailed Play-by-Play with detailed descriptions for the entire game (everything that should be in the game with some details referenced briefly
due to existing industry standards already in existence for a particular feature or detail:

## Play-by-Play

### Instructions for handling Play-by-Plays:
 A. Carefully read every detail from the play-by-play # you wish to implement
 B. Design a plan which contains which files must be added onto or modified in order to achieve all details for that number
 C. Once the plan is established, create a verbal summary of the changes you wish to make (files and description of code changes) in 1-3 sentences per file)
 D. First show the play-by-play # you are working on, followed by asking user (me) to approve each of the changes by showing a number and description for each file change to happen.
 E. For each approved set of changes, ensure that those changes are accurately reflected on the AGENTS.md play-by-play list if they deviate from the existing text by requesting for approval of change to AGENTS.md play-by-play #XX and showing what the new text for that will be once changed.
 F. If anything is not approved, please provide reasoning for that specific change and give 1 or 2 suggested alternatives for that which would still achieve the desired effect. 
 G. If the user approves one of the suggestions, make sure to update the AGENTS.md file play-by-play # with the new functionality and then implement the changes discusssed once everything is approved
 H. If user does not approve any suggestions, then ask for user to provide implementation details for that action and then follow the same procedure of approving the new changes and update the AGENTS.md with the new functionality when applicable. 
 I. Only do one play-by-play at a time, and skip any that are fully implemented already.

### Play-by-play items

### Main Menu (title screen)
1. The application opens revealing a Screen with the title Block Wars on the top 20% of the screen, centered on the X axis with the application
2. Beneath the Block Wars logo there are a few buttons: Single Player, Multiplayer, Powerup Editor, Options, and Exit.

### Powerup Editor
3. The player clicks on Powerup Editor which changes the entire screen (stackview) to the PowerupEditor scene which starts
   by showning a List View that displays the following choices: Create New, Edit Existing, Back to Main Menu
4. The player clicks on Create New which changes the page to the "Create Powerup" page which has a red button with an "X" on the 
   top-right which would essentially pop the stackview back one page. while the majority of the page is made of a few options to choose from in a form-like layout:
	 "Type" which has a Combobox and the options "Enemy" and "Self"
	 "Target" which is a combobox with "Blocks", "Hero(s)", and " Player Health"
	 "Color" which is a combobox with "Red", "Green", "Blue" and "Yellow"
	 "Next" which is a button at the bottom centered and larger than the rest of the page's components slightly.
5. Player chooses "Enemy", "Blocks" and "Green" then clicks "Next"
6. Next, another page transitions in which has the title "Select Blocks" because "Blocks" was chosen as the powerup type.
   The "Select Blocks" page contains a Game Grid (a 6x6 Grid Layout) with only Grey blocks, each one with clearly defined shadows for a simple 3d-ish effect.
	 Clicking on any of the blocks in the Game Grid will cause that individual block to change from Grey into a block matching the color chosen on the previous page
	 Clicking a colored blockw will change it back to Grey. 
7. Below the grid, there is a slider which goes from 1 to 20 idicating the amount of HP to add or remove to each block when the powerup is activated while in a game.
   Under the slider is a "Finish"
8. The player clicks "Finish" and the page returns to the Powerup Editor main scene. 
9. Clicking on "Edit Existing" Opens the "Choose Powerup" page to transition into view which contains a scrollable listview where each item is a card which has: a block
   matching that powerup's block color chosen during create powerup, the Type, the Target, the amount of damage, and if "Blocks" is chosen, the number of blocks selected.
	 There s also a final, separate box but still connected to the same card on the right-side which says: "Energy: <energy>"  where energy is the 
	 amount calculated by a special algorithm (number of targets * amount of HP * 0.5).
10. Clicking on any of the Powerup "Cards" will push the stackview to transition to a page identical to the "Create Powerup" page, only it will have all the values filled in 
   so that they match the selected Powerup card.  Clicking Next will take to the same page as the "Select Blocks" page if "Blocks" is chosen 
	 or just a slider from 0 to 100 if "Hero" or "Player/Enemy" is chosen instead of blocks for amount of damage / health to give/take
	 At the bottom is a "Save" button which overwrites the chosen powerup with the new values chosen from the two pages.
11. All powerup data is stored in the LocalStorage SQL Database feature that QML has built-in in JSON format and must contain all of the Player's Powerups in a table in a form that
   can be read by other parts of the same program.  
12. The player's Powerup is saved afte they click Save which returns them to the Powerup Editor main menu.
13. The player clicks on "Back to Main Menu" which transitions back to the Main Menu (title screen)

###	 Single Player (Player Vs. CPU)
14. The player clicks on Single player which transitions to the "Select Powerups" screen which is a screen containing four "Powerup Cards" arranged
  in a spaced column. each powerup card should have  with a mini layout within containing the details of the powerup chosen. 
	In the case where no powerup has been chosen for any card, a default "Blank" card will show that says "Select Powerup..." in a large button in the 
	center of the blank card. 
15. Clicking on "Select Powerup" will create an overlay Modal Box which has a scrollable list view of all the user's created powerups made from the Powerup Editor.
   There should also be a separator and beneath it should be 10 default powerups which will come shipped with he Game that players can choose from.
	 Clicking on any of the Powerup cards from the "Select Powerup" modal will hide the Modal Box and make the chosen Powerup Card's details shown in the chosen box
	instead of the "Blank card". 
16.  Clicking on the chosen card re-opens the Modal Box to choose a powerup (different or the same is ok) which updates that powerup.
17. on the Right side (arranged as a sort of sidebar next to the 4 Powerup cards) there should be a Large button (~15-20% of width) that is green and says "Ready!"
18. Clcking on "Ready" transitions to the Game Board screen.

#### Game Board
19. The Game Board screen starts off with two identical Layouts, one on the top half, the other on the bottom half of the page. The top layout is the "CPU Player"'s Dashboard
    The bottom layout is the "Player"'s Dashboard. 
		
##### Dashboard
20. A dashboard contains a progress bar at the top if on the top half of the screen or at the bottom if on the bottom half of the screen (essentially reflected about the X-axis)
21. Each dashboard also contains 4 rectangular cards oriented with spacing between them in a column along the ride side going from the top of the dashboard to the bottom spaced evenly.
    Each card also has a small horizontal progress bar (very tiny like only 8%-10% of the height of the card) with no letters or labels and the 
		background color of the progressbar should be black when empty and should be whatever color was chosen for the specific card which is directly above the bar. 
		This will represent the Energy which a player has accumulated thus far in the game (more on this in the Game Grid)
22. Each dashboard should have a large "Game Grid" which is where the match-3 game will be played. which is situated to the left of the Powerup Cards and should use about 80% of the available width and height of the dashboard

#### Game Board
23. When the Game Board first opens, it will say "Waiting for Opponent" in the center space between the two DashBoards (~7% of total height of Game Board)
24. in a Single Player game, the opponent is the CPU. 
25. Behind the scenes, the Javascript logic instantiates a new "CPU Player" object which will be able to send and receive information about the game via connected signals and slots both on the Game Board and the CPU Player
   which will be connected when needed. The CPU Player will choose 4 random powerups from the "default powerups" shipped with the game internally and save the powerup data into memory.
	 Once saved into memory, it will send a signal to the Game Board that essentially says "Set Powerup Data for Dashboard 0 (aka top)" to the followng: "<JSON object or array with powerup data for each of the four AI-chosen powerups>".
	 When the Game Board receives the signal to setup the Powerup Data from the CPU, it will send a signal with the: Dashboard #, the command "SetPowerupData", and the JSON data as the three args
	 The dashboard will receive this signal and update the four powerups shown on the Dashboard if the signal's Dashboard # matches with the Dashboard # of the receiving Dashboard. 
	 
26. The CPU's powerup cards are now visible ont he right side of the top Dashboard (Dashboard 0) and at the same time, a new instance of "Human Player" is instantiated and is connected to Dashboard 1 (bottom Dashboard)
    Human Player uses LocalStorage to lookup which Powerus were chosen by the Player ontehe "Select Powerups" page and then sends the same "SetPowerupData" signal with the Dashboard #, the command "SetPowerupData", and the JSON data for the Player's Powerups cards.
27. The Dashboard for the Player's cards are populated once the signal is received
28. Each Dashboard emits their own signal stating that "Powerups are Loaded" once they have fully parsed the JSON data and made it visible in alll four Powerup card slots. This signal should include the Dashboard # aand the Command "PowerDataLoaded". 
29. When the Game Grid receives the "PowerupDataLoaded" signal, it updates one of two hard coded properties:  powerupsLoaded0 and powerupsLoaded1 depending on Dashboard # it will set one of those to true.  By default both powerupsLoadedX properties of Game Board should be false.
30. After both dashboards emit PowerDataLoaded, the Game Board generates independent seeds (1–500) for each dashboard, applies them through each dashboard’s setSeed helper, and waits for the dashboards to acknowledge by emitting an indexSet command with the selected seed.
    with a random number between 1 and 500 which will define the index with which  block colors are chosen from out of a predefined pool of blocks included in a resource file loaded on startup and stored as a context property to allow quick and global access. The pool is a large dictionary of { <index>: <color> } pairs that pulls the block at an index each time a new block is needed
		so that blocks will have deterministic ordering every time to avoid issues with desyncing blocks and cheating and to minimize network traffic.  
31. Once each Dashboard gets the signal to set their pool index, the Dashboard sends a signal with Dashboard #, command "indexSet".
32. The Game Board receives the "indexSet" signal and updates the properties "indexSet0 or indexSet1" and runs the "checkIndexSet()" function 
33. If the checkIndexset() function returns both indexSetN are true, then runs the "initializeGame()" function. 
34. Game Board's "intiailizeGame()" function connects the the "setSwitchingEnabled" signal to go to each dashboard with the Dashboard # and true/false for the two params.
    It also connects the Game Board's "setFillingEnabled", "beginFilling", "turnEnded", "beginTurn", "setLaunchOnMatchEnabled" and "activatePowerup" signals to both Dashboards, each one having parameters for Dashboard # and either true/false or slot # for powerups oor other parameters if relevant
35. Once the connections are made, the game can begin. To start the game, the signal "chooseRandomNumber" will be connected to both the CPU player's instance and the "Human player"'s insance created earlier.
36. Game Board wills send the chooseRandomNumber signal which will be received by both players, and each player (whether CPU, human, or network player) will respond to that signal with a random number between 1 and 5000000. 
    The player with the highest number response is first. If both players have the same number, another signal is sent out.  The player's responses are in the form of a signal "randomNumberChoice" which will have the Dashboard # and the number as arguments and be handled by a function on GameBoard that checks to see if two properties are set and
		compares them once they are both not -1 (the default). Property names are randomNumber0 and randomNumber1.
37. At the start of each turn, the active dashboard receives "setFillingEnabled" true and "setLaunchOnMatchEnabled" true (plus a fresh "beginFilling" command), while the defending dashboard is told "setFillingEnabled" false and "setLaunchOnMatchEnabled" false so its blocks remain frozen until the attacker finishes cascading.
38. GameBoard will have a queue system where every command will need to be enqueued and sent in order to both players, each command having a UUID generated.
39. Launching blocks of any color will add energy to the attacker's powerup cards that share the launched block color equal to the launched block's HP; fully destroyed defender blocks also donate their remaining HP as energy to any of the attacker's powerups matching the destroyed block colors. (Example: launching three red blocks with 5 HP each that destroy two green blocks and one yellow block—each 5 HP—grants +15 red energy, +10 green energy, and +5 yellow energy to the corresponding powerup cards.)
40. When a Powerup card reaches 100% of its required energy, its border flashes on a slow interval to indicate it is fully charged; while flashing it no longer accumulates additional energy until the player activates that powerup.


##### Game Grid / Game Board / (Human/CPU/Network) Player interaction
43. When one of the players receives the signal to queue a command, it will send a signal back with the UUID stating that the signal has been received and queued. 
44. Game Board will track via multi-dimensional array of queue objects that contains UUID and whether or not each player has ACK'd the queue object and whether or not each Player has executed the command given (which will be executed in order one event at a time and then an EXEC signal willl be sent as that queued event completes from the Player instance)
45. Once an event in the queue has been ACK'd, the Game Board is free to enqueue / proceed to the next event in the game play for certain commands, while others will require that the Player has executed the entire command before queueing another event. 
46. Events like setFillingEnabled, turnEnded, etc all have various different timing requirements and must fully execute in order to prevent issues with Multiplayer "Network Players" who will have latency as a constant factor and trouble spot for synchronization failures
47. Once both Players have successfully executed beginFilling, then GameBoard will send a different signal the Dashboard which will instruct it to "BeginFilling" or "setLaunchOnMatchEnabled" etc along with the Dashboard #
48. There must be an association between the Player instance and the Dashboad in order to properly keep the games in sync and the messages to the right places. The two objects are separate, but must work together with the Game Board and stay coordinated across all for both players but cannot be simultanous, they must communicate in specific order when it comes to high level commands.
49. When a Dashboard gets a signal to "beginFilling" it will first drop any blocks already in the grid all the way to the side closest to the center of the entire Application window (GameBoard) -- for the Top Dashboard that would be the lowest cells on the Game Grid, for the bottom Dashboard that would be the top cells on the Game Grid. 
50. Blocks can only have one block per cell in the 6x6 Game Grid which each Dashboard has. Once all blocks have completely filled in the Game Grid so that no floating gaps exist between the end of the grid closest to the other player and all blocks currently on that Game Grid, then by going one row at a time, from left to right, one block at a time, create a new block by increasing (or resetting to 0 when at max) the POOL index for this Dashboard and then grabbing the color at the new index
    and instantiated a new Block.qml instance one cell bbefore the closest cell to the "player health" (we will call this cell -1) and it will be positioned in the current column being iterated. When blocks have been created in each column which still has an empty space, then the GameGrid will internally execute the "compressBlocks" function which sets the block's Y position to be at the target cell it will end up being when compressed.
		
##### Blocks
51. Blocks have Behavior attachments that will control their animations that execute "processAnimation" functions which determine the block's state (matched, powering up, taking damage, colliding, launching, airborn, exploding, filling, waiting, or dead, maybe others later?) and load sprite sheets depending on what action they are doing.
52. Spritesheets exist already which show blocks powering up for launch and transforming into projectiles so that they can load one spritesheet for the entire process of matching, launching, airborn,and colliding.  exploding is a separate animation that uses particles which have to be fed to a ParticleSystem overlay via signals and clever mapping of positions. an example Block.qml is included in this file for reference from an older version of the same game.
53. Blocks also must detect mouse events for switching when enabled, so they must be updated as to whether they are allowed to be interacted wth or not by the Game Grid

##### Game Board
54. Once the BeginFilling signal has been received by the GameGrid, then it will change the GameGrid's current state to "fill". 
55. Whenever the GameGrid's state changes into "fill", it will activate the "fillTimer"
56. The fillTimer's job is to periodically check to see if Row 0 has any cells which are null or undefined in the array that stores the Block instances for the GameGrid.
57. When a column in row 0 has an empty or undefined position, create a new Block instance at position Row -1 in the column that was checked. 
58. Once all columns have been checked and all columns with empty cells in row 0 have been identified and a new Block spawned, set all Block instances in row -1 to be in row 0 (which should update their y value as well to initiate the animation)

##### Block
59. Block should have a Behavior on y { SequentialAnimation } Behavior which executes a ScriptAction { } first that sets the "inAnimation" property to true for the Block instance and a ScriptAction { } after the NumberAnimation {} which sets the inAnimation to false.

##### Game Board
60. Whenever fillTimer should also have an early exit condition where it checks all Block instances for this GameGrid instance to see if any of them have "inAnimation" set to true
57. If any Blocks have inAnimation which are set to true, then return and do not continue to process until all Blocks which are not null have inAnimation set to false.
58. Once All Block instances for GameGrid have inAnimaton == false, change this GameGrid's state to "compact"
59. Compact mode will activate the "compactTimer" which checks for any blocks with inAnimaton == true and returns if  it finds any, othewise it will check each column for each row starting at the 5th row and then check to see if the 6th row in that same column has a Block or if it is null/unidefined.
60. If the row directly below a cell with a Block in it exists, then assign that Block to have occupy the empty cell.
61. The CompactTimer only moves down one cell per interval to keep things neat.
62. Once all Blocks are either at the last row or have another Block beneath them and no Block have inAnimation == true on this GameGrid, then change state to "fill"
63. Changing to fill state activates the fillTimer and steps 51-63 are repeated until the fillTimer does not have any cells in row 0 which are null or undefined and no Blocks have inAnimation == true. Once the loop ends, change the GameGrid state to "match"
64. When in match state, the matchTimer will first check for any blocks with inAnimation == true and return early if it finds any. Next it will search for any rows which have empty cells (null or undefined instead of Block instance), if so then change GameGrid state to "compact". 
65. After the preliminary checks pass, matchTimer's function will scan the rows for any row containing 3 or more of the same color all connected without any other colors in between them. Each of these Blocks will be added to the "matchList".
65. Next it will do the same for each column and add those blocks to the "matchList" should they not already be in the list.
66. If matchList is not empty, matchTimer will change the Game Grid state to "launch" and disable matchTimer.  If matchList is empty, change Game Grid state to "idle" and then send signal "cascadeEnded" which will be used to determine when a player's turn has ended after they make a move and when to enable swaps / powerups etc.
67. When the state is "launch" for Game Grid, the launchTimer will take the first Block from matchList if the list is not empty and call the .launch() function which will activate the launch process.  This function will also add 1 to the launchCount property of GameGrid
68. Once matchList is empty, check to see if launchCount > 0. If lauchCount > 0, return. If launchCount =< 0 change Game Grid state to "compact"

69. Whenever the signal to switch blocks occurs (qml: game grid got event request {"event_type":"swapBlocks","row1":2,"row2":2,"column1":5,"column2":4,"grid_id":1}), the grid where the blocks are switched on will always change the GameGrid state to "match"
70. The standard match, launch, compact, fill, match, launch, compact, fill infinite loop will occur where the GameGrid is changed from state to state using the aready defined timers.
71. When the GameGrid is in "match" state and does not find any matches, it will check to see if the GameGrid has  any swaps left to make from their allotment of 3 swaps per turn.  
72. If match has no matches, and the GameGrid blocks are not animating, then  this point the swaps remaining is 0 issue a signal to the other Game Grid stating that the turn has been ended for this Game Grid which in turn results in Cascading being disabled for this Game Grid as well as swapping being disabled. 
73. once the signal is sent informing that a Game Grid has finished their turn, the other Game Grid instance should detect that signal and enable cascades. 
74. After enabling cascades on the opponent Game Grid, the opponent Game Grid state should be set to compact which will trigger the infite loop system of compact, fill, match, launch, compact, fill, match, launch, and on and on.
75. Also, the opponent Game Grid should be given 3 swaps that they can make, and enable swapping once the Game Grid is in match state and has no mathes and no animations happening, which will be available to be used by the CPU (or remote player) depending on who the other player is. 
76. Once its the opponent's turn and their grid has completed at least one full cascade (or more depending on if any matches come up during the match state), but once the cascade is completed, then the CPU's Game Grid should be set to allow swaps to happen. 
77. The CPU Player will be sent a signal to make one move, which will cause the CPU player object to request the block data from the Game Grid, which will show all the available blocks on Game Grid 1 to the CPU by sending a signal containing the block data (row, col, color) for all blocks.
78. The CPU player will iterate through each grid position, searching each possible direction that the block can swap (up down left or right) and then check to see if there are any 3+ in a row or column when making that switch.  Once it finds a valid swap, it sends a signal to GameGrid 1 to make that swap then waits until cascading finishes (using timers) from that move and decrease moves remaining by 1 
79. Once cascading finished and sends the cascade finished signal, then the CPU will check to see if it has any moves remaining (out of its 3 moves), it will proceed to find a swap and make it 
80. After all 3 CPU swaps are made and all cascades are fully completed, then endTurn signal is sent which is picked up by Game Grid 0, which then cascades its blocks starting with comact and continuing on matching and launching etc (using timers) until no matches exist when the state changes to "match" at which point Game Grid 0 unlocks and swaps are allowed for Game Grid 0. 

##### Game Board / Powerups
81. When the active player still has swaps remaining, both grids are idle, and at least one of their four powerup cards is fully charged, that player may drag a charged card from the Powerup HUD onto any empty-friendly cell (never onto the opponent's grid) to deploy the powerup instead of performing a swap.
82. Dropping a powerup onto the board replaces the two horizontal blocks beneath it with the powerup entity; those cells are no longer considered matchable blocks for the purposes of the match-3 rules.
83. Each powerup card may be dragged onto its owner's grid at most once per game; up to four powerups can be deployed sequentially provided no cascades are active, the player still has swaps remaining, and no other powerup ability is firing.
84. Deploying a powerup card immediately resolves its ability using the stored powerup data (target owner, affected type, HP adjustments, and block selection); block targets either lose or gain health (including deployed powerup cards) according to the ability's color/amount and target rules.
85. After a powerup ability fires, that powerup card's current charged energy resets to 0 and must be recharged again up to the powerup card's energy level property by matching, but the deployed powerup tile remains on the grid permanently.
86. Clicking on a Powerup Card from the PowerupHud when that card has alreeady been deployed to the Game Grid, if the player has more than 0 swaps available and the Game is not in a cascading state (fill, match, launch, compact), if the Powerup Card that was clicked on is fully charged, then it will activate the Powerup Card's ability and reset that Powerup Card's charged energy back to 0.
87. Anytime a Powerup Card is activated and the powerup is targetting Blocks on either player's grid, the blocks which are affected will either show an explosion if the block is destroyed  in the process, display a temporary glowing affect if the block gains HP, or a small shake animation where the block just jitters for a half second if the block is damaged but not destroyed. 


## Coding guidelines

Make sure data is flowing to everywhere that might need to consume it and acknowledgement of that data is critical in order to gate how fast the next process runs. 

** NOT ALL DATA will go through the same path -- it all depends on what data needs to be accessed / notified / updated at the specific time / conditions **


### Example: 

Getting fill status of opponent grid might have the following signal / function data flow if called from a LocalGridController### Powerup Editor

LocalGridController:signal -> GameFlowController:function  -> GameFlowController:signal -> OtherGameBoardController:fuction -> OtherGameBoardController:signal -> GameFlowController:function -> GameFlowController:signal -> OriginalGameBoardController:function




### Important 

This data flow is critical as it will ensure correct ordering by building a callback graph otherwise everything happens out of order.

Make sure to use the same type of connection paths for any new functionality when involving non-deterministic situations where one
part of the code might be taking longer 

Use NetworkControllers functions to interact with C++ instance controlling the network connection backend so as not to expose the actual C++ instance outside of the network controller wich will only have functions to interact with the C++ side (trying to keep bugs to a minimum here)

## Game Rules / Details

1. Both players start off with 2 complete grids of blocks which have no instances of 3 matching blocks of the same color either horizontally or vertically (adjacently) anywhere on their Game Grid 
2. One player is attacking, the other defending.  
3. The attacking player's GameGrid is allowed to switch any block with another block that is directly adjacent to it as long as making that switch will result in 3 blocks all of the same color being adjacent to each other either horizontally or vertically
4. after the switch is made, the Game Grid does not accept input or switches temporarily, but will clear any matches, launch those blocks, and after launching all blocks, will fill in the empty spaces by dropping blocks down to fill in (or raiing blocks up depending on orientation) and continue to infinitely cascade and launch any matches that occur, followed by a fill in until no matches exist. This is where the "switch move ends" and if a player has more than 0 switches remaining, the board will now unlock and let them switch again as long as all cells have a block in them and no match-3 matches are pressent and no block launch animations are in progress. 
5. All blocks that are 3 or more in a row or column and next to each other without any other blocks of different color in between will begin the launch animation which ultimately causes the blocks to be launched at the opponent's GameGrid
6. All matches will be launched and all animations (explosion on the opponent's game grid will fully complete, and at which point all remaining blocks on the attacker's GameGrid will fill by dropping down (or rising up) depending on the orientation of the GameGrid so that there are no floating blocks (blocks with spaces beneath them where blocks have launched after matching)
7. Once all blocks have fully filled in all spaces beneath them, then blocks will be pulled from a predetermined poool of blocks in order and drop in from the above the grid simultanously (or in rapid succession) until all of the GameGrid rows and columns (cells) have one block in them.
8. Once the GameGrid is full, then the process of checking for matches and launching any matches occurs again, followed by the waiting for launch animations and then filling in and finally refilling of blocks. 
9. The whole process will repeat and continuously launch blocks at the enemy until there are no 3-in-a-line matches anywhere on the attacker's GameGrid and the game grid has no blocks in every cell with no active animations (no launches) happening.
10. once there are no further matches, animations, or empty cells, then the game move is complete. The attacker's gamegrid will accept input again and then the attacker can make another switch which will kick off the whole process again from steps 4 thru 9.
11. Each player gets 3 moves, then after the moves and animations are fully completed, and the attacker's board is filled in, the attacker becomes the defender. 
12. When defending, the defender's GameGrid does not fill in blocks.  Blocks just stay in position and are destroyed by the attacker's launched blocks. After the attacker completes all 3 moves and all animations etc have completed, and their grid is completely filled in with no matches or launches happening, then the defender's board will fill in and launch any matches, followed by the fill in / check matches / launch matches / fill in loop
13. Once the defender's board is fully filled in with no more animatons or matches, then now the defender becoems the attacker and attacker becomes defender, repeating the entire process forever until one player's life reaches 0.
14. Life is taken from a player when all of their blocks in a column  are destroyed (which is controlled by the amount of power the blocks have when launched versus the amount of power each block has when hit by the launch).  When all blocks on a defender's grid are destroyed, any additional blocks in that column launched will damage the player directly. 
15. Blocks can be damaged and powered up by Powerups. Powerups can be customed to damage enemy blocks or players,  or can be setup to grant power to blocks either by color or by pre-selecting specific cell locations to power up or damage on either their own grid or the enemy grid. Powerups each have a color that matches one of the game colors which can be chosen as well. 
16. Depending on how much power the powerup is calling on (more blocks affected * more power amount = more required energy), each player will have to match blocks of the same color as that powerup in order to charge up its temporary magic energy before the Powerups can be used.  
17. The amount of damage done to an opponent's blocks or directly to the player is converted directly into energy of the color of the block that was launched.  
18. Launching a yellow block with 10 power that destroys 2 green blocks with 5 points each would result in 10 yellow energy being added to all yellow Powerups
19. Once a powerup reaches the amount of required energy, it can be activated by dragging it onto the gamegrid from the powerup hud and placed on the board (only for the first activation). 
20. Once on the board, it can be damaged by enemy blocks or enemy powerups just like any other block with its health being equivalent to its max energy to start. Powerups are not counted towards match-3 matches, and always are considered not matching color despite them possibly havig the same colors as other blocks or powerups. 
21. Powerups can move one square in any direction but it costs one move to do so. 
22. When powerups are activated, their magic energy is set to 0 and must be refilled before they can activate again.  
23. once killed, Powerups cannot be revived and will disappear from the board like any other block. 
24. Powerups should not drop down with the other blocks that fill in.  Their position should remain static and blocks should merely skip over them and consider cells with powerups to be occupied and blocks should continue on past them or stop if there are no empty spaces beneath the powerups.
25. Hitting a defender's powerup with a launched block or  other powerup attack will cause the powerup to be moved from its static position down to the lowest empty space on the defender's GameGrid. This is to allow for powerups to be pulled out of defensive positions behind many blocks to break up defensive positions. 
26. Activating a powerup does not use a move.
27. Powerups can only be activated or moved when attacking, never while defending. 





#### Old Block.qml Reference File
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQml.Models 2.15
import "../models"
import QtMultimedia 5.5
import QtQuick.Controls 2.0
import "../constants" 1.0
import "../actions" 1.0
import "../stores" 1.0
import QuickFlux 1.1
import "../zones" 1.0
import QtQuick.LocalStorage 2.15
import "../controllers" 1.0
import "../components" 1.0
import "." 1.0

Item {

    id: block
		objectName: "Block"
		property var uuid: 0
		property var column
		property var row
		property var grid_id: 0
		property var block_color: "blue"
		property var isAttacking: false
		property var isMoving: true
		property var hasBeenLaunched: false
		property var block_health: 5
		Rectangle {
		    anchors.fill: parent
				color: block_color
				border.color: "black"
				border.width: 2
				}
		signal animationStart
		signal animationDone
		signal rowUpdated(var row)
		onRowChanged: {
		    //   console.log("Updating row for", block.row, block.column)
				debugText.text = block.row + "," + block.column + "," + block.block_health
				rowUpdated(row)
				}
		Behavior on y {
		    SequentialAnimation {
				    ScriptAction {
						    script: {
								    block.animationStart()
										AppActions.enableBlocks(grid_id, false)
										}
								}
						NumberAnimation {
						    duration: 100 + ((6 - row) * 75)
								//duration: 100
								}
//            NumberAnimation {
//                duration: 100 + ((6 - row) * 105)
//                 duration: 50 * (6 - row) + 150
//            }
            ScriptAction {
						    script: {
								    block.animationDone()
										}
								}
						}
				}

    /* functions */
		function launch() {
		    loader.sourceComponent = blockLaunchComponent
				isAttacking = true
				block.hasBeenLaunched = true
				launchCompleteReportTimer.start()
				}
		Timer {
		    id: launchCompleteReportTimer
				interval: 150 + (block.row * (15 * 6)) + (block.column * 15)
				triggeredOnStart: false
				onTriggered: {
				    AppActions.blockLaunchCompleted({
						                                    "row": block.row,
																								"column": block.column,
																								"grid_id": grid_id
																								})
																						}
				repeat: false
				running: false
				}

    /* components */
		Component {
		    id: blockIdleComponent
				Rectangle {
				    color: "black"
						border.color: "black"
						anchors.fill: parent

            Image {
						    source: "qrc:///images/block_" + block_color + ".png"
								height: {
								    return block.height * 0.90
										}
								width: {
								    return block.width * 0.90
										}

                id: blockImage
								asynchronous: true

                sourceSize.height: blockImage.height
								sourceSize.width: blockImage.width
								anchors.centerIn: parent
								visible: true
								}
						Text {
						    id: debugPosText
								text: block.uuid
								horizontalAlignment: Text.AlignHCenter
								font.pointSize: 22
								anchors.centerIn: parent
								anchors.fill: parent
								visible: false
								}
						}
				}

    Component {
		    id: blockLaunchComponent

        AnimatedSprite {

            id: sprite
						anchors.centerIn: parent
						height: {
						    return block.height * 0.90
								}
						width: {
						    return block.width * 0.90
								}
						z: 9999
						source: "qrc:///images/block_" + block_color + "_ss.png"
						frameCount: 5
						currentFrame: 0
						reverse: false
						frameSync: false
						frameWidth: 64
						frameHeight: 64
						loops: 1
						running: true
						frameDuration: 100
						interpolate: true

            smooth: false
						property var colorName: block_color

            onColorNameChanged: {
						    sprite.source = "qrc:///images/block_" + colorName + "_ss.png"
								}

            onFinished: {


                /*  ActionsController.armyBlocksRequestLaunchTargetDataFromOpponent(
								            {
														    "orientation": block.orientation,
																"column": block.col,
																"health": block.health,
																"attackModifier": block.attackModifier,
																"healthModifier": block.healthModifier,
																"uuid": block.uuid
																}) */
														var globPos = block.mapToGlobal(block.height / 2,
														                    block.width / 2)

                AppActions.particleBlockLaunchedGlobal({
								                                           "grid_id": block.grid_id,
																													 "x": globPos.x,
																													 "y": globPos.y
																													})
																											AppActions.blockLaunchCompleted({
																											"row": block.row,
																										"column": block.column,
																										"grid_id": grid_id,
																										"damage": block.block_health,
																										})

                block.y = 12 * (block.height)
								block.z = 999
								loader.sourceComponent = blockExplodeComponent

                // explode()
								}
						}
				}

    Component {
		    id: blockHealthGainComponent

        AnimatedSprite {

            id: sprite
						anchors.centerIn: parent
						height: {
						    return block.height * 0.90
								}
						width: {
						    return block.width * 0.90
								}
						z: 9999
						source: "qrc:///images/block_" + block_color + "_ss.png"
						frameCount: 5
						currentFrame: 0
						reverse: false
						frameSync: false
						frameWidth: 64
						frameHeight: 64
						loops: 1
						running: true
						frameDuration: 100
						interpolate: true

            smooth: false
						property var colorName: block_color

            onColorNameChanged: {
						    sprite.source = "qrc:///images/block_" + colorName + "_ss.png"
								}

            onFinished: {


                /*  ActionsController.armyBlocksRequestLaunchTargetDataFromOpponent(
								            {
														    "orientation": block.orientation,
																"column": block.col,
																"health": block.health,
																"attackModifier": block.attackModifier,
																"healthModifier": block.healthModifier,
																"uuid": block.uuid
																}) */
														var globPos = block.mapToGlobal(block.height / 2,
														                    block.width / 2)

                AppActions.particleBlockLaunchedGlobal({
								                                           "grid_id": block.grid_id,
																													 "x": globPos.x,
																													 "y": globPos.y
																													})

                loader.sourceComponent = blockIdleComponent

                // explode()
								}
						}
				}

    Component {
		    id: blockExplodeComponent

        AnimatedSprite {
				    id: sprite
						width: block.width * 4.5
						height: block.height * 4.5

            anchors.centerIn: parent
						z: 7000


            /*source: "qrc:///images/" + block_color + "_killed_ss.png"
						frameCount: 20
						frameWidth: 128
						frameHeight: 70 */
						source: "qrc:///images/block_die_ss.png"
						frameCount: 5
						frameWidth: 178
						frameHeight: 178
						//            source: "qrc:///images/explode_ss.png"
						//            frameCount: 20
						//            frameWidth: 64
						//            frameHeight: 64
						reverse: false
						frameSync: true

            loops: 3
						running: true
						frameDuration: 50
						interpolate: true

            smooth: true

            onFinished: {

                //console.log("Block destroyed", block.uuid)
								if (block.isAttacking == true) {
								    block.hasBeenLaunched = true
										var globPos = block.mapToGlobal(block.height / 2,
										                                block.width / 2)
																										AppActions.particleBlockKilledExplodeAtGlobal({
																										                  "grid_id": grid_id,
																																			"x": globPos.x,
																																			"y": globPos.y
																																			})

                       block.opacity = 0
											//   updatePositions()

                    // block.row = -20
										loader.sourceComponent = blockDebrisComponent
										// block.destroy()
										} else {
										hasBeenLaunched = true
										var globPos = block.mapToGlobal(block.height / 2,
										                                block.width / 2)

                    AppActions.particleBlockKilledExplodeAtGlobal({
										                                                  "grid_id": grid_id,
																																			"x": globPos.x,
																																			"y": globPos.y
																																			})

                    //  block.opacity = 0
										// block.row = -20
										loader.sourceComponent = blockDebrisComponent

                    //updatePositions()
										}

                block.opacity = 0
								//block.isBeingAttacked = false
								//block_color = armyBlocks.getNextColor(block.col)

                // updatePositions()
								//block.removed(block.row, block.col)
								// block.destroy()
								}
						}
				}

    BlockLaunchParticle {
		    id: launchParticleController
				z: 5001
				anchors.centerIn: block
				width: 20
				height: 20
				}

    Component {
		    id: blockDebrisComponent

        AnimatedSprite {
				    id: sprite
						width: block.width * 4.5
						height: block.height * 4.5

            anchors.centerIn: parent
						z: 7000

            source: "qrc:///images/" + block_color + "_killed_ss.png"
						frameCount: 20
						frameWidth: 128
						frameHeight: 70


            /*source: "qrc:///images/block_die_ss.png"
						frameCount: 5
						frameWidth: 178
						frameHeight: 178 */
						//            source: "qrc:///images/explode_ss.png"
						//            frameCount: 20
						//            frameWidth: 64
						//            frameHeight: 64
						reverse: false
						frameSync: true

            loops: 1
						running: true
						frameDuration: 50
						interpolate: true

            smooth: true

            onFinished: {
						    launchParticleController.disableEmitter()

                particleController.burstAt(block.x, block.y)
								//console.log("Block destroyed", block.uuid)
								block.isMoving = false
								if (block.isBeingAttacked == false) {

                    var globPos = block.mapToGlobal(block.height / 2,
										                                block.width / 2)
																										block.destroy()


                    /* AppActions.blockLaunchCompleted({
										                                    "uuid": block.uuid,
																												"row": block.row,
																												"column": block.col,
																												"grid_id": grid_id
																												})

                    block.destroy() */
										} else {
										AppActions.blockKilledFromFrontEnd({
										                                       "grid_id": grid_id,
																													 "uuid": block.uuid,
																													 "row": block.row,
																													 "column": block.column
																													})

                    //block.opacity = 0
										//block.row = 0
										block.hasBeenLaunched = true
										//loader.sourceComponent = blockIdleComponent
										// updatePositions()
										block.destroy()
										}

                //block.opacity = 0
								//block.isBeingAttacked = false
								//block_color = armyBlocks.getNextColor(block.col)

                // updatePositions()
								//block.removed(block.row, block.col)
								// block.destroy()
								}
						}
				}

    Item {
		    width: block.width
				height: block.height
				Loader {
				    id: loader
						width: block.width
						height: block.height
						sourceComponent: blockIdleComponent

            onLoaded: {

            }
						}
				Text {
				    id: debugText
						color: "white"
						text: block.row + "," + block.column
						}
				AppListener {
				    filter: ActionTypes.enableBlocks
						onDispatched: function (a, b) {
						    if (b.grid_id == grid_id) {
								    blockMouseArea.enabled = b.blocks_enabled
										}
								}
						}
				MouseArea {
				    property var mouse_start_x: 0
						property var mouse_start_y: 0
						property var direction: "none"
						id: blockMouseArea
						anchors.fill: parent
						onPressed: {
						    if (enabled) {
								    mouse_start_x = blockMouseArea.mouseX
										mouse_start_y = blockMouseArea.mouseY
										}
								}
						onMouseXChanged: {
						    if (enabled) {
								    var dx = mouse_start_x - blockMouseArea.mouseX
										var dy = mouse_start_y - blockMouseArea.mouseY
										if (Math.abs(dx) > Math.abs(dy)) {
										    if (Math.abs(dx) > (block.width * 0.7)) {
												    if (dx > 0) {
														    console.log("move left")
																if (block.column > 0) {
																    direction = "left"
																		} else {
																		direction = "none"
																		}
																}
														if (dx < 0) {
														    if (block.column < 5) {
																    direction = "right"
																		} else {
																		direction = "none"
																		}
																}
														} else {
														direction = "none"
														/* no movement */
														}
												} else {

                    }
										}
								}
						onMouseYChanged: {
						    if (enabled) {
								    var dx = mouse_start_x - blockMouseArea.mouseX
										var dy = mouse_start_y - blockMouseArea.mouseY
										if (Math.abs(dx) < Math.abs(dy)) {
										    if (Math.abs(dx) < (block.height * 0.7)) {
												    if (dy > 0) {
														    if (block.row > 0) {
																    direction = "up"
																		} else {
																		direction = "none"
																		}
																}
														if (dy < 0) {

                                if (block.row < 5) {
																    direction = "down"
																		} else {
																		direction = "none"
																		}
																}
														} else {
														direction = "none"
														/* no movement */
														}
												} else {

                    }
										}
								}
						onReleased: {
						    if (enabled) {
								    console.log("Moved", direction)
										if (direction != "none") {

                        AppActions.swapBlocks(block.row, block.column, grid_id,
												                      direction)
																							}
										}
								}
						}

        DropZone {
				    property alias row: block.row
						property alias column: block.column
						grid_id: block.grid_id
						id: powerupDropArea
						anchors.fill: parent
						onEntered: {
						    console.log("Draggable object entered drop area",
								            Drag.source.x, Drag.source.y)
														drag.source.x = parent.x
								drag.source.y = parent.y
								drag.source.width = parent.width
								drag.source.height = parent.height


                /*drag.source.anchors.left = parent.left
								drag.source.anchors.right = parent.right
								drag.source.anchors.top = parent.top
								drag.source.anchors.bottom = parent.bottom */
								}
						onDropped: {
						    // Calculate nearest grid block position
								var closestX = parent.x
								var closestY = parent.y

                // Position the rectangle to overlay the nearest block
								drag.source.x = closestX
								drag.source.y = closestY
								drag.source.width = parent.width
								drag.source.height = parent.height
								drag.source.parent = parent
								}
						}
				AppListener {
				    filter: ActionTypes.setBlockProperty
						onDispatched: function (evt, a) {
						    if (a.grid_id == block.grid_id) {
								    if (a.row == block.row) {
										    if (a.col == block.column) {
												    switch (a.propName) {
														case "block_color":
														    if (a.propValue == -1) {
																    block.block_color = "orange"
																		}
																if (a.propValue == -2) {
																    block.block_color = "purple"
																		}
																if (a.propValue == -3) {
																    block.block_color = "pink"
																		}
																if (a.propValue == -4) {
																    block.block_color = "cyan"
																		}
																if (a.propValue >= 0) {
																    block.block_color = a.propValue
																		}
																return
																default:
																return
																}
														}
												}
										}
								}
						}
				AppListener {
				    filter: ActionTypes.modifyBlockHealth
						onDispatched: function (atype, a) {
						    console.log("Block received modifyBlockHealth Dispatch",JSON.stringify(a));
								if (a.grid_id == block.grid_id) {
								    if (a.row == block.row) {
										    if (a.column == block.column) {
												    block.block_health = a.amount

                                if (block.block_health < 1) {
																    block.isAttacking = false
																		block.opacity = 0;
																		block.block_health = 0;
																		loader.sourceComponent = blockExplodeComponent
																		block.destroy();
																		}

                        }
												}
										}
								}
						}
				}
}


### BlockLaunchParticle.qml-- old version

import QtQuick 2.4
import QtQuick.Particles 2.0
import "."

Item {
    objectName: "Particle scene"
		width: parent.width
		height: parent.height
		id: launchController

    function burstAt(xpos, ypos) {
		    flashEmitter.lifeSpan = 2600
				flashEmitter.burst(65, xpos, ypos)
				}
		ParticleSystem {
		    id: particleSystem
				anchors.fill: parent
				}
		function enableEmitter() {
		    flashEmitter.enabled = true
				}
		function disableEmitter() {
		    flashEmitter.enabled = false
				}
		ImageParticle {

        objectName: "FlashParticle"
				groups: ["FlashParticles"]
				source: "qrc:///images/particles/particle.png"
				// color: "#00aaff"
				colorVariation: 0
				alpha: 0.7
				alphaVariation: 0
				redVariation: 0
				greenVariation: 0
				blueVariation: 0
				rotation: 0
				rotationVariation: 0
				autoRotation: false
				rotationVelocity: 0
				rotationVelocityVariation: 0
				entryEffect: ImageParticle.Scale
				system: particleSystem
				}

    ImageParticle {
		    objectName: "FlashTracer"
				groups: ["FlashParticles"]
				source: "qrc:///images/particles/star.png"
				// color: "#aaffff"
				colorVariation: 0
				alpha: 0.5
				alphaVariation: 0
				redVariation: 0
				greenVariation: 0
				blueVariation: 0
				rotation: 0
				rotationVariation: 0
				autoRotation: false
				rotationVelocity: 0
				rotationVelocityVariation: 0
				entryEffect: ImageParticle.Scale
				system: particleSystem
				}

    Emitter {
		    id: flashEmitter
				objectName: "FlashEmiter"
				x: 0
				y: 0
				width: 20
				height: 20
				enabled: false
				group: "FlashParticles"
				emitRate: 30
				maximumEmitted: 75
				startTime: 0
				lifeSpan: 800
				lifeSpanVariation: 0
				size: 30
				sizeVariation: 1
				endSize: 16
				velocityFromMovement: 63
				system: particleSystem
				velocity: PointDirection {
				    x: 7
						xVariation: 60
						y: 0
						yVariation: 35
						}
				acceleration: PointDirection {
				    x: 1
						xVariation: 27
						y: 0
						yVariation: 21
						}
				shape: EllipseShape {
				    fill: true
						}
				}

    Gravity {
		    objectName: "GravityBox"
				x: 0
				y: 0
				width: 180
				height: 180
				enabled: true
				groups: []
				whenCollidingWith: []
				once: false
				angle: 90
				magnitude: 153
				system: particleSystem
				}
}



#### BlockExplodeParticle.qml -- old version - for reference

import QtQuick 2.4
import QtQuick.Particles 2.0

Item {
    objectName: "Particle scene"
		width: parent.width
		height: parent.height
		property var system
		function burstAt(xpos, ypos) {
		    boomEmitter1.burst(1, xpos, ypos)
				smokeEmitter1.burst(10, xpos, ypos)
				boomEmitter2.burst(1, xpos, ypos)
				emberEmitter1.burst(15, xpos, ypos)
				}
		ParticleSystem {
		    id: particleSystem
				}

    ImageParticle {
		    objectName: "ember1"
				groups: ["ember1"]
				source: "qrc:///images/particles/ember_mid.png"
				color: "white"
				colorVariation: 0
				alpha: 1
				alphaVariation: 0
				redVariation: 0
				greenVariation: 0
				blueVariation: 0
				rotation: 0
				rotationVariation: 47
				autoRotation: false
				rotationVelocity: 0
				rotationVelocityVariation: 0
				entryEffect: ImageParticle.Fade
				system: particleSystem
				}

    ImageParticle {
		    objectName: "boom1"
				groups: ["boom1"]
				source: "qrc:///images/particles/boomboom.png"
				color: "#ffc4a3"
				colorVariation: 0
				alpha: 0.9
				alphaVariation: 0
				redVariation: 0
				greenVariation: 0
				blueVariation: 0
				rotation: 0
				rotationVariation: 0
				autoRotation: false
				rotationVelocity: 0
				rotationVelocityVariation: 0
				entryEffect: ImageParticle.None
				system: particleSystem
				}

    ImageParticle {
		    objectName: "smoke1"
				groups: ["smoke1"]
				source: "qrc:///images/particles/barrelpoof.png"
				color: "#262821"
				colorVariation: 0
				alpha: 1
				alphaVariation: 0
				redVariation: 0
				greenVariation: 0
				blueVariation: 0
				rotation: 21
				rotationVariation: 20
				autoRotation: false
				rotationVelocity: 0
				rotationVelocityVariation: 0
				entryEffect: ImageParticle.Fade
				system: particleSystem
				}

    ImageParticle {
		    objectName: "boom2"
				groups: ["boom2"]
				source: "qrc:///images/particles/boomboom2.png"
				color: "#ffc496"
				colorVariation: 0
				alpha: 0.5
				alphaVariation: 0
				redVariation: 0
				greenVariation: 0
				blueVariation: 0
				rotation: 0
				rotationVariation: 0
				autoRotation: false
				rotationVelocity: 0
				rotationVelocityVariation: 0
				entryEffect: ImageParticle.None
				system: particleSystem
				}

    Emitter {
		    objectName: "boomEmitter1"
				id: boomEmitter1
				x: 0
				y: 30
				width: 24
				height: 24
				enabled: false
				group: "boom1"
				emitRate: 1
				maximumEmitted: 20
				startTime: 0
				lifeSpan: 150
				lifeSpanVariation: 0
				size: 72
				sizeVariation: 0
				endSize: 160
				velocityFromMovement: 0
				system: particleSystem
				velocity: CumulativeDirection {}
				acceleration: PointDirection {
				    x: 0
						xVariation: 50
						y: 0
						yVariation: 49
						}
				shape: RectangleShape {}
				}
		Emitter {
		    id: emberEmitter1
				x: 0
				y: 0
				width: 20
				height: 20
				enabled: false
				group: "ember1"
				emitRate: 15
				maximumEmitted: 150
				startTime: 50
				lifeSpan: 900
				lifeSpanVariation: 200
				size: 8
				sizeVariation: 2
				endSize: 0
				velocityFromMovement: 0
				system: particleSystem
				velocity: PointDirection {
				    x: 0
						xVariation: 145
						y: -43
						yVariation: 148
						}
				acceleration: PointDirection {
				    x: 0
						xVariation: -25
						y: 0
						yVariation: -225
						}
				shape: RectangleShape {}
				}
		Emitter {
		    objectName: "smokeEmitter1"
				id: smokeEmitter1
				x: 0
				y: 0
				width: 30
				height: 30
				enabled: false
				group: "smoke1"
				emitRate: 17
				maximumEmitted: 100
				startTime: 75
				lifeSpan: 2800
				lifeSpanVariation: 0
				size: 55
				sizeVariation: 0
				endSize: 5
				velocityFromMovement: 20
				system: particleSystem
				velocity: PointDirection {
				    x: 0
						xVariation: 0
						y: -75
						yVariation: 0
						}
				acceleration: PointDirection {
				    x: 0
						xVariation: -5
						y: 0
						yVariation: -25
						}
				shape: RectangleShape {}
				}

    Emitter {
		    objectName: "boomEmitter2"
				id: boomEmitter2
				x: 0
				y: 70
				width: 25
				height: 25
				enabled: false
				group: "boom2"
				emitRate: 1
				maximumEmitted: 1
				startTime: 50
				lifeSpan: 150
				lifeSpanVariation: 0
				size: 0
				sizeVariation: 0
				endSize: 200
				velocityFromMovement: 0
				system: particleSystem
				velocity: PointDirection {
				    x: 0
						xVariation: 0
						y: 0
						yVariation: 0
						}
				acceleration: PointDirection {
				    x: 0
						xVariation: 0
						y: 0
						yVariation: 0
						}
				shape: RectangleShape {}
				}
}
