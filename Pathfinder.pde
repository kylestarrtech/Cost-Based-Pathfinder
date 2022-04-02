

final int sizeX = 960, sizeY = 640; //Has to be a multiple of gridSize w/ a minimum of a 10x10 Grid System (10(gridSize)x10(gridSize)).
GridElement[][] grid;
int gridRows, gridColumns;
int gridSize = 32; //Pixels - Try to keep the number a power of 2 and above 10. 8 minimum, but 8 is also VERY slow.
int xPointer, yPointer;
PImage maze;

int currentCost;
int pX, pY, gX, gY;
boolean goalFound = false, alreadyCalled = false, playerFound;
int tracebackIterations = 0;
GridElement gridPointer;

void setup()
{
  size(960, 640);
  gridRows = sizeX / gridSize;
  gridColumns = sizeY / gridSize;
  maze = loadImage("maze1.png");
  if (sizeX % gridSize == 0 && sizeY % gridSize == 0)
  {
    grid = new GridElement[gridRows][gridColumns];
    for (int i = 0; i < gridRows; i++)
    {
      for (int j = 0; j < gridColumns; j++)
      {
        grid[i][j] = new GridElement();
        grid[i][j].state = InitialStateFinder(i, j);
        grid[i][j].x = i;
        grid[i][j].y = j;
      }
    }
  }
  DrawGrid();
}

void draw()
{
  background(96, 96, 96);
  DrawGrid();
  fill(128);
  //textSize(24);
  //text(mouseX, 50, 50);
  //text(mouseY, 50, 100);
  text(floor(mouseX/gridSize), 50, 150);
  text(floor(mouseY/gridSize), 50, 200);
  text(gridRows, 50, 250);
  text(gridColumns, 50, 300);
  Highlights();

  if (mousePressed)
  {
    if (!alreadyCalled) {
      InitPathfinding();
      alreadyCalled = true;
    } else
    {
      if (!playerFound)
      {
        AssignCosts();
      }
    }
  } else if (key == ' ')
  {
    //println("SPACE");
  }
}

void Highlights()
{
  noStroke();
  fill(0, 255, 0, 128);

  if (mouseX <= sizeX && mouseY <= sizeY)
  {
    rect(floor(mouseX/gridSize)*gridSize, floor(mouseY/gridSize)*gridSize, gridSize, gridSize);
  }
}

void mouseReleased()
{
  int x = mouseX/gridSize;
  int y = mouseY/gridSize;
  if (x < gridRows && y < gridColumns && x >= 0 && y >= 0)
  {
    grid[x][y].state++;
    if (grid[x][y].state > 3)
    {
      grid[x][y].state = 0;
    }
  }
}

void keyPressed()
{
  if (true)
  {
    if (!alreadyCalled) {
      InitPathfinding();
      alreadyCalled = true;
    } else
    {
      if (!playerFound)
      {
        AssignCosts();
      }
    }
  } else if (key == ' ')
  {
    //println("SPACE");
  }
}

void DrawGrid()
{
  xPointer = 0;
  yPointer = 0;
  for (int i = 0; i < gridRows; i++)
  {
    for (int j = 0; j < gridColumns; j++)
    {
      switch (grid[i][j].state)
      {
      case 0:
        fill(255, 255, 255);
        break;
      case 1:
        fill(0, 0, 0);
        break;
      case 2:
        fill(128, 128, 255);
        break;
      case 3:
        fill(255, 255, 159);
        break;
      }
      if (grid[i][j].cost != 0 && grid[i][j].state != 2)
      {
        fill(255, 96, 255);
      }
      if (grid[i][j].traced && grid[i][j].state != 2)
      {
        fill(255, 0, 0);
      }
      stroke(0);
      strokeWeight(2);
      rect(xPointer, yPointer, gridSize, gridSize);
      textSize(gridSize/2);
      fill(0, 0, 0);
      text(grid[i][j].cost, xPointer, yPointer + gridSize);
      yPointer += gridSize;
    }
    xPointer += gridSize;
    yPointer = 0;
  }
}

