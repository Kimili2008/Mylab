#Tetris
import pygame
import socket
import random
import signal
import sys
#pygame.mixer.init()
#pygame.mixer_music.load("/mnt/c/Users/xhli/Desktop/music/Undertale-自制Remix-8 Bit-MEGALOVANIA.mid")

#9/10 changes :variable:score, changed function: drawer,execute
#9/16 changes :connection between two computers 
#9/18 changes :colors,background, boundary
#10/24 changes:data transmission four types of data: up down left right
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)	
s.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1)
signal.signal(signal.SIGFPE, signal.SIG_IGN)

# Quit and enter
print("Welcome \n to \n Tetris!")
mode = input("match or wait?")
# data transmission
conn = None
addr = None
def server():

        global conn, addr
        s.bind(("",12345))
        s.listen(10)	 
        print("socket is listening")
        conn, addr = s.accept()	 
        
        
   
    
    
def client():
    try:
        s.connect(("127.0.0.1",12345))
    except socket.timeout:
        pass
def send_data(data):
    try:
        global mode
        
        if mode == "wait":
            s.send(data.encode())
        else:
            conn.send(data.encode())
    except socket.timeout:
        pass
def receive_data():
    global gamestatus,judge
    try:
        if mode == "wait":
            data = s.recv(4096)
            if not data:
                pass
            else:
                print(data.decode())
                test = data.decode()
                for i in range(len(data.decode())-3):
                    if test[i+2]== "[" and test[i+3]=="[": 
                        print("WRONG!!!")
                        return
                data = eval(data.decode(encoding="ascii"))
                
                for i in data:
                    try:
                        if data[i] == "win":
                            lose()
                            gamestatus = False
                            judge = "lose"
                            print("YOU LOSE!!!")
                            pygame.quit()
                            sys.exit()
                        elif data[i] == "lose":
                            win()
                            gamestatus = False
                            judge = "win"
                            print("YOU WIN!!!")
                            pygame.quit()
                            sys.exit()
                    except TypeError:
                        pass
                return data
                
                    
        else:
            data = conn.recv(4096)

            if not data:
                pass
            else:
                data = eval(data.decode())
                print(data)
                
                for i in data:
                    try:
                        if data[i] == "win":
                            lose()
                            gamestatus = False
                            judge = "lose"
                            print("YOU LOSE!!!")
                            pygame.quit()
                            sys.exit()
                        elif data[i] == "lose":
                            win()
                            gamestatus = False
                            judge = "win"
                            print("YOU WIN!!!")
                            pygame.quit()
                            sys.exit()
                    except TypeError:
                        pass
                return data
                
    except socket.timeout:
        pass
        

try:
    if mode == "match":
        server()
    if mode == "wait":
        client()
except Exception:
    pass
    




s.settimeout(0.02)


pygame.init()

#color definition

def colors(type:str) -> tuple:
    match type:
        case("Black"):
            return (0, 0, 0)
        case("Blue"):
            return (100,149,237)
        case("Grey"):
            return (128, 128, 128)
        case("Green"):
            return (107,142,35)
        case("Lime"):
            return (0, 200, 0)
        case("Purple"):
            return (147,112,219)
        case("Red"):
            return (200, 0, 0)
        case("Teal"):
            return (0, 128, 128)
        case("White"):
            return (255, 255, 255)
        case("Yellow"):
            return (255, 255, 0)
        case("cream"):
            return (220,220,200)
        case("metal blue"):
            return (70,130,180)

#screen_initializing
screen = pygame.display.set_mode((1020,640))
screen.fill(colors("cream"))
pygame.display.set_caption("Tetris")
pygame.display.flip()
font = pygame.font.Font("C:\\Windows\\Fonts\\MTCORSVA.TTF",40)

    
# drawer
def cubes(coordinate:tuple,colorss:tuple,judge:bool):
    
    if judge == True:
        
        pygame.draw.rect(screen,colorss,(coordinate[0]+10,coordinate[1]+30,40,40))
        pygame.draw.rect(screen,colors("cream"),(coordinate[0]+10,coordinate[1]+30,40,40),1)




#collision
condition = 0
sentlist = []
def sentlistmadeup(collisionlist, stonelist):
    sentlist0 = collisionlist + stonelist
    sentlist1 = []
    for i in sentlist0:
        if not(i[0] == -1 or i[0] == 10 or i[1] == 15):
            sentlist1.append(i)
            
    
    return str(sentlist1)
    

collisionlist = []
stonelist = []
opponentlist = []

for i in range(0,10):
    stonelist.append([i,15,"cream"])

for i in range(0,15):
    stonelist.append([-1,i,"cream"])
    
for i in range(0,15):
    stonelist.append([10,i,"cream"])

    
     


