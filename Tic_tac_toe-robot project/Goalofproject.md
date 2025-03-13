## Workflow of the robot  
1. Preparion: The wires are plugged correctly and pieces are put into positions
2. The player click the button in the userinterface to select the game mode.(black or white)
3. The game starts! The player place the piece into the positions.
4. The camera above detects which stone does the player moves and responds.
5. The camera sends back the result-in a data type called frame in opencv.
6. After calculations of the frame, the program produces a matrix of the whole board. In a 2D array like [[0,1,0],[0,0,0],[1,0,2]]
7. The Arduino receives the message and gives back the best position to play after some calcuations.
8. The robotic arm receives the result, picks up the piece and moves to the right position.
The next cycle begins.
