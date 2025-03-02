import tkinter as tk
from tkinter import messagebox
import time
import cv2
from PIL import Image, ImageTk
import threading
import chess4

## thoughts 2025_2_20
## 棋盘格子的视觉识别并不稳定，尤其是黑棋会影响黑格的识别。或许可以考虑在检测出靠谱的片段后将坐标固定下来。
## 棋子的识别是好的，但是在大程序里不稳定，需要寻找原因
## 需要考虑拿取棋子的位置放在哪里
## thoughts 2025_2_21
##上述问题基本解决
## 现在关键是如何将这个程序包装为一个函数，或者将关键模块拉出来放到UI里
## thoughts 2025_2_24
## 或许可以分为两个程序，保持摄像头常开，通过serialport与自己在不同程序之间通信，当主程序需要摄像头的识别列表的时候再进行通讯
##也可以分为两个进程，建立一个通信队列quene，里面放置棋盘信息
#------------------------
#Serial part

import serial
try:
    ser=serial.Serial("COM7",9600)
except Exception:
    print('Serial breaks')
def send_to_arduino(data):
    """send readable stream of bytes to arduino"""
    ser.write(data.encode()) 
    pass 
def receive_from_arduino():
    while ser.in_waiting == 0:
        time.sleep(0.1)

    data = ser.readline()
    print(data.decode())
    return 
event = threading.Event()
    
    
#---------------------------------------------
#chess logic
def check_winner(board, player):
            #rows,columns and diagonals
            for row in board:
                if all(spot == player for spot in row):
                    return player
            for col in range(3):
                if all(board[row][col] == player for row in range(3)):
                    return player
            if all(board[i][i] == player for i in range(3)) or all(board[i][2-i] == player for i in range(3)):
                return player
            return False
def ai_move(board:list):
        """
        Give the AI best response to the next location
        
        parameters:
            board (list of list of int): a 3x3 list represents the board,0 represents empty blocks,1 represents the white,2 represents the black.
            
        return:
            tuple: the AI choice (row, col)。
        """
        # calculate the number of chess currently in board
        white_count = sum(row.count(1) for row in board)
        black_count = sum(row.count(2) for row in board)
    
        # decide who plays
        current_player = 1 if white_count < black_count else 2
        
        # check if there's a winning move
        def check_win_move(player):
            for row in range(3):
                for col in range(3):
                    if board[row][col] == 0:
                        # simulate to place the stones
                        board[row][col] = player
                        if check_winner(board, player)!=False:
                            board[row][col] = 0  
                            return (row, col)
                        board[row][col] = 0  
            return None
    
        # check the win move
        win_move = check_win_move(current_player)
        if win_move:
            return win_move
    
        # check if the opponent has the winning move
        opponent = 1 if current_player == 2 else 2
        block_move = check_win_move(opponent)
        if block_move:
            return block_move
    
        # choose a random space
        from random import choice
        empty_spots = [(r, c) for r in range(3) for c in range(3) if board[r][c] == 0]
        return choice(empty_spots)