#graphic initializing    
class graphics():
    def __init__(self,type:str,color:str) -> None:
        match type:
            case("strip"):
                random_number = random.randint(0,9)
                collisionlist.append([random_number,0,color])
                collisionlist.append([random_number,1,color])
                collisionlist.append([random_number,2,color])
                collisionlist.append([random_number,3,color])
                cubes((random_number*40,0),colors(color),True)
                cubes((random_number*40,40),colors(color),True)
                cubes((random_number*40,80),colors(color),True)
                cubes((random_number*40,120),colors(color),True)
                
                
            case("square"):
                random_number = random.randint(0,8)
                collisionlist.append([random_number,0,color])
                collisionlist.append([random_number,1,color])
                collisionlist.append([random_number+1,0,color])
                collisionlist.append([random_number+1,1,color])
                
                
                cubes((random_number*40,0),colors(color),True)
                cubes((random_number*40+40,0),colors(color),True)
                cubes((random_number*40,40),colors(color),True)
                cubes((random_number*40+40,40),colors(color),True)
            case("small L"):
                random_number = random.randint(0,8)
                collisionlist.append([random_number,0,color])
                collisionlist.append([random_number,1,color])
                collisionlist.append([random_number,2,color])
                collisionlist.append([random_number+1,2,color])
                
                cubes((random_number*40,0),colors(color),True)
                cubes((random_number*40,40),colors(color),True)
                cubes((random_number*40,80),colors(color),True)
                cubes((random_number*40+40,80),colors(color),True)
            case("small T"):
                random_number = random.randint(1,8)
                collisionlist.append([random_number+1,0,color])
                collisionlist.append([random_number-1,0,color])
                collisionlist.append([random_number,0,color])
                collisionlist.append([random_number,1,color])
                
                cubes((random_number*40,0),colors(color),True)
                cubes((random_number*40,40),colors(color),True)
                cubes((random_number*40-40,0),colors(color),True)
                cubes((random_number*40+40,0),colors(color),True)
    def drop(self) -> bool:
        for i in collisionlist:
            i[1] += 1
    def spin(self,type:str,condition:int):
        global collisionlist
        
        backuplist = collisionlist
        match type:
            case("strip"):
                pass
            case("square"):
                pass
            case("small L"):
                if condition == 0:
                    pass
                    """collisionlist[0][0] += 1
                    collisionlist[0][1] += 1
                    collisionlist[1][0] -= 1
                    collisionlist[1][1] += 1
                    print(collisionlist)"""
                if condition == 90:
                    pass
                    #collisionlist[0][0] += 0
                    #collisionlist[0][1] += 2
                    #collisionlist[1][0] += 2
                    #collisionlist[1][1] += 2
                    #print(collisionlist)
                if condition == 180:
                    pass
                    #collisionlist[1][0] += 2
                    #collisionlist[1][1] -= 2
                    #collisionlist[2][0] += 2
                    #collisionlist[2][1] += 0
                    #print(collisionlist)
                if condition == 270:
                    pass
                    #print(collisionlist)
            case("small T"):
                if condition == 0:
                    collisionlist[1][0] += 1
                    collisionlist[1][1] -= 1
                if condition == 90:
                    collisionlist[3][0] -= 1
                    collisionlist[3][1] -= 1
                    
                    
                    
                if condition == 180:
                    collisionlist[0][0] -= 1
                    collisionlist[0][1] += 1  
                    
                    
                    
                if condition == 270:
                    collisionlist[1][0] -= 1
                    collisionlist[1][1] += 1    
                    collisionlist[0][0] += 1
                    collisionlist[0][1] -= 1
                    collisionlist[3][0] += 1
                    collisionlist[3][1] += 1
                
        if self.hit_others() == True:
            collisionlist = backuplist
            return False
        else:
            return True
    
    
    
    
    
    def left(self) -> bool:
        for i in collisionlist:
            i[0] -= 1
    def right(self) -> bool:
        for i in collisionlist:
            i[0] += 1
    def reverse_drop(self):
        for i in collisionlist:
            i[1] -= 1
    def hit_others(self) -> bool:
        
        for i in collisionlist:
            for j in stonelist:
                if j[0] == i[0] and j[1] == i[1]:
                    return True