int InitialStateFinder(int x, int y)
{
  color c = maze.get(x, y);
  ////print(c);
  if (c == #000000)
  {
    //print("Wall.\n");
    return 1;
  } else if (c == #0000FF)
  {
    //print("Player.\n");
    return 2;
  } else if (c == #00FF00)
  {
    //print("Goal.\n");
    return 3;
  } else
  {
    //print("None true.\n");
    return 0;
  }
}

public void InitPathfinding()
{
  //print("\n----------\nPATHFINDING INITIALIZATION\n----------\n");
  pX=0;
  pY=0;
  for (int i = 0; i < gridRows; i++)
  {
    for (int j = 0; j < gridColumns; j++)
    {
      if (grid[i][j].state == 2)
      {
        pX = i;
        pY = j;
      }
    }
  }
  //println("PLAYER LOCATION SET TO: {" + pX + ", " + pY + "}!");
  currentCost = 0;
  //do
  //{
  AssignCosts();
  //} while (!goalFound);
}

public void AssignCosts()
{
  if (!goalFound)
  {
    //println("ASSIGNCOSTS() STARTING...");
    ArrayList<GridElement> costs = new ArrayList<GridElement>();
    //println("ARRAYLIST COSTS INITIALIZED");
    //println("CURRENTCOST: " + currentCost);
    if (currentCost == 0)
    {
      costs.add(grid[pX][pY]);
      //println("FIRST ITERATION? PLAYER POSITION SET TO COSTS!");
    }
    if (currentCost > 0) {
      for (int i = 0; i < gridRows; i++)
      {
        //println("LOOPING THRU XPOS: " + i);
        for (int j = 0; j < gridColumns; j++)
        {
          //println("   LOOPING THRU YPOS: " + j);
          if (grid[i][j].cost == currentCost)
          {
            costs.add(grid[i][j]);
            //println("      GRID ELEMENT {" + i + ", " + j + "} ADDED!");
          }
        }
      }
    }
    //println("COSTS LIST SIZE: " + costs.size());
    for (GridElement ge : costs)
    {
      GridElement above = null, below = null, left = null, right = null;
      if (ge.y != 0) {
        above = grid[ge.x][ge.y-1];
      }
      if (ge.y != gridColumns-1) {
        below = grid[ge.x][ge.y+1];
      }
      if (ge.x != 0) {
        left = grid[ge.x-1][ge.y];
      }
      if (ge.x != gridRows-1) {
        right = grid[ge.x+1][ge.y];
      }
      if (above != null && !goalFound)
      {
        if (above.state == 0 && above.cost == 0)
        {
          above.cost = currentCost + 1;
        }
        if (above.state == 3)
        {
          gX = above.x;
          gY = above.y;
          goalFound = true;
        }
      }
      if (below != null && !goalFound)
      {
        if (below.state == 0 && below.cost == 0)
        {
          below.cost = currentCost + 1;
        }
        if (below.state == 3)
        {
          gX = below.x;
          gY = below.y;
          goalFound = true;
        }
      }
      if (left != null && !goalFound)
      {
        if (left.state == 0 && left.cost == 0)
        {
          left.cost = currentCost + 1;
        }
        if (left.state == 3)
        {
          gX = left.x;
          gY = left.y;
          goalFound = true;
        }
      }
      if (right != null && !goalFound)
      {
        if (right.state == 0 && right.cost == 0)
        {
          right.cost = currentCost + 1;
        }
        if (right.state == 3)
        {
          gX = right.x;
          gY = right.y;
          goalFound = true;
        }
      }
    }

    currentCost++;
  }
  if (goalFound && tracebackIterations == 0)
  {
    //println("GOAL FOUND!!!");
    //println("FINAL CURRENTCOST: " + currentCost);
    gridPointer = grid[gX][gY];
    TraceBack();
  } else if (tracebackIterations != 0)
  {
    TraceBack();
  } else
  {
    //AssignCosts();
  }
}

public void TraceBack()
{
  GridElement above = null, below = null, left = null, right = null;
  int gPX = gridPointer.x, gPY = gridPointer.y;
  if (gPY != 0) {
    above = grid[gPX][gPY-1];
  }
  if (gPY != gridColumns-1) {
    below = grid[gPX][gPY+1];
  }
  if (gPX != 0) {
    left = grid[gPX-1][gPY];
  }
  if (gPX != gridRows-1) {
    right = grid[gPX+1][gPY];
  }
  boolean traceBackFound = false;
  if (above != null && !traceBackFound)
  {
    if (above.cost == currentCost - 1 && above.state != 1)
    {
      traceBackFound = true;
      gridPointer = above;
      above.traced = true;
    }
    if (above.state == 2)
    {
      playerFound = true;
    }
  }
  if (below != null && !traceBackFound)
  {
    if (below.cost == currentCost - 1 && below.state != 1)
    {
      traceBackFound = true;
      gridPointer = below;
      below.traced = true;
    }
    if (below.state == 2)
    {
      playerFound = true;
    }
  }
  if (left != null && !traceBackFound)
  {
    if (left.cost == currentCost - 1 && left.state != 1)
    {
      traceBackFound = true;
      gridPointer = left;
      left.traced = true;
    }
    if (left.state == 2)
    {
      playerFound = true;
    }
  }
  if (right != null && !traceBackFound)
  {
    if (right.cost == currentCost - 1 && right.state != 1)
    {
      traceBackFound = true;
      gridPointer = right;
      right.traced = true;
    }
    if (right.state == 2 )
    {
      playerFound = true;
    }
  }
  if (traceBackFound)
  {
    currentCost--;
    tracebackIterations++;
  }
  if (playerFound)
  {
    //println("PLAYER FOUND!");
  } else
  {
    //TraceBack();
  }
}