#-------------------------------------------------------
#UI part
class TicTacToeApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Tic-Tac-Toe Game")
        
        # Set window size to 800x1000 pixels
        self.root.geometry("805x700")
        
            
        
        # Initialize board state: 0 for empty, 1 for white, 2 for black
        self.board = [[0 for _ in range(3)] for _ in range(3)]
        self.current_player = 2  # Start with black player
        
        # Create canvas frame
        self.canvas_frame = tk.Frame(root)
        self.canvas_frame.place(x=0, y=0)
        
        # Create canvas for drawing the board
        self.canvas = tk.Canvas(self.canvas_frame, width=300, height=300, bg='white')
        self.canvas.pack()
        
        # Draw the board
        self.draw_board()
        messagebox.showinfo("Pick your side!")
        self.selection_button_black=tk.Button(root, text="Black", command=self.select_Black, font=("Helvetica", 20))
        self.selection_button_black.place(x=200,y=320)
        self.selection_button_white=tk.Button(root, text="White", command=self.select_White, font=("Helvetica", 20))
        self.selection_button_white.place(x=600,y=320)
        
        self.quenelist=None       
        self.whitelastmove=None
        self.blacklastmove=None
        
        
    def create_camera_display(self):
        # 摄像头显示区域
        self.camera_label = tk.Label(self.root)
        self.camera_label.place(width=500,height=400,x=305,y=0)    # set your camera layout at here
        
    def update_camera_feed(self):
        # 捕获摄像头画面并更新到 GUI
        cap = cv2.VideoCapture(1)  # 打开默认摄像头
        previousboard=[]

        while True:
            ret, frame = cap.read()
            frame = cv2.rotate(frame,cv2.ROTATE_180)
            if ret:
                chessboard_state,previousboard = chess4.detect_chessboard(frame, previousboard,board_size=(3, 3))
                if self.quenelist == "cam_send":
                    self.board=chessboard_state
                    self.quenelist = None              
                # 将 OpenCV 图像转换为 PIL 图像
                frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                image = Image.fromarray(frame)
                photo = ImageTk.PhotoImage(image=image)

                # 更新 Label 的内容
                self.camera_label.config(image=photo)
                self.camera_label.image = photo
                
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break
            else:
                print("Errors from reading the camera.")

            # 控制刷新频率
            self.root.update()
            time.sleep(0.04)
        cap.release()  

    def draw_board(self):
        """
        Draw the tic-tac-toe board on the canvas.
        """
        cell_size = 100
        for i in range(1, 3):
            self.canvas.create_line(i * cell_size, 0, i * cell_size, 300)
            self.canvas.create_line(0, i * cell_size, 300, i * cell_size)
        for c in range(3):
          for r in range(3):
              if self.board[r][c] != 0:
                  piece = "White" if self.board[r][c] == 1 else "Black"
                  x_center = c * 100 + 50
                  y_center = r * 100 + 50
                  self.canvas.create_text(x_center, y_center, text=piece, font=("Helvetica", 30), fill="black")
                
            

    def handle_input(self):
        """
        Normal input:Handle user input from the entry widget and make a move.
        Tic_tac_tie input: receive the row,col of the user's stone and call the robotic arm.Then AI make a move
        """
        ##
        ## Call the Camera here and check if there's a new stone. Idenify the new stone by comparing it with the old self.board
        ##If the new stone is there for over 60% in the last 25 pictures, then we see this as a new move. 
        try:
            input_str = self.entry.get().strip()
            row, col = map(int, input_str.split(','))
            if not self.board[row][col]:
                self.make_move(row, col)
                if self.check_winner():
                    winner = "White" if self.current_player == 2 else "Black"
                    messagebox.showinfo("Victory", f"{winner} wins!")
                    self.reset_board()
                    SystemExit()
                elif all(self.board[i][j] != 0 for i in range(3) for j in range(3)):
                    messagebox.showinfo("Draw", "It's a draw!")
                    self.reset_board()
                else:
                    self.ai_turn()
        except Exception as e:
            messagebox.showerror("Error", f"Invalid input: {e}")

    def make_move(self, row, col):
        """
        Make a move on the board and update the UI.
        :param row: Row index of the move.
        :param col: Column index of the move.
        """
        cell_size = 100
        x_center = col * cell_size + cell_size / 2
        y_center = row * cell_size + cell_size / 2
        piece = "White" if self.current_player == 1 else "Black"
        self.board[row][col] = self.current_player
        time.sleep(0.3)
        self.canvas.create_text(x_center, y_center, text=piece, font=("Helvetica", 30), fill="black")

        self.current_player_label.config(text=f"Current Player: {'White' if self.current_player == 1 else 'Black'}")

    def check_winner(self):
        """
        Check if there is a winner on the board.
        :return: True if there is a winner, False otherwise.
        """
        for row in self.board:
            if row[0] == row[1] == row[2] != 0:
                return True
        for col in range(3):
            if self.board[0][col] == self.board[1][col] == self.board[2][col] != 0:
                return True
        if self.board[0][0] == self.board[1][1] == self.board[2][2] != 0:
            return True
        if self.board[0][2] == self.board[1][1] == self.board[2][0] != 0:
            return True
        return False
        
        
    
    
    
    def select_Black(self):
        self.human = "Black"
        self.input_label = tk.Label(root, text="Enter position e.g.0,0:", font=("Helvetica", 14))
        self.input_label.place(x=0, y=320)

        
        # Undo button
        self.undo_button = tk.Button(root, text="Undo", command=self.undo_move, font=("Helvetica", 14))
        self.undo_button.place(x=0, y=360)
        
        # Reset button
        self.reset_button = tk.Button(root, text="Reset", command=self.reset_board, font=("Helvetica", 14))
        self.reset_button.place(x=100, y=360)
        
        # Display current player
        self.current_player_label = tk.Label(root, text="Current Player: Black", font=("Helvetica", 14))
        self.current_player_label.place(x=0, y=400)
        self.selection_button_black.destroy()
        self.selection_button_white.destroy()
        self.create_camera_display()
        # 启动摄像头线程
        self.camera_thread = threading.Thread(target=self.update_camera_feed, daemon=True)
        self.camera_thread.start()
        self.appstatus="app-waiting"
        self.player_thread = threading.Thread(target=self.player_turn, daemon=True)
        self.player_thread.start()
        

        

        
        
        
    def select_White(self):
        self.human = "White"
        self.input_label = tk.Label(root, text="Enter coordinates (e.g., 0,0):", font=("Helvetica", 14))
        self.input_label.place(x=0, y=320)

        
        # Undo button
        self.undo_button = tk.Button(root, text="Undo", command=self.undo_move, font=("Helvetica", 14))
        self.undo_button.place(x=0, y=360)
        
        # Reset button
        self.reset_button = tk.Button(root, text="Reset", command=self.reset_board, font=("Helvetica", 14))
        self.reset_button.place(x=100, y=360)
        
        # Display current player
        self.current_player_label = tk.Label(root, text="Current Player: Black", font=("Helvetica", 14))
        self.current_player_label.place(x=0, y=400)
        self.selection_button_black.destroy()
        self.selection_button_white.destroy()
        
        self.appstatus="app-playing"
        
        self.create_camera_display()
        # 启动摄像头线程
        self.camera_thread = threading.Thread(target=self.update_camera_feed, daemon=True)
        self.camera_thread.start()
        self.ai_thread=threading.Thread(target=self.ai_turn(True), daemon=True)
        self.ai_thread.start()

        

    def undo_move(self):
      """
      Undo the last two moves made on the board, considering the current player (Black or White).
      This method will remove one move from each player if possible.
      """
      # Track the number of undone moves for each player
      # ask arduino to stop
      self.player_thread.join()
      countwhite=0
      countblack=0
      for i in self.board:
          for j in i:
              if j==1: countwhite +=1
              elif j == 2: countblack += 1
              else:pass
      self.appstatus == "stop"
      if self.current_player == 1:#if current player is white
        if self.blacklastmove != None:
            str1='<'+str(self.blacklastmove[0])+','+str(self.blacklastmove[1])
            send_to_arduino(str1)  #ask arduino to redraw the stone on the board
            receive_from_arduino() #wait until it is done
            str2='<'+str(1)+';'+str(countblack-1)
            send_to_arduino(str2) 
            receive_from_arduino() #wait until it is done
            self.board[self.blacklastmove[0]][self.blacklastmove[1]]=0 #clear the board
            send_to_arduino('<r')
            receive_from_arduino()
            if self.whitelastmove != None:
                str1='<'+str(self.whitelastmove[0])+','+str(self.whitelastmove[1])
                send_to_arduino(str1)  #ask arduino to redraw the stone on the board
                receive_from_arduino() #wait until it is done
                str2='<'+str(0)+';'+str(countwhite-1)
                send_to_arduino(str2) 
                receive_from_arduino() #wait until it is done
                self.board[self.whitelastmove[0]][self.whitelastmove[1]]=0 #clear the board
                send_to_arduino('<r')
                receive_from_arduino()
              
      else:
        if self.whitelastmove != None:
            str1='<'+str(self.whitelastmove[0])+','+str(self.whitelastmove[1])
            send_to_arduino(str1)  #ask arduino to redraw the stone on the board
            receive_from_arduino() #wait until it is done
            str2='<'+str(0)+';'+str(countwhite-1)
            send_to_arduino(str2)
            print('undo!',str2) 
            receive_from_arduino() #wait until it is done   
            self.board[self.whitelastmove[0]][self.whitelastmove[1]]=0 #clear the board
            send_to_arduino('<r')
            receive_from_arduino()
            if self.blacklastmove != None:
                print(self.blacklastmove)
                print(self.whitelastmove)
                str1='<'+str(self.blacklastmove[0])+','+str(self.blacklastmove[1])
                send_to_arduino(str1)  #ask arduino to redraw the stone on the board
                receive_from_arduino() #wait until it is done
                str2='<'+str(1)+';'+str(countblack-1)
                send_to_arduino(str2) 
                receive_from_arduino() #wait until it is done
                self.board[self.blacklastmove[0]][self.blacklastmove[1]]=0 #clear the board
                send_to_arduino('<r')
                receive_from_arduino()
      # Redraw the entire board and pieces
      self.canvas.delete("all")
      self.draw_board()
      # Determine the new current player based on the undone moves
      # If both players had a move undone, switch back to the original player
      if self.whitelastmove != None and self.blacklastmove != None:
          pass  # Current player remains unchanged
      elif self.whitelastmove == None:  # More black moves were undone
          self.current_player = 1  # Switch to white
      else:  #More white moves were undone
          pass  
      self.current_player_label.config(text=f"Current Player: {'White' if self.current_player == 1 else 'Black'}")
      self.appstatus == "app-waiting"#begin another loop
      self.player_thread = threading.Thread(target=self.player_turn, daemon=True)
      self.player_thread.start()
    def reset_board(self):
        """
        Reset the board to its initial state.
        """

        #ask arudino to reset the board
        self.appstatus = 'reset'#stop arduino
        countblack = 0
        countwhite = 0
        for i in self.board:
            for j in i:
                if j != 0:
                    if j == 1:
                        countwhite += 1
                        str1='<'+str(i)+','+str(j)
                        send_to_arduino(str1)  #ask arduino to redraw the stone on the board
                        receive_from_arduino() #wait until it is done
                        str2='<'+str(0)+';'+str(countwhite-1)
                        send_to_arduino(str2) 
                        receive_from_arduino() #wait until it is done
                        send_to_arduino('<r')
                        receive_from_arduino()
                    if j == 2:
                        countblack += 1
                        str1='<'+str(i)+','+str(j)
                        send_to_arduino(str1)  #ask arduino to redraw the stone on the board
                        receive_from_arduino() #wait until it is done
                        str2='<'+str(1)+';'+str(countblack-1)
                        send_to_arduino(str2) 
                        receive_from_arduino() #wait until it is done
                        send_to_arduino('<r')
                        receive_from_arduino()
                        
                    
        self.board = [[0 for _ in range(3)] for _ in range(3)]
        self.previous_board= [[0 for _ in range(3)] for _ in range(3)]
        self.canvas.delete("all")
        self.draw_board()
        if self.current_player == 2:#if the player is black
            self.appstatus = 'app-waiting'
        else:
            self.player_thread.join()
            self.ai_turn()
            self.player_thread = threading.Thread(target=self.player_turn, daemon=True)
            self.player_thread.start()
        self.current_player_label.config(text="Current Player: Black")
        self.appstatus = 'app-waiting'
        self.current_player = 2
        self.blacklastmove=None
        self.whitelastmove=None
    def ai_turn(self,start=False):
        """
        Let the AI take its turn.
        """

        #更换玩家标记
        move = ai_move(self.board)
        if self.current_player == 2: self.current_player = 1
        else:self.current_player = 2
        self.current_player_label.config(text=f"Current Player: {'White' if self.current_player == 1 else 'Black'}")
        if start == True:
            self.current_player = 2
        #记下移动位置
        self.previous_board = self.board
        #让摄像头发来信息
        self.quenelist = "cam_send"
        #calculate the number of pieces
        count = 0
        for i in self.board:
            for j in i:
                if j == self.current_player:
                    count += 1
        ###
        print((count,'count is '))
        str1 ='>'+str(self.current_player-1)+';'+str(count) #str1 tells arduino to move to the stonepos and fetch it
        send_to_arduino(str1)
        print(str1)
        receive_from_arduino() #wait until there is data inputted
        
        print(move)
        str2 ='>'+str(move[0])+","+str(move[1]) #str2 tells arduino to move to the boardpos and drop it
        print(str2)
        send_to_arduino(str2)
        if move:
            self.make_move(move[0], move[1])
            if self.check_winner():
                self.appstatus = 'end'
                winner = "White" if self.current_player == 2 else "Black"
                messagebox.showinfo("Victory", f"{winner} wins!")
                SystemExit()
                self.reset_board()
                
            elif all(self.board[i][j] != 0 for i in range(3) for j in range(3)):
                messagebox.showinfo("Draw", "It's a draw!")
                self.reset_board()
            else:
                #self.current_player = 1 if self.current_player == 2 else 2
                #self.current_player_label.config(text=f"Current Player: {'White' if self.current_player == 1 else 'Black'}")
                pass
        #先等待，直到收到来自arduino的已完成的信息
        #再度让摄像头发来信息，检测列表的更换是否出现问题，出现问题则认为已作弊
        receive_from_arduino()
        #等待arduino运行完成后发出的确认指令
        #ask arduino to reset
        print('r')
        send_to_arduino("<r")
        time.sleep(1)
        self.previous_board=self.board #记录下当前棋局，避免人类过快放棋
        receive_from_arduino()
        
        
        self.appstatus = "app-waiting" # The app is waiting for player's response
        if self.current_player == 2: 
            self.current_player = 1 
            self.blacklastmove=(move[0],move[1])#record the last move of AI
            print(self.blacklastmove,'from line 506')
        else:
            self.current_player = 2 
            self.whitelastmove=(move[0],move[1])#record the last move of AI
        
        self.current_player_label.config(text=f"Current Player: {'White' if self.current_player == 1 else 'Black'}")
        if start == True:
            self.player_thread = threading.Thread(target=self.player_turn, daemon=True)
            self.player_thread.start()
        try:
            self.ai_thread.join()
        except Exception:
            pass
        #检测留到之后做
    def player_turn(self):
        while not event.is_set():
            count = 0
            self.previous_board=self.board
            while self.appstatus == "app-waiting" and count != 20: #when count = 9 , then the board has changed
                self.quenelist = "cam_send" #store the current board in self.board
                if self.previous_board != self.board: #if the board changes
                    count += 1  #number of changes increases
                else:
                    count = 0 #return to the initial status
                if count == 0:
                    self.previous_board = self.board #record the initial board
                time.sleep(0.03)
                if count == 19:
                    whitenum = 0 
                    blacknum = 0
                    for i in self.board:
                        for j in i:
                            if j == 1:
                                whitenum+=1
                            if j == 2:
                                blacknum+=1
                    for i in self.previous_board:
                        for j in i:
                            if j == 1:
                                whitenum-=1
                            if j == 2:
                                blacknum-=1
                    if whitenum>0 or blacknum > 0:
                        count = 19
                    else:
                        count = 0
            for i in range(len(self.previous_board)):
                for j in range(len(self.board)):
                    if self.previous_board[i][j]!=self.board[i][j]:
                        if self.current_player==1:self.whitelastmove=(i,j)
                        else:self.blacklastmove=(i,j)                                      
            print('detected!!!')
            print(self.board)
            self.draw_board()
            self.ai_turn()
            print('complete!from line448')            
                

                
                


root = tk.Tk()
app = TicTacToeApp(root)
root.mainloop()