receivedlist = []             
def drawer():
    screen.fill(colors("cream"))
    if_row()
    for j in collisionlist:
            cubes((j[0]*40,j[1]*40),colors(j[2]),True)
    for j in stonelist:
            
            cubes((j[0]*40,j[1]*40),colors(j[2]),True)
    if receivedlist != None:
        for j in receivedlist:
            cubes(((j[0]+15)*40,j[1]*40),colors(j[2]),True)
    pygame.draw.rect(screen,colors("metal blue"),(410,0,200,640),10)
    pygame.draw.rect(screen,colors("metal blue"),(0,0,1020,640),10)
    pygame.draw.rect(screen,colors("metal blue"),(410,200,200,10),5)
    font = pygame.font.Font("C:\\Windows\\Fonts\\MTCORSVA.TTF",40)
    score1 = "Score"
    textforscore = font.render(score1,True,colors("Green"))
    introduction = "Welcome!"
    textforintroduction = font.render(introduction,True,colors("Green"))
    scorecounter = font.render(str(score),True,colors("Green"))
    screen.blit(textforscore,(450,350))
    screen.blit(textforintroduction,(425,100))
    screen.blit(scorecounter,(430,400))
    """
    if judge == "win":
        textforscore = font.render("you win!",True,colors("Red"))
        screen.blit(textforscore,(160,200))
    if judge == "lose":
        textforscore = font.render("you lose!",True,colors("Red"))
        screen.blit(textforscore,(160,200))
    """

colorlist = ["Blue","Red","Green","Lime","Purple","Teal"]
type1 = ["strip","small T","small L","square"]

judge = None
#Row
def execute(row:list):
    global score
    score += 1
    for j in row: 
            stonelist.remove(j)

def renew(index:int):
    for i in stonelist:
        if i[0] != -1 and i[0] != 10 and i[1] != 15 and i[1] < index:
            i[1] += 1

def if_row():
    list = []
    for i in range(0,15):
        list.append([])
    for i in stonelist:
        if i[0] != -1 and i[0] != 10 and i[1] != 15:
            list[i[1]].append(i)  
    for i in list:
        if len(i) >= 10:
            execute(i)
            renew(list.index(i))
def if_lose():
    for i in stonelist:
        if i[1] == 2:
            return True
def lose():
    
    global gamestatus,judge,font,screen
    
    gamestatus = False
    judge = "lose"
def win(): 
    global gamestatus,judge,font,screen
    
    gamestatus = False
    judge = "win"
gamestatus = True

    


score = 0
drop_event_type = pygame.USEREVENT + 1
drop_event = pygame.event.Event(drop_event_type)
receive_event_type = pygame.USEREVENT + 1
receive_event = pygame.event.Event(receive_event_type)
pygame.time.set_timer(drop_event,500)

condition = 0
collisionlist = []
type = type1[random.randint(0,3)]
print(type)
test1 = graphics(type,colorlist[random.randint(0,5)])
drawer()
pygame.display.flip()

while gamestatus:
    
    for event in pygame.event.get():
            
            if event.type == pygame.QUIT:
                pygame.quit()
                gamestatus = False
            
                

            elif event.type == pygame.KEYDOWN:
                
                if event.key == pygame.K_RIGHT:
                    
                    test1.right()
                    if test1.hit_others() == True:                        
                        test1.left()
                    drawer()
                    pygame.display.flip()
                        
                if event.key == pygame.K_LEFT:
                    test1.left()
                    if test1.hit_others() == True:
                        test1.right()
                    drawer()
                    pygame.display.flip()
                        
                    
                if event.key == pygame.K_DOWN: 
                    test1.drop()
                    if test1.hit_others() == True:
                        test1.reverse_drop()
                        for j in collisionlist:
                            stonelist.append(j)
                        del test1    
                        
                        condition = 0
                        collisionlist = []
                        type = type1[random.randint(0,3)]
                        print(type)
                        test1 = graphics(type,colorlist[random.randint(0,5)])
                        drawer()
                        pygame.display.flip()
                        
                    
                if event.key == pygame.K_UP:
                    if condition != 270:
                        if test1.spin(type,condition) == True:
                            condition += 90
                            
                    else:
                        if test1.spin(type,condition) == True:
                            condition -= 270
                            
                    drawer()
                    pygame.display.flip()
                
                
            elif event.type == drop_event_type:
                
                test1.drop()
                if test1.hit_others() == True:
                    test1.reverse_drop()
                    for j in collisionlist:
                        stonelist.append(j)
                    del test1
                    condition = 0
                    collisionlist = []
                    type = type1[random.randint(0,3)]
                    test1 = graphics(type,colorlist[random.randint(0,5)])
                sentlist = sentlistmadeup(collisionlist,stonelist)
                send_data(sentlist)
                receivedlist = receive_data()
                drawer()
                
                if score == 5:
                    sentlist = ["win"]
                    send_data(sentlist)
                    win()
                    break
                if if_lose == True:
                    sentlist = ["lose"]
                    send_data(sentlist)
                    lose()
                    break
                
                pygame.display.flip()
            
            else:
                pygame.display.flip()
if judge == "lose":
    print("YOU LOSE!!!")
    pygame.quit()
if judge == "win":
    print("YOU WIN!!!")
    pygame.quit()
    