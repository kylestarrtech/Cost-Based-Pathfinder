 class GridElement
{
  int state; //0=Free 1=Wall 2=Player 3=Goal
  int cost; //Assigned during pathfinding.
  /* When a goal is assigned a cost, stop pathfinding.
  Trace that goal backwards to the player by comparing costs around the object.*/
  int x, y; //Find their place in the grid.
  boolean traced = false; //True if the grid element has been used as a traceback.
}
