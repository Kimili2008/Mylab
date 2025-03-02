import cv2
import numpy as np
counter=0
pre_list2=[]
black_bordered_centers=[]
def detect_chessboard(image, previous_grid_centers:list,board_size=(3, 3)):
    """
    检测棋盘上的棋子，并在图像上绘制棋盘和棋子。

    参数：
        image (numpy.ndarray): 输入的摄像头捕获的图像。

    返回：
        list: 二维列表，表示棋盘状态（0: 空，1: 白棋，2: 黑棋）。
        processedimage: 处理过的图像，包含了黑框中心和圆位置，颜色的显示
        
    """
    # 初始化棋盘状态
    rows, cols = board_size
    chessboard_state = [[0 for _ in range(cols)] for _ in range(rows)]

    # 转换为灰度图像并应用高斯模糊
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    gray = cv2.GaussianBlur(gray, (9, 9),2,2)

    # 使用 HoughCircles 检测圆
    circles = cv2.HoughCircles(gray, cv2.HOUGH_GRADIENT, 1,
                               minDist=20,
                               param1=30,  # 高阈值
                               param2=40,  # 累加器阈值
                               minRadius=15,
                               maxRadius=40)
    
    grid_centers = calculate_grid_centers(image)
    
    if len(grid_centers) == 9:
        previous_grid_centers = grid_centers
    else:  
        grid_centers = previous_grid_centers
    #print(len(grid_centers),"grid now")
    #print(grid_centers)
    for (x, y) in grid_centers:
        cv2.circle(image, (x, y), 5, (0, 255, 0), -1)
    if circles is not None:
        circles = np.round(circles[0, :]).astype("int")
        # 获取棋盘的格子中心坐标
        
        
        #print(grid_centers)
        # 遍历每个检测到的圆
        for (x, y, r) in circles:
            # 计算圆心区域的平均亮度
            roi = gray[y-5:y+5, x-5:x+5]
            average_brightness = np.mean(roi)

            # 判断是黑棋还是白棋
            if average_brightness < 100:  # 黑棋
                piece_type = 2
                render_color = (0, 0, 255)  # 红色表示黑棋

            elif average_brightness > 180:  # 白棋
                piece_type = 1
                render_color = (0, 255, 0)  # 绿色表示白棋
            else:
                continue  # 忽略其他情况
            cv2.circle(image, (x, y), r, render_color, 2)
            cv2.rectangle(image, (x - 3, y - 3), (x + 3, y + 3), render_color, -1)
            # 找到最近的格子中心

            res = in_grid_pos((x,y),piece_type,grid_centers)  # get the info about the position of the stone
            if res != None:
                chessboard_state[res[0]][res[1]] = piece_type
                # 在图像上绘制棋子
                print(chessboard_state)
                print(x,y)
    

    # 绘制棋盘边界和网格线
    return chessboard_state,previous_grid_centers


def calculate_grid_centers(image):
    """
    计算棋盘格子的中心坐标，并考虑棋盘可能不占满图像的情况。

    参数：
        image (numpy.ndarray): 输入图像。
        board_size (tuple): 棋盘大小，默认为 (3, 3)。

    返回：
        list: 格子中心的坐标列表，格式为 [((x, y), (i, j))...]。
    """
    
    def detect_black_bordered_squares(image, min_square_size=110, max_square_size=200):
        # 转换为灰度图像
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    
        # 使用高斯模糊减少噪声
        blurred = cv2.GaussianBlur(gray, (5, 5),0)
    
        # 边缘检测以找到黑色边框
        edges = cv2.Canny(blurred, 80, 150)
    
        # 查找轮廓
        contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
        black_bordered_square_centers = []
    
        for contour in contours:
            # 计算轮廓的面积和周长
            area = cv2.contourArea(contour)
            perimeter = cv2.arcLength(contour, True)
    
            # 近似轮廓为多边形
            epsilon = 0.025 * perimeter
            approx = cv2.approxPolyDP(contour, epsilon, True)
    
            # 判断是否为矩形
    
            if len(approx) % 2 == 0 and min_square_size**1 <= area <= max_square_size**2:
                # 获取矩形的边界框
                x, y, w, h = cv2.boundingRect(contour)
    
                # 判断宽高比是否接近正方形
                if 0.9 <= w / h <= 1.2:
                    # 计算中心坐标
                    center_x = x + w // 2
                    center_y = y + h // 2
                    black_bordered_square_centers.append((center_x, center_y))
        return black_bordered_square_centers
    global counter,pre_list2,black_bordered_centers
    if counter == 30:
            black_bordered_centers=[]
            pre_list1=[]
            for i in pre_list2:
                if i[1] >= counter*0.4:
                    black_bordered_centers.append(i[0])
            pre_list2 = []
            counter = 0

            for (x, y) in black_bordered_centers:
                cv2.circle(image, (x, y), 5, (0, 255, 0), -1)
            return black_bordered_centers
    else:
        # 检测黑框格子中心
        pre_list1 = detect_black_bordered_squares(image, min_square_size=230, max_square_size=500)
        a= len(pre_list2)

        if a > 0:
            for j in pre_list1:
                for i in range(a):
                  if ((pre_list2[i][0][0] <= j[0] + 20) and (pre_list2[i][0][0] >= j[0] - 20))and ((pre_list2[i][0][1] <= j[1] + 20) and (pre_list2[i][0][1] >= j[1] - 20)):
                      pre_list2[i][1] += 1
                  else:
                      if a <= 9:
                        pre_list2.append([j,1])
        else:
            for j in pre_list1:
                pre_list2.append([j,1])
            for i in pre_list2:
                count=0
                for j in pre_list2:
                    if i == j:
                        count += 1
                if count >=2:
                    for k in range(count-1):
                        pre_list2.remove(i)
        counter += 1
        
        for i in black_bordered_centers:
            count=0
            for j in black_bordered_centers:
                if i == j:
                    count += 1
            if count >=2:
                for k in range(count-1):
                    black_bordered_centers.remove(i)

        return black_bordered_centers
