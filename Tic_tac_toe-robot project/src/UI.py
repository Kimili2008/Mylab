import tkinter as tk
from tkinter import messagebox
import time

## thoughts 2025_2_20
## 棋盘格子的视觉识别并不稳定，尤其是黑棋会影响黑格的识别。或许可以考虑在检测出靠谱的片段后将坐标固定下来。
## 棋子的识别是好的，但是在大程序里不稳定，需要寻找原因
## 需要考虑拿取棋子的位置放在哪里
    
    
#------------------------
#Serial part

import serial
ser=serial.Serial("COM7",9600)
def send_to_arduino(data):
    """send readable stream of bytes to arduino"""
    ser.write(data.encode())  

    
    
    
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
        self.root.geometry("800x1000")
        
            
        
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
        

    def draw_board(self):
        """
        Draw the tic-tac-toe board on the canvas.
        """
        cell_size = 100
        for i in range(1, 3):
            self.canvas.create_line(i * cell_size, 0, i * cell_size, 300)
            self.canvas.create_line(0, i * cell_size, 300, i * cell_size)
            

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
        self.current_player = 2 if self.current_player == 1 else 1
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
        
        self.entry = tk.Entry(root, font=("Helvetica", 14))
        self.entry.place(x=200, y=320)
        
        self.submit_button = tk.Button(root, text="Submit", command=self.handle_input, font=("Helvetica", 14))
        self.submit_button.place(x=400, y=320)
        
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
        

        
        
        
    def select_White(self):
        self.human = "White"
        self.input_label = tk.Label(root, text="Enter coordinates (e.g., 0,0):", font=("Helvetica", 14))
        self.input_label.place(x=0, y=320)
        
        self.entry = tk.Entry(root, font=("Helvetica", 14))
        self.entry.place(x=200, y=320)
        
        self.submit_button = tk.Button(root, text="Submit", command=self.handle_input, font=("Helvetica", 14))
        self.submit_button.place(x=400, y=320)
        
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

        self.ai_turn()

    def undo_move(self):
      """
      Undo the last two moves made on the board, considering the current player (Black or White).
      This method will remove one move from each player if possible.
      """
      # Track the number of undone moves for each player
      undone_black = 0
      undone_white = 0
      def undo_single_move(player):
          nonlocal undone_black, undone_white
          for i in range(2, -1, -1):
              for j in range(2, -1, -1):
                  if self.board[i][j] == player:
                      self.board[i][j] = 0
                      if player == 2:  # Black
                          undone_black += 1
                      else:  # White
                          undone_white += 1
                      return True
          return False
      # First, try to undo a move by the opposite player
      opposite_player = 1 if self.current_player == 2 else 2
      if not undo_single_move(opposite_player):
          # If no move was found for the opposite player, attempt to undo a move by the current player
          undo_single_move(self.current_player)
      # Then, undo a move by the current player
      undo_single_move(self.current_player)
      # Redraw the entire board and pieces
      self.canvas.delete("all")
      self.draw_board()
      for r in range(3):
          for c in range(3):
              if self.board[r][c] != 0:
                  piece = "White" if self.board[r][c] == 1 else "Black"
                  x_center = c * 100 + 50
                  y_center = r * 100 + 50
                  self.canvas.create_text(x_center, y_center, text=piece, font=("Helvetica", 30), fill="black")
      # Determine the new current player based on the undone moves
      # If both players had a move undone, switch back to the original player
      if undone_black > 0 and undone_white > 0:
          pass  # Current player remains unchanged
      elif undone_black > undone_white:  # More black moves were undone
          self.current_player = 1  # Switch to white
      else:  # More white moves were undone
          self.current_player = 2  # Switch to black
          
      self.current_player_label.config(text=f"Current Player: {'White' if self.current_player == 1 else 'Black'}")
      

    def reset_board(self):
        """
        Reset the board to its initial state.
        """
        self.board = [[0 for _ in range(3)] for _ in range(3)]
        self.canvas.delete("all")
        self.draw_board()
        self.current_player = 1
        self.current_player_label.config(text="Current Player: Black")

    def ai_turn(self):
        """
        Let the AI take its turn.
        """
        
        move = ai_move(self.board)
        str1=str(move[0])+str(move[1])
        send_to_arduino(str1)
        if move:
            self.make_move(move[0], move[1])
            if self.check_winner():
                winner = "White" if self.current_player == 2 else "Black"
                messagebox.showinfo("Victory", f"{winner} wins!")
                self.reset_board()
            elif all(self.board[i][j] != 0 for i in range(3) for j in range(3)):
                messagebox.showinfo("Draw", "It's a draw!")
                self.reset_board()
            else:
                #self.current_player = 1 if self.current_player == 2 else 2
                #self.current_player_label.config(text=f"Current Player: {'White' if self.current_player == 1 else 'Black'}")
                pass

if __name__ == "__main__":
    root = tk.Tk()
    app = TicTacToeApp(root)
    root.mainloop()