def grid_centers_selection(gridcenters:list):
        """
        returns gridcenters_selected (contains information of the grid and its pos)
        example: -> [[2,2,345,678]] means the 2nd,2nd grid is at coordinate (345,678)
        Args:
            gridcenters (list): The list containing information of the coordinates of grid centers
        """
    
        lx=[item[:] for item in gridcenters]
        for j in range(len(gridcenters)):
            for  i in range(len(gridcenters)-1): #bubble-sort ascending order
                if lx[i][0] > lx[i+1][0]:
                    tem = lx[i]
                    lx[i]=lx[i+1]   
                    lx[i+1]=tem
    
        ly=[item[:] for item in gridcenters]
        for j in range(len(gridcenters)):
            for i in range(len(gridcenters)-1): #bubble-sort ascending order
                if ly[i][1] > ly[i+1][1]:
                    tem = ly[i]
                    ly[i]=ly[i+1]
                    ly[i+1]=tem
        gridcenters=[]
    
        for i in range(len(ly)):
            if i <= 2:
                for j in range(len(lx)):
                    if j <= 2 and lx[j] == ly[i]:
                        gridcenters.append([2,2,ly[i][0],ly[i][1]])
                    if (j >= 3 and j <= 5)and ly[i]==lx[j]:
                        gridcenters.append([2,1,ly[i][0],ly[i][1]])
                    if (j >= 6)and ly[i]==lx[j]:
                        gridcenters.append([2,0,ly[i][0],ly[i][1]])
                    
            if i >= 3 and i <= 5:
                for j in range(len(lx)):
                    if (j >= 3 and j <= 5)and ly[i]==lx[j]:
                        gridcenters.append([1,1,ly[i][0],ly[i][1]])
                    if j <= 2 and lx[j] == ly[i]:
                        gridcenters.append([1,2,ly[i][0],ly[i][1]])
                    if (j >= 6)and ly[i]==lx[j]:
                        gridcenters.append([1,0,ly[i][0],ly[i][1]])
            if i >= 6:
                for j in range(len(lx)):
                    if (j >= 6)and ly[i]==lx[j]:
                        gridcenters.append([0,0,ly[i][0],ly[i][1]])
                    if (j >= 3 and j <= 5)and ly[i]==lx[j]:
                        gridcenters.append([0,1,ly[i][0],ly[i][1]])
                    if j <= 2 and lx[j] == ly[i]:
                        gridcenters.append([0,2,ly[i][0],ly[i][1]])
        for j in range(len(gridcenters)):
            for i in range(len(gridcenters)-1): #bubble-sort ascending order
                if gridcenters[i][0] > gridcenters[i+1][0]:
                    tem = gridcenters[i]
                    gridcenters[i]=gridcenters[i+1]
                    gridcenters[i+1]=tem
        return gridcenters  
                

def distance_grid(grid_centers):
    """
    改进：使用中位数计算格子间距。
    """
    grid_list = grid_centers_selection(grid_centers)
    distances_x = []
    distances_y = []
    
    for i in range(len(grid_list) - 1):
        if grid_list[i][0] == grid_list[i+1][0]:  # 同一行
            distances_x.append(abs(grid_list[i][2] - grid_list[i+1][2]))
        #if grid_list[i][1] == grid_list[i+1][1]:  # 同一列
        #    distances_y.append(abs(grid_list[i][3] - grid_list[i+1][3]))
    
    res_x = np.median(distances_x) / 2 if distances_x else 0
    res_y = res_x
    return res_x, res_y



def in_grid_pos(circle_point,circle_type, grid_centers):
    """
    找到给定点所属的格子中心并返回所属格子在二维列表中的位置,用list,比如 [0,1,1] 代表这个格子在第0行第一列,同时为白棋

    参数：
        circle_point (tuple): 给定的点坐标 (x, y)。
        grid_centers (list): 格子中心的坐标列表。

    返回：
        并返回所属格子在二维列表中的位置,list,比如 [0,1,1] 代表这个格子在第0行第一列,而且该棋子为白棋
    """
    tolerance=-0.3

    distance=distance_grid(grid_centers)
    gridcenters = grid_centers_selection(grid_centers)

    for i in gridcenters:
            if (circle_point[0] >= int(float(i[2])-distance[0]*(1+tolerance))) and (circle_point[0]<= int(float(i[2])+distance[0]*(1+tolerance))):
                if (circle_point[1] >= int(float(i[3])-distance[1]*(1+tolerance))) and (circle_point[1]<= int(float(i[3])+distance[1]*(1+tolerance))):
                    return [i[0],i[1],circle_type]

                
                
        



# 示例用法
if __name__ == "__main__":
# 打开摄像头
    cap = cv2.VideoCapture(1)
    previousboard = []
    while True:
        ret, frame = cap.read()
        if not ret:
            print("Error reading frame from camera.")
            break
        # 检测棋盘状态
    
        chessboard_state,previousboard = detect_chessboard(frame, previousboard,board_size=(3, 3))
        
    
        # 显示带有标注的图像
        
        cv2.imshow("Detected Chessboard", frame)
        # 如果按下 'q' 键，则退出循环
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    # 释放摄像头并关闭所有 OpenCV 窗口
    cap.release()
    cv2.destroyAllWindows()